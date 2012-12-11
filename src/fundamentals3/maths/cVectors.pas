{                                                                              }
{                              Vector class v3.09                              }
{                                                                              }
{             This unit is copyright © 1999-2003 by David J Butler             }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{                   Its original file name is cVectors.pas                     }
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
{ Description:                                                                 }
{   Vector class with mathematical and statistical functions.                  }
{                                                                              }
{ Revision history:                                                            }
{   1999/09/27  0.01  Initial version.                                         }
{   1999/10/30  0.02  Added StdDev                                             }
{   1999/11/04  0.03  Added Pos, Append                                        }
{   2000/06/08  0.04  TVector now inherits from TExtendedArray.                }
{   2002/06/01  0.05  Created cVector unit from cMaths.                        }
{   2003/02/16  3.06  Revised for Fundamentals 3.                              }
{   2003/03/08  3.07  Revision and bug fixes.                                  }
{   2003/03/12  3.08  Optimizations.                                           }
{   2003/03/14  3.09  Removed vector based on Int64 values.                    }
{                     Added documentation.                                     }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cVectors;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cTypes,
  cArrays;



{                                                                              }
{ TVector                                                                      }
{                                                                              }
{   A vector class with mathematical and statistical functions.                }
{                                                                              }
{   Internally the vector stores its values as Extended type floating-point    }
{   values. The storage functionality is inherited from TExtendedArray.        }
{                                                                              }
{   Min and Max return the minimum and maximum vector values. Range is the     }
{   difference between the maximum and minimum values.                         }
{                                                                              }
{   IsZero returns True if all elements in the vector have a zero value.       }
{   HasZero returns True if at least one element has a zero value.             }
{   HasNegative returns True it at least one element has a negative value.     }
{                                                                              }
{   Add, Subtract, Multiply and DotProduct is overloaded to operate on         }
{   Extended and Int64 values.                                                 }
{                                                                              }
{   Normalize divides each element with the Norm of the vector.                }
{                                                                              }
{   Sum returns the sum of all vector elements. SumAndSquares calculates the   }
{   sum of all elements and the sum of each element squared. Likewise for      }
{   SumAndCubes and SumAndQuads.                                               }
{                                                                              }
{   Mean (or average) is the sum of all vector values divided by the number    }
{   of elements in the vector.                                                 }
{                                                                              }
{   Median is the middle-most value.                                           }
{                                                                              }
{   Mode is the most frequently appearing value.                               }
{                                                                              }
{   Variance is a measure of the spread of a distribution about its mean and   }
{   is defined by var(X) = E([X - E(X)]2). The variance is expressed in the    }
{   squared unit of measurement of X.                                          }
{                                                                              }
{   Standard deviation is the square root of the variance and like variance    }
{   is a measure of variability or dispersion of a sample. Standard deviation  }
{   is expressed in the same unit of measurement as the sample values.         }
{                                                                              }
{   StdDev returns the standard deviation of the sample while                  }
{   PopulationStdDev returns the standard deviation of the population.         }
{                                                                              }
{   M1, M2, M3 and M4 are the first four central moments (moments about the    }
{   mean). The second moment about the mean is equal to the variance.          }
{                                                                              }
{   Skewness is the degree of asymmetry about a central value of a             }
{   distribution. A distribution with many small values and few large values   }
{   is positively skewed (right tail), the opposite (left tail) is negatively  }
{   skewed.                                                                    }
{                                                                              }
{   Kurtosis is the degree of peakedness of a distribution, defined as a       }
{   normalized form of the fourth central moment of a distribution. Kurtosis   }
{   is based on the size of a distribution's tails. Distributions with         }
{   relatively large tails are called "leptokurtic"; those with small tails    }
{   are called "platykurtic." A distribution with the same kurtosis as the     }
{   normal distribution is called "mesokurtic."  The kurtosis of a normal      }
{   distribution is 0.                                                         }
{                                                                              }
{   Product returns the product of all vector elements.                        }
{                                                                              }
{   Angle returns the angle in radians between two vectors. Derived from       }
{   the equation: UV = |U| |V| Cos(Angle)                                      }
{                                                                              }
const
  VectorFloatDelta = ExtendedCompareDelta;

type
  TVector = class(TExtendedArray)
  protected
    { Errors                                                                   }
    procedure CheckVectorSizeMatch(const Size: Integer);

  public
    { AType implementations                                                    }
    class function CreateInstance: AType; override;

    { TVector interface                                                        }
    procedure Add(const V: Extended); overload;
    procedure Add(const V: PExtended; const Count: Integer); overload;
    procedure Add(const V: PInt64; const Count: Integer); overload;
    procedure Add(const V: ExtendedArray); overload;
    procedure Add(const V: Int64Array); overload;
    procedure Add(const V: TExtendedArray); overload;
    procedure Add(const V: TInt64Array); overload;
    procedure Add(Const V: TObject); overload;

    procedure Subtract(const V: Extended); overload;
    procedure Subtract(const V: PExtended; const Count: Integer); overload;
    procedure Subtract(const V: PInt64; const Count: Integer); overload;
    procedure Subtract(const V: ExtendedArray); overload;
    procedure Subtract(const V: Int64Array); overload;
    procedure Subtract(const V: TExtendedArray); overload;
    procedure Subtract(const V: TInt64Array); overload;
    procedure Subtract(Const V: TObject); overload;

    procedure Multiply(const V: Extended); overload;
    procedure Multiply(const V: PExtended; const Count: Integer); overload;
    procedure Multiply(const V: PInt64; const Count: Integer); overload;
    procedure Multiply(const V: ExtendedArray); overload;
    procedure Multiply(const V: Int64Array); overload;
    procedure Multiply(const V: TExtendedArray); overload;
    procedure Multiply(const V: TInt64Array); overload;
    procedure Multiply(const V: TObject); overload;

    function  DotProduct(const V: PExtended; const Count: Integer): Extended; overload;
    function  DotProduct(const V: PInt64; const Count: Integer): Extended; overload;
    function  DotProduct(const V: ExtendedArray): Extended; overload;
    function  DotProduct(const V: Int64Array): Extended; overload;
    function  DotProduct(const V: TExtendedArray): Extended; overload;
    function  DotProduct(const V: TInt64Array): Extended; overload;
    function  DotProduct(const V: TObject): Extended; overload;

    function  Norm: Extended;
    function  Min: Extended;
    function  Max: Extended;
    function  Range(var Min, Max: Extended): Extended;

    function  IsZero(const CompareDelta: Extended = VectorFloatDelta): Boolean;
    function  HasZero(const CompareDelta: Extended = VectorFloatDelta): Boolean;
    function  HasNegative: Boolean;

    procedure Normalize;
    procedure Negate;
    procedure ValuesInvert;
    procedure ValuesSqr;
    procedure ValuesSqrt;

    function  Sum: Extended;
    function  SumOfSquares: Extended;
    procedure SumAndSquares(var Sum, SumOfSquares: Extended);
    procedure SumAndCubes(var Sum, SumOfSquares, SumOfCubes: Extended);
    procedure SumAndQuads(var Sum, SumOfSquares, SumOfCubes, SumOfQuads: Extended);
    function  WeightedSum(const Weights: TVector): Extended;

    function  Mean: Extended;
    function  HarmonicMean: Extended;
    function  GeometricMean: Extended;
    function  Median: Extended;
    function  Mode: Extended;

    function  Variance: Extended;
    function  StdDev(var Mean: Extended): Extended;
    function  PopulationVariance: Extended;
    function  PopulationStdDev: Extended;

    function  M1: Extended;
    function  M2: Extended;
    function  M3: Extended;
    function  M4: Extended;
    function  Skew: Extended;
    function  Kurtosis: Extended;

    function  Product: Extended;
    function  Angle(const V: TVector): Extended;
  end;



{                                                                              }
{ Exceptions                                                                   }
{                                                                              }
type
  EVector = class(Exception);
  EVectorInvalidSize = class(EVector);
  EVectorInvalidType = class(EVector);
  EVectorEmpty = class(EVector);
  EVectorInvalidValue = class(EVector);
  EVectorDivisionByZero = class(EVector);



implementation

uses
  { Delphi }
  Math;



{                                                                              }
{ TVector                                                                      }
{                                                                              }
class function TVector.CreateInstance: AType;
begin
  Result := TVector.Create;
end;

procedure TVector.CheckVectorSizeMatch(const Size: Integer);
begin
  if Size <> FCount then
    raise EVectorInvalidSize.Create('Vector sizes mismatch (' +
        IntToStr(FCount) + ',' + IntToStr(Size) + ')');
end;

procedure TVector.Add(const V: Extended);
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      P^ := P^ + V;
      Inc(P);
    end;
end;

procedure TVector.Add(const V: PExtended; const Count: Integer);
var I    : Integer;
    P, Q : PExtended;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  For I := 0 to Count - 1 do
    begin
      P^ := P^ + Q^;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TVector.Add(const V: PInt64; const Count: Integer);
var I : Integer;
    P : PExtended;
    Q : PInt64;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  For I := 0 to Count - 1 do
    begin
      P^ := P^ + Q^;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TVector.Add(const V: ExtendedArray);
begin
  Add(PExtended(V), Length(V));
end;

procedure TVector.Add(const V: Int64Array);
begin
  Add(PInt64(V), Length(V));
end;

procedure TVector.Add(const V: TExtendedArray);
begin
  Add(PExtended(V.Data), V.Count);
end;

procedure TVector.Add(const V: TInt64Array);
begin
  Add(PInt64(V.Data), V.Count);
end;

procedure TVector.Add(const V: TObject);
begin
  if V is TExtendedArray then
    Add(TExtendedArray(V)) else
  if V is TInt64Array then
    Add(TInt64Array(V))
  else
    raise EVectorInvalidType.Create('Vector can not add with ' +
        ObjectClassName(V));
end;

procedure TVector.Subtract(const V: Extended);
begin
  Add(-V);
end;

procedure TVector.Subtract(const V: PExtended; const Count: Integer);
var I    : Integer;
    P, Q : PExtended;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  For I := 0 to Count - 1 do
    begin
      P^ := P^ - Q^;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TVector.Subtract(const V: PInt64; const Count: Integer);
var I : Integer;
    P : PExtended;
    Q : PInt64;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  For I := 0 to Count - 1 do
    begin
      P^ := P^ - Q^;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TVector.Subtract(const V: ExtendedArray);
begin
  Subtract(PExtended(V), Length(V));
end;

procedure TVector.Subtract(const V: Int64Array);
begin
  Subtract(PInt64(V), Length(V));
end;

procedure TVector.Subtract(const V: TExtendedArray);
begin
  Subtract(PExtended(V.Data), V.Count);
end;

procedure TVector.Subtract(const V: TInt64Array);
begin
  Subtract(PInt64(V.Data), V.Count);
end;

procedure TVector.Subtract(const V: TObject);
begin
  if V is TExtendedArray then
    Subtract(TExtendedArray(V)) else
  if V is TInt64Array then
    Subtract(TInt64Array(V))
  else
    raise EVectorInvalidType.Create('Vector can not subtract with ' +
        ObjectClassName(V));
end;

procedure TVector.Multiply(const V: Extended);
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      P^ := P^ * V;
      Inc(P);
    end;
end;

procedure TVector.Multiply(const V: PExtended; const Count: Integer);
var I    : Integer;
    P, Q : PExtended;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  For I := 0 to Count - 1 do
    begin
      P^ := P^ * Q^;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TVector.Multiply(const V: PInt64; const Count: Integer);
var I : Integer;
    P : PExtended;
    Q : PInt64;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  For I := 0 to Count - 1 do
    begin
      P^ := P^ * Q^;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TVector.Multiply(const V: ExtendedArray);
begin
  Multiply(PExtended(V), Length(V));
end;

procedure TVector.Multiply(const V: Int64Array);
begin
  Multiply(PInt64(V), Length(V));
end;

procedure TVector.Multiply(const V: TExtendedArray);
begin
  Multiply(PExtended(V.Data), V.Count);
end;

procedure TVector.Multiply(const V: TInt64Array);
begin
  Multiply(PInt64(V.Data), V.Count);
end;

procedure TVector.Multiply(const V: TObject);
begin
  if V is TExtendedArray then
    Multiply(TExtendedArray(V)) else
  if V is TInt64Array then
    Multiply(TInt64Array(V))
  else
    raise EVectorInvalidType.Create('Vector can not multiply with ' +
        ObjectClassName(V));
end;

function TVector.DotProduct(const V: PExtended; const Count: Integer): Extended;
var I    : Integer;
    P, Q : PExtended;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  Result := 0.0;
  For I := 0 to Count - 1 do
    begin
      Result := Result + P^ * Q^;
      Inc(P);
      Inc(Q);
    end;
end;

function TVector.DotProduct(const V: PInt64; const Count: Integer): Extended;
var I : Integer;
    P : PExtended;
    Q : PInt64;
begin
  CheckVectorSizeMatch(Count);
  P := Pointer(FData);
  Q := V;
  Result := 0.0;
  For I := 0 to Count - 1 do
    begin
      Result := Result + P^ * Q^;
      Inc(P);
      Inc(Q);
    end;
end;

function TVector.DotProduct(const V: ExtendedArray): Extended;
begin
  Result := DotProduct(PExtended(V), Length(V));
end;

function TVector.DotProduct(const V: Int64Array): Extended;
begin
  Result := DotProduct(PInt64(V), Length(V));
end;

function TVector.DotProduct(const V: TExtendedArray): Extended;
begin
  Result := DotProduct(PExtended(V.Data), V.Count);
end;

function TVector.DotProduct(const V: TInt64Array): Extended;
begin
  Result := DotProduct(PInt64(V.Data), V.Count);
end;

function TVector.DotProduct(const V: TObject): Extended;
begin
  if V is TExtendedArray then
    Result := DotProduct(TExtendedArray(V)) else
  if V is TInt64Array then
    Result := DotProduct(TInt64Array(V))
  else
    raise EVectorInvalidType.Create('Vector can not calculate dot product with ' +
        ObjectClassName(V));
end;

function TVector.Norm: Extended;
begin
  Result := Sqrt(DotProduct(self));
end;

function TVector.Min: Extended;
var I : Integer;
    P : PExtended;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No minimum: Vector empty');
  P := Pointer(FData);
  Result := P^;
  Inc(P);
  For I := 1 to FCount - 1 do
    begin
      if P^ < Result then
        Result := P^;
      Inc(P);
    end;
end;

function TVector.Max: Extended;
var I : Integer;
    P : PExtended;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No maximum: Vector empty');
  P := Pointer(FData);
  Result := P^;
  Inc(P);
  For I := 1 to FCount - 1 do
    begin
      if P^ > Result then
        Result := P^;
      Inc(P);
    end;
end;

function TVector.Range(var Min, Max: Extended): Extended;
var I : Integer;
    P : PExtended;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No range: Vector empty');
  P := Pointer(FData);
  Min := P^;
  Max := P^;
  Inc(P);
  For I := 1 to FCount - 1 do
    begin
      if P^ < Min then
        Min := P^ else
        if P^ > Max then
          Max := P^;
      Inc(P);
    end;
  Result := Max - Min;
end;

function TVector.IsZero(const CompareDelta: Extended): Boolean;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    if not FloatZero(P^, CompareDelta) then
      begin
        Result := False;
        exit;
      end else
      Inc(P);
  Result := True;
end;

function TVector.HasZero(const CompareDelta: Extended): Boolean;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    if FloatZero(P^, CompareDelta) then
      begin
        Result := True;
        exit;
      end else
      Inc(P);
  Result := False;
end;

function TVector.HasNegative: Boolean;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    if P^ < 0.0 then
      begin
        Result := True;
        exit;
      end else
      Inc(P);
  Result := False;
end;

procedure TVector.Normalize;
var I : Integer;
    P : PExtended;
    S : Extended;
begin
  if FCount = 0 then
    exit;
  S := Norm;
  if FloatZero(S, VectorFloatDelta) then
    exit;
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      P^ := P^ / S;
      Inc(P);
    end;
end;

procedure TVector.Negate;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      P^ := -P^;
      Inc(P);
    end;
end;

procedure TVector.ValuesInvert;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      if P^ <> 0.0 then
        P^ := 1.0 / P^;
      Inc(P);
    end;
end;

procedure TVector.ValuesSqr;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      P^ := Sqr(P^);
      Inc(P);
    end;
end;

procedure TVector.ValuesSqrt;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  For I := 0 to FCount - 1 do
    begin
      P^ := Sqrt(P^);
      Inc(P);
    end;
end;

function TVector.Sum: Extended;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  Result := 0.0;
  For I := 0 to FCount - 1 do
    begin
      Result := Result + P^;
      Inc(P);
    end;
end;

function TVector.SumOfSquares: Extended;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  Result := 0.0;
  For I := 0 to FCount - 1 do
    begin
      Result := Result + Sqr(P^);
      Inc(P);
    end;
end;

procedure TVector.SumAndSquares(var Sum, SumOfSquares: Extended);
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  Sum := 0.0;
  SumOfSquares := 0.0;
  For I := 0 to FCount - 1 do
    begin
      Sum := Sum + P^;
      SumOfSquares := SumOfSquares + Sqr(P^);
      Inc(P);
    end;
end;

procedure TVector.SumAndCubes(var Sum, SumOfSquares, SumOfCubes: Extended);
var I : Integer;
    P : PExtended;
    A : Extended;
begin
  P := Pointer(FData);
  Sum := 0.0;
  SumOfSquares := 0.0;
  SumOfCubes := 0.0;
  For I := 0 to FCount - 1 do
    begin
      Sum := Sum + P^;
      A := Sqr(P^);
      SumOfSquares := SumOfSquares + A;
      A := A * P^;
      SumOfCubes := SumOfCubes + A;
    end;
end;

procedure TVector.SumAndQuads(var Sum, SumOfSquares, SumOfCubes,
    SumOfQuads: Extended);
var I : Integer;
    P : PExtended;
    A : Extended;
begin
  P := Pointer(FData);
  Sum := 0.0;
  SumOfSquares := 0.0;
  SumOfCubes := 0.0;
  SumOfQuads := 0.0;
  For I := 0 to FCount - 1 do
    begin
      Sum := Sum + P^;
      A := Sqr(P^);
      SumOfSquares := SumOfSquares + A;
      A := A * P^;
      SumOfCubes := SumOfCubes + A;
      A := A * P^;
      SumOfQuads := SumOfQuads + A;
    end;
end;

function TVector.WeightedSum(const Weights: TVector): Extended;
begin
  Result := DotProduct(Weights);
end;

function TVector.Mean: Extended;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No mean: Vector empty');
  Result := Sum / FCount;
end;

function TVector.HarmonicMean: Extended;
var I : Integer;
    P : PExtended;
    S : Extended;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No harmonic mean: Vector empty');
  P := Pointer(FData);
  S := 0.0;
  For I := 0 to FCount - 1 do
    begin
      if P^ < 0.0 then
        raise EVectorInvalidValue.Create(
            'No harmonic mean: Vector contains negative values');
      S := S + 1.0 / P^;
      Inc(P);
    end;
  Result := FCount / S;
end;

function TVector.GeometricMean: Extended;
var I : Integer;
    P : PExtended;
    S : Extended;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No geometric mean');
  P := Pointer(FData);
  S := 0.0;
  For I := 0 to FCount - 1 do
    begin
      if P^ <= 0.0 then
        raise EVectorInvalidValue.Create(
            'No geometric mean: Vector contains non-positive values');
      S := S + Ln(P^);
    end;
  Result := Exp(S / FCount);
end;

function TVector.Median: Extended;
var V : TVector;
    I : Integer;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No median: Vector empty');
  V := TVector(Duplicate);
  try
    V.Sort;
    I := (FCount - 1) div 2;
    if FCount mod 2 = 0 then
      Result := (V.FData[I] + V.FData[I + 1]) / 2.0
    else
      Result := V.FData[I];
  finally
    V.Free;
  end;
end;

function TVector.Mode: Extended;
var V         : TVector;
    I         : Integer;
    P         : PExtended;
    ModeVal   : Extended;
    ModeCount : Integer;
    CurrVal   : Extended;
    CurrCount : Integer;
begin
  if FCount = 0 then
    raise EVectorEmpty.Create('No mode: Vector empty');
  V := TVector(Duplicate);
  try
    V.Sort;
    Assert(V.FCount = FCount, 'V.FCount = FCount');
    Assert(V.FCount > 0, 'V.FCount > 0');
    P := Pointer(V.FData);
    ModeVal := P^;
    ModeCount := 0;
    CurrVal := P^;
    CurrCount := 1;
    Inc(P);
    For I := 1 to V.FCount - 1 do
      begin
        if P^ = CurrVal then
          Inc(CurrCount)
        else
          begin
            if CurrCount > ModeCount then
              begin
                ModeVal := CurrVal;
                ModeCount := CurrCount;
              end;
            CurrVal := P^;
            CurrCount := 1;
          end;
        Inc(P);
      end;
    if CurrCount > ModeCount then
      ModeVal := CurrVal;
  finally
    V.Free;
  end;
  Result := ModeVal;
end;

function TVector.Variance: Extended;
var Sum, SumOfSquares : Extended;
begin
  if FCount <= 1 then
    Result := 0.0
  else
    begin
      SumAndSquares(Sum, SumOfSquares);
      Result := (SumOfSquares - Sqr(Sum) / FCount) / (FCount - 1);
    end;
end;

function TVector.StdDev(var Mean: Extended): Extended;
var S    : Extended;
    I, N : Integer;
    P    : PExtended;
begin
  N := FCount;
  if N = 0 then
    begin
      Result := 0.0;
      exit;
    end;
  P := Pointer(FData);
  if N = 1 then
    begin
      Mean := P^;
      Result := P^;
      exit;
    end;
  Mean := self.Mean;
  S := 0.0;
  For I := 0 to N - 1 do
    begin
      S := S + Sqr(P^ - Mean);
      Inc(P);
    end;
  Result := Sqrt(S / (N - 1));
end;

function TVector.PopulationVariance: Extended;
var Sum, Sum2 : Extended;
begin
  if FCount = 0 then
    Result := 0.0
  else
    begin
      SumAndSquares(Sum, Sum2);
      Result := (Sum2 - Sqr(Sum) / FCount) / FCount;
    end;
end;

function TVector.PopulationStdDev: Extended;
begin
  Result := Sqrt(PopulationVariance);
end;

function TVector.M1: Extended;
begin
  Result := Sum / (FCount + 1.0);
end;

function TVector.M2: Extended;
var Sum, Sum2, NI : Extended;
begin
  SumAndSquares(Sum, Sum2);
  NI     := 1.0 / (FCount + 1.0);
  Result := (Sum2 * NI)
          - Sqr(Sum * NI);
end;

function TVector.M3: Extended;
var Sum, Sum2, Sum3 : Extended;
    NI, M1          : Extended;
begin
  SumAndCubes(Sum, Sum2, Sum3);
  NI     := 1.0 / (FCount + 1.0);
  M1     := Sum * NI;
  Result := (Sum3 * NI)
          - (M1 * 3.0 * Sum2 * NI)
          + (2.0 * Sqr(M1) * M1);
end;

function TVector.M4: Extended;
var Sum, Sum2, Sum3, Sum4 : Extended;
    NI, M1, M1Sqr         : Extended;
begin
  SumAndQuads(Sum, Sum2, Sum3, Sum4);
  NI     := 1.0 / (FCount + 1.0);
  M1     := Sum * NI;
  M1Sqr  := Sqr(M1);
  Result := (Sum4 * NI)
          - (M1 * 4.0 * Sum3 * NI)
          + (M1Sqr * 6.0 * Sum2 * NI)
          - (3.0 * Sqr(M1Sqr));
end;

function TVector.Skew: Extended;
var Sum, Sum2, Sum3     : Extended;
    M1, M2, M3          : Extended;
    M1Sqr, S2N, S3N, NI : Extended;
begin
  SumAndCubes(Sum, Sum2, Sum3);
  NI     := 1.0 / (FCount + 1.0);
  M1     := Sum * NI;
  M1Sqr  := Sqr(M1);
  S2N    := Sum2 * NI;
  S3N    := Sum3 * NI;
  M2     := S2N - M1Sqr;
  M3     := S3N
          - (M1 * 3.0 * S2N)
          + (2.0 * M1Sqr * M1);
  Result := M3 * Power(M2, -3/2);
end;

function TVector.Kurtosis: Extended;
var Sum, Sum2, Sum3, Sum4    : Extended;
    M1, M2, M4, M1Sqr, M2Sqr : Extended;
    S2N, S3N, NI             : Extended;
begin
  SumAndQuads(Sum, Sum2, Sum3, Sum4);
  NI     := 1.0 / (FCount + 1.0);
  M1     := Sum * NI;
  M1Sqr  := Sqr(M1);
  S2N    := Sum2 * NI;
  S3N    := Sum3 * NI;
  M2     := S2N - M1Sqr;
  M2Sqr  := Sqr(M2);
  M4     := (Sum4 * NI)
          - (M1 * 4.0 * S3N)
          + (M1Sqr * 6.0 * S2N)
          - (3.0 * Sqr(M1Sqr));
  if FloatZero(M2Sqr, VectorFloatDelta) then
    raise EVectorDivisionByZero.Create('Kurtosis: Division by zero');
  Result := M4 / M2Sqr;
end;

function TVector.Product: Extended;
var I : Integer;
    P : PExtended;
begin
  P := Pointer(FData);
  Result := 1.0;
  For I := 0 to FCount - 1 do
    begin
      Result := Result * P^;
      Inc(P);
    end;
end;

function TVector.Angle(const V: TVector): Extended;
begin
  Assert(Assigned(V), 'Assigned(V)');
  Result := ArcCos(DotProduct(V) / (Norm * V.Norm));
end;



end.

