{                                                                              }
{            Blaze Peering Protocol Control Channel Utilities v0.01            }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{ Description:                                                                 }
{   Constants, structures and helper functions for the Blaze Peering           }
{   Protocol (BPP).                                                            }
{                                                                              }
{ Revision history:                                                            }
{   04/08/2003  0.01  Initial version.                                         }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cBlazeUtilsControlChannel;

interface

uses
  { Blaze }
  cBlazeUtilsMessages;



{                                                                              }
{ Control channel                                                              }
{                                                                              }
const
  BPP_ControlChannelIndex = 0;
  BPP_ControlChannelIDStr = '00000000';
  BPP_ControlChannelID    : TbppID8 = BPP_ControlChannelIDStr;

procedure bppHeaderSetDestinationControlChannel(var Hdr: TbppMessageHeader);



{                                                                              }
{ Distance                                                                     }
{                                                                              }
type
  TbppDistance = (
      DistanceUndefined,
      DistanceOpen,
      DistanceProxy,
      DistanceHost,
      DistanceVia,
      DistanceDistant,
      DistanceHops,
      DistanceNear);

const
  DistanceOpenSet       = [DistanceOpen, DistanceProxy, DistanceVia];
  DistanceClosedSet     = [DistanceHost, DistanceDistant, DistanceHops];
  DistancePeerSet       = [DistanceOpen, DistanceProxy, DistanceHost];
  DistanceNodeSet       = [DistanceVia, DistanceDistant, DistanceHops];

  DistancePeerClosedSet = DistancePeerSet * DistanceClosedSet;
  DistancePeerOpenSet   = DistancePeerSet * DistanceOpenSet;
  DistanceNodeClosedSet = DistanceNodeSet * DistanceClosedSet;
  DistanceNodeOpenSet   = DistanceNodeSet * DistanceOpenSet;

const
  BPP_DISTANCE_Open    = 'OPEN';
  BPP_DISTANCE_Proxy   = 'PROX';
  BPP_DISTANCE_Host    = 'HOST';
  BPP_DISTANCE_Via     = 'VIA';
  BPP_DISTANCE_Distant = 'HOP*';
  BPP_DISTANCE_Hops    = 'HOP';
  BPP_DISTANCE_Near    = 'NEAR';

function  bppEncodeDistanceStr(const Distance: TbppDistance;
          const Hops: Byte): String;
procedure bppDecodeDistanceStr(const S: String; var Distance: TbppDistance;
          var Hops: Byte);



{                                                                              }
{ Profile information                                                          }
{                                                                              }
type
  TbppProfileInformation = packed record
    Name     : String;
    Distance : TbppDistance;
    Hops     : Byte;
    NodeID   : TbppID8;
  end;

function  bppEncodeProfileInformation(const Info: TbppProfileInformation): String;
procedure bppDecodeProfileInformation(const S: String;
          var Info: TbppProfileInformation);



{                                                                              }
{ Channel information                                                          }
{                                                                              }
type
  TbppChannelInformation = packed record
    Profile   : String;
    ChannelID : TbppID;
    Name      : String;
    Distance  : TbppDistance;
    Hops      : Byte;
    NodeID    : TbppID;
    Bandwidth : Integer;
  end;



{                                                                              }
{ Node information                                                             }
{                                                                              }
type
  TbppNodeInformation = packed record
    NodeID    : TbppID;
    Name      : String;
    Distance  : TbppDistance;
    Hops      : Byte;
    IP        : Array[0..3] of Byte;
    TCPPort   : Word;
    UDPPort   : Word;
    DNSName   : String;
    NodeType  : Byte;
    Bandwidth : Integer;
    UpSince   : TDateTime;
    TimeStamp : TDateTime;
  end;

function  bppEncodeNodeAttributes(const Info: TbppNodeInformation): String;



{                                                                              }
{ Control channel messages                                                     }
{                                                                              }
const
  BPP_CC_CMD_LIMIT_FRAME        = 'LIMIT_FRAME';
  BPP_CC_CMD_LIMIT_CPS          = 'LIMIT_CPS';
  BPP_CC_CMD_LIMIT_FPS          = 'LIMIT_FPS';
  BPP_CC_CMD_I_AM               = 'I_AM';
  BPP_CC_CMD_ADVERTISE_PROFILES = 'ADVERTISE_PROFILES';
  BPP_CC_CMD_ADVERTISE_CHANNELS = 'ADVERTISE_CHANNELS';
  BPP_CC_CMD_ADVERTISE_NODES    = 'ADVERTISE_NODES';
  BPP_CC_CMD_IDENTIFY           = 'IDENTIFY';
  BPP_CC_CMD_INVITE             = 'INVITE';
  BPP_CC_CMD_PEER_WITH          = 'PEER_WITH';

  BPP_CC_REQ_JOIN               = 'JOIN';
  BPP_CC_REQ_JOIN_NODE          = 'JOIN_NODE';
  BPP_CC_REQ_LEAVE              = 'LEAVE';
  BPP_CC_REQ_LIST_PROFILES      = 'LIST_PROFILES';
  BPP_CC_REQ_LIST_CHANNELS      = 'LIST_CHANNELS';
  BPP_CC_REQ_LIST_NODES         = 'LIST_NODES';
  BPP_CC_REQ_AUTHENTICATE       = 'AUTHENTICATE';

  BPP_CC_RSP_OK                 = 'OK';
  BPP_CC_RSP_ERROR              = 'ER';

procedure bppControlChannelDecodeMessage(const S: String;
          var Identifier, Parameters: String);
procedure bppDecodeControlChannelMessage(const Msg: String;
          var Command, Param1, Param2: String);
function  bppEncodeControlChannelMessage(
          const Command, Param1, Param2: String): String;
function  bppDecodeControlChannelID(const S: String): String;



{                                                                              }
{ Control channel error response                                               }
{                                                                              }
const
  BPP_CC_ERRCLASS_Message    = 'MSG';
  BPP_CC_ERRCLASS_Command    = 'CMD';
  BPP_CC_ERRCLASS_Parameter  = 'PAR';
  BPP_CC_ERRCLASS_Profile    = 'PRF';
  BPP_CC_ERRCLASS_Channel    = 'CHN';
  BPP_CC_ERRCLASS_Node       = 'NDE';
  BPP_CC_ERRCLASS_Connection = 'CON';
  BPP_CC_ERRCLASS_System     = 'SYS';
  BPP_CC_ERRCLASS_Network    = 'NET';
  BPP_CC_ERRCLASS_Internal   = 'INT';
  BPP_CC_ERRCLASS_User       = 'USR';
  BPP_CC_ERRCLASS_Peer       = 'YOU';

  BPP_CC_ERR_Error        = 'ERROR';
  BPP_CC_ERR_Invalid      = 'INVALID';
  BPP_CC_ERR_NotFound     = 'NOT_FOUND';
  BPP_CC_ERR_NotAllowed   = 'NOT_ALLOWED';
  BPP_CC_ERR_NotLocal     = 'NOT_LOCAL';
  BPP_CC_ERR_Unreachable  = 'UNREACHABLE';
  BPP_CC_ERR_AccessDenied = 'ACCESS_DENIED';
  BPP_CC_ERR_NotSupported = 'NOT_SUPPORTED';
  BPP_CC_ERR_Blocked      = 'BLOCKED';
  BPP_CC_ERR_Abusive      = 'ABUSIVE';
  BPP_CC_ERR_Failure      = 'FAILURE';



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,
  cDateTime;



{                                                                              }
{ Control channel                                                              }
{                                                                              }
procedure bppHeaderSetDestinationControlChannel(var Hdr: TbppMessageHeader);
begin
  bppInitChannelID(Hdr.DestinationID.Channel, BPP_ControlChannelIndex);
end;



{                                                                              }
{ Distance                                                                     }
{                                                                              }
function bppEncodeDistanceStr(const Distance: TbppDistance;
    const Hops: Byte): String;
begin
  Case Distance of
    DistanceOpen    : Result := BPP_DISTANCE_Open;
    DistanceProxy   : Result := BPP_DISTANCE_Proxy;
    DistanceHost    : Result := BPP_DISTANCE_Host;
    DistanceVia     : Result := BPP_DISTANCE_Via + bppEncodeHopChar(Hops);
    DistanceDistant : Result := BPP_DISTANCE_Distant;
    DistanceHops    : Result := BPP_DISTANCE_Hops + bppEncodeHopChar(Hops);
    DistanceNear    : Result := BPP_DISTANCE_Near;
  else
    Result := '';
  end;
end;

procedure bppDecodeDistanceStr(const S: String; var Distance: TbppDistance;
    var Hops: Byte);
begin
  Hops := 0;
  if StrEqualNoCase(S, BPP_DISTANCE_Open) then
    Distance := DistanceOpen else
  if StrEqualNoCase(S, BPP_DISTANCE_Proxy) then
    Distance := DistanceProxy else
  if StrEqualNoCase(S, BPP_DISTANCE_Host) then
    Distance := DistanceHost else
  if StrMatchLeft(S, BPP_DISTANCE_Via, False) then
    Distance := DistanceVia else
  if StrEqualNoCase(S, BPP_DISTANCE_Distant) then
    Distance := DistanceDistant else
  if StrMatchLeft(S, BPP_DISTANCE_Hops, False) then
    Distance := DistanceHops else
  if StrEqualNoCase(S, BPP_DISTANCE_Near) then
    Distance := DistanceNear
  else
    Distance := DistanceUndefined;
  if (Distance in [DistanceVia, DistanceHops]) and
     (Length(S) > 3) then
    Hops := bppDecodeHopChar(S[4]);
end;



{                                                                              }
{ Profile information                                                          }
{                                                                              }
function bppEncodeProfileInformation(const Info: TbppProfileInformation): String;
begin
  Result := Info.Name + ':' +
            bppEncodeDistanceStr(Info.Distance, Info.Hops);
  if Info.Distance in DistanceNodeClosedSet then
    Result := Result + ':' + bppGetID8AsString(Info.NodeID);
end;

procedure bppDecodeProfileInformation(const S: String;
    var Info: TbppProfileInformation);
var T, U, V : String;
begin
  StrSplitAtChar(S, ':', Info.Name, T, True);
  StrSplitAtChar(T, ':', U, V, True);
  bppDecodeDistanceStr(U, Info.Distance, Info.Hops);
  bppSetID8AsString(Info.NodeID, V);
end;



{                                                                              }
{ Channel information                                                          }
{                                                                              }



{                                                                              }
{ Node information                                                             }
{                                                                              }
function bppEncodeNodeAttributes(const Info: TbppNodeInformation): String;
begin
  Result := '';
  With Info do
    begin
      if not (IP[0] in [0, 255]) then
        Result := Result + ';IPA=' + IntToStr(IP[0]) + '.' + IntToStr(IP[1]) +
            '.' + IntToStr(IP[2]) + '.' + IntToStr(IP[3]);
      if TCPPort <> 0 then
        Result := Result + ';TCP=' + IntToStr(TCPPort);
      if UDPPort <> 0 then
        Result := Result + ';UDP=' + IntToStr(UDPPort);
      if DNSName <> '' then
        Result := Result + ';DNS=' + DNSName;
      if Bandwidth > 0 then
        Result := Result + ';BPS=' + IntToStr(Bandwidth);
      if UpSince <> 0.0 then
        Result := Result + ';UPT=' + IntToStr(DiffMinutes(UpSince, Now));
      if TimeStamp <> 0.0 then
        Result := Result + ';AGE=' + IntToStr(DiffMinutes(TimeStamp, Now));
    end;
end;



{                                                                              }
{ Control channel                                                              }
{                                                                              }
procedure bppControlChannelDecodeMessage(const S: String;
    var Identifier, Parameters: String);
begin
  StrSplitAtChar(S, ':', Identifier, Parameters, True);
end;

procedure bppDecodeControlChannelMessage(const Msg: String;
    var Command, Param1, Param2: String);
var Params : String;
begin
  StrSplitAt(Msg, ':', Command, Params, True, True);
  StrSplitAt(Params, ':', Param1, Param2, True, True);
end;

function bppEncodeControlChannelMessage(
    const Command, Param1, Param2: String): String;
begin
  Result := Command + ':' + Param1;
  if Param2 <> '' then
    Result := Result + ':' + Param2;
end;

function bppDecodeControlChannelID(const S: String): String;
begin
  if (Length(S) <> 9) or (S[1] <> '#') then
    Result := ''
  else
    Result := CopyFrom(S, 2);
end;



end.
