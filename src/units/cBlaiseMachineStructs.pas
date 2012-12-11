{                                                                              }
{                      Blaise machine data structures v0.02                    }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{           Its original file name is cBlaiseMachineStructs.pas                }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise data structures from the machine layer.        }
{                                                                              }
{ Revision history:                                                            }
{   11/05/2003  0.01  Initial version.                                         }
{   25/05/2003  0.02  Improvements.                                            }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineStructs;

interface

uses
  { Blaise }
  cBlaiseTypes,
  cBlaiseMachineTypes;



{                                                                              }
{ TExpressionType                                                              }
{   Type definition for an expression.                                         }
{                                                                              }
type
  TExpressionType = class(ALocalisedTypeDefinition)
  public
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  GetTypeDefID: Byte; override;
  end;



{                                                                              }
{ TTExpression                                                                 }
{   Implementation of an expression structure.                                 }
{                                                                              }
type
  TTExpression = class(ABlaiseType)
  protected
    FDefinitionScope : ABlaiseType;
    FExpression      : AExpression;

    procedure SetExpression(const Expression: AExpression);

    function  GetAsUTF8: String; override;
    procedure SetAsUTF8(const S: String); override;
    function  GetAsBlaise: String; override;

  public
    constructor Create(const DefinitionScope: ABlaiseType);
    destructor Destroy; override;

    function  Eval(const Scope: ABlaiseType): TObject;

    procedure Assign(const Source: TObject); override;
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ TEvalFunction                                                                }
{   Built-in Eval function.                                                    }
{                                                                              }
type
  TEvalFunction = class(AFunction)
  protected
    FParams : TParameterAttributesArray;

  public
    constructor Create;
    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructsSimple,
  cBlaiseParser;



{                                                                              }
{ TExpressionType                                                              }
{                                                                              }
function TExpressionType.CreateTypeInstance: TObject;
begin
  Result := TTExpression.Create(FDefinitionScope);
end;

function TExpressionType.IsType(const Value: TObject): Boolean;
begin
  Result := Value is TTExpression;
end;

function TExpressionType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Expression;
end;



{                                                                              }
{ TTExpression                                                                 }
{                                                                              }
constructor TTExpression.Create(const DefinitionScope: ABlaiseType);
begin
  inherited Create;
  FDefinitionScope := DefinitionScope;
end;

destructor TTExpression.Destroy;
begin
  FreeAndNil(FExpression);
  inherited Destroy;
end;

procedure TTExpression.SetExpression(const Expression: AExpression);
begin
  FreeAndNil(FExpression);
  FExpression := Expression;
end;

function TTExpression.GetAsUTF8: String;
begin
  if Assigned(FExpression) then
    Result := FExpression.GetAsBlaise
  else
    Result := '';
end;

procedure TTExpression.SetAsUTF8(const S: String);
begin
  SetExpression(ParseBlaiseScriptExpression(S).GetAsExpression);
end;

function TTExpression.GetAsBlaise: String;
begin
  Result := 'Expression(' + StrQuote(GetAsUTF8, '''') + ')';
end;

procedure TTExpression.Assign(const Source: TObject);
begin
  if Source is TTString then
    SetAsString(TTString(Source).AsString)
  else
    inherited Assign(Source);
end;

function TTExpression.Eval(const Scope: ABlaiseType): TObject;
begin
  if not Assigned(FExpression) then
    raise EBlaiseType.Create('No expression');
  Result := FExpression.Evaluate(Scope);
end;

function TTExpression.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Eval') then
    begin
      Scope := self;
      FieldType := bfObject;
      Result := Eval(FDefinitionScope);
    end else
  if StrEqualNoCase(FieldName, 'ExprType') then
    begin
      Scope := self;
      FieldType := bfObject;
      Result := TTString.Create(BlaiseClassName(FExpression));
    end else
  if StrEqualNoCase(FieldName, 'Simplify') then
    begin
      Scope := self;
      FieldType := bfCall;
      Result := nil;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

function TTExpression.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  if StrEqualNoCase(FieldName, 'Simplify') then
    begin
      ValidateParamCount(0, 0, Parameters);
      if Assigned(FExpression) then
        FExpression := FExpression.Simplify(FDefinitionScope);
      Result := nil;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function TTExpression.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Expression;
end;



{                                                                              }
{ TEvalFunction                                                                }
{                                                                              }
constructor TEvalFunction.Create;
begin
  inherited Create;
  SetLength(FParams, 1);
  FParams[0] := [];
end;

function TEvalFunction.GetParameters: TParameterAttributesArray;
begin
  Result := FParams;
end;

function TEvalFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
var S : String;
    E : TTExpression;
begin
  ValidateParameters(FParams, Parameters);
  S := ObjectGetAsString(Parameters[0]);
  E := TTExpression.Create(nil);
  try
    E.SetAsString(S);
    Result := E.Eval(Scope);
  finally
    E.Free;
  end;
end;



end.
