{                                                                              }
{                         Blaise data structures v0.03                         }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{               Its original file name is cBlaiseStructs.pas                   }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise data structures.                               }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseStructs from cDataStructs.                }
{   05/03/2003  0.02  Revision.                                                }
{   26/04/2003  0.03  Added Repr function.                                     }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseStructs;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cStreams,
  cTypes,
  cArrays,
  cDictionaries,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructsSimple,
  cBlaiseStructsCollections;



{                                                                              }
{ TIdentifierType                                                              }
{   A Blaise type definition for an identifier type.                           }
{                                                                              }
type
  TIdentifierType = class(ALocalisedTypeDefinition)
  protected
    FIdentifier : String;

  public
    constructor Create(const Identifier: String);

    { ATypeDefinition                                                          }
    function  ResolveType: ATypeDefinition; override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  IsVariablesAutoInstanciate: Boolean; override;
    property  Identifier: String read FIdentifier;
    function  GetTypeDefID: Byte; override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TValueReferenceByIdentifier                                                  }
{                                                                              }
type
  TValueReferenceByIdentifier = class(AValueReference)
  protected
    FScope      : ABlaiseType;
    FIdentifier : String;

  public
    constructor Create(const Scope: ABlaiseType; const Identifier: String);

    procedure AssignValue(const Value: TObject); override;
    function  GetValue: TObject; override;
  end;



{                                                                              }
{ TValueReferenceByReference                                                   }
{                                                                              }
type
  TValueReferenceByReference = class(AValueReference)
  protected
    FReference : AValueReference;

  public
    constructor Create(const Reference: AValueReference);

    procedure AssignValue(const Value: TObject); override;
    function  GetValue: TObject; override;
  end;



{                                                                              }
{ TValueReferenceByIndex                                                       }
{                                                                              }
type
  TValueReferenceByIndex = class(AValueReference)
  protected
    FValueReference : AValueReference;
    FIndex          : TObject;
    FReversedIndex  : Boolean;

  public
    constructor Create(const ValueReference: AValueReference;
                const Index: TObject; const ReversedIndex: Boolean);
    destructor Destroy; override;

    procedure AssignValue(const Value: TObject); override;
    function  GetValue: TObject; override;
  end;
  EValueReferenceByIndex = class(Exception);



{                                                                              }
{ TBlaiseScope                                                                 }
{   A Blaise scope implementation.                                             }
{                                                                              }
{   The implementation stores its entries using the inherited dictionary.      }
{   Reference counting is managed for ABlaiseType items.                       }
{                                                                              }
type
  TBlaiseScope = class(TObjectDictionaryByString)
  protected
    procedure RaiseError(const Msg: String);

    function  GetItem(const Key: TObject): TObject; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear; override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    procedure DeleteField(const FieldName: String); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;

    { TBlaiseScope                                                             }
    procedure ReleaseField(const FieldName: String);
  end;
  EBlaiseScope = class(Exception);



{                                                                              }
{ TParentedScope                                                               }
{   Blaise scope with a parent scope.                                          }
{                                                                              }
type
  TParentedScope = class(TBlaiseScope)
  protected
    FParentScope : ABlaiseType;

  public
    constructor Create(const ParentScope: ABlaiseType);

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    property  ParentScope: ABlaiseType read FParentScope;
  end;



{                                                                              }
{ TUnitInterfaceScope                                                          }
{   Scope for unit interfaces.                                                 }
{                                                                              }
type
  TUnitInterfaceScope = class(TBlaiseScope)
  protected
    FImplementationScope : TBlaiseScope;

  public
    property  ImplementationScope: TBlaiseScope read FImplementationScope;
    procedure ExportToScope(const Scope: ABlaiseType); virtual; abstract;
  end;



{                                                                              }
{ AApplicationScope                                                            }
{                                                                              }
type
  AApplicationScope = class(TBlaiseScope)
  public
    procedure AddUsedUnit(const UnitName: String); virtual; abstract;
    function  GetUnit(const UnitName: String): TUnitInterfaceScope; virtual; abstract;
  end;



{                                                                              }
{ TRecordFieldFieldDefinition                                                  }
{                                                                              }
type
  TRecordFieldFieldDefinition = class(TVariableFieldDefinition)
  public
    function  GetFieldID: Byte; override;
  end;
  TRecordFieldFieldDefinitionArray = Array of TRecordFieldFieldDefinition;



{                                                                              }
{ TRecordType                                                                  }
{                                                                              }
type
  TRecordType = class(ALocalisedTypeDefinition)
  protected
    FParentRecord : TRecordType;
    FDefinition   : TRecordFieldFieldDefinitionArray;

  public
    constructor Create(const ParentRecord: TRecordType;
                const Definition: TRecordFieldFieldDefinitionArray);
    destructor Destroy; override;

    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;

    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTRecord                                                                     }
{                                                                              }
type
  TTRecord = class(TBlaiseScope)
  protected
    FRecordType : TRecordType;

    procedure AddInheritedFieldDefinitions(const RecordType: TRecordType);
    procedure InitRecord(const RecordType: TRecordType);

  public
    constructor Create(const RecordType: TRecordType);
    class function CreateInstance: AType; override;

    procedure Assign(const Source: TObject); override;
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ TSubrangeValue                                                               }
{   Holder for a value from a range type.                                      }
{                                                                              }
type
  TSubrangeValue = class(TTInteger)
  protected
    FSubrangeType : ASubrangeTypeDefinition;

  public
    constructor Create(const SubrangeType: ASubrangeTypeDefinition;
                const Value: Int64);
    destructor Destroy; override;

    class function CreateInstance: AType; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ TIntegerSubrangeType                                                         }
{   Range type implementation for an integer range.                            }
{                                                                              }
type
  TIntegerSubrangeType = class(ASubrangeTypeDefinition)
  public
    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
  end;



{                                                                              }
{ TEnumeratedRangeType                                                         }
{   Range type implementation for a range of enumerated identifiers.           }
{                                                                              }
type
  { TEnumeratedValueDefinition                                                 }
  TEnumeratedValueDefinition = record
    Identifier : String;
    Value      : Int64;
  end;
  PEnumeratedValueDefinition = ^TEnumeratedValueDefinition;
  TEnumeratedValueDefinitionArray = Array of TEnumeratedValueDefinition;

  { TEnumeratedRangeType                                                       }
  TEnumeratedSubrangeType = class(ASubrangeTypeDefinition)
  protected
    FValueDefinitions : TEnumeratedValueDefinitionArray;

  public
    constructor Create(const Min, Max: Int64;
                const ValueDefinitions: TEnumeratedValueDefinitionArray);

    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTStream                                                                     }
{   ABlaiseType implementation for a Stream.                                   }
{                                                                              }
type
  TTStream = class(ABlaiseStream)
  protected
    FItemType    : ATypeDefinition;
    FStream      : AStream;
    FStreamOwner : Boolean;

    function  GetSize: Int64; override;
    procedure SetSize(const Size: Int64); override;
    function  GetPosition: Int64; override;
    procedure SetPosition(const Position: Int64); override;
    function  GetReader: AReaderEx; override;
    function  GetWriter: AWriterEx; override;

  public
    constructor Create(const ItemType: ATypeDefinition;
                const Stream: AStream; const StreamOwner: Boolean);
    destructor Destroy; override;

    function  Read(var Buffer; const Size: Integer): Integer; override;
    function  Write(const Buffer; const Size: Integer): Integer; override;
    function  EOF: Boolean; override;
    procedure Truncate; override;
    function  IsOpen: Boolean; override;
    procedure Reopen; override;
  end;



{                                                                              }
{ TStreamType                                                                  }
{   ATypeDefinition implementation for a Stream type.                          }
{                                                                              }
type
  TStreamType = class(ALocalisedTypeDefinition)
  protected
    FItemType : ATypeDefinition;

  public
    constructor Create(const ItemType: ATypeDefinition);
    destructor Destroy; override;

    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  IsVariablesAutoInstanciate: Boolean; override;
    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ Scope function implementations                                               }
{                                                                              }
type
  { TLengthFunction                                                            }
  TLengthFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TAbsFunction                                                               }
  TAbsFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TSqrFunction                                                               }
  TSqrFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TSqrtFunction                                                              }
  TSqrtFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TExpFunction                                                               }
  TExpFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TLnFunction                                                                }
  TLnFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TSinFunction                                                               }
  TSinFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TCosFunction                                                               }
  TCosFunction = class(AUnaryScopeFunction)
    constructor Create;
  end;

  { TRandomFunction                                                            }
  TRandomFunction = class(AFunction)
  protected
    FParams : TParameterAttributesArray;

  public
    constructor Create;
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;

  { TCopyFunction                                                              }
  TCopyFunction = class(AFunction)
  protected
    FParams : TParameterAttributesArray;

  public
    constructor Create;
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;

  { TIncProcedure                                                              }
  TIncProcedure = class(AFunction)
  public
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;

  { TDecProcedure                                                              }
  TDecProcedure = class(AFunction)
  public
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;

  { TReprFunction                                                              }
  TReprFunction = class(AFunction)
  protected
    FParams : TParameterAttributesArray;

  public
    constructor Create;
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;



implementation

uses
  { Fundamentals }
  cRandom,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs;



{                                                                              }
{ TIdentifierType                                                              }
{                                                                              }
constructor TIdentifierType.Create(const Identifier: String);
begin
  inherited Create;
  FIdentifier := Identifier;
end;

function TIdentifierType.ResolveType: ATypeDefinition;
begin
  Assert(Assigned(FDefinitionScope), 'Assigned(FDefinitionScope)');
  Result := FDefinitionScope.GetValueAsTypeDefinition(FIdentifier, True);
end;

function TIdentifierType.CreateTypeInstance: TObject;
begin
  Result := ResolveType.CreateTypeInstance;
end;

function TIdentifierType.IsType(const Value: TObject): Boolean;
begin
  Result := ResolveType.IsType(Value);
end;

function TIdentifierType.IsVariablesAutoInstanciate: Boolean;
begin
  Result := ResolveType.IsVariablesAutoInstanciate;
end;

function TIdentifierType.GetField(const FieldName: String;
  var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := ResolveType.GetField(FieldName, Scope, FieldType);
end;

function TIdentifierType.CallField(const FieldName: String;
  const Parameters: array of TObject): TObject;
begin
  Result := ResolveType.CallField(FieldName, Parameters);
end;

function TIdentifierType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DEF_Identifier;
end;

procedure TIdentifierType.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedString(FIdentifier);
end;

procedure TIdentifierType.StreamIn(const Reader: AReaderEx);
begin
  FIdentifier := Reader.ReadPackedString;
end;



{                                                                              }
{ AValueReference implementations                                              }
{                                                                              }

{                                                                              }
{ TValueReferenceByIdentifier                                                  }
{                                                                              }
constructor TValueReferenceByIdentifier.Create(const Scope: ABlaiseType; const Identifier: String);
begin
  inherited Create;
  Assert(Assigned(Scope), 'Assigned(Scope)'); 
  FScope := Scope;
  FIdentifier := Identifier;
end;

procedure TValueReferenceByIdentifier.AssignValue(const Value: TObject);
begin
  FScope.AssignIdentifier(FIdentifier, Value);
end;

function TValueReferenceByIdentifier.GetValue: TObject;
var S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  Result := FScope.GetValue(FIdentifier, False, S, T);
end;



{                                                                              }
{ TValueReferenceByReference                                                   }
{                                                                              }
constructor TValueReferenceByReference.Create(const Reference: AValueReference);
begin
  inherited Create;
  Assert(Assigned(Reference), 'Assigned(Reference)');
  FReference := Reference;
end;

procedure TValueReferenceByReference.AssignValue(const Value: TObject);
begin
  FReference.AssignValue(Value);
end;

function TValueReferenceByReference.GetValue: TObject;
begin
  Result := FReference.GetValue;
end;



{                                                                              }
{ TValueReferenceByIndex                                                       }
{                                                                              }
constructor TValueReferenceByIndex.Create(const ValueReference: AValueReference;
    const Index: TObject; const ReversedIndex: Boolean);
begin
  inherited Create;
  Assert(Assigned(ValueReference), 'Assigned(ValueReference)');
  Assert(Assigned(Index), 'Assigned(Index)');
  FValueReference := ValueReference;
  FIndex := Index;
  FReversedIndex := ReversedIndex;
end;

destructor TValueReferenceByIndex.Destroy;
begin
  FreeAndNil(FIndex);
  FreeAndNil(FValueReference);
  inherited Destroy;
end;

procedure TValueReferenceByIndex.AssignValue(const Value: TObject);
begin
  ObjectAssignIndexedValue(FValueReference.GetValue, FIndex, Value,
      FReversedIndex);
end;

function TValueReferenceByIndex.GetValue: TObject;
begin
  Result := ObjectGetIndexedValue(FValueReference.GetValue, FIndex,
      FReversedIndex);
end;



{                                                                              }
{ TBlaiseScope                                                                 }
{                                                                              }
constructor TBlaiseScope.Create;
begin
  inherited CreateEx(TObjectDictionary.CreateEx(nil, nil,
      {IsItemOwner=}      False,
      {KeysCaseSensitive=}False,
      {AddOnSet=}         True,
      {DuplicatesAction=} ddAccept));
end;

destructor TBlaiseScope.Destroy;
begin
  if Assigned(FDictionary) then
    Clear;
  inherited Destroy;
end;

procedure TBlaiseScope.RaiseError(const Msg: String);
begin
  raise EBlaiseScope.Create(ObjectClassName(self) + ': ' + Msg);
end;

procedure ScopeObjectClear(const A: TObject);
begin
  if A is ABlaiseType then
    ABlaiseType(A).ReleaseReference else
  if A is TScopeValue then
    A.Free;
end;

procedure TBlaiseScope.Clear;
var I : Integer;
begin
  For I := 0 to FDictionary.Count - 1 do
    begin
      ScopeObjectClear(FDictionary.GetItemByIndex(I));
      FDictionary.SetItemByIndex(I, nil);
    end;
  FDictionary.Clear;
end;

function TBlaiseScope.GetItem(const Key: TObject): TObject;
begin
  Result := inherited GetItem(Key);
  if Result is AValueReference then
    Result := AValueReference(Result).GetValue;
end;

function TBlaiseScope.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if FDictionary.LocateItem(FieldName, Result) >= 0 then
    begin
      Scope := self;
      FieldType := bfObject;
    end
  else
    Scope := nil;
end;

procedure TBlaiseScope.SetField(const FieldName: String; const Value: TObject);
var I : Integer;
    V : TObject;
begin
  I := FDictionary.LocateItem(FieldName, V);
  if I >= 0 then
    begin
      if V = Value then
        exit;
      ObjectAddReference(Value);
      FDictionary.SetItemByIndex(I, Value);
      ScopeObjectClear(V);
    end
  else
    begin
      ObjectAddReference(Value);
      FDictionary.Add(FieldName, Value);
    end;
end;

procedure TBlaiseScope.DeleteField(const FieldName: String);
var I : Integer;
    V : TObject;
begin
  I := FDictionary.LocateItem(FieldName, V);
  if I >= 0 then
    begin
      FDictionary.DeleteItemByIndex(I);
      ScopeObjectClear(V);
    end;
end;

function TBlaiseScope.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := nil;
end;

procedure TBlaiseScope.ReleaseField(const FieldName: String);
begin
  FDictionary.Delete(FieldName);
end;



{                                                                              }
{ TParentedScope                                                               }
{                                                                              }
constructor TParentedScope.Create(const ParentScope: ABlaiseType);
begin
  inherited Create;
  FParentScope := ParentScope;
end;

function TParentedScope.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  // Get field in this scope
  Result := inherited GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Get field in parent scope
  if Assigned(FParentScope) then
    Result := FParentScope.GetField(FieldName, Scope, FieldType);
end;



{                                                                              }
{ TRecordFieldFieldDefinition                                                  }
{                                                                              }
function TRecordFieldFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_RECORD_VAR;
end;



{                                                                              }
{ TTRecord                                                                     }
{                                                                              }
constructor TTRecord.Create(const RecordType: TRecordType);
begin
  inherited Create;
  InitRecord(RecordType);
end;

procedure TTRecord.AddInheritedFieldDefinitions(const RecordType: TRecordType);
var I : Integer;
begin
  For I := 0 to Length(RecordType.FDefinition) - 1 do
    if not FDictionary.HasKey(
        TRecordFieldFieldDefinition(RecordType.FDefinition[I]).Identifier) then
      RecordType.FDefinition[I].AddToScope(self, RecordType.FDefinitionScope);
  if Assigned(RecordType.FParentRecord) then
    AddInheritedFieldDefinitions(RecordType.FParentRecord);
end;

procedure TTRecord.InitRecord(const RecordType: TRecordType);
begin
  FRecordType := RecordType;
  if not Assigned(RecordType) then
    exit;
  ScopeAddFieldDefinitions(self, AScopeFieldDefinitionArray(RecordType.FDefinition),
      RecordType.FDefinitionScope);
  if Assigned(RecordType.FParentRecord) then
    AddInheritedFieldDefinitions(RecordType.FParentRecord);
end;

class function TTRecord.CreateInstance: AType;
begin
  Result := TTRecord.Create(nil);
end;

procedure TTRecord.Assign(const Source: TObject);
var I, L : Integer;
    K    : TObject;
    S    : String;
begin
  if Source is TTRecord then
    begin
      Clear;
      InitRecord(TTRecord(Source).FRecordType);
    end else
  if Source is ABlaiseDictionary then
    begin
      Clear;
      InitRecord(FRecordType);
      L := ABlaiseDictionary(Source).GetCount;
      For I := 0 to L - 1 do
        begin
          K := ABlaiseDictionary(Source).GetKeyByIndex(I);
          S := ObjectGetAsUTF8(K);
          AssignIdentifier(S, ABlaiseDictionary(Source).Item[K]);
        end;
    end
  else
    inherited Assign(Source);
end;

function TTRecord.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_RECORD;
end;



{                                                                              }
{ TRecordType                                                                  }
{                                                                              }
constructor TRecordType.Create(const ParentRecord: TRecordType; const Definition: TRecordFieldFieldDefinitionArray);
begin
  inherited Create;
  FParentRecord := ParentRecord;
  FDefinition := Definition;
end;

destructor TRecordType.Destroy;
begin
  FreeObjectArray(FDefinition);
  inherited Destroy;
end;

function TRecordType.CreateTypeInstance: TObject;
begin
  Result := TTRecord.Create(self);
end;

function TRecordType.IsType(const Value: TObject): Boolean;
begin
  Result := (Value is TTRecord) and (TTRecord(Value).FRecordType = self);
end;

function TRecordType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_RECORD;
end;

procedure TRecordType.StreamOut(const Writer: AWriterEx);
var I, L : Integer;
begin
  StreamOutTypeDefinition(Writer, FParentRecord);
  L := Length(FDefinition);
  Writer.WriteLongInt(L);
  For I := 0 to L - 1 do
    StreamOutFieldDefinition(Writer, FDefinition[I]);
end;

procedure TRecordType.StreamIn(const Reader: AReaderEx);
var I, L : Integer;
begin
  FParentRecord := StreamInTypeDefinition(Reader) as TRecordType;
  L := Reader.ReadLongInt;
  SetLength(FDefinition, L);
  For I := 0 to L - 1 do
    FDefinition[I] := StreamInFieldDefinition(Reader) as TRecordFieldFieldDefinition;
end;



{                                                                              }
{ TSubrangeValue                                                               }
{                                                                              }
constructor TSubrangeValue.Create(const SubrangeType: ASubrangeTypeDefinition;
    const Value: Int64);
begin
  inherited Create(Value);
  Assert(Assigned(SubrangeType), 'Assigned(SubrangeType)');
  FSubrangeType := SubrangeType;
  ObjectAddReference(FSubrangeType);
end;

destructor TSubrangeValue.Destroy;
begin
  ObjectReleaseReferenceAndNil(FSubrangeType);
  inherited Destroy;
end;

class function TSubrangeValue.CreateInstance: AType;
begin
  Result := TSubrangeValue.Create(nil, 0);
end;

function TSubrangeValue.Duplicate: TObject;
begin
  Result := TSubrangeValue.Create(FSubrangeType, FValue);
end;

procedure TSubrangeValue.Assign(const Source: TObject);
var V : Int64;
begin
  if Source is TSubrangeValue then
    begin
      if not FSubrangeType.IsType(Source) then
        TypeError('Incompatible range types');
      V := TSubrangeValue(Source).FValue;
    end else
    V := ObjectGetAsInteger(Source);
  if (V < FSubrangeType.Min) or (V > FSubrangeType.Max) then
    TypeError('Subrange value out of bounds');
  FValue := V;
end;

function TSubrangeValue.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Subrange;
end;



{                                                                              }
{ TIntegerSubrangeType                                                         }
{                                                                              }
procedure TIntegerSubrangeType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
end;

function TIntegerSubrangeType.CreateTypeInstance: TObject;
begin
  Result := TSubrangeValue.Create(self, FMin);
end;

function TIntegerSubrangeType.IsType(const Value: TObject): Boolean;
var T : ASubrangeTypeDefinition;
begin
  Result := False;
  if Value is TSubrangeValue then
    begin
      T := TSubrangeValue(Value).FSubrangeType;
      if T = self then
        Result := True else
      if T is TIntegerSubrangeType then
        Result := (TIntegerSubrangeType(T).Min = FMin) and
                  (TIntegerSubrangeType(T).Max = FMax);
    end;
end;

function TIntegerSubrangeType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_SUBRANGE_INT;
end;



{                                                                              }
{ TEnumeratedSubrangeType                                                      }
{                                                                              }
constructor TEnumeratedSubrangeType.Create(const Min, Max: Int64;
    const ValueDefinitions: TEnumeratedValueDefinitionArray);
begin
  inherited Create(Min, Max);
  FValueDefinitions := ValueDefinitions;
end;

procedure TEnumeratedSubrangeType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
var I : Integer;
begin
  For I := 0 to Length(FValueDefinitions) - 1 do
    DefinitionScope.SetConstant(FValueDefinitions[I].Identifier,
        TSubrangeValue.Create(self, FValueDefinitions[I].Value));
end;

function TEnumeratedSubrangeType.CreateTypeInstance: TObject;
begin
  Result := TSubrangeValue.Create(self, FMin);
end;

function TEnumeratedSubrangeType.IsType(const Value: TObject): Boolean;
begin
  Result := (Value is TSubrangeValue) and
            (TSubrangeValue(Value).FSubrangeType = self);
end;

function TEnumeratedSubrangeType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_SUBRANGE_ENUMERATION;
end;

procedure TEnumeratedSubrangeType.StreamOut(const Writer: AWriterEx);
var I, L : Integer;
    P    : PEnumeratedValueDefinition;
begin
  inherited StreamOut(Writer);
  L := Length(FValueDefinitions);
  Writer.WriteLongInt(L);
  For I := 0 to L - 1 do
    begin
      P := @FValueDefinitions[I];
      Writer.WritePackedString(P^.Identifier);
      Writer.WriteInt64(P^.Value);
    end;
end;

procedure TEnumeratedSubrangeType.StreamIn(const Reader: AReaderEx);
var I, L : Integer;
    P    : PEnumeratedValueDefinition;
begin
  inherited StreamIn(Reader);
  L := Reader.ReadLongInt;
  SetLength(FValueDefinitions, L);
  For I := 0 to L - 1 do
    begin
      P := @FValueDefinitions[I];
      P^.Identifier := Reader.ReadPackedString;
      P^.Value := Reader.ReadInt64;
    end;
end;



{                                                                              }
{ TTStream                                                                     }
{   ABlaiseType implementation for a Stream.                                   }
{                                                                              }
constructor TTStream.Create(const ItemType: ATypeDefinition;
    const Stream: AStream; const StreamOwner: Boolean);
begin
  inherited Create;
  ObjectAddReference(ItemType);
  FItemType := ItemType;
  FStream := Stream;
  FStreamOwner := StreamOwner;
end;

destructor TTStream.Destroy;
begin
  ObjectReleaseReference(FItemType);
  if FStreamOwner then
    FreeAndNil(FStream);
  inherited Destroy;
end;

function TTStream.GetSize: Int64;
begin
  Result := FStream.Size;
end;

procedure TTStream.SetSize(const Size: Int64);
begin
  FStream.Size := Size;
end;

function TTStream.GetPosition: Int64;
begin
  Result := FStream.Position;
end;

procedure TTStream.SetPosition(const Position: Int64);
begin
  FStream.Position := Position;
end;

function TTStream.GetReader: AReaderEx;
begin
  Result := FStream.Reader;
end;

function TTStream.GetWriter: AWriterEx;
begin
  Result := FStream.Writer;
end;

function TTStream.Read(var Buffer; const Size: Integer): Integer;
begin
  Result := FStream.Read(Buffer, Size);
end;

function TTStream.Write(const Buffer; const Size: Integer): Integer;
begin
  Result := FStream.Write(Buffer, Size);
end;

function TTStream.EOF: Boolean;
begin
  Result := FStream.EOF;
end;

procedure TTStream.Truncate;
begin
  FStream.Truncate;
end;

function TTStream.IsOpen: Boolean;
begin
  Result := True;
end;

procedure TTStream.Reopen;
begin
  SetPosition(0);
end;



{                                                                              }
{ TStreamType                                                                  }
{   ATypeDefinition implementation for a Stream.                               }
{                                                                              }
constructor TStreamType.Create(const ItemType: ATypeDefinition);
begin
  inherited Create;
  ObjectAddReference(ItemType);
  FItemType := ItemType;
end;

destructor TStreamType.Destroy;
begin
  ObjectReleaseReference(FItemType);
  inherited Destroy;
end;

{$WARNINGS OFF}
function TStreamType.CreateTypeInstance: TObject;
begin
  TypeDefinitionError('Can not instanciate');
end;
{$WARNINGS ON}

function TStreamType.IsType(const Value: TObject): Boolean;
begin
  Result := Value is TTStream;
end;

function TStreamType.IsVariablesAutoInstanciate: Boolean;
begin
  Result := False;
end;

function TStreamType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_STREAM;
end;

procedure TStreamType.StreamOut(const Writer: AWriterEx);
begin
  StreamOutTypeDefinition(Writer, FItemType);
end;

procedure TStreamType.StreamIn(const Reader: AReaderEx);
begin
  FItemType := StreamInTypeDefinition(Reader);
end;



{                                                                              }
{ TLengthFunction                                                              }
{                                                                              }
constructor TLengthFunction.Create;
begin
  inherited Create(OperationGetLength);
end;



{                                                                              }
{ TAbsFunction                                                                 }
{                                                                              }
constructor TAbsFunction.Create;
begin
  inherited Create(OperationAbs);
end;



{                                                                              }
{ TSqrFunction                                                                 }
{                                                                              }
constructor TSqrFunction.Create;
begin
  inherited Create(OperationSqr);
end;



{                                                                              }
{ TSqrtFunction                                                                }
{                                                                              }
constructor TSqrtFunction.Create;
begin
  inherited Create(OperationSqrt);
end;



{                                                                              }
{ TExpFunction                                                                 }
{                                                                              }
constructor TExpFunction.Create;
begin
  inherited Create(OperationExp);
end;



{                                                                              }
{ TLnFunction                                                                  }
{                                                                              }
constructor TLnFunction.Create;
begin
  inherited Create(OperationLn);
end;



{                                                                              }
{ TSinFunction                                                                 }
{                                                                              }
constructor TSinFunction.Create;
begin
  inherited Create(OperationSin);
end;



{                                                                              }
{ TCosFunction                                                                 }
{                                                                              }
constructor TCosFunction.Create;
begin
  inherited Create(OperationCos);
end;



{                                                                              }
{ TRandomFunction                                                              }
{                                                                              }
constructor TRandomFunction.Create;
begin
  inherited Create;
  SetLength(FParams, 1);
  FParams[0] := [paOptional];
end;

function TRandomFunction.GetParameters: TParameterAttributesArray;
begin
  Result := FParams;
end;

function TRandomFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  ValidateParameters(FParams, Parameters);
  if Length(Parameters) > 0 then
    Result := GetImmutableInteger(RandomInt64(ObjectGetAsInteger(Parameters[0])))
  else
    Result := TTFloat.Create(RandomFloat);
end;



{                                                                              }
{ TCopyFunction                                                                }
{                                                                              }
constructor TCopyFunction.Create;
begin
  inherited Create;
  SetLength(FParams, 3);
  FParams[0] := [];
  FParams[1] := [paOptional];
  FParams[2] := [paOptional];
end;

function TCopyFunction.GetParameters: TParameterAttributesArray;
begin
  Result := FParams;
end;

function TCopyFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var V : TObject;
    L : Integer;
begin
  Result := nil;
  ValidateParameters(FParams, Parameters);
  V := Parameters[0];
  if V is AValueReference then
    V := AValueReference(V).GetValue;
  if Assigned(V) then
    begin
      L := Length(Parameters);
      if L = 1 then
        Result := ObjectDuplicate(V) else
      if L = 2 then
        ParamCountError(3, 2) else
        if V is TTString then
          begin
            Result := TTString(V).CreateInstance;
            TTString(Result).AsString := Copy(TTString(V).AsString,
                ObjectGetAsInteger(Parameters[1]),
                ObjectGetAsInteger(Parameters[2]));
          end else
        if V is TTUnicodeString then
          begin
            Result := TTUnicodeString(V).CreateInstance;
            TTUnicodeString(Result).AsUTF16 := Copy(TTUnicodeString(V).AsUTF16,
                ObjectGetAsInteger(Parameters[1]),
                ObjectGetAsInteger(Parameters[2]));
          end else
        if V is ABlaiseArrayBase then
          begin
            Result := ABlaiseArrayBase(V).CreateInstance;
            ABlaiseArrayBase(Result).Assign(
                ABlaiseArrayBase(V).InternalArray.DuplicateRange(
                    ObjectGetAsInteger(Parameters[1]),
                    ObjectGetAsInteger(Parameters[2])));
          end else
        if V is ABlaiseObject then
          Result := ABlaiseObject(V).Evaluate('__Copy__',
              [Parameters[1], Parameters[2]], False, True, False)
        else
          FunctionError('Range copy not supported on type');
    end;
end;



{                                                                              }
{ TIncProcedure                                                                }
{                                                                              }
function TIncProcedure.GetParameters: TParameterAttributesArray;
begin
  SetLength(Result, 2);
  Result[0] := [paReference, paOptional];
end;


function TIncProcedure.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var V : TObject;
begin
  V := AValueReference(Parameters[0]).GetValue;
  if Length(Parameters) > 1 then
    ObjectInc(V, Parameters[1])
  else
    ObjectInc(V);
  Result := nil;
end;



{                                                                              }
{ TDecProcedure                                                                }
{                                                                              }
function TDecProcedure.GetParameters: TParameterAttributesArray;
begin
  SetLength(Result, 2);
  Result[0] := [paReference, paOptional];
end;


function TDecProcedure.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var V : TObject;
begin
  V := AValueReference(Parameters[0]).GetValue;
  if Length(Parameters) > 1 then
    ObjectDec(V, Parameters[1])
  else
    ObjectDec(V);
  Result := nil;
end;



{                                                                              }
{ TReprFunction                                                                }
{                                                                              }
constructor TReprFunction.Create;
begin
  inherited Create;
  SetLength(FParams, 1);
  FParams[0] := [];
end;

function TReprFunction.GetParameters: TParameterAttributesArray;
begin
  Result := FParams;
end;

function TReprFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  ValidateParameters(FParams, Parameters);
  Result := TTString.Create(ObjectGetAsBlaise(Parameters[0]));
end;



end.

