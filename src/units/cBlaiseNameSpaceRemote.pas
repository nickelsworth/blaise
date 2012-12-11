{                                                                              }
{                    Blaise remote name space objects v0.02                    }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseNameSpaceRemote.pas             }
{                                                                              }
{ Description:                                                                 }
{   This unit implements local proxy objects for remote name space objects.    }
{                                                                              }
{ Revision history:                                                            }
{   16/05/2003  0.01  Initial version.                                         }
{   17/05/2003  0.02  Improvements.                                            }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseNameSpaceRemote;

interface

uses
  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructsCollections,
  cBlaiseNameSpaceTypes;



{                                                                              }
{ ARootRemoteNameSpace                                                         }
{   Abstract base class for a local name space object that represents the      }
{   root name space object shared by a remote system. The local name space     }
{   object is responsible for all communications between local objects and     }
{   remote objects in and below the remote root name space object.             }
{                                                                              }
{   Implementations must:                                                      }
{     Override RPC to do a (blocking) remote method call.                      }
{     Override GetObject to return the local object representing ObjID.        }
{     Override GetObjectID to return the object ID of a local object.          }
{                                                                              }
type
  ARootRemoteNameSpace = class(ANameSpaceEx)
  public
    function  RPC(const ObjID, Method: String;
              const Parameters: Array of String;
              const MinResponse, MaxResponse: Integer): StringArray; virtual; abstract;

    function  GetObject(const ObjID: String): ABlaiseType; virtual; abstract;
    function  GetObjectID(const A: TObject): String; virtual; abstract;
  end;



{                                                                              }
{ TRemoteInstanceCaller                                                        }
{   Helper object for doing remote method calls.                               }
{                                                                              }
type
  TRemoteInstanceCaller = class
  protected
    FRemoteNameSpace : ARootRemoteNameSpace;
    FObjectID        : String;
    FTypeID          : Byte;

    { ABlaiseType                                                              }
    function  GetAsString: String;
    function  GetAsUTF8: String;
    function  GetAsBlaise: String;
    procedure SetAsString(const Value: String);
    procedure SetAsUTF8(const Value: String);

  public
    { TRemoteInstanceCaller                                                    }
    constructor Create(const RemoteNameSpace: ARootRemoteNameSpace;
                const ObjectID: String);
    destructor Destroy; override;

    property  RemoteNameSpace: ARootRemoteNameSpace read FRemoteNameSpace;
    property  ObjectID: String read FObjectID;

    function  RPC(const Method: String; const Parameters: Array of String;
              const MinResponse, MaxResponse: Integer): StringArray;

    { ABlaiseType                                                              }
    function  Duplicate: TObject;
    procedure Assign(const Source: TObject);
    function  IsEqual(const T: TObject): Boolean;
    function  Compare(const T: TObject): TCompareResult;
    function  HashValue: LongWord;
    function  GetTypeID: Byte;
    procedure StreamOut(const Writer: AWriterEx);
    procedure StreamIn(const Reader: AReaderEx);

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject;
    procedure SetField(const FieldName: String; const Value: TObject);
    procedure DeleteField(const FieldName: String);
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject;

    { ASimpleType                                                              }
    procedure SetAsInteger(const Value: Int64);
    procedure SetAsFloat(const Value: Extended);
    procedure SetAsCurrency(const Value: Currency);
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetAsBoolean(const Value: Boolean);
    function  GetAsInteger: Int64;
    function  GetAsFloat: Extended;
    function  GetAsCurrency: Currency;
    function  GetAsDateTime: TDateTime;
    function  GetAsBoolean: Boolean;

    { AFunction                                                                }
    function  GetParameters: TParameterAttributesArray;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject;

    { ANameSpace                                                               }
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject;
    function  Exists(const Key: String): Boolean;
    function  GetItem(const Key: String): TObject;
    procedure SetItem(const Key: String; const Value: TObject);
    procedure Delete(const Key: String);
    function  Directory(const Key: String): TObject;
  end;



{                                                                              }
{ TRemoteBlaiseType                                                            }
{   Local proxy for a remote type instance.                                    }
{                                                                              }
type
  TRemoteBlaiseType = class(ABlaiseType)
  protected
    FRemoteNameSpace : ARootRemoteNameSpace;
    FObjectID        : String;
    FCaller          : TRemoteInstanceCaller;

    { ABlaiseType                                                              }
    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); override;

  public
    { TRemoteBlaiseType                                                        }
    constructor Create(const RemoteNameSpace: ARootRemoteNameSpace;
                const ObjectID: String);
    destructor Destroy; override;

    property  RemoteNameSpace: ARootRemoteNameSpace read FRemoteNameSpace;
    property  ObjectID: String read FObjectID;

    { ABlaiseType                                                              }
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  HashValue: LongWord; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    procedure DeleteField(const FieldName: String); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
  end;



{                                                                              }
{ TRemoteFunction                                                              }
{   Local proxy for a remote function instance.                                }
{                                                                              }
type
  TRemoteFunction = class(AFunction)
  protected
    FRemoteNameSpace   : ARootRemoteNameSpace;
    FObjectID          : String;
    FCaller            : TRemoteInstanceCaller;
    FParametersUpdated : Boolean;
    FParameters        : TParameterAttributesArray;

    { ABlaiseType                                                              }
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;
    procedure SetAsUTF8(const Value: String); override;

  public
    { TRemoteFunction                                                          }
    constructor Create(const RemoteNameSpace: ARootRemoteNameSpace;
                const ObjectID: String);
    destructor Destroy; override;

    property  RemoteNameSpace: ARootRemoteNameSpace read FRemoteNameSpace;
    property  ObjectID: String read FObjectID;

    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    procedure DeleteField(const FieldName: String); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;

    { AFunction                                                                }
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  GetMachineCode: Pointer; override;
    function  CreateLocalScope(const Scope: ABlaiseType;
              const Parameters: Array of TObject): ABlaiseType; override;
  end;



{                                                                              }
{ TRemoteNameSpace                                                             }
{   Local proxy for a remote name space instance.                              }
{                                                                              }
type
  TRemoteNameSpace = class(ANameSpaceEx)
  protected
    FRemoteNameSpace : ARootRemoteNameSpace;
    FObjectID        : String;
    FCaller          : TRemoteInstanceCaller;

    { ABlaiseType                                                              }
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;
    procedure SetAsUTF8(const Value: String); override;

  public
    { TRemoteNameSpace                                                         }
    constructor Create(const RemoteNameSpace: ARootRemoteNameSpace;
                const ObjectID: String);
    destructor Destroy; override;

    property  RemoteNameSpace: ARootRemoteNameSpace read FRemoteNameSpace;
    property  ObjectID: String read FObjectID;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    procedure DeleteField(const FieldName: String); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;

    { ANameSpace                                                               }
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
    function  Exists(const Key: String): Boolean; override;
    function  GetItem(const Key: String): TObject; override;
    procedure SetItem(const Key: String; const Value: TObject); override;
    procedure Delete(const Key: String); override;
    function  Directory(const Key: String): TObject; override;
  end;



{                                                                              }
{ TRemoteObject                                                                }
{   Local proxy for a remote object instance.                                  }
{                                                                              }
type
  TRemoteObject = class(ABlaiseObject)
  protected
    FRemoteNameSpace : ARootRemoteNameSpace;
    FObjectID        : String;
    FCaller          : TRemoteInstanceCaller;

    function  RPC(const Method: String; const Parameters: Array of String;
              const MinResponse, MaxResponse: Integer): StringArray;

    { ABlaiseType                                                              }
    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); override;

  public
    { TRemoteObject                                                            }
    constructor Create(const RemoteNameSpace: ARootRemoteNameSpace;
                const ObjectID: String);
    destructor Destroy; override;

    property  RemoteNameSpace: ARootRemoteNameSpace read FRemoteNameSpace;
    property  ObjectID: String read FObjectID;

    { ABlaiseType                                                              }
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  HashValue: LongWord; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    procedure DeleteField(const FieldName: String); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
  end;



{                                                                              }
{ ARootRemoteNameSpaceHandler                                                  }
{   Base class for remote root name space that implements RPC responses.       }
{                                                                              }
type
  ARootRemoteNameSpaceHandler = class(ARootRemoteNameSpace)
  protected
    FRootNameSpace : ANameSpace;
    FCaller        : TRemoteInstanceCaller;
    FLocalObjects  : TObjectDictionaryByString;
    FRemoteObjects : TObjectDictionaryByString;

    function  GetRemoteObject(const ObjID: String): ABlaiseType;

    function  GetLocalObject(const ObjID: String): ABlaiseType;
    function  GetLocalObjectTypeID(const Obj: TObject): Byte;

    function  GetRPCResponse(const Obj: ABlaiseType;
              const MethodID: String; const Parameters: Array of String;
              var ErrorReason, ErrorMessage: String): StringArray;

    { ABlaiseType                                                              }
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;
    procedure SetAsUTF8(const Value: String); override;

  public
    constructor Create(const RootNameSpace: ANameSpace);
    destructor Destroy; override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    procedure DeleteField(const FieldName: String); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;

    { ANameSpace                                                               }
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
    function  Exists(const Key: String): Boolean; override;
    function  GetItem(const Key: String): TObject; override;
    procedure SetItem(const Key: String; const Value: TObject); override;
    procedure Delete(const Key: String); override;
    function  Directory(const Key: String): TObject; override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,
  cStreams,

  { Blaze }
  cBlazeRPC,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructs,
  cBlaiseStructsSimple;



{                                                                              }
{ TRemoteInstanceCaller                                                        }
{                                                                              }
constructor TRemoteInstanceCaller.Create(const RemoteNameSpace: ARootRemoteNameSpace;
    const ObjectID: String);
begin
  inherited Create;
  Assert(Assigned(RemoteNameSpace));
  ObjectAddReference(RemoteNameSpace);
  FRemoteNameSpace := RemoteNameSpace;
  FObjectID := ObjectID;
  FTypeID := BLAISE_TYPE_ID_Invalid;
end;

destructor TRemoteInstanceCaller.Destroy;
begin
  ObjectReleaseReferenceAndNil(FRemoteNameSpace);
  inherited Destroy;
end;

function TRemoteInstanceCaller.RPC(const Method: String;
    const Parameters: Array of String;
    const MinResponse, MaxResponse: Integer): StringArray;
begin
  Result := FRemoteNameSpace.RPC(FObjectID, Method, Parameters, MinResponse,
      MaxResponse);
end;

{ AType calls                                                                  }
function TRemoteInstanceCaller.GetAsString: String;
begin
  Result := RPC('ABlaiseType.GetAsString', [], 1, 1)[0];
end;

function TRemoteInstanceCaller.GetAsUTF8: String;
begin
  Result := RPC('ABlaiseType.GetAsUTF8', [], 1, 1)[0];
end;

function TRemoteInstanceCaller.GetAsBlaise: String;
begin
  Result := RPC('ABlaiseType.GetAsBlaise', [], 1, 1)[0];
end;

procedure TRemoteInstanceCaller.SetAsString(const Value: String);
begin
  RPC('ABlaiseType.SetAsString', [Value], 0, 0);
end;

procedure TRemoteInstanceCaller.SetAsUTF8(const Value: String);
begin
  RPC('ABlaiseType.SetAsUTF8', [Value], 0, 0);
end;

function TRemoteInstanceCaller.Duplicate: TObject;
var R : StringArray;
begin
  R := RPC('ABlaiseType.Duplicate', [], 1, 1);
  With FRemoteNameSpace do
    Result := GetObject(R[0]);
end;

procedure TRemoteInstanceCaller.Assign(const Source: TObject);
begin
  RPC('ABlaiseType.Assign', [FRemoteNameSpace.GetObjectID(Source)], 0, 0);
end;

function TRemoteInstanceCaller.IsEqual(const T: TObject): Boolean;
var R : StringArray;
begin
  R := RPC('ABlaiseType.IsEqual', [FRemoteNameSpace.GetObjectID(T)], 1, 1);
  Result := R[0] = '1';
end;

function TRemoteInstanceCaller.Compare(const T: TObject): TCompareResult;
var R : StringArray;
begin
  R := RPC('ABlaiseType.Compare', [FRemoteNameSpace.GetObjectID(T)], 1, 1);
  Result := TCompareResult(StrToIntDef(R[0], Ord(crUndefined)));
end;

function TRemoteInstanceCaller.HashValue: LongWord;
var R : StringArray;
begin
  R := RPC('ABlaiseType.HashValue', [], 1, 1);
  Result := HexToLongWord(R[0]);
end;

function TRemoteInstanceCaller.GetTypeID: Byte;
var R : StringArray;
begin
  R := nil;
  if FTypeID = BLAISE_TYPE_ID_Invalid then
    begin
      // Cache TypeID. TypeID is static (Blaise values are strongly typed)
      R := RPC('ABlaiseType.GetTypeID', [], 1, 1);
      FTypeID := StrToIntDef(R[0], BLAISE_TYPE_ID_VALUE_Unknown);
    end;
  Result := FTypeID;
end;

procedure TRemoteInstanceCaller.StreamOut(const Writer: AWriterEx);
var R : StringArray;
begin
  R := RPC('ABlaiseType.StreamOut', [], 1, 1);
  Writer.WriteStr(R[0]);
end;

procedure TRemoteInstanceCaller.StreamIn(const Reader: AReaderEx);
var R : StringArray;
    S : TTStream;
begin
  S := TTStream.Create(nil, TReaderWriter.Create(Reader, nil, False, False), True);
  try
    ObjectAddReference(S);
    R := RPC('ABlaiseType.StreamIn', [FRemoteNameSpace.GetObjectID(S)], 1, 1);
  finally
    ObjectReleaseReference(S);
  end;
end;

function TRemoteInstanceCaller.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var R : StringArray;
begin
  R := RPC('ABlaiseType.GetField', [FieldName], 3, 3);
  With FRemoteNameSpace do
    begin
      Scope := GetObject(R[0]);
      FieldType := TBlaiseFieldType(StrToIntDef(R[1], 0));
      Result := GetObject(R[2]);
    end;
end;

procedure TRemoteInstanceCaller.SetField(const FieldName: String;
    const Value: TObject);
begin
  RPC('ABlaiseType.SetField', [FieldName, FRemoteNameSpace.GetObjectID(Value)], 0, 0);
end;

procedure TRemoteInstanceCaller.DeleteField(const FieldName: String);
begin
  RPC('ABlaiseType.DeleteField', [FieldName], 0, 0);
end;

function TRemoteInstanceCaller.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
var I, L : Integer;
    R, P : StringArray;
begin
  L := Length(Parameters);
  SetLength(P, L + 1);
  P[0] := FieldName;
  With FRemoteNameSpace do
    begin
      For I := 0 to L - 1 do
        P[I + 1] := GetObjectID(Parameters[I]);
      R := self.RPC('ABlaiseType.CallField', P, 1, 1);
      Result := GetObject(R[0]);
    end;
end;

{ ASimpleType calls                                                            }
procedure TRemoteInstanceCaller.SetAsInteger(const Value: Int64);
begin
  RPC('ASimpleType.SetAsInteger', [IntToStr(Value)], 0, 0);
end;

procedure TRemoteInstanceCaller.SetAsFloat(const Value: Extended);
begin
  RPC('ASimpleType.SetAsFloat', [FloatToStr(Value)], 0, 0);
end;

procedure TRemoteInstanceCaller.SetAsCurrency(const Value: Currency);
begin
  RPC('ASimpleType.SetAsCurrency', [FloatToStr(Value)], 0, 0);
end;

procedure TRemoteInstanceCaller.SetAsDateTime(const Value: TDateTime);
begin
  RPC('ASimpleType.SetAsDateTime', [DateTimeToStr(Value)], 0, 0);
end;

procedure TRemoteInstanceCaller.SetAsBoolean(const Value: Boolean);
begin
  RPC('ASimpleType.SetAsBoolean', [iif(Value, '1', '0')], 0, 0);
end;

function TRemoteInstanceCaller.GetAsInteger: Int64;
begin
  Result := StrToInt64(RPC('ASimpleType.GetAsInteger', [], 1, 1)[0]);
end;

function TRemoteInstanceCaller.GetAsFloat: Extended;
begin
  Result := StrToFloat(RPC('ASimpleType.GetAsFloat', [], 1, 1)[0]);
end;

function TRemoteInstanceCaller.GetAsCurrency: Currency;
begin
  Result := StrToFloat(RPC('ASimpleType.GetAsCurrency', [], 1, 1)[0]);
end;

function TRemoteInstanceCaller.GetAsDateTime: TDateTime;
begin
  Result := StrToDateTime(RPC('ASimpleType.GetAsDateTime', [], 1, 1)[0]);
end;

function TRemoteInstanceCaller.GetAsBoolean: Boolean;
begin
  Result := RPC('ASimpleType.GetAsBoolean', [], 1, 1)[0] = '1';
end;

{ AFunction calls                                                              }
function TRemoteInstanceCaller.GetParameters: TParameterAttributesArray;
var R    : StringArray;
    I, L : Integer;
begin
  R := RPC('AFunction.GetParameters', [], 0, -1);
  With FRemoteNameSpace do
    begin
      L := Length(R);
      SetLength(Result, L);
      For I := 0 to L - 1 do
        Result[I] := TParameterAttributes(Byte(StrToIntDef(R[I], 0)));
    end;
end;

function TRemoteInstanceCaller.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var R, P : StringArray;
    I, L : Integer;
begin
  With FRemoteNameSpace do
    begin
      L := Length(Parameters);
      SetLength(P, L);
      For I := 0 to L - 1 do
        P[I] := GetObjectID(Parameters[I]);
      R := self.RPC('AFunction.Call', P, 1, 1);
      Result := GetObject(R[0]);
    end;
end;

{ ANameSpace calls                                                             }
function TRemoteInstanceCaller.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
var R : StringArray;
begin
  R := RPC('ANameSpace.GetNameSpace', [Name, IntToStr(Position)], 2, 2);
  Position := StrToIntDef(R[0], Position);
  Result := FRemoteNameSpace.GetObject(R[1]);
end;

function TRemoteInstanceCaller.Exists(const Key: String): Boolean;
var R : StringArray;
begin
  R := RPC('ANameSpace.Exists', [Key], 1, 1);
  Result := StrToBoolean(R[0]);
end;

function TRemoteInstanceCaller.GetItem(const Key: String): TObject;
var R : StringArray;
begin
  R := RPC('ANameSpace.GetItem', [Key], 1, 1);
  Result := FRemoteNameSpace.GetObject(R[0]);
end;

procedure TRemoteInstanceCaller.SetItem(const Key: String; const Value: TObject);
begin
  RPC('ANameSpace.SetItem', [Key, FRemoteNameSpace.GetObjectID(Value)], 0, 0);
end;

procedure TRemoteInstanceCaller.Delete(const Key: String);
begin
  RPC('ANameSpace.Delete', [Key], 0, 0);
end;

function TRemoteInstanceCaller.Directory(const Key: String): TObject;
var R : StringArray;
begin
  R := RPC('ANameSpace.Directory', [Key], 1, 1);
  With FRemoteNameSpace do
    Result := GetObject(R[0]);
end;



{                                                                              }
{ TRemoteBlaiseType                                                            }
{                                                                              }
constructor TRemoteBlaiseType.Create(
    const RemoteNameSpace: ARootRemoteNameSpace; const ObjectID: String);
begin
  inherited Create;
  ObjectAddReference(RemoteNameSpace);
  FRemoteNameSpace := RemoteNameSpace;
  FObjectID := ObjectID;
  FCaller := TRemoteInstanceCaller.Create(RemoteNameSpace, ObjectID);
end;

destructor TRemoteBlaiseType.Destroy;
begin
  FreeAndNil(FCaller);
  ObjectReleaseReferenceAndNil(FRemoteNameSpace);
  inherited Destroy;
end;

function TRemoteBlaiseType.GetAsString: String;
begin
  Result := FCaller.GetAsString;
end;

function TRemoteBlaiseType.GetAsUTF8: String;
begin
  Result := FCaller.GetAsUTF8;
end;

function TRemoteBlaiseType.GetAsBlaise: String;
begin
  Result := FCaller.GetAsBlaise;
end;

procedure TRemoteBlaiseType.SetAsString(const Value: String);
begin
  FCaller.SetAsString(Value);
end;

procedure TRemoteBlaiseType.SetAsUTF8(const Value: String);
begin
  FCaller.SetAsUTF8(Value);
end;

function TRemoteBlaiseType.Duplicate: TObject;
begin
  Result := FCaller.Duplicate;
end;

procedure TRemoteBlaiseType.Assign(const Source: TObject);
begin
  FCaller.Assign(Source);
end;

function TRemoteBlaiseType.IsEqual(const T: TObject): Boolean;
begin
  Result := FCaller.IsEqual(T);
end;

function TRemoteBlaiseType.Compare(const T: TObject): TCompareResult;
begin
  Result := FCaller.Compare(T);
end;

function TRemoteBlaiseType.HashValue: LongWord;
begin
  Result := FCaller.HashValue;
end;

function TRemoteBlaiseType.GetTypeID: Byte;
begin
  Result := FCaller.GetTypeID;
end;

procedure TRemoteBlaiseType.StreamOut(const Writer: AWriterEx);
begin
  FCaller.StreamOut(Writer);
end;

procedure TRemoteBlaiseType.StreamIn(const Reader: AReaderEx);
begin
  FCaller.StreamIn(Reader);
end;

function TRemoteBlaiseType.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := FCaller.GetField(FieldName, Scope, FieldType);
end;

procedure TRemoteBlaiseType.SetField(const FieldName: String;
    const Value: TObject);
begin
  FCaller.SetField(FieldName, Value);
end;

procedure TRemoteBlaiseType.DeleteField(const FieldName: String);
begin
  FCaller.DeleteField(FieldName);
end;

function TRemoteBlaiseType.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := FCaller.CallField(FieldName, Parameters);
end;



{                                                                              }
{ TRemoteFunction                                                              }
{                                                                              }
constructor TRemoteFunction.Create(const RemoteNameSpace: ARootRemoteNameSpace;
    const ObjectID: String);
begin
  inherited Create;
  ObjectAddReference(RemoteNameSpace);
  FRemoteNameSpace := RemoteNameSpace;
  FObjectID := ObjectID;
  FCaller := TRemoteInstanceCaller.Create(RemoteNameSpace, ObjectID);
end;

destructor TRemoteFunction.Destroy;
begin
  FreeAndNil(FCaller);
  ObjectReleaseReferenceAndNil(FRemoteNameSpace);
  inherited Destroy;
end;

function TRemoteFunction.GetAsUTF8: String;
begin
  Result := FCaller.GetAsUTF8;
end;

function TRemoteFunction.GetAsBlaise: String;
begin
  Result := FCaller.GetAsBlaise;
end;

procedure TRemoteFunction.SetAsUTF8(const Value: String);
begin
  FCaller.SetAsUTF8(Value);
end;

function TRemoteFunction.GetTypeID: Byte;
begin
  Result := FCaller.GetTypeID;
end;

procedure TRemoteFunction.StreamOut(const Writer: AWriterEx);
begin
  FCaller.StreamOut(Writer);
end;

procedure TRemoteFunction.StreamIn(const Reader: AReaderEx);
begin
  FCaller.StreamIn(Reader);
end;

function TRemoteFunction.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  Result := FCaller.GetField(FieldName, Scope, FieldType);
end;

procedure TRemoteFunction.SetField(const FieldName: String; const Value: TObject);
begin
  FCaller.SetField(FieldName, Value);
end;

procedure TRemoteFunction.DeleteField(const FieldName: String);
begin
  FCaller.DeleteField(FieldName);
end;

function TRemoteFunction.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := FCaller.CallField(FieldName, Parameters);
end;

function TRemoteFunction.GetParameters: TParameterAttributesArray;
begin
  if not FParametersUpdated then
    begin
      // Cache parameters locally
      FParameters := FCaller.GetParameters;
      FParametersUpdated := True;
    end;
  Result := FParameters;
end;

function TRemoteFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  Result := FCaller.Call(Scope, Parameters);
end;

function TRemoteFunction.GetMachineCode: Pointer;
begin
  Result := nil;
end;

function TRemoteFunction.CreateLocalScope(const Scope: ABlaiseType;
    const Parameters: Array of TObject): ABlaiseType;
begin
  Result := nil;
end;



{                                                                              }
{ TRemoteNameSpace                                                             }
{                                                                              }
constructor TRemoteNameSpace.Create(
    const RemoteNameSpace: ARootRemoteNameSpace; const ObjectID: String);
begin
  inherited Create;
  ObjectAddReference(RemoteNameSpace);
  FRemoteNameSpace := RemoteNameSpace;
  FObjectID := ObjectID;
  FCaller := TRemoteInstanceCaller.Create(RemoteNameSpace, ObjectID);
end;

destructor TRemoteNameSpace.Destroy;
begin
  FreeAndNil(FCaller);
  ObjectReleaseReferenceAndNil(FRemoteNameSpace);
  inherited Destroy;
end;

function TRemoteNameSpace.GetAsUTF8: String;
begin
  Result := FCaller.GetAsUTF8;
end;

function TRemoteNameSpace.GetAsBlaise: String;
begin
  Result := FCaller.GetAsBlaise;
end;

procedure TRemoteNameSpace.SetAsUTF8(const Value: String);
begin
  FCaller.SetAsUTF8(Value);
end;

function TRemoteNameSpace.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := FCaller.GetField(FieldName, Scope, FieldType);
end;

procedure TRemoteNameSpace.SetField(const FieldName: String;
    const Value: TObject);
begin
  FCaller.SetField(FieldName, Value);
end;

procedure TRemoteNameSpace.DeleteField(const FieldName: String);
begin
  FCaller.DeleteField(FieldName);
end;

function TRemoteNameSpace.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := FCaller.CallField(FieldName, Parameters);
end;

function TRemoteNameSpace.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
begin
  Result := FCaller.GetNameSpace(RootNameSpace, Name, Position);
end;

function TRemoteNameSpace.Exists(const Key: String): Boolean;
begin
  Result := FCaller.Exists(Key);
end;

function TRemoteNameSpace.GetItem(const Key: String): TObject;
begin
  Result := FCaller.GetItem(Key);
end;

procedure TRemoteNameSpace.SetItem(const Key: String;
    const Value: TObject);
begin
  FCaller.SetItem(Key, Value);
end;

procedure TRemoteNameSpace.Delete(const Key: String);
begin
  FCaller.Delete(Key);
end;

function TRemoteNameSpace.Directory(const Key: String): TObject;
begin
  Result := FCaller.Directory(Key);
end;



{                                                                              }
{ TRemoteObject                                                                }
{                                                                              }
constructor TRemoteObject.Create(const RemoteNameSpace: ARootRemoteNameSpace;
    const ObjectID: String);
begin
  inherited Create;
  ObjectAddReference(RemoteNameSpace);
  FRemoteNameSpace := RemoteNameSpace;
  FObjectID := ObjectID;
  FCaller := TRemoteInstanceCaller.Create(RemoteNameSpace, ObjectID);
end;

destructor TRemoteObject.Destroy;
begin
  FreeAndNil(FCaller);
  ObjectReleaseReferenceAndNil(FRemoteNameSpace);
  inherited Destroy;
end;

function TRemoteObject.RPC(const Method: String;
    const Parameters: Array of String;
    const MinResponse, MaxResponse: Integer): StringArray;
begin
  Result := FRemoteNameSpace.RPC(FObjectID, Method, Parameters, MinResponse,
      MaxResponse);
end;

function TRemoteObject.GetAsString: String;
begin
  Result := FCaller.GetAsString;
end;

function TRemoteObject.GetAsUTF8: String;
begin
  Result := FCaller.GetAsUTF8;
end;

function TRemoteObject.GetAsBlaise: String;
begin
  Result := FCaller.GetAsBlaise;
end;

procedure TRemoteObject.SetAsString(const Value: String);
begin
  FCaller.SetAsString(Value);
end;

procedure TRemoteObject.SetAsUTF8(const Value: String);
begin
  FCaller.SetAsUTF8(Value);
end;

function TRemoteObject.Duplicate: TObject;
begin
  Result := FCaller.Duplicate;
end;

procedure TRemoteObject.Assign(const Source: TObject);
begin
  FCaller.Assign(Source);
end;

function TRemoteObject.IsEqual(const T: TObject): Boolean;
begin
  Result := FCaller.IsEqual(T);
end;

function TRemoteObject.Compare(const T: TObject): TCompareResult;
begin
  Result := FCaller.Compare(T);
end;

function TRemoteObject.HashValue: LongWord;
begin
  Result := FCaller.HashValue;
end;

function TRemoteObject.GetTypeID: Byte;
begin
  Result := FCaller.GetTypeID;
end;

procedure TRemoteObject.StreamOut(const Writer: AWriterEx);
begin
  FCaller.StreamOut(Writer);
end;

procedure TRemoteObject.StreamIn(const Reader: AReaderEx);
begin
  FCaller.StreamIn(Reader);
end;

function TRemoteObject.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var R : StringArray;
    T : Byte;
begin
  R := nil;
  Result := nil;
  if IsSystemFieldName(FieldName) then
    begin
      // ASimpleType
      if StrMatchLeft(FieldName, '__GetAs', False) then
        if StrEqualNoCase(FieldName, '__GetAsBoolean__') then
          Result := GetImmutableBoolean(FCaller.GetAsBoolean) else
        if StrEqualNoCase(FieldName, '__GetAsInteger__') then
          Result := GetImmutableInteger(FCaller.GetAsInteger) else
        if StrEqualNoCase(FieldName, '__GetAsFloat__') then
          Result := TTFloat.Create(FCaller.GetAsFloat) else
        if StrEqualNoCase(FieldName, '__GetAsDateTime__') then
          Result := TTDateTime.Create(FCaller.GetAsDateTime) else
      if Assigned(Result) then
        begin
          Scope := self;
          FieldType := bfObject;
          exit;
        end;
      if StrMatchLeft(FieldName, '__SetAs', False) and
        (StrEqualNoCase(FieldName, '__SetAsBoolean__') or
         StrEqualNoCase(FieldName, '__SetAsInteger__') or
         StrEqualNoCase(FieldName, '__SetAsFloat__') or
         StrEqualNoCase(FieldName, '__SetAsDateTime__')) then
        begin
          Scope := self;
          FieldType := bfCall;
          exit;
        end;
      // ABlaiseIterator
      if StrEqualNoCase(FieldName, '__EOF__') then
        begin
          R := RPC('ABlaiseIterator.EOF', [], 1, 1);
          Result := GetImmutableBoolean(R[0] = '1');
        end else
      if StrEqualNoCase(FieldName, '__Next__') then
        begin
          R := RPC('ABlaiseIterator.Next', [], 1, 1);
          Result := FRemoteNameSpace.GetObject(R[0]);
        end else
      // Collection
      if StrEqualNoCase(FieldName, '__GetCount__') then
        begin
          R := RPC('ACollection.GetCount', [], 1, 1);
          Result := GetImmutableInteger(StrToInt(R[0]));
        end else
      // ABlaiseObject
      if StrEqualNoCase(FieldName, '__IsSimpleType__') then
        begin
          T := GetTypeID;
          if TypeIDIsSimpleType(T) then
            Result := GetImmutableBoolean(True) else
          if T = BLAISE_TYPE_ID_OBJECT then
            Result := FCaller.GetField(FieldName, Scope, FieldType)
          else
            Result := GetImmutableBoolean(False);
        end else
      if StrEqualNoCase(FieldName, '__IsTypeDefinition__') then
        begin
          T := GetTypeID;
          if TypeIDIsTypeDefinition(T) then
            Result := GetImmutableBoolean(True) else
          if T = BLAISE_TYPE_ID_OBJECT then
            Result := FCaller.GetField(FieldName, Scope, FieldType)
          else
            Result := GetImmutableBoolean(False);
        end;
      if Assigned(Result) then
        begin
          Scope := self;
          FieldType := bfObject;
          exit;
        end;
    end;
  // inherited implementation
  Result := inherited GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // remote call
  Result := FCaller.GetField(FieldName, Scope, FieldType);
end;

function TRemoteObject.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
var F : Boolean;
    P : TObject;
begin
  Result := nil;
  F := IsSystemFieldName(FieldName);
  if F then
    // ABlaiseType
    if StrEqualNoCase(FieldName, '__SetAsString__') or
       StrEqualNoCase(FieldName, '__SetAsUTF8__') or
       StrEqualNoCase(FieldName, '__SetAsUTF16__') or
       StrEqualNoCase(FieldName, '__Assign__') or
       StrEqualNoCase(FieldName, '__IsEqual__') or
       StrEqualNoCase(FieldName, '__Compare__') then
      Result := inherited CallField(FieldName, Parameters)
    else
    // ASimpleType interface
    if StrMatchLeft(FieldName, '__SetAs', False) then
      begin
        ValidateParamCount(1, 1, Parameters);
        P := Parameters[0];
        if StrEqualNoCase(FieldName, '__SetAsBoolean__') then
          FCaller.SetAsBoolean(ObjectGetAsBoolean(P)) else
        if StrEqualNoCase(FieldName, '__SetAsInteger__') then
          FCaller.SetAsInteger(ObjectGetAsInteger(P)) else
        if StrEqualNoCase(FieldName, '__SetAsFloat__') then
          FCaller.SetAsFloat(ObjectGetAsFloat(P)) else
        if StrEqualNoCase(FieldName, '__SetAsDateTime__') then
          FCaller.SetAsDateTime(ObjectGetAsDateTime(P))
        else
          F := False;
      end
    else
      F := False;
  if not F then
    // remote call
    Result := FCaller.CallField(FieldName, Parameters);
end;

procedure TRemoteObject.SetField(const FieldName: String;
    const Value: TObject);
begin
  FCaller.SetField(FieldName, Value);
end;

procedure TRemoteObject.DeleteField(const FieldName: String);
begin
  FCaller.DeleteField(FieldName);
end;



{                                                                              }
{ ARootRemoteNameSpaceHandler                                                  }
{                                                                              }
constructor ARootRemoteNameSpaceHandler.Create(const RootNameSpace: ANameSpace);
begin
  inherited Create;
  FCaller := TRemoteInstanceCaller.Create(self, '/');
  ObjectAddReference(RootNameSpace);
  FRootNameSpace := RootNameSpace;
  FLocalObjects := TObjectDictionaryByString.Create;
  FRemoteObjects := TObjectDictionaryByString.Create;
end;

destructor ARootRemoteNameSpaceHandler.Destroy;
begin
  FreeAndNil(FRemoteObjects);
  FreeAndNil(FLocalObjects);
  ObjectReleaseReferenceAndNil(FRootNameSpace);
  FreeAndNil(FCaller);
  inherited Destroy;
end;

function ARootRemoteNameSpaceHandler.GetRemoteObject(const ObjID: String): ABlaiseType;
var I : Boolean;
    C : Byte;
begin
  if FRemoteObjects.FindItemByString(ObjID, TObject(Result)) then
    exit;
  rpcDecodeHandleValue(ObjID, I, C);
  Case C of
    BLAISE_TYPE_ID_GEN_BlaiseType :
      Result := TRemoteBlaiseType.Create(self, ObjID);
    BLAISE_TYPE_ID_GEN_Function :
      Result := TRemoteFunction.Create(self, ObjID);
    BLAISE_TYPE_ID_GEN_NameSpace :
      Result := TRemoteNameSpace.Create(self, ObjID);
  else
    Result := TRemoteObject.Create(self, ObjID);
  end;
  FRemoteObjects.AddItemByString(ObjID, Result);
end;

function ARootRemoteNameSpaceHandler.GetLocalObject(const ObjID: String): ABlaiseType;
begin
  Result := ABlaiseType(FLocalObjects[ObjID]);
end;

function ARootRemoteNameSpaceHandler.GetLocalObjectTypeID(const Obj: TObject): Byte;
begin
  if Obj is TRemoteObject then
    Result := TRemoteObject(Obj).GetTypeID else
  if Obj is ABlaiseObject then
    Result := BLAISE_TYPE_ID_OBJECT else
  if Obj is ANameSpace then
    Result := BLAISE_TYPE_ID_GEN_NameSpace else
  if Obj is AFunction then
    Result := BLAISE_TYPE_ID_GEN_Function else
  if Obj is ABlaiseType then
    Result := BLAISE_TYPE_ID_GEN_BlaiseType
  else
    Result := BLAISE_TYPE_ID_VALUE_Unknown;
end;

function ARootRemoteNameSpaceHandler.GetRPCResponse(const Obj: ABlaiseType;
    const MethodID: String; const Parameters: Array of String;
    var ErrorReason, ErrorMessage: String): StringArray;
var L : Integer;
    P : Integer;
    V : TObject;
    S : ABlaiseType;
    T : TBlaiseFieldType;
    A : ObjectArray;
    I : Integer;
    NotFound : Boolean;
begin
  Assert(Assigned(Obj));
  NotFound := False;
  Result := nil;
  L := Length(Parameters);
  if StrMatchLeft(MethodID, 'ABlaiseType.', False) then
    begin
      // ABlaiseType methods
      if StrEqualNoCase(MethodID, 'ABlaiseType.GetAsString') and (L = 0) then
        Result := AsStringArray([ObjectGetAsString(Obj)]) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.GetAsUTF8') and (L = 0) then
        Result := AsStringArray([ObjectGetAsUTF8(Obj)]) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.Assign') and (L = 1) then
        ObjectAssign(Obj, GetObject(Parameters[0])) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.Duplicate') then
        Result := AsStringArray([GetObjectID(ObjectDuplicate(Obj))]) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.HashValue') then
        Result := AsStringArray([IntToStr(ObjectHashValue(Obj))]) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.GetField') and (L = 1) then
        begin
          V := Obj.GetField(Parameters[0], S, T);
          Result := AsStringArray([GetObjectID(S), IntToStr(Ord(T)),
              GetObjectID(V)]);
        end else
      if StrEqualNoCase(MethodID, 'ABlaiseType.SetField') and (L = 2) then
        Obj.SetField(Parameters[0], GetObject(Parameters[1])) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.DeleteField') and (L = 1) then
        Obj.DeleteField(Parameters[0]) else
      if StrEqualNoCase(MethodID, 'ABlaiseType.CallField') and (L >= 1) then
        begin
          SetLength(A, L - 1);
          For I := 0 to L - 2 do
            A[I] := GetObject(Parameters[I + 1]);
          V := Obj.CallField(Parameters[0], A);
          Result := AsStringArray([GetObjectID(V)]);
        end
      else
        NotFound := True;
    end else
  if StrMatchLeft(MethodID, 'ASimpleType.', False) then
    begin
      // ASimpleType methods
      if StrEqualNoCase(MethodID, 'ASimpleType.GetAsInteger') and (L = 0) then
        Result := AsStringArray([IntToStr(ObjectGetAsInteger(Obj))]) else
      if StrEqualNoCase(MethodID, 'ASimpleType.GetAsFloat') and (L = 0) then
        Result := AsStringArray([FloatToStr(ObjectGetAsFloat(Obj))]) else
      if StrEqualNoCase(MethodID, 'ASimpleType.GetAsCurency') and (L = 0) then
        Result := AsStringArray([FloatToStr(ObjectGetAsFloat(Obj))]) else
      if StrEqualNoCase(MethodID, 'ASimpleType.GetAsDateTime') and (L = 0) then
        Result := AsStringArray([DateTimeToStr(ObjectGetAsDateTime(Obj))]) else
      if StrEqualNoCase(MethodID, 'ASimpleType.GetAsBoolean') and (L = 0) then
        Result := AsStringArray([iif(ObjectGetAsBoolean(Obj), '1', '0')]) else
      if StrEqualNoCase(MethodID, 'ASimpleType.SetAsInteger') and (L = 1) then
        ObjectSetAsInteger(Obj, StrToInt64(Parameters[0])) else
      if StrEqualNoCase(MethodID, 'ASimpleType.SetAsFloat') and (L = 1) then
        ObjectSetAsFloat(Obj, StrToFloat(Parameters[0])) else
      if StrEqualNoCase(MethodID, 'ASimpleType.SetAsCurrency') and (L = 1) then
        ObjectSetAsFloat(Obj, StrToFloat(Parameters[0])) else
      if StrEqualNoCase(MethodID, 'ASimpleType.SetAsDateTime') and (L = 1) then
        ObjectSetAsFloat(Obj, StrToDateTime(Parameters[0])) else
      if StrEqualNoCase(MethodID, 'ASimpleType.SetAsBoolean') and (L = 1) then
        ObjectSetAsBoolean(Obj, Parameters[0] = '1')
      else
        NotFound := True;
    end else
  if StrMatchLeft(MethodID, 'ANameSpace.', False) then
    begin
      // ANameSpace methods
      if StrEqualNoCase(MethodID, 'ANameSpace.GetNameSpace') and (L = 2) then
        begin
          P := StrToIntDef(Parameters[1], 0);
          V := ObjectGetNameSpace(FRootNameSpace, Obj, Parameters[0], P);
          Result := AsStringArray([IntToStr(P), GetObjectID(V)]);
        end else
      if StrEqualNoCase(MethodID, 'ANameSpace.Exists') and (L = 1) then
        Result := AsStringArray([rpcEncodeBooleanValue(
            ObjectNameSpaceExists(Obj, Parameters[0]))]) else
      if StrEqualNoCase(MethodID, 'ANameSpace.GetItem') and (L = 1) then
        Result := AsStringArray([GetObjectID(
            ObjectNameSpaceGetItem(Obj, Parameters[0]))]) else
      if StrEqualNoCase(MethodID, 'ANameSpace.SetItem') and (L = 2) then
        ObjectNameSpaceSetItem(Obj, Parameters[0], GetObject(Parameters[1])) else
      if StrEqualNoCase(MethodID, 'ANameSpace.Delete') and (L = 1) then
        ObjectNameSpaceDelete(Obj, Parameters[0]) else
      if StrEqualNoCase(MethodID, 'ANameSpace.Directory') and (L = 1) then
        Result := AsStringArray([GetObjectID(
            ObjectNameSpaceDirectory(Obj, Parameters[0]))])
      else
      NotFound := True;
    end
  else
    NotFound := True;
  // Invalid method
  if NotFound then
    begin
      ErrorReason := 'INVALID_REQUEST';
      ErrorMessage := 'Invalid request';
    end;
end;

function ARootRemoteNameSpaceHandler.GetAsUTF8: String;
begin
  Result := FCaller.GetAsUTF8;
end;

function ARootRemoteNameSpaceHandler.GetAsBlaise: String;
begin
  Result := FCaller.GetAsBlaise;
end;

procedure ARootRemoteNameSpaceHandler.SetAsUTF8(const Value: String);
begin
  FCaller.SetAsUTF8(Value);
end;

function ARootRemoteNameSpaceHandler.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := FCaller.GetField(FieldName, Scope, FieldType);
end;

procedure ARootRemoteNameSpaceHandler.SetField(const FieldName: String;
    const Value: TObject);
begin
  FCaller.SetField(FieldName, Value);
end;

procedure ARootRemoteNameSpaceHandler.DeleteField(const FieldName: String);
begin
  FCaller.DeleteField(FieldName);
end;

function ARootRemoteNameSpaceHandler.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := FCaller.CallField(FieldName, Parameters);
end;

function ARootRemoteNameSpaceHandler.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
begin
  Result := FCaller.GetNameSpace(RootNameSpace, Name, Position);
end;

function ARootRemoteNameSpaceHandler.Exists(const Key: String): Boolean;
begin
  Result := FCaller.Exists(Key);
end;

function ARootRemoteNameSpaceHandler.GetItem(const Key: String): TObject;
begin
  Result := FCaller.GetItem(Key);
end;

procedure ARootRemoteNameSpaceHandler.SetItem(const Key: String;
    const Value: TObject);
begin
  FCaller.SetItem(Key, Value);
end;

procedure ARootRemoteNameSpaceHandler.Delete(const Key: String);
begin
  FCaller.Delete(Key);
end;

function ARootRemoteNameSpaceHandler.Directory(const Key: String): TObject;
begin
  Result := FCaller.Directory(Key);
end;



end.

