{                                                                              }
{                         Blaise name space peer v0.03                         }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{              Its original file name is cBlaiseNameSpacePeer.pas              }
{                                                                              }
{ Description:                                                                 }
{   This unit implements a Blaise name space peer.                             }
{                                                                              }
{ Revision history:                                                            }
{   28/04/2003  0.01  Initial version.                                         }
{   10/05/2003  0.02  Change for Blaze RPC.                                    }
{   15/05/2003  0.03  Revision.                                                }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseNameSpacePeer;

interface

uses
  { Delphi }
  Windows,

  { Fundamentals }
  cUtils,
  cArrays,
  cThreads,

  { Blaze }
  cBlazeUtils,
  cBlazeUtilsMessages,
  cBlazeClasses,
  cBlazeRPC,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructsCollections,
  cBlaiseNameSpaceTypes,
  cBlaiseNameSpaceRemote;



{                                                                              }
{ TBlaisePeerConnection                                                        }
{                                                                              }
type
  TBlaisePeerConnection = class(AbppConnection)
  protected
    FStream       : ABlaiseStream;
    FReadThread   : TThreadEx;
    FReadThreadID : DWORD;

    procedure InitConnection(const System: AbppSystem); override;
    procedure Read(var Buf; const Size: Integer); override;
    procedure Send(const Buf; const Size: Integer); override;
    procedure Wait; override;
    procedure ReadThreadExecute;

  public
    constructor Create(const Initiator: Boolean; const Stream: ABlaiseStream);
    destructor Destroy; override;

    function  IsConnected: Boolean;
  end;



{                                                                              }
{ TBlaisePeeringSystem                                                         }
{                                                                              }
type
  TBlaisePeeringSystem = class(AbppSystem)
  protected
    FSendThread : TThreadEx;

    procedure SendThreadExecute;

  public
    constructor Create;
    destructor Destroy; override;
  end;

function GetPeeringSystem: TBlaisePeeringSystem;



{                                                                              }
{ TNameSpaceProfile                                                            }
{   Profile for the name space channel.                                        }
{                                                                              }
type
  TNameSpaceProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
  end;



{                                                                              }
{ TNameSpaceChannel                                                            }
{   Name space channel.                                                        }
{                                                                              }
type
  APeerNameSpace = class;
  TNameSpaceChannel = class(TrpcChannel)
  protected
    FRemoteNameSpace : APeerNameSpace;

    procedure HandleRPCRequest(const RequestHeader: TbppMessageHeader;
              const ObjectID, MethodID: String;
              const Parameters: Array of String); override;
    procedure Wait; override;
  end;



{                                                                              }
{ APeerNameSpace                                                               }
{   Base class for a local namespace representing the root of a remote name    }
{   space.                                                                     }
{                                                                              }
  APeerNameSpace = class(ARootRemoteNameSpaceHandler)
  protected
    FConnection    : TBlaisePeerConnection;
    FChannel       : TNameSpaceChannel;

    procedure OnInitChannel(const Connection: AbppConnection;
              const Channel: AbppChannel);
    procedure SetConnection(const Connection: TBlaisePeerConnection);
    procedure EnsureConnected; virtual; abstract;
    procedure EnsureJoined;
    procedure HandleRPCRequest(const Channel: TNameSpaceChannel;
              const RequestHeader: TbppMessageHeader;
              const ObjectID, MethodID: String;
              const Parameters: Array of String);

  public
    constructor Create(const RootNameSpace: TObject);
    destructor Destroy; override;

    { ARemoteNameSpace                                                         }
    function  RPC(const ObjID, Method: String;
              const Parameters: Array of String;
              const MinResponse, MaxResponse: Integer): StringArray; override;

    function  GetObject(const ObjID: String): ABlaiseType; override;
    function  GetObjectID(const A: TObject): String; override;
  end;



{                                                                              }
{ THostRemoteNameSpace                                                         }
{   Remote name space for HOST name space.                                     }
{                                                                              }
type
  THostRemoteNameSpace = class(APeerNameSpace)
  protected
    FConnectionName : String;

    procedure SetConnectionName(const ConnectionName: String);
    procedure EnsureConnected; override;

  public
    property  ConnectionName: String read FConnectionName write SetConnectionName;
  end;



{                                                                              }
{ THostNameSpace                                                               }
{   The HOST name space.                                                       }
{                                                                              }
type
  THostNameSpace = class(ANameSpaceCollection)
  public
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
  end;



{                                                                              }
{ TShareRemoteNameSpace                                                        }
{   A remote SHARE name space.                                                 }
{                                                                              }
type
  TShareRemoteNameSpace = class(APeerNameSpace)
  protected
    FServer : String;
    FRoot   : String;

    procedure EnsureConnected; override;

  public
    constructor Create(const Server, Root: String;
                const RootNameSpace: TObject;
                const Connection: TBlaisePeerConnection);
  end;



{                                                                              }
{ TShareServerNameSpace                                                        }
{   A SHARE server name space.                                                 }
{                                                                              }
type
  TShareServerNameSpace = class(ANameSpaceCollection)
  protected
    FServerPath    : String;
    FRootPath      : String;
    FServerThread  : TThreadEx;
    FAbort         : Boolean;
    FServer        : AServerNameSpace;
    FRootNameSpace : TObject;

    procedure ServerThreadExecute;

  public
    constructor Create(const ServerPath, RootPath: String;
                const RootNameSpace: TObject);
    destructor Destroy; override;

    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
  end;



{                                                                              }
{ TShareNameSpace                                                              }
{   The SHARE name space.                                                      }
{                                                                              }
type
  TShareNameSpace = class(ANameSpaceCollection)
  public
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructsSimple;



{                                                                              }
{ TBlaisePeerConnection                                                        }
{                                                                              }

{ TPeerReadThread                                                              }
type
  TPeerReadThread = class(TThreadEx)
  protected
    FConnection : TBlaisePeerConnection;
  public
    constructor Create(const Connection : TBlaisePeerConnection);
    procedure Execute; override;
  end;

constructor TPeerReadThread.Create(const Connection : TBlaisePeerConnection);
begin
  FreeOnTerminate := False;
  inherited Create(True);
  Assert(Assigned(Connection));
  FConnection := Connection;
end;

procedure TPeerReadThread.Execute;
begin
  FConnection.ReadThreadExecute;
end;

{ TBlaisePeerConnection                                                        }
constructor TBlaisePeerConnection.Create(const Initiator: Boolean;
    const Stream: ABlaiseStream);
begin
  inherited Create(Initiator);
  Assert(Assigned(Stream));
  ObjectAddReference(Stream);
  FStream := Stream;
  FReadThread := TPeerReadThread.Create(self);
end;

destructor TBlaisePeerConnection.Destroy;
begin
  FreeAndNil(FReadThread);
  inherited Destroy;
  ObjectReleaseReferenceAndNil(FStream);
end;

procedure TBlaisePeerConnection.InitConnection(const System: AbppSystem);
begin
  inherited InitConnection(System);
  FReadThread.Resume;
end;

procedure TBlaisePeerConnection.Read(var Buf; const Size: Integer);
begin
  if FStream.Read(Buf, Size) <> Size then
    raise ENameSpace.Create('Read error');
end;

procedure TBlaisePeerConnection.Send(const Buf; const Size: Integer);
begin
  FStream.Write(Buf, Size);
end;

function TBlaisePeerConnection.IsConnected: Boolean;
begin
  Result := not FStream.EOF;
end;

procedure TBlaisePeerConnection.Wait;
var ThreadCall : Boolean;
begin
  ThreadCall := GetCurrentThreadId = FReadThreadID;
  if ThreadCall then
    begin
      SysUnlock;
      try
        ReceiveMessage;
      finally
        SysLock;
      end;
    end
  else
    ThreadWouldBlock;
end;

procedure TBlaisePeerConnection.ReadThreadExecute;
var T : TThreadEx;
begin
  T := FReadThread;
  if not Assigned(T) then
    exit;
  FReadThreadID := GetCurrentThreadId;
  While not T.Terminated do
    ReceiveMessage;
end;



{                                                                              }
{ TBlaisePeeringSystem                                                         }
{                                                                              }

{ TPeeringSendThread                                                           }
type
  TPeeringSendThread = class(TThreadEx)
  protected
    FSystem : TBlaisePeeringSystem;
  public
    constructor Create(const System: TBlaisePeeringSystem);
    procedure Execute; override;
  end;

constructor TPeeringSendThread.Create(const System: TBlaisePeeringSystem);
begin
  FreeOnTerminate := False;
  inherited Create(True);
  Assert(Assigned(System));
  FSystem := System;
end;

procedure TPeeringSendThread.Execute;
begin
  FSystem.SendThreadExecute;
end;

{ TBlaisePeeringSystem                                                         }
constructor TBlaisePeeringSystem.Create;
begin
  inherited Create;
  AddProfile('NAMESPACE', TNameSpaceProfile.Create);
  FSendThread := TPeeringSendThread.Create(self);
  FSendThread.Resume;
end;

destructor TBlaisePeeringSystem.Destroy;
begin
  FreeAndNil(FSendThread);
  inherited Destroy;
end;

procedure TBlaisePeeringSystem.SendThreadExecute;
var T : TThreadEx;
begin
  T := FSendThread;
  if not Assigned(T) then
    exit;
  While not T.Terminated do
    begin
      Lock;
      try
        if T.Terminated then
          exit;
        SendFrames;
        ApplyTimeOuts;
      finally
        Unlock;
      end;
      if T.Terminated then
        exit;
      Sleep(1);
    end;
end;



{                                                                              }
{ Global peering system                                                        }
{                                                                              }
var
  GlobalPeeringSystem : TBlaisePeeringSystem = nil;

function GetPeeringSystem: TBlaisePeeringSystem;
begin
  if not Assigned(GlobalPeeringSystem) then
    GlobalPeeringSystem := TBlaisePeeringSystem.Create;
  Result := GlobalPeeringSystem;
end;



{                                                                              }
{ TNameSpaceProfile                                                            }
{                                                                              }
function TNameSpaceProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TNameSpaceChannel.Create(self);
end;



{                                                                              }
{ TNameSpaceChannel                                                            }
{                                                                              }
procedure TNameSpaceChannel.HandleRPCRequest(
    const RequestHeader: TbppMessageHeader;
    const ObjectID, MethodID: String; const Parameters: Array of String);
begin
  if Assigned(FRemoteNameSpace) then
    FRemoteNameSpace.HandleRPCRequest(self, RequestHeader, ObjectID, MethodID,
        Parameters);
end;

procedure TNameSpaceChannel.Wait;
begin
  (Connection as TBlaisePeerConnection).Wait;
end;



{                                                                              }
{ APeerNameSpace                                                               }
{                                                                              }
constructor APeerNameSpace.Create(const RootNameSpace: TObject);
begin
  inherited Create(RootNameSpace as ANameSpace);
end;

destructor APeerNameSpace.Destroy;
begin
  SetConnection(nil);
  FreeAndNil(FCaller);
  inherited Destroy;
end;

const
  NilStr               = '00000000';
  InitiatorNil         = 'c' + Char(BLAISE_TYPE_ID_VALUE_Nil) + NilStr;
  ListenerNil          = 'l' + Char(BLAISE_TYPE_ID_VALUE_Nil) + NilStr;
  InitiatorUnassigned  = 'c' + Char(BLAISE_TYPE_ID_VALUE_Unassigned) + NilStr;
  ListenerUnassigned   = 'l' + Char(BLAISE_TYPE_ID_VALUE_Unassigned) + NilStr;

function APeerNameSpace.GetObject(const ObjID: String): ABlaiseType;
var T : TrpcValueType;
begin
  if (ObjID = '') or
     (ObjID = InitiatorNil) or
     (ObjID = ListenerNil) then
    begin
      Result := nil;
      exit;
    end;
  if ObjID = '/' then
    begin
      Result := FRootNameSpace;
      exit;
    end;
  if (ObjID = InitiatorUnassigned) or (ObjID = ListenerUnassigned) then
    begin
      Result := nil;
      exit;
    end;
  T := rpcDecodeValueType(ObjID);
  GetPeeringSystem.Lock;
  try
    Case T of
      rpctListenerHandle,
      rpctInitiatorHandle :
        if rpcIsHandleLocal(T, FConnection.Initiator) then
          Result := GetLocalObject(ObjID)
        else
          Result := GetRemoteObject(ObjID);
    else
      Result := nil;
    end;
  finally
    GetPeeringSystem.Unlock;
  end;
end;

function APeerNameSpace.GetObjectID(const A: TObject): String;
var L : Char;
begin
  if FConnection.Initiator then
    L := 'c'
  else
    L := 'l';
  if not Assigned(A) then
    Result := L + Char(BLAISE_TYPE_ID_VALUE_Nil) + NilStr else
  if (A is TRemoteObject) and
     (TRemoteObject(A).RemoteNameSpace = self) then
    Result := TRemoteObject(A).ObjectID else
  if A = UnassignedValue then
    Result := L + Char(BLAISE_TYPE_ID_VALUE_Unassigned) + NilStr
  else
    begin
      Result := L + Char(GetLocalObjectTypeID(A)) +
                LongWordToHex(LongWord(A), 8);
      GetPeeringSystem.Lock;
      try
        FLocalObjects.ItemByString[Result] := A;
      finally
        GetPeeringSystem.Unlock;
      end;
    end;
end;

procedure APeerNameSpace.HandleRPCRequest(const Channel: TNameSpaceChannel;
    const RequestHeader: TbppMessageHeader; const ObjectID, MethodID: String;
    const Parameters: Array of String);
var Obj : ABlaiseType;
    ER, EM : String;
    RR : StringArray;
begin
  RR := nil;
  Log('Request:' + ObjectID + '.' + MethodID + '(' + StrJoin(Parameters, ',') + ')');
  try
    // Get object
    Obj := GetObject(ObjectID);
    if not Assigned(Obj) then
      begin
        Channel.SendRPCErrorResponse(RequestHeader, 'INVALID_OBJECT',
            'Object not found');
        exit;
      end;
    // Get response
    try
      RR := GetRPCResponse(Obj, MethodID, Parameters, ER, EM);
    finally
      ObjectReleaseUnreferenced(Obj);
    end;
  except
    on E : Exception do
      begin
        ER := 'SYSTEM_ERROR';
        EM := E.Message;
      end;
  end;
  // Send response
  if (ER <> '') or (EM <> '') then
    begin
      Log('Response: Error: ' + ER + ': ' + EM);
      Channel.SendRPCErrorResponse(RequestHeader, ER, EM);
    end
  else
    begin
      Log('Response: (' + StrJoin(RR, ',') + ')');
      Channel.SendRPCResultResponse(RequestHeader, RR);
    end;
end;

procedure APeerNameSpace.OnInitChannel(const Connection: AbppConnection;
    const Channel: AbppChannel);
begin
  if Channel is TNameSpaceChannel then
    TNameSpaceChannel(Channel).FRemoteNameSpace := self;
end;

procedure APeerNameSpace.SetConnection(const Connection: TBlaisePeerConnection);
begin
  if Assigned(FConnection) then
   GetPeeringSystem.RemoveConnection(FConnection);
  FreeAndNil(FConnection);
  FChannel := nil;
  if Assigned(Connection) then
    begin
      FConnection := Connection;
      FConnection.OnInitChannel := OnInitChannel;
      GetPeeringSystem.AddConnection(Connection);
    end;
end;

procedure APeerNameSpace.EnsureJoined;
begin
  EnsureConnected;
  if Assigned(FChannel) then
    exit;
  Log('Joining channel');
  FChannel := FConnection.Join('NameSpace', '') as TNameSpaceChannel;
end;

function APeerNameSpace.RPC(const ObjID, Method: String;
    const Parameters: Array of String;
    const MinResponse, MaxResponse: Integer): StringArray;
var L : Integer;
begin
  EnsureJoined;
  Log('RPC: ' + ObjID + '.' + Method + '(' + StrJoin(Parameters, ',') + ')');
  FChannel.RPC(ObjID, Method, Parameters, Result);
  L := Length(Result);
  if ((MinResponse >= 0) and (L < MinResponse)) or
     ((MaxResponse >= 0) and (L > MaxResponse)) then
    raise ENameSpace.Create('RPC: Invalid response');
end;



{                                                                              }
{ THostRemoteNameSpace                                                         }
{                                                                              }
procedure THostRemoteNameSpace.SetConnectionName(const ConnectionName: String);
begin
  if ConnectionName = FConnectionName then
    exit;
  SetConnection(nil);
  FConnectionName := ConnectionName;
end;

procedure THostRemoteNameSpace.EnsureConnected;
var C : TObject;
begin
  // Validate existing connection
  if Assigned(FConnection) then
    begin
      if FConnection.IsConnected then
        exit;
      SetConnection(nil);
    end;
  // Create new connection
  if FConnectionName = '' then
    raise ENameSpace.Create('No connection name');
  C := NameSpaceGetName(FRootNameSpace, ConnectionName);
  if not Assigned(C) then
    raise ENameSpace.Create('Can not resolve connection name');
  if not (C is ABlaiseStream) then
    raise ENameSpace.Create('Connection not a stream');
  SetConnection(TBlaisePeerConnection.Create(True, ABlaiseStream(C)));
end;



{                                                                              }
{ THostNameSpace                                                               }
{                                                                              }
function THostNameSpace.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
var I, J, L : Integer;
    Host    : String;
    Conn    : String;
    SetConn : Boolean;
begin
  SetConn := False;
  Conn := '';
  L := Length(Name);
  // Get host identifier and connection name
  I := PosChar(['/', '{'], Name, Position);
  if I = 0 then
    begin
      Host := CopyFrom(Name, Position);
      Position := L + 1;
    end else
    begin
      Host := CopyRange(Name, Position, I - 1);
      Position := I + 1;
      if Name[I] = '{' then
        begin
          J := StrFindClosingBracket(Name, I, '}');
          if J = 0 then
            raise ENameSpace.Create('Host: Mismatched bracket }');
          Conn := CopyRange(Name, I + 1, J - 1);
          SetConn := True;
          Position := J + 1;
          if (Position <= L) and (Name[Position] = '/') then
            Inc(Position);
        end;
    end;
  // Get host
  if not FItems.FindItemByString(Host, Result) then
    begin
      Result := THostRemoteNameSpace.Create(RootNameSpace);
      FItems.AddItemByString(Host, Result);
      THostRemoteNameSpace(Result).Start(FDomain, FPath + Host + '/');
    end;
  // Update parameters
  if SetConn then
    THostRemoteNameSpace(Result).ConnectionName := Conn;
end;



{                                                                              }
{ TShareRemoteNameSpace                                                        }
{                                                                              }
constructor TShareRemoteNameSpace.Create(const Server, Root: String;
    const RootNameSpace: TObject; const Connection: TBlaisePeerConnection);
begin
  inherited Create(RootNameSpace);
  FServer := Server;
  FRoot := Root;
  SetConnection(Connection);
end;

procedure TShareRemoteNameSpace.EnsureConnected;
begin
  if not Assigned(FConnection) or not FConnection.IsConnected then
    raise ENameSpace.Create('Not connected');
end;



{                                                                              }
{ TShareServerThread                                                           }
{                                                                              }
type
  TShareServerThread = class(TThreadEx)
  protected
    FNameSpace : TShareServerNameSpace;
    procedure Execute; override;
  public
    constructor Create(const NameSpace: TShareServerNameSpace);
  end;

constructor TShareServerThread.Create(const NameSpace: TShareServerNameSpace);
begin
  FreeOnTerminate := False;
  inherited Create(True);
  Assert(Assigned(NameSpace));
  FNameSpace := NameSpace;
end;

procedure TShareServerThread.Execute;
begin
  FNameSpace.ServerThreadExecute;
end;




{                                                                              }
{ TShareServerNameSpace                                                        }
{                                                                              }
constructor TShareServerNameSpace.Create(const ServerPath, RootPath: String;
    const RootNameSpace: TObject);
var V : TObject;
begin
  inherited Create;
  FServerPath := ServerPath;
  FRootPath := RootPath;
  FRootNameSpace := RootNameSpace;
  // Create server thread
  V := NameSpaceGetName(RootNameSpace, ServerPath);
  if not Assigned(V) then
    raise ENameSpace.Create('Server not found');
  if not (V is AServerNameSpace) then
    raise ENameSpace.Create('Not a server');
  FServer := AServerNameSpace(V);
  ObjectAddReference(FServer);
  FAbort := False;
  FServerThread := TShareServerThread.Create(self);
  FServerThread.Resume;
end;

destructor TShareServerNameSpace.Destroy;
begin
  FAbort := True;
  FreeAndNil(FServerThread);
  ObjectReleaseReferenceAndNil(FServer);
  inherited Destroy;
end;

procedure TShareServerNameSpace.ServerThreadExecute;
var V : TObject;
    S : ABlaiseStream;
    N : TShareRemoteNameSpace;
    T : TThreadEx;
    K : String;
begin
  T := FServerThread;
  While not T.Terminated do
    begin
      // Accept new client
      V := FServer.Accept(FAbort);
      if FAbort or T.Terminated then
        exit;
      if not (V is ABlaiseStream) then
        raise ENameSpace.Create('Invalid client');
      // Add client name space
      S := ABlaiseStream(V);
      N := TShareRemoteNameSpace.Create(FServerPath, FRootPath, FRootNameSpace,
          TBlaisePeerConnection.Create(False, S));
      K := LongWordToHex(LongWord(N));
      Add(K, N);
      N.Start(FDomain, FPath + K + '/');
    end;
end;

function TShareServerNameSpace.GetNameSpace(const RootNameSpace: TObject; const Name: String;
    var Position: Integer): TObject;
var K : String;
begin
  if Name = '' then
    begin
      Result := self;
      exit;
    end;
  K := ExtractStr(Name, Position, ['/'], []);
  Result := FItems.ItemByString[K];
end;



{                                                                              }
{ TShareNameSpace                                                              }
{                                                                              }
function TShareNameSpace.GetNameSpace(const RootNameSpace: TObject; const Name: String;
    var Position: Integer): TObject;
var Share  : String;
    Server : String;
    Root   : String;
begin
  Share := ExtractStr(Name, Position, [], ['{', '/']);
  Server := ExtractName(Name, Position, '/');
  Root := ExtractName(Name, Position, '/');
  if (Position <= Length(Name)) and (Name[Position] = '/') then
    Inc(Position);
  if not FItems.FindItemByString(Share, Result) then
    begin
      Result := TShareServerNameSpace.Create(Server, Root, RootNameSpace);
      Add(Share, Result);
      TShareServerNameSpace(Result).Start(FDomain, FPath + Share + '/');
      Log('share:' + Share + '{' + Server + '}{' + Root + '} created');
    end;
end;



initialization
finalization
  FreeAndNil(GlobalPeeringSystem);
end.

