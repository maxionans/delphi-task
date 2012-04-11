unit fMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ActnList, TarFTP.MVC, ExtCtrls, XPMan;

type
  TfrmMainForm = class(TForm, IView, IMainView)
    Label1: TLabel;
    edFtpServer: TEdit;
    Label2: TLabel;
    edUserName: TEdit;
    Label3: TLabel;
    edPassword: TEdit;
    lvFiles: TListView;
    btnAdd: TButton;
    btnRemove: TButton;
    ActionList: TActionList;
    acAddFiles: TAction;
    acRemoveSelected: TAction;
    btnSendFiles: TButton;
    acSendFiles: TAction;
    OpenDialog: TOpenDialog;
    tmErrorHandler: TTimer;
    XPManifest1: TXPManifest;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acAddFilesExecute(Sender: TObject);
    procedure acRemoveSelectedExecute(Sender: TObject);
    procedure acSendFilesExecute(Sender: TObject);
    procedure tmErrorHandlerTimer(Sender: TObject);
  private
    { Private declarations }
    FOldWndProc : TWndMethod;
    FFiles : TStrings;
    FModel : IModel;
    FController : IController;

    procedure AddFile(const FileName : String);
    procedure ListViewWndMethod(var Message : TMessage);
  public
    { Public declarations }
    procedure SetModel(const Model : IModel);
    procedure SetController(const Controller : IController);
    procedure Display;
    procedure ProcessErrors;
  end;

var
  frmMainForm: TfrmMainForm;

implementation

uses
  ShellApi, TarFTP.Utils;

{$R *.dfm}

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  lvFiles.WindowProc := FOldWndProc;
  FreeAndNil( FFiles );
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FOldWndProc := lvFiles.WindowProc;
  lvFiles.WindowProc := ListViewWndMethod;
  DragAcceptFiles( lvFiles.Handle, True );
  FFiles := TStringList.Create;
end;

procedure TfrmMainForm.ListViewWndMethod(var Message: TMessage);
var
  drop : HDROP;
  index : Integer;
  fileName : PChar;
begin
  if Message.Msg = WM_DROPFILES then
    begin
      drop := Message.WParam;
      try
        index := 0;
        fileName := AllocMem( $10000 );
        repeat
          if DragQueryFile( drop, index, fileName, $10000 ) = 0 then Break;
          AddFile( fileName );
          Inc( index );
        until False;
      finally
        DragFinish( drop );
      end
    end
  else
    FOldWndProc( Message );
end;

procedure TfrmMainForm.ProcessErrors;
begin
  tmErrorHandler.Enabled := True;
end;

procedure TfrmMainForm.SetController(const Controller: IController);
begin
  FController := Controller;
  if Assigned( FController ) then
    FController.RegisterView( IMainView, Self );
end;

procedure TfrmMainForm.SetModel(const Model: IModel);
begin
  FModel := Model;
end;

procedure TfrmMainForm.acAddFilesExecute(Sender: TObject);
var
  fileName : String;
begin
  if OpenDialog.Execute then
    for fileName in OpenDialog.Files do
      AddFile( fileName );
end;

procedure TfrmMainForm.acRemoveSelectedExecute(Sender: TObject);
var
  I : Integer;
begin
  lvFiles.Items.BeginUpdate;
  try
    for I := lvFiles.Items.Count - 1 downto 0 do
      if lvFiles.Items[ I ].Selected then
        begin
          lvFiles.Items[ I ].Delete;
          FFiles.Delete( I );
        end;
  finally
    lvFiles.Items.EndUpdate;
  end;
end;

procedure TfrmMainForm.acSendFilesExecute(Sender: TObject);
var
  fileName : String;
begin
  if lvFiles.Items.Count = 0 then
    begin
      Application.MessageBox(
        'No files were selected to upload.'#13#10 +
        'Please select at least a single file.',
        'Information',
        MB_OK or MB_ICONINFORMATION
      );
      acAddFiles.Execute;
      Abort;
    end;

  if edFtpServer.Text = '' then
    begin
      Application.MessageBox(
        'Please specify FTP host',
        'Information',
        MB_OK or MB_ICONINFORMATION
      );
      edFtpServer.SetFocus;
      Abort;
    end;

  for fileName in FFiles do
    FModel.AddFile( fileName );

  FModel.SetFtpCredentials(
    edFtpServer.Text, edUserName.Text, edPassword.Text
  );

  FController.CompressAndUpload;
end;

procedure TfrmMainForm.AddFile(const FileName: String);
begin
  if FileExists( FileName ) then
    with lvFiles.Items.Add do
    begin
      Caption := ExtractFileName( FileName );
      SubItems.Add( SizeToStr( GetFileSize( FileName ) ) );
      SubItems.Add( ExtractFileDir( FileName ) );
      FFiles.Add( FileName );
    end;
end;

procedure TfrmMainForm.Display;
begin
  Show;
end;

procedure TfrmMainForm.tmErrorHandlerTimer(Sender: TObject);
begin
  tmErrorHandler.Enabled := False;
  FModel.NeedError;
end;

end.
