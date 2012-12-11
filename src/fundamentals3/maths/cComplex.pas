{                                                                              }
{                           Complex numbers v3.05                              }
{                                                                              }
{             This unit is copyright © 1999-2003 by David J Butler             }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{                   Its original file name is cComplex.pas                     }
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
{ Revision history:                                                            }
{   1999/10/02  0.01  Added TComplex.                                          }
{   1999/11/21  0.02  Added TComplex.Power                                     }
{   2001/05/21  0.03  Moved TTRational and TTComplex from cExDataStructs.      }
{   2002/06/01  0.04  Created cComplex unit from cMaths.                       }
{   2003/02/16  3.05  Revised for Fundamentals 3.                              }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cComplex;

interface

uses
  { Delphi }
  SysUtils;



{                                                                              }
{ Complex numbers                                                              }
{   Class that represents a complex number (Real + i * Imag)                   }
{                                                                              }
type
  EComplex = class(Exception);
  TComplex = class
  private
    FReal,
    FImag  : Extended;

    function  GetAsString: String;
    procedure SetAsString(const S: String);

  public
    constructor Create(const TheRealPart: Extended = 0.0;
                const TheImaginaryPart: Extended = 0.0);

    property  RealPart: Extended read FReal write FReal;
    property  ImaginaryPart: Extended read FImag write FImag;

    property  AsString: String read GetAsString write SetAsString;

    procedure Assign(const C: TComplex); overload;
    procedure Assign(const V: Extended); overload;
    procedure AssignZero;
    procedure AssignI;
    procedure AssignMinI;

    function  Duplicate: TComplex;

    function  IsEqual(const C: TComplex): Boolean; overload;
    function  IsEqual(const R, I: Extended): Boolean; overload;
    function  IsReal: Boolean;
    function  IsZero: Boolean;
    function  IsI: Boolean;

    procedure Add(const C: TComplex); overload;
    procedure Add(const V: Extended); overload;
    procedure Subtract(const C: TComplex); overload;
    procedure Subtract(const V: Extended); overload;
    procedure Multiply(const C: TComplex); overload;
    procedure Multiply (Const V: Extended); overload;
    procedure MultiplyI;
    procedure MultiplyMinI;
    procedure Divide(const C: TComplex); overload;
    procedure Divide(const V: Extended); overload;
    procedure Negate;

    function  Modulo: Extended;
    function  Denom: Extended;
    procedure Conjugate;
    procedure Inverse;

    procedure Sqrt;
    procedure Exp;
    procedure Ln;
    procedure Sin;
    procedure Cos;
    procedure Tan;
    procedure Power(const C: TComplex);
  end;



implementation

uses
  { Delphi }
  Math,

  { Fundamentals }
  cUtils,
  cStrings,
  cMaths;



{                                                                              }
{ TComplex                                                                     }
{                                                                              }
constructor TComplex.Create(const TheRealPart, TheImaginaryPart: Extended);
begin
  inherited Create;
  FReal := TheRealPart;
  FImag := TheImaginaryPart;
end;

function TComplex.IsI: Boolean;
begin
  Result := FloatZero(FReal) and FloatOne(FImag);
end;

function TComplex.IsReal: Boolean;
begin
  Result := FloatZero(FImag);
end;

function TComplex.IsZero: Boolean;
begin
  Result := FloatZero(FReal) and FloatZero(FImag);
end;

function TComplex.IsEqual(const C: TComplex): Boolean;
begin
  Result := ApproxEqual(FReal, C.FReal) and
            ApproxEqual(FImag, C.FImag);
end;

function TComplex.IsEqual(const R, I: Extended): Boolean;
begin
  Result := ApproxEqual(FReal, R) and
            ApproxEqual(FImag, I);
end;

procedure TComplex.AssignZero;
begin
  FReal := 0.0;
  FImag := 0.0;
end;

procedure TComplex.AssignI;
begin
  FReal := 0.0;
  FImag := 1.0;
end;

procedure TComplex.AssignMinI;
begin
  FReal := 0.0;
  FImag := -1.0;
end;

procedure TComplex.Assign(const C: TComplex);
begin
  FReal := C.FReal;
  FImag := C.FImag;
end;

procedure TComplex.Assign(const V: Extended);
begin
  FReal := V;
  FImag := 0.0;
end;

function TComplex.Duplicate: TComplex;
begin
  Result := TComplex.Create(FReal, FImag);
end;

function TComplex.GetAsString: String;
var RZ, IZ : Boolean;
begin
  RZ := FloatZero(FReal);
  IZ := FloatZero(FImag);
  if IZ then
    Result := FloatToStr(FReal) else
    begin
      Result := Result + FloatToStr(FImag) + 'i';
      if not RZ then
        Result := Result + iif(Sgn(FReal) >= 0, '+', '-') + FloatToStr(Abs(FReal));
    end;
end;

procedure TComplex.SetAsString(const S: String);
var F, G, H : Integer;
begin
  F := Pos('(', S);
  G := Pos(',', S);
  H := Pos(')', S);
  if (F <> 1) or (H <> Length(S)) or (G < F) or (G > H) then
    raise EConvertError.Create('Can not convert string to complex number');
  FReal := StrToFloat(CopyRange(S, F + 1, G - 1));
  FImag := StrToFloat(CopyRange(S, G + 1, H - 1));
end;

procedure TComplex.Add(const C: TComplex);
begin
  FReal := FReal + C.FReal;
  FImag := FImag + C.FImag;
end;

procedure TComplex.Add(const V: Extended);
begin
  FReal := FReal + V;
end;

procedure TComplex.Subtract(const C: TComplex);
begin
  FReal := FReal - C.FReal;
  FImag := FImag - C.FImag;
end;

procedure TComplex.Subtract(const V: Extended);
begin
  FReal := FReal - V;
end;

procedure TComplex.Multiply(const C: TComplex);
var R, I : Extended;
begin
  R := FReal * C.FReal - FImag * C.FImag;
  I := FReal * C.FImag + FImag * C.FReal;
  FReal := R;
  FImag := I;
end;

procedure TComplex.Multiply(const V: Extended);
begin
  FReal := FReal * V;
  FImag := FImag * V;
end;

procedure TComplex.MultiplyI;
var R : Extended;
begin
  R := FReal;
  FReal := -FImag;
  FImag := R;
end;

procedure TComplex.MultiplyMinI;
var R : Extended;
begin
  R := FReal;
  FReal := FImag;
  FImag := -R;
end;

function TComplex.Denom: Extended;
begin
  Result := Sqr(FReal) + Sqr(FImag);
end;

procedure TComplex.Divide(const C: TComplex);
var R, D : Extended;
begin
  D := Denom;
  if FloatZero(D) then
    raise EDivByZero.Create('Complex division by zero') else
    begin
      R := FReal;
      FReal := (R * C.FReal + FImag * C.FImag) / D;
      FImag := (FImag * C.FReal - FReal * C.FImag) / D;
    end;
end;

procedure TComplex.Divide(const V: Extended);
var D : Extended;
begin
  D := Denom;
  if FloatZero(D) then
    raise EDivByZero.Create('Complex division by zero') else
    begin
      FReal := (FReal * V) / D;
      FImag := (FImag * V) / D;
    end;
end;

procedure TComplex.Negate;
begin
  FReal := -FReal;
  FImag := -FImag;
end;

procedure TComplex.Conjugate;
begin
  FImag := -FImag;
end;

procedure TComplex.Inverse;
var D : Extended;
begin
  D := Denom;
  if FloatZero(D) then
    raise EDivByZero.Create('Complex division by zero');
  FReal := FReal / D;
  FImag := - FImag / D;
end;

procedure TComplex.Exp;
var ExpZ : Extended;
    S, C : Extended;
begin
  ExpZ := System.Exp(FReal);
  SinCos(FImag, S, C);
  FReal := ExpZ * C;
  FImag := ExpZ * S;
end;

procedure TComplex.Ln;
var ModZ : Extended;
begin
  ModZ := Denom;
  if FloatZero(ModZ) then
    raise EDivByZero.Create('Complex log zero');
  FReal := System.Ln(ModZ);
  FImag := ArcTan2(FReal, FImag);
end;

procedure TComplex.Power(const C: TComplex);
begin
  if not IsZero then
    begin
      Ln;
      Multiply(C);
      Exp;
    end else
    if C.IsZero then
      Assign(1.0) else       { lim a^a = 1 as a-> 0 }
      AssignZero;            { 0^a = 0 for a <> 0   }
end;

function TComplex.Modulo: Extended;
begin
  Result := System.Sqrt(Denom);
end;

procedure TComplex.Sqrt;
var Root, Q : Extended;
begin
  if not FloatZero(FReal) or not FloatZero(FImag) then
    begin
      Root := System.Sqrt(0.5 * (Abs(FReal) + Modulo));
      Q := FImag / (2.0 * Root);
      if FReal >= 0.0 then
        begin
          FReal := Root;
          FImag := Q;
        end else
        if FImag < 0.0 then
          begin
            FReal := - Q;
            FImag := - Root;
          end else
          begin
            FReal := Q;
            FImag := Root;
          end;
    end else
    AssignZero;
end;

procedure TComplex.Cos;
begin
  FReal := System.Cos(FReal) * Cosh(FImag);
  FImag := -System.Sin(FReal) * Sinh(FImag);
end;

procedure TComplex.Sin;
begin
  FReal := System.Sin(FReal) * Cosh(FImag);
  FImag := -System.Cos(FReal) * Sinh(FImag);
end;

procedure TComplex.Tan;
var CCos : TComplex;
begin
  CCos := TComplex.Create(FReal, FImag);
  try
    CCos.Cos;
    if CCos.IsZero then
      raise EDivByZero.Create('Complex division by zero');
    self.Sin;
    self.Divide(CCos);
  finally
    CCos.Free;
  end;
end;



end.

