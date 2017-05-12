object FormForTesting: TFormForTesting
  Left = 0
  Top = 0
  Width = 398
  Height = 375
  Caption = 'FormForTesting'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = ActiveFormCreate
  OnDestroy = ActiveFormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 314
    Width = 398
    Height = 9
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitTop = 262
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 398
    Height = 17
    Align = alTop
    TabOrder = 0
    object Button2: TButton
      Left = 298
      Top = 3
      Width = 98
      Height = 15
      Caption = #1058#1077#1089#1090#1050#1086#1085#1090#1077#1082#1089#1090#1072'2'
      Enabled = False
      TabOrder = 0
      Visible = False
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 160
      Top = 3
      Width = 132
      Height = 15
      Caption = #1055#1088#1080#1084#1077#1088' '#1079#1072#1082#1088#1099#1090#1080#1103' '#1092#1086#1088#1084#1099
      Enabled = False
      TabOrder = 1
      Visible = False
      OnClick = Button1Click
    end
  end
  object mConsole: TMemo
    Left = 0
    Top = 323
    Width = 398
    Height = 52
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object TabControl1: TTabControl
    Left = 0
    Top = 17
    Width = 398
    Height = 297
    Align = alClient
    MultiLine = True
    TabOrder = 2
    TabPosition = tpLeft
    Tabs.Strings = (
      #1052#1086#1076#1091#1083#1100
      #1042#1099#1088#1072#1078#1077#1085#1080#1077)
    TabIndex = 0
    OnChange = TabControl1Change
    ExplicitTop = 20
    ExplicitHeight = 244
    object mModule: TRichEdit
      Left = 24
      Top = 37
      Width = 370
      Height = 224
      Align = alClient
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'import v7'
        ''
        '')
      ParentFont = False
      PlainText = True
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      WordWrap = False
      OnKeyDown = mEvalKeyDown
      ExplicitHeight = 75
    end
    object Panel2: TPanel
      Left = 24
      Top = 4
      Width = 370
      Height = 33
      Align = alTop
      Caption = 'Panel2'
      TabOrder = 1
      object btRun: TButton
        Left = 9
        Top = 4
        Width = 105
        Height = 25
        Action = acRun
        TabOrder = 0
      end
      object btBackground: TButton
        Left = 120
        Top = 4
        Width = 145
        Height = 25
        Action = acRunThreaded
        TabOrder = 1
      end
    end
    object mEval: TRichEdit
      Left = 24
      Top = 37
      Width = 370
      Height = 224
      Align = alClient
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        '# eval code'
        '')
      ParentFont = False
      PlainText = True
      ScrollBars = ssBoth
      TabOrder = 2
      Visible = False
      WantTabs = True
      WordWrap = False
      OnKeyDown = mEvalKeyDown
      ExplicitHeight = 203
    end
    object Panel3: TPanel
      Left = 24
      Top = 261
      Width = 370
      Height = 32
      Align = alBottom
      TabOrder = 3
      ExplicitTop = 208
      object eFunName: TEdit
        Left = 16
        Top = 6
        Width = 177
        Height = 21
        TabOrder = 0
        Text = 'timer1'
      end
      object eParam: TEdit
        Left = 200
        Top = 6
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object Button3: TButton
        Left = 328
        Top = 6
        Width = 33
        Height = 25
        Action = acRunFunctionThreaded
        TabOrder = 2
      end
    end
  end
  object PythonGUIInputOutput1: TPythonGUIInputOutput
    UnicodeIO = True
    RawOutput = False
    Output = mConsole
    Left = 280
    Top = 64
  end
  object ActionList1: TActionList
    Left = 120
    Top = 96
    object acRun: TAction
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' Ctrl+R'
      ShortCut = 16466
      OnExecute = acRunExecute
    end
    object acRunThreaded: TAction
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1074' '#1092#1086#1085#1077' Ctrl+F'
      ShortCut = 16454
      OnExecute = acRunThreadedExecute
    end
    object acEval: TAction
      Caption = #1042#1099#1095#1080#1089#1083#1080#1090#1100' Ctrl+E'
      ShortCut = 16453
      OnExecute = acEvalExecute
    end
    object acEvalBackground: TAction
      Caption = #1042#1099#1095#1080#1089#1083#1080#1090#1100' '#1074' '#1092#1086#1085#1077
      OnExecute = acEvalBackgroundExecute
    end
    object acRunFunctionThreaded: TAction
      Caption = 'Run'
      OnExecute = acRunFunctionThreadedExecute
    end
  end
end
