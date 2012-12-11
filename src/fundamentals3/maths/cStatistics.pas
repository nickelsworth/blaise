{                                                                              }
{                               Statistics v3.04                               }
{                                                                              }
{             This unit is copyright © 2000-2003 by David J Butler             }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{                  Its original file name is cStatistics.pas                   }
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
{   Statistical functions and classes.                                         }
{                                                                              }
{ References:                                                                  }
{   MathWorld:             http://mathworld.wolfram.com/                       }
{   Statistical concepts:  http://dorakmt.tripod.com/mtd/glosstat.html         }
{                                                                              }
{ Revision history:                                                            }
{   2000/01/22  0.01  Added TStatistic.                                        }
{   2003/02/16  0.02  Created cStatistics unit from cMaths.                    }
{   2003/03/08  3.03  Revised for Fundamentals 3.                              }
{   2003/03/13  3.04  Skew and Kurtosis. Added documentation.                  }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cStatistics;

interface

uses
  { Delphi }
  SysUtils;



{                                                                              }
{ Exceptions                                                                   }
{                                                                              }
type
  EStatistics = class(Exception);
  EStatisticsInvalidArgument = class(EStatistics);
  EStatisticsOverflow = class(EStatistics);



{                                                                              }
{ Binomial distribution                                                        }
{                                                                              }
{   The binomial distribution gives the probability of obtaining exactly r     }
{   successes in n independent trials, where there are two possible outcomes   }
{   one of which is conventionally called success.                             }
{                                                                              }
{   BinomialCoeff returns the binomial coefficient for the bin(n)-             }
{   distribution.                                                              }
{                                                                              }
function  BinomialCoeff(N, R: Integer): Extended;



{                                                                              }
{ Normal distribution                                                          }
{                                                                              }
{   The Normal distribution (Gaussian distribution) is a model for values on   }
{   a continuous scale. A normal distribution can be completely described by   }
{   two parameters: mean (m) and variance (s2). It is shown as C ~ N(m, s2).   }
{   The distribution is symmetrical with mean, mode, and median all equal      }
{   at m. In the special case of m = 1 and s2 = 1, it is called the standard   }
{   normal distribution                                                        }
{                                                                              }
{   CumNormal returns the area under the N(u,s) distribution.                  }
{   CumNormal01 returns the area under the N(0,1) distribution.                }
{   InvCummNormal01 returns position on X-axis that gives cummulative area     }
{    of Y0 under the N(0,1) distribution.                                      }
{   InvCummNormal returns position on X-axis that gives cummulative area       }
{     of Y0 under the N(u,s) distribution.                                     }
{                                                                              }
FUNCTION  erf(x: real): real;
function  erfc(const x: Extended): Extended;
function  CummNormal(const u, s, X: Extended): Extended;
function  CummNormal01(const X: Extended): Extended;
function  InvCummNormal01(Y0: Extended): Extended;
function  InvCummNormal(const u, s, Y0: Extended): Extended;



{                                                                              }
{ Chi-Squared distribution                                                     }
{                                                                              }
{   The Chi-Squared is a distribution derived from the normal distribution.    }
{   It is the distribution of a sum of squared Normal distributed variables.   }
{   The importance of the Chi-square distribution stems from the fact that it  }
{   describes the distribution of the Variance of a sample taken from a        }
{   Normal distributed population. Chi-squared (C2) is distributed with v      }
{   degrees of freedom with mean = v and variance = 2v.                        }
{                                                                              }
{   CumChiSquare returns the area under the X^2 (Chi-squared) (Chi, Df)        }
{   distribution.                                                              }
{                                                                              }
function  CummChiSquare(const Chi, Df: Extended): Extended;



{                                                                              }
{ F distribution                                                               }
{                                                                              }
{   The F-distribution is a continuous probability distribution of the ratio   }
{   of two independent random variables, each having a Chi-squared             }
{   distribution, divided by their respective degrees of freedom. In           }
{   regression analysis, the F-test can be used to test the joint              }
{   significance of all variables of a model.                                  }
{   CumF returns the area under the F (f, Df1, Df2) distribution.              }
{                                                                              }
function  CumF(const f, Df1, Df2: Extended): Extended;



{                                                                              }
{ Poison distribution                                                          }
{                                                                              }
{   The Poisson distribution is the probability distribution of the number     }
{   of (rare) occurrences of some random event in an interval of time or       }
{   space. Poisson distribution is used to represent distribution of counts    }
{   like number of defects in a piece of material, customer arrivals,          }
{   insurance claims, incoming telephone calls, or alpha particles emitted.    }
{   A transformation that often changes Poisson data approximately normal is   }
{   the square root.                                                           }
{   CummPoison returns the area under the Poi(u)-distribution.                 }
{                                                                              }
{                                                                              }
function  CummPoisson(const X: Integer; const u: Extended): Extended;



{                                                                              }
{ TStatistic                                                                   }
{                                                                              }
{   Class that computes various descriptive statistics on a sample without     }
{   storing the sample values.                                                 }
{                                                                              }
{   To use, call one of the Add methods for every sample value. The values of  }
{   the descriptive statistics are available after every call to Add.          }
{                                                                              }
{   Statistics calculated:                                                     }
{   ---------------------                                                      }
{                                                                              }
{   Count is the number of sample values added.                                }
{                                                                              }
{   Sum is the sum of all sample values. SumOfSquares is the sum of the        }
{   squares of all sample values. Likewise SumOfCubes and SumOfQuads.          }
{                                                                              }
{   Min and Max are the minimum and maximum sample values. Range is the        }
{   difference between the maximum and minimum sample values.                  }
{                                                                              }
{   Mean (or average) is the sum of all data values divided by the number of   }
{   elements in the sample.                                                    }
{                                                                              }
{   Variance is a measure of the spread of a distribution about its mean and   }
{   is defined by var(X) = E([X - E(X)]2). The variance is expressed in the    }
{   squared unit of measurement of X.                                          }
{                                                                              }
{   Standard deviation is the square root of the variance and like variance    }
{   is a measure of variability or dispersion of a sample. Standard deviation  }
{   is expressed in the same unit of measurement as the sample values.         }
{   If a distribution's standard deviation is greater than its mean, the mean  }
{   is inadequate as a representative measure of central tendency. For         }
{   normally distributed data values, approximately 68% of the distribution    }
{   falls within ± 1 standard deviation of the mean and 95% of the             }
{   distribution falls within ± 2 standard deviations of the mean.             }
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
type
  TStatistic = class
  protected
    FCount        : Integer;
    FMin          : Extended;
    FMax          : Extended;
    FSum          : Extended;
    FSumOfSquares : Extended;
    FSumOfCubes   : Extended;
    FSumOfQuads   : Extended;

  public
    procedure Assign(const S: TStatistic);
    function  Duplicate: TStatistic;
    procedure Clear;
    function  IsEqual(const S: TStatistic): Boolean;

    procedure Add(const V: Extended); overload;
    procedure Add(const V: Array of Extended); overload;
    procedure Add(const V: TStatistic); overload;
    procedure AddNegated(const V: TStatistic);
    procedure Negate;

    property  Count: Integer read FCount;
    property  Min: Extended read FMin;
    property  Max: Extended read FMax;
    property  Sum: Extended read FSum;
    property  SumOfSquares: Extended read FSumOfSquares;
    property  SumOfCubes: Extended read FSumOfCubes;
    property  SumOfQuads: Extended read FSumOfQuads;

    function  Range: Extended;
    function  Mean: Extended;
    function  PopulationVariance: Extended;
    function  PopulationStdDev: Extended;
    function  Variance: Extended;
    function  StdDev: Extended;

    function  M1: Extended;
    function  M2: Extended;
    function  M3: Extended;
    function  M4: Extended;
    function  Skew: Extended;
    function  Kurtosis: Extended;

    function  GetAsString: String;
  end;
  EStatistic = class(EStatistics);
  EStatisticNoSample = class(EStatistic);
  EStatisticDivisionByZero = class(EStatistic);



implementation

uses
  { Delphi }
  Math,

  { Fundamentals }
  cUtils,
  cMaths;



{                                                                              }
{ Binomial distribution                                                        }
{                                                                              }
function BinomialCoeff(N, R: Integer): Extended;
var I, K : Integer;
begin
  if (N <= 0) or (R > N) then
    raise EStatisticsInvalidArgument.Create('BinomialCoeff: Invalid argument');
  if N > 1547 then
    raise EStatisticsOverflow.Create('BinomialCoeff: Overflow');
  Result := 1.0;
  if (R = 0) or (R = N) then
    exit;
  if R > N div 2 then
   R := N - R;
  K := 2;
  For I := N - R + 1 to N do
    begin
      Result := Result * I;
      if K <= R then
        begin
          Result := Result / K;
          Inc(K);
        end;
    end;
  Result := Int(Result + 0.5);
end;



{                                                                              }
{ gamma function, incomplete, series evaluation                                }
{ The gamma functions were translated from 'Numerical Recipes'.                }
{                                                                              }
procedure gser(const a, x: Extended; var gamser, gln: Extended);
const itmax = 100;
      eps   = 3.0e-7;
var n : Integer;
    sum, del, ap : Extended;
begin
  gln := GammaLn(a);
  if FloatZero(x, ExtendedCompareDelta) then
    begin
      GamSer := 0.0;
      exit;
    end;
  if X < 0.0 then
    raise EStatisticsInvalidArgument.Create('Gamma: GSER: Invalid argument');
  ap := a;
  sum := 1.0 / a;
  del := sum;
  for n := 1 to itmax do
    begin
      ap := ap + 1.0;
      del := del * x / ap;
      sum := sum + del;
      if abs(del) < abs(sum) * eps then
        begin
          GamSer := sum * exp(-x + a * ln(x) - gln);
          exit;
        end;
    end;
  raise EStatisticsOverflow.Create('Gamma: GSER: Overflow: ' +
      'Argument a is too large or itmax is too small');
end;

{ gamma function, incomplete, continued fraction evaluation                    }
procedure gcf(const a, x: Extended; var gammcf, gln: Extended);
const itmax = 100;
      eps   = 3.0e-7;
var n : integer;
    gold, g, fac, b1, b0, anf, ana, an, a1, a0 : Extended;
begin
  gln := GammaLn(a);
  gold := 0.0;
  g := 0.0;
  a0 := 1.0;
  a1 := x;
  b0 := 0.0;
  b1 := 1.0;
  fac := 1.0;
  For n := 1 to itmax do
    begin
      an := 1.0 * n;
      ana := an - a;
      a0 := (a1 + a0 * ana) * fac;
      b0 := (b1 + b0 * ana) * fac;
      anf := an * fac;
      a1 := x * a0 + anf * a1;
      b1 := x * b0 + anf * b1;
      if not FloatZero(a1, ExtendedCompareDelta) then
        begin
          fac := 1.0 / a1;
          g := b1 * fac;
          if abs((g - gold) / g) < eps then
            break;
          gold := g;
        end;
    end;
  Gammcf := exp(-x + a * ln(x) - gln) * g;
end;

{ GAMMP  gamma function, incomplete                                            }
function GammP(const a,x: Extended): Extended;
var gammcf, gln : Extended;
begin
  if (x < 0.0) or (a <= 0.0) then
    raise EStatisticsInvalidArgument.Create('Gamma: GAMMP: Invalid argument');
  if x < a + 1.0 then
    begin
      gser(a, x, gammcf, gln);
      gammp := gammcf
    end
  else
    begin
      gcf(a, x, gammcf, gln);
      gammp := 1.0 - gammcf
    end;
end;

{ GAMMQ  gamma function, incomplete, complementary                             }
function gammq(const a, x: Extended): Extended;
var gamser, gln : Extended;
begin
  if (x < 0.0) or (a <= 0.0) then
    raise EStatisticsInvalidArgument.Create('Gamma: GAMMQ: Invalid argument');
  if x < a + 1.0 then
    begin
      gser(a, x, gamser, gln);
      Result := 1.0 - gamser;
    end
  else
    begin
      gcf(a, x, gamser, gln);
      Result := gamser
    end;
end;

FUNCTION erf(x: real): real;
BEGIN
   IF (x < 0.0) THEN BEGIN
      erf := -gammp(0.5,sqr(x))
   END ELSE BEGIN
      erf := gammp(0.5,sqr(x))
   END
END;

{ error function, complementary                                                }
function erfc(const x: Extended): Extended;
begin
  if x < 0.0 then
    erfc := 1.0 + gammp(0.5, sqr(x))
  else
    erfc := gammq(0.5, sqr(x));
end;



{                                                                              }
{ BETACF  beta function, incomplete, continued fraction evaluation             }
{ The beta functions were translated from 'Numerical Recipes'.                 }
{                                                                              }
function betacf(const a, b, x: Extended): Extended;
const itmax = 100;
      eps   = 3.0e-7;
var tem, qap, qam, qab, em, d : Extended;
    bz, bpp, bp, bm, az, app  : Extended;
    am, aold, ap              : Extended;
    m                         : Integer;
begin
  am := 1.0;
  bm := 1.0;
  az := 1.0;
  qab := a + b;
  qap := a + 1.0;
  qam := a - 1.0;
  bz := 1.0 - qab * x / qap;
  For m := 1 to itmax do
    begin
      em := m;
      tem := em + em;
      d := em * (b - m) * x / ((qam + tem) * (a + tem));
      ap := az + d * am;
      bp := bz + d * bm;
      d := -(a + em) * (qab + em) * x / ((a + tem) * (qap + tem));
      app := ap + d * az;
      bpp := bp + d * bz;
      aold := az;
      am := ap / bpp;
      bm := bp / bpp;
      az := app / bpp;
      bz := 1.0;
      if abs(az - aold) < eps * abs(az) then
        begin
          Result := az;
          exit;
        end;
    end;
  raise EStatisticsOverflow.Create('Beta: BETACF: ' +
      'Argument a or b is too big or itmax is too small');
end;

{ BETAI  beta function, incomplete                                             }
function betai(const a, b, x: Extended): Extended;
var bt : Extended;
begin
  if (x < 0.0) or (x > 1.0) then
    raise EStatisticsInvalidArgument.Create('Beta: BETAI: Invalid argument');
  if FloatZero(x, ExtendedCompareDelta) or FloatOne(x, ExtendedCompareDelta) then
    bt := 0.0 else
    bt := exp(GammaLn(a + b) - GammaLn(a) - GammaLn(b) + a * ln(x) + b * ln(1.0 - x));
  if x < (a + 1.0) / (a + b + 2.0) then
    Result := bt * betacf(a, b, x) / a else
    Result := 1.0 - bt * betacf(b, a, 1.0 - x) / b;
end;



{                                                                              }
{ Normal distribution                                                          }
{                                                                              }
function CummNormal(const u, s, X: Extended): Extended;
begin
  CummNormal := erfc(((X - u) / s) / Sqrt2) / 2.0;
end;

function CummNormal01(const X: Extended): Extended;
begin
  CummNormal01 := erfc(X / Sqrt2) / 2.0;
end;



{                                                                   }
{ Returns the argument, x, for which the area under the             }
{ Gaussian probability density function (integrated from            }
{ minus infinity to x) is equal to y.                               }
{                                                                   }
{ For small arguments 0 < y < exp(-2), the program computes         }
{ z = sqrt( -2.0 * log(y) );  then the approximation is             }
{ x = z - log(z)/z  - (1/z) P(1/z) / Q(1/z).                        }
{ There are two rational functions P/Q, one for 0 < y < exp(-32)    }
{ and the other for y up to exp(-2).  For larger arguments,         }
{ w = y - 0.5, and  x/sqrt(2pi) = w + w**3 R(w**2)/S(w**2)).        }
{                                                                   }
{ Algorithm translated into Delphi by David Butler from Cephes C    }
{ library with persmission of Stephen L. Moshier                    }
{ <moshier@na-net.ornl.gov>.                                        }
{                                                                   }
function InvCummNormal01(Y0: Extended): Extended;
const P0 : Array[0..4] of Extended = (
           -5.99633501014107895267e1,
            9.80010754185999661536e1,
           -5.66762857469070293439e1,
            1.39312609387279679503e1,
           -1.23916583867381258016e0);
      Q0 : Array[0..8] of Extended = (
            1.00000000000000000000e0,
            1.95448858338141759834e0,
            4.67627912898881538453e0,
            8.63602421390890590575e1,
           -2.25462687854119370527e2,
            2.00260212380060660359e2,
           -8.20372256168333339912e1,
            1.59056225126211695515e1,
           -1.18331621121330003142e0);
      P1 : Array[0..8] of Extended = (
            4.05544892305962419923e0,
            3.15251094599893866154e1,
            5.71628192246421288162e1,
            4.40805073893200834700e1,
            1.46849561928858024014e1,
            2.18663306850790267539e0,
           -1.40256079171354495875e-1,
           -3.50424626827848203418e-2,
           -8.57456785154685413611e-4);
      Q1 : Array[0..8] of Extended = (
            1.00000000000000000000e0,
            1.57799883256466749731e1,
            4.53907635128879210584e1,
            4.13172038254672030440e1,
            1.50425385692907503408e1,
            2.50464946208309415979e0,
           -1.42182922854787788574e-1,
           -3.80806407691578277194e-2,
           -9.33259480895457427372e-4);
      P2 : Array[0..8] of Extended = (
            3.23774891776946035970e0,
            6.91522889068984211695e0,
            3.93881025292474443415e0,
            1.33303460815807542389e0,
            2.01485389549179081538e-1,
            1.23716634817820021358e-2,
            3.01581553508235416007e-4,
            2.65806974686737550832e-6,
            6.23974539184983293730e-9);
      Q2 : Array[0..8] of Extended = (
            1.00000000000000000000e0,
            6.02427039364742014255e0,
            3.67983563856160859403e0,
            1.37702099489081330271e0,
            2.16236993594496635890e-1,
            1.34204006088543189037e-2,
            3.28014464682127739104e-4,
            2.89247864745380683936e-6,
            6.79019408009981274425e-9);
var X, Z, Y2, X0, X1 : Extended;
    Code             : Boolean;
begin
  if (Y0 <= 0.0) or (Y0 >= 1.0) then
    EStatisticsInvalidArgument.Create('InvCummNormal01: Invalid argument');
  Code := True;
  if Y0 > 1.0 - ExpM2 then
    begin
      Y0 := 1.0 - Y0;
      Code := False;
    end;
  if Y0 > ExpM2 then
    begin
      Y0 := Y0 - 0.5;
      Y2 := Y0 * Y0;
      X := Y0 + Y0 * (Y2 * PolyEval(Y2, P0, 4) / PolyEval(Y2, Q0, 8));
      InvCummNormal01 := X * Sqrt2Pi;
    end
  else
    begin
      X := Sqrt(-2.0 * Ln(Y0));
      X0 := X - Ln(X) / X;
      Z := 1.0 / X;
      if X < 8.0 then
        X1 := Z * PolyEval(Z, P1, 8) / PolyEval(Z, Q1, 8) else
        X1 := Z * PolyEval(Z, P2, 8) / PolyEval(Z, Q2, 8);
      X := X0 - X1;
      if Code then
        X := -X;
      InvCummNormal01 := X;
    end;
end;

function InvCummNormal(const u, s, Y0: Extended): Extended;
begin
  InvCummNormal := InvCummNormal01(Y0) * s + u;
end;



{                                                                              }
{ Chi-Squared distribution                                                     }
{                                                                              }
function CummChiSquare(const Chi, Df: Extended): Extended;
begin
  CummChiSquare := 1.0 - gammq(0.5 * Df, 0.5 * Chi);
end;



{                                                                              }
{ F distribution                                                               }
{                                                                              }
function CumF(const f, Df1, Df2: Extended): Extended;
begin
  if F <= 0.0 then
    raise EStatisticsInvalidArgument.Create('CumF: Invalid argument');
  CumF := 1.0 - (betai(0.5 * df2, 0.5 * df1, df2 / (df2 + df1 * f))
       + (1.0 - betai(0.5 * df1, 0.5 * df2, df1 / (df1 + df2 / f)))) / 2.0;
end;



{                                                                              }
{ Poisson distribution                                                         }
{                                                                              }
function CummPoisson(const X: Integer; const u: Extended): Extended;
begin
  CummPoisson := GammQ(X + 1, u);
end;



{                                                                              }
{ TStatistic                                                                   }
{                                                                              }
const
  StatisticFloatDelta = ExtendedCompareDelta;

procedure TStatistic.Assign(const S: TStatistic);
begin
  Assert(Assigned(S), 'Assigned(S)');
  FCount := S.FCount;
  FMin := S.FMin;
  FMax := S.FMax;
  FSum := S.FSum;
  FSumOfSquares := S.FSumOfSquares;
  FSumOfCubes := S.FSumOfCubes;
  FSumOfQuads := S.FSumOfQuads;
end;

function TStatistic.Duplicate: TStatistic;
begin
  Result := TStatistic.Create;
  Result.Assign(self);
end;

procedure TStatistic.Clear;
begin
  FCount := 0;
  FMin := 0.0;
  FMax := 0.0;
  FSum := 0.0;
  FSumOfSquares := 0.0;
  FSumOfCubes := 0.0;
  FSumOfQuads := 0.0;
end;

function TStatistic.IsEqual(const S: TStatistic): Boolean;
begin
  Result :=
      Assigned(S) and
      (FCount = S.FCount) and
      (FMin = S.FMin) and
      (FMax = S.FMax) and
      (FSum = S.FSum) and
      (FSumOfSquares = S.FSumOfSquares) and
      (FSumOfCubes = S.FSumOfCubes) and
      (FSumOfQuads = S.FSumOfQuads);
end;

procedure TStatistic.Add(const V: Extended);
var A: Extended;
begin
  Inc(FCount);
  if FCount = 1 then
    begin
      FMin := V;
      FMax := V;
    end else
    begin
      if V < FMin then
        FMin := V else
        if V > FMax then
          FMax := V;
    end;
  FSum := FSum + V;
  A := Sqr(V);
  FSumOfSquares := FSumOfSquares + A;
  A := A * V;
  FSumOfCubes := FSumOfCubes + A;
  A := A * V;
  FSumOfQuads := FSumOfQuads + A;
end;

procedure TStatistic.Add(const V: Array of Extended);
var I : Integer;
begin
  For I := 0 to High(V) - 1 do
    Add(V[I]);
end;

// Add the sample values of V
procedure TStatistic.Add(const V: TStatistic);
begin
  if Assigned(V) and (V.FCount > 0) then
    begin
      Inc(FCount, V.FCount);
      if V.FMin < FMin then
        FMin := V.FMin;
      if V.FMax > FMax then
        FMax := V.FMax;
      FSum := FSum + V.FSum;
      FSumOfSquares := FSumOfSquares + V.FSumOfSquares;
      FSumOfCubes := FSumOfCubes + V.FSumOfCubes;
      FSumOfQuads := FSumOfQuads + V.FSumOfQuads;
    end;
end;

// Add the negated sample values of V
procedure TStatistic.AddNegated(const V: TStatistic);
begin
  if Assigned(V) and (V.FCount > 0) then
    begin
      Inc(FCount, V.FCount);
      if -V.FMax < FMin then
        FMin := -V.FMax;
      if -V.FMin > FMax then
        FMax := -V.FMin;
      FSum := FSum - V.FSum;
      FSumOfSquares := FSumOfSquares + V.FSumOfSquares;
      FSumOfCubes := FSumOfCubes - V.FSumOfCubes;
      FSumOfQuads := FSumOfQuads + V.FSumOfQuads;
    end;
end;

// Negate all sample values
procedure TStatistic.Negate;
var T: Extended;
begin
  if FCount > 0 then
    begin
      T := FMin;
      FMin := -FMax;
      FMax := -T;
      FSum := -FSum;
      FSumOfCubes := -FSumOfCubes;
      // FSumOfSquares and FSumOfQuads stay unchanged
    end;
end;

function TStatistic.Range: Extended;
begin
  if FCount > 0 then
    Result := FMax - FMin
  else
    Result := 0.0;
end;

function TStatistic.Mean: Extended;
begin
  if FCount = 0 then
    raise EStatisticNoSample.Create('No mean');
  Result := FSum / FCount
end;

function TStatistic.PopulationVariance: Extended;
begin
  if FCount > 0 then
    Result := (FSumOfSquares - Sqr(FSum) / FCount) / FCount
  else
    Result := 0.0;
end;

function TStatistic.PopulationStdDev: Extended;
begin
  Result := Sqrt(PopulationVariance);
end;

// Variance is an unbiased estimator of s^2 (as opposed to PopulationVariance
// which is biased)
function TStatistic.Variance: Extended;
begin
  if FCount > 1 then
    Result := (FSumOfSquares - Sqr(FSum) / FCount) / (FCount - 1)
  else
    Result := 0.0;
end;

function TStatistic.StdDev: Extended;
begin
  Result := Sqrt(Variance);
end;

function TStatistic.M1: Extended;
begin
  Result := FSum / (FCount + 1);
end;

function TStatistic.M2: Extended;
var NI, M1 : Extended;
begin
  NI := 1.0 / (FCount + 1);
  M1 := FSum * NI;
  Result := FSumOfSquares * NI - Sqr(M1);
end;

function TStatistic.M3: Extended;
var NI, M1 : Extended;
begin
  NI := 1.0 / (FCount + 1);
  M1 := FSum * NI;
  Result := FSumOfCubes * NI
          - M1 * 3.0 * FSumOfSquares * NI
          + 2.0 * Sqr(M1) * M1;
end;

function TStatistic.M4: Extended;
var NI, M1, M1Sqr : Extended;
begin
  NI := 1.0 / (FCount + 1);
  M1 := FSum * NI;
  M1Sqr := Sqr(M1);
  Result := FSumOfQuads * NI
          - M1 * 4.0 * FSumOfCubes * NI
          + M1Sqr * 6.0 * FSumOfSquares * NI
          - 3.0 * Sqr(M1Sqr);
end;

function TStatistic.Skew: Extended;
begin
  Result := M3 * Power(M2, -3/2);
end;

function TStatistic.Kurtosis: Extended;
var M2Sqr : Extended;
begin
  M2Sqr := Sqr(M2);
  if FloatZero(M2Sqr, StatisticFloatDelta) then
    raise EStatisticDivisionByZero.Create('Kurtosis: Division by zero');
  Result := M4 / M2Sqr;
end;

function TStatistic.GetAsString: String;
begin
  if Count > 0 then
    Result := 'n: ' + IntToStr(Count) +
              '  Sum: ' + FloatToStr(Sum) +
              '  Sum of squares: ' + FloatToStr(SumOfSquares) + #13#10 +
              'Sum of cubes: ' + FloatToStr(SumOfCubes) +
              '  Sum of quads: ' + FloatToStr(SumOfQuads) + #13#10 +
              'Min: ' + FloatToStr(Min) +
              '  Max: ' + FloatToStr(Max) +
              '  Range: ' + FloatToStr(Range) + #13#10 +
              'Mean: ' + FloatToStr(Mean) +
              '  Variance: ' + FloatToStr(Variance) +
              '  Std Dev: ' + FloatToStr(StdDev) + #13#10 +
              'M3: ' + FloatToStr(M3) +
              '  M4: ' + FloatToStr(M4) + #13#10 +
              'Skew: ' + FloatToStr(Skew) +
              '  Kurtosis: ' + FloatToStr(Kurtosis) + #13#10
  else
    Result := 'n: 0';
end;



end.

