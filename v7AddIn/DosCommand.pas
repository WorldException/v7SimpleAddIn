unit DosCommand;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls, SyncObjs, DosThread;

type

  TDosCommand = class(TComponent) //the component to put on a form
  private
    FOwner: TComponent;
    FCommandLine: string;
    FInputToOutput: Boolean;
    FOnNewLine: TNewLineEvent;
    FOnNewError: TNewErrorEvent;
    FOnTerminated: TNotifyEvent;
    FThread: TDosThread;
    FTimer: TProcessTimer;
    FMaxTimeAfterBeginning: Integer;
    FMaxTimeAfterLastOutput: Integer;
    FPriority: Integer; //[HIGH_PRIORITY_CLASS, IDLE_PRIORITY_CLASS,
                        // NORMAL_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS]
    FThreadLock: TRTLCriticalSection; // Lock for FThread access

    function GetIsRunning: boolean; // MK: 20030613
  protected
  public
    show_window: boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Execute; //the user call this to execute the command
    procedure Stop; //the user can stop the process with this method
    procedure SendLine(Value: string; Eol: Boolean=True); //add a line in the input pipe
    property IsRunning: boolean read GetIsRunning; // MK: 20030613
      // When true, a command is still running
    property Priority: Integer read FPriority write FPriority; //priority of the process
  published
    property CommandLine: string read FCommandLine write FCommandLine;
      //command to execute
    property OnNewLine: TNewLineEvent read FOnNewLine write FOnNewLine;
      //event for each new line that is received through the pipe
    property OnNewError: TNewErrorEvent read FOnNewError write FOnNewError;
      //event for each error line that is received through the pipe
    property OnTerminated: TNotifyEvent read FOnTerminated write FOnTerminated;
      //event for the end of the process (normally, time out or by user (DosCommand.Stop;))
    property InputToOutput: Boolean read FInputToOutput write FInputToOutput;
      //check it if you want that the inputs appear also in the outputs
    property MaxTimeAfterBeginning: Integer read FMaxTimeAfterBeginning
      write FMaxTimeAfterBeginning; //maximum time of execution
    property MaxTimeAfterLastOutput: Integer read FMaxTimeAfterLastOutput
      write FMaxTimeAfterLastOutput; //maximum time of execution without an output
  end;


implementation
uses StrUtils;


//------------------------------------------------------------------------------

constructor TDosCommand.Create(AOwner: TComponent);
begin
 InitializeCriticalSection(FThreadLock);
 inherited;
 FOwner := AOwner;
 FCommandLine := '';
 FTimer := nil;
 FMaxTimeAfterBeginning := 0;
 FMaxTimeAfterLastOutput := 0;
 FPriority := NORMAL_PRIORITY_CLASS;
 show_window := false;
end;

destructor TDosCommand.Destroy;
begin
  if Assigned(FThread) and FThread.Started and not FThread.Finished then
  begin
    FThread.Terminate; //terminate the process
  end;
  //if Assigned(FThread) then begin
  //  self.Stop();
    //if not FThread.Finished then
    //    Sleep(1000);
    //FreeAndNil(FThread);
  //end;
  if Assigned(FTimer) then begin
    FreeAndNil(FTimer);
  end;
  DeleteCriticalSection(FThreadLock);
  inherited;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.Execute;
begin
  EnterCriticalSection(FThreadLock);
  try
    if FCommandLine = '' then  // MK: 20030613
      raise EDosCommand.Create('No Commandline to execute');

    if Assigned(FThread) and FThread.Started then
      raise EDosCommand.Create('Thread already running');

    if (FTimer = nil) then //create the timer (first call to execute)
      FTimer := TProcessTimer.Create(FOwner);
    FTimer.Beginning; //turn the timer on

    // Create thread outside lock to avoid deadlock
    FThread := TDosThread.Create(
      Self,
      FCommandLine,
      FTimer,
      FMaxTimeAfterBeginning,
      FMaxTimeAfterLastOutput,
      FOnNewLine,
      FOnNewError,
      FOnTerminated,
      FPriority,
      FInputToOutput,
      show_window
    );
    FThread.FreeOnTerminate := true ;
  finally
    LeaveCriticalSection(FThreadLock);
  end;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.Stop;
begin
    if Assigned(FThread) and FThread.Started and not FThread.Finished then
    begin
      FThread.Terminate; //terminate the process
    end
end;

//------------------------------------------------------------------------------

procedure TDosCommand.SendLine(Value: string; Eol: Boolean);
begin
  if Assigned(FThread) then
        FThread.InputLines.Add(Value);
end;

//------------------------------------------------------------------------------

function TDosCommand.GetIsRunning: boolean;
begin
    Result := Assigned(FThread) and not FThread.Finished;
end;

//------------------------------------------------------------------------------

end.

