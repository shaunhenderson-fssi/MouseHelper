object Form1: TForm1
  Left = 0
  Top = 0
  AlphaBlend = True
  BorderStyle = bsNone
  Caption = 'MouseHelper'
  ClientHeight = 100
  ClientWidth = 120
  Color = clFuchsia
  TransparentColor = True
  TransparentColorValue = clFuchsia
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clFuchsia
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 15
  object lblColor2: TLabel
    Left = 9
    Top = 25
    Width = 70
    Height = 21
    Caption = 'lblColor2'
    Color = clFuchsia
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object lblCoords2: TLabel
    Left = 9
    Top = 5
    Width = 82
    Height = 21
    Caption = 'lblCoords2'
    Color = clFuchsia
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object lblCoords: TLabel
    Left = 8
    Top = 4
    Width = 73
    Height = 21
    Caption = 'lblCoords'
    Color = clFuchsia
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object lblColor: TLabel
    Left = 8
    Top = 24
    Width = 61
    Height = 21
    Caption = 'lblColor'
    Color = clFuchsia
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 72
    Top = 8
  end
end
