{                                                                              }
{                          Blaise code classes v0.03                           }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseMachineCode.pas                 }
{                                                                              }
{ Description:                                                                 }
{                                                                              }
{ Revision history:                                                            }
{   08/03/2003  0.01  Created unit cBlaiseMachineCode from cBlaiseMachine.     }
{   06/04/2003  0.02  Implemented Compile.                                     }
{   08/04/2003  0.03  Support for language tasks.                              }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineCode;

interface

uses
  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cCallConventions,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructsCode,
  cBlaiseStructsObject,
  cBlaiseVMCompiler,
  cBlaiseMachineTypes;



{                                                                              }
{ === Field Definitions ===                                                    }
{                                                                              }

{                                                                              }
{ AFunctionFieldDefinition                                                     }
{                                                                              }
type
  AFunctionFieldDefinition = class(AScopeFieldDefinition)
  protected
    FClassIdentifier : String;
    FIdentifier      : String;
    FParamDefinition : AParameterFieldDefinitionArray;
    FLocalDefinition : AScopeFieldDefinitionArray;
    FCodeStatement   : AStatement;
    FMachineCode     : String;

    function  GetClassType(const Scope: ABlaiseType): TClassType;
    function  GetSelectedScope(const Scope: ABlaiseType): ABlaiseType;

    procedure CompileEnter(const Compiler: TBlaiseVMCompiler); virtual;
    procedure CompileLeave(const Compiler: TBlaiseVMCompiler); virtual;
    procedure CompileCode(const Compiler: TBlaiseVMCompiler); virtual;

  public
    constructor Create(const ClassIdentifier, Identifier: String;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray;
        const CodeStatement: AStatement);

    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TProcedureFieldDefinition                                                    }
{                                                                              }
type
  TProcedureFieldDefinition = class(AFunctionFieldDefinition)
  public
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TFunctionFieldDefinition                                                     }
{                                                                              }
type
  TFunctionFieldDefinition = class(AFunctionFieldDefinition)
  protected
    FCodeExpression : AExpression;
    FResultType     : ATypeDefinition;

    procedure CompileCode(const Compiler: TBlaiseVMCompiler); override;

  public
    constructor Create(const ClassIdentifier, Identifier: String;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray;
        const CodeStatement: AStatement;
        const CodeExpression: AExpression;
        const ResultType: ATypeDefinition);

    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTaskFieldDefinition                                                         }
{                                                                              }
type
  TTaskFieldDefinition = class(AFunctionFieldDefinition)
  protected
    procedure CompileEnter(const Compiler: TBlaiseVMCompiler); override;
    procedure CompileLeave(const Compiler: TBlaiseVMCompiler); override;

  public
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TConstructorFieldDefinition                                                  }
{                                                                              }
type
  TConstructorFieldDefinition = class(AFunctionFieldDefinition)
  protected
    procedure CompileCode(const Compiler: TBlaiseVMCompiler); override;

  public
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TDestructorFieldDefinition                                                   }
{                                                                              }
type
  TDestructorFieldDefinition = class(AFunctionFieldDefinition)
  public
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TExternalFunctionFieldDefinition                                             }
{                                                                              }
type
  TExternalFunctionFieldDefinition = class(AScopeFieldDefinition)
  protected
    FIdentifier      : String;
    FParamDefinition : AParameterFieldDefinitionArray;
    FResultType      : ATypeDefinition;
    FLibraryName     : String;
    FExternalName    : String;
    FConvention      : TCallingConvention;

  public
    constructor Create(const Identifier: String;
                const ParamDefinition: AParameterFieldDefinitionArray;
                const ResultType: ATypeDefinition;
                const LibraryName, ExternalName: String;
                const Convention: TCallingConvention);
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ === Scope Functions ===                                                      }
{                                                                              }

{                                                                              }
{ TProcedureScopeFunction                                                      }
{                                                                              }
type
  TProcedureScopeFunction = class(ACodeFrameScopeFunction)
  protected
    FCodeStatement : AStatement;
    FMachineCode   : String;

  public
    constructor Create(const DefinitionScope: ABlaiseType;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray;
        const CodeStatement: AStatement; const MachineCode: String);

    function  GetMachineCode: Pointer; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;



{                                                                              }
{ TFunctionScopeFunction                                                       }
{                                                                              }
type
  TFunctionScopeFunction = class(TProcedureScopeFunction)
  protected
    FResultType     : ATypeDefinition;
    FCodeExpression : AExpression;

  public
    constructor Create(const DefinitionScope: ABlaiseType;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray;
        const CodeStatement: AStatement; const MachineCode: String;
        const CodeExpression: AExpression; const ResultType: ATypeDefinition);

    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;



{                                                                              }
{ TTaskScopeFunction                                                           }
{                                                                              }
type
  TTaskScopeFunction = class(ACodeFrameScopeFunction)
  protected
    FCodeStatement : AStatement;
    FMachineCode   : String;

  public
    constructor Create(const DefinitionScope: ABlaiseType;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray;
        const CodeStatement: AStatement; const MachineCode: String);

    function  GetMachineCode: Pointer; override;
  end;



{                                                                              }
{ TConstructorScopeFunction                                                    }
{                                                                              }
type
  TConstructorScopeFunction = class(TProcedureScopeFunction)
  protected
    FClassType : TClassType;

  public
    constructor Create(const DefinitionScope: ABlaiseType;
        const ClassType: TClassType;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray;
        const CodeStatement: AStatement; const MachineCode: String);

    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  CreateLocalScope(const Scope: ABlaiseType;
              const Parameters: Array of TObject): ABlaiseType; override;
  end;



{                                                                              }
{ TDestructorScopeFunction                                                     }
{                                                                              }
type
  TDestructorScopeFunction = class(TProcedureScopeFunction);



{                                                                              }
{ TExternalScopeFunction                                                       }
{                                                                              }
type
  TExternalScopeFunction = class(AFunction)
  protected
    FParamDefinition   : AParameterFieldDefinitionArray;
    FResultType        : ATypeDefinition;
    FLibraryName       : String;
    FExternalName      : String;
    FConvention        : TCallingConvention;
    FParamAttributes   : TParameterAttributesArray;

  public
    constructor Create(const ParamDefinition: AParameterFieldDefinitionArray;
                const ResultType: ATypeDefinition;
                const LibraryName, ExternalName: String;
                const Convention: TCallingConvention);
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cDynLib,
  cDictionaries,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructsSimple,
  cBlaiseMachineStatements;



{                                                                              }
{ AFunctionFieldDefinition                                                     }
{                                                                              }
constructor AFunctionFieldDefinition.Create(
    const ClassIdentifier, Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray;
    const CodeStatement: AStatement);
begin
  inherited Create;
  FClassIdentifier := ClassIdentifier;
  FIdentifier := Identifier;
  FParamDefinition := ParamDefinition;
  FLocalDefinition := LocalDefinition;
  FCodeStatement := CodeStatement;
end;

function AFunctionFieldDefinition.GetClassType(const Scope: ABlaiseType): TClassType;
begin
  Result := TClassType(Scope.GetValueAsType(FClassIdentifier, True, TClassType,
      'Identifier not a class type'));
end;

function AFunctionFieldDefinition.GetSelectedScope(const Scope: ABlaiseType): ABlaiseType;
begin
  if FClassIdentifier <> '' then
    Result := GetClassType(Scope).ObjectScope
  else
    Result := Scope;
end;

procedure AFunctionFieldDefinition.CompileEnter(const Compiler: TBlaiseVMCompiler);
begin
  Compiler.EnterFunctionScope;
end;

procedure AFunctionFieldDefinition.CompileLeave(const Compiler: TBlaiseVMCompiler);
begin
  Compiler.LeaveFunctionScope;
end;

procedure AFunctionFieldDefinition.CompileCode(const Compiler: TBlaiseVMCompiler);
begin
  if Assigned(FCodeStatement) then
    FCodeStatement.Compile(Compiler);
end;

procedure AFunctionFieldDefinition.StreamOut(const Writer: AWriterEx);
var L, P : Integer;
    C    : TBlaiseVMCompiler;
begin
  // Identifier
  Writer.WritePackedString(FClassIdentifier);
  Writer.WritePackedString(FIdentifier);
  // Definitions
  StreamOutFieldDefinitions(Writer, AScopeFieldDefinitionArray(FParamDefinition));
  StreamOutFieldDefinitions(Writer, FLocalDefinition);
  // Code
  if FMachineCode <> '' then // already compiled code
    Writer.WritePackedString(FMachineCode) else
  if Writer is TBlaiseVMCompiler then // compile
    begin
      C := TBlaiseVMCompiler(Writer);
      P := C.GetOffset;
      C.WriteLongInt(-1);
      CompileEnter(C);
      CompileCode(C);
      CompileLeave(C);
      C.Return;
      L := Writer.Position - P - Sizeof(LongInt); // Size of compiled byte-code
      C.SetIntegerAtOffset(P, L);
    end
  else
    Writer.WriteLongInt(0);
end;

procedure AFunctionFieldDefinition.StreamIn(const Reader: AReaderEx);
var I, L : Integer;
begin
  FClassIdentifier := Reader.ReadPackedString;
  FIdentifier := Reader.ReadPackedString;
  L := Reader.ReadLongInt;
  SetLength(FParamDefinition, L);
  For I := 0 to L - 1 do
    FParamDefinition[I] := StreamInFieldDefinition(Reader) as AParameterFieldDefinition;
  FLocalDefinition := StreamInFieldDefinitions(Reader);
  FMachineCode := Reader.ReadPackedString;
end;



{                                                                              }
{ TProcedureFieldDefinition                                                    }
{                                                                              }
procedure TProcedureFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  GetSelectedScope(FieldScope).SetField(FIdentifier,
      TProcedureScopeFunction.Create(
          DefinitionScope, FParamDefinition, FLocalDefinition, FCodeStatement,
          FMachineCode));
end;

function TProcedureFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CODE_PROCEDURE;
end;



{                                                                              }
{ TTaskFieldDefinition                                                         }
{                                                                              }
procedure TTaskFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  GetSelectedScope(FieldScope).SetField(FIdentifier,
      TTaskScopeFunction.Create(
          DefinitionScope, FParamDefinition, FLocalDefinition, FCodeStatement,
          FMachineCode));
end;

function TTaskFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CODE_TASK;
end;

procedure TTaskFieldDefinition.CompileEnter(const Compiler: TBlaiseVMCompiler);
begin
  Compiler.StartTask;
end;

procedure TTaskFieldDefinition.CompileLeave(const Compiler: TBlaiseVMCompiler);
begin
end;



{                                                                              }
{ TFunctionFieldDefinition                                                     }
{                                                                              }
constructor TFunctionFieldDefinition.Create(const ClassIdentifier, Identifier: String;
  const ParamDefinition: AParameterFieldDefinitionArray;
  const LocalDefinition: AScopeFieldDefinitionArray;
  const CodeStatement: AStatement; const CodeExpression: AExpression;
  const ResultType: ATypeDefinition);
begin
  inherited Create(ClassIdentifier, Identifier, ParamDefinition,
      LocalDefinition, CodeStatement);
  FCodeExpression := CodeExpression;
  FResultType := ResultType;
end;

procedure TFunctionFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  if Assigned(FResultType) then
    FResultType.SetDefinitionScope(DefinitionScope);
  GetSelectedScope(FieldScope).SetField(FIdentifier,
      TFunctionScopeFunction.Create(
          DefinitionScope, FParamDefinition, FLocalDefinition, FCodeStatement,
          FMachineCode, FCodeExpression, FResultType));
end;

function TFunctionFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CODE_FUNCTION;
end;

procedure TFunctionFieldDefinition.CompileCode(const Compiler: TBlaiseVMCompiler);
begin
  if Assigned(FCodeExpression) then
    begin
      FCodeExpression.Compile(Compiler);
      Compiler.PopAccumulator;
    end
  else
    begin
      inherited CompileCode(Compiler);
      Compiler.PushInteger(0);
      Compiler.EvaluateIdentifier('Result');
    end;
  // coerce result
  //
end;

procedure TFunctionFieldDefinition.StreamOut(const Writer: AWriterEx);
begin
  inherited StreamOut(Writer);
  StreamOutTypeDefinition(Writer, FResultType);
end;

procedure TFunctionFieldDefinition.StreamIn(const Reader: AReaderEx);
begin
  inherited StreamIn(Reader);
  FResultType := StreamInTypeDefinition(Reader);
end;



{                                                                              }
{ TConstructorFieldDefinition                                                  }
{                                                                              }
procedure TConstructorFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
var C : TClassType;
begin
  C := GetClassType(FieldScope);
  C.ClassScope.SetField(FIdentifier, TConstructorScopeFunction.Create(
      DefinitionScope, C, FParamDefinition, FLocalDefinition, FCodeStatement,
      FMachineCode));
end;

function TConstructorFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CODE_CONSTRUCTOR;
end;

procedure TConstructorFieldDefinition.CompileCode(const Compiler: TBlaiseVMCompiler);
begin
  inherited CompileCode(Compiler);
  Compiler.EvaluateSelf;
end;



{                                                                              }
{ TDestructorFieldDefinition                                                   }
{                                                                              }
procedure TDestructorFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
var C : TClassType;
begin
  C := GetClassType(FieldScope);
  C.ObjectScope.SetField(FIdentifier, TDestructorScopeFunction.Create(
      DefinitionScope, FParamDefinition, FLocalDefinition, FCodeStatement,
      FMachineCode));
end;

function TDestructorFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CODE_DESTRUCTOR;
end;



{                                                                              }
{ TExternalFunctionFieldDefinition                                             }
{                                                                              }
constructor TExternalFunctionFieldDefinition.Create(const Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const ResultType: ATypeDefinition;
    const LibraryName, ExternalName: String;
    const Convention: TCallingConvention);
begin
  inherited Create;
  FIdentifier := Identifier;
  FParamDefinition := ParamDefinition;
  FResultType := ResultType;
  FLibraryName := LibraryName;
  FExternalName := ExternalName;
  FConvention := Convention;
end;

procedure TExternalFunctionFieldDefinition.AddToScope(const FieldScope,
    DefinitionScope: ABlaiseType);
begin
  FieldScope.SetField(FIdentifier, TExternalScopeFunction.Create(FParamDefinition,
      FResultType, FLibraryName, FExternalName, FConvention));
end;

function TExternalFunctionFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CODE_EXTERNAL;
end;

procedure TExternalFunctionFieldDefinition.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedString(FIdentifier);
  StreamOutFieldDefinitions(Writer, AScopeFieldDefinitionArray(FParamDefinition));
  StreamOutTypeDefinition(Writer, FResultType);
  Writer.WritePackedString(FLibraryName);
  Writer.WritePackedString(FExternalName);
  Writer.WriteLongInt(Ord(FConvention));
end;

procedure TExternalFunctionFieldDefinition.StreamIn(const Reader: AReaderEx);
var I, L : Integer;
begin
  FIdentifier := Reader.ReadPackedString;
  L := Reader.ReadLongInt;
  SetLength(FParamDefinition, L);
  For I := 0 to L - 1 do
    FParamDefinition[I] := StreamInFieldDefinition(Reader) as AParameterFieldDefinition;
  FResultType := StreamInTypeDefinition(Reader);
  FLibraryName := Reader.ReadPackedString;
  FExternalName := Reader.ReadPackedString;
  FConvention := TCallingConvention(Reader.ReadLongInt);
end;



{                                                                              }
{ TProcedureScopeFunction                                                      }
{                                                                              }
constructor TProcedureScopeFunction.Create(const DefinitionScope: ABlaiseType;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray;
    const CodeStatement: AStatement; const MachineCode: String);
begin
  inherited Create(DefinitionScope, ParamDefinition, LocalDefinition);
  FCodeStatement := CodeStatement;
  FMachineCode := MachineCode;
end;

function TProcedureScopeFunction.GetMachineCode: Pointer;
begin
  if FMachineCode = '' then
    Result := nil
  else
    Result := Pointer(FMachineCode);
end;

function TProcedureScopeFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var LocalScope : ABlaiseType;
begin
  LocalScope := CreateLocalScope(Scope, Parameters);
  try try
    if Assigned(FCodeStatement) then
      FCodeStatement.Execute(LocalScope);
  except
    on EExitFlowControl do ;
  end;
  finally
    FreeAndNil(LocalScope);
  end;
  Result := nil;
end;



{                                                                              }
{ TFunctionScopeFunction                                                       }
{                                                                              }
constructor TFunctionScopeFunction.Create(const DefinitionScope: ABlaiseType;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray;
    const CodeStatement: AStatement; const MachineCode: String;
    const CodeExpression: AExpression; const ResultType: ATypeDefinition);
begin
  inherited Create(DefinitionScope, ParamDefinition, LocalDefinition,
      CodeStatement, MachineCode);
  FCodeExpression := CodeExpression;
  FResultType := ResultType;
end;

function TFunctionScopeFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var LocalScope : TCodeFrameScope;
    P : ABlaiseType;
    T : TBlaiseFieldType;
begin
  LocalScope := CreateLocalScope(Scope, Parameters) as TCodeFrameScope;
  try
    if Assigned(FCodeExpression) then
      Result := FCodeExpression.Evaluate(LocalScope)
    else
      begin
        try
          FCodeStatement.Execute(LocalScope);
        except
          on EExitFlowControl do ;
        end;
        Result := LocalScope.GetValue('Result', False, P, T);
        LocalScope.ReleaseField('Result');
      end;
    if Assigned(FResultType) then
      Result := FResultType.CoerceAndReleaseUnreferenced(Result);
  finally
    FreeAndNil(LocalScope);
  end;
end;



{                                                                              }
{ TTaskScopeFunction                                                           }
{                                                                              }
constructor TTaskScopeFunction.Create(const DefinitionScope: ABlaiseType;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray;
    const CodeStatement: AStatement; const MachineCode: String);
begin
  inherited Create(DefinitionScope, ParamDefinition, LocalDefinition);
  FCodeStatement := CodeStatement;
  FMachineCode := MachineCode;
end;

function TTaskScopeFunction.GetMachineCode: Pointer;
begin
  if FMachineCode = '' then
    Result := nil
  else
    Result := Pointer(FMachineCode);
end;



{                                                                              }
{ TConstructorScopeFunction                                                    }
{                                                                              }
constructor TConstructorScopeFunction.Create(const DefinitionScope: ABlaiseType;
    const ClassType: TClassType; const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray;
    const CodeStatement: AStatement; const MachineCode: String);
begin
  inherited Create(DefinitionScope, ParamDefinition, LocalDefinition,
      CodeStatement, MachineCode);
  FClassType := ClassType;
end;

function TConstructorScopeFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var LocalScope : ABlaiseType;
begin
  Result := nil;
  LocalScope := CreateLocalScope(Scope, Parameters);
  try try
    FCodeStatement.Execute(LocalScope);
    Result := TTObject(TCodeFrameScope(LocalScope).ParentScope);
  except
    on EExitFlowControl do ;
  end;
  finally
    FreeAndNil(LocalScope);
  end;
end;

function TConstructorScopeFunction.CreateLocalScope(const Scope: ABlaiseType;
    const Parameters: Array of TObject): ABlaiseType;
var Instance : TTObject;
begin
  if not (Scope is TClassType) then
    FunctionError('Constructor not called from class scope');
  Instance := TTObject.Create(TClassType(Scope));
  try
    Result := inherited CreateLocalScope(Instance, Parameters);
  except
    Instance.Free;
    raise;
  end;
end;



{                                                                              }
{ Dynamic libraries                                                            }
{                                                                              }
var
  DynamicLibraries : TObjectDictionary = nil;

function GetDynamicLibrary(const FileName: String): TDynamicLibrary;
begin
  if not Assigned(DynamicLibraries) then
    DynamicLibraries := TObjectDictionary.CreateEx(nil, nil, True, False, True);
  if DynamicLibraries.LocateItem(FileName, TObject(Result)) >= 0 then
    exit;
  Result := TDynamicLibrary.Create(FileName);
  DynamicLibraries.Add(FileName, Result);
end;

function GetLibraryProcedure(const FileName, ProcName: String): Pointer;
begin
  Result := GetDynamicLibrary(FileName).ProcAddress[ProcName];
end;



{                                                                              }
{ TExternalScopeFunction                                                       }
{                                                                              }
constructor TExternalScopeFunction.Create(
    const ParamDefinition: AParameterFieldDefinitionArray;
    const ResultType: ATypeDefinition;
    const LibraryName, ExternalName: String;
    const Convention: TCallingConvention);
var I, L : Integer;
begin
  inherited Create;
  FParamDefinition := ParamDefinition;
  FResultType := ResultType;
  FLibraryName := LibraryName;
  FExternalName := ExternalName;
  FConvention := Convention;
  L := Length(FParamDefinition);
  SetLength(FParamAttributes, L);
  For I := 0 to L - 1 do
    FParamAttributes[I] := FParamDefinition[I].GetParameterAttributes;
end;

function TExternalScopeFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var P    : Pointer;
    I, L : Integer;
    A    : Integer;
    V    : Array of LongWord;
    R    : LongWord;
    W    : TObject;
begin
  ValidateParameters(FParamAttributes, Parameters);
  P := GetLibraryProcedure(FLibraryName, FExternalName);
  if not Assigned(P) then
    raise EFunction.Create('External procedure not found: ' + FLibraryName +
        ': ' + FExternalName);
  A := Length(Parameters);
  L := Length(FParamDefinition);
  SetLength(V, L);
  For I := 0 to L - 1 do
    if I < A then
      begin
        W := Parameters[I];
        if W is TTInteger then
          V[I] := LongWord(TTInteger(W).AsInteger) else
        if W is TTString then
          V[I] := LongWord(Pointer(TTString(W).Value))
        else
          raise EFunction.Create('Invalid parameter to external function'); 
      end
    else
      V[I] := 0;
  R := cCallConventions.Call(FConvention, P, V);
  Result := TTInteger.Create(R);
end;



initialization
finalization
  FreeAndNil(DynamicLibraries);
end.

