{                                                                              }
{                         Blaise Virtual Machine v0.07                         }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{                  Its original file name is cBlaiseVM.pas                     }
{                                                                              }
{ Description:                                                                 }
{   This unit implements the Blaise virtual machine.                           }
{                                                                              }
{ Revision history:                                                            }
{   28/03/2003  0.01  Initial version of TBlaiseVM.                            }
{   04/04/2003  0.02  Added TBlaiseVMProcess from TBlaiseVMThread.             }
{   05/04/2003  0.03  Added TBlaiseVMProgram.                                  }
{   07/04/2003  0.04  Relocatable code.                                        }
{   08/04/2003  0.05  Added support for language tasks.                        }
{   30/05/2003  0.06  Added exceptions.                                        }
{   05/06/2003  0.07  Inner-loop optimizations.                                }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseVM;

interface

uses
  { Delphi }
  Windows,
  SysUtils,

  { Fundamentals }
  cUtils,
  cReaders,
  cArrays,
  cThreads,
  cMicroThreads,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructsCollections,
  cBlaiseVMTypes,
  cBlaiseVMCompiler;



{                                                                              }
{ TBlaiseVMStack                                                               }
{   Virtual machine's stack.                                                   }
{                                                                              }
type
  TBlaiseVMStack = class(TObjectArray)
  protected
    procedure StackEmptyError;
    procedure SetPosition(const Position: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    // Stack position
    property  Position: Integer read FCount write SetPosition;

    // Push and Pop
    procedure Push(const V: TObject);
    procedure PushInteger(const V: Int64);
    procedure PushList(const V: Array of TObject);
    function  Pop: TObject;
    function  PopInteger: Int64;
    function  PopList: ObjectArray;

    // Stack peek
    function  Top: TObject;
    function  BelowTop: TObject;
    procedure Top2(var A, B: TObject);

    // Special operations
    procedure SwapTop2;
  end;



{                                                                              }
{ AFlowControlItem                                                             }
{                                                                              }
type
  AFlowControlItem = class
  end;

  TLoopControlItem = class(AFlowControlItem)
    BreakPos    : Integer;
    ContinuePos : Integer;
  end;

  AExceptionControlItem = class(AFlowControlItem)
    CallStackPos : Integer;
    StackPos     : Integer;
  end;

  TTryFinallyControlItem = class(AExceptionControlItem)
    FinallyPos : Integer;
  end;

  TTryExceptControlItem = class(AExceptionControlItem)
    ExceptPos : Integer;
  end;



{                                                                              }
{ TBlaiseVMProcess                                                             }
{   An execution process in the virtual machine.                               }
{                                                                              }
{   Every process has its own stack, registers and micro-thread. Processes     }
{   frequently switch context to the virtual machine scheduler to facilitate   }
{   multi-tasking.                                                             }
{                                                                              }
type
  TBlaiseVMThread = class;
  TProcessWaitOp = (woHasNext, woNext);
  TBlaiseVMProcess = class(AVirtualMachineProcess)
  protected
    FVMThread     : TBlaiseVMThread;
    FScope        : ABlaiseType;
    FSwitcher     : TWintelSwitcher;
    FScheduler    : TMicroThreadHandle;
    FMicroThread  : TMicroThreadHandle;

    FStack        : TBlaiseVMStack;
    FCallStack    : TObjectArray;
    FFlowStack    : TObjectArray;
    FRegBool      : Boolean;
    FRegCmp       : TCompareResult;
    FRegUTF8      : String;
    FRegInt       : Int64;
    FRegFloat     : Extended;
    FRegA         : TObject;      // Accumulator
    FRegF         : AFunction;    // Function
    FIdenScope    : ABlaiseType;
    FExceptStack  : TTArray;

    FTerminated   : Boolean;
    FExceptionObj : TObject;
    FEnterCount   : Integer;
    FPaused       : Boolean;
    FWaitedByOp   : TProcessWaitOp;
    FWaitedBy     : TBlaiseVMProcess;
    FHasRetVal    : Boolean;

    function  GetAddress: Pointer;

    procedure SetRegA(const A: TObject);
    procedure SetRegF(const F: AFunction);

    procedure ScopeCall(const Scope: ABlaiseType;
              const Func: AFunction; const Address: Pointer;
              const Parameters: Array of TObject;
              const Continuation: TBlaiseVMContinuation); override;

    procedure LOAD_CMP_A;

    procedure POP_A;

    procedure EVAL_COERCE_SIMPLE(const Identifier, TypeName: String);
    procedure EVAL_CMP;
    procedure EVAL_CMP_Ret;
    procedure EVAL_CMP_Rev;
    procedure EVAL_CMP_Rev_Ret;
    procedure EVAL_ITERATE;
    procedure EVAL_HASNEXT;
    procedure EVAL_NEXT;
    procedure EVAL_IS_TYPE;
    procedure EVAL_IS_IN;
    procedure EVAL_APPEND_LIST;

    procedure EVAL_L_COERCE(const Operation: TBinaryMathOperation);
    procedure EVAL_R_COERCE(const Operation: TBinaryMathOperation);

    procedure RET;
    procedure JMP_Conditional(const Condition: Boolean);

    procedure FLOW_EXIT;

    function  GetLoopControlItem: TLoopControlItem;
    procedure FLOW_BREAK;
    procedure FLOW_CONTINUE;
    procedure FLOW_ENTER_LOOP;
    procedure FLOW_LEAVE_LOOP;
    procedure FLOW_RAISE;
    procedure FLOW_RERAISE;
    procedure FLOW_ENTER_TRY_FIN;
    procedure FLOW_LEAVE_TRY_FIN;
    procedure FLOW_END_TRY_FIN;
    procedure FLOW_ENTER_TRY_EXCEPT;
    procedure FLOW_LEAVE_TRY_EXCEPT;
    procedure FLOW_END_TRY_EXCEPT;

    procedure IdenCall(const Identifier: String;
              const CallRequired, IsCall: Boolean);

    procedure IDEN_UNIQUE;
    procedure IDEN_EVAL;
    procedure IDEN_EXEC;
    procedure IDEN_ASSIGN;
    procedure IDEN_SCOPE;
    procedure IDEN_EVAL_IDX;
    procedure IDEN_EVAL_IDX_Fin;
    procedure IDEN_EXEC_IDX;
    procedure IDEN_ASSIGN_IDX;
    procedure IDEN_EVAL_CALL;
    procedure IDEN_EXEC_CALL;
    procedure IDEN_SELF;
    procedure IDEN_SCOPE_INHERITED;

    procedure CREATE_RATIONAL;
    procedure CREATE_ARRAY;
    procedure CREATE_DICT;

    procedure NAMED_DELETE;
    procedure NAMED_ASSIGN;
    procedure NAMED_EXISTS;
    procedure NAMED_GET;
    procedure NAMED_DIR;

    procedure USE_UNIT(const UnitName: String);
    procedure DECLARATION;
    procedure TEXTOUT;
    procedure ENTER_FUNC_SCOPE;
    procedure LEAVE_FUNC_SCOPE;
    procedure START_TASK;
    procedure TASK_RETURN;
    procedure IMPORT;

    procedure CreateMicroThread;
    procedure DeleteMicroThread;

  public
    constructor Create(const VMThread: TBlaiseVMThread;
                const Address: Pointer; const Size: Integer;
                const Scope: ABlaiseType);
    destructor Destroy; override;

    procedure Run;
    procedure Terminate;
    property  Terminated: Boolean read FTerminated;

    procedure SetResult(const Value: TObject); override;

    property  Stack: TBlaiseVMStack read FStack;
    property  RegBool: Boolean read FRegBool;
    property  RegCmp: TCompareResult read FRegCmp;
    property  RegUTF8: String read FRegUTF8;
    property  RegInt: Int64 read FRegInt;
    property  RegFloat: Extended read FRegFloat;
    property  RegA: TObject read FRegA;
    property  ExceptionObject: TObject read FExceptionObj;

    function  ReleaseRegA: TObject;
    function  ReleaseExceptionObject: TObject;
  end;



{                                                                              }
{ TBliaseVMThread                                                              }
{   A thread in the Blaise virtual machine.                                    }
{                                                                              }
{   A VM thread manages multiple VM processes using micro-threads.             }
{                                                                              }

  TBlaiseVMThread = class(AVirtualMachine)
  protected
    FThreadId    : DWORD;
    FScope       : ABlaiseType;
    FData        : String;
    FUserThread  : TThreadEx;
    FSwitcher    : TWintelSwitcher;
    FScheduler   : TMicroThreadHandle;
    FProcesses   : TObjectArray;
    FRunning     : Boolean;
    FTerminated  : Boolean;

    function  GetProcessCount: Integer;
    function  AddProcess(const Address: Pointer; const Size: Integer;
              const Scope: ABlaiseType): TBlaiseVMProcess;
    procedure DeleteProcess(const Process: TBlaiseVMProcess);

  public
    constructor Create(const Scope: ABlaiseType; const Data: String;
                const UserThread: TThreadEx);
    destructor Destroy; override;

    property  Scope: ABlaiseType read FScope;
    property  Data: String read FData;
    property  ThreadId: DWORD read FThreadId;
    property  ProcessCount: Integer read GetProcessCount;
    property  Running: Boolean read FRunning;
    property  Terminated: Boolean read FTerminated;

    procedure Run;
    function  StartUserProcess(const Address: Pointer;
              const Scope: ABlaiseType): TBlaiseVMProcess;
    procedure Terminate;

    function  CallFunction(const Func: AFunction; const Address: Pointer;
              const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    procedure ThreadWouldBlock; override;
  end;
  EBlaiseVM = class(EVirtualMachine);



{                                                                              }
{ TBlaiseVMProgram                                                             }
{   A program in the Blaise virtual machine.                                   }
{                                                                              }
{   A VM program manages multiple VM threads using system threads.             }
{                                                                              }
type
  TBlaiseVMProgram = class(AVirtualMachine)
  protected
    FLock       : TRTLCriticalSection;
    FScope      : ABlaiseType;
    FData       : String;
    FUserThread : TThreadEx;
    FMainThread : TBlaiseVMThread;
    FThreads    : TObjectArray;
    FRunning    : Boolean;

    procedure Lock;
    procedure Unlock;

    procedure AddUserThread(const Thread: TBlaiseVMThread);
    procedure DeleteThread(const Thread: TBlaiseVMThread);

  public
    constructor Create(const Scope: ABlaiseType; const Data: String;
                const UserThread: TThreadEx);
    destructor Destroy; override;

    property  Scope: ABlaiseType read FScope;
    property  Data: String read FData;
    property  Running: Boolean read FRunning;
    function  GetThreadById(const ThreadId: DWORD): TBlaiseVMThread;

    procedure Run;
    procedure StartUserThread(const Address: Integer);
    function  CallFunction(const Func: AFunction; const Address: Pointer;
              const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    procedure Terminate;
  end;



{                                                                              }
{ TBlaiseVM                                                                    }
{   The Blaise virtual machine.                                                }
{                                                                              }
{   A VM manages multiple VM programs using system threads.                    }
{                                                                              }
type
  TBlaiseVM = class(AVirtualMachine)
  protected
    FLock        : TRTLCriticalSection;
    FMainProgram : TBlaiseVMProgram;
    FPrograms    : TObjectArray;
    FRunning     : Boolean;

    procedure Lock;
    procedure Unlock;

    procedure AddUserProgram(const Prog: TBlaiseVMProgram);
    procedure DeleteProgram(const Prog: TBlaiseVMProgram);
    function  GetCurrentThread: TBlaiseVMThread;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Run(const Scope: ABlaiseType; const Data: String);
    procedure StartUserProgram(const Scope: ABlaiseType; const Data: String);
    function  CallFunction(const Func: AFunction; const Address: Pointer;
              const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
    procedure ThreadWouldBlock; override;
    procedure Terminate;
  end;



{                                                                              }
{ Global virtual machine lock                                                  }
{                                                                              }
procedure BlaiseVMLock;
procedure BlaiseVMUnlock;



implementation

uses
  { Fundamentals }
  cStrings,
  cWriters,
  cTypes,
  cDictionaries,
  cRational,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructs,
  cBlaiseStructsSimple,
  cBlaiseStructsObject,
  cBlaiseStructsCode;



{                                                                              }
{ TBlaiseVMStack                                                               }
{                                                                              }
constructor TBlaiseVMStack.Create;
begin
  inherited Create(nil, False);
end;

destructor TBlaiseVMStack.Destroy;
begin
  SetPosition(0);  // Release references to items still on stack
  inherited Destroy;
end;

procedure TBlaiseVMStack.StackEmptyError;
begin
  raise EBlaiseVM.Create('Stack empty');
end;

procedure TBlaiseVMStack.SetPosition(const Position: Integer);
var I : Integer;
begin
  // Can only set stack to lower position
  if (Position < 0) or (Position > FCount) then
    raise EBlaiseVM.Create('Invalid stack position');
  // Release references and set new position
  For I := FCount - 1 downto Position do
    ObjectReleaseReferenceAndNil(FData[I]);
  SetCount(Position);
end;

procedure TBlaiseVMStack.Push(const V: TObject);
var L : Integer;
begin
  L := FCount;
  SetCount(L + 1);
  ObjectAddReference(V);  // Add reference for stack
  FData[L] := V;
end;

function TBlaiseVMStack.Pop: TObject;
var L : Integer;
begin
  L := FCount;
  if L <= 0 then
    StackEmptyError;
  Dec(L);
  Result := FData[L];  // Caller must release reference
  SetCount(L);
end;

procedure TBlaiseVMStack.PushInteger(const V: Int64);
begin
  Push(TTInteger.Create(V));  // Push integer object
end;

function TBlaiseVMStack.PopInteger: Int64;
var V : TObject;
begin
  V := Pop;
  try
    Result := SimpleGetAsInteger(V);
  finally
    ObjectReleaseReference(V);
  end;
end;

procedure TBlaiseVMStack.PushList(const V: Array of TObject);
var I, L, P : Integer;
    F       : TObject;
begin
  L := Length(V);
  // Push items from left to right
  if L > 0 then
    begin
      P := FCount;
      SetCount(P + L);
      For I := 0 to L - 1 do
        begin
          F := V[I];
          ObjectAddReference(F);
          FData[P] := F;
          Inc(P);
        end;
    end;
  // Push item count
  PushInteger(L);
end;

function TBlaiseVMStack.PopList: ObjectArray;
var I, L : Integer;
begin
  L := PopInteger;
  SetLength(Result, L);
  For I := 1 to L do
    Result[L - I] := Pop;
end;

function TBlaiseVMStack.Top: TObject;
var L : Integer;
begin
  L := FCount;
  if L <= 0 then
    StackEmptyError;
  Result := FData[L - 1];
end;

function TBlaiseVMStack.BelowTop: TObject;
var L : Integer;
begin
  L := FCount;
  if L < 2 then
    StackEmptyError;
  Result := FData[L - 2];
end;

procedure TBlaiseVMStack.Top2(var A, B: TObject);
var L : Integer;
begin
  L := FCount;
  if L < 2 then
    StackEmptyError;
  A := FData[L - 2];
  B := FData[L - 1];
end;

procedure TBlaiseVMStack.SwapTop2;
var L : Integer;
    A : TObject;
begin
  L := FCount;
  if L < 2 then
    StackEmptyError;
  A := FData[L - 1];
  FData[L - 1] := FData[L - 2];
  FData[L - 2] := A;
end;



{                                                                              }
{ TCallStackItem                                                               }
{                                                                              }
type
  TCallStackItem = class
  protected
    Data         : Pointer;
    Size         : Integer;
    Pos          : Integer;
    Scope        : ABlaiseType;
    Func         : AFunction;
    Continuation : TBlaiseVMContinuation;

  public
    constructor Create(const Data: Pointer; const Size, Pos: Integer;
                const Scope: ABlaiseType; const Func: AFunction;
                const Continuation: TBlaiseVMContinuation);
  end;

constructor TCallStackItem.Create(const Data: Pointer; const Size, Pos: Integer;
    const Scope: ABlaiseType; const Func: AFunction;
    const Continuation: TBlaiseVMContinuation);
begin
  inherited Create;
  self.Data := Data;
  self.Size := Size;
  self.Pos := Pos;
  self.Scope := Scope;
  self.Func := Func;
  self.Continuation := Continuation;
end;




{                                                                              }
{ TTaskInstance                                                                }
{   Task instance data structure.                                              }
{                                                                              }
type
  TTaskInstance = class(ABlaiseType)
  protected
    FProcess : TBlaiseVMProcess;

  public
    constructor Create(const Process: TBlaiseVMProcess);
    destructor Destroy; override;

    property  Process: TBlaiseVMProcess read FProcess;
  end;

constructor TTaskInstance.Create(const Process: TBlaiseVMProcess);
begin
  inherited Create;
  FProcess := Process;
end;

destructor TTaskInstance.Destroy;
begin
  // Todo: Delete process when task becomes unreferenced
  inherited Destroy;
end;




{                                                                              }
{ TBlaiseVMProcess                                                             }
{                                                                              }
constructor TBlaiseVMProcess.Create(const VMThread: TBlaiseVMThread;
    const Address: Pointer; const Size: Integer;
    const Scope: ABlaiseType);
begin
  Assert(Assigned(VMThread));
  Assert(Assigned(Address));
  inherited Create(Address, Size);
  FVMThread := VMThread;
  FMicroThread := InvalidMicroThreadHandle;
  FScope := Scope;
  FSwitcher := VMThread.FSwitcher;
  FScheduler := VMThread.FScheduler;
  FStack := TBlaiseVMStack.Create;
  FCallStack := TObjectArray.Create(nil, True);
  FRegCmp := crUndefined;
  FFlowStack := TObjectArray.Create(nil, True);
  FExceptStack := TTArray.Create(nil);
  CreateMicroThread;
end;

destructor TBlaiseVMProcess.Destroy;
begin
  DeleteMicroThread;
  ObjectReleaseReferenceAndNil(FRegA);
  ObjectReleaseReferenceAndNil(FRegF);
  FreeAndNil(FExceptStack);
  FreeAndNil(FFlowStack);
  FreeAndNil(FCallStack);
  FreeAndNil(FStack);
  FreeAndNil(FExceptionObj);
  inherited Destroy;
end;

function TBlaiseVMProcess.GetAddress: Pointer;
var P : PChar;
begin
  P := FData;
  Inc(P, FPos);
  Result := P;
end;

procedure TBlaiseVMProcess.SetRegA(const A: TObject);
begin
  if A = FRegA then
    exit;
  ObjectAddReference(A);
  ObjectReleaseReference(FRegA);
  FRegA := A;
end;

procedure TBlaiseVMProcess.SetRegF(const F: AFunction);
begin
  if F = FRegF then
    exit;
  ObjectAddReference(F);
  ObjectReleaseReference(FRegF);
  FRegF := F;
end;

// Entry point for VM code that calls Blaise code
procedure TBlaiseVMProcess.ScopeCall(const Scope: ABlaiseType;
    const Func: AFunction; const Address: Pointer;
    const Parameters: Array of TObject;
    const Continuation: TBlaiseVMContinuation);
begin
  Assert(Assigned(Address));
  // Push call stack item
  FCallStack.AppendItem(TCallStackItem.Create(FData, FSize, FPos, FScope, FRegF,
      Continuation));
  // Set state for call
  FStack.PushList(Parameters);
  FScope := Scope;
  SetRegF(Func);
  JumpAddress(Address);
end;

procedure TBlaiseVMProcess.LOAD_CMP_A;
begin
  FRegCmp := IntegerToCompareResult(SimpleGetAsInteger(FRegA));
end;

procedure TBlaiseVMProcess.POP_A;
var V : TObject;
begin
  V := FStack.Pop;
  ObjectReleaseReference(FRegA);
  FRegA := V;
end;

procedure TBlaiseVMProcess.EVAL_COERCE_SIMPLE(const Identifier, TypeName: String);
begin
  if FRegA is ASimpleType then
    exit;
  if FRegA is ABlaiseObject then
    ScopeEval(ABlaiseType(FRegA), Identifier, [], nil) else
  if not (FRegA is ABlaiseType) then
    ObjectConvertToError(FRegA, TypeName);
end;

procedure TBlaiseVMProcess.EVAL_CMP;
var A, B : TObject;
begin
  FStack.Top2(A, B);
  if A = B then
    FRegCmp := crEqual else
  if A is ABlaiseObject then
    ScopeEval(ABlaiseObject(A), '__Compare__', [B], EVAL_CMP_Ret) else
  if A is ABlaiseType then
    FRegCmp := ABlaiseType(A).Compare(B)
  else
    EVAL_CMP_Rev;
end;

procedure TBlaiseVMProcess.EVAL_CMP_Ret;
begin
  LOAD_CMP_A;
  if FRegCmp = crUndefined then
    EVAL_CMP_Rev;
end;

procedure TBlaiseVMProcess.EVAL_CMP_Rev;
var A, B : TObject;
begin
  FStack.Top2(A, B);
  if B is ABlaiseObject then
    ScopeEval(ABlaiseObject(B), '__Compare__', [A], EVAL_CMP_Rev_Ret) else
  if B is ABlaiseType then
    FRegCmp := ReverseCompareResult(ABlaiseType(B).Compare(A))
  else
    FRegCmp := crUndefined;
end;

procedure TBlaiseVMProcess.EVAL_CMP_Rev_Ret;
begin
  LOAD_CMP_A;
  FRegCmp := ReverseCompareResult(FRegCmp);
end;

procedure TBlaiseVMProcess.EVAL_ITERATE;
var V : TObject;
begin
  V := FStack.Top;
  if V is TTaskInstance then
    SetRegA(V)
  else
    ObjectIterateVM(self, V);
end;

procedure TBlaiseVMProcess.EVAL_HASNEXT;
var V : TObject;
    P : TBlaiseVMProcess;
begin
  V := FStack.Top;
  if V is TTaskInstance then // todo: get TTaskInstance an iterator
    begin
      P := TTaskInstance(V).Process;
      if P.FHasRetVal then
        SetRegA(GetImmutableBoolean(True)) else
      if P.Terminated then
        SetRegA(GetImmutableBoolean(False))
      else
        begin
          Assert(P.FPaused);
          P.FWaitedByOp := woHasNext;
          P.FWaitedBy := self;
          P.FPaused := False;
          FPaused := True;
        end;
    end
  else
    ObjectHasNextVM(self, FStack.Top);
end;

procedure TBlaiseVMProcess.EVAL_NEXT;
var V : TObject;
    P : TBlaiseVMProcess;
begin
  V := FStack.Top;
  if V is TTaskInstance then
    begin
      P := TTaskInstance(V).Process;
      if P.FHasRetVal then
        begin
          SetRegA(P.FRegA);
          P.FHasRetVal := False;
        end else
      if P.Terminated then
        raise EBlaiseVM.Create('Next past EOF')
      else
        begin
          Assert(P.FPaused);
          P.FWaitedByOp := woNext;
          P.FWaitedBy := self;
          P.FPaused := False;
          FPaused := True;
        end;
    end
  else
    ObjectNextVM(self, FStack.Top);
end;

procedure TBlaiseVMProcess.EVAL_IS_TYPE;
var A, B : TObject;
begin
  FStack.Top2(A, B);
  if not (B is ATypeDefinition) then
    raise EBlaiseVM.Create('Not a type');
  FRegBool := ATypeDefinition(B).IsType(A);
end;

procedure TBlaiseVMProcess.EVAL_IS_IN;
var A, B : TObject;
begin
  FStack.Top2(A, B);
  ObjectIsInVM(self, A, B);
end;

procedure TBlaiseVMProcess.EVAL_APPEND_LIST;
var A, B : TObject;
begin
  FStack.Top2(A, B);
  ObjectAppendListVM(self, A, B);
end;

procedure TBlaiseVMProcess.EVAL_L_COERCE(const Operation: TBinaryMathOperation);
var A, B : TObject;
begin
  FStack.Top2(A, B);
  ObjectBinaryOpLeftCoerceVM(self, Operation, A, B);
end;

procedure TBlaiseVMProcess.EVAL_R_COERCE(const Operation: TBinaryMathOperation);
var A, B : TObject;
begin
  FStack.Top2(A, B);
  ObjectBinaryOpRightCoerceVM(self, Operation, A, B);
end;

procedure TBlaiseVMProcess.RET;
var L : Integer;
    R : TBlaiseVMContinuation;
    C : TCallStackItem;
begin
  // Process terminates if the call stack is empty
  L := FCallStack.Count;
  if L = 0 then
    begin
      Terminate;
      exit;
    end;
  // Restore state from call stack
  C := TCallStackItem(FCallStack[L - 1]);
  FData := C.Data;
  FSize := C.Size;
  FPos := C.Pos;
  FScope := C.Scope;
  SetRegF(C.Func);
  R := C.Continuation;
  // Pop call stack item
  FCallStack.Count := L - 1;
  // Set new execution address and call continuation
  if Assigned(R) then
    R;
end;

procedure TBlaiseVMProcess.JMP_Conditional(const Condition: Boolean);
var I : Integer;
begin
  I := ReadLongInt;
  if Condition then
    JumpRelative(I);
end;

// Entry point for Blaise code that evaluates identifiers
procedure TBlaiseVMProcess.IdenCall(const Identifier: String;
    const CallRequired, IsCall: Boolean);
var S, P : ABlaiseType;
    T    : TBlaiseFieldType;
    V    : TObject;
    A    : Pointer;
    R    : ObjectArray;
    L    : Integer;
begin
  R := nil;
  if Assigned(FIdenScope) then
    S := FIdenScope else
    S := FScope;
  try
    V := S.GetValue(Identifier, True, P, T);
    if not Assigned(P) then
      raise EBlaiseVM.Create('Identifier not defined: ' + Identifier);
    if T = bfCall then
      begin
        R := FStack.PopList;
        try
          SetRegA(P.CallField(Identifier, R));
        finally
          ObjectsReleaseReference(R);
        end;
      end else
    if V is AFunction then
      begin
        A := AFunction(V).GetMachineCode;
        if not Assigned(A) then
          try
            R := FStack.PopList;
            SetRegA(AFunction(V).Call(S, R));
          finally
            ObjectsReleaseReference(R);
            ObjectReleaseUnreferenced(V);
          end
        else
          begin
            FCallStack.AppendItem(TCallStackItem.Create(FData, FSize, FPos,
                FScope, FRegF, nil));
            FScope := S;
            SetRegF(AFunction(V));
            JumpAddress(A);
          end;
      end else
    if IsCall and (V is ATypeDefinition) then
      begin
        R := FStack.PopList;
        try
          L := Length(R);
          if L > 1 then
            raise EBlaiseVM.Create('Invalid coerce call');
          if L = 0 then
            SetRegA(ATypeDefinition(V).CreateTypeInstance)
          else
            SetRegA(ATypeDefinition(V).Coerce(R[0]));
        finally
          ObjectsReleaseReference(R);
        end;
      end
    else
      begin
        ObjectsReleaseReference(FStack.PopList);
        if CallRequired then
          raise EBlaiseVM.Create('Not a function: ' + Identifier);
        SetRegA(V);
      end;
  finally
    if Assigned(FIdenScope) then
      ObjectReleaseReferenceAndNil(FIdenScope);
  end;
end;

procedure TBlaiseVMProcess.FLOW_EXIT;
begin
  //
  RET;
end;

function TBlaiseVMProcess.GetLoopControlItem: TLoopControlItem;
var L : Integer;
    V : TObject;
begin
  L := FFlowStack.Count;
  if L = 0 then
    raise EBlaiseVM.Create('No loop flow control');
  V := FFlowStack[L - 1];
  if not (V is TLoopControlItem) then
    raise EBlaiseVM.Create('Invalid flow control');
  Result := TLoopControlItem(V);
end;

procedure TBlaiseVMProcess.FLOW_BREAK;
var I : TLoopControlItem;
begin
  I := GetLoopControlItem;
  JumpOffset(I.BreakPos);
end;

procedure TBlaiseVMProcess.FLOW_CONTINUE;
var I : TLoopControlItem;
begin
  I := GetLoopControlItem;
  JumpOffset(I.ContinuePos);
end;

procedure TBlaiseVMProcess.FLOW_ENTER_LOOP;
var B, C : Integer;
    I    : TLoopControlItem;
begin
  B := ReadLongInt;
  C := ReadLongInt;
  I := TLoopControlItem.Create;
  I.BreakPos := FPos + B - 4;
  I.ContinuePos := FPos + C;
  FFlowStack.AppendItem(I);
end;

procedure TBlaiseVMProcess.FLOW_LEAVE_LOOP;
var L : Integer;
begin
  L := FFlowStack.Count;
  if L = 0 then
    raise EBlaiseVM.Create('Flow stack empty');
  FFlowStack.Count := L - 1;
end;

procedure TBlaiseVMProcess.FLOW_RAISE;
var L, I : Integer;
    V    : AFlowControlItem;
    E    : TObject;
begin
  E := FStack.Pop;
  FExceptStack.Append(E);
  L := FFlowStack.Count;
  I := L - 1;
  While I >= 0 do
    begin
      V := AFlowControlItem(FFlowStack[I]);
      if V is AExceptionControlItem then
        begin
          While FCallStack.Count > AExceptionControlItem(V).CallStackPos do
            RET;
          FStack.Position := AExceptionControlItem(V).StackPos;
          if V is TTryFinallyControlItem then
            JumpOffset(TTryFinallyControlItem(V).FinallyPos) else
          if V is TTryExceptControlItem then
            JumpOffset(TTryExceptControlItem(V).ExceptPos);
          FFlowStack.Count := I;
          exit;
        end;
      FFlowStack.Count := I;
      Dec(I);
    end;
  raise EBlaiseVM.Create('Exception: ' + ObjectGetAsString(E));
end;

procedure TBlaiseVMProcess.FLOW_RERAISE;
var L : Integer;
begin
  L := FExceptStack.Count;
  if L = 0 then
    raise EBlaiseVM.Create('No exception');
  FStack.Push(FExceptStack[L - 1]);
  FExceptStack.Count := L - 1;
  FLOW_RAISE;
end;

procedure TBlaiseVMProcess.FLOW_ENTER_TRY_FIN;
var F : Integer;
    I : TTryFinallyControlItem;
begin
  F := ReadLongInt;
  I := TTryFinallyControlItem.Create;
  I.FinallyPos := FPos + F;
  I.StackPos := FStack.Position;
  I.CallStackPos := FCallStack.Count;
  FFlowStack.AppendItem(I);
end;

procedure TBlaiseVMProcess.FLOW_LEAVE_TRY_FIN;
var L : Integer;
begin
  L := FFlowStack.Count;
  if L = 0 then
    raise EBlaiseVM.Create('Flow stack empty');
  FFlowStack.Count := L - 1;
end;

procedure TBlaiseVMProcess.FLOW_END_TRY_FIN;
begin
  if FExceptStack.Count > 0 then
    FLOW_RERAISE;
end;

procedure TBlaiseVMProcess.FLOW_ENTER_TRY_EXCEPT;
var F : Integer;
    I : TTryExceptControlItem;
begin
  F := ReadLongInt;
  I := TTryExceptControlItem.Create;
  I.ExceptPos := FPos + F;
  I.StackPos := FStack.Position;
  I.CallStackPos := FCallStack.Count;
  FFlowStack.AppendItem(I);
end;

procedure TBlaiseVMProcess.FLOW_LEAVE_TRY_EXCEPT;
var L : Integer;
begin
  L := FFlowStack.Count;
  if L = 0 then
    raise EBlaiseVM.Create('Flow stack empty');
  FFlowStack.Count := L - 1;
end;

procedure TBlaiseVMProcess.FLOW_END_TRY_EXCEPT;
var L : Integer;
begin
  L := FExceptStack.Count;
  if L = 0 then
    raise EBlaiseVM.Create('No exception');
  FExceptStack.Count := L - 1;
end;

procedure TBlaiseVMProcess.IDEN_UNIQUE;
var S : ABlaiseType;
    T : TBlaiseFieldType;
    V : TObject;
begin
  V := FScope.GetValue(ReadPackedString, True, S, T);
  Assert(Assigned(S));
  if T <> bfObject then
    raise EBlaiseVM.Create('Not a simple field');
  SetRegA(nil);
  ObjectUniqueVM(self, V);
end;

procedure TBlaiseVMProcess.IDEN_EVAL;
begin
  IdenCall(ReadPackedString, False, False);
end;

procedure TBlaiseVMProcess.IDEN_EXEC;
begin
  IdenCall(ReadPackedString, True, False);
end;

procedure TBlaiseVMProcess.IDEN_ASSIGN;
var S : ABlaiseType;
    V : TObject;
begin
  if Assigned(FIdenScope) then
    S := FIdenScope else
    S := FScope;
  V := nil;
  try
    V := FStack.Pop;
    S.AssignIdentifier(ReadPackedString, V);
  finally
    ObjectReleaseReference(V);
    if Assigned(FIdenScope) then
      ObjectReleaseReferenceAndNil(FIdenScope);
  end;
end;

procedure TBlaiseVMProcess.IDEN_SCOPE;
var V : TObject;
begin
  V := FStack.Pop;
  if V = UnassignedValue then
    raise EBlaiseVM.Create('No scope: Unassigned value');
  if not (V is ABlaiseType) then
    raise EBlaiseVM.Create('No scope: Not a scope object');
  ObjectReleaseReferenceAndNil(FIdenScope);
  FIdenScope := ABlaiseType(V);
end;

procedure TBlaiseVMProcess.IDEN_EVAL_IDX;
var V, I : TObject;
begin
  FStack.Top2(V, I);
  ObjectGetIndexedValueVM(self, V, I, FRegBool, IDEN_EVAL_IDX_Fin);
end;

procedure TBlaiseVMProcess.IDEN_EVAL_IDX_Fin;
begin
  ObjectReleaseReference(FStack.Pop);
  ObjectReleaseReference(FStack.Pop);
end;

procedure TBlaiseVMProcess.IDEN_EXEC_IDX;
var V, I : TObject;
begin
  FStack.Top2(V, I);
  ObjectGetIndexedValueVM(self, V, I, FRegBool, nil);
  //
end;

procedure TBlaiseVMProcess.IDEN_ASSIGN_IDX;
var V, I, B : TObject;
begin
  I := FStack.Pop;
  V := FStack.Pop;
  B := FStack.Pop;
  ObjectAssignIndexedValueVM(self, V, I, B, FRegBool);
  //
end;

procedure TBlaiseVMProcess.IDEN_EVAL_CALL;
begin
  IdenCall(ReadPackedString, False, True);
end;

procedure TBlaiseVMProcess.IDEN_EXEC_CALL;
begin
  IdenCall(ReadPackedString, True, True);
end;

procedure TBlaiseVMProcess.IDEN_SELF;
begin
  if not (FScope is TCodeFrameScope) then
    raise EBlaiseVM.Create('Self not defined here');
  SetRegA(TCodeFrameScope(FScope).ParentScope);
end;

procedure TBlaiseVMProcess.IDEN_SCOPE_INHERITED;
var S : ABlaiseType;
begin
  S := FScope;
  if S is TCodeFrameScope then
    S := TCodeFrameScope(S).ParentScope;
  if not (S is TTObject) then
    raise EBlaiseVM.Create('Inherited scope not defined here');
  S := TTObject(S).InheritedScope;
  ObjectAddReference(S);
  ObjectReleaseReferenceAndNil(FIdenScope);
  FIdenScope := S;
end;

procedure TBlaiseVMProcess.CREATE_RATIONAL;
var A, B : Integer;
begin
  B := FStack.PopInteger;
  A := FStack.PopInteger;
  FStack.Push(TTRational.CreateEx(TRational.Create(A, B)));
end;

procedure TBlaiseVMProcess.CREATE_ARRAY;
var A : TTArray;
    L : ObjectArray;
begin
  L := FStack.PopList;
  try
    A := TTArray.Create(nil);
    A.Assign(L);
    FStack.Push(A);
  finally
    ObjectsReleaseReference(L);
  end;
end;

procedure TBlaiseVMProcess.CREATE_DICT;
var D    : TTDictionary;
    I, L : Integer;
    K, V : TObject;
begin
  D := TTDictionary.Create(nil, nil);
  L := FStack.PopInteger;
  For I := 0 to L - 1 do
    begin
      V := FStack.Pop;
      K := FStack.Pop;
      D.AddItem(K, V);
      ObjectReleaseReference(K);
      ObjectReleaseReference(V);
    end;
  FStack.Push(D);
end;

procedure TBlaiseVMProcess.NAMED_DELETE;
begin
  NameSpaceDeleteName(ScopeGetRootNameSpace(FScope), FRegUTF8);
end;

procedure TBlaiseVMProcess.NAMED_ASSIGN;
var V : TObject;
begin
  V := FStack.Pop;
  try
    NameSpaceSetName(ScopeGetRootNameSpace(FScope), FRegUTF8, V);
  finally
    ObjectReleaseReference(V);
  end;
end;

procedure TBlaiseVMProcess.NAMED_EXISTS;
begin
  FStack.Push(GetImmutableBoolean(
      NameSpaceNameExists(ScopeGetRootNameSpace(FScope), FRegUTF8)));
end;

procedure TBlaiseVMProcess.NAMED_GET;
begin
  FStack.Push(NameSpaceGetName(ScopeGetRootNameSpace(FScope), FRegUTF8));
end;

procedure TBlaiseVMProcess.NAMED_DIR;
begin
  FStack.Push(NameSpaceDirectory(ScopeGetRootNameSpace(FScope), FRegUTF8));
end;

procedure TBlaiseVMProcess.DECLARATION;
var Def : AScopeFieldDefinitionArray;
begin
  Def := StreamInFieldDefinitions(self);
  ScopeAddFieldDefinitions(FScope, Def, FScope, nil);
end;

procedure TBlaiseVMProcess.USE_UNIT(const UnitName: String);
begin
  if not (FScope is AApplicationScope) then
    raise EBlaiseVM.Create('Unit dependancy not allowed in this scope');
  AApplicationScope(FScope).AddUsedUnit(UnitName);
end;

procedure TBlaiseVMProcess.TEXTOUT;
var S : ABlaiseType;
    T : TBlaiseFieldType;
    V : TObject;
begin
  V := FScope.GetValue('__StdOutput__', True, S, T);
  if V is AWriterEx then
    AWriterEx(V).WriteStr(FRegUTF8) else
  if V is ABlaiseStream then
    ABlaiseStream(V).WriteStr(FRegUTF8)
  else
    raise EBlaiseVM.Create('Standard output not writable');
end;

procedure TBlaiseVMProcess.ENTER_FUNC_SCOPE;
var P : ObjectArray;
begin
  Assert(Assigned(FRegF));
  P := FStack.PopList;
  try
    FScope := FRegF.CreateLocalScope(FScope, P);
  finally
    ObjectsReleaseReference(P);
  end;
  Inc(FEnterCount);
end;

procedure TBlaiseVMProcess.LEAVE_FUNC_SCOPE;
begin
  if FEnterCount = 0 then
    raise EBlaiseVM.Create('Leave without Enter');
  FreeAndNil(FScope);
  Dec(FEnterCount);
end;

procedure TBlaiseVMProcess.START_TASK;
var S : ABlaiseType;
    P : TBlaiseVMProcess;
    L : ObjectArray;
begin
  Assert(Assigned(FRegF));
  L := FStack.PopList;
  try
    S := FRegF.CreateLocalScope(FVMThread.Scope, L);
  finally
    ObjectsReleaseReference(L);
  end;
  P := FVMThread.StartUserProcess(GetAddress, S);
  P.FPaused := True;
  SetRegA(TTaskInstance.Create(P));
  RET;
end;

procedure TBlaiseVMProcess.TASK_RETURN;
var V : TObject;
begin
  V := FStack.Pop;
  SetRegA(V);
  ObjectReleaseReference(V);
  FHasRetVal := True;
  if Assigned(FWaitedBy) then
    begin
      if FWaitedByOp = woHasNext then
        FWaitedBy.SetRegA(GetImmutableBoolean(True))
      else
        begin
          FWaitedBy.SetRegA(V);
          FHasRetVal := False;
        end;
      FWaitedBy.FPaused := False;
      FWaitedBy := nil;
    end;
  FPaused := True;
end;

procedure TBlaiseVMProcess.IMPORT;
var Identifier, UnitName : String;
begin
  Identifier := ReadPackedString;
  UnitName := ReadPackedString;
  ScopeImport(FScope, Identifier, UnitName);
end;

// Micro-thread run procedure
procedure ProcessRunProc(const Data: Pointer);
begin
  Assert(Assigned(Data));
  TBlaiseVMProcess(Data).Run;
end;

procedure TBlaiseVMProcess.CreateMicroThread;
begin
  Assert(FMicroThread = InvalidMicroThreadHandle);
  FMicroThread := FSwitcher.Add(ProcessRunProc, 8192, self);
end;

procedure TBlaiseVMProcess.DeleteMicroThread;
var T : TMicroThreadHandle;
begin
  T := FMicroThread;
  if T <> InvalidMicroThreadHandle then
    begin
      FMicroThread := InvalidMicroThreadHandle;
      FSwitcher.Delete(T);
    end;
end;

const
  VMProcess_ScheduleInterval = 32;

procedure TBlaiseVMProcess.Run;
var C, I : Integer;
begin
  // Validate Module ID
  if PeekByte = BLAISE_VM_MODULE_TYPE_ID then
    begin
      SkipByte;
      Case ReadByte of
        BLAISE_VM_MODULE_TYPE_ID_APPLICATION : ;
        BLAISE_VM_MODULE_TYPE_ID_UNIT : raise EBlaiseVM.Create('Unit can not run');
      else
        raise EBlaiseVM.Create('Invalid module type');
      end;
    end;
  // Execute instructions
  C := 0;
  While not FTerminated do
    begin
      if FPaused then
        FSwitcher.SwitchTo(FScheduler)
      else
        begin
          I := FPos;
          // Terminate process if execution address is past end of data
          if (FSize >= 0) and (I >= FSize) then
            begin
              Terminate;
              break;
            end;
          // Execute one instruction
          Inc(FPos);
          Case Byte(PChar(FData)[I]) of
            BLAISE_VM_NOP                   : ;
            BLAISE_VM_LOAD_UTF8_CONST       : FRegUTF8 := ReadPackedString;
            BLAISE_VM_LOAD_BOOL_A           : FRegBool := SimpleGetAsBoolean(FRegA);
            BLAISE_VM_LOAD_STR_A            : FRegUTF8 := SimpleGetAsString(FRegA);
            BLAISE_VM_LOAD_INT_A            : FRegInt := SimpleGetAsInteger(FRegA);
            BLAISE_VM_LOAD_FLOAT_A          : FRegFloat := SimpleGetAsFloat(FRegA);
            BLAISE_VM_LOAD_CMP_A            : LOAD_CMP_A;
            BLAISE_VM_REVERSE_CMP           : FRegCmp := ReverseCompareResult(FRegCmp);
            BLAISE_VM_LOAD_A_STACK0         : SetRegA(FStack.Top);
            BLAISE_VM_LOAD_A_STACK1         : SetRegA(FStack.BelowTop);
            BLAISE_VM_LOAD_BOOL_TRUE        : FRegBool := True;
            BLAISE_VM_LOAD_BOOL_FALSE       : FRegBool := False;
            BLAISE_VM_PUSH_NIL              : FStack.Push(UnassignedValue);
            BLAISE_VM_PUSH_CONST_OBJECT     : FStack.Push(StreamInObject(self));
            BLAISE_VM_PUSH_CONST_BOOL       : FStack.Push(TTBoolean.Create(ReadByte <> 0));
            BLAISE_VM_PUSH_CONST_STR        : FStack.Push(TTString.Create(ReadPackedString));
            BLAISE_VM_PUSH_CONST_INT        : FStack.Push(TTInteger.Create(ReadInt64));
            BLAISE_VM_PUSH_CONST_FLOAT      : FStack.Push(TTFloat.Create(ReadExtended));
            BLAISE_VM_PUSH_CONST_COMPLEX    : FStack.Push(TTComplex.CreateEx(ReadExtended));
            BLAISE_VM_PUSH_A                : FStack.Push(FRegA);
            BLAISE_VM_POP                   : ObjectReleaseReference(FStack.Pop);
            BLAISE_VM_POP_A                 : POP_A;
            BLAISE_VM_PUSH_BOOL             : FStack.Push(TTBoolean.Create(FRegBool));
            BLAISE_VM_STACK_SWAP_TOP2       : FStack.SwapTop2;
            BLAISE_VM_EVAL_COERCE_BOOL      : EVAL_COERCE_SIMPLE('__GetAsBoolean__', 'boolean');
            BLAISE_VM_EVAL_COERCE_STR       : EVAL_COERCE_SIMPLE('__GetAsString__', 'string');
            BLAISE_VM_EVAL_COERCE_INT       : EVAL_COERCE_SIMPLE('__GetAsInteger__', 'integer');
            BLAISE_VM_EVAL_COERCE_FLOAT     : EVAL_COERCE_SIMPLE('__GetAsFloat__', 'float');
            BLAISE_VM_EVAL_CMP              : EVAL_CMP;
            BLAISE_VM_EVAL_DUP              : ObjectDuplicateVM(self, FRegA);
            BLAISE_VM_EVAL_UNIQUE           : ObjectUniqueVM(self, FRegA);
            BLAISE_VM_EVAL_ITERATE          : EVAL_ITERATE;
            BLAISE_VM_EVAL_HASNEXT          : EVAL_HASNEXT;
            BLAISE_VM_EVAL_NEXT             : EVAL_NEXT;
            BLAISE_VM_EVAL_IS_TYPE          : EVAL_IS_TYPE;
            BLAISE_VM_EVAL_IS_IN            : EVAL_IS_IN;
            BLAISE_VM_EVAL_APPEND_LIST      : EVAL_APPEND_LIST;
            BLAISE_VM_EVAL_L_COERCE_ADD     : EVAL_L_COERCE(bmoAdd);
            BLAISE_VM_EVAL_R_COERCE_ADD     : EVAL_R_COERCE(bmoAdd);
            BLAISE_VM_EVAL_L_COERCE_SUB     : EVAL_L_COERCE(bmoSubtract);
            BLAISE_VM_EVAL_R_COERCE_SUB     : EVAL_R_COERCE(bmoSubtract);
            BLAISE_VM_EVAL_L_COERCE_MUL     : EVAL_L_COERCE(bmoMultiply);
            BLAISE_VM_EVAL_R_COERCE_MUL     : EVAL_R_COERCE(bmoMultiply);
            BLAISE_VM_EVAL_L_COERCE_DIV     : EVAL_L_COERCE(bmoDivide);
            BLAISE_VM_EVAL_R_COERCE_DIV     : EVAL_R_COERCE(bmoDivide);
            BLAISE_VM_EVAL_L_COERCE_POWER   : EVAL_L_COERCE(bmoPower);
            BLAISE_VM_EVAL_R_COERCE_POWER   : EVAL_R_COERCE(bmoPower);
            BLAISE_VM_EVAL_L_COERCE_IDIV    : EVAL_L_COERCE(bmoIntegerDivide);
            BLAISE_VM_EVAL_R_COERCE_IDIV    : EVAL_R_COERCE(bmoIntegerDivide);
            BLAISE_VM_EVAL_L_COERCE_MOD     : EVAL_L_COERCE(bmoModulo);
            BLAISE_VM_EVAL_R_COERCE_MOD     : EVAL_R_COERCE(bmoModulo);
            BLAISE_VM_EVAL_L_COERCE_AND     : EVAL_L_COERCE(bmoLogicalAND);
            BLAISE_VM_EVAL_R_COERCE_AND     : EVAL_R_COERCE(bmoLogicalAND);
            BLAISE_VM_EVAL_L_COERCE_OR      : EVAL_L_COERCE(bmoLogicalOR);
            BLAISE_VM_EVAL_R_COERCE_OR      : EVAL_R_COERCE(bmoLogicalOR);
            BLAISE_VM_EVAL_L_COERCE_XOR     : EVAL_L_COERCE(bmoLogicalXOR);
            BLAISE_VM_EVAL_R_COERCE_XOR     : EVAL_R_COERCE(bmoLogicalXOR);
            BLAISE_VM_EVAL_L_COERCE_SHL     : EVAL_L_COERCE(bmoBitwiseSHL);
            BLAISE_VM_EVAL_R_COERCE_SHL     : EVAL_R_COERCE(bmoBitwiseSHL);
            BLAISE_VM_EVAL_L_COERCE_SHR     : EVAL_L_COERCE(bmoBitwiseSHR);
            BLAISE_VM_EVAL_R_COERCE_SHR     : EVAL_R_COERCE(bmoBitwiseSHR);
            BLAISE_VM_EVAL_L_ADD            : ObjectAddVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_ADD            : ObjectReversedAddVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_SUB            : ObjectSubtractVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_SUB            : ObjectReversedSubtractVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_MUL            : ObjectMultiplyVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_MUL            : ObjectReversedMultiplyVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_DIV            : ObjectDivideVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_DIV            : ObjectReversedDivideVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_POWER          : ObjectPowerVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_POWER          : ObjectReversedPowerVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_IDIV           : ObjectIntegerDivideVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_IDIV           : ObjectReversedIntegerDivideVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_MOD            : ObjectModuloVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_MOD            : ObjectReversedModuloVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_AND            : ObjectLogicalANDVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_AND            : ObjectReversedLogicalANDVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_OR             : ObjectLogicalORVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_OR             : ObjectReversedLogicalORVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_XOR            : ObjectLogicalXORVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_XOR            : ObjectReversedLogicalXORVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_SHL            : ObjectBitwiseSHLVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_SHL            : ObjectReversedBitwiseSHLVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_L_SHR            : ObjectBitwiseSHRVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_R_SHR            : ObjectReversedBitwiseSHRVM(self, FRegA, FStack.Top);
            BLAISE_VM_EVAL_COERCE_SQR       : ObjectUnaryOpCoerceVM(self, umoSqr, FStack.Top);
            BLAISE_VM_EVAL_COERCE_SQRT      : ObjectUnaryOpCoerceVM(self, umoSqrt, FStack.Top);
            BLAISE_VM_EVAL_COERCE_EXP       : ObjectUnaryOpCoerceVM(self, umoExp, FStack.Top);
            BLAISE_VM_EVAL_COERCE_LN        : ObjectUnaryOpCoerceVM(self, umoLn, FStack.Top);
            BLAISE_VM_EVAL_COERCE_SIN       : ObjectUnaryOpCoerceVM(self, umoSin, FStack.Top);
            BLAISE_VM_EVAL_COERCE_COS       : ObjectUnaryOpCoerceVM(self, umoCos, FStack.Top);
            BLAISE_VM_EVAL_SQR              : ObjectSqrVM(self, FRegA);
            BLAISE_VM_EVAL_SQRT             : ObjectSqrVM(self, FRegA);
            BLAISE_VM_EVAL_EXP              : ObjectExpVM(self, FRegA);
            BLAISE_VM_EVAL_LN               : ObjectLnVM(self, FRegA);
            BLAISE_VM_EVAL_SIN              : ObjectSinVM(self, FRegA);
            BLAISE_VM_EVAL_COS              : ObjectCosVM(self, FRegA);
            BLAISE_VM_EVAL_NEGATE           : ObjectNegateVM(self, FRegA);
            BLAISE_VM_EVAL_ABS              : ObjectAbsVM(self, FRegA);
            BLAISE_VM_EVAL_INC              : ObjectIncVM(self, FRegA);
            BLAISE_VM_EVAL_DEC              : ObjectDecVM(self, FRegA);
            BLAISE_VM_EVAL_NOT              : ObjectLogicalNOTVM(self, FRegA);
            BLAISE_VM_RET                   : RET;
            BLAISE_VM_JMP                   : JumpRelative(ReadLongInt);
            BLAISE_VM_JMP_TRUE              : JMP_Conditional(FRegBool);
            BLAISE_VM_JMP_FALSE             : JMP_Conditional(not FRegBool);
            BLAISE_VM_JMP_CMP               : JMP_Conditional(FRegCmp in [crLess, crEqual, crGreater]);
            BLAISE_VM_JMP_EQ                : JMP_Conditional(FRegCmp = crEqual);
            BLAISE_VM_JMP_NE                : JMP_Conditional(FRegCmp <> crEqual);
            BLAISE_VM_JMP_GR                : JMP_Conditional(FRegCmp = crGreater);
            BLAISE_VM_JMP_LE                : JMP_Conditional(FRegCmp = crLess);
            BLAISE_VM_JMP_ASSIGNED          : JMP_Conditional(Assigned(FRegA));
            BLAISE_VM_JMP_NOT_ASSIGNED      : JMP_Conditional(not Assigned(FRegA));
            BLAISE_VM_FLOW_EXIT             : FLOW_EXIT;
            BLAISE_VM_FLOW_BREAK            : FLOW_BREAK;
            BLAISE_VM_FLOW_CONTINUE         : FLOW_CONTINUE;
            BLAISE_VM_FLOW_ENTER_LOOP       : FLOW_ENTER_LOOP;
            BLAISE_VM_FLOW_LEAVE_LOOP       : FLOW_LEAVE_LOOP;
            BLAISE_VM_FLOW_RAISE            : FLOW_RAISE;
            BLAISE_VM_FLOW_RERAISE          : FLOW_RERAISE;
            BLAISE_VM_FLOW_ENTER_TRY_FIN    : FLOW_ENTER_TRY_FIN;
            BLAISE_VM_FLOW_LEAVE_TRY_FIN    : FLOW_LEAVE_TRY_FIN;
            BLAISE_VM_FLOW_END_TRY_FIN      : FLOW_END_TRY_FIN;
            BLAISE_VM_FLOW_ENTER_TRY_EXCEPT : FLOW_ENTER_TRY_EXCEPT;
            BLAISE_VM_FLOW_LEAVE_TRY_EXCEPT : FLOW_LEAVE_TRY_EXCEPT;
            BLAISE_VM_FLOW_END_TRY_EXCEPT   : FLOW_END_TRY_EXCEPT;
            BLAISE_VM_IDEN_UNIQUE           : IDEN_UNIQUE;
            BLAISE_VM_IDEN_EVAL             : IDEN_EVAL;
            BLAISE_VM_IDEN_EXEC             : IDEN_EXEC;
            BLAISE_VM_IDEN_ASSIGN           : IDEN_ASSIGN;
            BLAISE_VM_IDEN_SCOPE            : IDEN_SCOPE;
            BLAISE_VM_IDEN_EVAL_IDX         : IDEN_EVAL_IDX;
            BLAISE_VM_IDEN_EXEC_IDX         : IDEN_EXEC_IDX;
            BLAISE_VM_IDEN_ASSIGN_IDX       : IDEN_ASSIGN_IDX;
            BLAISE_VM_IDEN_EVAL_CALL        : IDEN_EVAL_CALL;
            BLAISE_VM_IDEN_EXEC_CALL        : IDEN_EXEC_CALL;
            BLAISE_VM_IDEN_SELF             : IDEN_SELF;
            BLAISE_VM_IDEN_SCOPE_INHERITED  : IDEN_SCOPE_INHERITED;
            BLAISE_VM_CREATE_RATIONAL       : CREATE_RATIONAL;
            BLAISE_VM_CREATE_ARRAY          : CREATE_ARRAY;
            BLAISE_VM_CREATE_DICT           : CREATE_DICT;
            BLAISE_VM_NAMED_DELETE          : NAMED_DELETE;
            BLAISE_VM_NAMED_ASSIGN          : NAMED_ASSIGN;
            BLAISE_VM_NAMED_EXISTS          : NAMED_EXISTS;
            BLAISE_VM_NAMED_GET             : NAMED_GET;
            BLAISE_VM_NAMED_DIR             : NAMED_DIR;
            BLAISE_VM_USE_UNIT              : USE_UNIT(ReadPackedString);
            BLAISE_VM_DECLARATION           : DECLARATION;
            BLAISE_VM_TEXTOUT               : TEXTOUT;
            BLAISE_VM_ENTER_FUNC_SCOPE      : ENTER_FUNC_SCOPE;
            BLAISE_VM_LEAVE_FUNC_SCOPE      : LEAVE_FUNC_SCOPE;
            BLAISE_VM_START_TASK            : START_TASK;
            BLAISE_VM_TASK_RETURN           : TASK_RETURN;
            BLAISE_VM_IMPORT                : IMPORT;
          else
            raise EBlaiseVM.Create('Invalid opcode: ' + IntToStr(Byte(PChar(FData)[I])));
          end;
          // Schedule counter
          Inc(C);
          if C >= VMProcess_ScheduleInterval then
            begin
              C := 0;
              // Only do (expensive) switch if required
              if (FVMThread.FProcesses.Count > 1) or FVMThread.Terminated then
                FSwitcher.SwitchTo(FScheduler)
              else
                // Give another thread chance to run
                With TBlaiseVM(RequireMachine) do
                  begin
                    Unlock;
                    Lock;
                  end;
            end;
        end;
    end;
end;

procedure TBlaiseVMProcess.Terminate;
begin
  FTerminated := True;
  if Assigned(FWaitedBy) then
    begin
      if FWaitedByOp = woHasNext then
        FWaitedBy.SetRegA(GetImmutableBoolean(False))
      else
        FWaitedBy.SetRegA(nil);
      FWaitedBy.FPaused := False;
      FWaitedBy := nil;
    end;
end;

procedure TBlaiseVMProcess.SetResult(const Value: TObject);
begin
  SetRegA(Value);
end;

function TBlaiseVMProcess.ReleaseRegA: TObject;
begin
  Result := FRegA;
  if Result is ABlaiseType then
    ABlaiseType(Result).DecReference;
  FRegA := nil;
end;

function TBlaiseVMProcess.ReleaseExceptionObject: TObject;
begin
  Result := FExceptionObj;
  FExceptionObj := nil;
end;



{                                                                              }
{ TBlaiseVMThread                                                              }
{                                                                              }
constructor TBlaiseVMThread.Create(const Scope: ABlaiseType; const Data: String;
    const UserThread: TThreadEx);
begin
  inherited Create;
  FScheduler := InvalidMicroThreadHandle;
  FScope := Scope;
  FData := Data;
  FProcesses := TObjectArray.Create(nil, True);
  FThreadId := GetCurrentThreadId;
  FUserThread := UserThread;
end;

destructor TBlaiseVMThread.Destroy;
begin
  FreeAndNil(FProcesses);
  FreeAndNil(FSwitcher);
  inherited Destroy;
end;

function TBlaiseVMThread.GetProcessCount: Integer;
begin
  Result := FProcesses.Count;
end;

function TBlaiseVMThread.AddProcess(const Address: Pointer; const Size: Integer;
    const Scope: ABlaiseType): TBlaiseVMProcess;
begin
  Assert(Assigned(Address));
  Assert(Assigned(FSwitcher));
  Assert(FScheduler <> InvalidMicroThreadHandle);
  Result := TBlaiseVMProcess.Create(self, Address, Size, Scope);
  FProcesses.AppendItem(Result);
end;

procedure TBlaiseVMThread.DeleteProcess(const Process: TBlaiseVMProcess);
var I : Integer;
begin
  I := FProcesses.PosNext(TObject(Process), -1);
  if I < 0 then
    raise EBlaiseVM.Create('Process not found');
  FProcesses.Delete(I, 1);
end;

procedure TBlaiseVMThread.Run;
var I, L : Integer;
    J    : Integer;
    P, M : TBlaiseVMProcess;
    E    : TObject;
    A, R : Boolean;
begin
  if FRunning then
    raise EBlaiseVM.Create('Thread already running');
  if Length(FData) = 0 then
    raise EBlaiseVM.Create('Nothing to execute');
  FTerminated := False;
  FRunning := True;
  try
    // Initialize
    FSwitcher := TWintelSwitcher.Create;
    FScheduler := FSwitcher.GetCurrent;
    // Add main process
    M := AddProcess(Pointer(FData), Length(FData), FScope);
    // Scheduler loop
    P := nil;
    I := 0;
    While not FTerminated do
      begin
        // Check if main process is still running
        if M.Terminated then
          begin
            Terminate;
            break;
          end;
        // Find next active process on a round-robin basis
        L := FProcesses.Count;
        A := False;
        R := False;
        For J := 1 to L do
          begin
            if I >= L - 1 then
              I := 0 else
              Inc(I);
            P := TBlaiseVMProcess(FProcesses.Data[I]);
            if not P.Terminated then
              begin
                R := True;
                if not P.FPaused then
                  begin
                    A := True;
                    break;
                  end;
              end;
          end;
        if not R then // no more running processes
          Terminate else
        if not A then // no more active processes; could be deadlock
          SleepEx(1, True)
        else
          begin
            // Switch to process; keep global lock while executing
            BlaiseVMLock;
            R := False;
            try
              FSwitcher.SwitchTo(P.FMicroThread);
            except
              // Process raised an exception; Terminate it and save the exception
              // object.
              P.Terminate;
              {$IFDEF DELPHI5}
              P.FExceptionObj := ExceptObject;
              {$ELSE}
              P.FExceptionObj := AcquireExceptionObject;
              {$ENDIF}
              BlaiseVMUnlock;
              R := True;
            end;
            if not R then
              BlaiseVMUnlock;
          end;
      end;
    // Execution complete
    // Re-raise exception from the main process
    E := M.ReleaseExceptionObject;
    if Assigned(E) then
      raise E;
  finally
    // Clean up
    FRunning := False;
    FProcesses.Clear;
    FreeAndNil(FSwitcher);
  end;
end;

procedure TBlaiseVMThread.ThreadWouldBlock;
begin
  if FRunning then
    begin
      // Unlock VM while sleeping
      BlaiseVMUnlock;
      try
        SleepEx(1, True);
      finally
        BlaiseVMLock;
      end;
      // Switch task
      FSwitcher.SwitchTo(FScheduler);
    end
  else
    SleepEx(1, True);
end;

function TBlaiseVMThread.StartUserProcess(const Address: Pointer;
    const Scope: ABlaiseType): TBlaiseVMProcess;
begin
  if not FRunning then
    raise EBlaiseVM.Create('Thread not running');
  if not Assigned(Address) then
    raise EBlaiseVM.Create('Invalid execution address');
  Result := AddProcess(Address, -1, Scope);
end;

// Entry point for Delphi code that calls Blaise code
function TBlaiseVMThread.CallFunction(const Func: AFunction; const Address: Pointer;
    const Scope: ABlaiseType; const Parameters: Array of TObject): TObject;
var P : TBlaiseVMProcess;
    E : TObject;
begin
  if not FRunning then
    raise EBlaiseVM.Create('Thread not running');
  if not Assigned(Address) then
    raise EBlaiseVM.Create('Invalid execution address');
  Result := nil;
  // Create new process
  P := AddProcess(Address, -1, Scope);
  try
    // Pass paramaters
    P.Stack.PushList(Parameters);
    // Set function register
    P.SetRegF(Func);
    // Wait for process to finish
    While not FTerminated and not P.Terminated do
      FSwitcher.SwitchTo(FScheduler);
    // Re-raise exception from child process
    E := P.ReleaseExceptionObject;
    if Assigned(E) then
      raise E;
    // Return result
    Result := P.ReleaseRegA;
  finally
    DeleteProcess(P);
  end;
end;

procedure TBlaiseVMThread.Terminate;
begin
  FTerminated := True;
  if Assigned(FUserThread) then
    FUserThread.Terminate;
end;



{                                                                              }
{ TUserThread                                                                  }
{                                                                              }
type
  TUserThread = class(TThreadEx)
  protected
    FProgram  : TBlaiseVMProgram;
    FAddress  : Integer;
    FVMThread : TBlaiseVMThread;

    procedure Execute; override;

  public
    constructor Create(const Prog: TBlaiseVMProgram; const Address: Integer);
  end;

constructor TUserThread.Create(const Prog: TBlaiseVMProgram; const Address: Integer);
begin
  FreeOnTerminate := True;
  FProgram := Prog;
  FAddress := Address;
  inherited Create(False);
end;

procedure TUserThread.Execute;
begin
  FVMThread := TBlaiseVMThread.Create(FProgram.Scope, FProgram.Data, self);
  try
    FProgram.AddUserThread(FVMThread);
    FVMThread.Run;
  finally
    FVMThread.FUserThread := nil;
    FProgram.DeleteThread(FVMThread);
  end;
end;



{                                                                              }
{ TBlaiseVMProgram                                                             }
{                                                                              }
constructor TBlaiseVMProgram.Create(const Scope: ABlaiseType; const Data: String;
    const UserThread: TThreadEx);
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FScope := Scope;
  FData := Data;
  FUserThread := UserThread;
  FThreads := TObjectArray.Create(nil, True);
end;

destructor TBlaiseVMProgram.Destroy;
begin
  FreeAndNil(FThreads);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TBlaiseVMProgram.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TBlaiseVMProgram.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

function TBlaiseVMProgram.GetThreadById(const ThreadId: DWORD): TBlaiseVMThread;
var I : Integer;
    T : TBlaiseVMThread;
begin
  Lock;
  try
    For I := 0 to FThreads.Count - 1 do
      begin
        T := TBlaiseVMThread(FThreads.Data[I]);
        if T.ThreadId = ThreadId then
          begin
            Result := T;
            exit;
          end;
      end;
  finally
    Unlock;
  end;
  Result := nil;
end;

procedure TBlaiseVMProgram.AddUserThread(const Thread: TBlaiseVMThread);
begin
  Lock;
  try
    FThreads.AppendItem(Thread);
  finally
    Unlock;
  end;
end;

procedure TBlaiseVMProgram.DeleteThread(const Thread: TBlaiseVMThread);
begin
  Lock;
  try
    FThreads.DeleteValue(Thread);
  finally
    Unlock;
  end;
end;

procedure TBlaiseVMProgram.Run;
var L : Integer;
begin
  if FRunning then
    raise EBlaiseVM.Create('Program already running');
  FMainThread := TBlaiseVMThread.Create(FScope, FData, nil);
  try
    // Run main thread
    FRunning := True;
    FThreads.AppendItem(FMainThread);
    try
      FMainThread.Run;
    finally
      DeleteThread(FMainThread);
      FMainThread := nil;
    end;
    // Main thread terminated
    // Wait for other threads to terminate
    Repeat
      Lock;
      try
        L := FThreads.Count;
      finally
        Unlock;
      end;
      if L = 0 then
        break;
      Sleep(1);
    Until False;
  finally
    FRunning := False;
    FThreads.Clear;
  end;
end;

procedure TBlaiseVMProgram.StartUserThread(const Address: Integer);
begin
  if not FRunning then
    raise EBlaiseVM.Create('Program not running');
  TUserThread.Create(self, Address);
end;

function TBlaiseVMProgram.CallFunction(const Func: AFunction; const Address: Pointer;
    const Scope: ABlaiseType; const Parameters: Array of TObject): TObject;
var T : TBlaiseVMThread;
begin
  T := GetThreadById(GetCurrentThreadId);
  if not Assigned(T) then
    raise EBlaiseVM.Create('Thread not found');
  Result := T.CallFunction(Func, Address, Scope, Parameters);
end;

procedure TBlaiseVMProgram.Terminate;
var I : Integer;
begin
  Lock;
  try
    For I := 0 to FThreads.Count - 1 do
      TBlaiseVMThread(FThreads[I]).Terminate;
  finally
    Unlock;
  end;
end;



{                                                                              }
{ TUserProgram                                                                 }
{                                                                              }
type
  TUserProgram = class(TThreadEx)
  protected
    FMachine   : TBlaiseVM;
    FScope     : ABlaiseType;
    FData      : String;
    FVMProgram : TBlaiseVMProgram;

    procedure Execute; override;

  public
    constructor Create(const Machine: TBlaiseVM; const Scope: ABlaiseType;
                const Data: String);
  end;

constructor TUserProgram.Create(const Machine: TBlaiseVM; const Scope: ABlaiseType;
    const Data: String);
begin
  FreeOnTerminate := True;
  FMachine := Machine;
  FScope := Scope;
  FData := Data;
  inherited Create(False);
end;

procedure TUserProgram.Execute;
begin
  FVMProgram := TBlaiseVMProgram.Create(FScope, FData, self);
  try
    FMachine.AddUserProgram(FVMProgram);
    FVMProgram.Run;
  finally
    FVMProgram.FUserThread := nil;
    FMachine.DeleteProgram(FVMProgram);
  end;
end;



{                                                                              }
{ TBlaiseVM                                                                    }
{                                                                              }
constructor TBlaiseVM.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FPrograms := TObjectArray.Create(nil, True);
end;

destructor TBlaiseVM.Destroy;
begin
  FreeAndNil(FPrograms);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TBlaiseVM.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TBlaiseVM.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

procedure TBlaiseVM.AddUserProgram(const Prog: TBlaiseVMProgram);
begin
  Lock;
  try
    FPrograms.AppendItem(Prog);
  finally
    Unlock;
  end;
end;

procedure TBlaiseVM.DeleteProgram(const Prog: TBlaiseVMProgram);
begin
  Lock;
  try
    FPrograms.DeleteValue(Prog);
  finally
    Unlock;
  end;
end;

procedure TBlaiseVM.Run(const Scope: ABlaiseType; const Data: String);
begin
  if FRunning then
    raise EBlaiseVM.Create('Virtual machine already running');
  FRunning := True;
  try
    SetMachine(self);
    FMainProgram := TBlaiseVMProgram.Create(Scope, Data, nil);
    FPrograms.AppendItem(FMainProgram);
    FMainProgram.Run;
    // Main program terminated; terminate user programs
    Terminate;
  finally
    FRunning := False;
    FMainProgram := nil;
    FPrograms.Clear;
    SetMachine(nil);
  end;
end;

procedure TBlaiseVM.StartUserProgram(const Scope: ABlaiseType; const Data: String);
begin
  if not FRunning then
    raise EBlaiseVM.Create('Virtual machine not running');
  TUserProgram.Create(self, Scope, Data);
end;

function TBlaiseVM.GetCurrentThread: TBlaiseVMThread;
var I : Integer;
    P : TBlaiseVMProgram;
    T : LongWord;
begin
  Lock;
  try
    Result := nil;
    if not FRunning then
      exit;
    T := GetCurrentThreadId;
    For I := 0 to FPrograms.Count - 1 do
      begin
        P := TBlaiseVMProgram(FPrograms.Data[I]);
        Result := P.GetThreadById(T);
        if Assigned(Result) then
          break;
      end;
  finally
    Unlock;
  end;
end;

function TBlaiseVM.CallFunction(const Func: AFunction; const Address: Pointer;
    const Scope: ABlaiseType; const Parameters: Array of TObject): TObject;
var T : TBlaiseVMThread;
begin
  if not FRunning then
    raise EBlaiseVM.Create('Virtual machine not running');
  T := GetCurrentThread;
  if not Assigned(T) then
    raise EBlaiseVM.Create('Thread not found');
  Result := T.CallFunction(Func, Address, Scope, Parameters);
end;

procedure TBlaiseVM.ThreadWouldBlock;
var T : TBlaiseVMThread;
begin
  T := GetCurrentThread;
  if Assigned(T) then
    T.ThreadWouldBlock
  else
    SleepEx(1, True);
end;

procedure TBlaiseVM.Terminate;
var I : Integer;
begin
  Lock;
  try
    For I := FPrograms.Count - 1 downto 0 do
      TBlaiseVMProgram(FPrograms[I]).Terminate;
  finally
    Unlock;
  end;
end;



{                                                                              }
{ Global lock                                                                  }
{                                                                              }
procedure BlaiseVMLock;
var V : AVirtualMachine;
begin
  V := RequireMachine;
  Assert(V is TBlaiseVM);
  TBlaiseVM(V).Lock;
end;

procedure BlaiseVMUnlock;
var V : AVirtualMachine;
begin
  V := RequireMachine;
  Assert(V is TBlaiseVM);
  TBlaiseVM(V).Unlock;
end;



end.

