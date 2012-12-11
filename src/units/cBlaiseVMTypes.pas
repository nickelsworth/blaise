{                                                                              }
{                   Blaise Virtual Machine base classes v0.02                  }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{               Its original file name is cBlaiseVMTypes.pas                   }
{                                                                              }
{ Description:                                                                 }
{   This unit defines Blaise virtual machine base classes.                     }
{                                                                              }
{ Revision history:                                                            }
{   06/04/2003  0.01  Initial version.                                         }
{   07/04/2003  0.02  Added AVirtualMachineProcess.                            }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseVMTypes;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cReaders,

  { Blaise }
  cBlaiseTypes;



{                                                                              }
{ AVirtualMachine                                                              }
{   Abstract base class for a the virtual machine.                             }
{                                                                              }
type
  AVirtualMachine = class
  public
    function  CallFunction(const Func: AFunction; const Address: Pointer;
              const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; virtual;
    procedure ThreadWouldBlock; virtual;
  end;
  EVirtualMachine = class(EBlaiseError);



{                                                                              }
{ AVirtualMachineProcess                                                       }
{   Base class for a virtual machine process.                                  }
{                                                                              }
type
  TBlaiseVMContinuation = procedure of object;

  AVirtualMachineProcess = class(TMemoryReader)
  protected
    procedure InvalidJumpError;

    procedure JumpAddress(const Address: Pointer);
    procedure JumpAddressBlock(const Address: Pointer; const Size: Integer);
    procedure JumpOffset(const Offset: Integer);
    procedure JumpRelative(const Offset: Integer);

    procedure ScopeCall(const Scope: ABlaiseType;
              const Func: AFunction; const Address: Pointer;
              const Parameters: Array of TObject;
              const Continuation: TBlaiseVMContinuation); virtual; abstract;

  public
    procedure ScopeEval(const Scope: ABlaiseType; const FieldName: String;
              const Parameters: Array of TObject;
              const Continuation: TBlaiseVMContinuation = nil);
    procedure SetResult(const Value: TObject); virtual; abstract;
  end;
  EVirtualMachineProcess = class(EBlaiseError);



implementation

uses
  { Blaise }
  cBlaiseConsts;



{                                                                              }
{ AVirtualMachine                                                              }
{                                                                              }
function AVirtualMachine.CallFunction(const Func: AFunction;
    const Address: Pointer; const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  raise EVirtualMachine.Create(ClassName + '.CallFunction not implemented');
end;

procedure AVirtualMachine.ThreadWouldBlock;
begin
  raise EVirtualMachine.Create(ClassName + '.ThreadWouldBlock not implemented');
end;



{                                                                              }
{ AVirtualMachineProcess                                                       }
{                                                                              }
procedure AVirtualMachineProcess.InvalidJumpError;
begin
  raise EVirtualMachineProcess.Create('Invalid jump');
end;

procedure AVirtualMachineProcess.JumpAddress(const Address: Pointer);
begin
  if not Assigned(Address) then
    InvalidJumpError;
  SetData(Address, -1);
end;

procedure AVirtualMachineProcess.JumpAddressBlock(const Address: Pointer;
    const Size: Integer);
begin
  if not Assigned(Address) or (Size <= 0) then
    InvalidJumpError;
  SetData(Address, Size);
end;

procedure AVirtualMachineProcess.JumpOffset(const Offset: Integer);
var S : Integer;
begin
  if Offset < 0 then
    InvalidJumpError;
  S := FSize;
  if (S >= 0) and (Offset >= S) then
    InvalidJumpError;
  FPos := Offset;
end;

procedure AVirtualMachineProcess.JumpRelative(const Offset: Integer);
begin
  if Offset = BLAISE_VM_INVALID_REL_OFFSET then
    InvalidJumpError;
  JumpOffset(FPos + Offset);
end;

// ScopeEval is called by VM code to evaluate a scope identifier;
// It is the entry point for VM code that might call Blaise code.
procedure AVirtualMachineProcess.ScopeEval(const Scope: ABlaiseType;
    const FieldName: String; const Parameters: Array of TObject;
    const Continuation: TBlaiseVMContinuation);
var V : TObject;
    E : TBlaiseEvalType;
    A : Pointer;
begin
  V := Scope.EvaluateImmediate(FieldName, Parameters, True, False, E, A);
  Assert(E <> beNone);
  if E = beMachineCall then
    ScopeCall(Scope, AFunction(V), A, Parameters, Continuation)
  else
    begin
      SetResult(V);
      if Assigned(Continuation) then
        Continuation;
    end;
end;



end.

