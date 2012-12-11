{                                                                              }
{                            Blaise base classes v0.06                         }
{                                                                              }
{     This unit is copyright © 1999-2003 by David J Butler (david@e.co.za)     }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{                Its original file name is cBlaiseTypes.pas                    }
{                                                                              }
{ Description:                                                                 }
{   This unit defines the interfaces for Blaise data structures.               }
{                                                                              }
{ Revision history:                                                            }
{   08/06/2002  0.01  Created cBlaiseTypes from cDataStructs.                  }
{   05/03/2003  0.02  Documentation and revision.                              }
{   15/03/2003  0.03  Added callable scope fields.                             }
{   16/03/2003  0.04  Added auto instanciated variables.                       }
{   29/03/2003  0.05  Added streaming.                                         }
{   26/04/2003  0.06  UnassignedValue.                                         }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseTypes;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cStreams,
  cTypes;



{                                                                              }
{ Exceptions                                                                   }
{                                                                              }
type
  EBlaiseError = class(Exception);
  EBlaiseScopeError = class(EBlaiseError);
  EBlaiseParameterError = class(EBlaiseError);



{                                                                              }
{ ABlaiseType                                                                  }
{   Base class for a Blaise data structures.                                   }
{                                                                              }
{   The main features of ABlaiseType defined here are 'reference counting',    }
{   a 'scope interface' and 'representations'.                                 }
{                                                                              }
{   Reference counting is implemented using calls to AddReference,             }
{   RemoveReference and ReleaseUnreferenced. AddReference is called to signal  }
{   a new reference to the instance. Every call to AddReference must be        }
{   matched by a call to RemoveReference when the instance is no longer        }
{   referenced by the caller of AddReference. When there are no references     }
{   left to an instance, RemoveReference calls the virtual procedure           }
{   InstanceUnreferenced. The default behaviour of InstanceUnreferenced is     }
{   to free the instance.                                                      }
{                                                                              }
{   A call to ReleaseUnreferenced will call InstanceUnreferenced if there are  }
{   no references to it. ReleaseUnreferenced is used in cases where instances  }
{   are created with no reference, for example, some functions can return a    }
{   newly created unreferenced instance.                                       }
{                                                                              }
{   IsUniqueReference returns True if an instance does not have more than one  }
{   reference to it. This is used when a 'copy-on-write' strategy is used.     }
{   The GetUnique function returns self if an instance is unique, otherwise    }
{   a duplicate of the instance is returned. GetUnique can return an instance  }
{   with a reference count of 0, therefore every call to GetUnique must be     }
{   followed by a call to ReleaseUnreferenced on the result.                   }
{                                                                              }
{   The 'scope interface' allows access to a data structure's items based on   }
{   an identifier string. Implementations should implement the GetField,       }
{   SetField, DeleteField and CallField methods. The 'scope helper methods'    }
{   are implemented using calls to GetField, SetField, DeleteField and         }
{   CallField.                                                                 }
{                                                                              }
{   After a call to GetField, the returned result is the instance identified   }
{   by FieldName, and Scope contains the instance actually responsible for     }
{   that field. If the identifier was not found, Scope contains nil. If the    }
{   returned FieldType is bfCall, the field is a 'virtual function' that       }
{   can be called using CallField.                                             }
{                                                                              }
{   GetAsString returns the human readable version of the instance data as a   }
{   string in native format. GetAsUTF returns the same as GetAsString, but as  }
{   an UTF encoded Unicode string. The default implementation of AsString,     }
{   AsUTF16 and AsBlaise assume that AsUTF8 is implemented. GetAsBlaise        }
{   returns a string containing the instance data as a string in Blaise script }
{   syntax, if possible. The default implementation of GetAsBlaise calls       }
{   GetAsUTF8.                                                                 }
{                                                                              }
{   StreamOut and StreamIn writes/reads the instance data in a packed          }
{   binary format. GetTypeID is used in streaming to identify the type of      }
{   this object; it returns the TypeDefID of the ATypeDefinition of the type   }
{   of the value.                                                              }
{                                                                              }
type
  ATypeDefinition = class;
  TBlaiseFieldType = (bfObject, bfCall);
  TBlaiseEvalType = (beNone, beField, beFieldCall, beFunctionCall,
      beMachineCall);
  ABlaiseDataModule = class;
  ABlaiseType = class(AType)
  protected
    { Reference counting                                                       }
    FReferenceCount : Integer;

    procedure InstanceUnreferenced; virtual;

    { String representations                                                   }
    function  GetAsString: String; override;
    function  GetAsUTF8: String; virtual;
    function  GetAsUTF16: WideString; virtual;
    procedure SetAsString(const Value: String); override;
    procedure SetAsUTF8(const Value: String); virtual;
    procedure SetAsUTF16(const Value: WideString); virtual;
    function  GetAsBlaise: String; virtual;

  public
    { Exceptions                                                               }
    procedure ScopeError(const Msg: String);
    procedure IdentifierError(const Identifier, Msg: String);
    procedure IdentifierNotDefinedError(const Identifier: String);

    { Reference counting                                                       }
    procedure AddReference;
    procedure ReleaseReference;
    procedure ReleaseUnreferenced;
    procedure DecReference;
    function  IsUniqueReference: Boolean;
    function  IsUnreferenced: Boolean;

    { Scope interface                                                          }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; virtual;
    procedure SetField(const FieldName: String; const Value: TObject); virtual;
    procedure DeleteField(const FieldName: String); virtual;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; virtual;

    { Scope helper methods: Get                                                }
    function  GetIdentifier(const Identifier: String; const Required: Boolean;
              var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
    function  GetValue(const Identifier: String; const Required: Boolean;
              var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
    function  GetValueAsType(const Identifier: String; const Required: Boolean;
              const ValueClass: TClass; const ErrorMsg: String): TObject;
    function  GetValueAsTypeDefinition(const Identifier: String;
              const Required: Boolean): ATypeDefinition;

    { Scope helper methods: Evalute                                            }
    function  EvaluateImmediate(const Identifier: String;
              const Parameters: Array of TObject;
              const IdentifierRequired, CallRequired: Boolean;
              var EvalType: TBlaiseEvalType; var MachineCode: Pointer): TObject;
    function  Evaluate(const Identifier: String;
              const Parameters: Array of TObject;
              const IdentifierRequired, CallRequired,
              ReleaseParameters: Boolean): TObject; overload;
    function  Evaluate(const Identifier: String): TObject; overload;
    procedure Execute(const Identifier: String;
              const Parameters: Array of TObject;
              const ReleaseParameters: Boolean); overload;
    procedure Execute(const Identifier: String); overload;

    { Scope helper methods: Set                                                }
    procedure AssignIdentifier(const Identifier: String; const Value: TObject);
    procedure SetConstant(const Identifier: String; const Value: TObject);
    procedure AddVariable(const Identifier: String;
              const TypeDefinition: ATypeDefinition; const Value: TObject);
    procedure AddConstant(const Identifier: String;
              const TypeDefinition: ATypeDefinition; const Value: TObject);

    { Unicode representation                                                   }
    property  AsUTF8: String read GetAsUTF8 write SetAsUTF8;
    property  AsUTF16: WideString read GetAsUTF16 write SetAsUTF16;

    { Blaise representation                                                    }
    property  AsBlaise: String read GetAsBlaise;

    { Binary stream                                                            }
    function  GetTypeID: Byte; virtual;
    procedure StreamOut(const Writer: AWriterEx); virtual;
    procedure StreamIn(const Reader: AReaderEx); virtual;

    { Attributes                                                               }
    function  IsImmutable: Boolean; virtual;
  end;
  CBlaiseType = class of ABlaiseType;
  ABlaiseTypeArray = Array of ABlaiseType;
  EBlaiseType = class(EBlaiseError);
  EBlaiseBinaryStream = class(EBlaiseError);



{                                                                              }
{ ABlaiseDataModule                                                            }
{   Base class for a Blaise data module.                                       }
{                                                                              }

  ABlaiseDataModule = class
  public
    function  GetString(const Offset: Integer): String; virtual; abstract;
  end;



{                                                                              }
{ ATypeDefinition                                                              }
{   Base class for a Blaise type definition.                                   }
{                                                                              }
{   CreateTypeInstance creates an instance of the Blaise data structure        }
{   defined by the type definition.                                            }
{                                                                              }
{   IsType returns True if Value has the same Blaise type definition.          }
{                                                                              }
{   ResolveType returns the ultimate type definition.                          }
{                                                                              }
{   IsVariablesAutoInstanciate returns True if variables of this type are      }
{   automatically instanciated when declared. It returns False if variables    }
{   of this type are initialized to 'unassigned' when declared.                }
{                                                                              }
{   Coerce either returns Value if Value is already of the type, or it         }
{   returns a new instance of the type that is equivalent to Value.            }
{                                                                              }
{   GetTypeID returns the unique ID used in streaming.                         }
{                                                                              }

  ATypeDefinition = class(ABlaiseType)
  protected
    procedure TypeDefinitionError(const Msg: String);
    procedure CoerceError(const Value: TObject; const Msg: String);

  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;

    { ATypeDefinition                                                          }
    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); virtual;
    function  CreateTypeInstance: TObject; virtual;
    function  IsType(const Value: TObject): Boolean; virtual;
    function  ResolveType: ATypeDefinition; virtual;
    function  IsVariablesAutoInstanciate: Boolean; virtual;

    function  Coerce(const Value: TObject): TObject;
    function  CoerceAndReleaseUnreferenced(const Value: TObject): TObject;

    function  GetTypeDefID: Byte; virtual;
  end;
  CTypeDefinition = class of ATypeDefinition;
  ETypeDefinition = class(EBlaiseType);
  ATypeDefinitionArray = Array of ATypeDefinition;



{                                                                              }
{ ALocalisedTypeDefinition                                                     }
{   Base class for a Blaise type definition that requires to know the scope    }
{   where it was defined.                                                      }
{                                                                              }
type
  ALocalisedTypeDefinition = class(ATypeDefinition)
  protected
    FDefinitionScope : ABlaiseType;

  public
    procedure SetDefinitionScope(const DefinitionScope: ABlaiseType); override;
    property  DefinitionScope: ABlaiseType read FDefinitionScope;
  end;



{                                                                              }
{ AValueReference                                                              }
{   Base class for a value reference class.                                    }
{                                                                              }
{   A value reference acts as a proxy for another value.                       }
{                                                                              }
type
  AValueReference = class
  protected
    procedure RaiseError(const Msg: String); virtual;

  public
    function  GetValue: TObject; virtual;
    procedure AssignValue(const Value: TObject); virtual;
  end;
  EValueReference = class(EBlaiseError);



{                                                                              }
{ TScopeValue                                                                  }
{   Implementation of AValueReference for Blaise variables.                    }
{                                                                              }
{   TScopeValue can act as a container for constants and typed values.         }
{                                                                              }
type
  TScopeValueAttributes = Set of (
      svaConstant,
      svaTyped,
      svaAutoInstanciate);
  TScopeValue = class(AValueReference)
  protected
    FValue          : TObject;
    FAttributes     : TScopeValueAttributes;
    FTypeDefinition : ATypeDefinition;

    procedure InitValue(const Value: TObject;
              const TypeDefinition: ATypeDefinition);
    procedure SetValue(const Value: TObject);

  public
    constructor Create(const Value: TObject;
                const Attributes: TScopeValueAttributes;
                const TypeDefinition: ATypeDefinition);
    constructor CreateConstant(const Value: TObject);
    constructor CreateTyped(const Value: TObject;
                const TypeDefinition: ATypeDefinition);
    constructor CreateAutoInstanciate(const TypeDefinition: ATypeDefinition);

    destructor Destroy; override;

    procedure Clear;

    procedure AssignValue(const Value: TObject); override;
    function  GetValue: TObject; override;

    property  Value: TObject read FValue;
    property  Attributes: TScopeValueAttributes read FAttributes;
    property  TypeDefinition: ATypeDefinition read FTypeDefinition;
  end;



{                                                                              }
{ TTUnassigned                                                                 }
{   Special value to indicate an unassigned value reference.                   }
{                                                                              }
type
  TTUnassigned = class
  end;

var
  UnassignedValue : TTUnassigned = nil;



{                                                                              }
{ AScopeFieldDefinition                                                        }
{   Base class for the definition of scope entries (scope fields).             }
{                                                                              }
{   GetFieldID returns the unique ID used by streaming.                        }
{                                                                              }
type
  AScopeFieldDefinition = class
  protected
    procedure Init; virtual;
    procedure RaiseError(const Msg: String); virtual;

  public
    constructor Create;

    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
              virtual; abstract;

    function  GetFieldID: Byte; virtual;
    procedure StreamOut(const Writer: AWriterEx); virtual;
    procedure StreamIn(const Reader: AReaderEx); virtual;
  end;
  EScopeFieldDefinition = class(EBlaiseError);
  CScopeFieldDefinition = class of AScopeFieldDefinition;
  AScopeFieldDefinitionArray = Array of AScopeFieldDefinition;



{                                                                              }
{ ASimpleFieldDefinition                                                       }
{   Base class for a field definition with an identifier, a type definition    }
{   and a value.                                                               }
{                                                                              }
type
  ASimpleFieldDefinition = class(AScopeFieldDefinition)
  protected
    FIdentifier     : String;
    FTypeDefinition : ATypeDefinition;
    FValue          : TObject;

  public
    constructor Create(const Identifier: String;
                const TypeDefinition: ATypeDefinition;
                const Value: TObject);
    destructor Destroy; override;

    property  Identifier: String read FIdentifier;
    property  TypeDefinition: ATypeDefinition read FTypeDefinition;
    property  Value: TObject read FValue;

    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ TVariableFieldDefinition                                                     }
{   Implementation of a field definition for a variable.                       }
{                                                                              }
type
  TVariableFieldDefinition = class(ASimpleFieldDefinition)
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TConstantFieldDefinition                                                     }
{   Implementation of a field definition for a constant (read-only value).     }
{                                                                              }
type
  TConstantFieldDefinition = class(ASimpleFieldDefinition)
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ TTypeFieldDefinition                                                         }
{   Implementation of a field definition for a type declaration.               }
{                                                                              }
type
  TTypeFieldDefinition = class(ASimpleFieldDefinition)
    constructor Create(const Identifier: String; const TypeDefinition: ATypeDefinition);
    procedure AddToScope(const FieldScope, DefinitionScope: ABlaiseType); override;
    function  GetFieldID: Byte; override;
  end;



{                                                                              }
{ AFunction                                                                    }
{   Base class for a callable value.                                           }
{                                                                              }
{   AFunction implementations must override GetParameters and either Call or   }
{   GetCompiled.                                                               }
{                                                                              }
{   GetMachineCode returns a pointer to the compiled virtual machine code for  }
{   the function. It returns nil if this function has no machine code, in      }
{   which case the function is invoked using a call to the Call method.        }
{                                                                              }
{   Machine code functions must also implement CreateLocalScope.               }
{                                                                              }
{   Delphi implemented functions can call ValidateParameters to check if a     }
{   set of parameter values are valid.                                         }
{                                                                              }
type
  TParameterAttributes = Set of
      (paOptional,       // Parameter has a default value
       paReference);     // Parameter must be AValueReference
  TParameterAttributesArray = Array of TParameterAttributes;
  AFunction = class(ABlaiseType)
  protected
    procedure FunctionError(const Msg: String);

  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;

    { AFunction                                                                }
    function  GetParameters: TParameterAttributesArray; virtual;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; virtual;
    function  GetMachineCode: Pointer; virtual;
    function  CreateLocalScope(const Scope: ABlaiseType;
              const Parameters: Array of TObject): ABlaiseType; virtual;
  end;
  EFunction = class(EBlaiseType);



{                                                                              }
{ AUnaryScopeFunction                                                          }
{   Base class for a scope function whose call requires a single parameter.    }
{                                                                              }
type
  TUnaryFunction = function (const A: TObject): TObject;
  AUnaryScopeFunction = class(AFunction)
  protected
    FFunc   : TUnaryFunction;
    FParams : TParameterAttributesArray;

  public
    constructor Create(const Func: TUnaryFunction);

    function  GetParameters: TParameterAttributesArray; override;
    function  Call(const Scope: ABlaiseType;
              const Parameters: Array of TObject): TObject; override;
  end;



{                                                                              }
{ ABlaiseMathType                                                              }
{   Abstract base class for a data type that can take part in a mathematical   }
{   expression.                                                                }
{                                                                              }
{   The interface of ABlaiseMathType distinguishes between unary and binary    }
{   operations. An unary operator takes a single operand, for example Sqrt(X), }
{   while a binary operator takes two operands, for example X + Y (addition).  }
{                                                                              }
{   Before doing an unary operation, call UnaryOpCoerce to determine the type  }
{   required to store the result of the operation. For binary operations,      }
{   call BinaryOpLeftCoerce and/or BinaryOpRightCoerce. The Coerce functions   }
{   can return one of the following results:                                   }
{       i) nil - indicating that the operand do not know what type the result  }
{          will be or that the operation is not supported by the operand.      }
{      ii) self - indicating that the operand (or a duplicate of it) can       }
{          calculate the result using an in-place operation.                   }
{     iii) Duplicate(self) - indicating that the operand can calculate the     }
{          result in-place in a copy of itself.                                }
{      iv) New object - indicating that the new object should be used to       }
{          calculate the operation.                                            }
{   If the result from BinaryOpRightCoerce is used, the in-place calculation   }
{   must be done using the ReversedXXX method, with the left operand as        }
{   parameter. For example, if BinaryOpRightCoerce is called for addition,     }
{   RightOp.ReversedAdd(LeftOp) must be called, and if BinaryOpLeftCoerce is   }
{   used, LeftOp.Add(RightOp) must be called.                                  }
{                                                                              }
type
  TUnaryMathOperation = (
                         umoSqr, umoSqrt,
                         umoExp, umoLn,
                         umoSin, umoCos);
  TBinaryMathOperation = (
                          bmoAdd, bmoSubtract, bmoMultiply, bmoDivide,
                          bmoPower,
                          bmoIntegerDivide, bmoModulo,
                          bmoLogicalAND, bmoLogicalOR, bmoLogicalXOR,
                          bmoBitwiseSHL, bmoBitwiseSHR
                          );
  TBinaryOperationFunc = function (const A, B: TObject): TObject;
  ABlaiseMathType = class(ABlaiseType)
  protected
    { Exceptions                                                               }
    procedure OperationNotSupportedError(const Operation: String; const V: TObject = nil);

  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;

    { ABlaiseMathType                                                          }
    procedure Abs; virtual;
    procedure Negate; virtual;

    procedure Add(const V: TObject); virtual;
    procedure Subtract(const V: TObject); virtual;
    procedure Multiply(const V: TObject); virtual;
    procedure Divide(const V: TObject); virtual;

    procedure ReversedAdd(const V: TObject); virtual;
    procedure ReversedSubtract(const V: TObject); virtual;
    procedure ReversedMultiply(const V: TObject); virtual;
    procedure ReversedDivide(const V: TObject); virtual;

    procedure Sqr; virtual;
    procedure Sqrt; virtual;
    procedure Exp; virtual;
    procedure Ln; virtual;
    procedure Sin; virtual;
    procedure Cos; virtual;

    procedure Power(const V: TObject); virtual;
    procedure ReversedPower(const V: TObject); virtual;

    procedure IntegerDivide(const V: TObject); virtual;
    procedure Modulo(const V: TObject); virtual;

    procedure ReversedIntegerDivide(const V: TObject); virtual;
    procedure ReversedModulo(const V: TObject); virtual;

    procedure LogicalAND(const V: TObject); virtual;
    procedure LogicalOR(const V: TObject); virtual;
    procedure LogicalXOR(const V: TObject); virtual;

    procedure ReversedLogicalAND(const V: TObject); virtual;
    procedure ReversedLogicalOR(const V: TObject); virtual;
    procedure ReversedLogicalXOR(const V: TObject); virtual;

    procedure LogicalNOT; virtual;

    procedure BitwiseSHL(const V: TObject); virtual;
    procedure BitwiseSHR(const V: TObject); virtual;

    procedure ReversedBitwiseSHL(const V: TObject); virtual;
    procedure ReversedBitwiseSHR(const V: TObject); virtual;

    function  UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject; virtual;

    function  BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
              const RightOp: TObject): TObject; virtual;
    function  BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
              const LeftOp: TObject): TObject; virtual;
  end;
  EBlaiseMathType = class(EBlaiseType);



{                                                                              }
{ ASimpleType                                                                  }
{   Abstract base class for a data type that can be represented as one or      }
{   more of the simple types (string, integer and real).                       }
{                                                                              }
type
  ASimpleType = class(ABlaiseMathType)
  protected
    { Exceptions                                                               }
    procedure ConvertFromError(const T: String);
    procedure ConvertToError(const T: String);

    { Representations                                                          }
    procedure SetAsUTF8(const Value: String); override;
    procedure SetAsInteger(const Value: Int64); virtual;
    procedure SetAsFloat(const Value: Extended); virtual;
    procedure SetAsCurrency(const Value: Currency); virtual;
    procedure SetAsDateTime(const Value: TDateTime); virtual;
    procedure SetAsBoolean(const Value: Boolean); virtual;

    function  GetAsUTF8: String; override;
    function  GetAsInteger: Int64; virtual;
    function  GetAsFloat: Extended; virtual;
    function  GetAsCurrency: Currency; virtual;
    function  GetAsDateTime: TDateTime; virtual;
    function  GetAsBoolean: Boolean; virtual;

  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;

    { Representations                                                          }
    property  AsInteger: Int64 read GetAsInteger write SetAsInteger;
    property  AsFloat: Extended read GetAsFloat write SetAsFloat;
    property  AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property  AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property  AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    procedure SetAsRational(const Numerator, Denominator: Int64); virtual;

    { Operations                                                               }
    procedure Inc(const Count: Int64); virtual;
    procedure Dec(const Count: Int64); virtual;
  end;
  ESimpleType = class(EBlaiseMathType);



{                                                                              }
{ ANumberType                                                                  }
{   Base class for a Blaise number structure.                                  }
{                                                                              }
type
  ANumberType = class(ASimpleType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ APseudoNumberType                                                            }
{   Base class for a Blaise pseudo-number structure.                           }
{                                                                              }
type
  APseudoNumberType = class(ASimpleType)
  end;



{                                                                              }
{ AIntegerNumberType                                                           }
{   Base class for a Blaise integer number structure.                          }
{                                                                              }
type
  AIntegerNumberType = class(ANumberType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ ARealNumberType                                                              }
{   Base class for a Blaise real number structure.                             }
{                                                                              }
type
  ARealNumberType = class(ANumberType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ ADateTimeType                                                                }
{   Base class for a Blaise date/time structure.                               }
{                                                                              }
type
  ADateTimeType = class(ANumberType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ ABlaiseIterator                                                              }
{   Base class for a Blaise iterator structure.                                }
{                                                                              }
type
  ABlaiseIterator = class(ABlaiseType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;

    { ABlaiseIterator                                                          }
    function  EOF: Boolean; virtual;
    function  Next: TObject; virtual;
  end;
  EBlaiseIterator = class(EBlaiseType);



{                                                                              }
{ ASubrangeTypeDefinition                                                      }
{   Base class for a range type.                                               }
{                                                                              }
type
  ASubrangeTypeDefinition = class(ATypeDefinition)
  protected
    FMin : Int64;
    FMax : Int64;

  public
    constructor Create(const Min, Max: Int64);

    property  Min: Int64 read FMin;
    property  Max: Int64 read FMax;

    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;



{                                                                              }
{ AOrderedListType                                                             }
{   Base class for ordered list structures.                                    }
{                                                                              }
type
  AOrderedListType = class(ABlaiseMathType)
  protected
    { ABlaiseType                                                              }
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;

    { AOrderedListType                                                         }
    function  GetCount: Integer; virtual;
    procedure SetCount(const Count: Integer); virtual;
    function  GetItem(const Idx: Integer): TObject; virtual;
    procedure SetItem(const Idx: Integer; const Value: TObject); virtual;

  public
    { AType                                                                    }
    procedure Clear; override;
    procedure Assign(const Source: TObject); override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;

    { AOrderedListType                                                         }
    property  Count: Integer read GetCount write SetCount;
    property  Item[const Idx: Integer]: TObject read GetItem write SetItem; default;
    function  Iterate: ABlaiseIterator; virtual;
    procedure Append(const Value: TObject); virtual;
    procedure Delete(const Idx: Integer); virtual;
    procedure Sort; virtual;
    procedure AppendList(const A: AOrderedListType);
  end;



{                                                                              }
{ ABlaiseArray                                                                 }
{   Base class for a Blaise array structure.                                   }
{                                                                              }
type
  ABlaiseArray = class(AOrderedListType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
  end;



{                                                                              }
{ ABlaiseVector                                                                }
{   Base class for a Blaise vector structure.                                  }
{                                                                              }
{   The name 'vector' is used here in a mathematical context. A vector         }
{   differs from an array in that a vector stores numeric values only.         }
{                                                                              }
type
  ABlaiseVector = class(AOrderedListType)
  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;
  end;
  EBlaiseVector = class(EBlaiseMathType);



{                                                                              }
{ ABlaiseMatrix                                                                }
{   Abstract base class for a Blaise matrix structure.                         }
{                                                                              }
type
  ABlaiseMatrix = class(ABlaiseMathType)
  protected
    { AType                                                                    }
    function  GetAsUTF8: String; override;

    { ABlaiseMatrix                                                            }
    function  GetRowCount: Integer; virtual;
    procedure SetRowCount(const Count: Integer); virtual;
    function  GetColCount: Integer; virtual;
    procedure SetColCount(const Count: Integer); virtual;
    function  GetRow(const Idx: Integer): ABlaiseVector; virtual;
    function  GetItem(const Row, Col: Integer): TObject; virtual;
    procedure SetItem(const Row, Col: Integer; const Value: TObject); virtual;

  public
    property  RowCount: Integer read GetRowCount write SetRowCount;
    property  ColCount: Integer read GetColCount write SetColCount;
    property  Row[const Idx: Integer]: ABlaiseVector read GetRow;
    property  Item[const Row, Col: Integer]: TObject read GetItem write SetItem; default;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  GetTypeID: Byte; override;
  end;
  EBlaiseMatrix = class(EBlaiseMathType);



{                                                                              }
{ ABlaiseDictionary                                                            }
{   Abstract base class for a Blaise dictionary (key-value pairs) structure.   }
{                                                                              }
type
  ABlaiseDictionary = class(ABlaiseType)
  protected
    { ABlaiseType                                                              }
    function  GetAsUTF8: String; override;
    function  GetAsBlaise: String; override;

    { ABlaiseDictionary                                                        }
    function  GetItem(const Key: TObject): TObject; virtual;
    procedure SetItem(const Key: TObject; const Value: TObject); virtual;

  public
    property  Item[const Key: TObject]: TObject read GetItem write SetItem; default;
    procedure AddItem(const Key, Value: TObject); virtual;
    procedure Delete(const Key: TObject); virtual;
    function  GetCount: Integer; virtual;
    function  GetKeyByIndex(const Idx: Integer): TObject; virtual;

    { ABlaiseType                                                              }
    procedure Clear; override;
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;
    procedure StreamOut(const Writer: AWriterEx); override;
    procedure StreamIn(const Reader: AReaderEx); override;
  end;
  EBlaiseDictionary = class(EBlaiseType);



{                                                                              }
{ ABlaiseObject                                                                }
{   Base class for a Blaise structure that can override built-in methods.      }
{                                                                              }
type
  ABlaiseObject = class(ABlaiseType);



{                                                                              }
{ ABlaiseStream                                                                }
{   Base class for a Blaise stream structure.                                  }
{                                                                              }
type
  ABlaiseStream = class(ABlaiseType)
  protected
    function  GetSize: Int64; virtual;
    procedure SetSize(const Size: Int64); virtual;
    function  GetPosition: Int64; virtual;
    procedure SetPosition(const Position: Int64); virtual;
    function  GetReader: AReaderEx; virtual;
    function  GetWriter: AWriterEx; virtual;

    function  GetAsString: String; override;
    function  GetAsUTF8: String; override;
    procedure AssignTo(const Dest: TObject); override;

  public
    property  Size: Int64 read GetSize write SetSize;
    property  Position: Int64 read GetPosition write SetPosition;
    function  EOF: Boolean; virtual;

    function  Read(var Buffer; const Size: Integer): Integer; virtual;
    function  Write(const Buffer; const Size: Integer): Integer; virtual;
    procedure Truncate; virtual;

    function  IsOpen: Boolean; virtual;
    procedure Reopen; virtual;

    procedure ReadBuffer(var Buffer; const Size: Integer);
    procedure WriteBuffer(const Buffer; const Size: Integer);
    function  ReadStr(const Size: Integer): String;
    procedure WriteStr(const S: String);

    procedure PackInteger(const A: Int64);
    procedure PackFloat(const A: Extended);
    procedure PackString(const A: String);

    function  UnpackInteger: Int64;
    function  UnpackFloat: Extended;
    function  UnpackString: String;

    { AType                                                                    }
    procedure Assign(const Source: TObject); override;

    { ABlaiseType                                                              }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName: String; const Value: TObject); override;
    function  CallField(const FieldName: String;
              const Parameters: Array of TObject): TObject; override;
    function  GetTypeID: Byte; override;
  end;
  EBlaiseStream = class(EBlaiseType);



{                                                                              }
{ ANameSpace                                                                   }
{   Abstract base class for name space implementations.                        }
{   A 'name space' is responsible for managing and resolving 'names' into      }
{   objects.                                                                   }
{                                                                              }
type
  ANameSpaceDomain = class;
  ANameSpace = class(ABlaiseType)
  protected
    function  GetAsUTF8: String; override;

  public
    { ABlaiseType                                                              }
    function  GetTypeID: Byte; override;

    { ANameSpace                                                               }
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; virtual; abstract;

    function  Exists(const Key: String): Boolean; virtual; abstract;
    function  GetItem(const Key: String): TObject; virtual; abstract;
    procedure SetItem(const Key: String; const Value: TObject); virtual; abstract;
    procedure Delete(const Key: String); virtual; abstract;
    function  Directory(const Key: String): TObject; virtual; abstract;

    procedure Start(const Domain: ANameSpaceDomain; const Path: String); virtual;
    procedure Stop; virtual;
  end;
  ENameSpace = class(EBlaiseType);

  { ANameSpaceDomain                                                           }  
  ANameSpaceDomain = class
    function  GetData(const Path: String): AStream; virtual; abstract;
    procedure DeleteData(const Path: String); virtual; abstract;
  end;



implementation

uses
  { Fundamentals }
  cStrings,
  cUnicodeCodecs,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs,
  cBlaiseStructsSimple;



{                                                                              }
{ ABlaiseType                                                                  }
{                                                                              }

{ Reference counting                                                           }
procedure ABlaiseType.InstanceUnreferenced;
begin
  Assert(FReferenceCount = 0, 'FReferenceCount = 0');
  Assert(Assigned(self), 'Assigned(self)');
  Destroy;
end;

procedure ABlaiseType.AddReference;
begin
  Assert(FReferenceCount >= 0, 'FReferenceCount >= 0');
  Assert(Assigned(self), 'Assigned(self)');
  Inc(FReferenceCount);
end;

procedure ABlaiseType.ReleaseReference;
begin
  Assert(FReferenceCount > 0, 'FReferenceCount > 0');
  Assert(Assigned(self), 'Assigned(self)');
  Dec(FReferenceCount);
  if FReferenceCount = 0 then
    InstanceUnreferenced;
end;

procedure ABlaiseType.ReleaseUnreferenced;
begin
  if Assigned(self) then
    begin
      Assert(FReferenceCount >= 0, 'FReferenceCount >= 0');
      if FReferenceCount = 0 then
        InstanceUnreferenced;
    end;
end;

procedure ABlaiseType.DecReference;
begin
  Assert(FReferenceCount > 0, 'FReferenceCount > 0');
  Dec(FReferenceCount);
end;

function ABlaiseType.IsUniqueReference: Boolean;
begin
  Assert(FReferenceCount >= 0, 'FReferenceCount >= 0');
  Result := FReferenceCount <= 1;
end;

function ABlaiseType.IsUnreferenced: Boolean;
begin
  Assert(FReferenceCount >= 0, 'FReferenceCount >= 0');
  Result := FReferenceCount <= 0;
end;



{ String representations                                                       }
function ABlaiseType.GetAsString: String;
begin
  Result := UTF8StringToLongString(GetAsUTF8);
end;

procedure ABlaiseType.SetAsString(const Value: String);
begin
  SetAsUTF8(LongStringToUTF8String(Value));
end;

{$WARNINGS OFF}
function ABlaiseType.GetAsUTF8: String;
begin
  MethodNotImplementedError('GetAsUTF8');
end;
{$WARNINGS ON}

procedure ABlaiseType.SetAsUTF8(const Value: String);
begin
  MethodNotImplementedError('SetAsUTF8');
end;

function ABlaiseType.GetAsUTF16: WideString;
begin
  Result := UTF8StringToWideString(GetAsUTF8);
end;

procedure ABlaiseType.SetAsUTF16(const Value: WideString);
begin
  SetAsUTF8(WideStringToUTF8String(Value));
end;

function ABlaiseType.GetAsBlaise: String;
begin
  Result := GetAsUTF8;
end;




{ Scope errors                                                                 }
procedure ABlaiseType.ScopeError(const Msg: String);
begin
  raise EBlaiseScopeError.Create(BlaiseClassName(self) + ': ' + Msg);
end;

procedure ABlaiseType.IdentifierError(const Identifier, Msg: String);
begin
  ScopeError(Identifier + ': ' + Msg);
end;

procedure ABlaiseType.IdentifierNotDefinedError(const Identifier: String);
begin
  ScopeError('Identifier not defined: ' + Identifier);
end;



{ Scope interface                                                              }
function ABlaiseType.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  Result := nil;
  if IsSystemFieldName(FieldName) then
    begin
      // Objects
      if StrEqualNoCase(FieldName, '__GetAsString__') then
        Result := TTString.Create(GetAsString) else
      if StrEqualNoCase(FieldName, '__GetAsUTF8__') then
        Result := TTUnicode8.Create(UTF8StringToWideString(GetAsUTF8), ucUTF8) else
      if StrEqualNoCase(FieldName, '__GetAsUTF16__') then
        Result := TTUnicode16.Create(GetAsUTF16, ucUTF8) else
      if StrEqualNoCase(FieldName, '__GetAsBlaise__') then
        Result := TTString.Create(GetAsBlaise) else
      if StrEqualNoCase(FieldName, '__Duplicate__') then
        Result := Duplicate else
      if StrEqualNoCase(FieldName, '__HashValue__') then
        Result := TTInteger.Create(HashValue) else
      if StrEqualNoCase(FieldName, '__TypeID__') then
        Result := GetImmutableInteger(GetTypeID);
      if Assigned(Result) then
        begin
          Scope := self;
          FieldType := bfObject;
          exit;
        end else
      // Calls
      if StrEqualNoCase(FieldName, '__SetAsString__') or
         StrEqualNoCase(FieldName, '__SetAsUTF8__') or
         StrEqualNoCase(FieldName, '__SetAsUTF16__') or
         StrEqualNoCase(FieldName, '__Assign__') or
         StrEqualNoCase(FieldName, '__IsEqual__') or
         StrEqualNoCase(FieldName, '__Compare__') then
        begin
          Scope := self;
          FieldType := bfCall;
          exit;
        end;
    end;
  // Field not defined
  Scope := nil;
  FieldType := bfObject;
end;

procedure ABlaiseType.SetField(const FieldName: String; const Value: TObject);
begin
  IdentifierError(FieldName, 'Field not assignable');
end;

procedure ABlaiseType.DeleteField(const FieldName: String);
begin
  IdentifierError(FieldName, 'Field not deletable');
end;

function ABlaiseType.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
var F : Boolean;
begin
  Result := nil;
  F := True;
  if IsSystemFieldName(FieldName) then
    if StrEqualNoCase(FieldName, '__SetAsString__') then
      begin
        ValidateParamCount(1, 1, Parameters);
        SetAsString(ObjectGetAsString(Parameters[0]));
      end else
    if StrEqualNoCase(FieldName, '__SetAsUTF8__') then
      begin
        ValidateParamCount(1, 1, Parameters);
        SetAsUTF8(ObjectGetAsUTF8(Parameters[0]));
      end else
    if StrEqualNoCase(FieldName, '__SetAsUTF16__') then
      begin
        ValidateParamCount(1, 1, Parameters);
        SetAsUTF16(ObjectGetAsUTF16(Parameters[0]));
      end else
    if StrEqualNoCase(FieldName, '__Assign__') then
      begin
        ValidateParamCount(1, 1, Parameters);
        Assign(Parameters[0]);
      end else
    if StrEqualNoCase(FieldName, '__IsEqual__') then
      begin
        ValidateParamCount(1, 1, Parameters);
        Result := GetImmutableBoolean(IsEqual(Parameters[0]));
      end else
    if StrEqualNoCase(FieldName, '__Compare__') then
      begin
        ValidateParamCount(1, 1, Parameters);
        Result := GetImmutableInteger(Ord(Compare(Parameters[0])));
      end
    else
      F := False
  else
    F := False;
  if not F then
    IdentifierNotDefinedError(FieldName);
end;



{ Scope helper methods: Get                                                    }
function ABlaiseType.GetIdentifier(const Identifier: String;
    const Required: Boolean; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  // Initialize result
  Scope := nil;
  FieldType := bfObject;
  // Get field; Field was not found if Scope is nil
  Result := GetField(Identifier, Scope, FieldType);
  if Required and not Assigned(Scope) then
    IdentifierNotDefinedError(Identifier);
end;

function ABlaiseType.GetValue(const Identifier: String;
    const Required: Boolean; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
begin
  // Get field and resolve ultimate value
  Result := GetIdentifier(Identifier, Required, Scope, FieldType);
  if Result is AValueReference then
    Result := AValueReference(Result).GetValue;
end;

function ABlaiseType.GetValueAsType(const Identifier: String;
    const Required: Boolean; const ValueClass: TClass;
    const ErrorMsg: String): TObject;
var S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  Result := GetValue(Identifier, Required, S, T);
  if not Assigned(Result) then
    exit;
  if not Result.InheritsFrom(ValueClass) then
    begin
      ObjectReleaseUnreferenced(Result);
      IdentifierError(Identifier, ErrorMsg);
    end;
end;

function ABlaiseType.GetValueAsTypeDefinition(const Identifier: String;
    const Required: Boolean): ATypeDefinition;
begin
  Result := ATypeDefinition(GetValueAsType(Identifier, Required,
      ATypeDefinition, 'Identifier not a type'));
end;



{ Scope helper methods: Evaluate                                               }
function ABlaiseType.EvaluateImmediate(const Identifier: String;
    const Parameters: Array of TObject;
    const IdentifierRequired, CallRequired: Boolean;
    var EvalType: TBlaiseEvalType; var MachineCode: Pointer): TObject;
var V : TObject;
    S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  V := GetValue(Identifier, IdentifierRequired, S, T);
  if Assigned(S) then
    begin
      // callable field
      if T = bfCall then
        begin
          EvalType := beFieldCall;
          MachineCode := nil;
          Result := S.CallField(Identifier, Parameters);
        end else
      // callable value
      if ObjectIsFunction(V) then
        begin
          MachineCode := ObjectFunctionGetMachineCode(V);
          // Functions are called in this scope
          if not Assigned(MachineCode) then
            try
              EvalType := beFunctionCall;
              Result := ObjectFunctionCall(V, self, Parameters);
            finally
              ObjectReleaseUnreferenced(V);
            end
          else
            begin
              EvalType := beMachineCall;
              Result := V; // return function
            end;
        end
      else
        // field value
        begin
          EvalType := beField;
          MachineCode := nil;
          if CallRequired then
            IdentifierError(Identifier, 'Not a function');
          Result := V;
        end;
    end else
    begin
      // field not found
      EvalType := beNone;
      MachineCode := nil;
      Result := nil;
    end;
end;

function ABlaiseType.Evaluate(const Identifier: String;
    const Parameters: Array of TObject;
    const IdentifierRequired, CallRequired, ReleaseParameters: Boolean): TObject;
var E : TBlaiseEvalType;
    A : Pointer;
    F : AFunction;
begin
  try
    Result := EvaluateImmediate(Identifier, Parameters, IdentifierRequired,
        CallRequired, E, A);
    if E = beMachineCall then
      begin
        F := AFunction(Result);
        try
          Result := RequireMachine.CallFunction(F, A, self, Parameters);
        finally
          ObjectReleaseUnreferenced(F);
        end;
      end;
  finally
    if ReleaseParameters then
      ObjectsReleaseUnreferenced(Parameters);
  end;
end;

function ABlaiseType.Evaluate(const Identifier: String): TObject;
begin
  Result := Evaluate(Identifier, [], True, False, False);
end;

procedure ABlaiseType.Execute(const Identifier: String;
    const Parameters: Array of TObject; const ReleaseParameters: Boolean);
begin
  ObjectReleaseUnreferenced(Evaluate(Identifier, Parameters, True, True,
      ReleaseParameters));
end;

procedure ABlaiseType.Execute(const Identifier: String);
begin
  Execute(Identifier, [], False);
end;



{ Scope helper methods: Set                                                    }
procedure ABlaiseType.AssignIdentifier(const Identifier: String; const Value: TObject);
var V : TObject;
    S : ABlaiseType;
    T : TBlaiseFieldType;
begin
  V := GetIdentifier(Identifier, False, S, T);
  if not Assigned(S) then // If the identifier does not exist, create it in this scope
    SetField(Identifier, Value)
  else
    if V is AValueReference then // If AValueReference then forward the Assign call
      AValueReference(V).AssignValue(Value)
    else
      S.SetField(Identifier, Value); // Set the identifier in the scope where it exists
end;

procedure ABlaiseType.SetConstant(const Identifier: String; const Value: TObject);
begin
  SetField(Identifier, TScopeValue.CreateConstant(Value));
end;

procedure ABlaiseType.AddVariable(const Identifier: String;
    const TypeDefinition: ATypeDefinition; const Value: TObject);
begin
  if Assigned(TypeDefinition) then
    begin // typed variable
      if not Assigned(Value) then
        begin // typed variable without default value
          if TypeDefinition.IsVariablesAutoInstanciate then // instanciated variable
            SetField(Identifier,
                TScopeValue.CreateAutoInstanciate(TypeDefinition))
          else // unassigned
            SetField(Identifier,
                TScopeValue.CreateTyped(UnassignedValue, TypeDefinition));
        end
      else // typed variable with default value
        SetField(Identifier, TScopeValue.CreateTyped(
            TypeDefinition.Coerce(Value), TypeDefinition));
    end
  else // untyped variable
    if not Assigned(Value) then
      SetField(Identifier, UnassignedValue) // unassigned
    else
      SetField(Identifier, Value); // default value
end;

procedure ABlaiseType.AddConstant(const Identifier: String;
    const TypeDefinition: ATypeDefinition; const Value: TObject);
begin
  if Assigned(TypeDefinition) then
    SetConstant(Identifier, TypeDefinition.Coerce(Value)) else
    SetConstant(Identifier, Value);
end;



{ Binary stream                                                                }
function ABlaiseType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_BlaiseType;
end;

procedure ABlaiseType.StreamOut(const Writer: AWriterEx);
begin
  MethodNotImplementedError('StreamOut');
end;

procedure ABlaiseType.StreamIn(const Reader: AReaderEx);
begin
  MethodNotImplementedError('StreamIn');
end;

{ Attributes                                                                   }
function ABlaiseType.IsImmutable: Boolean;
begin
  Result := False;
end;



{                                                                              }
{ ATypeDefinition                                                              }
{                                                                              }
procedure ATypeDefinition.TypeDefinitionError(const Msg: String);
begin
  raise ETypeDefinition.Create(BlaiseClassName(self) + ': ' + Msg);
end;

procedure ATypeDefinition.CoerceError(const Value: TObject; const Msg: String);
begin
  TypeDefinitionError('Can not coerce from ' + BlaiseClassName(Value) + ': ' +
      Msg);
end;

procedure ATypeDefinition.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
  TypeDefinitionError('SetDefinitionScope not implemented');
end;

{$WARNINGS OFF}
function ATypeDefinition.CreateTypeInstance: TObject;
begin
  TypeDefinitionError('CreateTypeInstance not implemented');
end;

function ATypeDefinition.IsType(const Value: TObject): Boolean;
begin
  TypeDefinitionError('IsType not implemented');
end;
{$WARNINGS ON}

function ATypeDefinition.ResolveType: ATypeDefinition;
begin
  Result := self;
end;

function ATypeDefinition.IsVariablesAutoInstanciate: Boolean;
begin
  Result := True;
end;

function ATypeDefinition.Coerce(const Value: TObject): TObject;
var V : TObject;
begin
  if IsType(Value) then
    Result := Value // Return Value if already of the required type
  else
    begin
      // Create new instance and copy value
      Result := CreateTypeInstance;
      try
        if Result is AValueReference then
          V := AValueReference(Result).GetValue
        else
          V := Result;
        ObjectAssign(V, Value);
      except
        on E : Exception do
          begin
            Result.Free;
            CoerceError(Value, E.Message);
          end;
      end;
    end;
end;

function ATypeDefinition.CoerceAndReleaseUnreferenced(const Value: TObject): TObject;
begin
  Result := Coerce(Value);
  if Result <> Value then
    ObjectReleaseUnreferenced(Value);
end;

function ATypeDefinition.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_TypeDefinition;
end;

function ATypeDefinition.GetTypeDefID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Object;
end;



{                                                                              }
{ ALocalisedTypeDefinition                                                     }
{                                                                              }
procedure ALocalisedTypeDefinition.SetDefinitionScope(const DefinitionScope: ABlaiseType);
begin
  FDefinitionScope := DefinitionScope;
end;



{                                                                              }
{ AValueReference                                                              }
{                                                                              }
procedure AValueReference.RaiseError(const Msg: String);
begin
  raise EValueReference.Create(Msg);
end;

{$WARNINGS OFF}
function AValueReference.GetValue: TObject;
begin
  RaiseError('Method ' + BlaiseClassName(self) + '.GetValue not implemented');
end;
{$WARNINGS ON}

procedure AValueReference.AssignValue(const Value: TObject);
begin
  RaiseError('Method ' + BlaiseClassName(self) + '.SetValue not implemented');
end;



{                                                                              }
{ TScopeValue                                                                  }
{                                                                              }
constructor TScopeValue.Create(const Value: TObject;
    const Attributes: TScopeValueAttributes;
    const TypeDefinition: ATypeDefinition);
begin
  inherited Create;
  FAttributes := Attributes;
  InitValue(Value, TypeDefinition);
end;

constructor TScopeValue.CreateConstant(const Value: TObject);
begin
  inherited Create;
  FAttributes := [svaConstant];
  InitValue(Value, nil);
end;

constructor TScopeValue.CreateTyped(const Value: TObject; const TypeDefinition: ATypeDefinition);
begin
  Assert(Assigned(TypeDefinition));
  inherited Create;
  FAttributes := [svaTyped];
  InitValue(Value, TypeDefinition);
end;

constructor TScopeValue.CreateAutoInstanciate(const TypeDefinition: ATypeDefinition);
begin
  Assert(Assigned(TypeDefinition));
  inherited Create;
  FAttributes := [svaTyped, svaAutoInstanciate];
  InitValue(nil, TypeDefinition);
end;

destructor TScopeValue.Destroy;
begin
  ObjectReleaseReferenceAndNil(FValue);
  ObjectReleaseReferenceAndNil(FTypeDefinition);
  inherited Destroy;
end;

procedure TScopeValue.InitValue(const Value: TObject;
    const TypeDefinition: ATypeDefinition);
begin
  ObjectAddReference(Value);
  FValue := Value;
  ObjectAddReference(TypeDefinition);
  FTypeDefinition := TypeDefinition;
end;

procedure TScopeValue.Clear;
begin
  ObjectReleaseReferenceAndNil(FValue);
end;

procedure TScopeValue.SetValue(const Value: TObject);
begin
  Clear;
  ObjectAddReference(Value);
  FValue := Value;
end;

procedure TScopeValue.AssignValue(const Value: TObject);
begin
  if svaConstant in FAttributes then
    RaiseError('Value is read-only');
  if FValue is AValueReference then
    AValueReference(FValue).AssignValue(Value) else
  if svaTyped in FAttributes then
    SetValue(FTypeDefinition.Coerce(Value)) else
    SetValue(Value);
end;

function TScopeValue.GetValue: TObject;
begin
  Result := FValue;
  if not Assigned(Result) and (svaAutoInstanciate in FAttributes) then
    begin
      // Auto instanciate value on first access
      Assert(Assigned(FTypeDefinition));
      SetValue(FTypeDefinition.CreateTypeInstance);
      Exclude(FAttributes, svaAutoInstanciate);
      Result := FValue;
    end;
  // Resolve references
  if Result is AValueReference then
    Result := AValueReference(Result).GetValue;
end;



{                                                                              }
{ AScopeFieldDefinition                                                        }
{                                                                              }
constructor AScopeFieldDefinition.Create;
begin
  inherited Create;
  Init;
end;

procedure AScopeFieldDefinition.Init;
begin
end;

procedure AScopeFieldDefinition.RaiseError(const Msg: String);
begin
  raise EScopeFieldDefinition.Create(Msg);
end;

{$WARNINGS OFF}
function AScopeFieldDefinition.GetFieldID: Byte;
begin
  RaiseError('Method ' + ClassName + '.GetFieldID not implemented');
end;
{$WARNINGS ON}

procedure AScopeFieldDefinition.StreamOut(const Writer: AWriterEx);
begin
  RaiseError('Method ' + ClassName + '.StreamOut not implemented');
end;

procedure AScopeFieldDefinition.StreamIn(const Reader: AReaderEx);
begin
  RaiseError('Method ' + ClassName + '.StreamIn not implemented');
end;



{                                                                              }
{ ASimpleFieldDefinition                                                       }
{                                                                              }
constructor ASimpleFieldDefinition.Create(const Identifier: String;
    const TypeDefinition: ATypeDefinition; const Value: TObject);
begin
  inherited Create;
  FIdentifier := Identifier;
  ObjectAddReference(TypeDefinition);
  FTypeDefinition := TypeDefinition;
  ObjectAddReference(Value);
  FValue := Value;
end;

destructor ASimpleFieldDefinition.Destroy;
begin
  ObjectReleaseReferenceAndNil(FValue);
  ObjectReleaseReferenceAndNil(FTypeDefinition);
  inherited Destroy;
end;

procedure ASimpleFieldDefinition.StreamOut(const Writer: AWriterEx);
begin
  Writer.WritePackedString(FIdentifier);
  StreamOutTypeDefinition(Writer, FTypeDefinition);
  StreamOutObject(Writer, FValue);
end;

procedure ASimpleFieldDefinition.StreamIn(const Reader: AReaderEx);
begin
  FIdentifier := Reader.ReadPackedString;
  FTypeDefinition := StreamInTypeDefinition(Reader);
  ObjectAddReference(FTypeDefinition);
  FValue := StreamInObject(Reader);
  ObjectAddReference(FValue);
end;



{                                                                              }
{ TVariableFieldDefinition                                                     }
{                                                                              }
procedure TVariableFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  if Assigned(FTypeDefinition) then
    FTypeDefinition.SetDefinitionScope(DefinitionScope);
  FieldScope.AddVariable(FIdentifier, FTypeDefinition, FValue);
end;

function TVariableFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_VAR;
end;



{                                                                              }
{ TConstantFieldDefinition                                                     }
{                                                                              }
procedure TConstantFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  if Assigned(FTypeDefinition) then
    FTypeDefinition.SetDefinitionScope(DefinitionScope);
  FieldScope.AddConstant(FIdentifier, FTypeDefinition, FValue);
end;

function TConstantFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_CONST;
end;



{                                                                              }
{ TTypeFieldDefinition                                                         }
{                                                                              }
constructor TTypeFieldDefinition.Create(const Identifier: String;
    const TypeDefinition: ATypeDefinition);
begin
  inherited Create(Identifier, TypeDefinition, nil);
end;

procedure TTypeFieldDefinition.AddToScope(const FieldScope, DefinitionScope: ABlaiseType);
begin
  FTypeDefinition.SetDefinitionScope(DefinitionScope);
  FieldScope.SetConstant(FIdentifier, FTypeDefinition);
end;

function TTypeFieldDefinition.GetFieldID: Byte;
begin
  Result := BLAISE_FIELD_ID_TYPE;
end;



{                                                                              }
{ AFunction                                                                    }
{                                                                              }
procedure AFunction.FunctionError(const Msg: String);
begin
  raise EFunction.Create({$IFDEF DEBUG}ObjectClassName(self) + ': ' + {$ENDIF}
        Msg);
end;

function AFunction.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Function;
end;

function AFunction.GetParameters: TParameterAttributesArray;
begin
  FunctionError(ClassName + '.GetParameters not implemented');
end;

function AFunction.GetMachineCode: Pointer;
begin
  Result := nil;
end;

{$WARNINGS OFF}
function AFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  FunctionError(ClassName + '.Call not implemented');
end;

function AFunction.CreateLocalScope(const Scope: ABlaiseType;
    const Parameters: Array of TObject): ABlaiseType;
begin
  FunctionError(ClassName + '.CreateLocalScope not implemented');
end;
{$WARNINGS ON}



{                                                                              }
{ AUnaryScopeFunction                                                          }
{                                                                              }
constructor AUnaryScopeFunction.Create(const Func: TUnaryFunction);
begin
  inherited Create;
  Assert(Assigned(@Func), 'Assigned(@Func)');
  FFunc := Func;
  SetLength(FParams, 1);
  FParams[0] := [];
end;

function AUnaryScopeFunction.GetParameters: TParameterAttributesArray;
begin
  Result := FParams;
end;

function AUnaryScopeFunction.Call(const Scope: ABlaiseType;
    const Parameters: Array of TObject): TObject;
begin
  ValidateParameters(FParams, Parameters);
  Result := FFunc(Parameters[0]);
end;



{                                                                              }
{ ABlaiseMathType                                                              }
{                                                                              }
function ABlaiseMathType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_MathType;
end;

procedure ABlaiseMathType.OperationNotSupportedError(const Operation: String;
    const V: TObject);
begin
  raise ESimpleType.Create(BlaiseClassName(self) + ': Operation ' + Operation +
        ' not supported on ' + BlaiseClassName(V));
end;

procedure ABlaiseMathType.Abs;
begin
  OperationNotSupportedError('Abs');
end;

procedure ABlaiseMathType.Negate;
begin
  OperationNotSupportedError('Negate');
end;

procedure ABlaiseMathType.Add(const V: TObject);
begin
  OperationNotSupportedError('Add', V);
end;

procedure ABlaiseMathType.Subtract(const V: TObject);
begin
  OperationNotSupportedError('Subtract', V);
end;

procedure ABlaiseMathType.Multiply(const V: TObject);
begin
  OperationNotSupportedError('Multiply', V);
end;

procedure ABlaiseMathType.Divide(const V: TObject);
begin
  OperationNotSupportedError('Divide', V);
end;

procedure ABlaiseMathType.ReversedAdd(const V: TObject);
begin
  OperationNotSupportedError('Reversed Add', V);
end;

procedure ABlaiseMathType.ReversedSubtract(const V: TObject);
begin
  OperationNotSupportedError('Reversed Subtract', V);
end;

procedure ABlaiseMathType.ReversedMultiply(const V: TObject);
begin
  OperationNotSupportedError('Reversed Multiply', V);
end;

procedure ABlaiseMathType.ReversedDivide(const V: TObject);
begin
  OperationNotSupportedError('Reversed Divide', V);
end;

procedure ABlaiseMathType.Sqr;
begin
  OperationNotSupportedError('Sqr');
end;

procedure ABlaiseMathType.Sqrt;
begin
  OperationNotSupportedError('Sqrt');
end;

procedure ABlaiseMathType.Ln;
begin
  OperationNotSupportedError('Ln');
end;

procedure ABlaiseMathType.Exp;
begin
  OperationNotSupportedError('Exp');
end;

procedure ABlaiseMathType.Sin;
begin
  OperationNotSupportedError('Sin');
end;

procedure ABlaiseMathType.Cos;
begin
  OperationNotSupportedError('Cos');
end;

procedure ABlaiseMathType.Power(const V: TObject);
begin
  OperationNotSupportedError('Power', V);
end;

procedure ABlaiseMathType.ReversedPower(const V: TObject);
begin
  OperationNotSupportedError('Power', V);
end;

procedure ABlaiseMathType.IntegerDivide(const V: TObject);
begin
  OperationNotSupportedError('Integer Divide', V);
end;

procedure ABlaiseMathType.Modulo(const V: TObject);
begin
  OperationNotSupportedError('Mod', V);
end;

procedure ABlaiseMathType.ReversedIntegerDivide(const V: TObject);
begin
  OperationNotSupportedError('Reversed Integer Divide', V);
end;

procedure ABlaiseMathType.ReversedModulo(const V: TObject);
begin
  OperationNotSupportedError('Mod', V);
end;

procedure ABlaiseMathType.LogicalAND(const V: TObject);
begin
  OperationNotSupportedError('AND', V);
end;

procedure ABlaiseMathType.LogicalOR(const V: TObject);
begin
  OperationNotSupportedError('OR', V);
end;

procedure ABlaiseMathType.LogicalXOR(const V: TObject);
begin
  OperationNotSupportedError('XOR', V);
end;

procedure ABlaiseMathType.ReversedLogicalAND(const V: TObject);
begin
  OperationNotSupportedError('Reversed AND', V);
end;

procedure ABlaiseMathType.ReversedLogicalOR(const V: TObject);
begin
  OperationNotSupportedError('Reversed OR', V);
end;

procedure ABlaiseMathType.ReversedLogicalXOR(const V: TObject);
begin
  OperationNotSupportedError('Reversed XOR', V);
end;

procedure ABlaiseMathType.LogicalNOT;
begin
  OperationNotSupportedError('NOT');
end;

procedure ABlaiseMathType.BitwiseSHL(const V: TObject);
begin
  OperationNotSupportedError('SHL', V);
end;

procedure ABlaiseMathType.BitwiseSHR(const V: TObject);
begin
  OperationNotSupportedError('SHR', V);
end;

procedure ABlaiseMathType.ReversedBitwiseSHL(const V: TObject);
begin
  OperationNotSupportedError('Reversed SHL', V);
end;

procedure ABlaiseMathType.ReversedBitwiseSHR(const V: TObject);
begin
  OperationNotSupportedError('Reversed SHR', V);
end;

function ABlaiseMathType.UnaryOpCoerce(const Operation: TUnaryMathOperation): TObject;
begin
  Result := nil;
end;

function ABlaiseMathType.BinaryOpLeftCoerce(const Operation: TBinaryMathOperation;
    const RightOp: TObject): TObject;
begin
  Result := nil;
end;

function ABlaiseMathType.BinaryOpRightCoerce(const Operation: TBinaryMathOperation;
    const LeftOp: TObject): TObject;
begin
  Result := nil;
end;



{                                                                              }
{ ASimpleType                                                                  }
{                                                                              }
procedure ASimpleType.ConvertToError(const T: String);
begin
  ObjectConvertToError(self, T);
end;

procedure ASimpleType.ConvertFromError(const T: String);
begin
  ObjectConvertFromError(self, T);
end;

function ASimpleType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_SimpleType;
end;

function ASimpleType.GetField(const FieldName: String; var Scope: ABlaiseType;
    var FieldType: TBlaiseFieldType): TObject;
var F : Boolean;
begin
  Result := nil;
  F := IsSystemFieldName(FieldName);
  if F then
    if StrEqualNoCase(FieldName, '__IsSimpleType__') then
      begin
        Scope := self;
        FieldType := bfObject;
        Result := GetImmutableBoolean(True);
      end
    else
      F := False;
  if not F then
    if StrEqualNoCase(FieldName, 'Clear') then
      begin
        Scope := self;
        FieldType := bfCall;
        Result := nil;
      end
    else
      Result := inherited GetField(FieldName, Scope, FieldType);
end;

function ASimpleType.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  if StrEqualNoCase(FieldName, 'Clear') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Clear;
      Result := nil;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

{ Representations                                                              }
{$WARNINGS OFF}
function ASimpleType.GetAsUTF8: String;
begin
  ConvertToError('string');
end;

function ASimpleType.GetAsInteger: Int64;
begin
  ConvertToError('integer');
end;

function ASimpleType.GetAsFloat: Extended;
begin
  ConvertToError('float');
end;

function ASimpleType.GetAsCurrency: Currency;
begin
  try
    Result := AsFloat;
  except
    ConvertToError('currency');
  end;
end;

function ASimpleType.GetAsDateTime: TDateTime;
begin
  try
    Result := AsFloat;
  except
    ConvertToError('datetime');
  end;
end;

function ASimpleType.GetAsBoolean: Boolean;
begin
  try
    Result := AsInteger <> 0;
  except
    ConvertToError('boolean');
  end;
end;
{$WARNINGS ON}

procedure ASimpleType.SetAsUTF8(const Value: String);
begin
  ConvertFromError('string');
end;

procedure ASimpleType.SetAsInteger(const Value: Int64);
begin
  ConvertFromError('integer');
end;

procedure ASimpleType.SetAsFloat(const Value: Extended);
begin
  ConvertFromError('float');
end;

procedure ASimpleType.SetAsCurrency(const Value: Currency);
begin
  try
    AsFloat := Value;
  except
    ConvertFromError('currency');
  end;
end;

procedure ASimpleType.SetAsDateTime(const Value: TDateTime);
begin
  try
    AsFloat := Value;
  except
    ConvertFromError('datetime');
  end;
end;

procedure ASimpleType.SetAsBoolean(const Value: Boolean);
begin
  try
    AsInteger := Ord(Value);
  except
    ConvertFromError('boolean');
  end;
end;

procedure ASimpleType.SetAsRational(const Numerator, Denominator: Int64);
begin
  try
    AsFloat := Numerator / Denominator;
  except
    ConvertFromError('rational');
  end;
end;

{ Operations                                                                   }
procedure ASimpleType.Inc(const Count: Int64);
begin
  OperationNotSupportedError('Inc');
end;

procedure ASimpleType.Dec(const Count: Int64);
begin
  OperationNotSupportedError('Dec');
end;



{                                                                              }
{ ANumberType                                                                  }
{                                                                              }
function ANumberType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Number;
end;



{                                                                              }
{ AIntegerNumberType                                                           }
{                                                                              }
function AIntegerNumberType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Integer;
end;



{                                                                              }
{ ARealNumberType                                                              }
{                                                                              }
function ARealNumberType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Real;
end;



{                                                                              }
{ ADateTimeType                                                                }
{                                                                              }
function ADateTimeType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_DateTime;
end;



{                                                                              }
{ ABlaiseIterator                                                              }
{                                                                              }
function ABlaiseIterator.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Iterator;
end;

{$WARNINGS OFF}
function ABlaiseIterator.Next: TObject;
begin
  MethodNotImplementedError('Next');
end;

function ABlaiseIterator.EOF: Boolean;
begin
  MethodNotImplementedError('EOF');
end;
{$WARNINGS ON}



{                                                                              }
{ ASubrangeTypeDefinition                                                      }
{                                                                              }
constructor ASubrangeTypeDefinition.Create(const Min, Max: Int64);
begin
  inherited Create;
  FMin := Min;
  FMax := Max;
end;

procedure ASubrangeTypeDefinition.StreamOut(const Writer: AWriterEx);
begin
  Writer.WriteInt64(FMin);
  Writer.WriteInt64(FMax);
end;

procedure ASubrangeTypeDefinition.StreamIn(const Reader: AReaderEx);
begin
  FMin := Reader.ReadInt64;
  FMax := Reader.ReadInt64;
end;



{                                                                              }
{ TOrderedListIterator                                                         }
{                                                                              }
type
  TOrderedListIterator = class(ABlaiseIterator)
    FList  : AOrderedListType;
    FIndex : Integer;
    constructor Create(const List: AOrderedListType);
    destructor Destroy; override;
    function  EOF: Boolean; override;
    function  Next: TObject; override;
  end;

constructor TOrderedListIterator.Create(const List: AOrderedListType);
begin
  inherited Create;
  ObjectAddReference(List);
  FList := List;
end;

destructor TOrderedListIterator.Destroy;
begin
  ObjectReleaseReferenceAndNil(FList);
  inherited Destroy;
end;

function TOrderedListIterator.EOF: Boolean;
begin
  Result := FIndex >= FList.Count;
end;

function TOrderedListIterator.Next: TObject;
begin
  if EOF then
    raise EBlaiseIterator.Create('Next past EOF');
  Result := FList[FIndex];
  Inc(FIndex);
end;



{                                                                              }
{ AOrderedListType                                                             }
{                                                                              }
{$WARNINGS OFF}
function AOrderedListType.GetCount: Integer;
begin
  MethodNotImplementedError('GetCount');
end;
{$WARNINGS ON}

procedure AOrderedListType.SetCount(const Count: Integer);
begin
  MethodNotImplementedError('SetCount');
end;

{$WARNINGS OFF}
function AOrderedListType.GetItem(const Idx: Integer): TObject;
begin
  MethodNotImplementedError('GetItem');
end;
{$WARNINGS ON}

procedure AOrderedListType.SetItem(const Idx: Integer; const Value: TObject);
begin
  MethodNotImplementedError('SetItem');
end;

function AOrderedListType.Iterate: ABlaiseIterator;
begin
  Result := TOrderedListIterator.Create(self);
end;

function AOrderedListType.GetAsUTF8: String;
var I : Integer;
begin
  Result := '[';
  For I := 0 to GetCount - 1 do
    begin
      if I > 0 then
        Result := Result + ', ';
      Result := Result + ObjectGetAsUTF8(GetItem(I));
    end;
  Result := Result + ']';
end;

function AOrderedListType.GetAsBlaise: String;
var I : Integer;
begin
  Result := '[';
  For I := 0 to GetCount - 1 do
    begin
      if I > 0 then
        Result := Result + ', ';
      Result := Result + ObjectGetAsBlaise(GetItem(I));
    end;
  Result := Result + ']';
end;

procedure AOrderedListType.Clear;
begin
  SetCount(0);
end;

procedure AOrderedListType.Assign(const Source: TObject);
var I, L : Integer;
begin
  if Source is AOrderedListType then
    begin
      L := AOrderedListType(Source).Count;
      SetCount(L);
      For I := 0 to L - 1 do
        SetItem(I, AOrderedListType(Source).GetItem(I));
    end
  else
    inherited Assign(Source);
end;

function AOrderedListType.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Count') then
    Result := GetImmutableInteger(GetCount)
  else
    Result := nil;
  if Assigned(Result) then
    Scope := self else
  if StrEqualNoCase(FieldName, 'Append') or
     StrEqualNoCase(FieldName, 'Delete') or
     StrEqualNoCase(FieldName, 'Clear') or
     StrEqualNoCase(FieldName, 'Sort') then
    begin
      Scope := self;
      FieldType := bfCall;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure AOrderedListType.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Count') then
    SetCount(ObjectGetAsInteger(Value))
  else
    inherited SetField(FieldName, Value);
end;

function AOrderedListType.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Append') then
    begin
      ValidateParamCount(1, 1, Parameters);
      Append(Parameters[0]);
    end else
  if StrEqualNoCase(FieldName, 'Delete') then
    begin
      ValidateParamCount(1, 1, Parameters);
      Delete(ObjectGetAsInteger(Parameters[0]));
    end else
  if StrEqualNoCase(FieldName, 'Clear') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Clear;
    end else
  if StrEqualNoCase(FieldName, 'Sort') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Sort;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function AOrderedListType.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Sequence;
end;

procedure AOrderedListType.StreamOut(const Writer: AWriterEx);
var I, L : Integer;
begin
  L := GetCount;
  Writer.WriteLongInt(L);
  For I := 0 to L - 1 do
    StreamOutObject(Writer, GetItem(I));
end;

procedure AOrderedListType.StreamIn(const Reader: AReaderEx);
var I, L : Integer;
begin
  L := Reader.ReadLongInt;
  SetCount(L);
  For I := 0 to L - 1 do
    SetItem(I, StreamInObject(Reader));
end;

procedure AOrderedListType.Append(const Value: TObject);
begin
  MethodNotImplementedError('Append');
end;

procedure AOrderedListType.Delete(const Idx: Integer);
begin
  MethodNotImplementedError('Delete');
end;

procedure AOrderedListType.Sort;
begin
  MethodNotImplementedError('Sort');
end;

procedure AOrderedListType.AppendList(const A: AOrderedListType);
var L, C, I : Integer;
begin
  L := A.Count;
  if L <= 0 then
    exit;
  C := GetCount;
  SetCount(C + L);
  For I := 0 to L - 1 do
    SetItem(C + I, A.GetItem(I));
end;



{                                                                              }
{ ABlaiseArray                                                                 }
{                                                                              }
function ABlaiseArray.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_ARRAY;
end;



{                                                                              }
{ ABlaiseVector                                                                }
{                                                                              }
function ABlaiseVector.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_VECTOR;
end;



{                                                                              }
{ ABlaiseMatrix                                                                }
{                                                                              }
function ABlaiseMatrix.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_MATRIX;
end;

{$WARNINGS OFF}
function ABlaiseMatrix.GetColCount: Integer;
begin
  MethodNotImplementedError('GetColCount');
end;

function ABlaiseMatrix.GetRowCount: Integer;
begin
  MethodNotImplementedError('GetRowCount');
end;
{$WARNINGS ON}

procedure ABlaiseMatrix.SetColCount(const Count: Integer);
begin
  MethodNotImplementedError('SetColCount');
end;

procedure ABlaiseMatrix.SetRowCount(const Count: Integer);
begin
  MethodNotImplementedError('SetRowCount');
end;

{$WARNINGS OFF}
function ABlaiseMatrix.GetRow(const Idx: Integer): ABlaiseVector;
begin
  MethodNotImplementedError('GetRow');
end;

function ABlaiseMatrix.GetItem(const Row, Col: Integer): TObject;
begin
  MethodNotImplementedError('GetItem');
end;
{$WARNINGS ON}

procedure ABlaiseMatrix.SetItem(const Row, Col: Integer; const Value: TObject);
begin
  MethodNotImplementedError('SetItem');
end;

function ABlaiseMatrix.GetAsUTF8: String;
var I, L : Integer;
begin
  L := GetRowCount;
  if L = 0 then
    begin
      Result := '';
      exit;
    end;
  Result := '[';
  For I := 0 to L - 1 do
    begin
      if I > 0 then
        Result := Result + ','#13#10;
      Result := Result + ObjectGetAsUTF8(GetRow(I));
    end;
  Result := Result + ']';
end;

function ABlaiseMatrix.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'RowCount') then
    Result := GetImmutableInteger(GetRowCount) else
  if StrEqualNoCase(FieldName, 'ColCount') then
    Result := GetImmutableInteger(GetColCount)
  else
    Result := nil;
  if Assigned(Result) then
    Scope := self
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure ABlaiseMatrix.SetField(const FieldName: String; const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'RowCount') then
    SetRowCount(ObjectGetAsInteger(Value)) else
  if StrEqualNoCase(FieldName, 'ColCount') then
    SetColCount(ObjectGetAsInteger(Value))
  else
    inherited SetField(FieldName, Value);
end;



{                                                                              }
{ ABlaiseDictionary                                                            }
{                                                                              }
{$WARNINGS OFF}
function ABlaiseDictionary.GetItem(const Key: TObject): TObject;
begin
  MethodNotImplementedError('GetItem');
end;
{$WARNINGS ON}

procedure ABlaiseDictionary.SetItem(const Key: TObject; const Value: TObject);
begin
  MethodNotImplementedError('SetItem');
end;

procedure ABlaiseDictionary.AddItem(const Key, Value: TObject);
begin
  MethodNotImplementedError('AddItem');
end;

procedure ABlaiseDictionary.Delete(const Key: TObject);
begin
  MethodNotImplementedError('Delete');
end;

{$WARNINGS OFF}
function ABlaiseDictionary.GetCount: Integer;
begin
  MethodNotImplementedError('GetCount');
end;

function ABlaiseDictionary.GetKeyByIndex(const Idx: Integer): TObject;
begin
  MethodNotImplementedError('GetKeyByIndex');
end;
{$WARNINGS ON}

function ABlaiseDictionary.GetAsUTF8: String;
var I, L : Integer;
    K    : TObject;
begin
  L := GetCount;
  if L = 0 then
    begin
      Result := '[:]';
      exit;
    end;
  Result := '[';
  For I := 0 to L - 1 do
    begin
      if I > 0 then
        Result := Result + ', ';
      K := GetKeyByIndex(I);
      Result := Result + ObjectGetAsUTF8(K) + ':' +
                         ObjectGetAsUTF8(GetItem(K));
    end;
  Result := Result + ']';
end;

function ABlaiseDictionary.GetAsBlaise: String;
var I, L : Integer;
    K    : TObject;
begin
  L := GetCount;
  if L = 0 then
    begin
      Result := '[:]';
      exit;
    end;
  Result := '[';
  For I := 0 to L - 1 do
    begin
      if I > 0 then
        Result := Result + ', ';
      K := GetKeyByIndex(I);
      Result := Result + ObjectGetAsBlaise(K) + ':' +
                         ObjectGetAsBlaise(GetItem(K));
    end;
  Result := Result + ']';
end;

procedure ABlaiseDictionary.Clear;
var I : Integer;
begin
  For I := GetCount - 1 downto 0 do
    Delete(GetKeyByIndex(I));
end;

function ABlaiseDictionary.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  if StrEqualNoCase(FieldName, 'Count') then
    begin
      Scope := self;
      Result := GetImmutableInteger(GetCount);
    end else
  if StrEqualNoCase(FieldName, 'Add') or
     StrEqualNoCase(FieldName, 'Delete') then
    begin
      Scope := self;
      FieldType := bfCall;
      Result := nil;
    end
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

function ABlaiseDictionary.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'Add') then
    begin
      ValidateParamCount(2, 2, Parameters);
      AddItem(Parameters[0], Parameters[1]);
    end else
  if StrEqualNoCase(FieldName, 'Delete') then
    begin
      ValidateParamCount(1, 1, Parameters);
      Delete(Parameters[0]);
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;

function ABlaiseDictionary.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_DICTIONARY;
end;

procedure ABlaiseDictionary.StreamOut(const Writer: AWriterEx);
var I, L : Integer;
    K    : TObject;
begin
  L := GetCount;
  Writer.WriteLongInt(L);
  For I := 0 to L - 1 do
    begin
      K := GetKeyByIndex(I);
      StreamOutObject(Writer, K);
      StreamOutObject(Writer, GetItem(K));
    end;
end;

procedure ABlaiseDictionary.StreamIn(const Reader: AReaderEx);
var I, L : Integer;
    K    : TObject;
begin
  L := Reader.ReadLongInt;
  For I := 0 to L - 1 do
    begin
      K := StreamInObject(Reader);
      AddItem(K, StreamInObject(Reader));
    end;
end;



{                                                                              }
{ ABlaiseStream                                                                }
{   Base class for a Blaise stream structure.                                  }
{                                                                              }
function ABlaiseStream.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_Stream;
end;

{$WARNINGS OFF}
function ABlaiseStream.GetSize: Int64;
begin
  MethodNotImplementedError('GetSize');
end;

function ABlaiseStream.GetPosition: Int64;
begin
  MethodNotImplementedError('GetPosition');
end;
{$WARNINGS ON}

procedure ABlaiseStream.SetSize(const Size: Int64);
begin
  MethodNotImplementedError('SetSize');
end;

procedure ABlaiseStream.SetPosition(const Position: Int64);
begin
  MethodNotImplementedError('SetPosition');
end;

{$WARNINGS OFF}
function ABlaiseStream.GetReader: AReaderEx;
begin
  MethodNotImplementedError('GetReader');
end;

function ABlaiseStream.GetWriter: AWriterEx;
begin
  MethodNotImplementedError('GetWriter');
end;

function ABlaiseStream.EOF: Boolean;
begin
  MethodNotImplementedError('EOF');
end;

function ABlaiseStream.Read(var Buffer; const Size: Integer): Integer;
begin
  MethodNotImplementedError('Read');
end;

function ABlaiseStream.Write(const Buffer; const Size: Integer): Integer;
begin
  MethodNotImplementedError('Write');
end;
{$WARNINGS ON}

procedure ABlaiseStream.Truncate;
begin
  MethodNotImplementedError('Truncate');
end;

{$WARNINGS OFF}
function ABlaiseStream.IsOpen: Boolean;
begin
  MethodNotImplementedError('IsOpen');
end;
{$WARNINGS ON}

procedure ABlaiseStream.Reopen;
begin
  MethodNotImplementedError('Reopen');
end;

procedure ABlaiseStream.ReadBuffer(var Buffer; const Size: Integer);
begin
  if Read(Buffer, Size) <> Size then
    raise EBlaiseStream.Create('Read error');
end;

procedure ABlaiseStream.WriteBuffer(const Buffer; const Size: Integer);
begin
  if Write(Buffer, Size) <> Size then
    raise EBlaiseStream.Create('Write error');
end;

function ABlaiseStream.ReadStr(const Size: Integer): String;
var L : Integer;
begin
  if Size <= 0 then
    begin
      Result := '';
      exit;
    end;
  SetLength(Result, Size);
  L := Read(Pointer(Result)^, Size);
  if L <= 0 then
    begin
      Result := '';
      exit;
    end;
  if L < Size then
    SetLength(Result, L);
end;

procedure ABlaiseStream.WriteStr(const S: String);
begin
  WriteBuffer(Pointer(S)^, Length(S));
end;

const
  StreamBufSize = 2048;

function ABlaiseStream.GetAsString: String;
var S, P : Int64;
    I, L : Integer;
    Buf  : Array[0..StreamBufSize - 1] of Byte;
begin
  // Try to read the whole stream
  S := GetSize;
  if S >= 0 then
    begin
      P := GetPosition;
      if P >= 0 then
        begin
          L := S - P;
          Result := ReadStr(L);
          exit;
        end;
    end;
  // Read the stream block by block
  Result := '';
  L := 0;
  While not EOF do
    begin
      I := Read(Buf, StreamBufSize);
      if I <= 0 then
        raise EBlaiseStream.Create('Read error');
      SetLength(Result, L + I);
      Move(Buf, Result[L + 1], I);
      Inc(L, I);
    end;
end;

function ABlaiseStream.GetAsUTF8: String;
begin
  Result := LongStringToUTF8String(GetAsString);
end;

procedure ABlaiseStream.Assign(const Source: TObject);
begin
  if ObjectIsSimpleType(Source) then
    begin
      WriteStr(ObjectGetAsString(Source));
      Truncate;
    end
  else
    inherited Assign(Source);
end;

procedure ABlaiseStream.AssignTo(const Dest: TObject);
begin
  if ObjectIsSimpleType(Dest) then
    ObjectSetAsString(Dest, GetAsString)
  else
    inherited AssignTo(Dest);
end;

procedure ABlaiseStream.PackInteger(const A: Int64);
begin
  Write(A, Sizeof(Int64));
end;

procedure ABlaiseStream.PackFloat(const A: Extended);
begin
  Write(A, Sizeof(Extended));
end;

procedure ABlaiseStream.PackString(const A: String);
var L: Integer;
begin
  L := Length(A);
  PackInteger(L);
  if L > 0 then
    Write(Pointer(A)^, L);
end;

function ABlaiseStream.UnpackInteger: Int64;
begin
  ReadBuffer(Result, Sizeof(Int64));
end;

function ABlaiseStream.UnpackFloat: Extended;
begin
  ReadBuffer(Result, Sizeof(Extended));
end;

function ABlaiseStream.UnpackString: String;
var I: Int64;
    L: Integer;
begin
  I := UnpackInteger;
  if I > MaxInteger then
    raise EBlaiseStream.Create('Invalid packed string');
  L := Integer(I);
  SetLength(Result, L);
  if L > 0 then
    ReadBuffer(Pointer(Result)^, L);
end;

function ABlaiseStream.GetField(const FieldName: String;
    var Scope: ABlaiseType; var FieldType: TBlaiseFieldType): TObject;
begin
  Result := nil;
  if StrEqualNoCase(FieldName, 'ReadStr') or
     StrEqualNoCase(FieldName, 'WriteStr') or
     StrEqualNoCase(FieldName, 'ReadPacked') or
     StrEqualNoCase(FieldName, 'WritePacked') or
     StrEqualNoCase(FieldName, 'Truncate') then
    begin
      Scope := self;
      FieldType := bfCall;
      exit;
    end;
  if StrEqualNoCase(FieldName, 'EOF') then
    Result := GetImmutableBoolean(EOF) else
  if StrEqualNoCase(FieldName, 'Pos') then
    Result := GetImmutableInteger(GetPosition) else
  if StrEqualNoCase(FieldName, 'Size') then
    Result := GetImmutableInteger(GetSize);
  if Assigned(Result) then
    Scope := self
  else
    Result := inherited GetField(FieldName, Scope, FieldType);
end;

procedure ABlaiseStream.SetField(const FieldName: String;
    const Value: TObject);
begin
  if StrEqualNoCase(FieldName, 'Pos') then
    SetPosition(ObjectGetAsInteger(Value)) else
  if StrEqualNoCase(FieldName, 'Size') then
    SetSize(ObjectGetAsInteger(Value))
  else
    inherited SetField(FieldName, Value);
end;

function ABlaiseStream.CallField(const FieldName: String;
    const Parameters: Array of TObject): TObject;
var I : Integer;
begin
  if StrEqualNoCase(FieldName, 'ReadStr') then
    begin
      ValidateParamCount(1, 1, Parameters);
      Result := TTString.Create(ReadStr(ObjectGetAsInteger(Parameters[0])));
    end else
  if StrEqualNoCase(FieldName, 'WriteStr') then
    begin
      ValidateParamCount(1, 1, Parameters);
      WriteStr(ObjectGetAsString(Parameters[0]));
      Result := nil;
    end else
  if StrEqualNoCase(FieldName, 'ReadPacked') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Result := StreamInObject(GetReader);
    end else
  if StrEqualNoCase(FieldName, 'WritePacked') then
    begin
      ValidateParamCount(1, -1, Parameters);
      For I := 0 to Length(Parameters) - 1 do
        StreamOutObject(GetWriter, Parameters[I]);
      Result := nil;
    end else
  if StrEqualNoCase(FieldName, 'Truncate') then
    begin
      ValidateParamCount(0, 0, Parameters);
      Truncate;
      Result := nil;
    end
  else
    Result := inherited CallField(FieldName, Parameters);
end;



{                                                                              }
{ ANameSpace                                                                   }
{                                                                              }
function ANameSpace.GetTypeID: Byte;
begin
  Result := BLAISE_TYPE_ID_GEN_NameSpace;
end;

function ANameSpace.GetAsUTF8: String;
begin
  Result := BlaiseClassName(self);
end;

procedure ANameSpace.Start(const Domain: ANameSpaceDomain; const Path: String);
begin
end;

procedure ANameSpace.Stop;
begin
end;



initialization
  UnassignedValue := TTUnassigned.Create;
finalization
  FreeAndNil(UnassignedValue);
end.

