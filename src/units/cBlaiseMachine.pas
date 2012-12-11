{                                                                              }
{                            Blaise Machine v0.07                              }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{               Its original file name is cBlaiseMachine.pas                   }
{                                                                              }
{ Description:                                                                 }
{                                                                              }
{ Revision history:                                                            }
{   14/10/2001  0.01  Initial version                                          }
{   21/10/2001  0.02  Revision.                                                }
{   23/10/2001  0.03  Revision.                                                }
{   16/11/2001  0.04  Added TNamedExpression.                                  }
{   26/11/2001  0.05  Added TUsesFieldDefinition.                              }
{   08/03/2003  0.06  Revision.                                                }
{   30/05/2003  0.07  Support for units.                                       }
{                                                                              }

{$INCLUDE cHeader.inc}
{.DEFINE DCU_SUPPORT}
{.DEFINE DCU_SYSTEM}

unit cBlaiseMachine;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cTypes,
  cDictionaries,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructs,
  cBlaiseStructsCollections,
  cBlaiseVMCompiler,
  cBlaiseMachineTypes;


const
  UnitVersion = '0.06';
  BlaiseMachineVersion = '1';



{                                                                              }
{ TBlaiseUnit                                                                  }
{   A Blaise unit.                                                             }
{                                                                              }
type
  TBlaiseUnit = class;
  TBlaiseUnitImplementationScope = class(TBlaiseScope)
  protected
    FBlaiseUnit : TBlaiseUnit;
    FImported   : Boolean;

  public
    constructor Create(const BlaiseUnit : TBlaiseUnit);
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
  end;

  TApplicationScope = class;
  TBlaiseUnit = class(TUnitInterfaceScope)
  protected
    FApplicationScope        : TApplicationScope;
    FIdentifier              : String;
    FImported                : Boolean;
    FPrivateDeclarations     : AScopeFieldDefinitionArray;
    FPublicDeclarations      : AScopeFieldDefinitionArray;
    FInterfaceUsedUnits      : StringArray;
    FImplementationUsedUnits : StringArray;

    procedure Init; override;

  public
    constructor CreateEx(const Identifier: String;
                const PublicDeclarations,
                      PrivateDeclarations: AScopeFieldDefinitionArray;
                const InterfaceUsedUnits,
                      ImplementationUsedUnits: StringArray);
    destructor Destroy; override;

    property  Identifier: String read FIdentifier;
    property  InterfaceUsedUnits: StringArray read FInterfaceUsedUnits;
    property  ImplementationUsedUnits: StringArray read FImplementationUsedUnits;

    procedure InitUnit(const ApplicationScope: TApplicationScope);

    procedure Optimize;
    procedure Compile(const VM: TBlaiseVMCompiler);
    procedure StreamIn(const Reader: AReaderEx); override;

    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure ExportToScope(const Scope: ABlaiseType); override;
  end;



{                                                                              }
{ TApplicationScope                                                            }
{   TBlaiseScope implementation for an application.                            }
{                                                                              }
{   The inhterited scope is the global application scope.                      }
{   FDefaultScope is the default scope of the Blaise language.                 }
{   FUsedUnits is the list of units used by this scope.                        }
{   FGlobalUnits is the list of all units used by the application.             }
{                                                                              }
  TApplicationScope = class(AApplicationScope)
  protected
    FDefaultScope : TBlaiseScope;
    FUsedUnits    : StringArray;
    FGlobalUnits  : TBlaiseScope;

    function  GetUnitFile(const FileName: String): String;
    function  ImportBorlandDCU(const FilePath: String): ABlaiseType;
    function  ImportSourceUnit(const FilePath: String): TBlaiseUnit;
    function  ImportVMUnit(const FilePath: String): TBlaiseUnit;

  public
    constructor Create(const Input: AReaderEx; const Output, Log: AWriterEx);
    destructor Destroy; override;

    property  UsedUnits: StringArray read FUsedUnits write FUsedUnits;

    procedure AddUsedUnit(const UnitName: String); override;
    function  GetUnit(const UnitName: String): TUnitInterfaceScope; override;
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
  end;



{                                                                              }
{ TBlaiseApplication                                                           }
{   A Blaise application.                                                      }
{                                                                              }
{   Use cases:                                                                 }
{                                                                              }
{     1. Compile for VM                                                        }
{          Create, Optimize, Compile, Destroy                                  }
{                                                                              }
{     2. Execute tree                                                          }
{          Create, Optimize, InitScope, Execute, Destroy                       }
{                                                                              }
type
  TBlaiseApplication = class
  protected
    FUsedUnits    : StringArray;
    FDeclarations : AScopeFieldDefinitionArray;
    FStatement    : AStatement;
    FScope        : ABlaiseType;

  public
    constructor Create(const UsedUnits: StringArray;
                const Declarations: AScopeFieldDefinitionArray;
                const Statement: AStatement);
    destructor Destroy; override;

    procedure Optimize;
    procedure Compile(const VM: TBlaiseVMCompiler);
    procedure InitScope(const Scope: ABlaiseType); overload;
    procedure InitScope(const Input: AReaderEx; const Output, Log: AWriterEx); overload;
    procedure Execute;

    property  UsedUnits: StringArray read FUsedUnits;
    property  Declarations: AScopeFieldDefinitionArray read FDeclarations;
    property  Statement: AStatement read FStatement;
    property  Scope: ABlaiseType read FScope;
  end;
  EBlaiseApplication = class(Exception);
  EGeneratedException = class(Exception);



implementation

uses
  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructsSimple,
  cBlaiseMachineNameSpace,
  cBlaiseMachineStatements,
  cBlaiseMachineStructs,
  {$IFDEF DCU_SUPPORT}
  cBlaiseMachineDCU,
  {$IFDEF DCU_SYSTEM}
  cSystemDCU,
  {$ENDIF}
  {$ENDIF}
  cBlaiseParserNodes,
  cBlaiseParser;



{                                                                              }
{ Implementation constants                                                     }
{                                                                              }
const
  DCUFileExtention    = '.dcu';
  UnitFileExtention   = '.pas';
  VMUnitFileExtention = '.bcu';



{                                                                              }
{ TBlaiseUnitImplementationScope                                               }
{                                                                              }
constructor TBlaiseUnitImplementationScope.Create(const BlaiseUnit : TBlaiseUnit);
begin
  inherited Create;
  FBlaiseUnit := BlaiseUnit;
  FImported := False;
end;

function TBlaiseUnitImplementationScope.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var S : StringArray;
    I : Integer;
begin
  S := nil;
  // Import declarations
  if not FImported then
    begin
      FImported := True;
      ScopeAddFieldDefinitions(self, FBlaiseUnit.FPrivateDeclarations,
              self);
    end;
  // Private declarations
  Result := inherited GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Implementation used units
  S := FBlaiseUnit.ImplementationUsedUnits;
  For I := Length(S) - 1 downto 0 do
    begin
      Result := FBlaiseUnit.FApplicationScope.GetUnit(S[I]).GetField(
          FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end;
  // Public declarations
  Result := FBlaiseUnit.GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Interface used units
  S := FBlaiseUnit.InterfaceUsedUnits;
  For I := Length(S) - 1 downto 0 do
    begin
      Result := FBlaiseUnit.FApplicationScope.GetUnit(S[I]).GetField(
          FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end;
  // Unit name
  if FieldName = FBlaiseUnit.FIdentifier then
    begin
      Scope := self;
      Result := self;
      FieldType := bfObject;
      exit;
    end;
  // Default scope
  Result := FBlaiseUnit.FApplicationScope.FDefaultScope.GetField(FieldName, Scope, FieldType);
end;



{                                                                              }
{ TBlaiseUnit                                                                  }
{                                                                              }
constructor TBlaiseUnit.CreateEx(const Identifier: String;
    const PublicDeclarations, PrivateDeclarations: AScopeFieldDefinitionArray;
    const InterfaceUsedUnits, ImplementationUsedUnits: StringArray);
begin
  inherited Create;
  FIdentifier := Identifier;
  FPublicDeclarations := PublicDeclarations;
  FPrivateDeclarations := PrivateDeclarations;
  FInterfaceUsedUnits := InterfaceUsedUnits;
  FImplementationUsedUnits := ImplementationUsedUnits;
end;

procedure TBlaiseUnit.Init;
begin
  inherited Init;
  FImplementationScope := TBlaiseUnitImplementationScope.Create(self);
  ObjectAddReference(FImplementationScope);
end;

destructor TBlaiseUnit.Destroy;
begin
  FreeObjectArray(FPrivateDeclarations);
  FreeObjectArray(FPublicDeclarations);
  ObjectReleaseReferenceAndNil(FImplementationScope);
  ObjectReleaseReferenceAndNil(FApplicationScope);
  inherited Destroy;
end;

procedure TBlaiseUnit.InitUnit(const ApplicationScope: TApplicationScope);
begin
  ObjectAddReference(ApplicationScope);
  FApplicationScope := ApplicationScope;
  FImported := False;
end;

procedure TBlaiseUnit.Optimize;
begin
end;

procedure TBlaiseUnit.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.SetModuleType(BLAISE_VM_MODULE_TYPE_ID_UNIT);
  VM.WritePackedString(FIdentifier);
  StreamOutFieldDefinitions(VM, FPublicDeclarations);
  StreamOutFieldDefinitions(VM, FPrivateDeclarations);
  VM.WritePackedStringArray(FInterfaceUsedUnits);
  VM.WritePackedStringArray(FImplementationUsedUnits);
end;

procedure TBlaiseUnit.StreamIn(const Reader: AReaderEx);
begin
  if Reader.ReadByte <> BLAISE_VM_MODULE_TYPE_ID then
    raise EBlaiseApplication.Create('Invalid unit file');
  if Reader.ReadByte <> BLAISE_VM_MODULE_TYPE_ID_UNIT then
    raise EBlaiseApplication.Create('Invalid module type');
  FIdentifier := Reader.ReadPackedString;
  FPublicDeclarations := StreamInFieldDefinitions(Reader);
  FPrivateDeclarations := StreamInFieldDefinitions(Reader);
  FInterfaceUsedUnits := Reader.ReadPackedStringArray;
  FImplementationUsedUnits := Reader.ReadPackedStringArray;
end;

function TBlaiseUnit.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  // Import
  if not FImported then
    begin
      FImported := True;
      ScopeAddFieldDefinitions(self, FPublicDeclarations, FImplementationScope);
    end;
  // Public scope
  Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TBlaiseUnit.ExportToScope(const Scope: ABlaiseType);
var I : Integer;
begin
  // Import
  if not FImported then
    begin
      FImported := True;
      ScopeAddFieldDefinitions(self, FPublicDeclarations, FImplementationScope);
    end;
  // Export
  For I := 0 to GetCount - 1 do
    Scope.SetField(Dictionary.GetKeyByIndex(I), Dictionary.GetItemByIndex(I));
end;



{                                                                              }
{ TApplicationScope                                                            }
{                                                                              }
constructor TApplicationScope.Create(const Input: AReaderEx; const Output, Log: AWriterEx);

  procedure AddType(const Identifier: String; const TypeClass: ATypeDefinition);
  begin
    TypeClass.SetDefinitionScope(self);
    FDefaultScope.SetField(Identifier, TypeClass);
  end;

begin
  inherited Create;
  FDefaultScope := TBlaiseScope.Create;
  FGlobalUnits := TBlaiseScope.Create;

  // Special
  FDefaultScope.SetField('__Version__', TTString.Create(BlaiseFullVersion));
  FDefaultScope.SetField('__Copyright__', TTString.Create(BlaiseCopyright));

  // I/O Streams
  if Assigned(Input) then
    FDefaultScope.AssignIdentifier('__StdInput__', Input);
  if Assigned(Output) then
    FDefaultScope.AssignIdentifier('__StdOutput__', Output);
  if Assigned(Log) then
    FDefaultScope.AssignIdentifier('__StdLog__', Log);

  // Root Name Space
  FDefaultScope.SetField('__RootNameSpace__', GetGlobalRootNameSpace);

  // Language functions
  FDefaultScope.SetField('Copy', TCopyFunction.Create);
  FDefaultScope.SetField('Length', TLengthFunction.Create);
  FDefaultScope.SetField('Repr', TReprFunction.Create);
  FDefaultScope.SetField('Eval', TEvalFunction.Create);

  // Built-in types
  AddType('String', TStringType.Create);
  AddType('Base64Binary', TBase64BinaryType.Create);
  AddType('URL', TURLType.Create);
  AddType('Unicode', TUnicodeType.Create);
  AddType('Unicode8', TUnicode8Type.Create);
  AddType('Unicode16', TUnicode16Type.Create);
  AddType('Char', TCharType.Create);
  AddType('UnicodeChar', TUnicodeCharType.Create);
  AddType('Boolean', TBooleanType.Create);
  AddType('Integer', TIntegerType.Create);
  AddType('Byte', TByteType.Create);
  AddType('Int16', TInt16Type.Create);
  AddType('Int32', TInt32Type.Create);
  AddType('Int64', TInt64Type.Create);
  AddType('Float', TFloatType.Create);
  AddType('Single', TSingleFloatType.Create);
  AddType('Double', TDoubleFloatType.Create);
  AddType('Extended', TExtendedFloatType.Create);
  AddType('DateTime', TDateTimeType.Create);
  AddType('ANSIDateTime', TAnsiDateTimeType.Create);
  AddType('RFCDateTime', TRfcDateTimeType.Create);
  AddType('Duration', TDurationType.Create);
  AddType('Timer', TTimerType.Create);
  AddType('Currency', TCurrencyType.Create);
  AddType('Rational', TRationalType.Create);
  AddType('Complex', TComplexType.Create);
  AddType('Statistic', TStatisticType.Create);
  AddType('Vector', TVectorType.Create);
  AddType('Matrix', TMatrixType.Create);
  AddType('Expression', TExpressionType.Create);

  // Mathematical constants
  FDefaultScope.SetField('Infinity', GetImmutableInfinity);

  // Mathematical functions
  FDefaultScope.SetField('Abs', TAbsFunction.Create);
  FDefaultScope.SetField('Sin', TSinFunction.Create);
  FDefaultScope.SetField('Cos', TCosFunction.Create);
  FDefaultScope.SetField('Exp', TExpFunction.Create);
  FDefaultScope.SetField('Ln', TLnFunction.Create);
  FDefaultScope.SetField('Sqrt', TSqrtFunction.Create);
  FDefaultScope.SetField('Sqr', TSqrFunction.Create);
  FDefaultScope.SetField('Random', TRandomFunction.Create);

  // Mathematical operations
  FDefaultScope.SetField('Inc', TIncProcedure.Create);
  FDefaultScope.SetField('Dec', TDecProcedure.Create);
end;

destructor TApplicationScope.Destroy;
begin
  inherited Destroy;          // Free (inherited) variable scope before other
  FreeAndNil(FGlobalUnits);   // scopes to ensure UnitScope/DefaultScope exists
  FreeAndNil(FDefaultScope);  // when destructors are called.
end;

function TApplicationScope.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
var I : Integer;
begin
  // Global variable scope
  Result := inherited GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Unit by name
  For I := Length(FUsedUnits) - 1 downto 0 do
    if StrEqualNoCase(FieldName, FUsedUnits[I]) then
      begin
        Result := GetUnit(FieldName);
        Scope := self;
        FieldType := bfObject;
        exit;
      end;
  // Individual units' scope
  For I := Length(FUsedUnits) - 1 downto 0 do
    begin
      Result := GetUnit(FUsedUnits[I]).GetField(FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end;
  // Global default scope
  Result := FDefaultScope.GetField(FieldName, Scope, FieldType);
end;

function TApplicationScope.GetUnitFile(const FileName: String): String;
begin
  if FileExists(FileName) then
    Result := FileName
  else
    Result := '';
end;

{$WARNINGS OFF}
{$IFDEF DCU_SUPPORT}
function TApplicationScope.ImportBorlandDCU(const FilePath: String): ABlaiseType;
var U : TdcUnit;
begin
  try
    U := TdcUnit.Create;
    U.LoadFromFile(FilePath);
    U.SetApplicationScope(self);
    Result := U;
  except
    ModifyExceptMsg('Import Borland DCU');
    raise;
  end;
end;
{$ELSE}
function TApplicationScope.ImportBorlandDCU(const FilePath: String): ABlaiseType;
begin
  RaiseError('Can not import DCU file');
end;
{$ENDIF}

function TApplicationScope.ImportSourceUnit(const FilePath: String): TBlaiseUnit;
var P : TBlaiseScriptParser;
    S : ABlaiseScriptNode;
begin
  try
    P := TBlaiseScriptParser.Create;
    try
      P.SetFileName(FilePath);
      S := P.ExtractSource;
      if not (S is TUnitNode) then
        RaiseError('Source is not a unit');
      Result := TUnitNode(S).GetUnit;
    finally
      P.Free;
    end;
  except
    ModifyExceptMsg('Import Source Unit');
    raise;
  end;
end;
{$WARNINGS ON}

function TApplicationScope.ImportVMUnit(const FilePath: String): TBlaiseUnit;
var R : TFileReader;
begin
  Result := TBlaiseUnit.Create;
  try
    R := TFileReader.Create(FilePath);
    try
      Result.StreamIn(R);
    finally
      R.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TApplicationScope.AddUsedUnit(const UnitName: String);
begin
  Append(FUsedUnits, UnitName);
end;

function TApplicationScope.GetUnit(const UnitName: String): TUnitInterfaceScope;
var P : String;
begin
  // Check if unit has been imported
  if FGlobalUnits.Dictionary.LocateItem(UnitName, TObject(Result)) >= 0 then
    exit;
  // System unit
  {$IFDEF DCU_SUPPORT}
  {$IFDEF DCU_SYSTEM}
  if IsEqualNoCase(Name, 'System') then
    Result := TSystemDCU.Create;
  {$ENDIF}
  // DCU unit
  if not Assigned(Result) then
    begin
      P := FindUnit(UnitName + DCUFileExtention);
      if P <> '' then
        Result := ImportBorlandDCU(P)
    end;
  {$ENDIF}
  // Compiled unit
  if not Assigned(Result) then
    begin
      P := GetUnitFile(UnitName + VMUnitFileExtention);
      if P <> '' then
        Result := ImportVMUnit(P);
    end;
  // Source unit
  if not Assigned(Result) then
    begin
      P := GetUnitFile(UnitName + UnitFileExtention);
      if P <> '' then
        Result := ImportSourceUnit(P);
    end;
  if not Assigned(Result) then
    // Not found
    RaiseError('Unit not found: ' + UnitName);
  // Add unit
  TBlaiseUnit(Result).InitUnit(self);
  FGlobalUnits.AddItemByString(UnitName, Result);
end;



{                                                                              }
{ TBlaiseApplication                                                           }
{                                                                              }
constructor TBlaiseApplication.Create(const UsedUnits: StringArray;
    const Declarations: AScopeFieldDefinitionArray;
    const Statement: AStatement);
begin
  inherited Create;
  FUsedUnits := UsedUnits;
  FDeclarations := Declarations;
  FStatement := Statement;
end;

destructor TBlaiseApplication.Destroy;
begin
  ObjectReleaseReferenceAndNil(FScope);
  inherited Destroy;
end;

procedure TBlaiseApplication.Optimize;
begin
  if Assigned(FStatement) then
    FStatement := FStatement.Optimize(nil);
end;

procedure TBlaiseApplication.Compile(const VM: TBlaiseVMCompiler);
var I : Integer;
begin
  VM.SetModuleType(BLAISE_VM_MODULE_TYPE_ID_APPLICATION);
  For I := 0 to Length(FUsedUnits) - 1 do
    VM.UseUnit(FUsedUnits[I]);
  if Assigned(FDeclarations) then
    VM.Declare(FDeclarations);
  if Assigned(FStatement) then
    FStatement.Compile(VM);
  VM.Return;
end;

procedure TBlaiseApplication.InitScope(const Scope: ABlaiseType);
begin
  ObjectReleaseReferenceAndNil(FScope);
  ObjectAddReference(Scope);
  FScope := Scope;
end;

procedure TBlaiseApplication.InitScope(const Input: AReaderEx; const Output, Log: AWriterEx);
begin
  InitScope(TApplicationScope.Create(Input, Output, Log));
end;

procedure TBlaiseApplication.Execute;
var E : Boolean;
begin
  // Add declarations
  if Assigned(FScope) then
    begin
      if FScope is TApplicationScope then
        TApplicationScope(FScope).UsedUnits := FUsedUnits;
      ScopeAddFieldDefinitions(FScope, FDeclarations, FScope);
    end;
  // Execute main code block
  E := False;
  try try
    if Assigned(FStatement) then
      FStatement.Execute(FScope);
  except
    on EExitFlowControl do ;
    on E: ERaiseFlowControl do
      raise EGeneratedException.Create('Exception: ' +
          ObjectGetAsUTF8(E.ExceptionValue));
  else
    E := True;
    raise;
  end;
  // Execution complete: Clean up
  finally
    try
      ObjectReleaseReferenceAndNil(FScope);
    except
      if not E then
        raise;
    end;
  end;
end;



end.

