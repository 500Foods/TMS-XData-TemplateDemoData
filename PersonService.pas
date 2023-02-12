unit PersonService;

interface

uses
  System.Classes,
  XData.Security.Attributes,
  XData.Service.Common;

type
  [ServiceContract]
  IPersonService = interface(IInvokable)
    ['{B3F998DC-587F-442D-8101-97819329D6C9}']

    [Authorize] [HttpGet] function Directory(Format: String): TStream;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IPersonService));

end.
