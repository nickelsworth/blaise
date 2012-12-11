{$INCLUDE ..\cDefines.inc}
unit cTypes;

{                                                                              }
{                            Type base class v3.04                             }
{                                                                              }
{             This unit is copyright � 1999-2003 by David J Butler             }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{                    Its original file name is cTypes.pas                      }
{       The latest version is available from the Fundamentals home page        }
{                     http://fundementals.sourceforge.net/                     }
{                                                                              }
{                I invite you to use this unit, free of charge.                }
{        I invite you to distibute this unit, but it must be for free.         }
{             I also invite you to contribute to its development,              }
{             but do not distribute a modified copy of this file.              }
{                                                                              }
{          A forum is available on SourceForge for general discussion          }
{             http://sourceforge.net/forum/forum.php?forum_id=2117             }
{                                                                              }
{                                                                              }
{ Revision history:                                                            }
{   1999/11/12  0.01  Split cTypes from cDataStruct and cHolder.               }
{                     Default implementations for Assign, IsEqual              }
{   2001/07/30  1.02  Removed interfaces in AType (each interface adds four    }
{                     bytes to the instance size).                             }
{   2001/08/20  2.03  Merged cTypes and cDataStructs to allow object           }
{                     interface implementation in base classes.                }
{   2002/05/15  3.04  Split cTypes from cDataStructs.                          }
{                                                                              }

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils;



{                                                                              }
{ Note on class naming convention:                                             }
{   Classes with the A-prefix are abstract base classes. They define the       }
{   interface for the type and must never be instanciated.                     }
{                                                                              }



{                                                                              }
{ AType                                                                        }
{   Abstract base class for data structures.                                   }
{                                                                              }
{   Provides an interface for commonly used data operations such as            }
{   assigning, comparing and duplicating.                                      }
{                                                                              }
{   Duplicate creates a new instance of the object (using CreateInstance) and  }
{   then copies the content (using Assign). Implementations do not have to     }
{   override Duplicate if both CreateInstance and Assign are implemented.      }
{   Assign's default implementation calls the protected AssignTo.              }
{                                                                              }
{   Clear sets an instance's content (value) to an empty/zero state. This      }
{   state should be similar to the state of a new instance created using       }
{   CreateInstance.                                                            }
{                                                                              }
{   IsEqual compares content of instances. After a call to Assign, an          }
{   equivalent call to IsEqual should return True.                             }
{                                                                              }
{   Compare is the ranking function used by sorting and searching.             }
{                                                                              }
type
  AType = class
  protected
    procedure TypeError(const Msg: String; const Error: Exception = nil;
              const ErrorClass: ExceptClass = nil); virtual;
    procedure MethodNotImplementedError(const Method: String);

    procedure Init; virtual;
    procedure AssignTo(const Dest: TObject); virtual;

    function  GetAsString: String; virtual;
    procedure SetAsString(const S: String); virtual;

  public
    constructor Create;
    class function CreateInstance: AType; virtual;

    function  Duplicate: TObject; virtual;
    procedure Assign(const Source: TObject); virtual;
    procedure Clear; virtual;
    function  IsEmpty: Boolean; virtual;
    function  IsEqual(const V: TObject): Boolean; virtual;
    function  Compare(const V: TObject): TCompareResult; virtual;
    function  HashValue: LongWord; virtual;
    property  AsString: String read GetAsString write SetAsString;
  end;
  EType = class(Exception);
  TypeClass = class of AType;
  ATypeArray = Array of AType;
  TypeClassArray = Array of TypeClass;



{                                                                              }
{ AType helper functions                                                       }
{                                                                              }
function  TypeDuplicate(const V: TObject): TObject;
procedure TypeAssign(const A, B: TObject);
procedure TypeClear(const V: TObject);
function  TypeIsEqual(const A, B: TObject): Boolean;
function  TypeCompare(const A, B: TObject): TCompareResult;
function  TypeHashValue(const A: TObject): LongWord;
function  TypeGetAsString(const V: TObject): String;
procedure TypeSetAsString(const V: TObject; const S: String);



implementation



{                                                                              }
{ AType                                                                        }
{                                                                              }
constructor AType.Create;
begin
  inherited Create;
  Init;
end;

procedure AType.Init;
begin
end;

procedure AType.TypeError(const Msg: String; const Error: Exception;
    const ErrorClass: ExceptClass);
var S: String;
begin
  S := Msg;
  if Assigned(Error) then
    S := S + ': ' + Error.Message;
  if Assigned(ErrorClass) then
    raise ErrorClass.Create(S)
  else
    raise EType.Create(S);
end;

procedure AType.MethodNotImplementedError(const Method: String);
begin
  TypeError('Method ' + ClassName + '.' + Method + ' not implemented');
end;

class function AType.CreateInstance: AType;
begin
  Result := AType(TypeClass(self).Create);
end;

procedure AType.Clear;
begin
  MethodNotImplementedError('Clear');
end;

{$WARNINGS OFF}
function AType.IsEmpty: Boolean;
begin
  MethodNotImplementedError('IsEmpty');
end;
{$WARNINGS ON}

function AType.Duplicate: TObject;
begin
  try
    Result := CreateInstance;
    try
      AType(Result).Assign(self);
    except
      FreeAndNil(Result);
      raise;
    end;
  except
    on E: Exception do TypeError('Duplicate failed', E);
  end;
end;

procedure AType.Assign(const Source: TObject);
var R : Boolean;
begin
  if Source is AType then
    try
      AType(Source).AssignTo(self);
      R := True;
    except
      R := False;
    end else
    R := False;
  if not R then
    TypeError(ClassName + ' cannot assign from ' + ObjectClassName(Source));
end;

procedure AType.AssignTo(const Dest: TObject);
begin
  TypeError(ClassName + ' cannot assign to ' + ObjectClassName(Dest));
end;

{$WARNINGS OFF}
function AType.IsEqual(const V: TObject): Boolean;
begin
  TypeError(ClassName + ' cannot compare with ' + ObjectClassName(V));
end;

function AType.Compare(const V: TObject): TCompareResult;
begin
  TypeError(ClassName + ' cannot compare with ' + ObjectClassName(V));
end;

function AType.HashValue: LongWord;
begin
  try
    Result := HashStr(GetAsString, MaxLongWord, True);
  except
    on E : Exception do TypeError('Hash error', E);
  end;
end;
{$WARNINGS ON}

function AType.GetAsString: String;
begin
  MethodNotImplementedError('GetAsString');
end;

procedure AType.SetAsString(const S: String);
begin
  MethodNotImplementedError('SetAsString');
end;



{                                                                              }
{ AType helper functions                                                       }
{                                                                              }
function TypeGetAsString(const V: TObject): String;
begin
  if V is AType then
    Result := AType(V).GetAsString
  else
    raise EType.Create(ObjectClassName(V) + ' cannot convert to string');
end;

procedure TypeSetAsString(const V: TObject; const S: String);
begin
  if V is AType then
    AType(V).SetAsString(S)
  else
    raise EType.Create(ObjectClassName(V) + ' cannot set as string');
end;

function TypeDuplicate(const V: TObject): TObject;
begin
  if V is AType then
    Result := AType(V).Duplicate else
  if not Assigned(V) then
    Result := nil
  else
    raise EType.Create(ObjectClassName(V) + ' cannot duplicate');
end;

procedure TypeClear(const V: TObject);
begin
  if V is AType then
    AType(V).Clear else
  if Assigned(V) then
    raise EType.Create(ObjectClassName(V) + ' cannot clear');
end;

function TypeIsEqual(const A, B: TObject): Boolean;
begin
  if A = B then
    Result := True else
  if not Assigned(A) or not Assigned(B) then
    Result := False else
  if A is AType then
    Result := AType(A).IsEqual(B) else
  if B is AType then
    Result := AType(B).IsEqual(A)
  else
    raise EType.Create(ObjectClassName(A) + ' and ' + ObjectClassName(B) +
        ' cannot compare');
end;

function TypeCompare(const A, B: TObject): TCompareResult;
begin
  if A = B then
    Result := crEqual else
  if A is AType then
    Result := AType(A).Compare(B) else
  if B is AType then
    Result := ReverseCompareResult(AType(B).Compare(A))
  else
    Result := crUndefined;
end;

procedure TypeAssign(const A, B: TObject);
begin
  if A = B then
    exit else
  if A is AType then
    AType(A).Assign(B) else
  if B is AType then
    AType(B).AssignTo(A)
  else
    raise EType.Create(ObjectClassName(A) + ' cannot assign ' +
        ObjectClassName(B));
end;

function TypeHashValue(const A: TObject): LongWord;
begin
  if not Assigned(A) then
    Result := 0 else
  if A is AType then
    Result := AType(A).HashValue
  else
    raise EType.Create(A.ClassName + ' cannot calculate hash value');
end;



end.

