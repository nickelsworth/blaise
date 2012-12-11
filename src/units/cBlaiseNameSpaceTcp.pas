{                                                                              }
{                          Blaise TCP name space v0.03                         }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{               Its original file name is cBlaiseNameSpaceTcp.pas              }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise TCP name space.                                }
{                                                                              }
{ Revision history:                                                            }
{   17/03/2003  0.01  Initial version of TCP.                                  }
{   01/05/2003  0.02  TCP revision.                                            }
{   03/05/2003  0.03  Initial version of TCPD.                                 }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseNameSpaceTcp;

interface

uses
  { Fundamentals }
  cTCPServer,

  { Blaise }
  cBlaiseTypes,
  cBlaiseNameSpaceTypes;



{                                                                              }
{ TTcpNameSpace                                                                }
{   TCP client name space.                                                     }
{                                                                              }
type
  TTcpNameSpace = class(ANameSpaceCollection)
  protected
    procedure DecodeKey(const Key: String; var ID, Host, Port: String);
    function  FindItemByID(const ID: String): TObject;

  public
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
    function  Exists(const Key: String): Boolean; override;
    function  GetItem(const Key: String): TObject; override;
    procedure SetItem(const Key: String; const Value: TObject); override;
    procedure Delete(const Key: String); override;
    function  Directory(const Key: String): TObject; override;
  end;



{                                                                              }
{ TTcpdNameSpace                                                               }
{   TCP server name space.                                                     }
{                                                                              }
type
  TTcpdNameSpace = class(ANameSpaceCollection)
  public
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
  end;



implementation

uses
  { Delphi }
  Messages,
  Windows,
  SysUtils,

  { Fundamentals }
  cUtils,
  cStrings,
  cWindows,
  cReaders,
  cWriters,
  cStreams,
  cThreads,
  cSocketsTCPClient,
  cTCPStream,
  cTCPClient,

  { Blaise }
  cBlaiseFuncs,
  cBlaiseStructs, Classes;



{                                                                              }
{ TTcpClientItem                                                               }
{                                                                              }
type
  TTcpClientItem = class(ABlaiseStream)
  protected
    FHost   : String;
    FPort   : String;
    FLock   : TRTLCriticalSection;
    FClient : TfndTCPClient;

    procedure Lock;
    procedure Unlock;
    procedure OnInitSocket(Sender: ATCPClient);
    procedure OnSocketBeforeMessage(const Sender: TWindowHandle);
    procedure OnSocketAfterMessage(const Sender: TWindowHandle);
    procedure OnThreadRun(Sender: ATCPClient);
    procedure EnsureConnectedAndLock;

    function  GetSize: Int64; override;
    procedure SetSize(const Size: Int64); override;
    function  GetPosition: Int64; override;
    procedure SetPosition(const Position: Int64); override;
    function  GetReader: AReaderEx; override;
    function  GetWriter: AWriterEx; override;

  public
    constructor Create(const Host, Port: String);
    destructor Destroy; override;

    function  Read(var Buffer; const Size: Integer): Integer; override;
    function  Write(const Buffer; const Size: Integer): Integer; override;
    function  EOF: Boolean; override;
    procedure Truncate; override;
    function  IsOpen: Boolean; override;
    procedure Reopen; override;
  end;

constructor TTcpClientItem.Create(const Host, Port: String);
begin
  inherited Create;
  FHost := Host;
  FPort := Port;
  InitializeCriticalSection(FLock);
  FClient := TfndTCPClient.Create(nil);
  FClient.OnInitSocket := OnInitSocket;
  FClient.StreamMode := smBlockWaitMessage;
  FClient.RunInThread := True;
  FClient.OnThreadRun := OnThreadRun;
  FClient.TimeOut := 60000;
  FClient.Host := FHost;
  FClient.Port := FPort;
  FClient.Active := True;
end;

destructor TTcpClientItem.Destroy;
begin
  FreeAndNil(FClient);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TTcpClientItem.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TTcpClientItem.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

procedure TTcpClientItem.OnInitSocket(Sender: ATCPClient);
var Socket : TTCPClientSocket;
begin
  Socket := Sender.Socket;
  Assert(Assigned(Socket));
  Socket.OnBeforeMessage := OnSocketBeforeMessage;
  Socket.OnAfterMessage := OnSocketAfterMessage;
end;

procedure TTcpClientItem.OnSocketBeforeMessage(const Sender: TWindowHandle);
begin
  Lock;
end;

procedure TTcpClientItem.OnSocketAfterMessage(const Sender: TWindowHandle);
begin
  Unlock;
end;

procedure TTcpClientItem.OnThreadRun(Sender: ATCPClient);
begin
  Repeat
    if not Sender.Terminated and Assigned(Sender.Stream) then
      Sender.Stream.HandleMessage
    else
      break;
  Until False;
end;

procedure TTcpClientItem.EnsureConnectedAndLock;
begin
  Repeat
    Lock;
    if FClient.State = csConnecting then
      begin
        Unlock;
        ThreadWouldBlock;
      end else
      break;
  Until False;
  if not Assigned(FClient.Stream) or FClient.Stream.EOF then
    begin
      Unlock;
      raise ENameSpace.Create('TCP: Not connected');
    end;
end;

function TTcpClientItem.GetSize: Int64;
begin
  Result := -1;
end;

procedure TTcpClientItem.SetSize(const Size: Int64);
begin
  raise ENameSpace.Create('TCP: Can not set size');
end;

function TTcpClientItem.GetPosition: Int64;
begin
  EnsureConnectedAndLock;
  try
    Result := FClient.Stream.Position;
  finally
    Unlock;
  end;
end;

procedure TTcpClientItem.SetPosition(const Position: Int64);
begin
  EnsureConnectedAndLock;
  try
    FClient.Stream.Position := Position;
  finally
    Unlock;
  end;
end;

function TTcpClientItem.GetReader: AReaderEx;
begin
  EnsureConnectedAndLock;
  try
    Result := FClient.Stream.Reader;
  finally
    Unlock;
  end;
end;

function TTcpClientItem.GetWriter: AWriterEx;
begin
  EnsureConnectedAndLock;
  try
    Result := FClient.Stream.Writer;
  finally
    Unlock;
  end;
end;

function TTcpClientItem.EOF: Boolean;
begin
  Lock;
  try
    Result := not Assigned(FClient.Stream) or FClient.Stream.EOF;
  finally
    Unlock;
  end;
end;

function TTcpClientItem.Read(var Buffer; const Size: Integer): Integer;
var I : Integer;
begin
  if Size <= 0 then
    begin
      Result := 0;
      exit;
    end;
  EnsureConnectedAndLock;
  Repeat
    try
      I := FClient.Stream.Reader.AvailableToRead;
      if (I >= Size) or (FClient.State <> csConnected) then
        begin
          Result := FClient.Stream.Read(Buffer, Size);
          exit;
        end;
    finally
      Unlock;
    end;
    ThreadWouldBlock;
    Lock;
  Until False;
end;

function TTcpClientItem.Write(const Buffer; const Size: Integer): Integer;
begin
  EnsureConnectedAndLock;
  try
    Result := FClient.Stream.Write(Buffer, Size);
  finally
    Unlock;
  end;
end;

procedure TTcpClientItem.Truncate;
begin
  FClient.Active := False;
end;

function TTcpClientItem.IsOpen: Boolean;
begin
  Lock;
  try
    Result := Assigned(FClient.Stream) and
              (FClient.Stream.Connecting or FClient.Stream.Connected);
  finally
    Unlock;
  end;
end;

procedure TTcpClientItem.Reopen;
begin
  FClient.Active := False;
  Lock;
  try
    FClient.Host := FHost;
    FClient.Port := FPort;
    FClient.Active := True;
  finally
    Unlock;
  end;
end;



{                                                                              }
{ TTcpNameSpace                                                                }
{                                                                              }
function TTcpNameSpace.GetNameSpace(const RootNameSpace: TObject;
  const Name: String; var Position: Integer): TObject;
begin
  Result := self;
end;

procedure TTcpNameSpace.DecodeKey(const Key: String; var ID, Host, Port: String);
var S : StringArray;
    L : Integer;
begin
  ID := '';
  Host := '';
  Port := '';
  S := StrSplitChar(Key, ':');
  L := Length(S);
  if L = 1 then
    ID := S[0] else
  if L = 2 then
    begin
      Host := S[0];
      Port := S[1];
    end else
  if L >= 3 then
    begin
      ID := S[0];
      Host := S[1];
      Port := S[2];
    end;
end;

function TTcpNameSpace.FindItemByID(const ID: String): TObject;
begin
  Result := nil;
  if ID <> '' then
    FItems.FindItemByString(ID, Result);
end;

function TTcpNameSpace.GetItem(const Key: String): TObject;
var I, H, P : String;
begin
  DecodeKey(Key, I, H, P);
  if (I = '') and ((H = '') or (P = '')) then
    raise ENameSpace.Create('TCP: Invalid key');
  if I <> '' then
    begin
      Result := FindItemByID(I);
      if Assigned(Result) then
        exit;
    end;
  Result := TTcpClientItem.Create(H, P);
  Add(LongWordToHex(LongWord(Result), 8), Result);
end;

function TTcpNameSpace.Exists(const Key: String): Boolean;
var I, H, P : String;
begin
  DecodeKey(Key, I, H, P);
  if I = '' then
    raise ENameSpace.Create('TCP: Invalid key');
  Result := Assigned(FindItemByID(I));
end;

procedure TTcpNameSpace.SetItem(const Key: String; const Value: TObject);
begin
  raise ENameSpace.Create('Not implemented for TCP');
end;

procedure TTcpNameSpace.Delete(const Key: String);
var I, H, P : String;
begin
  DecodeKey(Key, I, H, P);
  if I = '' then
    raise ENameSpace.Create('TCP: Invalid key');
  FItems.DeleteByString(I);
end;

function TTcpNameSpace.Directory(const Key: String): TObject;
begin
  Result := FItems;
end;



{                                                                              }
{ TTcpdNameSpace                                                               }
{                                                                              }
type
  TTcpServerNameSpace = class;
  TTcpServerClientItem = class;

  { TTcpServerClientItemThread                                                 }
  TTcpServerClientItemThread = class(TThreadEx)
  protected
    FClient : TTcpServerClientItem;
    FHandle : THandle;

    procedure OnBeforeMessage(const Sender: TWindowHandle);
    procedure OnAfterMessage(const Sender: TWindowHandle);

  public
    constructor Create(const Client: TTcpServerClientItem);
    destructor Destroy; override;

    procedure Execute; override;
  end;

  { TTcpServerClientItem                                                       }
  TTcpServerClientItem = class(ABlaiseStream)
  protected
    FServerSpace : TTcpServerNameSpace;
    FClient      : TTCPServerClient;
    FLock        : TRTLCriticalSection;
    FThread      : TTcpServerClientItemThread;

    procedure Lock;
    procedure Unlock;

    function  GetSize: Int64; override;
    procedure SetSize(const Size: Int64); override;
    function  GetPosition: Int64; override;
    procedure SetPosition(const Position: Int64); override;
    function  GetReader: AReaderEx; override;
    function  GetWriter: AWriterEx; override;

  public
    constructor Create(const ServerSpace: TTcpServerNameSpace;
                const Client: TTCPServerClient);
    destructor Destroy; override;

    function  Read(var Buffer; const Size: Integer): Integer; override;
    function  Write(const Buffer; const Size: Integer): Integer; override;
    function  EOF: Boolean; override;
    procedure Truncate; override;
    function  IsOpen: Boolean; override;
    procedure Reopen; override;
  end;

  { TTcpServerThread                                                           }
  TTcpServerThread = class(TThreadEx)
  protected
    FServerSpace : TTcpServerNameSpace;
    FServer      : TfndTCPServer;
    FPort        : String;

    procedure OnBeforeMessage(const Sender: TWindowHandle);
    procedure OnAfterMessage(const Sender: TWindowHandle);

  public
    constructor Create(const ServerSpace: TTcpServerNameSpace; const Port: String);
    destructor Destroy; override;

    procedure Execute; override;
  end;

  { TTcpServerNameSpace                                                        }
  TTcpServerNameSpace = class(AServerNameSpace)
  protected
    FPort   : String;
    FLock   : TRTLCriticalSection;
    FThread : TTcpServerThread;

    procedure Lock;
    procedure Unlock;

  public
    constructor Create(const Port: String);
    destructor Destroy; override;

    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;

    function  Accept(var Abort: Boolean): TObject; override;
  end;



{ TTcpServerClientItemThread                                                   }
constructor TTcpServerClientItemThread.Create(const Client: TTcpServerClientItem);
begin
  FClient := Client;
  FreeOnTerminate := False;
  inherited Create(False);
end;

destructor TTcpServerClientItemThread.Destroy;
begin
  if FHandle <> 0 then
    PostMessage(FHandle, WM_QUIT, 0, 0);
  inherited Destroy;
end;

procedure TTcpServerClientItemThread.OnBeforeMessage(const Sender: TWindowHandle);
begin
  FClient.Lock;
end;

procedure TTcpServerClientItemThread.OnAfterMessage(const Sender: TWindowHandle);
begin
  FClient.Unlock;
end;

procedure TTcpServerClientItemThread.Execute;
var S : TTCPServerClientSocket;
begin
  S := FClient.FClient.GetSocket;
  S.OnBeforeMessage := OnBeforeMessage;
  S.OnAfterMessage := OnAfterMessage;
  FHandle := S.WindowHandle;
  FClient.FClient.Stream.StreamMode := smAsynchronous;
  While not Terminated do
    if not FClient.FClient.Socket.HandleMessage then
      break;
end;



{ TTcpServerClientItem                                                         }
constructor TTcpServerClientItem.Create(const ServerSpace: TTcpServerNameSpace;
    const Client: TTCPServerClient);
begin
  inherited Create;
  FServerSpace := ServerSpace;
  FClient := Client;
  InitializeCriticalSection(FLock);
  FThread := TTcpServerClientItemThread.Create(self);
end;

destructor TTcpServerClientItem.Destroy;
begin
  FreeAndNil(FThread);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TTcpServerClientItem.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TTcpServerClientItem.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

function TTcpServerClientItem.GetSize: Int64;
begin
  Result := -1;
end;

procedure TTcpServerClientItem.SetSize(const Size: Int64);
begin
  raise ENameSpace.Create('TCPD: Can not set size');
end;

function TTcpServerClientItem.GetPosition: Int64;
begin
  Lock;
  try
    Result := FClient.Stream.Position;
  finally
    Unlock;
  end;
end;

procedure TTcpServerClientItem.SetPosition(const Position: Int64);
begin
  Lock;
  try
    FClient.Stream.Position := Position;
  finally
    Unlock;
  end;
end;

function TTcpServerClientItem.GetReader: AReaderEx;
begin
  Lock;
  try
    Result := FClient.Stream.Reader;
  finally
   Unlock;
  end;
end;

function TTcpServerClientItem.GetWriter: AWriterEx;
begin
  Lock;
  try
    Result := FClient.Stream.Writer;
  finally
   Unlock;
  end;
end;

function TTcpServerClientItem.EOF: Boolean;
begin
  Lock;
  try
    Result := FClient.Stream.EOF;
  finally
   Unlock;
  end;
end;

procedure TTcpServerClientItem.Truncate;
begin
end;

function TTcpServerClientItem.Read(var Buffer; const Size: Integer): Integer;
begin
  if Size <= 0 then
    begin
      Result := 0;
      exit;
    end;
  Repeat
    Lock;
    try
      if (FClient.Stream.Reader.AvailableToRead >= Size) or
         not FClient.Socket.Connected then
        begin
          Result := FClient.Stream.Read(Buffer, Size);
          exit;
        end;
    finally
      Unlock;
    end;
    ThreadWouldBlock;
  Until False;
end;

function TTcpServerClientItem.Write(const Buffer; const Size: Integer): Integer;
begin
  Lock;
  try
    Result := FClient.Stream.Write(Buffer, Size);
  finally
    Unlock;
  end;
end;

function TTcpServerClientItem.IsOpen: Boolean;
begin
  Lock;
  try
    Result := not FClient.Stream.EOF;
  finally
    Unlock;
  end;
end;

procedure TTcpServerClientItem.Reopen;
begin
  raise ENameSpace.Create('TCPD: Can not reopen');
end;



{ TTcpServerThread                                                             }
constructor TTcpServerThread.Create(const ServerSpace: TTcpServerNameSpace;
    const Port: String);
begin
  FServerSpace := ServerSpace;
  FPort := Port;
  FreeOnTerminate := False;
  FServer := TfndTCPServer.CreateEx(FPort, 60000, smManualAccept, nil);
  inherited Create(False);
end;

destructor TTcpServerThread.Destroy;
begin
  if Assigned(FServer) and Assigned(FServer.Socket) then
    PostMessage(FServer.Socket.WindowHandle, WM_QUIT, 0, 0);
  FreeAndNil(FServer);
  inherited Destroy;
end;

procedure TTcpServerThread.OnBeforeMessage(const Sender: TWindowHandle);
begin
  FServerSpace.Lock;
end;

procedure TTcpServerThread.OnAfterMessage(const Sender: TWindowHandle);
begin
  FServerSpace.Unlock;
end;

procedure TTcpServerThread.Execute;
begin
  if Terminated then
    exit;
  FServerSpace.Lock;
  try
    FServer.Active := True;
    FServer.Socket.OnBeforeMessage := OnBeforeMessage;
    FServer.Socket.OnAfterMessage := OnAfterMessage;
  finally
    FServerSpace.Unlock;
  end;
  While not Terminated do
    if not FServer.Socket.HandleMessage then
      break;
end;



{ TTcpServerNameSpace                                                          }
constructor TTcpServerNameSpace.Create(const Port: String);
begin
  inherited Create;
  FPort := Port;
  InitializeCriticalSection(FLock);
  FThread := TTcpServerThread.Create(self, FPort);
end;

destructor TTcpServerNameSpace.Destroy;
begin
  FreeAndNil(FThread);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TTcpServerNameSpace.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TTcpServerNameSpace.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

function TTcpServerNameSpace.GetNameSpace(const RootNameSpace: TObject; const Name: String;
    var Position: Integer): TObject;
begin
  if Name[Position] = '/' then
    Inc(Position);
  Result := self;
end;

function TTcpServerNameSpace.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Accept') then
    begin
      Scope := self;
      FieldType := bfCall;
      Result := nil;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

function TTcpServerNameSpace.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
var A : Boolean;
begin
  if StrEqualNoCase(FieldName, 'Accept') then
    begin
      ValidateParamCount(0, 0, Parameters);
      A := False;
      Result := Accept(A);
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function TTcpServerNameSpace.Accept(var Abort: Boolean): TObject;
var C : TTCPServerClient;
    K : String;
begin
  Repeat
    if Abort then
      begin
        Result := nil;
        exit;
      end;
    Lock;
    try
      if FThread.FServer.Socket.PendingConnections > 0 then
        begin
          C := FThread.FServer.Accept;
          if Assigned(C) then
            begin
              Result := TTcpServerClientItem.Create(self, C);
              K := LongWordToHex(LongWord(Result), 8);
              Add(K, Result);
              Log('tcpd:' + FPort + '/' + K + ' accepted');
              exit;
            end;
        end;
    finally
      Unlock;
    end;
    ThreadWouldBlock;
  Until False;
end;



{ TTcpdNameSpace                                                               }
function TTcpdNameSpace.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
var Key, Addr, Port: String;
begin
  Key := ExtractStr(Name, Position, [':'], ['/']);
  Addr := ExtractStr(Name, Position, [':'], ['/']);
  Port := ExtractStr(Name, Position, [], ['/']);
  if Port = '' then
    raise ENameSpace.Create('TCPD: Invalid key');
  if Key = '' then
    Key := Port;
  if FItems.FindItemByString(Key, Result) then
    exit;
  Result := TTcpServerNameSpace.Create(Port);
  Add(Key, Result);
  Log('tcpd:' + Key + ':' + Addr + ':' + Port + ' created');
  TTcpServerNameSpace(Result).Start(FDomain, FPath + Key + '/');
end;



end.

