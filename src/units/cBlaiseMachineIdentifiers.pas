{                                                                              }
{                     Blaise machine identifier classes v0.01                  }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{          Its original file name is cBlaiseMachineIdentifiers.pas             }
{                                                                              }
{ Description:                                                                 }
{                                                                              }
{ Revision history:                                                            }
{   08/03/2003  0.01  Created unit cBlaiseMachineIdentifiers from other        }
{                     cBlaiseMachine units.                                    }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineIdentifiers;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseVMCompiler,
  cBlaiseMachineTypes;



{                                                                              }
{ TSimpleIdentifier                                                            }
{                                                                              }
type
  TSimpleIdentifier = class(AIdentifier)
  protected
    FIdentifier : String;

  public
    constructor Create(const Identifier: String);

    function  IdentifierDescription: String; override;
    function  GetAsBlaise: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
    procedure CompileCallEval(const VM: TBlaiseVMCompiler); override;
    procedure CompileCallExec(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TSelectedIdentifier                                                          }
{                                                                              }
type
  TSelectedIdentifier = class(AIdentifier)
  protected
    FParentIdentifier   : AIdentifier;
    FSelectedIdentifier : String;

    function  GetParentIdentifierAsScope(const Scope: ABlaiseType; var Parent: TObject): ABlaiseType;

  public
    constructor Create(const ParentIdentifier: AIdentifier; const SelectedIdentifier: String);
    destructor Destroy; override;

    function  IdentifierDescription: String; override;
    function  GetAsBlaise: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
    procedure CompileCallEval(const VM: TBlaiseVMCompiler); override;
    procedure CompileCallExec(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TSelfIdentifier                                                              }
{                                                                              }
type
  TSelfIdentifier = class(AIdentifier)
  public
    function  IdentifierDescription: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TInheritedIdentifier                                                         }
{                                                                              }
type
  TInheritedIdentifier = class(AIdentifier)
  protected
    FIdentifier : AIdentifier;

    function  GetInheritedScope(const Scope: ABlaiseType): ABlaiseType;

  public
    constructor Create(const Identifier: AIdentifier);
    destructor Destroy; override;

    function  IdentifierDescription: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
    procedure CompileCallEval(const VM: TBlaiseVMCompiler); override;
    procedure CompileCallExec(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIdentifierCall                                                              }
{   An identifier call with parameters.                                        }
{                                                                              }
type
  TIdentifierCall = class(AIdentifier)
  protected
    FIdentifier : AIdentifier;
    FParameters : AExpressionArray;

    procedure EvaluateParameters(const Scope: ABlaiseType;
              const Definition: TParameterAttributesArray;
              var Params: ObjectArray; var FreeParams: BooleanArray);
    procedure FreeParameters(var Params: ObjectArray;
              var FreeParams: BooleanArray);

  public
    constructor Create(const Identifier: AIdentifier; const Parameters: AExpressionArray);
    destructor Destroy; override;

    function  IdentifierDescription: String; override;
    function  GetAsBlaise: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIndexedIdentifier                                                           }
{                                                                              }
type
  TIndexedIdentifier = class(AIdentifier)
  protected
    FIdentifier    : AIdentifier;
    FIndex         : AExpression;
    FReversedIndex : Boolean;

  public
    constructor Create(const Identifier: AIdentifier; const Index: AExpression;
                const ReversedIndex: Boolean);
    destructor Destroy; override;

    function  IdentifierDescription: String; override;
    function  GetAsBlaise: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TSlicedIdentifier                                                            }
{                                                                              }
type
  TSliceIndex = class
  protected
    FIndex         : AExpression;
    FReversedIndex : Boolean;

  public
    constructor Create(const Index: AExpression; const ReversedIndex: Boolean);
  end;

  TIndexSlice = class
  protected
    FIndex : TSliceIndex;

  public
    constructor Create(const Index: TSliceIndex);
  end;

  TRangeSlice = class
  protected
    FLower : TSliceIndex;
    FUpper : TSliceIndex;
    FStep  : AExpression;

  public
    constructor Create(const Lower, Upper: TSliceIndex;
                const Step: AExpression);
  end;

  TMultiSlice = class
  end;

  TSlicedIdentifier = class(AIdentifier)
  protected
    FIdentifier : AIdentifier;
    FSlices     : ObjectArray;

  public
    constructor Create(const Identifier: AIdentifier;
                const Slices: ObjectArray);

    function  IdentifierDescription: String; override;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject);  override;
    procedure Execute(const Scope: ABlaiseType); override;
    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; override;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); override;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); override;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); override;
  end;



implementation

uses
  { Blaise }
  cBlaiseFuncs,
  cBlaiseStructs,
  cBlaiseStructsObject,
  cBlaiseStructsCode,
  cBlaiseMachineExpressions;



{                                                                              }
{ TSimpleIdentifier                                                            }
{                                                                              }
constructor TSimpleIdentifier.Create(const Identifier: String);
begin
  inherited Create;
  FIdentifier := Identifier;
end;

function TSimpleIdentifier.IdentifierDescription: String;
begin
  Result := FIdentifier;
end;

function TSimpleIdentifier.GetAsBlaise: String;
begin
  Result := FIdentifier;
end;

function TSimpleIdentifier.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := Scope.GetValue(FIdentifier, True, IdentifierScope, FieldType);
end;

function TSimpleIdentifier.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  Result := Scope.CallField(FIdentifier, Parameters);
end;

procedure TSimpleIdentifier.AssignValue(const Scope: ABlaiseType; const Value: TObject);
begin
  Scope.AssignIdentifier(FIdentifier, Value);
end;

procedure TSimpleIdentifier.Execute(const Scope: ABlaiseType);
begin
  Scope.Execute(FIdentifier, [], True);
end;

function TSimpleIdentifier.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := Scope.Evaluate(FIdentifier);
end;

function TSimpleIdentifier.CreateIdentifierReference(const Scope: ABlaiseType): AValueReference;
var V : TObject;
    S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  V := Scope.GetIdentifier(FIdentifier, True, S, T);
  if V is AValueReference then
    Result := TValueReferenceByReference.Create(AValueReference(V)) else
    Result := TValueReferenceByIdentifier.Create(S, FIdentifier);
end;

procedure TSimpleIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
  VM.PushInteger(0);
  VM.EvaluateIdentifier(FIdentifier);
end;

procedure TSimpleIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
  VM.PushInteger(0);
  VM.ExecuteIdentifier(FIdentifier);
end;

procedure TSimpleIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  VM.AssignIdentifier(FIdentifier);
end;

procedure TSimpleIdentifier.CompileCallEval(const VM: TBlaiseVMCompiler);
begin
  VM.EvaluateIdentifierCall(FIdentifier);
end;

procedure TSimpleIdentifier.CompileCallExec(const VM: TBlaiseVMCompiler);
begin
  VM.ExecuteIdentifierCall(FIdentifier);
end;



{                                                                              }
{ TSelectedIdentifier                                                          }
{                                                                              }
constructor TSelectedIdentifier.Create(const ParentIdentifier: AIdentifier; const SelectedIdentifier: String);
begin
  inherited Create;
  FParentIdentifier := ParentIdentifier;
  FSelectedIdentifier := SelectedIdentifier;
end;

destructor TSelectedIdentifier.Destroy;
begin
  FreeAndNil(FParentIdentifier);
  inherited Destroy;
end;

function TSelectedIdentifier.IdentifierDescription: String;
begin
  Result := FParentIdentifier.IdentifierDescription + '.' + FSelectedIdentifier;
end;

function TSelectedIdentifier.GetAsBlaise: String;
begin
  Result := FParentIdentifier.GetAsBlaise + '.' + FSelectedIdentifier;
end;

{$WARNINGS OFF}
function TSelectedIdentifier.GetParentIdentifierAsScope(const Scope: ABlaiseType; var Parent: TObject): ABlaiseType;
begin
  Parent := FParentIdentifier.Evaluate(Scope);
  try
    Assert(Assigned(Parent));
    if Parent = UnassignedValue then
      FParentIdentifier.IdentifierError('No scope: Unassigned value') else
    if Parent is ABlaiseType then
      Result := ABlaiseType(Parent)
    else
      FParentIdentifier.IdentifierError('No scope: Not a scope object');
  except
    ObjectReleaseUnreferenced(Parent);
    raise;
  end;
end;
{$WARNINGS ON}

function TSelectedIdentifier.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var P : TObject;
    S : ABlaiseType;
begin
  IdentifierScope := GetParentIdentifierAsScope(Scope, P);
  try
    Result := IdentifierScope.GetValue(FSelectedIdentifier, True, S, FieldType);
  finally
    ObjectReleaseUnreferenced(IdentifierScope);
  end;
end;

function TSelectedIdentifier.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  Result := Scope.CallField(FSelectedIdentifier, Parameters);
end;

procedure TSelectedIdentifier.AssignValue(const Scope: ABlaiseType; const Value: TObject);
var Parent : TObject;
    ParentScope : ABlaiseType;
begin
  ParentScope := GetParentIdentifierAsScope(Scope, Parent);
  try
    ParentScope.AssignIdentifier(FSelectedIdentifier, Value);
  finally
    ObjectReleaseUnreferenced(Parent);
  end;
end;

procedure TSelectedIdentifier.Execute(const Scope: ABlaiseType);
var Parent : TObject;
    ParentScope : ABlaiseType;
begin
  ParentScope := GetParentIdentifierAsScope(Scope, Parent);
  try
    ParentScope.Execute(FSelectedIdentifier, [], True);
  finally
    ObjectReleaseUnreferenced(Parent);
  end;
end;

function TSelectedIdentifier.Evaluate(const Scope: ABlaiseType): TObject;
var Parent : TObject;
    ParentScope : ABlaiseType;
begin
  ParentScope := GetParentIdentifierAsScope(Scope, Parent);
  try
    Result := ParentScope.Evaluate(FSelectedIdentifier);
  finally
    ObjectReleaseUnreferenced(Parent);
  end;
end;

function TSelectedIdentifier.CreateIdentifierReference(const Scope: ABlaiseType): AValueReference;
var Parent, V : TObject;
    ParentScope, S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  ParentScope := GetParentIdentifierAsScope(Scope, Parent);
  try
    V := ParentScope.GetIdentifier(FSelectedIdentifier, True, S, T);
    if V is AValueReference then
      Result := TValueReferenceByReference.Create(AValueReference(V)) else
      Result := TValueReferenceByIdentifier.Create(S, FSelectedIdentifier);
  finally
    ObjectReleaseUnreferenced(Parent);
  end;
end;

procedure TSelectedIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
  VM.PushInteger(0);
  FParentIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  VM.SetIdentifierScope;
  VM.EvaluateIdentifier(FSelectedIdentifier);
end;

procedure TSelectedIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
  VM.PushInteger(0);
  FParentIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  VM.SetIdentifierScope;
  VM.ExecuteIdentifier(FSelectedIdentifier);
end;

procedure TSelectedIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  FParentIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  VM.SetIdentifierScope;
  VM.AssignIdentifier(FSelectedIdentifier);
end;

procedure TSelectedIdentifier.CompileCallEval(const VM: TBlaiseVMCompiler);
begin
  FParentIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  VM.SetIdentifierScope;
  VM.EvaluateIdentifierCall(FSelectedIdentifier);
end;

procedure TSelectedIdentifier.CompileCallExec(const VM: TBlaiseVMCompiler);
begin
  FParentIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  VM.SetIdentifierScope;
  VM.ExecuteIdentifierCall(FSelectedIdentifier);
end;



{                                                                              }
{ TSelfIdentifier                                                              }
{                                                                              }
function TSelfIdentifier.IdentifierDescription: String;
begin
  Result := 'self';
end;

procedure TSelfIdentifier.AssignValue(const Scope: ABlaiseType; const Value: TObject);
begin
  IdentifierError('Assign operation not defined for self');
end;

procedure TSelfIdentifier.Execute(const Scope: ABlaiseType);
begin
  IdentifierError('Execute operation not defined for self');
end;

function TSelfIdentifier.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  if not (Scope is TCodeFrameScope) then
    IdentifierError('Self not defined here');
  Result := TCodeFrameScope(Scope).ParentScope;
  FieldType := bfObject;
  IdentifierScope := nil;
end;

{$WARNINGS OFF}
function TSelfIdentifier.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  IdentifierError('CallField operation not defined for self');
end;
{$WARNINGS ON}

function TSelfIdentifier.Evaluate(const Scope: ABlaiseType): TObject;
var P : ABlaiseType;
    T : TBlaiseFieldType;
begin
  Result := GetValue(Scope, P, T);
end;

{$WARNINGS OFF}
function TSelfIdentifier.CreateIdentifierReference(const Scope: ABlaiseType): AValueReference;
begin
  IdentifierError('Reference operation not defined for self');
end;
{$WARNINGS ON}

procedure TSelfIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  IdentifierError('Assign operation not defined for self');
end;

procedure TSelfIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
  IdentifierError('Execute operation not defined for self');
end;

procedure TSelfIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
  VM.EvaluateSelf;
end;



{                                                                              }
{ TInheritedIdentifier                                                         }
{                                                                              }
constructor TInheritedIdentifier.Create(const Identifier: AIdentifier);
begin
  inherited Create;
  Assert(Assigned(Identifier));
  FIdentifier := Identifier;
end;

destructor TInheritedIdentifier.Destroy;
begin
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

function TInheritedIdentifier.IdentifierDescription: String;
begin
  Result := 'inherited';
end;

function TInheritedIdentifier.GetInheritedScope(const Scope: ABlaiseType): ABlaiseType;
var S: ABlaiseType;
begin
  S := Scope;
  if S is TCodeFrameScope then
    S := TCodeFrameScope(S).ParentScope;
  if not (S is TTObject) then
    IdentifierError('Inherited scope not defined here');
  Result := TTObject(S).InheritedScope;
end;

procedure TInheritedIdentifier.AssignValue(const Scope: ABlaiseType; const Value: TObject);
begin
  FIdentifier.AssignValue(GetInheritedScope(Scope), Value);
end;

procedure TInheritedIdentifier.Execute(const Scope: ABlaiseType);
begin
  FIdentifier.Execute(GetInheritedScope(Scope));
end;

function TInheritedIdentifier.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := FIdentifier.GetValue(GetInheritedScope(Scope), IdentifierScope,
      FieldType);
end;

function TInheritedIdentifier.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  Result := FIdentifier.CallField(GetInheritedScope(Scope), Parameters);
end;

function TInheritedIdentifier.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := FIdentifier.Evaluate(GetInheritedScope(Scope));
end;

function TInheritedIdentifier.CreateIdentifierReference(const Scope: ABlaiseType): AValueReference;
begin
  Result := FIdentifier.CreateIdentifierReference(GetInheritedScope(Scope));
end;

procedure TInheritedIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  VM.SetInheritedScope;
  FIdentifier.CompileAssign(VM);
end;

procedure TInheritedIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
  VM.SetInheritedScope;
  FIdentifier.CompileExecute(VM);
end;

procedure TInheritedIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
  VM.SetInheritedScope;
  FIdentifier.CompileEvaluate(VM);
end;

procedure TInheritedIdentifier.CompileCallEval(const VM: TBlaiseVMCompiler);
begin
  VM.SetInheritedScope;
  FIdentifier.CompileCallEval(VM);
end;

procedure TInheritedIdentifier.CompileCallExec(const VM: TBlaiseVMCompiler);
begin
  VM.SetInheritedScope;
  FIdentifier.CompileCallExec(VM);
end;



{                                                                              }
{ TIdentifierCall                                                              }
{                                                                              }
constructor TIdentifierCall.Create(const Identifier: AIdentifier;
    const Parameters: AExpressionArray);
begin
  inherited Create;
  Assert(Assigned(Identifier), 'Assigned(Identifier)');
  FIdentifier := Identifier;
  FParameters := Parameters;
end;

destructor TIdentifierCall.Destroy;
begin
  FreeAndNil(FIdentifier);
  FreeObjectArray(FParameters);
  inherited Destroy;
end;

function TIdentifierCall.IdentifierDescription: String;
begin
  Result := FIdentifier.IdentifierDescription + '()';
end;

function TIdentifierCall.GetAsBlaise: String;
var I : Integer;
begin
  Result := FIdentifier.GetAsBlaise + '(';
  For I := 0 to Length(FParameters) - 1 do
    Result := Result + iif(I > 0, ',', '') + FParameters[I].GetAsBlaise;
  Result := Result + ')';
end;

procedure TIdentifierCall.AssignValue(const Scope: ABlaiseType; const Value: TObject);
begin
  IdentifierError('Assign operation not allowed on an identifier call');
end;

procedure TIdentifierCall.EvaluateParameters(const Scope: ABlaiseType;
    const Definition: TParameterAttributesArray;
    var Params: ObjectArray; var FreeParams: BooleanArray);
var I, L, M : Integer;
begin
  L := Length(FParameters);
  M := Length(Definition);
  SetLengthAndZero(Params, L);
  SetLengthAndZero(FreeParams, L);
  try
    For I := 0 to L - 1 do
      if (I < M) and (paReference in Definition[I]) then
        begin
          if not (FParameters[I] is TIdentifierExpression) then
            IdentifierError('Identifier parameter required');
          Params[I] := TIdentifierExpression(FParameters[I]).Identifier.CreateIdentifierReference(Scope);
          FreeParams[I] := True;
        end
      else
        Params[I] := FParameters[I].Evaluate(Scope);
  except
    FreeParameters(Params, FreeParams);
    raise;
  end;
end;

procedure TIdentifierCall.FreeParameters(var Params: ObjectArray;
    var FreeParams: BooleanArray);
var I : Integer;
begin
  For I := Length(Params) - 1 downto 0 do
    if FreeParams[I] then
      FreeAndNil(Params[I]);
  Params := nil;
  FreeParams := nil;
end;

function TIdentifierCall.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var Value, C : TObject;
    Params : ObjectArray;
    FreeParams : BooleanArray;
    Def : TParameterAttributesArray;
    L : Integer;
    T : TBlaiseFieldType;
begin
  Result := nil;
  FieldType := bfObject;
  Def := nil;
  Value := FIdentifier.GetValue(Scope, IdentifierScope, T);
  try
    if T = bfCall then
      begin
        EvaluateParameters(Scope, Def, Params, FreeParams);
        try
          Result := FIdentifier.CallField(IdentifierScope, Params);
        finally
          FreeParameters(Params, FreeParams);
        end;
      end else
    if ObjectIsFunction(Value) then
      begin
        Def := ObjectFunctionGetParameters(Value);
        EvaluateParameters(Scope, Def, Params, FreeParams);
        try
          Result := ObjectFunctionCall(Value, IdentifierScope, Params);
        finally
          FreeParameters(Params, FreeParams);
        end;
      end else
    if Value is ATypeDefinition then
      begin
        L := Length(FParameters);
        if L > 1 then
          IdentifierError('Too many parameters in coerce expression');
        if L = 0 then
          // Create instance when coercing 'nothing'
          Result := ATypeDefinition(Value).CreateTypeInstance
        else
          begin
            // Coerce parameter
            C := FParameters[0].Evaluate(Scope);
            try
              Result := ATypeDefinition(Value).Coerce(C);
            finally
              ObjectReleaseUnreferenced(C);
            end;
          end;
      end
    else
      IdentifierError('Not a function');
  finally
    ObjectReleaseUnreferenced(Value);
  end;
end;

{$WARNINGS OFF}
function TIdentifierCall.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  IdentifierError('CallField operation not defined for identifier call');
end;
{$WARNINGS ON}

function TIdentifierCall.Evaluate(const Scope: ABlaiseType): TObject;
var P : ABlaiseType;
    T : TBlaiseFieldType;
begin
  Result := GetValue(Scope, P, T);
end;

procedure TIdentifierCall.Execute(const Scope: ABlaiseType);
begin
  ObjectReleaseUnreferenced(Evaluate(Scope));
end;

{$WARNINGS OFF}
function TIdentifierCall.CreateIdentifierReference(const Scope: ABlaiseType): AValueReference;
begin
  IdentifierError('Not a variable');
end;
{$WARNINGS ON}

procedure TIdentifierCall.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  IdentifierError('Assign operation not allowed on an identifier call');
end;

procedure TIdentifierCall.CompileEvaluate(const VM: TBlaiseVMCompiler);
var I, L : Integer;
begin
  L := Length(FParameters);
  For I := 0 to L - 1 do
    FParameters[I].Compile(VM);
  VM.PushInteger(L);
  FIdentifier.CompileCallEval(VM);
end;

procedure TIdentifierCall.CompileExecute(const VM: TBlaiseVMCompiler);
var I, L : Integer;
begin
  L := Length(FParameters);
  For I := 0 to L - 1 do
    FParameters[I].Compile(VM);
  VM.PushInteger(L);
  FIdentifier.CompileCallExec(VM);
end;



{                                                                              }
{ TIndexedIdentifier                                                           }
{                                                                              }
constructor TIndexedIdentifier.Create(const Identifier: AIdentifier;
    const Index: AExpression; const ReversedIndex: Boolean);
begin
  inherited Create;
  FIdentifier := Identifier;
  FIndex := Index;
  FReversedIndex := ReversedIndex;
end;

destructor TIndexedIdentifier.Destroy;
begin
  FreeAndNil(FIndex);
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

function TIndexedIdentifier.IdentifierDescription: String;
begin
  Result := FIdentifier.IdentifierDescription + '[]';
end;

function TIndexedIdentifier.GetAsBlaise: String;
begin
  Result := FIdentifier.GetAsBlaise + '[' + FIndex.GetAsBlaise + ']';
end;

procedure TIndexedIdentifier.AssignValue(const Scope: ABlaiseType; const Value: TObject);
var V, R, T : TObject;
begin
  V := FIdentifier.Evaluate(Scope);
  if V is AValueReference then
    T := AValueReference(V).GetValue else
    T := V;
  try
    R := FIndex.Evaluate(Scope);
    try
      ObjectAssignIndexedValue(T, R, Value, FReversedIndex);
    finally
      ObjectReleaseUnreferenced(R);
    end;
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function TIndexedIdentifier.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
var V, R : TObject;
begin
  V := FIdentifier.Evaluate(Scope);
  try
    R := FIndex.Evaluate(Scope);
    try
      Result := ObjectGetIndexedValue(V, R, FReversedIndex);
    finally
      ObjectReleaseUnreferenced(R);
    end;
  finally
    ObjectReleaseUnreferenced(V);
  end;
  IdentifierScope := nil;
end;

{$WARNINGS OFF}
function TIndexedIdentifier.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  IdentifierError('CallField operation not defined for indexed identifier');
end;
{$WARNINGS ON}

function TIndexedIdentifier.Evaluate(const Scope: ABlaiseType): TObject;
var P : ABlaiseType;
    T : TBlaiseFieldType;
begin
  Result := GetValue(Scope, P, T);
end;

procedure TIndexedIdentifier.Execute(const Scope: ABlaiseType);
begin
  IdentifierError('Execute operation not defined for an indexed identifier');
end;

function TIndexedIdentifier.CreateIdentifierReference(const Scope: ABlaiseType): AValueReference;
var R : TObject;
begin
  R := FIndex.Evaluate(Scope);
  try
    Result := TValueReferenceByIndex.Create(
        FIdentifier.CreateIdentifierReference(Scope), R, FReversedIndex);
  except
    FreeAndNil(R);
    raise;
  end;
end;

procedure TIndexedIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
  FIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  FIndex.Compile(VM);
  if FReversedIndex then
    VM.LoadBooleanTrue else
    VM.LoadBooleanFalse;
  VM.EvaluateIndexedIdentifier;
end;

procedure TIndexedIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
  FIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  FIndex.Compile(VM);
  if FReversedIndex then
    VM.LoadBooleanTrue else
    VM.LoadBooleanFalse;
  VM.ExecuteIndexedIdentifier;
end;

procedure TIndexedIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  FIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
  FIndex.Compile(VM);
  if FReversedIndex then
    VM.LoadBooleanTrue else
    VM.LoadBooleanFalse;
  VM.AssignIndexedIdentifier;
end;



{                                                                              }
{ TSliceIndex                                                                  }
{                                                                              }
constructor TSliceIndex.Create(const Index: AExpression;
    const ReversedIndex: Boolean);
begin
  inherited Create;
  FIndex := Index;
  FReversedIndex := ReversedIndex;
end;



{                                                                              }
{ TIndexSlice                                                                  }
{                                                                              }
constructor TIndexSlice.Create(const Index: TSliceIndex);
begin
  inherited Create;
  FIndex := Index;
end;



{                                                                              }
{ TRangeSlice                                                                  }
{                                                                              }
constructor TRangeSlice.Create(const Lower, Upper: TSliceIndex;
    const Step: AExpression);
begin
  inherited Create;
  FLower := Lower;
  FUpper := Upper;
  FStep := Step;
end;



{                                                                              }
{ TSlicedIdentifier                                                            }
{                                                                              }
constructor TSlicedIdentifier.Create(const Identifier: AIdentifier;
    const Slices: ObjectArray);
begin
  inherited Create;
  FIdentifier := Identifier;
  FSlices := Slices;
end;

function TSlicedIdentifier.IdentifierDescription: String;
begin
  Result := FIdentifier.IdentifierDescription + '[:]';
end;

procedure TSlicedIdentifier.AssignValue(const Scope: ABlaiseType;
    const Value: TObject);
begin
  IdentifierError('Assign operation not defined for sliced identifier');
end;

function TSlicedIdentifier.GetValue(const Scope: ABlaiseType;
    var IdentifierScope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  IdentifierScope := nil;
  Result := nil;
end;

{$WARNINGS OFF}
function TSlicedIdentifier.CallField(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  IdentifierError('CallField operation not defined for sliced identifier');
end;
{$WARNINGS ON}

function TSlicedIdentifier.Evaluate(const Scope: ABlaiseType): TObject;
var P : ABlaiseType;
    T : TBlaiseFieldType;
begin
  Result := GetValue(Scope, P, T);
end;

procedure TSlicedIdentifier.Execute(const Scope: ABlaiseType);
begin
  IdentifierError('Not executable');
end;

{$WARNINGS OFF}
function TSlicedIdentifier.CreateIdentifierReference(
    const Scope: ABlaiseType): AValueReference;
begin
  IdentifierError('Not a variable');
end;
{$WARNINGS ON}

procedure TSlicedIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
end;

procedure TSlicedIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
end;

procedure TSlicedIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
end;



end.

