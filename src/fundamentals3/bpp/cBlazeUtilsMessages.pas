{                                                                              }
{                Blaze Peering Protocol Message Utilities v0.04                }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{ Description:                                                                 }
{   Constants, structures and helper functions for BPP messages.               }
{                                                                              }
{ Revision history:                                                            }
{   03/05/2003  0.01  Initial version.                                         }
{   05/05/2003  0.02  Revision.                                                }
{   01/08/2003  0.03  Protocol changes.                                        }
{   04/08/2003  0.04  Revision.                                                }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cBlazeUtilsMessages;

interface



{                                                                              }
{ Constants                                                                    }
{                                                                              }
const
  BPP_HexCharSet      = ['0'..'9', 'A'..'F'];
  BPP_HexChars        = '0123456789ABCDEF';
  BPP_AlphaNumCharSet = ['0'..'9', 'A'..'Z', 'a'..'z'];
  BPP_AlphaNumChars   = '0123456789' +
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                        'abcdefghijklmnopqrstuvwxyz';
  BPP_NameCharSet     = BPP_AlphaNumCharSet + ['_', '-'];
  BPP_CRLF            = #13#10;



{                                                                              }
{ Message class                                                                }
{                                                                              }

  (**************************************************************************)
  (*    '~'  Control                              [Direct]   [Channel]      *)
  (*    '>'  Request                              [Direct]   [Channel]      *)
  (*    '<'  Response (positive)                  [Direct]   [Channel]      *)
  (*    '['  Response (negative)                  [Direct]   [Channel]      *)
  (*    '*'  Broadcast                            [Network]  [Channel]      *)
  (*    '?'  Broadcast ping                       [Network]  [Channel]      *)
  (*    '^'  Routed (blind)                       [Network]  [Node]         *)
  (*    '&'  Routed (confirmed)                   [Network]  [Node]         *)
  (*    '/'  Routed ping                          [Network]  [Node]         *)
  (*    '{'  Routed circuit create                [Network]  [Node]         *)
  (*    '}'  Routed circuit destroy               [Network]  [Node]         *)
  (*    '@'  Routed confirmation (positive)       [Network]  [Node]         *)
  (*    '!'  Routed confirmation (negative)       [Network]  [Node]         *)
  (**************************************************************************)

const
  BPP_MC_Control              = '~';
  BPP_MC_Request              = '>';
  BPP_MC_ResponseACK          = '<';
  BPP_MC_ResponseNAK          = '[';
  BPP_MC_Broadcast            = '*';
  BPP_MC_BroadcastPing        = '?';
  BPP_MC_RoutedBlind          = '^';
  BPP_MC_RoutedConfirmed      = '&';
  BPP_MC_RoutedPing           = '/';
  BPP_MC_RoutedCircuitCreate  = '{';
  BPP_MC_RoutedCircuitDestroy = '{';
  BPP_MC_RoutedACK            = '@';
  BPP_MC_RoutedNAK            = '!';

const
  BPP_MC_ResponseSet           = [BPP_MC_ResponseACK,
                                  BPP_MC_ResponseNAK];
  BPP_MC_RoutedConfirmationSet = [BPP_MC_RoutedACK,
                                  BPP_MC_RoutedNAK];
  BPP_MC_RoutedSet             = [BPP_MC_RoutedBlind,
                                  BPP_MC_RoutedConfirmed,
                                  BPP_MC_RoutedPing,
                                  BPP_MC_RoutedCircuitCreate,
                                  BPP_MC_RoutedCircuitDestroy] +
                                  BPP_MC_RoutedConfirmationSet;
  BPP_MC_BroadcastSet          = [BPP_MC_Broadcast,
                                  BPP_MC_BroadcastPing];
  BPP_MC_DirectSet             = [BPP_MC_Control,
                                  BPP_MC_Request] +
                                  BPP_MC_ResponseSet;
  BPP_MC_NetworkSet            =  BPP_MC_BroadcastSet +
                                  BPP_MC_RoutedSet;
  BPP_MC_ValidSet              =  BPP_MC_DirectSet +
                                  BPP_MC_NetworkSet;

function  bppIsMessageClassResponse(const C: Char): Boolean;
function  bppIsMessageClassRoutedConfirmation(const C: Char): Boolean;
function  bppIsMessageClassRouted(const C: Char): Boolean;
function  bppIsMessageClassBroadcast(const C: Char): Boolean;
function  bppIsMessageClassDirect(const C: Char): Boolean;
function  bppIsMessageClassNetwork(const C: Char): Boolean;
function  bppIsMessageClassValid(const C: Char): Boolean;

const
  BPP_MC_ChannelSet       =  BPP_MC_DirectSet +
                             BPP_MC_BroadcastSet;
  BPP_MC_NodeSet          =  BPP_MC_RoutedSet;
  BPP_MC_RoutedConfirmSet = [BPP_MC_BroadcastPing,
                             BPP_MC_RoutedConfirmed,
                             BPP_MC_RoutedPing,
                             BPP_MC_RoutedCircuitCreate];

function  bppIsMessageClassChannel(const C: Char): Boolean;
function  bppIsMessageClassNode(const C: Char): Boolean;
function  bppIsMessageClassRoutedConfirm(const C: Char): Boolean;



{                                                                              }
{ Class parameter                                                              }
{                                                                              }
const
  BPP_CP_HopChars    = BPP_AlphaNumChars;
  BPP_CP_HopCharSet  = BPP_AlphaNumCharSet;
  BPP_CP_MaxHopCount = Length(BPP_CP_HopChars) - 1;

function  bppDecodeHopChar(const C: Char): Integer;
function  bppEncodeHopChar(const HopCount: Integer): Char;
function  bppIsHopCharValid(const C: Char): Boolean;

const
  BPP_CP_FinalFrag    = '-';
  BPP_CP_NonFinalFrag = '+';
  BPP_CP_FragCharSet  = [BPP_CP_FinalFrag, BPP_CP_NonFinalFrag];

function  bppIsFragCharValid(const C: Char): Boolean;

const
  BPP_CP_ValidSet = BPP_CP_FragCharSet + BPP_CP_HopCharSet;

function  bppIsClassParameterValid(const C: Char): Boolean;



{                                                                              }
{ ID fields                                                                    }
{                                                                              }
type
  TbppID2    = Array[0..1] of Char;
  TbppID8    = Array[0..7] of Char;
  TbppID12   = Array[0..11] of Char;
  TbppZeros3 = Array[0..2] of Char;

const
  BPP_ID_ValidSet    = BPP_AlphaNumCharSet;
  BPP_ID_HexValidSet = BPP_HexCharSet;

function  bppIsID12Valid(const ID: TbppID12): Boolean;
function  bppIsID8Valid(const ID: TbppID8): Boolean;
function  bppIsID8HexValid(const ID: TbppID8): Boolean;
procedure bppSetID8Hex(var ID: TbppID8; const Value: LongWord);
function  bppGetID8Hex(const ID: TbppID8): LongWord;
function  bppGetID8AsString(const ID: TbppID8): String;
procedure bppSetID8AsString(var ID: TbppID8; const S: String);

type
  TbppSequenceID = packed record
    IDPrefix : Char;
    Zeros    : TbppZeros3;
    Counter  : TbppID8;
  end;

const
  BPP_ID_SequenceIDPrefix         = '#';
  BPP_ID_SequenceIDCounterCharSet = BPP_HexCharSet;

procedure bppInitSequenceCounter(var Counter: LongWord);
procedure bppIncSequenceCounter(var Counter: LongWord);
function  bppIsSequenceIDValid(const ID: TbppSequenceID): Boolean;
procedure bppInitSequenceID(var ID: TbppSequenceID; const Counter: LongWord);
function  bppGetSequenceIDCounter(const ID: TbppSequenceID): LongWord;

type
  TbppChannelID = packed record
    IDPrefix : Char;
    Zeros    : TbppZeros3;
    ID       : TbppID8;
  end;

const
  BPP_ID_ChannelIDPrefix  = '#';
  BPP_ID_ChannelIDCharSet = BPP_HexCharSet;

function  bppIsChannelIDValid(const ID: TbppChannelID): Boolean;
procedure bppInitChannelID(var ID: TbppChannelID; const ChannelID: LongWord);
function  bppGetChannelID(const ID: TbppChannelID): LongWord;

type
  TbppNetworkID = packed record
    Counter   : TbppID2;
    CircuitID : TbppID2;
    NodeID    : TbppID8;
  end;

const
  BPP_ID_NetworkCounterCharSet   = BPP_AlphaNumCharSet;
  BPP_ID_CircuitCounterCharSet   = BPP_HexCharSet;
  BPP_ID_CircuitCounterChars     = BPP_HexChars;
  BPP_ID_CircuitCounterCharCount = Length(BPP_ID_CircuitCounterChars);
  BPP_ID_CircuitIDCharSet        = BPP_AlphaNumCharSet;
  BPP_ID_NodeIDCharSet           = BPP_AlphaNumCharSet;
  BPP_ID_NodeIDChars             = BPP_AlphaNumChars;
  BPP_ID_NodeIDCharCount         = Length(BPP_ID_NodeIDChars); // 62 -> ~48-bit id

function  bppIsNetworkIDValid(const ID: TbppNetworkID): Boolean;
function  bppRandomNodeIDChar: Char;
procedure bppGenerateNetworkID(var ID: TbppID8);
procedure bppInitCircuitCounter(var ID: TbppID2);
procedure bppIncreaseCircuitCounter(var ID: TbppID2);

type
  TbppID = packed record
  case Integer of
    0 : (Sequence  : TbppSequenceID);
    1 : (Channel   : TbppChannelID);
    2 : (Network   : TbppNetworkID);
    3 : (Chars     : TbppID12);
    4 : (Words     : Array[0..5] of Word);
    5 : (LongWords : Array[0..2] of LongWord);
    6 : (IDPrefix  : Char;
         VarPart   : Array[0..2] of Char;
         ID        : TbppID8);
  end;

const
  BPP_ID_Size = SizeOf(TbppID); // 12



{                                                                              }
{ Payload size                                                                 }
{                                                                              }
const
  BPP_MSG_PayloadSizeIndicator  = ':';
  BPP_MSG_PayloadTruncIndicator = '%';
  BPP_PS_ValidSet               = [BPP_MSG_PayloadSizeIndicator,
                                   BPP_MSG_PayloadTruncIndicator];

function  bppIsPayloadSizeIndicatorValid(const C: Char): Boolean;



{                                                                              }
{ Message trailer                                                              }
{                                                                              }
const
  BPP_MSG_Trailer     = BPP_CRLF;
  BPP_MSG_TrailerStr  : String = BPP_MSG_Trailer;
  BPP_MSG_TrailerSize = Length(BPP_MSG_Trailer); // 2

function  bppIsTrailerValid(const Buf): Boolean;



{                                                                              }
{ Message header                                                               }
{                                                                              }
type
  TbppMessageHeader = packed record
    MsgIndicator   : Char;
    MsgClass       : Char;
    ClassParam     : Char;
    MessageID      : TbppID;
    DestinationID  : TbppID;
    PayloadSizeInd : Char;
    PayloadSize    : Array[0..3] of Char;
    PayloadInd     : Char;
  end;

const
  BPP_MSG_MsgIndicator       = '$';
  BPP_MSG_PayloadIndicator   = '=';
  BPP_MSG_PayloadSizeCharSet = BPP_HexCharSet;
  BPP_MSG_HeaderSize         = Sizeof(TbppMessageHeader); // 33
  BPP_MSG_MinSize            = BPP_MSG_HeaderSize + BPP_MSG_TrailerSize; // 35
  BPP_MSG_DefaultFrameSize   = 512;
  BPP_MSG_DefaultPayloadSize = BPP_MSG_DefaultFrameSize - BPP_MSG_MinSize; // 477
  BPP_MSG_MinPayloadLimit    = 128;
  BPP_MSG_MinFrameLimit      = BPP_MSG_MinPayloadLimit + BPP_MSG_MinSize; // 163
  BPP_MSG_MaxPayloadSize     = $FFFF; // 65535
  BPP_MSG_MaxFrameSize       = BPP_MSG_MinSize + BPP_MSG_MaxPayloadSize; // 65570

procedure bppInitMessageHeader(var Hdr: TbppMessageHeader; const MsgClass: Char);
procedure bppInitControlMessageHeader(var Hdr: TbppMessageHeader);
procedure bppInitRequestMessageHeader(var Hdr: TbppMessageHeader);
procedure bppInitResponseMessageHeader(var Hdr: TbppMessageHeader;
          const RequestHdr: TbppMessageHeader; const Success: Boolean);
procedure bppInitBroadcastMessageHeader(var Hdr: TbppMessageHeader);
function  bppIsValidHeader(const Hdr: TbppMessageHeader): Boolean;
procedure bppSetPayloadSize(var Hdr: TbppMessageHeader; const Size: Word);
function  bppGetPayloadSize(const Hdr: TbppMessageHeader): Integer;
function  bppGetValidPayloadLimit(const Size: Integer): Integer;
function  bppEncodeMessageStr(var Hdr: TbppMessageHeader;
          const Payload: String): String;



{                                                                              }
{ Self-testing code                                                            }
{                                                                              }
procedure SelfTest;



implementation

uses
  { Fundamentals }
  cUtils,
  cStrings,
  cRandom;



{                                                                              }
{ Message class                                                                }
{                                                                              }
function bppIsMessageClassResponse(const C: Char): Boolean;
begin
  Result := C in BPP_MC_ResponseSet;
end;

function bppIsMessageClassRoutedConfirmation(const C: Char): Boolean;
begin
  Result := C in BPP_MC_RoutedConfirmationSet;
end;

function bppIsMessageClassRouted(const C: Char): Boolean;
begin
  Result := C in BPP_MC_RoutedSet;
end;

function bppIsMessageClassBroadcast(const C: Char): Boolean;
begin
  Result := C in BPP_MC_BroadcastSet;
end;

function bppIsMessageClassDirect(const C: Char): Boolean;
begin
  Result := C in BPP_MC_DirectSet;
end;

function bppIsMessageClassNetwork(const C: Char): Boolean;
begin
  Result := C in BPP_MC_NetworkSet;
end;

function bppIsMessageClassValid(const C: Char): Boolean;
begin
  Result := C in BPP_MC_ValidSet;
end;

function bppIsMessageClassChannel(const C: Char): Boolean;
begin
  Result := C in BPP_MC_ChannelSet;
end;

function bppIsMessageClassNode(const C: Char): Boolean;
begin
  Result := C in BPP_MC_NodeSet;
end;

function bppIsMessageClassRoutedConfirm(const C: Char): Boolean;
begin
  Result := C in BPP_MC_RoutedConfirmSet;
end;



{                                                                              }
{ Class parameter                                                              }
{                                                                              }
function bppDecodeHopChar(const C: Char): Integer;
begin
  Result := PosChar(C, BPP_CP_HopChars) - 1;
end;

function bppEncodeHopChar(const HopCount: Integer): Char;
var I : Integer;
begin
  if HopCount > BPP_CP_MaxHopCount then
    I := BPP_CP_MaxHopCount else
  if HopCount < 0 then
    I := 0
  else
    I := HopCount;
  Result := BPP_CP_HopChars[I + 1];
end;

function bppIsHopCharValid(const C: Char): Boolean;
begin
  Result := C in BPP_CP_HopCharSet;
end;

function bppIsFragCharValid(const C: Char): Boolean;
begin
  Result := C in BPP_CP_FragCharSet;
end;

function bppIsClassParameterValid(const C: Char): Boolean;
begin
  Result := C in BPP_CP_ValidSet;
end;



{                                                                              }
{ ID fields                                                                    }
{                                                                              }
function bppIsID12Valid(const ID: TbppID12): Boolean;
begin
  Result := StrPMatchChar(@ID, SizeOf(TbppID12), BPP_ID_ValidSet);
end;

function bppIsID8Valid(const ID: TbppID8): Boolean;
begin
  Result := StrPMatchChar(@ID, SizeOf(TbppID8), BPP_ID_ValidSet);
end;

function bppIsID8HexValid(const ID: TbppID8): Boolean;
begin
  Result := StrPMatchChar(@ID, SizeOf(TbppID8), BPP_ID_HexValidSet);
end;

procedure bppSetID8Hex(var ID: TbppID8; const Value: LongWord);
var I : Integer;
    M : LongWord;
    C : Byte;
begin
  M := $F0000000;
  C := 32;
  For I := 0 to 7 do
    begin
      Dec(C, 4);
      ID[I] := s_HexDigitsUpper[((Value and M) shr C) + 1];
      M := M shr 4;
    end;
end;

function bppGetID8Hex(const ID: TbppID8): LongWord;
var I    : Integer;
    F, C : Byte;
begin
  Result := 0;
  C := 32;
  For I := 0 to 7 do
    begin
      Dec(C, 4);
      F := HexCharValue(ID[I]);
      if F <= $0F then
        Result := Result or (LongWord(F) shl C);
    end;
end;

function bppGetID8AsString(const ID: TbppID8): String;
begin
  SetLength(Result, 8);
  Move(ID[0], Pointer(Result)^, 8);
end;

procedure bppSetID8AsString(var ID: TbppID8; const S: String);
var L : Integer;
begin
  FillMem(ID[0], 8, Ord(' '));
  L := MinI(Length(S), 8);
  if L > 0 then
    MoveMem(Pointer(S)^, ID[8 - L], L);
end;

procedure bppInitSequenceCounter(var Counter: LongWord);
begin
  Counter := 1;
end;

procedure bppIncSequenceCounter(var Counter: LongWord);
var C : LongWord;
begin
  C := Counter;
  if C = $7FFFFFFF then
    C := 0
  else
    Inc(C);
  Counter := C;
end;

function bppIsSequenceIDValid(const ID: TbppSequenceID): Boolean;
begin
  Result := (ID.IDPrefix = BPP_ID_SequenceIDPrefix) and
            (ID.Counter[0] in ['0'..'7']) and
            bppIsID8HexValid(ID.Counter);
end;

procedure bppInitSequenceID(var ID: TbppSequenceID; const Counter: LongWord);
begin
  FillMem(ID.Zeros, SizeOf(ID.Zeros), Ord('0'));
  ID.IDPrefix := BPP_ID_SequenceIDPrefix;
  bppSetID8Hex(ID.Counter, Counter);
end;

function bppGetSequenceIDCounter(const ID: TbppSequenceID): LongWord;
begin
  Result := bppGetID8Hex(ID.Counter);
end;

function bppIsChannelIDValid(const ID: TbppChannelID): Boolean;
begin
  Result := (ID.IDPrefix = BPP_ID_ChannelIDPrefix) and
            (ID.ID[0] in ['0'..'7']) and
            bppIsID8HexValid(ID.ID);
end;

procedure bppInitChannelID(var ID: TbppChannelID; const ChannelID: LongWord);
begin
  FillMem(ID.Zeros, SizeOf(ID.Zeros), Ord('0'));
  ID.IDPrefix := BPP_ID_ChannelIDPrefix;
  bppSetID8Hex(ID.ID, ChannelID);;
end;

function bppGetChannelID(const ID: TbppChannelID): LongWord;
begin
  Result := bppGetID8Hex(ID.ID);
end;

function bppIsNetworkIDValid(const ID: TbppNetworkID): Boolean;
begin
  Result := StrPMatchChar(@ID.Counter, SizeOf(ID.Counter), BPP_ID_NetworkCounterCharSet) and
            StrPMatchChar(@ID.CircuitID, SizeOf(ID.CircuitID), BPP_ID_CircuitIDCharSet) and
            StrPMatchChar(@ID.NodeID, SizeOf(ID.NodeID), BPP_ID_NodeIDCharSet);
end;

function bppRandomNodeIDChar: Char;
begin
  Result := BPP_ID_NodeIDChars[RandomUniform(BPP_ID_NodeIDCharCount) + 1];
end;

procedure bppGenerateNetworkID(var ID: TbppID8);
var I : Integer;
    C : Char;
begin
  C := BPP_ID_NodeIDChars[1];
  Repeat
    ID[0] := bppRandomNodeIDChar;
  Until ID[0] <> C; // First digit not 0
  For I := 1 to SizeOf(ID) - 1 do
    ID[I] := bppRandomNodeIDChar;
end;

procedure bppInitCircuitCounter(var ID: TbppID2);
begin
  ID[0] := '0';
  ID[1] := '1';
end;

procedure bppIncreaseCircuitCounter(var ID: TbppID2);
const IncDigits = SizeOf(ID);
var I, J : Integer;
    R    : Boolean;
begin
  J := IncDigits - 1;
  Repeat
    R := False;
    I := PosChar(ID[J], BPP_ID_CircuitCounterChars);
    if I <= 0 then
      I := 1 else
    if I < BPP_ID_CircuitCounterCharCount then
      Inc(I)
    else
      begin
        I := 1;
        R := True;
      end;
    ID[J] := BPP_ID_CircuitCounterChars[I];
    Dec(J);
  Until not R or (J < 0);
end;



{                                                                              }
{ Payload size                                                                 }
{                                                                              }
function bppIsPayloadSizeIndicatorValid(const C: Char): Boolean;
begin
  Result := C in BPP_PS_ValidSet;
end;



{                                                                              }
{ Message trailer                                                              }
{                                                                              }
function bppIsTrailerValid(const Buf): Boolean;
var P : PChar;
    I : Integer;
begin
  P := @Buf;
  For I := 0 to BPP_MSG_TrailerSize - 1 do
    if P^ <> BPP_MSG_Trailer[I + 1] then
      begin
        Result := False;
        exit;
      end
    else
      Inc(P);
  Result := True;
end;



{                                                                              }
{ Message header                                                               }
{                                                                              }
procedure bppInitMessageHeader(var Hdr: TbppMessageHeader; const MsgClass: Char);
begin
  FillMem(Hdr, SizeOf(Hdr), Ord('0'));
  Hdr.MsgIndicator := BPP_MSG_MsgIndicator;
  Hdr.MsgClass := MsgClass;
  if bppIsMessageClassDirect(MsgClass) then
    Hdr.ClassParam := BPP_CP_FinalFrag else
  if bppIsMessageClassNetwork(MsgClass) then
    Hdr.ClassParam := BPP_CP_HopChars[1];
  Hdr.PayloadSizeInd := BPP_MSG_PayloadSizeIndicator;
  Hdr.PayloadInd := BPP_MSG_PayloadIndicator;
end;

procedure bppInitControlMessageHeader(var Hdr: TbppMessageHeader);
begin
  bppInitMessageHeader(Hdr, BPP_MC_Control);
end;

procedure bppInitRequestMessageHeader(var Hdr: TbppMessageHeader);
begin
  bppInitMessageHeader(Hdr, BPP_MC_Request);
end;

procedure bppInitResponseMessageHeader(var Hdr: TbppMessageHeader;
    const RequestHdr: TbppMessageHeader; const Success: Boolean);
begin
  if Success then
    bppInitMessageHeader(Hdr, BPP_MC_ResponseACK) else
    bppInitMessageHeader(Hdr, BPP_MC_ResponseNAK);
  Hdr.MessageID := RequestHdr.MessageID;
  Hdr.DestinationID := RequestHdr.DestinationID;
end;

procedure bppInitBroadcastMessageHeader(var Hdr: TbppMessageHeader);
begin
  bppInitMessageHeader(Hdr, BPP_MC_Broadcast);
end;

function bppIsValidHeader(const Hdr: TbppMessageHeader): Boolean;
begin
  Result := (Hdr.MsgIndicator = BPP_MSG_MsgIndicator) and
            (Hdr.MsgClass in BPP_MC_ValidSet) and
            (Hdr.ClassParam in BPP_CP_ValidSet) and
            (Hdr.PayloadSizeInd in BPP_PS_ValidSet) and
            (Hdr.PayloadInd = BPP_MSG_PayloadIndicator) and
             StrPMatchChar(@Hdr.PayloadSize, SizeOf(Hdr.PayloadSize),
                 BPP_MSG_PayloadSizeCharSet);
  if not Result then
    exit;
  if bppIsMessageClassDirect(Hdr.MsgClass) then
    Result := bppIsFragCharValid(Hdr.ClassParam) else
    Result := bppIsHopCharValid(Hdr.ClassParam);
end;

procedure bppSetPayloadSize(var Hdr: TbppMessageHeader; const Size: Word);
begin
  Hdr.PayloadSize[0] := s_HexDigitsUpper[((Size and $F000) shr 12) + 1];
  Hdr.PayloadSize[1] := s_HexDigitsUpper[((Size and $0F00) shr 8) + 1];
  Hdr.PayloadSize[2] := s_HexDigitsUpper[((Size and $00F0) shr 4) + 1];
  Hdr.PayloadSize[3] := s_HexDigitsUpper[(Size and $000F) + 1];
end;

function bppGetPayloadSize(const Hdr: TbppMessageHeader): Integer;
begin
  Result := (HexCharValue(Hdr.PayloadSize[0]) shl 12) +
            (HexCharValue(Hdr.PayloadSize[1]) shl 8) +
            (HexCharValue(Hdr.PayloadSize[2]) shl 4) +
             HexCharValue(Hdr.PayloadSize[3]);
end;

function bppGetValidPayloadLimit(const Size: Integer): Integer;
begin
  if Size <= 0 then
    Result := BPP_MSG_DefaultPayloadSize else
  if Size < BPP_MSG_MinPayloadLimit then
    Result := BPP_MSG_MinPayloadLimit else
  if Size > BPP_MSG_MaxPayloadSize then
    Result := BPP_MSG_MaxPayloadSize
  else
    Result := Size;
end;

function bppEncodeMessageStr(var Hdr: TbppMessageHeader;
    const Payload: String): String;
var L : Integer;
    P : PChar;
begin
  L := Length(Payload);
  bppSetPayloadSize(Hdr, L);
  SetLength(Result, BPP_MSG_HeaderSize + L + BPP_MSG_TrailerSize);
  P := Pointer(Result);
  Move(Hdr, P^, Sizeof(Hdr));
  Inc(P, Sizeof(Hdr));
  if L > 0 then
    begin
      Move(Pointer(Payload)^, P^, L);
      Inc(P, L);
    end;
  Move(Pointer(BPP_MSG_TrailerStr)^, P^, BPP_MSG_TrailerSize);
end;



{                                                                              }
{ Self-testing code                                                            }
{                                                                              }
{$ASSERTIONS ON}
procedure SelfTest;
begin
  Assert(BPP_ID_Size = 12);
  Assert(BPP_MSG_HeaderSize = 33);
end;



end.
