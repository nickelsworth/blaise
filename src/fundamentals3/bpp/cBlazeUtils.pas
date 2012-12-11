{                                                                              }
{                     Blaze Peering Protocol Utilities v0.02                   }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{ Description:                                                                 }
{   Constants, structures and helper functions for the Blaze Peering           }
{   Protocol (BPP).                                                            }
{                                                                              }
{ Revision history:                                                            }
{   03/05/2003  0.01  Initial version.                                         }
{   04/08/2003  0.02  Revision.                                                }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cBlazeUtils;

interface

uses
  { Delphi }
  SysUtils;



{                                                                              }
{ Errors                                                                       }
{                                                                              }
const
  BPP_ERR_None           = $0000;

  BPP_ERR_MessageFormat  = $0100;
  BPP_ERR_InvalidMessage = $0101;
  BPP_ERR_OutOfSync      = $0102;

  BPP_ERR_ControlChannel = $0200;
  BPP_ERR_JoinFailed     = $0201;
  BPP_ERR_LeaveFailed    = $0202;

function bppErrorMessage(const ErrorCode: Integer): String;

type
  Ebpp = class(Exception)
  protected
    FErrorCode : Integer;
  public
    constructor Create(const ErrorCode: Integer; const ErrorMsg: String = '');
    property ErrorCode: Integer read FErrorCode;
  end;



implementation



{                                                                              }
{ Errors                                                                       }
{                                                                              }
function bppErrorMessage(const ErrorCode: Integer): String;
begin
  Case ErrorCode of
    BPP_ERR_None           : Result := '';
    BPP_ERR_InvalidMessage : Result := 'Invalid message';
    BPP_ERR_OutOfSync      : Result := 'Peers out of synchronization';
    BPP_ERR_JoinFailed     : Result := 'Join operation failed';
    BPP_ERR_LeaveFailed    : Result := 'Leave operation failed';
  else
    Case (ErrorCode div $100) * $100 of
      BPP_ERR_MessageFormat  : Result := 'Bad message format';
      BPP_ERR_ControlChannel : Result := 'Control channel operation failed';
    else
      Result := 'Blaze error: ' + IntToStr(ErrorCode);
    end;
  end;
end;

constructor Ebpp.Create(const ErrorCode: Integer; const ErrorMsg: String);
var S : String;
begin
  FErrorCode := ErrorCode;
  if ErrorMsg = '' then
    S := bppErrorMessage(ErrorCode) else
    S := ErrorMsg;
  inherited Create(S);
end;



end.

