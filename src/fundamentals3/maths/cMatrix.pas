{                                                                              }
{                                Matrix 3.08                                   }
{                                                                              }
{             This unit is copyright © 1999-2003 by David J Butler             }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{                    Its original file name is cMatrix.pas                     }
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
{   1999/09/27  0.01  Added TMatrix, TVector.                                  }
{   1999/10/03  0.02  Improvements.                                            }
{   1999/11/27  0.03  Added TMatrix.Normalise, TMatrix.Multiply (Row, Value)   }
{   2000/10/03  0.04  Fixed bug in TMatrix.Transposed reported by Jingyi Peng  }
{                     <pengj@rotellacapital.com>                               }
{   2002/06/01  0.05  Created cMatrix unit from cMaths.                        }
{   2003/02/16  3.06  Revised for Fundamentals 3.                              }
{   2003/03/14  3.07  Improvements and documentation.                          }
{   2003/05/27  3.08  Fixed bug in SolveMatrix reported by Karl Hans           }
{                     <k.h.kaese@kaese-schulsoftware.de>.                      }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cMatrix;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cVectors;



{                                                                              }
{ Matrix                                                                       }
{                                                                              }
{   CreateIdentity(N) constructs a square matrix and places the unity vector   }
{   in the diagonal, ie the diagonal elements are all 1.0.                     }
{   CreateDiagonal(D) constructs a square matrix and places the elements of    }
{   vector D in the diagonal.                                                  }
{                                                                              }
{   SetSize changes the dimensions of the matrix.                              }
{   Clear resets the dimensions to 0 x 0.                                      }
{                                                                              }
{   AssignZero keeps the current dimensions, but sets all elements to zero.    }
{   AssignIdentity sets the diagional to 1's and the rest to 0's.              }
{                                                                              }
{   Trace is calculated as the sum of the diagonal.                            }
{                                                                              }
{   Transpose called on a square matrix returns a new copy of the matrix,      }
{   but with the rows swapped with the columns.                                }
{                                                                              }
{   Multiply(M) performs matrix multiplication. It returns a new matrix        }
{   with the result.                                                           }
{                                                                              }
{   Normalise(M) makes the diagonal 1's by multiplying each row with a         }
{   factor. M is optional, and if specified, all operations performed during   }
{   normalisation are also performed on M.                                     }
{                                                                              }
{   IsOrtogonal returns True if X'X = I, ie the transposed X, multiplied by X  }
{   is equal to the identity matrix.                                           }
{                                                                              }
{   IsIdempotent returns True if XX = X, ie the matrix is unaffected if        }
{   multiplied by itself.                                                      }
{                                                                              }
{   SolveMatrix returns the determinant.                                       }
{                                                                              }
{   Inverse sets the matrix to Y where XY = I, ie a matrix multiplied by its   }
{   inverse is equal to the identity matrix.                                   }
{                                                                              }
type
  TMatrix = class
  protected
    FColCount : Integer;
    FRows     : Array of ExtendedArray;

    procedure CheckValidRowIndex(const Row: Integer);
    procedure CheckValidColIndex(const Col: Integer);
    procedure CheckValidIndex(const Row, Col: Integer);
    procedure CheckSquare;
    procedure SizeMismatchError;

    function  GetRowCount: Integer;
    procedure SetRowCount(const NewRowCount: Integer);
    procedure SetColCount(const NewColCount: Integer);

    function  GetItem(const Row, Col: Integer): Extended;
    procedure SetItem(const Row, Col: Integer; const Value: Extended);

    function  GetAsString: String; virtual;

    procedure AddRows(const I, J: Integer; const Factor: Extended);
    procedure SwapRows(const I, J: Integer);

  public
    constructor CreateSize(const RowCount, ColCount: Integer);
    constructor CreateSquare(const N: Integer);
    constructor CreateIdentity(const N: Integer);
    constructor CreateDiagonal(const D: TVector);

    property  ColCount: Integer read FColCount write SetColCount;
    property  RowCount: Integer read GetRowCount write SetRowCount;
    procedure SetSize(const RowCount, ColCount: Integer);
    procedure Clear;

    property  Item[const Row, Col: Integer]: Extended read GetItem write SetItem; default;

    procedure AssignZero;
    procedure AssignIdentity;
    procedure Assign(const Value: Extended); overload;
    procedure Assign(const M: TMatrix); overload;
    procedure Assign(const V: TVector); overload;

    function  Duplicate: TMatrix; overload;
    function  DuplicateRange(const R1, C1, R2, C2: Integer): TMatrix; overload;
    function  DuplicateRow(const Row: Integer): TVector;
    function  DuplicateCol(const Col: Integer): TVector;
    function  DuplicateDiagonal: TVector;

    function  IsEqual(const M: TMatrix): Boolean; overload;
    function  IsEqual(const V: TVector): Boolean; overload;

    function  IsSquare: Boolean;
    function  IsZero: Boolean;
    function  IsIdentity: Boolean;

    property  AsString: String read GetAsString;
    function  Trace: Extended;

    procedure SetRow(const Row: Integer; const V: TVector); overload;
    procedure SetRow(const Row: Integer; const Values: Array of Extended); overload;
    procedure SetCol(const Col: Integer; const V: TVector);

    function  Transpose: TMatrix;
    procedure TransposeInPlace;

    procedure Add(const M: TMatrix);
    procedure Subtract(const M: TMatrix);
    procedure Negate;

    procedure MultiplyRow(const Row: Integer; const Value: Extended);
    procedure Multiply(const Value: Extended); overload;
    function  Multiply(const M: TMatrix): TMatrix; overload;
    procedure MultiplyInPlace(const M: TMatrix);

    function  IsOrtogonal: Boolean;
    function  IsIdempotent: Boolean;

    function  Normalise(const M: TMatrix = nil): Extended;
    function  SolveMatrix(var M: TMatrix): Extended;
    function  Determinant: Extended;
    function  Inverse: TMatrix;
    procedure InverseInPlace;
    function  SolveLinearSystem(const V: TVector): TVector;
  end;
  EMatrix = class(Exception);



{                                                                              }
{ Self testing code                                                            }
{                                                                              }
procedure SelfTest;



implementation



{                                                                              }
{ TMatrix                                                                      }
{                                                                              }
constructor TMatrix.CreateSize(const RowCount, ColCount: Integer);
begin
  inherited Create;
  SetSize(RowCount, ColCount);
end;

constructor TMatrix.CreateSquare(const N: Integer);
begin
  inherited Create;
  SetSize(N, N);
end;

constructor TMatrix.CreateIdentity(const N: Integer);
var I : Integer;
begin
  inherited Create;
  SetSize(N, N);
  For I := 0 to N - 1 do
    FRows[I, I] := 1.0;
end;

constructor TMatrix.CreateDiagonal(const D: TVector);
var I, N : Integer;
begin
  inherited Create;
  Assert(Assigned(D), 'Assigned(D)');
  N := D.Count;
  SetSize(N, N);
  For I := 0 to N - 1 do
    FRows[I, I] := D.Data[I];
end;

procedure TMatrix.CheckValidRowIndex(const Row: Integer);
begin
  if (Row < 0) or (Row >= Length(FRows)) then
    raise EMatrix.Create('Matrix index out of bounds');
end;

procedure TMatrix.CheckValidColIndex(const Col: Integer);
begin
  if (Col < 0) or (Col >= FColCount) then
    raise EMatrix.Create('Matrix index out of bounds');
end;

procedure TMatrix.CheckValidIndex(const Row, Col: Integer);
begin
  if (Row < 0) or (Row >= Length(FRows)) or
     (Col < 0) or (Col >= FColCount) then
    raise EMatrix.Create('Matrix index out of bounds');
end;

procedure TMatrix.CheckSquare;
begin
  if not IsSquare then
    raise EMatrix.Create('Not a square matrix');
end;

procedure TMatrix.SizeMismatchError;
begin
  raise EMatrix.Create('Matrix size mismatch');
end;

function TMatrix.GetRowCount: Integer;
begin
  Result := Length(FRows);
end;

procedure TMatrix.SetRowCount(const NewRowCount: Integer);
var I, N, P : Integer;
begin
  P := Length(FRows);
  N := NewRowCount;
  if N < 0 then
    N := 0;
  if P = N then
    exit;
  // Resize
  SetLength(FRows, N);
  For I := P to N - 1 do
    SetLengthAndZero(FRows[I], FColCount);
end;

procedure TMatrix.SetColCount(const NewColCount: Integer);
var I, N : Integer;
begin
  N := NewColCount;
  if N < 0 then
    N := 0;
  if FColCount = N then
    exit;
  // Resize
  For I := 0 to Length(FRows) - 1 do
    SetLengthAndZero(FRows[I], N);
  FColCount := N;
end;

procedure TMatrix.SetSize(const RowCount, ColCount: Integer);
begin
  SetRowCount(RowCount);
  SetColCount(ColCount);
end;

procedure TMatrix.Clear;
begin
  SetSize(0, 0);
end;

function TMatrix.GetItem(const Row, Col: Integer): Extended;
begin
  CheckValidIndex(Row, Col);
  Result := FRows[Row, Col];
end;

procedure TMatrix.SetItem(const Row, Col: Integer; const Value: Extended);
begin
  CheckValidIndex(Row, Col);
  FRows[Row, Col] := Value;
end;

procedure TMatrix.AssignZero;
var I : Integer;
begin
  if FColCount = 0 then
    exit;
  For I := 0 to Length(FRows) - 1 do
    FillChar(FRows[I, 0], FColCount * Sizeof(Extended), #0);
end;

procedure TMatrix.AssignIdentity;
var I, N : Integer;
begin
  CheckSquare;
  N := Length(FRows);
  if N = 0 then
    exit;
  AssignZero;
  For I := 0 to N - 1 do
    FRows[I, I] := 1.0;
end;

procedure TMatrix.Assign(const Value: Extended);
var I, J : Integer;
begin
  For I := 0 to Length(FRows) - 1 do
    For J := 0 to FColCount - 1 do
      FRows[I, J] := Value;
end;

procedure TMatrix.Assign(const M: TMatrix);
var I : Integer;
begin
  Assert(Assigned(M), 'Assigned(M)');
  SetSize(M.RowCount, M.ColCount);
  if FColCount = 0 then
    exit;
  For I := 0 to Length(FRows) - 1 do
    FRows[I] := Copy(M.FRows[I]);
end;

procedure TMatrix.Assign(const V: TVector);
var N: Integer;
begin
  Assert(Assigned(V), 'Assigned(V)');
  N := V.Count;
  SetSize(1, N);
  if N = 0 then
    exit;
  FRows[0] := Copy(V.Data, 0, N - 1);
end;

function TMatrix.Duplicate: TMatrix;
begin
  Result := TMatrix.Create;
  try
    Result.Assign(self);
  except
    Result.Free;
    raise;
  end;
end;

function TMatrix.DuplicateRange(const R1, C1, R2, C2: Integer): TMatrix;
var I, T, L, B, R, W : Integer;
begin
  Result := TMatrix.Create;
  try
    T := MaxI(R1, 0);
    B := MinI(R2, Length(FRows));
    L := MaxI(C1, 0);
    R := MinI(C2, FColCount);
    if (T > B) or (L > R) then // range has no size
      exit;
    W := R - L + 1;
    Result.SetSize(B - T + 1, W);
    For I := T to B do
      Result.FRows[I - T] := Copy(FRows[I], L, W);
  except
    Result.Free;
    raise;
  end;
end;

function TMatrix.DuplicateRow(const Row: Integer): TVector;
begin
  CheckValidRowIndex(Row);
  Result := TVector.Create(Copy(FRows[Row]));
end;

function TMatrix.DuplicateCol(const Col: Integer): TVector;
var I, N : Integer;
begin
  CheckValidColIndex(Col);
  Result := TVector.Create;
  try
    N := Length(FRows);
    Result.Count := N;
    For I := 0 to N - 1 do
      Result.Data[I] := FRows[I, Col];
  except
    Result.Free;
    raise;
  end;
end;

function TMatrix.DuplicateDiagonal: TVector;
var I, N : Integer;
begin
  CheckSquare;
  Result := TVector.Create;
  try
    N := Length(FRows);
    Result.Count := N;
    For I := 0 to N - 1 do
      Result.Data[I] := FRows[I, I];
  except
    Result.Free;
    raise;
  end;
end;

function TMatrix.IsEqual(const M: TMatrix): Boolean;
var I, J : Integer;
begin
  Assert(Assigned(M), 'Assigned(M)');
  if (Length(FRows) <> Length(M.FRows)) or (FColCount <> M.FColCount) then
    begin
      Result := False;
      exit;
    end;
  For I := 0 to Length(FRows) - 1 do
    For J := 0 to FColCount - 1 do
      if not ApproxEqual(FRows[I, J], M.FRows[I, J]) then
        begin
          Result := False;
          exit;
        end;
  Result := True;
end;

function TMatrix.IsEqual(const V: TVector): Boolean;
var I : Integer;
begin
  Assert(Assigned(V), 'Assigned(V)');
  if (Length(FRows) <> 1) or (V.Count <> FColCount) then
    begin
      Result := False;
      exit;
    end;
  For I := 0 to FColCount - 1 do
    if not ApproxEqual(V.Data[I], FRows[0, I]) then
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;

function TMatrix.IsSquare: Boolean;
begin
  Result := Length(FRows) = FColCount;
end;

function TMatrix.IsZero: Boolean;
var I, J : Integer;
begin
  For I := 0 to Length(FRows) - 1 do
    For J := 0 to FColCount - 1 do
      if not FloatZero(FRows[I, J]) then
        begin
          Result := False;
          exit;
        end;
  Result := True;
end;

function TMatrix.IsIdentity: Boolean;
var I, J : Integer;
    R    : Extended;
begin
  if not IsSquare then
    begin
      Result := False;
      exit;
    end;
  For I := 0 to Length(FRows) - 1 do
    For J := 0 to FColCount - 1 do
      begin
        R := FRows[I, J];
        if ((J = I) and not ApproxEqual(R, 1.0)) or
           ((J <> I) and not FloatZero(R)) then
          begin
            Result := False;
            exit;
          end;
      end;
  Result := True;
end;

function TMatrix.GetAsString: String;
var I, J, R : Integer;
begin
  Result := '(';
  R := Length(FRows);
  For I := 0 to R - 1 do
    begin
      Result := Result + '(';
      For J := 0 to FColCount - 1 do
        begin
          Result := Result + FloatToStr(FRows[I, J]);
          if J < FColCount - 1 then
            Result := Result + ',';
        end;
      Result := Result + ')';
      if I < R - 1 then
        Result := Result + ',';
    end;
  Result := Result + ')';
end;

function TMatrix.Trace: Extended;
var I : Integer;
begin
  CheckSquare;
  Result := 0.0;
  For I := 0 to Length(FRows) - 1 do
    Result := Result + FRows[I, I];
end;

procedure TMatrix.SetRow(const Row: Integer; const V: TVector);
begin
  CheckValidRowIndex(Row);
  Assert(Assigned(V), 'Assigned(V)');
  if FColCount <> V.Count then
    SizeMismatchError;
  FRows[Row] := Copy(V.Data, 0, FColCount - 1);
end;

procedure TMatrix.SetRow(const Row: Integer; const Values: Array of Extended);
var I : Integer;
begin
  CheckValidRowIndex(Row);
  if FColCount <> Length(Values) then
    SizeMismatchError;
  For I := 0 to FColCount - 1 do
    FRows[Row, I] := Values[I];
end;

procedure TMatrix.SetCol(const Col: Integer; const V: TVector);
var I, N : Integer;
begin
  CheckValidColIndex(Col);
  Assert(Assigned(V), 'Assigned(V)');
  N := Length(FRows);
  if N <> V.Count then
    SizeMismatchError;
  For I := 0 to N - 1 do
    FRows[I, Col] := V.Data[I];
end;

function TMatrix.Transpose: TMatrix;
var I, J : Integer;
begin
  Result := TMatrix.CreateSize(FColCount, Length(FRows));
  try
    For I := 0 to FColCount - 1 do
      For J := 0 to Length(FRows) - 1 do
        Result.FRows[I, J] := FRows[J, I];
  except
    Result.Free;
    raise;
  end;
end;

procedure TMatrix.TransposeInPlace;
var M : TMatrix;
begin
  M := Transpose;
  try
    FColCount := M.FColCount;
    FRows := M.FRows;
  finally
    M.Free;
  end;
end;

procedure TMatrix.Add(const M: TMatrix);
var R, C, I, J : Integer;
    P, Q       : PExtended;
begin
  Assert(Assigned(M), 'Assigned(M)');
  R := Length(FRows);
  C := FColCount;
  if (M.RowCount <> R) or (M.ColCount <> C) then
    SizeMismatchError;
  if C = 0 then
    exit;
  For I := 0 to R - 1 do
    begin
      P := @FRows[I, 0];
      Q := @M.FRows[I, 0];
      For J := 0 to C - 1 do
        begin
          P^ := P^ + Q^;
          Inc(P);
          Inc(Q);
        end;
    end;
end;

procedure TMatrix.Subtract(const M: TMatrix);
var R, C, I, J : Integer;
    P, Q       : PExtended;
begin
  Assert(Assigned(M), 'Assigned(M)');
  R := Length(FRows);
  C := FColCount;
  if (M.RowCount <> R) or (M.ColCount <> C) then
    SizeMismatchError;
  if C = 0 then
    exit;
  For I := 0 to R - 1 do
    begin
      P := @FRows[I, 0];
      Q := @M.FRows[I, 0];
      For J := 0 to C - 1 do
        begin
          P^ := P^ - Q^;
          Inc(P);
          Inc(Q);
        end;
    end;
end;

procedure TMatrix.Negate;
var I, J, C : Integer;
    P       : PExtended;
begin
  C := FColCount;
  if C = 0 then
    exit;
  For I := 0 to Length(FRows) - 1 do
    begin
      P := @FRows[I, 0];
      For J := 0 to C - 1 do
        begin
          P^ := -P^;
          Inc(P);
        end;
    end;
end;

procedure TMatrix.MultiplyRow(const Row: Integer; const Value: Extended);
var I, C : Integer;
    P    : PExtended;
begin
  CheckValidRowIndex(Row);
  C := FColCount;
  if C = 0 then
    exit;
  P := @FRows[Row, 0];
  For I := 0 to C - 1 do
    begin
      P^ := P^ * Value;
      Inc(P);
    end;
end;

procedure TMatrix.Multiply(const Value: Extended);
var I : Integer;
begin
  For I := 0 to Length(FRows) - 1 do
    MultiplyRow(I, Value);
end;

function TMatrix.Multiply(const M: TMatrix): TMatrix;
var I, J, K : Integer;
    C, R, D : Integer;
    A       : Extended;
    P, Q    : PExtended;
begin
  Assert(Assigned(M), 'Assigned(M)');
  C := FColCount;
  if C <> M.RowCount then
    SizeMismatchError;
  R := Length(FRows);
  D := M.ColCount;
  Result := TMatrix.CreateSize(R, D);
  try
    if (C = 0) or (D = 0) then
      exit;
    For I := 0 to R - 1 do
      begin
        Q := @Result.FRows[I, 0];
        For J := 0 to D - 1 do
          begin
            A := 0.0;
            P := @FRows[I, 0];
            For K := 0 to C - 1 do
              begin
                A := A + P^ * M.FRows[K, J];
                Inc(P);
              end;
            Q^ := A;
            Inc(Q);
          end;
      end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TMatrix.MultiplyInPlace(const M: TMatrix);
var R : TMatrix;
begin
  Assert(Assigned(M), 'Assigned(M)');
  R := Multiply(M);
  try
    FColCount := R.FColCount;
    FRows := R.FRows;
  finally
    R.Free;
  end;
end;

function TMatrix.IsOrtogonal: Boolean;
var M : TMatrix;
begin
  M := Transpose;
  try
    M.MultiplyInPlace(self);
    Result := M.IsIdentity;
  finally
    M.Free;
  end;
end;

function TMatrix.IsIdempotent: Boolean;
var M : TMatrix;
begin
  M := Multiply(self);
  try
    Result := M.IsEqual(self);
  finally
    M.Free;
  end;
end;

function TMatrix.Normalise(const M: TMatrix): Extended;
var I : Integer;
    R : Extended;
begin
  CheckSquare;
  Result := 1.0;
  For I := 0 to Length(FRows) - 1 do
    begin
      R := FRows[I, I];
      Result := Result * R;
      if not FloatZero(R) then
        begin
          R := 1.0 / R;
          MultiplyRow(I, R);
          if Assigned(M) then
            M.MultiplyRow(I, R);
        end;
    end;
end;

procedure TMatrix.AddRows(const I, J: Integer; const Factor: Extended);
var F, C : Integer;
    P, Q : PExtended;
begin
  CheckValidRowIndex(I);
  CheckValidRowIndex(J);
  C := FColCount;
  if C = 0 then
    exit;
  P := @FRows[I, 0];
  Q := @FRows[J, 0];
  For F := 0 to C - 1 do
    begin
      P^ := P^ + Q^ * Factor;
      Inc(P);
      Inc(Q);
    end;
end;

procedure TMatrix.SwapRows(const I, J: Integer);
var P : ExtendedArray;
begin
  CheckValidRowIndex(I);
  CheckValidRowIndex(J);
  // Swap row references
  P := FRows[I];
  FRows[I] := FRows[J];
  FRows[J] := P;
end;

function TMatrix.SolveMatrix(var M: TMatrix): Extended;
var I, J, L : Integer;
    E, D    : Extended;
    P       : PExtended;
begin
  Assert(Assigned(M), 'Assigned(M)');
  Assert(IsSquare, 'IsSquare');
  Result := 1.0;
  L := Length(FRows);
  For I := 0 to L - 1 do
    begin
      J := I;
      P := @FRows[I, 0];
      While J < L do
        if not FloatZero(P^) then
          break
        else
          begin
            Inc(J);
            Inc(P);
          end;
      if J = L then
        begin
          Result := 0.0;
          exit;
        end;
      if J <> I then
        begin
          SwapRows(I, J);
          Result := -Result;
          M.SwapRows(I, J);
        end;
      D := FRows[I, I];
      For J := I + 1 to L - 1 do
        begin
          E := -(FRows[J, I] / D);
          AddRows(J, I, E);
          M.AddRows(J, I, E);
        end;
    end;
  For I := L - 1 downto 0 do
    begin
      D := FRows[I, I];
      For J := I - 1 downto 0 do
        begin
          E := -(FRows[J, I] / D);
          AddRows(J, I, E);
          M.AddRows(J, I, E);
        end;
    end;
  Result := Result * Normalise(M);
end;

function TMatrix.Determinant: Extended;
var A, B : TMatrix;
begin
  CheckSquare;
  A := Duplicate;
  try
    B := TMatrix.CreateIdentity(Length(FRows));
    try
      Result := A.SolveMatrix(B);
    finally
      B.Free;
    end;
  finally
    A.Free;
  end;
end;

function TMatrix.Inverse: TMatrix;
var R : Integer;
begin
  CheckSquare;
  R := Length(FRows);
  Result := TMatrix.CreateIdentity(R);
  try
    if SolveMatrix(Result) = 0.0 then
      raise EMatrix.Create('Matrix can not invert');
  except
    Result.Free;
    raise;
  end;
end;

procedure TMatrix.InverseInPlace;
var A : TMatrix;
begin
  A := Inverse;
  try
    FColCount := A.FColCount;
    FRows := A.FRows;
  finally
    A.Free;
  end;
end;

function TMatrix.SolveLinearSystem(const V: TVector): TVector;
var C, M : TMatrix;
begin
  Assert(Assigned(V), 'Assigned(V)');
  if not IsSquare or (V.Count <> Length(FRows)) then
    raise EMatrix.Create('Not a linear system');
  Result := nil;
  C := Duplicate;
  try
    M := TMatrix.Create;
    try
      M.Assign(V);
      if C.SolveMatrix(M) = 0.0 then
        raise EMatrix.Create('Can not solve this system');
      Result := M.DuplicateRow(0);
    finally
      M.Free;
    end;
  finally
    C.Free;
  end;
end;



{                                                                              }
{ Self testing code                                                            }
{                                                                              }
procedure SelfTest;
begin
end;



end.

