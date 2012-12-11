{$INCLUDE ..\cDefines.inc}

{                                                                              }
{ Revision history:                                                            }
{   2003/05/12  0.01  Initial version.                                         }
{                                                                              }
unit cCallConventions;

interface

uses
  { Delphi }
  SysUtils;



type
  ECallingConvention = class(Exception);
  TCallingConvention = (ccRegister, ccCDecl, ccPascal, ccStdCall, ccSafeCall);

function  Call(const Convention: TCallingConvention;
          const ProcAddress: Pointer;
          const Parameters: Array of LongWord): LongWord;



implementation



function CallPascal(const ProcAddress: Pointer;
    const Parameters: Array of LongWord): LongWord;
var ParamCount  : Integer;
    ResultValue : LongWord;
begin
  ParamCount := Length(Parameters);
  asm
      mov edx, dword ptr Parameters
      mov ecx, ParamCount
      test ecx, ecx
      jz @DoCall
    @LeftToRightLoop:
      push dword ptr [edx]
      dec ecx
      jz @DoCall
      add edx, 4
      jmp @LeftToRightLoop
    @DoCall:
      call [ProcAddress]
      mov ResultValue, eax
  end;
  Result := ResultValue;
end;



function CallStdCall(const ProcAddress: Pointer;
    const Parameters: Array of LongWord): LongWord;
var ParamCount  : Integer;
    ResultValue : LongWord;
begin
  ParamCount := Length(Parameters);
  asm
      mov edx, dword ptr Parameters
      mov ecx, ParamCount
      test ecx, ecx
      jz @DoCall
    @PassRightToLeft:
      mov eax, ecx
      dec eax
      shl eax, 2
      add edx, eax
    @RightToLeftLoop:
      push dword ptr [edx]
      dec ecx
      jz @DoCall
      sub edx, 4
      jmp @RightToLeftLoop
    @DoCall:
      call [ProcAddress]
      mov ResultValue, eax
  end;
  Result := ResultValue;
end;



function Call(const Convention: TCallingConvention;
    const ProcAddress: Pointer; const Parameters: Array of LongWord): LongWord;
begin
  Case Convention of
    ccPascal  : Result := CallPascal(ProcAddress, Parameters);
    ccStdCall : Result := CallStdCall(ProcAddress, Parameters);
  else
    raise ECallingConvention.Create('Convention not supported');
  end;
end;



end.
