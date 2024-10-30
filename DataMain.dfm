object DataModule1: TDataModule1
  OldCreateOrder = False
  Left = 471
  Top = 341
  Height = 376
  Width = 373
  object DBISAMSession1: TDBISAMSession
    EngineVersion = '3.30'
    LockRetryCount = 15
    LockWaitTime = 100
    LockProtocol = lpPessimistic
    ProgressSteps = 20
    SessionType = stLocal
    RemoteType = rtLAN
    RemoteAddress = '127.0.0.1'
    RemotePort = 12005
    RemoteTrace = False
    Left = 80
    Top = 72
  end
  object DBISAMQuery1: TDBISAMQuery
    AutoDisplayLabels = False
    CopyOnAppend = False
    EngineVersion = '3.30'
    MaxRowCount = -1
    Params = <>
    Left = 80
    Top = 128
  end
end
