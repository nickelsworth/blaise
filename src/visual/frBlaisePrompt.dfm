object frameBlaisePrompt: TframeBlaisePrompt
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object ePrompt: TRichEdit
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PopupMenu = mPrompt
    TabOrder = 0
    OnKeyPress = ePromptKeyPress
  end
  object mPrompt: TPopupMenu
    OnPopup = mPromptPopup
    Left = 192
    Top = 56
    object mPromptCut: TMenuItem
      Caption = 'Cu&t'
      OnClick = mPromptCutClick
    end
    object mPromptCopy: TMenuItem
      Caption = '&Copy'
      OnClick = mPromptCopyClick
    end
    object mPromptPaste: TMenuItem
      Caption = '&Paste'
      OnClick = mPromptPasteClick
    end
    object mPromptDelete: TMenuItem
      Caption = '&Delete'
      OnClick = mPromptDeleteClick
    end
    object mPromptSelectAll: TMenuItem
      Caption = 'Select &All'
      ShortCut = 16449
      OnClick = mPromptSelectAllClick
    end
    object mPromptN1: TMenuItem
      Caption = '-'
    end
    object mPromptClear: TMenuItem
      Caption = 'C&lear'
      ShortCut = 16460
      OnClick = mPromptClearClick
    end
  end
end
