object ServerContainer: TServerContainer
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 210
  Width = 431
  object SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher
    Active = True
    Left = 72
    Top = 16
  end
  object XDataServer: TXDataServer
    BaseUrl = 'http://+:12345/tms/xdata'
    Dispatcher = SparkleHttpSysDispatcher
    Pool = XDataConnectionPool
    EntitySetPermissions = <>
    SwaggerOptions.Enabled = True
    SwaggerOptions.AuthMode = Jwt
    SwaggerUIOptions.Enabled = True
    SwaggerUIOptions.ShowFilter = True
    SwaggerUIOptions.TryItOutEnabled = True
    Left = 216
    Top = 16
    object XDataServerJWT: TSparkleJwtMiddleware
      Secret = 
        'ThisIsAReallyLongSecretThatReallyDoesNeedToBeLongAsItIsUsedAsACr' +
        'iticalPartOfOurXDataSecurityModel'
    end
    object XDataServerCompress: TSparkleCompressMiddleware
    end
    object XDataServerCORS: TSparkleCorsMiddleware
      Origin = '*'
    end
  end
  object XDataConnectionPool: TXDataConnectionPool
    Connection = AureliusConnection
    Left = 216
    Top = 72
  end
  object AureliusConnection: TAureliusConnection
    Left = 216
    Top = 128
  end
  object DBConn: TFDConnection
    Left = 344
    Top = 16
  end
  object Query1: TFDQuery
    Connection = DBConn
    Left = 344
    Top = 128
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 344
    Top = 72
  end
end
