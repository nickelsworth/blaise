{                                                                              }
{                       Blaze Peering Protocol Classes v0.04                   }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{ Description:                                                                 }
{   Class framework for the Blaze Peering Protocol (BPP).                      }
{                                                                              }
{ Revision history:                                                            }
{   03/05/2003  0.01  Initial version.                                         }
{   05/05/2003  0.02  Implement direct messages.                               }
{   09/05/2003  0.03  Implement control channel.                               }
{   15/05/2003  0.04  Revision.                                                }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cBlazeClasses;

interface

uses
  { Delphi }
  Windows,

  { Fundamentals }
  cUtils,
  cArrays,
  cDictionaries,

  { Blaze }
  cBlazeUtils,
  cBlazeUtilsMessages,
  cBlazeUtilsControlChannel;



{                                                                              }
{ TbppTransportLimits                                                          }
{   Keeps track of BPP transport limits.                                       }
{                                                                              }
type
  TbppTransportLimits = class
  protected
    FSendLimitCPS     : Integer;
    FSendLimitFPS     : Integer;
    FSendStart        : LongWord;
    FSendBytes        : LongWord;
    FSendFrames       : LongWord;
    FPayloadSizeLimit : Integer;

    procedure SetPayloadSizeLimit(const PayloadSizeLimit: Integer);
    function  GetFrameSizeLimit: Integer;
    procedure SetFrameSizeLimit(const FrameSizeLimit: Integer);

    procedure InitTimer;
    function  CanSendFrame: Boolean;
    procedure NotifyFrameSent(const Size: Integer);

  public
    constructor Create;

    property  SendLimitCPS: Integer read FSendLimitCPS write FSendLimitCPS;
    property  SendLimitFPS: Integer read FSendLimitFPS write FSendLimitFPS;
    property  PayloadSizeLimit: Integer read FPayloadSizeLimit write SetPayloadSizeLimit;
    property  FrameSizeLimit: Integer read GetFrameSizeLimit write SetFrameSizeLimit;

    function  GetSendRateCPS: Integer;
    function  GetSendRateFPS: Integer;
  end;



{                                                                              }
{ TbppMessage                                                                  }
{   A BPP message.                                                             }
{                                                                              }
type
  TbppMessageState = (msInit,
                      msOutbound,
                      msFraming,
                      msSent,
                      msResponsePending,
                      msResponded,
                      msFinSuccess,
                      msFinAborted,
                      msFinTimeOut);
  TbppMessage = class;
  TbppMessageStateChangeEvent = procedure (const Sender: TbppMessage;
      const OldState, NewState: TbppMessageState) of object;
  TbppMessage = class
  protected
    FRefCount      : Integer;
    FState         : TbppMessageState;
    FPayload       : String;
    FTimeOut       : Integer;
    FTickCount     : LongWord;
    FPreviousState : TbppMessageState;
    FOnStateChange : TbppMessageStateChangeEvent;

    procedure Init; virtual;

    procedure TriggerOutbound; virtual;
    procedure TriggerFraming; virtual;
    procedure TriggerMessageSent; virtual;
    procedure TriggerResponsePending; virtual;
    procedure TriggerResponseReceived; virtual;
    procedure TriggerFinished; virtual;

    function  ApplyTimeOut(const TickCount: LongWord): Boolean;

    function  GetSendProgressPercent: Integer;
    function  GetElapsedTime: Integer;

  public
    FHeader        : TbppMessageHeader;
    FSendPosition  : Integer;

    procedure HandleResponseMessage(const Header: TbppMessageHeader;
              const Payload: String); virtual;
    procedure SetDestinationID(const ID: TbppID);
    procedure SetState(const State: TbppMessageState); virtual;

  public
    constructor Create;
    constructor CreateEx(const Header: TbppMessageHeader; const Payload: String;
                const TimeOut: Integer = -1);

    procedure AddReference;
    procedure ReleaseReference;

    property  Header: TbppMessageHeader read FHeader;
    property  Payload: String read FPayload;
    property  TimeOut: Integer read FTimeOut;

    property  State: TbppMessageState read FState;
    property  OnStateChange: TbppMessageStateChangeEvent read FOnStateChange write FOnStateChange;
    property  SendPosition: Integer read FSendPosition;
    property  SendProgressPercent: Integer read GetSendProgressPercent;
    property  ElapsedTime: Integer read GetElapsedTime;
    function  IsTransportFinished: Boolean;
    function  IsTransportSuccess: Boolean;
  end;



{                                                                              }
{ TbppMessageList                                                              }
{                                                                              }
type
  TbppMessageList = class(TObjectArray)
  public
    constructor Create;
    destructor Destroy; override;

    function  LocateMessageByID(const ID: TbppID;
              var Msg: TbppMessage): Integer;
    procedure ApplyTimeOuts(const TickCount: LongWord);
  end;



{                                                                              }
{ AbppChannel                                                                  }
{   Base implementation for a BPP channel.                                     }
{                                                                              }
{   Implementations must override the Handle_xxx_Message methods.              }
{                                                                              }
const
  bppChannelPriorityLow      = 1;
  bppChannelPriorityNormal   = 10;
  bppChannelPriorityHigh     = 100;
  bppChannelPriorityCritical = 1000;

type
  TbppChannelType = (ctInit,
                     ctControl,
                     ctInbound,
                     ctOutbound);
  AbppProfile = class;
  AbppConnection = class;
  AbppChannel = class
  protected
    FProfile         : AbppProfile;
    FChannelType     : TbppChannelType;
    FChannelIndex    : LongWord;
    FChannelID       : TbppID;
    FChannelIDStr    : String;
    FSendPriority    : Integer;
    FTransportLimits : TbppTransportLimits;
    FConnection      : AbppConnection;
    FOutbound        : TbppMessageList;
    FRequests        : TbppMessageList;

    procedure InitChannel(const ChannelType: TbppChannelType;
              const ChannelIndex: LongWord); virtual;
    procedure InitConnection(const Connection: AbppConnection); virtual;

    procedure SysLock;
    procedure SysUnlock;

    procedure AddOutbound(const Msg: TbppMessage);
    function  AddOutboundMessage(const Header: TbppMessageHeader;
              const Payload: String): TbppMessage;

    function  CanSendFrame: Boolean;
    function  SendFrame(var Size: Integer): Boolean;
    procedure ApplyTimeOuts(const TickCount: LongWord);

    procedure HandleControlMessage(const Header: TbppMessageHeader;
              const Payload: String); virtual;
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); virtual;
    procedure HandleResponseMessage(const RequestMessage: TbppMessage;
              const Header: TbppMessageHeader;
              const Payload: String); virtual;
    function  GetBroadcastMask(const Header: TbppMessageHeader;
              const Payload: String): String; virtual;
    function  MatchChannelMask(const ChannelMask: String): Boolean; virtual;

    procedure ChannelHandleResponseMessage(const Header: TbppMessageHeader;
              const Payload: String);
    procedure ChannelHandleBroadcastMessage(const Header: TbppMessageHeader;
              const Payload: String);

  public
    constructor Create(const Profile: AbppProfile);
    destructor Destroy; override;

    property  Profile: AbppProfile read FProfile;
    property  ChannelType: TbppChannelType read FChannelType;
    property  ChannelIndex: LongWord read FChannelIndex;
    property  ChannelIDStr: String read FChannelIDStr;
    property  SendPriority: Integer read FSendPriority write FSendPriority;
    property  TransportLimits: TbppTransportLimits read FTransportLimits;
    property  Connection: AbppConnection read FConnection;

    procedure SendControlMessage(const Payload: String);
    function  SendRequestMessage(const Payload: String): TbppMessage; overload;
    procedure SendRequestMessage(const Msg: TbppMessage); overload;
    procedure SendResponseMessage(const RequestHeader: TbppMessageHeader;
              const Payload: String; const Success: Boolean);
    procedure SendBroadcastMessage(const Payload: String);
    procedure ForwardBroadcastMessage(const Header: TbppMessageHeader;
              const Payload: String);
    procedure SendRoutedMessage(const Header: TbppMessageHeader;
              const Payload: String);
  end;



{                                                                              }
{ TbppChannelList                                                              }
{                                                                              }

  TbppChannelList = class(TObjectDictionary)
  protected
    FSendChannelIdx : Integer;

    procedure ApplyTimeOuts(const TickCount: LongWord);

  public
    constructor Create(const IsItemOwner: Boolean);

    function  ChannelCount: Integer;
    function  GetChannelByID(const ID: String): AbppChannel;
    function  GetChannelByIndex(const Idx: Integer): AbppChannel;
    function  GetReadyToSendChannel: AbppChannel;
  end;



{                                                                              }
{ TbppControlChannel                                                           }
{   Implementation of the BPP control channel.                                 }
{                                                                              }

  TbppControlChannel = class(AbppChannel)
  protected
    procedure SendErrorResponse(const RequestHeader: TbppMessageHeader;
              const ErrorType, ErrorMessage: String);
    procedure SendChannelOkResponse(const RequestHeader: TbppMessageHeader;
              const Channel: AbppChannel; const ProfileParam: String);

    procedure HandleControlMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;

  public
    constructor Create(const Profile: AbppProfile);

    procedure SendLimitFrameControl(const ChannelID: String;
              const Size: LongWord);
    procedure SendLimitCPSControl(const ChannelID: String;
              const CPS: Integer);
    procedure SendLimitFPSControl(const ChannelID: String;
              const FPS: Integer);

    function  SendJoinRequest(const Name, Param: String): TbppMessage;
    function  SendLeaveRequest(const ChannelID: String): TbppMessage;
  end;



{                                                                              }
{ AbppConnection                                                               }
{   Base implementation for a BPP connection.                                  }
{                                                                              }
{   Implementations must:                                                      }
{     Override the Read, Send and Wait methods.                                }
{     Call ReceiveMessages to wait for and process incoming messages.          }
{                                                                              }

  AbppSystem = class;
  AbppConnectionChannelEvent = procedure (const Connection: AbppConnection;
      const Channel: AbppChannel) of object;
  AbppConnection = class
  protected
    FInitiator       : Boolean;
    FSystem          : AbppSystem;
    FTransportLimits : TbppTransportLimits;
    FSeqCounterIn    : LongWord;
    FSeqCounterOut   : LongWord;
    FPartialIn       : Boolean;
    FPartialPayload  : StringArray;
    FChannels        : TbppChannelList;
    FChannelsInIdx   : LongWord;
    FControlChannel  : TbppControlChannel;
    FOnAddChannel    : AbppConnectionChannelEvent;
    FOnInitChannel   : AbppConnectionChannelEvent;
    FOnRemoveChannel : AbppConnectionChannelEvent;

    procedure InitConnection(const System: AbppSystem); virtual;
    procedure SysLock;
    procedure SysUnlock;

    procedure Read(var Buf; const Size: Integer); virtual; abstract;
    procedure Send(const Buf; const Size: Integer); virtual; abstract;
    procedure Wait; virtual; abstract;

    function  AllocChannelInIndex: LongWord;
    procedure AddChannel(const Channel: AbppChannel);
    function  GetChannelByIDStr(const ID: String): AbppChannel;
    function  GetChannelByID(const ID: TbppID): AbppChannel;
    function  GetControlChannel: TbppControlChannel;
    procedure RemoveChannel(const ID: String);

    procedure DoSendFrame(var Header: TbppMessageHeader; const Payload: String);
    function  SendFrame: Boolean;
    function  SendFrames: Boolean;
    procedure ApplyTimeOuts(const TickCount: LongWord);
    procedure ReceiveMessage;

    procedure HandleDirectMessage(const Channel: AbppChannel;
              const Header: TbppMessageHeader; const Payload: String);
    procedure HandleBroadcastMessage(const Header: TbppMessageHeader;
              const Payload: String);
    procedure HandleMessage(const Header: TbppMessageHeader;
              const Payload: String); virtual;

  public
    constructor Create(const Initiator: Boolean);
    destructor Destroy; override;

    property  Initiator: Boolean read FInitiator;
    property  System: AbppSystem read FSystem;
    property  TransportLimits: TbppTransportLimits read FTransportLimits;
    property  ControlChannel: TbppControlChannel read GetControlChannel;
    property  Channels: TbppChannelList read FChannels;

    function  Join(const Name, Param: String): AbppChannel;
    procedure Leave(const Channel: AbppChannel);

    property  OnInitChannel: AbppConnectionChannelEvent read FOnInitChannel write FOnInitChannel;
    property  OnAddChannel: AbppConnectionChannelEvent read FOnAddChannel write FOnAddChannel;
    property  OnRemoveChannel: AbppConnectionChannelEvent read FOnRemoveChannel write FOnRemoveChannel;
  end;



{                                                                              }
{ AbppProfile                                                                  }
{   Base implementation for a BPP profile.                                     }
{                                                                              }
{   Implementations must implement the CreateChannel method.                   }
{                                                                              }

  AbppProfile = class
  protected
    FSystem     : AbppSystem;
    FChannels   : TbppChannelList;
    FBroadcasts : TObjectDictionary;

    procedure InitProfile(const System: AbppSystem); virtual;

    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; virtual; abstract;

    procedure AddChannel(const Channel: AbppChannel);
    procedure RemoveChannel(const ID: String);

    procedure HandleBroadcastMessage(const Channel: AbppChannel;
              const ChannelMask: String;
              const Header: TbppMessageHeader; const Payload: String); virtual;
    function  HandleRoutedMessage(const Header: TbppMessageHeader;
              const Payload: String): Boolean; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    property  System: AbppSystem read FSystem;
    property  Channels: TbppChannelList read FChannels;

    procedure SendBroadcastMessage(const ChannelMask, Payload: String);
  end;



{                                                                              }
{ AbppSystem                                                                   }
{   Base implementation for a BPP system.                                      }
{                                                                              }
{   Implementations must:                                                      }
{     Call AddProfile to register profiles at any time.                        }
{     Call AddConnection when a connection has been established.               }
{     Call RemoveConnection when a connection is no longer usable.             }
{     Call SendFrames periodically to send frames from the outbound queue.     }
{     Call ApplyTimeOuts periodically to expire timed-out messages.            }
{                                                                              }

  AbppSystem = class
  protected
    FLock            : TRTLCriticalSection;
    FProfiles        : TObjectDictionary;
    FConnections     : TObjectArray;
    FTransportLimits : TbppTransportLimits;

    function  GetConnectionCount: Integer;
    function  GetConnection(const Idx: Integer): AbppConnection;

    function  CanSendFrame: Boolean;
    procedure NotifyFrameSent(const Size: Integer);

    function  CreateControlChannel: TbppControlChannel;

    procedure HandleRoutedMessage(const Header: TbppMessageHeader;
              const Payload: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    property  TransportLimits: TbppTransportLimits read FTransportLimits;

    procedure AddProfile(const Name: String; const Profile: AbppProfile);
    function  GetProfile(const Name: String): AbppProfile;
    function  CreateChannelByProfile(const Name, Param: String;
              var InitParam: String): AbppChannel;

    procedure AddConnection(const Connection: AbppConnection);
    procedure RemoveConnection(const Connection: AbppConnection);
    property  ConnectionCount: Integer read GetConnectionCount;
    property  Connection[const Idx: Integer]: AbppConnection read GetConnection;

    function  SendFrames: Boolean;
    procedure ApplyTimeOuts;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,

  { Blaze }
  cBlazeProfilesStd;



{                                                                              }
{ TbppTransportLimits                                                          }
{                                                                              }
constructor TbppTransportLimits.Create;
begin
  inherited Create;
  FSendLimitCPS := -1;
  FSendLimitFPS := -1;
  FPayloadSizeLimit := BPP_MSG_DefaultPayloadSize;
end;

procedure TbppTransportLimits.SetPayloadSizeLimit(const PayloadSizeLimit: Integer);
begin
  FPayloadSizeLimit := bppGetValidPayloadLimit(PayloadSizeLimit);
end;

function TbppTransportLimits.GetFrameSizeLimit: Integer;
begin
  Result := FPayloadSizeLimit + BPP_MSG_MinSize;
end;

procedure TbppTransportLimits.SetFrameSizeLimit(const FrameSizeLimit: Integer);
begin
  if FrameSizeLimit <= 0 then
    SetPayloadSizeLimit(BPP_MSG_DefaultPayloadSize) else
  if FrameSizeLimit <= BPP_MSG_MinSize + BPP_MSG_MinPayloadLimit then
    SetPayloadSizeLimit(BPP_MSG_MinPayloadLimit)
  else
    SetPayloadSizeLimit(FrameSizeLimit - BPP_MSG_MinSize);
end;

procedure TbppTransportLimits.InitTimer;
var T : LongWord;
begin
  T := GetTickCount;
  FSendStart := T;
  FSendBytes := 0;
  FSendFrames := 0;
end;

function TbppTransportLimits.CanSendFrame: Boolean;
var A : Int64;
begin
  // Check bandwidth limit
  if FSendLimitCPS >= 0 then
    begin
      if FSendLimitCPS = 0 then
        Result := False
      else
        begin
          A := (Int64(GetTickCount - FSendStart) * FSendLimitCPS) div 1000
               + BPP_MSG_MinSize
               - FSendBytes;
          Result := A >= BPP_MSG_MinSize;
        end;
      if not Result then
        exit;
    end;
  // Check frame rate limit
  if FSendLimitFPS >= 0 then
    begin
      if FSendLimitFPS = 0 then
        Result := False
      else
        begin
          A := (Int64(GetTickCount - FSendStart) * FSendLimitFPS) div 1000
               + 1
               - FSendFrames;
          Result := A >= 1;
        end;
      if not Result then
        exit;
    end;
  // Send allowed
  Result := True;
end;

procedure TbppTransportLimits.NotifyFrameSent(const Size: Integer);
var T, E : LongWord;
begin
  // Update statistics
  Inc(FSendBytes, Size);
  Inc(FSendFrames);
  T := GetTickCount;
  E := LongWord(T - FSendStart);
  While (E >= 15000) and (FSendFrames >= 2) do
    begin
      E := E div 2;
      FSendBytes := FSendBytes div 2;
      FSendFrames := FSendFrames div 2;
    end;
  FSendStart := LongWord(T - E);
end;

function TbppTransportLimits.GetSendRateCPS: Integer;
var E : Integer;
begin
  E := LongWord(GetTickCount - FSendStart);
  if E = 0 then
    Result := 0
  else
    Result := Trunc((FSendBytes * 1000.0) / E);
end;

function TbppTransportLimits.GetSendRateFPS: Integer;
var E : Integer;
begin
  E := LongWord(GetTickCount - FSendStart);
  if E = 0 then
    Result := 0
  else
    Result := Trunc((FSendFrames * 1000.0) / E);
end;



{                                                                              }
{ TbppMessage                                                                  }
{                                                                              }
constructor TbppMessage.Create;
begin
  inherited Create;
  Init;
end;

constructor TbppMessage.CreateEx(const Header: TbppMessageHeader;
    const Payload: String; const TimeOut: Integer);
begin
  inherited Create;
  Init;
  FHeader := Header;
  FPayload := Payload;
  FTimeOut := TimeOut;
end;

procedure TbppMessage.Init;
begin
  FState := msInit;
  FPreviousState := msInit;
  FTimeOut := -1;
end;

procedure TbppMessage.AddReference;
begin
  Assert(FRefCount >= 0);
  Inc(FRefCount);
end;

procedure TbppMessage.ReleaseReference;
begin
  Assert(FRefCount > 0);
  Dec(FRefCount);
  if FRefCount = 0 then
    Destroy;
end;

procedure TbppMessage.SetDestinationID(const ID: TbppID);
begin
  FHeader.DestinationID := ID;
end;

procedure TbppMessage.SetState(const State: TbppMessageState);
begin
  if State = FState then
    exit;
  // Set state
  FPreviousState := FState;
  FState := State;
  // Trigger state change
  Case State of
    msOutbound        : TriggerOutbound;
    msFraming         : TriggerFraming;
    msSent            : TriggerMessageSent;
    msResponsePending : TriggerResponsePending;
    msResponded       : TriggerResponseReceived;
    msFinSuccess,
    msFinAborted,
    msFinTimeOut      : TriggerFinished;
  end;
  // Notify state change
  if Assigned(FOnStateChange) then
    FOnStateChange(self, FPreviousState, FState);
end;

procedure TbppMessage.TriggerOutbound;
begin
  FTickCount := GetTickCount;
end;

procedure TbppMessage.TriggerFraming;
begin
end;

procedure TbppMessage.TriggerMessageSent;
begin
end;

procedure TbppMessage.TriggerResponsePending;
begin
end;

procedure TbppMessage.TriggerResponseReceived;
begin
end;

procedure TbppMessage.TriggerFinished;
begin
  if FPreviousState <> msInit then
    FTickCount := LongWord(GetTickCount - FTickCount);
end;

function TbppMessage.ApplyTimeOut(const TickCount: LongWord): Boolean;
begin
  Result := (FTimeOut >= 0) and
            (FState in [msOutbound, msFraming, msResponsePending]) and
            (Integer(TickCount - FTickCount) > FTimeOut);
  if Result then
    SetState(msFinTimeOut);
end;

procedure TbppMessage.HandleResponseMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
end;

function TbppMessage.IsTransportFinished: Boolean;
begin
  Result := FState in [msFinSuccess, msFinAborted, msFinTimeOut];
end;

function TbppMessage.IsTransportSuccess: Boolean;
begin
  Result := FState = msFinSuccess;
end;

function TbppMessage.GetSendProgressPercent: Integer;
var L : Integer;
begin
  Case FState of
    msInit,
    msOutbound : Result := 0;
    msFraming  :
      begin
        L := Length(FPayload);
        if L = 0 then
          Result := 0
        else
          Result := Trunc((FSendPosition / L) * 100.0);
      end;
    msSent,
    msResponsePending,
    msResponded,
    msFinSuccess  : Result := 100;
    msFinAborted,
    msFinTimeOut  : Result := -1;
  else
    Result := 0;
  end;
end;

function TbppMessage.GetElapsedTime: Integer;
begin
  Case FState of
    msInit        : Result := 0; // no timer
    msOutbound,
    msFraming,
    msSent,
    msResponsePending,
    msResponded   : Result := Integer(GetTickCount - FTickCount); // running timer
    msFinSuccess,
    msFinAborted,
    msFinTimeOut  : Result := FTickCount; // stopped timer
  else
    Result := -1;
  end;
end;



{                                                                              }
{ TbppMessageList                                                              }
{                                                                              }
constructor TbppMessageList.Create;
begin
  inherited Create(nil, False);
end;

destructor TbppMessageList.Destroy;
var I : Integer;
    M : TbppMessage;
begin
  // Release message references
  For I := 0 to FCount - 1 do
    begin
      M := TbppMessage(FData[I]);
      FData[I] := nil;
      if Assigned(M) then
        begin
          M.FState := msFinAborted;
          M.ReleaseReference;
        end;
    end;
  inherited Destroy;
end;

procedure TbppMessageList.ApplyTimeOuts(const TickCount: LongWord);
var I : Integer;
    M : TbppMessage;
begin
  For I := FCount - 1 downto 0 do
    begin
      M := TbppMessage(FData[I]);
      if M.ApplyTimeOut(TickCount) then
        begin
          Delete(I);
          M.ReleaseReference;
        end;
    end;
end;

function TbppMessageList.LocateMessageByID(const ID: TbppID;
    var Msg: TbppMessage): Integer;
var I : Integer;
    M : TbppMessage;
begin
  For I := 0 to FCount - 1 do
    begin
      M := TbppMessage(FData[I]);
      if ID.Chars = M.FHeader.MessageID.Chars then
        begin
          Msg := M;
          Result := I;
          exit;
        end;
    end;
  Msg := nil;
  Result := -1;
end;



{                                                                              }
{ AbppChannel                                                                  }
{                                                                              }
constructor AbppChannel.Create(const Profile: AbppProfile);
begin
  inherited Create;
  Assert(Assigned(Profile));
  FProfile := Profile;
  FChannelType := ctInit;
  FSendPriority := bppChannelPriorityNormal;
  FTransportLimits := TbppTransportLimits.Create;
  FOutbound := TbppMessageList.Create;
  FRequests := TbppMessageList.Create;
end;

destructor AbppChannel.Destroy;
begin
  if Assigned(FProfile) and (FChannelIDStr <> '') then
    FProfile.RemoveChannel(FChannelIDStr);
  FreeAndNil(FRequests);
  FreeAndNil(FOutbound);
  FreeAndNil(FTransportLimits);
  inherited Destroy;
end;

procedure AbppChannel.InitChannel(const ChannelType: TbppChannelType;
    const ChannelIndex: LongWord);
begin
  FChannelType := ChannelType;
  FChannelIndex := ChannelIndex;
  bppSetID8Hex(FChannelID.Channel.ID, ChannelIndex);
  FChannelIDStr := LongWordToHex(ChannelIndex, 8);
end;

procedure AbppChannel.InitConnection(const Connection: AbppConnection);
begin
  Assert(Assigned(Connection));
  Assert(FChannelType <> ctInit);
  FConnection := Connection;
  FTransportLimits.InitTimer;
  FProfile.AddChannel(self);
end;

procedure AbppChannel.SysLock;
begin
  Assert(Assigned(FProfile));
  Assert(Assigned(FProfile.System));
  FProfile.System.Lock;
end;

procedure AbppChannel.SysUnlock;
begin
  FProfile.System.Unlock;
end;

procedure AbppChannel.AddOutbound(const Msg: TbppMessage);
begin
  Assert(Assigned(Msg));
  Assert(Msg.State = msInit);
  SysLock;
  try
    Msg.SetDestinationID(FChannelID);
    Msg.SetState(msOutbound);
    Msg.AddReference;
    FOutbound.AppendItem(Msg);
  finally
    SysUnlock;
  end;
end;

function AbppChannel.AddOutboundMessage(const Header: TbppMessageHeader;
    const Payload: String): TbppMessage;
begin
  // Create outbound message with a reference on behalf of the caller.
  // The caller must release the reference.
  Result := TbppMessage.CreateEx(Header, Payload);
  Result.AddReference;
  AddOutbound(Result);
end;

procedure AbppChannel.SendControlMessage(const Payload: String);
var Hdr : TbppMessageHeader;
begin
  bppInitControlMessageHeader(Hdr);
  AddOutboundMessage(Hdr, Payload).ReleaseReference;
end;

function AbppChannel.SendRequestMessage(const Payload: String): TbppMessage;
var Hdr : TbppMessageHeader;
begin
  bppInitRequestMessageHeader(Hdr);
  Result := AddOutboundMessage(Hdr, Payload);
end;

procedure AbppChannel.SendRequestMessage(const Msg: TbppMessage);
begin
  Assert(Assigned(Msg));
  bppInitRequestMessageHeader(Msg.FHeader);
  AddOutbound(Msg);
end;

procedure AbppChannel.SendResponseMessage(const RequestHeader: TbppMessageHeader;
    const Payload: String; const Success: Boolean);
var Hdr : TbppMessageHeader;
begin
  bppInitResponseMessageHeader(Hdr, RequestHeader, Success);
  AddOutboundMessage(Hdr, Payload).ReleaseReference;
end;

procedure AbppChannel.SendBroadcastMessage(const Payload: String);
var Hdr : TbppMessageHeader;
begin
  bppInitBroadcastMessageHeader(Hdr);
  AddOutboundMessage(Hdr, Payload).ReleaseReference;
end;

procedure AbppChannel.ForwardBroadcastMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  AddOutboundMessage(Header, Payload).ReleaseReference;
end;

procedure AbppChannel.SendRoutedMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  AddOutboundMessage(Header, Payload).ReleaseReference;
end;

function AbppChannel.CanSendFrame: Boolean;
begin
  Result := (FOutbound.Count > 0) and FTransportLimits.CanSendFrame;
end;

function AbppChannel.SendFrame(var Size: Integer): Boolean;
var M : TbppMessage;
    L : Integer;
    N : Integer;
    P : Integer;
    S : String;
    F : Boolean;
begin
  // Get oldest outbound message
  L := FOutbound.Count;
  if L = 0 then
    begin
      Size := 0;
      Result := False;
      exit;
    end;
  M := TbppMessage(FOutbound[0]);
  // Set state
  if M.State = msOutbound then
    M.SetState(msFraming);
  // Get payload
  P := MinI(MinI(FTransportLimits.PayloadSizeLimit,
      FConnection.TransportLimits.PayloadSizeLimit),
      FConnection.FSystem.TransportLimits.PayloadSizeLimit);
  if P < BPP_MSG_MinPayloadLimit then
    P := BPP_MSG_MinPayloadLimit;
  L := Length(M.Payload);
  N := L - M.SendPosition;
  F := N <= P;
  if F then
    begin
      if M.FHeader.MsgClass in BPP_MC_DirectSet then
        M.FHeader.ClassParam := BPP_CP_FinalFrag;
      S := CopyFrom(M.Payload, M.SendPosition + 1);
      M.FSendPosition := L;
      Size := N;
    end
  else
    begin
      if M.FHeader.MsgClass in BPP_MC_DirectSet then
        M.FHeader.ClassParam := BPP_CP_NonFinalFrag
      else
        begin
          // Truncate network message
          M.FHeader.PayloadSizeInd := BPP_MSG_PayloadTruncIndicator;
          F := True;
        end;
      S := Copy(M.Payload, M.SendPosition + 1, P);
      Inc(M.FSendPosition, P);
      Size := P;
    end;
  Inc(Size, BPP_MSG_HeaderSize + BPP_MSG_TrailerSize);
  // Send frame
  FConnection.DoSendFrame(M.FHeader, S);
  FTransportLimits.NotifyFrameSent(Size);
  if F then
    begin
      M.SetState(msSent);
      // Remove message from outbound queue
      FOutbound.Delete(0);
      // Set message state
      if M.FHeader.MsgClass = BPP_MC_Request then
        begin
          M.SetState(msResponsePending);
          FRequests.AppendItem(M);
        end
      else
        begin
          M.SetState(msFinSuccess);
          M.ReleaseReference;
        end;
    end;
  Result := True;
end;

procedure AbppChannel.ApplyTimeOuts(const TickCount: LongWord);
begin
  FOutbound.ApplyTimeOuts(TickCount);
  FRequests.ApplyTimeOuts(TickCount);
end;

procedure AbppChannel.HandleControlMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
end;

procedure AbppChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
end;

procedure AbppChannel.HandleResponseMessage(const RequestMessage: TbppMessage;
    const Header: TbppMessageHeader; const Payload: String);
begin
end;

function AbppChannel.GetBroadcastMask(const Header: TbppMessageHeader;
    const Payload: String): String;
begin
  Result := '';
end;

function AbppChannel.MatchChannelMask(const ChannelMask: String): Boolean;
begin
  Result := True;
end;

procedure AbppChannel.ChannelHandleResponseMessage(const Header: TbppMessageHeader;
    const Payload: String);
var I : Integer;
    M : TbppMessage;
begin
  // Find request message
  I := FRequests.LocateMessageByID(Header.MessageID, M);
  if I < 0 then
    exit;
  // Handle response
  M.SetState(msResponded);
  M.HandleResponseMessage(Header, Payload);
  HandleResponseMessage(M, Header, Payload);
  M.SetState(msFinSuccess);
  // Remove request 
  FRequests.Delete(I);
  M.ReleaseReference;
end;

procedure AbppChannel.ChannelHandleBroadcastMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  Assert(Assigned(FProfile));
  FProfile.HandleBroadcastMessage(self, GetBroadcastMask(Header, Payload),
      Header, Payload);
end;



{                                                                              }
{ TbppChannelList                                                              }
{                                                                              }
constructor TbppChannelList.Create(const IsItemOwner: Boolean);
begin
  inherited CreateEx(nil, nil, IsItemOwner, False, True, ddAccept);
end;

function TbppChannelList.ChannelCount: Integer;
begin
  Result := FValues.Count;
end;

function TbppChannelList.GetChannelByID(const ID: String): AbppChannel;
begin
  Result := AbppChannel(GetItem(ID));
end;

function TbppChannelList.GetChannelByIndex(const Idx: Integer): AbppChannel;
begin
  Result := AbppChannel(GetItemByIndex(Idx));
end;

procedure TbppChannelList.ApplyTimeOuts(const TickCount: LongWord);
var I : Integer;
begin
  For I := 0 to FValues.Count - 1 do
    AbppChannel(FValues[I]).ApplyTimeOuts(TickCount);
end;

function TbppChannelList.GetReadyToSendChannel: AbppChannel;
var I, J, P, L : Integer;
    C : AbppChannel;
begin
  // Find ready channel with highest priority on a round-robin basis
  J := FSendChannelIdx;
  L := Count;
  P := -1;
  Result := nil;
  For I := 0 to L - 1 do
    begin
      if J >= L then
        J := 0;
      C := AbppChannel(GetItemByIndex(J));
      Inc(J);
      if C.CanSendFrame then
        if not Assigned(Result) or (C.SendPriority > P) then
          begin
            Result := C;
            P := C.SendPriority;
            FSendChannelIdx := J;
          end;
    end;
end;



{                                                                              }
{ TbppControlChannelRequestMessage                                             }
{                                                                              }
type
  TbppControlChannelResponseType = (ccrspUnknown, ccrspOk, ccrspError);
  TbppControlChannelRequestMessage = class(TbppMessage)
  protected
    FControlChannel : TbppControlChannel;
    FResponseType   : TbppControlChannelResponseType;
    FErrorReason    : String;
    FErrorMessage   : String;

    procedure HandleResponseMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
    procedure HandleOk(const ChannelID, Param: String); virtual;
    procedure HandleError(const Reason, ErrorMsg: String); virtual;

  public
    constructor Create(const ControlChannel: TbppControlChannel;
                const Command, Param1, Param2: String);

    property  ResponseType: TbppControlChannelResponseType read FResponseType;
    property  ErrorReason: String read FErrorReason;
    property  ErrorMessage: String read FErrorMessage;
  end;

constructor TbppControlChannelRequestMessage.Create(
    const ControlChannel: TbppControlChannel;
    const Command, Param1, Param2: String);
begin
  inherited Create;
  FControlChannel := ControlChannel;
  FPayload := bppEncodeControlChannelMessage(Command, Param1, Param2);
end;

procedure TbppControlChannelRequestMessage.HandleResponseMessage(
    const Header: TbppMessageHeader; const Payload: String);
var C, F, G : String;
begin
  bppDecodeControlChannelMessage(Payload, C, F, G);
  if StrEqualNoCase(C, BPP_CC_RSP_OK) then // success
    begin
      FResponseType := ccrspOk;
      HandleOk(F, G);
    end else
  if StrEqualNoCase(C, BPP_CC_RSP_ERROR) then // failure
    begin
      FResponseType := ccrspError;
      FErrorReason := F;
      FErrorMessage := G;
      HandleError(F, G);
    end
  else // unknown response
    begin
      FResponseType := ccrspUnknown;
      HandleError('', '');
    end;
end;

procedure TbppControlChannelRequestMessage.HandleOk(const ChannelID,
    Param: String);
begin
end;

procedure TbppControlChannelRequestMessage.HandleError(const Reason,
    ErrorMsg: String);
begin
end;



{                                                                              }
{ TbppControlChannelJoinRequest                                                }
{                                                                              }
type
  TbppControlChannelJoinRequest = class(TbppControlChannelRequestMessage)
  protected
    FName   : String;
    FParam  : String;
    FJoined : AbppChannel;
    procedure HandleOk(const ChannelID, Param: String); override;
  public
    constructor Create(const ControlChannel: TbppControlChannel;
                const Name, Param: String);
    property  JoinedChannel: AbppChannel read FJoined;
  end;

constructor TbppControlChannelJoinRequest.Create(
    const ControlChannel: TbppControlChannel; const Name, Param: String);
begin
  inherited Create(ControlChannel, BPP_CC_REQ_JOIN, Name, Param);
  FName := Name;
  FParam := Param;
end;

procedure TbppControlChannelJoinRequest.HandleOk(const ChannelID, Param: String);
var Prof : AbppProfile;
    I    : String;
begin
  // Join outbound channel
  FJoined := nil;
  Prof := FControlChannel.Connection.System.GetProfile(FName);
  if not Assigned(Prof) then
    exit;
  FJoined := Prof.CreateChannel(Param, I);
  FJoined.InitChannel(ctOutbound, HexToLongWord(ChannelID));
  FControlChannel.Connection.AddChannel(FJoined);
end;



{                                                                              }
{ TbppControlChannelLeaveRequest                                               }
{                                                                              }
type
  TbppControlChannelLeaveRequest = class(TbppControlChannelRequestMessage)
  protected
    FChannelID : String;
    procedure HandleOk(const ChannelID, Param: String); override;
  public
    constructor Create(const ControlChannel: TbppControlChannel;
                const ChannelID: String);
  end;

constructor TbppControlChannelLeaveRequest.Create(
    const ControlChannel: TbppControlChannel; const ChannelID: String);
begin
  inherited Create(ControlChannel, BPP_CC_REQ_LEAVE, ChannelID, '');
  FChannelID := ChannelID;
end;

procedure TbppControlChannelLeaveRequest.HandleOk(const ChannelID, Param: String);
begin
  // Leave outbound channel
  FControlChannel.Connection.RemoveChannel(ChannelID);
end;



{                                                                              }
{ TbppControlChannel                                                           }
{                                                                              }
constructor TbppControlChannel.Create(const Profile: AbppProfile);
begin
  inherited Create(Profile);
  FChannelType := ctControl;
  FChannelIndex := BPP_ControlChannelIndex;
//  FChannelID := BPP_ControlChannelID;
  FChannelIDStr := BPP_ControlChannelIDStr;
  FSendPriority := bppChannelPriorityCritical;
end;

{ Control messages                                                             }
procedure TbppControlChannel.HandleControlMessage(const Header: TbppMessageHeader;
    const Payload: String);
var C, F, G : String;
    I       : Int64;
    Chan    : AbppChannel;
begin
  // Decode message
  bppDecodeControlChannelMessage(Payload, C, F, G);
  // Decode channel id
  F := bppDecodeControlChannelID(F);
  if F = '' then
    exit;
  // Get channel
  Chan := Connection.GetChannelByIDStr(F);
  if not Assigned(Chan) then
    exit;
  if StrEqualNoCase(C, BPP_CC_CMD_LIMIT_FRAME) then
    Chan.TransportLimits.PayloadSizeLimit := StrToIntDef(G, 0) else
  if StrEqualNoCase(C, BPP_CC_CMD_LIMIT_CPS) then
    begin
      // Limit bandwidth
      I := StrToIntDef(G, -1);
      if (I >= 0) and (I <= $7FFFFFFF) then
        Chan.TransportLimits.SendLimitCPS := I
      else
        Chan.TransportLimits.SendLimitCPS := -1;
    end else
  if StrEqualNoCase(C, BPP_CC_CMD_LIMIT_FPS) then
    begin
      // Limit frame rate
      I := StrToIntDef(G, -1);
      if (I >= 0) and (I <= $7FFFFFFF) then
        Chan.TransportLimits.SendLimitFPS := I
      else
        Chan.TransportLimits.SendLimitFPS := -1;
    end;
end;

procedure TbppControlChannel.SendLimitFrameControl(const ChannelID: String;
    const Size: LongWord);
begin
  SendControlMessage(bppEncodeControlChannelMessage(
      BPP_CC_CMD_LIMIT_FRAME, '#' + ChannelID, LongWordToStr(Size)));
end;

procedure TbppControlChannel.SendLimitCPSControl(const ChannelID: String;
    const CPS: Integer);
begin
  SendControlMessage(bppEncodeControlChannelMessage(
      BPP_CC_CMD_LIMIT_FRAME, '#' + ChannelID, IntToStr(CPS)));
end;

procedure TbppControlChannel.SendLimitFPSControl(const ChannelID: String;
    const FPS: Integer);
begin
  SendControlMessage(bppEncodeControlChannelMessage(
      BPP_CC_CMD_LIMIT_FRAME, '#' + ChannelID, IntToStr(FPS)));
end;

{ Incoming requests                                                            }
procedure TbppControlChannel.SendErrorResponse(const RequestHeader: TbppMessageHeader;
    const ErrorType, ErrorMessage: String);
begin
  SendResponseMessage(RequestHeader, bppEncodeControlChannelMessage(
      BPP_CC_RSP_ERROR, ErrorType, ErrorMessage), False);
end;

procedure TbppControlChannel.SendChannelOkResponse(
    const RequestHeader: TbppMessageHeader;
    const Channel: AbppChannel; const ProfileParam: String);
begin
  Assert(Assigned(Channel));
  SendResponseMessage(RequestHeader, bppEncodeControlChannelMessage(
      BPP_CC_RSP_OK, '#' + Channel.ChannelIDStr, ProfileParam), True);
end;

procedure TbppControlChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
var C, F, G : String;
    I       : String;
    Resp    : Boolean;
    Prof    : AbppProfile;
    Chan    : AbppChannel;
    J       : Integer;
begin
  Resp := False;
  try
    bppDecodeControlChannelMessage(Payload, C, F, G);
    if StrEqualNoCase(C, BPP_CC_REQ_JOIN) then
      begin
        // Join
        Prof := Connection.System.GetProfile(F);
        if not Assigned(Prof) then
          SendErrorResponse(Header, BPP_CC_ERR_NotFound, '')
        else
          begin
            I := '';
            Chan := Prof.CreateChannel(G, I);
            Chan.InitChannel(ctInbound, Connection.AllocChannelInIndex);
            Connection.AddChannel(Chan);
            SendChannelOKResponse(Header, Chan, I);
          end;
        Resp := True;
      end else
    if StrEqualNoCase(C, BPP_CC_REQ_LEAVE) then
      begin
        // Leave
        F := bppDecodeControlChannelID(F);
        if F <> '' then
          begin
            Chan := Connection.GetChannelByIDStr(F);
            if Assigned(Chan) and (Chan.ChannelType <> ctInbound) then
              Chan := nil;
          end
        else
          Chan := nil;
        if not Assigned(Chan) then
          SendErrorResponse(Header, BPP_CC_ERR_NotFound, '')
        else
          begin
            Connection.RemoveChannel(F);
            SendChannelOKResponse(Header, Chan, '');
          end;
        Resp := True;
      end else
    // List
    if StrEqualNoCase(C, BPP_CC_REQ_LIST_PROFILES) then
      begin
        I := '';
        For J := 0 to FProfile.System.FProfiles.Count - 1 do
          I := I + FProfile.System.FProfiles.GetKeyByIndex(J) + #13#10;
        SendResponseMessage(Header, I, True);
      end else
    if StrEqualNoCase(C, BPP_CC_REQ_LIST_CHANNELS) then
      begin
      end else
    if StrEqualNoCase(C, BPP_CC_REQ_LIST_NODES) then
      begin
      end
    else
      // Unrecognised command
      SendErrorResponse(Header, BPP_CC_ERR_Invalid, '');
  except
    on E : Exception do
      if not Resp then
        SendErrorResponse(Header, BPP_CC_ERR_Error, E.Message);
  end;
end;

{ Outgoing requests                                                            }
function TbppControlChannel.SendJoinRequest(const Name, Param: String): TbppMessage;
begin
  Result := TbppControlChannelJoinRequest.Create(self, Name, Param);
  SendRequestMessage(Result);
  Result.AddReference;
end;

function TbppControlChannel.SendLeaveRequest(const ChannelID: String): TbppMessage;
begin
  Assert(Length(ChannelID) = 8);
  Result := TbppControlChannelLeaveRequest.Create(self, ChannelID);
  SendRequestMessage(Result);
  Result.AddReference;
end;



{                                                                              }
{ TbppControlChannelProfile                                                    }
{                                                                              }
type
  TbppControlChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
  end;

function TbppControlChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppControlChannel.Create(self);
end;



{                                                                              }
{ AbppConnection                                                               }
{                                                                              }
constructor AbppConnection.Create(const Initiator: Boolean);
begin
  inherited Create;
  FInitiator := Initiator;
  FTransportLimits := TbppTransportLimits.Create;
  FChannels := TbppChannelList.Create(True);
end;

destructor AbppConnection.Destroy;
begin
  FreeAndNil(FChannels);
  FreeAndNil(FTransportLimits);
  inherited Destroy;
end;

procedure AbppConnection.InitConnection(const System: AbppSystem);
begin
  Assert(Assigned(System));
  FSystem := System;
  bppInitSequenceCounter(FSeqCounterIn);
  bppInitSequenceCounter(FSeqCounterOut);
  FPartialIn := False;
  if FInitiator then
    FChannelsInIdx := 1
  else
    FChannelsInIdx := 2;
  FTransportLimits.InitTimer;
  // Add control channel
  FControlChannel := System.CreateControlChannel;
  FControlChannel.InitChannel(ctControl, BPP_ControlChannelIndex);
  AddChannel(FControlChannel);
end;

procedure AbppConnection.SysLock;
begin
  Assert(Assigned(FSystem));
  FSystem.Lock;
end;

procedure AbppConnection.SysUnlock;
begin
  FSystem.Unlock;
end;

function AbppConnection.AllocChannelInIndex: LongWord;
begin
  Result := FChannelsInIdx;
  Inc(FChannelsInIdx, 2);
  if FChannelsInIdx = $80000000 then
    FChannelsInIdx := $00000002 else
  if FChannelsInIdx = $80000001 then
    FChannelsInIdx := $00000001;
end;

procedure AbppConnection.AddChannel(const Channel: AbppChannel);
begin
  Assert(Assigned(Channel));
  if Assigned(FOnInitChannel) then
    FOnInitChannel(self, Channel);
  FChannels.Add(Channel.ChannelIDStr, Channel);
  Channel.InitConnection(self);
  if Assigned(FOnAddChannel) then
    FOnAddChannel(self, Channel);
end;

function AbppConnection.GetControlChannel: TbppControlChannel;
begin
  Result := FControlChannel;
end;

function AbppConnection.GetChannelByIDStr(const ID: String): AbppChannel;
begin
  Result := FChannels.GetChannelByID(ID);
end;

function AbppConnection.GetChannelByID(const ID: TbppID): AbppChannel;
begin
  if not bppIsID8HexValid(ID.Channel.ID) then
    Result := nil
  else
    Result := AbppChannel(FChannels[bppGetID8AsString(ID.Channel.ID)]);
end;

procedure AbppConnection.RemoveChannel(const ID: String);
var C : AbppChannel;
begin
  C := FChannels.GetChannelByID(ID);
  Assert(Assigned(C));
  if Assigned(FOnRemoveChannel) then
    FOnRemoveChannel(self, C);
  FChannels.Delete(ID);
end;

procedure AbppConnection.DoSendFrame(var Header: TbppMessageHeader;
    const Payload: String);
var S : String;
    L : Integer;
begin
  // Set sequence ID
  if Header.MsgClass in [BPP_MC_Control, BPP_MC_Request] then
    begin
      bppSetID8Hex(Header.MessageID.Sequence.Counter, FSeqCounterOut);
      if Header.ClassParam = BPP_CP_FinalFrag then
        bppIncSequenceCounter(FSeqCounterOut);
    end;
  // Send
  S := bppEncodeMessageStr(Header, Payload);
  L := Length(S);
  Send(Pointer(S)^, L);
  // Notify
  FSystem.NotifyFrameSent(L);
end;

function AbppConnection.SendFrame: Boolean;
var A : AbppChannel;
    S : Integer;
begin
  // Check system limits
  Result := FSystem.CanSendFrame and FTransportLimits.CanSendFrame;
  if not Result then
    exit;
  // Find ready channel with highest priority
  A := FChannels.GetReadyToSendChannel;
  // Send frame
  if Assigned(A) then
    begin
      A.SendFrame(S);
      Result := True;
    end
  else
    Result := False;
end;

function AbppConnection.SendFrames: Boolean;
begin
  // Send as many frames as possible, return True if at least one sent
  Result := SendFrame;
  if Result then
    Repeat
    Until not SendFrame;
end;

procedure AbppConnection.ApplyTimeOuts(const TickCount: LongWord);
begin
  FChannels.ApplyTimeOuts(TickCount);
end;

procedure AbppConnection.HandleDirectMessage(const Channel: AbppChannel;
    const Header: TbppMessageHeader; const Payload: String);
begin
  Assert(Assigned(Channel));
  Case Header.MsgClass of
    BPP_MC_Control      : Channel.HandleControlMessage(Header, Payload);
    BPP_MC_Request      : Channel.HandleRequestMessage(Header, Payload);
    BPP_MC_ResponseACK,
    BPP_MC_ResponseNAK  : Channel.ChannelHandleResponseMessage(Header, Payload);
  else
    raise Ebpp.Create(BPP_ERR_InvalidMessage);
  end;
end;

procedure AbppConnection.HandleBroadcastMessage(const Header: TbppMessageHeader;
    const Payload: String);
var C : AbppChannel;
begin
  C := GetChannelByID(Header.DestinationID);
  if Assigned(C) then
    C.ChannelHandleBroadcastMessage(Header, Payload);
end;

procedure AbppConnection.HandleMessage(const Header: TbppMessageHeader;
    const Payload: String);
var Seq  : LongWord;
    PayL : String;
    Chan : AbppChannel;
begin
  SysLock;
  try
    // Direct message
    if Header.MsgClass in BPP_MC_DirectSet then
      begin
        // Sequence id
        Seq := bppGetID8Hex(Header.MessageID.Sequence.Counter);
        if Seq <> FSeqCounterIn then
          raise Ebpp.Create(BPP_ERR_OutOfSync);
        if Header.ClassParam = BPP_CP_NonFinalFrag then
          begin
            // Non-final frame
            if not FPartialIn then
              begin
                FPartialIn := True;
                FPartialPayload := nil;
              end;
            Append(FPartialPayload, Payload);
            exit;
          end;
        // Final frame
        if Header.ClassParam <> BPP_CP_FinalFrag then
          raise Ebpp.Create(BPP_ERR_InvalidMessage);
        if FPartialIn then
          begin
            FPartialIn := False;
            Append(FPartialPayload, Payload);
            PayL := StrJoin(FPartialPayload, '');
            FPartialPayload := nil;
          end
        else
          PayL := Payload;
        bppIncSequenceCounter(FSeqCounterIn);
        // Handle direct message
        Chan := GetChannelByID(Header.DestinationID);
        if Assigned(Chan) then
          HandleDirectMessage(Chan, Header, PayL);
        exit;
      end;
    // Network message
    Case Header.MsgClass of
      BPP_MC_Broadcast,
      BPP_MC_BroadcastPing    : HandleBroadcastMessage(Header, Payload);
      BPP_MC_RoutedBlind,
      BPP_MC_RoutedConfirmed,
      BPP_MC_RoutedACK,
      BPP_MC_RoutedNAK,
      BPP_MC_RoutedPing       : FSystem.HandleRoutedMessage(Header, Payload);
    else
      raise Ebpp.Create(BPP_ERR_InvalidMessage);
    end;
  finally
    SysUnlock;
  end;
end;

procedure AbppConnection.ReceiveMessage;
var Hdr : TbppMessageHeader;
    L   : Integer;
    S   : String;
    T   : Array[0..BPP_MSG_TrailerSize - 1] of Char;
begin
  // Read header
  Read(Hdr, Sizeof(Hdr));
  if not bppIsValidHeader(Hdr) then
    raise Ebpp.Create(BPP_ERR_InvalidMessage);
  // Read payload
  L := bppGetPayloadSize(Hdr);
  SetLength(S, L);
  if L > 0 then
    Read(Pointer(S)^, L);
  // Read terminator
  Read(T[0], BPP_MSG_TrailerSize);
  if not bppIsTrailerValid(T) then
    raise Ebpp.Create(BPP_ERR_InvalidMessage);
  // Handle message
  HandleMessage(Hdr, S);
end;

function AbppConnection.Join(const Name, Param: String): AbppChannel;
var M : TbppControlChannelJoinRequest;
begin
  Result := nil;
  // Request
  M := ControlChannel.SendJoinRequest(Name, Param) as TbppControlChannelJoinRequest;
  try
    // Wait for response
    While not M.IsTransportFinished do
      Wait;
    // Check response
    if M.IsTransportSuccess and (M.ResponseType = ccrspOk) then
      Result := M.JoinedChannel
    else
      raise Ebpp.Create(BPP_ERR_JoinFailed);
  finally
    M.ReleaseReference;
  end;
end;

procedure AbppConnection.Leave(const Channel: AbppChannel);
var M : TbppControlChannelLeaveRequest;
begin
  Assert(Assigned(Channel));
  // Send request
  M := ControlChannel.SendLeaveRequest(Channel.ChannelIDStr) as
      TbppControlChannelLeaveRequest;
  try
    // Wait for response
    While not M.IsTransportFinished do
      Wait;
    // Check response
    if M.IsTransportSuccess and (M.ResponseType <> ccrspOk) then
      raise Ebpp.Create(BPP_ERR_LeaveFailed);
  finally
    M.ReleaseReference;
  end;
end;



{                                                                              }
{ TbppBroadcastItem                                                            }
{                                                                              }
type
  TbppBroadcastItem = class
  protected
    FNetworkID : TbppID;
    FChannelID : TbppID;
  end;



{                                                                              }
{ AbppProfile                                                                  }
{                                                                              }
const
  MaxBroadcastCacheItems = 32768;

constructor AbppProfile.Create;
begin
  inherited Create;
  FChannels := TbppChannelList.Create(False);
  FBroadcasts := TObjectDictionary.CreateEx(nil, nil, True, True, True, ddAccept);
end;

destructor AbppProfile.Destroy;
begin
  FreeAndNil(FBroadcasts);
  FreeAndNil(FChannels);
  inherited Destroy;
end;

procedure AbppProfile.InitProfile(const System: AbppSystem);
begin
  Assert(Assigned(System));
  FSystem := System;
end;

procedure AbppProfile.AddChannel(const Channel: AbppChannel);
begin
  Assert(Assigned(Channel));
  FChannels.Add(Channel.ChannelIDStr, Channel);
end;

procedure AbppProfile.RemoveChannel(const ID: String);
begin
  FChannels.Delete(ID);
end;

procedure AbppProfile.HandleBroadcastMessage(const Channel: AbppChannel;
    const ChannelMask: String; const Header: TbppMessageHeader;
    const Payload: String);
var B : TbppBroadcastItem;
    S : String;
    I, J : Integer;
    C : AbppChannel;
    H : TbppMessageHeader;
begin
  S := bppGetID8AsString(Header.MessageID.Sequence.Counter);
  // Ignore message if it has been seen before
  if FBroadcasts.LocateItem(S, TObject(B)) >= 0 then
    exit;
  // Make space in cache
  While FBroadcasts.Count > MaxBroadcastCacheItems do
    FBroadcasts.DeleteItemByIndex(0);
  // Add cache item
  B := TbppBroadcastItem.Create;
  B.FNetworkID := Header.MessageID;
  B.FChannelID := Channel.FChannelID;
  FBroadcasts.Add(S, B);
  J := bppDecodeHopChar(Header.ClassParam);
  if J >= 1 then
    begin
      // Adjust hop count
      H := Header;
      H.ClassParam := bppEncodeHopChar(J - 1);
      // Forward to all except originator
      For I := 0 to FChannels.Count - 1 do
        begin
          C := AbppChannel(FChannels.GetItemByIndex(I));
          if (C <> Channel) and C.MatchChannelMask(ChannelMask) then
            C.ForwardBroadcastMessage(H, Payload);
        end;
    end;
end;

function AbppProfile.HandleRoutedMessage(const Header: TbppMessageHeader;
    const Payload: String): Boolean;
var B : TbppBroadcastItem;
    C : AbppChannel;
    S : String;
begin
  S := bppGetID8AsString(Header.DestinationID.Network.NodeID);
  // Forward on broadcast route
  if FBroadcasts.LocateItem(S, TObject(B)) >= 0 then
    begin
      C := FChannels.GetChannelByID(B.FChannelID.Chars);
      if Assigned(C) then
        C.SendRoutedMessage(Header, Payload);
      Result := True;
    end
  else
    Result := False;
end;

procedure AbppProfile.SendBroadcastMessage(const ChannelMask, Payload: String);
var I : Integer;
    C : AbppChannel;
begin
  // Forward to all
  For I := 0 to FChannels.Count - 1 do
    begin
      C := AbppChannel(FChannels.GetItemByIndex(I));
      if C.MatchChannelMask(ChannelMask) then
        C.SendBroadcastMessage(Payload);
    end;
end;



{                                                                              }
{ AbppSystem                                                                   }
{                                                                              }
constructor AbppSystem.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FTransportLimits := TbppTransportLimits.Create;
  FProfiles := TObjectDictionary.CreateEx(nil, nil, True, False, True); // owner
  FConnections := TObjectArray.Create(nil, False); // not owner
  FTransportLimits.InitTimer;
  AddProfile(':', TbppControlChannelProfile.Create);
  AddProfile('NULL', TbppNullChannelProfile.Create);
  AddProfile('ECHO', TbppEchoChannelProfile.Create);
  AddProfile('DFLT', TbppDefaultChannelProfile.Create);
  AddProfile('TIME', TbppTimeChannelProfile.Create);
  AddProfile('USER', TbppUserChannelProfile.Create);
  AddProfile('CHAT', TbppChatChannelProfile.Create);
end;

destructor AbppSystem.Destroy;
begin
  FreeAndNil(FConnections);
  FreeAndNil(FProfiles);
  FreeAndNil(FTransportLimits);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure AbppSystem.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure AbppSystem.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

function AbppSystem.CanSendFrame: Boolean;
begin
  Result := FTransportLimits.CanSendFrame;
end;

procedure AbppSystem.NotifyFrameSent(const Size: Integer);
begin
  FTransportLimits.NotifyFrameSent(Size);
end;

procedure AbppSystem.AddProfile(const Name: String; const Profile: AbppProfile);
begin
  Assert(Assigned(Profile));
  Lock;
  try
    Profile.InitProfile(self);
    FProfiles[Name] := Profile;
  finally
    Unlock;
  end;
end;

function AbppSystem.GetProfile(const Name: String): AbppProfile;
begin
  Result := AbppProfile(FProfiles[Name]);
end;

function AbppSystem.CreateChannelByProfile(const Name, Param: String;
    var InitParam: String): AbppChannel;
var P : AbppProfile;
begin
  P := AbppProfile(FProfiles[Name]);
  if Assigned(P) then
    Result := P.CreateChannel(Param, InitParam)
  else
    Result := nil;
end;

function AbppSystem.CreateControlChannel: TbppControlChannel;
var I : String;
begin
  Result := CreateChannelByProfile(':', '', I) as TbppControlChannel;
end;

function AbppSystem.GetConnectionCount: Integer;
begin
  Result := FConnections.Count;
end;

function AbppSystem.GetConnection(const Idx: Integer): AbppConnection;
begin
  Result := AbppConnection(FConnections[Idx]);
end;

procedure AbppSystem.AddConnection(const Connection: AbppConnection);
begin
  Assert(Assigned(Connection));
  Lock;
  try
    FConnections.AppendItem(Connection);
    Connection.InitConnection(self);
  finally
    Unlock;
  end;
end;

procedure AbppSystem.RemoveConnection(const Connection: AbppConnection);
begin
  Assert(Assigned(Connection));
  Lock;
  try
    FConnections.DeleteValue(Connection);
  finally
    Unlock;
  end;
end;

procedure AbppSystem.HandleRoutedMessage(const Header: TbppMessageHeader;
    const Payload: String);
var S : String;
    I : Integer;
begin
  // Pass on to profiles for routing
  S := bppGetID8AsString(Header.DestinationID.Network.NodeID);
  For I := 0 to FProfiles.Count - 1 do
    if AbppProfile(FProfiles.GetItemByIndex(I)).HandleRoutedMessage(
        Header, Payload) then
      exit;
end;

function AbppSystem.SendFrames: Boolean;
var I : Integer;
begin
  Lock;
  try
    // Send frames on all connections
    Result := False;
    For I := 0 to FConnections.Count - 1 do
      if AbppConnection(FConnections[I]).SendFrames then
        Result := True;
  finally
    Unlock;
  end;
end;

procedure AbppSystem.ApplyTimeOuts;
var I : Integer;
    T : LongWord;
begin
  Lock;
  try
    T := GetTickCount;
    For I := 0 to FConnections.Count - 1 do
      AbppConnection(FConnections[I]).ApplyTimeOuts(T);
  finally
    Unlock;
  end;
end;



end.

