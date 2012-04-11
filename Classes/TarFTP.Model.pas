unit TarFTP.Model;

interface

uses
  SysUtils, TarFTP.Interfaces, TarFTP.MVC,
  TarFTP.Tasks;

type
  TCompressCommand = class(TCommand)
  private
    FArchiver: IArchiver;
    FOnFileCompress: TWorkProgressEvent;
    FOutputFile: String;
    procedure FileProgress(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64);
  public
  { ICommand }
    procedure Execute(const Task: ITask); override;

  { Common }
    constructor Create(const Archiver: IArchiver; const OutputFile: String;
        OnFileCompress: TWorkProgressEvent);
    destructor Destroy; override;
  end;

  TUploadCommand = class(TCommand)
  private
    FFileToUpload: String;
    FFtpSender: IFtpSender;
    FHost: String;
    FOnFileUpload: TWorkProgressEvent;
    FPassword: String;
    FUserName: String;
    FTask : ITask;
    FAborted : Boolean;
    procedure FileProgress(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64);
  public
  { ICommand }
    procedure Execute(const Task: ITask); override;

  { Common }
    constructor Create(const FtpSender: IFtpSender;
        const Host, UserName, Password, FileToUpload: String;
        OnFileUpload: TWorkProgressEvent);
    destructor Destroy; override;
  end;

  TModel = class(TInterfacedObject, IModel)
  private
    FArchiver: IArchiver;
    FFtpSender: IFtpSender;
    FOnFileCompress : TWorkProgressEvent;
    FOnFileUpload : TWorkProgressEvent;
    FOnTaskEvent : TModelNotifyEvent;
    FOutputFile : String;
    FHost : String;
    FUserName : String;
    FPassword : String;
    FTask : ITask;
    FActiveTask : TTaskKind;
    FFactory : IFactory;
    FForcedTerminate : Boolean;
    FTerminated: Boolean;

    procedure DoTaskEvent(Task : TTaskKind; State : TTaskState);

    procedure CompressionComplete(const Task : ITask);
    procedure CompressionStart(const Task: ITask);
    procedure UploadingComplete(const Task: ITask);
    procedure UploadingStart(const Task: ITask);
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

  { Common }
    constructor Create(Factory: IFactory);
    destructor Destroy; override;
  end;

implementation

{ TModel }

procedure TModel.AddFile(const FileName: String);
begin
  FArchiver.AddFile( FileName );
end;

procedure TModel.Compress;
begin
  if FActiveTask <> tkUndefined then
    raise Exception.Create( 'Can not compress files while another ' +
                            'task is running' );

  FActiveTask := tkCompress;
  FTask.OnTaskStart := Self.CompressionStart;
  FTask.OnTaskComplete := Self.CompressionComplete;
  FTask.Run(
    TCompressCommand.Create( FArchiver, FOutputFile, FOnFileCompress )
  );
end;

procedure TModel.CompressionComplete(const Task: ITask);
begin
  FActiveTask := tkUndefined;
  DoTaskEvent( tkCompress, tsAfterFinished );
end;

constructor TModel.Create(Factory: IFactory);
begin
  Assert( Assigned( Factory ), 'Factory is unassigned' );
  FArchiver := Factory.CreateArchiver;
  FFtpSender := Factory.CreateFtpSender;
  FTask := Factory.CreateTask;
  FFactory := Factory;
end;

destructor TModel.Destroy;
begin
  FArchiver := nil;
  FFtpSender := nil;
  FTask := nil;
  FFactory := nil;
  inherited;
end;

procedure TModel.CompressionStart(const Task: ITask);
begin
  DoTaskEvent( tkCompress, tsBeforeStarted );
end;

procedure TModel.DoTaskEvent(Task: TTaskKind; State: TTaskState);
begin
  if Assigned( FOnTaskEvent ) then
    FOnTaskEvent( Task, State );
end;

procedure TModel.ForcedTerminateTask;
begin
  FForcedTerminate := True;
  FTask.ForcedTerminate;
end;

function TModel.GetError: Boolean;
begin
  Result := FTask.Error <> nil;
end;

function TModel.GetOnFileCompress: TWorkProgressEvent;
begin
  Result := FOnFileCompress;
end;

function TModel.GetOnFileUpload: TWorkProgressEvent;
begin
  Result := FOnFileUpload;
end;

function TModel.GetOnTaskEvent: TModelNotifyEvent;
begin
  Result := FOnTaskEvent;
end;

function TModel.GetTerminated: Boolean;
begin
  Result := FTerminated or FForcedTerminate;
end;

procedure TModel.NeedError;
begin
  if not FForcedTerminate and Assigned( FTask.Error ) then
    raise FTask.Error.Create( FTask.ErrorMessage );
end;

procedure TModel.Reset;
begin
  if FActiveTask <> tkUndefined then
    raise Exception.Create( 'Can not reset model while any ' +
                            'task is running' );

  FTerminated := False;
  FForcedTerminate := False;
  FTask := FFactory.CreateTask;
end;

procedure TModel.SetFtpCredentials(const Host, Login, Password: string);
begin
  FHost := Host;
  FUserName := Login;
  FPassword := Password;
end;

procedure TModel.SetOnFileCompress(Value: TWorkProgressEvent);
begin
  FOnFileCompress := Value;
end;

procedure TModel.SetOnFileUpload(Value: TWorkProgressEvent);
begin
  FOnFileUpload := Value;
end;

procedure TModel.SetOnTaskEvent(Value: TModelNotifyEvent);
begin
  FOnTaskEvent := Value;
end;

procedure TModel.SetOutputFile(const OutputFile: String);
begin
  FOutputFile := OutputFile;
end;

procedure TModel.TerminateTask;
begin
  FTerminated := True;
  FTask.Terminate;
end;

procedure TModel.Upload;
begin
  if FActiveTask <> tkUndefined then
    raise Exception.Create( 'Can not upload files while another ' +
                            'task is running' );

  FActiveTask := tkUpload;
  FTask.OnTaskStart := Self.UploadingStart;
  FTask.OnTaskComplete := Self.UploadingComplete;
  FTask.Run(
    TUploadCommand.Create(
      FFtpSender, FHost, FUserName, FPassword, FOutputFile,
      FOnFileUpload
    )
  );
end;

procedure TModel.UploadingComplete(const Task: ITask);
begin
  DoTaskEvent( tkUpload, tsAfterFinished );
  FActiveTask := tkUndefined;
end;

procedure TModel.UploadingStart(const Task: ITask);
begin
  DoTaskEvent( tkUpload, tsBeforeStarted );
end;

{ TCompressCommand }

constructor TCompressCommand.Create(const Archiver: IArchiver; const
    OutputFile: String; OnFileCompress: TWorkProgressEvent);
begin
  Assert( Assigned( Archiver ), 'Archiver is unassigned' );

  FArchiver := Archiver;
  FArchiver.OnProgress := FileProgress;
  FOutputFile := OutputFile;
  FOnFileCompress := OnFileCompress;
end;

destructor TCompressCommand.Destroy;
begin
  if Assigned( FArchiver ) then
    FArchiver.OnProgress := nil;
  FArchiver := nil;
  inherited;
end;

procedure TCompressCommand.Execute(const Task: ITask);
begin
  FArchiver.CompressToFile( FOutputFile );
end;

procedure TCompressCommand.FileProgress(CurrentItem, TotalItems: Integer;
  BytesProcessed, TotalBytes: Int64);
begin
  if Assigned( FOnFileCompress ) then
    FOnFileCompress(
      CurrentItem, TotalItems, BytesProcessed, TotalBytes
    );
end;

{ TUploadCommand }

constructor TUploadCommand.Create(const FtpSender: IFtpSender; const Host,
  UserName, Password, FileToUpload: String; OnFileUpload: TWorkProgressEvent);
begin
  Assert( Assigned( FtpSender ), 'FtpSender is unassigned' );

  FFtpSender := FtpSender;
  FFtpSender.OnProgress := FileProgress;
  FHost := Host;
  FUserName := UserName;
  FPassword := Password;
  FFileToUpload := FileToUpload;
  FOnFileUpload := OnFileUpload;
end;

destructor TUploadCommand.Destroy;
begin
  FFtpSender.OnProgress := nil;
  FFtpSender := nil;
  FTask := nil;
  inherited;
end;

procedure TUploadCommand.Execute(const Task: ITask);
begin
  FTask := Task;
  FAborted := False;
  FFtpSender.LogIn( FHost, FUserName, FPassword );
  try
    FFtpSender.UploadFile( FFileToUpload );
  finally
    if not FAborted then FFtpSender.Disconnect;
  end;
end;

procedure TUploadCommand.FileProgress(CurrentItem, TotalItems: Integer;
  BytesProcessed, TotalBytes: Int64);
begin
  if Assigned( FOnFileUpload ) then
    FOnFileUpload(
      CurrentItem, TotalItems, BytesProcessed, TotalBytes
    );

  if FTask.Terminated and not FAborted then
    begin
      FAborted := True;
      FFtpSender.Abort;
    end;
end;

end.
