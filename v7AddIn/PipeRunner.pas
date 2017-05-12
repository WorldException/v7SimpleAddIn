unit PipeRunner;

interface
uses AddInObj, Classes, DosCommand;
const
  AddInName = 'Process';

type
  TAddInProcess = class(TBaseAddIn)
  private
    fEventAction: string;
    fEventPrefix: string;
    fEventSource: string;
    fShowWindow: string;
  public
    // Запускатель внешних комманд
    command: TDosCommand;

    { Место для собственных методов и свойств компоненты }
    [v7Method('Start,Запустить')]
    function RunPipe(exepath: OleVariant): OleVariant;

    [v7Method('Stop,Завершить')]
    function StopPipe(): OleVariant;

    [v7Method('Write,Записать')]
    function WritePipe(msg: OleVariant): OleVariant;

    procedure OnCommanNewLine(Sender: TObject; NewLine: string; OutputType: TOutputType);

    [v7Property('ShowWindow,ПоказыватьОкно')]
    property ShowWindow: string read fShowWindow write fShowWindow;

    [v7Property('EventSource,СобытиеИсточник')]
    property EventSource: string read fEventSource write fEventSource;

    [v7Property('EventAction,СобытиеДействие')]
    property EventAction:string read fEventAction write fEventAction;

    [v7Property('EventPrefix,СобытиеПрефикс')]
    property EventPrefix:string read fEventPrefix write fEventPrefix;

    procedure after_done; override;
  protected
    function ExtensionName:string; override;
  end;


implementation
uses StrUtils, SysUtils;

function TAddInProcess.RunPipe(exepath: OleVariant): OleVariant;
begin
  result := 0;
  self.StopPipe();
  try
    self.command := TDosCommand.Create(nil);
    self.command.CommandLine := exepath;
    self.command.OnNewLine := self.OnCommanNewLine;
    self.command.show_window := Length(fShowWindow) > 0;
    self.command.Execute;
    self.command.InputToOutput := false;
    if Length(EventSource) = 0 then
      EventSource := exepath;
    if Length(EventAction) = 0 then
      EventAction := 'process';

  finally

  end;
  result := 1;
end;


function TAddInProcess.StopPipe: OleVariant;
begin
  if Assigned(self.command) and self.command.IsRunning then begin
    self.command.Stop;
    self.command.Free;
    self.command := nil;
  end;
end;

procedure TAddInProcess.after_done;
begin
  inherited;
  StopPipe();
end;

function TAddInProcess.ExtensionName: string;
begin
  result := AddInName;
end;

procedure TAddInProcess.OnCommanNewLine(Sender: TObject; NewLine: string; OutputType: TOutputType);
begin
  if Length(EventPrefix) > 0 then begin
    if EventPrefix <> LeftStr(NewLine, Length(EventPrefix)) then
      Exit;
  end;
  Self.SendEvent(NewLine, EventAction, EventSource);
end;

function TAddInProcess.WritePipe(msg: OleVariant): OleVariant;
begin
  if Assigned(self.command) and self.command.IsRunning then begin
    self.command.SendLine(msg);
  end;
end;

initialization
  AddInObj.RegisterAddIn(
    TAddInProcess,
    StringToGUID('{B0FF3E81-4A6D-46E7-AA09-E0C19D0967B5}'),
    AddInName
  );

end.