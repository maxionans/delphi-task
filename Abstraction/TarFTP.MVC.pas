unit TarFTP.MVC;

interface

uses
  Classes;

type
  IController = interface;

  IModel = interface;

  IView = interface
  ['{A74830EF-5BA4-4F8A-B3F4-F3A49A4FD45D}']
    procedure SetController(const Controller : IController);
    procedure SetModel(const Model : IModel);

    procedure Display;
    procedure Close;
    procedure ProcessErrors;
  end;

  IMainView = interface(IView)
  ['{29AE12AB-4B0B-4CA5-B986-F77EE1B5D40A}']
  end;

  IFileCompressionView = interface(IView)
  ['{EA63896E-3089-48BB-987F-5DF0810A3DE4}']
  end;

  IFileUploadView = interface(IView)
  ['{9A1C09EB-E341-48B1-B623-BC0C15F3C3A4}']
  end;

  IController = interface
  ['{58B1B9F7-0A80-495C-889D-005722F618BF}']
    procedure RegisterView(const Kind : TGUID; const View : IView);
    procedure CompressAndUpload;
  end;

  TWorkProgressEvent = procedure(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64) of object;

  TTaskKind = (
    tkUndefined, tkCompress, tkUpload
  );

  TTaskState = (
    tsBeforeStarted, tsAfterFinished
  );

  TModelNotifyEvent = procedure(Task : TTaskKind; State : TTaskState) of object;

  IModel = interface
  ['{99B8DD6A-CF98-4760-9F7C-07A6D863F885}']
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
    procedure SetFtpCredentials(const Host, Login, Password : String);
    procedure NeedError;

    procedure Compress;
    procedure Upload;

    procedure TerminateTask;
    procedure ForcedTerminateTask;
  end;

implementation

end.
