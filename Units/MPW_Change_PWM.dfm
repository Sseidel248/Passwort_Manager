object MasterPasswortChange: TMasterPasswortChange
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #196'nderung des Masterpasswortes'
  ClientHeight = 221
  ClientWidth = 394
  Color = clBtnFace
  Constraints.MaxHeight = 250
  Constraints.MaxWidth = 400
  Constraints.MinHeight = 250
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GradientPanelMPWChange: TGradientPanel
    Left = 0
    Top = 0
    Width = 394
    Height = 221
    Align = alClient
    Caption = 'GradientPanelMPWChange'
    Color = clSkyBlue
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ColorGradient = cgHorizontal
    RGB_Gradient = rgbLinear
    ColorTo = clMoneyGreen
    object LStep1: TLabel
      Left = 16
      Top = 46
      Width = 353
      Height = 19
      AutoSize = False
      Caption = 'Ihre Masterpasswort stimmt nicht!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object LStep2: TLabel
      Left = 16
      Top = 131
      Width = 353
      Height = 20
      AutoSize = False
      Caption = 'Ihre Eingabe stimmt nicht '#252'berein!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object BChangeMasterPW: TButton
      Left = 16
      Top = 157
      Width = 353
      Height = 33
      Caption = 'Masterpasswort '#228'ndern'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
      OnClick = BChangeMasterPWClick
    end
    object EOldMPW: TEditEx
      Left = 16
      Top = 19
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      TextHint = '<Aktuelles Masterpasswort>'
      OnChange = EOldMPWChange
      OnKeyPress = EOldMPWKeyPress
      Bordercolor = clNone
      FocusBorderColor = clNone
      TextHintOnFocus = True
    end
    object ENewMPW: TEditEx
      Left = 16
      Top = 71
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      TextHint = '<Neues Masterpasswort>'
      OnChange = ENewMPWChange
      OnKeyPress = EOldMPWKeyPress
      Bordercolor = clNone
      FocusBorderColor = clNone
      TextHintOnFocus = True
    end
    object ENewMPW2: TEditEx
      Left = 16
      Top = 101
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      TextHint = '<Neues Masterpasswort wiederholen>'
      OnChange = ENewMPW2Change
      Bordercolor = clNone
      FocusBorderColor = clNone
      TextHintOnFocus = True
    end
  end
end
