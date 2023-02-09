unit SystemService;

interface

uses
  System.Classes,
  XData.Service.Common;

type
  [ServiceContract]
  ISystemService = interface(IInvokable)
    ['{F9CC965F-B6F1-4D38-A50A-E271705E9FCB}']

    ///  <summary>
    ///    XData Application Information
    ///  </summary>
    ///  <remarks>
    ///    Returns JSON that includes information about the currently running application.
    ///  </remarks>
    ///  <param name="TZ">
    ///    The TimeZone of the connecting client.  This is used in determining what
    ///    adjustments to make when displaying dates and times on reports, or where
    ///    similar data needs to be converted to a local context.  This uses IANA
    ///    TimeZone names.  If an invalid TimeZone is provided, the JSON object for
    ///    Current Time (Client) will indicate as much.  Here are some examples.
    ///    - Pacific Standard Time
    ///    - America/New_York
    ///    - Europe/Paris
    ///    - EET
    ///    - UTC
    ///    - GMT
    ///    - EST
    ///    - PST8PDT
    ///  </param>
    [HttpGet] function Info(TZ: String):TStream;

    ///  <summary>
    ///    Login to XData Server
    ///  </summary>
    ///  <remarks>
    ///    If authentication is successful, a JWT will be returned with the appropriate
    ///    authorization information.
    ///  </remarks>
    ///  <param name="Login_ID">
    ///    Login_ID can be either the account_name, first_name+last_name, or any of the
    ///    contact entries that have been marked as login_ok, which would typically be
    ///    just the email address but could also include phone numbers or other values.
    ///  </param>
    ///  <param name="Password">
    ///    Password corresponding to the username.
    ///  </param>
    ///  <param name="API_Key">
    ///    An application-level API key that has been provided for your use.
    ///  </param>
    ///  <param name="TZ">
    ///    The TimeZone of the connecting client.  This is used in determining what
    ///    adjustments to make when displaying dates and times on reports, or where
    ///    similar data needs to be converted to a local context.  This uses IANA
    ///    TimeZone names.  If an invalid TimeZone is provided, the JSON object for
    ///    Current Time (Client) will indicate as much.  Here are some examples.
    ///    - Pacific Standard Time
    ///    - America/New_York
    ///    - Europe/Paris
    ///    - EET
    ///    - UTC
    ///    - GMT
    ///    - EST
    ///    - PST8PDT
    ///  </param>
    [HttpPost] function Login(Login_ID: String; Password: String; API_Key: String; TZ: String):String;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(ISystemService));

end.
