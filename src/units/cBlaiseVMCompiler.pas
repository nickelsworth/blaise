{                                                                              }
{                    Blaise Virtual Machine Compiler v0.02                     }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{              Its original file name is cBlaiseVMCompiler.pas                 }
{                                                                              }
{ Description:                                                                 }
{   This unit implements the Blaise virtual machine compiler.                  }
{                                                                              }
{ Revision history:                                                            }
{   29/03/2003  0.01  Initial version.                                         }
{   07/04/2003  0.02  Relocatable code.                                        }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseVMCompiler;

interface

uses
  { Fundamentals }
  cWriters,

  { Blaise }
  cBlaiseTypes;



{                                                                              }
{ TBlaiseVMCompiler                                                            }
{   Virtual Machine Compiler class.                                            }
{                                                                              }
type
  TBlaiseVMCompiler = class(TStringWriter)
  protected

  public
    procedure Clear;
    function  GetOffset: Integer;
    procedure SetIntegerAtOffset(const P, V: Integer);

    procedure Nop;

    procedure LoadUTF8(const V: String);
    procedure LoadBooleanFromA;
    procedure LoadStringFromA;
    procedure LoadIntegerFromA;
    procedure LoadFloatFromA;
    procedure LoadCompareFromA;
    procedure ReverseCompare;
    procedure LoadAFromStack0;
    procedure LoadAFromStack1;
    procedure LoadBooleanTrue;
    procedure LoadBooleanFalse;

    procedure PushNil;
    procedure PushObject(const V: TObject);
    procedure PushBoolean(const V: Boolean);
    procedure PushString(const V: String);
    procedure PushInteger(const V: Int64);
    procedure PushFloat(const V: Extended);
    procedure PushComplex(const V: Extended);
    procedure PushAccumulator;
    procedure PushBooleanRegister;

    procedure Pop;
    procedure PopAccumulator;
    procedure PopBoolean;
    procedure PopUTF8;
    procedure PopInt;
    procedure StackSwapTop2;

    procedure EvalCoerceBoolean;
    procedure EvalCoerceString;
    procedure EvalCoerceInteger;
    procedure EvalCoerceFloat;
    procedure EvalCompare;
    procedure EvalDup;
    procedure EvalUnique;
    procedure EvalIterate;
    procedure EvalHasNext;
    procedure EvalNext;
    procedure EvalIsType;
    procedure EvalIsIn;
    procedure EvalAppendList;

    procedure EvalLeftCoerceAdd;
    procedure EvalRightCoerceAdd;
    procedure EvalLeftCoerceSubtract;
    procedure EvalRightCoerceSubtract;
    procedure EvalLeftCoerceMultiply;
    procedure EvalRightCoerceMultiply;
    procedure EvalLeftCoerceDivide;
    procedure EvalRightCoerceDivide;
    procedure EvalLeftCoerceIntegerDivide;
    procedure EvalRightCoerceIntegerDivide;
    procedure EvalLeftCoerceModulo;
    procedure EvalRightCoerceModulo;
    procedure EvalLeftCoerceAND;
    procedure EvalRightCoerceAND;
    procedure EvalLeftCoerceOR;
    procedure EvalRightCoerceOR;
    procedure EvalLeftCoerceXOR;
    procedure EvalRightCoerceXOR;
    procedure EvalLeftCoerceSHL;
    procedure EvalRightCoerceSHL;
    procedure EvalLeftCoerceSHR;
    procedure EvalRightCoerceSHR;

    procedure EvalLeftAdd;
    procedure EvalRightAdd;
    procedure EvalLeftSubtract;
    procedure EvalRightSubtract;
    procedure EvalLeftMultiply;
    procedure EvalRightMultiply;
    procedure EvalLeftDivide;
    procedure EvalRightDivide;
    procedure EvalLeftIntegerDivide;
    procedure EvalRightIntegerDivide;
    procedure EvalLeftModulo;
    procedure EvalRightModulo;
    procedure EvalLeftAND;
    procedure EvalRightAND;
    procedure EvalLeftOR;
    procedure EvalRightOR;
    procedure EvalLeftXOR;
    procedure EvalRightXOR;
    procedure EvalLeftSHL;
    procedure EvalRightSHL;
    procedure EvalLeftSHR;
    procedure EvalRightSHR;

    procedure EvalCoerceSqr;
    procedure EvalCoerceSqrt;
    procedure EvalCoerceExp;
    procedure EvalCoerceLn;
    procedure EvalCoerceSin;
    procedure EvalCoerceCos;

    procedure EvalSqr;
    procedure EvalSqrt;
    procedure EvalExp;
    procedure EvalLn;
    procedure EvalSin;
    procedure EvalCos;

    procedure EvalInc;
    procedure EvalDec;

    procedure Return;

    function  GenJumpForward(const JmpOp: Byte): Integer;
    procedure GenJumpOffset(const JmpOp: Byte; const Offset: Integer);

    procedure SetJumpPosition(const P: Integer);

    function  Jump: Integer;
    procedure JumpPosition(const P: Integer);
    function  JumpTrue: Integer;
    procedure JumpTruePosition(const P: Integer);
    function  JumpFalse: Integer;
    procedure JumpFalsePosition(const P: Integer);
    function  JumpCompared: Integer;
    function  JumpEqual: Integer;
    function  JumpNotEqual: Integer;
    function  JumpGreater: Integer;
    function  JumpLess: Integer;
    function  JumpAssigned: Integer;
    function  JumpNotAssigned: Integer;

    procedure FlowExit;

    procedure FlowBreak;
    procedure FlowContinue;
    procedure EnterLoopBlock(var BreakPos, ContinuePos: Integer);
    procedure LeaveLoopBlock;
    procedure SetBreakBlockPosition(const P: Integer);
    procedure SetContinueBlockPosition(const P: Integer);

    procedure FlowRaise;
    procedure FlowReraise;
    function  EnterTryFinallyBlock: Integer;
    procedure LeaveTryFinallyBlock;
    procedure LeaveTryFinallyHandler;
    procedure SetFinallyBlockPosition(const P: Integer);
    function  EnterTryExceptBlock: Integer;
    procedure LeaveTryExceptBlock;
    procedure LeaveTryExceptHandler;
    procedure SetExceptBlockPosition(const P: Integer);

    procedure EvaluateUnique(const Identifier: String);
    procedure EvaluateIdentifier(const Identifier: String);
    procedure ExecuteIdentifier(const Identifier: String);
    procedure AssignIdentifier(const Identifier: String);
    procedure SetIdentifierScope;
    procedure EvaluateIndexedIdentifier;
    procedure ExecuteIndexedIdentifier;
    procedure AssignIndexedIdentifier;
    procedure EvaluateIdentifierCall(const Identifier: String);
    procedure ExecuteIdentifierCall(const Identifier: String);
    procedure EvaluateSelf;
    procedure SetInheritedScope;

    procedure CreateRational;
    procedure CreateArray;
    procedure CreateDictionary;

    procedure Compare;

    procedure UnOp(const Oper: Byte);
    procedure CoerceUnOp(const Coerce, Oper: Byte);
    procedure UnOpSqr;
    procedure UnOpSqrt;
    procedure UnOpExp;
    procedure UnOpLn;
    procedure UnOpSin;
    procedure UnOpCos;
    procedure UnOpNegate;
    procedure UnOpAbs;
    procedure UnOpInc;
    procedure UnOpDec;
    procedure UnOpLogicalNOT;

    procedure BinOp(const LCoerce, RCoerce, LOper, ROper: Byte);
    procedure BinOpAdd;
    procedure BinOpSubtract;
    procedure BinOpMultiply;
    procedure BinOpDivide;
    procedure BinOpPower;
    procedure BinOpIntegerDivide;
    procedure BinOpModulo;
    procedure BinOpLogicalAND;
    procedure BinOpLogicalOR;
    procedure BinOpLogicalXOR;
    procedure BinOpBitwiseSHL;
    procedure BinOpBitwiseSHR;

    procedure NamedDelete;
    procedure NamedAssign;
    procedure NamedExists;
    procedure NamedGet;
    procedure NamedDirectory;

    procedure SetModuleType(const ModuleTypeID: Byte);
    procedure UseUnit(const UnitName: String);
    procedure Declare(const Decl: AScopeFieldDefinitionArray);
    procedure TextOut;
    procedure EnterFunctionScope;
    procedure LeaveFunctionScope;
    procedure StartTask;
    procedure TaskReturn;
    procedure Import(const Identifier, UnitName: String);
  end;



implementation

uses
  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs;



{                                                                              }
{ TBlaiseVMCompiler                                                            }
{                                                                              }
procedure TBlaiseVMCompiler.Clear;
begin
  FData := '';
  FSize := 0;
  FPos := 0;
end;

function TBlaiseVMCompiler.GetOffset: Integer;
begin
  Result := FPos;
end;

procedure TBlaiseVMCompiler.SetIntegerAtOffset(const P, V: Integer);
var F : PChar;
begin
  Assert(P >= 0);
  Assert(P + Sizeof(Integer) <= FSize);
  F := Pointer(FData);
  Inc(F, P);
  PInteger(F)^ := V;
end;

procedure TBlaiseVMCompiler.Nop;
begin
  WriteByte(BLAISE_VM_NOP);
end;

procedure TBlaiseVMCompiler.LoadUTF8(const V: String);
begin
  WriteByte(BLAISE_VM_LOAD_UTF8_CONST);
  WritePackedString(V);
end;

procedure TBlaiseVMCompiler.LoadBooleanFromA;
begin
  WriteByte(BLAISE_VM_LOAD_BOOL_A);
end;

procedure TBlaiseVMCompiler.LoadStringFromA;
begin
  WriteByte(BLAISE_VM_LOAD_STR_A);
end;

procedure TBlaiseVMCompiler.LoadIntegerFromA;
begin
  WriteByte(BLAISE_VM_LOAD_INT_A);
end;

procedure TBlaiseVMCompiler.LoadFloatFromA;
begin
  WriteByte(BLAISE_VM_LOAD_FLOAT_A);
end;

procedure TBlaiseVMCompiler.LoadCompareFromA;
begin
  WriteByte(BLAISE_VM_LOAD_CMP_A);
end;

procedure TBlaiseVMCompiler.ReverseCompare;
begin
  WriteByte(BLAISE_VM_REVERSE_CMP);
end;

procedure TBlaiseVMCompiler.LoadAFromStack0;
begin
  WriteByte(BLAISE_VM_LOAD_A_STACK0);
end;

procedure TBlaiseVMCompiler.LoadAFromStack1;
begin
  WriteByte(BLAISE_VM_LOAD_A_STACK1);
end;

procedure TBlaiseVMCompiler.LoadBooleanTrue;
begin
  WriteByte(BLAISE_VM_LOAD_BOOL_TRUE);
end;

procedure TBlaiseVMCompiler.LoadBooleanFalse;
begin
  WriteByte(BLAISE_VM_LOAD_BOOL_FALSE);
end;

procedure TBlaiseVMCompiler.PushNil;
begin
  WriteByte(BLAISE_VM_PUSH_NIL);
end;

procedure TBlaiseVMCompiler.PushObject(const V: TObject);
begin
  WriteByte(BLAISE_VM_PUSH_CONST_OBJECT);
  StreamOutObject(self, V);
end;

procedure TBlaiseVMCompiler.PushBoolean(const V: Boolean);
begin
  WriteByte(BLAISE_VM_PUSH_CONST_BOOL);
  if V then
    WriteByte(1) else
    WriteByte(0);
end;

procedure TBlaiseVMCompiler.PushString(const V: String);
begin
  WriteByte(BLAISE_VM_PUSH_CONST_STR);
  WritePackedString(V);
end;

procedure TBlaiseVMCompiler.PushInteger(const V: Int64);
begin
  WriteByte(BLAISE_VM_PUSH_CONST_INT);
  WriteInt64(V);
end;

procedure TBlaiseVMCompiler.PushFloat(const V: Extended);
begin
  WriteByte(BLAISE_VM_PUSH_CONST_FLOAT);
  WriteExtended(V);
end;

procedure TBlaiseVMCompiler.PushComplex(const V: Extended);
begin
  WriteByte(BLAISE_VM_PUSH_CONST_COMPLEX);
  WriteExtended(V);
end;

procedure TBlaiseVMCompiler.PushAccumulator;
begin
  WriteByte(BLAISE_VM_PUSH_A);
end;

procedure TBlaiseVMCompiler.PushBooleanRegister;
begin
  WriteByte(BLAISE_VM_PUSH_BOOL);
end;

procedure TBlaiseVMCompiler.Pop;
begin
  WriteByte(BLAISE_VM_POP);
end;

procedure TBlaiseVMCompiler.PopAccumulator;
begin
  WriteByte(BLAISE_VM_POP_A);
end;

procedure TBlaiseVMCompiler.PopBoolean;
begin
  WriteByte(BLAISE_VM_POP_A);
  WriteByte(BLAISE_VM_EVAL_COERCE_BOOL);
  WriteByte(BLAISE_VM_LOAD_BOOL_A);
end;

procedure TBlaiseVMCompiler.PopUTF8;
begin
  WriteByte(BLAISE_VM_POP_A);
  WriteByte(BLAISE_VM_EVAL_COERCE_STR);
  WriteByte(BLAISE_VM_LOAD_STR_A);
end;

procedure TBlaiseVMCompiler.PopInt;
begin
  WriteByte(BLAISE_VM_POP_A);
  WriteByte(BLAISE_VM_EVAL_COERCE_INT);
  WriteByte(BLAISE_VM_LOAD_INT_A);
end;

procedure TBlaiseVMCompiler.StackSwapTop2;
begin
  WriteByte(BLAISE_VM_STACK_SWAP_TOP2);
end;

procedure TBlaiseVMCompiler.EvalCoerceBoolean;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_BOOL);
end;

procedure TBlaiseVMCompiler.EvalCoerceString;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_STR);
end;

procedure TBlaiseVMCompiler.EvalCoerceInteger;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_INT);
end;

procedure TBlaiseVMCompiler.EvalCoerceFloat;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_FLOAT);
end;

procedure TBlaiseVMCompiler.EvalCompare;
begin
  WriteByte(BLAISE_VM_EVAL_CMP);
end;

procedure TBlaiseVMCompiler.EvalDup;
begin
  WriteByte(BLAISE_VM_EVAL_DUP);
end;

procedure TBlaiseVMCompiler.EvalUnique;
begin
  WriteByte(BLAISE_VM_EVAL_UNIQUE);
end;

procedure TBlaiseVMCompiler.EvalHasNext;
begin
  WriteByte(BLAISE_VM_EVAL_HASNEXT);
end;

procedure TBlaiseVMCompiler.EvalIterate;
begin
  WriteByte(BLAISE_VM_EVAL_ITERATE);
end;

procedure TBlaiseVMCompiler.EvalNext;
begin
  WriteByte(BLAISE_VM_EVAL_NEXT);
end;

procedure TBlaiseVMCompiler.EvalIsType;
begin
  WriteByte(BLAISE_VM_EVAL_IS_TYPE);
end;

procedure TBlaiseVMCompiler.EvalIsIn;
begin
  WriteByte(BLAISE_VM_EVAL_IS_IN);
end;

procedure TBlaiseVMCompiler.EvalAppendList;
begin
  WriteByte(BLAISE_VM_EVAL_APPEND_LIST);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceAdd;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_ADD);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceAdd;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_ADD);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceSubtract;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_SUB);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceSubtract;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_SUB);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceMultiply;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_MUL);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceMultiply;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_MUL);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceDivide;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_DIV);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceDivide;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_DIV);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceIntegerDivide;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_IDIV);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceIntegerDivide;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_IDIV);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceModulo;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_MOD);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceModulo;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_MOD);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceAND;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_AND);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceAND;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_AND);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceOR;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_OR);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceOR;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_OR);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceXOR;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_XOR);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceXOR;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_XOR);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceSHL;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_SHL);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceSHL;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_SHL);
end;

procedure TBlaiseVMCompiler.EvalLeftCoerceSHR;
begin
  WriteByte(BLAISE_VM_EVAL_L_COERCE_SHR);
end;

procedure TBlaiseVMCompiler.EvalRightCoerceSHR;
begin
  WriteByte(BLAISE_VM_EVAL_R_COERCE_SHR);
end;

procedure TBlaiseVMCompiler.EvalLeftAdd;
begin
  WriteByte(BLAISE_VM_EVAL_L_ADD);
end;

procedure TBlaiseVMCompiler.EvalRightAdd;
begin
  WriteByte(BLAISE_VM_EVAL_R_ADD);
end;

procedure TBlaiseVMCompiler.EvalLeftSubtract;
begin
  WriteByte(BLAISE_VM_EVAL_L_SUB);
end;

procedure TBlaiseVMCompiler.EvalRightSubtract;
begin
  WriteByte(BLAISE_VM_EVAL_R_SUB);
end;

procedure TBlaiseVMCompiler.EvalLeftMultiply;
begin
  WriteByte(BLAISE_VM_EVAL_L_MUL);
end;

procedure TBlaiseVMCompiler.EvalRightMultiply;
begin
  WriteByte(BLAISE_VM_EVAL_R_MUL);
end;

procedure TBlaiseVMCompiler.EvalLeftDivide;
begin
  WriteByte(BLAISE_VM_EVAL_L_DIV);
end;

procedure TBlaiseVMCompiler.EvalRightDivide;
begin
  WriteByte(BLAISE_VM_EVAL_R_DIV);
end;

procedure TBlaiseVMCompiler.EvalLeftIntegerDivide;
begin
  WriteByte(BLAISE_VM_EVAL_L_IDIV);
end;

procedure TBlaiseVMCompiler.EvalRightIntegerDivide;
begin
  WriteByte(BLAISE_VM_EVAL_R_IDIV);
end;

procedure TBlaiseVMCompiler.EvalLeftModulo;
begin
  WriteByte(BLAISE_VM_EVAL_L_MOD);
end;

procedure TBlaiseVMCompiler.EvalRightModulo;
begin
  WriteByte(BLAISE_VM_EVAL_R_MOD);
end;

procedure TBlaiseVMCompiler.EvalLeftAND;
begin
  WriteByte(BLAISE_VM_EVAL_L_AND);
end;

procedure TBlaiseVMCompiler.EvalRightAND;
begin
  WriteByte(BLAISE_VM_EVAL_R_AND);
end;

procedure TBlaiseVMCompiler.EvalLeftOR;
begin
  WriteByte(BLAISE_VM_EVAL_L_OR);
end;

procedure TBlaiseVMCompiler.EvalRightOR;
begin
  WriteByte(BLAISE_VM_EVAL_R_OR);
end;

procedure TBlaiseVMCompiler.EvalLeftXOR;
begin
  WriteByte(BLAISE_VM_EVAL_L_XOR);
end;

procedure TBlaiseVMCompiler.EvalRightXOR;
begin
  WriteByte(BLAISE_VM_EVAL_R_XOR);
end;

procedure TBlaiseVMCompiler.EvalLeftSHL;
begin
  WriteByte(BLAISE_VM_EVAL_L_SHL);
end;

procedure TBlaiseVMCompiler.EvalRightSHL;
begin
  WriteByte(BLAISE_VM_EVAL_R_SHL);
end;

procedure TBlaiseVMCompiler.EvalLeftSHR;
begin
  WriteByte(BLAISE_VM_EVAL_L_SHR);
end;

procedure TBlaiseVMCompiler.EvalRightSHR;
begin
  WriteByte(BLAISE_VM_EVAL_R_SHR);
end;

procedure TBlaiseVMCompiler.EvalCoerceSqr;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_SQR);
end;

procedure TBlaiseVMCompiler.EvalCoerceSqrt;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_SQRT);
end;

procedure TBlaiseVMCompiler.EvalCoerceExp;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_EXP);
end;

procedure TBlaiseVMCompiler.EvalCoerceLn;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_LN);
end;

procedure TBlaiseVMCompiler.EvalCoerceSin;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_SIN);
end;

procedure TBlaiseVMCompiler.EvalCoerceCos;
begin
  WriteByte(BLAISE_VM_EVAL_COERCE_COS);
end;

procedure TBlaiseVMCompiler.EvalSqr;
begin
  WriteByte(BLAISE_VM_EVAL_SQR);
end;

procedure TBlaiseVMCompiler.EvalSqrt;
begin
  WriteByte(BLAISE_VM_EVAL_SQRT);
end;

procedure TBlaiseVMCompiler.EvalExp;
begin
  WriteByte(BLAISE_VM_EVAL_EXP);
end;

procedure TBlaiseVMCompiler.EvalLn;
begin
  WriteByte(BLAISE_VM_EVAL_LN);
end;

procedure TBlaiseVMCompiler.EvalSin;
begin
  WriteByte(BLAISE_VM_EVAL_SIN);
end;

procedure TBlaiseVMCompiler.EvalCos;
begin
  WriteByte(BLAISE_VM_EVAL_COS);
end;

procedure TBlaiseVMCompiler.EvalInc;
begin
  WriteByte(BLAISE_VM_EVAL_INC);
end;

procedure TBlaiseVMCompiler.EvalDec;
begin
  WriteByte(BLAISE_VM_EVAL_DEC);
end;

procedure TBlaiseVMCompiler.Return;
begin
  WriteByte(BLAISE_VM_RET);
end;

function TBlaiseVMCompiler.GenJumpForward(const JmpOp: Byte): Integer;
begin
  // write an incomplete jump instruction; a later call to SetJumpPosition
  // will set the jump position
  WriteByte(JmpOp);
  Result := FPos;
  WriteLongInt(BLAISE_VM_INVALID_REL_OFFSET);
end;

procedure TBlaiseVMCompiler.GenJumpOffset(const JmpOp: Byte; const Offset: Integer);
begin
  // the jump parameter is the relative offset from the end of the jump instruction
  WriteByte(JmpOp);
  WriteLongInt(Offset - FPos - Sizeof(LongInt));
end;

procedure TBlaiseVMCompiler.SetJumpPosition(const P: Integer);
begin
  // set the jump paramater for the jump instruction created by JumpForward;
  // the parameter is the relative offset from the end of the jump instruction
  SetIntegerAtOffset(P, FPos - P - Sizeof(LongInt));
end;

function TBlaiseVMCompiler.Jump: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP);
end;

procedure TBlaiseVMCompiler.JumpPosition(const P: Integer);
begin
  GenJumpOffset(BLAISE_VM_JMP, P);
end;

function TBlaiseVMCompiler.JumpTrue: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_TRUE);
end;

procedure TBlaiseVMCompiler.JumpTruePosition(const P: Integer);
begin
  GenJumpOffset(BLAISE_VM_JMP_TRUE, P);
end;

function TBlaiseVMCompiler.JumpFalse: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_FALSE);
end;

procedure TBlaiseVMCompiler.JumpFalsePosition(const P: Integer);
begin
  GenJumpOffset(BLAISE_VM_JMP_FALSE, P);
end;

function TBlaiseVMCompiler.JumpCompared: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_CMP);
end;

function TBlaiseVMCompiler.JumpEqual: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_EQ);
end;

function TBlaiseVMCompiler.JumpNotEqual: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_NE);
end;

function TBlaiseVMCompiler.JumpGreater: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_GR);
end;

function TBlaiseVMCompiler.JumpLess: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_LE);
end;

function TBlaiseVMCompiler.JumpAssigned: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_ASSIGNED);
end;

function TBlaiseVMCompiler.JumpNotAssigned: Integer;
begin
  Result := GenJumpForward(BLAISE_VM_JMP_NOT_ASSIGNED);
end;

procedure TBlaiseVMCompiler.FlowExit;
begin
  WriteByte(BLAISE_VM_FLOW_EXIT);
end;

procedure TBlaiseVMCompiler.FlowBreak;
begin
  WriteByte(BLAISE_VM_FLOW_BREAK);
end;

procedure TBlaiseVMCompiler.FlowContinue;
begin
  WriteByte(BLAISE_VM_FLOW_CONTINUE);
end;

procedure TBlaiseVMCompiler.EnterLoopBlock(var BreakPos, ContinuePos: Integer);
begin
  WriteByte(BLAISE_VM_FLOW_ENTER_LOOP);
  BreakPos := FPos;
  WriteLongInt(BLAISE_VM_INVALID_REL_OFFSET);
  ContinuePos := FPos;
  WriteLongInt(BLAISE_VM_INVALID_REL_OFFSET);
end;

procedure TBlaiseVMCompiler.LeaveLoopBlock;
begin
  WriteByte(BLAISE_VM_FLOW_LEAVE_LOOP);
end;

procedure TBlaiseVMCompiler.SetBreakBlockPosition(const P: Integer);
begin
  SetIntegerAtOffset(P, FPos - P - Sizeof(LongInt));
end;

procedure TBlaiseVMCompiler.SetContinueBlockPosition(const P: Integer);
begin
  SetIntegerAtOffset(P, FPos - P - Sizeof(LongInt));
end;

procedure TBlaiseVMCompiler.FlowRaise;
begin
  WriteByte(BLAISE_VM_FLOW_RAISE);
end;

procedure TBlaiseVMCompiler.FlowReraise;
begin
  WriteByte(BLAISE_VM_FLOW_RERAISE);
end;

function TBlaiseVMCompiler.EnterTryFinallyBlock: Integer;
begin
  WriteByte(BLAISE_VM_FLOW_ENTER_TRY_FIN);
  Result := FPos;
  WriteLongInt(BLAISE_VM_INVALID_REL_OFFSET);
end;

procedure TBlaiseVMCompiler.LeaveTryFinallyBlock;
begin
  WriteByte(BLAISE_VM_FLOW_LEAVE_TRY_FIN);
end;

procedure TBlaiseVMCompiler.LeaveTryFinallyHandler;
begin
  WriteByte(BLAISE_VM_FLOW_END_TRY_FIN);
end;

procedure TBlaiseVMCompiler.SetFinallyBlockPosition(const P: Integer);
begin
  SetIntegerAtOffset(P, FPos - P - Sizeof(LongInt));
end;

function TBlaiseVMCompiler.EnterTryExceptBlock: Integer;
begin
  WriteByte(BLAISE_VM_FLOW_ENTER_TRY_EXCEPT);
  Result := FPos;
  WriteLongInt(BLAISE_VM_INVALID_REL_OFFSET);
end;

procedure TBlaiseVMCompiler.LeaveTryExceptBlock;
begin
  WriteByte(BLAISE_VM_FLOW_LEAVE_TRY_EXCEPT);
end;

procedure TBlaiseVMCompiler.LeaveTryExceptHandler;
begin
  WriteByte(BLAISE_VM_FLOW_END_TRY_EXCEPT);
end;

procedure TBlaiseVMCompiler.SetExceptBlockPosition(const P: Integer);
begin
  SetIntegerAtOffset(P, FPos - P - Sizeof(LongInt));
end;

procedure TBlaiseVMCompiler.AssignIdentifier(const Identifier: String);
begin
  WriteByte(BLAISE_VM_IDEN_ASSIGN);
  WritePackedString(Identifier);
end;

procedure TBlaiseVMCompiler.EvaluateUnique(const Identifier: String);
begin
  WriteByte(BLAISE_VM_IDEN_UNIQUE);
  WritePackedString(Identifier);
end;

procedure TBlaiseVMCompiler.EvaluateIdentifier(const Identifier: String);
begin
  WriteByte(BLAISE_VM_IDEN_EVAL);
  WritePackedString(Identifier);
end;

procedure TBlaiseVMCompiler.ExecuteIdentifier(const Identifier: String);
begin
  WriteByte(BLAISE_VM_IDEN_EXEC);
  WritePackedString(Identifier);
end;

procedure TBlaiseVMCompiler.SetIdentifierScope;
begin
  WriteByte(BLAISE_VM_IDEN_SCOPE);
end;

procedure TBlaiseVMCompiler.EvaluateIndexedIdentifier;
begin
  WriteByte(BLAISE_VM_IDEN_EVAL_IDX);
end;

procedure TBlaiseVMCompiler.ExecuteIndexedIdentifier;
begin
  WriteByte(BLAISE_VM_IDEN_EXEC_IDX);
end;

procedure TBlaiseVMCompiler.AssignIndexedIdentifier;
begin
  WriteByte(BLAISE_VM_IDEN_ASSIGN_IDX);
end;

procedure TBlaiseVMCompiler.EvaluateIdentifierCall(const Identifier: String);
begin
  WriteByte(BLAISE_VM_IDEN_EVAL_CALL);
  WritePackedString(Identifier);
end;

procedure TBlaiseVMCompiler.ExecuteIdentifierCall(const Identifier: String);
begin
  WriteByte(BLAISE_VM_IDEN_EXEC_CALL);
  WritePackedString(Identifier);
end;

procedure TBlaiseVMCompiler.EvaluateSelf;
begin
  WriteByte(BLAISE_VM_IDEN_SELF);
end;

procedure TBlaiseVMCompiler.SetInheritedScope;
begin
  WriteByte(BLAISE_VM_IDEN_SCOPE_INHERITED);
end;

procedure TBlaiseVMCompiler.CreateRational;
begin
  WriteByte(BLAISE_VM_CREATE_RATIONAL);
end;

procedure TBlaiseVMCompiler.CreateArray;
begin
  WriteByte(BLAISE_VM_CREATE_ARRAY);
end;

procedure TBlaiseVMCompiler.CreateDictionary;
begin
  WriteByte(BLAISE_VM_CREATE_DICT);
end;

procedure TBlaiseVMCompiler.Compare;
var F : Integer;
begin
  WriteByte(BLAISE_VM_EVAL_CMP);
  F := JumpCompared;
  WriteByte(BLAISE_VM_STACK_SWAP_TOP2);
  WriteByte(BLAISE_VM_EVAL_CMP);
  WriteByte(BLAISE_VM_STACK_SWAP_TOP2);
  WriteByte(BLAISE_VM_REVERSE_CMP);
  SetJumpPosition(F);
end;

procedure TBlaiseVMCompiler.UnOp(const Oper: Byte);
begin
  WriteByte(BLAISE_VM_POP_A);
  WriteByte(BLAISE_VM_EVAL_UNIQUE);
  WriteByte(Oper);
  WriteByte(BLAISE_VM_PUSH_A);
end;

procedure TBlaiseVMCompiler.CoerceUnOp(const Coerce, Oper: Byte);
var lDo : Integer;
begin
  WriteByte(Coerce);
  lDo := JumpAssigned;
  WriteByte(BLAISE_VM_LOAD_A_STACK0);
  WriteByte(BLAISE_VM_EVAL_DUP);
  SetJumpPosition(lDo);
  WriteByte(Oper);
  WriteByte(BLAISE_VM_POP);
  WriteByte(BLAISE_VM_PUSH_A);
end;

procedure TBlaiseVMCompiler.UnOpSqr;
begin
  CoerceUnOp(BLAISE_VM_EVAL_COERCE_SQR, BLAISE_VM_EVAL_SQR);
end;

procedure TBlaiseVMCompiler.UnOpSqrt;
begin
  CoerceUnOp(BLAISE_VM_EVAL_COERCE_SQRT, BLAISE_VM_EVAL_SQRT);
end;

procedure TBlaiseVMCompiler.UnOpExp;
begin
  CoerceUnOp(BLAISE_VM_EVAL_COERCE_EXP, BLAISE_VM_EVAL_EXP);
end;

procedure TBlaiseVMCompiler.UnOpLn;
begin
  CoerceUnOp(BLAISE_VM_EVAL_COERCE_LN, BLAISE_VM_EVAL_LN);
end;

procedure TBlaiseVMCompiler.UnOpSin;
begin
  CoerceUnOp(BLAISE_VM_EVAL_COERCE_SIN, BLAISE_VM_EVAL_SIN);
end;

procedure TBlaiseVMCompiler.UnOpCos;
begin
  CoerceUnOp(BLAISE_VM_EVAL_COERCE_COS, BLAISE_VM_EVAL_COS);
end;

procedure TBlaiseVMCompiler.UnOpNegate;
begin
  UnOp(BLAISE_VM_EVAL_NEGATE);
end;

procedure TBlaiseVMCompiler.UnOpAbs;
begin
  UnOp(BLAISE_VM_EVAL_ABS);
end;

procedure TBlaiseVMCompiler.UnOpInc;
begin
  UnOp(BLAISE_VM_EVAL_INC);
end;

procedure TBlaiseVMCompiler.UnOpDec;
begin
  UnOp(BLAISE_VM_EVAL_DEC);
end;

procedure TBlaiseVMCompiler.UnOpLogicalNOT;
begin
  UnOp(BLAISE_VM_EVAL_NOT);
end;

procedure TBlaiseVMCompiler.BinOp(const LCoerce, RCoerce, LOper, ROper: Byte);
var lDo, lRevDo, lFin : Integer;
begin
  WriteByte(LCoerce);
  lDo := JumpAssigned;
  WriteByte(BLAISE_VM_STACK_SWAP_TOP2);
  WriteByte(RCoerce);
  lRevDo := JumpAssigned;
  WriteByte(BLAISE_VM_LOAD_A_STACK0);
  WriteByte(BLAISE_VM_STACK_SWAP_TOP2);
  WriteByte(BLAISE_VM_EVAL_DUP);
  SetJumpPosition(lDo);
  WriteByte(LOper);
  lFin := Jump;
  SetJumpPosition(lRevDo);
  WriteByte(ROper);
  SetJumpPosition(lFin);
  WriteByte(BLAISE_VM_POP);
  WriteByte(BLAISE_VM_POP);
  WriteByte(BLAISE_VM_PUSH_A);
end;

procedure TBlaiseVMCompiler.BinOpAdd;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_ADD,
        BLAISE_VM_EVAL_R_COERCE_ADD,
        BLAISE_VM_EVAL_L_ADD,
        BLAISE_VM_EVAL_R_ADD);
end;

procedure TBlaiseVMCompiler.BinOpSubtract;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_SUB,
        BLAISE_VM_EVAL_R_COERCE_SUB,
        BLAISE_VM_EVAL_L_SUB,
        BLAISE_VM_EVAL_R_SUB);
end;

procedure TBlaiseVMCompiler.BinOpMultiply;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_MUL,
        BLAISE_VM_EVAL_R_COERCE_MUL,
        BLAISE_VM_EVAL_L_MUL,
        BLAISE_VM_EVAL_R_MUL);
end;

procedure TBlaiseVMCompiler.BinOpDivide;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_DIV,
        BLAISE_VM_EVAL_R_COERCE_DIV,
        BLAISE_VM_EVAL_L_DIV,
        BLAISE_VM_EVAL_R_DIV);
end;

procedure TBlaiseVMCompiler.BinOpPower;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_POWER,
        BLAISE_VM_EVAL_R_COERCE_POWER,
        BLAISE_VM_EVAL_L_POWER,
        BLAISE_VM_EVAL_R_POWER);
end;

procedure TBlaiseVMCompiler.BinOpIntegerDivide;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_IDIV,
        BLAISE_VM_EVAL_R_COERCE_IDIV,
        BLAISE_VM_EVAL_L_IDIV,
        BLAISE_VM_EVAL_R_IDIV);
end;

procedure TBlaiseVMCompiler.BinOpModulo;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_MOD,
        BLAISE_VM_EVAL_R_COERCE_MOD,
        BLAISE_VM_EVAL_L_MOD,
        BLAISE_VM_EVAL_R_MOD);
end;

procedure TBlaiseVMCompiler.BinOpLogicalAND;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_AND,
        BLAISE_VM_EVAL_R_COERCE_AND,
        BLAISE_VM_EVAL_L_AND,
        BLAISE_VM_EVAL_R_AND);
end;

procedure TBlaiseVMCompiler.BinOpLogicalOR;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_OR,
        BLAISE_VM_EVAL_R_COERCE_OR,
        BLAISE_VM_EVAL_L_OR,
        BLAISE_VM_EVAL_R_OR);
end;

procedure TBlaiseVMCompiler.BinOpLogicalXOR;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_XOR,
        BLAISE_VM_EVAL_R_COERCE_XOR,
        BLAISE_VM_EVAL_L_XOR,
        BLAISE_VM_EVAL_R_XOR);
end;

procedure TBlaiseVMCompiler.BinOpBitwiseSHL;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_SHL,
        BLAISE_VM_EVAL_R_COERCE_SHL,
        BLAISE_VM_EVAL_L_SHL,
        BLAISE_VM_EVAL_R_SHL);
end;

procedure TBlaiseVMCompiler.BinOpBitwiseSHR;
begin
  BinOp(BLAISE_VM_EVAL_L_COERCE_SHR,
        BLAISE_VM_EVAL_R_COERCE_SHR,
        BLAISE_VM_EVAL_L_SHR,
        BLAISE_VM_EVAL_R_SHR);
end;

procedure TBlaiseVMCompiler.NamedDelete;
begin
  WriteByte(BLAISE_VM_NAMED_DELETE);
end;

procedure TBlaiseVMCompiler.NamedAssign;
begin
  WriteByte(BLAISE_VM_NAMED_ASSIGN);
end;

procedure TBlaiseVMCompiler.NamedExists;
begin
  WriteByte(BLAISE_VM_NAMED_EXISTS);
end;

procedure TBlaiseVMCompiler.NamedGet;
begin
  WriteByte(BLAISE_VM_NAMED_GET);
end;

procedure TBlaiseVMCompiler.NamedDirectory;
begin
  WriteByte(BLAISE_VM_NAMED_DIR);
end;

procedure TBlaiseVMCompiler.SetModuleType(const ModuleTypeID: Byte);
begin
  WriteByte(BLAISE_VM_MODULE_TYPE_ID);
  WriteByte(ModuleTypeID);
end;

procedure TBlaiseVMCompiler.UseUnit(const UnitName: String);
begin
  WriteByte(BLAISE_VM_USE_UNIT);
  WritePackedString(UnitName);
end;

procedure TBlaiseVMCompiler.Declare(const Decl: AScopeFieldDefinitionArray);
begin
  WriteByte(BLAISE_VM_DECLARATION);
  StreamOutFieldDefinitions(self, Decl);
end;

procedure TBlaiseVMCompiler.TextOut;
begin
  WriteByte(BLAISE_VM_TEXTOUT);
end;

procedure TBlaiseVMCompiler.EnterFunctionScope;
begin
  WriteByte(BLAISE_VM_ENTER_FUNC_SCOPE);
end;

procedure TBlaiseVMCompiler.LeaveFunctionScope;
begin
  WriteByte(BLAISE_VM_LEAVE_FUNC_SCOPE);
end;

procedure TBlaiseVMCompiler.StartTask;
begin
  WriteByte(BLAISE_VM_START_TASK);
end;

procedure TBlaiseVMCompiler.TaskReturn;
begin
  WriteByte(BLAISE_VM_TASK_RETURN);
end;

procedure TBlaiseVMCompiler.Import(const Identifier, UnitName: String);
begin
  WriteByte(BLAISE_VM_IMPORT);
  WritePackedString(Identifier);
  WritePackedString(UnitName);
end;



end.

