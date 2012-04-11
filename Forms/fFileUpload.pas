unit fFileUpload;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TarFTP.MVC, Diagnostics, TarFTP.Utils,
  ExtCtrls;

type
  TfrmFileUpload = class(TForm, IView, IFileUploadView)
    Label1: TLabel;
    lblFilesProcessed: TLabel;
    lblTimeElapsed: TLabel;
    ProgressBar1: TProgressBar;
    btnStop: TButton;
    lblSpeed: TLabel;
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

    procedure DoFileUpload(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64; const ElapsedTime : TDateTime);
    procedure FileUpload(CurrentItem, TotalItems: Integer; BytesProcessed,
        TotalBytes: Int64);
  public
    procedure SetController(const Controller : IController);
    procedure SetModel(const Model : IModel);

    procedure Display;
    procedure ProcessErrors;
  end;

var
  frmFileUpload: TfrmFileUpload;

implementation

{$R *.dfm}

procedure TfrmFileUpload.btnStopClick(Sender: TObject);
begin
  FModel.TerminateTask;
  btnStop.Enabled := False;
  Label1.Caption := 'Terminating...';
end;

procedure TfrmFileUpload.Display;
begin
  Label1.Caption := 'Uploading files. Plase wait...';
  FileUpload( 1, 1, 0, 0 );
  DoFileUpload( 1, 1, 0, 0, EncodeTime( 0, 0, 0, 0 ) );
  FStopwatch := TStopwatch.StartNew;
  FStopwatch.Start;
  Show;
end;

procedure TfrmFileUpload.DoFileUpload(CurrentItem, TotalItems: Integer;
  BytesProcessed, TotalBytes: Int64; const ElapsedTime: TDateTime);
var
  speed : Single;
begin
  lblFilesProcessed.Caption := Format(
    'Uploading %d out of %d total files',
    [ CurrentItem, TotalItems ]
  );

  lblTimeElapsed.Caption := 'Elapsed time: ' + TimeToStr( ElapsedTime );

  if TotalBytes > 0 then
    ProgressBar1.Position := BytesProcessed * 100 div TotalBytes
  else
    ProgressBar1.Position := 0;

  if FStopwatch.ElapsedMilliseconds > 0 then
    speed := BytesProcessed * 1000 / FStopwatch.ElapsedMilliseconds
  else
    speed := 0;

  lblSpeed.Caption := 'Speed: ' + SizeToStr( Round( speed ) );
end;

procedure TfrmFileUpload.FileUpload(CurrentItem, TotalItems: Integer;
    BytesProcessed, TotalBytes: Int64);
begin
  FCurrentItem := CurrentItem;
  FTotalItems := TotalItems;
  FBytesProcessed := BytesProcessed;
  FTotalBytes := TotalBytes;
end;

procedure TfrmFileUpload.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmUpdate.Enabled := False;
  Application.MainForm.Enabled := True;
end;

procedure TfrmFileUpload.FormShow(Sender: TObject);
begin
  tmUpdate.Enabled := True;
  Application.MainForm.Enabled := False;
end;

procedure TfrmFileUpload.ProcessErrors;
begin
  // do nothing
end;

procedure TfrmFileUpload.SetController(const Controller: IController);
begin
  FController := Controller;
  if Assigned( FController ) then
    FController.RegisterView( IFileUploadView, Self );
end;

procedure TfrmFileUpload.SetModel(const Model: IModel);
begin
  FModel := Model;
  if Assigned( FModel ) then
    FModel.OnFileUpload := Self.FileUpload;
end;

procedure TfrmFileUpload.tmUpdateTimer(Sender: TObject);
var
  elapsedTime : TDateTime;
begin
  elapsedTime := EncodeTime(
    FStopwatch.Elapsed.Hours, FStopwatch.Elapsed.Minutes,
    FStopwatch.Elapsed.Seconds, FStopwatch.Elapsed.Milliseconds
  );

  DoFileUpload(
    FCurrentItem, FTotalItems, FBytesProcessed, FTotalBytes, elapsedTime
  );
end;

end.
