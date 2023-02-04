unit SystemServiceImplementation;

interface

uses
  XData.Server.Module,
  XData.Service.Common,
  SystemService;

type
  [ServiceImplementation]
  TSystemService = class(TInterfacedObject, ISystemService)
  private
    function Sum(A, B: double): double;
    function EchoString(Value: string): string;
  end;

implementation

function TSystemService.Sum(A, B: double): double;
begin
  Result := A + B;
end;

function TSystemService.EchoString(Value: string): string;
begin
  Result := Value;
end;

initialization
  RegisterServiceType(TSystemService);

end.
