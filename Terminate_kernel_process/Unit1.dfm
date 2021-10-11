object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Terminate Process Kernel'
  ClientHeight = 174
  ClientWidth = 343
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 28
    Top = 37
    Width = 50
    Height = 13
    Caption = 'Process Id'
  end
  object Button1: TButton
    Left = 28
    Top = 104
    Width = 97
    Height = 25
    Caption = 'Terminate'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 28
    Top = 56
    Width = 97
    Height = 21
    TabOrder = 1
    Text = '0'
  end
end
