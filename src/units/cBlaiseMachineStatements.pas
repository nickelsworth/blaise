{                                                                              }
{                         Blaise statement classes v0.02                       }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{          Its original file name is cBlaiseMachineStatements.pas              }
{                                                                              }
{ Description:                                                                 }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseMachineStatements from cBlaiseMachine.    }
{   29/03/2003  0.02  Implemented Compile.                                     }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineStatements;

interface

uses
  { Delphi }
  SysUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseVMCompiler,
  cBlaiseMachineTypes;



{                                                                              }
{ TStatementBlock                                                              }
{                                                                              }
type
  TStatementBlock = class(AStatement)
  protected
    FStatements : AStatementArray;

  public
    constructor Create(const Statements: AStatementArray);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIfStatement                                                                 }
{                                                                              }
type
  TIfStatement = class(AStatement)
  protected
    FCondition      : AExpression;
    FTrueStatement  : AStatement;
    FFalseStatement : AStatement;

  public
    constructor Create(const Condition: AExpression;
                const TrueStatement, FalseStatement: AStatement);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TAssignmentStatement                                                         }
{                                                                              }
type
  TAssignmentStatement = class(AStatement)
  protected
    FIdentifier : AIdentifier;
    FExpression : AExpression;

  public
    constructor Create(const Identifier: AIdentifier;
                const Expression: AExpression);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TProcedureCallStatement                                                      }
{                                                                              }
type
  TProcedureCallStatement = class(AStatement)
  protected
    FIdentifier : AIdentifier;

  public
    constructor Create(const Identifier: AIdentifier);
    destructor Destroy; override;

    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TForStatement                                                                }
{                                                                              }
type
  TForStatement = class(AStatement)
  protected
    FIdentifier : String;
    FStart      : AExpression;
    FStop       : AExpression;
    FIncrease   : Boolean;
    FStatement  : AStatement;

  public
    constructor Create(const Identifier: String; const Start, Stop: AExpression;
                const Increase: Boolean; const Statement: AStatement);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TForEachStatement                                                            }
{                                                                              }
type
  TForEachStatement = class(AStatement)
  protected
    FIdentifier    : String;
    FCollection    : AExpression;
    FCondition     : AExpression;
    FStatement     : AStatement;
    FElseStatement : AStatement;

  public
    constructor Create(const Identifier: String; const Collection: AExpression;
        const Condition: AExpression;
        const Statement, ElseStatement: AStatement);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TRepeatStatement                                                             }
{                                                                              }
type
  TRepeatStatement = class(AStatement)
  protected
    FStatement : AStatement;
    FCondition : AExpression;

  public
    constructor Create(const Statement: AStatement;
                const Condition: AExpression);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TWhileStatement                                                              }
{                                                                              }
type
  TWhileStatement = class(AStatement)
  protected
    FCondition : AExpression;
    FStatement : AStatement;

  public
    constructor Create(const Condition: AExpression;
                const Statement: AStatement);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TTextOutputStatement                                                         }
{                                                                              }
type
  TTextOutputStatement = class(AStatement)
  protected
    FIdentifier  : AIdentifier;
    FExpressions : AExpressionArray;
    FNewLine     : Boolean;

  public
    constructor Create(const Identifier: AIdentifier;
                const Expressions: AExpressionArray; const NewLine: Boolean);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ EFlowControlChange                                                           }
{                                                                              }
type
  EFlowControlChange = class(Exception);



{                                                                              }
{ TExitStatement                                                               }
{                                                                              }
type
  TExitStatement = class(AStatement)
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;
  EExitFlowControl = class(EFlowControlChange);



{                                                                              }
{ TBreakStatement                                                              }
{                                                                              }
type
  TBreakStatement = class(AStatement)
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;
  EBreakFlowControl = class(EFlowControlChange);



{                                                                              }
{ TContinueStatement                                                           }
{                                                                              }
type
  TContinueStatement = class(AStatement)
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;
  EContinueFlowControl = class(EFlowControlChange);



{                                                                              }
{ TReturnStatement                                                             }
{                                                                              }
type
  TReturnStatement = class(AStatement)
  protected
    FExpression : AExpression;

  public
    constructor Create(const Expression: AExpression);
    destructor Destroy; override;

    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TImportStatement                                                             }
{                                                                              }
type
  TImportStatement = class(AStatement)
  protected
    FIdentifier : String;
    FUnitName   : String;

  public
    constructor Create(const Identifier, UnitName: String);

    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TRaiseStatement                                                              }
{                                                                              }
type
  TRaiseStatement = class(AStatement)
  protected
    FException : AExpression;

  public
    constructor Create(const Exception: AExpression);
    destructor Destroy; override;

    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;
  ERaiseFlowControl = class(EFlowControlChange)
    ExceptionValue : TObject;

    constructor Create(const ExceptionValue: TObject);
    destructor Destroy; override;
  end;



{                                                                              }
{ TTryFinallyStatement                                                         }
{                                                                              }
type
  TTryFinallyStatement = class(AStatement)
  protected
    FTryStatement     : AStatement;
    FFinallyStatement : AStatement;

  public
    constructor Create(const TryStatement, FinallyStatement: AStatement);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TTryExceptStatement                                                          }
{                                                                              }
type
  TExceptionHandlerDefinition = record
    TypeIdentifier : String;
    Identifier     : String;
    Statement      : AStatement;
  end;
  TExceptionHandlerDefinitionArray = Array of TExceptionHandlerDefinition;
  TTryExceptStatement = class(AStatement)
  protected
    FTryStatement   : AStatement;
    FDefaultHandler : AStatement;
    FHandleDefault  : Boolean;
    FTypeHandlers   : TExceptionHandlerDefinitionArray;

  public
    constructor Create(const TryStatement, DefaultHandler: AStatement;
        const HandleDefault: Boolean;
        const TypeHandlers: TExceptionHandlerDefinitionArray);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TCaseStatement                                                               }
{                                                                              }
type
  TCaseCaseDefinition = class
    Expression     : AExpression;
    HighExpression : AExpression;
    Statement      : AStatement;

    destructor Destroy; override;
    procedure Optimize(const Scope: ABlaiseType);
    function  MatchValue(const Scope: ABlaiseType; const Value: TObject): Boolean;
  end;
  TCaseCaseDefinitionArray = Array of TCaseCaseDefinition;
  TCaseStatement = class(AStatement)
  protected
    FCaseExpression   : AExpression;
    FCaseCases        : TCaseCaseDefinitionArray;
    FElseStatement    : AStatement;

  public
    constructor Create(const CaseExpression: AExpression;
        const CaseCases: TCaseCaseDefinitionArray;
        const ElseStatement: AStatement);
    destructor Destroy; override;

    function  Optimize(const Scope: ABlaiseType): AStatement; override;
    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;




{                                                                              }
{ TNamedDeleteStatement                                                        }
{                                                                              }
type
  TNamedDeleteStatement = class(AStatement)
  protected
    FExpression : AExpression;

  public
    constructor Create(const Expression: AExpression);
    destructor Destroy; override;

    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TNamedAssignmentStatement                                                    }
{                                                                              }
type
  TNamedAssignmentStatement = class(AStatement)
  protected
    FName  : AExpression;
    FValue : AExpression;

  public
    constructor Create(const Name, Value: AExpression);
    destructor Destroy; override;

    procedure Execute(const Scope: ABlaiseType); override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



implementation

uses
  { Fundamentals }
  cUtils,
  cWriters,

  { Blaise }
  cBlaiseFuncs,
  cBlaiseStructs,
  cBlaiseStructsCode,
  cBlaiseMachineExpressions;



{                                                                              }
{ TStatementBlock                                                              }
{                                                                              }
constructor TStatementBlock.Create(const Statements: AStatementArray);
begin
  inherited Create;
  FStatements := Statements;
end;

destructor TStatementBlock.Destroy;
begin
  FreeObjectArray(FStatements);
  inherited Destroy;
end;

function TStatementBlock.Optimize(const Scope: ABlaiseType): AStatement;
var I : Integer;
begin
  For I := 0 to Length(FStatements) - 1 do
    FStatements[I] := FStatements[I].Optimize(Scope);
  Result := self;
end;

procedure TStatementBlock.Execute(const Scope: ABlaiseType);
var I : Integer;
begin
  For I := 0 to Length(FStatements) - 1 do
    FStatements[I].Execute(Scope);
end;

procedure TStatementBlock.Compile(const VM: TBlaiseVMCompiler);
var I : Integer;
begin
  For I := 0 to Length(FStatements) - 1 do
    FStatements[I].Compile(VM);
end;



{                                                                              }
{ TIfStatement                                                                 }
{                                                                              }
constructor TIfStatement.Create(const Condition: AExpression; const TrueStatement, FalseStatement: AStatement);
begin
  inherited Create;
  FCondition := Condition;
  FTrueStatement := TrueStatement;
  FFalseStatement := FalseStatement;
end;

destructor TIfStatement.Destroy;
begin
  FreeAndNil(FFalseStatement);
  FreeAndNil(FTrueStatement);
  FreeAndNil(FCondition);
  inherited Destroy;
end;

function TIfStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  FCondition := FCondition.Simplify(Scope);
  FTrueStatement := FTrueStatement.Optimize(Scope);
  FFalseStatement := FFalseStatement.Optimize(Scope);
  if FCondition is TConstantExpression then
    begin
      if FCondition.EvaluateAsBoolean(Scope) then
        begin
          Result := FTrueStatement;
          FTrueStatement := nil;
        end else
        begin
          Result := FFalseStatement;
          FFalseStatement := nil;
        end;
      Free;
    end else
    Result := self;
end;

procedure TIfStatement.Execute(const Scope: ABlaiseType);
begin
  if FCondition.EvaluateAsBoolean(Scope) then
    FTrueStatement.Execute(Scope) else
    if Assigned(FFalseStatement) then
      FFalseStatement.Execute(Scope);
end;

procedure TIfStatement.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FCondition.Compile(VM);
  VM.PopBoolean;
  P := VM.JumpFalse;
  FTrueStatement.Compile(VM);
  Q := -1;
  if Assigned(FFalseStatement) then
    Q := VM.Jump;
  VM.SetJumpPosition(P);
  if Assigned(FFalseStatement) then
    begin
      FFalseStatement.Compile(VM);
      VM.SetJumpPosition(Q);
    end;
end;



{                                                                              }
{ TCaseCaseDefinition                                                          }
{                                                                              }
destructor TCaseCaseDefinition.Destroy;
begin
  FreeAndNil(Statement);
  FreeAndNil(HighExpression);
  FreeAndNil(Expression);
  inherited Destroy;
end;

procedure TCaseCaseDefinition.Optimize(const Scope: ABlaiseType);
begin
  if Assigned(Expression) then
    Expression := Expression.Simplify(Scope);
  if Assigned(HighExpression) then
    HighExpression := HighExpression.Simplify(Scope);
  if Assigned(Statement) then
    Statement := Statement.Optimize(Scope);
end;

function TCaseCaseDefinition.MatchValue(const Scope: ABlaiseType; const Value: TObject): Boolean;
var L, H : TObject;
    C : TCompareResult;
begin
  L := Expression.Evaluate(Scope);
  try
    if Assigned(HighExpression) then
      begin
        C := ObjectCompare(Value, L);
        if C = crEqual then
          begin
            Result := True;
            exit;
          end;
        if C in [crLess, crUndefined] then
          begin
            Result := False;
            exit;
          end;
        H := HighExpression.Evaluate(Scope);
        try
          C := ObjectCompare(Value, H);
          Result := C in [crLess, crEqual];
        finally
          ObjectReleaseUnreferenced(H);
        end;
      end else
      Result := ObjectIsEqual(Value, L);
  finally
    ObjectReleaseUnreferenced(L);
  end;
end;



{                                                                              }
{ TCaseStatement                                                               }
{                                                                              }
constructor TCaseStatement.Create(const CaseExpression: AExpression; const CaseCases: TCaseCaseDefinitionArray; const ElseStatement: AStatement);
begin
  inherited Create;
  FCaseExpression := CaseExpression;
  FCaseCases := CaseCases;
  FElseStatement := ElseStatement;
end;

destructor TCaseStatement.Destroy;
begin
  FreeAndNil(FElseStatement);
  FreeObjectArray(FCaseCases);
  FreeAndNil(FCaseExpression);
  inherited Destroy;
end;

function TCaseStatement.Optimize(const Scope: ABlaiseType): AStatement;
var I : Integer;
begin
  Result := self;
  FCaseExpression := FCaseExpression.Simplify(Scope);
  For I := 0 to Length(FCaseCases) - 1 do
    FCaseCases[I].Optimize(Scope);
  if Assigned(FElseStatement) then
    FElseStatement := FElseStatement.Optimize(Scope);
end;

procedure TCaseStatement.Execute(const Scope: ABlaiseType);
var C : TObject;
    I : Integer;
    S : AStatement;
begin
  C := FCaseExpression.Evaluate(Scope);
  try
    For I := 0 to Length(FCaseCases) - 1 do
      if FCaseCases[I].MatchValue(Scope, C) then
        begin
          S := FCaseCases[I].Statement;
          if Assigned(S) then
            S.Execute(Scope);
          exit;
        end;
    if Assigned(FElseStatement) then
      FElseStatement.Execute(Scope);
  finally
    ObjectReleaseUnreferenced(C);
  end;
end;

procedure TCaseStatement.Compile(const VM: TBlaiseVMCompiler);
var I, L : Integer;
    C    : TCaseCaseDefinition;
    R    : Boolean;
    N, O : Integer;
    F    : Array of Integer;
begin
  O := -1;
  FCaseExpression.Compile(VM);
  L := Length(FCaseCases);
  SetLength(F, L);
  For I := 0 to L - 1 do
    begin
      C := FCaseCases[I];
      C.Expression.Compile(VM);
      R := Assigned(C.HighExpression);
      if not R then
        begin
          VM.Compare;
          VM.Pop;
          N := VM.JumpNotEqual;
        end
      else
        begin
          VM.Compare;
          VM.Pop;
          N := VM.JumpLess;
          C.HighExpression.Compile(VM);
          VM.Compare;
          VM.Pop;
          O := VM.JumpGreater;
        end;
      if Assigned(C.Statement) then
        C.Statement.Compile(VM);
      F[I] := VM.Jump;
      VM.SetJumpPosition(N);
      if R then
        VM.SetJumpPosition(O);
    end;
  if Assigned(FElseStatement) then
    FElseStatement.Compile(VM);
  For I := 0 to L - 1 do
    VM.SetJumpPosition(F[I]);
  VM.Pop;
end;



{                                                                              }
{ TAssignmentStatement                                                         }
{                                                                              }
constructor TAssignmentStatement.Create(const Identifier: AIdentifier;
    const Expression: AExpression);
begin
  inherited Create;
  FIdentifier := Identifier;
  FExpression := Expression;
end;

destructor TAssignmentStatement.Destroy;
begin
  FreeAndNil(FExpression);
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

function TAssignmentStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  FExpression := FExpression.Simplify(Scope);
  Result := self;
end;

procedure TAssignmentStatement.Execute(const Scope: ABlaiseType);
var V: TObject;
begin
  V := FExpression.Evaluate(Scope);
  try
    FIdentifier.AssignValue(Scope, V);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

procedure TAssignmentStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  FIdentifier.CompileAssign(VM);
end;



{                                                                              }
{ TProcedureCallStatement                                                      }
{                                                                              }
constructor TProcedureCallStatement.Create(const Identifier: AIdentifier);
begin
  inherited Create;
  FIdentifier := Identifier;
end;

destructor TProcedureCallStatement.Destroy;
begin
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

procedure TProcedureCallStatement.Execute(const Scope: ABlaiseType);
begin
  FIdentifier.Execute(Scope);
end;

procedure TProcedureCallStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  FIdentifier.CompileExecute(VM);
end;



{                                                                              }
{ TForStatement                                                                }
{                                                                              }
constructor TForStatement.Create(const Identifier: String;
    const Start, Stop: AExpression; const Increase: Boolean;
    const Statement: AStatement);
begin
  inherited Create;
  FIdentifier := Identifier;
  FStart := Start;
  FStop := Stop;
  FIncrease := Increase;
  FStatement := Statement;
end;

destructor TForStatement.Destroy;
begin
  FreeAndNil(FStatement);
  FreeAndNil(FStop);
  FreeAndNil(FStart);
  inherited Destroy;
end;

function TForStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  FStart := FStart.Simplify(Scope);
  FStop := FStop.Simplify(Scope);
  if Assigned(FStatement) then
    FStatement := FStatement.Optimize(Scope);
  Result := self;
end;

procedure TForStatement.Execute(const Scope: ABlaiseType);
var StartVal, StopVal : TObject;
    V : TObject;
    S : ABlaiseType;
    T : TBlaiseFieldType;

  function IsFinished(const Value: TObject): Boolean;
  var C : TCompareResult;
    begin
      C := ObjectCompare(Value, StopVal);
      Result := (FIncrease and (C = crGreater)) or
                (not FIncrease and (C = crLess)) or
                (C = crUndefined);
    end;

begin
  StartVal := FStart.Evaluate(Scope);
  try
    StopVal := FStop.Evaluate(Scope);
    try
      if IsFinished(StartVal) then
        exit;
      Scope.AssignIdentifier(FIdentifier, StartVal);
      Repeat
        try
          if Assigned(FStatement) then
            FStatement.Execute(Scope);
        except
          on EContinueFlowControl do ;
          on EBreakFlowControl do break;
        end;
        V := Scope.GetValue(FIdentifier, True, S, T);
        if FIncrease then
          ObjectInc(V)
        else
          ObjectDec(V);
      Until IsFinished(V);
    finally
      ObjectReleaseUnreferenced(StopVal);
    end;
  finally
    ObjectReleaseUnreferenced(StartVal);
  end;
end;

procedure TForStatement.Compile(const VM: TBlaiseVMCompiler);
var B, C, P, Q, R : Integer;
begin
  FStop.Compile(VM);
  FStart.Compile(VM);
  VM.Compare;
  if FIncrease then
    P := VM.JumpLess else
    P := VM.JumpGreater;
  VM.EnterLoopBlock(B, C);
  R := VM.GetOffset;
  VM.AssignIdentifier(FIdentifier);
  if Assigned(FStatement) then
    FStatement.Compile(VM);
  VM.SetContinueBlockPosition(C);
  VM.EvaluateUnique(FIdentifier);
  if FIncrease then
    begin
      VM.EvalInc;
      VM.PushAccumulator;
      VM.Compare;
      Q := VM.JumpLess;
    end
  else
    begin
      VM.EvalDec;
      VM.PushAccumulator;
      VM.Compare;
      Q := VM.JumpGreater;
    end;
  VM.JumpPosition(R);
  VM.SetJumpPosition(Q);
  VM.Pop;
  VM.SetBreakBlockPosition(B);
  VM.LeaveLoopBlock;
  VM.SetJumpPosition(P);
end;



{                                                                              }
{ TForEachStatement                                                            }
{                                                                              }
constructor TForEachStatement.Create(const Identifier: String;
    const Collection: AExpression; const Condition: AExpression;
    const Statement, ElseStatement: AStatement);
begin
  inherited Create;
  FIdentifier := Identifier;
  FCollection := Collection;
  FCondition := Condition;
  FStatement := Statement;
  FElseStatement := ElseStatement;
end;

destructor TForEachStatement.Destroy;
begin
  FreeAndNil(FElseStatement);
  FreeAndNil(FStatement);
  FreeAndNil(FCondition);
  FreeAndNil(FCollection);
  inherited Destroy;
end;

function TForEachStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  FCollection := FCollection.Simplify(Scope);
  if Assigned(FCondition) then
    FCondition := FCondition.Simplify(Scope);
  if Assigned(FStatement) then
    FStatement := FStatement.Optimize(Scope);
  if Assigned(FElseStatement) then
    FElseStatement := FElseStatement.Optimize(Scope);
  Result := self;
end;

procedure TForEachStatement.Execute(const Scope: ABlaiseType);
var C, I, V : TObject;
    R       : Boolean;
begin
  C := FCollection.Evaluate(Scope);
  I := ObjectIterate(C);
  R := False;
  While ObjectHasNext(I) do
    begin
      V := ObjectNext(I);
      Scope.AssignIdentifier(FIdentifier, V);
      if Assigned(FStatement) then
        FStatement.Execute(Scope);
      R := True;
    end;
  if not R and Assigned(FElseStatement) then
    FElseStatement.Execute(Scope);
end;

procedure TForEachStatement.Compile(const VM: TBlaiseVMCompiler);
var F, R : Integer;
begin
  FCollection.Compile(VM);
  VM.EvalIterate;
  VM.Pop;
  VM.PushAccumulator;
  R := VM.GetOffset;
  VM.EvalHasNext;
  VM.LoadBooleanFromA;
  F := VM.JumpFalse;
  VM.EvalNext;
  VM.PushAccumulator;
  VM.AssignIdentifier(FIdentifier);
  if Assigned(FStatement) then
    FStatement.Compile(VM);
  VM.JumpPosition(R);
  VM.SetJumpPosition(F);
  VM.Pop;
end;



{                                                                              }
{ TRepeatStatement                                                             }
{                                                                              }
constructor TRepeatStatement.Create(const Statement: AStatement;
    const Condition: AExpression);
begin
  inherited Create;
  FStatement := Statement;
  FCondition := Condition;
end;

destructor TRepeatStatement.Destroy;
begin
  FreeAndNil(FCondition);
  FreeAndNil(FStatement);
  inherited Destroy;
end;

function TRepeatStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  FStatement := FStatement.Optimize(Scope);
  FCondition := FCondition.Simplify(Scope);
  Result := self;
end;

procedure TRepeatStatement.Execute(const Scope: ABlaiseType);
begin
  Repeat
    try
      FStatement.Execute(Scope);
    except
      on EBreakFlowControl do break;
      on EContinueFlowControl do ;
    end;
  Until FCondition.EvaluateAsBoolean(Scope);
end;

procedure TRepeatStatement.Compile(const VM: TBlaiseVMCompiler);
var P, B, C : Integer;
begin
  VM.EnterLoopBlock(B, C);
  P := VM.GetOffset;
  FStatement.Compile(VM);
  VM.SetContinueBlockPosition(C);
  FCondition.Compile(VM);
  VM.PopBoolean;
  VM.JumpFalsePosition(P);
  VM.SetBreakBlockPosition(B);
  VM.LeaveLoopBlock;
end;



{                                                                              }
{ TWhileStatement                                                              }
{                                                                              }
constructor TWhileStatement.Create(const Condition: AExpression;
    const Statement: AStatement);
begin
  inherited Create;
  FCondition := Condition;
  FStatement := Statement;
end;

destructor TWhileStatement.Destroy;
begin
  FreeAndNil(FStatement);
  FreeAndNil(FCondition);
  inherited Destroy;
end;

function TWhileStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  FCondition := FCondition.Simplify(Scope);
  FStatement := FStatement.Optimize(Scope);
  Result := self;
end;

procedure TWhileStatement.Execute(const Scope: ABlaiseType);
begin
  While FCondition.EvaluateAsBoolean(Scope) do
    try
      FStatement.Execute(Scope);
    except
      on EBreakFlowControl do break;
      on EContinueFlowControl do ;
    end;
end;

procedure TWhileStatement.Compile(const VM: TBlaiseVMCompiler);
var B, C, P, R : Integer;
begin
  VM.EnterLoopBlock(B, C);
  R := VM.GetOffset;
  VM.SetContinueBlockPosition(C);
  FCondition.Compile(VM);
  VM.PopBoolean;
  P := VM.JumpFalse;
  FStatement.Compile(VM);
  VM.JumpPosition(R);
  VM.SetJumpPosition(P);
  VM.SetBreakBlockPosition(B);
  VM.LeaveLoopBlock;
end;



{                                                                              }
{ TWriteStatement                                                              }
{                                                                              }
constructor TTextOutputStatement.Create(const Identifier: AIdentifier;
    const Expressions: AExpressionArray; const NewLine: Boolean);
begin
  inherited Create;
  FIdentifier := Identifier;
  FExpressions := Expressions;
  FNewLine := NewLine;
end;

destructor TTextOutputStatement.Destroy;
begin
  FreeObjectArray(FExpressions);
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

function TTextOutputStatement.Optimize(const Scope: ABlaiseType): AStatement;
var I : Integer;
begin
  Result := self;
  For I := 0 to Length(FExpressions) - 1 do
    FExpressions[I] := FExpressions[I].Simplify(Scope);
end;

procedure TTextOutputStatement.Execute(const Scope: ABlaiseType);
var S, O : TObject;
    I : Integer;
    T : ABlaiseType;
    F : TBlaiseFieldType;
begin
  if Assigned(FIdentifier) then
    S := FIdentifier.Evaluate(Scope) else
    S := Scope.GetValue('__StdOutput__', True, T, F);
  try
    if not (S is AWriterEx) then
      ExecuteError('Standard output not writable');
    For I := 0 to Length(FExpressions) - 1 do
      begin
        O := FExpressions[I].Evaluate(Scope);
        try
          AWriterEx(S).WriteStr(ObjectGetAsUTF8(O));
        finally
          ObjectReleaseUnreferenced(O);
        end;
      end;
    if FNewLine then
      AWriterEx(S).WriteStr(#13#10);
  finally
    ObjectReleaseUnreferenced(S);
  end;
end;

procedure TTextOutputStatement.Compile(const VM: TBlaiseVMCompiler);
var I : Integer;
begin
  For I := 0 to Length(FExpressions) - 1 do
    begin
      FExpressions[I].Compile(VM);
      VM.PopUTF8;
      VM.TextOut;
    end;
  if FNewLine then
    begin
      VM.LoadUTF8(#13#10);
      VM.TextOut;
    end;
end;



{                                                                              }
{ TExitStatement                                                               }
{                                                                              }
procedure TExitStatement.Execute(const Scope: ABlaiseType);
begin
  raise EExitFlowControl.Create('Exit call not in procedure');
end;

procedure TExitStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.FlowExit;
end;



{                                                                              }
{ TBreakStatement                                                              }
{                                                                              }
procedure TBreakStatement.Execute(const Scope: ABlaiseType);
begin
  raise EBreakFlowControl.Create('Break call not in For, While or Repeat loop');
end;

procedure TBreakStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.FlowBreak;
end;



{                                                                              }
{ TContinueStatement                                                           }
{                                                                              }
procedure TContinueStatement.Execute(const Scope: ABlaiseType);
begin
  raise EContinueFlowControl.Create('Continue call not in For, While or Repeat loop');
end;

procedure TContinueStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.FlowContinue;
end;



{                                                                              }
{ TReturnStatement                                                             }
{                                                                              }
constructor TReturnStatement.Create(const Expression: AExpression);
begin
  inherited Create;
  FExpression := Expression;
end;

destructor TReturnStatement.Destroy;
begin
  FreeAndNil(FExpression);
  inherited Destroy;
end;

procedure TReturnStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  VM.TaskReturn;
end;



{                                                                              }
{ TImportStatement                                                             }
{                                                                              }
constructor TImportStatement.Create(const Identifier, UnitName: String);
begin
  inherited Create;
  FIdentifier := Identifier;
  FUnitName := UnitName;
end;

procedure TImportStatement.Execute(const Scope: ABlaiseType);
begin
  ScopeImport(Scope, FIdentifier, FUnitName);
end;

procedure TImportStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.Import(FIdentifier, FUnitName);
end;



{                                                                              }
{ ERaiseFlowControl                                                            }
{                                                                              }
constructor ERaiseFlowControl.Create(const ExceptionValue: TObject);
begin
  inherited Create('Exception');
  self.ExceptionValue := ExceptionValue;
end;

destructor ERaiseFlowControl.Destroy;
begin
  FreeAndNil(ExceptionValue);
  inherited Destroy;
end;



{                                                                              }
{ TRaiseStatement                                                              }
{                                                                              }
constructor TRaiseStatement.Create(const Exception: AExpression);
begin
  inherited Create;
  FException := Exception;
end;

destructor TRaiseStatement.Destroy;
begin
  FreeAndNil(FException);
  inherited Destroy;
end;

procedure TRaiseStatement.Execute(const Scope: ABlaiseType);
begin
  if Assigned(FException) then
    raise ERaiseFlowControl.Create(FException.Evaluate(Scope))
  else
    raise ERaiseFlowControl.Create(nil);
end;

procedure TRaiseStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  if Assigned(FException) then
    begin
      FException.Compile(VM);
      VM.FlowRaise;
    end
  else
    VM.FlowReraise;
end;



{                                                                              }
{ TTryFinallyStatement                                                         }
{                                                                              }
constructor TTryFinallyStatement.Create(const TryStatement, FinallyStatement: AStatement);
begin
  inherited Create;
  FTryStatement := TryStatement;
  FFinallyStatement := FinallyStatement;
end;

destructor TTryFinallyStatement.Destroy;
begin
  FreeAndNil(FFinallyStatement);
  FreeAndNil(FTryStatement);
  inherited Destroy;
end;

function TTryFinallyStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  if Assigned(FTryStatement) then
    FTryStatement := FTryStatement.Optimize(Scope);
  if Assigned(FFinallyStatement) then
    FFinallyStatement := FFinallyStatement.Optimize(Scope);
  if not Assigned(FFinallyStatement) then
    begin
      Result := FTryStatement;
      FTryStatement := nil;
      Free;
    end else
    Result := self;
end;

procedure TTryFinallyStatement.Execute(const Scope: ABlaiseType);
begin
  try
    if Assigned(FTryStatement) then
      FTryStatement.Execute(Scope);
  finally
    if Assigned(FFinallyStatement) then
      FFinallyStatement.Execute(Scope);
  end;
end;

procedure TTryFinallyStatement.Compile(const VM: TBlaiseVMCompiler);
var F : Integer;
begin
  F := VM.EnterTryFinallyBlock;
  if Assigned(FTryStatement) then
    FTryStatement.Compile(VM);
  VM.LeaveTryFinallyBlock;
  VM.SetFinallyBlockPosition(F);
  if Assigned(FFinallyStatement) then
    FFinallyStatement.Compile(VM);
  VM.LeaveTryFinallyHandler;
end;



{                                                                              }
{ TTryExceptStatement                                                          }
{                                                                              }
constructor TTryExceptStatement.Create(const TryStatement, DefaultHandler: AStatement;
    const HandleDefault: Boolean;
    const TypeHandlers: TExceptionHandlerDefinitionArray);
begin
  inherited Create;
  FTryStatement := TryStatement;
  FDefaultHandler := DefaultHandler;
  FHandleDefault := HandleDefault;
  FTypeHandlers := TypeHandlers;
end;

destructor TTryExceptStatement.Destroy;
var I : Integer;
begin
  For I := Length(FTypeHandlers) - 1 downto 0 do
    FreeAndNil(FTypeHandlers[I].Statement);
  FreeAndNil(FDefaultHandler);
  FreeAndNil(FTryStatement);
  inherited Destroy;
end;

function TTryExceptStatement.Optimize(const Scope: ABlaiseType): AStatement;
var I : Integer;
begin
  if Assigned(FTryStatement) then
    FTryStatement := FTryStatement.Optimize(Scope);
  if Assigned(FDefaultHandler) then
    FDefaultHandler := FDefaultHandler.Optimize(Scope);
  For I := 0 to Length(FTypeHandlers) - 1 do
    FTypeHandlers[I].Statement := FTypeHandlers[I].Statement.Optimize(Scope);

  if not Assigned(FTryStatement) then
    begin
      Result := nil;
      Free;
    end else
    Result := self;
end;

procedure TTryExceptStatement.Execute(const Scope: ABlaiseType);
var I : Integer;
    L : TParentedScope;
    S : ABlaiseType;
    V : TObject;
begin
  try
    if Assigned(FTryStatement) then
      FTryStatement.Execute(Scope);
  except
    on E: ERaiseFlowControl do
      begin
        if not Assigned(E.ExceptionValue) then
          ExecuteError('Raise without exception value');
        For I := 0 to Length(FTypeHandlers) - 1 do
          if Scope.GetValueAsTypeDefinition(FTypeHandlers[I].TypeIdentifier, True).IsType(E.ExceptionValue) then
            begin
              if Assigned(FTypeHandlers[I].Statement) then
                begin
                  if FTypeHandlers[I].Identifier <> '' then
                    begin
                      L := TParentedScope.Create(Scope);
                      L.SetField(FTypeHandlers[I].Identifier, E.ExceptionValue);
                      S := L;
                    end else
                    begin
                      L := nil;
                      S := Scope;
                    end;
                  try try
                    FTypeHandlers[I].Statement.Execute(S);
                  except
                    on F: ERaiseFlowControl do
                      if Assigned(F.ExceptionValue) then
                        raise else
                        begin
                          V := E.ExceptionValue;
                          E.ExceptionValue := nil;
                          raise ERaiseFlowControl.Create(V);
                        end;
                  end;
                  finally
                    FreeAndNil(L);
                  end;
                end;
              exit;
            end;
        if not FHandleDefault then
          raise else
          if Assigned(FDefaultHandler) then
            try
              FDefaultHandler.Execute(Scope);
            except
              on F: ERaiseFlowControl do
                if Assigned(F.ExceptionValue) then
                  raise else
                  begin
                    V := E.ExceptionValue;
                    E.ExceptionValue := nil;
                    raise ERaiseFlowControl.Create(V);
                  end;
            end;
      end;
  end;
end;

procedure TTryExceptStatement.Compile(const VM: TBlaiseVMCompiler);
var E, F : Integer;
begin
  E := VM.EnterTryExceptBlock;
  if Assigned(FTryStatement) then
    FTryStatement.Compile(VM);
  VM.LeaveTryExceptBlock;
  F := VM.Jump;
  VM.SetExceptBlockPosition(E);
  if Assigned(FDefaultHandler) then
    FDefaultHandler.Compile(VM);
  VM.LeaveTryExceptHandler;
  VM.SetJumpPosition(F);
end;



{                                                                              }
{ TNamedDeleteStatement                                                        }
{                                                                              }
constructor TNamedDeleteStatement.Create(const Expression: AExpression);
begin
  inherited Create;
  FExpression := Expression;
end;

destructor TNamedDeleteStatement.Destroy;
begin
  FreeAndNil(FExpression);
  inherited Destroy;
end;

procedure TNamedDeleteStatement.Execute(const Scope: ABlaiseType);
var Name : String;
begin
  Name := FExpression.EvaluateAsUTF8(Scope);
  NameSpaceDeleteName(ScopeGetRootNameSpace(Scope), Name);
end;

procedure TNamedDeleteStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  VM.PopUTF8;
  VM.NamedDelete;
end;



{                                                                              }
{ TNamedAssignmentStatement                                                    }
{                                                                              }
constructor TNamedAssignmentStatement.Create(const Name, Value: AExpression);
begin
  inherited Create;
  FName := Name;
  FValue := Value;
end;

destructor TNamedAssignmentStatement.Destroy;
begin
  FreeAndNil(FName);
  FreeAndNil(FValue);
  inherited Destroy;
end;

procedure TNamedAssignmentStatement.Execute(const Scope: ABlaiseType);
var Name  : String;
    Value : TObject;
begin
  Name := FName.EvaluateAsUTF8(Scope);
  Value := FValue.Evaluate(Scope);
  try
    NameSpaceSetName(ScopeGetRootNameSpace(Scope), Name, Value);
  finally
    ObjectReleaseUnreferenced(Value);
  end;
end;

procedure TNamedAssignmentStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  FValue.Compile(VM);
  FName.Compile(VM);
  VM.PopUTF8;
  VM.NamedAssign;
end;



end.

