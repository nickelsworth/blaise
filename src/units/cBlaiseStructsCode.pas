{                                                                              }
{                         Blaise code structures v0.01                         }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseStructsCode.pas                 }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise code structures.                               }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseStructsCode from cDataStructs.            }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseStructsCode;

interface

uses
  { Delphi }
  SysUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructs;



{                                                                              }
{ AParameterFieldDefinition                                                    }
{   Base class for a parameter field definition.                               } 
{                                                                              }
type
  AParameterFieldDefinition = class(ASimpleFieldDefinition)
  protected
    FParameterValue : TObject;

  public
    procedure SetParameterValue(const ParameterValue: TObject); virtual;
    function  GetParameterAttributes: TParameterAttributes; virtual;
  end;
  AParameterFieldDefinitionArray = Array of AParameterFieldDefinition;



{                                                                              }
{ TConstantParamaterFieldDefinition                                            }
{   Constant parameter field definition.                                       }
{                                                                              }
type
  TConstantParameterFieldDefinition = class(AParameterFieldDefinition)
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TLocalParamaterFieldDefinition                                               }
{   Local parameter field definition.                                          }
{                                                                              }
type
  TLocalParameterFieldDefinition = class(AParameterFieldDefinition)
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TVariableParamaterFieldDefinition                                            }
{   Variable (reference) parameter field definition.                           }
{                                                                              }
type
  TVariableParameterFieldDefinition = class(AParameterFieldDefinition)
    procedure SetParameterValue(const ParameterValue: TObject); override;
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetParameterAttributes: TParameterAttributes; override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TCodeFrameScope                                                              }
{   Local scope for an code frame (execution frame).                           }
{                                                                              }
type
  TCodeFrameScope = class(TBlaiseScope)
  protected
    FParentScope     : ABlaiseType;
    FDefinitionScope : ABlaiseType;

    procedure CodeFrameError(const Msg: String);

    procedure AddParameterFieldDefinitions(
              const ParameterDefinitions: AParameterFieldDefinitionArray;
              const ParamAttributes: TParameterAttributesArray;
              const ParameterValues: Array of TObject;
              const Scope: ABlaiseType);

  public
    { TCodeFrameScope interface                                                }
    constructor Create(const ParentScope: ABlaiseType;
                const FunctionDefinitionScope: ABlaiseType;
                const ParamDefinition: AParameterFieldDefinitionArray;
                const ParamAttributes: TParameterAttributesArray;
                const Parameters: Array of TObject;
                const LocalDefinitions: AScopeFieldDefinitionArray);

    property  ParentScope: ABlaiseType read FParentScope;
    property  DefinitionScope: ABlaiseType read FDefinitionScope;

    { ABlaiseType implementation                                               }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
  end;
  ECodeFrameScope = class(Exception);



{                                                                              }
{ ACodeFrameScopeFunction                                                      }
{   Base class for a scope function with a local code frame.                   }
{                                                                              }
type
  ACodeFrameScopeFunction = class(AFunction)
  protected
    FDefinitionScope : ABlaiseType;
    FParamDefinition : AParameterFieldDefinitionArray;
    FLocalDefinition : AScopeFieldDefinitionArray;
    FParamAttributes : TParameterAttributesArray;

  public
    constructor Create(const DefinitionScope: ABlaiseType;
        const ParamDefinition: AParameterFieldDefinitionArray;
        const LocalDefinition: AScopeFieldDefinitionArray);

    function  GetParameters: TParameterAttributesArray; override;
    function  CreateLocalScope(const Scope: ABlaiseType;
              const Parameters: Array of TObject): ABlaiseType; override;
  end;



implementation

uses
  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseConsts,
  cBlaiseStructsObject,
  cBlaiseFuncs;



{                                                                              }
{ AParameterFieldDefinition                                                    }
{                                                                              }
procedure AParameterFieldDefinition.SetParameterValue(const ParameterValue: TObject);
begin
  FParameterValue := ParameterValue;
end;

function AParameterFieldDefinition.GetParameterAttributes: TParameterAttributes;
begin
  if Assigned(FValue) then
    Result := [paOptional] else
    Result := [];
end;



{                                                                              }
{ TConstantParameterFieldDefinition                                            }
{                                                                              }
procedure TConstantParameterFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  if Assigned(FTypeDefinition) then
    FTypeDefinition.SetDefinitionScope(DefinitionScope);
  if Assigned(FParameterValue) then
    FieldScope.AddConstant(FIdentifier, FTypeDefinition, FParameterValue) else
    FieldScope.AddConstant(FIdentifier, FTypeDefinition, FValue);
end;

function TConstantParameterFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_PAR_CONST;
end;



{                                                                              }
{ TLocalParameterFieldDefinition                                               }
{                                                                              }
procedure TLocalParameterFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  if Assigned(FTypeDefinition) then
    FTypeDefinition.SetDefinitionScope(DefinitionScope);
  if Assigned (FParameterValue) then
    FieldScope.AddVariable(FIdentifier, FTypeDefinition, FParameterValue) else
    FieldScope.AddVariable(FIdentifier, FTypeDefinition, FValue);
end;

function TLocalParameterFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_PAR_LOCAL;
end;



{                                                                              }
{ TVariableParameterFieldDefinition                                            }
{                                                                              }
procedure TVariableParameterFieldDefinition.SetParameterValue(const ParameterValue: TObject);
begin
  if not (ParameterValue is AValueReference) then
    RaiseError('Parameter value not a reference');
  inherited SetParameterValue(ParameterValue);
end;

procedure TVariableParameterFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  if Assigned(FTypeDefinition) then
    FTypeDefinition.SetDefinitionScope(DefinitionScope);
  if Assigned(FParameterValue) then
    FieldScope.AddVariable(FIdentifier, FTypeDefinition, FParameterValue) else
    FieldScope.AddVariable(FIdentifier, FTypeDefinition, FValue);
end;

function TVariableParameterFieldDefinition.GetParameterAttributes: TParameterAttributes;
begin
  Result := inherited GetParameterAttributes + [paReference];
end;

function TVariableParameterFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_PAR_VAR;
end;



{                                                                              }
{ TCodeFrameScope                                                              }
{                                                                              }
constructor TCodeFrameScope.Create(const ParentScope: ABlaiseType;
    const FunctionDefinitionScope: ABlaiseType;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const ParamAttributes: TParameterAttributesArray;
    const Parameters: Array of TObject;
    const LocalDefinitions: AScopeFieldDefinitionArray);
begin
  inherited Create;
  FParentScope := ParentScope;
  if ParentScope is TClassType then // class method
    FDefinitionScope := TClassType(ParentScope).DefinitionScope else
  if ParentScope is TTObject then // object method
    FDefinitionScope := TTObject(ParentScope)._ClassType.DefinitionScope else
  if ParentScope is TInheritedObjectScope then // inherited method
    FDefinitionScope := TInheritedObjectScope(ParentScope)._ClassType.DefinitionScope
  else
    begin
      FParentScope := nil;
      FDefinitionScope := FunctionDefinitionScope;
    end;
  AddParameterFieldDefinitions(ParamDefinition, ParamAttributes, Parameters,
      FunctionDefinitionScope);
  ScopeAddFieldDefinitions(self, LocalDefinitions, self);
end;

procedure TCodeFrameScope.CodeFrameError(const Msg: String);
begin
  raise ECodeFrameScope.Create (Msg);
end;

procedure TCodeFrameScope.AddParameterFieldDefinitions(
    const ParameterDefinitions: AParameterFieldDefinitionArray;
    const ParamAttributes: TParameterAttributesArray;
    const ParameterValues: Array of TObject; const Scope: ABlaiseType);
var I, L, M : Integer;
begin
  ValidateParameters(ParamAttributes, ParameterValues);
  L := Length(ParameterValues);
  M := Length(ParameterDefinitions);
  For I := 0 to MinI(L, M) - 1 do
    ParameterDefinitions[I].SetParameterValue(ParameterValues [I]);
  For I := L to M - 1 do
    ParameterDefinitions[I].SetParameterValue(nil);
  ScopeAddFieldDefinitions(self, AScopeFieldDefinitionArray(ParameterDefinitions), Scope);
end;

function TCodeFrameScope.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  // Check code frame's local scope
  Result := inherited GetField(FieldName, Scope, FieldType);
  if Assigned(Scope) then
    exit;
  // Check parent scope
  if Assigned(FParentScope) then
    begin
      Result := FParentScope.GetField(FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end; 
  // Check definition scope
  if Assigned(FDefinitionScope) then
    begin
      Result := FDefinitionScope.GetField(FieldName, Scope, FieldType);
      if Assigned(Scope) then
        exit;
    end;
end;



{                                                                              }
{ ACodeFrameScopeFunction                                                      }
{                                                                              }
constructor ACodeFrameScopeFunction.Create(const DefinitionScope: ABlaiseType;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray);
var I, L : Integer;
begin
  inherited Create;
  FDefinitionScope := DefinitionScope;
  FParamDefinition := ParamDefinition;
  FLocalDefinition := LocalDefinition;
  L := Length(FParamDefinition);
  SetLength(FParamAttributes, L);
  For I := 0 to L - 1 do
    FParamAttributes[I] := FParamDefinition[I].GetParameterAttributes;
end;

function ACodeFrameScopeFunction.GetParameters: TParameterAttributesArray;
begin
  Result := FParamAttributes;
end;

function ACodeFrameScopeFunction.CreateLocalScope(const Scope: ABlaiseType;
    const Parameters: Array of TObject): ABlaiseType;
begin
  Result := TCodeFrameScope.Create(Scope, FDefinitionScope, FParamDefinition,
      FParamAttributes, Parameters, FLocalDefinition);
end;



end.

