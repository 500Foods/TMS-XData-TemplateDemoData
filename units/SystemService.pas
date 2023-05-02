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
    ///    If login is successful, a JWT will be returned.
    ///  </remarks>
    ///  <param name="Login_ID">
    ///    Login_ID can be any of the contact entries that have been marked as login_ok,
    ///    which would typically be just the email address but could also include phone
    ///    numbers or other values.
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
    [HttpGet] function Login(Login_ID: String; Password: String; API_Key: String; TZ: String):TStream;

    ///  <summary>
    ///    Logout - revoke the JWT.
    ///  </summary>
    ///  <remarks>
    ///    The JWT issued by the Login endpoint is good for a set period of time.  This will revoke
    ///    the JWT, making it invalid immediately rather than when it expires after a period of time.
    ///  </remarks>
    ///  <param name="ActionSession">
    ///    Session identifier unique to the user - just an encoded Unix timestamp.
    ///  </param>
    ///  <param name="ActionLog">
    ///    Client action log. Just a text log.
    ///  </param>
    [HttpPost] function Logout(ActionSession: String; ActionLog: String):TStream;

    ///  <summary>
    ///    Renew a previously issued JWT.
    ///  </summary>
    ///  <remarks>
    ///    The JWT issued by the Login endpoint is good for a set period of time.
    ///    This endpoint will re-issue a new JWT with the same claims for another period of time.
    ///  </remarks>
    ///  <param name="ActionSession">
    ///    Session identifier unique to the user - just an encoded Unix timestamp.
    ///  </param>
    ///  <param name="ActionLog">
    ///    Client action log. Just a text log.
    ///  </param>
    [HttpPost] function Renew(ActionSession: String; ActionLog: String):TStream;

    ///  <summary>
    ///    List of Icon Sets that are available for search and retrieval
    ///  </summary>
    ///  <remarks>
    ///    Returns a JSON array that includes the following.
    ///    - Name of Icon Set
    ///    - License Information
    ///    - Count of Icons included in Set
    ///    - Default Icon Width for Set
    ///    - Default Icon Height for Set
    ///
    ///    The order of the array should be used to identify which sets are to be included or excluded when a search is requested.
    ///  </remarks>
    [HttpGet] function AvailableIconSets:TStream;

    ///  <summary>
    ///    Performs a search for icons, returing whatever icons were found as a JSON array.
    ///  </summary>
    ///  <remarks>
    ///    The returned array is a JSON list of icons, including the SVG parts needed to build the icon.
    ///  </remarks>
    ///  <param name="SearchTerms">
    ///    Up to three terms will be used in conducting the search.  Any more that are passed in will be ignored.
    ///  </param>
    ///  <param name="SearchSets">
    ///    A comma-separated list of Icon Sets to search, where the number indicates the position in the array from AvailableIconSets.  A value of 'all' is also accepted, as this is likely the default search choice much of the time.
    ///  </param>
    ///  <param name="Results">
    ///    Indicates how many icons are to be returned.  If conducting searches while someone is typing, this should be a much smaller number than if a more deliberate search is being performed.
    ///  </param>
    [HttpGet] function SearchIconSets(SearchTerms: String; SearchSets:String; Results:Integer):TStream;

    [HttpGet] function SearchFontAwesome(Query: String):TStream;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(ISystemService));

end.
