(******************************************************************************)
(*                                                                            *)
(*    Unit:          Micro Threads.                                           *)
(*    Version:       1.03                                                     *)
(*    Target:        Borland Delphi 5-7 compiler                              *)
(*                   Microsoft Windows 95/98/NT/2000/XP/2003                  *)
(*    Copyright:     Copyright (c) 2003 D.J. Butler.                          *)
(*                   All rights reserved.                                     *)
(*    Homepage:      http://www.eternallines.com/microthreads                 *)
(*    E-mail:        david@e.co.za                                            *)
(*                                                                            *)
(*                                                                            *)
(*  Description:                                                              *)
(*    "Micro-threads" are light-weight threads that run in a single system    *)
(*    thread. Micro-threads are co-operatively scheduled by the user, unlike  *)
(*    system threads which are pre-emptively scheduled by the operating       *)
(*    system.                                                                 *)
(*                                                                            *)
(*    Micro-threads are also called user threads or co-operative routines.    *)
(*    Windows Fibers are an example of micro-threads.                         *)
(*                                                                            *)
(*    A "switcher" is responsible for doing the context switch when execution *)
(*    is transferred between two micro-threads.                               *)
(*                                                                            *)
(*    This unit defines an abstract micro-thread switcher and two switcher    *)
(*    implementations. One implementation uses Windows Fibers and the other   *)
(*    does low-level CPU manipulation.                                        *)
(*                                                                            *)
(*                                                                            *)
(*  Revision history:                                                         *)
(*    2003/04/03  1.00  Initial version.                                      *)
(*    2003/04/04  1.01  Windows Fiber support. Redesigned stack and exception *)
(*                      handling of Wintel switcher to use system stack.      *)
(*    2003/05/25  1.02  Delphi 5 support.                                     *)
(*    2003/09/06  1.03  Small revisions.                                      *)
(*                                                                            *)
(******************************************************************************)

{$INCLUDE ..\cDefines.inc}
unit cMicroThreads;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cArrays;

const
  UnitName      = 'cMicroThreads';
  UnitVersion   = '1.03';
  UnitDesc      = 'Micro Threads';
  UnitCopyright = 'Copyright (c) 2003 D.J. Butler';



{                                                                              }
{ AMicroThreadSwitcher                                                         }
{   Abstract base class for micro-thread switchers.                            }
{                                                                              }
{   The switcher object must be constructed in the system thread it intends    }
{   running in; and in addition, all switcher methods must be called from      }
{   within that same system thread.                                            }
{                                                                              }
{   Call Add to create a new micro-thread. It returns a handle to the new      }
{   micro-thread. The micro-thread only starts execution when it is activated  }
{   by a call to SwitchTo.                                                     }
{                                                                              }
{   GetCurrent returns a handle of the currently executing micro-thread.       }
{   When a switcher is created, there exists one micro-thread for the          }
{   currently running thread.                                                  }
{                                                                              }
{   Delete removes a micro-thread previously created by a call to Add.         }
{   The initial thread and the currently running thread can not be deleted.    }
{                                                                              }
type
  TMicroThreadRunProc = procedure (const Data: Pointer);
  TMicroThreadHandle = LongWord;

const
  InvalidMicroThreadHandle = TMicroThreadHandle(0);

type
  AMicroThreadSwitcher = class
  public
    function  Add(const RunProc: TMicroThreadRunProc;
              const StackSize: Integer = -1;
              const Data: Pointer = nil): TMicroThreadHandle; virtual; abstract;
    procedure SwitchTo(const Handle: TMicroThreadHandle); virtual; abstract;
    procedure Delete(const Handle: TMicroThreadHandle); virtual; abstract;
    function  GetPrimary: TMicroThreadHandle; virtual; abstract;
    function  GetCurrent: TMicroThreadHandle; virtual; abstract;
    function  GetCount: Integer; virtual; abstract;
  end;
  EMicroThreadSwitcher = class(Exception);



{                                                                              }
{ TFiberSwitcher                                                               }
{   Switcher implementation using Windows Fibers.                              }
{                                                                              }
{   Fibers are available under Windows NT/2000 but not under Windows 95/98.    }
{                                                                              }
type
  TFiberSwitcher = class(AMicroThreadSwitcher)
  protected
    FCount   : Integer;
    FPrimary : Pointer;
    FCurrent : Pointer;

  public
    constructor Create;

    function  Add(const RunProc: TMicroThreadRunProc;
              const StackSize: Integer = -1;
              const Data: Pointer = nil): TMicroThreadHandle; override;
    procedure SwitchTo(const Handle: TMicroThreadHandle); override;
    procedure Delete(const Handle: TMicroThreadHandle); override;
    function  GetPrimary: TMicroThreadHandle; override;
    function  GetCurrent: TMicroThreadHandle; override;
    function  GetCount: Integer; override;
  end;
  EFiberSwitcher = class(EMicroThreadSwitcher);



{                                                                              }
{ TWintelSwitcher                                                              }
{   Switcher implementation using low-level CPU state. The implementation      }
{   uses Intel-386 and Windows specific code.                                  }
{                                                                              }
type
  TWintelMicroThreadState = (
      mtReady,          // Ready to start running
      mtRunning,        // Currently running
      mtYielding,       // Currently yielding
      mtTerminated);    // Completed execution

  TWintelSwitcher = class(AMicroThreadSwitcher)
  protected
    FThreads      : TObjectArray;
    FStackBase    : Pointer;
    FPrimary      : TMicroThreadHandle;
    FCurrent      : TMicroThreadHandle;
    FExceptObject : TObject;

    function  GetIndexFromHandle(const Handle: TMicroThreadHandle): Integer;

  public
    constructor Create;
    destructor Destroy; override;

    function  Add(const RunProc: TMicroThreadRunProc;
              const StackSize: Integer = -1;
              const Data: Pointer = nil): TMicroThreadHandle; override;
    procedure SwitchTo(const Handle: TMicroThreadHandle); override;
    procedure Delete(const Handle: TMicroThreadHandle); override;
    function  GetPrimary: TMicroThreadHandle; override;
    function  GetCurrent: TMicroThreadHandle; override;
    function  GetCount: Integer; override;
  end;
  EWintelSwitcher = class(EMicroThreadSwitcher);



implementation

uses
  { Delphi }
  Windows;



{                                                                              }
{ Windows API functions                                                        }
{                                                                              }

// These functions are redeclared because Delphi's Windows unit declare them
// incorrectly.
function ConvertThreadToFiber(lpParameter: Pointer): Pointer; stdcall;
    external kernel32 name 'ConvertThreadToFiber';

function CreateFiber(dwStackSize: DWORD; lpStartAddress: TFNFiberStartRoutine;
         lpParameter: Pointer): Pointer; stdcall;
    external kernel32 name 'CreateFiber';



{$IFDEF DELPHI6_UP}
{$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}

{                                                                              }
{ TFiberSwitcher                                                               }
{                                                                              }
{   Experiments have shown that Windows 2000 can handle in the order of two    }
{   hundred fibers per thread.                                                 }
{                                                                              }
const
  DefaultFiberStackSize = 16384;

type
  TFiberStartInfo = record
    RunProc : TMicroThreadRunProc;
    Data    : Pointer;
  end;
  PFiberStartInfo = ^TFiberStartInfo;

procedure FiberStartProc(const Parameter: Pointer); stdcall;
var P : PFiberStartInfo;
    F : TFiberStartInfo;
begin
  P := Parameter;
  Assert(Assigned(P));
  F := P^;
  Dispose(P);
  Assert(Assigned(@F.RunProc));
  F.RunProc(F.Data);
end;

constructor TFiberSwitcher.Create;
begin
  inherited Create;
  FPrimary := ConvertThreadToFiber(nil);
  if LongWord(FPrimary) = 0 then
    RaiseLastWin32Error;
  FCurrent := FPrimary;
  FCount := 1;
end;

function TFiberSwitcher.Add(const RunProc: TMicroThreadRunProc;
    const StackSize: Integer; const Data: Pointer): TMicroThreadHandle;
var M : Integer;
    P : PFiberStartInfo;
begin
  M := StackSize;
  if M < 0 then
    M := DefaultFiberStackSize;
  New(P);
  P^.RunProc := RunProc;
  P^.Data := Data;
  Result := LongWord(CreateFiber(M, @FiberStartProc, P));
  if Result = 0 then
    begin
      Dispose(P);
      RaiseLastWin32Error;
    end;
  Inc(FCount);
end;

procedure TFiberSwitcher.SwitchTo(const Handle: TMicroThreadHandle);
var P : Pointer;
begin
  P := Pointer(LongWord(Handle));
  SwitchToFiber(P);
  FCurrent := P;
end;

procedure TFiberSwitcher.Delete(const Handle: TMicroThreadHandle);
begin
  DeleteFiber(Pointer(LongWord(Handle)));
  Dec(FCount);
end;

function TFiberSwitcher.GetPrimary: TMicroThreadHandle;
begin
  Result := LongWord(FPrimary);
end;

function TFiberSwitcher.GetCurrent: TMicroThreadHandle;
begin
  Result := LongWord(FCurrent);
end;

function TFiberSwitcher.GetCount: Integer;
begin
  Result := FCount;
end;



{                                                                              }
{ TWintelSwitcher                                                              }
{                                                                              }
{  Experiments have been done with 100,000 micro-threads and showed that       }
{  switching was efficient.                                                    }
{                                                                              }
{  Stacks:                                                                     }
{  ======                                                                      }
{                                                                              }
{   Windows requires all stack frames to be inside the stack allocated by      }
{   the system. It also requires the stack frames to be in sequential order    }
{   on the stack. Furthermore, for exception handling, it requires all         }
{   'exception records' to be on the stack, and for them to chain in a         }
{   sequential order through stack memory.                                     }
{                                                                              }
{   Stack layout during execution:                                             }
{                                                                              }
{      +------------------------+                                              }
{      .           ^            .     ^                                        }
{      .           |            .     |---- Saved section of stack             }
{      |  micro-thread stack    |     v                                        }
{      |                        |                                              }
{      +-----------^------------+     <---- FStackBase                         }
{      |           |            |                                              }
{      |           |            |                                              }
{      |  primary thread stack  |                                              }
{      |                        |                                              }
{      +------------------------+                                              }
{      |                        |                                              }
{      |   application stack    |                                              }
{      |                        |                                              }
{      +------------------------+                                              }
{                                                                              }
{   The 'micro-thread stack' part of the stack is copied during context        }
{   switches.                                                                  }
{                                                                              }
{   The 'primary thread stack' is an area of the stack reserved for the        }
{   exclusive use of the primary micro-thread. This allows fast context        }
{   switches to and from the primary micro-thread. Its stack can however       }
{   still grow beyond FStackBase. If this happens, only the part above         }
{   FStackBase is copied during context switches.                              }
{                                                                              }
{                                                                              }
{  Flow of execution:                                                          }
{  =================                                                           }
{                                                                              }
{   A call to SwitchTo is invalid to a terminated micro-thread. A micro-       }
{   thread terminates when it returns normally or when an exception is         }
{   raised. When a thread terminates, control is returned to the primary       }
{   micro-thread. When an exception is raised in a non-primary micro-thread,   }
{   the exception is re-raised in the primary micro-thread. The primary        }
{   micro-thread follows normal exception handling and flow of execution       }
{   rules.                                                                     }
{                                                                              }
{   Because the primary micro-thread never terminates, and because execution   }
{   returns to the primary micro-thread when other micro-threads terminate     }
{   or raise an exception, it is useful to use the primary thread as a         }
{   scheduler for the other threads.                                           }
{                                                                              }

const
  PrimaryWintelThreadReservedStack = 4096;

{ TWintelMicroThread                                                           }
type
  TWintelMicroThread = class
    Magic        : LongWord;                  // Identify a valid instance pointer
    State        : TWintelMicroThreadState;   // Current state
    RunProc      : TMicroThreadRunProc;       // Run procedure
    RunProcData  : Pointer;                   // Run procedure parameter
    Stack        : Pointer;                   // Saved stack
    StackSize    : Integer;                   // Size of allocated Stack memory
    StackPointer : Pointer;                   // SP register
    BasePointer  : Pointer;                   // BP register
    ExceptionReg : Pointer;                   // FS:[0] register

    constructor Create(const RunProc: TMicroThreadRunProc;
                const RunProcData: Pointer);
    destructor Destroy; override;
  end;

const
  WintelMicroThreadMagic = $F0544D0F;

constructor TWintelMicroThread.Create(const RunProc: TMicroThreadRunProc;
    const RunProcData: Pointer);
begin
  inherited Create;
  // Initialize
  self.Magic := WintelMicroThreadMagic;
  self.State := mtReady;
  self.RunProc := RunProc;
  self.RunProcData := RunProcData;
end;

destructor TWintelMicroThread.Destroy;
var P : Pointer;
begin
  // Clear
  Magic := 0;
  // Free stack buffer
  P := Stack;
  if Assigned(P) then
    begin
      Stack := nil;
      StackSize := 0;
      FreeMem(P);
    end;
  inherited Destroy;
end;

{ TWintelSwitcher                                                              }
constructor TWintelSwitcher.Create;
var Base : Pointer;
    T    : TWintelMicroThread;
begin
  inherited Create;
  FThreads := TObjectArray.Create(nil, True);
  // Initialize stack base
  asm
    // get this base pointer and reserve a bit more space for exclusive use
    // by the primary micro-thread; the top of this stack will be the
    // stack base for other micro-threads.
    mov eax, ebp
    sub eax, PrimaryWintelThreadReservedStack
    mov Base, eax
  end;
  Assert(Base <> nil);
  FStackBase := Base;
  // Initialize the currently running thread as the primary micro-thread
  FPrimary := Add(nil, -1, nil);
  T := TWintelMicroThread(Pointer(FPrimary));
  T.State := mtRunning;
  FCurrent := FPrimary;
end;

destructor TWintelSwitcher.Destroy;
begin
  FreeAndNil(FThreads);
  inherited Destroy;
end;

// The StackSize parameter is ignored; With the Wintel Switcher, all
// micro-threads share the application stack. The actual stack size for this
// micro-thread is the same as the current application stack.
// A small stack buffer is initially allocated in dynamic memory for the
// saved stack of this micro-thread. This buffer is enlarged as needed.
function TWintelSwitcher.Add(const RunProc: TMicroThreadRunProc;
    const StackSize: Integer; const Data: Pointer): TMicroThreadHandle;
const InitialWintelThreadStackSize = 128;
var T : TWintelMicroThread;
begin
  // Create micro-thread
  T := TWintelMicroThread.Create(RunProc, Data);
  try
    Assert(T.Magic = WintelMicroThreadMagic);
    // Allocate minimal initial stack storage
    GetMem(T.Stack, InitialWintelThreadStackSize);
    T.StackSize := InitialWintelThreadStackSize;
  except
    T.Free;
    raise;
  end;
  // Add thread information
  FThreads.AppendItem(T);
  // Return handle
  Result := TMicroThreadHandle(LongWord(T));
  Assert(Result <> InvalidMicroThreadHandle);
end;

procedure TWintelSwitcher.SwitchTo(const Handle: TMicroThreadHandle);
var L    : Integer;
    U    : TMicroThreadHandle;
    T, R : TWintelMicroThread;
    A    : TWintelMicroThreadState;
begin
  // Check if valid handle
  U := FCurrent;
  if Handle = U then
    raise EWintelSwitcher.Create('Thread already running');
  R := TWintelMicroThread(Pointer(Handle));
  if (Handle = InvalidMicroThreadHandle) or (R.Magic <> WintelMicroThreadMagic) then
    raise EWintelSwitcher.Create('Invalid thread handle');
  A := R.State;
  Case A of
    mtReady,
    mtYielding   : ;
    mtTerminated : raise EWintelSwitcher.Create('Thread has terminated');
  else
    raise EWintelSwitcher.Create('Invalid thread');
  end;
  // Save running thread's state
  if U <> InvalidMicroThreadHandle then
    begin
      FCurrent := InvalidMicroThreadHandle;
      T := TWintelMicroThread(Pointer(U));
      asm
        mov eax, dword ptr [T]
        // Set state
        mov byte ptr [eax + TWintelMicroThread.State], mtYielding
        // Save stack pointers
        mov [eax + TWintelMicroThread.StackPointer], esp
        mov [eax + TWintelMicroThread.BasePointer], ebp
        // Save exception register
        xor edx, edx
        mov ecx, fs:[edx]
        mov [eax + TWintelMicroThread.ExceptionReg], ecx
      end;
      // Save stack contents
      L := PChar(FStackBase) - PChar(T.StackPointer);
      if L > T.StackSize then
        begin
          T.StackSize := L + (L shr 3); // allocate new stack with an extra 1/8th
          ReallocMem(T.Stack, T.StackSize);
        end;
      if L > 0 then
        Move(T.StackPointer^, T.Stack^, L);
    end;
  // Set state for thread being switched to
  R.State := mtRunning;
  FCurrent := Handle;
  if A = mtYielding then
    begin
      // Resume a yielding thread
      Assert(Assigned(R.StackPointer));
      L := PChar(FStackBase) - PChar(R.StackPointer);
      asm
        mov ecx, self
        mov eax, dword ptr [R]
        // Restore stack pointer; This must be done before the stack contents
        // is restored (which could overwrite the current stack)
        mov esp, [eax + TWintelMicroThread.StackPointer]
        // Push self
        push ecx
        // Push new base pointer; We still need the current value of EBP to
        // access local variable L in a following statement.
        push [eax + TWintelMicroThread.BasePointer]
        // Push new exception register
        push [eax + TWintelMicroThread.ExceptionReg]
        // Restore stack contents
        cmp L, 0
        jle @NoCopy
        mov edx, [eax + TWintelMicroThread.StackPointer]
        mov ecx, L
        mov eax, [eax + TWintelMicroThread.Stack]
        call Move
      @NoCopy:
        // Restore exception register
        xor eax, eax
        pop edx
        mov fs:[eax], edx
        // Restore base pointer
        pop ebp
        // Restore self
        pop ecx
        // Context switch complete
        // If the switch is to the primary micro-thread, check if an exception
        // was raised by another micro-thread
        mov eax, [ecx + TWintelSwitcher.FExceptObject]
        or eax, eax
        jz @NoException        // No exception raised
        mov edx, [ecx + TWintelSwitcher.FCurrent]
        cmp edx, [ecx + TWintelSwitcher.FPrimary]
        jne @NoException       // Not primary micro-thread
        // Exception was raised by another micro-thread; Clear the flag and
        // re-raise the exception object in the primary micro-thread
        xor edx, edx
        mov [ecx + TWintelSwitcher.FExceptObject], edx
        call System.@RaiseExcept
      @NoException:
      end;
      // Thread resumes when this function exits
    end
  else
    begin
      // Start running a non-primary micro-thread
      Assert(A = mtReady);
      asm
        mov ecx, self
        mov eax, dword ptr [R]
        // Get RunProc
        mov edx, [eax + TWintelMicroThread.RunProc]
        // Set stack pointer
        mov esp, [ecx + TWintelSwitcher.FStackBase]
        mov [eax + TWintelMicroThread.StackPointer], esp
        // Create stack frame; A base pointer of 0 is pushed to indicate
        // that this is the first stack frame.
        push 0
        mov ebp, esp     // After this, local variables are not accessible by compiler
        // Save values
        push eax         // TWintelMicroThread
        push ecx         // self
        // Save RunProc info
        push edx         // RunProc
        push [eax + TWintelMicroThread.RunProcData]
      end;
      // Setup exception register; The current exception register is invalid;
      // The only valid exception handler at this point is that of the primary
      // thread (once its state has been restored). A Delphi exception handler
      // is installed here on the new stack frame to catch all exceptions. The
      // exception is handled later by the primary thread.
      try
        // Call RunProc; When the call returns, the thread terminated or
        // raised an exception.
        asm
          mov eax, [ebp - 16]  // RunProcData
          mov edx, [ebp - 12]  // RunProc
          call edx
        end;
        // Thread terminated
      except
        // Thread raised an exception; acquire the exception object and save it
        // for re-raising
        asm
          {$IFDEF DELPHI5}
          call ExceptObject
          {$ELSE}
          call AcquireExceptionObject
          {$ENDIF}
          mov ecx, [ebp - 8]   // self
          mov [ecx + TWintelSwitcher.FExceptObject], eax
        end;
      end;
      asm
        // Remove RunProc info
        add esp, 8
        // Restore saved values; local variables are not valid after RunProc
        pop ecx          // self
        pop eax          // TWintelMicroThread
        // Set thread terminated
        mov byte ptr [eax + TWintelMicroThread.State], mtTerminated
        mov dword ptr [ecx + TWintelSwitcher.FCurrent], InvalidMicroThreadHandle
        // Resume primary thread by calling SwitchTo(1); FCurrent has
        // been set to 0 to indicate that no state should be saved when
        // SwitchTo re-enters.
        mov eax, ecx     // self
        mov edx, [ecx + TWintelSwitcher.FPrimary]  // Handle
        mov ecx, [eax]   // self.VMT
        {$IFDEF DELPHI5}
        mov ecx, OFFSET TWintelSwitcher.SwitchTo
        call ecx
        {$ELSE}
        call dword ptr [ecx + VMTOFFSET TWintelSwitcher.SwitchTo]
        {$ENDIF}
      end;
    end;
end;

function TWintelSwitcher.GetIndexFromHandle(const Handle: TMicroThreadHandle): Integer;
var T : TWintelMicroThread;
begin
  T := TWintelMicroThread(Pointer(Handle));
  Result := FThreads.PosNext(T, -1);
  if Result < 0 then
    raise EWintelSwitcher.Create('Invalid thread handle');
end;

procedure TWintelSwitcher.Delete(const Handle: TMicroThreadHandle);
var T : TWintelMicroThread;
begin
  // Check if valid handle
  T := TWintelMicroThread(Pointer(Handle));
  if not Assigned(T) or (T.Magic <> WintelMicroThreadMagic) then
    raise EWintelSwitcher.Create('Invalid thread handle');
  if Handle = FCurrent then
    raise EWintelSwitcher.Create('Cannot delete running thread');
  if Handle = FPrimary then
    raise EWintelSwitcher.Create('Cannot delete primary thread');
  // Free entry
  FThreads.Delete(GetIndexFromHandle(Handle), 1);
end;

function TWintelSwitcher.GetPrimary: TMicroThreadHandle;
begin
  Result := FPrimary;
end;

function TWintelSwitcher.GetCurrent: TMicroThreadHandle;
begin
  Result := FCurrent;
end;

function TWintelSwitcher.GetCount: Integer;
begin
  Result := FThreads.Count;
end;



end.

