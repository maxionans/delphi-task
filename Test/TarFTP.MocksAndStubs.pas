unit TarFTP.MocksAndStubs;

interface

uses
  SysUtils, Classes, TarFTP.Interfaces, TarFTP.MVC,
  TarFTP.Factory;

type
  TArchiverStub = class(TInterfacedObject, IArchiver)
  public
  { IArchiver }
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure AddFile(const FileName : String);
    procedure CompressToFile(const OutputFile : String);
  end;

  TFtpSenderStub = class(TInterfacedObject, IFtpSender)
  public
  { IFtpSender }
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure EstablishConnection(const Url : String);
    procedure LogIn(const Url, Login, Password: string);
    procedure UploadFile(const FileName : String);
    procedure Abort;
    procedure Disconnect;
  end;

  TModelStub = class(TInterfacedObject, IModel)
  public
  { IModel }
    function GetOnFileCompress : TWorkProgressEvent;
    procedure SetOnFileCompress(Value : TWorkProgressEvent);
    property OnFileCompress : TWorkProgressEvent read GetOnFileCompress
        write SetOnFileCompress;

    function GetOnFileUpload : TWorkProgressEvent;
    procedure SetOnFileUpload(Value : TWorkProgressEvent);
    property OnFileUpload : TWorkProgressEvent read GetOnFileUpload
        write SetOnFileUpload;

    function GetOnTaskEvent : TModelNotifyEvent;
    procedure SetOnTaskEvent(Value : TModelNotifyEvent);
    property OnTaskEvent : TModelNotifyEvent read GetOnTaskEvent
        write SetOnTaskEvent;

    function GetTerminated : Boolean;
    property Terminated : Boolean read GetTerminated;

    function GetError : Boolean;
    property Error: Boolean read GetError;

    procedure Reset;
    procedure AddFile(const FileName : String);
    procedure SetOutputFile(const OutputFile : String);
    procedure SetFtpCredentials(const Host, Login, Password: string);
    procedure NeedError;

    procedure Compress;
    procedure Upload;

    procedure TerminateTask;
    procedure ForcedTerminateTask;
  end;

  TArchiverMock = class(TInterfacedObject, IArchiver)
  private
    FAddFile_FileName: String;
    FArchiver: IArchiver;
    FCompressToFile_OutputFile: String;
  public
  { IArchiver }
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure AddFile(const FileName : String);
    procedure CompressToFile(const OutputFile : String);

  { Common }
    property AddFile_FileName: String read FAddFile_FileName
        write FAddFile_FileName;
    property CompressToFile_OutputFile: String read FCompressToFile_OutputFile
        write FCompressToFile_OutputFile;

    constructor Create;
    destructor Destroy; override;
  end;

  TFtpSenderMock = class(TInterfacedObject, IFtpSender)
  private
    FLogIn_Url: String;
    FLogIn_Login: String;
    FLogIn_Password: String;
    FUploadFile_FileName: String;
    FDisconnectCalled: Boolean;
    FFtpSender: IFtpSender;
  public
  { IFtpSender }
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure LogIn(const Url, Login, Password : String);
    procedure UploadFile(const FileName : String);
    procedure Abort;
    procedure Disconnect;

  { Common }
    property LogIn_Url: String read FLogIn_Url write FLogIn_Url;
    property LogIn_Login: String read FLogIn_Login write FLogIn_Login;
    property LogIn_Password: String read FLogIn_Password write FLogIn_Password;
    property UploadFile_FileName: String read FUploadFile_FileName
        write FUploadFile_FileName;
    property DisconnectCalled: Boolean read FDisconnectCalled write FDisconnectCalled;

    constructor Create;
    destructor Destroy; override;
  end;

  TFactoryMock = class(TInterfacedObject, IFactory)
  private
    FArchiver : IArchiver;
    FFtpSender : IFtpSender;
  public
  { IFactory }
    function CreateArchiver : IArchiver;
    function CreateFtpSender : IFtpSender;
    function CreateTask : ITask;

  { Common }
    property Archiver: IArchiver read FArchiver write FArchiver;
    property FtpSender: IFtpSender read FFtpSender write FFtpSender;

    destructor Destroy; override;
  end;

implementation

uses TarFTP.Tasks;

{ TArchiverStub }

procedure TArchiverStub.AddFile(const FileName: String);
begin
end;

procedure TArchiverStub.CompressToFile(const OutputFile: String);
begin
  with TStringList.Create do
  try
    SaveToFile( OutputFile );
  finally
    Free;
  end;
end;

function TArchiverStub.GetOnProgress: TProgressEvent;
begin
  Result := nil;
end;

procedure TArchiverStub.SetOnProgress(Value: TProgressEvent);
begin

end;

{ TFtpSenderStub }

procedure TFtpSenderStub.Abort;
begin

end;

procedure TFtpSenderStub.Disconnect;
begin

end;

procedure TFtpSenderStub.EstablishConnection(const Url: String);
begin

end;

function TFtpSenderStub.GetOnProgress: TProgressEvent;
begin
  Result := nil;
end;

procedure TFtpSenderStub.LogIn(const Url, Login, Password: string);
begin

end;

procedure TFtpSenderStub.SetOnProgress(Value: TProgressEvent);
begin

end;

procedure TFtpSenderStub.UploadFile(const FileName: String);
begin

end;

{ TModelStub }

procedure TModelStub.AddFile(const FileName: String);
begin

end;

procedure TModelStub.Compress;
begin

end;

procedure TModelStub.ForcedTerminateTask;
begin

end;

function TModelStub.GetError: Boolean;
begin
  Result := False;
end;

function TModelStub.GetOnFileCompress: TWorkProgressEvent;
begin
  Result := nil;
end;

function TModelStub.GetOnFileUpload: TWorkProgressEvent;
begin
  Result := nil;
end;

function TModelStub.GetOnTaskEvent: TModelNotifyEvent;
begin
  Result := nil;
end;

function TModelStub.GetTerminated: Boolean;
begin
  Result := False;
end;

procedure TModelStub.NeedError;
begin

end;

procedure TModelStub.Reset;
begin

end;

procedure TModelStub.SetFtpCredentials(const Host, Login, Password: string);
begin

end;

procedure TModelStub.SetOnFileCompress(Value: TWorkProgressEvent);
begin

end;

procedure TModelStub.SetOnFileUpload(Value: TWorkProgressEvent);
begin

end;

procedure TModelStub.SetOnTaskEvent(Value: TModelNotifyEvent);
begin

end;

procedure TModelStub.SetOutputFile(const OutputFile: String);
begin

end;

procedure TModelStub.TerminateTask;
begin

end;

procedure TModelStub.Upload;
begin

end;

{ TFactoryMock }

function TFactoryMock.CreateArchiver: IArchiver;
begin
  Result := FArchiver;
end;

function TFactoryMock.CreateFtpSender: IFtpSender;
begin
  Result := FFtpSender;
end;

function TFactoryMock.CreateTask: ITask;
begin
  Result := TSimpleTask.Create;
end;

destructor TFactoryMock.Destroy;
begin
  FArchiver := nil;
  FFtpSender := nil;
  inherited;
end;

{ TArchiverMock }

procedure TArchiverMock.AddFile(const FileName: String);
begin
  FAddFile_FileName := FileName;
  FArchiver.AddFile( FileName );
end;

procedure TArchiverMock.CompressToFile(const OutputFile: String);
begin
  FCompressToFile_OutputFile := OutputFile;
  FArchiver.CompressToFile( OutputFile );
end;

constructor TArchiverMock.Create;
begin
  with TFactory.Create do
  try
    FArchiver := CreateArchiver;
  finally
    Free;
  end;
end;

destructor TArchiverMock.Destroy;
begin
  FArchiver := nil;
  inherited;
end;

function TArchiverMock.GetOnProgress: TProgressEvent;
begin
  Result := FArchiver.OnProgress;
end;

procedure TArchiverMock.SetOnProgress(Value: TProgressEvent);
begin
  FArchiver.OnProgress := Value;
end;

{ TFtpSenderMock }

procedure TFtpSenderMock.Abort;
begin
  FFtpSender.Abort;
end;

constructor TFtpSenderMock.Create;
begin
  with TFactory.Create do
  try
    FFtpSender := CreateFtpSender;
  finally
    Free;
  end;
end;

destructor TFtpSenderMock.Destroy;
begin
  FFtpSender := nil;
  inherited;
end;

procedure TFtpSenderMock.Disconnect;
begin
  FDisconnectCalled := True;
  FFtpSender.Disconnect;
end;

function TFtpSenderMock.GetOnProgress: TProgressEvent;
begin
  Result := FFtpSender.OnProgress;
end;

procedure TFtpSenderMock.LogIn(const Url, Login, Password: String);
begin
  FLogIn_Url := Url;
  FLogIn_Login := Login;
  FLogIn_Password := Password;
  FFtpSender.LogIn( Url, Login, Password );
end;

procedure TFtpSenderMock.SetOnProgress(Value: TProgressEvent);
begin
  FFtpSender.OnProgress := Value;
end;

procedure TFtpSenderMock.UploadFile(const FileName: String);
begin
  FUploadFile_FileName := FileName;
  FFtpSender.UploadFile( FileName );
end;

end.
