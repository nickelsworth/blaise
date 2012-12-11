{                                                                              }
{ Blaise test cases                                                            }
{                                                                              }

Program BlaiseSelfTest;

{ Comment spanning across
  lines }

(* Comment spanning across
   lines *)

uses
  BlaiseTestUnit,
  BlaiseTestUnit2;

var
  Error : Boolean = False;

procedure Assert(const Condition: Boolean; const Msg: String);
begin
  if not Condition then
    begin
      Error := True;
      Writeln('Error: ' + Msg);
    end;
end;

procedure TestLexer;
begin
  Assert(0 = 0, 'Number');
  Assert(0 <> 1, 'Number');
  
  Assert($0 = 0, 'Hex');
  Assert($1 = 1, 'Hex');
  Assert($5A = 90, 'Hex');
  Assert($A5 = 165, 'Hex');
  Assert($FF = 255, 'Hex');
  Assert($FFA5 = 65445, 'Hex');

  Assert(0x0 = 0, 'Hex');
  Assert(0x1 = 1, 'Hex');
  Assert(0x5A = 90, 'Hex');
  Assert(0x0A5 = 165, 'Hex');
  Assert(0xFF = 255, 'Hex');
  Assert(0xFFA5 = 65445, 'Hex');
  Assert(0XFFA5 = 65445, 'Hex');

  Assert(1.2e3 = 1200, 'SciReal');
  Assert(1.2e+2 = 120, 'SciReal');
  Assert(1.2e-2 = 0.012, 'SciReal');

  Assert(0b0 = 0, 'Binary');
  Assert(0b1 = 1, 'Binary');
  Assert(0b01 = 1, 'Binary');
  Assert(0b10 = 2, 'Binary');
  Assert(0b11 = 3, 'Binary');
  Assert(0b011 = 3, 'Binary');
  Assert(0b110 = 6, 'Binary');
  Assert(0b111 = 7, 'Binary');
  Assert(0B111 = 7, 'Binary');
  Assert(0b1111111111111111111111111111 = $0FFFFFFF, 'Binary');

  Assert(#65 = 'A', 'String');
  Assert('X'#65 = 'XA', 'String');
  Assert('X'#65'Y' = 'XAY', 'String');
  Assert('X'#65#66'Y' = 'XABY', 'String');
  Assert('A''B' = 'A'#39'B', 'String');
end;

procedure TestSimpleTypes;
var
  A, B : Integer;
  C, D : Float;
  E, F : String;
  G, H : Boolean;
  I    : URL;
begin
  Assert(2 = 2,            'Int Compare');
  Assert(1 < 2,            'Int Compare');
  Assert(2 > 1,            'Int Compare');
  Assert(2 <= 3,           'Int Compare');
  Assert(2 <= 2,           'Int Compare');
  Assert(2 <> 3,           'Int Compare');
  Assert(3 >= 2,           'Int Compare');
  Assert(3 >= 3,           'Int Compare');

  Assert(1.2 < 2.3,        'Float Compare');
  Assert(2.3 > 1.2,        'Float Compare');
  Assert(1.0 = 1,          'Float Compare Int');
  Assert(1.1 <> 1,         'Float Compare Int');

  Assert('AB' = 'AB',      'String Compare');
  Assert('AB' < 'AC',      'String Compare');
  Assert('BA' > 'AB',      'String Compare');
  Assert('AC' <> 'AB',     'String Compare');

  Assert(True,                   'Boolean');
  Assert(not False,              'Boolean');
  Assert(True or True,           'Boolean Logical Or');
  Assert(False or True,          'Boolean Logical Or');
  Assert(True or False,          'Boolean Logical Or');
  Assert(not (False or False),   'Boolean Logical Or');
  Assert(True and True,          'Boolean Logical And');
  Assert(not (True and False),   'Boolean Logical And');
  Assert(not (False and True),   'Boolean Logical And');
  Assert(not (False and False),  'Boolean Logical And');
  Assert(False xor True,         'Boolean Logical Xor');
  Assert(True xor False,         'Boolean Logical Xor');
  Assert(not (False xor False),  'Boolean Logical Xor');
  Assert(not (True xor True),    'Boolean Logical Xor');

  Assert(1 + 1 = 2,        'Int Add Int');
  Assert(1.1 + 2 = 3.1,    'Float Add Int');
  Assert(1 + 2.1 = 3.1,    'Int Add Float');
  Assert(1.1 + 2.1 = 3.2,  'Float Add Float');
  Assert('1' + '2' = '12', 'String Add String');

  Assert(1 - 1 = 0,        'Int Subtract Int');
  Assert(2.0 - 1.0 = 1.0,  'Float Subtract Float');
  Assert(2.1 - 1.1 = 1.0,  'Float Subtract Float');

  Assert(2 * 3 = 6,        'Int Multiply Int');
  Assert(2.1 * 3.1 = 6.51, 'Float Multiply Float');
  Assert(2 * 3.1 = 6.2,    'Int Multiply Float');
  Assert(3.1 * 2 = 6.2,    'Float Multiply Int');

  Assert(6 / 2 = 3,        'Int Divide Int = Int');
  Assert(6.51 / 3.1 = 2.1, 'Float Divide Float');
  Assert(1 / 2 = 0.5,      'Int Divide Int = Float');
  Assert(1 / 2.5 = 0.4,    'Int Divide Float');

  Assert(4 div 2 = 2,      'Int Div');
  Assert(5 div 2 = 2,      'Int Div');
  Assert(4 mod 2 = 0,      'Int Mod');
  Assert(5 mod 2 = 1,      'Int Mod');

  Assert(1 shl 2 = 4,      'Int Shl');
  Assert(0 shl 2 = 0,      'Int Shl');
  Assert(4 shr 2 = 1,      'Int Shr');
  Assert(4 shr 3 = 0,      'Int Shr');
  Assert(2 and 3 = 2,      'Int And');
  Assert(2 or 3 = 3,       'Int Or');
  Assert(2 xor 3 = 1,      'Int Xor');

  Assert(Sqr(3) = 9,       'Int Sqr');
  Assert(Sqrt(9) = 3,      'Int Sqrt');
  Assert(Exp(Ln(9)) = 9,   'Exp / Ln');

  Assert(2**3 = 8,         'Power');
  Assert(3**0 = 1,         'Power');
  Assert(4**-1 = 0.25,     'Power Neg');
  Assert(2**-2 = 0.25,     'Power Neg');
  Assert(4**0.5 = 2,       'Power Float');

  I := 'http://www.w3.net/index.html';
  Assert(I.Protocol = 'http', 'URL');
  Assert(I.Host = 'www.w3.net', 'URL');
  Assert(I.Path = '/index.html', 'URL');
  I.Host := 'www.w3.org';
  Assert(I = 'http://www.w3.org/index.html', 'URL');
end;

procedure TestRangeTypes;
var A : Range 1..100;
    B : (v1, v2, v3=5, v4=7, v5);
begin
  Assert(A = 1, 'Range');
  A := 5;
  Assert(A = 5, 'Range');

  Assert(B = v1, 'Enum');
  Assert(B = 0, 'Enum');
  Assert(v1 = 0, 'Enum');
  Assert(v2 = 1, 'Enum');
  Assert(v3 = 5, 'Enum');
  Assert(v4 = 7, 'Enum');
  Assert(v5 = 8, 'Enum');
  B := v2;
  Assert(B = v2, 'Enum');
  Assert(B = 1, 'Enum');
  B := 7;
  Assert(B = v4, 'Enum');
  Assert(B = 7, 'Enum');
end;

procedure TestStatistic;
var A, B : Statistic;
begin
  Assert(A.Count = 0, 'Count');
  A.Add(1.5);
  Assert(A.Count = 1, 'Count');
  Assert(A.Sum = 1.5, 'Sum');
  Assert(A.Range = 0, 'Range');
  Assert(A.Mean = 1.5, 'Mean');
  Assert(A.Variance = 0, 'Variance');
  Assert(A.Skew = 0, 'Skew');
  Assert(A.Kurtosis = 1, 'Kurtosis');

  B := A - 0.2;
  Assert(A.Count = 1, 'Count');
  Assert(B.Count = 2, 'Count');
  Assert(B.Sum = 1.3, 'Sum');
  Assert(B.SumOfCubes = 3.367, 'SumOfCubes');
  Assert(B.Range = 1.7, 'Range');
  Assert(B.Min = -0.2, 'Min');
  Assert(B.Mean = 0.65, 'Mean');
  Assert(B.Variance = 1.445, 'Variance');
  Assert(B.Kurtosis = 1.5, 'Kurtosis');

  A.Clear;
  Assert(A.Count = 0, 'Count');
end;

procedure TestArray;
var A : Array;
    B : Array of Integer;
    C : Array of Array of String;
begin
  Assert(A.Count = 0, 'Count');
  A.Append('X');
  Assert(A.Count = 1, 'Append');
  Assert(A[0] = 'X', 'GetItem');
  A[0] := 'Y';
  Assert(A.Count = 1, 'SetItem');
  Assert(A[0] = 'Y', 'SetItem');
  A.Append(5);
  Assert(A.Count = 2, 'Append');
  Assert(A[0] = 'Y', 'Append');
  Assert(A[1] = 5, 'Append');

  Assert(B.Count = 0, 'Count');
  B.Append(6);
  Assert(B.Count = 1, 'Append');
  Assert(B[0] = 6, 'GetItem');
  B[0] := 7;
  Assert(B.Count = 1, 'SetItem');
  Assert(B[0] = 7, 'SetItem');
  B.Append(3);
  Assert(B.Count = 2, 'Append');
  Assert(B[0] = 7, 'Append');
  Assert(B[1] = 3, 'Append');
  B.Count := 3;
  Assert(B.Count = 3, 'SetCount');
  Assert(B[2] = 0, 'SetCount');
  Assert(B[<0] = 0, 'GetItem'); 
  Assert(B[<-1] = 3, 'GetItem');
  Assert(B[<-2] = 7, 'GetItem');

  Assert(C.Count = 0, 'Count');
  C.Count := 1;
  Assert(C.Count = 1, 'Count');
  Assert(C[0].Count = 0, 'Count');
  C[0].Count := 1;
  Assert(C[0].Count = 1, 'Count');
  Assert(C[0][0] = '', 'GetItem');
  C[0][0] := 'A';
  Assert(C[0][0] = 'A', 'SetItem'); 
  Assert(C[0,0] = 'A', 'GetItem'); 
end;

procedure TestDictionary;
var A : Dictionary;
    B : Dictionary of Integer;
    C : Dictionary[String];
begin
  A['X'] := 1;
  Assert(A['X'] = 1, 'GetItem'); 
  A[2] := 3;
  Assert(A[2] = 3, 'GetItem');

  B['X'] := 1;
  Assert(B['X'] = 1, 'GetItem');

  C['X'] := 'A';
  Assert(C['X'] = 'A', 'GetItem');
end;

procedure TestExpressions;
begin
  Assert(if 1 = 1 then True else False, 'iif');
  Assert((if 1 = 1 then 2 else 1) = 2, 'iif');
  Assert((if 1 <> 1 then 2 else 1) = 1, 'iif');
  Assert((if True then 2 else 1) = 2, 'iif');
  Assert((if False then 2 else 1) = 1, 'iif');
  Assert(not (if True then False else True), 'iif');

  Assert((x := 1) = 1, 'assign');
  Assert(x = 1, 'assign');
  Assert((x := 1) <> 0, 'assign');
  Assert((x := 1 + 1) = 2, 'assign');
  Assert(x = 2, 'assign');
  Assert((y := (x := 1 + 1) + 1) = 3, 'assign');
  Assert(x = 2, 'assign');
  Assert(y = 3, 'assign');
end;

procedure TestBuiltInFunctions;
begin
  Assert(Repr(1) = '1', 'Repr');
  Assert(Repr('a') = '''a''', 'Repr');
end;

procedure TestLoops;
var A : Integer;
begin
  A := 0;
  For I := 1 to 10 do
    A := A + 1;
  Assert(A = 10, 'For');
  A := 0;
  While A < 10 do
    A := A + 1;
  Assert(A = 10, 'While');
  A := 0;
  Repeat
    A := A + 1;
  Until A = 10;
  Assert(A = 10, 'Repeat');
end;

procedure TestStatements;
begin
  X := 1;
  Assert(X = 1, 'assign');
  Assert(X <> 0, 'assign');
  Y := 0;
  if X = 1 then
    Y := 1;
  Assert(Y = 1, 'if');
  Assert(Y <> 0, 'if');
  if X <> 0 then
    Y := 2
  else
    Y := 3;
  Assert(Y = 2, 'if');
  if X = 2 then
    Y := 4
  else
    Y := 5;
  Assert(Y = 5, 'if');

  X := 1;
  Case X of
    0 : Assert(False, 'case');
    1 : Assert(True, 'case');
  else
    Assert(False, 'case');
  end;
  X := 0.5;
  Case X of
    0..1   : Assert(True, 'case');
    1..1.9 : Assert(False, 'case');
  else
    Assert(False, 'case');
  end;
  Case X of
    0.1..0.2 : Assert(False, 'case');
    0.6..1.0 : Assert(False, 'case');
  else
    Assert(True, 'case');
  end;
end;

procedure TestExpressionType;
var A : Expression;
begin
  A := '1+1';
  Assert(A.Eval = 2, 'Eval');
  Assert(String(A) = '(1 + 1)', 'String');
  A.Simplify;
  Assert(String(A) = '2', 'String');

  X := 1;
  Assert(Eval('1+1+x') = 3, 'Eval');

  A := '1+1+x';
  Assert(String(A) = '((1 + 1) + x)', 'String');
  A.Simplify;
  Assert(String(A) = '(2 + x)', 'Simplify');
  Assert(Repr(A) = 'Expression(''(2 + x)'')', 'Repr');
end;

procedure TestRecordType;
type
  R1 = record
    A, B : Integer;
    C    : Integer = 1;
    D    : Boolean;
  end;
var
  X : R1 = ['A':2, 'B':3.3, 'C':4];
  Y : R1;
  Z : R1 = ['F':'X'];
begin
  Assert(X.A = 2, 'Record');
  Assert(X.B = 3, 'Record');
  Assert(X.C = 4, 'Record');
  Assert(X.D = False, 'Record');
  Assert(Y.A = 0, 'Record');
  Assert(Y.C = 1, 'Record');
  Y.D := True;
  Assert(Y.D = True, 'Record'); 
  Y.E := 5;
  Assert(Y.E = 5, 'Record');
  Assert(Z.F = 'X', 'Record');
  Z := X;
  Assert(Z.A = 2, 'Record');
end;

procedure TestMatrixType;
var A : Matrix;
    X : Vector;
begin
  X.Count := 3;
  Assert(X.Count = 3, 'Vector');
  Assert(X[0] = 0, 'Vector');
  X[1] := 2;
  Assert(X[1] = 2, 'Vector');

  A.RowCount := 3;
  A.ColCount := 3;
  Assert(A.RowCount = 3, 'Matrix');
  Assert(A.ColCount = 3, 'Matrix');
  Assert(A[0,0] = 0, 'Matrix');
  A[1,1] := 1;
  Assert(A[1,1] = 1, 'Matrix'); 
end;

procedure TestUnits;
begin
  Assert(BlaiseTestUnit.UnitTest1 = 1, 'Units');
  Assert(UnitTest1 = 1, 'Units');
  Assert(UnitTest2 = 2, 'Units');
  Assert(UnitTest3 = 3, 'Units');
  Assert(UnitTest2_1 = 1, 'Units');
  Assert(UnitTest2_2 = 2, 'Units');
  Assert(UnitTest2_3 = 3, 'Units');
end;

task TaskA;
begin
  for i := 1 to 10 do return i;
end;

task TaskB;
begin
  for i in TaskA do return i;
end;

procedure TestTasks;
var y: array of integer;
begin
  for x in TaskB do
    y.append(x);
  Assert(y.count = 10, 'Tasks');
  for i := 1 to 10 do
    Assert(y[i - 1] = i, 'Tasks');
end;

procedure TestExceptions;
var x, y, z : integer;
begin
  try
    x := 1;
  except
    x := 3;
  end;
  Assert(x = 1, 'Except');
  try
    x := 1;
    raise 2;
  except
    x := 3;
  end;
  Assert(x = 3, 'Raise');
  try
    x := 2;
    y := 3;
  finally
    y := 4;
  end;
  Assert(x = 2, 'Finally');
  Assert(y = 4, 'Finally');
  try
    try
      x := 1;
      y := 1;
      z := 1;
      raise 2;
    finally
      z := 2;
    end;
  except
    x := 3;
    try
      x := 4;
      raise 5;
    except
      x := 6;
      y := 6;
    end;
    x := 7;
  end;
  Assert(x = 7, 'Except');
  Assert(y = 6, 'Except');
  Assert(z = 2, 'Finally');
end;

type
  Obj1 = class
    A, B : Integer;

    procedure Proc1;
  end;

  Obj2 = class(Obj1)
    C : Integer;

    procedure Proc1;
    procedure Proc2(X: Integer);
  end;

procedure Obj1.Proc1;
begin
  A := A + 1;
end;

procedure Obj2.Proc1;
begin
  inherited Proc1;
  B := B + 1;
end;

procedure Obj2.Proc2(X: Integer);
begin
  C := C + X;
end;

procedure TestObjects;
var I, J : Obj1;
    K    : Obj2;
begin
  I := Obj1();
  Assert(I is Obj1, 'is');
  Assert(not (I is Obj2), 'is');
  Assert(I.A = 0, 'Object');
  I.A := 1;
  Assert(I.A = 1, 'Object');
  J := I;
  Assert(J.A = 1, 'Object');
  Assert(J.B = 0, 'Object');
  J.B := 2;
  Assert(J.B = 2, 'Object');
  Assert(I.B = 2, 'Object');
  J := Obj1();
  Assert(J.A = 0, 'Object');
  Assert(J.B = 0, 'Object');
  Assert(I.B = 2, 'Object');
  I.Proc1;
  Assert(I.A = 2, 'Object');
  I.Proc1;
  Assert(I.A = 3, 'Object');
  Assert(J.A = 0, 'Object');

  K := Obj2();
  Assert(K is Obj1, 'is');
  Assert(K is Obj2, 'is');
  Assert(K.A = 0, 'Object');
  Assert(K.B = 0, 'Object');
  Assert(K.C = 0, 'Object');
  K.Proc1;
  Assert(K.A = 1, 'Object');
  Assert(K.B = 1, 'Object');
  Assert(K.C = 0, 'Object');
  K.Proc2(3);
  Assert(K.A = 1, 'Object');
  Assert(K.B = 1, 'Object');
  Assert(K.C = 3, 'Object');
end;

begin
  Writeln('Blaise Self Test');
  Writeln('');

  // Assert(False, 'Comment');
  Assert(True, 'Assert'); // Comment

  Writeln('+ Lexer');
  TestLexer;
  Writeln('+ Simple types');
  TestSimpleTypes;
  Writeln('+ Range types');
  TestRangeTypes;
  Writeln('+ Statistic');
  TestStatistic;
  Writeln('+ Array');
  TestArray;
  Writeln('+ Dictionary');
  TestDictionary;
  Writeln('+ Expressions');
  TestExpressions;
  Writeln('+ Built-in functions');
  TestBuiltInFunctions;
  Writeln('+ Loops');
  TestLoops;
  Writeln('+ Statements');
  TestStatements;
  Writeln('+ Expression type');
  TestExpressionType;
  Writeln('+ Record type');
  TestRecordType;
  Writeln('+ Matrix type');
  TestMatrixType;
  Writeln('+ Units');
  TestUnits;
  Writeln('+ Tasks');
  TestTasks;
  Writeln('+ Exceptions');
  TestExceptions;
  Writeln('+ Objects');
  TestObjects;

  Writeln('');
  if Error then
    Writeln('Failure') else
    Writeln('Success');
end.