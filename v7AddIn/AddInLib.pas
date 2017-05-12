unit AddInLib;

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:      //
//   Type Libraries     : LIBID_xxxx                                    //
//   CoClasses          : CLASS_xxxx                                    //
//   DISPInterfaces     : DIID_xxxx                                     //
//   Non-DISP interfaces: IID_xxxx                                      //
// *********************************************************************//
const
  IID_IInitDone: TGUID = '{AB634001-F13D-11D0-A459-004095E1DAEA}';
  IID_IPropertyProfile: TGUID = '{AB634002-F13D-11D0-A459-004095E1DAEA}';
  IID_IErrorLog: TGUID = '{3127CA40-446E-11CE-8135-00AA004BB851}';
  IID_IAsyncEvent: TGUID = '{AB634004-F13D-11D0-A459-004095E1DAEA}';
  IID_ILanguageExtender: TGUID = '{AB634003-F13D-11D0-A459-004095E1DAEA}';
  IID_IStatusLine: TGUID = '{AB634005-F13D-11D0-A459-004095E1DAEA}';
  IID_IExtWndsSupport: TGUID = '{EFE19EA0-09E4-11D2-A601-008048DA00DE}';
type

// *********************************************************************//
// Forward declaration of interfaces defined in Type Library            //
// *********************************************************************//
  IInitDone = interface;
  IPropertyProfile = interface;
  IErrorLog = interface;
  IAsyncEvent = interface;
  ILanguageExtender = interface;
  IStatusLine = interface;
  IExtWndsSupport = interface;

  RECT = packed record
    left: Integer;
    top: Integer;
    right: Integer;
    bottom: Integer;
  end;

// *********************************************************************//
// Interface: IInitDone
// Flags:     (0)
// GUID:      {AB634001-F13D-11D0-A459-004095E1DAEA}
// *********************************************************************//
  IInitDone = interface(IUnknown)
    ['{AB634001-F13D-11D0-A459-004095E1DAEA}']
    function Init(const pConnection: IDispatch): HResult; stdcall;
    function Done: HResult; stdcall;
    function GetInfo(var pInfo: PSafeArray): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPropertyProfile
// Flags:     (0)
// GUID:      {AB634002-F13D-11D0-A459-004095E1DAEA}
// *********************************************************************//
  IPropertyProfile = interface(IPropertyBag)
    ['{AB634002-F13D-11D0-A459-004095E1DAEA}']
    function RegisterProfileAs(const bstrProfileName: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IErrorLog
// Flags:     (0)
// GUID:      {3127CA40-446E-11CE-8135-00AA004BB851}
// *********************************************************************//
  IErrorLog = interface(IUnknown)
    ['{3127CA40-446E-11CE-8135-00AA004BB851}']
    function AddError(pszPropName: PWideChar; var pExcepInfo: EXCEPINFO): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAsyncEvent
// Flags:     (0)
// GUID:      {AB634004-F13D-11D0-A459-004095E1DAEA}
// *********************************************************************//
  IAsyncEvent = interface(IUnknown)
    ['{AB634004-F13D-11D0-A459-004095E1DAEA}']
    function SetEventBufferDepth(lDepth: Integer): HResult; stdcall;
    function GetEventBufferDepth(var plDepth: Integer): HResult; stdcall;
    function ExternalEvent(const bstrSource: WideString; const bstrMessage: WideString;
                           const bstrData: WideString): HResult; stdcall;
    function CleanBuffer: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ILanguageExtender
// Flags:     (0)
// GUID:      {AB634003-F13D-11D0-A459-004095E1DAEA}
// *********************************************************************//
  ILanguageExtender = interface(IUnknown)
    ['{AB634003-F13D-11D0-A459-004095E1DAEA}']
    function RegisterExtensionAs(var bstrExtensionName: WideString): HResult; stdcall;
    function GetNProps(var plProps: Integer): HResult; stdcall;
    function FindProp(const bstrPropName: WideString; var plPropNum: Integer): HResult; stdcall;
    function GetPropName(lPropNum: Integer; lPropAlias: Integer; var pbstrPropName: WideString): HResult; stdcall;
    function GetPropVal(lPropNum: Integer; var pvarPropVal: OleVariant): HResult; stdcall;
    function SetPropVal(lPropNum: Integer; var varPropVal: OleVariant): HResult; stdcall;
    function IsPropReadable(lPropNum: Integer; var pboolPropRead: Integer): HResult; stdcall;
    function IsPropWritable(lPropNum: Integer; var pboolPropWrite: Integer): HResult; stdcall;
    function GetNMethods(var plMethods: Integer): HResult; stdcall;
    function FindMethod(const bstrMethodName: WideString; var plMethodNum: Integer): HResult; stdcall;
    function GetMethodName(lMethodNum: Integer; lMethodAlias: Integer;
                           var pbstrMethodName: WideString): HResult; stdcall;
    function GetNParams(lMethodNum: Integer; var plParams: Integer): HResult; stdcall;
    function GetParamDefValue(lMethodNum: Integer; lParamNum: Integer;
                              var pvarParamDefValue: OleVariant): HResult; stdcall;
    function HasRetVal(lMethodNum: Integer; var pboolRetValue: Integer): HResult; stdcall;
    function CallAsProc(lMethodNum: Integer; var paParams: PSafeArray): HResult; stdcall;
    function CallAsFunc(lMethodNum: Integer; var pvarRetValue: OleVariant; var paParams: PSafeArray): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IStatusLine
// Flags:     (0)
// GUID:      {AB634005-F13D-11D0-A459-004095E1DAEA}
// *********************************************************************//
  IStatusLine = interface(IUnknown)
    ['{AB634005-F13D-11D0-A459-004095E1DAEA}']
    function SetStatusLine(const bstrStatusLine: WideString): HResult; stdcall;
    function ResetStatusLine: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IExtWndsSupport
// Flags:     (0)
// GUID:      {EFE19EA0-09E4-11D2-A601-008048DA00DE}
// *********************************************************************//
  IExtWndsSupport = interface(IUnknown)
    ['{EFE19EA0-09E4-11D2-A601-008048DA00DE}']
    function GetAppMainFrame(var hwnd: HWND): HResult; stdcall;
    function GetAppMDIFrame(var hwnd: HWND): HResult; stdcall;
    function CreateAddInWindow(const bstrProgID: WideString; const bstrWindowName: WideString;
                             dwStyles: Integer; dwExStyles: Integer; var rctl: RECT;
                             Flags: Integer; var pHwnd: HWND; var pDisp: IDispatch): HResult; stdcall;
  end;

implementation

uses ComObj;

end.
