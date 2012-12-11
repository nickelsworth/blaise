{                                                                              }
{                     Blaise syntactic statement nodes v0.01                   }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseParserNodesStmt.pas             }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise syntactic statement nodes.                     }
{                                                                              }
{ Revision history:                                                            }
{   14/04/2003  0.01  Created cBlaiseParserNodesStmt from cBlaiseParserNodes.  }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseParserNodesStmt;

interface

uses
  { Blaise }
  cBlaiseParserNodes,
  cBlaiseMachineTypes,
  cBlaiseMachineStatements;



{                                                                              }
{ TStatementBlockNode                                                          }
{                                                                              }
type
  TStatementBlockNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TIfStatementNode                                                             }
{                                                                              }
type
  TIfStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TAssignmentStatementNode                                                     }
{                                                                              }
type
  TAssignmentStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TProcedureCallStatementNode                                                  }
{                                                                              }
type
  TProcedureCallStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TRepeatStatementNode                                                         }
{                                                                              }
type
  TRepeatStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TWhileStatementNode                                                          }
{                                                                              }
type
  TWhileStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TForStatementNode                                                            }
{                                                                              }
type
  TForStatementNode = class(AStatementNode)
  protected
    FIncrease : Boolean;

  public
    property  Increase: Boolean read FIncrease write FIncrease;
    function  GetNodeParameterStr: String; override;
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TForEachStatementNode                                                        }
{                                                                              }
type
  TForEachStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TTextOutputStatementNode                                                     }
{                                                                              }
type
  TTextOutputStatementNode = class(AStatementNode)
  protected
    FNewLine : Boolean;

  public
    constructor Create(const NewLine: Boolean);
    function  GetNodeParameterStr: String; override;
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TExitStatementNode                                                           }
{                                                                              }
type
  TExitStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TBreakStatementNode                                                          }
{                                                                              }
type
  TBreakStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TContinueStatementNode                                                       }
{                                                                              }
type
  TContinueStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TReturnStatementNode                                                         }
{                                                                              }
type
  TReturnStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TImportStatementNode                                                         }
{                                                                              }
type
  TImportStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TRaiseStatementNode                                                          }
{                                                                              }
type
  TRaiseStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TTryFinallyStatementNode                                                     }
{                                                                              }
type
  TTryFinallyStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TOnExceptionClauseNode                                                       }
{                                                                              }
type
  TOnExceptionClauseNode = class(ABlaiseScriptNode)
  public
    function  GetAsExceptionHandlerDefinition: TExceptionHandlerDefinition;
  end;
  TOnExceptionClauseNodeArray = Array of TOnExceptionClauseNode;



{                                                                              }
{ TTryExceptStatementNode                                                      }
{                                                                              }
type
  TTryExceptStatementNode = class(AStatementNode)
  protected
    FHandleDefault: Boolean;

  public
    property  HandleDefault: Boolean read FHandleDefault write FHandleDefault;
    function  GetNodeParameterStr: String; override;
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TCaseStatementNode                                                           }
{                                                                              }
type
  TCaseCaseNode = class(ABlaiseScriptNode)
  public
    function  GetAsCaseCaseDefinition: TCaseCaseDefinition;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;
  TCaseCaseNodeArray = Array of TCaseCaseNode;

  TCaseStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TNamedAssignmentStatementNode                                                }
{                                                                              }
type
  TNamedAssignmentStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TNamedDeleteStatementNode                                                    }
{                                                                              }
type
  TNamedDeleteStatementNode = class(AStatementNode)
  public
    function  GetAsStatement: AStatement; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



implementation

uses
  { Blaise }
  cBlaiseParserLexer;



{                                                                              }
{ TStatementBlockNode                                                          }
{                                                                              }
function TStatementBlockNode.GetAsStatement: AStatement;
begin
  Result := TStatementBlock.Create(GetStatements);
end;

procedure TStatementBlockNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Begin);
      Indent;
      Statements(GetStatementNodes);
      Unindent;
      NewLine;
      Keyword(c_End);
    end;
end;



{                                                                              }
{ TIfStatementNode                                                             }
{                                                                              }
function TIfStatementNode.GetAsStatement: AStatement;
begin
  Result := TIfStatement.Create(GetExpression, GetStatement,
      GetOptionalStatement(2));
end;

procedure TIfStatementNode.WriteSource(const Writer: ASourceWriter);
var E : AExpressionNode;
begin
  With Writer do
    begin
      Keyword(c_If);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
      Space;
      Keyword(c_Then);
      Indent;
      NewLine;
      GetStatementNode(1).WriteSource(Writer);
      Unindent;
      E := GetExpressionNode(2);
      if Assigned(E) then
        begin
          Keyword(c_Else);
          Indent;
          NewLine;
          E.WriteSource(Writer);
          Unindent;
        end;
    end;
end;



{                                                                              }
{ TAssignmentStatementNode                                                     }
{                                                                              }
function TAssignmentStatementNode.GetAsStatement: AStatement;
begin
  Result := TAssignmentStatement.Create(GetIdentifier, GetExpression);
end;

procedure TAssignmentStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  GetIdentifierNode.WriteSource(Writer);
  With Writer do
    begin
      Space;
      Symbol(':=');
      Space;
    end;
  GetExpressionNode(1).WriteSource(Writer);
end;



{                                                                              }
{ TProcedureCallStatementNode                                                  }
{                                                                              }
function TProcedureCallStatementNode.GetAsStatement: AStatement;
begin
  Result := TProcedureCallStatement.Create(GetIdentifier);
end;

procedure TProcedureCallStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  GetIdentifierNode.WriteSource(Writer);
end;



{                                                                              }
{ TRepeatStatementNode                                                         }
{                                                                              }
function TRepeatStatementNode.GetAsStatement: AStatement;
begin
  Result := TRepeatStatement.Create(GetStatementsAsStatement, GetExpression);
end;

procedure TRepeatStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Repeat);
      Indent;
      Statements(GetStatementNodes);
      Unindent;
      NewLine;
      Keyword(c_Until);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
    end;
end;


{                                                                              }
{ TWhileStatementNode                                                          }
{                                                                              }
function TWhileStatementNode.GetAsStatement: AStatement;
begin
  Result := TWhileStatement.Create(GetExpression, GetOptionalStatement(1));
end;

procedure TWhileStatementNode.WriteSource(const Writer: ASourceWriter);
var S : AStatementNode;
begin
  With Writer do
    begin
      Keyword(c_While);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
      Space;
      Keyword(c_Do);
      S := GetStatementNode(1);
      if Assigned(S) then
        begin
          Indent;
          NewLine;
          S.WriteSource(Writer);
          Unindent;
        end
      else
        Space;
    end;
end;


{                                                                              }
{ TForStatementNode                                                            }
{                                                                              }
function TForStatementNode.GetNodeParameterStr: String;
begin
  if FIncrease then
    Result := ''
  else
    Result := 'downto';
end;

function TForStatementNode.GetAsStatement: AStatement;
var A, B : AExpression;
begin
  GetTwoExpressions(A, B);
  Result := TForStatement.Create(GetSimpleIdentifierValue(1, True), A, B,
      FIncrease, GetOptionalStatement(1));
end;

procedure TForStatementNode.WriteSource(const Writer: ASourceWriter);
var A, B : AExpressionNode;
    S    : AStatementNode;
begin
  GetTwoExpressionNodes(A, B);
  With Writer do
    begin
      Keyword(c_For);
      Space;
      Identifier(GetSimpleIdentifierValue(1, True));
      Space;
      Symbol(':=');
      Space;
      A.WriteSource(Writer);
      Space;
      if FIncrease then
        Keyword(c_To)
      else
        Keyword(c_DownTo);
      Space;
      B.WriteSource(Writer);
      Space;
      Keyword(c_Do);
      S := GetStatementNode(1);
      if Assigned(S) then
        begin
          Indent;
          NewLine;
          S.WriteSource(Writer);
          Unindent;
        end
      else
        Space;
    end;
end;



{                                                                              }
{ TForEachStatementNode                                                        }
{                                                                              }
function TForEachStatementNode.GetAsStatement: AStatement;
begin
  Result := TForEachStatement.Create(GetSimpleIdentifierValue(1, True),
      GetExpression, GetOptionalExpression(2),
      GetOptionalStatement(1), GetOptionalStatement(2));
end;

procedure TForEachStatementNode.WriteSource(const Writer: ASourceWriter);
var S : AStatementNode;
begin
  With Writer do
    begin
      Keyword(c_For);
      Space;
      Identifier(GetSimpleIdentifierValue(1, True));
      Space;
      Keyword(c_In);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
      Space;
      Keyword(c_Do);
      S := GetStatementNode(1);
      if Assigned(S) then
        begin
          Indent;
          NewLine;
          S.WriteSource(Writer);
          Unindent;
        end
      else
        Space;
    end;
end;



{                                                                              }
{ TTextOutputStatementNode                                                     }
{                                                                              }
constructor TTextOutputStatementNode.Create(const NewLine: Boolean);
begin
  inherited Create;
  FNewLine := NewLine;
end;

function TTextOutputStatementNode.GetNodeParameterStr: String;
begin
  if FNewLine then
    Result := 'NewLine'
  else
    Result := '';
end;

function TTextOutputStatementNode.GetAsStatement: AStatement;
begin
  Result := TTextOutputStatement.Create(GetOptionalIdentifier, GetExpressions,
      FNewLine);
end;

procedure TTextOutputStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      if FNewLine then
        Identifier(c_Writeln)
      else
        Identifier(c_Write);
      Symbol('(');
      Expressions(GetExpressionNodes);
      Symbol(')');
    end;
end;



{                                                                              }
{ TExitStatementNode                                                           }
{                                                                              }
function TExitStatementNode.GetAsStatement: AStatement;
begin
  Result := TExitStatement.Create;
end;

procedure TExitStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Exit);
end;



{                                                                              }
{ TBreakStatementNode                                                          }
{                                                                              }
function TBreakStatementNode.GetAsStatement: AStatement;
begin
  Result := TBreakStatement.Create;
end;

procedure TBreakStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Break);
end;



{                                                                              }
{ TContinueStatementNode                                                       }
{                                                                              }
function TContinueStatementNode.GetAsStatement: AStatement;
begin
  Result := TContinueStatement.Create;
end;

procedure TContinueStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Continue);
end;



{                                                                              }
{ TReturnStatementNode                                                         }
{                                                                              }
function TReturnStatementNode.GetAsStatement: AStatement;
begin
  Result := TReturnStatement.Create(GetExpression);
end;

procedure TReturnStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Return);
      Space;
    end;
  GetExpressionNode(1).WriteSource(Writer);
end;



{                                                                              }
{ TImportStatementNode                                                         }
{                                                                              }
function TImportStatementNode.GetAsStatement: AStatement;
begin
  Result := TImportStatement.Create(GetSimpleIdentifierValue(1, True),
      GetSimpleIdentifierValue(2, True));
end;

procedure TImportStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Import);
      Space;
      Identifier(GetSimpleIdentifierValue(1, True));
      Space;
      Keyword(c_From);
      Space;
      Identifier(GetSimpleIdentifierValue(2, True));
    end;
end;



{                                                                              }
{ TRaiseStatementNode                                                          }
{                                                                              }
function TRaiseStatementNode.GetAsStatement: AStatement;
begin
  Result := TRaiseStatement.Create(GetOptionalExpression(1));
end;

procedure TRaiseStatementNode.WriteSource(const Writer: ASourceWriter);
var E : AExpressionNode;
begin
  E := GetExpressionNode(1);
  Writer.Keyword(c_Raise);
  if Assigned(E) then
    begin
      Writer.Space;
      E.WriteSource(Writer);
    end;
end;



{                                                                              }
{ TTryFinallyStatementNode                                                     }
{                                                                              }
function TTryFinallyStatementNode.GetAsStatement: AStatement;
begin
  Result := TTryFinallyStatement.Create(GetOptionalStatement(1),
      GetOptionalStatement(2));
end;

procedure TTryFinallyStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Try);
      NewLine;
      Keyword(c_Finally);
      NewLine;
      Keyword(c_End);
    end;
end;



{                                                                              }
{ TOnExceptionClauseNode                                                       }
{                                                                              }
function TOnExceptionClauseNode.GetAsExceptionHandlerDefinition: TExceptionHandlerDefinition;
var S, T : String;
begin
  S := GetSimpleIdentifierValue(1, True);
  T := GetSimpleIdentifierValue(2, False);
  if T <> '' then
    begin
      Result.TypeIdentifier := T;
      Result.Identifier := S;
    end else
    begin
      Result.TypeIdentifier := S;
      Result.Identifier := '';
    end;
  Result.Statement := GetOptionalStatement(1);
end;



{                                                                              }
{ TTryExceptStatementNode                                                      }
{                                                                              }
function TTryExceptStatementNode.GetNodeParameterStr: String;
begin
  if FHandleDefault then
    Result := 'default'
  else
    Result := '';
end;

function TTryExceptStatementNode.GetAsStatement: AStatement;
var N    : TOnExceptionClauseNodeArray;
    H    : TExceptionHandlerDefinitionArray;
    I, L : Integer;
begin
  N := TOnExceptionClauseNodeArray(GetChildNodes(TOnExceptionClauseNode));
  L := Length(N);
  SetLength(H, L);
  For I := 0 to L - 1 do
    H[I] := N[I].GetAsExceptionHandlerDefinition;
  Result := TTryExceptStatement.Create(GetOptionalStatement(1),
      GetOptionalStatement(2), FHandleDefault, H);
end;

procedure TTryExceptStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Try);
      NewLine;
      Keyword(c_Except);
      NewLine;
      Keyword(c_End);
    end;
end;


{                                                                              }
{ TCaseCaseNode                                                                }
{                                                                              }
function TCaseCaseNode.GetAsCaseCaseDefinition: TCaseCaseDefinition;
var E, H : AExpression;
begin
  E := GetExpression;
  H := GetOptionalExpression(2);
  Result := TCaseCaseDefinition.Create;
  Result.Expression := E;
  Result.HighExpression := H;
  Result.Statement := GetOptionalStatement(1);
end;

procedure TCaseCaseNode.WriteSource(const Writer: ASourceWriter);
var E, H : AExpressionNode;
    S    : AStatementNode;
begin
  E := GetExpressionNode(1);
  H := GetExpressionNode(2);
  E.WriteSource(Writer);
  With Writer do
    begin
      if Assigned(H) then
        begin
          Symbol('..');
          H.WriteSource(Writer);
        end;
      Space;
      Symbol(':');
      Space;
      S := GetStatementNode(1);
      if Assigned(S) then
        S.WriteSource(Writer);
      SDelim;
    end;
end;



{                                                                              }
{ TCaseStatementNode                                                           }
{                                                                              }
function TCaseStatementNode.GetAsStatement: AStatement;
var C    : TCaseCaseDefinitionArray;
    N    : TCaseCaseNodeArray;
    I, L : Integer;
begin
  N := TCaseCaseNodeArray(GetChildNodes(TCaseCaseNode));
  L := Length(N);
  SetLength(C, L);
  For I := 0 to L - 1 do
    C[I] := N[I].GetAsCaseCaseDefinition;
  Result := TCaseStatement.Create(GetExpression, C, GetOptionalStatement(1));
end;

procedure TCaseStatementNode.WriteSource(const Writer: ASourceWriter);
var N : TCaseCaseNodeArray;
    I : Integer;
    E : AStatementNode;
begin
  N := TCaseCaseNodeArray(GetChildNodes(TCaseCaseNode));
  With Writer do
    begin
      Keyword(c_Case);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
      Space;
      KeyWord(c_Of);
      Indent;
      For I := 0 to Length(N) - 1 do
        begin
          NewLine;
          N[I].WriteSource(Writer);
        end;
      Unindent;
      E := GetStatementNode(1);
      if Assigned(E) then
        begin
          NewLine;
          Keyword(c_Else);
          Indent;
          NewLine;
          E.WriteSource(Writer);
          Unindent;
        end;
      NewLine;
      Keyword(c_End);
    end;
end;



{                                                                              }
{ TNamedAssignmentStatementNode                                                }
{                                                                              }
function TNamedAssignmentStatementNode.GetAsStatement: AStatement;
var A, B : AExpression;
begin
  GetTwoExpressions(A, B);
  Result := TNamedAssignmentStatement.Create(A, B);
end;

procedure TNamedAssignmentStatementNode.WriteSource(const Writer: ASourceWriter);
var A, B : AExpressionNode;
begin
  GetTwoExpressionNodes(A, B);
  With Writer do
    begin
      Keyword(c_Named);
      Space;
      A.WriteSource(Writer);
      Space;
      Symbol(':=');
      Space;
      B.WriteSource(Writer);
    end;
end;



{                                                                              }
{ TNamedDeleteStatementNode                                                    }
{                                                                              }
function TNamedDeleteStatementNode.GetAsStatement: AStatement;
begin
  Result := TNamedDeleteStatement.Create(GetExpression);
end;

procedure TNamedDeleteStatementNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Named);
      Space;
      Keyword(c_Delete);
      Space;
    end;
  GetExpressionNode(1).WriteSource(Writer);
end;



end.

