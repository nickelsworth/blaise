{                                                                              }
{                     Blaise syntactic expression nodes v0.01                  }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseParserNodesExpr.pas             }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise syntactic expression nodes.                    }
{                                                                              }
{ Revision history:                                                            }
{   09/06/2002  0.01  Created cBlaiseParserNodesExpr from cBlaiseParser.       }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseParserNodesExpr;

interface

uses
  { Blaise }
  cBlaiseMachineTypes,
  cBlaiseMachineExpressions,
  cBlaiseParserNodes;



{                                                                              }
{ TConstantExpressionNode                                                      }
{                                                                              }
type
  TConstantExpressionNode = class(AConstantExpressionNode)
  protected
    FValue : TObject;

  public
    constructor Create(const Value: TObject);
    destructor Destroy; override;

    function  GetNodeParameterStr: String; override;
    function  GetAsExpression: AExpression; override;
    function  GetValue: TObject; override;
  end;



{                                                                              }
{ TBooleanConstantExpressionNode                                               }
{                                                                              }
type
  TBooleanConstantExpressionNode = class(AConstantExpressionNode)
  protected
    FValue : Boolean;

  public
    constructor Create(const Value: Boolean);

    function  GetNodeParameterStr: String; override;
    function  GetAsExpression: AExpression; override;
    function  GetValue: TObject; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TStringConstantExpressionNode                                                }
{                                                                              }
type
  TStringConstantExpressionNode = class(AConstantExpressionNode)
  protected
    FValue : String;

  public
    constructor Create(const Value: String);

    function  GetNodeParameterStr: String; override;
    function  GetAsExpression: AExpression; override;
    function  GetValue: TObject; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TIntegerConstantExpressionNode                                               }
{                                                                              }
type
  TIntegerConstantExpressionNode = class(AConstantExpressionNode)
  protected
    FValue : Integer;

  public
    constructor Create(const Value: Integer);

    function  GetNodeParameterStr: String; override;
    function  GetAsExpression: AExpression; override;
    function  GetValue: TObject; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TFloatConstantExpressionNode                                                 }
{                                                                              }
type
  TFloatConstantExpressionNode = class(AConstantExpressionNode)
  protected
    FValue : Extended;

  public
    constructor Create(const Value: Extended);

    function  GetNodeParameterStr: String; override;
    function  GetAsExpression: AExpression; override;
    function  GetValue: TObject; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TComplexConstantExpressionNode                                               }
{                                                                              }
type
  TComplexConstantExpressionNode = class(AConstantExpressionNode)
  protected
    FImag : Extended;

  public
    constructor Create(const Imag: Extended);

    function  GetNodeParameterStr: String; override;
    function  GetAsExpression: AExpression; override;
    function  GetValue: TObject; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TConditionalExpressionNode                                                   }
{                                                                              }
type
  TConditionalExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Condition, TrueValue, FalseValue: AExpressionNode);
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ AUnaryOperatorExpressionNode                                                 }
{                                                                              }
type
  AUnaryOperatorExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Operand: AExpressionNode);
  end;



{                                                                              }
{ TNegateExpressionNode                                                        }
{                                                                              }
type
  TNegateExpressionNode = class(AUnaryOperatorExpressionNode)
  public
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TLogicalNOTExpressionNode                                                    }
{                                                                              }
type
  TLogicalNOTExpressionNode = class(AUnaryOperatorExpressionNode)
  public
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ ABinaryOperatorExpressionNode                                                }
{                                                                              }
type
  ABinaryOperatorExpressionNode = class(AExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); virtual; abstract;
  public
    constructor Create(const LeftOperand, RightOperand: AExpressionNode);
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TAddExpressionNode                                                           }
{                                                                              }
type
  TAddExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TSubtractExpressionNode                                                      }
{                                                                              }
type
  TSubtractExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TMultiplyExpressionNode                                                      }
{                                                                              }
type
  TMultiplyExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TDivideExpressionNode                                                        }
{                                                                              }
type
  TDivideExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TPowerExpressionNode                                                         }
{                                                                              }
type
  TPowerExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TLogicalORExpressionNode                                                     }
{                                                                              }
type
  TLogicalORExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TLogicalANDExpressionNode                                                    }
{                                                                              }
type
  TLogicalANDExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TLogicalXORExpressionNode                                                    }
{                                                                              }
type
  TLogicalXORExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TBitwiseSHLExpressionNode                                                    }
{                                                                              }
type
  TBitwiseSHLExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TBitwiseSHRExpressionNode                                                    }
{                                                                              }
type
  TBitwiseSHRExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIntegerDivideExpressionNode                                                 }
{                                                                              }
type
  TIntegerDivideExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TRationalDivideExpressionNode                                                }
{                                                                              }
type
  TRationalDivideExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TModuloExpressionNode                                                        }
{                                                                              }
type
  TModuloExpressionNode = class(ABinaryOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ ABooleanOperatorExpressionNode                                               }
{                                                                              }
type
  ABooleanOperatorExpressionNode = class(ABinaryOperatorExpressionNode);



{                                                                              }
{ TIsEqualExpressionNode                                                       }
{                                                                              }
type
  TIsEqualExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsNotEqualExpressionNode                                                    }
{                                                                              }
type
  TIsNotEqualExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsLessExpressionNode                                                        }
{                                                                              }
type
  TIsLessExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsGreaterExpressionNode                                                     }
{                                                                              }
type
  TIsGreaterExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsLessOrEqualExpressionNode                                                 }
{                                                                              }
type
  TIsLessOrEqualExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsGreaterorEqualExpressionNode                                              }
{                                                                              }
type
  TIsGreaterOrEqualExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsInExpressionNode                                                          }
{                                                                              }
type
  TIsInExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TIsTypeExpressionNode                                                        }
{                                                                              }
type
  TIsTypeExpressionNode = class(ABooleanOperatorExpressionNode)
  protected
    procedure WriteOperatorSource(const Writer: ASourceWriter); override;
  public
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TAssignmentExpressionNode                                                    }
{                                                                              }
type
  TAssignmentExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Identifier: AIdentifierNode;
                const Value: AExpressionNode);
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TIdentifierExpressionNode                                                    }
{                                                                              }
type
  TIdentifierExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Identifier: AIdentifierNode);
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TNilExpressionNode                                                           }
{                                                                              }
type
  TNilExpressionNode = class(AExpressionNode)
  public
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TArrayConstructorExpressionNode                                              }
{                                                                              }
type
  TArrayConstructorExpressionNode = class(AExpressionNode)
  public
    function  IsConstant: Boolean; override;
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TDictionaryConstructorExpressionNode                                         }
{                                                                              }
type
  TDictionaryConstructorExpressionNode = class(AExpressionNode)
  public
    function  IsConstant: Boolean; override;
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TListComprehensionExpressionNode                                             }
{                                                                              }
type
  TListComprehensionLoopNode = class(ABlaiseScriptNode)
    function  GetAsListComprehensionLoop: TListComprehensionLoop;
  end;
  TListComprehensionExpressionNode = class(AExpressionNode)
    function  GetAsExpression: AExpression; override;
  end;



{                                                                              }
{ TNamedExpressionNode                                                         }
{                                                                              }
type
  TNamedExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Expression: AExpressionNode);
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TNamedExistsExpressionNode                                                   }
{                                                                              }
type
  TNamedExistsExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Expression: AExpressionNode);
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



{                                                                              }
{ TNamedDirectoryExpressionNode                                                }
{                                                                              }
type
  TNamedDirectoryExpressionNode = class(AExpressionNode)
  public
    constructor Create(const Expression: AExpressionNode);
    function  GetAsExpression: AExpression; override;
    procedure WriteSource(const Writer: ASourceWriter); override;
  end;



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseFuncs,
  cBlaiseTypes,
  cBlaiseStructsSimple,
  cBlaiseParserLexer;



{                                                                              }
{ TConstantExpressionNode                                                      }
{                                                                              }
constructor TConstantExpressionNode.Create(const Value: TObject);
begin
  inherited Create;
  ObjectAddReference(Value);
  FValue := Value;
end;

destructor TConstantExpressionNode.Destroy;
begin
  ObjectReleaseReferenceAndNil(FValue);
  inherited Destroy;
end;

function TConstantExpressionNode.GetNodeParameterStr: String;
begin
  if FValue is ASimpleType then
    Result := ASimpleType(FValue).AsString
  else
    Result := '{Object}';
end;

function TConstantExpressionNode.GetValue: TObject;
begin
  Result := FValue;
end;

function TConstantExpressionNode.GetAsExpression: AExpression;
begin
  Result := TConstantExpression.Create(FValue);
end;



{                                                                              }
{ TBooleanConstantExpressionNode                                               }
{                                                                              }
constructor TBooleanConstantExpressionNode.Create(const Value: Boolean);
begin
  inherited Create;
  FValue := Value;
end;

function TBooleanConstantExpressionNode.GetNodeParameterStr: String;
begin
  Result := BooleanToStr(FValue);
end;

function TBooleanConstantExpressionNode.GetAsExpression: AExpression;
begin
  Result := TBooleanConstantExpression.Create(FValue);
end;

function TBooleanConstantExpressionNode.GetValue: TObject;
begin
  Result := GetImmutableBoolean(FValue);
end;

procedure TBooleanConstantExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  if FValue then
    Writer.Identifier(c_True)
  else
    Writer.Identifier(c_False);
end;



{                                                                              }
{ TStringConstantExpressionNode                                                }
{                                                                              }
constructor TStringConstantExpressionNode.Create(const Value: String);
begin
  inherited Create;
  FValue := Value;
end;

function TStringConstantExpressionNode.GetNodeParameterStr: String;
begin
  Result := StrQuote(FValue, '''');
end;

function TStringConstantExpressionNode.GetAsExpression: AExpression;
begin
  Result := TStringConstantExpression.Create(FValue);
end;

function TStringConstantExpressionNode.GetValue: TObject;
begin
  Result := TTString.Create(FValue);
end;

procedure TStringConstantExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.StringLiteral(FValue);
end;



{                                                                              }
{ TIntegerConstantExpressionNode                                               }
{                                                                              }
constructor TIntegerConstantExpressionNode.Create(const Value: Integer);
begin
  inherited Create;
  FValue := Value;
end;

function TIntegerConstantExpressionNode.GetNodeParameterStr: String;
begin
  Result := IntToStr(FValue);
end;

function TIntegerConstantExpressionNode.GetAsExpression: AExpression;
begin
  Result := TIntegerConstantExpression.Create(FValue);
end;

function TIntegerConstantExpressionNode.GetValue: TObject;
begin
  Result := GetImmutableInteger(FValue);
end;

procedure TIntegerConstantExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.NumericLiteral(IntToStr(FValue));
end;



{                                                                              }
{ TFloatConstantExpressionNode                                                 }
{                                                                              }
constructor TFloatConstantExpressionNode.Create(const Value: Extended);
begin
  inherited Create;
  FValue := Value;
end;

function TFloatConstantExpressionNode.GetNodeParameterStr: String;
begin
  Result := FloatToStr(FValue);
end;

function TFloatConstantExpressionNode.GetAsExpression: AExpression;
begin
  Result := TFloatConstantExpression.Create(FValue);
end;

function TFloatConstantExpressionNode.GetValue: TObject;
begin
  Result := TTFloat.Create(FValue);
end;

procedure TFloatConstantExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.NumericLiteral(FloatToStr(FValue));
end;



{                                                                              }
{ TComplexConstantExpressionNode                                               }
{                                                                              }
constructor TComplexConstantExpressionNode.Create(const Imag: Extended);
begin
  inherited Create;
  FImag := Imag;
end;

function TComplexConstantExpressionNode.GetNodeParameterStr: String;
begin
  Result := FloatToStr(FImag);
end;

function TComplexConstantExpressionNode.GetAsExpression: AExpression;
begin
  Result := TComplexConstantExpression.Create(FImag);
end;

function TComplexConstantExpressionNode.GetValue: TObject;
begin
  Result := TTComplex.CreateEx(FImag);
end;

procedure TComplexConstantExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.NumericLiteral(FloatToStr(FImag));
  Writer.Symbol('i');
end;



{                                                                              }
{ TConditionalExpressionNode                                                   }
{                                                                              }
constructor TConditionalExpressionNode.Create(const Condition, TrueValue,
    FalseValue: AExpressionNode);
begin
  Assert(Assigned(Condition), 'Condition required');
  Assert(Assigned(TrueValue), 'TrueValue required');
  Assert(Assigned(FalseValue), 'FalseValue required');
  inherited Create;
  AddChild(Condition);
  AddChild(TrueValue);
  AddChild(FalseValue);
end;

function TConditionalExpressionNode.GetAsExpression: AExpression;
var C, T, F : AExpression;
begin
  GetThreeExpressions(C, T, F);
  Result := TConditionalExpression.Create(C, T, F);
end;

procedure TConditionalExpressionNode.WriteSource(const Writer: ASourceWriter);
var C, T, F : AExpressionNode;
begin
  GetThreeExpressionNodes(C, T, F);
  With Writer do
    begin
      Keyword(c_If);
      Space;
      C.WriteSource(Writer);
      Space;
      Keyword(c_Then);
      Space;
      T.WriteSource(Writer);
      Space;
      Keyword(c_Else);
      Space;
      F.WriteSource(Writer);
    end;
end;



{                                                                              }
{ AUnaryOperatorExpressionNode                                                 }
{                                                                              }
constructor AUnaryOperatorExpressionNode.Create(const Operand: AExpressionNode);
begin
  Assert(Assigned(Operand), 'Operand required');
  inherited Create;
  AddChild(Operand);
end;



{                                                                              }
{ TNegateExpressionNode                                                        }
{                                                                              }
function TNegateExpressionNode.GetAsExpression: AExpression;
begin
  Result := TNegateExpression.Create(GetExpression);
end;

procedure TNegateExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('-');
  GetExpressionNode(1).WriteSource(Writer);
end;



{                                                                              }
{ TLogicalNOTExpressionNode                                                    }
{                                                                              }
function TLogicalNOTExpressionNode.GetAsExpression: AExpression;
begin
  Result := TLogicalNOTExpression.Create(GetExpression);
end;

procedure TLogicalNOTExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword('not');
  Writer.Space;
  GetExpressionNode(1).WriteSource(Writer);
end;



{                                                                              }
{ ABinaryOperatorExpressionNode                                                }
{                                                                              }
constructor ABinaryOperatorExpressionNode.Create(const LeftOperand,
    RightOperand: AExpressionNode);
begin
  Assert(Assigned(LeftOperand));
  Assert(Assigned(RightOperand));
  inherited Create;
  AddChild(LeftOperand);
  AddChild(RightOperand);
end;

procedure ABinaryOperatorExpressionNode.WriteSource(const Writer: ASourceWriter);
var L, R : AExpressionNode;
begin
  GetTwoExpressionNodes(L, R);
  L.WriteSource(Writer);
  Writer.Space;
  WriteOperatorSource(Writer);
  Writer.Space;
  R.WriteSource(Writer);
end;



{                                                                              }
{ TAddExpressionNode                                                           }
{                                                                              }
function TAddExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TAddExpression.Create(L, R);
end;

procedure TAddExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('+');
end;



{                                                                              }
{ TSubtractExpressionNode                                                      }
{                                                                              }
function TSubtractExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TSubtractExpression.Create(L, R);
end;

procedure TSubtractExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('-');
end;



{                                                                              }
{ TMultiplyExpressionNode                                                      }
{                                                                              }
function TMultiplyExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TMultiplyExpression.Create(L, R);
end;

procedure TMultiplyExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('*');
end;



{                                                                              }
{ TDivideExpressionNode                                                        }
{                                                                              }
function TDivideExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TDivideExpression.Create(L, R);
end;

procedure TDivideExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('/');
end;



{                                                                              }
{ TPowerExpressionNode                                                         }
{                                                                              }
function TPowerExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TPowerExpression.Create(L, R);
end;

procedure TPowerExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('**');
end;



{                                                                              }
{ TLogicalORExpressionNode                                                     }
{                                                                              }
function TLogicalORExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TLogicalORExpression.Create(L, R);
end;

procedure TLogicalORExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Or);
end;



{                                                                              }
{ TLogicalANDExpressionNode                                                    }
{                                                                              }
function TLogicalANDExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TLogicalANDExpression.Create(L, R);
end;

procedure TLogicalANDExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_And);
end;



{                                                                              }
{ TLogicalXORExpressionNode                                                    }
{                                                                              }
function TLogicalXORExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TLogicalXORExpression.Create(L, R);
end;

procedure TLogicalXORExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Xor);
end;



{                                                                              }
{ TBitwiseSHLExpressionNode                                                    }
{                                                                              }
function TBitwiseSHLExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TBitwiseSHLExpression.Create(L, R);
end;

procedure TBitwiseSHLExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Shl);
end;



{                                                                              }
{ TBitwiseSHRExpressionNode                                                    }
{                                                                              }
function TBitwiseSHRExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TBitwiseSHRExpression.Create(L, R);
end;

procedure TBitwiseSHRExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Shr);
end;



{                                                                              }
{ TIntegerDivideExpressionNode                                                 }
{                                                                              }
function TIntegerDivideExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIntegerDivideExpression.Create(L, R);
end;

procedure TIntegerDivideExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Div);
end;



{                                                                              }
{ TRationalDivideExpressionNode                                                }
{                                                                              }
function TRationalDivideExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TRationalDivideExpression.Create(L, R);
end;

procedure TRationalDivideExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Rdiv);
end;



{                                                                              }
{ TModuloExpressionNode                                                        }
{                                                                              }
function TModuloExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TModuloExpression.Create(L, R);
end;

procedure TModuloExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Mod);
end;



{                                                                              }
{ TIsEqualExpressionNode                                                       }
{                                                                              }
function TIsEqualExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsEqualExpression.Create(L, R);
end;

procedure TIsEqualExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('=');
end;



{                                                                              }
{ TIsNotEqualExpressionNode                                                    }
{                                                                              }
function TIsNotEqualExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsNotEqualExpression.Create(L, R);
end;

procedure TIsNotEqualExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('<>');
end;



{                                                                              }
{ TIsLessExpressionNode                                                        }
{                                                                              }
function TIsLessExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsLessExpression.Create(L, R);
end;

procedure TIsLessExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('<');
end;



{                                                                              }
{ TIsGreaterExpressionNode                                                     }
{                                                                              }
function TIsGreaterExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsGreaterExpression.Create(L, R);
end;

procedure TIsGreaterExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('>');
end;



{                                                                              }
{ TIsLessOrEqualExpressionNode                                                 }
{                                                                              }
function TIsLessOrEqualExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsLessOrEqualExpression.Create(L, R);
end;

procedure TIsLessOrEqualExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('<=');
end;



{                                                                              }
{ TIsGreaterOrEqualExpressionNode                                              }
{                                                                              }
function TIsGreaterOrEqualExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsGreaterOrEqualExpression.Create(L, R);
end;

procedure TIsGreaterOrEqualExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('>=');
end;



{                                                                              }
{ TIsInExpressionNode                                                          }
{                                                                              }
function TIsInExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsInExpression.Create(L, R);
end;

procedure TIsInExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('in');
end;



{                                                                              }
{ TIsTypeExpressionNode                                                        }
{                                                                              }
function TIsTypeExpressionNode.GetAsExpression: AExpression;
var L, R : AExpression;
begin
  GetTwoExpressions(L, R);
  Result := TIsTypeExpression.Create(L, R);
end;

procedure TIsTypeExpressionNode.WriteOperatorSource(const Writer: ASourceWriter);
begin
  Writer.Symbol('is');
end;



{                                                                              }
{ TAssignmentExpressionNode                                                    }
{                                                                              }
constructor TAssignmentExpressionNode.Create(const Identifier: AIdentifierNode;
    const Value: AExpressionNode);
begin
  Assert(Assigned(Identifier));
  Assert(Assigned(Value));
  inherited Create;
  AddChild(Identifier);
  AddChild(Value);
end;

function TAssignmentExpressionNode.GetAsExpression: AExpression;
begin
  Result := TAssignmentExpression.Create(GetIdentifier, GetExpression);
end;

procedure TAssignmentExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      GetIdentifierNode.WriteSource(Writer);
      Space;
      Symbol(':=');
      Space;
      GetExpressionNode(1).WriteSource(Writer);
    end;
end;



{                                                                              }
{ TIdentifierExpressionNode                                                    }
{                                                                              }
constructor TIdentifierExpressionNode.Create(const Identifier: AIdentifierNode);
begin
  Assert(Assigned(Identifier));
  inherited Create;
  AddChild(Identifier);
end;

function TIdentifierExpressionNode.GetAsExpression: AExpression;
begin
  Result := TIdentifierExpression.Create(GetIdentifier);
end;

procedure TIdentifierExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  GetIdentifierNode.WriteSource(Writer);
end;



{                                                                              }
{ TNilExpressionNode                                                           }
{                                                                              }
function TNilExpressionNode.GetAsExpression: AExpression;
begin
  Result := TNilExpression.Create;
end;

procedure TNilExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_nil);
end;



{                                                                              }
{ TArrayConstructorExpressionNode                                              }
{                                                                              }
function TArrayConstructorExpressionNode.IsConstant: Boolean;
var E : AExpressionNodeArray;
    I : Integer;
begin
  E := GetExpressionNodes;
  For I := 0 to Length(E) - 1 do
    if not E[I].IsConstant then
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;

function TArrayConstructorExpressionNode.GetAsExpression: AExpression;
begin
  Result := TArrayConstructorExpression.Create(GetExpressions);
end;

procedure TArrayConstructorExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Symbol('[');
      Expressions(GetExpressionNodes);
      Symbol(']');
    end;
end;



{                                                                              }
{ TDictionaryConstructorExpressionNode                                         }
{                                                                              }
function TDictionaryConstructorExpressionNode.IsConstant: Boolean;
var E : AExpressionNodeArray;
    I : Integer;
begin
  E := GetExpressionNodes;
  For I := 0 to Length(E) - 1 do
    if not E[I].IsConstant then
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;

function TDictionaryConstructorExpressionNode.GetAsExpression: AExpression;
var E, K, V : AExpressionArray;
    I, L    : Integer;
begin
  E := GetExpressions;
  L := Length(E) div 2;
  SetLength(K, L);
  SetLength(V, L);
  For I := 0 to L - 1 do
    begin
      K[I] := E[I * 2];
      V[I] := E[I * 2 + 1];
    end;
  Result := TDictionaryConstructorExpression.Create(K, V);
end;

procedure TDictionaryConstructorExpressionNode.WriteSource(const Writer: ASourceWriter);
var N : AExpressionNodeArray;
    I : Integer;
begin
  N := GetExpressionNodes;
  With Writer do
    begin
      Symbol('[');
      For I := 0 to Length(N) div 2 - 1 do
        begin
          N[I * 2].WriteSource(Writer);
          Symbol(':');
          N[I * 2 + 1].WriteSource(Writer);
          Symbol(',');
          Space;
        end;
      Symbol(']');
    end;
end;



{                                                                              }
{ TListComprehensionExpressionNode                                             }
{                                                                              }
function TListComprehensionLoopNode.GetAsListComprehensionLoop: TListComprehensionLoop;
var N : TListComprehensionLoopNode;
    L : TListComprehensionLoop;
begin
  N := TListComprehensionLoopNode(GetChildNode(1, TListComprehensionLoopNode));
  if Assigned(N) then
    L := N.GetAsListComprehensionLoop
  else
    L := nil;
  Result := TListComprehensionLoop.Create(GetSimpleIdentifierValue(1, True),
    GetExpression, GetOptionalExpression(2), L);
end;

function TListComprehensionExpressionNode.GetAsExpression: AExpression;
var L : TListComprehensionLoopNode;
begin
  L := TListComprehensionLoopNode(GetChildNode(1, TListComprehensionLoopNode));
  Result := TListComprehensionExpression.Create(GetExpression, L.GetAsListComprehensionLoop);
end;



{                                                                              }
{ TNamedExpressionNode                                                         }
{                                                                              }
constructor TNamedExpressionNode.Create(const Expression: AExpressionNode);
begin
  inherited Create;
  AddChild(Expression);
end;

function TNamedExpressionNode.GetAsExpression: AExpression;
begin
  Result := TNamedExpression.Create(GetExpression);
end;

procedure TNamedExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  Writer.Keyword(c_Named);
  Writer.Space;
  GetExpressionNode(1).WriteSource(Writer);
end;



{                                                                              }
{ TNamedExistsExpressionNode                                                   }
{                                                                              }
constructor TNamedExistsExpressionNode.Create(const Expression: AExpressionNode);
begin
  inherited Create;
  AddChild(Expression);
end;

function TNamedExistsExpressionNode.GetAsExpression: AExpression;
begin
  Result := TNamedExistsExpression.Create(GetExpression);
end;

procedure TNamedExistsExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Named);
      Space;
      Keyword(c_Exists);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
    end;
end;



{                                                                              }
{ TNamedDirectoryExpressionNode                                                }
{                                                                              }
constructor TNamedDirectoryExpressionNode.Create(const Expression: AExpressionNode);
begin
  inherited Create;
  AddChild(Expression);
end;

function TNamedDirectoryExpressionNode.GetAsExpression: AExpression;
begin
  Result := TNamedDirectoryExpression.Create(GetExpression);
end;

procedure TNamedDirectoryExpressionNode.WriteSource(const Writer: ASourceWriter);
begin
  With Writer do
    begin
      Keyword(c_Named);
      Space;
      Keyword(c_Dir);
      Space;
      GetExpressionNode(1).WriteSource(Writer);
    end;
end;



end.

