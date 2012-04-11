unit TarFTP.Tasks;

interface

uses
  Windows, SysUtils, Classes, TarFTP.Interfaces, SyncObjs, IdGlobal;

type
  TCommand = class(TInterfacedObject, ICommand)
  public
  { ICommand }
    procedure Execute(const Task : ITask); virtual; abstract;
  end;

  TTask = class(TInterfacedObject, ITask)
  private
    FError: TExceptionClass;
    FErrorMessage: string;
    FTerminated : Boolean;
    FSuspendCounter : Integer;
    FWorking : Boolean;
    FOnTaskStart : TTaskNotifyEvent;
    FOnTaskComplete : TTaskNotifyEvent;
    procedure Reset;
    procedure SetWorking(Value : Boolean);
    procedure DoTaskStart;
    procedure DoTaskComplete;
  protected
    procedure TaskStart;
    procedure TaskComplete;
    procedure DoCommand(Command : ICommand); virtual; abstract;
    procedure SetError(Error : TExceptionClass; const Message : String);
  public
  { ITask }
    function GetOnTaskStart : TTaskNotifyEvent;
    procedure SetOnTaskStart(Value : TTaskNotifyEvent);
    property OnTaskStart: TTaskNotifyEvent read GetOnTaskStart
        write SetOnTaskStart;

    function GetOnTaskComplete : TTaskNotifyEvent;
    procedure SetOnTaskComplete(Value : TTaskNotifyEvent);
    property OnTaskComplete: TTaskNotifyEvent read GetOnTaskComplete
        write SetOnTaskComplete;

    function GetError : TExceptionClass;
    property Error : TExceptionClass read GetError;

    function GetErrorMessage : String;
    property ErrorMessage : string read GetErrorMessage;

    function GetTerminated : Boolean;
    property Terminated : Boolean read GetTerminated;

    function GetSuspended : Boolean;
    property Suspended : Boolean read GetSuspended;

    procedure Run(const Command : ICommand);
    procedure Terminate;
    procedure ForcedTerminate; virtual;
    procedure Suspend;
    procedure Resume;
  end;

  TSimpleTask = class(TTask)
  protected
    procedure DoCommand(Command: ICommand); override;
  end;

  TErrorHandler = procedure(Error : TExceptionClass;
      const Message : String) of object;

  TTaskThread = class(TThread)
  private
    FCommand : ICommand;
    FTask: ITask;
    FErrorHandler : TErrorHandler;
    FLock: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(const Task: ITask; const Command: ICommand; OnTerminate:
        TNotifyEvent; ErrorHandler: TErrorHandler; Lock : TCriticalSection);
    destructor Destroy; override;
  end;

  TThreadedTask = class(TTask)
  private
    FThread : TTaskThread;
    FLock : TCriticalSection;

    procedure ThreadTerminate(Sender : TObject);
  protected
    procedure DoCommand(Command: ICommand); override;
    procedure DoThreadTerminate;
  public
    procedure ForcedTerminate; override;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TTask }

procedure TTask.DoTaskComplete;
begin
  if Assigned( FOnTaskComplete ) then
    FOnTaskComplete( Self );
end;

procedure TTask.DoTaskStart;
begin
  if Assigned( FOnTaskStart ) then
    FOnTaskStart( Self );
end;

procedure TTask.ForcedTerminate;
begin

end;

function TTask.GetError: TExceptionClass;
begin
  Result := FError;
end;

function TTask.GetErrorMessage: String;
begin
  Result := FErrorMessage;
end;

function TTask.GetOnTaskComplete: TTaskNotifyEvent;
begin
  Result := FOnTaskComplete;
end;

function TTask.GetOnTaskStart: TTaskNotifyEvent;
begin
  Result := FOnTaskStart;
end;

function TTask.GetSuspended: Boolean;
begin
  Result := FSuspendCounter > 0;
end;

function TTask.GetTerminated: Boolean;
begin
  Result := FTerminated;
end;

procedure TTask.Reset;
begin
  FTerminated := False;
  FSuspendCounter := 0;
  FWorking := False;
  FErrorMessage := '';
  FError := nil;
end;

procedure TTask.Resume;
begin
  Dec( FSuspendCounter );
end;

procedure TTask.Run(const Command: ICommand);
begin
  if FWorking then
    raise Exception.Create( 'Task is already running' );

  Assert( Assigned( Command ), 'Command is unassigned' );

  Reset;
  TaskStart;
  DoCommand( Command );
end;

procedure TTask.SetError(Error: TExceptionClass; const Message: String);
begin
  FError := Error;
  FErrorMessage := Message;
end;

procedure TTask.SetOnTaskComplete(Value: TTaskNotifyEvent);
begin
  FOnTaskComplete := Value;
end;

procedure TTask.SetOnTaskStart(Value: TTaskNotifyEvent);
begin
  FOnTaskStart := Value;
end;

procedure TTask.SetWorking(Value: Boolean);
begin
  FWorking := Value;
end;

procedure TTask.Suspend;
begin
  Inc( FSuspendCounter );
end;

procedure TTask.TaskComplete;
begin
  SetWorking( False );
  FTerminated := True;
  DoTaskComplete;
end;

procedure TTask.TaskStart;
begin
  DoTaskStart;
  SetWorking( True );
end;

procedure TTask.Terminate;
begin
  FTerminated := True;
end;

{ TSimpleTask }

procedure TSimpleTask.DoCommand(Command: ICommand);
begin
  try
    Command.Execute( Self );
  except
    on E : Exception do
    begin
      SetError( TExceptionClass(E.ClassType), E.Message );
    end;
  end;

  TaskComplete;
end;

{ TTaskThread }

constructor TTaskThread.Create(const Task: ITask; const Command: ICommand;
    OnTerminate: TNotifyEvent; ErrorHandler: TErrorHandler;
    Lock : TCriticalSection);
begin
  Assert( Assigned( Task ), 'Task is unassigned' );
  Assert( Assigned( Command ), 'Command is unassigned' );

  FTask := Task;
  FCommand := Command;
  FErrorHandler := ErrorHandler;
  FLock := Lock;
  Self.OnTerminate := OnTerminate;
  FreeOnTerminate := True;

  inherited Create;
end;

destructor TTaskThread.Destroy;
begin
  FTask := nil;
  FCommand := nil;
  inherited;
end;

procedure TTaskThread.Execute;
begin
  try
    FCommand.Execute( FTask );
  except
    on E : Exception do
    try
      FLock.Acquire;
      if Assigned( FErrorHandler ) then
        FErrorHandler( TExceptionClass(E.ClassType), E.Message );
    finally
      FLock.Release;
    end;
  end;
end;

{ TThreadedTask }

constructor TThreadedTask.Create;
begin
  FLock := TCriticalSection.Create;
end;

destructor TThreadedTask.Destroy;
begin
  FreeAndNil( FLock );
  inherited;
end;

procedure TThreadedTask.DoCommand(Command: ICommand);
begin
  try
    FThread := TTaskThread.Create(
      Self, Command, ThreadTerminate, SetError, FLock
    );
  except
    TaskComplete;
    raise;
  end;
end;

procedure TThreadedTask.DoThreadTerminate;
begin
  ThreadTerminate( FThread );
end;

procedure TThreadedTask.ForcedTerminate;
var
  thread : TTaskThread;
begin
  FLock.Acquire;
  try
    if Assigned( FThread ) then
      begin
        TerminateThread( FThread.Handle, 0 );
        thread := FThread;

        if GetCurrentThreadId <> MainThreadID then
          TThread.Queue( nil, DoThreadTerminate )
        else
          ThreadTerminate( nil );

        thread.FCommand := nil;
        thread.FTask := nil;
        thread.Free;
      end;
  finally
    FLock.Release;
  end;
end;

procedure TThreadedTask.ThreadTerminate(Sender: TObject);
begin
  FLock.Acquire;
  try
    FThread := nil;
    TaskComplete;
  finally
    FLock.Release;
  end;
end;

end.
