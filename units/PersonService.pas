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

    ///  <summary>
    ///    Return directory dataset.
    ///  </summary>
    ///  <remarks>
    ///    All person records are returned, along with their contact information.
    ///  </remarks>
    ///  <param name="format">
    ///     Valid dataset formats for this request include the following.
    ///    - CSV - Comma Separated Values Format, includes header row
    ///    - PLAIN - No delimiters or header row
    ///    - FIREDAC: FireDAC JSON Format
    ///    - BINARY: FireDAC Binary Format
    ///    - XML: FireDAC XML Format
    ///    - JSON: Simple JSON Format
    ///  </param>
    [Authorize] [HttpGet] function Directory(Format: String): TStream;

    ///  <summary>
    ///    Return user profile information.
    ///  </summary>
    ///  <remarks>
    ///    The profile information is returned as JSONbased on the person that is
    ///    logged in - the JWT is used to determine the person_id.
    ///  </remarks>
    [Authorize] [HttpGet] function Profile: TStream;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IPersonService));

end.
