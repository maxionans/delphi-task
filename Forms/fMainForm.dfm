object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'FTP Uploader'
  ClientHeight = 462
  ClientWidth = 684
  Color = clWhite
  Constraints.MinHeight = 500
  Constraints.MinWidth = 700
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    684
    462)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 24
    Width = 47
    Height = 13
    Caption = 'FTP Host:'
  end
  object Label2: TLabel
    Left = 33
    Top = 51
    Width = 56
    Height = 13
    Caption = 'User Name:'
  end
  object Label3: TLabel
    Left = 257
    Top = 51
    Width = 50
    Height = 13
    Caption = 'Password:'
  end
  object edFtpServer: TEdit
    Left = 95
    Top = 21
    Width = 362
    Height = 21
    TabOrder = 0
    Text = 'frantic-13.com'
  end
  object edUserName: TEdit
    Left = 95
    Top = 48
    Width = 138
    Height = 21
    TabOrder = 1
    Text = 'delphitest@frantic-13.com'
  end
  object edPassword: TEdit
    Left = 319
    Top = 48
    Width = 138
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
    Text = '9rVT*o~MTpfO'
  end
  object lvFiles: TListView
    AlignWithMargins = True
    Left = 32
    Top = 84
    Width = 620
    Height = 278
    Margins.Left = 32
    Margins.Top = 84
    Margins.Right = 32
    Margins.Bottom = 100
    Align = alClient
    Columns = <
      item
        Caption = 'Name'
        Width = 200
      end
      item
        Alignment = taRightJustify
        Caption = 'Size'
        Width = 100
      end
      item
        Caption = 'Path'
        Width = 300
      end>
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
  end
  object btnAdd: TButton
    Left = 33
    Top = 372
    Width = 116
    Height = 25
    Action = acAddFiles
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object btnRemove: TButton
    Left = 155
    Top = 372
    Width = 116
    Height = 25
    Action = acRemoveSelected
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object btnSendFiles: TButton
    Left = 33
    Top = 403
    Width = 117
    Height = 38
    Action = acSendFiles
    Anchors = [akLeft, akBottom]
    Caption = 'Upload'
    TabOrder = 6
  end
  object ActionList: TActionList
    Left = 336
    Top = 240
    object acAddFiles: TAction
      Caption = 'Add Files'
      OnExecute = acAddFilesExecute
    end
    object acRemoveSelected: TAction
      Caption = 'Remove Selected'
      OnExecute = acRemoveSelectedExecute
    end
    object acSendFiles: TAction
      Caption = 'Send Files'
      OnExecute = acSendFilesExecute
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'All Files|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofFileMustExist, ofEnableSizing]
    Left = 336
    Top = 296
  end
  object tmErrorHandler: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmErrorHandlerTimer
    Left = 400
    Top = 240
  end
  object XPManifest1: TXPManifest
    Left = 400
    Top = 296
  end
end
