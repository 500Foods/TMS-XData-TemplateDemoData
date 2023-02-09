object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'XData Template Demo Data'
  ClientHeight = 242
  ClientWidth = 743
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    743
    242)
  PixelsPerInch = 96
  TextHeight = 13
  object mmInfo: TMemo
    Left = 8
    Top = 40
    Width = 727
    Height = 194
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 0
  end
  object btStart: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = btStartClick
  end
  object btStop: TButton
    Left = 90
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 2
    OnClick = btStopClick
  end
  object btSwagger: TButton
    Left = 171
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Swagger'
    TabOrder = 3
    OnClick = btSwaggerClick
  end
end
