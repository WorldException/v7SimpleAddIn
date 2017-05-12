unit PropPage;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses SysUtils, Windows, Messages, Classes, Graphics, Controls, StdCtrls,
  ExtCtrls, Forms, ComServ, ComObj, StdVcl, AxCtrls;

type
  TPropertyPage1 = class(TPropertyPage)
    Label1: TLabel;
    Memo1: TMemo;
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure UpdatePropertyPage; override;
    procedure UpdateObject; override;
  end;

const
  Class_AddInPropPage: TGUID = '{A18163D3-C402-4928-825A-96BA0CF743B6}';

implementation

{$R *.DFM}

procedure TPropertyPage1.UpdatePropertyPage;
begin
  { Update your controls from OleObject }
end;

procedure TPropertyPage1.UpdateObject;
begin
  { Update OleObject from your controls }
end;

initialization
  TActiveXPropertyPageFactory.Create(
    ComServer,
    TPropertyPage1,
    Class_AddInPropPage);
end.
