unit TarFTPTests;

interface

uses
  TestFramework, Windows, Dialogs, Forms, fMainForm, Controls, Classes,
  SysUtils, Variants, Graphics, Messages, TarFTP.Interfaces,
  TarFTP.MVC, TarFTP.MocksAndStubs, IdAntiFreezeBase ;

type
  TTarArchiverTest = class(TTestCase)
  private
    FArchiver : IArchiver;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressSingleFile;
    procedure TestCompressNoFile;
    procedure TestCompressFileThatNotExists;
    procedure TestCompressMultipleFiles;
  end;

  TFtpSenderTest = class(TTestCase)
  private
    FFtpSender : IFtpSender;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFtpAuthentification;
    procedure TestUploadFile;
  end;

  ETestException = class(Exception);

  TTaskTest = class(TTestCase, ICommand)
  private
    FTask : ITask;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    procedure Execute(const Task: ITask);

    procedure DoCheck;
  published
    procedure TestErrorInsideSimpleTask;
    procedure TestErrorInsideThreadedTask;
  end;

  TModelTest1 = class(TTestCase)
  private
    FModel : IModel;

    FFactory : TFactoryMock;
    FFactoryIntf : IFactory;
    FArchiver : TArchiverMock;
    FFtpSender : TFtpSenderMock;

    FTaskCompressBefore : Boolean;
    FTaskCompressAfter : Boolean;
    FTaskUploadBefore : Boolean;
    FTaskUploadAfter : Boolean;
    FFileCompress : Boolean;
    FFileUpload : Boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure FileCompress(CurrentItem, TotalItems: Integer; BytesProcessed,
        TotalBytes: Int64);
    procedure FileUpload(CurrentItem, TotalItems: Integer; BytesProcessed,
        TotalBytes: Int64);
    procedure TaskNotify(Task : TTaskKind; State : TTaskState);
  published
    procedure TestCompress;
    procedure TestUpload;
  end;

  TModelTest2 = class(TTestCase)
  private
    FModel : IModel;
    FComplete : Boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TaskNotify(Task : TTaskKind; State : TTaskState);
  published
    procedure TestNoOutputFileCompress;
    procedure TestNoHostUpload;
  end;

implementation

uses
  TarFTP.Archiver, TarFTP.Types, TarFTP.FtpSender,
  TarFTP.Model, TarFTP.Tasks, TarFTP.Factory, IdExceptionCore;

const
  S_DATA_FOLDER = '.\TestData\';

  S_FILE1 = 'File1.txt';

  S_SINGLE_FILE = 'Single.tar';

  S_TMP_FILE = 'Temp.tar';

  S_TASK_EVENT_ERROR_MSG = 'Event "%s" has not been fired';

  S_FTP_HOST = 'frantic-13.com';

  S_USER_NAME = 'delphitest@frantic-13.com';

  S_PASSWORD = '9rVT*o~MTpfO';

  S_WRONG_PARAM_ERROR_MSG = '%s called with wrong %s'#13#10 +
                            'Expected: %s'#13#10 +
                            'Got: %s';

  S_TEST_EXCEPTION_MSG = 'Test exception message';

function AreFilesIdentical(const File1, File2 : String) : Boolean;
const
  S_ERROR_MSG = 'File not exists: %s';

  function LoadFile(const FileName : String) : TMemoryStream;
  var
    srcStream : TFileStream;
  begin
    srcStream := TFileStream.Create( FileName, fmOpenRead or fmShareDenyWrite );
    try
      Result := TMemoryStream.Create;
      Result.CopyFrom( srcStream, 0 );
    finally
      srcStream.Free;
    end;
  end;

var
  mem1, mem2 : TMemoryStream;
begin
  if not FileExists( File1 ) then
    raise EFileNotFoundException.CreateFmt( S_ERROR_MSG, [ File1 ] );

  if not FileExists( File2 ) then
    raise EFileNotFoundException.CreateFmt( S_ERROR_MSG, [ File2 ] );

  Result := False;
  mem1 := nil;
  mem2 := nil;
  try
    mem1 := LoadFile( File1 );
    mem2 := LoadFile( File2 );

    if ( mem1.Size <> mem2.Size ) then
      Exit;

    Result := CompareMem( mem1.Memory, mem2.Memory, mem1.Size );
  finally
    mem1.Free;
    mem2.Free;
  end;
end;

{ TTarArchiverTest }

procedure TTarArchiverTest.SetUp;
begin
//  FArchiver := TArchiverStub.Create;
  FArchiver := TTarArchiver.Create;
end;

procedure TTarArchiverTest.TearDown;
begin
  FArchiver := nil;
end;

procedure TTarArchiverTest.TestCompressFileThatNotExists;
var
  errorClass : TClass;
begin
  errorClass := nil;
  try
    FArchiver.AddFile( S_DATA_FOLDER + 'FileThatNotExists.txt' );
    FArchiver.CompressToFile( S_TMP_FILE );
  except
    on E : Exception do
      errorClass := E.ClassType;
  end;

  Check(
    Assigned( errorClass ),
    'Archiver raised no error, but exception expected'
  );

  Check(
    errorClass = EFOpenError,
    'Archiver raised ' + errorClass.ClassName + ' exception, but ' +
    'EFOpenError expected'
  );
end;

procedure TTarArchiverTest.TestCompressMultipleFiles;
begin
  if FileExists( S_TMP_FILE ) then
    Assert( DeleteFile( S_TMP_FILE ), 'Temporary file already exists and ' +
                                      'could not be removed' );

  FArchiver.AddFile( S_DATA_FOLDER + 'File1.txt' );
  FArchiver.AddFile( S_DATA_FOLDER + 'File2.txt' );
  FArchiver.AddFile( S_DATA_FOLDER + 'File3.txt' );
  FArchiver.CompressToFile( S_TMP_FILE );

  Check(
    FileExists( S_TMP_FILE ),
    'Archiver has not generated a file'
  );

  Check(
    AreFilesIdentical( S_TMP_FILE, S_DATA_FOLDER + 'Multiple.tar' ),
    'The file generated by the archiver is invalid'
  );
end;

procedure TTarArchiverTest.TestCompressNoFile;
var
  errorClass : TClass;
begin
  errorClass := nil;
  try
    FArchiver.CompressToFile( S_TMP_FILE );
  except
    on E: Exception do
      errorClass := E.ClassType;
  end;

  Check(
    Assigned( errorClass ),
    'Archiver raised no error, but exception expected'
  );

  Check(
    errorClass = ENoFilesToCompress,
    'Archiver raised ' + errorClass.ClassName + ' exception, but ' +
    'ENoFilesToCompress expected'
  );
end;

procedure TTarArchiverTest.TestCompressSingleFile;
begin
  if FileExists( S_TMP_FILE ) then
    Assert( DeleteFile( S_TMP_FILE ), 'Temporary file already exists and ' +
                                      'could not be removed' );

  FArchiver.AddFile( S_DATA_FOLDER + S_FILE1 );
  FArchiver.CompressToFile( S_TMP_FILE );

  Check(
    FileExists( S_TMP_FILE ),
    'Archiver has not generated a file'
  );

  Check(
    AreFilesIdentical( S_TMP_FILE, S_DATA_FOLDER + S_SINGLE_FILE ),
    'The file generated by the archiver is invalid'
  );
end;

{ TFtpSender }

procedure TFtpSenderTest.SetUp;
begin
  FFtpSender := TFtpSender.Create;
end;

procedure TFtpSenderTest.TearDown;
begin
  FFtpSender := nil;
end;

procedure TFtpSenderTest.TestFtpAuthentification;
var
  loggedIn : Boolean;
  errMsg : String;
begin
  try
    try
      FFtpSender.LogIn(
        'frantic-13.com', 'delphitest@frantic-13.com', '9rVT*o~MTpfO'
      );
      loggedIn := True;
    finally
      FFtpSender.Disconnect;
    end;
  except
    on E : Exception do
    begin
      loggedIn := False;
      errMsg := E.Message;
    end;
  end;

  Check(
    loggedIn,
    'FtpSender failed authentification: ' + errMsg
  );
end;

procedure TFtpSenderTest.TestUploadFile;
var
  uploaded : Boolean;
  errMsg : String;
begin
  try
    try
      FFtpSender.LogIn(
        S_FTP_HOST, S_USER_NAME, S_PASSWORD
      );
      FFtpSender.UploadFile( S_DATA_FOLDER + S_SINGLE_FILE );
      uploaded := True;
    finally
      FFtpSender.Disconnect;
    end;
  except
    on E : Exception do
    begin
      uploaded := False;
      errMsg := E.Message;
    end;
  end;

  Check(
    uploaded,
    'FtpSender was unable to upload the file: ' + errMsg
  );
end;

{ TModelTest }

procedure TModelTest1.FileCompress(CurrentItem, TotalItems: Integer;
    BytesProcessed, TotalBytes: Int64);
begin
  FFileCompress := True;
end;

procedure TModelTest1.FileUpload(CurrentItem, TotalItems: Integer;
    BytesProcessed, TotalBytes: Int64);
begin
  FFileUpload := True;
end;

procedure TModelTest1.SetUp;
begin
//  FModel := TModelStub.Create;

  FArchiver := TArchiverMock.Create;
  FFtpSender := TFtpSenderMock.Create;
  FFactory := TFactoryMock.Create;
  FFactoryIntf := FFactory;

  FFactory.Archiver := FArchiver;
  FFactory.FtpSender := FFtpSender;

  FModel := TModel.Create( FFactory );
  FModel.OnFileCompress := Self.FileCompress;
  FModel.OnFileUpload := Self.FileUpload;
  FModel.OnTaskEvent := Self.TaskNotify;

  FFileCompress := False;
  FFileUpload := False;
  FTaskCompressBefore := False;
  FTaskCompressAfter := False;
  FTaskUploadBefore := False;
  FTaskUploadAfter := False;
end;

procedure TModelTest1.TaskNotify(Task: TTaskKind; State: TTaskState);
begin
  case Task of
    tkUndefined: ;
    tkCompress:
      if State = tsBeforeStarted then
        FTaskCompressBefore := True
      else
        FTaskCompressAfter := True;

    tkUpload:
      if State = tsBeforeStarted then
        FTaskUploadBefore := True
      else
        FTaskUploadAfter := True;
  end;
end;

procedure TModelTest1.TearDown;
begin
  FModel := nil;
  FFactory := nil;
  FFactoryIntf := nil;
  FArchiver := nil;
  FFtpSender := nil;
end;

procedure TModelTest1.TestCompress;
var
  inputFile: String;
begin
  inputFile := S_DATA_FOLDER + S_FILE1;
  FModel.AddFile( inputFile );
  FModel.SetOutputFile( S_TMP_FILE );
  FModel.OnFileCompress := FileCompress;
  FModel.Compress;

  Check(
    FTaskCompressBefore,
    Format( S_TASK_EVENT_ERROR_MSG, [ 'TaskCompress -> BeforeStarted' ] )
  );

  Check(
    FTaskCompressAfter,
    Format( S_TASK_EVENT_ERROR_MSG, [ 'TaskCompress -> AfterFinished' ] )
  );

  Check(
    FFileCompress,
    Format( S_TASK_EVENT_ERROR_MSG, [ 'FileCompress' ] )
  );

  Check(
    SameText( FArchiver.AddFile_FileName, inputFile ),
    Format(
      S_WRONG_PARAM_ERROR_MSG,
      [ 'Archiver.AddFile', 'file name', inputFile,
        FArchiver.AddFile_FileName ]
    )
  );

  Check(
    SameText( FArchiver.CompressToFile_OutputFile, S_TMP_FILE ),
    Format(
      S_WRONG_PARAM_ERROR_MSG,
      [ 'Archiver.CompressToFile', 'file name', S_TMP_FILE,
        FArchiver.CompressToFile_OutputFile ]
    )
  );
end;

procedure TModelTest1.TestUpload;
begin
  FModel.AddFile( S_DATA_FOLDER + S_FILE1 );
  FModel.SetOutputFile( S_TMP_FILE );
  FModel.Compress;
  FModel.SetFtpCredentials( S_FTP_HOST, S_USER_NAME, S_PASSWORD );
  FModel.OnFileUpload := FileUpload;
  FModel.Upload;

  Check(
    FTaskUploadBefore,
    Format( S_TASK_EVENT_ERROR_MSG, [ 'TaskUpload -> BeforeStarted' ] )
  );

  Check(
    FTaskUploadAfter,
    Format( S_TASK_EVENT_ERROR_MSG, [ 'TaskUpload -> AfterFinished' ] )
  );

  Check(
    FFileUpload,
    Format( S_TASK_EVENT_ERROR_MSG, [ 'FileUpload' ] )
  );

  Check(
    SameText( FFtpSender.LogIn_Url, S_FTP_HOST ),
    Format(
      S_WRONG_PARAM_ERROR_MSG,
      [ 'FtpSender.LogIn', 'host', S_FTP_HOST,
        FFtpSender.LogIn_Url ]
    )
  );

  Check(
    SameText( FFtpSender.LogIn_Login, S_USER_NAME ),
    Format(
      S_WRONG_PARAM_ERROR_MSG,
      [ 'FtpSender.LogIn', 'user name', S_USER_NAME,
        FFtpSender.LogIn_Login ]
    )
  );

  Check(
    SameText( FFtpSender.LogIn_Password, S_PASSWORD ),
    Format(
      S_WRONG_PARAM_ERROR_MSG,
      [ 'FtpSender.LogIn', 'password', S_PASSWORD,
        FFtpSender.LogIn_Password ]
    )
  );
end;

{ TTaskTest }

procedure TTaskTest.DoCheck;
begin
  try
    FTask.Run( Self );
  except
  end;

  while not FTask.Terminated do
  begin
    Application.ProcessMessages;
    Sleep( 1 );
  end;

  Check(
    Assigned( FTask.Error ),
    'Task.Error is unassigned'
  );

  Check(
    FTask.Error = ETestException,
    'Task.Error has wrong value.'#13#10 +
    'Expected: ' + ETestException.ClassName + #13#10 +
    'Got: ' + FTask.Error.ClassName
  );

  Check(
    FTask.ErrorMessage = S_TEST_EXCEPTION_MSG,
    'Task.ErrorMessage has wrong value.'#13#10 +
    'Expected: ' + S_TEST_EXCEPTION_MSG + #13#10 +
    'Got: ' + FTask.ErrorMessage
  );
end;

procedure TTaskTest.Execute(const Task: ITask);
begin
  raise ETestException.Create( S_TEST_EXCEPTION_MSG );
end;

procedure TTaskTest.SetUp;
begin

end;

procedure TTaskTest.TearDown;
begin
  FTask := nil;
end;

procedure TTaskTest.TestErrorInsideSimpleTask;
begin
  FTask := TSimpleTask.Create;
  DoCheck;
end;

procedure TTaskTest.TestErrorInsideThreadedTask;
begin
  FTask := TThreadedTask.Create;
  DoCheck;
end;

{ TModelTest2 }

procedure TModelTest2.SetUp;
begin
  FModel := TModel.Create( TFactory.Create );
  FComplete := False;
end;

procedure TModelTest2.TaskNotify(Task: TTaskKind; State: TTaskState);
begin
  if State = tsAfterFinished then
    FComplete := True;
end;

procedure TModelTest2.TearDown;
begin
  FModel := nil;
end;

procedure TModelTest2.TestNoHostUpload;
var
  ok : Boolean;
begin
  FModel.OnTaskEvent := TaskNotify;
  FModel.Upload;

  while not FComplete do
  begin
    Sleep( 1 );
    Application.ProcessMessages;
  end;

  ok := False;
  try
    FModel.NeedError;
  except
    on E : EIdHostRequired do
      ok := True
    else
      raise;
  end;

  Check(
    ok, 'FModel.NeedError expected to raise EIdHostRequired exception'
  );
end;

procedure TModelTest2.TestNoOutputFileCompress;
var
  ok : Boolean;
begin
  FModel.AddFile( S_DATA_FOLDER + S_FILE1 );
  FModel.OnTaskEvent := TaskNotify;

  FModel.Compress;

  while not FComplete do
  begin
    Sleep( 1 );
    Application.ProcessMessages;
  end;

  ok := False;
  try
    FModel.NeedError;
  except
    on E : EFCreateError do
      ok := True
    else
      raise;
  end;

  Check(
    ok, 'FModel.NeedError expected to raise EFCreateError exception'
  );
end;

initialization

  RegisterTest( TTarArchiverTest.Suite );
  RegisterTest( TFtpSenderTest.Suite );
  RegisterTest( TTaskTest.Suite );
  RegisterTest( TModelTest1.Suite );
  RegisterTest( TModelTest2.Suite );

end.

