library AddIn;



uses
  ComServ,
  AddInObj in 'AddInObj.pas',
  AddInLib in 'AddInLib.pas',
  PropPage in 'PropPage.pas' {PropertyPage1: TPropertyPage} {PropertyPage1: CoClass},
  DosCommand in 'DosCommand.pas',
  PipeRunner in 'PipeRunner.pas';

{$E dll}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;



{$R *.RES}
{$R 'AddInStr.res' 'AddInStr.rc'}

begin
end.
