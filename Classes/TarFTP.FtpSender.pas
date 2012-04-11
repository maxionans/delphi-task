unit TarFTP.FtpSender;

interface

uses
  SysUtils, TarFTP.Interfaces, IdComponent, IdTCPConnection, IdFtp,
  IdFTPCommon, TarFTP.Utils;

type
  TFtpSender = class(TInterfacedObject, IFtpSender)
  private
    FFtp : TIdFTP;
    FOnProgress : TProgressEvent;
    FTotalBytes : Int64;
    procedure Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure DoProgress(CurrentItem, TotalItems : Integer;
        BytesProcessed, TotalBytes : Int64);
  public
  { IFtpSender }
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure LogIn(const Url, Login, Password: string);
    procedure UploadFile(const FileName : String);
    procedure Abort;
    procedure Disconnect;

  { Common }
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TFtpSender }

procedure TFtpSender.Abort;
begin
  FFtp.Abort;
  FFtp.Disconnect;
end;

constructor TFtpSender.Create;
begin
  FFtp := TIdFTP.Create;
end;

destructor TFtpSender.Destroy;
begin
  FreeAndNil( FFtp );
  inherited;
end;

procedure TFtpSender.Disconnect;
begin
  if FFtp.Connected then FFtp.Disconnect;
end;

procedure TFtpSender.DoProgress(CurrentItem, TotalItems: Integer;
  BytesProcessed, TotalBytes: Int64);
begin
  if Assigned( FOnProgress ) then
    FOnProgress( CurrentItem, TotalItems, BytesProcessed, TotalBytes );
end;

function TFtpSender.GetOnProgress: TProgressEvent;
begin
  Result := FOnProgress;
end;

procedure TFtpSender.LogIn(const Url, Login, Password: string);
begin
  FFtp.Host := Url;

  FFtp.Username := Login;
  FFtp.Password := Password;

  FFtp.Connect;
end;

procedure TFtpSender.SetOnProgress(Value: TProgressEvent);
begin
  FOnProgress := Value;
end;

procedure TFtpSender.UploadFile(const FileName: String);
begin
  FTotalBytes := GetFileSize( FileName );
  FFtp.OnWork := Self.Work;
  FFtp.IOHandler.OnWork := Self.Work;
  FFtp.IOHandler.SendBufferSize := $10000;
  FFtp.Put( FileName );
end;

procedure TFtpSender.Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  DoProgress( 1, 1, AWorkCount, FTotalBytes );
end;

end.
