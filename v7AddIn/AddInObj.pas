unit AddInObj;
{
  Доработанный шаблон внешней компоненты для 1С 7 и 8
  Компилировать в >= XE2
  Автор Евгений quick.es@gmail.com

  Помни!!! Проект должен называться AddIn.dll, переименовывать можно только готовый файл
  иначе при загрузке получишь Не найден CLSID
  В самом конце модуля надо сгенерировать новый GUID Ctrl+Shift+G
}
interface

uses
  Windows, Dialogs, Forms, ActiveX, ComObj, SysUtils, AddInLib,
  System.RTTI, Classes;

type
  v7Atribute = class(TCustomAttribute)
    procedure parseEngRus();
  public
    strEngRus, strEng, strRus: string;
    function hasName(strName: WideString): boolean;
  end;

  v7Method = class(v7Atribute)
  public
    paramsCount, retValue: integer;
    method: TRttiMethod;
    constructor Create(strEngRus_: string);
  end;

  v7Property = class(v7Atribute)
  public
    Value: OleVariant;
    readOnly: Boolean;
    prop: TRttiProperty;
    constructor Create(strEngRus_: string);
  end;

  TBaseAddIn = class(TComObject, IinitDone, ILanguageExtender, ISpecifyPropertyPages)
  private
    LContext: TRttiContext;
    procedure InitV7RttiInfo;
    function GetPages(out Pages: TCAGUID): HResult; stdcall;
  public
    fEventSource, fEventAction, fEventPrefix: string;
    v7MethodsArray: array of v7Method;
    v7PropsArray: array of v7Property;
    { Interfaces }
    pConn: IDispatch;
    pErrorLog: IErrorLog;
    pEvent: IAsyncEvent;
    pProfile: IPropertyProfile;
    pExtWndsSupport: IExtWndsSupport;
    pStatusLine: IStatusLine;
    ApplicationHandle: HWND;

    {Функция для получения ссылки на контекст 1С без зависания при выходе}
    function v7GetAppDisp:OleVariant;

    procedure ShowErrorLog(MsgText:String);
    procedure SendEvent(MsgText:String; Sender:String='Process'; Source:String='Message');

    procedure Initialize; override;
    destructor Destroy; override;

    procedure after_done(); virtual;

  {$REGION}
  protected
    function ExtensionName:string; virtual; abstract;
    function LoadProperties: boolean;
    procedure SaveProperties;
    { This function is useful in ILanguageExtender implementation }
    { These two methods is convenient way to access function
      parameters from SAFEARRAY vector of variants }
    function GetNParam(var pArray: PSafeArray; lIndex: integer): OleVariant;
    procedure PutNParam(var pArray: PSafeArray; lIndex: integer;
      var varPut: OleVariant);

    { Interface implementation }
    { IInitDone implementation }
    function Init(const pConnection: IDispatch): HResult; stdcall;
    function Done: HResult; stdcall;
    function GetInfo(var pInfo: PSafeArray { (OleVariant) } ): HResult; stdcall;
    { ILanguageExtender implementation }
    function RegisterExtensionAs(var bstrExtensionName: WideString)
      : HResult; stdcall;
    function GetNProps(var plProps: integer): HResult; stdcall;
    function FindProp(const bstrPropName: WideString; var plPropNum: integer)
      : HResult; stdcall;
    function GetPropName(lPropNum, lPropAlias: integer;
      var pbstrPropName: WideString): HResult; stdcall;
    function GetPropVal(lPropNum: integer; var pvarPropVal: OleVariant)
      : HResult; stdcall;
    function SetPropVal(lPropNum: integer; var varPropVal: OleVariant)
      : HResult; stdcall;
    function IsPropReadable(lPropNum: integer; var pboolPropRead: integer)
      : HResult; stdcall;
    function IsPropWritable(lPropNum: integer; var pboolPropWrite: integer)
      : HResult; stdcall;
    function GetNMethods(var plMethods: integer): HResult; stdcall;
    function FindMethod(const bstrMethodName: WideString;
      var plMethodNum: integer): HResult; stdcall;
    function GetMethodName(lMethodNum, lMethodAlias: integer;
      var pbstrMethodName: WideString): HResult; stdcall;
    function GetNParams(lMethodNum: integer; var plParams: integer)
      : HResult; stdcall;
    function GetParamDefValue(lMethodNum, lParamNum: integer;
      var pvarParamDefValue: OleVariant): HResult; stdcall;
    function HasRetVal(lMethodNum: integer; var pboolRetValue: integer)
      : HResult; stdcall;
    function CallAsProc(lMethodNum: integer;
      var paParams: PSafeArray { (OleVariant) } ): HResult; stdcall;
    function CallAsFunc(lMethodNum: integer; var pvarRetValue: OleVariant;
      var paParams: PSafeArray { (OleVariant) } ): HResult; stdcall;
    {$ENDREGION}
  end;

  TClassBaseAddIn = class of TBaseAddIn;


  procedure RegisterAddIn(cls:TClassBaseAddIn; guid: TGUID; name: string);


  { var
    v7MethodsArray : array of v7MethodAtribute; }
  {procedure ShowErrorLog(MsgText:String);
  procedure SendEvent(MsgText:String; Sender:String='Python'; Source:String='Message');}

  var
   //instance: TAddInProcess;
   CatalogIB: string;

implementation

uses ComServ, TypInfo, PropPage, Variants, StrUtils;
{
procedure ShowErrorLog(MsgText:String);
begin
  if Assigned(instance) then
    instance.ShowErrorLog(MsgText);
end;
procedure SendEvent(MsgText:String; Sender:String='Python'; Source:String='Message');
begin
  if Assigned(instance) then
    instance.SendEvent(MsgText, Sender, Source);
end;
}

procedure RegisterAddIn(cls:TClassBaseAddIn; guid: TGUID; name: string);
begin
  // очень важно, иначе будет не найден CLSID
  ComServer.SetServerName('AddIn');
  TComObjectFactory.Create(ComServer, cls, guid, name,'V7 AddIn 2.0', ciMultiInstance, tmSingle);
end;
{$REGION}
function TBaseAddIn.v7GetAppDisp: OleVariant;
var
  AppDisp:IDispatch;
begin
  AppDisp := OleVariant(pConn).AppDispatch;
  AppDisp._AddRef;
  result := Variant(AppDisp);
end;

procedure TBaseAddIn.InitV7RttiInfo();
var
  LType: TRttiType;
  LAttr: TCustomAttribute;
  LMeth: TRttiMethod;
  LProp: TRttiProperty;
  countMethods: integer;
  v7Atr: v7Method;
  v7PropAtr: v7Property;
begin
  countMethods := 0;
  SetLength(v7MethodsArray, 2);
  { Create a new Rtti context }
  LContext := TRttiContext.Create;
  { Extract type information for TSomeType type }
  LType := LContext.GetType(self.ClassType);
  { Search for the custom attribute and do some custom processing }
  for LMeth in LType.GetMethods() do
  begin
    for LAttr in LMeth.GetAttributes() do
      if LAttr is v7Method then
      begin
        v7Atr := v7Method(LAttr);
        v7Atr.method := LMeth;
        v7Atr.paramsCount := Length(LMeth.GetParameters);
        v7Atr.retValue := integer(LMeth.MethodKind = mkFunction);
        inc(countMethods);
        SetLength(v7MethodsArray, countMethods);
        v7MethodsArray[countMethods - 1] := v7Atr;
      end;
  end;
  countMethods := 0;
  for LProp in LType.GetProperties() do
  begin
    for LAttr in LProp.GetAttributes() do
      if LAttr is v7Property then
      begin
        inc(countMethods);
        SetLength(v7PropsArray, countMethods);
        v7PropAtr := v7Property(LAttr);
        v7PropAtr.prop := LProp;
        v7PropAtr.readOnly := Not LProp.IsWritable;
        v7PropsArray[countMethods - 1] := v7PropAtr;
      end;
  end;
  { Destroy the context }
  // LContext.Free;
end;

function TBaseAddIn.LoadProperties: boolean;
begin
  LoadProperties := True;
end;


procedure TBaseAddIn.SaveProperties;
begin

end;

procedure TBaseAddIn.SendEvent(MsgText: String; Sender:String='Process'; Source:String='Message');
begin
  //ShowClip
  pEvent.ExternalEvent(Trim(Sender), Trim(Source), Trim(MsgText));
end;

function TBaseAddIn.GetNParam(var pArray: PSafeArray; lIndex: integer)
  : OleVariant;
var
  varGet: OleVariant;
begin
  SafeArrayGetElement(pArray, lIndex, varGet);
  GetNParam := varGet;
end;

procedure TBaseAddIn.PutNParam(var pArray: PSafeArray; lIndex: integer;
  var varPut: OleVariant);
begin
  SafeArrayPutElement(pArray, lIndex, varPut);
end;

{ IInitDone interface }

function TBaseAddIn.Init(const pConnection: IDispatch): HResult; stdcall;
var
  iRes: integer;
  wnd: HWND;
begin
  pConn := pConnection;

  pErrorLog := nil;
  pConnection.QueryInterface(IID_IErrorLog, pErrorLog);

  pEvent := nil;
  pConnection.QueryInterface(IID_IAsyncEvent, pEvent);

  pProfile := nil;
  iRes := pConnection.QueryInterface(IID_IPropertyProfile, pProfile);
  if (iRes = S_OK) then
  begin
    //ToDo как быть с сохранением?
    //pProfile.RegisterProfileAs(TAddInProcess.ExtensionName);
    if (LoadProperties() <> True) then
    begin
      Init := E_FAIL;
      Exit;
    end;
  end;

  pStatusLine := nil;
  pConnection.QueryInterface(IID_IStatusLine, pStatusLine);

  pExtWndsSupport := nil;
  pConnection.QueryInterface(IID_IExtWndsSupport, pExtWndsSupport);

  pExtWndsSupport.GetAppMainFrame(wnd);
  Application.Handle := wnd;
  ApplicationHandle := wnd;

  //CatalogIB := v7GetAppDisp.EvalExpr('КаталогИБ()');
  // Буфер отправляемых событий
  pEvent.SetEventBufferDepth(100);

  Init := S_OK;
end;

procedure TBaseAddIn.Initialize;
begin
  inherited;
  InitV7RttiInfo;
end;

destructor TBaseAddIn.Destroy;
begin
  LContext.Free;
  inherited;
end;

function TBaseAddIn.Done: HResult; stdcall;
begin
  SaveProperties();

  if (pErrorLog <> nil) then
    pErrorLog._Release();

  if (pEvent <> nil) then
    pEvent._Release();

  if (pProfile <> nil) then
    pProfile._Release();

  if (pStatusLine <> nil) then
    pStatusLine._Release();

  if (pExtWndsSupport <> nil) then
    pExtWndsSupport._Release();

  self.after_done();

  Done := S_OK;
end;

function TBaseAddIn.GetInfo(var pInfo: PSafeArray { (OleVariant) } )
  : HResult; stdcall;
var
  varInfo: OleVariant;
begin
  varInfo := '2000';
  PutNParam(pInfo, 0, varInfo);
  GetInfo := S_OK;
end;

{ ISpecifyPropertyPages interface }

function TBaseAddIn.GetPages(out Pages: TCAGUID) : HResult; stdcall;
begin
  Pages.cElems := 1;
  Pages.pElems := CoTaskMemAlloc(SizeOf(TGUID));
  (Pages.pElems)[0] := Class_AddInPropPage;
  GetPages := S_OK;
end;

{ ILanguageExtender interface }

function TBaseAddIn.RegisterExtensionAs(var bstrExtensionName: WideString)
  : HResult; stdcall;
begin
  bstrExtensionName := self.ExtensionName;
  RegisterExtensionAs := S_OK;
end;

function TBaseAddIn.GetNProps(var plProps: integer): HResult; stdcall;
begin
  plProps := Length(v7PropsArray) - 1;
  GetNProps := S_OK;
end;

function TBaseAddIn.FindProp(const bstrPropName: WideString;
  var plPropNum: integer): HResult; stdcall;
var
  i: integer;
begin
  plPropNum := -1;
  FindProp := S_FALSE;
  for i := 0 to Length(v7PropsArray) - 1 do
  begin
    if v7PropsArray[i].hasName(bstrPropName) then
    begin
      plPropNum := i;
      FindProp := S_OK;
      break;
    end;
  end;
end;

function TBaseAddIn.GetPropName(lPropNum, lPropAlias: integer;
  var pbstrPropName: WideString): HResult; stdcall;
begin
  pbstrPropName := '';
  GetPropName := S_FALSE;
  if lPropNum < Length(v7PropsArray) then
  begin
    if lPropAlias = 0 then
      pbstrPropName := v7PropsArray[lPropNum].strEng
    else
      pbstrPropName := v7PropsArray[lPropNum].strRus;
    GetPropName := S_OK;
  end;
end;

function TBaseAddIn.GetPropVal(lPropNum: integer; var pvarPropVal: OleVariant)
  : HResult; stdcall;
begin
  VarClear(pvarPropVal);
  GetPropVal := S_FALSE;
  if lPropNum < Length(v7PropsArray) then
  begin
    pvarPropVal := v7PropsArray[lPropNum].prop.GetValue(self).AsVariant;
    GetPropVal := S_OK;
  end;
end;

function TBaseAddIn.SetPropVal(lPropNum: integer; var varPropVal: OleVariant)
  : HResult; stdcall;
begin
  SetPropVal := S_FALSE;
  if lPropNum < Length(v7PropsArray) then
  begin
    v7PropsArray[lPropNum].prop.SetValue(self,
      TValue.From<OleVariant>(varPropVal));
    SetPropVal := S_OK;
  end;
end;

procedure TBaseAddIn.ShowErrorLog(MsgText: String);
var
  ErrInfo: PExcepInfo;
begin
  if Trim(MsgText) = '' then Exit;
  New(ErrInfo);
  ErrInfo^.bstrSource := self.ExtensionName;
  ErrInfo^.bstrDescription := MsgText;
  ErrInfo^.wCode := 1006;
  ErrInfo^.scode := E_FAIL;
  pErrorLog.AddError(nil, ErrInfo^);
end;

function TBaseAddIn.IsPropReadable(lPropNum: integer;
  var pboolPropRead: integer): HResult; stdcall;
begin
  IsPropReadable := S_OK;
end;

function TBaseAddIn.IsPropWritable(lPropNum: integer;
  var pboolPropWrite: integer): HResult; stdcall;
begin
  IsPropWritable := S_FALSE;
  if lPropNum < Length(v7PropsArray) then
  begin
    if v7PropsArray[lPropNum].readOnly then
      pboolPropWrite := 0
    else
      pboolPropWrite := 1;
    IsPropWritable := S_OK;

  end;
end;

function TBaseAddIn.GetNMethods(var plMethods: integer): HResult; stdcall;
begin
  plMethods := Length(v7MethodsArray) - 1;
  GetNMethods := S_OK;
end;

function TBaseAddIn.FindMethod(const bstrMethodName: WideString;
  var plMethodNum: integer): HResult; stdcall;
var
  v7Atr: v7Method;
  i: integer;
begin
  FindMethod := S_FALSE;
  plMethodNum := -1;
  for i := 0 to Length(v7MethodsArray) - 1 do
  begin
    v7Atr := v7MethodsArray[i];
    if v7Atr.hasName(bstrMethodName) then
    begin
      plMethodNum := i;
      FindMethod := S_OK;
      break;
    end;
  end;
end;

function TBaseAddIn.GetMethodName(lMethodNum, lMethodAlias: integer;
  var pbstrMethodName: WideString): HResult; stdcall;
begin
  GetMethodName := S_FALSE;
  pbstrMethodName := '';
  if lMethodNum < Length(v7MethodsArray) then
  begin
    if lMethodAlias = 0 then
      pbstrMethodName := v7MethodsArray[lMethodNum].strEng
    else
      pbstrMethodName := v7MethodsArray[lMethodNum].strRus;
    GetMethodName := S_OK;
  end;
end;

function TBaseAddIn.GetNParams(lMethodNum: integer; var plParams: integer)
  : HResult; stdcall;
begin
  GetNParams := S_FALSE;
  plParams := 0;
  if lMethodNum < Length(v7MethodsArray) then
  begin
    plParams := v7MethodsArray[lMethodNum].paramsCount;
    GetNParams := S_OK;
  end;
end;

function TBaseAddIn.GetParamDefValue(lMethodNum, lParamNum: integer;
  var pvarParamDefValue: OleVariant): HResult; stdcall;
begin
  { Ther is no default value for any parameter }
  VarClear(pvarParamDefValue);
  GetParamDefValue := S_OK;
end;

function TBaseAddIn.HasRetVal(lMethodNum: integer; var pboolRetValue: integer)
  : HResult; stdcall;
begin
  pboolRetValue := 0;
  if lMethodNum < Length(v7MethodsArray) then
  begin
    pboolRetValue := v7MethodsArray[lMethodNum].retValue;
  end;
  HasRetVal := S_OK;
end;

function TBaseAddIn.CallAsProc(lMethodNum: integer;
  var paParams: PSafeArray { (OleVariant) } ): HResult; stdcall;
var
  v7Atr: v7Method;
  args: Array of TValue;
  i: integer;
begin
  CallAsProc := S_FALSE;
  if lMethodNum < Length(v7MethodsArray) then
  begin
    v7Atr := v7MethodsArray[lMethodNum];
    SetLength(args, v7Atr.paramsCount);
    for i := 0 to v7Atr.paramsCount - 1 do
      args[i] := TValue.From<OleVariant>(GetNParam(paParams, i));
    v7Atr.method.Invoke(self, args);
    CallAsProc := S_OK;
  end;
end;

procedure TBaseAddIn.after_done;
begin
  //
end;

function TBaseAddIn.CallAsFunc(lMethodNum: integer;
  var pvarRetValue: OleVariant; var paParams: PSafeArray { (OleVariant) } )
  : HResult; stdcall;
var
  v7Atr: v7Method;
  args: Array of TValue;
  i: integer;
  obj: OleVariant;
begin
  CallAsFunc := S_FALSE;
  if lMethodNum < Length(v7MethodsArray) then
  begin
    v7Atr := v7MethodsArray[lMethodNum];
    SetLength(args, v7Atr.paramsCount);
    for i := 0 to v7Atr.paramsCount - 1 do
    begin
      obj := GetNParam(paParams, i);
      args[i] := TValue.From<OleVariant>(obj);
    end;
    pvarRetValue := v7Atr.method.Invoke(self, args).AsVariant;
    CallAsFunc := S_OK;
  end;

end;

{ v7MethodAtribute }

constructor v7Method.Create(strEngRus_: string);
begin
  inherited Create;
  strEngRus := strEngRus_;
  paramsCount := 0;
  retValue := 0;
  parseEngRus;
end;

{ v7PropAtribute }

constructor v7Property.Create(strEngRus_: string);
begin
  strEngRus := strEngRus_;
  readOnly := false;
  parseEngRus;
end;

{ v7Atribute }

function v7Atribute.hasName(strName: WideString): boolean;
begin
  result := False;
  if (UpperCase(strName) = UpperCase(strEng)) or
    (UpperCase(strName) = UpperCase(strRus)) then
    result := True;
end;

procedure v7Atribute.parseEngRus;
var
  p: integer;
begin
  p := Pos(',', strEngRus);
  if p > 0 then
  begin
    strEng := Copy(strEngRus, 0, p - 1);
    strRus := Copy(strEngRus, p + 1, Length(strEngRus));
  end;
end;
{$ENDREGION}
{ TBaseAddIn }


initialization

end.
