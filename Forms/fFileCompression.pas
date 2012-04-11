unit fFileCompression;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, TarFTP.MVC, ExtCtrls, Diagnostics;

type
  TfrmFileCompression = class(TForm, IView, IFileCompressionView)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    lblFilesProcessed: TLabel;
    lblTimeElapsed: TLabel;
    btnStop: TButton;
    tmUpdate: TTimer;
    procedure btnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure tmUpdateTimer(Sender: TObject);
  private
    { Private declarations }
    FModel : IModel;
    FController : IController;
    FStopwatch : TStopwatch;
    FCurrentItem : Integer;
    FTotalItems : Integer;
    FBytesProcessed : Int64;
    FTotalBytes : Int64;

    procedure DoFileCompress(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64; const ElapsedTime : TDateTime);
    procedure FileCompress(CurrentItem, TotalItems: Integer; BytesProcessed,
        TotalBytes: Int64);
  public
    procedure SetModel(const Model: IModel);
    procedure SetController(const Controller: IController);
    procedure Display;
    procedure ProcessErrors;
  end;

var
  frmFileCompression: TfrmFileCompression;

implementation

{$R *.dfm}

procedure TfrmFileCompression.btnStopClick(Sender: TObject);
begin
  FModel.ForcedTerminateTask;
end;

{ TfrmFileCompression }

procedure TfrmFileCompression.Display;
begin
  FileCompress( 0, 0, 0, 0 );
  DoFileCompress( 0, 0, 0, 0, EncodeTime( 0, 0, 0, 0 ) );

  FStopwatch := TStopwatch.StartNew;
  FStopwatch.Start;

  Show;
end;

procedure TfrmFileCompression.DoFileCompress(CurrentItem, TotalItems: Integer;
  BytesProcessed, TotalBytes: Int64; const ElapsedTime: TDateTime);
begin
  lblFilesProcessed.Caption := Format(
    'Compressing %d out of %d total files',
    [ CurrentItem, TotalItems ]
  );

  lblTimeElapsed.Caption := 'Elapsed time: ' + TimeToStr( ElapsedTime );

  if TotalBytes > 0 then
    ProgressBar1.Position := BytesProcessed * 100 div TotalBytes
  else
    ProgressBar1.Position := 0;
end;

procedure TfrmFileCompression.FileCompress(CurrentItem, TotalItems: Integer;
    BytesProcessed, TotalBytes: Int64);
begin
  FCurrentItem := CurrentItem;
  FTotalItems := TotalItems;
  FBytesProcessed := BytesProcessed;
  FTotalBytes := TotalBytes;
end;

procedure TfrmFileCompression.FormClose(Sender: TObject; var Action:
    TCloseAction);
begin
  Application.MainForm.Enabled := True;
  tmUpdate.Enabled := False;
end;

procedure TfrmFileCompression.FormShow(Sender: TObject);
begin
  Application.MainForm.Enabled := False;
  tmUpdate.Enabled := True;
end;

procedure TfrmFileCompression.ProcessErrors;
begin
  // do nothing
end;

procedure TfrmFileCompression.SetController(const Controller: IController);
begin
  FController := Controller;
  if Assigned( FController ) then
    FController.RegisterView( IFileCompressionView, Self );
end;

procedure TfrmFileCompression.SetModel(const Model: IModel);
begin
  FModel := Model;
  if Assigned( FModel ) then
    FModel.OnFileCompress := Self.FileCompress;
end;

procedure TfrmFileCompression.tmUpdateTimer(Sender: TObject);
var
  elapsedTime : TDateTime;
begin
  elapsedTime := EncodeTime(
    FStopwatch.Elapsed.Hours, FStopwatch.Elapsed.Minutes,
    FStopwatch.Elapsed.Seconds, FStopwatch.Elapsed.Milliseconds
  );

  DoFileCompress(
    FCurrentItem, FTotalItems, FBytesProcessed, FTotalBytes, elapsedTime
  );
end;

end.
