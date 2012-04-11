unit TarFTP.Interfaces;

interface

uses
  SysUtils;

type
  TProgressEvent = procedure(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64) of object;

  IArchiver = interface
  ['{6F15B19F-2C02-4C33-BE65-D256876BFE9F}']
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure AddFile(const FileName : String);
    procedure CompressToFile(const OutputFile : String);
  end;

  IFtpSender = interface
  ['{04C29E43-F0EF-4250-A5BD-AFE6A4276D9F}']
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure LogIn(const Url, Login, Password : String);
    procedure UploadFile(const FileName : String);
    procedure Abort;
    procedure Disconnect;
  end;

  ITask = interface;

  IFactory = interface
  ['{10D6545C-F74D-4AE2-8767-27D06747121F}']
    function CreateArchiver : IArchiver;
    function CreateFtpSender : IFtpSender;
    function CreateTask : ITask;
  end;

  ICommand = interface
  ['{0FF3696A-4F86-43C0-BEF9-525813D8888E}']
    procedure Execute(const Task : ITask);
  end;

  TTaskNotifyEvent = procedure (const Task : ITask) of object;

  TExceptionClass = class of Exception;

  ITask = interface
  ['{0F68A76F-8FC7-45A5-B973-F5B21B76966F}']
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
    procedure ForcedTerminate;
    procedure Suspend;
    procedure Resume;
  end;

implementation

end.
