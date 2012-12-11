{                                                                              }
{                         Blaise syntactic nodes v0.03                         }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseParserNodes.pas                 }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise syntactic nodes.                               }
{                                                                              }
{ Revision history:                                                            }
{   09/06/2002  0.01  Created cBlaiseParserNodes from cBlaiseParser.           }
{   13/04/2003  0.02  Removed dependancy on generic base class.                }
{   15/04/2003  0.03  Added WriteSource method.                                }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseParserNodes;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseMachineTypes,
  cBlaiseMachineIdentifiers,
  cBlaiseMachine;



{                                                                              }
{ ABlaiseScriptNode                                                            }
{   Base class for syntactic nodes.                                            }
{                                                                              }
type
  ABlaiseScriptNode = class;
  ABlaiseScriptNodeArray = Array of ABlaiseScriptNode;
  CBlaiseScriptNode = class of ABlaiseScriptNode;
  AExpressionNode = class;
  AExpressionNodeArray = Array of AExpressionNode;
  AIdentifierNode = class;
  AStatementNode = class;
  AStatementNodeArray = Array of AStatementNode;
  ATypeNode = class;
  ADeclarationNode = class;
  CDeclarationNode = class of ADeclarationNode;
  ADeclarationNodeArray = Array of ADeclarationNode;

  ASourceWriter = class
  protected
    FIndentLevel : Integer;
  public
    procedure Space; virtual; abstract;
    procedure NewLine; virtual; abstract;
    procedure Symbol(const S: String); virtual; abstract;
    procedure Keyword(const S: String); virtual; abstract;
    procedure Identifier(const S: String); virtual; abstract;
    procedure NumericLiteral(const S: String); virtual; abstract;
    procedure StringLiteral(const S: String); virtual; abstract;

    procedure Indent;
    procedure Unindent;
    procedure SDelim;
    procedure Expressions(const N: AExpressionNodeArray);
    procedure Statements(const N: AStatementNodeArray);
  end;

  ABlaiseScriptNode = class
  protected
    FNext         : ABlaiseScriptNode;
    FParent       : ABlaiseScriptNode;
    FFirst        : ABlaiseScriptNode;
    FLast         : ABlaiseScriptNode;
    FRelSourcePos : Integer;
    FSourceLen    : Integer;

    procedure NodeError(const Msg: String);
    procedure AbstractError(const Method: String);

    function  GetChildNode(const Nr: Integer;
              const NodeType: CBlaiseScriptNode): ABlaiseScriptNode;
    function  RequireChildNode(const Nr: Integer;
              const NodeType: CBlaiseScriptNode): ABlaiseScriptNode;
    function  GetChildNodes(const NodeType: CBlaiseScriptNode):
              ABlaiseScriptNodeArray;
    function  GetTwoChildNodes(const NodeType: CBlaiseScriptNode;
              var A, B: ABlaiseScriptNode): Boolean;
    function  GetThreeChildNodes(const NodeType: CBlaiseScriptNode;
              var A, B, C: ABlaiseScriptNode): Boolean;

    function  GetExpressionNode(const Nr: Integer): AExpressionNode;
    function  GetExpression: AExpression;
    function  GetOptionalExpression(const Nr: Integer): AExpression;
    function  GetConstantExpressionValue: TObject;
    function  GetExpressionEvaluated(const Scope: ABlaiseType): TObject;
    function  GetOptionalExpressionEvaluated(const Scope: ABlaiseType): TObject;
    procedure GetTwoExpressionNodes(var A, B: AExpressionNode);
    procedure GetTwoExpressions(var A, B: AExpression);
    procedure GetThreeExpressionNodes(var A, B, C: AExpressionNode);
    procedure GetThreeExpressions(var A, B, C: AExpression);
    procedure GetTwoExpressionsEvaluated(const Scope: ABlaiseType;
              var A, B: TObject);
    function  GetExpressionNodes: AExpressionNodeArray;
    function  GetExpressions: AExpressionArray;

    function  GetIdentifierNode: AIdentifierNode;
    function  GetIdentifier: AIdentifier;
    function  GetOptionalIdentifier: AIdentifier;
    function  GetSimpleIdentifierValue(const Nr: Integer;
              const Required: Boolean): String;
    function  GetTwoIdentifierNodes(var A, B: AIdentifierNode): Boolean;
    function  GetSimpleIdentifierValues: StringArray;

    function  GetStatementNode(const Nr: Integer): AStatementNode;
    function  GetStatement: AStatement;
    function  GetOptionalStatement(const Nr: Integer): AStatement;
    function  GetStatementNodes: AStatementNodeArray;
    function  GetStatements: AStatementArray;
    function  GetStatementsAsStatement: AStatement;

    function  GetTypeNode: ATypeNode;
    function  GetTypeDefinition: ATypeDefinition;
    function  GetOptionalTypeDefinition: ATypeDefinition;
    procedure GetTwoTypeDefinitions(var A, B: ATypeDefinition);

    function  GetFieldDefinitions(const NodeType: CDeclarationNode):
              AScopeFieldDefinitionArray;

  public
    class function StructureName: String; virtual;

    destructor Destroy; override;

    property  Parent: ABlaiseScriptNode read FParent;
    property  First: ABlaiseScriptNode read FFirst;
    property  Next: ABlaiseScriptNode read FNext;
    function  NodeName: String; virtual;
    function  GetNodeParameterStr: String; virtual;
    property  RelSourcePos: Integer read FRelSourcePos write FRelSourcePos;
    property  SourceLen: Integer read FSourceLen write FSourceLen;
    function  SourcePos: Integer;

    procedure AddChild(const Child: ABlaiseScriptNode);

    procedure WriteSource(const Writer: ASourceWriter); virtual;
    function  GetSource: String;
    function  GetSourceAsHtml: String;
  end;
  EBlaiseScriptNode = class(Exception);



{                                                                              }
{ AExpressionNode                                                              }
{   Base class for syntactic nodes representing expressions.                   }
{                                                                              }

  AExpressionNode = class(ABlaiseScriptNode)
  public
    class function StructureName: String; override;
    function  IsConstant: Boolean; virtual;
    function  GetAsExpression: AExpression; virtual;
  end;
  EExpressionNode = class(EBlaiseScriptNode);

  AConstantExpressionNode = class(AExpressionNode)
  public
    function  IsConstant: Boolean; override;
    function  GetValue: TObject; virtual; abstract;
  end;



{                                                                              }
{ AStatementNode                                                               }
{   Base class for syntactic nodes representing statements.                    }
{                                                                              }

  AStatementNode = class(ABlaiseScriptNode)
  public
    class function StructureName: String; override;
    function  GetAsStatement: AStatement; virtual;
  end;



{                                                                              }
{ AIdentifierNode                                                              }
{   Base class for syntactic nodes representing identifiers.                   }
{                                                                              }

  AIdentifierNode = class(ABlaiseScriptNode)
  public
    function  GetAsIdentifier: AIdentifier; virtual; abstract;
  end;



{                                                                              }
{ ATypeNode                                                                    }
{   Base class for syntactic nodes representing types.                         }
{                                                                              }

  ATypeNode = class(ABlaiseScriptNode)
  public
    function  GetAsTypeDefinition: ATypeDefinition; virtual;
  end;



{                                                                              }
{ ADeclarationNode                                                             }
{   Base class for syntactic nodes representing declarations.                  }
{                                                                              }

  ADeclarationNode = class(ABlaiseScriptNode)
  public
    function  GetAsFieldDefinitions: AScopeFieldDefinitionArray; virtual;
  end;

  TDeclarationListNode = class(ADeclarationNode)
  public
    function  GetAsFieldDefinitions: AScopeFieldDefinitionArray; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
    function  GetImplementation(const Prototype: ABlaiseScriptNode): ADeclarationNode;
    function  GetPrototype(const Declaration: ADeclarationNode): ABlaiseScriptNode;
  end;



{                                                                              }
{ AIdentifierNode implementations                                              }
{                                                                              }
type
  { TSimpleIdentifierNode                                                      }
  TSimpleIdentifierNode = class(AIdentifierNode)
  protected
    FIdentifier : String;

  public
    constructor Create(const Identifier: String);
    property  Identifier: String read FIdentifier;
    function  GetNodeParameterStr: String; override;
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  { TSelectedIdentifierNode                                                    }
  TSelectedIdentifierNode = class(AIdentifierNode)
  public
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  { TIdentifierCallNode                                                        }
  TIdentifierCallNode = class(AIdentifierNode)
  public
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  { TSelfIdentifierNode                                                        }
  TSelfIdentifierNode = class(AIdentifierNode)
  public
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  { TInheritedIdentifierNode                                                   }
  TInheritedIdentifierNode = class(AIdentifierNode)
  public
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  { TIndexNode                                                                 }
  TIndexNode = class(ABlaiseScriptNode)
  protected
    FReversedIndex : Boolean;

  public
    constructor Create(const ReversedIndex: Boolean);
    function  GetNodeParameterStr: String; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
    function  GetAsSliceIndex: TSliceIndex;
    function  GetAsSlice: TObject;
  end;

  { TIndexedIdentifierNode                                                     }
  TIndexedIdentifierNode = class(AIdentifierNode)
  public
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  { TRangeSliceNode                                                            }
  TRangeSliceNode = class(ABlaiseScriptNode)
    procedure WriteSource(const Writer: ASourceWriter); override;
    function  GetAsSlice: TObject;
  end;

  { TMultiSliceNode                                                            }
  TMultiSliceNode = class(ABlaiseScriptNode)
    procedure WriteSource(const Writer: ASourceWriter); override;
    function  GetAsSlice: TObject;
  end;

  { TSlicedIdentifierNode                                                      }
  TSlicedIdentifierNode = class(AIdentifierNode)
  public
    function  GetAsIdentifier: AIdentifier; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TUnitNode                                                                    }
{                                                                              }
type
  TInterfaceSectionNode = class(ABlaiseScriptNode)
  public
    function  GetUsesList: StringArray;
    function  GetDeclarations: TDeclarationListNode;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  TImplementationSectionNode = class(ABlaiseScriptNode)
  public
    function  GetUsesList: StringArray;
    function  GetDeclarations: TDeclarationListNode;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;

  TUnitNode = class(ABlaiseScriptNode)
  public
    function  GetIdentifier: String;
    function  GetInterfaceSection: TInterfaceSectionNode;
    function  GetImplementationSection: TImplementationSectionNode;
    function  GetPublicDeclarations: AScopeFieldDefinitionArray;
    function  GetPrivateDeclarations: AScopeFieldDefinitionArray;
    function  GetUnit: TBlaiseUnit;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TUsesNode                                                                    }
{                                                                              }
type
  TUsesNode = class(ABlaiseScriptNode)
  public
    function  GetUsesList: StringArray;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TApplicationNode                                                             }
{                                                                              }
type
  TApplicationNode = class(ABlaiseScriptNode)
  protected
    function  GetDeclarations: TDeclarationListNode;
    function  GetUsesList: StringArray;
    function  GetMain: AStatementNode;

  public
    function  GetApplication: TBlaiseApplication;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



implementation

uses
  { Fundamentals }
  cStrings,
  cWriters,

  { Blaise }
  cBlaiseFuncs,
  cBlaiseStructs,
  cBlaiseStructsSimple,
  cBlaiseMachineStatements,
  cBlaiseParserLexer,
  cBlaiseParserNodesDecl;



{                                                                              }
{ ABlaiseScriptNode                                                            }
{                                                                              }
class function ABlaiseScriptNode.StructureName: String;
begin
  Result := StrExclSuffix(StrExclPrefix(ClassName, 'T'), 'Node');
end;

destructor ABlaiseScriptNode.Destroy;
var I, N : ABlaiseScriptNode;
begin
  I := FFirst;
  FFirst := nil;
  While Assigned(I) do
    begin
      N := I;
      I := I.FNext;
      N.Free;
    end;
  inherited Destroy;
end;

function ABlaiseScriptNode.NodeName: String;
begin
  Result := StructureName;
end;

procedure ABlaiseScriptNode.NodeError(const Msg: String);
begin
  raise EBlaiseScriptNode.Create(NodeName + ': ' + Msg);
end;

procedure ABlaiseScriptNode.AbstractError(const Method: String);
begin
  raise EBlaiseScriptNode.Create('Method ' + ClassName + '.' + Method +
      ' not implemented')
end;

function ABlaiseScriptNode.GetNodeParameterStr: String;
begin
  Result := '';
end;

function ABlaiseScriptNode.SourcePos: Integer;
begin
  Result := FRelSourcePos;
  if Parent is ABlaiseScriptNode then
    Result := Result + ABlaiseScriptNode(Parent).SourcePos;
end;

procedure ABlaiseScriptNode.AddChild(const Child: ABlaiseScriptNode);
begin
  if not Assigned(Child) then
    exit;
  Child.FNext := nil;
  Child.FParent := self;
  if not Assigned(FFirst) then
    FFirst := Child;
  if Assigned(FLast) then
    FLast.FNext := Child;
  FLast := Child;
end;

function ABlaiseScriptNode.GetChildNode(const Nr: Integer;
    const NodeType: CBlaiseScriptNode): ABlaiseScriptNode;
var I : Integer;
begin
  Assert(Nr >= 1);
  Assert(Assigned(NodeType));
  Result := FFirst;
  I := 0;
  While Assigned(Result) do
    begin
      if Result.InheritsFrom(NodeType) then
        begin
          Inc(I);
          if I >= Nr then
            exit;
        end;
      Result := Result.FNext;
    end;
end;

function ABlaiseScriptNode.RequireChildNode(const Nr: Integer;
    const NodeType: CBlaiseScriptNode): ABlaiseScriptNode;
begin
  Result := GetChildNode(Nr, NodeType);
  if not Assigned(Result) then
    NodeError('Node not found');
end;

function ABlaiseScriptNode.GetChildNodes(const NodeType: CBlaiseScriptNode):
    ABlaiseScriptNodeArray;
var N : ABlaiseScriptNode;
begin
  Assert(Assigned(NodeType));
  Result := nil;
  N := FFirst;
  While Assigned(N) do
    begin
      if N.InheritsFrom(NodeType) then
        Append(ObjectArray(Result), N);
      N := N.FNext;
    end;
end;

function ABlaiseScriptNode.GetTwoChildNodes(const NodeType: CBlaiseScriptNode;
    var A, B: ABlaiseScriptNode): Boolean;
begin
  A := FFirst;
  While Assigned(A) and not A.InheritsFrom(NodeType) do
    A := A.FNext;
  if not Assigned(A) then
    begin
      B := nil;
      Result := False;
      exit;
    end;
  B := A.FNext;
  While Assigned(B) and not B.InheritsFrom(NodeType) do
    B := B.FNext;
  Result := Assigned(B);
end;

function ABlaiseScriptNode.GetThreeChildNodes(const NodeType: CBlaiseScriptNode;
    var A, B, C: ABlaiseScriptNode): Boolean;
begin
  A := FFirst;
  While Assigned(A) and not A.InheritsFrom(NodeType) do
    A := A.FNext;
  if not Assigned(A) then
    begin
      B := nil;
      C := nil;
      Result := False;
      exit;
    end;
  B := A.FNext;
  While Assigned(B) and not B.InheritsFrom(NodeType) do
    B := B.FNext;
  if not Assigned(B) then
    begin
      C := nil;
      Result := False;
      exit;
    end;
  C := B.FNext;
  While Assigned(C) and not C.InheritsFrom(NodeType) do
    C := C.FNext;
  Result := Assigned(C);
end;

function ABlaiseScriptNode.GetExpressionNode(const Nr: Integer): AExpressionNode;
begin
  Result := AExpressionNode(GetChildNode(Nr, AExpressionNode));
end;

function ABlaiseScriptNode.GetExpression: AExpression;
var V : AExpressionNode;
begin
  V := GetExpressionNode(1);
  if not Assigned(V) then
    NodeError('Expression not found');
  Result := V.GetAsExpression;
end;

function ABlaiseScriptNode.GetOptionalExpression(const Nr: Integer): AExpression;
var V : AExpressionNode;
begin
  V := GetExpressionNode(Nr);
  if not Assigned(V) then
    Result := nil
  else
    Result := V.GetAsExpression;
end;

{$WARNINGS OFF}
function ABlaiseScriptNode.GetConstantExpressionValue: TObject;
var E : AExpressionNode;
    F : AExpression;
begin
  E := GetExpressionNode(1);
  if not Assigned(E) then
    Result := nil else
  if not E.IsConstant then
    NodeError('Constant required')
  else
    if E is AConstantExpressionNode then
      Result := AConstantExpressionNode(E).GetValue
    else
      begin
        F := E.GetAsExpression;
        try
          Result := F.Evaluate(nil);
        finally
          F.Free;
        end;
      end;
end;
{$WARNINGS ON}

function ABlaiseScriptNode.GetExpressionEvaluated(const Scope: ABlaiseType): TObject;
var V : AExpression;
begin
  V := GetExpression;
  if not Assigned(V) then
    Result := nil
  else
    try
      Result := V.Evaluate(Scope);
    finally
      V.Free;
    end;
end;

function ABlaiseScriptNode.GetOptionalExpressionEvaluated(const Scope: ABlaiseType): TObject;
var V : AExpression;
begin
  V := GetOptionalExpression(1);
  if not Assigned(V) then
    Result := nil
  else
    try
      Result := V.Evaluate(Scope);
    finally
      V.Free;
    end;
end;

procedure ABlaiseScriptNode.GetTwoExpressionNodes(var A, B: AExpressionNode);
begin
  GetTwoChildNodes(AExpressionNode, ABlaiseScriptNode(A), ABlaiseScriptNode(B));
end;

procedure ABlaiseScriptNode.GetTwoExpressions(var A, B: AExpression);
var I, J : ABlaiseScriptNode;
begin
  if not GetTwoChildNodes(AExpressionNode, I, J) then
    NodeError('Expression not found');
  A := AExpressionNode(I).GetAsExpression;
  try
    B := AExpressionNode(J).GetAsExpression;
  except
    A.Free;
    raise;
  end;
end;

procedure ABlaiseScriptNode.GetThreeExpressionNodes(var A, B, C: AExpressionNode);
begin
  GetThreeChildNodes(AExpressionNode, ABlaiseScriptNode(A),
      ABlaiseScriptNode(B), ABlaiseScriptNode(C));
end;

procedure ABlaiseScriptNode.GetThreeExpressions(var A, B, C: AExpression);
var I, J, K : ABlaiseScriptNode;
begin
  if not GetThreeChildNodes(AExpressionNode, I, J, K) then
    NodeError('Expression not found');
  A := AExpressionNode(I).GetAsExpression;
  B := nil;
  try
    B := AExpressionNode(J).GetAsExpression;
    C := AExpressionNode(K).GetAsExpression;
  except
    A.Free;
    B.Free;
    raise;
  end;
end;

procedure ABlaiseScriptNode.GetTwoExpressionsEvaluated(const Scope: ABlaiseType;
    var A, B: TObject);
var I, J : AExpression;
begin
  GetTwoExpressions(I, J);
  if Assigned(I) then
    A := I.Evaluate(Scope)
  else
    A := nil;
  if Assigned(J) then
    try
      B := J.Evaluate(Scope);
    except
      ObjectReleaseUnreferenced(A);
      raise;
    end
  else
    B := nil;
end;

function ABlaiseScriptNode.GetExpressionNodes: AExpressionNodeArray;
begin
  Result := AExpressionNodeArray(GetChildNodes(AExpressionNode));
end;

function ABlaiseScriptNode.GetExpressions: AExpressionArray;
var N : ABlaiseScriptNode;
begin
  Result := nil;
  try
    N := FFirst;
    While Assigned(N) do
      begin
        if N is AExpressionNode then
          Append(ObjectArray(Result), AExpressionNode(N).GetAsExpression);
        N := N.FNext;
      end;
  except
    FreeObjectArray(Result);
    raise;
  end;
end;

function ABlaiseScriptNode.GetIdentifierNode: AIdentifierNode;
begin
  Result := AIdentifierNode(GetChildNode(1, AIdentifierNode));
end;

{$WARNINGS OFF}
function ABlaiseScriptNode.GetIdentifier: AIdentifier;
var V : AIdentifierNode;
begin
  V := GetIdentifierNode;
  if Assigned(V) then
    Result := V.GetAsIdentifier
  else
    NodeError('Identifier not found');
end;
{$WARNINGS ON}

function ABlaiseScriptNode.GetOptionalIdentifier: AIdentifier;
var V : AIdentifierNode;
begin
  V := GetIdentifierNode;
  if Assigned(V) then
    Result := V.GetAsIdentifier
  else
    Result := nil;
end;

{$WARNINGS OFF}
function ABlaiseScriptNode.GetSimpleIdentifierValue(const Nr: Integer;
    const Required: Boolean): String;
var N : TSimpleIdentifierNode;
begin
  N := TSimpleIdentifierNode(GetChildNode(Nr, TSimpleIdentifierNode));
  if Assigned(N) then
    Result := N.Identifier
  else
    if Required then
      NodeError('Simple identifier not found')
    else
      Result := '';
end;
{$WARNINGS ON}

function ABlaiseScriptNode.GetTwoIdentifierNodes(var A, B: AIdentifierNode): Boolean;
begin
  Result := GetTwoChildNodes(AIdentifierNode, ABlaiseScriptNode(A),
      ABlaiseScriptNode(B));
end;

function ABlaiseScriptNode.GetSimpleIdentifierValues: StringArray;
var N : ABlaiseScriptNode;
begin
  Result := nil;
  N := FFirst;
  While Assigned(N) do
    begin
      if N is TSimpleIdentifierNode then
        Append(Result, TSimpleIdentifierNode(N).Identifier);
      N := N.FNext;
    end;
end;

function ABlaiseScriptNode.GetStatementNode(const Nr: Integer): AStatementNode;
begin
  Result := AStatementNode(GetChildNode(Nr, AStatementNode));
end;

function ABlaiseScriptNode.GetStatement: AStatement;
var N : AStatementNode;
begin
  N := GetStatementNode(1);
  if not Assigned(N) then
    NodeError('Statement not found');
  Result := N.GetAsStatement
end;

function ABlaiseScriptNode.GetOptionalStatement(const Nr: Integer): AStatement;
var V : AStatementNode;
begin
  V := GetStatementNode(Nr);
  if not Assigned(V) then
    Result := nil
  else
    Result := V.GetAsStatement;
end;

function ABlaiseScriptNode.GetStatementNodes: AStatementNodeArray;
begin
  Result := AStatementNodeArray(GetChildNodes(AStatementNode));
end;

function ABlaiseScriptNode.GetStatements: AStatementArray;
var N : ABlaiseScriptNode;
begin
  Result := nil;
  try
    N := FFirst;
    While Assigned(N) do
      begin
        if N is AStatementNode then
          Append(ObjectArray(Result), AStatementNode(N).GetAsStatement);
        N := N.FNext;
      end;
  except
    FreeObjectArray(Result);
    raise;
  end;
end;

function ABlaiseScriptNode.GetStatementsAsStatement: AStatement;
var V : AStatementArray;
    L : Integer;
begin
  V := GetStatements;
  L := Length(V);
  if L = 0 then
    Result := nil else
  if L = 1 then
    Result := V[0]
  else
    Result := TStatementBlock.Create(V);
end;

function ABlaiseScriptNode.GetTypeNode: ATypeNode;
begin
  Result := ATypeNode(GetChildNode(1, ATypeNode));
end;

{$WARNINGS OFF}
function ABlaiseScriptNode.GetTypeDefinition: ATypeDefinition;
var V : ATypeNode;
begin
  V := GetTypeNode;
  if Assigned(V) then
    Result := V.GetAsTypeDefinition
  else
    NodeError('Type definition not found');
end;
{$WARNINGS ON}

function ABlaiseScriptNode.GetOptionalTypeDefinition: ATypeDefinition;
var V : ATypeNode;
begin
  V := GetTypeNode;
  if Assigned(V) then
    Result := V.GetAsTypeDefinition
  else
    Result := nil;
end;

procedure ABlaiseScriptNode.GetTwoTypeDefinitions(var A, B: ATypeDefinition);
var I, J : ABlaiseScriptNode;
begin
  if not GetTwoChildNodes(ATypeNode, I, J) then
    NodeError('Type not found');
  A := ATypeNode(I).GetAsTypeDefinition;
  try
    B := ATypeNode(J).GetAsTypeDefinition;
  except
    A.Free;
    raise;
  end;
end;

function ABlaiseScriptNode.GetFieldDefinitions(
    const NodeType: CDeclarationNode): AScopeFieldDefinitionArray;
var N : ABlaiseScriptNode;
begin
  Assert(Assigned(NodeType));
  Result := nil;
  try
    N := FFirst;
    While Assigned(N) do
      begin
        if N.InheritsFrom(NodeType) then
          AppendObjectArray(ObjectArray(Result),
              ObjectArray(ADeclarationNode(N).GetAsFieldDefinitions));
        N := N.FNext;
      end;
  except
    FreeObjectArray(Result);
    raise;
  end;
end;

procedure ABlaiseScriptNode.WriteSource(const Writer: ASourceWriter);
begin
  AbstractError('WriteSource');
end;



{ ASourceWriter                                                                }
procedure ASourceWriter.Indent;
begin
  Inc(FIndentLevel);
end;

procedure ASourceWriter.Unindent;
begin
  Assert(FIndentLevel > 0);
  Dec(FIndentLevel);
end;

procedure ASourceWriter.SDelim;
begin
  Symbol(c_SDelim);
end;

procedure ASourceWriter.Expressions(const N: AExpressionNodeArray);
var I : Integer;
begin
  For I := 0 to Length(N) - 1 do
    begin
      if I > 0 then
        begin
          Symbol(',');
          Space;
        end;
      N[I].WriteSource(self);
    end;
end;

procedure ASourceWriter.Statements(const N: AStatementNodeArray);
var I : Integer;
begin
  For I := 0 to Length(N) - 1 do
    begin
      NewLine;
      N[I].WriteSource(self);
      SDelim;
    end;
end;



{ TStringSourceWriter                                                          }
type
  TStringSourceWriter = class(ASourceWriter)
  protected
    FWriter : TStringWriter;

    procedure WriteStr(const S: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Space; override;
    procedure NewLine; override;
    procedure Symbol(const S: String); override;
    procedure Keyword(const S: String); override;
    procedure Identifier(const S: String); override;
    procedure NumericLiteral(const S: String); override;
    procedure StringLiteral(const S: String); override;
  end;

constructor TStringSourceWriter.Create;
begin
  inherited Create;
  FWriter := TStringWriter.Create;
end;

destructor TStringSourceWriter.Destroy;
begin
  FreeAndNil(FWriter);
  inherited Destroy;
end;

procedure TStringSourceWriter.WriteStr(const S: String);
begin
  FWriter.WriteStr(S);
end;

procedure TStringSourceWriter.Space;
begin
  WriteStr(' ');
end;

procedure TStringSourceWriter.NewLine;
begin
  WriteStr(CRLF + DupChar(' ', FIndentLevel * 2));
end;

procedure TStringSourceWriter.Symbol(const S: String);
begin
  WriteStr(S);
end;

procedure TStringSourceWriter.Keyword(const S: String);
begin
  WriteStr(S);
end;

procedure TStringSourceWriter.Identifier(const S: String);
begin
  WriteStr(S);
end;

procedure TStringSourceWriter.NumericLiteral(const S: String);
begin
  WriteStr(S);
end;

procedure TStringSourceWriter.StringLiteral(const S: String);
begin
  WriteStr(StrQuote(S, ''''));
end;

function ABlaiseScriptNode.GetSource: String;
var W : TStringSourceWriter;
begin
  W := TStringSourceWriter.Create;
  try
    WriteSource(W);
    Result := W.FWriter.AsString;
  finally
    W.Free;
  end;
end;



{ THtmlSourceWriter                                                            }
type
  THtmlSourceWriter = class(TStringSourceWriter)
  public
    procedure Space; override;
    procedure NewLine; override;
    procedure Symbol(const S: String); override;
    procedure Keyword(const S: String); override;
    procedure Identifier(const S: String); override;
    procedure NumericLiteral(const S: String); override;
    procedure StringLiteral(const S: String); override;

    function  GetHtml: String;
  end;

procedure THtmlSourceWriter.Identifier(const S: String);
begin
  WriteStr(S);
end;

procedure THtmlSourceWriter.Keyword(const S: String);
begin
  WriteStr('<B>' + S + '</B>');
end;

procedure THtmlSourceWriter.NewLine;
begin
  WriteStr(CRLF + DupChar(' ', FIndentLevel * 2));
end;

procedure THtmlSourceWriter.NumericLiteral(const S: String);
begin
  WriteStr('<EM CLASS=num>' + S + '</EM>');
end;

procedure THtmlSourceWriter.Space;
begin
  WriteStr(' ');
end;

procedure THtmlSourceWriter.StringLiteral(const S: String);
begin
  WriteStr('<EM CLASS=str>' + StrQuote(S, '''') + '</EM>');
end;

procedure THtmlSourceWriter.Symbol(const S: String);
begin
  WriteStr(S);
end;

function THtmlSourceWriter.GetHtml: String;
begin
  Result := '<HTML>'#13#10 +
            '<HEAD><STYLE>'#13#10 +
            'PRE { white-space: nowrap; font-size:13; margin-left:48px }'#13#10 +
            'EM.num { color: #800000; font-style:normal }'#13#10 +
            'EM.str { color: #800000; font-style:normal }'#13#10 +
            '</STYLE></HEAD>'#13#10 +
            '<BODY><PRE>'#13#10 +
            FWriter.AsString +
            #13#10'</PRE></BODY></HTML>';
end;

function ABlaiseScriptNode.GetSourceAsHtml: String;
var W : THtmlSourceWriter;
begin
  W := THtmlSourceWriter.Create;
  try
    WriteSource(W);
    Result := W.GetHtml;
  finally
    W.Free;
  end;
end;



{                                                                              }
{ AExpressionNode                                                              }
{                                                                              }
class function AExpressionNode.StructureName: String;
begin
  Result := StrExclSuffix(inherited StructureName, 'Expression');
end;

function AExpressionNode.IsConstant: Boolean;
begin
  Result := False;
end;

{$WARNINGS OFF}
function AExpressionNode.GetAsExpression: AExpression;
begin
  AbstractError('GetAsExpression');
end;
{$WARNINGS ON}



{                                                                              }
{ AConstantExpressionNode                                                      }
{                                                                              }
function AConstantExpressionNode.IsConstant: Boolean;
begin
  Result := True;
end;



{                                                                              }
{ AStatementNode                                                               }
{                                                                              }
class function AStatementNode.StructureName: String;
begin
  Result := StrExclSuffix(inherited StructureName, 'Statement');
end;

{$WARNINGS OFF}
function AStatementNode.GetAsStatement: AStatement;
begin
  AbstractError('GetAsStatement')
end;
{$WARNINGS ON}



{                                                                              }
{ ATypeNode                                                                    }
{                                                                              }
{$WARNINGS OFF}
function ATypeNode.GetAsTypeDefinition: ATypeDefinition;
begin
  AbstractError('GetAsTypeDefinition');
end;
{$WARNINGS ON}



{                                                                              }
{ ADeclarationNode                                                             }
{                                                                              }
{$WARNINGS OFF}
function ADeclarationNode.GetAsFieldDefinitions: AScopeFieldDefinitionArray;
begin
  AbstractError('GetAsFieldDefinitions');
end;
{$WARNINGS ON}



{                                                                              }
{ TDeclarationListNode                                                         }
{                                                                              }
function TDeclarationListNode.GetAsFieldDefinitions: AScopeFieldDefinitionArray;
var N : ABlaiseScriptNode;
begin
  Result := nil;
  try
    N := FFirst;
    While Assigned(N) do
      begin
        if N is ADeclarationNode then
          AppendObjectArray(ObjectArray(Result),
              ObjectArray(ADeclarationNode(N).GetAsFieldDefinitions));
        N := N.FNext;
      end;
  except
    FreeObjectArray(Result);
    raise;
  end;
end;

procedure TDeclarationListNode.WriteSource(const Writer: ASourceWriter);
var N : ADeclarationNodeArray;
    I : Integer;
begin
  N := ADeclarationNodeArray(GetChildNodes(ADeclarationNode));
  For I := 0 to Length(N) - 1 do
    begin
      N[I].WriteSource(Writer);
      Writer.NewLine;
    end;
end;

function TDeclarationListNode.GetImplementation(const Prototype: ABlaiseScriptNode): ADeclarationNode;
var A : ABlaiseScriptNode;
begin
  A := First;
  While Assigned(A) do
    begin
      if A is AFunctionDeclarationNode then
        if AFunctionDeclarationNode(A).GetPrototype.MatchPrototype(Prototype) then
          begin
            Result := AFunctionDeclarationNode(A);
            exit;
          end;
      A := A.Next;
    end;
  Result := nil;
end;

function TDeclarationListNode.GetPrototype(const Declaration: ADeclarationNode): ABlaiseScriptNode;
var A : ABlaiseScriptNode;
    P : TFunctionPrototypeNode;
begin
  if Declaration is AFunctionDeclarationNode then
    begin
      P := AFunctionDeclarationNode(Declaration).GetPrototype;
      A := First;
      While Assigned(A) do
        begin
          if A is TFunctionPrototypeNode then
            if TFunctionPrototypeNode(A).MatchPrototype(P) then
              begin
                Result := TFunctionPrototypeNode(A);
                exit;
              end;
          A := A.Next;
        end;
    end;
  Result := nil;
end;



{                                                                              }
{ TSimpleIdentifierNode                                                        }
{                                                                              }
constructor TSimpleIdentifierNode.Create(const Identifier: String);
begin
  inherited Create;
  FIdentifier := Identifier;
end;

function TSimpleIdentifierNode.GetNodeParameterStr: String;
begin
  Result := FIdentifier;
end;

function TSimpleIdentifierNode.GetAsIdentifier: AIdentifier;
begin
  Result := TSimpleIdentifier.Create(FIdentifier);
end;

procedure TSimpleIdentifierNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Identifier(FIdentifier);
end;



{                                                                              }
{ TSelectedIdentifierNode                                                      }
{                                                                              }
function TSelectedIdentifierNode.GetAsIdentifier: AIdentifier;
var A, B : AIdentifierNode;
begin
  GetTwoIdentifierNodes(A, B);
  if not (B is TSimpleIdentifierNode) then
    NodeError('Invalid identifier');
  Result := TSelectedIdentifier.Create(A.GetAsIdentifier,
      TSimpleIdentifierNode(B).Identifier);
end;

procedure TSelectedIdentifierNode.WriteSource(const Writer: ASourceWriter);
var A, B : AIdentifierNode;
begin
  GetTwoIdentifierNodes(A, B);
  A.WriteSource(Writer);
  Writer.Symbol('.');
  B.WriteSource(Writer);
end;



{                                                                              }
{ TIndexNode                                                                   }
{                                                                              }
constructor TIndexNode.Create(const ReversedIndex: Boolean);
begin
  inherited Create;
  FReversedIndex := ReversedIndex;
end;

function TIndexNode.GetNodeParameterStr: String;
begin
  if FReversedIndex then
    Result := 'Reversed' else
    Result := '';
end;

procedure TIndexNode.WriteSource(const Writer: ASourceWriter);
var N : AExpressionNode;
begin
  if FReversedIndex then
    Writer.Symbol('<');
  N := GetExpressionNode(1);
  if Assigned(N) then
    N.WriteSource(Writer);
end;

function TIndexNode.GetAsSliceIndex: TSliceIndex;
begin
  Result := TSliceIndex.Create(GetOptionalExpression(1), FReversedIndex);
end;

function TIndexNode.GetAsSlice: TObject;
begin
  Result := TIndexSlice.Create(GetAsSliceIndex);
end;



{                                                                              }
{ TIndexedIdentifierNode                                                       }
{                                                                              }
function TIndexedIdentifierNode.GetAsIdentifier: AIdentifier;
var I : TIndexNode;
begin
  I := TIndexNode(RequireChildNode(1, TIndexNode));
  Result := TIndexedIdentifier.Create(GetIdentifier, I.GetExpression,
      I.FReversedIndex);
end;

procedure TIndexedIdentifierNode.WriteSource(const Writer: ASourceWriter);
var I : TIndexNode;
begin
  I := TIndexNode(RequireChildNode(1, TIndexNode));
  GetIdentifierNode.WriteSource(Writer);
  Writer.Symbol('[');
  I.WriteSource(Writer);
  Writer.Symbol(']');
end;



{                                                                              }
{ TRangeSliceNode                                                              }
{                                                                              }
function TRangeSliceNode.GetAsSlice: TObject;
var I, J : TIndexNode;
begin
  I := TIndexNode(RequireChildNode(1, TIndexNode));
  J := TIndexNode(RequireChildNode(2, TIndexNode));
  Result := TRangeSlice.Create(I.GetAsSliceIndex, J.GetAsSliceIndex,
      GetOptionalExpression(1));
end;

procedure TRangeSliceNode.WriteSource(const Writer: ASourceWriter);
var I, J : TIndexNode;
    E    : AExpressionNode;
begin
  I := TIndexNode(RequireChildNode(1, TIndexNode));
  J := TIndexNode(RequireChildNode(2, TIndexNode));
  E := GetExpressionNode(1);
  I.WriteSource(Writer);
  Writer.Symbol(':');
  J.WriteSource(Writer);
  if Assigned(E) then
    begin
      Writer.Symbol(':');
      E.WriteSource(Writer);
    end;
end;


{                                                                              }
{ TMultiSliceNode                                                              }
{                                                                              }
function TMultiSliceNode.GetAsSlice: TObject;
begin
  Result := TMultiSlice.Create;
end;

procedure TMultiSliceNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('...');
end;



{                                                                              }
{ TSlicedIdentifierNode                                                        }
{                                                                              }
function TSlicedIdentifierNode.GetAsIdentifier: AIdentifier;
var N : ABlaiseScriptNode;
    S : ObjectArray;
    V : TObject;
begin
  S := nil;
  V := nil;
  N := FFirst;
  While Assigned(N) do
    begin
      if not (N is AIdentifierNode) then
        begin
          if N is TIndexNode then
            V := TIndexNode(N).GetAsSlice else
          if N is TRangeSliceNode then
            V := TRangeSliceNode(N).GetAsSlice else
          if N is TMultiSliceNode then
            V := TMultiSliceNode(N).GetAsSlice
          else
            NodeError('Invalid slice node');
          Append(S, V);
        end;
      N := N.FNext;
    end;
  Result := TSlicedIdentifier.Create(GetIdentifier, S);
end;

procedure TSlicedIdentifierNode.WriteSource(const Writer: ASourceWriter);
var N : ABlaiseScriptNode;
    R : Boolean;
begin
  GetIdentifierNode.WriteSource(Writer);
  Writer.Symbol('[');
  N := FFirst;
  R := False;
  While Assigned(N) do
    begin
      if not (N is AIdentifierNode) then
        begin
          if R then
            begin
              Writer.Symbol(',');
              Writer.Space;
            end else
            R := True;
          N.WriteSource(Writer);
        end;
      N := N.FNext;
    end;
  Writer.Symbol(']');
end;



{                                                                              }
{ TIdentifierCallNode                                                          }
{                                                                              }
function TIdentifierCallNode.GetAsIdentifier: AIdentifier;
begin
  Result := TIdentifierCall.Create(GetIdentifier, GetExpressions);
end;

procedure TIdentifierCallNode.WriteSource(const Writer: ASourceWriter);
begin
  GetIdentifierNode.WriteSource(Writer);
  With Writer do
    begin
      Symbol('(');
      Expressions(GetExpressionNodes);
      Symbol(')');
    end;
end;



{                                                                              }
{ TSelfIdentifierNode                                                          }
{                                                                              }
function TSelfIdentifierNode.GetAsIdentifier: AIdentifier;
begin
  Result := TSelfIdentifier.Create;
end;

procedure TSelfIdentifierNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Self);
end;



{                                                                              }
{ TInheritedIdentifierNode                                                     }
{                                                                              }
function TInheritedIdentifierNode.GetAsIdentifier: AIdentifier;
begin
  Result := TInheritedIdentifier.Create(GetIdentifier);
end;

procedure TInheritedIdentifierNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_inherited);
  Writer.Space;
  GetIdentifierNode.WriteSource(Writer);
end;



{                                                                              }
{ TInterfaceSectionNode                                                        }
{                                                                              }
function TInterfaceSectionNode.GetUsesList: StringArray;
var U : TUsesNode;
begin
  U := TUsesNode(GetChildNode(1, TUsesNode));
  if Assigned(U) then
    Result := U.GetUsesList
  else
    Result := nil;
end;

function TInterfaceSectionNode.GetDeclarations: TDeclarationListNode;
begin
  Result := TDeclarationListNode(GetChildNode(1, TDeclarationListNode));
end;

procedure TInterfaceSectionNode.WriteSource(const Writer: ASourceWriter);
begin
  GetDeclarations.WriteSource(Writer);
end;



{                                                                              }
{ TImplementationSectionNode                                                   }
{                                                                              }
function TImplementationSectionNode.GetUsesList: StringArray;
var U : TUsesNode;
begin
  U := TUsesNode(GetChildNode(1, TUsesNode));
  if Assigned(U) then
    Result := U.GetUsesList
  else
    Result := nil;
end;

function TImplementationSectionNode.GetDeclarations: TDeclarationListNode;
begin
  Result := TDeclarationListNode(GetChildNode(1, TDeclarationListNode));
end;

procedure TImplementationSectionNode.WriteSource(const Writer: ASourceWriter);
begin
  GetDeclarations.WriteSource(Writer);
end;



{                                                                              }
{ TUnitNode                                                                    }
{                                                                              }
function TUnitNode.GetIdentifier: String;
begin
  Result := GetSimpleIdentifierValue(1, True);
end;

function TUnitNode.GetInterfaceSection: TInterfaceSectionNode;
begin
  Result := TInterfaceSectionNode(RequireChildNode(1, TInterfaceSectionNode));
end;

function TUnitNode.GetImplementationSection: TImplementationSectionNode;
begin
  Result := TImplementationSectionNode(RequireChildNode(1, TImplementationSectionNode));
end;

function TUnitNode.GetPublicDeclarations: AScopeFieldDefinitionArray;
var IntDecl : TDeclarationListNode;
    ImpDecl : TDeclarationListNode;
    Decl    : ABlaiseScriptNode;
    Impl    : ADeclarationNode;
begin
  IntDecl := GetInterfaceSection.GetDeclarations;
  ImpDecl := GetImplementationSection.GetDeclarations;
  Decl := IntDecl.First;
  Result := nil;
  While Assigned(Decl) do
    begin
      if Decl is TFunctionPrototypeNode then
        begin
          Impl := ImpDecl.GetImplementation(Decl);
          if not Assigned(Impl) then
            NodeError('Implementation not found');
          AppendObjectArray(ObjectArray(Result), ObjectArray(Impl.GetAsFieldDefinitions));
        end else
      if Decl is ADeclarationNode then
        AppendObjectArray(ObjectArray(Result),
            ObjectArray(ADeclarationNode(Decl).GetAsFieldDefinitions));
      Decl := Decl.Next;
    end;
end;

function TUnitNode.GetPrivateDeclarations: AScopeFieldDefinitionArray;
var IntDecl : TDeclarationListNode;
    ImpDecl : TDeclarationListNode;
    Decl    : ABlaiseScriptNode;
    Impl    : ADeclarationNode;
begin
  IntDecl := GetInterfaceSection.GetDeclarations;
  ImpDecl := GetImplementationSection.GetDeclarations;
  Impl := ADeclarationNode(ImpDecl.First);
  Result := nil;
  While Assigned(Impl) do
    begin
      if Impl is AFunctionDeclarationNode then
        begin
          Decl := IntDecl.GetPrototype(Impl);
          if not Assigned(Decl) then
            AppendObjectArray(ObjectArray(Result), ObjectArray(Impl.GetAsFieldDefinitions));
        end
      else
        AppendObjectArray(ObjectArray(Result), ObjectArray(Impl.GetAsFieldDefinitions));
      Impl := ADeclarationNode(Impl.Next);
    end;
end;

function TUnitNode.GetUnit: TBlaiseUnit;
begin
  Result := TBlaiseUnit.CreateEx(
      GetIdentifier,
      GetPublicDeclarations,
      GetPrivateDeclarations,
      GetInterfaceSection.GetUsesList,
      GetImplementationSection.GetUsesList);
end;

procedure TUnitNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Unit);
  Writer.Space;
  Writer.Identifier(GetIdentifier);
  Writer.SDelim;
  Writer.NewLine;
  Writer.NewLine;
  Writer.Keyword(c_Interface);
  Writer.NewLine;
  Writer.NewLine;
  GetInterfaceSection.WriteSource(Writer);
  Writer.NewLine;
  Writer.Keyword(c_Implementation);
  Writer.NewLine;
  Writer.NewLine;
  GetImplementationSection.WriteSource(Writer);
  Writer.NewLine;
  Writer.Keyword(c_End);
  Writer.Symbol('.');
  Writer.NewLine;
end;



{                                                                              }
{ TUsesNode                                                                    }
{                                                                              }
function TUsesNode.GetUsesList: StringArray;
begin
  Result := GetSimpleIdentifierValues;
end;

procedure TUsesNode.WriteSource(const Writer: ASourceWriter);
var S : StringArray;
    I : Integer;
begin
  S := GetSimpleIdentifierValues;
  With Writer do
    begin
      Keyword(c_Uses);
      Indent;
      For I := 0 to Length(S) - 1 do
        begin
          if I > 0 then
            Symbol(',');
          NewLine;
          Identifier(S[I]);
        end;
      SDelim;
      NewLine;
    end;
end;



{                                                                              }
{ TApplicationNode                                                             }
{                                                                              }
function TApplicationNode.GetDeclarations: TDeclarationListNode;
begin
  Result := TDeclarationListNode(GetChildNode(1, TDeclarationListNode));
end;

function TApplicationNode.GetUsesList: StringArray;
var U : TUsesNode;
begin
  U := TUsesNode(GetChildNode(1, TUsesNode));
  if Assigned(U) then
    Result := U.GetUsesList
  else
    Result := nil;
end;

function TApplicationNode.GetMain: AStatementNode;
begin
  Result := AStatementNode(GetChildNode(1, AStatementNode));
end;

function TApplicationNode.GetApplication: TBlaiseApplication;
var D : TDeclarationListNode;
    U : StringArray;
    F : AScopeFieldDefinitionArray;
begin
  U := GetUsesList;
  D := GetDeclarations;
  if Assigned(D) then
    F := D.GetAsFieldDefinitions
  else
    F := nil;
  Result := TBlaiseApplication.Create(U, F, GetMain.GetAsStatement);
end;

procedure TApplicationNode.WriteSource(const Writer: ASourceWriter);
var D : TDeclarationListNode;
    U : TUsesNode;
    M : AStatementNode;
begin
  D := GetDeclarations;
  U := TUsesNode(GetChildNode(1, TUsesNode));
  if Assigned(U) then
    begin
      U.WriteSource(Writer);
      Writer.NewLine;
    end;
  if Assigned(D) then
    begin
      D.WriteSource(Writer);
      Writer.NewLine;
    end;
  M := GetMain;
  if Assigned(M) then
    begin
      M.WriteSource(Writer);
      Writer.Symbol('.');
    end;
end;



end.

