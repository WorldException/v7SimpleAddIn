unit FormForTest;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, AxCtrls, AddIn_TLB, StdVcl, Vcl.StdCtrls,RTTI, Vcl.ExtCtrls,
  PythonEngine, PythonGUIInputOutput, Vcl.ActnList, Vcl.ComCtrls;

type
  TFormForTesting = class(TActiveForm, IFormForTesting)
    PythonGUIInputOutput1: TPythonGUIInputOutput;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    mConsole: TMemo;
    Splitter1: TSplitter;
    ActionList1: TActionList;
    acRun: TAction;
    acRunThreaded: TAction;
    TabControl1: TTabControl;
    mModule: TRichEdit;
    Panel2: TPanel;
    btRun: TButton;
    btBackground: TButton;
    mEval: TRichEdit;
    acEval: TAction;
    acEvalBackground: TAction;
    Panel3: TPanel;
    eFunName: TEdit;
    eParam: TEdit;
    Button3: TButton;
    acRunFunctionThreaded: TAction;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ActiveFormCreate(Sender: TObject);
    procedure ActiveFormDestroy(Sender: TObject);
    procedure acRunExecute(Sender: TObject);
    procedure acRunThreadedExecute(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure acEvalExecute(Sender: TObject);
    procedure acEvalBackgroundExecute(Sender: TObject);
    procedure acRunFunctionThreadedExecute(Sender: TObject);
    procedure mEvalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    MDIHandle:HWND;
    { Private declarations }
    FEvents: IFormForTestingEvents;
    procedure ActivateEvent(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure CreateEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure DeactivateEvent(Sender: TObject);
    procedure DestroyEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure MouseEnterEvent(Sender: TObject);
    procedure MouseLeaveEvent(Sender: TObject);
    procedure PaintEvent(Sender: TObject);
  protected
    { Protected declarations }
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    function Get_Active: WordBool; safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_AlignWithMargins: WordBool; safecall;
    function Get_AutoScroll: WordBool; safecall;
    function Get_AutoSize: WordBool; safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    function Get_BorderWidth: Integer; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Color: OLE_COLOR; safecall;
    function Get_DockSite: WordBool; safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_ExplicitHeight: Integer; safecall;
    function Get_ExplicitLeft: Integer; safecall;
    function Get_ExplicitTop: Integer; safecall;
    function Get_ExplicitWidth: Integer; safecall;
    function Get_Font: IFontDisp; safecall;
    function Get_HelpFile: WideString; safecall;
    function Get_KeyPreview: WordBool; safecall;
    function Get_MouseInClient: WordBool; safecall;
    function Get_ParentCustomHint: WordBool; safecall;
    function Get_ParentDoubleBuffered: WordBool; safecall;
    function Get_PixelsPerInch: Integer; safecall;
    function Get_PopupMode: TxPopupMode; safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    function Get_Scaled: WordBool; safecall;
    function Get_ScreenSnap: WordBool; safecall;
    function Get_SnapBuffer: Integer; safecall;
    function Get_UseDockManager: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    procedure _Set_Font(var Value: IFontDisp); safecall;
    procedure Set_AlignWithMargins(Value: WordBool); safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    procedure Set_BorderWidth(Value: Integer); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Color(Value: OLE_COLOR); safecall;
    procedure Set_DockSite(Value: WordBool); safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Font(const Value: IFontDisp); safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    procedure Set_ParentCustomHint(Value: WordBool); safecall;
    procedure Set_ParentDoubleBuffered(Value: WordBool); safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    procedure Set_PopupMode(Value: TxPopupMode); safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    procedure Set_ScreenSnap(Value: WordBool); safecall;
    procedure Set_SnapBuffer(Value: Integer); safecall;
    procedure Set_UseDockManager(Value: WordBool); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure axTestContext(cont: OleVariant); safecall;
    procedure SetWNDHandle(wnd: OleVariant); safecall;
  public
    { Public declarations }
    Context  : OleVariant;
    procedure Initialize; override;
  end;

implementation

uses ComObj, ComServ, PyEngine, StrUtils;

{$R *.DFM}

{ TFormForTesting }

procedure TFormForTesting.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_FormForTestingPage); }
end;

procedure TFormForTesting.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IFormForTestingEvents;
  inherited EventSinkChanged(EventSink);
end;

procedure TFormForTesting.Initialize;
begin
  inherited Initialize;
  OnActivate := ActivateEvent;
  OnClick := ClickEvent;
  OnCreate := CreateEvent;
  OnDblClick := DblClickEvent;
  OnDeactivate := DeactivateEvent;
  OnDestroy := DestroyEvent;
  OnKeyPress := KeyPressEvent;
  OnMouseEnter := MouseEnterEvent;
  OnMouseLeave := MouseLeaveEvent;
  OnPaint := PaintEvent;
end;
{$REGION}
function TFormForTesting.Get_Active: WordBool;
begin
  Result := Active;
end;

function TFormForTesting.Get_AlignDisabled: WordBool;
begin
  Result := AlignDisabled;
end;

function TFormForTesting.Get_AlignWithMargins: WordBool;
begin
  Result := AlignWithMargins;
end;

function TFormForTesting.Get_AutoScroll: WordBool;
begin
  Result := AutoScroll;
end;

function TFormForTesting.Get_AutoSize: WordBool;
begin
  Result := AutoSize;
end;

function TFormForTesting.Get_AxBorderStyle: TxActiveFormBorderStyle;
begin
  Result := Ord(AxBorderStyle);
end;

function TFormForTesting.Get_BorderWidth: Integer;
begin
  Result := Integer(BorderWidth);
end;

function TFormForTesting.Get_Caption: WideString;
begin
  Result := WideString(Caption);
end;

function TFormForTesting.Get_Color: OLE_COLOR;
begin
  Result := OLE_COLOR(Color);
end;

function TFormForTesting.Get_DockSite: WordBool;
begin
  Result := DockSite;
end;

function TFormForTesting.Get_DoubleBuffered: WordBool;
begin
  Result := DoubleBuffered;
end;

function TFormForTesting.Get_DropTarget: WordBool;
begin
  Result := DropTarget;
end;

function TFormForTesting.Get_Enabled: WordBool;
begin
  Result := Enabled;
end;

function TFormForTesting.Get_ExplicitHeight: Integer;
begin
  Result := ExplicitHeight;
end;

function TFormForTesting.Get_ExplicitLeft: Integer;
begin
  Result := ExplicitLeft;
end;

function TFormForTesting.Get_ExplicitTop: Integer;
begin
  Result := ExplicitTop;
end;

function TFormForTesting.Get_ExplicitWidth: Integer;
begin
  Result := ExplicitWidth;
end;

function TFormForTesting.Get_Font: IFontDisp;
begin
  GetOleFont(Font, Result);
end;

function TFormForTesting.Get_HelpFile: WideString;
begin
  Result := WideString(HelpFile);
end;

function TFormForTesting.Get_KeyPreview: WordBool;
begin
  Result := KeyPreview;
end;

function TFormForTesting.Get_MouseInClient: WordBool;
begin
  Result := MouseInClient;
end;

function TFormForTesting.Get_ParentCustomHint: WordBool;
begin
  Result := ParentCustomHint;
end;

function TFormForTesting.Get_ParentDoubleBuffered: WordBool;
begin
  Result := ParentDoubleBuffered;
end;

function TFormForTesting.Get_PixelsPerInch: Integer;
begin
  Result := PixelsPerInch;
end;

function TFormForTesting.Get_PopupMode: TxPopupMode;
begin
  Result := Ord(PopupMode);
end;

function TFormForTesting.Get_PrintScale: TxPrintScale;
begin
  Result := Ord(PrintScale);
end;

function TFormForTesting.Get_Scaled: WordBool;
begin
  Result := Scaled;
end;

function TFormForTesting.Get_ScreenSnap: WordBool;
begin
  Result := ScreenSnap;
end;

function TFormForTesting.Get_SnapBuffer: Integer;
begin
  Result := SnapBuffer;
end;

function TFormForTesting.Get_UseDockManager: WordBool;
begin
  Result := UseDockManager;
end;

function TFormForTesting.Get_Visible: WordBool;
begin
  Result := Visible;
end;

function TFormForTesting.Get_VisibleDockClientCount: Integer;
begin
  Result := VisibleDockClientCount;
end;

procedure TFormForTesting._Set_Font(var Value: IFontDisp);
begin
  SetOleFont(Font, Value);
end;

procedure TFormForTesting.acEvalBackgroundExecute(Sender: TObject);
begin
  //ToDo
end;

procedure TFormForTesting.acEvalExecute(Sender: TObject);
begin
  PyEngine.dmPyEngine.Eval(mEval.Text);
end;

procedure TFormForTesting.acRunExecute(Sender: TObject);
begin
  PyEngine.dmPyEngine.RunStrings(mModule.Lines);
end;

procedure TFormForTesting.acRunFunctionThreadedExecute(Sender: TObject);
begin
  PyEngine.dmPyEngine.RunFunctionThreaded(eFunName.Text, eParam.Text)
end;

procedure TFormForTesting.acRunThreadedExecute(Sender: TObject);
begin
  PyEngine.dmPyEngine.RunStringThreaded(mModule.Lines);
end;

procedure TFormForTesting.ActivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnActivate;
end;
{$ENDREGION}
procedure TFormForTesting.Button1Click(Sender: TObject);
begin
  PostMessage(MDIHandle,WM_CLOSE,0,0);
end;

procedure TFormForTesting.Button2Click(Sender: TObject);
begin
  Context.ОбработкаВыбора('ButtonClick','По событию');
end;
{$REGION; автогеренируемое}
procedure TFormForTesting.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnClick;
end;

procedure TFormForTesting.CreateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnCreate;
end;

procedure TFormForTesting.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDblClick;
end;

procedure TFormForTesting.DeactivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDeactivate;
end;

procedure TFormForTesting.DestroyEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDestroy;
end;

procedure TFormForTesting.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  if FEvents <> nil then FEvents.OnKeyPress(TempKey);
  Key := Char(TempKey);
end;

procedure TFormForTesting.mEvalKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  m: TRichEdit;
begin
  m := TRichEdit(Sender);
  mConsole.Lines.Add('down '+IntToStr(ord(key)));
  if Key = 9 then begin
    Key := 0;
    mConsole.Lines.Add(m.Lines[m.CaretPos.Y]);
    m.Lines[m.CaretPos.Y] := LeftStr(m.Lines[m.CaretPos.Y], m.CaretPos.X) +
      '  ' + Copy(m.Lines[m.CaretPos.Y], m.CaretPos.X+1);
  end;
end;

procedure TFormForTesting.MouseEnterEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnMouseEnter;
end;

procedure TFormForTesting.MouseLeaveEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnMouseLeave;
end;

procedure TFormForTesting.PaintEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnPaint;
end;

procedure TFormForTesting.Set_AlignWithMargins(Value: WordBool);
begin
  AlignWithMargins := Value;
end;

procedure TFormForTesting.Set_AutoScroll(Value: WordBool);
begin
  AutoScroll := Value;
end;

procedure TFormForTesting.Set_AutoSize(Value: WordBool);
begin
  AutoSize := Value;
end;

procedure TFormForTesting.Set_AxBorderStyle(Value: TxActiveFormBorderStyle);
begin
  AxBorderStyle := TActiveFormBorderStyle(Value);
end;

procedure TFormForTesting.Set_BorderWidth(Value: Integer);
begin
  BorderWidth := TBorderWidth(Value);
end;

procedure TFormForTesting.Set_Caption(const Value: WideString);
begin
  Caption := TCaption(Value);
end;

procedure TFormForTesting.Set_Color(Value: OLE_COLOR);
begin
  Color := TColor(Value);
end;

procedure TFormForTesting.Set_DockSite(Value: WordBool);
begin
  DockSite := Value;
end;

procedure TFormForTesting.Set_DoubleBuffered(Value: WordBool);
begin
  DoubleBuffered := Value;
end;

procedure TFormForTesting.Set_DropTarget(Value: WordBool);
begin
  DropTarget := Value;
end;

procedure TFormForTesting.Set_Enabled(Value: WordBool);
begin
  Enabled := Value;
end;

procedure TFormForTesting.Set_Font(const Value: IFontDisp);
begin
  SetOleFont(Font, Value);
end;

procedure TFormForTesting.Set_HelpFile(const Value: WideString);
begin
  HelpFile := string(Value);
end;

procedure TFormForTesting.Set_KeyPreview(Value: WordBool);
begin
  KeyPreview := Value;
end;

procedure TFormForTesting.Set_ParentCustomHint(Value: WordBool);
begin
  ParentCustomHint := Value;
end;

procedure TFormForTesting.Set_ParentDoubleBuffered(Value: WordBool);
begin
  ParentDoubleBuffered := Value;
end;

procedure TFormForTesting.Set_PixelsPerInch(Value: Integer);
begin
  PixelsPerInch := Value;
end;

procedure TFormForTesting.Set_PopupMode(Value: TxPopupMode);
begin
  PopupMode := TPopupMode(Value);
end;

procedure TFormForTesting.Set_PrintScale(Value: TxPrintScale);
begin
  PrintScale := TPrintScale(Value);
end;

procedure TFormForTesting.Set_Scaled(Value: WordBool);
begin
  Scaled := Value;
end;

procedure TFormForTesting.Set_ScreenSnap(Value: WordBool);
begin
  ScreenSnap := Value;
end;

procedure TFormForTesting.Set_SnapBuffer(Value: Integer);
begin
  SnapBuffer := Value;
end;

procedure TFormForTesting.Set_UseDockManager(Value: WordBool);
begin
  UseDockManager := Value;
end;

procedure TFormForTesting.Set_Visible(Value: WordBool);
begin
  Visible := Value;
end;
procedure TFormForTesting.TabControl1Change(Sender: TObject);
var
  visiblEdits: boolean;
begin
  if TabControl1.TabIndex = 0 then begin
    // Код скрипта
    mModule.Visible := True;
    mEval.Visible := False;
    btRun.Action := acRun;
    btBackground.Action := acRunThreaded;

    acRun.Enabled := true;
    acRunThreaded.Enabled := true;
    acEval.Enabled := false;
    acEvalBackground.Enabled := false;

  end else begin
    mEval.Visible := True;
    mModule.Visible := False;
    btRun.Action := acEval;
    btBackground.Action := acEvalBackground;

    acRun.Enabled := false;
    acRunThreaded.Enabled := false;
    acEval.Enabled := true;
    acEvalBackground.Enabled := true;

  end;

end;

{$ENDREGION}
procedure TFormForTesting.ActiveFormCreate(Sender: TObject);
begin
  PyEngine.dmPyEngine.SetPythonGUI(PythonGUIInputOutput1);
  mConsole.Lines.Add('created');
end;

procedure TFormForTesting.ActiveFormDestroy(Sender: TObject);
begin
  PyEngine.dmPyEngine.ClearPythonGUI;
end;

procedure TFormForTesting.axTestContext(cont: OleVariant);
begin
  Context := cont.Сам;
  Context.ОбработкаВыбора('TestContext','При открытии формы');
end;

procedure TFormForTesting.SetWNDHandle(wnd: OleVariant);
begin
  MDIHandle := wnd;
end;

initialization
  TActiveFormFactory.Create(
    ComServer,
    TActiveFormControl,
    TFormForTesting,
    Class_FormForTesting,
    0,
    '',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL,
    tmSingle);
finalization

end.
