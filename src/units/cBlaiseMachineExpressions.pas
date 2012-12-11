{                                                                              }
{                         Blaise expression classes v0.03                      }
{                                                                              }
{      This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)    }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{          Its original file name is cBlaiseMachineExpressions.pas             }
{                                                                              }
{ Description:                                                                 }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseMachineExpressions from cBlaiseMachine.   }
{   29/03/2003  0.02  Implemented Compile.                                     }
{   25/05/2003  0.03  Implemented GetAsBlaise.                                 }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineExpressions;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseVMCompiler,
  cBlaiseMachineTypes;



{                                                                              }
{ AUnaryOperationExpression                                                    }
{                                                                              }
type
  TUnaryFunction = procedure(const A: TObject);
  AUnaryOperationExpression = class(AExpression)
  protected
    FOperand   : AExpression;
    FOperation : TUnaryFunction;

  public
    constructor Create(const Operand: AExpression; const Operation: TUnaryFunction);
    destructor Destroy; override;

    function  Simplify(const Scope: ABlaiseType): AExpression; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
  end;



{                                                                              }
{ ABinaryOperationExpression                                                   }
{                                                                              }
type
  ABinaryOperationExpression = class(AExpression)
  protected
    FLeftOperand  : AExpression;
    FRightOperand : AExpression;

    procedure EvaluateOperands(const Scope: ABlaiseType; var LeftValue, RightValue: TObject);
    procedure ReleaseOperands (var LeftValue, RightValue: TObject);
    function  GetOperatorString: String; virtual;

  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Simplify(const Scope: ABlaiseType): AExpression; override;
  end;



{                                                                              }
{ ABooleanBinaryOperationExpression                                            }
{                                                                              }
type
  ABooleanBinaryOperationExpression = class(ABinaryOperationExpression)
    function  EvaluateAsInteger(const Scope: ABlaiseType): Int64; override;
  end;



{                                                                              }
{ TIdentifierExpression                                                        }
{                                                                              }
type
  TIdentifierExpression = class(AExpression)
  protected
    FIdentifier : AIdentifier;

  public
    constructor Create(const Identifier: AIdentifier);
    destructor Destroy; override;

    property  Identifier: AIdentifier read FIdentifier;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TAssignmentExpression                                                        }
{                                                                              }
type
  TAssignmentExpression = class(AExpression)
  protected
    FIdentifier : AIdentifier;
    FExpression : AExpression;

  public
    constructor Create(const Identifier: AIdentifier;
                const Expression: AExpression);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TNilExpression                                                               }
{                                                                              }
type
  TNilExpression = class(AExpression)
    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ AConstantExpression                                                          }
{                                                                              }
type
  AConstantExpression = class(AExpression);


  
{                                                                              }
{ TConstantExpression                                                          }
{                                                                              }
type
  TConstantExpression = class(AConstantExpression)
  protected
    FValue : TObject;

  public
    constructor Create(const Value: TObject);
    destructor Destroy; override;
    property  Value: TObject read FValue write FValue;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TBooleanConstantExpression                                                   }
{                                                                              }
type
  TBooleanConstantExpression = class(AConstantExpression)
  protected
    FValue : Boolean;

  public
    constructor Create(const Value: Boolean);
    property  Value: Boolean read FValue write FValue;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TStringConstantExpression                                                    }
{                                                                              }
type
  TStringConstantExpression = class(AConstantExpression)
  protected
    FValue : String;

  public
    constructor Create(const Value: String);
    property  Value: String read FValue write FValue;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIntegerConstantExpression                                                   }
{                                                                              }
type
  TIntegerConstantExpression = class(AConstantExpression)
  protected
    FValue : Integer;

  public
    constructor Create(const Value: Integer);
    property  Value: Integer read FValue write FValue;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TFloatConstantExpression                                                     }
{                                                                              }
type
  TFloatConstantExpression = class(AConstantExpression)
  protected
    FValue : Extended;

  public
    constructor Create(const Value: Extended);
    property  Value: Extended read FValue write FValue;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TComplexConstantExpression                                                   }
{                                                                              }
type
  TComplexConstantExpression = class(AConstantExpression)
  protected
    FImag : Extended;

  public
    constructor Create(const Imag: Extended);
    property  Imag: Extended read FImag write FImag;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TConditionalExpression                                                       }
{                                                                              }
type
  TConditionalExpression = class(AExpression)
  protected
    FCondition  : AExpression;
    FTrueValue  : AExpression;
    FFalseValue : AExpression;

  public
    constructor Create(const Condition, TrueValue, FalseValue: AExpression);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Simplify(const Scope: ABlaiseType): AExpression; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TNegateExpression                                                            }
{                                                                              }
type
  TNegateExpression = class(AUnaryOperationExpression)
    constructor Create(const Operand: AExpression);
    function  GetAsBlaise: String; override;
    function  Simplify(const Scope: ABlaiseType): AExpression; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TAbsExpression                                                               }
{                                                                              }
type
  TAbsExpression = class(AUnaryOperationExpression)
    constructor Create(const Operand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TSqrExpression                                                               }
{                                                                              }
type
  TSqrExpression = class(AUnaryOperationExpression)
    constructor Create(const Operand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TSqrtExpression                                                              }
{                                                                              }
type
  TSqrtExpression = class(AUnaryOperationExpression)
    constructor Create(const Operand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TLogicalNOTExpression                                                        }
{                                                                              }
type
  TLogicalNOTExpression = class(AUnaryOperationExpression)
    constructor Create(const Operand: AExpression);
    function  GetAsBlaise: String; override;
    function  Simplify(const Scope: ABlaiseType): AExpression; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ ACohersableBinaryOperationExpression                                         }
{                                                                              }
type
  TCohersableBinaryFunction = function (const A, B: TObject): TObject;
  ACohersableBinaryOperationExpression = class(ABinaryOperationExpression)
  protected
    FOperation : TCohersableBinaryFunction;

    procedure CompileOperation(const VM: TBlaiseVMCompiler); virtual; abstract;

  public
    constructor Create(const LeftOperand, RightOperand: AExpression;
                const Operation: TCohersableBinaryFunction);

    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TAddExpression                                                               }
{                                                                              }
type
  TAddExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TSubtractExpression                                                          }
{                                                                              }
type
  TSubtractExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TMultiplyExpression                                                          }
{                                                                              }
type
  TMultiplyExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TDivideExpression                                                            }
{                                                                              }
type
  TDivideExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TPowerExpression                                                             }
{                                                                              }
type
  TPowerExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TRationalDivideExpression                                                    }
{                                                                              }
type
  TRationalDivideExpression = class(ABinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIntegerDivideExpression                                                     }
{                                                                              }
type
  TIntegerDivideExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TModuloExpression                                                            }
{                                                                              }
type
  TModuloExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TLogicalANDExpression                                                        }
{                                                                              }
type
  TLogicalANDExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TLogicalORExpression                                                         }
{                                                                              }
type
  TLogicalORExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TLogicalXORExpression                                                        }
{                                                                              }
type
  TLogicalXORExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TBitwiseSHLExpression                                                        }
{                                                                              }
type
  TBitwiseSHLExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ TBitwiseSHRExpression                                                        }
{                                                                              }
type
  TBitwiseSHRExpression = class(ACohersableBinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
    procedure CompileOperation(const VM: TBlaiseVMCompiler); override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
  end;



{                                                                              }
{ AIsEqualExpression                                                           }
{                                                                              }
type
  AIsEqualExpression = class(ABooleanBinaryOperationExpression)
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  EvaluateAsBoolean(const Scope: ABlaiseType): Boolean; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIsEqualExpression                                                           }
{                                                                              }
type
  TIsEqualExpression = class(AIsEqualExpression)
  protected
    function  GetOperatorString: String; override;
  end;



{                                                                              }
{ TIsNotEqualExpression                                                        }
{                                                                              }
type
  TIsNotEqualExpression = class(AIsEqualExpression)
  protected
    function  GetOperatorString: String; override;
  public
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  EvaluateAsBoolean(const Scope: ABlaiseType): Boolean; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ ACompareOperationExpression                                                  }
{                                                                              }
type
  ACompareOperationExpression = class(ABooleanBinaryOperationExpression)
  protected
    FCompareSet : TCompareResultSet;

  public
    constructor Create(const LeftOperand, RightOperand: AExpression;
        const CompareSet: TCompareResultSet);

    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    function  EvaluateAsBoolean(const Scope: ABlaiseType): Boolean; override;
  end;



{                                                                              }
{ TIsLessExpression                                                            }
{                                                                              }
type
  TIsLessExpression = class(ACompareOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIsGreaterExpression                                                         }
{                                                                              }
type
  TIsGreaterExpression = class(ACompareOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIsLessOrEqualExpression                                                     }
{                                                                              }
type
  TIsLessOrEqualExpression = class(ACompareOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIsGreaterOrEqualExpression                                                  }
{                                                                              }
type
  TIsGreaterOrEqualExpression = class(ACompareOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    constructor Create(const LeftOperand, RightOperand: AExpression);
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIsTypeExpression                                                            }
{                                                                              }
type
  TIsTypeExpression = class(ABinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TIsInExpression                                                              }
{                                                                              }
type
  TIsInExpression = class(ABinaryOperationExpression)
  protected
    function  GetOperatorString: String; override;
  public
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TRangeExpression                                                             }
{                                                                              }
type
  TRangeExpression = class(ABinaryOperationExpression)
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
  end;



{                                                                              }
{ TArrayConstructorExpression                                                  }
{                                                                              }
type
  TArrayConstructorExpression = class(AExpression)
  protected
    FValues : AExpressionArray;

  public
    constructor Create(const Values: AExpressionArray);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Simplify(const Scope: ABlaiseType): AExpression; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TDictionaryConstructorExpression                                             }
{                                                                              }
type
  TDictionaryConstructorExpression = class(AExpression)
  protected
    FKeys   : AExpressionArray;
    FValues : AExpressionArray;

  public
    constructor Create(const Keys, Values: AExpressionArray);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Simplify(const Scope: ABlaiseType): AExpression; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TListComprehensionExpression                                                 }
{                                                                              }
type
  TListComprehensionLoop = class
  protected
    FIdentifier : String;
    FCollection : AExpression;
    FCondition  : AExpression;
    FLoop       : TListComprehensionLoop;

  public
    constructor Create(const Identifier: String; const Collection: AExpression;
                const Condition: AExpression;
                const Loop: TListComprehensionLoop);
    destructor Destroy; override;

    function  Evaluate(const Scope: ABlaiseType;
              const Expression: AExpression): TObject;
    procedure Compile(const VM: TBlaiseVMCompiler;
              const Expression: AExpression);
  end;

  TListComprehensionExpression = class(AExpression)
  protected
    FExpression : AExpression;
    FLoop       : TListComprehensionLoop;

  public
    constructor Create(const Expression: AExpression;
                const Loop: TListComprehensionLoop);
    destructor Destroy; override;

    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TNamedExistsExpression                                                       }
{                                                                              }
type
  TNamedExistsExpression = class(AExpression)
  protected
    FExpression : AExpression;

  public
    constructor Create(const Expression: AExpression);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TNamedExpression                                                             }
{                                                                              }
type
  TNamedExpression = class(AExpression)
  protected
    FExpression : AExpression;

  public
    constructor Create(const Expression: AExpression);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



{                                                                              }
{ TNamedDirectoryExpression                                                    }
{                                                                              }
type
  TNamedDirectoryExpression = class(AExpression)
  protected
    FExpression : AExpression;

  public
    constructor Create(const Expression: AExpression);
    destructor Destroy; override;

    function  GetAsBlaise: String; override;
    function  Evaluate(const Scope: ABlaiseType): TObject; override;
    procedure Compile(const VM: TBlaiseVMCompiler); override;
  end;



implementation

uses
  { Fundamentals }
  cStrings,
  cStreams,
  cArrays,
  cDictionaries,
  cRational,

  { Blaise }
  cBlaiseFuncs,
  cBlaiseParserLexer,
  cBlaiseStructsSimple,
  cBlaiseStructsCollections,
  cBlaiseStructs;



{                                                                              }
{ AUnaryOperationExpression                                                    }
{                                                                              }
constructor AUnaryOperationExpression.Create(const Operand: AExpression; const Operation: TUnaryFunction);
begin
  inherited Create;
  FOperand := Operand;
  FOperation := Operation;
end;

destructor AUnaryOperationExpression.Destroy;
begin
  FreeAndNil(FOperand);
  inherited Destroy;
end;

function AUnaryOperationExpression.Simplify(const Scope: ABlaiseType): AExpression;
begin
  FOperand := FOperand.Simplify(Scope);
  if FOperand is TConstantExpression then
    begin
      Result := TConstantExpression.Create(Evaluate(Scope));
      Free;
    end
  else
    Result := self;
end;

function AUnaryOperationExpression.Evaluate(const Scope: ABlaiseType): TObject;
var V : TObject;
begin
  V := FOperand.Evaluate(Scope);
  try
    Result := ObjectDuplicate(V);
  finally
    ObjectReleaseUnreferenced(V);
  end;
  try
    FOperation(Result);
  except
    ObjectReleaseUnreferenced(Result);
    raise;
  end;
end;



{                                                                              }
{ ABinaryOperationExpression                                                   }
{                                                                              }
constructor ABinaryOperationExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create;
  FLeftOperand := LeftOperand;
  FRightOperand := RightOperand;
end;

destructor ABinaryOperationExpression.Destroy;
begin
  FreeAndNil(FRightOperand);
  FreeAndNil(FLeftOperand);
  inherited Destroy;
end;

procedure ABinaryOperationExpression.EvaluateOperands(const Scope: ABlaiseType;
    var LeftValue, RightValue: TObject);
begin
  LeftValue := FLeftOperand.Evaluate(Scope);
  try
    RightValue := FRightOperand.Evaluate(Scope);
  except
    ObjectReleaseUnreferenced(LeftValue);
    LeftValue := nil;
    raise;
  end;
end;

procedure ABinaryOperationExpression.ReleaseOperands(var LeftValue, RightValue: TObject);
begin
  ObjectReleaseUnreferenced(LeftValue);
  LeftValue := nil;
  ObjectReleaseUnreferenced(RightValue);
  RightValue := nil;
end;

function ABinaryOperationExpression.GetOperatorString: String;
begin
  Result := '_' + StrExclSuffix(ObjectClassName(self), 'Expression', False) +
            '_';
end;

function ABinaryOperationExpression.GetAsBlaise: String;
begin
  Result := '(' + FLeftOperand.GetAsBlaise + ' ' + GetOperatorString + ' ' +
      FRightOperand.GetAsBlaise + ')';
end;

function ABinaryOperationExpression.Simplify(const Scope: ABlaiseType): AExpression;
begin
  FLeftOperand := FLeftOperand.Simplify(Scope);
  FRightOperand := FRightOperand.Simplify(Scope);
  if (FLeftOperand is AConstantExpression) and (FRightOperand is AConstantExpression) then
    begin
      Result := TConstantExpression.Create(Evaluate(Scope));
      Free;
    end
  else
    Result := self;
end;



{                                                                              }
{ ABooleanBinaryOperationExpression                                            }
{                                                                              }
function ABooleanBinaryOperationExpression.EvaluateAsInteger(const Scope: ABlaiseType): Int64;
begin
  if EvaluateAsBoolean(Scope) then
    Result := 1 else
    Result := 0;
end;



{                                                                              }
{ TIdentifierExpression                                                        }
{                                                                              }
constructor TIdentifierExpression.Create(const Identifier: AIdentifier);
begin
  inherited Create;
  FIdentifier := Identifier;
end;

destructor TIdentifierExpression.Destroy;
begin
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

function TIdentifierExpression.GetAsBlaise: String;
begin
  Result := FIdentifier.GetAsBlaise;
end;

function TIdentifierExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := FIdentifier.Evaluate(Scope);
end;

procedure TIdentifierExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FIdentifier.CompileEvaluate(VM);
  VM.PushAccumulator;
end;



{                                                                              }
{ TAssignmentExpression                                                        }
{                                                                              }
constructor TAssignmentExpression.Create(const Identifier: AIdentifier;
    const Expression: AExpression);
begin
  inherited Create;
  FIdentifier := Identifier;
  FExpression := Expression;
end;

destructor TAssignmentExpression.Destroy;
begin
  FreeAndNil(FExpression);
  FreeAndNil(FIdentifier);
  inherited Destroy;
end;

function TAssignmentExpression.GetAsBlaise: String;
begin
  Result := '(' + FIdentifier.GetAsBlaise + ' := ' +
            FExpression.GetAsBlaise + ')';
end;

function TAssignmentExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := FExpression.Evaluate(Scope);
  FIdentifier.AssignValue(Scope, Result);
end;

procedure TAssignmentExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  VM.PopAccumulator;
  VM.PushAccumulator;
  VM.PushAccumulator;
  FIdentifier.CompileAssign(VM);
end;



{                                                                              }
{ TNilExpression                                                               }
{                                                                              }
function TNilExpression.GetAsBlaise: String;
begin
  Result := c_Nil;
end;

function TNilExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := UnassignedValue;
end;

procedure TNilExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushNil;
end;



{                                                                              }
{ TConstantExpression                                                          }
{                                                                              }
constructor TConstantExpression.Create(const Value: TObject);
begin
  inherited Create;
  ObjectAddReference(Value);
  FValue := Value;
end;

destructor TConstantExpression.Destroy;
begin
  if Assigned(FValue) then
    ObjectReleaseReference(FValue);
  inherited Destroy;
end;

function TConstantExpression.GetAsBlaise: String;
begin
  Result := ObjectGetAsBlaise(FValue);
end;

function TConstantExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := FValue;
end;

procedure TConstantExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushObject(FValue);
end;



{                                                                              }
{ TBooleanConstantExpression                                                   }
{                                                                              }
constructor TBooleanConstantExpression.Create(const Value: Boolean);
begin
  inherited Create;
  FValue := Value;
end;

function TBooleanConstantExpression.GetAsBlaise: String;
begin
  if FValue then
    Result := 'True' else
    Result := 'False';
end;

function TBooleanConstantExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := GetImmutableBoolean(FValue);
end;

procedure TBooleanConstantExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushBoolean(FValue);
end;



{                                                                              }
{ TStringConstantExpression                                                    }
{                                                                              }
constructor TStringConstantExpression.Create(const Value: String);
begin
  inherited Create;
  FValue := Value;
end;

function TStringConstantExpression.GetAsBlaise: String;
begin
  Result := StrQuote(FValue, '''');
end;

function TStringConstantExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := TTString.Create(FValue);
end;

procedure TStringConstantExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushString(FValue);
end;



{                                                                              }
{ TIntegerConstantExpression                                                   }
{                                                                              }
constructor TIntegerConstantExpression.Create(const Value: Integer);
begin
  inherited Create;
  FValue := Value;
end;

function TIntegerConstantExpression.GetAsBlaise: String;
begin
  Result := IntToStr(FValue);
end;

function TIntegerConstantExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := GetImmutableInteger(FValue);
end;

procedure TIntegerConstantExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushInteger(FValue);
end;



{                                                                              }
{ TFloatConstantExpression                                                     }
{                                                                              }
constructor TFloatConstantExpression.Create(const Value: Extended);
begin
  inherited Create;
  FValue := Value;
end;

function TFloatConstantExpression.GetAsBlaise: String;
begin
  Result := FloatToStr(FValue);
end;

function TFloatConstantExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := TTFloat.Create(FValue);
end;

procedure TFloatConstantExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushFloat(FValue);
end;



{                                                                              }
{ TComplexConstantExpression                                                   }
{                                                                              }
constructor TComplexConstantExpression.Create(const Imag: Extended);
begin
  inherited Create;
  FImag := Imag;
end;

function TComplexConstantExpression.GetAsBlaise: String;
begin
  Result := FloatToStr(FImag) + 'i';
end;

function TComplexConstantExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := TTComplex.CreateEx(FImag);
end;

procedure TComplexConstantExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  VM.PushComplex(FImag);
end;



{                                                                              }
{ TConditionalExpression                                                       }
{                                                                              }
constructor TConditionalExpression.Create(const Condition, TrueValue, FalseValue: AExpression);
begin
  inherited Create;
  FCondition := Condition;
  FTrueValue := TrueValue;
  FFalseValue := FalseValue;
end;

destructor TConditionalExpression.Destroy;
begin
  FreeAndNil(FFalseValue);
  FreeAndNil(FTrueValue);
  FreeAndNil(FCondition);
  inherited Destroy;
end;

function TConditionalExpression.GetAsBlaise: String;
begin
  Result := '(' + c_If + ' ' + FCondition.GetAsBlaise + ' ' + c_Then + ' ' +
            FTrueValue.GetAsBlaise + ' ' + c_Else + ' ' +
            FFalseValue.GetAsBlaise + ')';
end;

function TConditionalExpression.Simplify(const Scope: ABlaiseType): AExpression;
begin
  FCondition := FCondition.Simplify(Scope);
  FTrueValue := FTrueValue.Simplify(Scope);
  FFalseValue := FFalseValue.Simplify(Scope);
  if FCondition is TConstantExpression then
    begin
      if FCondition.EvaluateAsBoolean(Scope) then
        begin
          Result := FTrueValue;
          FTrueValue := nil;
        end else
        begin
          Result := FFalseValue;
          FFalseValue := nil;
        end;
      Free;
    end
  else
    Result := self;
end;

function TConditionalExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  if FCondition.EvaluateAsBoolean(Scope) then
    Result := FTrueValue.Evaluate(Scope)
  else
    Result := FFalseValue.Evaluate(Scope);
end;

procedure TConditionalExpression.Compile(const VM: TBlaiseVMCompiler);
var F, G : Integer;
begin
  FCondition.Compile(VM);
  VM.PopBoolean;
  F := VM.JumpFalse;
  FTrueValue.Compile(VM);
  G := VM.Jump;
  VM.SetJumpPosition(F);
  FFalseValue.Compile(VM);
  VM.SetJumpPosition(G);
end;



{                                                                              }
{ TNegateExpression                                                            }
{                                                                              }
constructor TNegateExpression.Create(const Operand: AExpression);
begin
  inherited Create(Operand, ObjectNegate);
end;

function TNegateExpression.GetAsBlaise: String;
begin
  Result := '-(' + FOperand.GetAsBlaise + ')';
end;

function TNegateExpression.Simplify(const Scope: ABlaiseType): AExpression;
begin
  Result := inherited Simplify(Scope);
  if Result <> self then
    exit;
  if FOperand is TNegateExpression then
    begin
      Result := TNegateExpression(FOperand).FOperand;
      TNegateExpression(FOperand).FOperand := nil;
      Free;
    end;
end;

procedure TNegateExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FOperand.Compile(VM);
  VM.UnOpNegate;
end;



{                                                                              }
{ TAbsExpression                                                               }
{                                                                              }
constructor TAbsExpression.Create(const Operand: AExpression);
begin
  inherited Create(Operand, ObjectAbs);
end;

procedure TAbsExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FOperand.Compile(VM);
  VM.UnOpAbs;
end;



{                                                                              }
{ TSqrExpression                                                               }
{                                                                              }
constructor TSqrExpression.Create(const Operand: AExpression);
begin
  inherited Create(Operand, ObjectSqr);
end;

procedure TSqrExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FOperand.Compile(VM);
  VM.UnOpSqr;
end;



{                                                                              }
{ TSqrtExpression                                                              }
{                                                                              }
constructor TSqrtExpression.Create(const Operand: AExpression);
begin
  inherited Create(Operand, ObjectSqr);
end;

procedure TSqrtExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FOperand.Compile(VM);
  VM.UnOpSqrt;
end;



{                                                                              }
{ TLogicalNOTExpression                                                        }
{                                                                              }
constructor TLogicalNOTExpression.Create(const Operand: AExpression);
begin
  inherited Create(Operand, ObjectLogicalNOT);
end;

function TLogicalNOTExpression.GetAsBlaise: String;
begin
  Result := c_Not + ' (' + FOperand.GetAsBlaise + ')';
end;

function TLogicalNOTExpression.Simplify(const Scope: ABlaiseType): AExpression;
begin
  Result := inherited Simplify(Scope);
  if Result <> self then
    exit;
  if FOperand is TLogicalNOTExpression then
    begin
      Result := TLogicalNOTExpression(FOperand).FOperand;
      TLogicalNOTExpression(FOperand).FOperand := nil;
      Free;
    end;
end;

procedure TLogicalNOTExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FOperand.Compile(VM);
  VM.UnOpLogicalNOT;
end;



{                                                                              }
{ ACohersableBinaryOperationExpression                                         }
{                                                                              }
constructor ACohersableBinaryOperationExpression.Create(const LeftOperand,
    RightOperand: AExpression; const Operation: TCohersableBinaryFunction);
begin
  inherited Create(LeftOperand, RightOperand);
  FOperation := Operation;
end;

function ACohersableBinaryOperationExpression.Evaluate(
    const Scope: ABlaiseType): TObject;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := FOperation(L, R);
  finally
    ReleaseOperands(L, R);
  end;
end;

procedure ACohersableBinaryOperationExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  CompileOperation(VM);
end;



{                                                                              }
{ TAddExpression                                                               }
{                                                                              }
constructor TAddExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationAdd);
end;

function TAddExpression.GetOperatorString: String;
begin
  Result := '+';
end;

procedure TAddExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpAdd;
end;



{                                                                              }
{ TSubtractExpression                                                          }
{                                                                              }
constructor TSubtractExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationSubtract);
end;

function TSubtractExpression.GetOperatorString: String;
begin
  Result := '-';
end;

procedure TSubtractExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpSubtract;
end;



{                                                                              }
{ TMultiplyExpression                                                          }
{                                                                              }
constructor TMultiplyExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationMultiply);
end;

function TMultiplyExpression.GetOperatorString: String;
begin
  Result := '*';
end;

procedure TMultiplyExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpMultiply;
end;



{                                                                              }
{ TDivideExpression                                                            }
{                                                                              }
constructor TDivideExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationDivide);
end;

function TDivideExpression.GetOperatorString: String;
begin
  Result := '/';
end;

procedure TDivideExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpDivide;
end;



{                                                                              }
{ TPowerExpression                                                             }
{                                                                              }
constructor TPowerExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationPower);
end;

function TPowerExpression.GetOperatorString: String;
begin
  Result := c_Power;
end;

procedure TPowerExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpPower;
end;



{                                                                              }
{ TRationalDivideExpression                                                    }
{                                                                              }
function TRationalDivideExpression.GetOperatorString: String;
begin
  Result := c_RDiv;
end;

function TRationalDivideExpression.Evaluate(const Scope: ABlaiseType): TObject;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := TTRational.CreateEx(TRational.Create(ObjectGetAsInteger(L), ObjectGetAsInteger(R)));
  finally
    ReleaseOperands(L, R);
  end;
end;

procedure TRationalDivideExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.CreateRational;
end;



{                                                                              }
{ TIntegerDivideExpression                                                     }
{                                                                              }
constructor TIntegerDivideExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationIntegerDivide);
end;

function TIntegerDivideExpression.GetOperatorString: String;
begin
  Result := 'div';
end;

procedure TIntegerDivideExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpIntegerDivide;
end;



{                                                                              }
{ TModuloExpression                                                            }
{                                                                              }
constructor TModuloExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationModulo);
end;

function TModuloExpression.GetOperatorString: String;
begin
  Result := 'mod';
end;

procedure TModuloExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpModulo;
end;



{                                                                              }
{ TLogicalANDExpression                                                        }
{                                                                              }
constructor TLogicalANDExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationLogicalAND);
end;

function TLogicalANDExpression.GetOperatorString: String;
begin
  Result := 'and';
end;

procedure TLogicalANDExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpLogicalAND;
end;


{                                                                              }
{ TLogicalORExpression                                                         }
{                                                                              }
constructor TLogicalORExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationLogicalOR);
end;

function TLogicalORExpression.GetOperatorString: String;
begin
  Result := 'or';
end;

procedure TLogicalORExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpLogicalOR;
end;



{                                                                              }
{ TLogicalXORExpression                                                        }
{                                                                              }
constructor TLogicalXORExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationLogicalXOR);
end;

function TLogicalXORExpression.GetOperatorString: String;
begin
  Result := 'xor';
end;

procedure TLogicalXORExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpLogicalXOR;
end;



{                                                                              }
{ TBitwiseSHLExpression                                                        }
{                                                                              }
constructor TBitwiseSHLExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationBitwiseSHL);
end;

function TBitwiseSHLExpression.GetOperatorString: String;
begin
  Result := 'shl';
end;

procedure TBitwiseSHLExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpBitwiseSHL;
end;



{                                                                              }
{ TBitwiseSHRExpression                                                        }
{                                                                              }
constructor TBitwiseSHRExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, OperationBitwiseSHR);
end;

function TBitwiseSHRExpression.GetOperatorString: String;
begin
  Result := 'shr';
end;

procedure TBitwiseSHRExpression.CompileOperation(const VM: TBlaiseVMCompiler);
begin
  VM.BinOpBitwiseSHR;
end;



{                                                                              }
{ AIsEqualExpression                                                           }
{                                                                              }
function AIsEqualExpression.EvaluateAsBoolean(const Scope: ABlaiseType): Boolean;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := ObjectIsEqual(L, R);
  finally
    ReleaseOperands(L, R);
  end;
end;

function AIsEqualExpression.Evaluate(const Scope: ABlaiseType): TObject;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := GetImmutableBoolean(ObjectIsEqual(L, R));
  finally
    ReleaseOperands(L, R);
  end;
end;

procedure AIsEqualExpression.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.Compare;
  VM.Pop;
  VM.Pop;
  P := VM.JumpEqual;
  VM.PushBoolean(False);
  Q := VM.Jump;
  VM.SetJumpPosition(P);
  VM.PushBoolean(True);
  VM.SetJumpPosition(Q);
end;



{                                                                              }
{ TIsEqualExpression                                                           }
{                                                                              }
function TIsEqualExpression.GetOperatorString: String;
begin
  Result := '=';
end;



{                                                                              }
{ TIsNotEqualExpression                                                        }
{                                                                              }
function TIsNotEqualExpression.GetOperatorString: String;
begin
  Result := '<>';
end;

function TIsNotEqualExpression.EvaluateAsBoolean(const Scope: ABlaiseType): Boolean;
begin
  Result := not inherited EvaluateAsBoolean(Scope);
end;

function TIsNotEqualExpression.Evaluate(const Scope: ABlaiseType): TObject;
begin
  Result := inherited Evaluate(Scope);
  TTBoolean(Result).Negate;
end;

procedure TIsNotEqualExpression.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.Compare;
  VM.Pop;
  VM.Pop;
  P := VM.JumpEqual;
  VM.PushBoolean(True);
  Q := VM.Jump;
  VM.SetJumpPosition(P);
  VM.PushBoolean(False);
  VM.SetJumpPosition(Q);
end;



{                                                                              }
{ ACompareOperationExpression                                                  }
{                                                                              }
constructor ACompareOperationExpression.Create(const LeftOperand, RightOperand: AExpression;
    const CompareSet: TCompareResultSet);
begin
  inherited Create(LeftOperand, RightOperand);
  FCompareSet := CompareSet;
end;

function ACompareOperationExpression.EvaluateAsBoolean(const Scope: ABlaiseType): Boolean;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := ObjectCompare(L, R) in FCompareSet;
  finally
    ReleaseOperands(L, R);
  end;
end;

function ACompareOperationExpression.Evaluate(const Scope: ABlaiseType): TObject;
var L, R : TObject;
  V : Boolean;
begin
  EvaluateOperands(Scope, L, R);
  try
    V := ObjectCompare(L, R) in FCompareSet;
    Result := GetImmutableBoolean(V);
  finally
    ReleaseOperands(L, R);
  end;
end;



{                                                                              }
{ TIsLessExpression                                                            }
{                                                                              }
constructor TIsLessExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, [crLess]);
end;

function TIsLessExpression.GetOperatorString: String;
begin
  Result := '<';
end;

procedure TIsLessExpression.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.Compare;
  VM.Pop;
  VM.Pop;
  P := VM.JumpLess;
  VM.PushBoolean(False);
  Q := VM.Jump;
  VM.SetJumpPosition(P);
  VM.PushBoolean(True);
  VM.SetJumpPosition(Q);
end;



{                                                                              }
{ TIsGreaterExpression                                                         }
{                                                                              }
constructor TIsGreaterExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, [crGreater]);
end;

function TIsGreaterExpression.GetOperatorString: String;
begin
  Result := '>';
end;

procedure TIsGreaterExpression.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.Compare;
  VM.Pop;
  VM.Pop;
  P := VM.JumpGreater;
  VM.PushBoolean(False);
  Q := VM.Jump;
  VM.SetJumpPosition(P);
  VM.PushBoolean(True);
  VM.SetJumpPosition(Q);
end;



{                                                                              }
{ TIsLessOrEqualExpression                                                     }
{                                                                              }
constructor TIsLessOrEqualExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, [crLess, crEqual]);
end;

function TIsLessOrEqualExpression.GetOperatorString: String;
begin
  Result := '<=';
end;

procedure TIsLessOrEqualExpression.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.Compare;
  VM.Pop;
  VM.Pop;
  P := VM.JumpGreater;
  VM.PushBoolean(True);
  Q := VM.Jump;
  VM.SetJumpPosition(P);
  VM.PushBoolean(False);
  VM.SetJumpPosition(Q);
end;



{                                                                              }
{ TIsGreaterOrEqualExpression                                                  }
{                                                                              }
constructor TIsGreaterOrEqualExpression.Create(const LeftOperand, RightOperand: AExpression);
begin
  inherited Create(LeftOperand, RightOperand, [crGreater, crEqual]);
end;

function TIsGreaterOrEqualExpression.GetOperatorString: String;
begin
  Result := '>=';
end;

procedure TIsGreaterOrEqualExpression.Compile(const VM: TBlaiseVMCompiler);
var P, Q : Integer;
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.Compare;
  VM.Pop;
  VM.Pop;
  P := VM.JumpLess;
  VM.PushBoolean(True);
  Q := VM.Jump;
  VM.SetJumpPosition(P);
  VM.PushBoolean(False);
  VM.SetJumpPosition(Q);
end;



{                                                                              }
{ TIsTypeExpression                                                            }
{                                                                              }
function TIsTypeExpression.GetOperatorString: String;
begin
  Result := 'is';
end;

function TIsTypeExpression.Evaluate(const Scope: ABlaiseType): TObject;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    if not (R is ATypeDefinition) then
      EvaluateError('Not a type');
    Result := GetImmutableBoolean(ATypeDefinition(R).IsType(L));
  finally
    ReleaseOperands(L, R);
  end;
end;

procedure TIsTypeExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.EvalIsType;
  VM.Pop;
  VM.Pop;
  VM.PushBooleanRegister;
end;



{                                                                              }
{ TIsInExpression                                                              }
{                                                                              }
function TIsInExpression.GetOperatorString: String;
begin
  Result := 'in';
end;

function TIsInExpression.Evaluate(const Scope: ABlaiseType): TObject;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := GetImmutableBoolean(ObjectIsIn(L, R));
  finally
    ReleaseOperands(L, R);
  end;
end;

procedure TIsInExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FLeftOperand.Compile(VM);
  FRightOperand.Compile(VM);
  VM.EvalIsIn;
  VM.Pop;
  VM.Pop;
  VM.PushAccumulator;
end;



{                                                                              }
{ TRangeExpression                                                             }
{                                                                              }
function TRangeExpression.Evaluate(const Scope: ABlaiseType): TObject;
var L, R : TObject;
begin
  EvaluateOperands(Scope, L, R);
  try
    Result := TIntegerSubrangeType.Create(ObjectGetAsInteger(L), ObjectGetAsInteger(R));
  finally
    ReleaseOperands(L, R);
  end;
end;



{                                                                              }
{ TArrayConstructorExpression                                                  }
{                                                                              }
constructor TArrayConstructorExpression.Create(const Values: AExpressionArray);
begin
  inherited Create;
  FValues := Values;
end;

destructor TArrayConstructorExpression.Destroy;
begin
  FreeObjectArray(FValues);
  inherited Destroy;
end;

function TArrayConstructorExpression.GetAsBlaise: String;
var I : Integer;
begin
  Result := '[';
  For I := 0 to Length(FValues) - 1 do
    Result := Result + iif(I > 0, ',', '') +
              FValues[I].GetAsBlaise;
  Result := Result + ']';
end;

function TArrayConstructorExpression.Simplify(const Scope: ABlaiseType): AExpression;
var I : Integer;
begin
  Result := self;
  For I := 0 to Length(FValues) - 1 do
    FValues[I] := FValues[I].Simplify(Scope);
end;

function TArrayConstructorExpression.Evaluate(const Scope: ABlaiseType): TObject;
var I, L : Integer;
    V    : ObjectArray;
begin
  L := Length(FValues);
  SetLengthAndZero(V, L);
  try
    For I := 0 to L - 1 do
      V[I] := FValues[I].Evaluate(Scope);
  except
    FreeObjectArray(V);
    raise;
  end;
  Result := TTArray.Create(nil);
  TTArray(Result).Assign(V);
end;

procedure TArrayConstructorExpression.Compile(const VM: TBlaiseVMCompiler);
var I, L : Integer;
begin
  L := Length(FValues);
  For I := 0 to L - 1 do
    FValues[I].Compile(VM);
  VM.PushInteger(L);
  VM.CreateArray;
end;



{                                                                              }
{ TDictionaryConstructorExpression                                             }
{                                                                              }
constructor TDictionaryConstructorExpression.Create(const Keys, Values: AExpressionArray);
begin
  inherited Create;
  FKeys := Keys;
  FValues := Values;
end;

destructor TDictionaryConstructorExpression.Destroy;
begin
  FreeObjectArray(FValues);
  FreeObjectArray(FKeys);
  inherited Destroy;
end;

function TDictionaryConstructorExpression.GetAsBlaise: String;
var I, L : Integer;
begin
  L := Length(FKeys);
  if L = 0 then
    begin
      Result := '[:]';
      exit;
    end;
  Result := '[';
  For I := 0 to Length(FKeys) - 1 do
    Result := Result + iif(I > 0, ',', '') +
              FKeys[I].GetAsBlaise + ':' +
              FValues[I].GetAsBlaise;
  Result := Result + ']';
end;

function TDictionaryConstructorExpression.Simplify(const Scope: ABlaiseType): AExpression;
var I : Integer;
begin
  Result := self;
  For I := 0 to Length(FValues) - 1 do
    FValues[I] := FValues[I].Simplify(Scope);
  For I := 0 to Length(FKeys) - 1 do
    FKeys[I] := FKeys[I].Simplify(Scope);
end;

function TDictionaryConstructorExpression.Evaluate(const Scope: ABlaiseType): TObject;
var I, L : Integer;
    K : StringArray;
    V : ObjectArray;
begin
  Assert(Length(FValues) = Length(FKeys), 'Keys:Values lengths must match');
  L := Length(FValues);
  SetLength(K, L);
  SetLengthAndZero(V, L);
  try
    For I := 0 to L - 1 do
      begin
        K[I] := FKeys[I].EvaluateAsUTF8(Scope);
        V[I] := FValues[I].Evaluate(Scope);
        ObjectAddReference(V[I]);
      end;
  except
    FreeObjectArray(V);
    raise;
  end;
  Result := TTObjectDictionaryByString.CreateEx(
      TObjectDictionary.CreateEx(
          TStringArray.Create(K), TObjectArray.Create(V, False),
          False, True, True, ddAccept));
end;

procedure TDictionaryConstructorExpression.Compile(const VM: TBlaiseVMCompiler);
var I, L : Integer;
begin
  Assert(Length(FValues) = Length(FKeys), 'Keys:Values lengths must match');
  L := Length(FValues);
  For I := 0 to L - 1 do
    begin
      FKeys[I].Compile(VM);
      FValues[I].Compile(VM);
    end;
  VM.PushInteger(L);
  VM.CreateDictionary;
end;



{                                                                              }
{ TListComprehensionExpression                                                 }
{                                                                              }
constructor TListComprehensionLoop.Create(const Identifier: String;
    const Collection: AExpression; const Condition: AExpression;
    const Loop: TListComprehensionLoop);
begin
  inherited Create;
  FIdentifier := Identifier;
  FCollection := Collection;
  FCondition := Condition;
  FLoop := Loop;
end;

destructor TListComprehensionLoop.Destroy;
begin
  FreeAndNil(FLoop);
  FreeAndNil(FCondition);
  FreeAndNil(FCollection);
  inherited Destroy;
end;

function TListComprehensionLoop.Evaluate(const Scope: ABlaiseType;
    const Expression: AExpression): TObject;
var C, I, V, R : TObject;
begin
  C := FCollection.Evaluate(Scope);
  I := ObjectIterate(C);
  Result := TTArray.Create(nil);
  try
    While ObjectHasNext(I) do
      begin
        V := ObjectNext(I);
        if not Assigned(FCondition) or FCondition.EvaluateAsBoolean(Scope) then
          begin
            Scope.SetField(FIdentifier, V);
            if Assigned(FLoop) then
              begin
                R := FLoop.Evaluate(Scope, Expression);
                TTArray(Result).AppendList(R as ABlaiseArray);
              end
            else
              begin
                R := Expression.Evaluate(Scope);
                TTArray(Result).Append(R);
              end;
          end;
      end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TListComprehensionLoop.Compile(const VM: TBlaiseVMCompiler;
    const Expression: AExpression);
var F, R : Integer;
begin
  VM.PushInteger(0);
  if Assigned(FLoop) then
    VM.CreateArray;
  FCollection.Compile(VM);
  VM.EvalIterate;
  VM.Pop;
  VM.PushAccumulator;
  R := VM.GetOffset;
  VM.EvalHasNext;
  VM.LoadBooleanFromA;
  F := VM.JumpFalse;
  VM.EvalNext;
  VM.PushAccumulator;
  VM.AssignIdentifier(FIdentifier);
  if Assigned(FLoop) then
    begin
      VM.StackSwapTop2;
      FLoop.Compile(VM, Expression);
      VM.EvalAppendList;
      VM.Pop;
      VM.StackSwapTop2;
    end
  else
    begin
      VM.StackSwapTop2;
      VM.PopAccumulator;
      VM.EvalInc;
      VM.PushAccumulator;
      VM.StackSwapTop2;
      Expression.Compile(VM);
      VM.StackSwapTop2;
      VM.PopAccumulator;
      VM.StackSwapTop2;
      VM.PushAccumulator;
    end;
  VM.JumpPosition(R);
  VM.SetJumpPosition(F);
  VM.Pop;
  if not Assigned(FLoop) then
    VM.CreateArray;
end;

constructor TListComprehensionExpression.Create(const Expression: AExpression;
    const Loop: TListComprehensionLoop);
begin
  inherited Create;
  FExpression := Expression;
  FLoop := Loop;
end;

destructor TListComprehensionExpression.Destroy;
begin
  FreeAndNil(FLoop);
  FreeAndNil(FExpression);
  inherited Destroy;
end;

function TListComprehensionExpression.Evaluate(const Scope: ABlaiseType): TObject;
var S : TParentedScope;
begin
  S := TParentedScope.Create(Scope);
  try
    Result := FLoop.Evaluate(S, FExpression);
  finally
    S.Free;
  end;
end;

procedure TListComprehensionExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FLoop.Compile(VM, FExpression);
end;



{                                                                              }
{ TNamedExistsExpression                                                       }
{                                                                              }
constructor TNamedExistsExpression.Create(const Expression: AExpression);
begin
  inherited Create;
  FExpression := Expression;
end;

destructor TNamedExistsExpression.Destroy;
begin
  FreeAndNil(FExpression);
  inherited Destroy;
end;

function TNamedExistsExpression.GetAsBlaise: String;
begin
  Result := c_Named + ' ' + c_Exists + ' ' + FExpression.GetAsBlaise;
end;

function TNamedExistsExpression.Evaluate(const Scope: ABlaiseType): TObject;
var Name : String;
begin
  Name := FExpression.EvaluateAsUTF8(Scope);
  Result := GetImmutableBoolean(NameSpaceNameExists(
      ScopeGetRootNameSpace(Scope), Name));
end;

procedure TNamedExistsExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  VM.PopUTF8;
  VM.NamedExists;
end;



{                                                                              }
{ TNamedExpression                                                             }
{                                                                              }
constructor TNamedExpression.Create(const Expression: AExpression);
begin
  inherited Create;
  FExpression := Expression;
end;

destructor TNamedExpression.Destroy;
begin
  FreeAndNil(FExpression);
  inherited Destroy;
end;

function TNamedExpression.GetAsBlaise: String;
begin
  Result := c_Named + ' ' + FExpression.GetAsBlaise;
end;

function TNamedExpression.Evaluate(const Scope: ABlaiseType): TObject;
var Name : String;
begin
  Name := FExpression.EvaluateAsUTF8(Scope);
  Result := NameSpaceGetName(ScopeGetRootNameSpace(Scope), Name);
end;

procedure TNamedExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  VM.PopUTF8;
  VM.NamedGet;
end;



{                                                                              }
{ TNamedDirectoryExpression                                                    }
{                                                                              }
constructor TNamedDirectoryExpression.Create(const Expression: AExpression);
begin
  inherited Create;
  FExpression := Expression;
end;

destructor TNamedDirectoryExpression.Destroy;
begin
  FreeAndNil(FExpression);
  inherited Destroy;
end;

function TNamedDirectoryExpression.GetAsBlaise: String;
begin
  Result := c_Named + ' ' + c_Dir + ' ' + FExpression.GetAsBlaise;
end;

function TNamedDirectoryExpression.Evaluate(const Scope: ABlaiseType): TObject;
var Name : String;
begin
  Name := FExpression.EvaluateAsUTF8(Scope);
  Result := NameSpaceDirectory(ScopeGetRootNameSpace(Scope), Name);
end;

procedure TNamedDirectoryExpression.Compile(const VM: TBlaiseVMCompiler);
begin
  FExpression.Compile(VM);
  VM.PopUTF8;
  VM.NamedDirectory;
end;



end.

