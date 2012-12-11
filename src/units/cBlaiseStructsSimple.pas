{                                                                              }
{                            Blaise simple types v0.04                         }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseStructsSimple.pas               }
{                                                                              }
{ Description:                                                                 }
{   ASimpleType implementations.                                               }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseStructsSimple from cDataStructs and       }
{                     cMaths.                                                  }
{   13/03/2003  0.02  Added Statistic type.                                    }
{   16/03/2003  0.03  Added UnicodeString type.                                }
{   25/05/2003  0.04  Added Single, Double, Extended, Byte, Int16, Int32,      }
{                     Int64, Base64Binary, URL, Char, UnicodeChar, Duration    }
{                     and Timer types.                                         }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseStructsSimple;

interface

uses
  { Fundamentals }
  cUtils,
  cDateTime,
  cReaders,
  cWriters,
  cUnicodeCodecs,
  cRational,
  cComplex,
  cStatistics,
  cTypes,

  { Blaise }
  cBlaiseTypes;



{                                                                              }
{ AStringBase                                                                  }
{   Base class for String implementations of ASimpleType.                      }
{                                                                              }
type
  AStringBase = class(ASimpleType)
  protected
    function  GetLen: Integer; virtual; abstract;
    procedure SetLen(const Len: Integer); virtual; abstract;

    function  GetAsBlaise: String; override;

  public
    property  Len: Integer read GetLen write SetLen;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
  end;



{                                                                              }
{ TTString                                                                     }
{   ASimpleType implementation of a String value.                              }
{                                                                              }
{   TTString holds raw character data. The string is not translated when       }
{   converted to/from Unicode representations.                                 }
{                                                                              }
type
  TTString = class(AStringBase)
  protected
    FValue : String;

    function  GetCharacter(const Idx: Integer): Char;
    procedure SetCharacter(const Idx: Integer; const Ch: Char);

    { AType                                                                    }
    procedure AssignTo(const Dest: TObject); override;

    { ASimpleType                                                              }
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsUTF16(const Value: WideString); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsCurrency(const Value: Currency); override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    function  GetAsUTF16: WideString; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsCurrency: Currency; override;
    function  GetAsDateTime: TDateTime; override;
    function  GetAsBoolean: Boolean; override;

    { AStringBase                                                              }
    function  GetLen: Integer; override;
    procedure SetLen(const Len: Integer); override;

  public
    constructor Create(const S: String = '');

    property  Value: String read FValue write FValue;

    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ASimpleType                                                              }
    procedure Add(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;

    { TTString interface                                                       }
    property  Character[const Idx: Integer]: Char read GetCharacter write SetCharacter; default;
    function  AsPChar: PChar;

    procedure ConvertUpper;
    procedure ConvertLower;

    function  Match(const M: String; const StartIndex: Integer = 1;
              const CaseSensitive: Boolean = True): Boolean;
    function  MatchLeft(const M: String; const CaseSensitive: Boolean = True): Boolean;
    function  MatchRight(const M: String; const CaseSensitive: Boolean = True): Boolean;

    procedure RemoveAll(const C: CharSet);
    procedure Trim;
    procedure TrimLeft;
    procedure TrimRight;
  end;



{                                                                              }
{ TTBase64Binary                                                               }
{   Binary value encoded in base 64 when represented as string.                } 
{                                                                              }
type
  TTBase64Binary = class(TTString)
  protected
    FAlphabet : String;
    FPadChar  : Char;

    { AType                                                                    }
    procedure SetAsString(const Value: String); override;
    function  GetAsString: String; override;

    { TTBase64Binary                                                           }
    function  GetAlphabet: String;
    procedure SetAlphabet(const Alphabet: String);

  public
    constructor Create(const Alphabet: String = '';
                const PadChar: Char = #0);
    property  Alphabet: String read FAlphabet write SetAlphabet;
    property  PadChar: Char read FPadChar write FPadChar;

    { AType                                                                    }
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;




{                                                                              }
{ TTCompressedBinary                                                           }
{                                                                              }
type
  TCompressionAlgorithm = (caNone, caZLIB);
  TTCompressedBinary = class(TTString)
  protected
    FAlgorithm : TCompressionAlgorithm;

  public
  end;



{                                                                              }
{ TTURL                                                                        }
{   URL string value.                                                          }
{                                                                              }
type
  TTURL = class(TTString)
  protected
    function  GetProtocol: String;
    procedure SetProtocol(const Protocol: String);
    function  GetHost: String;
    procedure SetHost(const Host: String);
    function  GetPath: String;
    procedure SetPath(const Path: String);

  public
    { AType                                                                    }
    function  Duplicate: TObject; override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  GetTypeID: Byte; override;

    { TTURL                                                                    }
    property  Protocol: String read GetProtocol write SetProtocol;
    property  Host: String read GetHost write SetHost;
    property  Path: String read GetPath write SetPath;
  end;



{                                                                              }
{ TTUnicodeString                                                              }
{   ASimpleType implementation of an Unicode String value.                     }
{                                                                              }
type
  TTUnicodeString = class(AStringBase)
  protected
    FValue : WideString;
    FCodec : TUnicodeCodecType;

    function  GetCodecClass: TUnicodeCodecClass;
    function  GetEncoding: String;
    function  GetCharacter(const Idx: Integer): WideChar;
    procedure SetCharacter(const Idx: Integer; const Ch: WideChar);

    { AType                                                                    }
    procedure Init; override;
    procedure AssignTo(const Dest: TObject); override;

    { ASimpleType                                                              }
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsUTF16(const Value: WideString); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsCurrency(const Value: Currency); override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    function  GetAsUTF16: WideString; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsCurrency: Currency; override;
    function  GetAsDateTime: TDateTime; override;
    function  GetAsBoolean: Boolean; override;

    { AStringBase                                                              }
    function  GetLen: Integer; override;
    procedure SetLen(const Len: Integer); override;

  public
    constructor Create(const S: WideString = '';
                const Codec: TUnicodeCodecType = ucUTF8);

    property  Value: WideString read FValue write FValue;

    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;

    { ASimpleType                                                              }
    procedure Add(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;

    { TTUnicodeString interface                                                }
    property  Codec: TUnicodeCodecType read FCodec;
    property  Encoding: String read GetEncoding;
    property  Character[const Idx: Integer]: WideChar read GetCharacter write SetCharacter; default;

    procedure ConvertUpper;
    procedure ConvertLower;
    procedure Trim;
    procedure TrimLeft;
    procedure TrimRight;
  end;

  { TTUnicode8                                                                 }
  TTUnicode8 = class(TTUnicodeString)
  public
    class function CreateInstance: AType; override;
  end;

  { TTUnicode16                                                                }
  TTUnicode16 = class(TTUnicodeString)
  public
    class function CreateInstance: AType; override;
  end;



{                                                                              }
{ TTChar                                                                       }
{   ASimpleType implementation of a character value.                           }
{                                                                              }
type
  TTChar = class(ASimpleType)
  protected
    FValue : Char;

    { ASimpleType                                                              }
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsBoolean: Boolean; override;

  public
    constructor Create(const S: Char = #0);

    property  Value: Char read FValue write FValue;

    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ASimpleType                                                              }
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTUnicodeChar                                                                }
{   ASimpleType implementation of an Unicode character value.                  }
{                                                                              }
type
  TTUnicodeChar = class(ASimpleType)
  protected
    FValue : UCS4Char;

    { ASimpleType                                                              }
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsBoolean: Boolean; override;

  public
    constructor Create(const S: UCS4Char = 0);

    property  Value: UCS4Char read FValue write FValue;

    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ASimpleType                                                              }
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTBoolean                                                                    }
{   ASimpleType implementation of a Boolean value.                             }
{                                                                              }
type
  TTBoolean = class(ASimpleType)
  protected
    FValue : Boolean;

    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsBoolean: Boolean; override;

  public
    constructor Create(const S: Boolean = False); reintroduce; overload;

    property  Value: Boolean read FValue write FValue;

    { ABlaiseType                                                              }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ASimpleType                                                              }
    procedure Negate; override;
    procedure LogicalAND(const V: TObject); override;
    procedure LogicalOR(const V: TObject); override;
    procedure LogicalXOR(const V: TObject); override;
    procedure LogicalNOT; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;

  TTImmutableBoolean = class(TTBoolean)
  public
    { ABlaiseType                                                              }
    function  IsImmutable: Boolean; override;
  end;



{                                                                              }
{ AIntegerBase                                                                 }
{   Base class for AIntegerNumberType implementations.                         }
{                                                                              }
type
  AIntegerBase = class(AIntegerNumberType)
  protected
    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsCurrency(const Value: Currency); override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsUTF8: String; override;
    function  GetAsFloat: Extended; override;
    function  GetAsCurrency: Currency; override;
    function  GetAsDateTime: TDateTime; override;
    function  GetAsBoolean: Boolean; override;

  public
    { AType                                                                    }
    procedure Clear; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;

    { ABlaiseMathType                                                          }
    procedure Negate; override;

    procedure LogicalAND(const V: TObject); override;
    procedure LogicalOR(const V: TObject); override;
    procedure LogicalXOR(const V: TObject); override;
    procedure LogicalNOT; override;

    procedure BitwiseSHL(const V: TObject); override;
    procedure BitwiseSHR(const V: TObject); override;

    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure IntegerDivide(const V: TObject); override;
    procedure Modulo(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure Divide(const V: TObject); override;
    procedure Power(const V: TObject); override;
    procedure Abs; override;
    procedure Sqr; override;
    procedure Inc(const Count: Int64); override;
    procedure Dec(const Count: Int64); override;

    function  UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTByte                                                                       }
{   AIntegerNumberType implementation of a byte value.                         }
{                                                                              }
type
  TTByte = class(AIntegerBase)
  protected
    FValue : Byte;

    { ASimpleType                                                              }
    procedure SetAsInteger(const Value: Int64); override;
    function  GetAsInteger: Int64; override;

  public
    constructor Create(const S: Byte = 0); reintroduce; overload;

    property  Value: Byte read FValue write FValue;

    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTInt16                                                                      }
{   AIntegerNumberType implementation of a 16 bit integer value.               }
{                                                                              }
type
  TTInt16 = class(AIntegerBase)
  protected
    FValue : SmallInt;

    { ASimpleType                                                              }
    procedure SetAsInteger(const Value: Int64); override;
    function  GetAsInteger: Int64; override;

  public
    constructor Create(const S: SmallInt = 0); reintroduce; overload;

    property  Value: SmallInt read FValue write FValue;

    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTInt32                                                                      }
{   AIntegerNumberType implementation of a 32 bit integer value.               }
{                                                                              }
type
  TTInt32 = class(AIntegerBase)
  protected
    FValue : LongInt;

    { ASimpleType                                                              }
    procedure SetAsInteger(const Value: Int64); override;
    function  GetAsInteger: Int64; override;

  public
    constructor Create(const S: LongInt = 0); reintroduce; overload;

    property  Value: LongInt read FValue write FValue;

    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTInt64                                                                      }
{   AIntegerNumberType implementation of a 64 bit integer value.               }
{                                                                              }
type
  TTInt64 = class(AIntegerBase)
  protected
    FValue : Int64;

    { ASimpleType                                                              }
    procedure SetAsInteger(const Value: Int64); override;
    function  GetAsInteger: Int64; override;

  public
    constructor Create(const S: Int64 = 0); reintroduce; overload;

    property  Value: Int64 read FValue write FValue;

    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTInteger                                                                    }
{   Default integer is an Int64.                                               }
{                                                                              }
type
  TTInteger = TTInt64;
  TTImmutableInteger = class(TTInteger)
  public
    { ABlaiseType                                                              }
    function  IsImmutable: Boolean; override;
  end;

  

{                                                                              }
{ AFloatBase                                                                   }
{   Base class for a ARealNumberType implementation of a Float value.          }
{                                                                              }
type
  AFloatBase = class(ARealNumberType)
  protected
    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsCurrency(const Value: Currency); override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsCurrency: Currency; override;
    function  GetAsDateTime: TDateTime; override;
    function  GetAsBoolean: Boolean; override;

  public
    { AType                                                                    }
    procedure Clear; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;

    { ABlasieMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure Divide(const V: TObject); override;
    procedure Power(const V: TObject); override;
    procedure Abs; override;
    procedure Sqr; override;
    procedure Inc(const Count: Int64); override;
    procedure Dec(const Count: Int64); override;
    procedure SetAsRational(const Numerator, Denominator: Int64); override;
    procedure Sqrt; override;
    procedure Exp; override;
    procedure Ln; override;
    procedure Sin; override;
    procedure Cos; override;
    function  UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTSingle                                                                     }
{   ARealNumberType implementation of a Single float value.                    }
{                                                                              }
type
  TTSingle = class(AFloatBase)
  protected
    FValue : Single;

    procedure SetAsFloat(const Value: Extended); override;
    function  GetAsFloat: Extended; override;

  public
    constructor Create(const S: Single = 0.0); reintroduce; overload;

    property  Value: Single read FValue write FValue;
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTDouble                                                                     }
{   ARealNumberType implementation of a Double float value.                    }
{                                                                              }
type
  TTDouble = class(AFloatBase)
  protected
    FValue : Double;

    procedure SetAsFloat(const Value: Extended); override;
    function  GetAsFloat: Extended; override;

  public
    constructor Create(const S: Double = 0.0); reintroduce; overload;

    property  Value: Double read FValue write FValue;
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTExtended                                                                   }
{   ARealNumberType implementation of an Extended float value.                 }
{                                                                              }
type
  TTExtended = class(AFloatBase)
  protected
    FValue : Extended;

    procedure SetAsFloat(const Value: Extended); override;
    function  GetAsFloat: Extended; override;

  public
    constructor Create(const S: Extended = 0.0); reintroduce; overload;

    property  Value: Extended read FValue write FValue;
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TTFloat                                                                      }
{   Default float is an Extended float.                                        }
{                                                                              }
type
  TTFloat = TTExtended;

  TTImmutableFloat = class(TTFloat)
  public
    { ABlaiseType                                                              }
    function  IsImmutable: Boolean; override;
  end;



{                                                                              }
{ TTDateTime                                                                   }
{   ADateTimeType implementation of a DateTime value.                          }
{                                                                              }
type
  TTDateTime = class(ADateTimeType)
  protected
    FValue : TDateTime;

    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsDateTime(const Value: TDateTime); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsDateTime: TDateTime; override;

  public
    constructor Create(const S: TDateTime); reintroduce; overload;

    property  Value: TDateTime read FValue write FValue;

    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  GetTypeID: Byte; override;

    { ASimpleType                                                              }
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;

    { TTDateTime interface                                                     }
    function  GetYear: Integer;
    procedure SetYear(const Year: Integer);
    function  GetMonth: Integer;
    procedure SetMonth(const Month: Integer);
    function  GetDay: Integer;
    procedure SetDay(const Day: Integer);
    function  GetHour: Integer;
    procedure SetHour(const Hour: Integer);
    function  GetMinute: Integer;
    procedure SetMinute(const Minute: Integer);
    function  GetSecond: Integer;
    procedure SetSecond(const Second: Integer);
    function  GetMillisecond: Integer;
    procedure SetMillisecond(const Millisecond: Integer);

    procedure AddMilliseconds(const Milliseconds: Int64);
    function  GetAsMilliseconds: Int64;
    procedure SetAsMilliseconds(const Milliseconds: Int64);

    function  GetDayOfWeek: Integer;
    function  GetDayOfYear: Integer;
    function  GetDaysInMonth: Integer;
    function  GetDaysInYear: Integer;
  end;



{                                                                              }
{ TTAnsiDateTime                                                               }
{   A DateTime implementation with ANSI style string and numeric               }
{   representations.                                                           }
{                                                                              }
type
  TTAnsiDateTime = class(TTDateTime)
  protected
    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;

  public
    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ TTRfcDateTime                                                                }
{   A DateTime implementation with RFC style string representation.            }
{                                                                              }
type
  TTRfcDateTime = class(TTDateTime)
  protected
    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    function  GetAsUTF8: String; override;

  public
    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ TTDuration                                                                   }
{   A DateTime implementation representing a time duration.                    }
{                                                                              }
type
  TTDuration = class(TTDateTime)
  public
    { ASimpleType                                                              }
    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;

    { AType                                                                    }
    function  Duplicate: TObject; override;
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ TTTimer                                                                      }
{   A DateTime implementation for a timer.                                     }
{                                                                              }
type
  TTTimer = class(TTDuration)
  protected
    FTimer   : THPTimer;
    FRunning : Boolean;

    procedure SetRunning(const Running: Boolean);

    { ASimpleType                                                              }
    function  GetAsDateTime: TDateTime; override;
    function  GetAsBoolean: Boolean; override;

  public
    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;

    { TTTimer                                                                  }
    property  Running: Boolean read FRunning write SetRunning;
    procedure Start;
    procedure Stop;
  end;



{                                                                              }
{ TTCurrency                                                                   }
{   ANumberType implementation of a Currency value.                            }
{                                                                              }
type
  TTCurrency = class(ARealNumberType)
  protected
    FValue : Currency;

    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsCurrency(const Value: Currency); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsCurrency: Currency; override;

  public
    constructor Create(const S: Currency = 0.0); reintroduce; overload;

    property  Value: Currency read FValue write FValue;

    { AType                                                                    }
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { ASimpleType                                                              }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure Divide(const V: TObject); override;
    procedure Abs; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTRational                                                                   }
{   ARealNumberType implementation of a Rational value.                        }
{                                                                              }
type
  TTRational = class(ARealNumberType)
  protected
    FValue : TRational;

    { AType                                                                    }
    procedure AssignTo(const Dest: TObject); override;

    { ABlaiseType                                                              }
    function  GetAsBlaise: String; override;

    { ASimpleType                                                              }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsBoolean: Boolean; override;

  public
    constructor CreateEx(const S: TRational);
    constructor Create;
    destructor Destroy; override;

    { AType                                                                    }
    class function CreateInstance: AType; override;
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  GetTypeID: Byte; override;

    { ABlaiseMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure Divide(const V: TObject); override;
    procedure Power(const V: TObject); override;
    procedure Abs; override;
    procedure Sqr; override;
    procedure SetAsRational(const Numerator, Denominator: Int64); override;
    procedure Sqrt; override;
    procedure Exp; override;
    procedure Ln; override;
    procedure Sin; override;
    procedure Cos; override;
    function  UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTComplex                                                                    }
{   ANumberType implementation of a Complex value.                             }
{                                                                              }
type
  TTComplex = class(ANumberType)
  protected
    FValue : TComplex;

    procedure AssignTo(const Dest: TObject); override;

    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); override;
    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsBoolean(const Value: Boolean); override;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsBoolean: Boolean; override;

  public
    constructor CreateEx(const S: TComplex); overload;
    constructor CreateEx(const Imag: Extended); overload;
    constructor Create;
    destructor Destroy; override;

    { AType implementation                                                     }
    class function CreateInstance: AType; override;
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;

    { ASimpleType implementation                                               }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure Divide(const V: TObject); override;
    procedure Power(const V: TObject); override;
    procedure Abs; override;
    procedure Sqr; override;
    procedure SetAsRational(const Numerator, Denominator: Int64); override;
    procedure Sqrt; override;
    procedure Exp; override;
    procedure Ln; override;
    procedure Sin; override;
    procedure Cos; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTStatistic                                                                  }
{   ANumberType implementation of a Statistic.                                 }
{                                                                              }
type
  TTStatistic = class(ANumberType)
  protected
    FValue : TStatistic;

    function  AddSamples(const Source: TObject;
              const Negate, Reset: Boolean): Boolean;

    procedure AssignTo(const Dest: TObject); override;
    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; override;
    function  GetAsFloat: Extended; override;
    function  GetAsBoolean: Boolean; override;

  public
    constructor CreateEx(const S: TStatistic);
    constructor Create;
    destructor Destroy; override;

    { AType implementation                                                     }
    class function CreateInstance: AType; override;
    procedure Clear; override;
    function  Duplicate: TObject; override;
    procedure Assign(const Source: TObject); override;

    { ABlaiseType implementation                                               }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;

    { ASimpleType implementation                                               }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure ReversedAdd(const V: TObject); override;
    procedure ReversedSubtract(const V: TObject); override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
    function  BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
              const LeftOp: TObject): TObject; override;
  end;



{                                                                              }
{ TTInfinity                                                                   }
{   Implementation of infinite numbers.                                        }
{                                                                              }
type
  TInfinityKind = (
      PositiveInfinity,
      NegativeInfinity,
      PositiveZero,
      NegativeZero);
  TTInfinity = class(APseudoNumberType)
  protected
    FKind: TInfinityKind;

    procedure Init; override;
    function  GetAsUTF8: String; override;

  public
    { AType                                                                    }
    procedure Assign(const Source: TObject); override;
    function  IsEqual(const T: TObject): Boolean; override;
    function  Compare(const T: TObject): TCompareResult; override;

    { ABlasieMathType                                                          }
    procedure Negate; override;
    procedure Add(const V: TObject); override;
    procedure Subtract(const V: TObject); override;
    procedure Multiply(const V: TObject); override;
    procedure Divide(const V: TObject); override;
    procedure Power(const V: TObject); override;
    procedure Abs; override;
    procedure Sqr; override;
    function  UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject; override;
    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; override;
  end;



{                                                                              }
{ TSimpleTypeDefinition                                                        }
{   Blaise type definitions for the simple types.                              }
{                                                                              }
type
  TSimpleTypeDefinition = class(ATypeDefinition)
  protected
    FTypeClass : CBlaiseType;

  public
    constructor Create(const TypeClass: CBlaiseType);

    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    function  CreateTypeInstance: TObject; override;
    function  IsType(const Value: TObject): Boolean; override;
    function  IsVariablesAutoInstanciate: Boolean; override;

    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;
  CSimpleTypeDefinition = class of TSimpleTypeDefinition;

  { TStringType                                                                }
  TStringType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TBase64BinaryType                                                          }
  TBase64BinaryType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TURLType                                                                   }
  TURLType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TUnicodeType                                                               }
  TUnicodeType = class(TSimpleTypeDefinition)
    constructor Create;

    function GetTypeDefID: Byte; override;

    { ABlaiseType implementation                                               }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
  end;

  { TUnicode8Type                                                              }
  TUnicode8Type = class(TSimpleTypeDefinition)
    constructor Create;
  end;

  { TUnicode16Type                                                             }
  TUnicode16Type = class(TSimpleTypeDefinition)
    constructor Create;
  end;

  { TCharType                                                                  }
  TCharType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TUnicodeCharType                                                           }
  TUnicodeCharType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TByteType                                                                   }
  TByteType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TInt16Type                                                                 }
  TInt16Type = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TInt32Type                                                                 }
  TInt32Type = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TInt64Type                                                                 }
  TInt64Type = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TIntegerType                                                               }
  TIntegerType = TInt64Type;

  { TSingleFloatType                                                           }
  TSingleFloatType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TDoubleFloatType                                                           }
  TDoubleFloatType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TExtendedFloatType                                                         }
  TExtendedFloatType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TFloatType                                                                 }
  TFloatType = TExtendedFloatType;

  { TBooleanType                                                               }
  TBooleanType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TDateTimeType                                                              }
  TDateTimeType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TAnsiDateTimeType                                                          }
  TAnsiDateTimeType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TRfcDateTimeType                                                           }
  TRfcDateTimeType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TDurationType                                                              }
  TDurationType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TTimerType                                                                 }
  TTimerType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TCurrencyType                                                              }
  TCurrencyType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TRationalType                                                              }
  TRationalType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TComplexType                                                               }
  TComplexType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;

  { TStatisticType                                                             }
  TStatisticType = class(TSimpleTypeDefinition)
    constructor Create;
    function GetTypeDefID: Byte; override;
  end;



{                                                                              }
{ Immutable values                                                             }
{                                                                              }
function  GetImmutableBoolean(const Value: Boolean): TTBoolean;
function  GetImmutableInteger(const Value: Int64): TTInteger;
function  GetImmutableFloatZero: TTFloat;
function  GetImmutableInfinity: TTInfinity;



implementation

uses
  { Delphi }
  Math,
  SysUtils,

  { Fundamentals }
  cStrings,
  cUnicode,
  cInternetUtils,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs;



{                                                                              }
{ AStringBase                                                                  }
{                                                                              }
function AStringBase.GetAsBlaise: String;
begin
  Result := StrQuote(GetAsUTF8, '''');
end;

function AStringBase.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Length') then
    begin
      Scope := self;
      FieldType := bfObject;
      Result := GetImmutableInteger(GetLen);
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure AStringBase.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Len') then
    SetLen(ObjectGetAsInteger(Value))
  else
    inherited SetField(FieldName, Value);
end;



{                                                                              }
{ TTString                                                                     }
{                                                                              }
constructor TTString.Create(const S: String);
begin
  inherited Create;
  FValue := S;
end;

procedure TTString.Clear;
begin
  FValue := '';
end;

function TTString.Duplicate: TObject;
begin
  Result := TTString.Create(FValue);
end;

procedure TTString.Assign(const Source: TObject);
begin
  FValue := ObjectGetAsString(Source);
end;

procedure TTString.AssignTo(const Dest: TObject);
begin
  ObjectSetAsString(Dest, self);
end;

function TTString.IsEqual(const T: TObject): Boolean;
begin
  Result := ObjectGetAsString(T) = FValue;
end;

function TTString.Compare(const T: TObject): TCompareResult;
begin
  Result := cUtils.Compare(FValue, ObjectGetAsString(T));
end;

function TTString.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_STRING;
end;

procedure TTString.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedString(FValue);
end;

procedure TTString.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadPackedString;
end;

function TTString.GetAsString: String;
begin
  Result := FValue;
end;

procedure TTString.SetAsString(const Value: String);
begin
  FValue := Value;
end;

function TTString.GetAsUTF8: String;
begin
  Result := LongStringToUTF8String(FValue);
end;

procedure TTString.SetAsUTF8(const Value: String);
begin
  try
    FValue := UTF8StringToLongString(Value);
  except
    ConvertFromError('utf-8');
  end;
end;

function TTString.GetAsUTF16: WideString;
begin
  Result := LongStringToWideString(FValue);
end;

procedure TTString.SetAsUTF16(const Value: WideString);
begin
  try
    FValue := WideStringToLongString(Value);
  except
    ConvertFromError('utf-16');
  end;
end;

function TTString.GetAsInteger: Int64;
begin
  Result := StrToInt64(FValue);
end;

procedure TTString.SetAsInteger(const Value: Int64);
begin
  FValue := IntToStr(Value);
end;

function TTString.GetAsFloat: Extended;
begin
  Result := StrToFloat(FValue);
end;

procedure TTString.SetAsFloat(const Value: Extended);
begin
  FValue := FloatToStr(Value);
end;

function TTString.GetAsCurrency: Currency;
begin
  Result := StrToFloat(FValue);
end;

procedure TTString.SetAsCurrency(const Value: Currency);
begin
  FValue := FloatToStr(Value);
end;

function TTString.GetAsDateTime: TDateTime;
begin
  Result := StrToDateTime(FValue);
end;

procedure TTString.SetAsDateTime(const Value: TDateTime);
begin
  FValue := FormatDateTime('d mmm yyyy hh:nn:ss', Value);
end;

function TTString.GetAsBoolean: Boolean;
begin
  Result := (FValue = '1') or
            StrEqualNoCase(FValue, 'True');
end;

procedure TTString.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    FValue := 'True' else
    FValue := 'False';
end;

procedure TTString.Add(const V: TObject);
begin
  FValue := FValue + ObjectGetAsString(V);
end;

function TTString.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation; const RightOp: TObject): TObject;
begin
  if (Operation = bmoAdd) and
     (ObjectIsString(RightOp) or ObjectIsUnicodeString(RightOp)) then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTString.GetLen: Integer;
begin
  Result := Length(FValue);
end;

procedure TTString.SetLen(const Len: Integer);
begin
  SetLengthAndZero(FValue, Len);
end;

function TTString.GetCharacter(const Idx: Integer): Char;
begin
  if (Idx < 1) or (Idx > Length(FValue)) then
    raise ERangeError.Create('String index out of bounds');
  Result := FValue[Idx];
end;

procedure TTString.SetCharacter(const Idx: Integer; const Ch: Char);
begin
  if (Idx < 1) or (Idx > Length(FValue)) then
    raise ERangeError.Create('String index out of bounds');
  FValue[Idx] := Ch;
end;

procedure TTString.Trim;
begin
  TrimInPlace(FValue, csWhiteSpace);
end;

procedure TTString.TrimLeft;
begin
  TrimLeftInPlace(FValue, csWhiteSpace);
end;

procedure TTString.TrimRight;
begin
  TrimRightInPlace(FValue, csWhiteSpace);
end;

function TTString.AsPChar: PChar;
begin
  Result := PChar(FValue);
end;

procedure TTString.ConvertUpper;
begin
  cStrings.ConvertUpper(FValue);
end;

procedure TTString.ConvertLower;
begin
  cStrings.ConvertLower(FValue);
end;

procedure TTString.RemoveAll(const C: CharSet);
begin
  FValue := StrRemoveChar(FValue, C);
end;

function TTString.Match(const M: String; const StartIndex: Integer; const CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := StrMatch(FValue, M, StartIndex) else
    Result := StrMatchNoCase(FValue, M, StartIndex);
end;

function TTString.MatchLeft(const M: String; const CaseSensitive: Boolean): Boolean;
begin
  Result := StrMatchLeft(FValue, M, CaseSensitive);
end;

function TTString.MatchRight(const M: String; const CaseSensitive: Boolean): Boolean;
begin
  Result := StrMatchRight(FValue, M, CaseSensitive);
end;



{                                                                              }
{ TTBase64Binary                                                               }
{                                                                              }
constructor TTBase64Binary.Create(const Alphabet: String; const PadChar: Char);
begin
  inherited Create;
  FAlphabet := Alphabet;
  FPadChar := PadChar;
end;

function TTBase64Binary.GetAlphabet: String;
begin
  if FAlphabet = '' then
    Result := b64_MIMEBase64
  else
    Result := FAlphabet;
end;

procedure TTBase64Binary.SetAlphabet(const Alphabet: String);
begin
  FAlphabet := Alphabet;
end;

procedure TTBase64Binary.SetAsString(const Value: String);
var P : CharSet;
begin
  if FPadChar = #0 then
    P := []
  else
    P := [FPadChar];
  FValue := DecodeBase64(Value, GetAlphabet, P);
end;

function TTBase64Binary.GetAsString: String;
begin
  FValue := EncodeBase64(FValue, GetAlphabet, FPadChar <> #0, 4, FPadChar);
end;

function TTBase64Binary.Duplicate: TObject;
begin
  Result := TTBase64Binary.Create(FAlphabet, FPadChar);
end;

procedure TTBase64Binary.Assign(const Source: TObject);
begin
  if Source is TTBase64Binary then
    begin
      FValue := TTBase64Binary(Source).FValue;
      FAlphabet := TTBase64Binary(Source).FAlphabet;
      FPadChar := TTBase64Binary(Source).FPadChar;
    end
  else
    inherited Assign(Source);
end;

function TTBase64Binary.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Alphabet') then
    begin
      Scope := self;
      FieldType := bfObject;
      Result := TTString.Create(FAlphabet);
    end else
  if StrEqualNoCase(FieldName, 'PadChar') then
    begin
      Scope := self;
      FieldType := bfObject;
      Result := TTChar.Create(FPadChar);
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TTBase64Binary.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Alphabet') then
    SetAlphabet(ObjectGetAsString(Value)) else
  if StrEqualNoCase(FieldName, 'PadChar') then
    PadChar := ObjectGetAsChar(Value)
  else
    inherited SetField(FieldName, Value);
end;

function TTBase64Binary.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_BINARY_BASE64;
end;

procedure TTBase64Binary.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedString(FAlphabet);
  Writer.WriteByte(Byte(FPadChar));
  inherited StreamOut(Writer);
end;

procedure TTBase64Binary.StreamIn(const Reader: AReaderEx);
begin
  FAlphabet := Reader.ReadPackedString;
  FPadChar := Char(Reader.ReadByte);
  inherited StreamIn(Reader);
end;



{                                                                              }
{ TTURL                                                                        }
{                                                                              }
function TTURL.GetProtocol: String;
var A, B : String;
begin
  DecodeURL(FValue, Result, A, B);
end;

procedure TTURL.SetProtocol(const Protocol: String);
var A, B, C : String;
begin
  DecodeURL(FValue, A, B, C);
  FValue := EncodeURL(Protocol, B, C);
end;

function TTURL.GetHost: String;
var A, B : String;
begin
  DecodeURL(FValue, A, Result, B);
end;

procedure TTURL.SetHost(const Host: String);
var A, B, C : String;
begin
  DecodeURL(FValue, A, B, C);
  FValue := EncodeURL(A, Host, C);
end;

function TTURL.GetPath: String;
var A, B : String;
begin
  DecodeURL(FValue, A, B, Result);
end;

procedure TTURL.SetPath(const Path: String);
var A, B, C : String;
begin
  DecodeURL(FValue, A, B, C);
  FValue := EncodeURL(A, B, Path);
end;

function TTURL.Duplicate: TObject;
begin
  Result := TTURL.Create(FValue);
end;

function TTURL.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Protocol') then
    Result := TTString.Create(GetProtocol) else
  if StrEqualNoCase(FieldName, 'Host') then
    Result := TTString.Create(GetHost) else
  if StrEqualNoCase(FieldName, 'Path') then
    Result := TTString.Create(GetPath)
  else
    Result := nil;
  if Assigned(Result) then
    begin
      Scope := self;
      FieldType := bfObject;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TTURL.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Protocol') then
    SetProtocol(ObjectGetAsString(Value)) else
  if StrEqualNoCase(FieldName, 'Host') then
    SetHost(ObjectGetAsString(Value)) else
  if StrEqualNoCase(FieldName, 'Path') then
    SetPath(ObjectGetAsString(Value))
  else
    inherited SetField(FieldName, Value);
end;

function TTURL.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_STRING_URL;
end;



{                                                                              }
{ TTUnicodeString                                                              }
{                                                                              }
constructor TTUnicodeString.Create(const S: WideString;
    const Codec: TUnicodeCodecType);
begin
  inherited Create;
  FValue := S;
  FCodec := Codec;
end;

procedure TTUnicodeString.Init;
begin
  inherited Init;
  FCodec := ucUTF8;
end;

procedure TTUnicodeString.Clear;
begin
  FValue := '';
end;

function TTUnicodeString.Duplicate: TObject;
begin
  Result := TTUnicodeString.Create(FValue, FCodec);
end;

procedure TTUnicodeString.Assign(const Source: TObject);
begin
  if ObjectIsUnicodeString(Source) then
    FValue := ObjectGetAsUTF16(Source) else
  if ObjectIsString(Source) then
    SetAsString(ObjectGetAsString(Source)) 
  else
    FValue := ObjectGetAsUTF16(Source);
end;

procedure TTUnicodeString.AssignTo(const Dest: TObject);
begin
  ObjectSetAsUTF16(Dest, self);
end;

function TTUnicodeString.IsEqual(const T: TObject): Boolean;
begin
  Result := ObjectGetAsUTF16(T) = FValue;
end;

function TTUnicodeString.Compare(const T: TObject): TCompareResult;
begin
  Result := cUtils.Compare(FValue, ObjectGetAsUTF16(T));
end;

function TTUnicodeString.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_UNICODE;
end;

procedure TTUnicodeString.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedWideString(FValue);
end;

procedure TTUnicodeString.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadPackedWideString;
end;

function TTUnicodeString.GetCodecClass: TUnicodeCodecClass;
begin
  Result := GetUnicodeCodecClassByType(FCodec);
  if not Assigned(Result) then
    Result := TUTF16Codec;
end;

function TTUnicodeString.GetEncoding: String;
begin
  Result := GetCodecClass.GetAliasByIndex(0);
end;

function TTUnicodeString.GetAsString: String;
var I : Integer;
begin
  Result := EncodeUnicodeEncoding(GetCodecClass, FValue, I);
end;

procedure TTUnicodeString.SetAsString(const Value: String);
var I : Integer;
begin
  FValue := DecodeUnicodeEncoding(GetCodecClass, Pointer(Value), Length(Value), I);
end;

function TTUnicodeString.GetAsUTF8: String;
begin
  Result := WideStringToUTF8String(FValue);
end;

procedure TTUnicodeString.SetAsUTF8(const Value: String);
begin
  FValue := UTF8StringToWideString(Value);
end;

function TTUnicodeString.GetAsUTF16: WideString;
begin
  Result := FValue;
end;

procedure TTUnicodeString.SetAsUTF16(const Value: WideString);
begin
  FValue := Value;
end;

function TTUnicodeString.GetAsInteger: Int64;
begin
  Result := StrToInt64(GetAsUTF8);
end;

procedure TTUnicodeString.SetAsInteger(const Value: Int64);
begin
  SetAsUTF8(IntToStr(Value));
end;

function TTUnicodeString.GetAsFloat: Extended;
begin
  Result := StrToFloat(GetAsUTF8);
end;

procedure TTUnicodeString.SetAsFloat(const Value: Extended);
begin
  SetAsUTF8(FloatToStr(Value));
end;

function TTUnicodeString.GetAsCurrency: Currency;
begin
  Result := StrToFloat(GetAsUTF8);
end;

procedure TTUnicodeString.SetAsCurrency(const Value: Currency);
begin
  SetAsUTF8(FloatToStr(Value));
end;

function TTUnicodeString.GetAsDateTime: TDateTime;
begin
  Result := StrToDateTime(GetAsUTF8);
end;

procedure TTUnicodeString.SetAsDateTime(const Value: TDateTime);
begin
  SetAsUTF8(FormatDateTime('d mmm yyyy hh:nn:ss', Value));
end;

function TTUnicodeString.GetAsBoolean: Boolean;
begin
  Result := WideEqualAnsiStr('1', FValue, True) or
            WideEqualAnsiStr('True', FValue, False);
end;

procedure TTUnicodeString.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    SetAsUTF8('True') else
    SetAsUTF8('False');
end;

procedure TTUnicodeString.Add(const V: TObject);
begin
  if ObjectIsUnicodeString(V) then
    FValue := FValue + ObjectGetAsUTF16(V)
  else
    inherited Add(V);
end;

function TTUnicodeString.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation; const RightOp: TObject): TObject;
begin
  if (Operation = bmoAdd) and ObjectIsUnicodeString(RightOp) then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTUnicodeString.GetLen: Integer;
begin
  Result := Length(FValue);
end;

procedure TTUnicodeString.SetLen(const Len: Integer);
begin
  WideSetLengthAndZero(FValue, Len);
end;

function TTUnicodeString.GetCharacter(const Idx: Integer): WideChar;
begin
  if (Idx < 1) or (Idx > Length(FValue)) then
    raise ERangeError.Create('String index out of bounds');
  Result := FValue[Idx];
end;

procedure TTUnicodeString.SetCharacter(const Idx: Integer; const Ch: WideChar);
begin
  if (Idx < 1) or (Idx > Length(FValue)) then
    raise ERangeError.Create('String index out of bounds');
  FValue[Idx] := Ch;
end;

procedure TTUnicodeString.ConvertUpper;
begin
  FValue := WideUpperCase(FValue);
end;

procedure TTUnicodeString.ConvertLower;
begin
  FValue := WideLowerCase(FValue);
end;

procedure TTUnicodeString.Trim;
begin
  WideTrimInPlace(FValue, IsWideWhiteSpace);
end;

procedure TTUnicodeString.TrimLeft;
begin
  WideTrimLeftInPlace(FValue, IsWideWhiteSpace);
end;

procedure TTUnicodeString.TrimRight;
begin
  WideTrimRightInPlace(FValue, IsWideWhiteSpace);
end;

function TTUnicodeString.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Encoding') then
    begin
      Scope := self;
      FieldType := bfObject;
      Result := TTString.Create(GetEncoding);
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;



{                                                                              }
{ TTUnicode8                                                                   }
{                                                                              }
class function TTUnicode8.CreateInstance: AType;
begin
  Result := TTUnicode8.Create('', ucUTF8);
end;



{                                                                              }
{ TTUnicode16                                                                  }
{                                                                              }
class function TTUnicode16.CreateInstance: AType;
begin
  Result := TTUnicode16.Create('', ucUTF16);
end;



{                                                                              }
{ TTChar                                                                       }
{                                                                              }
constructor TTChar.Create(const S: Char);
begin
  inherited Create;
  FValue := S;
end;

procedure TTChar.SetAsString(const Value: String);
begin
  if Length(Value) <> 1 then
    TypeError('Invalid character value');
  FValue := Value[1];
end;

procedure TTChar.SetAsUTF8(const Value: String);
begin
  try
    SetAsString(UTF8StringToLongString(Value));
  except
    ConvertFromError('utf-8');
  end;
end;

procedure TTChar.SetAsInteger(const Value: Int64);
begin
  if (Value < 0) or (Value > 255) then
    TypeError('Invalid character value');
  FValue := Char(Byte(Value));
end;

procedure TTChar.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    FValue := '1' else
    FValue := '0';
end;

function TTChar.GetAsString: String;
begin
  Result := FValue;
end;

function TTChar.GetAsUTF8: String;
begin
  Result := LongStringToUTF8String(FValue);
end;

function TTChar.GetAsInteger: Int64;
begin
  Result := Ord(FValue);
end;

function TTChar.GetAsBoolean: Boolean;
begin
  Result := FValue in [#1, '1', 'T', 't'];
end;

procedure TTChar.Clear;
begin
  FValue := #0;
end;

function TTChar.Duplicate: TObject;
begin
  Result := TTChar.Create(FValue);
end;

procedure TTChar.Assign(const Source: TObject);
begin
  if Source is TTChar then
    FValue := TTChar(Source).FValue else
  if ObjectIsString(Source) then
    FValue := ObjectGetAsChar(Source) 
  else
    inherited Assign(Source);
end;

function TTChar.IsEqual(const T: TObject): Boolean;
begin
  if T is TTChar then
    Result := TTChar(T).FValue = FValue else
  if T is TTString then
    Result := (TTString(T).Len = 1) and (TTString(T).FValue[1] = FValue)
  else
    Result := inherited IsEqual(T);
end;

function TTChar.Compare(const T: TObject): TCompareResult;
begin
  if T is TTChar then
    Result := cUtils.Compare(Ord(FValue), Ord(TTChar(T).FValue))
  else
    Result := inherited Compare(T);
end;

function TTChar.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_CHAR;
end;

procedure TTChar.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteByte(Byte(Ord(FValue)));
end;

procedure TTChar.StreamIn(const Reader: AReaderEx);
begin
  FValue := Char(Reader.ReadByte);
end;

function TTChar.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  if (Operation = bmoAdd) and
     (ObjectIsString(RightOp) or ObjectIsUnicodeString(RightOp) or
      (RightOp is TTChar) or (RightOp is TTUnicodeChar)) then
    Result := TTString.Create(FValue)
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;



{                                                                              }
{ TTUnicodeChar                                                                }
{                                                                              }
constructor TTUnicodeChar.Create(const S: UCS4Char);
begin
  inherited Create;
  FValue := S;
end;

procedure TTUnicodeChar.SetAsString(const Value: String);
begin
  if Length(Value) <> 1 then
    TypeError('Invalid character value');
  FValue := Ord(Value[1]);
end;

procedure TTUnicodeChar.SetAsUTF8(const Value: String);
begin
  try
    SetAsString(UTF8StringToLongString(Value));
  except
    ConvertFromError('utf-8');
  end;
end;

procedure TTUnicodeChar.SetAsInteger(const Value: Int64);
begin
  if (Value < 0) or (Value > $FFFFFFFF) then
    TypeError('Invalid character value');
  FValue := UCS4Char(LongWord(Value));
end;

procedure TTUnicodeChar.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    FValue := Ord('1') else
    FValue := Ord('0');
end;

function TTUnicodeChar.GetAsString: String;
begin
  SetLength(Result, 4);
  Move(FValue, Pointer(Result)^, 4);
end;

function TTUnicodeChar.GetAsUTF8: String;
var Buf : Array[0..7] of Byte;
    Len : Integer;
begin
  Len := 0;
  UCS4CharToUTF8(FValue, @Buf[0], Sizeof(Buf), Len);
  SetLength(Result, Len);
  if Len > 0 then
    Move(Buf[0], Pointer(Result)^, Len);
end;

function TTUnicodeChar.GetAsInteger: Int64;
begin
  Result := Ord(FValue);
end;

function TTUnicodeChar.GetAsBoolean: Boolean;
begin
  Result := FValue in [1, Ord('1'), Ord('T'), Ord('t')];
end;

procedure TTUnicodeChar.Clear;
begin
  FValue := 0;
end;

function TTUnicodeChar.Duplicate: TObject;
begin
  Result := TTUnicodeChar.Create(FValue);
end;

procedure TTUnicodeChar.Assign(const Source: TObject);
begin
  if Source is TTUnicodeChar then
    FValue := TTUnicodeChar(Source).FValue
  else
    inherited Assign(Source);
end;

function TTUnicodeChar.IsEqual(const T: TObject): Boolean;
begin
  if T is TTUnicodeChar then
    Result := TTUnicodeChar(T).FValue = FValue else
  if T is TTUnicodeString then
    Result := (TTUnicodeString(T).Len = 1) and
              (Ord(TTUnicodeString(T).FValue[1]) = FValue)
  else
    Result := inherited IsEqual(T);
end;

function TTUnicodeChar.Compare(const T: TObject): TCompareResult;
begin
  if T is TTUnicodeChar then
    Result := cUtils.Compare(Ord(FValue), Ord(TTUnicodeChar(T).FValue))
  else
    Result := inherited Compare(T);
end;

function TTUnicodeChar.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_UNICODECHAR;
end;

procedure TTUnicodeChar.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteLongWord(Ord(FValue));
end;

procedure TTUnicodeChar.StreamIn(const Reader: AReaderEx);
begin
  FValue := UCS4Char(Reader.ReadLongWord);
end;

function TTUnicodeChar.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  if (Operation = bmoAdd) and
     (ObjectIsString(RightOp) or ObjectIsUnicodeString(RightOp) or
      (RightOp is TTChar) or (RightOp is TTUnicodeChar)) then
    Result := TTUnicodeString.Create(GetAsUTF16)
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;



{                                                                              }
{ TTBoolean                                                                    }
{                                                                              }
constructor TTBoolean.Create(const S: Boolean);
begin
  inherited Create;
  FValue := S;
end;

procedure TTBoolean.Clear;
begin
  FValue := False;
end;

function TTBoolean.Duplicate: TObject;
begin
  Result := TTBoolean.Create(FValue);
end;

procedure TTBoolean.Assign(const Source: TObject);
begin
  FValue := ObjectGetAsBoolean(Source);
end;

function TTBoolean.IsEqual(const T: TObject): Boolean;
begin
  Result := ObjectGetAsBoolean(T) = FValue;
end;

function TTBoolean.Compare(const T: TObject): TCompareResult;
begin
  Result := cUtils.Compare(FValue, ObjectGetAsBoolean(T));
end;

function TTBoolean.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_BOOLEAN;
end;

procedure TTBoolean.StreamOut(const Writer: AWriterEx);
begin
  if FValue then
    Writer.WriteByte(1) else
    Writer.WriteByte(0);
end;

procedure TTBoolean.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadByte <> 0;
end;

function TTBoolean.GetAsUTF8: String;
begin
  if FValue then
    Result := 'True' else
    Result := 'False';
end;

procedure TTBoolean.SetAsUTF8(const Value: String);
begin
  FValue := StrToBoolean(Value);
end;

function TTBoolean.GetAsInteger: Int64;
begin
  if FValue then
    Result := 1 else
    Result := 0;
end;

procedure TTBoolean.SetAsInteger(const Value: Int64);
begin
  FValue := Value <> 0;
end;

function TTBoolean.GetAsFloat: Extended;
begin
  if FValue then
    Result := 1.0 else
    Result := 0.0;
end;

procedure TTBoolean.SetAsFloat(const Value: Extended);
begin
  FValue := not FloatZero(Value, ExtendedCompareDelta);
end;

function TTBoolean.GetAsBoolean: Boolean;
begin
  Result := FValue;
end;

procedure TTBoolean.SetAsBoolean(const Value: Boolean);
begin
  FValue := Value;
end;

function TTBoolean.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation; const RightOp: TObject): TObject;
begin
  if ObjectIsBoolean(RightOp) and
     (Operation in [bmoLogicalAND, bmoLogicalOR, bmoLogicalXOR]) then
    Result := TTBoolean.Create(FValue)
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

procedure TTBoolean.LogicalAND(const V: TObject);
begin
  FValue := FValue and ObjectGetAsBoolean(V);
end;

procedure TTBoolean.LogicalOR(const V: TObject);
begin
  FValue := FValue or ObjectGetAsBoolean(V);
end;

procedure TTBoolean.LogicalXOR(const V: TObject);
begin
  FValue := FValue xor ObjectGetAsBoolean(V);
end;

procedure TTBoolean.Negate;
begin
  FValue := not FValue;
end;

procedure TTBoolean.LogicalNOT;
begin
  FValue := not FValue;
end;

function TTImmutableBoolean.IsImmutable: Boolean;
begin
  Result := True;
end;



{                                                                              }
{ AIntegerBase                                                                 }
{                                                                              }
procedure AIntegerBase.Clear;
begin
  AsInteger := 0;
end;

procedure AIntegerBase.Assign(const Source: TObject);
begin
  AsInteger := ObjectGetAsInteger(Source);
end;

function AIntegerBase.IsEqual(const T: TObject): Boolean;
begin
  Result := ObjectGetAsInteger(T) = AsInteger;
end;

function AIntegerBase.Compare(const T: TObject): TCompareResult;
begin
  Result := cUtils.Compare(AsInteger, ObjectGetAsInteger(T));
end;

function AIntegerBase.GetAsUTF8: String;
begin
  Result := IntToStr(AsInteger);
end;

procedure AIntegerBase.SetAsUTF8(const Value: String);
begin
  AsInteger := StrToInt64(Value);
end;

function AIntegerBase.GetAsFloat: Extended;
begin
  Result := AsInteger;
end;

procedure AIntegerBase.SetAsFloat(const Value: Extended);
begin
  AsInteger := Trunc(Value);
end;

function AIntegerBase.GetAsCurrency: Currency;
begin
  Result := AsInteger;
end;

procedure AIntegerBase.SetAsCurrency(const Value: Currency);
begin
  AsInteger := Trunc(Value);
end;

function AIntegerBase.GetAsDateTime: TDateTime;
begin
  Result := AsInteger;
end;

procedure AIntegerBase.SetAsDateTime(const Value: TDateTime);
begin
  AsInteger := Trunc(Value);
end;

function AIntegerBase.GetAsBoolean: Boolean;
begin
  Result := AsInteger <> 0;
end;

procedure AIntegerBase.SetAsBoolean(const Value: Boolean);
begin
  AsInteger := Ord(Value);
end;

procedure AIntegerBase.LogicalAND(const V: TObject);
begin
  AsInteger := AsInteger and ObjectGetAsInteger(V);
end;

procedure AIntegerBase.LogicalOR(const V: TObject);
begin
  AsInteger := AsInteger or ObjectGetAsInteger(V);
end;

procedure AIntegerBase.LogicalXOR(const V: TObject);
begin
  AsInteger := AsInteger xor ObjectGetAsInteger(V);
end;

procedure AIntegerBase.Add(const V: TObject);
begin
  AsInteger := AsInteger + ObjectGetAsInteger(V);
end;

procedure AIntegerBase.Subtract(const V: TObject);
begin
  AsInteger := AsInteger - ObjectGetAsInteger(V);
end;

procedure AIntegerBase.Multiply(const V: TObject);
begin
  AsInteger := AsInteger * ObjectGetAsInteger(V);
end;

procedure AIntegerBase.IntegerDivide(const V: TObject);
begin
  AsInteger := AsInteger div ObjectGetAsInteger(V);
end;

procedure AIntegerBase.Modulo(const V: TObject);
begin
  AsInteger := AsInteger mod ObjectGetAsInteger(V);
end;

procedure AIntegerBase.BitwiseSHL(const V: TObject);
begin
  AsInteger := AsInteger shl ObjectGetAsInteger(V);
end;

procedure AIntegerBase.BitwiseSHR(const V: TObject);
begin
  AsInteger := AsInteger shr ObjectGetAsInteger(V);
end;

procedure AIntegerBase.Divide(const V: TObject);
begin
  AsInteger := Trunc(AsInteger / ObjectGetAsInteger(V));
end;

procedure AIntegerBase.Power(const V: TObject);
var I : Extended;
begin
  I := AsInteger;
  AsInteger := Round(Math.Power(I, ObjectGetAsFloat(V)));
end;

procedure AIntegerBase.Sqr;
begin
  AsInteger := System.Sqr(AsInteger);
end;

procedure AIntegerBase.Inc(const Count: Int64);
begin
  AsInteger := AsInteger + Count;
end;

procedure AIntegerBase.Dec(const Count: Int64);
begin
  AsInteger := AsInteger - Count;
end;

procedure AIntegerBase.Abs;
begin
  AsInteger := System.Abs(AsInteger);
end;

procedure AIntegerBase.Negate;
begin
  AsInteger := -AsInteger;
end;

procedure AIntegerBase.LogicalNOT;
begin
  AsInteger := not AsInteger;
end;

function AIntegerBase.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation; const RightOp: TObject): TObject;
begin
  if (Operation = bmoDivide) and ObjectIsInteger(RightOp) then
    Result := TTFloat.Create(AsInteger) else
  if (Operation = bmoPower) and ObjectIsInteger(RightOp) and
     (TTInteger(RightOp).Value < 0) then
    Result := TTFloat.Create(AsInteger) else
  if ObjectIsInteger(RightOp) then
    Result := Duplicate else
  if Operation in [bmoIntegerDivide, bmoModulo, bmoLogicalAND, bmoLogicalOR,
      bmoLogicalXOR, bmoBitwiseSHL, bmoBitwiseSHR] then
    Result := Duplicate else
  if ObjectIsFloat(RightOp) then
    Result := TTFloat.Create(AsInteger) else
  if RightOp is TTComplex then
    Result := TTComplex.CreateEx(TComplex.Create(AsInteger, 0.0)) else
  if RightOp is TTRational then
    Result := TTRational.CreateEx(TRational.Create(AsInteger, 1))
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function AIntegerBase.UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject;
begin
  if (Operation = umoSqrt) and (AsInteger < 0) then
    Result := TTComplex.CreateEx(TComplex.Create(AsInteger, 0.0)) else
  if Operation = umoSqr then
    Result := Duplicate
  else
    Result := TTFloat.Create(AsInteger);
end;



{                                                                              }
{ TTByte                                                                       }
{                                                                              }
constructor TTByte.Create(const S: Byte);
begin
  inherited Create;
  FValue := S;
end;

function TTByte.Duplicate: TObject;
begin
  Result := TTByte.Create(FValue);
end;

function TTByte.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_BYTE;
end;

procedure TTByte.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteByte(FValue);
end;

procedure TTByte.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadByte;
end;

function TTByte.GetAsInteger: Int64;
begin
  Result := FValue;
end;

procedure TTByte.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
end;



{                                                                              }
{ TTInt16                                                                      }
{                                                                              }
constructor TTInt16.Create(const S: SmallInt);
begin
  inherited Create;
  FValue := S;
end;

function TTInt16.Duplicate: TObject;
begin
  Result := TTInt16.Create(FValue);
end;

function TTInt16.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_16;
end;

procedure TTInt16.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteWord(Word(FValue));
end;

procedure TTInt16.StreamIn(const Reader: AReaderEx);
begin
  FValue := SmallInt(Reader.ReadWord);
end;

function TTInt16.GetAsInteger: Int64;
begin
  Result := FValue;
end;

procedure TTInt16.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
end;



{                                                                              }
{ TTInt32                                                                      }
{                                                                              }
constructor TTInt32.Create(const S: LongInt);
begin
  inherited Create;
  FValue := S;
end;

function TTInt32.Duplicate: TObject;
begin
  Result := TTInt32.Create(FValue);
end;

function TTInt32.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_32;
end;

procedure TTInt32.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteInt64(FValue);
end;

procedure TTInt32.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadInt64;
end;

function TTInt32.GetAsInteger: Int64;
begin
  Result := FValue;
end;

procedure TTInt32.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
end;



{                                                                              }
{ TTInt64                                                                      }
{                                                                              }
constructor TTInt64.Create(const S: Int64);
begin
  inherited Create;
  FValue := S;
end;

function TTInt64.Duplicate: TObject;
begin
  Result := TTInt64.Create(FValue);
end;

function TTInt64.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_64;
end;

procedure TTInt64.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteInt64(FValue);
end;

procedure TTInt64.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadInt64;
end;

function TTInt64.GetAsInteger: Int64;
begin
  Result := FValue;
end;

procedure TTInt64.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
end;

function TTImmutableInteger.IsImmutable: Boolean;
begin
  Result := True;
end;



{                                                                              }
{ AFloatBase                                                                   }
{                                                                              }
procedure AFloatBase.Clear;
begin
  AsFloat := 0.0;
end;

procedure AFloatBase.Assign(const Source: TObject);
begin
  AsFloat := ObjectGetAsFloat(Source);
end;

function AFloatBase.IsEqual(const T: TObject): Boolean;
begin
  Result := ApproxEqual(ObjectGetAsFloat(T), AsFloat, ExtendedCompareEpsilon);
end;

function AFloatBase.Compare(const T: TObject): TCompareResult;
begin
  Result := ApproxCompare(AsFloat, ObjectGetAsFloat(T), ExtendedCompareEpsilon);
end;

function AFloatBase.GetAsCurrency: Currency;
begin
  Result := AsFloat;
end;

procedure AFloatBase.SetAsCurrency(const Value: Currency);
begin
  AsFloat := Value;
end;

function AFloatBase.GetAsDateTime: TDateTime;
begin
  Result := AsFloat;
end;

procedure AFloatBase.SetAsDateTime(const Value: TDateTime);
begin
  AsFloat := Value;
end;

function AFloatBase.GetAsUTF8: String;
begin
  Result := FloatToStr(AsFloat);
end;

procedure AFloatBase.SetAsUTF8(const Value: String);
begin
  AsFloat := StrToFloat(Value);
end;

function AFloatBase.GetAsInteger: Int64;
begin
  Result := Trunc(AsFloat);
end;

procedure AFloatBase.SetAsInteger(const Value: Int64);
begin
  AsFloat := Value;
end;

function AFloatBase.GetAsBoolean: Boolean;
begin
  Result := not FloatZero(AsFloat, ExtendedCompareDelta);
end;

procedure AFloatBase.SetAsBoolean(const Value: Boolean);
begin
  AsFloat := Ord(Value);
end;

procedure AFloatBase.Add(const V: TObject);
begin
  AsFloat := AsFloat + ObjectGetAsFloat(V);
end;

procedure AFloatBase.Subtract(const V: TObject);
begin
  AsFloat := AsFloat - ObjectGetAsFloat(V);
end;

procedure AFloatBase.Multiply(const V: TObject);
begin
  AsFloat := AsFloat * ObjectGetAsFloat(V);
end;

procedure AFloatBase.Divide(const V: TObject);
begin
  AsFloat := AsFloat / ObjectGetAsFloat(V);
end;

procedure AFloatBase.SetAsRational(const Numerator, Denominator: Int64);
begin
  AsFloat := Numerator / Denominator;
end;

procedure AFloatBase.Negate;
begin
  AsFloat := -AsFloat;
end;

procedure AFloatBase.Power(const V: TObject);
begin
  AsFloat := Math.Power(AsFloat, ObjectGetAsFloat(V));
end;

procedure AFloatBase.Sin;
begin
  AsFloat := System.Sin(AsFloat);
end;

procedure AFloatBase.Cos;
begin
  AsFloat := System.Cos(AsFloat);
end;

procedure AFloatBase.Ln;
begin
  AsFloat := System.Ln(AsFloat);
end;

procedure AFloatBase.Exp;
begin
  AsFloat := System.Exp(AsFloat);
end;

procedure AFloatBase.Sqr;
begin
  AsFloat := System.Sqr(AsFloat);
end;

procedure AFloatBase.Inc(const Count: Int64);
begin
  AsFloat := AsFloat + Count;
end;

procedure AFloatBase.Dec(const Count: Int64);
begin
  AsFloat := AsFloat - Count;
end;

procedure AFloatBase.Sqrt;
begin
  AsFloat := System.Sqrt(AsFloat);
end;

procedure AFloatBase.Abs;
begin
  AsFloat := System.Abs(AsFloat);
end;

function AFloatBase.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation; const RightOp: TObject): TObject;
begin
  if ObjectIsFloat(RightOp) or ObjectIsInteger(RightOp) or (RightOp is TTRational) then
    Result := Duplicate else
  if RightOp is TTComplex then
    Result := TTComplex.CreateEx(TComplex.Create(AsFloat, 0.0))
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function AFloatBase.UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject;
begin
  if (Operation = umoSqrt) and (AsFloat < 0.0) then
    Result := TTComplex.CreateEx(TComplex.Create(AsFloat, 0.0))
  else
    Result := Duplicate;
end;



{                                                                              }
{ TTSingle                                                                     }
{                                                                              }
constructor TTSingle.Create(const S: Single);
begin
  inherited Create;
  FValue := S;
end;

function TTSingle.Duplicate: TObject;
begin
  Result := TTSingle.Create(FValue);
end;

function TTSingle.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_FLOAT_SINGLE;
end;

procedure TTSingle.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteSingle(FValue);
end;

procedure TTSingle.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadSingle;
end;

function TTSingle.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TTSingle.SetAsFloat(const Value: Extended);
begin
  FValue := Value;
end;



{                                                                              }
{ TTDouble                                                                     }
{                                                                              }
constructor TTDouble.Create(const S: Double);
begin
  inherited Create;
  FValue := S;
end;

function TTDouble.Duplicate: TObject;
begin
  Result := TTDouble.Create(FValue);
end;

function TTDouble.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_FLOAT_DOUBLE;
end;

procedure TTDouble.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteDouble(FValue);
end;

procedure TTDouble.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadDouble;
end;

function TTDouble.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TTDouble.SetAsFloat(const Value: Extended);
begin
  FValue := Value;
end;



{                                                                              }
{ TTExtended                                                                   }
{                                                                              }
constructor TTExtended.Create(const S: Extended);
begin
  inherited Create;
  FValue := S;
end;

function TTExtended.Duplicate: TObject;
begin
  Result := TTExtended.Create(FValue);
end;

function TTExtended.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_FLOAT_EXTENDED;
end;

procedure TTExtended.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteExtended(FValue);
end;

procedure TTExtended.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadExtended;
end;

function TTExtended.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TTExtended.SetAsFloat(const Value: Extended);
begin
  FValue := Value;
end;

function TTImmutableFloat.IsImmutable: Boolean;
begin
  Result := True;
end;



{                                                                              }
{ TTDateTime                                                                   }
{                                                                              }
constructor TTDateTime.Create(const S: TDateTime);
begin
  inherited Create;
  FValue := S;
end;

procedure TTDateTime.Clear;
begin
  FValue := 0.0;
end;

function TTDateTime.Duplicate: TObject;
begin
  Result := TTDateTime.Create(FValue);
end;

procedure TTDateTime.Assign(const Source: TObject);
begin
  FValue := ObjectGetAsDateTime(Source);
end;

function TTDateTime.IsEqual(const T: TObject): Boolean;
begin
  Result := ObjectGetAsDateTime(T) = FValue;
end;

function TTDateTime.Compare(const T: TObject): TCompareResult;
begin
  Result := cUtils.Compare(FValue, ObjectGetAsDateTime(T));
end;

procedure TTDateTime.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteDouble(FValue);
end;

procedure TTDateTime.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadDouble;
end;

function TTDateTime.GetAsDateTime: TDateTime;
begin
  Result := FValue;
end;

procedure TTDateTime.SetAsDateTime(const Value: TDateTime);
begin
  FValue := Value;
end;

function TTDateTime.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TTDateTime.SetAsFloat(const Value: Extended);
begin
  FValue := Value;
end;

function TTDateTime.GetAsUTF8: String;
begin
  Result := FormatDateTime('d mmm yyyy hh:nn:ss', FValue);
end;

procedure TTDateTime.SetAsUTF8(const Value: String);
begin
  FValue := StrToDateTime(Value);
end;

function TTDateTime.GetAsInteger: Int64;
begin
  Result := Trunc(FValue);
end;

procedure TTDateTime.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
end;

procedure TTDateTime.Add(const V: TObject);
begin
  FValue := FValue + ObjectGetAsFloat(V);
end;

procedure TTDateTime.Subtract(const V: TObject);
begin
  FValue := FValue - ObjectGetAsFloat(V);
end;

function TTDateTime.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  if Operation in [bmoAdd, bmoSubtract] then
    Result := Duplicate else
  if ObjectIsDateTime(RightOp) then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTDateTime.GetYear: Integer;
begin
  Result := cDateTime.Year(FValue);
end;

procedure TTDateTime.SetYear(const Year: Integer);
begin
  cDateTime.SetYear(FValue, Year);
end;

function TTDateTime.GetMonth: Integer;
begin
  Result := cDateTime.Month(FValue);
end;

procedure TTDateTime.SetMonth(const Month: Integer);
begin
  cDateTime.SetMonth(FValue, Month);
end;

function TTDateTime.GetDay: Integer;
begin
  Result := cDateTime.Day(FValue);
end;

procedure TTDateTime.SetDay(const Day: Integer);
begin
  cDateTime.SetDay(FValue, Day);
end;

function TTDateTime.GetHour: Integer;
begin
  Result := cDateTime.Hour(FValue);
end;

procedure TTDateTime.SetHour(const Hour: Integer);
begin
  cDateTime.SetHour(FValue, Hour);
end;

function TTDateTime.GetMinute: Integer;
begin
  Result := cDateTime.Minute(FValue);
end;

procedure TTDateTime.SetMinute(const Minute: Integer);
begin
  cDateTime.SetMinute(FValue, Minute);
end;

function TTDateTime.GetSecond: Integer;
begin
  Result := cDateTime.Second(FValue);
end;

procedure TTDateTime.SetSecond(const Second: Integer);
begin
  cDateTime.SetSecond(FValue, Second);
end;

function TTDateTime.GetMillisecond: Integer;
begin
  Result := cDateTime.Millisecond(FValue);
end;

procedure TTDateTime.SetMillisecond(const Millisecond: Integer);
begin
  cDateTime.SetMillisecond(FValue, Millisecond);
end;

function TTDateTime.GetDayOfWeek: Integer;
begin
  Result := DayOfWeek(FValue);
end;

function TTDateTime.GetDayOfYear: Integer;
begin
  Result := cDateTime.DayOfYear(FValue);
end;

function TTDateTime.GetDaysInMonth: Integer;
begin
  Result := cDateTime.DaysInMonth(FValue);
end;

function TTDateTime.GetDaysInYear: Integer;
begin
  Result := cDateTime.DaysInYear(FValue);
end;

procedure TTDateTime.AddMilliseconds(const Milliseconds: Int64);
begin
  FValue := cDateTime.AddMilliseconds(FValue, Milliseconds);
end;

procedure TTDateTime.SetAsMilliseconds(const Milliseconds: Int64);
begin
  FValue := Milliseconds * cDateTime.OneMillisecond;
end;

function TTDateTime.GetAsMilliseconds: Int64;
begin
  Result := Round(FValue / cDateTime.OneMillisecond);
end;

function TTDateTime.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Year') then
    Result := TTInteger.Create(GetYear) else
  if StrEqualNoCase(FieldName, 'Month') then
    Result := GetImmutableInteger(GetMonth) else
  if StrEqualNoCase(FieldName, 'Day') then
    Result := GetImmutableInteger(GetDay) else
  if StrEqualNoCase(FieldName, 'Hour') then
    Result := GetImmutableInteger(GetHour) else
  if StrEqualNoCase(FieldName, 'Minute') then
    Result := GetImmutableInteger(GetMinute) else
  if StrEqualNoCase(FieldName, 'Second') then
    Result := GetImmutableInteger(GetSecond) else
  if StrEqualNoCase(FieldName, 'Millisecond') then
    Result := GetImmutableInteger(GetMillisecond) else
  if StrEqualNoCase(FieldName, 'AsMilliseconds') then
    Result := GetImmutableInteger(GetAsMilliseconds) else
  if StrEqualNoCase(FieldName, 'DayOfWeek') then
    Result := GetImmutableInteger(GetDayOfWeek) else
  if StrEqualNoCase(FieldName, 'DayOfYear') then
    Result := GetImmutableInteger(GetDayOfYear) else
  if StrEqualNoCase(FieldName, 'DaysInMonth') then
    Result := GetImmutableInteger(GetDaysInMonth) else
  if StrEqualNoCase(FieldName, 'DaysInYear') then
    Result := GetImmutableInteger(GetDaysInYear)
  else
    Result := nil;
  if Assigned(Result) then
    begin
      Scope := self;
      FieldType := bfObject;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TTDateTime.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Year') then
    SetYear(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'Month') then
    SetMonth(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'Day') then
    SetDay(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'Hour') then
    SetHour(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'Minute') then
    SetMinute(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'Second') then
    SetSecond(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'Millisecond') then
    SetMillisecond(ObjectGetAsIntegerAndRelease(Value)) else
  if StrEqualNoCase(FieldName, 'AsMilliseconds') then
    SetAsMilliseconds(ObjectGetAsIntegerAndRelease(Value))
  else
    inherited SetField(FieldName, Value);
end;

function TTDateTime.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_DATETIME;
end;



{                                                                              }
{ TTAnsiDateTime                                                               }
{                                                                              }
procedure TTAnsiDateTime.SetAsUTF8(const Value: String);
begin
  try
    SetAsInteger(StrToInt64(Value));
  except
    ConvertFromError('string');
  end;
end;

procedure TTAnsiDateTime.SetAsInteger(const Value: Int64);
begin
  try
    FValue := ANSIToDateTime(Integer(Value));
  except
    TypeError('Invalid ANSI date value');
  end;
end;

procedure TTAnsiDateTime.SetAsFloat(const Value: Extended);
begin
  SetAsInteger(Trunc(Value));
  FValue := FValue + Frac(Value);
end;

function TTAnsiDateTime.GetAsUTF8: String;
begin
  Result := IntToStr(GetAsInteger);
end;

function TTAnsiDateTime.GetAsInteger: Int64;
begin
  Result := DateTimeToANSI(FValue);
end;

function TTAnsiDateTime.GetAsFloat: Extended;
begin
  Result := GetAsInteger + Frac(FValue);
end;

function TTAnsiDateTime.Duplicate: TObject;
begin
  Result := TTAnsiDateTime.Create(FValue);
end;

function TTAnsiDateTime.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_DATETIME_ANSI;
end;



{                                                                              }
{ TTRfcDateTime                                                                }
{                                                                              }
procedure TTRfcDateTime.SetAsUTF8(const Value: String);
begin
  try
    FValue := RFCDateTimeToDateTime(Value)
  except
    ConvertFromError('string');
  end;
end;

function TTRfcDateTime.GetAsUTF8: String;
begin
  Result := DateTimeToRFCDateTime(FValue);
end;

function TTRfcDateTime.Duplicate: TObject;
begin
  Result := TTRfcDateTime.Create(FValue);
end;

function TTRfcDateTime.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_DATETIME_RFC;
end;



{                                                                              }
{ TTDuration                                                                   }
{                                                                              }
function TTDuration.GetAsUTF8: String;
begin
  Result := DateTimeAsElapsedTime(GetAsDateTime, True);
end;

function TTDuration.GetAsInteger: Int64;
begin
  Result := Round(GetAsDateTime * 24.0 * 60.0 * 60.0 * 1000.0);
end;

function TTDuration.GetAsFloat: Extended;
begin
  Result := GetAsInteger;
end;

function TTDuration.Duplicate: TObject;
begin
  Result := TTDuration.Create(FValue);
end;

function TTDuration.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_DURATION;
end;



{                                                                              }
{ TTTimer                                                                      }
{                                                                              }
function TTTimer.GetAsDateTime: TDateTime;
begin
  if FRunning then
    Result := cDateTime.AddMilliseconds(FValue,
        MillisecondsElapsed(FTimer, True))
  else
    Result := FValue;
end;

function TTTimer.GetAsBoolean: Boolean;
begin
  Result := FRunning;
end;

procedure TTTimer.Clear;
begin
  inherited Clear;
  FTimer := ElapsedTimer(0);
  FRunning := False;
end;

function TTTimer.Duplicate: TObject;
begin
  Result := TTTimer.Create(FValue);
  TTTimer(Result).Assign(self);
end;

procedure TTTimer.Assign(const Source: TObject);
begin
  if Source is TTTimer then
    begin
      FValue := TTTimer(Source).FValue;
      FTimer := TTTimer(Source).FTimer;
      FRunning := TTTimer(Source).FRunning;
    end
  else
    inherited Assign(Source);
end;

function TTTimer.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Start') or
     StrEqualNoCase(FieldName, 'Stop') then
    begin
      Scope := self;
      FieldType := bfCall;
      Result := nil;
      exit;
    end else
  if StrEqualNoCase(FieldName, 'Running') then
    Result := GetImmutableBoolean(FRunning)
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TTTimer.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Running') then
    SetRunning(ObjectGetAsBoolean(Value))
  else
    inherited SetField(FieldName, Value);
end;

function TTTimer.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Start') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Start;
    end else
  if StrEqualNoCase(FieldName, 'Stop') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Stop;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function TTTimer.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_DURATION_TIMER;
end;

procedure TTTimer.SetRunning(const Running: Boolean);
begin
  if Running then
    Start
  else
    Stop;
end;

procedure TTTimer.Start;
begin
  if FRunning then
    exit;
  FTimer := StartTimer;
  FRunning := True;
end;

procedure TTTimer.Stop;
begin
  if not FRunning then
    exit;
  StopTimer(FTimer);
  FRunning := False;
  AddMilliseconds(MillisecondsElapsed(FTimer, False));
end;



{                                                                              }
{ TTCurrency                                                                   }
{                                                                              }
constructor TTCurrency.Create(const S: Currency);
begin
  inherited Create;
  FValue := S;
end;

procedure TTCurrency.Clear;
begin
  FValue := 0.0;
end;

function TTCurrency.Duplicate: TObject;
begin
  Result := TTCurrency.Create(FValue);
end;

procedure TTCurrency.Assign(const Source: TObject);
begin
  FValue := ObjectGetAsFloat(Source);
end;

function TTCurrency.IsEqual(const T: TObject): Boolean;
begin
  Result := ObjectGetAsFloat(T) = FValue;
end;

function TTCurrency.Compare(const T: TObject): TCompareResult;
begin
  Result := cUtils.Compare(FValue, ObjectGetAsFloat(T));
end;

procedure TTCurrency.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteExtended(FValue);
end;

procedure TTCurrency.StreamIn(const Reader: AReaderEx);
begin
  FValue := Reader.ReadExtended;
end;

function TTCurrency.GetAsUTF8: String;
begin
  Result := FloatToStr(FValue);
end;

procedure TTCurrency.SetAsUTF8(const Value: String);
begin
  FValue := StrToFloat(Value);
end;

function TTCurrency.GetAsInteger: Int64;
begin
  Result := Trunc(FValue);
end;

procedure TTCurrency.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
end;

function TTCurrency.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TTCurrency.SetAsFloat(const Value: Extended);
begin
  FValue := Value;
end;

function TTCurrency.GetAsCurrency: Currency;
begin
  Result := FValue;
end;

procedure TTCurrency.SetAsCurrency(const Value: Currency);
begin
  FValue := Value;
end;

procedure TTCurrency.Add(const V: TObject);
begin
  FValue := FValue + ObjectGetAsFloat(V);
end;

procedure TTCurrency.Subtract(const V: TObject);
begin
  FValue := FValue - ObjectGetAsFloat(V);
end;

procedure TTCurrency.Negate;
begin
  FValue := -FValue;
end;

procedure TTCurrency.Multiply(const V: TObject);
begin
  FValue := FValue * ObjectGetAsFloat(V);
end;

procedure TTCurrency.Divide(const V: TObject);
begin
  FValue := FValue / ObjectGetAsFloat(V);
end;

procedure TTCurrency.Abs;
begin
  FValue := System.Abs(FValue);
end;

function TTCurrency.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
  const RightOp: TObject): TObject;
begin
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply, bmoDivide] then
    Result := Duplicate else
  if RightOp is TTCurrency then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;



{                                                                              }
{ TTRational                                                                   }
{                                                                              }
constructor TTRational.CreateEx(const S: TRational);
begin
  inherited Create;
  FValue := S;
end;

class function TTRational.CreateInstance: AType;
begin
  Result := TTRational.CreateEx(TRational.Create);
end;

function TTRational.GetAsBlaise: String;
begin
  Result := IntToStr(FValue.Numerator) + ' rdiv ' +
            IntToStr(FValue.Denominator);
end;

function TTRational.GetAsUTF8: String;
begin
  Result := FValue.AsString;
end;

function TTRational.GetAsFloat: Extended;
begin
  Result := FValue.AsReal;
end;

function TTRational.GetAsInteger: Int64;
begin
  Result := Trunc(GetAsFloat);
end;

function TTRational.GetAsBoolean: Boolean;
begin
  Result := not FValue.IsZero;
end;

procedure TTRational.SetAsUTF8(const Value: String);
begin
  FValue.AsString := Value;
end;

procedure TTRational.SetAsInteger(const Value: Int64);
begin
  FValue.Assign(Value);
end;

procedure TTRational.SetAsRational(const Numerator, Denominator: Int64);
begin
  FValue.Assign(Numerator, Denominator);
end;

procedure TTRational.SetAsFloat(const Value: Extended);
begin
  FValue.Assign(Value);
end;

procedure TTRational.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    FValue.AssignOne else
    FValue.AssignZero;
end;

constructor TTRational.Create;
begin
  inherited Create;
  FValue := TRational.Create;
end;

destructor TTRational.Destroy;
begin
  FreeAndNil(FValue);
  inherited Destroy;
end;

procedure TTRational.Clear;
begin
  FValue.AssignZero;
end;

function TTRational.Duplicate: TObject;
begin
  Result := TTRational.CreateEx(FValue.Duplicate);
end;

procedure TTRational.Assign(const Source: TObject);
begin
  if Source is TTRational then
    FValue.Assign(TTRational(Source).FValue) else
  if ObjectIsString(Source) then
    FValue.AsString := ObjectGetAsString(Source) else
  if ObjectIsUnicodeString(Source) then
    FValue.AsString := ObjectGetAsUTF8(Source) else
  if ObjectIsSimpleType(Source) then
    FValue.Assign(ObjectGetAsFloat(Source))
  else
    inherited Assign(Source);
end;

procedure TTRational.AssignTo(const Dest: TObject);
begin
  if Dest is TTRational then
    TTRational(Dest).FValue.Assign(FValue) else
  if ObjectIsString(Dest) then
    ObjectSetAsString(Dest, FValue.AsString) else
  if ObjectIsUnicodeString(Dest) then
    ObjectSetAsUTF8(Dest, FValue.AsString) else
  if ObjectIsSimpleType(Dest) then
    ObjectSetAsFloat(Dest, FValue.AsReal) 
  else
    inherited AssignTo(Dest);
end;

function TTRational.IsEqual(const T: TObject): Boolean;
begin
  if T is TTRational then
    Result := FValue.IsEqual(TTRational(T).FValue) else
  if ObjectIsSimpleType(T) then
    Result := FValue.IsEqual(ObjectGetAsFloat(T))
  else
    Result := inherited IsEqual(T);
end;

function TTRational.Compare(const T: TObject): TCompareResult;
begin
  if T is TTRational then
    Result := cUtils.Compare(FValue.AsReal, TTRational(T).FValue.AsReal) else
  if ObjectIsSimpleType(T) then
    Result := cUtils.Compare(FValue.AsReal, ObjectGetAsFloat(T))
  else
    Result := inherited Compare(T);
end;

function TTRational.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Numerator') then
    Result := GetImmutableInteger(FValue.Numerator) else
  if StrEqualNoCase(FieldName, 'Denominator') then
    Result := GetImmutableInteger(FValue.Denominator)
  else
    Result := nil;
  if Assigned(Result) then
    begin
      Scope := self;
      FieldType := bfObject;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TTRational.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Numerator') then
    FValue.Numerator := ObjectGetAsIntegerAndRelease(Value) else
  if StrEqualNoCase(FieldName, 'Denominator') then
    FValue.Denominator := ObjectGetAsIntegerAndRelease(Value) else
    inherited SetField(FieldName, Value);
end;

function TTRational.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_RATIONAL;
end;

procedure TTRational.Add(const V: TObject);
begin
  if V is TTRational then
    FValue.Add(TTRational(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Add(ObjectGetAsFloat(V)) else
    inherited Add(V);
end;

procedure TTRational.Subtract(const V: TObject);
begin
  if V is TTRational then
    FValue.Subtract(TTRational(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Subtract(ObjectGetAsFloat(V)) else
    inherited Subtract(V);
end;

procedure TTRational.Multiply(const V: TObject);
begin
  if V is TTRational then
    FValue.Multiply(TTRational(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Multiply(ObjectGetAsFloat(V)) else
    inherited Multiply(V);
end;

procedure TTRational.Divide(const V: TObject);
begin
  if V is TTRational then
    FValue.Divide(TTRational(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Divide(ObjectGetAsFloat(V)) else
    inherited Divide(V);
end;

procedure TTRational.Power(const V: TObject);
begin
  if V is TTRational then
    FValue.Power(TTRational(V).FValue) else
  if ObjectIsFloat(V) then
    FValue.Power(ObjectGetAsFloat(V)) else
  if ObjectIsInteger(V) then
    FValue.Power(ObjectGetAsInteger(V)) else
  if ObjectIsSimpleType(V) then
    FValue.Power(ObjectGetAsFloat(V)) else
    inherited Power(V);
end;

procedure TTRational.Negate;
begin
  FValue.Negate;
end;

procedure TTRational.Sqr;
begin
  FValue.Sqr;
end;

procedure TTRational.Sqrt;
begin
  FValue.Sqrt;
end;

procedure TTRational.Abs;
begin
  FValue.Abs;
end;

procedure TTRational.Exp;
begin
  FValue.Exp;
end;

procedure TTRational.Ln;
begin
  FValue.Ln;
end;

procedure TTRational.Sin;
begin
  FValue.Sin;
end;

procedure TTRational.Cos;
begin
  FValue.Cos;
end;

function TTRational.UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject;
begin
  if Operation = umoSqr then
    Result := Duplicate
  else
    Result := TTFloat.Create(GetAsFloat);
end;

function TTRational.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
  const RightOp: TObject): TObject;
begin
  if ObjectIsInteger(RightOp) or ObjectIsFloat(RightOp) or (RightOp is TTRational) then
    Result := Duplicate else
  if RightOp is TTComplex then
    Result := TTComplex.CreateEx(TComplex.Create(GetAsFloat, 0.0))
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;



{                                                                              }
{ TTComplex                                                                    }
{                                                                              }
constructor TTComplex.CreateEx(const S: TComplex);
begin
  inherited Create;
  FValue := S;
end;

constructor TTComplex.CreateEx(const Imag: Extended);
begin
  inherited Create;
  FValue := TComplex.Create(0.0, Imag);
end;

class function TTComplex.CreateInstance: AType;
begin
  Result := TTComplex.CreateEx(TComplex.Create);
end;

function TTComplex.GetAsUTF8: String;
begin
  Result := FValue.AsString;
end;

function TTComplex.GetAsFloat: Extended;
begin
  if not FloatZero(FValue.ImaginaryPart, ExtendedCompareDelta) then
    raise EConvertError.Create(
        'Can not convert an imaginary number to a real number');
  Result := FValue.RealPart;
end;

function TTComplex.GetAsInteger: Int64;
begin
  Result := Trunc(GetAsFloat);
end;

function TTComplex.GetAsBoolean: Boolean;
begin
  Result := not FValue.IsZero;
end;

procedure TTComplex.SetAsUTF8(const Value: String);
begin
  FValue.AsString := Value;
end;

procedure TTComplex.SetAsInteger(const Value: Int64);
begin
  FValue.Assign(Value);
end;

procedure TTComplex.SetAsFloat(const Value: Extended);
begin
  FValue.Assign(Value);
end;

procedure TTComplex.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    FValue.Assign(1.0)
  else
    FValue.Assign(0.0);
end;

constructor TTComplex.Create;
begin
  inherited Create;
  FValue := TComplex.Create;
end;

destructor TTComplex.Destroy;
begin
  FreeAndNil(FValue);
  inherited Destroy;
end;

procedure TTComplex.Clear;
begin
  FValue.AssignZero;
end;

function TTComplex.Duplicate: TObject;
begin
  Result := TTComplex.CreateEx(FValue.Duplicate);
end;

procedure TTComplex.Assign(const Source: TObject);
begin
  if Source is TTComplex then
    FValue.Assign(TTComplex(Source).FValue) else
  if ObjectIsString(Source) then
    FValue.AsString := ObjectGetAsString(Source) else
  if ObjectIsUnicodeString(Source) then
    FValue.AsString := ObjectGetAsUTF8(Source) else
  if ObjectIsSimpleType(Source) then
    FValue.Assign(ObjectGetAsFloat(Source))
  else
    inherited Assign(Source);
end;

procedure TTComplex.AssignTo(const Dest: TObject);
begin
  if Dest is TTComplex then
    TTComplex(Dest).FValue.Assign(FValue) else
  if Dest is TTString then
    TTString(Dest).AsString := FValue.AsString else
  if Dest is TTUnicodeString then
    TTUnicodeString(Dest).AsUTF8 := FValue.AsString else
  if ObjectIsSimpleType(Dest) then
    begin
      if not FloatZero(FValue.ImaginaryPart, ExtendedCompareDelta) then
        raise EConvertError.Create('Can not convert imaginary number to a real number');
      ObjectSetAsFloat(Dest, FValue.RealPart);
    end
  else
    inherited AssignTo(Dest);
end;

function TTComplex.IsEqual(const T: TObject): Boolean;
begin
  if T is TTComplex then
    Result := FValue.IsEqual(TTComplex(T).FValue) else
  if ObjectIsSimpleType(T) then
    Result := FValue.IsEqual(ObjectGetAsFloat(T), 0.0)
  else
    Result := inherited IsEqual(T);
end;

function TTComplex.Compare(const T: TObject): TCompareResult;
begin
  if T is TTComplex then
    begin
      Result := cUtils.Compare(FValue.ImaginaryPart, TTComplex(T).FValue.ImaginaryPart);
      if Result = crEqual then
        Result := cUtils.Compare(FValue.RealPart, TTComplex(T).FValue.RealPart);
    end else
  if ObjectIsSimpleType(T) then
    begin
      if FValue.IsReal then
        Result := cUtils.Compare(FValue.RealPart, ObjectGetAsFloat(T))
      else
        Result := crUndefined;
    end
  else
    Result := inherited Compare(T);
end;

function TTComplex.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Conjugate') or
     StrEqualNoCase(FieldName, 'Invert') then
    begin
      Scope := self;
      FieldType := bfCall;
      exit;
    end else
  if StrEqualNoCase(FieldName, 'Real') then
    Result := TTFloat.Create(FValue.RealPart) else
  if StrEqualNoCase(FieldName, 'Imaginary') then
    Result := TTFloat.Create(FValue.ImaginaryPart) else
  if StrEqualNoCase(FieldName, 'Modulo') then
    Result := TTFloat.Create(FValue.Modulo);
  if Assigned(Result) then
    begin
      Scope := self;
      FieldType := bfObject;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure TTComplex.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Real') then
    FValue.RealPart := ObjectGetAsFloatAndRelease(Value) else
  if StrEqualNoCase(FieldName, 'Imaginary') then
    FValue.ImaginaryPart := ObjectGetAsFloatAndRelease(Value)
  else
    inherited SetField(FieldName, Value);
end;

function TTComplex.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Conjugate') then
    begin
      ValidateParamCount(0, 0, Parameters);
      FValue.Conjugate;
    end else
  if StrEqualNoCase(FieldName, 'Invert') then
    begin
      ValidateParamCount(0, 0, Parameters);
      FValue.Inverse;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function TTComplex.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_COMPLEX;
end;

procedure TTComplex.Add(const V: TObject);
begin
  if V is TTComplex then
    FValue.Add(TTComplex(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Add(ObjectGetAsFloat(V)) else
    inherited Add(V);
end;

procedure TTComplex.Subtract(const V: TObject);
begin
  if V is TTComplex then
    FValue.Subtract(TTComplex(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Subtract(ObjectGetAsFloat(V)) else
    inherited Subtract(V);
end;

procedure TTComplex.Multiply(const V: TObject);
begin
  if V is TTComplex then
    FValue.Multiply(TTComplex(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Multiply(ObjectGetAsFloat(V)) else
    inherited Multiply(V);
end;

procedure TTComplex.Divide(const V: TObject);
begin
  if V is TTComplex then
    FValue.Divide(TTComplex(V).FValue) else
  if ObjectIsSimpleType(V) then
    FValue.Divide(ObjectGetAsFloat(V)) else
    inherited Divide(V);
end;

procedure TTComplex.Power(const V: TObject);
begin
  if V is TTComplex then
    begin
      FValue.Ln;
      FValue.Multiply(TTComplex(V).FValue);
      FValue.Exp;
    end else
  if ObjectIsSimpleType(V) then
    begin
      FValue.Ln;
      FValue.Multiply(ObjectGetAsFloat(V));
      FValue.Exp;
    end else
    inherited Power(V);
end;

procedure TTComplex.Negate;
begin
  FValue.Negate;
end;

procedure TTComplex.Abs;
begin
  FValue.Assign(FValue.Denom);
end;

procedure TTComplex.Sqr;
begin
  FValue.Multiply(FValue);
end;

procedure TTComplex.SetAsRational(const Numerator, Denominator: Int64);
begin
  FValue.Assign(Numerator / Denominator);
end;

procedure TTComplex.Sqrt;
begin
  FValue.Sqrt;
end;

procedure TTComplex.Exp;
begin
  FValue.Exp;
end;

procedure TTComplex.Ln;
begin
  FValue.Ln;
end;

procedure TTComplex.Sin;
begin
  FValue.Sin;
end;

procedure TTComplex.Cos;
begin
  FValue.Cos;
end;

function TTComplex.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
  const RightOp: TObject): TObject;
begin
  if ObjectIsInteger(RightOp) or ObjectIsFloat(RightOp) or (RightOp is TTRational) then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;



{                                                                              }
{ TTStatistic                                                                  }
{   ASimpleType implementation of a Statistic.                                 }
{                                                                              }
constructor TTStatistic.CreateEx(const S: TStatistic);
begin
  inherited Create;
  Assert(Assigned(S), 'Assigned(S)');
  FValue := S;
end;

constructor TTStatistic.Create;
begin
  inherited Create;
  FValue := TStatistic.Create;
end;

destructor TTStatistic.Destroy;
begin
  FreeAndNil(FValue);
  inherited Destroy;
end;

class function TTStatistic.CreateInstance: AType;
begin
  Result := TTStatistic.Create;
end;

procedure TTStatistic.Clear;
begin
  FValue.Clear;
end;

function TTStatistic.AddSamples(const Source: TObject;
    const Negate, Reset: Boolean): Boolean;
var I: Integer;
    V: Extended;
begin
  Assert(Assigned(FValue), 'Assigned(FValue)');
  Result := True;
  if ObjectIsSimpleType(Source) then
    begin
      if Reset then
        FValue.Clear;
      if Source is TTStatistic then
        if Negate then
          FValue.AddNegated(TTStatistic(Source).FValue) else
          FValue.Add(TTStatistic(Source).FValue)
      else
        begin
          V := ObjectGetAsFloat(Source);
          if Negate then
            V := -V;
          FValue.Add(V);
        end;
    end else
  if Source is ABlaiseArray then
    begin
      if Reset then
        FValue.Clear;
      For I := 0 to ABlaiseArray(Source).Count - 1 do
        begin
          V := ObjectGetAsFloat(ABlaiseArray(Source).Item[I]);
          if Negate then
            V := -V;
          FValue.Add(V);
        end
    end
  else
    Result := False;
end;

procedure TTStatistic.Assign(const Source: TObject);
begin
  if not AddSamples(Source, False, True) then
    inherited Assign(Source);
end;

procedure TTStatistic.AssignTo(const Dest: TObject);
begin
  if ObjectIsSimpleType(Dest) then
    begin
      if ObjectIsInteger(Dest) or ObjectIsFloat(Dest) or
         (Dest is TTRational) or (Dest is TTComplex) then
        ObjectSetAsFloat(Dest, GetAsFloat) else
      if ObjectIsString(Dest) then
        ObjectSetAsString(Dest, GetAsString) else
      if ObjectIsUnicodeString(Dest) then
        ObjectSetAsUTF8(Dest, GetAsUTF8)
      else
        inherited AssignTo(Dest);
    end
  else
    inherited AssignTo(Dest);
end;

function TTStatistic.Duplicate: TObject;
begin
  Result := TTStatistic.CreateEx(FValue.Duplicate);
end;

function TTStatistic.GetAsUTF8: String;
begin
  Result := FValue.GetAsString;
end;

function TTStatistic.GetAsInteger: Int64;
begin
  Result := Round(FValue.Mean);
end;

function TTStatistic.GetAsFloat: Extended;
begin
  Result := FValue.Mean;
end;

function TTStatistic.GetAsBoolean: Boolean;
begin
  Result := FValue.Count > 0;
end;

procedure TTStatistic.Negate;
begin
  FValue.Negate;
end;

procedure TTStatistic.Add(const V: TObject);
begin
  if not AddSamples(V, False, False) then
    inherited Add(V);
end;

procedure TTStatistic.Subtract(const V: TObject);
begin
  if not AddSamples(V, True, False) then
    inherited Subtract(V);
end;

procedure TTStatistic.ReversedAdd(const V: TObject);
begin
  if not AddSamples(V, False, False) then
    inherited ReversedAdd(V);
end;

procedure TTStatistic.ReversedSubtract(const V: TObject);
begin
  FValue.Negate;
  if not AddSamples(V, False, False) then
    inherited ReversedSubtract(V);
end;

function TTStatistic.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  if Operation in [bmoAdd, bmoSubtract] then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;

function TTStatistic.BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const LeftOp: TObject): TObject;
begin
  if Operation in [bmoAdd, bmoSubtract] then
    Result := Duplicate
  else
    Result := inherited BinaryOpRightCoerce(Operation, LeftOp);
end;

function TTStatistic.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Count') then
    Result := GetImmutableInteger(FValue.Count) else
  if StrEqualNoCase(FieldName, 'Min') then
    Result := TTFloat.Create(FValue.Min) else
  if StrEqualNoCase(FieldName, 'Max') then
    Result := TTFloat.Create(FValue.Max) else
  if StrEqualNoCase(FieldName, 'Range') then
    Result := TTFloat.Create(FValue.Range) else
  if StrEqualNoCase(FieldName, 'Mean') then
    Result := TTFloat.Create(FValue.Mean) else
  if StrEqualNoCase(FieldName, 'Sum') then
    Result := TTFloat.Create(FValue.Sum) else
  if StrEqualNoCase(FieldName, 'SumOfSqr') then
    Result := TTFloat.Create(FValue.SumOfSquares) else
  if StrEqualNoCase(FieldName, 'SumOfCubes') then
    Result := TTFloat.Create(FValue.SumOfCubes) else
  if StrEqualNoCase(FieldName, 'SumOfQuads') then
    Result := TTFloat.Create(FValue.SumOfQuads) else
  if StrEqualNoCase(FieldName, 'PopVar') then
    Result := TTFloat.Create(FValue.PopulationVariance) else
  if StrEqualNoCase(FieldName, 'PopStdDev') then
    Result := TTFloat.Create(FValue.PopulationStdDev) else
  if StrEqualNoCase(FieldName, 'Variance') then
    Result := TTFloat.Create(FValue.Variance) else
  if StrEqualNoCase(FieldName, 'StdDev') then
    Result := TTFloat.Create(FValue.StdDev) else
  if StrEqualNoCase(FieldName, 'M1') then
    Result := TTFloat.Create(FValue.M1) else
  if StrEqualNoCase(FieldName, 'M2') then
    Result := TTFloat.Create(FValue.M2) else
  if StrEqualNoCase(FieldName, 'M3') then
    Result := TTFloat.Create(FValue.M3) else
  if StrEqualNoCase(FieldName, 'M4') then
    Result := TTFloat.Create(FValue.M4) else
  if StrEqualNoCase(FieldName, 'Skew') then
    Result := TTFloat.Create(FValue.Skew) else
  if StrEqualNoCase(FieldName, 'Kurtosis') then
    Result := TTFloat.Create(FValue.Kurtosis)
  else
    Result := nil;
  if Assigned(Result) then
    begin
      Scope := self;
      FieldType := bfObject;
    end else
  if StrEqualNoCase(FieldName, 'Add') or StrEqualNoCase(FieldName, 'Clear') then
    begin
      Scope := self;
      FieldType := bfCall;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

function TTStatistic.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Add') then
    begin
      ValidateParamCount(1, 1, Parameters);
      AddSamples(Parameters[0], False, False);
    end else
  if StrEqualNoCase(FieldName, 'Clear') then
    begin
      ValidateParamCount(0, 0, Parameters);
      FValue.Clear;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function TTStatistic.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_STATISTIC;
end;



{                                                                              }
{ TTInfinity                                                                   }
{                                                                              }
procedure TTInfinity.Init;
begin
  inherited Init;
  FKind := PositiveInfinity;
end;

function TTInfinity.GetAsUTF8: String;
begin
  Case FKind of
    PositiveInfinity : Result := 'Infinity';
    NegativeInfinity : Result := '-Infinity';
    PositiveZero     : Result := '1/Infinity';
    NegativeZero     : Result := '-1/Infinity';
  else
    Result := '';
  end;
end;

procedure TTInfinity.Assign(const Source: TObject);
begin
  if Source is TTInfinity then
    FKind := TTInfinity(Source).FKind else
  if not (Source is ANumberType) then
    inherited Assign(Source);
end;

function TTInfinity.IsEqual(const T: TObject): Boolean;
begin
  if T is TTInfinity then
    Result := TTInfinity(T).FKind = FKind
  else
    Result := False;
end;

function TTInfinity.Compare(const T: TObject): TCompareResult;
begin
  if T is TTInfinity then
    if TTInfinity(T).FKind = FKind then
      Result := crEqual
    else
      Case FKind of
        PositiveInfinity : Result := crGreater;
        NegativeInfinity : Result := crLess;
        PositiveZero     :
          if TTInfinity(T).FKind = PositiveInfinity then
            Result := crLess
          else
            Result := crGreater;
        NegativeZero     :
          if TTInfinity(T).FKind = NegativeInfinity then
            Result := crGreater
          else
            Result := crLess;
      else
        Result := crUndefined;
      end
  else
  if T is ANumberType then
    Case FKind of
      PositiveInfinity : Result := crGreater;
      NegativeInfinity : Result := crLess;
      PositiveZero     :
        if ANumberType(T).AsFloat <= 0.0 then
          Result := crGreater
        else
          Result := crLess;
      NegativeZero     :
        if ANumberType(T).AsFloat >= 0.0 then
          Result := crLess
        else
          Result := crGreater;
    else
      Result := crUndefined;
    end
  else
    Result := inherited Compare(T);
end;

procedure TTInfinity.Negate;
begin
  Case FKind of
    PositiveInfinity : FKind := NegativeInfinity;
    NegativeInfinity : FKind := PositiveInfinity;
    PositiveZero     : FKind := NegativeZero;
    NegativeZero     : FKind := PositiveZero;
  end;
end;

procedure TTInfinity.Add(const V: TObject);
begin
  inherited Add(V);
end;

procedure TTInfinity.Subtract(const V: TObject);
begin
  inherited Subtract(V);
end;

procedure TTInfinity.Multiply(const V: TObject);
begin
  inherited Multiply(V);
end;

procedure TTInfinity.Divide(const V: TObject);
begin
  inherited Divide(V);
end;

procedure TTInfinity.Power(const V: TObject);
begin
  inherited Power(V);
end;

procedure TTInfinity.Abs;
begin
  Case FKind of
    NegativeInfinity : FKind := PositiveInfinity;
    NegativeZero     : FKind := PositiveZero;
  end;
end;

procedure TTInfinity.Sqr;
begin
  Abs;
end;

function TTInfinity.UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject;
begin
  if Operation in [umoSqr] then
    Result := Duplicate
  else
    Result := inherited UnaryOpCoerce(Operation);
end;

function TTInfinity.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  if Operation in [bmoAdd, bmoSubtract, bmoMultiply, bmoDivide, bmoPower] then
    Result := Duplicate
  else
    Result := inherited BinaryOpLeftCoerce(Operation, RightOp);
end;



{                                                                              }
{ TSimpleTypeDefinition                                                        }
{                                                                              }
constructor TSimpleTypeDefinition.Create(const TypeClass: CBlaiseType);
begin
  inherited Create;
  FTypeClass := TypeClass;
end;

procedure TSimpleTypeDefinition.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
end;

function TSimpleTypeDefinition.CreateTypeInstance: TObject;
begin
  Result := FTypeClass.CreateInstance;
end;

function TSimpleTypeDefinition.IsType(const Value: TObject): Boolean;
begin
  Result := Value.InheritsFrom(FTypeClass);
end;

function TSimpleTypeDefinition.IsVariablesAutoInstanciate: Boolean;
begin
  Result := True;
end;

procedure TSimpleTypeDefinition.StreamOut(const Writer: AWriterEx);
begin
end;

procedure TSimpleTypeDefinition.StreamIn(const Reader: AReaderEx);
begin
end;



{                                                                              }
{ TStringType                                                                  }
{                                                                              }
constructor TStringType.Create;
begin
  inherited Create(TTString);
end;

function TStringType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_STRING;
end;



{                                                                              }
{ TBase64BinaryType                                                            }
{                                                                              }
constructor TBase64BinaryType.Create;
begin
  inherited Create(TTBase64Binary);
end;

function TBase64BinaryType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_BINARY_BASE64;
end;



{                                                                              }
{ TURLType                                                                     }
{                                                                              }
constructor TURLType.Create;
begin
  inherited Create(TTURL);
end;

function TURLType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_STRING_URL;
end;



{                                                                              }
{ TUnicode8Type                                                                }
{                                                                              }
constructor TUnicode8Type.Create;
begin
  inherited Create(TTUnicode8);
end;



{                                                                              }
{ TUnicode16Type                                                               }
{                                                                              }
constructor TUnicode16Type.Create;
begin
  inherited Create(TTUnicode16);
end;



{                                                                              }
{ TUnicodeType                                                                 }
{                                                                              }
constructor TUnicodeType.Create;
begin
  inherited Create(TTUnicodeString);
end;

function TUnicodeType.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Create') then
    begin
      Scope := self;
      FieldType := bfCall;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

function TUnicodeType.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
var T: TUnicodeCodecType;
    N: String;
begin
  if StrEqualNoCase(FieldName, 'Create') then
    begin
      ValidateParamCount(1, 1, Parameters);
      N := ObjectGetAsUTF8(Parameters[0]);
      T := GetUnicodeCodecTypeByName(N);
      if T = ucCustom then
        ParameterError('Invalid encoding name: ' + N);
      Result := TTUnicodeString.Create('', T);
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function TUnicodeType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_UNICODE;
end;



{                                                                              }
{ TCharType                                                                    }
{                                                                              }
constructor TCharType.Create;
begin
  inherited Create(TTChar);
end;

function TCharType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_CHAR;
end;



{                                                                              }
{ TUnicodeCharType                                                             }
{                                                                              }
constructor TUnicodeCharType.Create;
begin
  inherited Create(TTUnicodeChar);
end;

function TUnicodeCharType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_UNICODECHAR;
end;



{                                                                              }
{ TByteType                                                                    }
{                                                                              }
constructor TByteType.Create;
begin
  inherited Create(TTByte);
end;

function TByteType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_BYTE;
end;



{                                                                              }
{ TInt16Type                                                                   }
{                                                                              }
constructor TInt16Type.Create;
begin
  inherited Create(TTInt16);
end;

function TInt16Type.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_16;
end;



{                                                                              }
{ TInt32Type                                                                   }
{                                                                              }
constructor TInt32Type.Create;
begin
  inherited Create(TTInt32);
end;

function TInt32Type.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_32;
end;



{                                                                              }
{ TInt64Type                                                                   }
{                                                                              }
constructor TInt64Type.Create;
begin
  inherited Create(TTInt64);
end;

function TInt64Type.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_INTEGER_64;
end;



{                                                                              }
{ TSingleFloatType                                                             }
{                                                                              }
constructor TSingleFloatType.Create;
begin
  inherited Create(TTSingle);
end;

function TSingleFloatType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_FLOAT_SINGLE;
end;



{                                                                              }
{ TDoubleFloatType                                                             }
{                                                                              }
constructor TDoubleFloatType.Create;
begin
  inherited Create(TTDouble);
end;

function TDoubleFloatType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_FLOAT_DOUBLE;
end;



{                                                                              }
{ TExtendedFloatType                                                           }
{                                                                              }
constructor TExtendedFloatType.Create;
begin
  inherited Create(TTExtended);
end;

function TExtendedFloatType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_FLOAT_EXTENDED;
end;



{                                                                              }
{ TBooleanType                                                                 }
{                                                                              }
constructor TBooleanType.Create;
begin
  inherited Create(TTBoolean);
end;

function TBooleanType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_BOOLEAN;
end;



{                                                                              }
{ TDateTimeType                                                                }
{                                                                              }
constructor TDateTimeType.Create;
begin
  inherited Create(TTDateTime);
end;

function TDateTimeType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DATETIME;
end;



{                                                                              }
{ TAnsiDateTimeType                                                            }
{                                                                              }
constructor TAnsiDateTimeType.Create;
begin
  inherited Create(TTAnsiDateTime);
end;

function TAnsiDateTimeType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DATETIME_ANSI;
end;



{                                                                              }
{ TRfcDateTimeType                                                             }
{                                                                              }
constructor TRfcDateTimeType.Create;
begin
  inherited Create(TTRfcDateTime);
end;

function TRfcDateTimeType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DATETIME_RFC;
end;



{                                                                              }
{ TDurationType                                                                }
{                                                                              }
constructor TDurationType.Create;
begin
  inherited Create(TTDuration);
end;

function TDurationType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DURATION;
end;



{                                                                              }
{ TTimerType                                                                   }
{                                                                              }
constructor TTimerType.Create;
begin
  inherited Create(TTTimer);
end;

function TTimerType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_DURATION_TIMER;
end;



{                                                                              }
{ TCurrencyType                                                                }
{                                                                              }
constructor TCurrencyType.Create;
begin
  inherited Create(TTCurrency);
end;

function TCurrencyType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_CURRENCY;
end;



{                                                                              }
{ TRationalType                                                                }
{                                                                              }
constructor TRationalType.Create;
begin
  inherited Create(TTRational);
end;

function TRationalType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_RATIONAL;
end;



{                                                                              }
{ TComplexType                                                                 }
{                                                                              }
constructor TComplexType.Create;
begin
  inherited Create(TTComplex);
end;

function TComplexType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_COMPLEX;
end;



{                                                                              }
{ TStatisticType                                                               }
{                                                                              }
constructor TStatisticType.Create;
begin
  inherited Create(TTStatistic);
end;

function TStatisticType.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_STATISTIC;
end;



{                                                                              }
{ Immutable values                                                             }
{                                                                              }
var
  ImmutableBooleans  : Array[Boolean] of TTBoolean = (nil, nil);
  ImmutableIntegers  : Array[-128..366] of TTInteger;
  ImmutableFloatZero : TTFloat = nil;
  ImmutableInfinity  : TTInfinity = nil;

function GetImmutableBoolean(const Value: Boolean): TTBoolean;
begin
  Result := ImmutableBooleans[Value];
  if not Assigned(Result) then
    begin
      Result := TTImmutableBoolean.Create(Value);
      ObjectAddReference(Result);
      ImmutableBooleans[Value] := Result;
    end;
end;

function GetImmutableInteger(const Value: Int64): TTInteger;
begin
  if (Value <= 366) and (Value >= -128) then
    begin
      Result := ImmutableIntegers[Value];
      if not Assigned(Result) then
        begin
          Result := TTImmutableInteger.Create(Value);
          ObjectAddReference(Result);
          ImmutableIntegers[Value] := Result;
        end;
    end
  else
    Result := TTImmutableInteger.Create(Value);
end;

function GetImmutableFloatZero: TTFloat;
begin
  Result := ImmutableFloatZero;
  if not Assigned(Result) then
    begin
      Result := TTImmutableFloat.Create(0.0);
      ObjectAddReference(Result);
      ImmutableFloatZero := Result;
    end;
end;

function GetImmutableInfinity: TTInfinity;
begin
  Result := ImmutableInfinity;
  if not Assigned(Result) then
    begin
      Result := TTInfinity.Create;
      ObjectAddReference(Result);
      ImmutableInfinity := Result;
    end;
end;

procedure ReleaseImmutableValues;
var I : Integer;
begin
  ObjectReleaseReferenceAndNil(ImmutableInfinity);
  ObjectReleaseReferenceAndNil(ImmutableFloatZero);
  For I := -128 to 366 do
    ObjectReleaseReferenceAndNil(ImmutableIntegers[I]);
  ObjectReleaseReferenceAndNil(ImmutableBooleans[False]);
  ObjectReleaseReferenceAndNil(ImmutableBooleans[True]);
end;



initialization
  FillChar(ImmutableIntegers, Sizeof(ImmutableIntegers), #0);
finalization
  ReleaseImmutableValues;
end.

