{                                                                              }
{                    Blaise syntactic declaration nodes v0.01                  }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseParserNodesDecl.pas             }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise syntactic type nodes and Blaise syntactic      }
{   declaration nodes.                                                         }
{                                                                              }
{ Revision history:                                                            }
{   14/04/2003  0.01  Created unit cBlaiseParserNodesDecl from unit            }
{                     cBlaiseParserNodes.                                      }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseParserNodesDecl;

interface

uses
  { Fundamentals }
  cCallConventions,

  { Blaise }
  cBlaiseParserNodes,
  cBlaiseTypes,
  cBlaiseStructs,
  cBlaiseStructsCode;



{                                                                              }
{ === Type nodes ===                                                           }
{                                                                              }

{                                                                              }
{ TIdentifierTypeNode                                                          }
{                                                                              }
type
  TIdentifierTypeNode = class(ATypeNode)
  protected
    FIdentifier : String;

  public
    constructor Create(const Identifier: String);
    function  GetNodeParameterStr: String; override;
    function  GetAsTypeDefinition: ATypeDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TArrayTypeNode                                                               }
{                                                                              }
type
  TArrayTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TDictionaryTypeNode                                                          }
{                                                                              }
type
  TDictionaryTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TRecordTypeNode                                                              }
{                                                                              }
type
  TRecordTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TClassTypeNode                                                               }
{                                                                              }
type
  AClassSectionNode = class(ABlaiseScriptNode)
  public
    procedure GetDefinitions(var ClassDef, InstanceDef: AScopeFieldDefinitionArray);
  end;
  TPrivateSection = class(AClassSectionNode);
  TProtectedSection = class(AClassSectionNode);
  TPublicSection = class(AClassSectionNode);
  AClassSectionNodeArray = Array of AClassSectionNode;

  TClassTypeNode = class(TRecordTypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TEnumeratedTypeNode                                                          }
{                                                                              }
type
  TEnumeratedTypeValueNode = class(ABlaiseScriptNode)
  public
    function  GetAsEnumeratedValueDefinition(
              const NextValue: Int64): TEnumeratedValueDefinition;
  end;

  TEnumeratedTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
  end;
  TEnumeratedTypeValueNodeArray = Array of TEnumeratedTypeValueNode;



{                                                                              }
{ TRangeTypeNode                                                               }
{                                                                              }
type
  TRangeTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
  end;



{                                                                              }
{ TStreamTypeNode                                                              }
{                                                                              }
type
  TStreamTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TUntypedTypeNode                                                             }
{   Special type node to indicate an untyped declaration.                      }
{                                                                              }
type
  TUntypedTypeNode = class(ATypeNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; override;
  end;



{                                                                              }
{ === Declaration Nodes ===                                                    }
{                                                                              }

{                                                                              }
{ AMultipleDeclarationNode                                                     }
{                                                                              }
type
  AMultipleDeclarationNode = class(ADeclarationNode)
  protected
    function  GetSourceKeyword: String; virtual; abstract;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition; const Value: TObject):
              AScopeFieldDefinition; virtual; abstract;
    function  GetAsFieldDefinitions: AScopeFieldDefinitionArray; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TRecordFieldDefinitionNode                                                   }
{                                                                              }
type
  TRecordFieldDefinitionNode = class(AMultipleDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition;
              const Value: TObject): AScopeFieldDefinition; override;
  end;
  TRecordFieldDefinitionNodeArray = Array of TRecordFieldDefinitionNode;



{                                                                              }
{ TVariableDeclaration                                                         }
{                                                                              }
type
  TVariableDeclaration = class(AMultipleDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition;
              const Value: TObject): AScopeFieldDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TConstDeclaration                                                            }
{                                                                              }
type
  TConstDeclaration = class(AMultipleDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition;
              const Value: TObject): AScopeFieldDefinition; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TTypeDeclaration                                                             }
{                                                                              }
type
  TTypeDeclaration = class(ADeclarationNode)
  public
    function  GetAsFieldDefinitions: AScopeFieldDefinitionArray; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ AParameterDefinitionNode                                                     }
{                                                                              }
type
  AParameterDefinitionNode = class(AMultipleDeclarationNode);
  AParameterDefinitionNodeArray = Array of AParameterDefinitionNode;



{                                                                              }
{ TConstParamDefinition                                                        }
{                                                                              }
type
  TConstParamDefinition = class(AParameterDefinitionNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition;
              const Value: TObject): AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TVarParamDefinition                                                          }
{                                                                              }
type
  TVarParamDefinition = class(AParameterDefinitionNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition;
              const Value: TObject): AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TLocalParamDefinition                                                        }
{                                                                              }
type
  TLocalParamDefinition = class(AParameterDefinitionNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetFieldDefinition(const Identifier: String;
              const TypeDef: ATypeDefinition;
              const Value: TObject): AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TFunctionPrototypeNode                                                       }
{                                                                              }
type
  TFunctionPrototypeNode = class(ABlaiseScriptNode)
  public
    function  GetParameterFieldDefinitions: AParameterFieldDefinitionArray;
    procedure GetIdentifiers(var ClassIdentifier, Identifier: String);
    procedure WriteIdentifierSource(const Writer: ASourceWriter);
    procedure WriteParametersSource(const Writer: ASourceWriter);
    function  MatchPrototype(const Prototype: ABlaiseScriptNode): Boolean; virtual;
  end;



{                                                                              }
{ Function directives                                                          }
{                                                                              }
type
  ADirectiveNode = class(ABlaiseScriptNode);
  TOverloadDirectiveNode = class(ADirectiveNode);
  TOverrideDirectiveNode = class(ADirectiveNode);
  TVirtualDirectiveNode = class(ADirectiveNode);
  TAbstractDirectiveNode = class(ADirectiveNode);
  TReintroduceDirectiveNode = class(ADirectiveNode);

  ACallingConventionNode = class(ABlaiseScriptNode)
    function  GetCallingConvention: TCallingConvention; virtual; abstract;
  end;
  TCDeclCallingNode = class(ACallingConventionNode)
    function  GetCallingConvention: TCallingConvention; override;
  end;
  TPascalCallingNode = class(ACallingConventionNode)
    function  GetCallingConvention: TCallingConvention; override;
  end;
  TRegisterCallingNode = class(ACallingConventionNode)
    function  GetCallingConvention: TCallingConvention; override;
  end;
  TStdCallCallingNode = class(ACallingConventionNode)
    function  GetCallingConvention: TCallingConvention; override;
  end;
  TSafeCallCallingNode = class(ACallingConventionNode)
    function  GetCallingConvention: TCallingConvention; override;
  end;

  TExternalDirectiveNode = class(ABlaiseScriptNode)
    LibraryName : String;
  end;
  TNameDirectiveNode = class(ABlaiseScriptNode)
    ExternalName : String;
  end;

  TFunctionDirectivesNode = class(ABlaiseScriptNode)
    function  IsExternal: Boolean;
  end;



{                                                                              }
{ AFunctionDeclarationNode                                                     }
{                                                                              }
type
  AFunctionDeclarationNode = class(ADeclarationNode)
  protected
    function  GetSourceKeyword: String; virtual; abstract;
    procedure WriteStatementSource(const Writer: ASourceWriter);
    procedure WriteBodySource(const Writer: ASourceWriter); virtual;

    function  GetAsFunctionDefinition(const Prototype: TFunctionPrototypeNode;
              const ClassIdentifier, Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LocalDefinition: AScopeFieldDefinitionArray):
              AScopeFieldDefinition; virtual; abstract;
    function  GetAsExternalDefinition(const Prototype: TFunctionPrototypeNode;
              const Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LibraryName, FunctionName: String;
              const Convention: TCallingConvention):
              AScopeFieldDefinition; virtual;

  public
    function  GetAsFieldDefinitions: AScopeFieldDefinitionArray; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
    function  GetPrototype: TFunctionPrototypeNode;
  end;



{                                                                              }
{ TProcedureDeclarationNode                                                    }
{                                                                              }
type
  TProcedureDeclarationNode = class(AFunctionDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetAsFunctionDefinition(const Prototype: TFunctionPrototypeNode;
              const ClassIdentifier, Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LocalDefinition: AScopeFieldDefinitionArray):
              AScopeFieldDefinition; override;
    function  GetAsExternalDefinition(const Prototype: TFunctionPrototypeNode;
              const Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LibraryName, FunctionName: String;
              const Convention: TCallingConvention):
              AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TFunctionDeclarationNode                                                     }
{                                                                              }
type
  TFunctionDeclarationNode = class(AFunctionDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetAsFunctionDefinition(const Prototype: TFunctionPrototypeNode;
              const ClassIdentifier, Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LocalDefinition: AScopeFieldDefinitionArray):
              AScopeFieldDefinition; override;
    function  GetAsExternalDefinition(const Prototype: TFunctionPrototypeNode;
              const Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LibraryName, FunctionName: String;
              const Convention: TCallingConvention):
              AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TTaskDeclarationNode                                                         }
{                                                                              }
type
  TTaskDeclarationNode = class(AFunctionDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetAsFunctionDefinition(const Prototype: TFunctionPrototypeNode;
              const ClassIdentifier, Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LocalDefinition: AScopeFieldDefinitionArray):
              AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TConstructorDeclarationNode                                                  }
{                                                                              }
type
  TConstructorDeclarationNode = class(AFunctionDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetAsFunctionDefinition(const Prototype: TFunctionPrototypeNode;
              const ClassIdentifier, Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LocalDefinition: AScopeFieldDefinitionArray):
              AScopeFieldDefinition; override;
  end;



{                                                                              }
{ TDestructorDeclarationNode                                                   }
{                                                                              }
type
  TDestructorDeclarationNode = class(AFunctionDeclarationNode)
  protected
    function  GetSourceKeyword: String; override;

  public
    function  GetAsFunctionDefinition(const Prototype: TFunctionPrototypeNode;
              const ClassIdentifier, Identifier: String;
              const ParamDefinition: AParameterFieldDefinitionArray;
              const LocalDefinition: AScopeFieldDefinitionArray):
              AScopeFieldDefinition; override;
  end;



{                                                                              }
{ ADirective                                                                   }
{                                                                              }
type
  ADirective = class(ABlaiseScriptNode);
  TPersistDirective = class(ADirective);



implementation

uses
  { Fundamentals }
  cUtils,
  cStrings,

  { Blaise }
  cBlaiseFuncs,
  cBlaiseStructsSimple,
  cBlaiseStructsCollections,
  cBlaiseStructsObject,
  cBlaiseMachine,
  cBlaiseMachineCode,
  cBlaiseParserLexer;



{                                                                              }
{ TIdentifierTypeNode                                                          }
{                                                                              }
constructor TIdentifierTypeNode.Create(const Identifier: String);
begin
  inherited Create;
  FIdentifier := Identifier;
end;

function TIdentifierTypeNode.GetNodeParameterStr: String;
begin
  Result := FIdentifier;
end;

function TIdentifierTypeNode.GetAsTypeDefinition: ATypeDefinition;
begin
  Result := TIdentifierType.Create(FIdentifier);
end;

procedure TIdentifierTypeNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Identifier(FIdentifier);
end;



{                                                                              }
{ TArrayTypeNode                                                               }
{                                                                              }
function TArrayTypeNode.GetAsTypeDefinition: ATypeDefinition;
begin
  Result := TArrayType.Create(GetOptionalTypeDefinition);
end;

procedure TArrayTypeNode.WriteSource(const Writer: ASourceWriter);
var T : ATypeNode;
begin
  T := GetTypeNode;
  With Writer do
    begin
      Keyword(c_Array);
      if Assigned(T) then
        begin
          Space;
          Keyword(c_Of);
          Space;
          T.WriteSource(Writer);
        end;
    end;
end;


{                                                                              }
{ TDictionaryTypeNode                                                          }
{                                                                              }
function TDictionaryTypeNode.GetAsTypeDefinition: ATypeDefinition;
var K, V : ATypeDefinition;
begin
  GetTwoTypeDefinitions(K, V);
  Result := TDictionaryType.Create(K, V);
end;

procedure TDictionaryTypeNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Dictionary);
end;



{                                                                              }
{ TRecordTypeNode                                                              }
{                                                                              }
function TRecordTypeNode.GetAsTypeDefinition: ATypeDefinition;
begin
  Result := TRecordType.Create(nil, TRecordFieldFieldDefinitionArray(
      GetFieldDefinitions(TRecordFieldDefinitionNode)));
end;

procedure TRecordTypeNode.WriteSource(const Writer: ASourceWriter);
var N : TRecordFieldDefinitionNodeArray;
    I : Integer;
begin
  N := TRecordFieldDefinitionNodeArray(GetChildNodes(TRecordFieldDefinitionNode));
  With Writer do
    begin
      Keyword(c_Record);
      Indent;
      For I := 0 to Length(N) - 1 do
        begin
          NewLine;
          N[I].WriteSource(Writer);
        end;
      Unindent;
      Keyword(c_End);
    end;
end;



{                                                                              }
{ TClassTypeNode                                                               }
{                                                                              }
procedure AClassSectionNode.GetDefinitions(
    var ClassDef, InstanceDef: AScopeFieldDefinitionArray);
var D : AScopeFieldDefinitionArray;
begin
  D := GetFieldDefinitions(ADeclarationNode);
  AppendObjectArray(ObjectArray(InstanceDef), ObjectArray(D));
end;

function TClassTypeNode.GetAsTypeDefinition: ATypeDefinition;
var S    : AClassSectionNodeArray;
    P    : StringArray;
    C, N : AScopeFieldDefinitionArray;
    I    : Integer;
begin
  S := AClassSectionNodeArray(GetChildNodes(AClassSectionNode));
  P := GetSimpleIdentifierValues;
  SetLength(C, 0);
  SetLength(N, 0);
  For I := 0 to Length(S) - 1 do
    S[I].GetDefinitions(C, N);
  Result := TClassType.Create(P, C, N)
end;

procedure TClassTypeNode.WriteSource(const Writer: ASourceWriter);
var S    : AClassSectionNodeArray;
    P    : StringArray;
    I, L : Integer;
begin
  S := AClassSectionNodeArray(GetChildNodes(AClassSectionNode));
  P := GetSimpleIdentifierValues;
  Writer.Keyword(c_Class);
  L := Length(P);
  if L > 0 then
    begin
      Writer.Symbol('(');
      For I := 0 to L - 1 do
        begin
          if I > 0 then
            begin
              Writer.Symbol(',');
              Writer.Space;
            end;
          Writer.Identifier(P[I]);
        end;
      Writer.Symbol(')');
    end;
  For I := 0 to Length(S) - 1 do
    S[I].WriteSource(Writer);
end;



{                                                                              }
{ TEnumeratedTypeValueNode                                                     }
{                                                                              }
function TEnumeratedTypeValueNode.GetAsEnumeratedValueDefinition(
    const NextValue: Int64): TEnumeratedValueDefinition;
var V: TObject;
begin
  Result.Identifier := GetSimpleIdentifierValue(1, True);
  V := GetOptionalExpressionEvaluated(nil);
  if not Assigned(V) then
    Result.Value := NextValue
  else
    try
      Result.Value := ObjectGetAsInteger(V);
    finally
      ObjectReleaseUnreferenced(V);
    end;
end;



{                                                                              }
{ TEnumeratedTypeNode                                                          }
{                                                                              }
function TEnumeratedTypeNode.GetAsTypeDefinition: ATypeDefinition;
var N      : TEnumeratedTypeValueNodeArray;
    ValDef : TEnumeratedValueDefinitionArray;
    I, L   : Integer;
    Min    : Int64;
    Max    : Int64;
    Next   : Int64;
    F      : Int64;
begin
  N := TEnumeratedTypeValueNodeArray(GetChildNodes(TEnumeratedTypeValueNode));
  L := Length(N);
  SetLength(ValDef, L);
  Next := 0;
  Min := 0;
  Max := -1;
  For I := 0 to L - 1 do
    begin
      ValDef[I] := N[I].GetAsEnumeratedValueDefinition(Next);
      F := ValDef[I].Value;
      Next := F + 1;
      if I = 0 then
        begin
          Min := F;
          Max := F;
        end else
        if F > Max then
          Max := F else
          if F < Min then
            Min := F;
    end;
  Result := TEnumeratedSubrangeType.Create(Min, Max, ValDef);
end;



{                                                                              }
{ TRangeTypeNode                                                               }
{                                                                              }
function TRangeTypeNode.GetAsTypeDefinition: ATypeDefinition;
var A, B : TObject;
begin
  GetTwoExpressionsEvaluated(nil, A, B);
  Result := TIntegerSubrangeType.Create(ObjectGetAsInteger(A),
      ObjectGetAsInteger(B));
end;



{                                                                              }
{ TStreamTypeNode                                                              }
{                                                                              }
function TStreamTypeNode.GetAsTypeDefinition: ATypeDefinition;
begin
  Result := TStreamType.Create(GetOptionalTypeDefinition);
end;

procedure TStreamTypeNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Stream);
end;



{                                                                              }
{ TUntypedTypeNode                                                             }
{                                                                              }
function TUntypedTypeNode.GetAsTypeDefinition: ATypeDefinition;
begin
  Result := nil;
end;



{                                                                              }
{ AMultipleDeclarationNode                                                     }
{                                                                              }
function AMultipleDeclarationNode.GetAsFieldDefinitions: AScopeFieldDefinitionArray;
var S : StringArray;
    T : ATypeDefinition;
    V : TObject;
    I, L : Integer;
begin
  S := GetSimpleIdentifierValues;
  L := Length(S);
  SetLength(Result, L);
  if L = 0 then
    exit;
  T := GetOptionalTypeDefinition;
  try
    V := GetConstantExpressionValue;
    try
      try
        For I := 0 to L - 1 do
          Result[I] := GetFieldDefinition(S[I], T, V);
      except
        FreeAndNilObjectArray(ObjectArray(Result));
        raise;
      end;
    finally
      ObjectReleaseUnreferenced(V);
    end;
  finally
    T.ReleaseUnreferenced;
  end;
end;

procedure AMultipleDeclarationNode.WriteSource(const Writer: ASourceWriter);
var K : String;
    S : StringArray;
    I : Integer;
    T : ATypeNode;
begin
  K := GetSourceKeyword;
  if K <> '' then
    begin
      Writer.Keyword(K);
      Writer.Space;
    end;
  S := GetSimpleIdentifierValues;
  For I := 0 to Length(S) - 1 do
    begin
      if I > 0 then
        begin
          Writer.Symbol(',');
          Writer.Space;
        end;
      Writer.Identifier(S[I]);
    end;
  T := GetTypeNode;
  if Assigned(T) then
    begin
      Writer.Symbol(':');
      Writer.Space;
      T.WriteSource(Writer);
    end;
end;



{                                                                              }
{ TVariableDeclaration                                                         }
{                                                                              }
function TVariableDeclaration.GetFieldDefinition(const Identifier: String;
    const TypeDef: ATypeDefinition; const Value: TObject): AScopeFieldDefinition;
begin
  Result := TVariableFieldDefinition.Create(Identifier, TypeDef, Value);
end;

function TVariableDeclaration.GetSourceKeyword: String;
begin
  Result := c_Var;
end;

procedure TVariableDeclaration.WriteSource(const Writer: ASourceWriter);
begin
  inherited WriteSource(Writer);
  Writer.SDelim;
  Writer.NewLine;
end;



{                                                                              }
{ TConstDeclaration                                                            }
{                                                                              }
function TConstDeclaration.GetFieldDefinition(const Identifier: String;
    const TypeDef: ATypeDefinition; const Value: TObject): AScopeFieldDefinition;
begin
  Result := TConstantFieldDefinition.Create(Identifier, TypeDef, Value);
end;

function TConstDeclaration.GetSourceKeyword: String;
begin
  Result := c_Const;
end;

procedure TConstDeclaration.WriteSource(const Writer: ASourceWriter);
begin
  inherited WriteSource(Writer);
  Writer.SDelim;
  Writer.NewLine;
end;



{                                                                              }
{ TRecordFieldDefinitionNode                                                   }
{                                                                              }
function TRecordFieldDefinitionNode.GetFieldDefinition(const Identifier: String;
    const TypeDef: ATypeDefinition; const Value: TObject): AScopeFieldDefinition;
begin
  Result := TRecordFieldFieldDefinition.Create(Identifier, TypeDef, Value);
end;

function TRecordFieldDefinitionNode.GetSourceKeyword: String;
begin
  Result := '';
end;



{                                                                              }
{ TTypeDeclaration                                                             }
{                                                                              }
function TTypeDeclaration.GetAsFieldDefinitions: AScopeFieldDefinitionArray;
begin
  SetLength(Result, 1);
  Result[0] := TTypeFieldDefinition.Create(GetSimpleIdentifierValue(1, True), GetTypeDefinition);
end;

procedure TTypeDeclaration.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Type);
      Space;
      Identifier(GetSimpleIdentifierValue(1, True));
      Space;
      Symbol('=');
      Space;
      GetTypeNode.WriteSource(Writer);
    end;
end;



{                                                                              }
{ TConstParamDefinition                                                        }
{                                                                              }
function TConstParamDefinition.GetFieldDefinition(const Identifier: String;
    const TypeDef: ATypeDefinition; const Value: TObject): AScopeFieldDefinition;
begin
  Result := TConstantParameterFieldDefinition.Create(Identifier, TypeDef, Value);
end;

function TConstParamDefinition.GetSourceKeyword: String;
begin
  Result := c_Const;
end;



{                                                                              }
{ TVarParamDefinition                                                          }
{                                                                              }
function TVarParamDefinition.GetFieldDefinition(const Identifier: String;
    const TypeDef: ATypeDefinition; const Value: TObject): AScopeFieldDefinition;
begin
  Result := TVariableParameterFieldDefinition.Create(Identifier, TypeDef, Value);
end;

function TVarParamDefinition.GetSourceKeyword: String;
begin
  Result := c_Var;
end;



{                                                                              }
{ TLocalParamDefinition                                                        }
{                                                                              }
function TLocalParamDefinition.GetFieldDefinition(const Identifier: String;
    const TypeDef: ATypeDefinition; const Value: TObject): AScopeFieldDefinition;
begin
  Result := TLocalParameterFieldDefinition.Create(Identifier, TypeDef, Value);
end;

function TLocalParamDefinition.GetSourceKeyword: String;
begin
  Result := '';
end;



{                                                                              }
{ TFunctionPrototypeNode                                                       }
{                                                                              }
function TFunctionPrototypeNode.GetParameterFieldDefinitions: AParameterFieldDefinitionArray;
begin
  Result := AParameterFieldDefinitionArray(GetFieldDefinitions(AParameterDefinitionNode));
end;

procedure TFunctionPrototypeNode.GetIdentifiers(var ClassIdentifier, Identifier: String);
var S : StringArray;
begin
  S := GetSimpleIdentifierValues;
  if Length(S) = 0 then
    NodeError('Identifier not found');
  if Length(S) = 2 then
    begin
      ClassIdentifier := S[0];
      Identifier := S[1];
    end else
    begin
      ClassIdentifier := '';
      Identifier := S[0];
    end;
end;

procedure TFunctionPrototypeNode.WriteIdentifierSource(const Writer: ASourceWriter);
var C, I : String;
begin
  GetIdentifiers(C, I);
  if C <> '' then
    begin
      Writer.Identifier(C);
      Writer.Symbol('.');
    end;
  Writer.Identifier(I);
end;

procedure TFunctionPrototypeNode.WriteParametersSource(const Writer: ASourceWriter);
var P    : AParameterDefinitionNodeArray;
    L, I : Integer;
begin
  P := AParameterDefinitionNodeArray(GetChildNodes(AParameterDefinitionNode));
  L := Length(P);
  if L = 0 then
    exit;
  Writer.Symbol('(');
  For I := 0 to L - 1 do
    begin
      if I > 0 then
        begin
          Writer.SDelim;
          Writer.Space;
        end;
      P[I].WriteSource(Writer);
    end;
  Writer.Symbol(')');
end;

function TFunctionPrototypeNode.MatchPrototype(const Prototype: ABlaiseScriptNode): Boolean;
var A, B, C, D : String;
    P, Q       : AParameterDefinitionNodeArray;
    F          : TFunctionPrototypeNode;
begin
  P := nil;
  Q := nil;
  Result := Prototype is TFunctionPrototypeNode;
  if not Result then
    exit;
  F := TFunctionPrototypeNode(Prototype);
  GetIdentifiers(A, B);
  F.GetIdentifiers(C, D);
  Result := StrEqualNoCase(A, C) and StrEqualNoCase(B, D);
  if not Result then
    exit;
  P := AParameterDefinitionNodeArray(GetChildNodes(AParameterDefinitionNode));
  Q := AParameterDefinitionNodeArray(F.GetChildNodes(AParameterDefinitionNode));
  Result := Length(P) = Length(Q);
  if not Result then
    exit;
end;



{                                                                              }
{ Function directives                                                          }
{                                                                              }
function TCDeclCallingNode.GetCallingConvention: TCallingConvention;
begin
  Result := ccCDecl;
end;

function TPascalCallingNode.GetCallingConvention: TCallingConvention;
begin
  Result := ccPascal;
end;

function TRegisterCallingNode.GetCallingConvention: TCallingConvention;
begin
  Result := ccRegister;
end;

function TStdCallCallingNode.GetCallingConvention: TCallingConvention;
begin
  Result := ccStdCall;
end;

function TSafeCallCallingNode.GetCallingConvention: TCallingConvention;
begin
  Result := ccSafeCall;
end;

function TFunctionDirectivesNode.IsExternal: Boolean;
begin
  Result := Assigned(GetChildNode(1, TExternalDirectiveNode));
end;



{                                                                              }
{ AFunctionDeclarationNode                                                     }
{                                                                              }
function AFunctionDeclarationNode.GetPrototype: TFunctionPrototypeNode;
begin
  Result := TFunctionPrototypeNode(RequireChildNode(1, TFunctionPrototypeNode));
end;

function AFunctionDeclarationNode.GetAsFieldDefinitions: AScopeFieldDefinitionArray;
var Prototype       : TFunctionPrototypeNode;
    Locals          : TDeclarationListNode;
    LocalDefs       : AScopeFieldDefinitionArray;
    ClassIdentifier : String;
    Identifier      : String;
    Field           : AScopeFieldDefinition;
    Params          : AParameterFieldDefinitionArray;
    Directives      : TFunctionDirectivesNode;
    ExternalNode    : TExternalDirectiveNode;
    NameNode        : TNameDirectiveNode;
    ExternalName    : String;
    ConventionNode  : ACallingConventionNode;
    Convention      : TCallingConvention;
begin
  Prototype := GetPrototype;
  if not Assigned(Prototype) then
    NodeError('Prototype not found');
  Prototype.GetIdentifiers(ClassIdentifier, Identifier);
  Directives := TFunctionDirectivesNode(GetChildNode(1, TFunctionDirectivesNode));
  Locals := TDeclarationListNode(GetChildNode(1, TDeclarationListNode));
  Params := Prototype.GetParameterFieldDefinitions;
  try
    Field := nil;
    if Assigned(Directives) then
      begin
        ExternalNode := TExternalDirectiveNode(Directives.GetChildNode(1, TExternalDirectiveNode));
        if Assigned(ExternalNode) then
          begin
            NameNode := TNameDirectiveNode(Directives.GetChildNode(1, TNameDirectiveNode));
            if Assigned(NameNode) then
              ExternalName := NameNode.ExternalName else
              ExternalName := '';
            ConventionNode := ACallingConventionNode(Directives.GetChildNode(1, ACallingConventionNode));
            if Assigned(ConventionNode) then
              Convention := ConventionNode.GetCallingConvention else
              Convention := ccStdCall;
            Field := GetAsExternalDefinition(Prototype, Identifier,
                Params, ExternalNode.LibraryName, ExternalName, Convention);
          end;
      end;
    if not Assigned(Field) then
      begin
        if Assigned(Locals) then
          LocalDefs := Locals.GetAsFieldDefinitions else
          LocalDefs := nil;
        try
          Field := GetAsFunctionDefinition(Prototype, ClassIdentifier, Identifier,
              Params, LocalDefs);
        except
          FreeObjectArray(LocalDefs);
          raise;
        end;
      end;
  except
    FreeObjectArray(Params);
    raise;
  end;
  SetLength(Result, 1);
  Result[0] := Field;
end;

function AFunctionDeclarationNode.GetAsExternalDefinition(
    const Prototype: TFunctionPrototypeNode;
    const Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LibraryName, FunctionName: String;
    const Convention: TCallingConvention): AScopeFieldDefinition;
begin
  raise EBlaiseScriptNode.Create('Declaration does not support external');
end;

procedure AFunctionDeclarationNode.WriteSource(const Writer: ASourceWriter);
var Prototype  : TFunctionPrototypeNode;
begin
  Prototype := GetPrototype;
  Writer.Keyword(GetSourceKeyword);
  Writer.Space;
  Prototype.WriteIdentifierSource(Writer);
  Prototype.WriteParametersSource(Writer);
  WriteBodySource(Writer);
end;

procedure AFunctionDeclarationNode.WriteStatementSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      SDelim;
      NewLine;
      GetStatementNode(1).WriteSource(Writer);
      SDelim;
      NewLine;
    end;
end;

procedure AFunctionDeclarationNode.WriteBodySource(const Writer: ASourceWriter);
begin
  WriteStatementSource(Writer);
end;



{                                                                              }
{ TProcedureDeclarationNode                                                    }
{                                                                              }
function TProcedureDeclarationNode.GetAsFunctionDefinition(
    const Prototype: TFunctionPrototypeNode;
    const ClassIdentifier, Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray): AScopeFieldDefinition;
begin
  Result := TProcedureFieldDefinition.Create(ClassIdentifier, Identifier,
      ParamDefinition, LocalDefinition, GetStatement);
end;

function TProcedureDeclarationNode.GetAsExternalDefinition(
    const Prototype: TFunctionPrototypeNode;
    const Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LibraryName, FunctionName: String;
    const Convention: TCallingConvention): AScopeFieldDefinition;
begin
  Result := TExternalFunctionFieldDefinition.Create(Identifier,
      ParamDefinition, nil, LibraryName, FunctionName, Convention);
end;

function TProcedureDeclarationNode.GetSourceKeyword: String;
begin
  Result := c_Procedure;
end;



{                                                                              }
{ TFunctionDeclarationNode                                                     }
{                                                                              }
function TFunctionDeclarationNode.GetAsFunctionDefinition(
    const Prototype: TFunctionPrototypeNode;
    const ClassIdentifier, Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray): AScopeFieldDefinition;
begin
  Result := TFunctionFieldDefinition.Create(ClassIdentifier, Identifier,
      ParamDefinition, LocalDefinition,
      GetOptionalStatement(1), GetOptionalExpression(1),
      Prototype.GetOptionalTypeDefinition);
end;

function TFunctionDeclarationNode.GetAsExternalDefinition(
    const Prototype: TFunctionPrototypeNode;
    const Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LibraryName, FunctionName: String;
    const Convention: TCallingConvention): AScopeFieldDefinition;
begin
  Result := TExternalFunctionFieldDefinition.Create(Identifier,
      ParamDefinition, Prototype.GetTypeDefinition, LibraryName,
      FunctionName, Convention);
end;

function TFunctionDeclarationNode.GetSourceKeyword: String;
begin
  Result := c_Function;
end;



{                                                                              }
{ TTaskDeclarationNode                                                         }
{                                                                              }
function TTaskDeclarationNode.GetAsFunctionDefinition(
    const Prototype: TFunctionPrototypeNode;
    const ClassIdentifier, Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray): AScopeFieldDefinition;
begin
  Result := TTaskFieldDefinition.Create(ClassIdentifier, Identifier,
      ParamDefinition, LocalDefinition, GetStatement);
end;

function TTaskDeclarationNode.GetSourceKeyword: String;
begin
  Result := c_Task;
end;



{                                                                              }
{ TConstructorDeclarationNode                                                  }
{                                                                              }
function TConstructorDeclarationNode.GetAsFunctionDefinition(
    const Prototype: TFunctionPrototypeNode;
    const ClassIdentifier, Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray): AScopeFieldDefinition;
begin
  Result := TConstructorFieldDefinition.Create(ClassIdentifier, Identifier,
      ParamDefinition, LocalDefinition, GetStatement);
end;

function TConstructorDeclarationNode.GetSourceKeyword: String;
begin
  Result := c_Constructor;
end;



{                                                                              }
{ TDestructorDeclarationNode                                                   }
{                                                                              }
function TDestructorDeclarationNode.GetAsFunctionDefinition(
    const Prototype: TFunctionPrototypeNode;
    const ClassIdentifier, Identifier: String;
    const ParamDefinition: AParameterFieldDefinitionArray;
    const LocalDefinition: AScopeFieldDefinitionArray): AScopeFieldDefinition;
begin
  Result := TDestructorFieldDefinition.Create(ClassIdentifier, Identifier,
      ParamDefinition, LocalDefinition, GetStatement);
end;

function TDestructorDeclarationNode.GetSourceKeyword: String;
begin
  Result := c_Destructor;
end;



end.

