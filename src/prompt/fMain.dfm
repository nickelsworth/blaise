object frmMain: TfrmMain
  Left = 272
  Top = 254
  Width = 532
  Height = 428
  Caption = 'Blaise Prompt'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inline frameBlaisePrompt: TframeBlaisePrompt
    Left = 0
    Top = 0
    Width = 524
    Height = 401
    Align = alClient
    TabOrder = 0
    inherited ePrompt: TRichEdit
      Width = 524
      Height = 401
    end
  end
end
