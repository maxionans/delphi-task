program TarFTP_Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  fMainForm in '..\Forms\fMainForm.pas' {frmMainForm},
  TarFTPTests in 'TarFTPTests.pas',
  TarFTP.Interfaces in '..\Abstraction\TarFTP.Interfaces.pas',
  TarFTP.MocksAndStubs in 'TarFTP.MocksAndStubs.pas',
  TarFTP.Archiver in '..\Classes\TarFTP.Archiver.pas',
  TarFTP.Types in '..\Classes\TarFTP.Types.pas',
  TarFTP.FtpSender in '..\Classes\TarFTP.FtpSender.pas',
  TarFTP.MVC in '..\Abstraction\TarFTP.MVC.pas',
  TarFTP.Model in '..\Classes\TarFTP.Model.pas',
  TarFTP.Tasks in '..\Classes\TarFTP.Tasks.pas',
  TarFTP.Factory in '..\Classes\TarFTP.Factory.pas',
  TarFTP.Utils in '..\Utils\TarFTP.Utils.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;

  ReportMemoryLeaksOnShutdown := True;
end.

