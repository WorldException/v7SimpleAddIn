====== Запуск процессов в 1С ======

Внешняя компонента для 1С 7.7/8.х по технологии СОМ. 
Позволяет запустить процесс в отдельном потоке без отображения окна и общаться
с ним через stdout, stdin. Данные внешнего приложения вызывают "ОбработкаВнешнегоСобытия"
что позволяет эмулировать различное оборудование, а так же асинхронно регировать на события внешей программы.

==== Возможности ====

	* Можно запускать любую консольную программу или скрипт (python, php, perl, cmd, vbs, js)
	* Процесс запускается в отдельном потоке и не мешает выполнению основного процесса 1С.
	* При завершении 1С, процесс убивается.
	* Можно запустить несколько процессов создав несколько объектов
	* Строка с переносом передается в 1С в качестве события "ОбработкаВнешнегоСобытия"
	* Можно передать свои данные в процесс через Записать("какие то данные")
	* Ошибки во внешнем процессе не приводят к падению 1С, как это бывает при использовании внешних компонент.

==== Пример ====
<code basic>

Процедура ЗапуститьВнешний2()
	П = СоздатьОбъект("AddIn.Process");
	П.СобытиеИсточник = "test";
	П.СобытиеДействие = "msg";
	П.ПоказыватьОкно = "";
	П.Запустить("c:\python27\python.exe -u "+КаталогИБ()+"test.py");
КонецПроцедуры

Процедура ОбработкаВнешнегоСобытия(а,п,в)
    Сообщить("ОБРАБОТКА:"+а+" "+п+" "+в);
КонецПроцедуры

ЗагрузитьВнешнююКомпоненту(КаталогИБ()+"AddIn.dll");

</code>

<code python>
#coding: utf-8
from __future__ import unicode_literals

print("start")
print("Привет".encode('cp1251'))

while True:
    line = sys.stdin.readline()
    print(line)
</code>
	
==== Применение =====

Компонента писалась для запуска python скриптов, но использоваться может любая консольная программа.

На данный момент я использую для работы сканеров штрихкодов через сервер redis.
Такой подход позволил добиться стабильной работы rs232 сканеров с удаленным сервером терминалов 
даже при переодических потерях связи. Скрипты для сканеров не включены в этот проект.

Второе применение это связка python + http://www.seleniumhq.org/ + firefox позволила сделать простую обработку 
для размещения заказа поставщику через его веб интерфейс. При запуске открывает браузер и выполняется заполнение как бы это 
приходилось делать менеджеру. В обработке 1С запускается скрипт, а в обработке внешнего события ожидается команда готовности получать 
данные о строках заказа.


==== v7AddIn =====
Исходники компоненты на Delphi XE5.

Для компиляции нужен Delphi не ниже XE2, т.к. шаблон компоненты переделан
мной для значительного упрощения создания внешних компонент используется RTTI.
Благодаря этому код упростился. Можете использовать как основу для создания своих компонент.

<code pascal>
TAddInProcess = class(TBaseAddIn)
  private
    fEventAction: string;
    fEventPrefix: string;
    fEventSource: string;
    fShowWindow: string;
  public
    // Запускатель внешних комманд
    command: TDosCommand;

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
</code>
