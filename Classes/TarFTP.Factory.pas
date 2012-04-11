unit TarFTP.Factory;

interface

uses
  SysUtils, TarFTP.Interfaces;

type
  TFactory = class(TInterfacedObject, IFactory)
  public
  { IFactory }
    function CreateArchiver : IArchiver;
    function CreateFtpSender : IFtpSender;
    function CreateTask : ITask;
  end;

implementation

uses TarFTP.Archiver, TarFTP.FtpSender, TarFTP.Tasks;

{ TFactory }

function TFactory.CreateArchiver: IArchiver;
begin
  Result := TTarArchiver.Create;
end;

function TFactory.CreateFtpSender: IFtpSender;
begin
  Result := TFtpSender.Create;
end;

function TFactory.CreateTask: ITask;
begin
  Result := TThreadedTask.Create;
end;

end.
