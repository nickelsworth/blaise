{$INCLUDE cHeader.inc}
unit cBlaiseParser;

{                                                                              }
{                              Blaise Parser v0.43                             }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                             All rights reserved.                             }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{                Its original file name is cBlaiseParser.pas                   }
{                                                                              }
{                                                                              }
{ Revision history:                                                            }
{   21/05/99  0.01  Expression parser and evaluator. 650 lines.                }
{   22/05/99  0.02  Added strings values.                                      }
{   23/05/99  0.03  Initial statement parser.                                  }
{   23/05/99  0.04  Removed TMathExpressionLexGenerator.                       }
{   01/06/99  0.05  Added TDataStore, TConstantIdentifier                      }
{                   Removed TRootMathExpression class, changing Optimize to    }
{                   a function that returns a optimized copy of self.          }
{   01/06/99  0.06  Added DataStore classes.                                   }
{                   Added TIfStatement, TBlockStatement                        }
{   20/06/99  0.07  Added TAssignmentExpression                                }
{                   Moved DataStore to cDataStore                              }
{   20/06/99  0.08  Renamed from cStatementParser to cScriptParser             }
{                   Const, Type, Var declarations                              }
{   21/06/99  0.09  TStatement now inherits from TSyntacticNode instead of     }
{                   TTreeNode directly.                                        }
{                   Added For Each statement.                                  }
{   21/06/99  0.10  Added TSyntacticNode                                       }
{   22/06/99  0.11  Added list constants, TArrayExpression                     }
{   09/07/99  0.12  Moved TSyntacticNode from cMathExprParser so that          }
{                   cRegExParser can also use it.                              }
{   06/12/99  0.13  TSyntacticNode now inherits from TTTreeType.               }
{   18/12/99  0.14  Rational numbers implemented.                              }
{   19/12/99  0.15  Lists and complex numbers implemented.                     }
{   20/12/99  0.16  Regular expression type implemented.                       }
{   21/12/99  0.17  Identifiers and assignment implemented.                    }
{   22/12/99  0.18  Bugs for breakfast.                                        }
{   24/12/99  0.19  Redefining language, using L0 and L1 units, now part of    }
{                   L2 units.                                                  }
{   26/03/00  0.20  Compilable state.                                          }
{   01/04/00  0.21  Support for structured identifiers.                        }
{   19/04/01  0.22  Support for dictionaries and list items.                   }
{   22/04/01  0.23  Reworked language syntax.                                  }
{   18/05/01  0.24  Moved Pascal Script language into cPascalScript.           }
{                   Unit now only has syntactic structures of a math expr.     }
{   26/05/01  0.25  Refactored.                                                }
{   31/07/00  0.26  Recompilable with "Delphi Fundamentals".                   }
{   29/08/00  0.27  Recompilable after latest round of changes to L0/L1.       }
{   29/08/00  0.28  Compilable state.                                          }
{   01/09/00  0.29  Comments. Writeln. Functions.                              }
{   04/09/00  0.30  Renamed unit to cPascalScriptBase                          }
{   03/01/01  0.31  Refactored with latest changes to namespaces (cExTypes).   }
{   12/01/01  0.32  Compilable state.                                          }
{   19/04/01  0.33  Compilable state.                                          }
{   21/04/01  0.34  Added TCaseStatement.                                      }
{   26/05/01  0.35  Moved from L2 to L0. Moved Pascal Script to                }
{                   cPascalScript. Kept syntactic nodes.                       }
{                   Refactored unit.                                           }
{   26/05/01  0.36  Moved Pascal Script from cMathExpr and cScript.            }
{                   Refactored.                                                }
{   28/05/01  0.37  Merged cMathExpr / cScriptParser into cPascalScript.       }
{   30/09/01  0.38  Moved TPascalScriptScope and related classes to            }
{                   cPascalScriptScope.                                        }
{   13/10/01  0.39  Replaced Execute/Evalute methods with classes from         }
{                   cPascalScriptScope / cPascalScriptMachine.                 }
{   14/05/02  0.40  Moved Lexer to unit cBlaiseLexer.                          }
{   09/06/02  0.41  Moved Nodes to unit cBlaiseParserNodes.                    }
{   26/04/03  0.42  Added slicing.                                             }
{   30/05/03  0.43  Added import statement.                                    }
{                                                                              }

interface


uses
  { Blaise }
  cBlaiseParserLexer,
  cBlaiseParserNodes;



{                                                                              }
{ Version                                                                      }
{                                                                              }
const
  UnitVersion = '0.43';
  BlaiseParserVersion = '1';



{                                                                              }
{ TBlaiseScriptParser                                                          }
{                                                                              }
type
  TNodeParseProc = function : ABlaiseScriptNode of object;
  EBlaiseScriptParser = class(EBlaiseLexer);
  TBlaiseScriptParser = class(TBlaiseLexer)
  protected
    procedure ParseError(const Msg: String);

    procedure ExpectType(const TokenType: Integer; const TypeExpected: String;
              const Skip: Boolean = True);
    procedure ExpectStatementDelim;

    function  ParseNode(const NodeParseProc: TNodeParseProc;
              const RelPos: Integer;
              const Required: String = ''): ABlaiseScriptNode;
    function  ParseChildSeq(const NodeClass: CBlaiseScriptNode;
              const AbsPos: Integer;
              const Seq: Array of TNodeParseProc;
              const Required: Array of String): ABlaiseScriptNode;
    function  ParseChildMult(const Node: ABlaiseScriptNode;
              const AbsPos: Integer; const Child: TNodeParseProc;
              const DelimiterToken: Integer; const DelimTypeExpected: String;
              const DelimRequired: Boolean): Integer;
    function  ParseCommaSepIdentifiers(const NodeClass: CBlaiseScriptNode;
              const AbsPos: Integer): ABlaiseScriptNode;
    function  ParseAny(const AbsPos: Integer;
              const Options: Array of TNodeParseProc): ABlaiseScriptNode;
    procedure ParseStatementList(const Node: ABlaiseScriptNode;
              const AbsPos: Integer);
    procedure ParseParamValues(const Node: ABlaiseScriptNode;
              const AbsPos: Integer);
    function  ParseFuncLikePrototype(const TokenType: Integer;
              const AbsPos: Integer): ABlaiseScriptNode;
    procedure ParseClassDefinition(const Node: ABlaiseScriptNode;
              const AbsPos: Integer);
    function  ParseSection(const SectionClass: CBlaiseScriptNode;
              const DelimiterToken: Integer): ABlaiseScriptNode;
    function  ParseDeclarationsLike(const DeclarationsClass: CBlaiseScriptNode;
              const FunctionParser: TNodeParseProc): ABlaiseScriptNode;
    function  ParseIdentifiersTypeAndValue(const NodeClass: CBlaiseScriptNode;
              const ValueRequired: Boolean): ABlaiseScriptNode;
    function  ParseSpecifierWithIdentifier(const TokenText: String;
              const SpecifierClass: CBlaiseScriptNode): ABlaiseScriptNode;

    function  ParseExpression: ABlaiseScriptNode;
    function  ParseIdentifier: ABlaiseScriptNode;
    function  ParseSelf: ABlaiseScriptNode;
    function  ParseStringLiteral: ABlaiseScriptNode;
    function  ParseIntegerLiteral: ABlaiseScriptNode;
    function  ParseEnumeratedTypeValue: ABlaiseScriptNode;
    function  ParseEnumeratedTypeOrIdentifierType: ABlaiseScriptNode;
    function  ParseSetType: ABlaiseScriptNode;
    function  ParseRecordType: ABlaiseScriptNode;
    function  ParseRecordFieldDefinition: ABlaiseScriptNode;
    function  ParsePrivateSection: ABlaiseScriptNode;
    function  ParseProtectedSection: ABlaiseScriptNode;
    function  ParsePublicSection: ABlaiseScriptNode;
    function  ParseClassType: ABlaiseScriptNode;
    function  ParseArrayType: ABlaiseScriptNode;
    function  ParseStreamType: ABlaiseScriptNode;
    function  ParseDictionaryType: ABlaiseScriptNode;
    function  ParseTypeDefinition: ABlaiseScriptNode;
    function  ParseConstDeclaration: ABlaiseScriptNode;
    function  ParseVarDeclaration: ABlaiseScriptNode;
    function  ParseTypeDeclaration: ABlaiseScriptNode;
    function  ParseMemberDefinition: ABlaiseScriptNode;
    function  ParseParamDefinition: ABlaiseScriptNode;
    function  ParsePropertyPrototype: ABlaiseScriptNode;
    function  ParseConstructorProtoType: ABlaiseScriptNode;
    function  ParseDestructorProtoType: ABlaiseScriptNode;
    function  ParseFuncProtoType: ABlaiseScriptNode;
    function  ParseFunctionPrototype: ABlaiseScriptNode;
    function  ParseReadSpecifier: ABlaiseScriptNode;
    function  ParseWriteSpecifier: ABlaiseScriptNode;
    function  ParseProcProtoType: ABlaiseScriptNode;
    function  ParseTaskProtoType: ABlaiseScriptNode;
    function  ParseFunctionDirectives: ABlaiseScriptNode;
    function  ParseFunctionDeclaration: ABlaiseScriptNode;
    function  ParseDeclarations: ABlaiseScriptNode;
    function  ParseStatement: ABlaiseScriptNode;
    function  ParseBlock: ABlaiseScriptNode;
    function  ParseProgramDeclaration: ABlaiseScriptNode;
    function  ParseUsesClause: ABlaiseScriptNode;
    function  ParseIdentifierStatement: ABlaiseScriptNode;
    function  ParseNamedStatement: ABlaiseScriptNode;
    function  ParseReadWriteStatement: ABlaiseScriptNode;
    function  ParseRaiseStatement: ABlaiseScriptNode;
    function  ParseExitStatement: ABlaiseScriptNode;
    function  ParseBreakStatement: ABlaiseScriptNode;
    function  ParseContinueStatement: ABlaiseScriptNode;
    function  ParseReturnStatement: ABlaiseScriptNode;
    function  ParseImportStatement: ABlaiseScriptNode;
    function  ParseSlice: ABlaiseScriptNode;
    function  ParseName: ABlaiseScriptNode;
    function  ParseTextWriteStatement: ABlaiseScriptNode;
    function  ParseSimpleStatement: ABlaiseScriptNode;
    function  ParseOnExceptionClause: ABlaiseScriptNode;
    function  ParseTryStatement: ABlaiseScriptNode;
    function  ParseIfStatement: ABlaiseScriptNode;
    function  ParseCaseCaseNode: ABlaiseScriptNode;
    function  ParseCaseStatement: ABlaiseScriptNode;
    function  ParseRepeatStatement: ABlaiseScriptNode;
    function  ParseForStatement: ABlaiseScriptNode;
    function  ParseWhileStatement: ABlaiseScriptNode;
    function  ParseCompoundStatement: ABlaiseScriptNode;
    function  ParseProgram: ABlaiseScriptNode;
    function  ParseInterfaceDefinition: ABlaiseScriptNode;
    function  ParseInterfaceSection: ABlaiseScriptNode;
    function  ParseImplementationSection: ABlaiseScriptNode;
    function  ParseUnit: ABlaiseScriptNode;

  public
    procedure SetFileName(const FileName: String);

    function  ExtractExpression: AExpressionNode;
    function  ExtractStatement: AStatementNode;
    function  ExtractSource: ABlaiseScriptNode;
    function  ExtractDeclarations: TDeclarationListNode;
    function  ExtractImmediate: ABlaiseScriptNode;
  end;

function  ParseBlaiseScriptStatement(const Data: Pointer;
          const Size: Integer): AStatementNode; overload;
function  ParseBlaiseScriptStatement(const S: String): AStatementNode; overload;
function  ParseBlaiseScriptExpression(const S: String): AExpressionNode;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cStrings,
  cReaders,
  cComplex,

  { Blaise }
  cBlaiseStructsSimple,
  cBlaiseParserNodesDecl,
  cBlaiseParserNodesExpr,
  cBlaiseParserNodesStmt;



{                                                                              }
{ TBlaiseScriptParser                                                          }
{                                                                              }
procedure TBlaiseScriptParser.SetFileName(const FileName: String);
begin
  SetText(ReadFileToStr(FileName));
end;

procedure TBlaiseScriptParser.ParseError(const Msg: String);
begin
  raise EBlaiseScriptParser.Create(self, Msg);
end;



{                                                                              }
{ Syntactic Parser                                                             }
{                                                                              }
procedure TBlaiseScriptParser.ExpectType(const TokenType: Integer;
    const TypeExpected: String; const Skip: Boolean);
begin
  if TokenType <> FTokenType then
    ParseError(TypeExpected + ' expected');
  if Skip then
    GetToken;
end;

procedure TBlaiseScriptParser.ExpectStatementDelim;
begin
  ExpectType(ttStatementDelim, c_SDelim, True);
end;

function TBlaiseScriptParser.ParseNode(const NodeParseProc: TNodeParseProc;
    const RelPos: Integer; const Required: String): ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  Result := NodeParseProc;
  if (Required <> '') and not Assigned(Result) then
    ParseError(Required + ' expected');
  if Assigned(Result) then
    begin
      Result.RelSourcePos := RelPos;
      Result.SourceLen := LastTokenEnd - P;
    end;
end;

function TBlaiseScriptParser.ParseChildSeq(const NodeClass: CBlaiseScriptNode;
    const AbsPos: Integer; const Seq: Array of TNodeParseProc;
    const Required: Array of String): ABlaiseScriptNode;
var I : Integer;
begin
  Result := NodeClass.Create;
  try
    For I := 0 to Length(Seq) - 1 do
      Result.AddChild(ParseNode(Seq[I], TokenPos - AbsPos, Required[I]));
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TBlaiseScriptParser.ParseChildMult(const Node: ABlaiseScriptNode;
    const AbsPos: Integer; const Child: TNodeParseProc;
    const DelimiterToken: Integer; const DelimTypeExpected: String;
    const DelimRequired: Boolean): Integer;
var N : ABlaiseScriptNode;
begin
  Result := 0;
  Repeat
    N := ParseNode(Child, TokenPos - AbsPos);
    if Assigned(N) then
      begin
        Node.AddChild(N);
        Inc(Result);
        if DelimiterToken <> ttEOF then
          if DelimRequired then
            ExpectType(DelimiterToken, DelimTypeExpected, True) else
            if not MatchType(DelimiterToken, True) then
              exit;
      end;
  Until not Assigned(N);
end;

function TBlaiseScriptParser.ParseCommaSepIdentifiers(
    const NodeClass: CBlaiseScriptNode;
    const AbsPos: Integer): ABlaiseScriptNode;
var R : Boolean;
begin
  Result := NodeClass.Create;
  try
    Repeat
      Result.AddChild(ParseNode(ParseIdentifier, TokenPos - AbsPos, 'Identifier'));
      R := TokenType = ttComma;
      if R then
        GetToken;
    Until not R;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TBlaiseScriptParser.ParseAny(const AbsPos: Integer;
       const Options: Array of TNodeParseProc): ABlaiseScriptNode;
var I : Integer;
begin
  Result := nil;
  For I := 0 to Length(Options) - 1 do
    begin
      Result := ParseNode(Options[I], TokenPos - AbsPos);
      if Assigned(Result) then
        exit;
    end;
end;



{                                                                              }
{ Expression Syntactic Parser                                                  }
{                                                                              }

{ StringLiteral ::=  <CharLiteral>* <QuotedString> ( <CharLiteral>+ <StringLiteral> ) }
function TBlaiseScriptParser.ParseStringLiteral: ABlaiseScriptNode;
var R : Boolean;
    S : String;
    I : Int64;
begin
  S := '';
  Repeat
    While TokenType = ttHash do
      begin
        GetToken;
        I := TokenAsInteger;
        if (I < 0) or (I > $FF) then
          ParseError('Character out of range');
        S := S + Char(I);
        GetToken;
      end;
    if TokenType = ttStringLiteral then
      begin
        S := S + StrUnquote(TokenText);
        GetToken;
        R := TokenType <> ttHash;
      end else
      R := True;
  Until R ;
  Result := TStringConstantExpressionNode.Create(S);
end;

function TBlaiseScriptParser.ParseIntegerLiteral: ABlaiseScriptNode;
begin
  Result := TIntegerConstantExpressionNode.Create(TokenAsInteger);
  GetToken;
end;

function TBlaiseScriptParser.ParseExpression: ABlaiseScriptNode;

  procedure ParseLevel1(var Expr: AExpressionNode; const AbsPos: Integer); forward;

  // () literals conditionals identifiers                                     //
  procedure ParseLevel7(var Expr: AExpressionNode; const AbsPos: Integer);
  var V, C, TV, FV  : AExpressionNode;
      T             : Integer;
      N, P          : ABlaiseScriptNode;
  begin
    Case TokenType of
      ttInherited, ttIdentifier, ttSelf : // Identifiers
        begin
          N := ParseNode(ParseName, 0, 'Name');
          if TokenType = ttAssignment then // Assignment
            begin
              if not (N is AIdentifierNode) then
                ParseError('Can not assign to left side');
              GetToken;
              V := nil;
              ParseLevel1(V, 0);
              if not Assigned(V) then
                ParseError('Expression expected');
              Expr := TAssignmentExpressionNode.Create(AIdentifierNode(N), V);
            end else
          if N is AIdentifierNode then
            Expr := TIdentifierExpressionNode.Create(AIdentifierNode(N)) else
          if N is AExpressionNode then
            Expr := AExpressionNode(N) else
            ParseError('Unexpected node type')
        end;
      ttNamed : // Named
        begin
          GetToken;
          if MatchTokenText(c_Exists, True, False) then
            begin
              ParseLevel1(Expr, TokenPos);
              Expr := TNamedExistsExpressionNode.Create(Expr);
            end else
          if MatchTokenText(c_Dir, True, False) then
            begin
              ParseLevel1(Expr, TokenPos);
              Expr := TNamedDirectoryExpressionNode.Create(Expr);
            end else
            begin
              ParseLevel1(Expr, TokenPos);
              Expr := TNamedExpressionNode.Create(Expr);
            end;
        end;
      ttOpenBlockBracket : // List constant
        begin
          GetToken;
          if MatchType(ttCloseBlockBracket, True) then
            Expr := TArrayConstructorExpressionNode.Create else
          if MatchType(ttColon, True) then
            begin
              ExpectType(ttCloseBlockBracket, ']', True);
              Expr := TDictionaryConstructorExpressionNode.Create;
            end else
            begin
              V := AExpressionNode(ParseNode(ParseExpression, 0, 'Expression'));
              if MatchType(ttColon, True) then // Dictionary constant
                begin
                  Expr := TDictionaryConstructorExpressionNode.Create;
                  Expr.AddChild(V);
                  Expr.AddChild(ParseNode(ParseExpression, 0, 'Expression'));
                  While MatchType(ttComma, True) do
                    begin
                      Expr.AddChild(ParseNode(ParseExpression, 0, 'Expression'));
                      ExpectType(ttColon, ':', True);
                      Expr.AddChild(ParseNode(ParseExpression, 0, 'Expression'));
                    end;
                end else
              if MatchType(ttFor, True) then // List comprehension
                begin
                  Expr := TListComprehensionExpressionNode.Create;
                  Expr.AddChild(V);
                  P := nil;
                  Repeat
                    N := TListComprehensionLoopNode.Create;
                    N.AddChild(ParseNode(ParseIdentifier, 0, 'Identifier'));
                    ExpectType(ttIn, c_In, True);
                    N.AddChild(ParseNode(ParseExpression, 0, 'Expression'));
                    if MatchType(ttWhere, True) then
                      N.AddChild(ParseNode(ParseExpression, 0, 'Expression'));
                    if Assigned(P) then
                      N.AddChild(P);
                    P := N;
                  Until not MatchType(ttFor, True);
                  Expr.AddChild(P);
                end
              else // Array constant
                begin
                  Expr := TArrayConstructorExpressionNode.Create;
                  Expr.AddChild(V);
                  While MatchType(ttComma, True) do
                    Expr.AddChild(ParseNode(ParseExpression, 0, 'Expression'));
                end;
              ExpectType(ttCloseBlockBracket, ']', True);
            end;
        end;
      ttNil : // Nil
        begin
          Expr := TNilExpressionNode.Create;
          GetToken;
        end;
      ttOpenBracket : // Parentheses
        begin
          GetToken;
          ParseLevel1(Expr, TokenPos);
          ExpectType(ttCloseBracket, ')', True);
        end;
      ttHash, ttStringLiteral : // String literals
        Expr := ParseNode(ParseStringLiteral, TokenPos - AbsPos) as AExpressionNode;
      ttNumber, ttHexNumber, ttBinaryNumber, ttHexNumber2 : // Integer literals
        Expr := ParseNode(ParseIntegerLiteral, TokenPos - AbsPos) as AExpressionNode;
      ttPlus, ttMinus : // Signed
        begin
          T := TokenType;
          GetToken;
          V := nil;
          ParseLevel7(V, 0);
          if not Assigned(V) then
            ParseError('Expression expected');
          Expr := V;
          if T = ttMinus then
            Expr := TNegateExpressionNode.Create(Expr);
        end;
      ttRealNumber, ttSciRealNumber : // Real constant
        begin
          Expr := TFloatConstantExpressionNode.Create(StrToFloat(TokenText));
          GetToken;
        end;
      ttComplexNumber : // Complex constant
        begin
          Expr := TComplexConstantExpressionNode.Create(StrToFloat(
              CopyLeft(TokenText, Length(TokenText) - 1)));
          GetToken;
        end;
      ttTrue, ttFalse : // Boolean constant
        begin
          Expr := TBooleanConstantExpressionNode.Create(TokenType = ttTrue);
          GetToken;
        end;
      ttIf : // Conditional
        begin
          GetToken;
          C := nil;
          ParseLevel1(C, 0);
          ExpectType(ttThen, ',', True);
          TV := nil;
          ParseLevel1(TV, 0);
          ExpectType(ttElse, ',', True);
          FV := nil;
          ParseLevel1(FV, 0);
          Expr := TConditionalExpressionNode.Create(C, TV, FV);
        end;
      ttRegExLiteral : // RegEx constant
        begin
          ParseError('RegEx not implemented');
          // Expr := TConstantExpressionNode.Create(RegEx);
        end;
      else
        Expr := nil;
    end;
  end;

  //                                                                          //
  procedure ParseLevel6(var Expr: AExpressionNode; const AbsPos: Integer);
  begin
    ParseLevel7(Expr, AbsPos);
  end;

  // Power                                                                    //
  procedure ParseLevel5(var Expr: AExpressionNode; const AbsPos: Integer);
  var E : AExpressionNode;
  begin
    ParseLevel6(Expr, AbsPos);
    While TokenType = ttPower do
      begin
        if not Assigned(Expr) then
          ParseError('Expression expected');
        GetToken;
        E := nil;
        ParseLevel6(E, 0);
        if not Assigned(E) then
          ParseError('Operand expected');
        Expr := TPowerExpressionNode.Create(Expr, E);
      end;
  end;

  // Not                                                                      //
  procedure ParseLevel4(var Expr: AExpressionNode; const AbsPos: Integer);
  begin
    ParseLevel5(Expr, AbsPos);
    if TokenType = ttNOT then
      begin
        if Assigned(Expr) then
          ParseError('Invalid use of operator');
        GetToken;
        ParseLevel4(Expr, 0);
        Expr := TLogicalNotExpressionNode.Create(Expr);
      end;
  end;

  // * / div mod rdiv and shl shr  <term> = <factor> * <factor> ...           //
  procedure ParseLevel3(var Expr: AExpressionNode; const AbsPos: Integer);
  var Oper : Integer;
      E    : AExpressionNode;
  begin
    ParseLevel4(Expr, AbsPos);
    While (TokenType = ttMultiply) or (TokenType = ttDivide) or (TokenType = ttDiv) or
          (TokenType = ttMod) or (TokenType = ttAnd) or (TokenType = ttShl) or
          (TokenType = ttShr) or (TokenType = ttRDiv) do
      begin
        if not Assigned(Expr) then
          ParseError('Operand expected');
        Oper := TokenType;
        GetToken;
        E := nil;
        ParseLevel4(E, TokenPos);
        if not Assigned(E) then
          ParseError('Operand expected');
        Case Oper of
          ttMultiply : Expr := TMultiplyExpressionNode.Create(Expr, E);
          ttDivide   : Expr := TDivideExpressionNode.Create(Expr, E);
          ttAND      : Expr := TLogicalANDExpressionNode.Create(Expr, E);
          ttSHL      : Expr := TBitwiseSHLExpressionNode.Create(Expr, E);
          ttSHR      : Expr := TBitwiseSHRExpressionNode.Create(Expr, E);
          ttDiv      : Expr := TIntegerDivideExpressionNode.Create(Expr, E);
          ttMod      : Expr := TModuloExpressionNode.Create(Expr, E);
          ttRDiv     : Expr := TRationalDivideExpressionNode.Create(Expr, E);
        end;
        Expr.RelSourcePos := TokenPos - AbsPos;
        Expr.SourceLen := LastTokenEnd - AbsPos;
      end;
  end;

  // + - or xor          <term> + <term> or <term> ...                        //
  procedure ParseLevel2(var Expr: AExpressionNode; const AbsPos: Integer);
  var Oper : Integer;
      E    : AExpressionNode;
  begin
    ParseLevel3(Expr, AbsPos);
    While (TokenType = ttPlus) or (TokenType = ttMinus) or
          (TokenType = ttOr) or (TokenType = ttXor)  do
      begin
        if not Assigned(Expr) then
          ParseError('Operand expected');
        Oper := TokenType;
        GetToken;
        E := nil;
        ParseLevel3(E, 0);
        if not Assigned(Expr) then
          ParseError('Operand expected');
        Case Oper of
          ttPlus  : Expr := TAddExpressionNode.Create(Expr, E);
          ttMinus : Expr := TSubtractExpressionNode.Create(Expr, E);
          ttOR    : Expr := TLogicalORExpressionNode.Create(Expr, E);
          ttXOR   : Expr := TLogicalXORExpressionNode.Create(Expr, E);
        end;
      end;
  end;

  // Comparison operators, in, is                                             //
  procedure ParseLevel1(var Expr: AExpressionNode; const AbsPos: Integer);
  var Oper : Integer;
      E    : AExpressionNode;
  begin
    ParseLevel2(Expr, AbsPos);
    While ((TokenType >= ttLessOrEqual) and (TokenType <= ttEqual)) or
          (TokenType = ttIn) or (TokenType = ttIs) do
      begin
        if not Assigned(Expr) then
          ParseError('Operand expected');
        Oper := TokenType;
        GetToken;
        E := nil;
        ParseLevel2(E, 0);
        if not Assigned(E) then
          ParseError('Operand expected');
        Case Oper of
          ttEqual          : Expr := TIsEqualExpressionNode.Create(Expr, E);
          ttNotEqual       : Expr := TIsNotEqualExpressionNode.Create(Expr, E);
          ttLess           : Expr := TIsLessExpressionNode.Create(Expr, E);
          ttGreater        : Expr := TIsGreaterExpressionNode.Create(Expr, E);
          ttLessOrEqual    : Expr := TIsLessOrEqualExpressionNode.Create(Expr, E);
          ttGreaterOrEqual : Expr := TIsGreaterOrEqualExpressionNode.Create(Expr, E);
          ttIn             : Expr := TIsInExpressionNode.Create(Expr, E);
          ttIs             : Expr := TIsTypeExpressionNode.Create(Expr, E);
        end;
      end;
  end;

var R : AExpressionNode;
begin
  R := nil;
  ParseLevel1(R, 0);
  Result := R;
end;



{                                                                              }
{ Syntactic Statement Parser                                                   }
{                                                                              }

{ StatementList ::= (<Statement>? ';')* <Statement>?                           }
procedure TBlaiseScriptParser.ParseStatementList(const Node: ABlaiseScriptNode;
    const AbsPos: Integer);
var N : ABlaiseScriptNode;
    R : Boolean;
begin
  Repeat
    While MatchType(ttStatementDelim, True) do ;
    N := ParseNode(ParseStatement, TokenPos - AbsPos);
    if Assigned(N) then
      begin
        Node.AddChild(N);
        R := MatchType(ttStatementDelim, True);
      end else
      R := False;
  Until not R;
end;

{ ParamValues ::= <Expression> ( ',' <Expression> )*                           }
procedure TBlaiseScriptParser.ParseParamValues(const Node: ABlaiseScriptNode;
    const AbsPos: Integer);
var N : ABlaiseScriptNode;
    R : Boolean;
begin
  Repeat
    N := ParseNode(ParseExpression, TokenPos - AbsPos);
    if Assigned(N) then
      Node.AddChild(N);
    R := Assigned(N) and MatchType(ttComma, True);
  Until not R;
end;

{   Identifier ::= [A-Za-z_][A-Za-z_0-9]*                                      }
function TBlaiseScriptParser.ParseIdentifier: ABlaiseScriptNode;
begin
  if TokenType = ttIdentifier then
    begin
      Result := TSimpleIdentifierNode.Create(TokenText);
      GetToken;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseSelf: ABlaiseScriptNode;
begin
  if TokenType = ttSelf then
    begin
      Result := TSelfIdentifierNode.Create;
      GetToken;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseEnumeratedTypeValue: ABlaiseScriptNode;
var P : Integer;
begin
  if MatchType(ttIdentifier, False) then
    begin
      P := TokenPos;
      Result := TEnumeratedTypeValueNode.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
        if MatchType(ttEqual, True) then
          Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ EnumType ::= '(' <Identifier> ( '=' <Value> )?                               }
{              ( ',' <Identifier> ( '=' <Value> )? )* ')'                      }
{ IdentifierType ::= <Identifier>                                              }
{ RangeType ::=                                                                }
function TBlaiseScriptParser.ParseEnumeratedTypeOrIdentifierType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttOpenBracket, True) then
    begin
      Result := TEnumeratedTypeNode.Create;
      try
        ParseChildMult(Result, P, ParseEnumeratedTypeValue, ttComma, ',', False);
        ExpectType(ttCloseBracket, ')', True);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
  if MatchTokenText('Range', True, False) then
    begin
      Result := TRangeTypeNode.Create;
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        ExpectType(ttDotDot, '..', True);
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
  if TokenType = ttIdentifier then
    begin
      Result := TIdentifierTypeNode.Create(TokenText);
      GetToken;
    end else
    Result := nil;
end;

{ SetType ::=                                                                  }
function TBlaiseScriptParser.ParseSetType: ABlaiseScriptNode;
begin
  Result := nil;
end;

{ RecordType ::= 'Record' (<FieldDefinition> ';' )* 'end'                      }
function TBlaiseScriptParser.ParseRecordFieldDefinition: ABlaiseScriptNode;
begin
  Result := ParseIdentifiersTypeAndValue(TRecordFieldDefinitionNode, False);
end;

function TBlaiseScriptParser.ParseRecordType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  MatchType(ttPacked, True);
  if MatchType(cBlaiseParserLexer.ttRecord, True) then
    begin
      Result := TRecordTypeNode.Create;
      try
        ParseChildMult(Result, P, ParseRecordFieldDefinition, ttStatementDelim,
            ';', True);
        ExpectType(ttEnd, c_End, True);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ ParamDefinition ::= ( 'const' | 'var' )? <Identifier> ( ':' <TypeDefinition> )? }
{                     ( '=' <Expression> )?                                       }
function TBlaiseScriptParser.ParseParamDefinition: ABlaiseScriptNode;
var C : CBlaiseScriptNode;
begin
  if MatchType(ttconst, True) then
    C := TConstParamDefinition else
  if MatchType(ttvar, True) then
    C := TVarParamDefinition else
    C := TLocalParamDefinition;
  Result := ParseIdentifiersTypeAndValue(C, False);
end;

{ FuncProtoType ::= 'Function' <ProtoIdentifier> ( '(' ParamDefinition (';' ParamDefinition)* ')' )? }
{                   ( ':' <TypeDefinition> )?                                                     }
{        <ProtoIdentifier> ( '(' ParamDefinition (';' ParamDefinition)* ')' )? }
{ ProtoIdentifier ::= <Identifier> ( '.' <Identifier )?                        }
function TBlaiseScriptParser.ParseFuncLikePrototype(const TokenType: Integer;
    const AbsPos: Integer): ABlaiseScriptNode;
begin
  if MatchType(TokenType, True) then
    begin
      Result := TFunctionPrototypeNode.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - AbsPos, 'Identifier'));
        if MatchType(ttDot, True) then
          Result.AddChild(ParseNode(ParseIdentifier, TokenPos - AbsPos, 'Identifier'));
        if MatchType(ttOpenBracket, True) then
          begin
            Result.AddChild(ParseNode(ParseParamDefinition, TokenPos - AbsPos, 'Parameter definition'));
            While MatchType(ttStatementDelim, True) do
              Result.AddChild(ParseNode(ParseParamDefinition, TokenPos - AbsPos, 'Parameter definition'));
            ExpectType(ttCloseBracket, ')', True);
          end;
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseFuncProtoType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  MatchType(ttClass, True);
  Result := ParseFuncLikePrototype(ttFunction, P);
  if Assigned(Result) and MatchType(ttColon, True) then
    try
      Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
    except
      FreeAndNil(Result);
      raise;
    end;
end;

{ ProcProtoType ::= 'Procedure' <Identifier> ( '(' ParamDefinition (';' ParamDefinition)* ')' )? }
function TBlaiseScriptParser.ParseProcProtoType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  MatchType(ttClass, True);
  Result := ParseFuncLikePrototype(ttProcedure, P);
end;

function TBlaiseScriptParser.ParseTaskProtoType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  MatchType(ttClass, True);
  Result := ParseFuncLikePrototype(ttTask, P);
end;

{ ConstructorProtoType ::= 'Constructor' <Identifier> ( '(' ParamDefinition (';' ParamDefinition)* ')' )? }
function TBlaiseScriptParser.ParseConstructorProtoType: ABlaiseScriptNode;
begin
  Result := ParseFuncLikePrototype(ttConstructor, TokenPos);
end;

{ DestructorProtoType ::= 'Destructor' <Identifier> ( '(' ParamDefinition (';' ParamDefinition)* ')' )? }
function TBlaiseScriptParser.ParseDestructorProtoType: ABlaiseScriptNode;
begin
  Result := ParseFuncLikePrototype(ttDestructor, TokenPos);
end;

function TBlaiseScriptParser.ParseSpecifierWithIdentifier(const TokenText: String;
    const SpecifierClass: CBlaiseScriptNode): ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchTokenText(TokenText, True, False) then
    begin
      Result := SpecifierClass.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ ReadSpecifier ::= 'read' <Identifier>                                        }
type
  TReadSpecifier = class(ABlaiseScriptNode);

function TBlaiseScriptParser.ParseReadSpecifier: ABlaiseScriptNode;
begin
  Result := ParseSpecifierWithIdentifier(c_Read, TReadSpecifier);
end;

{ WriteSpecififer ::= 'write' <Identifier>                                     }
type
  TWriteSpecifier = class(ABlaiseScriptNode);

function TBlaiseScriptParser.ParseWriteSpecifier: ABlaiseScriptNode;
begin
  Result := ParseSpecifierWithIdentifier(c_Write, TWriteSpecifier);
end;

{ PropertyPrototype ::= 'Property' <Identifier>                                }
{                       ( '[' ParamDefinition (';' ParamDefinition)* ']' )?    }
{                       (':' <TypeDefinition>)?                                }
{                        <ReadSpecifier>? <WriteSpecifier>?                    }
type
  TPropertyProtoType = class(ABlaiseScriptNode);

function TBlaiseScriptParser.ParsePropertyPrototype: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttProperty, True) then
    begin
      Result := TPropertyProtoType.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
        if MatchType(ttOpenBlockBracket, True) then
          begin
            Result.AddChild(ParseNode(ParseParamDefinition, TokenPos - P, 'Parameter definition'));
            While MatchType(ttStatementDelim, True) do
              Result.AddChild(ParseNode(ParseParamDefinition, TokenPos - P, 'Parameter definition'));
            ExpectType(ttCloseBlockBracket, ']', True);
          end;
        if MatchType(ttColon, True) then
          Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
        Result.AddChild(ParseNode(ParseReadSpecifier, TokenPos - P));
        Result.AddChild(ParseNode(ParseWriteSpecifier, TokenPos - P));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;


{ MemberDefinition ::= ( ( <FuncPrototype> | <ProcPrototype> | <ConstructorPrototype> | }
{                        <DestructorPrototype> ) ';' <FunctionDirectives> )             }
{                      | <PropertyPrototype> ';'                                        }
function TBlaiseScriptParser.ParseMemberDefinition: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  Result := ParseAny(TokenPos, [ParseFuncPrototype, ParseProcPrototype,
                     ParseConstructorPrototype, ParseDestructorPrototype,
                     ParsePropertyPrototype]) as ABlaiseScriptNode;
  if Assigned(Result) then
    begin
      ExpectStatementDelim;
      if not (Result is TPropertyPrototype) then
        Result.AddChild(ParseNode(ParseFunctionDirectives, TokenPos - P));
    end;
end;


{ ClassSectionID ::= 'private' | 'protected' | 'public'                          }
{ ClassSection ::= ( <FieldDefinition> ';' )* <MemberDefinition>*                }
{ ClassDefinition ::= <ClassSection>? ( <ClassSectionID> <ClassSection> )* 'end' }
function TBlaiseScriptParser.ParseSection(const SectionClass: CBlaiseScriptNode; const DelimiterToken: Integer): ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  MatchType(DelimiterToken, True);
  Result := SectionClass.Create;
  try
    ParseChildMult(Result, P, ParseRecordFieldDefinition, ttStatementDelim, ';', True);
    ParseChildMult(Result, P, ParseMemberDefinition, ttEOF, '', False);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TBlaiseScriptParser.ParsePrivateSection: ABlaiseScriptNode;
begin
  Result := ParseSection(TPrivateSection, ttPrivate);
end;

function TBlaiseScriptParser.ParseProtectedSection: ABlaiseScriptNode;
begin
  Result := ParseSection(TProtectedSection, ttProtected);
end;

function TBlaiseScriptParser.ParsePublicSection: ABlaiseScriptNode;
begin
  Result := ParseSection(TPublicSection, ttPublic);
end;

procedure TBlaiseScriptParser.ParseClassDefinition(const Node: ABlaiseScriptNode;
    const AbsPos: Integer);
var R : Boolean;
begin
  if MatchType(ttEnd, True) then
    exit;
  if not MatchType(ttPrivate, False) and not MatchType(ttProtected, False) and
     not MatchType(ttPublic, False) then
    Node.AddChild(ParseNode(ParsePublicSection, TokenPos - AbsPos));
  R := True;
  Repeat
    if MatchType(ttPrivate, False) then
      Node.AddChild(ParseNode(ParsePrivateSection, TokenPos - AbsPos)) else
    if MatchType(ttProtected, False) then
      Node.AddChild(ParseNode(ParseProtectedSection, TokenPos - AbsPos)) else
    if MatchType(ttPublic, False) then
      Node.AddChild(ParseNode(ParsePublicSection, TokenPos - AbsPos)) else
      begin
        ExpectType(ttEnd, c_End, True);
        R := False;
      end;
  Until not R;
end;

{ ClassParent ::= <Identifier>                                                 }
{ ClassType ::= 'class' ('(' <ClassParent> ')')? <ClassDefinition>?            }
function TBlaiseScriptParser.ParseClassType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttClass, True) then
    begin
      Result := TClassTypeNode.Create;
      try
        if MatchType(ttOpenBracket, True) then
          begin
            Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
            ExpectType(ttCloseBracket, ')', True);
          end;
        if not MatchType(ttStatementDelim, False) then
          ParseClassDefinition(Result, P);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ ArrayType ::= 'array of' <TypeDefinition>                                    }
function TBlaiseScriptParser.ParseArrayType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttArray, True) then
    begin
      Result := TArrayTypeNode.Create;
      try
        if MatchType(ttOf, True) then
          Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ StreamType ::= 'Stream' ( 'of' <TypeDefinition> )?                           }
function TBlaiseScriptParser.ParseStreamType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttStream, True) then
    begin
      Result := TStreamTypeNode.Create;
      if MatchType(ttOf, True) then
        try
          Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
        except
          FreeAndNil(Result);
          raise;
        end;
    end else
    Result := nil;
end;

{ DictionaryType ::= 'Dictionary' ( '[' <TypeDefinition> ']' )?                }
{                    ( 'of' <TypeDefinition> )?                                }
function TBlaiseScriptParser.ParseDictionaryType: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttDictionary, True) then
    begin
      Result := TDictionaryTypeNode.Create;
      try
        // key type
        if MatchType(ttOpenBlockBracket, True) then
          begin
            Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
            ExpectType(ttCloseBlockBracket, ']', True);
          end else
          Result.AddChild(TUntypedTypeNode.Create);
        // value type
        if MatchType(ttOf, True) then
          Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type')) else
          Result.AddChild(TUntypedTypeNode.Create);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ TypeDefinition ::= <EnumType> | <SetType> | <RecordType> |                   }
{                    <ClassType> | <Identifier> | <ArrayType>                  }
function TBlaiseScriptParser.ParseTypeDefinition: ABlaiseScriptNode;
begin
  Result := ParseAny(TokenPos, [
      ParseSetType, ParseRecordType, ParseClassType,
      ParseArrayType, ParseDictionaryType,
      ParseStreamType,
      ParseEnumeratedTypeOrIdentifierType
                               ]);
end;

{ FunctionDirectives ::= 'overload;'? 'virtual;'? 'override;'? 'abstract;'? 'reintroduce;'? }
const
  Directives = 10;
  Directive : Array[1..Directives] of record
                ClassType : CBlaiseScriptNode;
                Text      : String;
                Token     : Integer; end = (
    (ClassType:TOverloadDirectiveNode;    Text:c_Overload;    Token: ttOverload),
    (ClassType:TOverrideDirectiveNode;    Text:c_Override;    Token: ttOverride),
    (ClassType:TVirtualDirectiveNode;     Text:c_Virtual;     Token: ttVirtual),
    (ClassType:TAbstractDirectiveNode;    Text:c_Abstract;    Token: ttAbstract),
    (ClassType:TReintroduceDirectiveNode; Text:c_Reintroduce; Token: ttReintroduce),
    (ClassType:TCDeclCallingNode;         Text:c_CDecl;       Token: ttCDecl),
    (ClassType:TPascalCallingNode;        Text:c_Pascal;      Token: ttPascal),
    (ClassType:TRegisterCallingNode;      Text:c_Register;    Token: ttRegister),
    (ClassType:TStdCallCallingNode;       Text:c_StdCall;     Token: ttStdCall),
    (ClassType:TSafeCallCallingNode;      Text:c_SafeCall;    Token: ttSafeCall));

function TBlaiseScriptParser.ParseFunctionDirectives: ABlaiseScriptNode;
var I, P, Q : Integer;
    R : Boolean;
    N : ABlaiseScriptNode;
begin
  Result := nil;
  P := TokenPos;
  try
    Repeat
      N := nil;
      R := False;
      Q := TokenPos - P;
      For I := 1 to Directives do
        if MatchType(Directive[I].Token, True) then
          begin
            N := Directive[I].ClassType.Create;
            N.SourceLen := Length(Directive[I].Text);
            N.RelSourcePos := Q;;
            R := True;
            break;
          end;
      if MatchType(ttExternal, True) then
        begin
          N := TExternalDirectiveNode.Create;
          if MatchType(ttStringLiteral, False) then
            begin
              TExternalDirectiveNode(N).LibraryName := StrUnquote(TokenText);
              GetToken;
            end;
          R := True;
        end else
      if MatchTokenText(c_Name, True, False) then
        begin
          N := TNameDirectiveNode.Create;
          ExpectType(ttStringLiteral, 'String', False);
          TNameDirectiveNode(N).ExternalName := StrUnquote(TokenText);
          GetToken;
          R := True;
        end;
      if R then
        begin
          ExpectStatementDelim;
          if not Assigned(Result) then
            Result := TFunctionDirectivesNode.Create;
          Result.AddChild(N);
        end;
    Until not R;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ FunctionDeclaration ::= <FuncProtoType> ':=' <Expression> |                             }
{                          ( <FuncProtoType> | <ProcProtoType> | <ConstructorProtoType> | }
{                            <DestructorProtoType> ) ';' <FunctionDirectives>             }
{                            <Declarations>? <Block>                                      }
function TBlaiseScriptParser.ParseFunctionDeclaration: ABlaiseScriptNode;
var P : Integer;
    R : Boolean;
    D : TFunctionDirectivesNode;
begin
  P := TokenPos;
  Result := nil;
  R := False;
  try
    if MatchType(ttFunction, False) then
      begin
        Result := TFunctionDeclarationNode.Create;
        Result.AddChild(ParseNode(ParseFuncProtoType, TokenPos - P, 'function prototype'));
        if MatchType(ttAssignment, True) then
          Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression')) else
          R := True;
      end else
    if MatchType(ttProcedure, False) then
      begin
        Result := TProcedureDeclarationNode.Create;
        Result.AddChild(ParseNode(ParseProcProtoType, TokenPos - P, 'procedure prototype'));
        R := True;
      end else
    if MatchType(ttTask, False) then
      begin
        Result := TTaskDeclarationNode.Create;
        Result.AddChild(ParseNode(ParseTaskProtoType, TokenPos - P, 'task prototype'));
        R := True;
      end else
    if MatchType(ttConstructor, False) then
      begin
        Result := TConstructorDeclarationNode.Create;
        Result.AddChild(ParseNode(ParseConstructorProtoType, TokenPos - P, 'Constructor prototype'));
        R := True;
      end else
    if MatchType(ttDestructor, False) then
      begin
        Result := TDestructorDeclarationNode.Create;
        Result.AddChild(ParseNode(ParseDestructorProtoType, TokenPos - P, 'Destructor prototype'));
        R := True;
      end;

    if R then
      begin
        ExpectStatementDelim;
        D := TFunctionDirectivesNode(ParseNode(ParseFunctionDirectives, TokenPos - P));
        Result.AddChild(D);
        if not Assigned(D) or not D.IsExternal then
          begin
            Result.AddChild(ParseNode(ParseDeclarations, TokenPos - P));
            Result.AddChild(ParseNode(ParseBlock, TokenPos - P, 'begin'));
            ExpectStatementDelim;
          end;
      end else
    if Assigned(Result) then
      ExpectStatementDelim;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TBlaiseScriptParser.ParseIdentifiersTypeAndValue(const NodeClass: CBlaiseScriptNode;
    const ValueRequired: Boolean): ABlaiseScriptNode;
var P : Integer;
    R : Boolean;
begin
  if TokenType = ttIdentifier then
    begin
      P := TokenPos;
      Result := ParseCommaSepIdentifiers(NodeClass, P);
      try
        if MatchType(ttColon, True) then
          Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
        R := ValueRequired;
        if R then
          ExpectType(ttEqual, '=', True) else
          R := MatchType(ttEqual, True);
        if R then
          Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'))
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ VarDeclaration ::= <Identifier> ( ',' <Identifier> )*                        }
{                    (':' <TypeDefinition>)? ('=' <Expression>)?               }
function TBlaiseScriptParser.ParseVarDeclaration: ABlaiseScriptNode;
begin
  Result := ParseIdentifiersTypeAndValue(TVariableDeclaration, False);
end;

{ ConstDeclaration ::= <Identifier> (',' <Identifier>)*                        }
{                      (':' <TypeDefinition>)? '=' <Expression>                }
function TBlaiseScriptParser.ParseConstDeclaration: ABlaiseScriptNode;
begin
  Result := ParseIdentifiersTypeAndValue(TConstDeclaration, True);
end;

{ TypeDeclaration ::= <Identifier> '=' <TypeDefinition>                        }
function TBlaiseScriptParser.ParseTypeDeclaration: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if TokenType = ttIdentifier then
    begin
      Result := TTypeDeclaration.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
        ExpectType(ttEqual, '=', True);
        Result.AddChild(ParseNode(ParseTypeDefinition, TokenPos - P, 'Type'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ [DeclarationClass] ::= ( 'type' ( <TypeDeclaration> ';' )+ |                 }
{                   'const' ( <ConstDeclaration> ';' )+ |                      }
{                   'var' ( <VarDeclaration> ';') + |                          }
{                   [FunctionParser] ';' <FunctionDirectives> )*               }
function TBlaiseScriptParser.ParseDeclarationsLike(const DeclarationsClass: CBlaiseScriptNode;
    const FunctionParser: TNodeParseProc): ABlaiseScriptNode;

  procedure SetResult;
    begin
      if not Assigned(Result) then
        Result := DeclarationsClass.Create;
    end;

var R : Boolean;
    P : Integer;
    N : ABlaiseScriptNode;
    O : TNodeParseProc;
    S : String;
begin
  P := TokenPos;
  Result := nil;
  R := True;
  try
    Repeat
      O := nil;
      if MatchType(ttType, True) then
        begin
          O := ParseTypeDeclaration;
          S := 'Type declaration';
        end else
      if MatchType(ttConst, True) then
        begin
          O := ParseConstDeclaration;
          S := 'Constant declaration';
        end else
      if MatchType(ttVar, True) then
        begin
          O := ParseVarDeclaration;
          S := 'Variable declaration';
        end;

      if Assigned(O) then
        begin
          SetResult;
          N := ParseNode(O, TokenPos - P, S);
          While Assigned(N) do
            begin
              ExpectStatementDelim;
              if MatchTokenText('persist', True, False) then
                begin
                  ExpectStatementDelim;
                  N.AddChild(TPersistDirective.Create);
                end;
              Result.AddChild(N);
              N := ParseNode(O, TokenPos - P);
            end;
        end else
      if MatchType(ttClass, True) or MatchType(ttFunction, False) or
         MatchType(ttProcedure, False) or MatchType(ttConstructor, False) or
         MatchType(ttDestructor, False) or MatchType(ttTask, False) then
        begin
          SetResult;
          Result.AddChild(ParseNode(FunctionParser, TokenPos - P));
        end else
        R := False;
    Until not R;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ FunctionPrototype ::= <FuncProtoType> | <ProcProtoType>                      }
function TBlaiseScriptParser.ParseFunctionPrototype: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  Result := ParseAny(TokenPos, [ParseFuncProtoType, ParseProcProtoType]);
  try
    ExpectStatementDelim;
    Result.AddChild(ParseNode(ParseFunctionDirectives, TokenPos - P));
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ InterfaceDefinition ::= ( 'type' ( <TypeDeclaration> ';' )+ |                }
{                   'const' ( <ConstDeclaration> ';' )+ |                      }
{                   <FunctionProtoType> ';' <FunctionDirectives> )*            }
function TBlaiseScriptParser.ParseInterfaceDefinition: ABlaiseScriptNode;
begin
  Result := ParseDeclarationsLike(TDeclarationListNode, ParseFunctionPrototype);
end;


{ Declarations := ( 'type' ( <TypeDeclaration> ';' )+ |                        }
{                   'const' ( <ConstDeclaration> ';' )+ |                      }
{                   <FunctionDeclaration> ';' )*                               }
function TBlaiseScriptParser.ParseDeclarations: ABlaiseScriptNode;
begin
  Result := ParseDeclarationsLike(TDeclarationListNode, ParseFunctionDeclaration);
end;

function TBlaiseScriptParser.ParseSlice: ABlaiseScriptNode;
var P : Integer;
    S : Boolean;
    N : ABlaiseScriptNode;
begin
  if MatchType(ttDotDotDot, True) then
    begin
      Result := TMultiSliceNode.Create;
      exit;
    end;
  P := TokenPos;
  N := TIndexNode.Create(MatchType(ttLess, True));
  S := MatchType(ttColon, True);
  if not S then
    try
      N.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
      S := MatchType(ttColon, True);
    except
      N.Free;
      raise;
    end;
  if not S then
    begin
      Result := N;
      exit;
    end;
  Result := TRangeSliceNode.Create;
  try
    Result.AddChild(N);
    N := TIndexNode.Create(MatchType(ttLess, True));
    Result.AddChild(N);
    N.AddChild(ParseNode(ParseExpression, TokenPos - P, ''));
    if MatchType(ttColon, True) then
      Result.AddChild(ParseNode(ParseExpression, TokenPos - P, ''));
  except
    Result.Free;
    raise;
  end;
end;

{ TypeCastIdentifier ::= ( <Identifier> ) '(' <Name> ')'                       }
{ SelectedIdentifier ::= <Name> '.' <Identifier>                               }
{ IndexedIdentifier ::= <Name> '[' <Expression> ']'                            }
{ FunctionCallExpr ::= <Name> ( '(' <ParamValues> ')' )?                       }
{ ProcedureCallStatement ::= <Name> ( '(' <ParamValues> ')' )?                 }
{ Name ::= <TypeCastIdentifier> | <SelectedIdentifier> |                       }
{          <IndexedIdentifier> | <FunctionCallExpr> |                          }
{          'inherited'? <Identifier>                                           }
function TBlaiseScriptParser.ParseName: ABlaiseScriptNode;
var P    : Integer;
    N    : ABlaiseScriptNode;
    R    : Boolean;
    S    : ABlaiseScriptNodeArray;
    F    : Boolean;
    I, L : Integer;
begin
  P := TokenPos;
  if MatchType(ttInherited, True) then
    begin
      Result := TInheritedIdentifierNode.Create;
      Result.AddChild(ParseNode(ParseIdentifier, 0, 'Identifier'));
    end else
  if TokenType = ttIdentifier then
    Result := ParseNode(ParseIdentifier, 0) else
  if TokenType = ttSelf then
    Result := ParseNode(ParseSelf, 0) else
    Result := nil;
  if not Assigned(Result) then
    exit;
  try
    R := True;
    Repeat
      if MatchType(ttOpenBlockBracket, True) then
        begin
          S := nil;
          Repeat
            N := ParseSlice;
            Append(ObjectArray(S), N);
          Until not MatchType(ttComma, True);
          ExpectType(ttCloseBlockBracket, ']', True);
          F := True;
          L := Length(S);
          For I := 0 to L - 1 do
            if not (S[I] is TIndexNode) then
              begin
                F := False;
                break;
              end;
          if F then
            For I := 0 to L - 1 do
              begin
                N := TIndexedIdentifierNode.Create;
                N.AddChild(Result);
                N.AddChild(TIndexNode(S[I]));
                Result := N;
              end
          else
            begin
              N := TSlicedIdentifierNode.Create;
              N.AddChild(Result);
              Result := N;
              For I := 0 to L - 1 do
                Result.AddChild(S[I]);
            end;
        end else
      if MatchType(ttDot, True) then
        begin
          N := TSelectedIdentifierNode.Create;
          try
            N.AddChild(Result); Result := nil;
            N.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
            N.RelSourcePos := 0;
            N.SourceLen := LastTokenEnd - P;
          except
            FreeAndNil(N);
            raise;
          end;
          Result := N;
        end else
      if MatchType(ttOpenBracket, True) then
        begin
          N := TIdentifierCallNode.Create;
          try
            N.AddChild(Result); Result := nil;
            ParseParamValues(N, P);
            N.RelSourcePos := 0;
            ExpectType(ttCloseBracket, ')', True);
            N.SourceLen := LastTokenEnd - P;
          except
            FreeAndNil(N);
            raise;
          end;
          Result := N;
        end else
        R := False;
    Until not R;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TBlaiseScriptParser.ParseNamedStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  Result := nil;
  if MatchType(ttNamed, True) then
    if MatchTokenText(c_Delete, True, False) then
      begin
        Result := TNamedDeleteStatementNode.Create;
        try
          Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        except
          Result.Free;
          raise;
        end;
      end else
      begin
        Result := TNamedAssignmentStatementNode.Create;
        try
          Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Named expression'));
          ExpectType(ttAssignment, 'Named statement', True);
          Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        except
          Result.Free;
          raise;
        end;
      end;
end;

{ AssignmentStatement ::= <Name> ':=' <Expression>                                        }
{ IdentifierStatement ::= AssignmentStatement | ProcedureCallStatement | FunctionCallExpr }
function TBlaiseScriptParser.ParseIdentifierStatement: ABlaiseScriptNode;
var P : Integer;
    N : ABlaiseScriptNode;
begin
  P := TokenPos;
  Result := ParseNode(ParseName, 0);
  if not Assigned(Result) then
    exit;
  try
    if MatchType(ttAssignment, True) then
      begin
        N := TAssignmentStatementNode.Create;
        try
          N.AddChild(Result); Result := nil;
          N.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        except
          FreeAndNil(N);
          raise;
        end;
        Result := N;
      end else
      begin
        N := TProcedureCallStatementNode.Create;
        try
          N.AddChild(Result); Result := nil;
        except
          FreeAndNil(N);
          raise;
        end;
        Result := N;
      end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ ReadWriteStatement ::=                                                       }
function TBlaiseScriptParser.ParseReadWriteStatement: ABlaiseScriptNode;
begin
  Result := nil;
end;

{ RaiseStatement ::= 'raise' <Expression>?                                     }
function TBlaiseScriptParser.ParseRaiseStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttRaise, True) then
    begin
      Result := TRaiseStatementNode.Create;
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseExitStatement: ABlaiseScriptNode;
begin
  if MatchType(ttExit, True) then
    Result := TExitStatementNode.Create else
    Result := nil;
end;

function TBlaiseScriptParser.ParseBreakStatement: ABlaiseScriptNode;
begin
  if MatchType(ttBreak, True) then
    Result := TBreakStatementNode.Create else
    Result := nil;
end;

function TBlaiseScriptParser.ParseContinueStatement: ABlaiseScriptNode;
begin
  if MatchType(ttContinue, True) then
    Result := TContinueStatementNode.Create else
    Result := nil;
end;

function TBlaiseScriptParser.ParseReturnStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttReturn, True) then
    begin
      Result := TReturnStatementNode.Create;
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseImportStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttImport, True) then
    begin
      Result := TImportStatementNode.Create;
      try
        if MatchType(ttMultiply, True) then
          Result.AddChild(TSimpleIdentifierNode.Create('*'))
        else
          Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P));
        ExpectType(ttFrom, c_From, True);
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseTextWriteStatement: ABlaiseScriptNode;
var P : Integer;
    R : Boolean;
begin
  P := TokenPos;
  R := MatchTokenText(c_Writeln, True, False);
  if R or MatchTokenText(c_Write, True, False) then
    begin
      Result := TTextOutputStatementNode.Create(R);
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        if MatchType(ttTo, True) then
          Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ SimpleStatement ::= IdentifierStatement | ReadWriteStatement | RaiseStatement  }
function TBlaiseScriptParser.ParseSimpleStatement: ABlaiseScriptNode;
begin
  Result := ParseAny(TokenPos, [ParseTextWriteStatement, ParseNamedStatement,
    ParseReadWriteStatement, ParseRaiseStatement, ParseExitStatement,
    ParseBreakStatement, ParseContinueStatement, ParseIdentifierStatement,
    ParseReturnStatement, ParseImportStatement]);
end;

{ CaseStatement ::=                                                            }
function TBlaiseScriptParser.ParseCaseCaseNode: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  Result := TCaseCaseNode.Create;
  try
    Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
    if MatchType(ttDotDot, True) then
      Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
    ExpectType(ttColon, ':', True);
    Result.AddChild(ParseNode(ParseStatement, TokenPos - P));
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TBlaiseScriptParser.ParseCaseStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttCase, True) then
    begin
      Result := TCaseStatementNode.Create;
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        ExpectType(ttOf, c_Of, True);
        While (TokenType <> ttElse) and (TokenType <> ttEnd) do
          begin
            Result.AddChild(ParseNode(ParseCaseCaseNode, TokenPos - P, 'Case expression'));
            if (TokenType <> ttElse) and (TokenType <> ttEnd) then
              ExpectStatementDelim;
          end;
        if MatchType(ttElse, True) then
          begin
            Result.AddChild(ParseNode(ParseStatement, TokenPos - P, 'Statement'));
            MatchType(ttStatementDelim, True);
          end;
        ExpectType(ttEnd, c_End, True);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ IfStatement ::= 'if' <Expression> 'then' <Statement> ( 'else' <Statement> )? }
function TBlaiseScriptParser.ParseIfStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttif, True) then
    begin
      Result := TIfStatementNode.Create;
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        ExpectType(ttThen, c_then, True);
        Result.AddChild(ParseNode(ParseStatement, TokenPos - P, 'Statement'));
        if MatchType(ttElse, True) then
          Result.AddChild(ParseNode(ParseStatement, TokenPos - P, 'Statement'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ RepeatStatement ::= 'repeat' <StatementList> 'until' <Expression>            }
function TBlaiseScriptParser.ParseRepeatStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttRepeat, True) then
    begin
      Result := TRepeatStatementNode.Create;
      try
        ParseStatementList(Result, P);
        ExpectType(ttUntil, c_until, True);
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ WhileStatement ::= 'while' <Expression> 'do' <Statement>                     }
function TBlaiseScriptParser.ParseWhileStatement: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttWhile, True) then
    begin
      Result := TWhileStatementNode.Create;
      try
        Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
        ExpectType(ttDo, c_do, True);
        Result.AddChild(ParseNode(ParseStatement, TokenPos - P, 'Statement'));
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ ForStatement ::= 'for' <Identifier> ':=' <Expression> ( 'to' | 'downto' )    }
{     <Expression> 'do' <Statement>                                            }
function TBlaiseScriptParser.ParseForStatement: ABlaiseScriptNode;
var P : Integer;
    R : Boolean;
    I : ABlaiseScriptNode;
begin
  P := TokenPos;
  if MatchType(ttFor, True) then
    begin
      I := ParseNode(ParseIdentifier, TokenPos - P, 'Identifier');
      if MatchType(ttIn, True) then
        begin
          Result := TForEachStatementNode.Create;
          try
            Result.AddChild(I);
            Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
            if MatchType(ttWhere, True) then
              Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
            ExpectType(ttDo, c_Do, True);
            Result.AddChild(ParseNode(ParseStatement, TokenPos - P, ''));
            if MatchType(ttElse, True) then
              Result.AddChild(ParseNode(ParseStatement, TokenPos - P, ''));
          except
            FreeAndNil(Result);
            raise;
          end;
        end else
        begin
          ExpectType(ttAssignment, c_Assign, True);
          Result := TForStatementNode.Create;
          try
            Result.AddChild(I);
            Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
            R := MatchType(ttTo, True);
            if not R then
              if not MatchType(ttDownTo, True) then
                ParseError('to expected');
            TForStatementNode(Result).Increase := R;
            Result.AddChild(ParseNode(ParseExpression, TokenPos - P, 'Expression'));
            ExpectType(ttDo, c_Do, True);
            Result.AddChild(ParseNode(ParseStatement, TokenPos - P, ''));
          except
            FreeAndNil(Result);
            raise;
          end;
        end;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseOnExceptionClause: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttOn, True) then
    begin
      Result := TOnExceptionClauseNode.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
        if MatchType(ttColon, True) then
          Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
        ExpectType(ttDo, c_do, True);
        Result.AddChild(ParseNode(ParseStatement, TokenPos - P, 'Statement'));
        MatchType(ttStatementDelim, True);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

function TBlaiseScriptParser.ParseTryStatement: ABlaiseScriptNode;
var P : Integer;
    T, U : TStatementBlockNode;
    E : Boolean;

  function ParseBlock : TStatementBlockNode;
  begin
    Result := TStatementBlockNode.Create;
    try
      Result.RelSourcePos := TokenPos - P;
      ParseStatementList(Result, TokenPos);
      Result.SourceLen := LastTokenEnd - P - Result.RelSourcePos;
    except
      FreeAndNil(Result);
      raise;
    end;
  end;

begin
  P := TokenPos;
  if MatchType(ttTry, True) then
    begin
      T := ParseBlock;
      try
        if MatchType(ttFinally, True) then
          begin
            U := ParseBlock;
            Result := TTryFinallyStatementNode.Create;
          end else
          begin
            ExpectType(ttExcept, 'finally or except', True);
            Result := TTryExceptStatementNode.Create;
            if MatchType(ttOn, False) then
              begin
                Repeat
                  Result.AddChild(ParseNode(ParseOnExceptionClause, TokenPos - P, 'on clause'));
                Until not MatchType(ttOn, False);
                if MatchType(ttElse, True) then
                  begin
                    U := ParseBlock;
                    E := True;
                  end else
                  begin
                    U := nil;
                    E := False;
                  end;
              end else
              begin
                U := ParseBlock;
                E := True;
              end;
            TTryExceptStatementNode(Result).HandleDefault := E;
          end;
        ExpectType(ttEnd, c_End, True);
      except
        FreeAndNil(T);
        raise;
      end;
      Result.AddChild(T);
      Result.AddChild(U);
    end else
    Result := nil;
end;

{ CompoundStatement ::= IfStatement | WhileStatement | RepeatStatement | ForStatement | TryStatement | CaseStatement }
function TBlaiseScriptParser.ParseCompoundStatement: ABlaiseScriptNode;
begin
  Result := ParseAny(TokenPos, [ParseIfStatement, ParseWhileStatement,
      ParseRepeatStatement, ParseForStatement, ParseTryStatement,
      ParseCaseStatement]);
end;

{ Statement ::= <SimpleStatement> | <CompoundStatement> | <Block>              }
function TBlaiseScriptParser.ParseStatement: ABlaiseScriptNode;
begin
  Result := ParseAny(TokenPos, [ParseSimpleStatement, ParseCompoundStatement,
      ParseBlock]);
end;

{ Block ::= 'begin' <StatementList> 'end'                                      }
function TBlaiseScriptParser.ParseBlock: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttbegin, True) then
    begin
      Result := TStatementBlockNode.Create;
      try
        ParseStatementList(Result, P);
        ExpectType(ttEnd, c_End, True);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{              'Program' <Identifier>                                          }
type
  TProgramDeclaration = class(ABlaiseScriptNode);

function TBlaiseScriptParser.ParseProgramDeclaration: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttProgram, True) then
    Result := ParseChildSeq(TProgramDeclaration, P, [ParseIdentifier], ['Identifier']) else
    Result := nil;
end;

{ UsesClause ::= 'uses' <Identifier> (',' <Identifier>)*                       }
function TBlaiseScriptParser.ParseUsesClause: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttUses, True) then
    Result := ParseCommaSepIdentifiers(TUsesNode, P)
  else
    Result := nil;
end;

{          (<UsesClause> ';')?                                                 }
{          <InterfaceDefinition>                                               }
function TBlaiseScriptParser.ParseInterfaceSection: ABlaiseScriptNode;
var P : Integer;
    N : ABlaiseScriptNode;
begin
  P := TokenPos;
  Result := TInterfaceSectionNode.Create;
  try
    N := ParseNode(ParseUsesClause, TokenPos - P);
    if Assigned(N) then
      begin
        Result.AddChild(N);
        ExpectStatementDelim;
      end;
    Result.AddChild(ParseNode(ParseInterfaceDefinition, TokenPos - P));
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{          (<UsesClause> ';')?                                                 }
{          <Declarations>                                                      }
function TBlaiseScriptParser.ParseImplementationSection: ABlaiseScriptNode;
var P : Integer;
    N : ABlaiseScriptNode;
begin
  P := TokenPos;
  Result := TImplementationSectionNode.Create;
  try
    N := ParseNode(ParseUsesClause, TokenPos - P);
    if Assigned(N) then
      begin
        Result.AddChild(N);
        ExpectStatementDelim;
      end;
    Result.AddChild(ParseNode(ParseDeclarations, TokenPos - P));
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ Unit ::= 'unit' <Identifier> ';'                                             }
{          'interface'                                                         }
{          (<UsesClause> ';')?                                                 }
{          <InterfaceDefinition>                                               }
{          'implementation'                                                    }
{          (<UsesClause> ';')?                                                 }
{          <Declarations>                                                      }
{          ( 'initialization' <StatementList>? )?                              }
{          ( 'finalization' <StatementList>? )?                                }
{          'end.'                                                              }
function TBlaiseScriptParser.ParseUnit: ABlaiseScriptNode;
var P : Integer;
begin
  P := TokenPos;
  if MatchType(ttUnit, True) then
    begin
      Result := TUnitNode.Create;
      try
        Result.AddChild(ParseNode(ParseIdentifier, TokenPos - P, 'Identifier'));
        ExpectStatementDelim;

        ExpectType(ttInterface, c_Interface, True);
        Result.AddChild(ParseNode(ParseInterfaceSection, TokenPos - P));

        ExpectType(ttImplementation, c_Implementation, True);
        Result.AddChild(ParseNode(ParseImplementationSection, TokenPos - P));

        if MatchType(ttinitialization, True) then
          ParseStatementList(Result, P);
        if MatchType(ttfinalization, True) then
          ParseStatementList(Result, P);

        ExpectType(ttEnd, c_End, True);
        ExpectType(ttDot, '.', True);
      except
        FreeAndNil(Result);
        raise;
      end;
    end else
    Result := nil;
end;

{ Program ::= ('Program' <Identifier> ';')?                                    }
{             (<UsesClause> ';')?                                              }
{             <Declarations>                                                   }
{             <Block> '.'                                                      }
function TBlaiseScriptParser.ParseProgram: ABlaiseScriptNode;
var P : Integer;
    N : ABlaiseScriptNode;
begin
  P := TokenPos;
  Result := TApplicationNode.Create;
  try
    N := ParseNode(ParseProgramDeclaration, TokenPos - P);
    if Assigned(N) then
      begin
        Result.AddChild(N);
        ExpectStatementDelim;
      end;

    N := ParseNode(ParseUsesClause, TokenPos - P);
    if Assigned(N) then
      begin
        Result.AddChild(N);
        ExpectStatementDelim;
      end;

    Result.AddChild(ParseNode(ParseDeclarations, TokenPos - P));
    Result.AddChild(ParseNode(ParseBlock, TokenPos - P, 'Block'));

    ExpectType(ttDot, '.', True);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ Source ::= Program | Unit                                                    }
function TBlaiseScriptParser.ExtractSource: ABlaiseScriptNode;
var P : Integer;
begin
  GetToken;
  P := TokenPos;
  if MatchType(ttUnit, False) then
    Result := ParseNode(ParseUnit, P) else
    Result := ParseNode(ParseProgram, P);
end;

{ Immediate ::= Statement | Declaration                                        }
function TBlaiseScriptParser.ExtractImmediate: ABlaiseScriptNode;
begin
  GetToken;
  Result := ParseAny(TokenPos, [ParseDeclarations, ParseStatement])
      as ABlaiseScriptNode;
end;

{ Expression                                                                   }
function TBlaiseScriptParser.ExtractExpression: AExpressionNode;
begin
  GetToken;
  Result := ParseExpression as AExpressionNode;
end;

{ Statement                                                                    }
function TBlaiseScriptParser.ExtractStatement: AStatementNode;
begin
  GetToken;
  Result := ParseStatement as AStatementNode;
end;

{ Declarations                                                                 }
function TBlaiseScriptParser.ExtractDeclarations: TDeclarationListNode;
begin
  GetToken;
  Result := ParseDeclarations as TDeclarationListNode;
end;

{ Parsing Functions                                                            }
function ParseBlaiseScriptStatement(const Data: Pointer; const Size: Integer): AStatementNode;
var P : TBlaiseScriptParser;
begin
  P := TBlaiseScriptParser.Create;
  try
    P.SetData(Data, Size);
    Result := P.ExtractStatement;
  finally
    FreeAndNil(P);
  end;
end;

function ParseBlaiseScriptStatement(const S: String): AStatementNode;
var P : TBlaiseScriptParser;
begin
  P := TBlaiseScriptParser.Create;
  try
    P.SetText(S);
    Result := P.ExtractStatement;
  finally
    FreeAndNil(P);
  end;
end;

function ParseBlaiseScriptExpression(const S: String): AExpressionNode;
var P : TBlaiseScriptParser;
begin
  P := TBlaiseScriptParser.Create;
  try
    P.SetText(S);
    Result := P.ExtractExpression;
  finally
    FreeAndNil(P);
  end;
end;



end.

