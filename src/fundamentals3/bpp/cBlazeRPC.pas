{                                                                              }
{                             Blaze RPC Protocol v0.02                         }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{ Description:                                                                 }
{   Implementation of the BPP RPC protocol.                                    }
{                                                                              }
{ Revision history:                                                            }
{   09/05/2003  0.01  Initial version.                                         }
{   14/05/2003  0.02  Revision.                                                }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cBlazeRPC;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,

  { Blaze }
  cBlazeUtils,
  cBlazeUtilsMessages,
  cBlazeClasses;



{                                                                              }
{ Exception                                                                    }
{                                                                              }
type
  EBlazeRPC = class(Exception);



{                                                                              }
{ Value encoding / decoding                                                    }
{                                                                              }
type
  TrpcValueType = (rpctUnknown,
                   rpctInteger,
                   rpctString,
                   rpctBoolean,
                   rpctFloat,
                   rpctListenerHandle,
                   rpctInitiatorHandle);

function  rpcEncodeIntegerValue(const A: Integer): String;
function  rpcEncodeStringValue(const A: String): String;
function  rpcEncodeBooleanValue(const A: Boolean): String;
function  rpcEncodeFloatValue(const A: Extended): String;
function  rpcEncodeHandleValue(const Initiator: Boolean; const TypeID: Byte;
          const A: Cardinal): String;

function  rpcDecodeIntegerValue(const A: String): Integer;
function  rpcDecodeStringValue(const A: String): String;
function  rpcDecodeBooleanValue(const A: String): Boolean;
function  rpcDecodeFloatValue(const A: String): Extended;
function  rpcDecodeHandleValue(const A: String; var Initiator: Boolean;
          var TypeID: Byte): LongWord;

function  rpcDecodeValueType(const A: String): TrpcValueType;
function  rpcIsHandleLocal(const Handle: TrpcValueType;
          const Initiator: Boolean): Boolean;

function  rpcEncodeListValue(const A: String): String;
function  rpcDecodeListValue(const A: String): String;

procedure rpcEncodeListValues(var A: StringArray);
procedure rpcDecodeListValues(var A: StringArray);



{                                                                              }
{ Message functions                                                            }
{                                                                              }
function  rpcEncodeRequest(const ObjectID, MethodID: String;
          const ParameterList: Array of String): String;
procedure rpcDecodeRequest(const S: String;
          var ObjectID, MethodID: String;
          var ParameterList: StringArray);

function  rpcEncodeResultResponse(const ResultList: Array of String): String;
function  rpcEncodeErrorResponse(const ErrorReason, ErrorMessage: String): String;

type
  TrpcResponseType = (rpcrUnknown, rpcrResult, rpcrError);

function  rpcDecodeResponseType(const S: String): TrpcResponseType;
procedure rpcDecodeResultResponse(const S: String; var ResultList: StringArray);
procedure rpcDecodeErrorResponse(const S: String;
          var ErrorReason, ErrorMessage: String);



{                                                                              }
{ TrpcMessage                                                                  }
{                                                                              }
type
  TrpcMessage = class(TbppMessage)
  protected
    FResponseType : TrpcResponseType;
    FResultList   : StringArray;
    FErrorReason  : String;
    FErrorMessage : String;

    procedure HandleRPCResult; virtual;
    procedure HandleRPCError; virtual;

  public
    constructor Create(const ObjectID, MethodID: String;
                const Parameters: Array of String);

    property  ResponseType: TrpcResponseType read FResponseType;
    property  ResultList: StringArray read FResultList;
    property  ErrorReason: String read FErrorReason;
    property  ErrorMessage: String read FErrorMessage;
  end;



{                                                                              }
{ TrpcChannel                                                                  }
{                                                                              }
type
  TrpcChannel = class(AbppChannel)
  protected
    // BPP
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
    procedure HandleResponseMessage(const RequestMessage: TbppMessage;
              const Header: TbppMessageHeader;
              const Payload: String); override;

    // RPC
    procedure HandleRPCRequest(const RequestHeader: TbppMessageHeader;
              const ObjectID, MethodID: String;
              const Parameters: Array of String); virtual; abstract;
    procedure Wait; virtual; abstract;

  public
    // Request
    function  SendRPCRequest(const ObjectID, MethodID: String;
              const Parameters: Array of String): TrpcMessage;

    // Response
    procedure SendRPCResultResponse(const RequestHeader: TbppMessageHeader;
              const ResultList: Array of String);
    procedure SendRPCErrorResponse(const RequestHeader: TbppMessageHeader;
              const ErrorReason, ErrorMessage: String);

    // Request and Response
    procedure RPC(const ObjectID, MethodID: String;
              const Parameters: Array of String;
              var ResultList: StringArray);
  end;



implementation

uses
  { Fundamentals }
  cStrings;



{                                                                              }
{ Parameters                                                                   }
{                                                                              }
function rpcEncodeIntegerValue(const A: Integer): String;
begin
  Result := 'i<' + IntToStr(A) + '>';
end;

function rpcDecodeIntegerValue(const A: String): Integer;
var L : Integer;
begin
  L := Length(A);
  if (L < 4) or (A[1] <> 'i') or (A[2] <> '<') or (A[L] <> '>') then
    raise EBlazeRPC.Create('Invalid integer value');
  try
    Result := StrToInt(Copy(A, 3, L - 3));
  except
    raise EBlazeRPC.Create('Invalid integer value');
  end;
end;

function rpcEncodeStringValue(const A: String): String;
var L : Integer;
begin
  L := Length(A);
  Result := 's<' + IntToStr(L) + '><' + A + '>';
end;

function rpcDecodeStringValue(const A: String): String;
var L, I, J : Integer;
begin
  L := Length(A);
  if (L < 6) or (A[1] <> 's') or (A[2] <> '<') or (A[L] <> '>') then
    raise EBlazeRPC.Create('Invalid string value');
  I := PosChar('>', A, 3);
  if (I <= 0) or (I >= L) or (A[I + 1] <> '<') then
    raise EBlazeRPC.Create('Invalid string value');
  J := StrToInt(CopyRange(A, 3, I - 1));
  if I + J + 2 <> L then
    raise EBlazeRPC.Create('Invalid string value');
  Result := Copy(A, I + 2, J);
end;

function rpcEncodeBooleanValue(const A: Boolean): String;
begin
  if A then
    Result := '1'
  else
    Result := '0';
end;

function rpcDecodeBooleanValue(const A: String): Boolean;
begin
  if Length(A) <> 1 then
    raise EBlazeRPC.Create('Invalid boolean value');
  Case PChar(Pointer(A))^ of
    '0' : Result := True;
    '1' : Result := False;
  else
    raise EBlazeRPC.Create('Invalid boolean value');
  end;
end;

function rpcEncodeFloatValue(const A: Extended): String;
begin
  Result := 'f<' + FloatToStr(A) + '>';
end;

function rpcDecodeFloatValue(const A: String): Extended;
var L : Integer;
begin
  L := Length(A);
  if (L < 4) or (A[1] <> 'f') or (A[2] <> '<') or (A[L] <> '>') then
    raise EBlazeRPC.Create('Invalid float value');
  try
    Result := StrToFloat(Copy(A, 3, L - 3));
  except
    raise EBlazeRPC.Create('Invalid float value');
  end;
end;

function rpcDecodeHandleValue(const A: String; var Initiator: Boolean;
    var TypeID: Byte): LongWord;
var L : Integer;
begin
  L := Length(A);
  if (L <> 10) or not (A[1] in ['c', 'l']) then
    raise EBlazeRPC.Create('Invalid handle value');
  Initiator := A[1] = 'c';
  TypeID := Byte(A[2]);
  Result := HexToLongWord(Copy(A, 3, L - 2));
end;

function rpcEncodeHandleValue(const Initiator: Boolean; const TypeID: Byte;
    const A: Cardinal): String;
begin
  if Initiator then
    Result := 'c'
  else
    Result := 'l';
  Result := Result + Char(TypeID) + LongWordToHex(A, 8);
end;

function rpcDecodeValueType(const A: String): TrpcValueType;
begin
  if A = '' then
    Result := rpctUnknown
  else
    Case PChar(Pointer(A))^ of
      'i'  : Result := rpctInteger;
      's'  : Result := rpctString;
      '0',
      '1'  : Result := rpctBoolean;
      'f'  : Result := rpctFloat;
      'l'  : Result := rpctListenerHandle;
      'c'  : Result := rpctInitiatorHandle;
    else
      Result := rpctUnknown;
    end;
end;

function rpcIsHandleLocal(const Handle: TrpcValueType;
         const Initiator: Boolean): Boolean;
begin
  Result := ((Handle = rpctListenerHandle) and not Initiator) or
            ((Handle = rpctInitiatorHandle) and Initiator);
end;

function rpcEncodeListValue(const A: String): String;
begin
  Result := StrReplace('`', '```', A);
  Result := StrReplace('~', '.`.', Result);
end;

function rpcDecodeListValue(const A: String): String;
begin
  Result := StrReplace('.`.', '~', A);
  Result := StrReplace('```', '`', Result);
end;

procedure rpcEncodeListValues(var A: StringArray);
var I : Integer;
begin
  For I := 0 to Length(A) - 1 do
    A[I] := rpcEncodeListValue(A[I]);
end;

procedure rpcDecodeListValues(var A: StringArray);
var I : Integer;
begin
  For I := 0 to Length(A) - 1 do
    A[I] := rpcDecodeListValue(A[I]);
end;



{                                                                              }
{ Message                                                                      }
{                                                                              }
function rpcEncodeRequest(const ObjectID, MethodID: String;
    const ParameterList: Array of String): String;
var P : StringArray;
begin
  P := AsStringArray(ParameterList);
  rpcEncodeListValues(P);
  Result := ObjectID + '!' + MethodID;
  if Length(P) > 0 then
    Result := Result + '~' + StrJoin(P, '~');
end;

procedure rpcDecodeRequest(const S: String; var ObjectID, MethodID: String;
    var ParameterList: StringArray);
var I, P : String;
    F, G : Integer;
begin
  G := PosChar('~', S);
  // Decode ParameterList
  if G > 0 then
    begin
      I := CopyLeft(S, G - 1);
      P := CopyFrom(S, G + 1);
      if P = '' then
        ParameterList := AsStringArray([''])
      else
        begin
          ParameterList := StrSplitChar(P, '~');
          rpcDecodeListValues(ParameterList);
        end;
    end
  else
    begin
      I := S;
      ParameterList := nil;
    end;
  // Decode identifier
  F := PosChar('!', I);
  if F > 0 then
    begin
      ObjectID := CopyLeft(I, F - 1);
      MethodID := CopyFrom(I, F + 1);
    end
  else
    begin
      ObjectID := '';
      MethodID := I;
    end;
end;

function rpcEncodeResultResponse(const ResultList: Array of String): String;
var R : StringArray;
begin
  R := AsStringArray(ResultList);
  rpcEncodeListValues(R);
  Result := 'Result';
  if Length(R) > 0 then
    Result := Result + '~' + StrJoin(R, '~');
end;

function rpcEncodeErrorResponse(const ErrorReason, ErrorMessage: String): String;
begin
  Result := 'Error~' + rpcEncodeListValue(ErrorReason) +
                 '~' + rpcEncodeListValue(ErrorMessage);
end;

function rpcDecodeResponseType(const S: String): TrpcResponseType;
var T : String;
begin
  T := StrBefore(S, '~', True);
  TrimInPlace(T);
  if StrEqualNoCase(T, 'Result') then
    Result := rpcrResult else
  if StrEqualNoCase(T, 'Error') then
    Result := rpcrError
  else
    Result := rpcrUnknown;
end;

procedure rpcDecodeResultResponse(const S: String; var ResultList: StringArray);
var F : Integer;
    P : String;
begin
  F := PosChar('~', S);
  if F = 0 then
    ResultList := nil
  else
    begin
      P := CopyFrom(S, F + 1);
      if P = '' then
        ResultList := AsStringArray([''])
      else
        begin
          ResultList := StrSplitChar(P, '~');
          rpcDecodeListValues(ResultList);
        end;
    end;
end;

procedure rpcDecodeErrorResponse(const S: String;
    var ErrorReason, ErrorMessage: String);
var I, P : String;
begin
  StrSplitAtChar(S, '~', I, P, True);
  StrSplitAtChar(P, '~', ErrorReason, ErrorMessage, True);
end;



{                                                                              }
{ TrpcMessage                                                                  }
{                                                                              }
constructor TrpcMessage.Create(const ObjectID, MethodID: String;
    const Parameters: Array of String);
begin
  inherited Create;
  bppInitRequestMessageHeader(FHeader);
  FPayload := rpcEncodeRequest(ObjectID, MethodID, Parameters);
  FResponseType := rpcrUnknown;
end;

procedure TrpcMessage.HandleRPCResult;
begin
end;

procedure TrpcMessage.HandleRPCError;
begin
end;



{                                                                              }
{ TrpcChannel                                                                  }
{                                                                              }
procedure TrpcChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
var Obj, Met : String;
    Par      : StringArray;
begin
  rpcDecodeRequest(Payload, Obj, Met, Par);
  HandleRPCRequest(Header, Obj, Met, Par);
end;

procedure TrpcChannel.HandleResponseMessage(const RequestMessage: TbppMessage;
    const Header: TbppMessageHeader; const Payload: String);
var T    : TrpcResponseType;
    Res  : StringArray;
    R, M : String;
begin
  T := rpcDecodeResponseType(Payload);
  Case T of
    rpcrResult :
      begin
        rpcDecodeResultResponse(Payload, Res);
        if RequestMessage is TrpcMessage then
          With TrpcMessage(RequestMessage) do
            begin
              FResponseType := rpcrResult;
              FResultList := Res;
              HandleRPCResult;
            end;
      end;
    rpcrError :
      begin
        rpcDecodeErrorResponse(Payload, R, M);
        if RequestMessage is TrpcMessage then
          With TrpcMessage(RequestMessage) do
            begin
              FResponseType := rpcrError;
              FErrorReason := R;
              FErrorMessage := M;
              HandleRPCError;
            end;
      end;
    else
      if RequestMessage is TrpcMessage then
        With TrpcMessage(RequestMessage) do
          begin
            FResponseType := T;
            FErrorReason := '';
            FErrorMessage := '';
            HandleRPCError;
          end;
  end;
end;

function TrpcChannel.SendRPCRequest(const ObjectID, MethodID: String;
    const Parameters: Array of String): TrpcMessage;
begin
  Result := TrpcMessage.Create(ObjectID, MethodID, Parameters);
  Result.AddReference;
  SendRequestMessage(Result);
end;

procedure TrpcChannel.SendRPCResultResponse(const RequestHeader: TbppMessageHeader;
    const ResultList: Array of String);
begin
  SendResponseMessage(RequestHeader, rpcEncodeResultResponse(ResultList), True);
end;

procedure TrpcChannel.SendRPCErrorResponse(const RequestHeader: TbppMessageHeader;
    const ErrorReason, ErrorMessage: String);
begin
  SendResponseMessage(RequestHeader,
      rpcEncodeErrorResponse(ErrorReason, ErrorMessage), False);
end;

procedure TrpcChannel.RPC(const ObjectID, MethodID: String;
    const Parameters: Array of String;
    var ResultList: StringArray);
var M : TrpcMessage;
begin
  // Send request
  M := SendRPCRequest(ObjectID, MethodID, Parameters);
  try
    // Wait for response
    While not M.IsTransportFinished do
      Wait;
    // Check if sucess
    if not M.IsTransportSuccess then
      raise EBlazeRPC.Create('RPC failed');
    Case M.ResponseType of
      rpcrUnknown : raise EBlazeRPC.Create('Unknown RPC response');
      rpcrError   : raise EBlazeRPC.Create(M.ErrorMessage);
    end;
    // Set result
    Assert(M.ResponseType = rpcrResult);
    ResultList := M.ResultList;
  finally
    M.ReleaseReference;
  end;
end;



end.

