{                                                                              }
{                      Blaise collection structures v0.05                      }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{          Its original file name is cBlaiseStructsCollections.pas             }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise collections.                                   }
{                                                                              }
{ Revision history:                                                            }
{   08/03/2003  0.01  Create cBlaiseStructsCollections from cBlaiseStructs.    }
{   09/03/2003  0.02  Added vectors.                                           }
{   14/03/2003  0.03  Added matrices.                                          }
{   26/04/2003  0.04  Dictionary support for key and item type definitions.    }
{   25/05/2003  0.05  Matrix revision.                                         }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseStructsCollections;

interface

uses
  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cTypes,
  cArrays,
  cDictionaries,
  cMatrix,

  { Blaise }
  cBlaiseTypes;



{                                                                              }
{ ABlaiseArrayBase                                                             }
{   Base class for Blaise arrays implemented with AArray.                      }
{                                                                              }
type
  ABlaiseArrayBase = class(ABlaiseArray)
  protected
    FArray    : AArray;
    FItemType : ATypeDefinition;

    function  GetCount: Integer; override;
    procedure SetCount(const Count: Integer); override;

  public
    constructor Create(const ItemType: ATypeDefinition);
    destructor Destroy; override;
    property  InternalArray: AArray read FArray;

    procedure Delete(const Idx: Integer); override;
    procedure Sort; override;
  end;



{                                                                              }
{ TTStringArray                                                                }
{   A Blaise string array.                                                     }
{                                                                              }
type
  TTStringArray = class(ABlaiseArrayBase)
  protected
    procedure Init; override;
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    procedure Append(const Value: TObject); override;
  end;



{                                                                              }
{ TTIntegerArray                                                               }
{   A Blaise integer array.                                                    }
{                                                                              }
type
  TTIntegerArray = class(ABlaiseArrayBase)
  protected
    procedure Init; override;
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    procedure Append(const Value: TObject); override;
  end;



{                                                                              }
{ TTFloatArray                                                                 }
{   A Blaise float array.                                                      }
{                                                                              }
type
  TTFloatArray = class(ABlaiseArrayBase)
  protected
    procedure Init; override;
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    procedure Append(const Value: TObject); override;
  end;



{                                                                              }
{ TTBooleanArray                                                               }
{   A Blaise boolean array.                                                    }
{                                                                              }
type
  TTBooleanArray = class(ABlaiseArrayBase)
  protected
    procedure Init; override;
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    procedure Append(const Value: TObject); override;
  end;



{                                                                              }
{ TTArray                                                                      }
{   A Blaise array that stores values of any type.                             }
{                                                                              }
type
  TTArray = class(ABlaiseArrayBase)
  protected
    procedure Init; override;
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    destructor Destroy; override;

    procedure Clear; override;
    procedure Assign(const V: ObjectArray); reintroduce; overload;

    procedure Append(const Value: TObject); override;
    procedure Delete(const Idx: Integer); override;
  end;



{                                                                              }
{ TArrayType                                                                   }
{   A Blaise type definition for an array.                                     }
{                                                                              }
type
  TArrayType = class(ALocalisedTypeDefinition)
  protected
    FItemType : ATypeDefinition;

  public
    constructor Create(const ItemType: ATypeDefinition);
    destructor Destroy; override;

    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ ABlaiseVectorBase                                                            }
{   Base class for Blaise vectors implemented with AArray.                     }
{                                                                              }
type
  ABlaiseVectorBase = class(ABlaiseVector)
  protected
    FVector : AArray;

    { ABlaiseVector                                                            }
    function  GetCount: Integer; override;
    procedure SetCount(const Count: Integer); override;

  public
    constructor Create(const Vector: AArray);
    destructor Destroy; override;

    procedure Assign(const Source: TObject); override;
  end;



{                                                                              }
{ TTFloatVector                                                                }
{   A Blaise float vector.                                                     }
{                                                                              }
type
  TTFloatVector = class(ABlaiseVectorBase)
  protected
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    constructor Create;
    class function CreateInstance: AType; override;

    { ABlaiseMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure ReversedAdd(const V: TObject); override;
    procedure ReversedSubtract(const V: TObject); override;
    procedure ReversedMultiply(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
    function  BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
              const LeftOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTObjectVector                                                               }
{   A Blaise object vector.                                                    }
{                                                                              }
{   The object vector can store numeric values of any type.                    }
{                                                                              }
type
  TTObjectVector = class(ABlaiseVectorBase)
  protected
    { ABlaiseVector                                                            }
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;
    procedure SetCount(const Count: Integer); override;

    { TTObjectVector                                                           }
    function  CheckVectorSizeMatch(const Size: Integer): Integer;
    function  DoBinaryOperation(const OperationFunc: TBinaryOperationFunc;
              const V: TObject): Boolean;
    function  DoReversedBinaryOperation(const OperationFunc: TBinaryOperationFunc;
              const V: TObject): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    { AType                                                                    }
    class function CreateInstance: AType; override;
    procedure Assign(const Source: TObject); override;

    { ABlaiseMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure ReversedAdd(const V: TObject); override;
    procedure ReversedSubtract(const V: TObject); override;
    procedure ReversedMultiply(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
    function  BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
              const LeftOp: TObject): TObject; override;
  end;
  EObjectVector = class(EBlaiseVector);



{                                                                              }
{ TTVector                                                                     }
{   A Blaise vector.                                                           }
{                                                                              }
{   Internally the implementation maintains a polymorphic vector, based on     }
{   the actual values stored in the vector. When the current vector has        }
{   insufficient precision to store a value, the vector is promoted to a       }
{   new type. The promotion order is 1) Float 2) Object.                       }
{                                                                              }
type
  TInternalVectorType = (
      vtEmpty,
      vtFloat,
      vtObject);
  TTVector = class(ABlaiseVector)
  protected
    FVector : ABlaiseVectorBase;
    FCount  : Integer;
    FType   : TInternalVectorType;

    procedure InvalidIndexError;
    procedure SetVectorType(const VectorType: TInternalVectorType);
    procedure EnsurePrecision(const VectorType: TInternalVectorType);
    procedure EnsureItemPrecision(const Item: TObject);
    procedure EnsureOperationPrecision(const V: TObject);

    { ABlaiseVector                                                            }
    function  GetCount: Integer; override;
    procedure SetCount(const Count: Integer); override;
    function  GetItem(const Idx: Integer): TObject; override;
    procedure SetItem(const Idx: Integer; const Value: TObject); override;

  public
    constructor Create;
    destructor Destroy; override;

    property  VectorType: TInternalVectorType read FType write SetVectorType;

    {AType                                                                     }
    class function CreateInstance: AType; override;
    procedure Assign(const Source: TObject); override;
    procedure Clear; override;

    { ABlaiseMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure ReversedAdd(const V: TObject); override;
    procedure ReversedSubtract(const V: TObject); override;
    procedure ReversedMultiply(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
    function  BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
              const LeftOp: TObject): TObject; override;
  end;



{                                                                              }
{ TVectorType                                                                  }
{   A Blaise type definition for a vector.                                     }
{                                                                              }
type
  TVectorType = class(ATypeDefinition)
  public
    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTMatrix                                                                     }
{   A Blaise matrix.                                                           }
{                                                                              }
{   FRows holds an array of TTVector instances.                                }
{                                                                              }
type
  TTMatrix = class(ABlaiseMatrix)
  protected
    FColCount : Integer;
    FRows     : TTArray;

    function  GetRowCount: Integer; override;
    procedure SetRowCount(const Count: Integer); override;
    function  GetColCount: Integer; override;
    procedure SetColCount(const Count: Integer); override;
    function  GetRow(const Idx: Integer): ABlaiseVector; override;
    function  GetItem(const Row, Col: Integer): TObject; override;
    procedure SetItem(const Row, Col: Integer; const Value: TObject); override;

  public
    constructor Create;
    destructor Destroy; override;

    { AType                                                                    }
    class function CreateInstance: AType; override;
    procedure Assign(const Source: TObject); override;

    { ABlaiseMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure ReversedAdd(const V: TObject); override;
    procedure ReversedSubtract(const V: TObject); override;
    procedure ReversedMultiply(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
    function  BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
              const LeftOp: TObject): TObject; override;
  end;
  EObjectMatrix = class(EBlaiseMatrix);



{                                                                              }
{ TMatrixType                                                                  }
{   A Blaise type definition for a matrix.                                     }
{                                                                              }
type
  TMatrixType = class(ATypeDefinition)
  public
    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TObjectDictionaryByString                                                    }
{   ABlaiseDictionary implementation where the key is a string and the value   }
{   is an object.                                                              }
{                                                                              }
type
  TObjectDictionaryByString = class(ABlaiseDictionary)
  protected
    FDictionary : TObjectDictionary;

    function  GetItem(const Key: TObject): TObject; override;
    procedure SetItem(const Key, Value: TObject); override;

    function  GetItemByString(const Key: String): TObject;
    procedure SetItemByString(const Key: String; const Value: TObject);

  public
    constructor Create;
    constructor CreateEx(const Dictionary: TObjectDictionary);
    destructor Destroy; override;

    property  Dictionary: TObjectDictionary read FDictionary;
    property  ItemByString[const Key: String]: TObject read GetItemByString
              write SetItemByString; default;
    function  FindItemByString(const Key: String; var Value: TObject): Boolean;
    procedure AddItemByString(const Key: String; const Value: TObject);
    procedure DeleteByString(const Key: String);

    { ABlaiseDictionary                                                        }
    procedure AddItem(const Key, Value: TObject); override;
    procedure Delete(const Key: TObject); override;
    function  GetCount: Integer; override;
    function  GetKeyByIndex(const Idx: Integer): TObject; override;
  end;



{                                                                              }
{ TTObjectDictionaryByString                                                   }
{   TObjectDictionaryByString implementation used by the dictionary type.      }
{                                                                              }
type
  TTObjectDictionaryByString = class(TObjectDictionaryByString)
  protected
    FItemType : ATypeDefinition;

    function  CoerceValue(const Value: TObject): TObject;
    procedure SetItem(const Key, Value: TObject); override;

  public
    constructor Create(const ItemType: ATypeDefinition);
    destructor Destroy; override;
    
    procedure AddItem(const Key, Value: TObject); override;
  end;



{                                                                              }
{ TTDictionaryByString                                                         }
{   ABlaiseDictionary implementation where key is a string.                    }
{                                                                              }
type
  TDictionaryItemType = (diString, diInteger, diInt64, diExtended);
  TTDictionaryByString = class(ABlaiseDictionary)
  protected
    FDictionary : ADictionary;
    FItemType   : TDictionaryItemType;

    function  GetItem(const Key: TObject): TObject; override;
    procedure SetItem(const Key, Value: TObject); override;

  public
    constructor Create(const Dictionary: ADictionary);
    destructor Destroy; override;

    { ABlaiseDictionary                                                        }
    procedure AddItem(const Key, Value: TObject); override;
    procedure Delete(const Key: TObject); override;
    function  GetCount: Integer; override;
    function  GetKeyByIndex(const Idx: Integer): TObject; override;
  end;



{                                                                              }
{ TTDictionary                                                                 }
{   ABlaiseDictionary implementation where the key and value are objects.      }
{                                                                              }
type
  TTDictionary = class(ABlaiseDictionary)
  protected
    FKeyType  : ATypeDefinition;
    FItemType : ATypeDefinition;
    FKeys     : TObjectArray;
    FValues   : TObjectArray;
    FLookup   : Array of IntegerArray;

    { ABlaiseDictionary                                                        }
    function  GetItem(const Key: TObject): TObject; override;
    procedure SetItem(const Key, Value: TObject); override;

    { TObjectDictionary                                                        }
    procedure Rehash;
    function  LocateKey(const Key: TObject; var LookupIdx: Integer;
              const ErrorIfNotFound: Boolean): Integer;
    procedure DeleteByIndex(const Idx: Integer; const Hash: Integer);
    function  CoerceValue(const Value: TObject): TObject;

  public
    constructor Create(const KeyType, ItemType: ATypeDefinition);
    destructor Destroy; override;

    { AType                                                                    }
    class function CreateInstance: AType; override;

    { ABlaiseDictionary                                                        }
    procedure AddItem(const Key, Value: TObject); override;
    procedure Delete(const Key: TObject); override;
    function  GetCount: Integer; override;
    function  GetKeyByIndex(const Idx: Integer): TObject; override;

    { TObjectDictionary interface                                              }
    function  LocateItem(const Key: TObject; var Value: TObject): Boolean;
    function  HasKey(const Key: TObject): Boolean;
    function  KeyIndex(const Key: TObject; const ErrorIfNotFound: Boolean): Integer;
    function  GetItemByIndex(const Idx: Integer): TObject;
    procedure SetItemByIndex(const Idx: Integer; const Value: TObject);
    procedure DeleteItemByIndex(const Idx: Integer);
  end;
  EObjectDictionaryByObject = class(EBlaiseDictionary);



{                                                                              }
{ TDictionaryType                                                              }
{   ATypeDefinition implementation for dictionary types.                       }
{                                                                              }
type
  TDictionaryType = class(ALocalisedTypeDefinition)
  protected
    FKeyType  : ATypeDefinition;
    FItemType : ATypeDefinition;

  public
    constructor Create(const KeyType, ItemType: ATypeDefinition);
    destructor Destroy; override;

    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cVectors,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructsSimple;



{                                                                              }
{ ABlaiseArrayBase                                                             }
{                                                                              }
constructor ABlaiseArrayBase.Create(const ItemType: ATypeDefinition);
begin
  inherited Create;
  Assert(Assigned(FArray));
  ObjectAddReference(ItemType);
  FItemType := ItemType;
end;

destructor ABlaiseArrayBase.Destroy;
begin
  FreeAndNil(FArray);
  ObjectReleaseReferenceAndNil(FItemType);
  inherited Destroy;
end;

function ABlaiseArrayBase.GetCount: Integer;
begin
  Assert(Assigned(FArray));
  Result := FArray.Count;
end;

procedure ABlaiseArrayBase.SetCount(const Count: Integer);
begin
  Assert(Assigned(FArray));
  FArray.Count := Count;
end;

procedure ABlaiseArrayBase.Delete(const Idx: Integer);
begin
  FArray.Delete(Idx, 1);
end;

procedure ABlaiseArrayBase.Sort;
begin
  FArray.Sort;
end;



{                                                                              }
{ TTStringArray                                                                }
{                                                                              }
procedure TTStringArray.Init;
begin
  inherited Init;
  FArray := TStringArray.Create;
end;

function TTStringArray.GetItem(const Idx: Integer): TObject;
begin
  Result := TTString.Create(AStringArray(FArray).Item[Idx]);
end;

procedure TTStringArray.SetItem(const Idx: Integer; const Value: TObject);
begin
  AStringArray(FArray).Item[Idx] := ObjectGetAsUTF8(Value);
end;

procedure TTStringArray.Append(const Value: TObject);
begin
  AStringArray(FArray).AppendItem(ObjectGetAsUTF8(Value));
end;



{                                                                              }
{ TTIntegerArray                                                               }
{                                                                              }
procedure TTIntegerArray.Init;
begin
  inherited Init;
  FArray := TInt64Array.Create;
end;

function TTIntegerArray.GetItem(const Idx: Integer): TObject;
begin
  Result := GetImmutableInteger(AInt64Array(FArray).Item[Idx]);
end;

procedure TTIntegerArray.SetItem(const Idx: Integer; const Value: TObject);
begin
  AInt64Array(FArray).Item[Idx] := ObjectGetAsInteger(Value);
end;

procedure TTIntegerArray.Append(const Value: TObject);
begin
  AInt64Array(FArray).AppendItem(ObjectGetAsInteger(Value));
end;



{                                                                              }
{ TTFloatArray                                                                 }
{                                                                              }
procedure TTFloatArray.Init;
begin
  inherited Init;
  FArray := TExtendedArray.Create;
end;

function TTFloatArray.GetItem(const Idx: Integer): TObject;
begin
  Result := TTFloat.Create(AExtendedArray(FArray).Item[Idx]);
end;

procedure TTFloatArray.SetItem(const Idx: Integer; const Value: TObject);
begin
  AExtendedArray(FArray).Item[Idx] := ObjectGetAsFloat(Value);
end;

procedure TTFloatArray.Append(const Value: TObject);
begin
  AExtendedArray(FArray).AppendItem(ObjectGetAsFloat(Value));
end;



{                                                                              }
{ TTBooleanArray                                                               }
{                                                                              }
procedure TTBooleanArray.Init;
begin
  inherited Init;
  FArray := TBitArray.Create;
end;

function TTBooleanArray.GetItem(const Idx: Integer): TObject;
begin
  Result := GetImmutableBoolean(ABitArray(FArray).Bit[Idx]);
end;

procedure TTBooleanArray.SetItem(const Idx: Integer; const Value: TObject);
begin
  ABitArray(FArray).Bit[Idx] := ObjectGetAsBoolean(Value);
end;

procedure TTBooleanArray.Append(const Value: TObject);
begin
  ABitArray(FArray).AppendItem(ObjectGetAsBoolean(Value));
end;



{                                                                              }
{ TTArray                                                                      }
{                                                                              }
destructor TTArray.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TTArray.Init;
begin
  inherited Init;
  FArray := TObjectArray.Create(nil, False);
end;

procedure TTArray.Clear;
var I: Integer;
begin
  if Assigned(FArray) then
    begin
      For I := FArray.Count - 1 downto 0 do
        ObjectReleaseReference(AObjectArray(FArray).Item[I]);
      FArray.Clear;
    end;
end;

procedure TTArray.Assign(const V: ObjectArray);
var I, L : Integer;
begin
  Clear;
  Assert(Assigned(FArray), 'Assigned(FArray)');
  L := Length(V);
  if L = 0 then
    exit;
  For I := 0 to L - 1 do
    ObjectAddReference(V[I]);
  AObjectArray(FArray).AppendArray(V);
end;

function TTArray.GetItem(const Idx: Integer): TObject;
begin
  Result := AObjectArray(FArray).Item[Idx];
  // initialize item value on first access
  if not Assigned(Result) then
    begin
      if not Assigned(FItemType) then
        Result := UnassignedValue
      else
        if FItemType.IsVariablesAutoInstanciate then
          Result := FItemType.CreateTypeInstance
        else
          Result := UnassignedValue;
      ObjectAddReference(Result);
      AObjectArray(FArray).Item[Idx] := Result;
    end;
end;

procedure TTArray.SetItem(const Idx: Integer; const Value: TObject);
var P, V : TObject;
begin
  if Assigned(FItemType) then
    V := FItemType.Coerce(Value)
  else
    V := Value;
  P := AObjectArray(FArray).Item[Idx];
  ObjectAddReference(V);
  ObjectReleaseReference(P);
  AObjectArray(FArray).Item[Idx] := V;
end;

procedure TTArray.Append(const Value: TObject);
begin
  ObjectAddReference(Value);
  AObjectArray(FArray).AppendItem(Value);
end;

procedure TTArray.Delete(const Idx: Integer);
begin
  ObjectReleaseReference(AObjectArray(FArray).Item[Idx]);
  inherited Delete(Idx);
end;



{                                                                              }
{ TArrayType                                                                   }
{                                                                              }
constructor TArrayType.Create(const ItemType: ATypeDefinition);
begin
  inherited Create;
  ObjectAddReference(ItemType);
  FItemType := ItemType;
end;

destructor TArrayType.Destroy;
begin
  ObjectReleaseReferenceAndNil(FItemType);
  inherited Destroy;
end;

procedure TArrayType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
  inherited SetDefinitionScope(DefinitionScope);
  if Assigned(FItemType) then
    FItemType.SetDefinitionScope(DefinitionScope);
end;

function TArrayType.CreateTypeInstance: TObject;
var T : ATypeDefinition;
begin
  Result := nil;
  if Assigned(FItemType) then
    begin
      T := FItemType.ResolveType;
      if T is TStringType then
        Result := TTStringArray.Create(FItemType) else
      if T is TIntegerType then
        Result := TTIntegerArray.Create(FItemType) else
      if T is TFloatType then
        Result := TTFloatArray.Create(FItemType) else
      if T is TBooleanType then
        Result := TTBooleanArray.Create(FItemType);
    end;
  if not Assigned(Result) then
    Result := TTArray.Create(FItemType);
end;

function TArrayType.IsType(const Value: TObject): Boolean;
var V    : TObject;
    T, U : ATypeDefinition;
begin
  if Value is AValueReference then
    V := AValueReference(Value).GetValue else
    V := Value;
  Result := V is ABlaiseArrayBase;
  if not Result then
    exit;
  T := ABlaiseArrayBase(V).FItemType;
  if Assigned(T) then
    T := T.ResolveType;
  U := FItemType;
  if Assigned(U) then
    U := U.ResolveType;
  Result := (T = U) or
            (Assigned(T) and Assigned(U) and (T.ClassType = U.ClassType));
end;

function TArrayType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_ARRAY;
end;

procedure TArrayType.StreamOut(const Writer: AWriterEx);
begin
  StreamOutTypeDefinition(Writer, FItemType);
end;

procedure TArrayType.StreamIn(const Reader: AReaderEx);
begin
  FItemType := StreamInTypeDefinition(Reader);
  ObjectAddReference(FItemType);
end;



{                                                                              }
{ ABlaiseVectorBase                                                            }
{                                                                              }
constructor ABlaiseVectorBase.Create(const Vector: AArray);
begin
  inherited Create;
  Assert(Assigned(Vector), 'Assigned(Vector)');
  FVector := Vector;
end;

destructor ABlaiseVectorBase.Destroy;
begin
  FreeAndNil(FVector);
  inherited Destroy;
end;

function ABlaiseVectorBase.GetCount: Integer;
begin
  Result := FVector.Count;
end;

procedure ABlaiseVectorBase.SetCount(const Count: Integer);
begin
  FVector.Count := Count;
end;

procedure ABlaiseVectorBase.Assign(const Source: TObject);
begin
  if Source is ABlaiseVectorBase then
    FVector.Assign(ABlaiseVectorBase(Source).FVector) else
  if Source is AArray then
    FVector.Assign(Source)
  else
    inherited Assign(Source);
end;



{                                                                              }
{ TTFloatVector                                                                }
{                                                                              }
constructor TTFloatVector.Create;
begin
  inherited Create(TVector.Create);
end;

class function TTFloatVector.CreateInstance: AType;
begin
  Result := TTFloatVector.Create;
end;

function TTFloatVector.GetItem(const Idx: Integer): TObject;
begin
  Result := TTFloat.Create(TVector(FVector).Item[Idx]);
end;

procedure TTFloatVector.SetItem(const Idx: Integer; const Value: TObject);
begin
  TVector(FVector).Item[Idx] := ObjectGetAsFloat(Value);
end;

procedure TTFloatVector.Negate;
begin
  TVector(FVector).Negate;
end;

procedure TTFloatVector.Add(const V: TObject);
begin
  if V is TTFloatVector then
    TVector(FVector).Add(TTFloatVector(V).FVector) else
  if ObjectIsSimpleType(V) then
    TVector(FVector).Add(ObjectGetAsFloat(V)) else
  if V is TTIntegerArray then
    TVector(FVector).Add(TInt64Array(TTIntegerArray(V).FArray)) else
  if V is TTFloatArray then
    TVector(FVector).Add(TExtendedArray(TTFloatArray(V).FArray))
  else
    inherited Add(V);
end;

procedure TTFloatVector.Subtract(const V: TObject);
begin
  if V is TTFloatVector then
    TVector(FVector).Subtract(TTFloatVector(V).FVector) else
  if ObjectIsSimpleType(V) then
    TVector(FVector).Subtract(ObjectGetAsFloat(V)) else
  if V is TTIntegerArray then
    TVector(FVector).Subtract(TInt64Array(TTIntegerArray(V).FArray)) else
  if V is TTFloatArray then
    TVector(FVector).Subtract(TExtendedArray(TTFloatArray(V).FArray))
  else
    inherited Subtract(V);
end;

procedure TTFloatVector.Multiply(const V: TObject);
begin
  if V is TTFloatVector then
    TVector(FVector).Multiply(TTFloatVector(V).FVector) else
  if ObjectIsSimpleType(V) then
    TVector(FVector).Multiply(ObjectGetAsFloat(V)) else
  if V is TTIntegerArray then
    TVector(FVector).Multiply(TInt64Array(TTIntegerArray(V).FArray)) else
  if V is TTFloatArray then
    TVector(FVector).Multiply(TExtendedArray(TTFloatArray(V).FArray))
  else
    inherited Multiply(V);
end;

procedure TTFloatVector.ReversedAdd(const V: TObject);
begin
  Add(V);
end;

procedure TTFloatVector.ReversedSubtract(const V: TObject);
begin
  TVector(FVector).Negate;
  Add(V);
end;

procedure TTFloatVector.ReversedMultiply(const V: TObject);
begin
  Multiply(V);
end;

function TTFloatVector.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if RightOp is TTVector then
        begin
          Result := TTVector.Create;
          TTVector(Result).Assign(self);
        end else
      if (RightOp is TTFloatVector) or ObjectIsFloat(RightOp) or
         ObjectIsInteger(RightOp) or (RightOp is TTFloatArray) or
         (RightOp is TTIntegerArray) then
        Result := Duplicate else
      if (RightOp is ABlaiseMathType) or (RightOp is ABlaiseArray) then
        begin
          Result := TTObjectVector.Create;
          TTObjectVector(Result).Assign(self);
        end;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTFloatVector.BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const LeftOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if (LeftOp is TTFloatVector) or ObjectIsFloat(LeftOp) or
         ObjectIsInteger(LeftOp) or (LeftOp is TTFloatArray) or
         (LeftOp is TTIntegerArray) then
        Result := Duplicate else
      if (LeftOp is ABlaiseMathType) or (LeftOp is ABlaiseArray) then
        begin
          Result := TTObjectVector.Create;
          TTObjectVector(Result).Assign(self);
        end;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpRightCoerce(Operation, LeftOp);
end;



{                                                                              }
{ TTObjectVector                                                               }
{                                                                              }
constructor TTObjectVector.Create;
begin
  inherited Create(TObjectArray.Create(nil, False));
end;

destructor TTObjectVector.Destroy;
var I : Integer;
begin
  if Assigned(FVector) then
    For I := FVector.Count - 1 downto 0 do
      ObjectReleaseReference(TObjectArray(FVector).Item[I]);
  inherited Destroy;
end;

class function TTObjectVector.CreateInstance: AType;
begin
  Result := TTObjectVector.Create;
end;

procedure TTObjectVector.SetCount(const Count: Integer);
var I : Integer;
begin
  For I := Count to FVector.Count - 1 do
    ObjectReleaseReference(TObjectArray(FVector).Item[I]);
  inherited SetCount(Count);
end;

function TTObjectVector.GetItem(const Idx: Integer): TObject;
begin
  Result := TObjectArray(FVector).Item[Idx];
end;

procedure TTObjectVector.SetItem(const Idx: Integer; const Value: TObject);
begin
  ObjectReleaseReference(TObjectArray(FVector).Item[Idx]);
  ObjectAddReference(Value);
  TObjectArray(FVector).Item[Idx] := Value;
end;

procedure TTObjectVector.Assign(const Source: TObject);
var I, L : Integer;
begin
  if Source is ABlaiseVector then
    begin
      L := ABlaiseVector(Source).Count;
      SetCount(L);
      For I := 0 to L - 1 do
        SetItem(I, ABlaiseVector(Source).Item[I]);
    end
  else
    inherited Assign(Source);
end;

function TTObjectVector.CheckVectorSizeMatch(const Size: Integer): Integer;
begin
  if Size <> GetCount then
    raise EObjectVector.Create('Vector sizes mismatch (' + IntToStr(GetCount) + ',' +
        IntToStr(Size) + ')');
  Result := Size;
end;

procedure TTObjectVector.Negate;
var I : Integer;
begin
  For I := 0 to GetCount - 1 do
    SetItem(I, OperationNegate(GetItem(I)));
end;

function TTObjectVector.DoBinaryOperation(const OperationFunc: TBinaryOperationFunc;
    const V: TObject): Boolean;
var I, L : Integer;
begin
  Result := True;
  if V is ABlaiseVector then
    begin
      L := CheckVectorSizeMatch(ABlaiseVector(V).Count);
      For I := 0 to L - 1 do
        SetItem(I, OperationFunc(GetItem(I), ABlaiseVector(V).Item[I]));
    end else
  if V is ABlaiseArray then
    begin
      L := CheckVectorSizeMatch(ABlaiseArray(V).Count);
      For I := 0 to L - 1 do
        SetItem(I, OperationFunc(GetItem(I), ABlaiseArray(V).Item[I]));
    end else
  if V is ABlaiseType then
    begin
      For I := 0 to GetCount - 1 do
        SetItem(I, OperationFunc(GetItem(I), V));
    end
  else
    Result := False;
end;

function TTObjectVector.DoReversedBinaryOperation(const OperationFunc: TBinaryOperationFunc;
    const V: TObject): Boolean;
var I, L : Integer;
begin
  Result := True;
  if V is ABlaiseVector then
    begin
      L := CheckVectorSizeMatch(ABlaiseVector(V).Count);
      For I := 0 to L - 1 do
        SetItem(I, OperationFunc(ABlaiseVector(V).Item[I], GetItem(I)));
    end else
  if V is ABlaiseArray then
    begin
      L := CheckVectorSizeMatch(ABlaiseArray(V).Count);
      For I := 0 to L - 1 do
        SetItem(I, OperationFunc(ABlaiseArray(V).Item[I], GetItem(I)));
    end else
  if V is ABlaiseType then
    begin
      For I := 0 to GetCount - 1 do
        SetItem(I, OperationFunc(V, GetItem(I)));
    end
  else
    Result := False;
end;

procedure TTObjectVector.Add(const V: TObject);
begin
  if not DoBinaryOperation(OperationAdd, V) then
    inherited Add(V);
end;

procedure TTObjectVector.Subtract(const V: TObject);
begin
  if not DoBinaryOperation(OperationSubtract, V) then
    inherited Subtract(V);
end;

procedure TTObjectVector.Multiply(const V: TObject);
begin
  if not DoBinaryOperation(OperationMultiply, V) then
    inherited Multiply(V);
end;

procedure TTObjectVector.ReversedAdd(const V: TObject);
begin
  if not DoReversedBinaryOperation(OperationAdd, V) then
    inherited ReversedAdd(V);
end;

procedure TTObjectVector.ReversedSubtract(const V: TObject);
begin
  if not DoReversedBinaryOperation(OperationSubtract, V) then
    inherited ReversedSubtract(V);
end;

procedure TTObjectVector.ReversedMultiply(const V: TObject);
begin
  if not DoReversedBinaryOperation(OperationMultiply, V) then
    inherited ReversedMultiply(V);
end;

function TTObjectVector.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if RightOp is TTVector then
        begin
          Result := TTVector.Create;
          TTVector(Result).Assign(self);
        end else
      if (RightOp is ABlaiseVector) or (RightOp is ABlaiseArray) or
         ObjectIsSimpleType(RightOp) then
        Result := Duplicate;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTObjectVector.BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const LeftOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if (LeftOp is ABlaiseVector) or (LeftOp is ABlaiseArray) or
         ObjectIsSimpleType(LeftOp) then
        Result := Duplicate;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpRightCoerce(Operation, LeftOp);
end;



{                                                                              }
{ TTVector                                                                     }
{                                                                              }
constructor TTVector.Create;
begin
  inherited Create;
  FType := vtEmpty;
end;

destructor TTVector.Destroy;
begin
  FreeAndNil(FVector);
  inherited Destroy;
end;

class function TTVector.CreateInstance: AType;
begin
  Result := TTVector.Create;
end;

procedure TTVector.InvalidIndexError;
begin
  raise EBlaiseVector.Create('Vector index out of bounds');
end;

procedure TTVector.SetVectorType(const VectorType: TInternalVectorType);
var V : ABlaiseVectorBase;
begin
  if VectorType = FType then
    exit;
  // Create vector
  V := nil;
  Case VectorType of
    vtFloat   : V := TTFloatVector.Create;
    vtObject  : V := TTObjectVector.Create;
  end;
  // Initialize vector
  if Assigned(V) then
    try
      // Vector is cleared if it changed to lower precision
      if Assigned(FVector) and (VectorType > FType) then
        V.Assign(FVector)
      else
        V.Count := FCount;
    except
      V.Free;
      raise;
    end;
  // Update state
  FreeAndNil(FVector);
  FVector := V;
  FType := VectorType;
end;

procedure TTVector.EnsurePrecision(const VectorType: TInternalVectorType);
begin
  // Check if current vector has more precision than VectorType
  if VectorType <= FType then
    exit;
  SetVectorType(VectorType);
  // Global assertion for this class
  Assert((FType = vtEmpty) or Assigned(FVector), '(FType = vtEmpty) or Assigned(FVector)');
end;

procedure TTVector.EnsureItemPrecision(const Item: TObject);
begin
  // Ensure current vector has precision for Item
  if ObjectIsInteger(Item) or ObjectIsFloat(Item) then
    EnsurePrecision(vtFloat)
  else
    EnsurePrecision(vtObject);
end;

function TTVector.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TTVector.SetCount(const Count: Integer);
var C : Integer;
begin
  C := MaxI(0, Count);
  if C = FCount then
    exit;
  FCount := C;
  if FType = vtEmpty then
    exit;
  Assert(Assigned(FVector), 'Assigned(FVector)');
  FVector.Count := C;
end;

function TTVector.GetItem(const Idx: Integer): TObject;
begin
  if (Idx < 0) or (Idx >= FCount) then
    InvalidIndexError;
  if FType = vtEmpty then
    Result := GetImmutableFloatZero
  else
    begin
      Assert(Assigned(FVector), 'Assigned(FVector)');
      Result := FVector.GetItem(Idx);
    end;
end;

procedure TTVector.SetItem(const Idx: Integer; const Value: TObject);
begin
  if (Idx < 0) or (Idx >= FCount) then
    InvalidIndexError;
  EnsureItemPrecision(Value);
  Assert(FType <> vtEmpty, 'FType <> vtEmpty');
  Assert(Assigned(FVector), 'Assigned(FVector)');
  FVector.SetItem(Idx, Value);
end;

procedure TTVector.Clear;
begin
  SetVectorType(vtEmpty);
end;

procedure TTVector.Assign(const Source: TObject);

  procedure AssignVector(const T: TInternalVectorType; const V: ABlaiseVector);
  begin
    SetVectorType(vtEmpty);
    SetCount(V.Count);
    SetVectorType(T);
    FVector.Assign(V);
  end;

begin
  if Source is TTVector then
    begin
      if TTVector(Source).FType = vtEmpty then
        SetVectorType(vtEmpty)
      else
        AssignVector(TTVector(Source).FType, TTVector(Source).FVector);
    end else
  if Source is TTFloatVector then
    AssignVector(vtFloat, TTFloatVector(Source)) else
  if Source is ABlaiseVector then
    AssignVector(vtObject, ABlaiseVector(Source)) else
  if Source is ABlaiseArray then
    begin
      SetVectorType(vtEmpty);
      SetCount(ABlaiseArray(Source).Count);
      SetVectorType(vtObject);
      FVector.Assign(Source);
    end
  else
    inherited Assign(Source);
end;

procedure TTVector.Negate;
begin
  if Assigned(FVector) then
    FVector.Negate;
end;

procedure TTVector.EnsureOperationPrecision(const V: TObject);
begin
  if V is TTVector then
    EnsurePrecision(TTVector(V).FType) else
  if ObjectIsInteger(V) or (V is TTFloatVector) or ObjectIsFloat(V) then
    EnsurePrecision(vtFloat)
  else
    EnsurePrecision(vtObject);
end;

procedure TTVector.Add(const V: TObject);
begin
  EnsureOperationPrecision(V);
  if V is TTVector then
    FVector.Add(TTVector(V).FVector)
  else
    FVector.Add(V);
end;

procedure TTVector.Subtract(const V: TObject);
begin
  EnsureOperationPrecision(V);
  if V is TTVector then
    FVector.Subtract(TTVector(V).FVector)
  else
    FVector.Subtract(V);
end;

procedure TTVector.Multiply(const V: TObject);
begin
  EnsureOperationPrecision(V);
  if V is TTVector then
    FVector.Multiply(TTVector(V).FVector)
  else
    FVector.Multiply(V);
end;

procedure TTVector.ReversedAdd(const V: TObject);
begin
  EnsureOperationPrecision(V);
  if V is TTVector then
    FVector.ReversedAdd(TTVector(V).FVector)
  else
    FVector.ReversedAdd(V);
end;

procedure TTVector.ReversedSubtract(const V: TObject);
begin
  EnsureOperationPrecision(V);
  if V is TTVector then
    FVector.ReversedSubtract(TTVector(V).FVector)
  else
    FVector.ReversedSubtract(V);
end;

procedure TTVector.ReversedMultiply(const V: TObject);
begin
  EnsureOperationPrecision(V);
  if V is TTVector then
    FVector.ReversedMultiply(TTVector(V).FVector)
  else
    FVector.ReversedMultiply(V);
end;

function TTVector.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if (RightOp is ABlaiseVector) or (RightOp is ABlaiseArray) or
         ObjectIsSimpleType(RightOp) then
        Result := Duplicate;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTVector.BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const LeftOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if (LeftOp is ABlaiseVector) or (LeftOp is ABlaiseArray) or
         ObjectIsSimpleType(LeftOp) then
        Result := Duplicate;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpRightCoerce(Operation, LeftOp);
end;



{                                                                              }
{ TVectorType                                                                  }
{                                                                              }
procedure TVectorType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
end;

function TVectorType.CreateTypeInstance: TObject;
begin
  Result := TTVector.Create;
end;

function TVectorType.IsType(const Value: TObject): Boolean;
begin
  Result := Value is TTVector;
end;

function TVectorType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_VECTOR;
end;

procedure TVectorType.StreamOut(const Writer: AWriterEx);
begin
end;

procedure TVectorType.StreamIn(const Reader: AReaderEx);
begin
end;



{                                                                              }
{ TTMatrix                                                                     }
{                                                                              }
constructor TTMatrix.Create;
begin
  inherited Create;
  FRows := TTArray.Create(nil);
end;

destructor TTMatrix.Destroy;
begin
  FreeAndNil(FRows);
  inherited Destroy;
end;

class function TTMatrix.CreateInstance: AType;
begin
  Result := TTMatrix.Create;
end;

function TTMatrix.GetRow(const Idx: Integer): ABlaiseVector;
var V : TObject;
begin
  V := FRows[Idx];
  if V = UnassignedValue then
    begin
      // create a new row on first access
      Result := TTVector.Create;
      Result.Count := FColCount;
      FRows[Idx] := Result;
    end
  else
    Result := TTVector(V);
end;

function TTMatrix.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

procedure TTMatrix.SetRowCount(const Count: Integer);
begin
  FRows.Count := Count;
end;

function TTMatrix.GetColCount: Integer;
begin
  Result := FColCount;
end;

procedure TTMatrix.SetColCount(const Count: Integer);
var I, N : Integer;
    V    : ABlaiseVector;
begin
  N := Count;
  if N < 0 then
    N := 0;
  if N = FColCount then
    exit;
  For I := 0 to FRows.Count - 1 do
    begin
      V := GetRow(I);
      if Assigned(V) then
        V.Count := N;
    end;
  FColCount := N;
end;

function TTMatrix.GetItem(const Row, Col: Integer): TObject;
begin
  Result := GetRow(Row).Item[Col];
end;

procedure TTMatrix.SetItem(const Row, Col: Integer; const Value: TObject);
begin
  GetRow(Row).Item[Col] := Value;
end;

procedure TTMatrix.Assign(const Source: TObject);
var I, J, R, C : Integer;
begin
  if Source is ABlaiseMatrix then
    begin
      R := ABlaiseMatrix(Source).RowCount;
      C := ABlaiseMatrix(Source).ColCount;
      SetRowCount(R);
      SetColCount(C);
      For I := 0 to R - 1 do
        For J := 0 to C - 1 do
          SetItem(I, J, ABlaiseMatrix(Source).Item[I, J]);
    end
  else
    inherited Assign(Source);
end;

procedure TTMatrix.Negate;
var I, J : Integer;
begin
  For I := 0 to RowCount - 1 do
    For J := 0 to ColCount - 1 do
      SetItem(I, J, OperationNegate(GetItem(I, J)));
end;

procedure TTMatrix.Add(const V: TObject);
var I, J : Integer;
begin
  if V is ABlaiseMatrix then
    begin
      if (RowCount <> ABlaiseMatrix(V).RowCount) or
         (ColCount <> ABlaiseMatrix(V).ColCount) then
        raise EObjectMatrix.Create('Matrix size mismatch');
      For I := 0 to RowCount - 1 do
        For J := 0 to ColCount - 1 do
          SetItem(I, J, OperationAdd(GetItem(I, J), ABlaiseMatrix(V).Item[I, J]));
    end
  else
    inherited Add(V);
end;

procedure TTMatrix.Subtract(const V: TObject);
var I, J : Integer;
begin
  if V is ABlaiseMatrix then
    begin
      if (RowCount <> ABlaiseMatrix(V).RowCount) or
         (ColCount <> ABlaiseMatrix(V).ColCount) then
        raise EObjectMatrix.Create('Matrix size mismatch');
      For I := 0 to RowCount - 1 do
        For J := 0 to ColCount - 1 do
          SetItem(I, J, OperationSubtract(GetItem(I, J), ABlaiseMatrix(V).Item[I, J]));
    end
  else
    inherited Subtract(V);
end;

procedure TTMatrix.Multiply(const V: TObject);
var I, J, C, D : Integer;
    R, K       : Integer;
    P          : TTMatrix;
    A, B, S    : TObject;
begin
  if V is ABlaiseMatrix then
    begin
      C := ColCount;
      if C <> ABlaiseMatrix(V).RowCount then
        raise EObjectMatrix.Create('Matrix size mismatch');
      R := RowCount;
      D := ABlaiseMatrix(V).ColCount;
      P := TTMatrix.Create;
      try
        P.RowCount := R;
        P.ColCount := D;
        For I := 0 to R - 1 do
          For J := 0 to D - 1 do
            begin
              A := TTFloat.Create(0.0);
              try
                For K := 0 to C - 1 do
                  begin
                    B := OperationMultiply(GetItem(I, K), ABlaiseMatrix(V).Item[K, J]);
                    try
                      S := OperationAdd(A, B);
                    finally
                      ObjectReleaseUnreferenced(B);
                    end;
                    ObjectReleaseUnreferenced(A);
                    A := S;
                  end;
                P.Item[I, J] := A;
              finally
                ObjectReleaseUnreferenced(A);
              end;
            end;
        Assign(P);
      finally
        P.Free;
      end;
    end
  else
    inherited Multiply(V);
end;

procedure TTMatrix.ReversedAdd(const V: TObject);
begin
  Add(V);
end;

procedure TTMatrix.ReversedSubtract(const V: TObject);
begin
  Negate;
  Add(V);
end;

procedure TTMatrix.ReversedMultiply(const V: TObject);
var A : TTMatrix;
begin
  if V is ABlaiseMatrix then
    begin
      A := TTMatrix.Create;
      try
        A.Assign(V);
        A.Multiply(self);
        Assign(A);
      finally
        A.Free;
      end;
    end
  else
    inherited ReversedMultiply(V);
end;

function TTMatrix.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if RightOp is TTMatrix then
        Result := Duplicate;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTMatrix.BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const LeftOp: TObject): TObject;
begin
  Result := nil;
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply] then
    begin
      if LeftOp is TTMatrix then
        Result := Duplicate;
    end;
  if not Assigned(Result) then
    Result := inherited BinaryOpRightCoerce(Operation, LeftOp);
end;



{                                                                              }
{ TMatrixType                                                                  }
{                                                                              }
procedure TMatrixType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
end;

function TMatrixType.CreateTypeInstance: TObject;
begin
  Result := TTMatrix.Create;
end;

function TMatrixType.IsType(const Value: TObject): Boolean;
begin
  Result := Value is TTMatrix;
end;

function TMatrixType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_MATRIX;
end;

procedure TMatrixType.StreamOut(const Writer: AWriterEx);
begin
end;

procedure TMatrixType.StreamIn(const Reader: AReaderEx);
begin
end;



{                                                                              }
{ TObjectDictionaryByString                                                    }
{                                                                              }
constructor TObjectDictionaryByString.Create;
begin
  inherited Create;
  FDictionary := TObjectDictionary.CreateEx(nil, nil,
      {IsItemOwner=}      False,
      {KeysCaseSensitive=}False,
      {AddOnSet=}         True,
      {DuplicatesAction=} ddAccept)
end;

constructor TObjectDictionaryByString.CreateEx(const Dictionary: TObjectDictionary);
begin
  inherited Create;
  Assert(Assigned(Dictionary), 'Assigned(Dictionary)');
  FDictionary := Dictionary;
end;

destructor TObjectDictionaryByString.Destroy;
var I: Integer;
begin
  if Assigned(FDictionary) then
    begin
      For I := 0 to FDictionary.Count - 1 do
        ObjectReleaseReference(FDictionary.GetItemByIndex(I));
      FreeAndNil(FDictionary);
    end;
  inherited Destroy;
end;

function TObjectDictionaryByString.FindItemByString(const Key: String; var Value: TObject): Boolean;
begin
  Result := FDictionary.LocateItem(Key, Value) >= 0;
end;

function TObjectDictionaryByString.GetItemByString(const Key: String): TObject;
begin
  if not FindItemByString(Key, Result) then
    raise EBlaiseDictionary.Create('Key not found');
end;

procedure TObjectDictionaryByString.SetItemByString(const Key: String;
    const Value: TObject);
var V{, N} : TObject;
    I    : Integer;
begin
  I := FDictionary.LocateItem(Key, V);
  if (I >= 0) and (Value = V) then
    exit;
  ObjectAddReference(Value);
  if I >= 0 then
    begin
      ObjectReleaseReference(V);
      FDictionary.SetItemByIndex(I, Value);
    end else
    FDictionary.Add(Key, Value);
end;

procedure TObjectDictionaryByString.AddItemByString(const Key: String;
    const Value: TObject);
begin
  ObjectAddReference(Value);
  FDictionary.Add(Key, Value);
end;

procedure TObjectDictionaryByString.DeleteByString(const Key: String);
var I: Integer;
    V: TObject;
begin
  I := FDictionary.LocateItem(Key, V);
  if I >= 0 then
    begin
      ObjectReleaseReference(V);
      FDictionary.DeleteItemByIndex(I);
    end;
end;

function TObjectDictionaryByString.GetItem(const Key: TObject): TObject;
begin
  Result := GetItemByString(ObjectGetAsUTF8(Key));
end;

procedure TObjectDictionaryByString.SetItem(const Key, Value: TObject);
begin
  SetItemByString(ObjectGetAsUTF8(Key), Value);
end;

procedure TObjectDictionaryByString.AddItem(const Key, Value: TObject);
begin
  AddItemByString(ObjectGetAsUTF8(Key), Value);
end;

procedure TObjectDictionaryByString.Delete(const Key: TObject);
begin
  DeleteByString(ObjectGetAsUTF8(Key));
end;

function TObjectDictionaryByString.GetCount: Integer;
begin
  Result := FDictionary.Count;
end;

function TObjectDictionaryByString.GetKeyByIndex(const Idx: Integer): TObject;
begin
  Result := TTString.Create(FDictionary.GetKeyByIndex(Idx));
end;



{                                                                              }
{ TTObjectDictionaryByString                                                   }
{                                                                              }
constructor TTObjectDictionaryByString.Create(const ItemType: ATypeDefinition);
begin
  inherited Create;
  ObjectAddReference(ItemType);
  FItemType := ItemType;
end;

destructor TTObjectDictionaryByString.Destroy;
begin
  ObjectReleaseReferenceAndNil(FItemType);
  inherited Destroy;
end;

function TTObjectDictionaryByString.CoerceValue(const Value: TObject): TObject;
begin
  if Assigned(FItemType) then
    Result := FItemType.Coerce(Value) else
    Result := Value;
end;

procedure TTObjectDictionaryByString.SetItem(const Key, Value: TObject);
begin
  inherited SetItem(Key, CoerceValue(Value));
end;

procedure TTObjectDictionaryByString.AddItem(const Key, Value: TObject);
begin
  inherited AddItem(Key, CoerceValue(Value));
end;



{                                                                              }
{ TTDictionaryByString                                                         }
{                                                                              }
constructor TTDictionaryByString.Create(const Dictionary: ADictionary);
begin
  inherited Create;
  Assert(Assigned(Dictionary), 'Assigned(Dictionary)');
  FDictionary := Dictionary;
  if FDictionary is AStringDictionary then
    FItemType := diString else
  if FDictionary is AIntegerDictionary then
    FItemType := diInteger else
  if FDictionary is AInt64Dictionary then
    FItemType := diInt64 else
  if FDictionary is AExtendedDictionary then
    FItemType := diExtended else
    TypeError('Invalid dictionary type');
end;

destructor TTDictionaryByString.Destroy;
begin
  FreeAndNil(FDictionary);
  inherited Destroy;
end;

{$WARNINGS OFF}
function TTDictionaryByString.GetItem(const Key: TObject): TObject;
var K : String;
begin
  Assert(Assigned(Key), 'Assigned(Key)');
  K := ObjectGetAsUTF8(Key);
  Case FItemType of
    diString   : Result := TTString.Create(AStringDictionary(FDictionary).Item[K]);
    diInteger  : Result := GetImmutableInteger(AIntegerDictionary(FDictionary).Item[K]);
    diInt64    : Result := GetImmutableInteger(AInt64Dictionary(FDictionary).Item[K]);
    diExtended : Result := TTFloat.Create(AExtendedDictionary(FDictionary).Item[K]);
  else
    TypeError('Invalid dictionary type');
  end;
end;
{$WARNINGS ON}

procedure TTDictionaryByString.SetItem(const Key, Value: TObject);
var K : String;
begin
  Assert(Assigned(Key), 'Assigned(Key)');
  K := ObjectGetAsUTF8(Key);
  Case FItemType of
    diString   : AStringDictionary(FDictionary).Item[K] := ObjectGetAsUTF8(Value);
    diInteger  : AIntegerDictionary(FDictionary).Item[K] := ObjectGetAsInteger(Value);
    diInt64    : AInt64Dictionary(FDictionary).Item[K] := ObjectGetAsInteger(Value);
    diExtended : AExtendedDictionary(FDictionary).Item[K] := ObjectGetAsFloat(Value);
  else
    TypeError('Invalid dictionary type');
  end;
end;

procedure TTDictionaryByString.AddItem(const Key, Value: TObject);
begin
  Assert(Assigned(Key), 'Assigned(Key)');
  SetItem(Key, Value);
end;

procedure TTDictionaryByString.Delete(const Key: TObject);
begin
  Assert(Assigned(Key), 'Assigned(Key)');
  FDictionary.Delete(ObjectGetAsUTF8(Key));
end;

function TTDictionaryByString.GetCount: Integer;
begin
  Result := FDictionary.Count;
end;

function TTDictionaryByString.GetKeyByIndex(const Idx: Integer): TObject;
begin
  Result := TTString.Create(FDictionary.GetKeyByIndex(Idx));
end;



{                                                                              }
{ TTDictionary                                                                 }
{                                                                              }
constructor TTDictionary.Create(const KeyType, ItemType: ATypeDefinition);
begin
  inherited Create;
  ObjectAddReference(KeyType);
  FKeyType := KeyType;
  ObjectAddReference(ItemType);
  FItemType := ItemType;
  FKeys := TObjectArray.Create(nil, False);
  FValues := TObjectArray.Create(nil, False);
end;

destructor TTDictionary.Destroy;
var I : Integer;
begin
  if Assigned(FKeys) then
    begin
      For I := 0 to FKeys.Count - 1 do
        ObjectReleaseReference(FKeys[I]);
      FreeAndNil(FKeys);
    end;
  if Assigned(FValues) then
    begin
      For I := 0 to FValues.Count - 1 do
        ObjectReleaseReference(FValues[I]);
      FreeAndNil(FValues);
    end;
  ObjectReleaseReference(FItemType);
  ObjectReleaseReference(FKeyType);
  inherited Destroy;
end;

procedure TTDictionary.Rehash;
var I, C : Integer;
    L : LongWord;
begin
  C := FKeys.Count;
  L := DictionaryRehashSize(C);
  FLookup := nil;
  SetLength(FLookup, L);
  For I := 0 to C - 1 do
    Append(FLookup[ObjectHashValue(FKeys[I]) mod L], I);
end;

class function TTDictionary.CreateInstance: AType;
begin
  Result := TTDictionary.Create(nil, nil);
end;

function TTDictionary.LocateKey(const Key: TObject; var LookupIdx: Integer;
    const ErrorIfNotFound: Boolean): Integer;
var H, I, J : Integer;
    L : LongWord;
begin
  Result := -1;
  L := Length(FLookup);
  if L > 0 then
    begin
      H := ObjectHashValue(Key) mod L;
      LookupIdx := H;
      For I := 0 to Length(FLookup[H]) - 1 do
        begin
          J := FLookup[H, I];
          if ObjectIsEqual(Key, FKeys[J]) then
            begin
              Result := J;
              break;
            end;
        end;
    end;
  if ErrorIfNotFound and (Result = -1) then
    raise EObjectDictionaryByObject.Create('Key not found');
end;

function TTDictionary.KeyIndex(const Key: TObject; const ErrorIfNotFound: Boolean): Integer;
var H : Integer;
begin
  Result := LocateKey(Key, H, ErrorIfNotFound);
end;

function TTDictionary.CoerceValue(const Value: TObject): TObject;
begin
  if Assigned(FItemType) then
    Result := FItemType.Coerce(Value) else
    Result := Value;
end;

procedure TTDictionary.AddItem(const Key, Value: TObject);
var H, I : Integer;
    L    : LongWord;
    V    : TObject;
begin
  Assert(Assigned(Key), 'Assigned(Key)');
  V := CoerceValue(Value);
  L := Length(FLookup);
  if L = 0 then
    begin
      Rehash;
      L := Length(FLookup);
    end;
  H := ObjectHashValue(Key) mod L;
  ObjectAddReference(Key);
  I := FKeys.AppendItem(Key);
  Append(FLookup[H], I);
  ObjectAddReference(V);
  FValues.AppendItem(V);
  if (I + 1) div AverageHashChainSize > Integer(L) then
    Rehash;
end;

procedure TTDictionary.DeleteByIndex(const Idx: Integer; const Hash: Integer);
var I, J, H : Integer;
begin
  if Hash < 0 then
    H := ObjectHashValue(FKeys[Idx]) mod LongWord(Length(FLookup)) else
    H := Hash;
  ObjectReleaseReference(FKeys[Idx]);
  FKeys.Delete(Idx);
  ObjectReleaseReference(FValues[Idx]);
  FValues.Delete(Idx);
  J := PosNext(Idx, FLookup[H]);
  Assert(J >= 0, 'Invalid hash value/lookup table');
  Remove(FLookup[H], J, 1);
  For I := 0 to Length(FLookup) - 1 do
    For J := 0 to Length(FLookup[I]) - 1 do
      if FLookup[I][J] > Idx then
        Dec(FLookup[I][J]);
end;

procedure TTDictionary.Delete(const Key: TObject);
var I, H : Integer;
begin
  I := LocateKey(Key, H, True);
  DeleteByIndex(I, H);
end;

function TTDictionary.HasKey(const Key: TObject): Boolean;
begin
  Result := KeyIndex(Key, False) >= 0;
end;

function TTDictionary.LocateItem(const Key: TObject; var Value: TObject): Boolean;
var I : Integer;
begin
  I := KeyIndex(Key, False);
  Result := I >= 0;
  if Result then
    Value := FValues[I] else
    Value := nil;
end;

function TTDictionary.GetItem(const Key: TObject): TObject;
begin
  if not LocateItem(Key, Result) then
    raise EObjectDictionaryByObject.Create('Key not found');
end;

procedure TTDictionary.SetItem(const Key, Value: TObject);
var I : Integer;
    V : TObject;
begin
  I := KeyIndex(Key, False);
  if I >= 0 then
    begin
      V := CoerceValue(Value);
      ObjectAddReference(V);
      ObjectReleaseReference(FValues[I]);
      FValues[I] := V;
    end
  else
    AddItem(Key, Value);
end;

function TTDictionary.GetCount: Integer;
begin
  Result := FKeys.Count;
end;

function TTDictionary.GetKeyByIndex(const Idx: Integer): TObject;
begin
  Result := FKeys[Idx];
end;

procedure TTDictionary.DeleteItemByIndex(const Idx: Integer);
begin
  DeleteByIndex(Idx, -1);
end;

function TTDictionary.GetItemByIndex(const Idx: Integer): TObject;
begin
  Result := FValues[Idx];
end;

procedure TTDictionary.SetItemByIndex(const Idx: Integer; const Value: TObject);
begin
  ObjectReleaseReference(FValues[Idx]);
  FValues[Idx] := Value;
  ObjectAddReference(Value);
end;



{                                                                              }
{ TDictionaryType                                                              }
{                                                                              }
constructor TDictionaryType.Create(const KeyType, ItemType: ATypeDefinition);
begin
  inherited Create;
  ObjectAddReference(KeyType);
  FKeyType := KeyType;
  ObjectAddReference(ItemType);
  FItemType := ItemType;
end;

destructor TDictionaryType.Destroy;
begin
  ObjectReleaseReference(FItemType);
  ObjectReleaseReference(FKeyType);
  inherited Destroy;
end;

procedure TDictionaryType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
  inherited SetDefinitionScope(DefinitionScope);
  if Assigned(FKeyType) then
    FKeyType.SetDefinitionScope(DefinitionScope);
  if Assigned(FItemType) then
    FItemType.SetDefinitionScope(DefinitionScope);
end;

function TDictionaryType.CreateTypeInstance: TObject;
var K, T : ATypeDefinition;
begin
  if not Assigned(FKeyType) then
    Result := TTDictionary.Create(nil, FItemType)
  else
    begin
      K := FKeyType.ResolveType;
      if K is TStringType then
        begin
          if not Assigned(FItemType) then
            Result := TTObjectDictionaryByString.Create(nil)
          else
            begin
              T := FItemType.ResolveType;
              if T is TStringType then
                Result := TTDictionaryByString.Create(TStringDictionary.Create) else
              if T is TIntegerType then
                Result := TTDictionaryByString.Create(TInt64Dictionary.Create) else
              if T is TFloatType then
                Result := TTDictionaryByString.Create(TExtendedDictionary.Create)
              else
                Result := TTObjectDictionaryByString.Create(FItemType);
            end;
        end
      else
        Result := TTDictionary.Create(FKeyType, FItemType);
    end;
end;

function TDictionaryType.IsType(const Value: TObject): Boolean;
var V    : TObject;
    K, T : ATypeDefinition;
begin
  if Value is AValueReference then
    V := AValueReference(Value).GetValue else
    V := Value;
  if not Assigned(FKeyType) then
    begin
      Result := (V is TTDictionary) and
                not Assigned(TTDictionary(V).FKeyType) and
                (TTDictionary(V).FItemType = FItemType);
    end
  else
    begin
      K := FKeyType.ResolveType;
      if K is TStringType then
        begin
          if not Assigned(FItemType) then
            Result := (V is TTObjectDictionaryByString) and
                      (TTObjectDictionaryByString(V).FItemType = FItemType)
          else
            begin
              T := FItemType.ResolveType;
              if T is TStringType then
                Result := (V is TTDictionaryByString) and
                          (TTDictionaryByString(V).FDictionary is TStringDictionary) else
              if T is TIntegerType then
                Result := (V is TTDictionaryByString) and
                          (TTDictionaryByString(V).FDictionary is TInt64Dictionary) else
              if T is TFloatType then
                Result := (V is TTDictionaryByString) and
                          (TTDictionaryByString(V).FDictionary is TExtendedDictionary)
              else
                Result := (V is TTObjectDictionaryByString) and
                          (TTObjectDictionaryByString(V).FItemType = FItemType)
            end;
        end
      else
        Result := (V is TTDictionary) and
                  (TTDictionary(V).FKeyType = FKeyType) and
                  (TTDictionary(V).FItemType = FItemType);
    end;
end;

function TDictionaryType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DICTIONARY;
end;

procedure TDictionaryType.StreamOut(const Writer: AWriterEx);
begin
  StreamOutTypeDefinition(Writer, FKeyType);
  StreamOutTypeDefinition(Writer, FItemType);
end;

procedure TDictionaryType.StreamIn(const Reader: AReaderEx);
begin
  FKeyType := StreamInTypeDefinition(Reader);
  ObjectAddReference(FKeyType);
  FItemType := StreamInTypeDefinition(Reader);
  ObjectAddReference(FItemType);
end;



end.

