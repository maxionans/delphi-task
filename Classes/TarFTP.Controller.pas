unit TarFTP.Controller;

interface

uses
  Windows, SysUtils, Dialogs, Classes, TarFTP.MVC, Generics.Collections;

type
  TViewRegistry = TDictionary<TGUID, IView>;

  TController = class(TInterfacedObject, IController)
  private
    FModel: IModel;
    FViewRegistry : TViewRegistry;
    procedure TaskEvent(Task : TTaskKind; State : TTaskState);
  public
  { IController }
    procedure RegisterView(const Kind : TGUID; const View : IView);
    procedure CompressAndUpload;

  { Common }
    constructor Create(const Model : IModel);
    destructor Destroy; override;
  end;

implementation

uses
  IOUtils;

{ TController }

constructor TController.Create(const Model: IModel);
begin
  Assert( Assigned( Model ), 'Model is unassigned' );

  FViewRegistry := TViewRegistry.Create;
  FModel := Model;
  FModel.OnTaskEvent := Self.TaskEvent;
end;

destructor TController.Destroy;
begin
  FModel := nil;
  FreeAndNil( FViewRegistry );
  inherited;
end;

procedure TController.RegisterView(const Kind: TGUID; const View: IView);
begin
  Assert( Assigned( View ), 'View is unassigned' );
  FViewRegistry.AddOrSetValue( Kind, View );
end;

procedure TController.TaskEvent(Task: TTaskKind; State: TTaskState);
var
  view : IView;
begin
  case Task of
    tkCompress : view := FViewRegistry[ IFileCompressionView ];
    tkUpload : view := FViewRegistry[ IFileUploadView ];
  else
    Exit;
  end;

  if State = tsBeforeStarted then
    view.Display
  else
    begin
      view.Close;
      FViewRegistry[ IMainView ].ProcessErrors;

      if not ( FModel.Error or FModel.Terminated ) then
        if ( Task = tkCompress ) then
          FModel.Upload
        else
          ShowMessage( 'File sent' );
    end;
end;

procedure TController.CompressAndUpload;
var
  fileName : String;
begin
  FModel.Reset;
  fileName := TPath.GetTempFileName;
  DeleteFile( fileName );
  fileName := ChangeFileExt( fileName, '.tar' );
  FModel.SetOutputFile( fileName );
  FModel.Compress;
end;

end.
