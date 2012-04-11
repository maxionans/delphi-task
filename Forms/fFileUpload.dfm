object frmFileUpload: TfrmFileUpload
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Uploading files...'
  ClientHeight = 228
  ClientWidth = 457
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 32
    Top = 32
    Width = 393
    Height = 13
    Margins.Left = 32
    Margins.Top = 32
    Margins.Right = 32
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Uploading files. Please wait...'
    ExplicitWidth = 142
  end
  object lblFilesProcessed: TLabel
    AlignWithMargins = True
    Left = 32
    Top = 77
    Width = 393
    Height = 13
    Margins.Left = 32
    Margins.Top = 32
    Margins.Right = 32
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Uploading %d out of %d total files '
    ExplicitWidth = 169
  end
  object lblTimeElapsed: TLabel
    AlignWithMargins = True
    Left = 32
    Top = 98
    Width = 393
    Height = 13
    Margins.Left = 32
    Margins.Top = 8
    Margins.Right = 32
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Elapsed time: %s'
    ExplicitWidth = 83
  end
  object lblSpeed: TLabel
    AlignWithMargins = True
    Left = 32
    Top = 119
    Width = 393
    Height = 13
    Margins.Left = 32
    Margins.Top = 8
    Margins.Right = 32
    Margins.Bottom = 0
    Align = alTop
    Caption = 'Speed: %f KB/sec'
    ExplicitWidth = 87
  end
  object ProgressBar1: TProgressBar
    AlignWithMargins = True
    Left = 32
    Top = 140
    Width = 393
    Height = 17
    Margins.Left = 32
    Margins.Top = 8
    Margins.Right = 32
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 0
  end
  object btnStop: TButton
    Left = 350
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = btnStopClick
  end
  object tmUpdate: TTimer
    Enabled = False
    OnTimer = tmUpdateTimer
    Left = 80
    Top = 152
  end
end
