{                                                                              }
{                         Blaise utility functions v0.03                       }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{                 Its original file name is cBlaiseFuncs.pas                   }
{                                                                              }
{ Description:                                                                 }
{   This unit contains Blaise implementation helper functions.                 }
{                                                                              }
{ Revision history:                                                            }
{   14/06/2002  0.01  Created cBlaiseFuncs from various units.                 }
{   06/04/2003  0.02  Added virtual machine functions.                         }
{   17/05/2003  0.03  Object type checking functions.                          }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseFuncs;

interface

uses
  Contnrs,
  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  {$IFDEF DELPHI5}
  cUnicodeCodecs,
  {$ENDIF}

  { Blaise }
  cBlaiseTypes,
  cBlaiseVMTypes;



{                                                                              }
{ Error functions                                                              }
{                                                                              }
function  ModifyExceptMsg(const Loc: String): String;
function  BlaiseClassName(const A: TObject): String;
function  BlaiseNodeName(const A: TObject): String;

procedure ParameterError(const Msg: String);
procedure ParamCountError(const Expected, Actual: Integer);
procedure ValidateParamCount(const Min, Max: Integer;
          const Parameters: Array of TObject);
procedure ValidateParameters(const Attributes: TParameterAttributesArray;
          const Parameters: Array of TObject);

procedure ObjectOperationNotSupportedError(const A: TObject;
          const T: String); overload;
procedure ObjectOperationNotSupportedError(const A, B: TObject;
          const T: String); overload;
procedure ObjectConvertToError(const A: TObject; const T: String);
procedure ObjectConvertFromError(const A: TObject; const T: String);



{                                                                              }
{ ABlaiseType helper functions                                                 }
{                                                                              }
procedure ObjectAddReference(const A: TObject);
procedure ObjectReleaseReference(const A: TObject);
procedure ObjectReleaseReferenceAndNil(var A);
procedure ObjectsReleaseReference(const A: ObjectArray);
procedure ObjectReleaseUnreferenced(const A: TObject);
procedure ObjectsReleaseUnreferenced(const A: Array of TObject);
function  ObjectIsUnique(const A: TObject): Boolean;
function  ObjectIsUnreferenced(const A: TObject): Boolean;
function  ObjectUnique(const A: TObject): TObject;
procedure ObjectUniqueVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectEnsureReferenceUnique(var A: TObject);

function  ObjectDuplicate(const A: TObject): TObject;
procedure ObjectDuplicateVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectAssign(const A, B: TObject);
function  ObjectIsEqual(const A, B: TObject): Boolean;
function  ObjectCompare(const A, B: TObject): TCompareResult;
function  IntegerToCompareResult(const I: Int64): TCompareResult;

function  SimpleGetAsString(const A: TObject): String;
function  SimpleGetAsUTF8(const A: TObject): String;

function  ObjectGetAsString(const A: TObject): String;
procedure ObjectSetAsString(const A, V: TObject); overload;
procedure ObjectSetAsString(const A: TObject; const V: String); overload;
function  ObjectGetAsUTF8(const A: TObject): String;
function  ObjectGetAsUTF16(const A: TObject): WideString;
procedure ObjectSetAsUTF16(const A, V: TObject);
function  ObjectGetAsBlaise(const A: TObject): String;
function  ObjectHashValue(const A: TObject): LongWord;

function  IsSystemFieldName(const FieldName: String): Boolean;



{                                                                              }
{ Object helper functions                                                      }
{                                                                              }
function  SimpleGetAsBoolean(const A: TObject): Boolean;
function  SimpleGetAsInteger(const A: TObject): Int64;
function  SimpleGetAsFloat(const A: TObject): Extended;

function  ObjectGetAsBoolean(const A: TObject): Boolean;
function  ObjectGetAsBooleanAndRelease(const A: TObject): Boolean;
function  ObjectGetAsInteger(const A: TObject): Int64;
function  ObjectGetAsIntegerAndRelease(const A: TObject): Int64;
function  ObjectGetAsFloat(const A: TObject): Extended;
function  ObjectGetAsFloatAndRelease(const A: TObject): Extended;
function  ObjectGetAsDateTime(const A: TObject): TDateTime;
function  ObjectGetAsDateTimeAndRelease(const A: TObject): TDateTime;
function  ObjectGetAsChar(const A: TObject): Char;
function  ObjectGetAsCharAndRelease(const A: TObject): Char;
function  ObjectGetAsUnicodeChar(const A: TObject): UCS4Char;
function  ObjectGetAsUnicodeCharAndRelease(const A: TObject): UCS4Char;

procedure ObjectSetAsUTF8(const A: TObject; const V: String);
procedure ObjectSetAsBoolean(const A: TObject; const V: Boolean);
procedure ObjectSetAsInteger(const A: TObject; const V: Integer);
procedure ObjectSetAsFloat(const A: TObject; const V: Extended);

function  ObjectGetTypeID(const A: TObject): Byte;
function  ObjectIsTypeDefinition(const A: TObject): Boolean;
function  ObjectIsSimpleType(const A: TObject): Boolean;
function  ObjectIsString(const A: TObject): Boolean;
function  ObjectIsUnicodeString(const A: TObject): Boolean;
function  ObjectIsBoolean(const A: TObject): Boolean;
function  ObjectIsInteger(const A: TObject): Boolean;
function  ObjectIsOrdinal(const A: TObject): Boolean;
function  ObjectIsReal(const A: TObject): Boolean;
function  ObjectIsFloat(const A: TObject): Boolean;
function  ObjectIsDateTime(const A: TObject): Boolean;
function  ObjectIsFunction(const A: TObject): Boolean;
function  ObjectIsStream(const A: TObject): Boolean;
function  ObjectIsSequence(const A: TObject): Boolean;
function  ObjectIsNameSpace(const A: TObject): Boolean;

procedure ObjectAbs(const A: TObject);
procedure ObjectNegate(const A: TObject);

procedure ObjectAbsVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectNegateVM(const P: AVirtualMachineProcess; const A: TObject);

procedure ObjectAdd(const A, B: TObject);
procedure ObjectSubtract(const A, B: TObject);
procedure ObjectMultiply(const A, B: TObject);
procedure ObjectDivide(const A, B: TObject);
procedure ObjectPower(const A, B: TObject);
procedure ObjectIntegerDivide(const A, B: TObject);
procedure ObjectModulo(const A, B: TObject);

procedure ObjectReversedAdd(const A, B: TObject);
procedure ObjectReversedSubtract(const A, B: TObject);
procedure ObjectReversedMultiply(const A, B: TObject);
procedure ObjectReversedDivide(const A, B: TObject);
procedure ObjectReversedPower(const A, B: TObject);
procedure ObjectReversedIntegerDivide(const A, B: TObject);
procedure ObjectReversedModulo(const A, B: TObject);

procedure ObjectAddVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectSubtractVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectMultiplyVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectPowerVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectIntegerDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectModuloVM(const P: AVirtualMachineProcess; const A, B: TObject);

procedure ObjectReversedAddVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedSubtractVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedMultiplyVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedPowerVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedIntegerDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedModuloVM(const P: AVirtualMachineProcess; const A, B: TObject);

procedure ObjectSqr(const A: TObject);
procedure ObjectSqrt(const A: TObject);
procedure ObjectExp(const A: TObject);
procedure ObjectLn(const A: TObject);
procedure ObjectSin(const A: TObject);
procedure ObjectCos(const A: TObject);

procedure ObjectSqrVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectSqrtVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectExpVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectLnVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectSinVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectCosVM(const P: AVirtualMachineProcess; const A: TObject);

procedure ObjectLogicalAND(const A, B: TObject);
procedure ObjectLogicalOR(const A, B: TObject);
procedure ObjectLogicalXOR(const A, B: TObject);
procedure ObjectReversedLogicalAND(const A, B: TObject);
procedure ObjectReversedLogicalOR(const A, B: TObject);
procedure ObjectReversedLogicalXOR(const A, B: TObject);

procedure ObjectLogicalANDVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectLogicalORVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectLogicalXORVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedLogicalANDVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedLogicalORVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedLogicalXORVM(const P: AVirtualMachineProcess; const A, B: TObject);

procedure ObjectLogicalNOT(const A: TObject);
procedure ObjectLogicalNOTVM(const P: AVirtualMachineProcess; const A: TObject);

procedure ObjectBitwiseSHL(const A, B: TObject);
procedure ObjectBitwiseSHR(const A, B: TObject);
procedure ObjectReversedBitwiseSHL(const A, B: TObject);
procedure ObjectReversedBitwiseSHR(const A, B: TObject);

procedure ObjectBitwiseSHLVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectBitwiseSHRVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedBitwiseSHLVM(const P: AVirtualMachineProcess; const A, B: TObject);
procedure ObjectReversedBitwiseSHRVM(const P: AVirtualMachineProcess; const A, B: TObject);

procedure ObjectInc(const A: TObject); overload;
procedure ObjectDec(const A: TObject); overload;
procedure ObjectInc(const A, B: TObject); overload;
procedure ObjectDec(const A, B: TObject); overload;

procedure ObjectIncVM(const P: AVirtualMachineProcess; const A: TObject); overload;
procedure ObjectDecVM(const P: AVirtualMachineProcess; const A: TObject); overload;
procedure ObjectIncVM(const P: AVirtualMachineProcess; const A, B: TObject); overload;
procedure ObjectDecVM(const P: AVirtualMachineProcess; const A, B: TObject); overload;

function  ObjectIsIn(const A, B: TObject): Boolean;
procedure ObjectIsInVM(const P: AVirtualMachineProcess; const A, B: TObject);

function  ObjectUnaryOpCoerce(const Operation: TUnaryMathOperation;
          const A: TObject): TObject;
procedure ObjectUnaryOpCoerceVM(const P: AVirtualMachineProcess;
          const Operation: TUnaryMathOperation; const A: TObject);

function  ObjectBinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
          const A, B: TObject): TObject;
function  ObjectBinaryOpRightCoerce(const Operation: TBinaryMathOperation;
          const A, B: TObject): TObject;

function  ObjectBinaryOpLeftCoerceVM(const P: AVirtualMachineProcess;
          const Operation: TBinaryMathOperation; const A, B: TObject): TObject;
function  ObjectBinaryOpRightCoerceVM(const P: AVirtualMachineProcess;
          const Operation: TBinaryMathOperation; const A, B: TObject): TObject;

function  ObjectIterate(const A: TObject): TObject;
procedure ObjectIterateVM(const P: AVirtualMachineProcess; const A: TObject);

function  ObjectHasNext(const A: TObject): Boolean;
function  ObjectNext(const A: TObject): TObject;

procedure ObjectHasNextVM(const P: AVirtualMachineProcess; const A: TObject);
procedure ObjectNextVM(const P: AVirtualMachineProcess; const A: TObject);

function  ObjectEOF(const A: TObject): Boolean;

function  ObjectFunctionGetParameters(const A: TObject): TParameterAttributesArray;
function  ObjectFunctionGetMachineCode(const A: TObject): Pointer;
function  ObjectFunctionCall(const A: TObject; const Scope: ABlaiseType;
          const Parameters: Array of TObject): TObject;



{                                                                              }
{ Container helper functions                                                   }
{                                                                              }
procedure ObjectAppendItem(const A, B: TObject);
procedure ObjectAppendList(const A, B: TObject);

procedure ObjectAppendItemVM(const P: AVirtualMachineProcess;
          const A, B: TObject);
procedure ObjectAppendListVM(const P: AVirtualMachineProcess;
          const A, B: TObject);

function  ObjectGetLength(const A: TObject): Integer;

function  ObjectGetIndexedValue(const A, Index: TObject;
          const ReversedIndex: Boolean): TObject;
procedure ObjectAssignIndexedValue(const A, Index, Value: TObject;
          const ReversedIndex: Boolean);

procedure ObjectGetIndexedValueVM(const P: AVirtualMachineProcess;
          const A, Index: TObject; const ReversedIndex: Boolean;
          const Continuation: TBlaiseVMContinuation);
procedure ObjectAssignIndexedValueVM(const P: AVirtualMachineProcess;
          const A, Index, Value: TObject; const ReversedIndex: Boolean);



{                                                                              }
{ Operations                                                                   }
{                                                                              }
function  OperationAbs(const A: TObject): TObject;
function  OperationNegate(const A: TObject): TObject;

function  OperationAdd(const A, B: TObject): TObject;
function  OperationSubtract(const A, B: TObject): TObject;
function  OperationMultiply(const A, B: TObject): TObject;
function  OperationDivide(const A, B: TObject): TObject;
function  OperationPower(const A, B: TObject): TObject;

function  OperationIntegerDivide(const A, B: TObject): TObject;
function  OperationModulo(const A, B: TObject): TObject;

function  OperationLogicalAND(const A, B: TObject): TObject;
function  OperationLogicalOR(const A, B: TObject): TObject;
function  OperationLogicalXOR(const A, B: TObject): TObject;
function  OperationLogicalNOT(const A: TObject): TObject;

function  OperationBitwiseSHL(const A, B: TObject): TObject;
function  OperationBitwiseSHR(const A, B: TObject): TObject;

function  OperationSqr(const A: TObject): TObject;
function  OperationSqrt(const A: TObject): TObject;
function  OperationExp(const A: TObject): TObject;
function  OperationLn(const A: TObject): TObject;
function  OperationSin(const A: TObject): TObject;
function  OperationCos(const A: TObject): TObject;

function  OperationGetLength(const A: TObject): TObject;



{                                                                              }
{ Name space helper functions                                                  }
{                                                                              }
function  ObjectGetNameSpace(const Root, NameSpace: TObject; const Name: String;
          var Position: Integer): TObject;
function  ObjectNameSpaceGetItem(const A: TObject; const Key: String): TObject;
function  ObjectNameSpaceExists(const A: TObject; const Key: String): Boolean;
procedure ObjectNameSpaceSetItem(const A: TObject; const Key: String;
          const Value: TObject);
procedure ObjectNameSpaceDelete(const A: TObject; const Key: String);
function  ObjectNameSpaceDirectory(const A: TObject; const Key: String): TObject;

function  NameSpaceResolveNameSpace(const NameSpace: TObject;
          const Name: String; var Key: String): TObject;
function  NameSpaceGetName(const NameSpace: TObject;
          const Name: String): TObject;
function  NameSpaceNameExists(const NameSpace: TObject;
          const Name: String): Boolean;
procedure NameSpaceSetName(const NameSpace: TObject;
          const Name: String; const Value: TObject);
procedure NameSpaceDeleteName(const NameSpace: TObject;
          const Name: String);
function  NameSpaceDirectory(const NameSpace: TObject;
          const Name: String): TObject;



{                                                                              }
{ Scope helper functions                                                       }
{                                                                              }
procedure ScopeAddFieldDefinitions(const FieldScope: ABlaiseType;
          const FieldDefinitions: AScopeFieldDefinitionArray;
          const DefinitionScope: ABlaiseType;
          const FieldType: CScopeFieldDefinition = nil);
function  ScopeGetRootNameSpace(const Scope: ABlaiseType): ANameSpace;
procedure ScopeImport(const Scope: ABlaiseType; const Identifier, UnitName: String);



{                                                                              }
{ Stream helper functions                                                      }
{                                                                              }
function  CreateTypeDefinitionByID(const ID: Byte): ATypeDefinition;
function  StreamInTypeDefinition(const Reader: AReaderEx): ATypeDefinition;
procedure StreamOutTypeDefinition(const Writer: AWriterEx;
          const TypeDef: ATypeDefinition);

function  GetFieldDefinitionClassByID(const ID: Byte): CScopeFieldDefinition;
function  CreateFieldDefinitionByID(const ID: Byte): AScopeFieldDefinition;
function  StreamInFieldDefinition(const Reader: AReaderEx): AScopeFieldDefinition;
function  StreamInFieldDefinitions(const Reader: AReaderEx): AScopeFieldDefinitionArray;
procedure StreamOutFieldDefinition(const Writer: AWriterEx;
          const FieldDef: AScopeFieldDefinition);
procedure StreamOutFieldDefinitions(const Writer: AWriterEx;
          const FieldDef: AScopeFieldDefinitionArray);

function  CreateObjectByTypeID(const ID: Byte): TObject;
function  StreamInObject(const Reader: AReaderEx): TObject;
procedure StreamOutObject(const Writer: AWriterEx; const Value: TObject);



{                                                                              }
{ Machine functions                                                            }
{                                                                              }
function  GetMachine: AVirtualMachine;
function  RequireMachine: AVirtualMachine;
procedure SetMachine(const Machine: AVirtualMachine);
procedure ThreadWouldBlock;



implementation

uses
  { Delphi }
  Windows,
  SysUtils,

  { Fundamentals }
  cStrings,
  cTypes,

  { Blaise }
  cBlaiseConsts,
  cBlaiseStructs,
  cBlaiseStructsSimple,
  cBlaiseStructsCollections,
  cBlaiseStructsCode,
  cBlaiseStructsObject,
  cBlaiseMachineCode,
  cBlaiseMachine,
  cBlaiseParserNodes;



{                                                                              }
{ Error functions                                                              }
{                                                                              }
function ModifyExceptMsg(const Loc: String): String;
var E : TObject;
begin
  E := ExceptObject;
  if E is Exception then
    begin
      Result := Loc + ': ' + Exception(E).Message;
      Exception(E).Message := Result;
    end
  else
    Result := Loc;
end;

function BlaiseClassName(const A: TObject): String;
begin
  if not Assigned(A) then
    Result := 'nil'
  else
    begin
      Result := A.ClassName;
      if (Result <> '') and (Result[1] in ['A', 'T']) then
        begin
          Delete(Result, 1, 1);
          if (Length(Result) > 1) and (Result[1] = 'T') and
             (Result[2] in ['A'..'Z']) then
            Delete(Result, 1, 1);
        end;
    end;
end;

function BlaiseNodeName(const A: TObject): String;
begin
  if A is ABlaiseScriptNode then
    Result := ABlaiseScriptNode(A).NodeName
  else
    Result := BlaiseClassName(A);
end;

procedure ParameterError(const Msg: String);
begin
  raise EBlaiseParameterError.Create(Msg);
end;

procedure ParamCountError(const Expected, Actual: Integer);
begin
  if Expected = 0 then
    ParameterError('No parameter expected') else
  if Actual = 0 then
    if Expected = 1 then
      ParameterError('Parameter required') else
      ParameterError('Parameters required')
  else
    if Actual > Expected then
      ParameterError('Too many parameters') else
      ParameterError('Too few parameters');
end;

procedure ValidateParamCount(const Min, Max: Integer;
          const Parameters: Array of TObject);
var Actual : Integer;
begin
  Actual := Length(Parameters);
  if Actual < Min then
    ParamCountError(Min, Actual) else
  if (Max >= 0) and (Actual > Max) then
    ParamCountError(Max, Actual);
end;

procedure ValidateParameters(const Attributes: TParameterAttributesArray;
    const Parameters: Array of TObject);
var E, A, I : Integer;
begin
  E := Length(Attributes);
  A := Length(Parameters);
  if A > E then
    ParamCountError(E, A);
  if A < E then
    For I := A to E - 1 do
      if not (paOptional in Attributes[I]) then
        ParamCountError(E, A);
  For I := 0 to A - 1 do
    if (paReference in Attributes[I]) and not (Parameters[I] is AValueReference) then
      ParameterError('Reference required') else
    if not (paOptional in Attributes[I]) and not Assigned(Parameters[I]) then
      ParameterError('Parameter value required');
end;

procedure ObjectOperationNotSupportedError(const A: TObject; const T: String);
begin
  raise EBlaiseType.Create(BlaiseClassName(A) + ': Operation not supported: ' + T);
end;

procedure ObjectOperationNotSupportedError(const A, B: TObject; const T: String);
begin
  raise EBlaiseType.Create(BlaiseClassName(A) + ': Operation not supported with ' +
    BlaiseClassName(B) + ': ' + T);
end;

procedure ObjectConvertToError(const A: TObject; const T: String);
begin
  raise EBlaiseType.Create(BlaiseClassName(A) + ' cannot convert to ' + T);
end;

procedure ObjectConvertFromError(const A: TObject; const T: String);
begin
  raise EBlaiseType.Create(BlaiseClassName(A) + ' cannot convert from ' + T);
end;



{                                                                              }
{ ABlaiseType helper functions                                                 }
{                                                                              }
procedure ObjectAddReference(const A: TObject);
begin
  if Assigned(A) then
    if A is ABlaiseType then
      ABlaiseType(A).AddReference;
end;

procedure ObjectReleaseReference(const A: TObject);
begin
  if Assigned(A) then
    if A is ABlaiseType then
      ABlaiseType(A).ReleaseReference;
end;

procedure ObjectReleaseReferenceAndNil(var A);
var V: TObject;
begin
  V := TObject(A);
  if Assigned(V) then
    begin
      Pointer(A) := nil;
      if V is ABlaiseType then
        ABlaiseType(V).ReleaseReference;
    end;
end;

procedure ObjectsReleaseReference(const A: ObjectArray);
var I : Integer;
    V : TObject;
begin
  For I := 0 to Length(A) - 1 do
    begin
      V := A[I];
      if V is ABlaiseType then
        ABlaiseType(V).ReleaseReference;
    end;
end;

procedure ObjectReleaseUnreferenced(const A: TObject);
begin
  if Assigned(A) then
    if A is ABlaiseType then
      ABlaiseType(A).ReleaseUnreferenced;
end;

function ObjectIsUnique(const A: TObject): Boolean;
begin
  if A is ABlaiseType then
    Result := ABlaiseType(A).IsUniqueReference
  else
    Result := False;
end;

function ObjectIsUnreferenced(const A: TObject): Boolean;
begin
  if A is ABlaiseType then
    Result := ABlaiseType(A).IsUnreferenced
  else
    Result := False;
end;

function ObjectUnique(const A: TObject): TObject;
begin
  if A is ABlaiseType then
    if ABlaiseType(A).IsUniqueReference then
      Result := A
    else
      Result := ObjectDuplicate(A)
  else
    Result := A;
end;

procedure ObjectUniqueVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseType then
    if ABlaiseType(A).IsUniqueReference then
      P.SetResult(A)
    else
      ObjectDuplicateVM(P, A)
  else
    P.SetResult(A);
end;

procedure ObjectEnsureReferenceUnique(var A: TObject);
var U: TObject;
begin
  U := ObjectUnique(A);
  if U <> A then
    begin
      ObjectReleaseReference(A);
      A := U;
    end;
end;

procedure ObjectsReleaseUnreferenced(const A: Array of TObject);
var I : Integer;
    B : TObject;
begin
  For I := 0 to Length(A) - 1 do
    begin
      B := A[I];
      if B is ABlaiseType then
        ABlaiseType(B).ReleaseUnreferenced;
    end;
end;

{$WARNINGS OFF}
procedure ObjectAssign(const A, B: TObject);
begin
  if A = B then
    exit else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Assign__', [B], False) else
  if (A is AType) or (B is AType) then
    TypeAssign(A, B)
  else
    ObjectOperationNotSupportedError(A, B, 'Assign');
end;

function ObjectDuplicate(const A: TObject): TObject;
begin
  if not Assigned(A) then
    Result := nil else
  if A = UnassignedValue then
    Result := UnassignedValue else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate('__Duplicate__') else
  if A is AType then
    Result := AType(A).Duplicate
  else
    ObjectOperationNotSupportedError(A, 'Duplicate');
end;
{$WARNINGS ON}

procedure ObjectDuplicateVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if not Assigned(A) then
    P.SetResult(nil) else
  if A = UnassignedValue then
    P.SetResult(UnassignedValue) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Duplicate__', []) else
  if A is AType then
    P.SetResult(AType(A).Duplicate)
  else
    ObjectOperationNotSupportedError(A, 'Duplicate');
end;

function ObjectIsEqual(const A, B: TObject): Boolean;
begin
  if A = B then
    Result := True else
  if not Assigned(A) or not Assigned(B) then
    Result := False else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(ABlaiseObject(A).Evaluate(
        '__IsEqual__', [B], True, True, False)) else
  if B is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(ABlaiseObject(B).Evaluate(
        '__IsEqual__', [A], True, True, False)) else
  if A is AType then
    Result := AType(A).IsEqual(B) else
  if B is AType then
    Result := AType(B).IsEqual(A)
  else
    raise EBlaiseType.Create(BlaiseClassName(A) + ' and ' + BlaiseClassName(B) +
        ' cannot compare');
end;

function ObjectCompare(const A, B: TObject): TCompareResult;
begin
  if A = B then
    Result := crEqual else
  if A is ABlaiseObject then
    Result := TCompareResult(ObjectGetAsIntegerAndRelease(
        ABlaiseObject(A).Evaluate('__Compare__', [B], True, True, False))) else
  if B is ABlaiseObject then
    Result := ReverseCompareResult(TCompareResult(ObjectGetAsIntegerAndRelease(
        ABlaiseObject(B).Evaluate('__Compare__', [A], True, True, False)))) else
  if A is AType then
    Result := AType(A).Compare(B) else
  if B is AType then
    Result := ReverseCompareResult(AType(B).Compare(A))
  else
    Result := crUndefined;
end;

function IntegerToCompareResult(const I: Int64): TCompareResult;
begin
  if (I >= Ord(Low(TCompareResult))) and (I <= Ord(High(TCompareResult))) then
    Result := TCompareResult(I)
  else
    Result := crUndefined
end;

function SimpleGetAsString(const A: TObject): String;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsString else
  if A is ABlaiseType and not (A is ABlaiseObject) then
    Result := ABlaiseType(A).AsString
  else
    ObjectConvertToError(A, 'string');
end;

function ObjectGetAsString(const A: TObject): String;
var R : TObject;
begin
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsString__');
      try
        Result := TypeGetAsString(R);
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end
  else
    Result := TypeGetAsString(A);
end;

procedure ObjectSetAsString(const A, V: TObject);
begin
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsString__', [V], False) else
  if A is AType then
    AType(A).AsString := ObjectGetAsString(V)
  else
    ObjectOperationNotSupportedError(A, 'SetAsString');
end;

procedure ObjectSetAsString(const A: TObject; const V: String);
begin
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsString__', [TTString.Create(V)], True) else
  if A is AType then
    AType(A).AsString := V
  else
    ObjectOperationNotSupportedError(A, 'SetAsString');
end;

function SimpleGetAsUTF8(const A: TObject): String;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsUTF8 else
  if A is ABlaiseType and not (A is ABlaiseObject) then
    Result := ABlaiseType(A).AsUTF8
  else
    ObjectConvertToError(A, 'string');
end;

function ObjectGetAsUTF8(const A: TObject): String;
var R : TObject;
begin
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsUTF8__');
      try
        if R is ABlaiseType then
          Result := ABlaiseType(R).AsUTF8
        else
          ObjectConvertToError(A, 'string');
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end else
  if A is ABlaiseType then
    Result := ABlaiseType(A).AsUTF8
  else
    ObjectConvertToError(A, 'string');
end;

function ObjectGetAsUTF16(const A: TObject): WideString;
var R : TObject;
begin
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsUTF16__');
      try
        if R is ABlaiseType then
          Result := ABlaiseType(R).AsUTF16
        else
          ObjectConvertToError(A, 'string');
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end else
  if A is ABlaiseType then
    Result := ABlaiseType(A).AsUTF16
  else
    ObjectConvertToError(A, 'string');
end;

procedure ObjectSetAsUTF16(const A, V: TObject);
begin
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsUTF16__', [V], False) else
  if A is ABlaiseType then
    ABlaiseType(A).AsUTF16 := ObjectGetAsUTF16(V)
  else
    ObjectConvertFromError(A, 'string');
end;

function ObjectGetAsBlaise(const A: TObject): String;
var R : TObject;
begin
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetRepr__');
      try
        Result := TypeGetAsString(R);
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end else
  if A is ABlaiseType then
    Result := ABlaiseType(A).AsBlaise
  else
    Result := TypeGetAsString(A);
end;

function ObjectHashValue(const A: TObject): LongWord;
begin
  if A is ABlaiseObject then
    Result := ObjectGetAsIntegerAndRelease(ABlaiseObject(A).Evaluate(
        '__HashValue__', [], True, False, False)) else
    Result := TypeHashValue(A);
end;

function IsSystemFieldName(const FieldName: String): Boolean;
begin
  Result := StrMatchLeft(FieldName, '__', True);
end;



{                                                                              }
{ ASimpleType helper functions                                                 }
{                                                                              }

{ Representations                                                              }

{$WARNINGS OFF}
function SimpleGetAsBoolean(const A: TObject): Boolean;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsBoolean
  else
    ObjectConvertToError(A, 'boolean');
end;

function ObjectGetAsBoolean(const A: TObject): Boolean;
var R : TObject;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsBoolean else
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsBoolean__');
      try
        if R is ASimpleType then
          Result := ASimpleType(R).AsBoolean else
          ObjectConvertToError(A, 'boolean');
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end
  else
    ObjectConvertToError(A, 'boolean');
end;

function ObjectGetAsBooleanAndRelease(const A: TObject): Boolean;
begin
  try
    Result := ObjectGetAsBoolean(A);
  finally
    ObjectReleaseUnreferenced(A);
  end;
end;

function SimpleGetAsInteger(const A: TObject): Int64;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsInteger else
    ObjectConvertToError(A, 'integer');
end;

function ObjectGetAsInteger(const A: TObject): Int64;
var R : TObject;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsInteger else
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsInteger__');
      try
        if R is ASimpleType then
          Result := ASimpleType(R).AsInteger else
          ObjectConvertToError(A, 'integer');
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end
  else
    ObjectConvertToError(A, 'integer');
end;

function ObjectGetAsIntegerAndRelease(const A: TObject): Int64;
begin
  try
    Result := ObjectGetAsInteger(A);
  finally
    ObjectReleaseUnreferenced(A);
  end;
end;

function SimpleGetAsFloat(const A: TObject): Extended;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsFloat
  else
    ObjectConvertToError(A, 'float');
end;

function ObjectGetAsFloat(const A: TObject): Extended;
var R : TObject;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsFloat else
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsFloat__');
      try
        if R is ASimpleType then
          Result := ASimpleType(R).AsFloat else
          ObjectConvertToError(A, 'float');
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end
  else
    ObjectConvertToError(A, 'float');
end;

function ObjectGetAsFloatAndRelease(const A: TObject): Extended;
begin
  try
    Result := ObjectGetAsFloat(A);
  finally
    ObjectReleaseUnreferenced(A);
  end;
end;

function ObjectGetAsDateTime(const A: TObject): TDateTime;
var R : TObject;
begin
  if A is ASimpleType then
    Result := ASimpleType(A).AsDateTime else
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetAsDateTime__');
      try
        if R is ASimpleType then
          Result := ASimpleType(R).AsDateTime else
          ObjectConvertToError(A, 'dateTime');
      finally
        ObjectReleaseUnreferenced(R);
      end;
    end
  else
    ObjectConvertToError(A, 'datetime');
end;

function ObjectGetAsDateTimeAndRelease(const A: TObject): TDateTime;
begin
  try
    Result := ObjectGetAsDateTime(A);
  finally
    ObjectReleaseUnreferenced(A);
  end;
end;

function ObjectGetAsChar(const A: TObject): Char;
begin
  if A is TTChar then
    Result := TTChar(A).Value else
  if (A is TTString) and (TTString(A).Len = 1) then
    Result := TTString(A).Character[1]
  else
    ObjectConvertToError(A, 'char');
end;

function ObjectGetAsCharAndRelease(const A: TObject): Char;
begin
  try
    Result := ObjectGetAsChar(A);
  finally
    ObjectReleaseUnreferenced(A);
  end;
end;

function ObjectGetAsUnicodeChar(const A: TObject): UCS4Char;
begin
  if A is TTUnicodeChar then
    Result := TTUnicodeChar(A).Value else
  if (A is TTUnicodeString) and (TTUnicodeString(A).Len = 1) then
    Result := UCS4Char(TTUnicodeString(A).Character[1])
  else
    ObjectConvertToError(A, 'char');
end;

function ObjectGetAsUnicodeCharAndRelease(const A: TObject): UCS4Char;
begin
  try
    Result := ObjectGetAsUnicodeChar(A);
  finally
    ObjectReleaseUnreferenced(A);
  end;
end;
{$WARNINGS ON}

procedure ObjectSetAsUTF8(const A: TObject; const V: String);
begin
  if A is ASimpleType then
    ASimpleType(A).AsUTF8 := V else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsUTF8__', [TTString.Create(V)], True)
  else
    ObjectConvertFromError(A, 'utf8');
end;

procedure ObjectSetAsBoolean(const A: TObject; const V: Boolean);
begin
  if A is ASimpleType then
    ASimpleType(A).AsBoolean := V else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsBoolean__', [GetImmutableBoolean(V)], True)
  else
    ObjectConvertFromError(A, 'boolean');
end;

procedure ObjectSetAsInteger(const A: TObject; const V: Integer);
begin
  if A is ASimpleType then
    ASimpleType(A).AsInteger := V else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsInteger__', [GetImmutableInteger(V)], True)
  else
    ObjectConvertFromError(A, 'integer');
end;

procedure ObjectSetAsFloat(const A: TObject; const V: Extended);
begin
  if A is ASimpleType then
    ASimpleType(A).AsFloat := V else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__SetAsFloat__', [TTFloat.Create(V)], True)
  else
    ObjectConvertFromError(A, 'float');
end;

{ Type checking                                                                }
function ObjectGetTypeID(const A: TObject): Byte;
begin
  if A is ABlaiseType then
    Result := ABlaiseType(A).GetTypeID
  else
    Result := BLAISE_TYPE_ID_GEN_Object;
end;

function ObjectIsTypeDefinition(const A: TObject): Boolean;
begin
  if A is ATypeDefinition then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsTypeDefinition__')) else
  if A is ABlaiseType then
    Result := TypeIDIsTypeDefinition(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsSimpleType(const A: TObject): Boolean;
begin
  if A is ASimpleType then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsSimpleType__')) else
  if A is ABlaiseType then
    Result := TypeIDIsSimpleType(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsString(const A: TObject): Boolean;
begin
  if A is TTString then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsString__')) else
  if A is ABlaiseType then
    Result := ABlaiseType(A).GetTypeID = BLAISE_TYPE_ID_STRING
  else
    Result := False;
end;

function ObjectIsUnicodeString(const A: TObject): Boolean;
begin
  if A is TTUnicodeString then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsUnicodeString__')) else
  if A is ABlaiseType then
    Result := ABlaiseType(A).GetTypeID = BLAISE_TYPE_ID_UNICODE
  else
    Result := False;
end;

function ObjectIsBoolean(const A: TObject): Boolean;
begin
  if A is TTBoolean then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsBoolean__')) else
  if A is ABlaiseType then
    Result := ABlaiseType(A).GetTypeID = BLAISE_TYPE_ID_BOOLEAN
  else
    Result := False;
end;

function ObjectIsInteger(const A: TObject): Boolean;
begin
  if A is TTInteger then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsInteger__')) else
  if A is ABlaiseType then
    Result := TypeIDIsInteger(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsOrdinal(const A: TObject): Boolean;
begin
  if A is AIntegerNumberType then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__IsOrdinal__')) else
  if A is ABlaiseType then
    Result := TypeIDIsOrdinal(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsReal(const A: TObject): Boolean;
begin
  if A is ARealNumberType then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsReal__')) else
  if A is ABlaiseType then
    Result := TypeIDIsReal(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsFloat(const A: TObject): Boolean;
begin
  if A is AFloatBase then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsFloat__')) else
  if A is ABlaiseType then
    Result := TypeIDIsFloat(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsDateTime(const A: TObject): Boolean;
begin
  if A is ADateTimeType then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsDateTime__')) else
  if A is ABlaiseType then
    Result := TypeIDIsDateTime(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsFunction(const A: TObject): Boolean;
begin
  if A is AFunction then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsFunction__')) else
  if A is ABlaiseType then
    Result := TypeIDIsFunction(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsStream(const A: TObject): Boolean;
begin
  if A is ABlaiseStream then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsStream__')) else
  if A is ABlaiseType then
    Result := TypeIDIsStream(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsSequence(const A: TObject): Boolean;
begin
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsSequence__')) else
  if A is ABlaiseType then
    Result := TypeIDIsSequence(ABlaiseType(A).GetTypeID)
  else
    Result := False;
end;

function ObjectIsNameSpace(const A: TObject): Boolean;
begin
  if A is ANameSpace then
    Result := True else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__IsNameSpace__'))
  else
    Result := False;
end;

{ Numeric operations                                                           }
procedure ObjectAbs(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Abs else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Abs__') else
    ObjectOperationNotSupportedError(A, 'Abs');
end;

procedure ObjectNegate(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Negate else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Negate__') else
    ObjectOperationNotSupportedError(A, 'Negate');
end;

procedure ObjectAbsVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Abs else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Abs__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Abs');
end;

procedure ObjectNegateVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Negate else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Negate__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Negate');
end;

procedure ObjectAdd(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Add(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Add__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Add');
end;

procedure ObjectReversedAdd(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedAdd(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedAdd__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Add');
end;

procedure ObjectSubtract(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Subtract(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Subtract__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Subtract');
end;

procedure ObjectReversedSubtract(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedSubtract(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedSubtract__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Subtract');
end;

procedure ObjectMultiply(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Multiply(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Multiply__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Multiply');
end;

procedure ObjectReversedMultiply(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedMultiply(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedMultiply__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Multiply');
end;

procedure ObjectDivide(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Divide(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Divide__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Divide');
end;

procedure ObjectReversedDivide(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedDivide(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedDivide__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Divide');
end;

procedure ObjectPower(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Power(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Power__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Power');
end;

procedure ObjectReversedPower(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedPower(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedPower__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Power');
end;

procedure ObjectIntegerDivide(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).IntegerDivide(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__IntegerDivide__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Integer Divide');
end;

procedure ObjectReversedIntegerDivide(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedIntegerDivide(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedIntegerDivide__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Integer Divide');
end;

procedure ObjectModulo(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Modulo(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Modulo__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Modulo');
end;

procedure ObjectReversedModulo(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedModulo(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedModulo__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Modulo');
end;

procedure ObjectAddVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Add(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Add__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Add');
end;

procedure ObjectReversedAddVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedAdd(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedAdd__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Add');
end;

procedure ObjectSubtractVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Subtract(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Subtract__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Subtract');
end;

procedure ObjectReversedSubtractVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedSubtract(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedSubtract__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Subtract');
end;

procedure ObjectMultiplyVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Multiply(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Multiply__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Multiply');
end;

procedure ObjectReversedMultiplyVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedMultiply(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedMultiply__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Multiply');
end;

procedure ObjectDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Divide(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Divide__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Divide');
end;

procedure ObjectReversedDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedDivide(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedDivide__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Divide');
end;

procedure ObjectPowerVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Power(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Power__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Power');
end;

procedure ObjectReversedPowerVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedPower(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedPower__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Power');
end;

procedure ObjectIntegerDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).IntegerDivide(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__IntegerDivide__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Integer Divide');
end;

procedure ObjectReversedIntegerDivideVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedIntegerDivide(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedIntegerDivide__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Integer Divide');
end;

procedure ObjectModuloVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Modulo(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Modulo__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Modulo');
end;

procedure ObjectReversedModuloVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedModulo(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedModulo__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Modulo');
end;

procedure ObjectSqr(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Sqr else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Sqr__') else
    ObjectOperationNotSupportedError(A, 'Sqr');
end;

procedure ObjectSqrt(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Sqrt else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Sqrt__') else
    ObjectOperationNotSupportedError(A, 'Sqrt');
end;

procedure ObjectExp(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Exp else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Exp__') else
    ObjectOperationNotSupportedError(A, 'Exp');
end;

procedure ObjectLn(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Ln else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Ln__') else
    ObjectOperationNotSupportedError(A, 'Ln');
end;

procedure ObjectSin(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Sin else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Sin__') else
    ObjectOperationNotSupportedError(A, 'Sin');
end;

procedure ObjectCos(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Cos else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Cos__') else
    ObjectOperationNotSupportedError(A, 'Cos');
end;

procedure ObjectSqrVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Sqr else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Sqr__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Sqr');
end;

procedure ObjectSqrtVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Sqrt else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Sqrt__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Sqrt');
end;

procedure ObjectExpVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Exp else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Exp__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Exp');
end;

procedure ObjectLnVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Ln else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Ln__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Ln');
end;

procedure ObjectSinVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Sin else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Sin__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Sin');
end;

procedure ObjectCosVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).Cos else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Cos__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Cos');
end;

procedure ObjectLogicalAND(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalAND(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__LogicalAND__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Logical AND');
end;

procedure ObjectReversedLogicalAND(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedLogicalAND(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedLogicalAND__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Logical AND');
end;

procedure ObjectLogicalOR(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalOR(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__LogicalOR__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Logical OR');
end;

procedure ObjectReversedLogicalOR(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedLogicalOR(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedLogicalOR__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Logical OR');
end;

procedure ObjectLogicalXOR(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalXOR(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__LogicalXOR__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Logical XOR');
end;

procedure ObjectReversedLogicalXOR(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedLogicalXOR(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedLogicalXOR__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Logical XOR');
end;

procedure ObjectLogicalNOT(const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalNOT else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__LogicalNOT__') else
    ObjectOperationNotSupportedError(A, 'Logical NOT');
end;

procedure ObjectLogicalNOTVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalNOT else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__LogicalNOT__', [], nil) else
    ObjectOperationNotSupportedError(A, 'Logical NOT');
end;

procedure ObjectBitwiseSHL(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).BitwiseSHL(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__BitwiseSHL__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Bitwise SHL');
end;

procedure ObjectBitwiseSHR(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).BitwiseSHR(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__BitwiseSHR__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Bitwise SHR');
end;

procedure ObjectReversedBitwiseSHL(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedBitwiseSHL(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedBitwiseSHL__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Bitwise SHL');
end;

procedure ObjectReversedBitwiseSHR(const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedBitwiseSHR(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__ReversedBitwiseSHR__', [B], False) else
    ObjectOperationNotSupportedError(A, 'Reversed Bitwise SHR');
end;

procedure ObjectLogicalANDVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalAND(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '_LogicalAND', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Logical AND');
end;

procedure ObjectReversedLogicalANDVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedLogicalAND(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedLogicalAND__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Logical AND');
end;

procedure ObjectLogicalORVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalOR(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__LogicalOR__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Logical OR');
end;

procedure ObjectReversedLogicalORVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedLogicalOR(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedLogicalOR__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Logical OR');
end;

procedure ObjectLogicalXORVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).LogicalXOR(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__LogicalXOR__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Logical XOR');
end;

procedure ObjectReversedLogicalXORVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedLogicalXOR(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedLogicalXOR__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Logical XOR');
end;

procedure ObjectBitwiseSHLVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).BitwiseSHL(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__BitwiseSHL__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Bitwise SHL');
end;

procedure ObjectReversedBitwiseSHLVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedBitwiseSHL(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedBitwiseSHL__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Bitwise SHL');
end;

procedure ObjectBitwiseSHRVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).BitwiseSHR(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__BitwiseSHR__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Bitwise SHR');
end;

procedure ObjectReversedBitwiseSHRVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ABlaiseMathType then
    ABlaiseMathType(A).ReversedBitwiseSHR(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__ReversedBitwiseSHR__', [B], nil) else
    ObjectOperationNotSupportedError(A, 'Reversed Bitwise SHR');
end;

procedure ObjectInc(const A: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Inc(1) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Inc__')
  else
    ObjectOperationNotSupportedError(A, 'Inc');
end;

procedure ObjectDec(const A: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Dec(1) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Dec__')
  else
    ObjectOperationNotSupportedError(A, 'Dec');
end;

procedure ObjectInc(const A, B: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Inc(ObjectGetAsInteger(B)) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Inc__', [B], False)
  else
    ObjectOperationNotSupportedError(A, 'Inc');
end;

procedure ObjectDec(const A, B: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Dec(ObjectGetAsInteger(B)) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Dec__', [B], False)
  else
    ObjectOperationNotSupportedError(A, 'Dec');
end;

procedure ObjectIncVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Inc(1) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Inc__', [], nil)
  else
    ObjectOperationNotSupportedError(A, 'Inc');
end;

procedure ObjectDecVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Dec(1) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Dec__', [], nil)
  else
    ObjectOperationNotSupportedError(A, 'Dec');
end;

procedure ObjectIncVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Inc(ObjectGetAsInteger(B)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Inc__', [B], nil)
  else
    ObjectOperationNotSupportedError(A, 'Inc');
end;

procedure ObjectDecVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  if A is ASimpleType then
    ASimpleType(A).Dec(ObjectGetAsInteger(B)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Dec__', [B], nil)
  else
    ObjectOperationNotSupportedError(A, 'Dec');
end;

function ObjectIsIn(const A, B: TObject): Boolean;
begin
  Result := False;
end;

procedure ObjectIsInVM(const P: AVirtualMachineProcess; const A, B: TObject);
begin
  P.SetResult(GetImmutableBoolean(False));
end;



{ Coerce                                                                       }
const
  SimpleTypeUnaryCoerceCalls: Array[TUnaryMathOperation] of String = (
      '__CoerceSqr__', '__CoerceSqrt__',
      '__CoerceExp__', '__CoerceLn__',
      '__CoerceSin__', '__CoerceCos__');

const
  SimpleTypeLeftCoerceCalls: Array[TBinaryMathOperation] of String =(
      '__CoerceAdd__', '__CoerceSubtract__', '__CoerceMultiply__', '__CoerceDivide__',
      '__CoerceIntegerDivide__', '__CoerceModulo__',
      '__CoerceLogicalAND__', '__CoerceLogicalOR__', '__CoerceLogicalXOR__',
      '__CoerceBitwiseSHL__', '__CoerceBitwiseSHR__',
      '__CoercePower__'
    );

const
  SimpleTypeRightCoerceCalls: Array[TBinaryMathOperation] of String =(
      '__ReversedCoerceAdd__', '__ReversedCoerceSubtract__',
      '__ReversedCoerceMultiply__', '__ReversedCoerceDivide__',
      '__ReversedCoerceIntegerDivide__', '__ReversedCoerceModulo__',
      '__ReversedCoerceLogicalAND__', '__ReversedCoerceLogicalOR__',
      '__ReversedCoerceLogicalXOR__',
      '__ReversedCoerceBitwiseSHL__', '__ReversedCoerceBitwiseSHR__',
      '__ReversedCoercePower__'
    );

{$WARNINGS OFF}
function ObjectUnaryOpCoerce(const Operation: TUnaryMathOperation;
    const A: TObject): TObject;
begin
  if A is ABlaiseMathType then
    Result := ABlaiseMathType(A).UnaryOpCoerce(Operation) else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate(SimpleTypeUnaryCoerceCalls[Operation], [],
        False, False, False)
  else
    ObjectOperationNotSupportedError(A, 'Unary Coerce');
end;

procedure ObjectUnaryOpCoerceVM(const P: AVirtualMachineProcess;
    const Operation: TUnaryMathOperation; const A: TObject);
begin
  if A is ABlaiseMathType then
    P.SetResult(ABlaiseMathType(A).UnaryOpCoerce(Operation)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), SimpleTypeUnaryCoerceCalls[Operation], [], nil)
  else
    ObjectOperationNotSupportedError(A, 'Unary Coerce');
end;

function ObjectBinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const A, B: TObject): TObject;
begin
  if A is ABlaiseMathType then
    Result := ABlaiseMathType(A).BinaryOpLeftCoerce(Operation, B) else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate(SimpleTypeLeftCoerceCalls[Operation], [B],
        False, False, False)
  else
    ObjectOperationNotSupportedError(A, 'Binary Coerce');
end;

function ObjectBinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const A, B: TObject): TObject;
begin
  if A is ABlaiseMathType then
    Result := ABlaiseMathType(A).BinaryOpRightCoerce(Operation, B) else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate(SimpleTypeRightCoerceCalls[Operation], [B],
        False, False, False)
  else
    ObjectOperationNotSupportedError(A, 'Reversed Binary Coerce');
end;

function ObjectBinaryOpLeftCoerceVM(const P: AVirtualMachineProcess;
    const Operation: TBinaryMathOperation; const A, B: TObject): TObject;
begin
  if A is ABlaiseMathType then
    P.SetResult(ABlaiseMathType(A).BinaryOpLeftCoerce(Operation, B)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), SimpleTypeLeftCoerceCalls[Operation], [B], nil)
  else
    ObjectOperationNotSupportedError(A, 'Binary Coerce');
end;

function ObjectBinaryOpRightCoerceVM(const P: AVirtualMachineProcess;
    const Operation: TBinaryMathOperation; const A, B: TObject): TObject;
begin
  if A is ABlaiseMathType then
    P.SetResult(ABlaiseMathType(A).BinaryOpRightCoerce(Operation, B)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), SimpleTypeRightCoerceCalls[Operation], [B], nil)
  else
    ObjectOperationNotSupportedError(A, 'Reversed Binary Coerce');
end;

function ObjectIterate(const A: TObject): TObject;
begin
  if A is ABlaiseIterator then
    Result := A else
  if A is ABlaiseArray then
    Result := ABlaiseArray(A).Iterate else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate('__Iterate__', [], True, False, False)
  else
    ObjectOperationNotSupportedError(A, 'Iterate');
end;

procedure ObjectIterateVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseIterator then
    P.SetResult(A) else
  if A is ABlaiseArray then
    P.SetResult(ABlaiseArray(A).Iterate) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Iterate__', [], nil)
  else
    ObjectOperationNotSupportedError(A, 'Iterate');
end;

function ObjectHasNext(const A: TObject): Boolean;
begin
  if A is ABlaiseIterator then
    Result := not ABlaiseIterator(A).EOF else
  if A is ABlaiseObject then
    Result := ObjectGetAsBoolean(ABlaiseObject(A).Evaluate('__HasNext__', [], True, False, False))
  else
    ObjectOperationNotSupportedError(A, 'HasNext');
end;

function ObjectNext(const A: TObject): TObject;
begin
  if A is ABlaiseIterator then
    Result := ABlaiseIterator(A).Next else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate('__Next__', [], True, False, False)
  else
    ObjectOperationNotSupportedError(A, 'Next');
end;
{$WARNINGS ON}

procedure ObjectHasNextVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseIterator then
    P.SetResult(GetImmutableBoolean(not ABlaiseIterator(A).EOF)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__HasNext__', [], nil)
  else
    ObjectOperationNotSupportedError(A, 'HasNext');
end;

procedure ObjectNextVM(const P: AVirtualMachineProcess; const A: TObject);
begin
  if A is ABlaiseIterator then
    P.SetResult(ABlaiseIterator(A).Next) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__Next__', [], nil)
  else
    ObjectOperationNotSupportedError(A, 'Next');
end;

{$WARNINGS OFF}
function ObjectEOF(const A: TObject): Boolean;
begin
  if A is ABlaiseStream then
    Result := ABlaiseStream(A).EOF else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(
        ABlaiseObject(A).Evaluate('__EOF__', [], True, False, False))
  else
    ObjectOperationNotSupportedError(A, 'EOF');
end;

function ObjectFunctionGetParameters(const A: TObject): TParameterAttributesArray;
var R    : TObject;
    I, L : Integer;
    J    : TTInteger;
begin
  if A is AFunction then
    Result := AFunction(A).GetParameters else
  if A is ABlaiseObject then
    begin
      R := ABlaiseObject(A).Evaluate('__GetParameters__', [], True, False, False);
      L := ObjectGetLength(R);
      SetLength(Result, L);
      if L > 0 then
        begin
          For I := 0 to L - 1 do
            begin
              J := GetImmutableInteger(I);
              Result[I] := TParameterAttributes(Byte(ObjectGetAsInteger(
                  ObjectGetIndexedValue(R, J, False))));
              ObjectReleaseUnreferenced(J);
            end;
        end;
    end
  else
    ObjectOperationNotSupportedError(A, 'GetMachineCode');
end;

function ObjectFunctionGetMachineCode(const A: TObject): Pointer;
begin
  if A is AFunction then
    Result := AFunction(A).GetMachineCode else
  if A is ABlaiseObject then
    Result := Pointer(LongWord(ObjectGetAsInteger(
        ABlaiseObject(A).Evaluate('__GetMachineCode__', [], True, False, False))))
  else
    ObjectOperationNotSupportedError(A, 'GetMachineCode');
end;

function ObjectFunctionCall(const A: TObject; const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var P : ObjectArray;
    L : Integer;
begin
  if A is AFunction then
    Result := AFunction(A).Call(Scope, Parameters) else
  if A is ABlaiseObject then
    begin
      L := Length(Parameters);
      SetLength(P, L + 1);
      P[0] := Scope;
      if L > 0 then
        Move(Parameters[0], P[1], L * Sizeof(TObject));
      Result := ABlaiseObject(A).Evaluate('__Call__', P, True, False, False);
    end
  else
    ObjectOperationNotSupportedError(A, 'Call');
end;
{$WARNINGS ON}



{                                                                              }
{ Container helper functions                                                   }
{                                                                              }
procedure ObjectAppendItem(const A, B: TObject);
begin
  if A is ABlaiseArray then
    ABlaiseArray(A).Append(B) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__AppendItem__', [B], False)
  else
    ObjectOperationNotSupportedError(A, 'AppendItem');
end;

procedure ObjectAppendList(const A, B: TObject);
begin
  if (A is ABlaiseArray) and (B is ABlaiseArray) then
    ABlaiseArray(A).AppendList(ABlaiseArray(B)) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__AppendList__', [B], False)
  else
    ObjectOperationNotSupportedError(A, 'AppendList');
end;

procedure ObjectAppendItemVM(const P: AVirtualMachineProcess;
    const A, B: TObject);
begin
  if A is ABlaiseArray then
    ABlaiseArray(A).Append(B) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__AppendItem__', [B], nil)
  else
    ObjectOperationNotSupportedError(A, 'AppendItem');
end;

procedure ObjectAppendListVM(const P: AVirtualMachineProcess;
    const A, B: TObject);
begin
  if (A is ABlaiseArray) and (B is ABlaiseArray) then
    ABlaiseArray(A).AppendList(ABlaiseArray(B)) else
  if A is ABlaiseObject then
    P.ScopeEval(ABlaiseObject(A), '__AppendList__', [B], nil)
  else
    ObjectOperationNotSupportedError(A, 'AppendList');
end;

function ArrayGetCount(const A: TObject; var Count: Integer): Boolean;
begin
  Result := True;
  if A is AStringBase then
    Count := AStringBase(A).Len else
  if A is ABlaiseArray then
    Count := ABlaiseArray(A).Count else
  if A is ABlaiseVector then
    Count := ABlaiseVector(A).Count else
  if A is ABlaiseMatrix then
    Count := ABlaiseMatrix(A).RowCount
  else
    begin
      Count := 0;
      Result := False;
    end;
end;

{$WARNINGS OFF}
function ObjectGetCount(const A: TObject): Int64;
var C : Integer;
begin
  if ArrayGetCount(A, C) then
    Result := C else
  if A is ABlaiseObject then
    Result := ObjectGetAsIntegerAndRelease(ABlaiseObject(A).Evaluate('__GetCount__'))
  else
    ObjectOperationNotSupportedError(A, 'GetCount');
end;
{$WARNINGS ON}

function ObjectGetLength(const A: TObject): Integer;
begin
  if ArrayGetCount(A, Result) then
    exit;
  if A is ABlaiseObject then
    Result := ObjectGetAsIntegerAndRelease(ABlaiseObject(A).Evaluate('__GetLength__'))
  else
    Result := 0;
end;

{$WARNINGS OFF}
function ObjectGetIndexedValue(const A, Index: TObject;
    const ReversedIndex: Boolean): TObject;
var I : Int64;
    R : Boolean;
begin
  R := False;
  if not ReversedIndex then
    begin
      if A is ABlaiseDictionary then
        Result := ABlaiseDictionary(A).Item[Index] else
      if A is ABlaiseObject then
        Result := ABlaiseObject(A).Evaluate('__GetItem__', [Index], True, True, False) else
      if (A is ABlaiseArray) or (A is TTString) or (A is TTUnicodeString) or
         (A is ABlaiseVector) or (A is ABlaiseMatrix) then
        begin
          I := ObjectGetAsInteger(Index);
          R := True;
        end
      else
        ObjectOperationNotSupportedError(A, 'GetItem');
    end
  else
    begin
      I := ObjectGetCount(A) + ObjectGetAsInteger(Index) - 1;
      if A is ABlaiseObject then
        Result := ABlaiseObject(A).Evaluate('__GetItem__', [GetImmutableInteger(I)], True, True, True)
      else
        R := True;
    end;
  if R then
    if A is ABlaiseArray then
      Result := ABlaiseArray(A).Item[I] else
    if A is TTString then
      Result := TTString.Create(TTString(A).Character[I]) else
    if A is TTUnicodeString then
      Result := TTUnicodeString.Create(TTUnicodeString(A).Character[I]) else
    if A is ABlaiseVector then
      Result := ABlaiseVector(A).Item[I] else
    if A is ABlaiseMatrix then
      Result := ABlaiseMatrix(A).Row[I]
    else
      ObjectOperationNotSupportedError(A, 'GetItem');
end;
{$WARNINGS ON}

procedure ObjectAssignIndexedValue(const A, Index, Value: TObject;
    const ReversedIndex: Boolean);
var I : Int64;
    R : Boolean;
    V : TObject;
begin
  I := -1;
  R := False;
  if not ReversedIndex then
    begin
      if A is ABlaiseDictionary then
        ABlaiseDictionary(A).Item[Index] := Value else
      if A is ABlaiseObject then
        ABlaiseObject(A).Execute('__SetItem__', [Index, Value], False) else
      if (A is ABlaiseArray) or (A is ABlaiseVector) then
        begin
          I := ObjectGetAsInteger(Index);
          R := True;
        end
      else
        ObjectOperationNotSupportedError(A, 'SetItem');
    end
  else
    begin
      I := ObjectGetCount(A) + ObjectGetAsInteger(Index) - 1;
      if A is ABlaiseObject then
        begin
          V := GetImmutableInteger(I);
          ABlaiseObject(A).Execute('__SetItem__', [V, Value], False);
          ObjectReleaseUnreferenced(V);
        end
      else
        R := True;
    end;
  if R then
    if A is ABlaiseArray then
      ABlaiseArray(A).Item[I] := Value else
    if A is ABlaiseVector then
      ABlaiseVector(A).Item[I] := Value
    else
      ObjectOperationNotSupportedError(A, 'SetItem');
end;

{$WARNINGS OFF}
procedure ObjectGetIndexedValueVM(const P: AVirtualMachineProcess;
    const A, Index: TObject; const ReversedIndex: Boolean;
    const Continuation: TBlaiseVMContinuation);
begin
  if not ReversedIndex and (A is ABlaiseObject) then
    P.ScopeEval(ABlaiseObject(A), '__GetItem__', [Index], Continuation)
  else
    begin
      P.SetResult(ObjectGetIndexedValue(A, Index, ReversedIndex));
      if Assigned(Continuation) then
        Continuation;
    end;
end;
{$WARNINGS ON}

procedure ObjectAssignIndexedValueVM(const P: AVirtualMachineProcess;
    const A, Index, Value: TObject; const ReversedIndex: Boolean);
begin
  if not ReversedIndex and (A is ABlaiseObject) then
    P.ScopeEval(ABlaiseObject(A), '__SetItem__', [Index, Value], nil)
  else
    ObjectAssignIndexedValue(A, Index, Value, ReversedIndex);
end;



{                                                                              }
{ Operation helper functions                                                   }
{                                                                              }
function OperationAbs(const A: TObject): TObject;
begin
  Result := ObjectDuplicate(A);
  try
    ObjectAbs(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function OperationNegate(const A: TObject): TObject;
begin
  Result := ObjectDuplicate(A);
  try
    ObjectNegate(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function OperationLogicalNOT(const A: TObject): TObject;
begin
  Result := ObjectDuplicate(A);
  try
    ObjectLogicalNOT(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

type
  SimpleUnaryOperationfunction = procedure(const A: TObject);

function SimpleUnaryOperation(const Operation: TUnaryMathOperation;
    const Func: SimpleUnaryOperationFunction; const Operand: TObject): TObject;
begin
  Assert(Assigned(Operand), 'Assigned(Operand)');
  // Coerce
  Result := ObjectUnaryOpCoerce(Operation, Operand);
  if not Assigned(Result) then
    raise EBlaiseType.Create(BlaiseClassName(Operand) + ': Operation not supported');
  if Result = Operand then
    Result := ObjectDuplicate(Operand);
  // Do operation
  try
    Func(Result);
  except
    ObjectReleaseUnreferenced(Result);
    raise;
  end;
end;

function OperationSqr(const A: TObject): TObject;
begin
  Result := SimpleUnaryOperation(umoSqr, ObjectSqr, A);
end;

function OperationSqrt(const A: TObject): TObject;
begin
  Result := SimpleUnaryOperation(umoSqrt, ObjectSqrt, A);
end;

function OperationExp(const A: TObject): TObject;
begin
  Result := SimpleUnaryOperation(umoExp, ObjectExp, A);
end;

function OperationLn(const A: TObject): TObject;
begin
  Result := SimpleUnaryOperation(umoLn, ObjectLn, A);
end;

function OperationSin(const A: TObject): TObject;
begin
  Result := SimpleUnaryOperation(umoSin, ObjectSin, A);
end;

function OperationCos(const A: TObject): TObject;
begin
  Result := SimpleUnaryOperation(umoCos, ObjectCos, A);
end;

type
  SimpleBinaryOperationfunction = procedure(const A, B: TObject);

function SimpleBinaryOperation(const Operation: TBinaryMathOperation;
    const Func, ReversedFunc: SimpleBinaryOperationFunction;
    const A, B: TObject): TObject;
begin
  // Attempt to coerce the left operand
  Result := ObjectBinaryOpLeftCoerce(Operation, A, B);
  if Assigned(Result) then
    begin
      if Result = A then
        Result := ObjectDuplicate(A);
      try
        Func(Result, B);
      except
        ObjectReleaseUnreferenced(Result);
        raise;
      end;
      exit;
    end;
  // Attempt to coerce the right operand
  Result := ObjectBinaryOpRightCoerce(Operation, B, A);
  if Assigned(Result) then
    begin
      if Result = B then
        Result := ObjectDuplicate(B);
      try
        ReversedFunc(Result, A);
      except
        ObjectReleaseUnreferenced(Result);
        raise;
      end;
      exit;
    end;
  // Attempt on the left operand using a duplicate
  Result := ObjectDuplicate(A);
  try
    Func(Result, B);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function OperationAdd(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoAdd,
      ObjectAdd, ObjectReversedAdd, A, B);
end;

function OperationSubtract(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoSubtract,
      ObjectSubtract, ObjectReversedSubtract, A, B);
end;

function OperationMultiply(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoMultiply,
      ObjectMultiply, ObjectReversedMultiply, A, B);
end;

function OperationDivide(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoDivide,
      ObjectDivide, ObjectReversedDivide, A, B);
end;

function OperationPower(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoPower,
      ObjectPower, ObjectReversedPower, A, B);
end;

function OperationIntegerDivide(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoIntegerDivide,
      ObjectIntegerDivide, ObjectReversedIntegerDivide, A, B);
end;

function OperationModulo(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoModulo,
      ObjectModulo, ObjectReversedModulo, A, B);
end;

function OperationLogicalOR(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoLogicalOR,
      ObjectLogicalOR, ObjectReversedLogicalOR, A, B);
end;

function OperationLogicalAND(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoLogicalAND,
      ObjectLogicalAND, ObjectReversedLogicalAND, A, B);
end;

function OperationLogicalXOR(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoLogicalXOR,
      ObjectLogicalXOR, ObjectReversedLogicalXOR, A, B);
end;

function OperationBitwiseSHL(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoBitwiseSHL,
      ObjectBitwiseSHL, ObjectReversedBitwiseSHL, A, B);
end;

function OperationBitwiseSHR(const A, B: TObject): TObject;
begin
  Result := SimpleBinaryOperation(bmoBitwiseSHR,
      ObjectBitwiseSHR, ObjectReversedBitwiseSHR, A, B);
end;

function OperationGetLength(const A: TObject): TObject;
begin
  Result := GetImmutableInteger(ObjectGetLength(A));
end;



{                                                                              }
{ Name space helper functions                                                  }
{                                                                              }
function ObjectGetNameSpace(const Root, NameSpace: TObject; const Name: String;
    var Position: Integer): TObject;
var Pos : TScopeValue;
    N   : TTString;
begin
  Result := nil;
  if NameSpace is ANameSpace then
    Result := ANameSpace(NameSpace).GetNameSpace(Root, Name, Position) else
  if NameSpace is ABlaiseObject then
    begin
      Pos := TScopeValue.Create(GetImmutableInteger(Position), [], nil);
      N := TTString.Create(Name);
      try
        Result := ABlaiseObject(NameSpace).Evaluate('__GetNameSpace__',
            [Root, N, Pos], True, False, False);
        try
          Position := ObjectGetAsInteger(Pos.Value);
        except
          ObjectReleaseUnreferenced(Result);
          raise;
        end;
      finally
        N.Free;
        Pos.Free;
      end;
    end
  else
    ObjectOperationNotSupportedError(NameSpace, 'GetNameSpace');
end;

{$WARNINGS OFF}
function ObjectNameSpaceGetItem(const A: TObject; const Key: String): TObject;
begin
  if A is ANameSpace then
    Result := ANameSpace(A).GetItem(Key) else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate('__GetItem__', [TTString.Create(Key)],
        True, False, True)
  else
    ObjectOperationNotSupportedError(A, 'GetItem');
end;

function ObjectNameSpaceExists(const A: TObject; const Key: String): Boolean;
begin
  if A is ANameSpace then
    Result := ANameSpace(A).Exists(Key) else
  if A is ABlaiseObject then
    Result := ObjectGetAsBooleanAndRelease(ABlaiseObject(A).Evaluate(
        '__Exists__', [TTString.Create(Key)], True, False, True))
  else
    ObjectOperationNotSupportedError(A, 'Exists');
end;

procedure ObjectNameSpaceSetItem(const A: TObject; const Key: String;
    const Value: TObject);
var S : TTString;
begin
  if A is ANameSpace then
    ANameSpace(A).SetItem(Key, Value) else
  if A is ABlaiseObject then
    begin
      S := TTString.Create(Key);
      try
        ABlaiseObject(A).Execute('__SetItem__', [S, Value], True);
      finally
        S.Free;
      end;
    end
  else
    ObjectOperationNotSupportedError(A, 'SetItem');
end;

procedure ObjectNameSpaceDelete(const A: TObject; const Key: String);
begin
  if A is ANameSpace then
    ANameSpace(A).Delete(Key) else
  if A is ABlaiseObject then
    ABlaiseObject(A).Execute('__Delete__', [TTString.Create(Key)], True)
  else
    ObjectOperationNotSupportedError(A, 'Delete');
end;

function ObjectNameSpaceDirectory(const A: TObject; const Key: String): TObject;
begin
  if A is ANameSpace then
    Result := ANameSpace(A).Directory(Key) else
  if A is ABlaiseObject then
    Result := ABlaiseObject(A).Evaluate('__Directory__', [TTString.Create(Key)],
        True, False, True)
  else
    ObjectOperationNotSupportedError(A, 'Directory');
end;
{$WARNINGS ON}

procedure NameSpaceUnresolvedError(const Unresolved: String);
begin
  raise ENameSpace.Create('Name did not resolve: Unresolved [' +
      Unresolved + ']');
end;

function NameSpaceResolve(const Root, NameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
var P : Integer;
    N : TObject;
begin
  P := Position;
  Result := ObjectGetNameSpace(Root, NameSpace, Name, Position);
  if (Position = P) or (Position > Length(Name)) or
      not Assigned(Result) then
    exit;
  N := Result;
  try
    Result := NameSpaceResolve(Root, N, Name, Position);
  finally
    ObjectReleaseUnreferenced(N);
  end;
end;

function NameSpaceResolveNameSpace(const NameSpace: TObject;
    const Name: String; var Key: String): TObject;
var L, P : Integer;
begin
  L := Length(Name);
  if L = 0 then
    begin
      Key := '';
      Result := NameSpace;
      exit;
    end;
  P := 1;
  Result := NameSpaceResolve(NameSpace, NameSpace, Name, P);
  Key := CopyFrom(Name, P);
  if not Assigned(Result) then
    NameSpaceUnresolvedError(Key);
end;

function NameSpaceGetName(const NameSpace: TObject;
    const Name: String): TObject;
var V : TObject;
    K : String;
begin
  V := NameSpaceResolveNameSpace(NameSpace, Name, K);
  try
    Result := ObjectNameSpaceGetItem(V, K);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function NameSpaceNameExists(const NameSpace: TObject;
    const Name: String): Boolean;
var V : TObject;
    K : String;
begin
  V := NameSpaceResolveNameSpace(NameSpace, Name, K);
  try
    Result := ObjectNameSpaceExists(V, K);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

procedure NameSpaceSetName(const NameSpace: TObject;
    const Name: String; const Value: TObject);
var V : TObject;
    K : String;
begin
  V := NameSpaceResolveNameSpace(NameSpace, Name, K);
  try
    ObjectNameSpaceSetItem(V, K, Value);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

procedure NameSpaceDeleteName(const NameSpace: TObject;
    const Name: String);
var V : TObject;
    K : String;
begin
  V := NameSpaceResolveNameSpace(NameSpace, Name, K);
  try
    ObjectNameSpaceDelete(V, K);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function NameSpaceDirectory(const NameSpace: TObject;
    const Name: String): TObject;
var V : TObject;
    K : String;
begin
  V := NameSpaceResolveNameSpace(NameSpace, Name, K);
  try
    Result := ObjectNameSpaceDirectory(V, K);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;



{                                                                              }
{ Scope helper functions                                                       }
{                                                                              }
procedure ScopeAddFieldDefinitions(const FieldScope: ABlaiseType;
    const FieldDefinitions: AScopeFieldDefinitionArray;
    const DefinitionScope: ABlaiseType; const FieldType: CScopeFieldDefinition);
var I : Integer;
begin
  For I := 0 to Length(FieldDefinitions) - 1 do
    if not Assigned(FieldType) or
        (Assigned(FieldType) and FieldDefinitions[I].InheritsFrom(FieldType)) then
      FieldDefinitions[I].AddToScope(FieldScope, DefinitionScope);
end;

function ScopeGetRootNameSpace(const Scope: ABlaiseType): ANameSpace;
var R : TObject;
    S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  R := Scope.GetIdentifier('__RootNameSpace__', True, S, T);
  if not (R is ANameSpace) then
    raise ENameSpace.Create('Invalid root name space: ' + BlaiseClassName(R));
  Result := ANameSpace(R);
end;

procedure ScopeImport(const Scope: ABlaiseType; const Identifier, UnitName: String);
var S : ABlaiseType;
    U : TUnitInterfaceScope;
    T : TBlaiseFieldType;
    V : TObject;
begin
  S := Scope;
  While Assigned(S) and not (S is AApplicationScope) do
    if S is TCodeFrameScope then
      S := TCodeFrameScope(S).ParentScope;
  if not (S is AApplicationScope) then
    raise EBlaiseScope.Create('Application scope not found');
  U := AApplicationScope(S).GetUnit(UnitName);
  if Identifier = '*' then
    U.ExportToScope(Scope)
  else
    begin
      V := U.GetIdentifier(Identifier, True, S, T);
      Scope.SetField(Identifier, V);
    end;
end;


{                                                                              }
{ Stream functions                                                             }
{                                                                              }
function CreateTypeDefinitionByID(const ID: Byte): ATypeDefinition;
begin
  Case ID of
    BLAISE_TYPE_ID_DEF_None             : Result := nil;
    BLAISE_TYPE_ID_DEF_Identifier       : Result := TIdentifierType.Create('');
    BLAISE_TYPE_ID_FIRST_Abstract..
    BLAISE_TYPE_ID_LAST_Abstract        :
      raise EBlaiseBinaryStream.Create('Abstract type');
    BLAISE_TYPE_ID_DEF_Unknown          :
      raise EBlaiseBinaryStream.Create('Unknown type');
    BLAISE_TYPE_ID_STRING               : Result := TStringType.Create;
    BLAISE_TYPE_ID_STRING_URL           : Result := TURLType.Create;
    BLAISE_TYPE_ID_BINARY_BASE64        : Result := TBase64BinaryType.Create;
    BLAISE_TYPE_ID_CHAR                 : Result := TCharType.Create;
    BLAISE_TYPE_ID_UNICODECHAR          : Result := TUnicodeCharType.Create;
    BLAISE_TYPE_ID_UNICODE              : Result := TUnicodeType.Create;
    BLAISE_TYPE_ID_BOOLEAN              : Result := TBooleanType.Create;
    BLAISE_TYPE_ID_INTEGER_BYTE         : Result := TByteType.Create;
    BLAISE_TYPE_ID_INTEGER_16           : Result := TInt16Type.Create;
    BLAISE_TYPE_ID_INTEGER_32           : Result := TInt32Type.Create;
    BLAISE_TYPE_ID_INTEGER_64           : Result := TInt64Type.Create;
    BLAISE_TYPE_ID_FLOAT_SINGLE         : Result := TSingleFloatType.Create;
    BLAISE_TYPE_ID_FLOAT_DOUBLE         : Result := TDoubleFloatType.Create;
    BLAISE_TYPE_ID_FLOAT_EXTENDED       : Result := TExtendedFloatType.Create;
    BLAISE_TYPE_ID_DATETIME             : Result := TDateTimeType.Create;
    BLAISE_TYPE_ID_DATETIME_ANSI        : Result := TAnsiDateTimeType.Create;
    BLAISE_TYPE_ID_DATETIME_RFC         : Result := TRfcDateTimeType.Create;
    BLAISE_TYPE_ID_DURATION             : Result := TDurationType.Create;
    BLAISE_TYPE_ID_DURATION_TIMER       : Result := TTimerType.Create;
    BLAISE_TYPE_ID_RATIONAL             : Result := TRationalType.Create;
    BLAISE_TYPE_ID_COMPLEX              : Result := TComplexType.Create;
    BLAISE_TYPE_ID_STATISTIC            : Result := TStatisticType.Create;
    BLAISE_TYPE_ID_ARRAY                : Result := TArrayType.Create(nil);
    BLAISE_TYPE_ID_VECTOR               : Result := TVectorType.Create;
    BLAISE_TYPE_ID_MATRIX               : Result := TMatrixType.Create;
    BLAISE_TYPE_ID_DICTIONARY           : Result := TDictionaryType.Create(nil, nil);
    BLAISE_TYPE_ID_RECORD               : Result := TRecordType.Create(nil, nil);
    BLAISE_TYPE_ID_CLASS                : Result := TClassType.Create(nil, nil, nil);
    BLAISE_TYPE_ID_SUBRANGE_INT         : Result := TIntegerSubrangeType.Create(0, -1);
    BLAISE_TYPE_ID_SUBRANGE_ENUMERATION : Result := TEnumeratedSubrangeType.Create(0, -1, nil);
    BLAISE_TYPE_ID_STREAM               : Result := TStreamType.Create(nil);
  else
    raise EBlaiseBinaryStream.Create(
        'Unrecognised type definition id [' + IntToStr(ID) + ']');
  end;
end;


function StreamInTypeDefinition(const Reader: AReaderEx): ATypeDefinition;
var ID : Byte;
begin
  Assert(Assigned(Reader));
  ID := Reader.ReadByte;
  Result := CreateTypeDefinitionByID(ID);
  if Assigned(Result) then
    try
      Result.StreamIn(Reader);
    except
      Result.Free;
      raise;
    end;
end;

procedure StreamOutTypeDefinition(const Writer: AWriterEx;
    const TypeDef: ATypeDefinition);
begin
  Assert(Assigned(Writer));
  if Assigned(TypeDef) then
    begin
      Writer.WriteByte(TypeDef.GetTypeDefID);
      TypeDef.StreamOut(Writer);
    end
  else
    Writer.WriteByte(BLAISE_TYPE_ID_DEF_None);
end;

function GetFieldDefinitionClassByID(const ID: Byte): CScopeFieldDefinition;
begin
  Case ID of
    BLAISE_FIELD_ID_None             : Result := nil;
    BLAISE_FIELD_ID_VAR              : Result := TVariableFieldDefinition;
    BLAISE_FIELD_ID_CONST            : Result := TConstantFieldDefinition;
    BLAISE_FIELD_ID_TYPE             : Result := TTypeFieldDefinition;
    BLAISE_FIELD_ID_RECORD_VAR       : Result := TRecordFieldFieldDefinition;
    BLAISE_FIELD_ID_PROPERTY         : Result := TPropertyFieldDefinition;
    BLAISE_FIELD_ID_PAR_CONST        : Result := TConstantParameterFieldDefinition;
    BLAISE_FIELD_ID_PAR_VAR          : Result := TVariableParameterFieldDefinition;
    BLAISE_FIELD_ID_PAR_LOCAL        : Result := TLocalParameterFieldDefinition;
    BLAISE_FIELD_ID_CODE_PROCEDURE   : Result := TProcedureFieldDefinition;
    BLAISE_FIELD_ID_CODE_FUNCTION    : Result := TFunctionFieldDefinition;
    BLAISE_FIELD_ID_CODE_CONSTRUCTOR : Result := TConstructorFieldDefinition;
    BLAISE_FIELD_ID_CODE_DESTRUCTOR  : Result := TDestructorFieldDefinition;
    BLAISE_FIELD_ID_CODE_TASK        : Result := TTaskFieldDefinition;
    BLAISE_FIELD_ID_CODE_EXTERNAL    : Result := TExternalFunctionFieldDefinition;
  else
    raise EBlaiseBinaryStream.Create('Unrecognised field id [' + IntToStr(ID) + ']');
  end;
end;

function CreateFieldDefinitionByID(const ID: Byte): AScopeFieldDefinition;
var C : CScopeFieldDefinition;
begin
  C := GetFieldDefinitionClassByID(ID);
  if Assigned(C) then
    Result := C.Create
  else
    Result := nil;
end;

function StreamInFieldDefinition(const Reader: AReaderEx): AScopeFieldDefinition;
var ID : Byte;
begin
  Assert(Assigned(Reader));
  ID := Reader.ReadByte;
  Result := CreateFieldDefinitionByID(ID);
  if Assigned(Result) then
    try
      Result.StreamIn(Reader);
    except
      Result.Free;
      raise;
    end;
end;

function StreamInFieldDefinitions(const Reader: AReaderEx): AScopeFieldDefinitionArray;
var I, L : Integer;
begin
  Assert(Assigned(Reader));
  L := Reader.ReadLongInt;
  SetLength(Result, L);
  if L = 0 then
    exit;
  For I := 0 to L - 1 do
    Result[I] := nil;
  try
    For I := 0 to L - 1 do
      Result[I] := StreamInFieldDefinition(Reader);
  except
    For I := L - 1 downto 0 do
      Result[I].Free;
    raise;
  end;
end;

procedure StreamOutFieldDefinition(const Writer: AWriterEx;
    const FieldDef: AScopeFieldDefinition);
var ID : Byte;
begin
  Assert(Assigned(Writer));
  ID := FieldDef.GetFieldID;
  Writer.WriteByte(ID);
  FieldDef.StreamOut(Writer);
end;

procedure StreamOutFieldDefinitions(const Writer: AWriterEx;
    const FieldDef: AScopeFieldDefinitionArray);
var I, L : Integer;
begin
  Assert(Assigned(Writer));
  L := Length(FieldDef);
  Writer.WriteLongInt(L);
  For I := 0 to L - 1 do
    StreamOutFieldDefinition(Writer, FieldDef[I]);
end;

function CreateObjectByTypeID(const ID: Byte): TObject;
begin
  Case ID of
    BLAISE_TYPE_ID_VALUE_Nil             : Result := nil;
    BLAISE_TYPE_ID_VALUE_Unassigned      : Result := UnassignedValue;
    BLAISE_TYPE_ID_VALUE_Unknown         :
      raise EBlaiseBinaryStream.Create('Unknown type');
    BLAISE_TYPE_ID_FIRST_Abstract..
    BLAISE_TYPE_ID_LAST_Abstract         :
      raise EBlaiseBinaryStream.Create('Abstract type');
    BLAISE_TYPE_ID_INTEGER_BYTE          : Result := TTByte.Create(0);
    BLAISE_TYPE_ID_INTEGER_16            : Result := TTInt16.Create(0);
    BLAISE_TYPE_ID_INTEGER_32            : Result := TTInt32.Create(0);
    BLAISE_TYPE_ID_INTEGER_64            : Result := TTInt64.Create(0);
    BLAISE_TYPE_ID_FLOAT_SINGLE          : Result := TTSingle.Create(0.0);
    BLAISE_TYPE_ID_FLOAT_DOUBLE          : Result := TTDouble.Create(0.0);
    BLAISE_TYPE_ID_FLOAT_EXTENDED        : Result := TTExtended.Create(0.0);
    BLAISE_TYPE_ID_RATIONAL              : Result := TTRational.Create;
    BLAISE_TYPE_ID_SUBRANGE_INT,
    BLAISE_TYPE_ID_SUBRANGE_ENUMERATION  : Result := TSubrangeValue.Create(nil, 0);
    BLAISE_TYPE_ID_CURRENCY              : Result := TTCurrency.Create(0);
    BLAISE_TYPE_ID_STRING                : Result := TTString.Create('');
    BLAISE_TYPE_ID_STRING_URL            : Result := TTURL.Create('');
    BLAISE_TYPE_ID_BINARY_BASE64         : Result := TTBase64Binary.Create;
    BLAISE_TYPE_ID_CHAR                  : Result := TTChar.Create;
    BLAISE_TYPE_ID_UNICODE               : Result := TTUnicodeString.Create('');
    BLAISE_TYPE_ID_UNICODECHAR           : Result := TTUnicodeChar.Create;
    BLAISE_TYPE_ID_BOOLEAN               : Result := TTBoolean.Create(False);
    BLAISE_TYPE_ID_DATETIME              : Result := TTDateTime.Create;
    BLAISE_TYPE_ID_DATETIME_ANSI         : Result := TTAnsiDateTime.Create;
    BLAISE_TYPE_ID_DATETIME_RFC          : Result := TTRfcDateTime.Create;
    BLAISE_TYPE_ID_DURATION              : Result := TTDuration.Create;
    BLAISE_TYPE_ID_DURATION_TIMER        : Result := TTTimer.Create;
    BLAISE_TYPE_ID_RECORD                : Result := TTRecord.Create(nil);
    BLAISE_TYPE_ID_ARRAY                 : Result := TTArray.Create(nil);
    BLAISE_TYPE_ID_VECTOR                : Result := TTVector.Create;
    BLAISE_TYPE_ID_MATRIX                : Result := TTMatrix.Create;
    BLAISE_TYPE_ID_DICTIONARY            : Result := TTDictionary.Create(nil, nil);
  else
    raise EBlaiseBinaryStream.Create(
        'Unrecognised object type id [' + IntToStr(ID) + ']');
  end;
end;

function StreamInObject(const Reader: AReaderEx): TObject;
var ID : Byte;
begin
  Assert(Assigned(Reader));
  ID := Reader.ReadByte;
  Result := CreateObjectByTypeID(ID);
  if Assigned(Result) then
    try
      ABlaiseType(Result).StreamIn(Reader);
    except
      Result.Free;
      raise;
    end;
end;

procedure StreamOutObject(const Writer: AWriterEx; const Value: TObject);
begin
  Assert(Assigned(Writer));
  if not Assigned(Value) then
    Writer.WriteByte(BLAISE_TYPE_ID_VALUE_Nil) else
  if Value = UnassignedValue then
    Writer.WriteByte(BLAISE_TYPE_ID_VALUE_Unassigned) else
  if Value is ABlaiseType then
    begin
      Writer.WriteByte(ABlaiseType(Value).GetTypeID);
      ABlaiseType(Value).StreamOut(Writer);
    end
  else
    ObjectOperationNotSupportedError(Value, 'StreamOut');
end;



{                                                                              }
{ Machine functions                                                            }
{                                                                              }
var
  GlobalMachine : AVirtualMachine = nil;

function GetMachine: AVirtualMachine;
begin
  Result := GlobalMachine;
end;

function RequireMachine: AVirtualMachine;
begin
  Result := GlobalMachine;
  if not Assigned(Result) then
    raise EVirtualMachine.Create('Virtual machine required');
end;

procedure SetMachine(const Machine: AVirtualMachine);
begin
  GlobalMachine := Machine;
end;

procedure ThreadWouldBlock;
var M : AVirtualMachine;
begin
  M := GetMachine;
  if Assigned(M) then
    M.ThreadWouldBlock
  else
    SleepEx(1, True);
end;



end.

