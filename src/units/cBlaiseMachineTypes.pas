{                                                                              }
{                        Blaise machine base classes v0.01                     }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{            Its original file name is cBlaiseMachineTypes.pas                 }
{                                                                              }
{ Description:                                                                 }
{                                                                              }
{ Revision history:                                                            }
{   08/03/2003  0.01  Created unit cBlaiseMachineTypes from other              }
{                     cBlaiseMachine units.                                    }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineTypes;

interface

uses
  { Delphi }
  SysUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseVMCompiler;



{                                                                              }
{ AIdentifier                                                                  }
{   Base class for an identifier.                                              }
{                                                                              }
{   Evaluate is called by expressions.                                         }
{   Execute and AssignValue are called by statements.                          }
{                                                                              }
{   CallField is called by Identifiers on Identifiers after a call to          }
{   GetValue returned a bfCall FieldType.                                      }
{                                                                              }
type
  AIdentifier = class
  public
    procedure IdentifierError(const Msg: String);
    function  IdentifierDescription: String; virtual; abstract;
    function  GetAsBlaise: String; virtual;

    function  GetValue(const Scope: ABlaiseType; var IdentifierScope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; virtual; abstract;
    function  CallField(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; virtual; abstract;
    function  Evaluate(const Scope: ABlaiseType): TObject; virtual; abstract;
    procedure Execute(const Scope: ABlaiseType); virtual; abstract;
    procedure AssignValue(const Scope: ABlaiseType; const Value: TObject); virtual; abstract;
    function  CreateIdentifierReference(const Scope: ABlaiseType): AValueReference; virtual; abstract;

    procedure CompileEvaluate(const VM: TBlaiseVMCompiler); virtual;
    procedure CompileExecute(const VM: TBlaiseVMCompiler); virtual;
    procedure CompileAssign(const VM: TBlaiseVMCompiler); virtual;
    procedure CompileCallEval(const VM: TBlaiseVMCompiler); virtual;
    procedure CompileCallExec(const VM: TBlaiseVMCompiler); virtual;
  end;
  EIdentifier = class(Exception);



{                                                                              }
{ AExpression                                                                  }
{   Base class for an expression.                                              }
{                                                                              }
type
  AExpression = class
  protected
    procedure EvaluateError(const Msg: String);

  public
    function  GetAsBlaise: String; virtual;

    function  Evaluate(const Scope: ABlaiseType): TObject; virtual; abstract;
    function  EvaluateAsBoolean(const Scope: ABlaiseType): Boolean; virtual;
    function  EvaluateAsInteger(const Scope: ABlaiseType): Int64; virtual;
    function  EvaluateAsString(const Scope: ABlaiseType): String; virtual;
    function  EvaluateAsUTF8(const Scope: ABlaiseType): String; virtual;

    function  Simplify(const Scope: ABlaiseType): AExpression; virtual;

    procedure Compile(const VM: TBlaiseVMCompiler); virtual;
  end;
  AExpressionArray = Array of AExpression;
  EExpression = class(Exception);



{                                                                              }
{ AStatement                                                                   }
{   Base class for a statement.                                                }
{                                                                              }
type
  AStatement = class
  protected
    procedure ExecuteError(const Msg: String);

  public
    procedure Execute(const Scope: ABlaiseType); virtual;
    function  Optimize(const Scope: ABlaiseType): AStatement; virtual;
    procedure Compile(const VM: TBlaiseVMCompiler); virtual;
  end;
  AStatementArray = Array of AStatement;
  EStatement = class(Exception);



implementation

uses
  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseFuncs;



{                                                                              }
{ AIdentifier                                                                  }
{                                                                              }
procedure AIdentifier.IdentifierError(const Msg: String);
begin
  raise EIdentifier.Create(IdentifierDescription + ': ' + Msg);
end;

function AIdentifier.GetAsBlaise: String;
begin
  Result := '_' + BlaiseClassName(self) + '_';
end;

procedure AIdentifier.CompileEvaluate(const VM: TBlaiseVMCompiler);
begin
  raise EIdentifier.Create(ClassName + '.CompileEvaluate not implemented');
end;

procedure AIdentifier.CompileExecute(const VM: TBlaiseVMCompiler);
begin
  raise EIdentifier.Create(ClassName + '.CompileExecute not implemented');
end;

procedure AIdentifier.CompileAssign(const VM: TBlaiseVMCompiler);
begin
  raise EIdentifier.Create(ClassName + '.CompileAssign not implemented');
end;

procedure AIdentifier.CompileCallEval(const VM: TBlaiseVMCompiler);
begin
  raise EIdentifier.Create(ClassName + '.CompileCallEval not implemented');
end;

procedure AIdentifier.CompileCallExec(const VM: TBlaiseVMCompiler);
begin
  raise EIdentifier.Create(ClassName + '.CompileCallExec not implemented');
end;



{                                                                              }
{ AExpression                                                                  }
{                                                                              }
function AExpression.GetAsBlaise: String;
begin
  Result := '_' + StrExclSuffix(BlaiseClassName(self), 'Expression', False) +
            '_';
end;

procedure AExpression.EvaluateError(const Msg: String);
begin
  raise EExpression.Create(Msg);
end;

function AExpression.EvaluateAsBoolean(const Scope: ABlaiseType): Boolean;
var V : TObject;
begin
  V := Evaluate(Scope);
  try
    Result := ObjectGetAsBoolean(V);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function AExpression.EvaluateAsInteger(const Scope: ABlaiseType): Int64;
var V : TObject;
begin
  V := Evaluate(Scope);
  try
    Result := ObjectGetAsInteger(V);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function AExpression.EvaluateAsString(const Scope: ABlaiseType): String;
var V : TObject;
begin
  V := Evaluate(Scope);
  try
    Result := ObjectGetAsString(V);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function AExpression.EvaluateAsUTF8(const Scope: ABlaiseType): String;
var V : TObject;
begin
  V := Evaluate(Scope);
  try
    Result := ObjectGetAsUTF8(V);
  finally
    ObjectReleaseUnreferenced(V);
  end;
end;

function AExpression.Simplify(const Scope: ABlaiseType): AExpression;
begin
  Result := self;
end;

procedure AExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  raise EExpression.Create(ClassName + '.Compile not implemented');
end;



{                                                                              }
{ AStatement                                                                   }
{                                                                              }
procedure AStatement.ExecuteError(const Msg: String);
begin
  raise EStatement.Create(Msg);
end;

procedure AStatement.Execute(const Scope: ABlaiseType);
begin
  raise EStatement.Create(ClassName + '.Execute not implemented');
end;

function AStatement.Optimize(const Scope: ABlaiseType): AStatement;
begin
  Result := self;
end;

procedure AStatement.Compile(const VM: TBlaiseVMCompiler);
begin
  raise EStatement.Create(ClassName + '.Compile not implemented');
end;



end.
