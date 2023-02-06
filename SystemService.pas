unit SystemService;

interface

uses
  System.Classes,
  XData.Service.Common;

type
  [ServiceContract]
  ISystemService = interface(IInvokable)
    ['{F9CC965F-B6F1-4D38-A50A-E271705E9FCB}']

    [HttpGet] function Info(TZ: String):TStream;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(ISystemService));

end.
