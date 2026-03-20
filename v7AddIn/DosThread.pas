unit DosThread;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls, SyncObjs;
const
  MaxBufSize = 1000;
  SleepPause = 50;

type
  CyrillicAnsi = type AnsiString(1251);
  EDosCommand = class(Exception);  // MK: 20030613

  TCreatePipeError = class(Exception); //exception raised when a pipe cannot be created
  TCreateProcessError = class(Exception); //exception raised when the process cannot be created
  TOutputType = (otEntireLine, otBeginningOfLine); //to know if the newline is finished.

  TProcessTimer = class(TTimer) //timer for stopping the process after XXX sec
  private
    FSinceBeginning: Integer;
    FSinceLastOutput: Integer;
    procedure MyTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Beginning; //call this at the beginning of a process
    procedure NewOutput; //call this when a new output is received
    procedure Ending; //call this when the process is terminated
    property SinceBeginning: Integer read FSinceBeginning;
    property SinceLastOutput: Integer read FSinceLastOutput;
  end;

  TNewLineEvent = procedure(Sender: TObject; NewLine: string; OutputType: TOutputType) of object;
  TNewErrorEvent = procedure(Sender: TObject; Message: string) of object;

  TDosThread = class(TThread) //the thread that is waiting for outputs through the pipe
  private
    FOwner: TObject;
    FCommandLine: string;
    FInputToOutput: Boolean;
    FTimer: TProcessTimer;
    FMaxTimeAfterBeginning: Integer;
    FMaxTimeAfterLastOutput: Integer;
    FOnNewLine: TNewLineEvent;
    FOnNewError: TNewErrorEvent;
    FOnTerminated: TNotifyEvent;
    FCreatePipeError: TCreatePipeError;
    FCreateProcessError: TCreateProcessError;
    FPriority: Integer;
    FInputLinesLock: TRTLCriticalSection; // Lock for InputLines access
    inputPipeRead, inputPipeWrite: THandle; // stdin pipe handles
    outputPipeRead, outputPipeWrite: THandle; // stdout pipe handles
    errorPipeRead, errorPipeWrite: THandle; // stderr pipe handles

    sa: PSECURITYATTRIBUTES; //security information for pipes
    sd: PSECURITY_DESCRIPTOR;
    pi: TProcessInformation;

    procedure FExecute;
    procedure WriteToStdIn();
    function CheckProcessAlive(): boolean;
  protected
    procedure Execute; override; //call this to create the process
  public
    show_window: boolean;
    InputLines: TstringList;
    constructor Create(AOwner: TObject; Cl: string; t: TProcessTimer; mtab, mtalo: Integer; Onl: TNewLineEvent;
      One: TNewErrorEvent; Ot: TNotifyEvent; p: Integer; ito, _show_window: Boolean);
    destructor Destroy; override;
  end;

implementation
uses StrUtils;
//type TCharBuffer = array[0..MaxInt - 1] of Char;
{$IF CompilerVersion >= 22.0 THEN}
type TCharBuffer = array[0..MaxBufSize - 1] of AnsiChar;
{$ELSE}
type TCharBuffer = array[0..MaxBufSize - 1] of Char;
{$IFEND}

//------------------------------------------------------------------------------

constructor TProcessTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Enabled := False; //timer is off
  OnTimer := MyTimer;
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.MyTimer(Sender: TObject);
begin
  Inc(FSinceBeginning);
  Inc(FSinceLastOutput);
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.Beginning;
begin
  Interval := 1000; //time is in sec
  FSinceBeginning := 0; //this is the beginning
  FSinceLastOutput := 0;
  Enabled := True; //set the timer on
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.NewOutput;
begin
  FSinceLastOutput := 0; //a new output has been caught
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.Ending;
begin
  Enabled := False; //set the timer off
end;

function TDosThread.CheckProcessAlive(): boolean;
var
  Exit_Code: DWORD; //process exit code
begin
  result := false;
  if @pi <> nil then begin
    GetExitCodeProcess(pi.hProcess, Exit_Code); //while the process is running
    result := Exit_Code = STILL_ACTIVE;
  end;
end;

//------------------------------------------------------------------------------
procedure TDosThread.FExecute;
var
  pBuf: TCharBuffer; // stdout buffer
  errorBuf: TCharBuffer; // stderr buffer
  iBufSize: Cardinal;
  app_spawn: PChar;
  si: TStartupInfo;
  bread: DWORD; //bytes read
  readed: DWORD;
  errorReaded: DWORD;
  avail: DWORD; //bytes available in stdout
  errorAvail: DWORD; //bytes available in stderr
  Str, Last, ErrorStr: string;
  I: LongWord;
  LineBeginned, created: Boolean;
begin //FExecute

  // START PROCESS
  ZeroMemory(@si, SizeOf(TStartupInfo));
  si.cb := SizeOf(TStartupInfo);
  si.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  if show_window then
    si.wShowWindow := SW_SHOW
  else
    si.wShowWindow := SW_HIDE;
  si.hStdOutput := outputPipeWrite;
  si.hStdError := errorPipeWrite; // Separate pipe for stderr
  si.hStdInput := inputPipeRead;

  app_spawn := PChar(FCommandLine);

  //spawn the child process
  created := CreateProcess(
    nil,
    app_spawn, // cmd line
    nil,  // proc security attre
    nil,  // primary thread secur attr
    TRUE, // handles inherited
    FPriority, // use priority flag
    nil,  // use parent env
    nil,  // use parent cur directory
    si,   // pointer startup info
    pi    // receives Proc INFO
  );
  if not created then
  begin
    raise TCreateProcessError.Create(string(app_spawn) + ' doesn''t exist or cannot be started.');
  end;

  Last := ''; // Buffer to save last output without finished with CRLF
  ErrorStr := ''; // Buffer for stderr
  Str := '';
  LineBeginned := False;
  iBufSize := MaxBufSize;
  FillChar(pBuf, iBufSize, #0);
  FillChar(errorBuf, iBufSize, #0);
  try
    repeat //main program loop
      if not CheckProcessAlive() or Terminated then begin
        break;
      end;
      // Read stdout
      PeekNamedPipe(outputPipeRead, nil, 0, @bread, @avail, nil);
      if avail > 0 then
      begin
        Str := Last; //take the begin of the line (if exists)
        repeat
          FillChar(pBuf, iBufSize, #0); //empty the buffer
          ReadFile(outputPipeRead, pBuf[0], MaxBufSize, readed, nil); //read the stdout pipe
          I := 0;
          while (I < readed) and not Terminated do
          begin
            case pBuf[I] of
              #0: Inc(I);
              #10:
                begin
                  Inc(I);
                  FTimer.NewOutput; //a new output has been caught
                  if Assigned(FOnNewLine) then
                    Synchronize(procedure begin
                      FOnNewLine(FOwner, Str, otEntireLine);
                    end);
                  Str := '';
                end;
              #13:
                begin
                  Inc(I);
                  if (I < readed) and (pBuf[I] = #10) then
                    Inc(I); //skip #10 if follows #13
                  FTimer.NewOutput; //a new output has been caught
                  if Assigned(FOnNewLine) then
                    Synchronize(procedure begin
                      FOnNewLine(FOwner, Str, otEntireLine);
                    end);
                  Str := '';
                end;
            else
              begin
                Str := Str + string(pBuf[I]); //add a character
                LineBeginned := True;
                Inc(I);
              end;
            end;
          end;
          avail := avail - readed;
          Last := Str; // no CRLF found in the rest, maybe in the next output
        until avail <= 0;
      end;

      // Read stderr
      PeekNamedPipe(errorPipeRead, nil, 0, @bread, @errorAvail, nil);
      if errorAvail > 0 then
      begin
        repeat
          FillChar(errorBuf, iBufSize, #0);
          ReadFile(errorPipeRead, errorBuf[0], MaxBufSize, errorReaded, nil);
          I := 0;
          while (I < errorReaded) and not Terminated do
          begin
            case errorBuf[I] of
              #0: Inc(I);
              #10:
                begin
                  Inc(I);
                  if ErrorStr <> '' then
                  begin
                    if Assigned(FOnNewError) then
                      Synchronize(procedure begin
                        FOnNewError(FOwner, ErrorStr);
                      end);
                  end;
                  ErrorStr := '';
                end;
              #13:
                begin
                  Inc(I);
                  if (I < errorReaded) and (errorBuf[I] = #10) then
                    Inc(I);
                  if ErrorStr <> '' then
                  begin
                    if Assigned(FOnNewError) then
                      Synchronize(procedure begin
                        FOnNewError(FOwner, ErrorStr);
                      end);
                  end;
                  ErrorStr := '';
                end;
            else
              begin
                ErrorStr := ErrorStr + string(errorBuf[I]);
                Inc(I);
              end;
            end;
          end;
          errorAvail := errorAvail - errorReaded;
        until errorAvail <= 0;
        if ErrorStr <> '' then
        begin
          if Assigned(FOnNewError) then
            Synchronize(procedure begin
              FOnNewError(FOwner, ErrorStr);
            end);
        end;
        ErrorStr := '';
      end;
      
      //send lines in input (if exist)
      self.WriteToStdIn;

      Sleep(SleepPause); // Give other processes a chance

    until Terminated
      or ((FMaxTimeAfterBeginning < FTimer.FSinceBeginning) and (FMaxTimeAfterBeginning > 0)) //time out
      or ((FMaxTimeAfterLastOutput < FTimer.FSinceLastOutput) and (FMaxTimeAfterLastOutput > 0)) //time out
      ; //user requested stop

    // Terminate process only if still running
    if CheckProcessAlive() then
      TerminateProcess(pi.hProcess, 0);
  finally
    
  end;
  FTimer.Ending; //turn the timer off
  if Assigned(FOnTerminated) then
    Synchronize(procedure begin
      FOnTerminated(FOwner);
    end);
end;

//------------------------------------------------------------------------------

procedure TDosThread.Execute;
begin
  FExecute;
end;

//------------------------------------------------------------------------------

constructor TDosThread.Create(AOwner: TObject; Cl: string; t: TProcessTimer; mtab, mtalo: Integer; Onl: TNewLineEvent;
 One: TNewErrorEvent; Ot: TNotifyEvent; p: Integer; ito, _show_window: Boolean);
begin
  InitializeCriticalSection(FInputLinesLock);
  FOwner := AOwner;
  FCommandline := Cl;
  InputLines := TStringList.Create;
  InputLines.Clear;
  FInputToOutput := ito;
  FOnNewLine := Onl;
  FOnNewError := One;
  FOnTerminated := Ot;
  FTimer := t;
  FMaxTimeAfterBeginning := mtab;
  FMaxTimeAfterLastOutput := mtalo;
  FPriority := p;
  show_window := _show_window;

  GetMem(sa, sizeof(SECURITY_ATTRIBUTES));
  sd := nil;
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin //initialize security descriptor (Windows NT)
    GetMem(sd, sizeof(SECURITY_DESCRIPTOR));
    InitializeSecurityDescriptor(sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(sd, true, nil, false);
    sa.lpSecurityDescriptor := sd;
  end
  else begin
    sa.lpSecurityDescriptor := nil;
  end;
  sa.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle := true; //allow inheritable handles

  // Create stdin pipe
  if not CreatePipe(inputPipeRead, inputPipeWrite, sa, 0) then
  begin
    raise FCreatePipeError.Create('Cannot create stdin pipe');
  end;

  // Create stdout pipe
  if not CreatePipe(outputPipeRead, outputPipeWrite, sa, 0) then
  begin
    raise FCreatePipeError.Create('Cannot create stdout pipe');
  end;

  // Create stderr pipe
  if not CreatePipe(errorPipeRead, errorPipeWrite, sa, 0) then
  begin
    raise FCreatePipeError.Create('Cannot create stderr pipe');
  end;

  inherited Create(False);
end;

destructor TDosThread.Destroy;
begin
  if errorPipeRead <> 0 then begin
    CloseHandle(errorPipeRead);
  end;
  if errorPipeWrite <> 0 then
    CloseHandle(errorPipeWrite);
  if outputPipeRead <> 0 then
    CloseHandle(outputPipeRead);
  if outputPipeWrite <> 0 then
    CloseHandle(outputPipeWrite);
  if errorPipeRead <> 0 then
    CloseHandle(errorPipeRead);
  if inputPipeWrite <> 0 then
    CloseHandle(inputPipeWrite);
  if Assigned(sd) then
    FreeMem(sd);
  if Assigned(sa) then
    FreeMem(sa);

  DeleteCriticalSection(FInputLinesLock);
  inherited;
end;

procedure TDosThread.WriteToStdIn;
var
  bytesWritten: DWORD;
  Str: string;
  oem: CyrillicAnsi;
  LineToProcess: string;
begin
  //send lines in input (if exist)
  EnterCriticalSection(FInputLinesLock);
  try
    while (InputLines.Count > 0) and not Terminated do
    begin
      LineToProcess := InputLines[0] + #13+#10;
      InputLines.Delete(0); //delete the line immediately after reading
      
      oem := CyrillicAnsi(LineToProcess);
      if not WriteFile(inputPipeWrite, PAnsiChar(oem)^, ByteLength(oem), bytesWritten, nil) then
      begin
        // Write failed - pipe may be broken
        Break;
      end;

      if FInputToOutput then //if we have to output the inputs
      begin
        if Assigned(FOnNewLine) then
          FOnNewLine(FOwner, Copy(LineToProcess, 1, Length(LineToProcess) - 2), otEntireLine);
      end;
    end;
  finally
    LeaveCriticalSection(FInputLinesLock);
  end;
end;

end.


