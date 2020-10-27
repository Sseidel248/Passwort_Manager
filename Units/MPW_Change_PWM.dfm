object MasterPasswortChange: TMasterPasswortChange
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #196'nderung des Masterpasswortes'
  ClientHeight = 261
  ClientWidth = 384
  Color = clBtnFace
  Constraints.MaxHeight = 300
  Constraints.MaxWidth = 400
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GradientPanelMPWChange: TGradientPanel
    Left = 0
    Top = 0
    Width = 384
    Height = 261
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
      Top = 173
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
      Top = 208
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
      TabOrder = 3
      OnClick = BChangeMasterPWClick
    end
    object EOldMPW: TEditWithBorder
      Left = 16
      Top = 16
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TextHint = 'Altes Masterpasswort eingeben...'
      OnChange = EOldMPWChange
      OnKeyPress = EOldMPWKeyPress
      Required = False
      ForEmptyText = True
      TextBorderColor = clRed
    end
    object ENewMPW: TEditWithBorder
      Left = 16
      Top = 80
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      TextHint = 'Neues Masterpasswort eingeben...'
      OnChange = ENewMPWChange
      OnKeyPress = ENewMPWKeyPress
      Required = False
      ForEmptyText = True
      TextBorderColor = clRed
    end
    object ENewMPW2: TEditWithBorder
      Left = 16
      Top = 143
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      TextHint = 'Neues Masterpasswort erneut eingeben...'
      OnChange = ENewMPW2Change
      Required = False
      ForEmptyText = True
      TextBorderColor = clRed
    end
  end
end
