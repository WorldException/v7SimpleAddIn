====== ������ ��������� � 1� ======

������� ���������� ��� 1� 7.7/8.� �� ���������� ���. 
��������� ��������� ������� � ��������� ������ ��� ����������� ���� � ��������
� ��� ����� stdout, stdin. ������ �������� ���������� �������� "������������������������"
��� ��������� ����������� ��������� ������������, � ��� �� ���������� ���������� �� ������� ������ ���������.

==== ����������� ====

	* ����� ��������� ����� ���������� ��������� ��� ������ (python, php, perl, cmd, vbs, js)
	* ������� ����������� � ��������� ������ � �� ������ ���������� ��������� �������� 1�.
	* ��� ���������� 1�, ������� ���������.
	* ����� ��������� ��������� ��������� ������ ��������� ��������
	* ������ � ��������� ���������� � 1� � �������� ������� "������������������������"
	* ����� �������� ���� ������ � ������� ����� ��������("����� �� ������")
	* ������ �� ������� �������� �� �������� � ������� 1�, ��� ��� ������ ��� ������������� ������� ���������.

==== ������ ====
<code basic>

��������� ����������������2()
	� = �������������("AddIn.Process");
	�.��������������� = "test";
	�.��������������� = "msg";
	�.�������������� = "";
	�.���������("c:\python27\python.exe -u "+���������()+"test.py");
��������������

��������� ������������������������(�,�,�)
    ��������("���������:"+�+" "+�+" "+�);
��������������

��������������������������(���������()+"AddIn.dll");

</code>

<code python>
#coding: utf-8
from __future__ import unicode_literals

print("start")
print("������".encode('cp1251'))

while True:
    line = sys.stdin.readline()
    print(line)
</code>
	
==== ���������� =====

���������� �������� ��� ������� python ��������, �� �������������� ����� ����� ���������� ���������.

�� ������ ������ � ��������� ��� ������ �������� ���������� ����� ������ redis.
����� ������ �������� �������� ���������� ������ rs232 �������� � ��������� �������� ���������� 
���� ��� ������������� ������� �����. ������� ��� �������� �� �������� � ���� ������.

������ ���������� ��� ������ python + http://www.seleniumhq.org/ + firefox ��������� ������� ������� ��������� 
��� ���������� ������ ���������� ����� ��� ��� ���������. ��� ������� ��������� ������� � ����������� ���������� ��� �� ��� 
����������� ������ ���������. � ��������� 1� ����������� ������, � � ��������� �������� ������� ��������� ������� ���������� �������� 
������ � ������� ������.


==== v7AddIn =====
��������� ���������� �� Delphi XE5.

��� ���������� ����� Delphi �� ���� XE2, �.�. ������ ���������� ���������
���� ��� ������������� ��������� �������� ������� ��������� ������������ RTTI.
��������� ����� ��� ����������. ������ ������������ ��� ������ ��� �������� ����� ���������.

<code pascal>
TAddInProcess = class(TBaseAddIn)
  private
    fEventAction: string;
    fEventPrefix: string;
    fEventSource: string;
    fShowWindow: string;
  public
    // ����������� ������� �������
    command: TDosCommand;

    [v7Method('Start,���������')]
    function RunPipe(exepath: OleVariant): OleVariant;

    [v7Method('Stop,���������')]
    function StopPipe(): OleVariant;

    [v7Method('Write,��������')]
    function WritePipe(msg: OleVariant): OleVariant;

    procedure OnCommanNewLine(Sender: TObject; NewLine: string; OutputType: TOutputType);

    [v7Property('ShowWindow,��������������')]
    property ShowWindow: string read fShowWindow write fShowWindow;

    [v7Property('EventSource,���������������')]
    property EventSource: string read fEventSource write fEventSource;

    [v7Property('EventAction,���������������')]
    property EventAction:string read fEventAction write fEventAction;

    [v7Property('EventPrefix,��������������')]
    property EventPrefix:string read fEventPrefix write fEventPrefix;
</code>
