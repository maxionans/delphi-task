program TarFTP;

uses
  Forms,
  fMainForm in 'Forms\fMainForm.pas' {frmMainForm},
  TarFTP.MVC in 'Abstraction\TarFTP.MVC.pas',
  TarFTP.Archiver in 'Classes\TarFTP.Archiver.pas',
  TarFTP.Factory in 'Classes\TarFTP.Factory.pas',
  TarFTP.FtpSender in 'Classes\TarFTP.FtpSender.pas',
  TarFTP.Model in 'Classes\TarFTP.Model.pas',
  TarFTP.Interfaces in 'Abstraction\TarFTP.Interfaces.pas',
  LibTar in 'Utils\LibTar.pas',
  TarFTP.Types in 'Classes\TarFTP.Types.pas',
  TarFTP.Tasks in 'Classes\TarFTP.Tasks.pas',
  TarFTP.Controller in 'Classes\TarFTP.Controller.pas',
  fFileCompression in 'Forms\fFileCompression.pas' {frmFileCompression},
  TarFTP.Utils in 'Utils\TarFTP.Utils.pas',
  fFileUpload in 'Forms\fFileUpload.pas' {frmFileUpload};

{$R *.res}

var
  model : IModel;
  controller : IController;
begin
  model := TModel.Create( TFactory.Create );
  controller := TController.Create( model );

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmFileCompression, frmFileCompression);
  Application.CreateForm(TfrmFileUpload, frmFileUpload);
  frmMainForm.SetModel( model );
  frmMainForm.SetController( controller );
  frmFileCompression.SetModel( model );
  frmFileCompression.SetController( controller );
  frmFileUpload.SetModel( model );
  frmFileUpload.SetController( controller );

  Application.Run;

  model := nil;
  controller := nil;
end.
