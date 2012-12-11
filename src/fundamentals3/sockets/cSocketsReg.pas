unit cSocketsReg;

interface

procedure Register;

implementation

uses
  { Delphi }
  Classes,

  { Fundamentals }
  cSocketHostLookup,
  cSocketsUDP,
  cTCPClient,
  cTCPServer;

procedure Register;
begin
  RegisterComponents('fnd Sockets', [
      TfndSocketHostLookup,
      TfndUDPSocket, TfndUDPClientSocket,
      TfndTCPClient, TfndTCPClientCollection, TfndSocks5Proxy, TfndHTTPTunnelProxy,
      TfndTCPServer]);
end;



end.
