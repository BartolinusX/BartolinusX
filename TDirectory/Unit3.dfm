object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object TreeView1: TTreeView
    Left = 0
    Top = 8
    Width = 313
    Height = 434
    CheckBoxes = True
    Indent = 19
    PopupMenu = PopupMenu1
    TabOrder = 0
    OnChanging = TreeView1Changing
    OnDeletion = TreeView1Deletion
  end
  object Button1: TButton
    Left = 528
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 319
    Top = 112
    Width = 306
    Height = 330
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
    WordWrap = False
  end
  object PopupMenu1: TPopupMenu
    Left = 392
    Top = 40
    object SaveasUTF8BOM1: TMenuItem
      Caption = 'Save as UTF8-BOM'
      OnClick = SaveasUTF8BOM1Click
    end
    object OznczawszystkiebezBOM1: TMenuItem
      Caption = 'Oznacz wszystkie bez BOM'
      OnClick = OznczawszystkiebezBOM1Click
    end
  end
end
