{                                                                              }
{                        Blaise object structures v0.02                        }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{            Its original file name is cBlaiseStructsObject.pas                }
{                                                                              }
{ Description:                                                                 }
{   This unit implements the Blaise object type.                               }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseStructsObject from cDataStructs.          }
{   07/03/2002  0.02  Revised TClassType and TTObject.                         }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseStructsObject;

interface

uses
  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cDictionaries,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructs;



{                                                                              }
{ TPropertyFieldDefinition                                                     }
{   Field definition of a property.                                            }
{                                                                              }
type
  TPropertyFieldDefinition = class(AScopeFieldDefinition)
  protected
    FIdentifier      : String;
    FTypeDefinition  : ATypeDefinition;
    FReadIdentifier  : String;
    FWriteIdentifier : String;

  public
    constructor Create(const Identifier: String; const TypeDefinition: ATypeDefinition;
        const ReadIdentifier, WriteIdentifier: String);
    destructor Destroy; override;

    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TClassType                                                                   }
{   Type definition of a Blaise class.                                         }
{                                                                              }
{   A Blaise class can inherit from any Blaise type. FParents is a list of     }
{   parent types.                                                              }
{                                                                              }
{   FClassScope is the class' scope. It contains class variables, class        }
{   functions and constructors.                                                }
{                                                                              }
{   FObjectScope is the scope that is shared by all objects of this class      }
{   type. It contains methods and properties.                                  }
{                                                                              }
type
  TClassType = class(ALocalisedTypeDefinition)
  protected
    FParentNames        : StringArray;
    FClassDefinition    : AScopeFieldDefinitionArray;
    FInstanceDefinition : AScopeFieldDefinitionArray;

    FParentTypes        : ATypeDefinitionArray;
    FClassScope         : TBlaiseScope;
    FObjectScope        : TBlaiseScope;

    procedure SetInstanceFields(const Scope: ABlaiseType);
    function  CreateParentInstances: ABlaiseTypeArray;

  public
    constructor Create(const ParentNames: StringArray;
                const ClassDefinition,
                InstanceDefinition: AScopeFieldDefinitionArray);
    destructor Destroy; override;

    property  ClassScope: TBlaiseScope read FClassScope write FClassScope;
    property  ObjectScope: TBlaiseScope read FObjectScope write FObjectScope;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ATypeDefinition                                                          }
    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  IsVariablesAutoInstanciate: Boolean; override;
    function  GetTypeDefID: Byte; override;

    { TClassType                                                               }
    function  InheritsFromClass(const C: ABlaiseType): Boolean;
  end;



{                                                                              }
{ TTObject                                                                     }
{   A Blaise object implementation.                                            }
{                                                                              }
{   FInstanceScope stores fields defined by FClassType and fields defined      }
{   at run-time.                                                               }
{                                                                              }
type
  TInheritedObjectScope = class(ABlaiseType)
  protected
    FClassType       : TClassType;
    FParentInstances : ABlaiseTypeArray;

  public
    constructor Create(const ClassType: TClassType);
    destructor Destroy; override;

    property  _ClassType: TClassType read FClassType;

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
  end;

  TTObject = class(ABlaiseObject)
  protected
    FClassType      : TClassType;
    FInheritedScope : TInheritedObjectScope;
    FInstanceScope  : TBlaiseScope;

  public
    constructor Create(const ClassType: TClassType);
    destructor Destroy; override;

    property  _ClassType: TClassType read FClassType;
    property  InheritedScope: TInheritedObjectScope read FInheritedScope;

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  GetTypeID: Byte; override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs;



{                                                                              }
{ TPropertyFieldDefinition                                                     }
{                                                                              }
constructor TPropertyFieldDefinition.Create(const Identifier: String;
    const TypeDefinition: ATypeDefinition;
    const ReadIdentifier, WriteIdentifier: String);
begin
  inherited Create;
  FIdentifier := Identifier;
  ObjectAddReference(TypeDefinition);
  FTypeDefinition := TypeDefinition;
  FReadIdentifier := ReadIdentifier;
  FWriteIdentifier := WriteIdentifier;
end;

destructor TPropertyFieldDefinition.Destroy;
begin
  ObjectReleaseReferenceAndNil(FTypeDefinition);
  inherited Destroy;
end;

procedure TPropertyFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
end;

function TPropertyFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_PROPERTY;
end;

procedure TPropertyFieldDefinition.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedString(FIdentifier);
  StreamOutTypeDefinition(Writer, FTypeDefinition);
  Writer.WritePackedString(FReadIdentifier);
  Writer.WritePackedString(FWriteIdentifier);
end;

procedure TPropertyFieldDefinition.StreamIn(const Reader: AReaderEx);
begin
  FIdentifier := Reader.ReadPackedString;
  FTypeDefinition := StreamInTypeDefinition(Reader);
  FReadIdentifier := Reader.ReadPackedString;
  FWriteIdentifier := Reader.ReadPackedString;
end;



{                                                                              }
{ TClassType                                                                   }
{                                                                              }
constructor TClassType.Create(const ParentNames: StringArray;
    const ClassDefinition, InstanceDefinition: AScopeFieldDefinitionArray);
begin
  inherited Create;
  FClassDefinition := ClassDefinition;
  FInstanceDefinition := InstanceDefinition;
  FParentNames := ParentNames;
  FClassScope := TBlaiseScope.Create;
  FObjectScope := TBlaiseScope.Create;
end;

destructor TClassType.Destroy;
var I: Integer;
begin
  For I := Length(FParentTypes) - 1 downto 0 do
    ObjectReleaseReferenceAndNil(FParentTypes[I]);
  FreeAndNil(FObjectScope);
  FreeAndNil(FClassScope);
  FreeObjectArray(FClassDefinition);
  FreeObjectArray(FInstanceDefinition);
  inherited Destroy;
end;

procedure TClassType.SetDefinitionScope(const DefinitionScope: ABlaiseType);
var I, L : Integer;
    V    : ATypeDefinition;
begin
  Assert(Assigned(DefinitionScope), 'Assigned(DefinitionScope)');
  inherited SetDefinitionScope(DefinitionScope);
  L := Length(FParentNames);
  SetLength(FParentTypes, L);
  For I := 0 to L - 1 do
    begin
      V := DefinitionScope.GetValueAsTypeDefinition(FParentNames[I], True);
      ObjectAddReference(V);
      FParentTypes[I] := V;
    end;
  ScopeAddFieldDefinitions(FClassScope, FClassDefinition, DefinitionScope);
  ScopeAddFieldDefinitions(FObjectScope, FInstanceDefinition, DefinitionScope);
end;

function TClassType.CreateTypeInstance: TObject;
begin
  Assert(Assigned(FDefinitionScope), 'Assigned(FDefinitionScope)');
  Result := TTObject.Create(self);
end;

function TClassType.IsType(const Value: TObject): Boolean;
begin
  if Value = UnassignedValue then
    Result := True else
  if not (Value is TTObject) then
    Result := False
  else
    Result := TTObject(Value)._ClassType.InheritsFromClass(self);
end;

function TClassType.IsVariablesAutoInstanciate: Boolean;
begin
  Result := False;
end;

procedure TClassType.SetInstanceFields(const Scope: ABlaiseType);
var I : Integer;
    V : AScopeFieldDefinition;
begin
  For I := 0 to Length(FInstanceDefinition) - 1 do
    begin
      V := FInstanceDefinition[I];
      if V is TRecordFieldFieldDefinition then
        V.AddToScope(Scope, FDefinitionScope);
    end;
end;

function TClassType.CreateParentInstances: ABlaiseTypeArray;
var I, L : Integer;
begin
  L := Length(FParentTypes);
  SetLength(Result, L);
  For I := 0 to L - 1 do
    Result[I] := ABlaiseType(FParentTypes[I].CreateTypeInstance);
end;

function TClassType.InheritsFromClass(const C: ABlaiseType): Boolean;
var I : Integer;
begin
  if C = self then
    begin
      Result := True;
      exit;
    end;
  For I := 0 to Length(FParentTypes) - 1 do
    if (FParentTypes[I] is TClassType) and TClassType(FParentTypes[I]).InheritsFromClass(C) then
      begin
        Result := True;
        exit;
      end;
  Result := False;
end;

function TClassType.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var I : Integer;
begin
  // Check class scope
  Result := FClassScope.GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Check parents
  For I := 0 to Length(FParentTypes) - 1 do
    begin
      Result := FParentTypes[I].GetField(FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end;
end;

procedure TClassType.SetField(const FieldName: String; const Value: TObject);
begin
  FClassScope.SetField(FieldName, Value);
end;

{$WARNINGS OFF}
function TClassType.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  IdentifierNotDefinedError(FieldName);
end;
{$WARNINGS ON}

function TClassType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_CLASS;
end;

procedure TClassType.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedStringArray(FParentNames);
  StreamOutFieldDefinitions(Writer, FClassDefinition);
  StreamOutFieldDefinitions(Writer, FInstanceDefinition);
end;

procedure TClassType.StreamIn(const Reader: AReaderEx);
begin
  FParentNames := Reader.ReadPackedStringArray;
  FClassDefinition := StreamInFieldDefinitions(Reader);
  FInstanceDefinition := StreamInFieldDefinitions(Reader);
end;



{                                                                              }
{ TInheritedObjectScope                                                        }
{                                                                              }
constructor TInheritedObjectScope.Create(const ClassType: TClassType);
var I : Integer;
begin
  Assert(Assigned(ClassType), 'Assigned(ClassType)');
  inherited Create;
  FClassType := ClassType;
  // Create parent instances
  FParentInstances := ClassType.CreateParentInstances;
  For I := 0 to Length(FParentInstances) - 1 do
    ObjectAddReference(FParentInstances[I]);
end;

destructor TInheritedObjectScope.Destroy;
begin
  ObjectsReleaseReference(ObjectArray(FParentInstances));
  inherited Destroy;
end;

function TInheritedObjectScope.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
var I : Integer;
begin
  // Check parent instances
  For I := 0 to Length(FParentInstances) - 1 do
    begin
      Result := FParentInstances[I].GetField(FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end;
  // Not found
  Scope := nil;
  Result := nil;
end;

procedure TInheritedObjectScope.SetField(const FieldName: String; const Value: TObject);
begin
  ScopeError('Can not add fields to inherited scope');
end;



{                                                                              }
{ TTObject                                                                     }
{                                                                              }
constructor TTObject.Create(const ClassType: TClassType);
begin
  Assert(Assigned(ClassType), 'Assigned(ClassType)');
  inherited Create;
  FInstanceScope := TBlaiseScope.Create;
  FClassType := ClassType;
  // Create parent instances
  FInheritedScope := TInheritedObjectScope.Create(ClassType);
  ObjectAddReference(FInheritedScope);
  // Add instance fields to scope
  ClassType.SetInstanceFields(FInstanceScope);
end;

destructor TTObject.Destroy;
begin
  FreeAndNil(FInstanceScope);
  ObjectReleaseReferenceAndNil(FInheritedScope);
  inherited Destroy;
end;

function TTObject.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  // Check instance scope
  Result := FInstanceScope.GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    begin
      Scope := self;
      exit;
    end;
  // Check ClassType's object scope
  Result := FClassType.FObjectScope.GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Check ClassType's class scope
  Result := FClassType.FClassScope.GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Check inherited scope
  Result := FInheritedScope.GetField(FieldName, Scope, FieldType);
end;

procedure TTObject.SetField(const FieldName: String; const Value: TObject);
begin
  FInstanceScope.SetField(FieldName, Value);
end;

function TTObject.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_OBJECT;
end;



end.

