{                                                                              }
{                     Borland DCU Support for Blaise v0.06                     }
{                                                                              }
{     This unit is copyright © 2001-2003 by David J Butler (david@e.co.za)     }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{                 Its original file name is cBorlandDCU.pas                    }
{                                                                              }
{              All rights of this unit remains with its author.                }
{              It may not be used in any commercial application.               }
{                     It may not be modified in any way.                       }
{         I invite you to distibute this unit, but it must be for free.        }
{             I also invite you to contribute to its development,              }
{             but do not distribute a modified copy of this file.              }
{        Send modifications, suggestions and bug reports to david@e.co.za      }
{                                                                              }
{ Revision history:                                                            }
{   22/11/2001  0.01  Initial version                                          }
{   23/11/2001  0.02  Refactored                                               }
{   24/11/2001  0.03  Optimizations                                            }
{   25/11/2001  0.04  Refactored TdcuParser                                    }
{   30/11/2001  0.05  Moved TdcuParser to cBorlandDCUParser                    }
{                     575 lines interface. 1338 lines implementation.          }
{   02/12/2001  0.06  Implemented TdcuProcedure.Call                           }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseMachineDCU;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cDynLib,
  cReaders,
  cArrays,
  cDictionaries,
  cDCUParser,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructs,
  cBlaiseMachine;



{                                                                              }
{ TdcUnit                                                                      }
{   A parsed Borland DCU. A TdcUnit instance is populated by a TdcUnitParser.  }
{                                                                              }
type
  TdcUnit = class;

  { AdcuTypeDefinition                                                         }
  {   Base class for DCU type definitions                                      }
  AdcuTypeDefinition = class(ATypeDefinition)
    procedure RaiseDcuError(const Msg : String);
    procedure SetUnit(const dcUnit : TdcUnit); virtual;
    function  GetAsSource(const dcUnit : TdcUnit) : String; virtual;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; virtual;
    function  CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject; virtual;
    procedure SetDefinitionScope(const DefinitionScope : ABlaiseType); override;
    function  CanPassAsRegister : Boolean; virtual;
    function  GetValueAsParameterValue(const Value : TObject) : LongWord; virtual;
    function  GetValueAddress(const Value : TObject) : Pointer; virtual;
    function  InstanceDataSize : Integer; virtual;
  end;
  EdcuTypeDefinition = class(Exception);

  { AdcuDeclaration                                                            }
  {   Base class for DCU declarations                                          }
  AdcuDeclaration = class(AValueReference)
    protected
    FIdentifier : String;
    FValue      : TObject;
    FUnit       : TdcUnit;

    procedure RaiseDcuError(const Msg : String); virtual;
    function  CreateValue(const dcUnit : TdcUnit) : TObject; virtual;

    public
    constructor Create(const Identifier : String);

    procedure SetUnit(const dcUnit : TdcUnit);
    procedure SetAddressOffset(const Offset, Size : Integer); virtual;
    function  GetSourcePrefix : String; virtual;
    function  GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String; virtual;
    function  GetAddress(const dcUnit : TdcUnit) : Pointer; virtual;
    procedure ApplyFixups(const dcUnit : TdcUnit); virtual;
    Property  Identifier : String read FIdentifier;
    function  GetValue : TObject; override;
  end;
  EdcuDeclaration = class(Exception);

  { TdcuSourceFile                                                             }
  TdcuSourceFile = record
    SourceType : TdcuSourceFileType;
    Name       : String;
    FileTime   : TDateTime;
  end;
  PdcuSourceFile = ^TdcuSourceFile;

  { AdcuImport                                                                 }
  AdcuImport = class(AdcuDeclaration)
    function  GetIdentifierAddress(const Identifier : String) : Pointer; virtual; abstract;
  end;
  CdcuImport = class of AdcuImport;
  AdcuUnitImport = class(AdcuImport)
    function  ResolveValue(const FieldIdentifier : String; var ImportUnit : TdcUnit) : AdcuDeclaration;
    function  GetIdentifierAddress(const Identifier : String) : Pointer; override;
  end;
  TdcuInterfaceUnitImport = class(AdcuUnitImport);
  TdcuImplementationUnitImport = class(AdcuUnitImport);
  TdcuDLLImport = class(AdcuImport)
    protected
    FDynamicLibrary : TDynamicLibrary;
    FIdentifiers    : StringArray;
    FAddresses      : PointerArray;

    function GetDynamicLibrary : TDynamicLibrary;

    public
    destructor Destroy; override;
    function  GetIdentifierAddress(const Identifier : String) : Pointer; override;
  end;

  { TdcuImportedValueDeclaration                                               }
  TdcuImportedValueDeclaration = class(AdcuDeclaration)
    protected
    FFileIndex : Integer;

    public
    constructor Create(const FileIndex : Integer; const Section : TdcuImportSection; const Identifier : String);
    function  GetAddress(const dcUnit : TdcUnit) : Pointer; override;
    procedure ApplyFixups(const dcUnit : TdcUnit); override;
  end;

  { TFixupRec                                                                  }
  TFixupRec = record
    Offset       : Integer;
    FixupType    : TdcuFixupType;
    AddressIndex : Integer;
    FixedUp      : Boolean;
  end;
  PFixupRec = ^TFixupRec;

  { TdcUnit                                                                    }
  CdcuTypeDefinition = class of AdcuTypeDefinition;
  TdcUnit = class(ABlaiseType)
    protected
    FOnLog            : TdcuLogEvent;
    FVersion          : TDCUVersion;
    FFileTime         : TDateTime;
    FUnitName         : String;
    FSourceFiles      : Array of TdcuSourceFile;
    FImports          : Array of AdcuImport;
    FDeclarations     : TObjectDictionary;
    FTypes            : TObjectArray;
    FAddresses        : TObjectArray;
    FDataBlock        : String;
    FDataBlockOffset  : Integer;
    FFixups           : Array of TFixupRec;
    FDeclCount        : Integer;
    FApplicationScope : TApplicationScope;

    procedure Log(const Msg : String);
    procedure RaiseDcuError(const Msg : String);

    function  AddSourceFile(const SourceType : TdcuSourceFileType;
        const Name : String; const FileTime : TDateTime) : Integer;
    procedure AddDeclaration(const Identifier : String; const D : AdcuDeclaration);
    function  AddType(const D : AdcuTypeDefinition) : Integer;
    function  AddImportFile(const Section : TdcuImportSection; const Name : String; var FileIndex : Integer) : TObject;
    function  AddAddressItem(const Item : TObject) : Integer;
    procedure SetAddressItem(const AddressIndex : Integer; const Item : TObject);

    function  GetTypeByIndex(const Index : Integer) : AdcuTypeDefinition;
    function  GetTypeSource(const Index : Integer) : String;
    function  GetResolvedType(const Index : Integer) : AdcuTypeDefinition;
    function  GetFirstFixup(const Offset, Size : Integer) : Integer;
    procedure ApplyFixup(const FixupIndex : Integer);
    procedure ApplyFixups(const Offset, Size : Integer);

    public
    { AType implementation                                                     }
    function  GetField(const FieldName: String; var Scope: ABlaiseType;
              var FieldType: TBlaiseFieldType): TObject; override;
    procedure SetField(const FieldName : String; const Value : TObject); override;

    { TdcUnit interface                                                        }
    constructor Create;
    destructor Destroy; override;

    property  OnLog : TdcuLogEvent read FOnLog write FOnLog;

    procedure LoadFromReader(const S : AReaderEx);
    procedure LoadFromFile(const FileName : String);

    procedure SetApplicationScope(const ApplicationScope : TApplicationScope);

    property  Version : TDCUVersion read FVersion;
    function  VersionAsString : String;
    function  IsKylix : Boolean;
    function  IsDelphi : Boolean;
    function  IsDelphi4OrLater : Boolean;
    function  IsDelphi5OrLater : Boolean;

    property  UnitName : String read FUnitName;
    property  FileTime : TDateTime read FFileTime;

    function  GetAsSource : String;
  end;
  EdcUnit = class(EdcuParser);



{                                                                              }
{ TdcUnitParser                                                                }
{   AdcuParser implementation that populates a TdcUnit structure.              }
{                                                                              }
type
  TdcUnitParser = class(AdcuParser)
  protected
    FUnit : TdcUnit;

    { Header                                                                   }
    procedure SetVersion(const Version : TdcuVersion); override;
    procedure SetFileTime(const FileTime : TDateTime); override;
    procedure SetUnitFlags(const UnitFlags : LongWord); override;
    procedure SetPriorityFlags(const PriorityFlags : LongWord); override;
    procedure SetUnitName(const UnitName : String); override;

    { Addresses                                                                }
    function  AddAddressItem(const Item : TObject) : Integer; override;
    procedure SetAddressItem(const AddressIndex : Integer; const Item : TObject); override;
    procedure SetAddressOffset(const AddressIndex, Offset, Size : Integer); override;

    { Imports                                                                  }
    function  AddImportFile(const Section : TdcuImportSection; const Name : String; var FileIndex : Integer) : TObject; override;
    function  AddImportValue(const FileIndex : Integer; const Section : TdcuImportSection; const Name, ImportName : String) : TObject; override;
    function  AddImportType(const FileIndex : Integer; const Section : TdcuImportSection; const Name, ImportName : String) : TObject; override;
    procedure AddSourceFile(const SourceType : TdcuSourceFileType; const Name : String; const FileTime : TDateTime); override;

    { Declarations                                                             }
    procedure AddDeclaration(const Identifier : String; const Declaration : TObject); override;
    function  CreateArgumentDeclaration(const ArgType : TdcuArgumentType; const Identifier : String; const TypeIndex : Integer) : TObject; override;
    function  CreateFieldDeclaration(const ListType : TdcuFieldListType; const FieldType : TdcuFieldType; const Identifier : String; const TypeIndex, Offset : Integer) : TObject; override;

    function  CreateTypeDeclaration(const Identifier : String; const DefinitionIndex : Integer) : TObject; override;
    function  CreateDistinctTypeDeclaration(const Identifier : String; const DefinitionIndex : Integer) : TObject; override;
    function  CreateConstDeclaration(const Identifier : String; const TypeIndex : Integer; const Value : Int64) : TObject; override;
    function  CreateConstDeclaration(const Identifier : String; const TypeIndex : Integer; const Value : String) : TObject; override;
    function  CreateVarDeclaration(const Identifier : String; const TypeIndex : Integer) : TObject; override;
    function  CreateThreadVarDeclaration(const Identifier : String; const TypeIndex : Integer) : TObject; override;
    function  CreateInitializedVarDeclaration(const Identifier : String; const TypeIndex : Integer; const DataOffset : Integer) : TObject; override;
    function  CreateAbsoluteVarDeclaration(const Identifier : String; const TypeIndex : Integer; const Offset : Integer) : TObject; override;
    function  CreateProcDeclaration(const Identifier : String; const CallingConvention : TdcuProcCallingConvention; const Arguments, LocalDeclarations : ObjectArray; const ResultTypeIndex : Integer) : TObject; override;
    function  CreateSysProcDeclaration(const Identifier : String) : TObject; override;
    function  CreateEmbeddedProcDeclaration(const Identifier : String; const Declarations : ObjectArray; const CallingConvention : TdcuProcCallingConvention; const Arguments : ObjectArray; const ResultTypeIndex : Integer) : TObject; override;
    function  CreateLabelDeclaration(const Identifier : String; const Offset : LongWord) : TObject; override;
    function  CreateSetDefaultDeclaration(const ConstIndex, ArgIndex : Integer) : TObject; override;

    { Type Definitions                                                         }
    function  GetTypeCount : Integer; override;
    function  AddTypeDefinition(const TypeDefinition : TObject) : Integer; override;
    function  CreateFloatDefinition(const FloatType : TdcuFloatType) : TObject; override;
    function  CreateVariantDefinition(const VariantType : Byte): TObject; override;
    function  CreatePointerTypeDefinition(const ReferenceTypeIndex : Integer): TObject; override;
    function  CreateVoidTypeDefinition : TObject; override;
    function  CreateArrayDefinition : TObject; override;
    function  CreateShortStringDefinition : TObject; override;
    function  CreateStringDefinition : TObject; override;
    function  CreateRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; override;
    function  CreateCharRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; override;
    function  CreateBooleanRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; override;
    function  CreateWideCharRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; override;
    function  CreateWideRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; override;
    function  CreateFileDefinition(const ElementTypeIndex : Integer): TObject; override;
    function  CreateTextDefinition: TObject; override;
    function  CreateEnumDefinition(const BaseTypeIndex, Lo, Hi : Integer): TObject; override;
    function  CreateSetDefinition(const ElementTypeIndex : Integer): TObject; override;
    function  CreateRecordDefinition(const Size : Integer; const Fields : ObjectArray) : TObject; override;
    function  CreateClassDefinition(const ParentTypeIndex : Integer; const Fields : ObjectArray): TObject; override;
    function  CreateInterfaceDefinition(const IsDispInterface : Boolean; const ParentTypeIndex : Integer; const GUID : TGUID; const Fields : ObjectArray) : TObject; override;
    function  CreateObjectVMTDefinition(const ObjectTypeIndex : Integer): TObject; override;
    function  CreateProcTypeDefinition(const ResultTypeIndex : Integer; const CallingConvention : TdcuProcCallingConvention; const Arguments, LocalDeclarations : ObjectArray) : TObject; override;

    { Code                                                                     }
    procedure SetDataBlock(const DataBlock : String); override;
    procedure SetDataBlockOffset(const Offset : Integer); override;
    procedure SetFixupCount(const FixupCount : Integer); override;
    procedure SetFixupItem(const ItemIndex : Integer; const FixupType : TdcuFixupType; const Offset, AddressIndex : Integer); override;
    procedure SetCodeLinesCount(const CodeLines : Integer); override;
    procedure SetCodeLineOffset(const LineIndex, LineNr, LineOffset : Integer); override;

    { Unit                                                                     }
    procedure FinalizeParsing; override;

  public
    procedure ParseUnit(const dcUnit : TdcUnit; const RequiredVersion : TdcuVersion = dcuVerUndefined);
  end;



{                                                                              }
{ AdcuDeclaration classes                                                      }
{                                                                              }
type
  { AdcuDeclarationWithType                                                    }
  AdcuDeclarationWithType = class(AdcuDeclaration)
  protected
    FTypeIndex : Integer;

    function  ResolveType(const dcUnit : TdcUnit) : AdcuTypeDefinition;
    function  GetType(const dcUnit : TdcUnit) : AdcuTypeDefinition;
    function  GetTypeAsSource(const dcUnit : TdcUnit) : String;

  public
    constructor Create(const Identifier : String; const TypeIndex : Integer);

    property  TypeIndex : Integer read FTypeIndex;
  end;

  { TdcuConstDeclaration                                                       }
  TdcuConstDeclaration = class(AdcuDeclarationWithType)
  protected
    FIntValue : Int64;
    FStrValue : String;

  public
    constructor Create(const Identifier : String; const TypeIndex : Integer;
        const Value : Int64); overload;
    constructor Create(const Identifier : String; const TypeIndex : Integer;
        const Value : String); overload;

    function  GetSourcePrefix : String; override;
    function  GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String; override;
  end;

  { TdcuTypeDeclaration                                                        }
  TdcuTypeDeclaration = class(AdcuDeclarationWithType)
  protected
    function  CreateValue(const dcUnit : TdcUnit) : TObject; override;

  public
    constructor Create(const Identifier : String; const TypeIndex : Integer);
    function  GetSourcePrefix : String; override;
    function  GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String; override;
  end;
  TdcuDistinctTypeDeclaration = class(TdcuTypeDeclaration);

  { TdcuVarDeclaration                                                         }
  TdcuVarDeclaration = class(AdcuDeclarationWithType)
  protected
    FAddress : Pointer;

  public
    constructor Create(const Identifier : String; const TypeIndex : Integer);

    function  CreateValue(const dcUnit : TdcUnit) : TObject; override;
    function  GetAddress(const dcUnit : TdcUnit) : Pointer; override;
    function  GetSourcePrefix : String; override;
    function  GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String; override;
    procedure ApplyFixups(const dcUnit : TdcUnit); override;
  end;
  TdcuThreadVarDeclaration = class(TdcuVarDeclaration);
  TdcuInitializedVarDeclaration = class(TdcuVarDeclaration)
  protected
    FDataOffset : Integer;
    FOffset     : Integer;
    FSize       : Integer;

  public
    constructor Create(const Identifier : String; const TypeIndex : Integer; const DataOffset : Integer);

    function  GetAddress(const dcUnit : TdcUnit) : Pointer; override;
    procedure ApplyFixups(const dcUnit : TdcUnit); override;
    procedure SetAddressOffset(const Offset, Size : Integer); override;
  end;
  TdcuFieldDeclaration = class(TdcuVarDeclaration)
  protected
    FFieldOffset : Integer;

  public
    constructor Create(const Identifier : String; const TypeIndex, FieldOffset : Integer);
    function  GetAsRecordFieldFieldDefinition(const dcUnit : TdcUnit) : TRecordFieldFieldDefinition; virtual;
  end;
  TdcuFieldDeclarationArray = Array of TdcuFieldDeclaration;
  TdcuAbsoluteVarDeclaration = class(TdcuVarDeclaration)
    constructor Create(const Identifier : String; const TypeIndex, Offset : Integer);
  end;

  { AdcuArgumentDeclaration                                                    }
  AdcuArgumentDeclaration = class(AdcuDeclarationWithType)
    function  GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String; override;
    function  GetParameterValue(const dcUnit : TdcUnit; const Value : TObject) : LongWord; virtual; abstract;
  end;
  CdcuArgumentDeclaration = class of AdcuArgumentDeclaration;
  AdcuArgumentDeclarationArray = Array of AdcuArgumentDeclaration;

  TdcuArgumentValueDeclaration = class(AdcuArgumentDeclaration)
    function  GetParameterValue(const dcUnit : TdcUnit; const Value : TObject) : LongWord; override;
  end;
  TdcuArgumentVarDeclaration = class(AdcuArgumentDeclaration)
  end;
  TdcuArgumentResultDeclaration = class(AdcuArgumentDeclaration)
    function  GetParameterValue(const dcUnit : TdcUnit; const Value : TObject) : LongWord; override;
  end;
  TdcuLocalVarDeclaration = class(AdcuArgumentDeclaration)
  end;
  TdcuLocalAbsDeclaration = class(AdcuArgumentDeclaration)
  end;

  { TdcuSysProcDeclaration                                                     }
  TdcuSysProcDeclaration = class(AdcuDeclaration);

  { TdcuMethodDeclaration                                                      }
  TdcuMethodDeclaration = class(AdcuDeclaration)
  end;

  { TdcuPropertyDeclaration                                                    }
  TdcuPropertyDeclaration = class(AdcuDeclaration)
  end;

  { TdcuLabelDeclaration                                                       }
  TdcuLabelDeclaration = class(AdcuDeclaration)
    constructor Create(const Identifier : String; const Offset : Integer);
  end;

  { TdcuSetDefaultDeclaration                                                  }
  TdcuSetDefaultDeclaration = class(AdcuDeclaration)
    constructor Create(const ConstIndex, ArgIndex : Integer);
  end;

  { TdcuProcDeclaration                                                        }
  TdcuProcDeclaration = class(AdcuDeclaration)
  protected
    FResultTypeIndex   : Integer;
    FArguments         : AdcuArgumentDeclarationArray;
    FLocalDeclarations : ObjectArray;
    FOffset, FSize     : Integer;
    FCallingConvention : TdcuProcCallingConvention;

    function  CreateValue(const dcUnit : TdcUnit) : TObject; override;
    function  GetArgumentsAsSource(const dcUnit : TdcUnit) : String;

  public
    constructor Create(const Identifier : String;
        const CallingConvention : TdcuProcCallingConvention;
        const Arguments : AdcuArgumentDeclarationArray;
        const LocalDeclarations : ObjectArray;
        const ResultTypeIndex : Integer);
    destructor Destroy; override;

    property  ResultTypeIndex : Integer read FResultTypeIndex;
    function  GetSourcePrefix : String; override;
    function  GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String; override;
    procedure SetAddressOffset(const Offset, Size : Integer); override;
    function  GetAddress(const dcUnit : TdcUnit) : Pointer; override;
    procedure ApplyFixups(const dcUnit : TdcUnit); override;
  end;
  TdcuProcedure = class(AFunction)
  protected
    FUnit            : TdcUnit;
    FProcDeclaration : TdcuProcDeclaration;

  public
    constructor Create(const dcUnit : TdcUnit; const ProcDeclaration : TdcuProcDeclaration);

    function  Call(const Scope : ABlaiseType; const Parameters : Array of TObject) : TObject; override;
    function  GetParameters : TParameterAttributesArray; override;
  end;

  { TdcuEmbeddedProcDeclaration                                                }
  TdcuEmbeddedProcDeclaration = class(AdcuDeclaration)
    FOffset, FSize : Integer;

    constructor Create(const Identifier : String; const Declarations : ObjectArray;
      const CallingConvention : TdcuProcCallingConvention; const Arguments : ObjectArray;
      const ResultTypeIndex : Integer);
    procedure SetAddressOffset(const Offset, Size : Integer); override;
    procedure ApplyFixups(const dcUnit : TdcUnit); override;
    function  GetAddress(const dcUnit : TdcUnit) : Pointer; override;
  end;



{                                                                              }
{ AdcuTypeDefinition classes                                                   }
{                                                                              }
type
  { TdcuImportedTypeDefinition                                                 }
  TdcuImportedTypeDefinition = class(AdcuTypeDefinition)
    FileIndex  : Integer;
    ImportName : String;
    dcUnit     : TdcUnit;

    constructor Create(const FileIndex : Integer; const Section : TdcuImportSection; const ImportName : String);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    procedure SetUnit(const dcUnit : TdcUnit); override;
    function  IsType(const Value : TObject) : Boolean; override;
    function  ResolveType : ATypeDefinition; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject; override;
    function  GetValueAsParameterValue(const Value : TObject) : LongWord; override;
  end;

  { Simple types                                                               }
  TdcuStringDefinition = class(AdcuTypeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  IsType(const Value : TObject) : Boolean; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject; override;
    function  CanPassAsRegister : Boolean; override;
    function  GetValueAsParameterValue(const Value : TObject) : LongWord; override;
  end;
  TdcuBooleanDefinition = class(AdcuTypeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  IsType(const Value : TObject) : Boolean; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject; override;
    function  CanPassAsRegister : Boolean; override;
    function  GetValueAsParameterValue(const Value : TObject) : LongWord; override;
    function  GetValueAddress(const Value : TObject) : Pointer; override;
    function  InstanceDataSize : Integer; override;
  end;
  TdcuCharDefinition = class(AdcuTypeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CanPassAsRegister : Boolean; override;
  end;
  TdcuWideCharDefinition = class(AdcuTypeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;
  AdcuIntegerDefinition = class(AdcuTypeDefinition)
    function  IsType(const Value : TObject) : Boolean; override;
    function  CreateTypeInstance : TObject; override;
    function  CanPassAsRegister : Boolean; override;
  end;
  TdcuByteDefinition = class(AdcuIntegerDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  InstanceDataSize : Integer; override;
  end;
  TdcuWordDefinition = class(AdcuIntegerDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;
  TdcuLongIntDefinition = class(AdcuIntegerDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject; override;
    function  GetValueAsParameterValue(const Value : TObject) : LongWord; override;
    function  InstanceDataSize : Integer; override;
  end;
  TdcuLongWordDefinition = class(AdcuIntegerDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject; override;
  end;

  { TdcuRangeDefinition                                                        }
  TdcuRangeDefinition = class(AdcuTypeDefinition)
    FElementTypeIndex : Integer;
    FLowBound, FHighBound : Int64;

    constructor Create(const ElementTypeIndex : Integer; const LowBound, HighBound : Int64);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;
  TdcuCharRangeDefinition = class(TdcuRangeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;
  TdcuBooleanRangeDefinition = class(TdcuRangeDefinition);
  TdcuWideCharRangeDefinition = class(TdcuRangeDefinition);
  TdcuWideRangeDefinition = class(TdcuRangeDefinition);

  { TdcuEnumDefinition                                                         }
  TdcuEnumDefinition = class(AdcuTypeDefinition)
    constructor Create(const BaseTypeIndex : Integer; const Lo, Hi : Int64);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuSetDefinition                                                          }
  TdcuSetDefinition = class(AdcuTypeDefinition)
    constructor Create(const ElementTypeIndex : Integer);
    function GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { AdcuFloatDefinition                                                        }
  AdcuFloatDefinition = class(AdcuTypeDefinition)
    function  CanPassAsRegister : Boolean; override;
  end;
  TdcuReal48Definition = class(AdcuFloatDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;
  TdcuSingleDefinition = class(AdcuFloatDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;
  TdcuDoubleDefinition = class(AdcuFloatDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;
  TdcuExtendedDefinition = class(AdcuFloatDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;
  TdcuCompDefinition = class(AdcuFloatDefinition)
    function GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;
  TdcuCurrencyDefinition = class(AdcuFloatDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;

  { TdcuArrayDefinition                                                        }
  TdcuArrayDefinition = class(AdcuTypeDefinition)
    function GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuShortStringDefinition                                                  }
  TdcuShortStringDefinition = class(TdcuArrayDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
  end;

  { AdcuRecordDefinition                                                       }
  AdcuRecordDefinition = class(AdcuTypeDefinition)
  end;

  { TdcuRecordDefinition                                                       }
  TdcuRecordDefinition = class(AdcuRecordDefinition)
  protected
    FDataSize   : Integer;
    FFields     : TdcuFieldDeclarationArray;
    FRecordType : TRecordType;
    FUnit       : TdcUnit;

    function  GetRecordType(const dcUnit : TdcUnit) : TRecordType;

  public
    constructor Create(const DataSize : Integer; const Fields : TdcuFieldDeclarationArray);
    destructor Destroy; override;

    procedure SetUnit(const dcUnit : TdcUnit); override;
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CanPassAsRegister : Boolean; override;
    function  CreateTypeInstance : TObject; override;
    function  CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject; override;
    function  GetValueAddress(const Value : TObject) : Pointer; override;
    function  InstanceDataSize : Integer; override;
  end;

  { TdcuPointerDefinition                                                      }
  TdcuPointerDefinition = class(AdcuTypeDefinition)
  protected
    FReferenceTypeIndex : Integer;

  public
    constructor Create(const ReferenceTypeIndex : Integer);

    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  InstanceDataSize : Integer; override;
  end;

  { TdcuVoidDefinition                                                         }
  TdcuVoidDefinition = class(AdcuTypeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuClassDefinition                                                        }
  TdcuClassDefinition = class(AdcuRecordDefinition)
    constructor Create(const ParentTypeIndex : Integer; const Fields : ObjectArray);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuInterfaceDefinition                                                    }
  TdcuInterfaceDefinition = class(AdcuRecordDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuObjectVMTDefinition                                                     }
  TdcuObjectVMTDefinition = class(AdcuTypeDefinition)
    constructor Create(const ObjectTypeIndex : Integer);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuFileDefinition                                                         }
  TdcuFileDefinition = class(AdcuTypeDefinition)
    constructor Create(const ElementTypeIndex : Integer);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
  end;

  { TdcuTextDefinition                                                         }
  TdcuTextDefinition = class(AdcuTypeDefinition)
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  InstanceDataSize : Integer; override;
  end;

  { TdcuVariantDefinition                                                      }
  TdcuVariantDefinition = class(AdcuTypeDefinition)
    constructor Create(const VariantType : Byte);
    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  CanPassAsRegister : Boolean; override;
  end;

  { TdcuProcTypeDefinition                                                     }
  TdcuProcTypeDefinition = class(AdcuTypeDefinition)
    FCallingConvention : TdcuProcCallingConvention;

    function  GetAsSource(const dcUnit : TdcUnit) : String; override;
    function  InstanceDataSize : Integer; override;
  end;


implementation

uses
  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseStructsSimple,
  cBlaiseFuncs;



{                                                                              }
{ AdcuTypeDefinition                                                           }
{                                                                              }
procedure AdcuTypeDefinition.RaiseDcuError(const Msg : String);
  begin
    raise EdcuTypeDefinition.Create (ObjectClassName (self) + ': ' + Msg);
  end;

procedure AdcuTypeDefinition.SetUnit(const dcUnit : TdcUnit);
  begin
  end;

function AdcuTypeDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := '{' + ObjectClassName (self) + '}';
  end;

procedure AdcuTypeDefinition.SetDefinitionScope(const DefinitionScope : ABlaiseType);
  begin
  end;

{$WARNINGS OFF}
function AdcuTypeDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    RaiseDcuError ('CreateTypeInstanceFromData not implemented');
  end;

function AdcuTypeDefinition.CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject;
  begin
    RaiseDcuError ('CreateTypeInstanceFromResult not implemented');
  end;

function AdcuTypeDefinition.CanPassAsRegister : Boolean;
  begin
    RaiseDcuError ('CannPassAsRegister not implemented');
  end;

function AdcuTypeDefinition.GetValueAsParameterValue(const Value : TObject) : LongWord;
  begin
    RaiseDcuError ('GetValueAsParameterValue not implemented');
  end;

function AdcuTypeDefinition.GetValueAddress(const Value : TObject) : Pointer;
  begin
    RaiseDcuError ('GetValueAddress not implemented');
  end;

function AdcuTypeDefinition.InstanceDataSize : Integer;
  begin
    RaiseDcuError ('InstanceDataSize not implemented');
  end;
{$WARNINGS ON}


{ TdcuRangeDefinition                                                          }
constructor TdcuRangeDefinition.Create(const ElementTypeIndex : Integer; const LowBound, HighBound : Int64);
  begin
    inherited Create;
    FElementTypeIndex := ElementTypeIndex;
    FLowBound := LowBound;
    FHighBound := HighBound;
  end;

function TdcuRangeDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
var T : AdcuTypeDefinition;
  begin
    T := dcUnit.GetResolvedType (FElementTypeIndex);
    if T = self then
      Result := 'self' else
      if Assigned (T) then
        Result := T.GetAsSource (dcUnit) else
        Result := 'nil';
    Result := IntToStr (FLowBound) + '..' + IntToStr (FHighBound) + ' { ' + Result + ' }';
  end;

function TdcuCharRangeDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
var T : AdcuTypeDefinition;
  begin
    T := dcUnit.GetResolvedType (FElementTypeIndex);
    if T = self then
      Result := 'self' else
      if Assigned (T) then
        Result := T.GetAsSource (dcUnit) else
        Result := 'nil';
    Result := '#' + IntToStr (FLowBound) + '..#' + IntToStr (FHighBound) + ' { ' + Result + ' }';
  end;

function TdcuCharDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Char';
  end;

function TdcuCharDefinition.CanPassAsRegister : Boolean;
  begin
    Result := True;
  end;

function TdcuWideCharDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'WideChar';
  end;

{ TdcuBooleanDefinition                                                        }
function TdcuBooleanDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Boolean';
  end;

function TdcuBooleanDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTBoolean.Create;
  end;

function TdcuBooleanDefinition.IsType(const Value : TObject) : Boolean;
  begin
    Result := Value is TTBoolean;
  end;

function TdcuBooleanDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTBoolean.Create (PBoolean (Data)^);
  end;

function TdcuBooleanDefinition.CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject;
  begin
    Result := TTBoolean.Create (ResultValue <> 0);
  end;

function TdcuBooleanDefinition.CanPassAsRegister : Boolean;
  begin
    Result := True;
  end;

function TdcuBooleanDefinition.GetValueAsParameterValue(const Value : TObject) : LongWord;
  begin
    Result := Ord (ObjectGetAsBoolean (Value));
  end;

function TdcuBooleanDefinition.GetValueAddress(const Value : TObject) : Pointer;
  begin
    if not (Value is TTBoolean) then
      RaiseDcuError ('Not a boolean');
    Result := @TTBoolean (Value).Value;
  end;

function TdcuBooleanDefinition.InstanceDataSize : Integer;
  begin
    Result := 1;
  end;

{ AdcuIntegerDefinition                                                        }
function AdcuIntegerDefinition.IsType(const Value : TObject) : Boolean;
  begin
    Result := Value is TTInteger;
  end;

function AdcuIntegerDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTInteger.Create;
  end;

function AdcuIntegerDefinition.CanPassAsRegister : Boolean;
  begin
    Result := True;
  end;

{ TdcuByteDefinition                                                           }
function TdcuByteDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Byte';
  end;

function TdcuByteDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTInteger.Create (PByte (Data)^);
  end;

function TdcuByteDefinition.InstanceDataSize : Integer;
  begin
    Result := Sizeof (Byte);
  end;

{ TdcuWordDefinition                                                           }
function TdcuWordDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Word';
  end;

function TdcuWordDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTInteger.Create (PWord (Data)^);
  end;

{ TdcuLongIntDefinition                                                        }
function TdcuLongIntDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'LongInt';
  end;

function TdcuLongIntDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTInteger.Create (PLongInt (Data)^);
  end;

function TdcuLongIntDefinition.CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject;
  begin
    Result := TTInteger.Create (LongInt (ResultValue));
  end;

function TdcuLongIntDefinition.GetValueAsParameterValue(const Value : TObject) : LongWord;
  begin
    Result := ObjectGetAsInteger (Value);
  end;

function TdcuLongIntDefinition.InstanceDataSize : Integer;
  begin
    Result := Sizeof (LongInt);
  end;

{ TdcuLongWordDefinition                                                       }
function TdcuLongWordDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'LongWord';
  end;

function TdcuLongWordDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTInteger.Create (PLongWord (Data)^);
  end;

function TdcuLongWordDefinition.CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject;
  begin
    Result := TTInteger.Create (ResultValue);
  end;

{ TdcuEnumDefinition                                                           }
constructor TdcuEnumDefinition.Create(const BaseTypeIndex : Integer; const Lo, Hi : Int64);
  begin
    inherited Create;
  end;

function TdcuEnumDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Enum';
  end;

{ TdcuSetDefinition                                                            }
constructor TdcuSetDefinition.Create(const ElementTypeIndex : Integer);
  begin
    inherited Create;
  end;

function TdcuSetDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Set';
  end;

{ AdcuFloatDefinition                                                          }
function AdcuFloatDefinition.CanPassAsRegister : Boolean;
  begin
    Result := False;
  end;

{ TdcuReal48Definition                                                         }
function TdcuReal48Definition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Real48';
  end;

function TdcuReal48Definition.CreateTypeInstance : TObject;
  begin
    Result := TTFloat.Create;
  end;

function TdcuReal48Definition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
type PReal48 = ^Real48;
  begin
    Result := TTFloat.Create (PReal48 (Data)^);
  end;

{ TdcuSingleDefinition                                                         }
function TdcuSingleDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Single';
  end;

function TdcuSingleDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTFloat.Create;
  end;

function TdcuSingleDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTFloat.Create (PSingle (Data)^);
  end;

{ TdcuDoubleDefinition                                                         }
function TdcuDoubleDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Double';
  end;

function TdcuDoubleDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTFloat.Create;
  end;

function TdcuDoubleDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTFloat.Create (PDouble (Data)^);
  end;

{ TdcuExtendedDefinition                                                       }
function TdcuExtendedDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Extended';
  end;

function TdcuExtendedDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTFloat.Create;
  end;

function TdcuExtendedDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTFloat.Create (PExtended (Data)^);
  end;

{ TdcuCurrencyDefinition                                                       }
function TdcuCurrencyDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Currency';
  end;

function TdcuCurrencyDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTCurrency.Create;
  end;

function TdcuCurrencyDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTCurrency.Create (PCurrency (Data)^);
  end;

{ TdcuCompDefinition                                                           }
function TdcuCompDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Comp';
  end;

{ TdcuArrayDefinition                                                          }
function TdcuArrayDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Array';
  end;

{ TdcuShortStringDefinition                                                    }
function TdcuShortStringDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'ShortString';
  end;

function TdcuShortStringDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTString.Create;
  end;

function TdcuShortStringDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTString.Create (PShortString (Data)^);
  end;

{ TdcuStringDefinition                                                         }
function TdcuStringDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'String';
  end;

function TdcuStringDefinition.IsType(const Value : TObject) : Boolean;
  begin
    Result := Value is TTString;
  end;

function TdcuStringDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTString.Create;
  end;

function TdcuStringDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
var P : PChar;
    S : String;
    L : Integer;
  begin
    P := Data;
    Inc (P, 8);
    L := PInteger (P)^;
    SetLength (S, L);
    if L > 0 then
      begin
        Inc (P, 4);
        Move (P^, S [1], L);
      end;
    Result := TTString.Create (S);
  end;

function TdcuStringDefinition.CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject;
var S : String;
    P : PChar absolute S;
  begin
    P := Pointer (ResultValue);
    Result := TTString.Create (S);
  end;

function TdcuStringDefinition.CanPassAsRegister : Boolean;
  begin
    Result := True;
  end;

function TdcuStringDefinition.GetValueAsParameterValue(const Value : TObject) : LongWord;
  begin
    if not (Value is TTString) then
      RaiseDcuError ('Not a string');
//    Result := LongWord (TTString (Value).AsPChar);
    Result := LongWord (Pointer (TTString (Value).Value));
  end;

{ TdcuRecordDefinition                                                         }
constructor TdcuRecordDefinition.Create(const DataSize : Integer; const Fields : TdcuFieldDeclarationArray);
  begin
    inherited Create;
    FFields := Fields;
    FDataSize := DataSize;
  end;

destructor TdcuRecordDefinition.Destroy;
  begin
    FreeObjectArray (FFields);
    inherited Destroy;
  end;

function TdcuRecordDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Record';
  end;

function TdcuRecordDefinition.CanPassAsRegister : Boolean;
  begin
    Result := False;
  end;

procedure TdcuRecordDefinition.SetUnit(const dcUnit : TdcUnit);
  begin
    FUnit := dcUnit;
  end;

function TdcuRecordDefinition.GetRecordType(const dcUnit : TdcUnit) : TRecordType;
var I, L : Integer;
    F : TRecordFieldFieldDefinitionArray;
  begin
    Result := FRecordType;
    if Assigned (Result) then
      exit;
    L := Length (FFields);
    SetLength (F, L);
    For I := 0 to L - 1 do
      F [I] := FFields [I].GetAsRecordFieldFieldDefinition (dcUnit);
    FRecordType := TRecordType.Create (nil, F);
    Result := FRecordType;
  end;

function TdcuRecordDefinition.CreateTypeInstance : TObject;
  begin
    Result := TTRecord.Create (GetRecordType (FUnit));
  end;

function TdcuRecordDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := TTRecord.Create (GetRecordType (dcUnit));
    inherited CreateTypeInstanceFromData (dcUnit, Data);
  end;

function TdcuRecordDefinition.GetValueAddress(const Value : TObject) : Pointer;
  begin
    Result := inherited GetValueAddress (Value);
  end;

function TdcuRecordDefinition.InstanceDataSize : Integer;
  begin
    Result := FDataSize;
  end;

{ TdcuPointerDefinition                                                        }
constructor TdcuPointerDefinition.Create(const ReferenceTypeIndex : Integer);
  begin
    inherited Create;
    FReferenceTypeIndex := ReferenceTypeIndex;
  end;

function TdcuPointerDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Pointer';
  end;

function TdcuPointerDefinition.InstanceDataSize : Integer;
  begin
    Result := Sizeof (Pointer);
  end;

{ TdcuVoidDefinition                                                           }
function TdcuVoidDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Void';
  end;

{ TdcuClassDefinition                                                          }
constructor TdcuClassDefinition.Create(const ParentTypeIndex : Integer; const Fields : ObjectArray);
  begin
    inherited Create;
  end;

function TdcuClassDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'class';
  end;

{ TdcuInterfaceDefinition                                                      }
function TdcuInterfaceDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'interface';
  end;

{ TdcuProcTypeDefinition                                                       }
function TdcuProcTypeDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'procedure';
  end;

function TdcuProcTypeDefinition.InstanceDataSize : Integer;
  begin
    Result := Sizeof (Pointer);
  end;

{ TdcuObjectVMTDefinition                                                      }
constructor TdcuObjectVMTDefinition.Create(const ObjectTypeIndex : Integer);
  begin
    inherited Create;
  end;

function TdcuObjectVMTDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'VMT';
  end;

{ TdcuFileDefinition                                                           }
constructor TdcuFileDefinition.Create(const ElementTypeIndex : Integer);
  begin
    inherited Create;
  end;

function TdcuFileDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'File';
  end;

{ TdcuTextDefinition                                                           }
function TdcuTextDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Text';
  end;

function TdcuTextDefinition.InstanceDataSize : Integer;
  begin
    Result := Sizeof (Text);
  end;

{ TdcuVariantDefinition                                                        }
constructor TdcuVariantDefinition.Create(const VariantType : Byte);
  begin
    inherited Create;
  end;

function TdcuVariantDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := 'Variant';
  end;

function TdcuVariantDefinition.CanPassAsRegister : Boolean;
  begin
    Result := False;
  end;

{ TdcuImportedTypeDefinition                                                   }
constructor TdcuImportedTypeDefinition.Create(const FileIndex : Integer; const Section : TdcuImportSection; const ImportName : String);
  begin
    self.FileIndex := FileIndex;
    self.ImportName := ImportName;
    inherited Create;
  end;

function TdcuImportedTypeDefinition.GetAsSource(const dcUnit : TdcUnit) : String;
  begin
    Result := dcUnit.FImports [FileIndex].Identifier + '.' + ImportName;
  end;

procedure TdcuImportedTypeDefinition.SetUnit(const dcUnit : TdcUnit);
  begin
    self.dcUnit := dcUnit;
  end;

function TdcuImportedTypeDefinition.ResolveType : ATypeDefinition;
var U : ABlaiseType;
  begin
    U := dcUnit.FApplicationScope.ImportUnit (dcUnit.FImports [FileIndex].Identifier);
    Result := AdcuTypeDefinition (U.GetValueAsType (ImportName, True, AdcuTypeDefinition, 'Identifier not a type'));
  end;

function TdcuImportedTypeDefinition.IsType(const Value : TObject) : Boolean;
  begin
    Result := ResolveType.IsType (Value);
  end;

function TdcuImportedTypeDefinition.CreateTypeInstance : TObject;
  begin
    Result := ResolveType.CreateTypeInstance;
  end;

function TdcuImportedTypeDefinition.CreateTypeInstanceFromData(const dcUnit : TdcUnit; const Data : Pointer) : TObject;
  begin
    Result := AdcuTypeDefinition (ResolveType).CreateTypeInstanceFromData (dcUnit, Data);
  end;

function TdcuImportedTypeDefinition.CreateTypeInstanceFromResult(const ResultValue : LongWord) : TObject;
  begin
    Result := AdcuTypeDefinition (ResolveType).CreateTypeInstanceFromResult (ResultValue); 
  end;

function TdcuImportedTypeDefinition.GetValueAsParameterValue(const Value : TObject) : LongWord;
  begin
    Result := AdcuTypeDefinition (ResolveType).GetValueAsParameterValue  (Value); 
  end;


{                                                                              }
{ AdcuDeclaration                                                              }
{                                                                              }
constructor AdcuDeclaration.Create(const Identifier : String);
  begin
    inherited Create;
    FIdentifier := Identifier;
  end;

procedure AdcuDeclaration.RaiseDcuError(const Msg : String);
  begin
    raise EdcuDeclaration.Create (ObjectClassName (self) + ' (' + FIdentifier + '): ' + Msg);
  end;

function AdcuDeclaration.GetSourcePrefix : String;
  begin
    Result := '{type:' + ClassName + '}';
  end;

{$WARNINGS OFF}
function AdcuDeclaration.GetAddress(const dcUnit : TdcUnit) : Pointer;
  begin
    RaiseDcuError ('GetAddress not implemented');
  end;

procedure AdcuDeclaration.ApplyFixups(const dcUnit : TdcUnit);
  begin
    RaiseDcuError ('ApplyFixups not implemented');
  end;
{$WARNINGS ON}

function AdcuDeclaration.GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String;
  begin
    Result := Identifier + ' : {type:' + ClassName + '}';
  end;

procedure AdcuDeclaration.SetUnit(const dcUnit : TdcUnit);
  begin
    FUnit := dcUnit;
  end;

procedure AdcuDeclaration.SetAddressOffset(const Offset, Size : Integer);
  begin
  end;

function AdcuDeclaration.GetValue : TObject;
  begin
    Result := FValue;
    if not Assigned (Result) then
      begin
        Result := CreateValue (FUnit);
        FValue := Result;
      end;
    if Result is AValueReference then
      Result := AValueReference (Result).GetValue;
  end;

{$WARNINGS OFF}
function AdcuDeclaration.CreateValue(const dcUnit : TdcUnit) : TObject;
  begin
    RaiseDcuError ('CreateValue not implemented');
  end;
{$WARNINGS ON}


{ AdcuUnitImport                                                               }
function AdcuUnitImport.ResolveValue(const FieldIdentifier : String; var ImportUnit : TdcUnit) : AdcuDeclaration;
var U, P : ABlaiseType;
    T    : TBlaiseFieldType;
  begin
    U := FUnit.FApplicationScope.ImportUnit (FIdentifier);
    if not (U is TdcUnit) then
      RaiseDcuError ('Unit not a DCU: ' + ObjectClassName (U));
    ImportUnit := TdcUnit (U);
    Result := AdcuDeclaration (ImportUnit.GetField (FieldIdentifier, P, T));
    if not Assigned (Result) then
      RaiseDcuError ('Declaration not found: ' + FieldIdentifier);
  end;

function AdcuUnitImport.GetIdentifierAddress(const Identifier : String) : Pointer;
var U : TdcUnit;
  begin
    Result := ResolveValue (Identifier, U).GetAddress (U);
  end;

{ TdcuDLLImport                                                                }
destructor TdcuDLLImport.Destroy;
var I : Integer;
  begin
    For I := Length (FAddresses) - 1 downto 0 do
      FreeMem (FAddresses [I], Sizeof (Pointer));
    FAddresses := nil;
    FreeAndNil (FDynamicLibrary);
    inherited Destroy;
  end;

function TdcuDLLImport.GetDynamicLibrary : TDynamicLibrary;
  begin
    Result := FDynamicLibrary;
    if Assigned (Result) then
      exit;
    FDynamicLibrary := TDynamicLibrary.Create (FIdentifier);
    Result := FDynamicLibrary;
  end;

function TdcuDLLImport.GetIdentifierAddress(const Identifier : String) : Pointer;
var I : Integer;
    P, Q : Pointer;
  begin
    For I := 0 to Length (FIdentifiers) - 1 do
      if Identifier = FIdentifiers [I] then
        begin
          Result := FAddresses [I];
          exit;
        end;
    P := GetDynamicLibrary.ProcAddress [Identifier];
    GetMem (Q, Sizeof (Pointer));
    PLongWord (Q)^ := LongWord (P);
    Result := Q;
    Append (FIdentifiers, Identifier);
    Append (FAddresses, Result);
  end;

{ TdcuImportedValueDeclaration                                                 }
constructor TdcuImportedValueDeclaration.Create(const FileIndex : Integer; const Section : TdcuImportSection; const Identifier : String);
  begin
    inherited Create (Identifier);
    FFileIndex := FileIndex;
  end;

function TdcuImportedValueDeclaration.GetAddress(const dcUnit : TdcUnit) : Pointer;
  begin
    Result := dcUnit.FImports [FFileIndex].GetIdentifierAddress (FIdentifier);
  end;

procedure TdcuImportedValueDeclaration.ApplyFixups(const dcUnit : TdcUnit);
var U : TdcUnit;
    F : AdcuImport;
  begin
    F := dcUnit.FImports [FFileIndex];
    if F is AdcuUnitImport then
      AdcuUnitImport (F).ResolveValue (FIdentifier, U).ApplyFixups (U);
  end;



{                                                                              }
{ TdcUnit                                                                      }
{                                                                              }
constructor TdcUnit.Create;
  begin
    inherited Create;
    FDeclarations := TObjectDictionary.CreateEx (nil, nil, True, False, True, ddAccept);
    FTypes := TObjectArray.Create (nil, True);
    FAddresses := TObjectArray.Create (nil, False);
  end;

destructor TdcUnit.Destroy;
  begin
    FreeAndNil (FAddresses);
    FreeAndNil (FDeclarations);
    FreeAndNil (FTypes);
    inherited Destroy;
  end;

procedure TdcUnit.Log(const Msg : String);
  begin
    if Assigned (FOnLog) then
      FOnLog (self, Msg);
  end;

procedure TdcUnit.RaiseDcuError(const Msg : String);
  begin
    raise EdcUnit.Create (FUnitName, FVersion, Msg);
  end;

function TdcUnit.AddSourceFile(const SourceType : TdcuSourceFileType; const Name : String; const FileTime : TDateTime) : Integer;
var S : PdcuSourceFile;
  begin
    Result := Length (FSourceFiles);
    SetLength (FSourceFiles, Result + 1);
    S := @FSourceFiles [Result];
    S.SourceType := SourceType;
    S.Name := Name;
    S.FileTime := FileTime;
  end;

procedure TdcUnit.AddDeclaration(const Identifier : String; const D : AdcuDeclaration);
  begin
    if Assigned (D) then
      D.SetUnit (self); 
    FDeclarations.Add (Identifier, D);
  end;

function TdcUnit.AddType(const D : AdcuTypeDefinition) : Integer;
  begin
    Result := FTypes.AppendItem (D);
    if Assigned (D) then
      D.SetUnit (self);
  end;

function TdcUnit.GetTypeByIndex(const Index : Integer) : AdcuTypeDefinition;
  begin
    if (Index <= 0) or (Index > FTypes.Count) then
      RaiseDcuError ('Invalid Index');
    Result := AdcuTypeDefinition (FTypes [Index - 1]);
    Assert (Assigned (Result), 'Type ' + IntToHex (Index, 1) + ' nil');
  end;

function TdcUnit.GetTypeSource(const Index : Integer) : String;
var T : AdcuTypeDefinition;
  begin
    T := GetTypeByIndex (Index);
    if Assigned (T) then
      Result := T.GetAsSource (self) else
      Result := '{' + ObjectClassName (T) + '}';
  end;

function TdcUnit.GetResolvedType(const Index : Integer) : AdcuTypeDefinition;
  begin
    Result := GetTypeByIndex (Index).ResolveType as AdcuTypeDefinition;
  end;

function TdcUnit.GetFirstFixup(const Offset, Size : Integer) : Integer;
var I, L, H, U, D : Integer;
  begin
    // Does a binary search (assumes Fixup table is sorted ascending by Offset)
    U := Offset + Size - 1;
    L := 0;
    H := Length (FFixups) - 1;
    Repeat
      I := (L + H) div 2;
      D := FFixups [I].Offset;
      if D > U then
        H := I - 1 else
      if D < Offset then
        L := I + 1 else
        begin
          While (I > 0) and (FFixups [I - 1].Offset >= Offset) do
            Dec (I);
          Result := I;
          exit;
        end;
    Until L > H;
    Result := -1;
  end;

procedure TdcUnit.ApplyFixup(const FixupIndex : Integer);
var P : PFixupRec;
    V : TObject;
    A, B : LongWord;
  begin
    P := @FFixups [FixupIndex];
    if not (P^.FixupType in [fxAddress, fxJumpAddress, fxDataAddress]) then
      exit;
    if P^.FixedUp then
      exit;
    P^.FixedUp := True;
    V := FAddresses [P^.AddressIndex - 1];
    Assert (Assigned (V), 'Address ' + IntToStr (P^.AddressIndex) + ' not assigned');
    if not (V is AdcuDeclaration) then
      RaiseDcuError ('Can not apply fixup on ' + V.ClassName);
    AdcuDeclaration (V).ApplyFixups (self);
    A := LongWord (AdcuDeclaration (V).GetAddress (self));
    B := LongWord (@PChar (FDataBlock) [P^.Offset]);
    if P^.FixupType = fxJumpAddress then
      LongInt (A) := Int64 (A) - Int64 (B) - 4;
    Inc (PLongWord (Pointer (B))^, A);
  end;

procedure TdcUnit.ApplyFixups(const Offset, Size : Integer);
var I, L, H : Integer;
  begin
    I := GetFirstFixup (Offset, Size);
    if I = -1 then
      exit;
    H := Offset + Size - 1;
    L := Length (FFixups);
    While (I < L) and (FFixups [I].Offset <= H) do
      begin
        ApplyFixup (I);
        Inc (I);
      end;
  end;

function TdcUnit.AddImportFile(const Section : TdcuImportSection; const Name : String; var FileIndex : Integer) : TObject;
const ImportClasses : Array [TdcuImportSection] of CdcuImport =
          (TdcuInterfaceUnitImport, TdcuImplementationUnitImport, TdcuDLLImport);
  begin
    Result := ImportClasses [Section].Create (Name);
    AdcuImport (Result).SetUnit (self);
    FileIndex := Append (ObjectArray (FImports), Result);
  end;

function TdcUnit.AddAddressItem(const Item : TObject) : Integer;
  begin
    Result := FAddresses.AppendItem (Item);
  end;

procedure TdcUnit.SetAddressItem(const AddressIndex : Integer; const Item : TObject);
  begin
    Assert (not Assigned (FAddresses.Item [AddressIndex]), 'Duplicate setting of address item');
    FAddresses.Item [AddressIndex] := Item;
  end;

function TdcUnit.GetAsSource : String;

  function GetUsesListAsSource(const Section : TdcuImportSection) : String;
  var I : Integer;
      F : Boolean;
    begin
      F := True;
      For I := Length (FImports) - 1 downto 0 do
//        if FImports [I].Section = Section then
          if F then
            begin
              Result := 'uses' + CRLF +
                        '  ' + FImports [I].Identifier;
              F := False;
            end else
            Result := Result + ',' + CRLF + '  ' + FImports [I].Identifier;
      if F then
        Result := '' else
        Result := Result + ';' + CRLF + CRLF;
    end;

  function GetDeclarationsAsSource : String;
  var I : Integer;
      Q : AdcuDeclaration;
      S, T : String;
    begin
      Result := '';
      T := '';
      For I := 0 to FDeclarations.Count - 1 do
        begin
          Q := AdcuDeclaration (FDeclarations.GetItemByIndex (I));
          try
            S := Q.GetSourcePrefix;
            if S <> T then
              begin
                if S <> '' then
                  Result := Result + S + CRLF;
                T := S;
              end;
            Result := Result + '  ' + Q.GetDeclarationAsSource (self, FDeclarations.GetKeyByIndex (I)) + CRLF;
          except
            Result := Result + '[' + Q.ClassName + ']' + CRLF;
          end;
        end;
    end;

  function GetAddresses : String;
  var I : Integer;
      V : TObject;
    begin
      Result := '{ Addresses:' + CRLF;
      For I := 0 to FAddresses.Count - 1 do
        begin
          V := FAddresses [I];
          Result := Result + IntToHex (I + 1, 1) + '. ';
          if V is AdcuDeclaration then
            Result := Result + AdcuDeclaration (V).FIdentifier else
            Result := Result + ObjectClassName (V);
          Result := Result + CRLF;
        end;
      Result := Result + '}' + CRLF;
    end;

  function GetFixups : String;
  var I : Integer;
    begin
      Result := '{ Fixups:' + CRLF;
      For I := 0 to Length (FFixups) - 1 do
        begin
          Result := Result + IntToStr (I) + '. ' + IntToHex (FFixups [I].Offset, 1) + ' ' +
              IntToHex (FFixups [I].AddressIndex, 1) + CRLF;
        end;
      Result := Result + '}' + CRLF;
    end;

  begin
    Result := 'unit ' + UnitName + ';' + CRLF +
              '// Compiled with ' + dcuVersionAsString (Version) + CRLF +
              '// Creation date: ' + FormatDateTime ('dd mmm yyyy hh:nn:ss', FileTime) + CRLF +
              CRLF +
              'interface' + CRLF +
              CRLF +
              GetUsesListAsSource (dcuInterfaceImport) +
              GetDeclarationsAsSource +
              CRLF +
              'implementation' + CRLF +
              CRLF +
              GetUsesListAsSource (dcuImplementationImport) +
              'end.';
    Result := '';
    Result := Result + CRLF + CRLF +
              GetAddresses + CRLF +
              GetFixups;
  end;

function TdcUnit.GetField(const FieldName : String; var Scope : ABlaiseType;
    var FieldType: TBlaiseFieldType) : TObject;
  begin
    Result := nil;
    Scope := nil;
    FieldType := bfObject;
//    Result := FDeclarations.GetField (FieldName, Parent);
  end;

procedure TdcUnit.SetField(const FieldName : String; const Value : TObject);
  begin
    RaiseDcuError ('Not implemented');
  end;

{ Version                                                                      }
function TdcUnit.IsKylix : Boolean;
  begin
    Result := FVersion in KylixVersions;
  end;

function TdcUnit.IsDelphi : Boolean;
  begin
    Result := FVersion in DelphiVersions;
  end;

function TdcUnit.IsDelphi4OrLater : Boolean;
  begin
    Result := FVersion in Delphi4AndLaterVersions;
  end;

function TdcUnit.IsDelphi5OrLater : Boolean;
  begin
    Result := FVersion in Delphi5AndLaterVersions;
  end;

function TdcUnit.VersionAsString : String;
  begin
    Result := dcuVersionAsString (FVersion);
  end;

{ Load                                                                         }
procedure TdcUnit.LoadFromReader(const S : AReaderEx);
var P : TdcUnitParser;
  begin
    P := TdcUnitParser.Create (S, False);
    try
      P.OnLog := FOnLog;
      P.ParseUnit (self);
    finally
      P.Free;
    end;
  end;

procedure TdcUnit.LoadFromFile(const FileName : String);
var F : TFileReader;
  begin
    F := TFileReader.Create (FileName);
    try
      LoadFromReader (F);
    finally
      FreeAndNil (F);
    end;
  end;

procedure TdcUnit.SetApplicationScope(const ApplicationScope : TApplicationScope);
  begin
    FApplicationScope := ApplicationScope;
  end;



{ AdcuDeclarationWithType                                                      }
constructor AdcuDeclarationWithType.Create(const Identifier : String; const TypeIndex : Integer);
  begin
    inherited Create (Identifier);
    FTypeIndex := TypeIndex;
  end;

function AdcuDeclarationWithType.ResolveType(const dcUnit : TdcUnit) : AdcuTypeDefinition;
  begin
    Result := dcUnit.GetResolvedType (FTypeIndex);
  end;

function AdcuDeclarationWithType.GetType(const dcUnit : TdcUnit) : AdcuTypeDefinition;
  begin
    Result := dcUnit.GetTypeByIndex (FTypeIndex);
  end;

function AdcuDeclarationWithType.GetTypeAsSource(const dcUnit : TdcUnit) : String;
  begin
    try
      Result := dcUnit.GetTypeSource (FTypeIndex);
    except
      Result := '[]';
    end;
  end;

{ TdcuConstDeclaration                                                         }
constructor TdcuConstDeclaration.Create(const Identifier : String; const TypeIndex : Integer; const Value : Int64);
  begin
    inherited Create (Identifier, TypeIndex);
    FIntValue := Value;
  end;

constructor TdcuConstDeclaration.Create(const Identifier : String; const TypeIndex : Integer; const Value : String);
  begin
    inherited Create (Identifier, TypeIndex);
    FStrValue := Value;
  end;

function TdcuConstDeclaration.GetSourcePrefix : String;
  begin
    Result := 'const';
  end;

function TdcuConstDeclaration.GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String;
var I : Integer;
  begin
    Result := Identifier + ' : ' + GetTypeAsSource (dcUnit) + ' = ';
    if FStrValue <> '' then
      begin
        For I := 1 to Length (FStrValue) do
          Result := Result + IntToHex (Ord (FStrValue [I]), 2);
      end else
      Result := Result + IntToStr (FIntValue);
    Result := Result + ';';
  end;

{ TdcuTypeDeclaration                                                          }
constructor TdcuTypeDeclaration.Create(const Identifier : String; const TypeIndex : Integer);
  begin
    inherited Create (Identifier, TypeIndex);
  end;

function TdcuTypeDeclaration.GetSourcePrefix : String;
  begin
    Result := 'type';
  end;

function TdcuTypeDeclaration.GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String;
var T : AdcuTypeDefinition;
  begin
    Result := Identifier + ' = ';
    try
      T := dcUnit.GetTypeByIndex (FTypeIndex);
      if Assigned (T) then
        Result := Result + T.GetAsSource (dcUnit) else
        Result := Result + '[nil]';
    except
      on E : Exception do
        Result := Result + '[Error:' + E.Message + ']';
    end;
    Result := Result + ';';
  end;

function TdcuTypeDeclaration.CreateValue(const dcUnit : TdcUnit) : TObject;
  begin
    Result := TScopeValue.CreateConstant (ResolveType (dcUnit));
  end;

{ TdcuVarDeclaration                                                           }
constructor TdcuVarDeclaration.Create(const Identifier : String; const TypeIndex : Integer);
  begin
    inherited Create (Identifier, TypeIndex);
  end;

constructor TdcuAbsoluteVarDeclaration.Create(const Identifier : String; const TypeIndex, Offset : Integer);
  begin
    inherited Create (Identifier, TypeIndex);
  end;

function TdcuVarDeclaration.GetSourcePrefix : String;
  begin
    Result := 'var';
  end;

function TdcuVarDeclaration.GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String;
  begin
    Result := Identifier + ' : ' + GetTypeAsSource (dcUnit) + ';';
  end;

procedure TdcuVarDeclaration.ApplyFixups(const dcUnit : TdcUnit);
  begin
  end;

{$WARNINGS OFF}
function TdcuVarDeclaration.CreateValue(const dcUnit : TdcUnit) : TObject;
  begin
    RaiseDcuError ('DCU Global variables not accessible');
  end;
{$WARNINGS ON}

function TdcuVarDeclaration.GetAddress(const dcUnit : TdcUnit) : Pointer;
var T : AdcuTypeDefinition;
    L : Integer;
  begin
    Result := FAddress;
    if Assigned (Result) then
      exit;
    T := ResolveType (dcUnit);
    Assert (Assigned (T), 'Variable has no type');
    L := T.InstanceDataSize;
    GetMem (FAddress, L);
    FillChar (FAddress^, L, #0);
    Result := FAddress;
  end;

{ TdcuInitializedVarDeclaration                                                }
constructor TdcuInitializedVarDeclaration.Create(const Identifier : String; const TypeIndex : Integer; const DataOffset : Integer);
  begin
    inherited Create (Identifier, TypeIndex);
    FDataOffset := DataOffset;
  end;

function TdcuInitializedVarDeclaration.GetAddress(const dcUnit : TdcUnit) : Pointer;
  begin
    Result := @PChar (dcUnit.FDataBlock) [FDataOffset];
  end;

procedure TdcuInitializedVarDeclaration.ApplyFixups(const dcUnit : TdcUnit);
  begin
    dcUnit.ApplyFixups (FOffset, FSize);
  end;

procedure TdcuInitializedVarDeclaration.SetAddressOffset(const Offset, Size : Integer);
  begin
    FOffset := Offset;
    FSize := Size;
  end;

{ TdcuFieldDeclaration                                                         }
constructor TdcuFieldDeclaration.Create(const Identifier : String; const TypeIndex, FieldOffset : Integer);
  begin
    inherited Create (Identifier, TypeIndex);
    FFieldOffset := FieldOffset;
  end;

function TdcuFieldDeclaration.GetAsRecordFieldFieldDefinition(const dcUnit : TdcUnit) : TRecordFieldFieldDefinition;
  begin
    Result := TRecordFieldFieldDefinition.Create (FIdentifier, nil, GetType (dcUnit));
  end;

{ TdcuMethodDeclaration                                                        }

{ TdcuPropertyDeclaration                                                      }

{ TdcuLabelDeclaration                                                         }
constructor TdcuLabelDeclaration.Create(const Identifier : String; const Offset : Integer);
  begin
    inherited Create (Identifier);
  end;

{ TdcuSetDefaultDeclaration                                                    }
constructor TdcuSetDefaultDeclaration.Create(const ConstIndex, ArgIndex : Integer);
  begin
    inherited Create ('');
  end;

{ AdcuArgumentDeclaration                                                      }
function AdcuArgumentDeclaration.GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String;
  begin
    Result := inherited GetDeclarationAsSource (dcUnit, FIdentifier);
  end;

{ TdcuArgumentValueDeclaration                                                 }
function TdcuArgumentValueDeclaration.GetParameterValue(const dcUnit : TdcUnit; const Value : TObject) : LongWord;
  begin
    Result := GetType (dcUnit).GetValueAsParameterValue (Value);
  end;

{ TdcuArgumentVarDeclaration                                                   }

{ TdcuArgumentResultDeclaration                                                }
function TdcuArgumentResultDeclaration.GetParameterValue(const dcUnit : TdcUnit; const Value : TObject) : LongWord;
  begin
    Result := GetType (dcUnit).GetValueAsParameterValue (Value);
  end;

{ TdcuLocalVarDeclaration                                                      }

{ TdcuProcedure                                                                }
constructor TdcuProcedure.Create(const dcUnit : TdcUnit; const ProcDeclaration : TdcuProcDeclaration);
  begin
    inherited Create;
    FUnit := dcUnit;
    FProcDeclaration := ProcDeclaration;
  end;

function TdcuProcedure.GetParameters : TParameterAttributesArray;
var I, L : Integer;
  begin
    L := Length (FProcDeclaration.FArguments);
    SetLength (Result, L);
    For I := 0 to L - 1 do
      Result [I] := [];
  end;

function TdcuProcedure.Call(const Scope : ABlaiseType; const Parameters : Array of TObject) : TObject;
var I, L, ArgCount, ParamCount, LocalsCount : Integer;
    ParameterValue : LongWordArray;
    Arguments : AdcuArgumentDeclarationArray;
    PassInRegisters, PassLeftToRight : Boolean;
    ResultArgInRegister : Boolean;
    DoParameterCleanup : Boolean;
    ParameterInRegister : BooleanArray;
    RegistersUsed : Integer;
    RegisterValue : Array [0..2] of LongWord;
    ProcAddress : Pointer;
    ResultType : AdcuTypeDefinition;
    Isprocedure : Boolean;
    ResultArgument : TdcuArgumentResultDeclaration;
    ResultValue : LongWord;
    ResultRef : LongWord;
  begin
    Arguments := FProcDeclaration.FArguments;
    ArgCount := Length (Arguments);
    ParamCount := Length (Parameters);
    LocalsCount := Length (FProcDeclaration.FLocalDeclarations);
    PassInRegisters := FProcDeclaration.FCallingConvention = ccRegister;
    PassLeftToRight := FProcDeclaration.FCallingConvention in [ccRegister, ccPascal];
    DoParameterCleanup := FProcDeclaration.FCallingConvention = ccCDecl;

    ResultType := FUnit.GetTypeByIndex (FProcDeclaration.FResultTypeIndex);
    IsProcedure := ResultType is TdcuVoidDefinition;

    if not IsProcedure and (LocalsCount > 0) and (FProcDeclaration.FLocalDeclarations [0] is TdcuArgumentResultDeclaration) then
      ResultArgument := TdcuArgumentResultDeclaration (FProcDeclaration.FLocalDeclarations [0]) else
      ResultArgument := nil;

    L := ArgCount;
    if Assigned (ResultArgument) then
      Inc (L);
    SetLength (ParameterValue, L);
    For I := 0 to ParamCount - 1 do
      ParameterValue [I] := Arguments [I].GetParameterValue (FUnit, Parameters [I]);
    For I := ParamCount to ArgCount - 1 do
      ParameterValue [I] := Arguments [I].GetParameterValue (FUnit, nil);
    if Assigned (ResultArgument) then
      begin
        ResultRef := ResultArgument.GetParameterValue (FUnit,
            ResultArgument.ResolveType (FUnit).CreateTypeInstance);
        ParameterValue [ArgCount] := LongWord (@ResultRef);
      end;

    if PassInRegisters then
      begin
        SetLengthAndZero (ParameterInRegister, L);
        RegistersUsed := 0;
        For I := 0 to ArgCount - 1 do
          if Arguments [I].ResolveType (FUnit).CanPassAsRegister then
            begin
              ParameterInRegister [I] := True;
              RegisterValue [RegistersUsed] := ParameterValue [I];
              Inc (RegistersUsed);
              if RegistersUsed = 3 then
                break;
            end;
        ResultArgInRegister := Assigned (ResultArgument) and (RegistersUsed < 3) and
            ResultArgument.ResolveType (FUnit).CanPassAsRegister;
        if ResultArgInRegister then
          begin
            ParameterInRegister [ArgCount] := True;
            RegisterValue [RegistersUsed] := ParameterValue [ArgCount];
            Inc (RegistersUsed);
          end;
      end;

    FProcDeclaration.ApplyFixups (FUnit);
    ProcAddress := FProcDeclaration.GetAddress (FUnit);

    Asm
        // Push stack parameters
        mov edx, dword ptr ParameterValue
        mov ecx, L
        test ecx, ecx
        jz @DoCall

        cmp PassInRegisters, 0
        je @PassStackOnly

        // Push certain values on stack
        mov eax, dword ptr ParameterInRegister
      @StackParamLoop:
        cmp byte ptr [eax], 0
        jne @NextStackParam
        push dword ptr [edx]
      @NextStackParam:
        dec ecx
        jz @SetRegisterParams
        inc eax
        add edx, 4
        jmp @StackParamLoop

        // Push all values on stack
      @PassStackOnly:
        cmp PassLeftToRight, 0
        je @PassRightToLeft
      @LeftToRightLoop:
        push dword ptr [edx]
        dec ecx
        jz @DoCall
        add edx, 4
        jmp @LeftToRightLoop
      @PassRightToLeft:
        mov eax, ecx
        dec eax
        shl eax, 2
        add edx, eax
      @RightToLeftLoop:
        push dword ptr [edx]
        dec ecx
        jz @DoCall
        sub edx, 4
        jmp @RightToLeftLoop

        // Set register parameters (EAX, EDX, ECX)
      @SetRegisterParams:
        mov ecx, RegistersUsed
        test ecx, ecx
        jz @DoCall
        mov eax, dword ptr RegisterValue [0]
        dec ecx
        jz @DoCall
        mov edx, dword ptr RegisterValue [4]
        dec ecx
        jz @DoCall
        mov ecx, dword ptr RegisterValue [8]

      @DoCall:
        call [ProcAddress]
        mov ResultValue, eax

        // Do parameter clean-up
        cmp DoParameterCleanup, 0
        je @CallComplete
        mov ecx, L
        shl ecx, 2
        add esp, ecx

      @CallComplete:
    end;

    if IsProcedure then
      Result := nil else
      if Assigned (ResultArgument) then
        Result := ResultType.CreateTypeInstanceFromResult (ResultRef) else
        Result := ResultType.CreateTypeInstanceFromResult (ResultValue);
  end;

{ TdcuProcDeclaration                                                          }
constructor TdcuProcDeclaration.Create(const Identifier : String; const CallingConvention : TdcuProcCallingConvention; const Arguments : AdcuArgumentDeclarationArray; const LocalDeclarations : ObjectArray; const ResultTypeIndex : Integer);
  begin
    inherited Create (Identifier);
    FResultTypeIndex := ResultTypeIndex;
    FArguments := Arguments;
    FLocalDeclarations := LocalDeclarations;
    FCallingConvention := CallingConvention;
  end;

destructor TdcuProcDeclaration.Destroy;
  begin
    FreeObjectArray (FLocalDeclarations);
    FreeObjectArray (FArguments);
    inherited Destroy;
  end;

function TdcuProcDeclaration.GetSourcePrefix : String;
  begin
    Result := '';
  end;

function TdcuProcDeclaration.GetArgumentsAsSource(const dcUnit : TdcUnit) : String;
var I : Integer;
  begin
    Result := '';
    For I := 0 to Length (FArguments) - 1 do
      Result := Result + FArguments [I].GetDeclarationAsSource (dcUnit, '') + '; ';
  end;

function TdcuProcDeclaration.GetDeclarationAsSource(const dcUnit : TdcUnit; const Identifier : String) : String;
  begin
    Result := 'procedure ' + Identifier + ' (' +
        GetArgumentsAsSource (dcUnit) + ') : ' +
        dcUnit.GetTypeSource (FResultTypeIndex) + ';';
  end;

function TdcuProcDeclaration.CreateValue(const dcUnit : TdcUnit) : TObject;
  begin
    Result := TdcuProcedure.Create (dcUnit, self);
  end;

procedure TdcuProcDeclaration.SetAddressOffset(const Offset, Size : Integer);
  begin
    FOffset := Offset;
    FSize := Size;
  end;

function TdcuProcDeclaration.GetAddress(const dcUnit : TdcUnit) : Pointer;
  begin
    Result := @PChar (dcUnit.FDataBlock) [FOffset];
  end;

procedure TdcuProcDeclaration.ApplyFixups(const dcUnit : TdcUnit);
  begin
    dcUnit.ApplyFixups (FOffset, FSize);
  end;

{ TdcuEmbeddedProcDeclaration                                                  }
constructor TdcuEmbeddedProcDeclaration.Create(const Identifier : String; const Declarations : ObjectArray; const CallingConvention : TdcuProcCallingConvention; const Arguments : ObjectArray; const ResultTypeIndex : Integer);
  begin
    inherited Create (Identifier);
  end;

procedure TdcuEmbeddedProcDeclaration.SetAddressOffset(const Offset, Size : Integer);
  begin
    FOffset := Offset;
    FSize := Size;
  end;

procedure TdcuEmbeddedProcDeclaration.ApplyFixups(const dcUnit : TdcUnit);
  begin
    dcUnit.ApplyFixups (FOffset, FSize);
  end;

function TdcuEmbeddedProcDeclaration.GetAddress(const dcUnit : TdcUnit) : Pointer;
  begin
    Result := @PChar (dcUnit.FDataBlock) [FOffset];
  end;


{                                                                              }
{ TdcUnitParser                                                                }
{                                                                              }
procedure TdcUnitParser.ParseUnit(const dcUnit : TdcUnit; const RequiredVersion : TdcuVersion);
  begin
    FUnit := dcUnit;
    inherited ParseUnit (RequiredVersion);
  end;

function TdcUnitParser.GetTypeCount : Integer;
  begin
    Result := FUnit.FTypes.Count;
  end;

function TdcUnitParser.AddTypeDefinition(const TypeDefinition : TObject) : Integer;
  begin
    Result := FUnit.AddType (TypeDefinition as AdcuTypeDefinition);
  end;

procedure TdcUnitParser.AddDeclaration(const Identifier : String; const Declaration : TObject);
  begin
    FUnit.AddDeclaration (Identifier, Declaration as AdcuDeclaration);
  end;

procedure TdcUnitParser.SetVersion(const Version : TdcuVersion);
  begin
    FUnit.FVersion := Version;
  end;

procedure TdcUnitParser.SetFileTime(const FileTime : TDateTime);
  begin
    FUnit.FFileTime := FileTime;
  end;

procedure TdcUnitParser.SetUnitFlags(const UnitFlags : LongWord);
  begin
  end;

procedure TdcUnitParser.SetPriorityFlags(const PriorityFlags : LongWord);
  begin
  end;

procedure TdcUnitParser.SetUnitName(const UnitName : String);
  begin
    FUnit.FUnitName := UnitName;
  end;

{ Addresses                                                                    }
procedure TdcUnitParser.SetAddressOffset(const AddressIndex, Offset, Size : Integer);

  procedure AddressError(const Msg : String);
    begin
      FormatError ('SetAddressOffset ' + IntToStr (AddressIndex) + ': ' + Msg);
    end;

var V : TObject;
  begin
    if (AddressIndex <= 0) and (AddressIndex > FUnit.FAddresses.Count) then
      AddressError ('Invalid AddressIndex: ' + IntToStr (AddressIndex));
    if Offset >= Length (FUnit.FDataBlock) then
      AddressError ('Invalid Offset: ' + IntToStr (Offset));
    if Offset + Size > Length (FUnit.FDataBlock) then
      AddressError ('Invalid Size: ' + IntToStr (Offset + Size));

    V := FUnit.FAddresses [AddressIndex - 1];
    if V is AdcuDeclaration then
      AdcuDeclaration (V).SetAddressOffset (Offset, Size);
  end;

function TdcUnitParser.AddAddressItem(const Item : TObject) : Integer;
  begin
    Result := FUnit.AddAddressItem (Item);
  end;

procedure TdcUnitParser.SetAddressItem(const AddressIndex : Integer; const Item : TObject);
  begin
    Assert ((AddressIndex > 0) and (AddressIndex <= FUnit.FAddresses.Count), 'SetAddressItem: Invalid AddressIndex: ' + IntToStr (AddressIndex));
    FUnit.SetAddressItem (AddressIndex, Item);
  end;

{                                                                              }
procedure TdcUnitParser.AddSourceFile(const SourceType : TdcuSourceFileType; const Name : String; const FileTime : TDateTime);
  begin
    FUnit.AddSourceFile (SourceType, Name, FileTime);
  end;

function TdcUnitParser.AddImportFile(const Section : TdcuImportSection; const Name : String; var FileIndex : Integer) : TObject;
  begin
    Result := FUnit.AddImportFile (Section, Name, FileIndex);
  end;

function TdcUnitParser.AddImportValue(const FileIndex : Integer; const Section : TdcuImportSection; const Name, ImportName : String): TObject;
  begin
    Result := TdcuImportedValueDeclaration.Create (FileIndex, Section, ImportName);
  end;

function TdcUnitParser.AddImportType(const FileIndex : Integer; const Section : TdcuImportSection; const Name, ImportName : String) : TObject;
  begin
    Result := TdcuImportedTypeDefinition.Create (FileIndex, Section, ImportName);
  end;

function TdcUnitParser.CreateArgumentDeclaration(const ArgType : TdcuArgumentType; const Identifier : String; const TypeIndex : Integer) : TObject;
const
  ArgClasses : Array [TdcuArgumentType] of CdcuArgumentDeclaration = (
      TdcuLocalVarDeclaration, TdcuArgumentValueDeclaration, TdcuArgumentVarDeclaration,
      TdcuArgumentResultDeclaration, TdcuLocalAbsDeclaration);
  begin
    Result := ArgClasses [ArgType].Create (Identifier, TypeIndex);
  end;

function TdcUnitParser.CreateFieldDeclaration(const ListType : TdcuFieldListType; const FieldType : TdcuFieldType; const Identifier : String; const TypeIndex, Offset : Integer) : TObject;
  begin
    Case FieldType of
      ftField        : Result := TdcuFieldDeclaration.Create (Identifier, TypeIndex, Offset);
      ftMethod,
      ftConstructor,
      ftDestructor,
      ftProperty     : Result := nil;
    else
      Result := nil;
    end;
  end;

function TdcUnitParser.CreateConstDeclaration(const Identifier : String; const TypeIndex : Integer; const Value : Int64) : TObject;
  begin
    Result := TdcuConstDeclaration.Create (Identifier, TypeIndex, Value);
  end;

function TdcUnitParser.CreateConstDeclaration(const Identifier : String; const TypeIndex : Integer; const Value : String) : TObject;
  begin
    Result := TdcuConstDeclaration.Create (Identifier, TypeIndex, Value);
  end;

function TdcUnitParser.CreateTypeDeclaration(const Identifier : String; const DefinitionIndex : Integer) : TObject;
  begin
    Result := TdcuTypeDeclaration.Create (Identifier, DefinitionIndex);
  end;

function TdcUnitParser.CreateDistinctTypeDeclaration(const Identifier : String; const DefinitionIndex : Integer) : TObject;
  begin
    Result := TdcuDistinctTypeDeclaration.Create (Identifier, DefinitionIndex);
  end;

function TdcUnitParser.CreateVarDeclaration(const Identifier : String; const TypeIndex : Integer) : TObject;
  begin
    Result := TdcuVarDeclaration.Create (Identifier, TypeIndex);
  end;

function TdcUnitParser.CreateThreadVarDeclaration(const Identifier : String; const TypeIndex : Integer) : TObject;
  begin
    Result := TdcuThreadVarDeclaration.Create (Identifier, TypeIndex);
  end;

function TdcUnitParser.CreateInitializedVarDeclaration(const Identifier : String; const TypeIndex : Integer; const DataOffset : Integer) : TObject;
  begin
    Result := TdcuInitializedVarDeclaration.Create (Identifier, TypeIndex, DataOffset);
  end;

function TdcUnitParser.CreateAbsoluteVarDeclaration(const Identifier : String; const TypeIndex : Integer; const Offset : Integer) : TObject;
  begin
    Result := TdcuAbsoluteVarDeclaration.Create (Identifier, TypeIndex, Offset);
  end;

function TdcUnitParser.CreateProcDeclaration(const Identifier : String; const CallingConvention : TdcuProcCallingConvention; const Arguments, LocalDeclarations : ObjectArray; const ResultTypeIndex : Integer) : TObject;
  begin
    Result := TdcuProcDeclaration.Create (Identifier, CallingConvention, AdcuArgumentDeclarationArray (Arguments), LocalDeclarations, ResultTypeIndex);
  end;

function TdcUnitParser.CreateSysProcDeclaration(const Identifier : String) : TObject;
  begin
    Result := TdcuSysProcDeclaration.Create (Identifier);
  end;

function TdcUnitParser.CreateEmbeddedProcDeclaration(const Identifier : String; const Declarations : ObjectArray; const CallingConvention : TdcuProcCallingConvention; const Arguments : ObjectArray; const ResultTypeIndex : Integer) : TObject;
  begin
    Result := TdcuEmbeddedProcDeclaration.Create (Identifier, Declarations, CallingConvention, Arguments, ResultTypeIndex);
  end;

function TdcUnitParser.CreateLabelDeclaration(const Identifier : String; const Offset : LongWord) : TObject;
  begin
    Result := TdcuLabelDeclaration.Create (Identifier, Offset);
  end;

function TdcUnitParser.CreateSetDefaultDeclaration(const ConstIndex, ArgIndex : Integer) : TObject;
  begin
    Result := TdcuSetDefaultDeclaration.Create (ConstIndex, ArgIndex);
  end;

{ Type Definitions                                                             }
function TdcUnitParser.CreatePointerTypeDefinition(const ReferenceTypeIndex : Integer) : TObject;
  begin
    Result := TdcuPointerDefinition.Create (ReferenceTypeIndex);
  end;

function TdcUnitParser.CreateVoidTypeDefinition : TObject;
  begin
    Result := TdcuVoidDefinition.Create;
  end;

function TdcUnitParser.CreateObjectVMTDefinition(const ObjectTypeIndex : Integer) : TObject;
  begin
    Result := TdcuObjectVMTDefinition.Create (ObjectTypeIndex);
  end;

function TdcUnitParser.CreateProcTypeDefinition(const ResultTypeIndex : Integer; const CallingConvention : TdcuProcCallingConvention; const Arguments, LocalDeclarations : ObjectArray) : TObject;
  begin
    Result := TdcuProcTypeDefinition.Create;
  end;

function TdcUnitParser.CreateFileDefinition(const ElementTypeIndex : Integer) : TObject;
  begin
    Result := TdcuFileDefinition.Create (ElementTypeIndex);
  end;

function TdcUnitParser.CreateTextDefinition : TObject;
  begin
    Result := TdcuTextDefinition.Create;
  end;

function TdcUnitParser.CreateVariantDefinition(const VariantType : Byte) : TObject;
  begin
    Result := TdcuVariantDefinition.Create (VariantType);
  end;

function TdcUnitParser.CreateEnumDefinition(const BaseTypeIndex, Lo, Hi : Integer) : TObject;
  begin
    Result := TdcuEnumDefinition.Create (BaseTypeIndex, Lo, Hi);
  end;

function TdcUnitParser.CreateSetDefinition(const ElementTypeIndex : Integer) : TObject;
  begin
    Result := TdcuSetDefinition.Create (ElementTypeIndex);
  end;

function TdcUnitParser.CreateRecordDefinition(const Size : Integer; const Fields : ObjectArray) : TObject;
  begin
    Result := TdcuRecordDefinition.Create (Size, TdcuFieldDeclarationArray (Fields));
  end;

function TdcUnitParser.CreateFloatDefinition(const FloatType : TdcuFloatType) : TObject;
const
  FloatClasses : Array [TdcuFloatType] of CdcuTypeDefinition =
      (TdcuReal48Definition, TdcuSingleDefinition, TdcuDoubleDefinition,
       TdcuExtendedDefinition, TdcuCompDefinition, TdcuCurrencyDefinition);
  begin
    Result := FloatClasses [FloatType].Create;
  end;

function TdcUnitParser.CreateArrayDefinition : TObject;
  begin
    Result := nil;
  end;

function TdcUnitParser.CreateClassDefinition(const ParentTypeIndex : Integer; const Fields : ObjectArray) : TObject;
  begin
    Result := TdcuClassDefinition.Create (ParentTypeIndex, Fields);
  end;

function TdcUnitParser.CreateInterfaceDefinition(const IsDispInterface : Boolean; const ParentTypeIndex : Integer; const GUID : TGUID; const Fields : ObjectArray) : TObject;
  begin
    Result := nil;
  end;

function TdcUnitParser.CreateShortStringDefinition : TObject;
  begin
    Result := TdcuShortStringDefinition.Create;
  end;

function TdcUnitParser.CreateStringDefinition : TObject;
  begin
    Result := TdcuStringDefinition.Create;
  end;

function TdcUnitParser.CreateRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject;
  begin
    Result := nil;
    if TypeIndex = ElementTypeIndex then
      if (LowBound = MinLongInt) and (HighBound = MaxLongInt) then
        Result := TdcuLongIntDefinition.Create else
      if (LowBound = MinLongWord) and (HighBound = MaxLongWord) then
        Result := TdcuLongWordDefinition.Create;
    if not Assigned (Result) then
      Result := TdcuRangeDefinition.Create (ElementTypeIndex, LowBound, HighBound);
  end;

function TdcUnitParser.CreateCharRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject;
  begin
    if (TypeIndex = ElementTypeIndex) and (LowBound = 0) and (HighBound = $FF) then
      Result := TdcuCharDefinition.Create else
      Result := TdcuCharRangeDefinition.Create (ElementTypeIndex, LowBound, HighBound);
  end;

function TdcUnitParser.CreateBooleanRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject;
  begin
    if (TypeIndex = ElementTypeIndex) and (LowBound = 0) and (HighBound = 1) then
      Result := TdcuBooleanDefinition.Create else
      Result := TdcuBooleanRangeDefinition.Create (ElementTypeIndex, LowBound, HighBound);
  end;

function TdcUnitParser.CreateWideCharRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject;
  begin
    if (TypeIndex = ElementTypeIndex) and (LowBound = 0) and (HighBound = $FFFF) then
      Result := TdcuWideCharDefinition.Create else
      Result := TdcuWideCharRangeDefinition.Create (ElementTypeIndex, LowBound, HighBound);
  end;

function TdcUnitParser.CreateWideRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject;
  begin
    Result := TdcuWideRangeDefinition.Create (ElementTypeIndex, LowBound, HighBound);
  end;

{ Code                                                                         }
procedure TdcUnitParser.SetDataBlock(const DataBlock : String);
  begin
    FUnit.FDataBlock := DataBlock;
  end;

procedure TdcUnitParser.SetDataBlockOffset(const Offset : Integer);
  begin
    if Offset > Length (FUnit.FDataBlock) then
      FormatError ('SetDataBlockOffset: Invalid DataBlockOffset');
    FUnit.FDataBlockOffset := Offset;
  end;

procedure TdcUnitParser.SetFixupCount(const FixupCount : Integer);
  begin
    SetLength (FUnit.FFixups, FixupCount);
  end;

procedure TdcUnitParser.SetFixupItem(const ItemIndex : Integer; const FixupType : TdcuFixupType; const Offset, AddressIndex : Integer);
var P : PFixupRec;
  begin
    P := @FUnit.FFixups [ItemIndex];
    P^.Offset := Offset;
    P^.FixupType := FixupType;
    P^.AddressIndex := AddressIndex;
  end;

procedure TdcUnitParser.SetCodeLinesCount(const CodeLines : Integer);
  begin
  end;

procedure TdcUnitParser.SetCodeLineOffset(const LineIndex, LineNr, LineOffset : Integer);
  begin
  end;

{ Unit                                                                         }
procedure TdcUnitParser.FinalizeParsing;
var I : Integer;
    T, E : AdcuTypeDefinition;
    R : TdcuRangeDefinition;
  begin
    For I := 0 to FUnit.FTypes.Count - 1 do
      begin
        T := AdcuTypeDefinition (FUnit.FTypes [I]);
        if T is TdcuRangeDefinition then
          begin
            R := TdcuRangeDefinition (T);
            E := FUnit.GetTypeByIndex (R.FElementTypeIndex);
            if E is TdcuLongIntDefinition then
              if (R.FLowBound = MinByte) and (R.FHighBound = MaxByte) then
                FUnit.FTypes [I] := TdcuByteDefinition.Create;
          end;
      end;
  end;



end.

