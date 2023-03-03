unit DashboardService;

interface

uses
  System.Classes,
  XData.Security.Attributes,
  XData.Service.Common;

type
  [ServiceContract]
  IDashboardService = interface(IInvokable)
    ['{925353F2-1ADD-4239-90F3-37BC41F48332}']

    ///  <summary>
    ///    Return JSON for setting up an Administrator dashboard.
    ///  </summary>
    ///  <remarks>
    ///    JWT is used to determine Administrator identity.
    ///  </remarks>
    [HttpGet] [Authorize] function AdministratorDashboard: TStream;
  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IDashboardService));

end.
