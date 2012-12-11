{                                                                              }
{                          Borland DCU Parser v0.01                            }
{                                                                              }
{          This unit is copyright © 2001 by David Butler (david@e.co.za)       }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{               Its original file name is cBorlandDCUParser.pas                }
{  The latest version is available from http://fundementals.sourceforge.net/   }
{                                                                              }
{                I invite you to use this unit, free of charge.                }
{        I invite you to distibute this unit, but it must be for free.         }
{             I also invite you to contribute to its development,              }
{             but do not distribute a modified copy of this file.              }
{       Send modifications, suggestions and bug reports to david@e.co.za       }
{                                                                              }
{ Notes:                                                                       }
{   This unit decodes Delphi 3-6 and Kylix 1-2 compiled units (DCU files).     }
{                                                                              }
{ Revision history:                                                            }
{   30/11/2001  v0.01  Moved from cBorlandDCU                                  }
{                      236 lines interface. 1203 lines implementation.         }
{                                                                              }
{ Credits:                                                                     }
{   This unit was developed with reference to the great work done by Alexei    }
{   Hmelnov <alex@monster.icc.ru> in decyphering the DCU format, particularly  }
{   his DCU32INT utility (http://monster.icc.ru/~alex/DCU/)                    }
{                                                                              }

{$INCLUDE cHeader.inc}
{.DEFINE PROFILE}
unit cDCUParser;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cReaders;



{                                                                              }
{ AdcuParser                                                                   }
{   Implements the DCU parser. To use, derive from AdcuParser and override     }
{   the abstract methods.                                                      }
{                                                                              }
type
  TdcuLogEvent = procedure (const Sender : TObject; const Msg : String) of object;
  TdcuParseDeclarationFunction = function (var Identifier : String;
      var AddressIndex : Integer) : TObject of object;
  TdcuParseDefinitionFunction = function : TObject of object;
  TdcuVersion = (dcuVerUndefined,
      dcuVerDelphi3, dcuVerDelphi4, dcuVerDelphi5, dcuVerDelphi6,
      dcuVerKylix1, dcuVerKylix2);
  TdcuSourceFileType = (dcuSourceFile, dcuResourceFile, dcuObjectFile);
  TdcuImportSection = (dcuInterfaceImport, dcuImplementationImport,
      dcuDLLImport);
  TdcuFieldListType = (ltRecord, ltClass, ltInterface, ltDispInterface);
  TdcuProcCallingConvention = (ccRegister, ccCdecl, ccPascal, ccStdCall, ccSafeCall);
  TdcuFloatType = (ftReal48, ftSingle, ftDouble, ftExtended, ftComp, ftCurrency);
  TdcuArgumentType = (atVar, atArgValue, atArgVar, atArgResult, atAbsVar);
  TdcuFieldType = (ftField, ftMethod, ftConstructor, ftDestructor, ftProperty);
  TdcuFixupType = (fxNotUsed0, fxAddress, fxJumpAddress, fxDataAddress, fxNotUsed4,
      fxStart, fxEnd);
  AdcuParser = class
  protected
    FReader      : AReaderEx;
    FReaderOwner : Boolean;

    PrevTag      : Byte;
    Tag          : Byte;
    DeclLookup   : Array[0..255] of TdcuParseDeclarationFunction;
    DefLookup    : Array[0..255] of TdcuParseDefinitionFunction;

    FOnLog       : TdcuLogEvent;
    FVersion     : TdcuVersion;
    FUnitName    : String;

    function  TokenOutOfContext(var Identifier : String; var AddressIndex : Integer) : TObject;
    procedure InitTagLookupTable; virtual;
    procedure Log(const Msg : String);

    { Version                                                                  }
    function  IsKylix : Boolean;
    function  IsDelphi : Boolean;
    function  IsDelphi4orLater : Boolean;
    function  IsDelphi5orLater : Boolean;

    { Exceptions                                                               }
    procedure RaiseError(const Msg : String);
    procedure ReadError;
    procedure FormatError(const Msg : String);
    procedure UnknownTagError(const Section : String);
    procedure UnexpectedTagError(const Expected : String);

    { Decoding                                                                 }
    function  ReadTag : Byte;
    function  ReadUIndex : Int64;
    function  ReadSIndex : Int64;
    function  ReadLongWord : LongWord;
    procedure ReadName (var Identifier : ShortString);

    { Header                                                                   }
    procedure ParseHeader(const RequiredVersion : TdcuVersion);
    procedure ParseUnitFlags;
    procedure ParseSourceFiles;

    procedure SetVersion(const Version : TdcuVersion); virtual; abstract;
    procedure SetFileTime(const FileTime : TDateTime); virtual; abstract;
    procedure SetUnitFlags(const UnitFlags : LongWord); virtual; abstract;
    procedure SetPriorityFlags(const PriorityFlags : LongWord); virtual; abstract;
    procedure SetUnitName(const UnitName : String); virtual; abstract;

    { Addresses                                                                }
    function  AddAddressItem(const Item : TObject) : Integer; virtual; abstract;
    procedure SetAddressItem(const AddressIndex : Integer; const Item : TObject); virtual; abstract;
    procedure SetAddressOffset(const AddressIndex, Offset, Size : Integer); virtual; abstract;

    { Imports                                                                  }
    procedure ParseImport(const Section : TdcuImportSection);
    procedure ParseImports;

    procedure AddSourceFile(const SourceType : TdcuSourceFileType; const Name : String; const FileTime : TDateTime); virtual; abstract;
    function  AddImportFile(const Section : TdcuImportSection; const Name : String; var FileIndex : Integer) : TObject; virtual; abstract;
    function  AddImportValue(const FileIndex : Integer; const Section : TdcuImportSection; const Name, ImportName : String) : TObject; virtual; abstract;
    function  AddImportType(const FileIndex : Integer; const Section : TdcuImportSection; const Name, ImportName : String) : TObject; virtual; abstract;

    { Data                                                                     }
    procedure ParseDataBlock;
    procedure ParseFixups;

    procedure SetDataBlock(const DataBlock : String); virtual; abstract;
    procedure SetDataBlockOffset(const Offset : Integer); virtual; abstract;
    procedure SetFixupCount(const FixupCount : Integer); virtual; abstract;
    procedure SetFixupItem(const ItemIndex : Integer;
              const FixupType : TdcuFixupType;
              const Offset, Index : Integer); virtual; abstract;

    { Tables                                                                   }
    procedure ParseCodeLinesTable;

    procedure SetCodeLinesCount(const CodeLines : Integer); virtual; abstract;
    procedure SetCodeLineOffset(const LineIndex, LineNr, LineOffset : Integer); virtual; abstract;

    { Declarations                                                             }
    procedure ParseIdentifier (var Identifier : String; var AddressIndex : Integer);
    procedure ParseIdentifierWithFlags (var Identifier : String; var AddressIndex : Integer);
    procedure ParseDeclarationWithType (var Identifier : String; var AddressIndex, TypeIndex : Integer);
    procedure ParseLocalField(const Method, InterfaceField : Boolean; var Identifier : String; var AddressIndex, TypeIndex, Offset : Integer);
    procedure ParsePropertyField (var Identifier : String; var AddressIndex, TypeIndex : Integer);
    procedure ParseVarDeclarationBase (var Identifier : String; var AddressIndex, TypeIndex, Offset : Integer);
    function  ParseCallingConvention : TdcuProcCallingConvention;
    procedure ParseProcDeclarationBase (var Identifier : String; var AddressIndex : Integer; var CallingConvention : TdcuProcCallingConvention; var Arguments, LocalDeclarations : ObjectArray; var ResultTypeIndex : Integer);

    function  ParseTag (var Identifier : String; var Declaration : TObject) : Boolean;
    procedure ParseMainDeclarations;
    function  ParseEmbeddedDeclarations : ObjectArray;
    procedure ParseArgumentDeclarations (var Arguments, LocalDeclarations : ObjectArray);
    function  ParseRecordFieldDeclarations : ObjectArray;
    function  ParseFieldListDeclarations(const ListType : TdcuFieldListType) : ObjectArray;

    procedure AddDeclaration(const Identifier : String; const Declaration : TObject); virtual; abstract;
    function  CreateArgumentDeclaration(const ArgType : TdcuArgumentType; const Identifier : String; const TypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateFieldDeclaration(const ListType : TdcuFieldListType; const FieldType : TdcuFieldType; const Identifier : String; const TypeIndex, Offset : Integer) : TObject; virtual; abstract;

    function  ParseTypeDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseDistinctTypeDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseConstDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseThreadVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseInitializedVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseAbsoluteVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseProcDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseSysProcDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseEmbeddedProcDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseLabelDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
    function  ParseSetDefaultDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;

    function  CreateTypeDeclaration(const Identifier : String; const DefinitionIndex : Integer) : TObject; virtual; abstract;
    function  CreateDistinctTypeDeclaration(const Identifier : String; const DefinitionIndex : Integer) : TObject; virtual; abstract;
    function  CreateConstDeclaration(const Identifier : String; const TypeIndex : Integer; const Value : Int64) : TObject; overload; virtual; abstract;
    function  CreateConstDeclaration(const Identifier : String; const TypeIndex : Integer; const Value : String) : TObject; overload; virtual; abstract;
    function  CreateVarDeclaration(const Identifier : String; const TypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateThreadVarDeclaration(const Identifier : String; const TypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateInitializedVarDeclaration(const Identifier : String; const TypeIndex : Integer; const DataOffset : Integer) : TObject; virtual; abstract;
    function  CreateAbsoluteVarDeclaration(const Identifier : String; const TypeIndex : Integer; const Offset : Integer) : TObject; virtual; abstract;
    function  CreateProcDeclaration(const Identifier : String; const CallingConvention : TdcuProcCallingConvention; const Arguments, LocalDeclarations : ObjectArray; const ResultTypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateSysProcDeclaration(const Identifier : String) : TObject; virtual; abstract;
    function  CreateEmbeddedProcDeclaration(const Identifier : String; const Declarations : ObjectArray; const CallingConvention : TdcuProcCallingConvention; const Arguments : ObjectArray; const ResultTypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateLabelDeclaration(const Identifier : String; const Offset : LongWord) : TObject; virtual; abstract;
    function  CreateSetDefaultDeclaration(const ConstIndex, ArgIndex : Integer) : TObject; virtual; abstract;

    { Type Definitions                                                         }
    procedure ParseTypeBase (var RTTISize, Size : Integer);
    procedure ParseRangeTypeBase (var ElementTypeIndex : Integer; var LowBound, HighBound : Int64);
    procedure ParseArrayTypeBase;

    function  ParseFloatDefinition : TObject;
    function  ParseVariantDefinition : TObject;
    function  ParsePointerDefinition : TObject;
    function  ParseVoidDefinition : TObject;
    function  ParseArrayDefinition : TObject;
    function  ParseShortStringDefinition : TObject;
    function  ParseStringDefinition : TObject;
    function  ParseRangeDefinition : TObject;
    function  ParseCharRangeDefinition : TObject;
    function  ParseBooleanRangeDefinition : TObject;
    function  ParseWideCharRangeDefinition : TObject;
    function  ParseWideRangeDefinition : TObject;
    function  ParseFileDefinition : TObject;
    function  ParseTextDefinition : TObject;
    function  ParseEnumDefinition : TObject;
    function  ParseSetDefinition : TObject;
    function  ParseRecordDefinition : TObject;
    function  ParseClassDefinition : TObject;
    function  ParseInterfaceDefinition : TObject;
    function  ParseObjectVMTDefinition : TObject;
    function  ParseProcTypeDefinition : TObject;

    function  GetTypeCount : Integer; virtual; abstract;
    function  AddTypeDefinition(const TypeDefinition : TObject) : Integer; virtual; abstract;
    function  CreateFloatDefinition(const FloatType : TdcuFloatType) : TObject; virtual; abstract;
    function  CreateVariantDefinition(const VariantType : Byte) : TObject; virtual; abstract;
    function  CreatePointerTypeDefinition(const ReferenceTypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateVoidTypeDefinition : TObject; virtual; abstract;
    function  CreateArrayDefinition : TObject; virtual; abstract;
    function  CreateShortStringDefinition : TObject; virtual; abstract;
    function  CreateStringDefinition : TObject; virtual; abstract;
    function  CreateRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; virtual; abstract;
    function  CreateCharRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; virtual; abstract;
    function  CreateBooleanRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; virtual; abstract;
    function  CreateWideCharRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; virtual; abstract;
    function  CreateWideRangeDefinition(const TypeIndex, ElementTypeIndex : Integer; const LowBound, HighBound : Int64) : TObject; virtual; abstract;
    function  CreateFileDefinition(const ElementTypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateTextDefinition : TObject; virtual; abstract;
    function  CreateEnumDefinition(const BaseTypeIndex, Lo, Hi : Integer) : TObject; virtual; abstract;
    function  CreateSetDefinition(const ElementTypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateRecordDefinition(const Size : Integer; const Fields : ObjectArray) : TObject; virtual; abstract;
    function  CreateClassDefinition(const ParentTypeIndex : Integer; const Fields : ObjectArray) : TObject; virtual; abstract;
    function  CreateInterfaceDefinition(const IsDispInterface : Boolean; const ParentTypeIndex : Integer; const GUID : TGUID; const Fields : ObjectArray) : TObject; virtual; abstract;
    function  CreateObjectVMTDefinition(const ObjectTypeIndex : Integer) : TObject; virtual; abstract;
    function  CreateProcTypeDefinition(const ResultTypeIndex : Integer; const CallingConvention : TdcuProcCallingConvention; const Arguments, LocalDeclarations : ObjectArray) : TObject; virtual; abstract;

    { Unit                                                                     }
    procedure ParseUnit(const RequiredVersion : TdcuVersion = dcuVerUndefined);

    procedure FinalizeParsing; virtual;

  public
    { AdcuParser interface                                                     }
    constructor Create(const Reader : AReaderEx; const ReaderOwner : Boolean = True);

    property  OnLog : TdcuLogEvent read FOnLog write FOnLog;
  end;
  EdcuParser = class (Exception)
    constructor Create(const UnitName : String; const UnitVersion : TdcuVersion; const Msg : String);
  end;



{ Version                                                                      }
const
  KylixVersions           = [dcuVerKylix1, dcuVerKylix2];
  DelphiVersions          = [dcuVerDelphi3, dcuVerDelphi4, dcuVerDelphi5, dcuVerDelphi6];
  Delphi4AndLaterVersions = [dcuVerDelphi4, dcuVerDelphi5, dcuVerDelphi6, dcuVerKylix1, dcuVerKylix2];
  Delphi5AndLaterVersions = [dcuVerDelphi5, dcuVerDelphi6, dcuVerKylix1, dcuVerKylix2];

function dcuVersionAsString(const Version : TdcuVersion) : String;



implementation

uses
  { Fundamentals }
  {$IFDEF PROFILE}
  cDateTime,
  {$ENDIF}
  cStrings;



{ Tags                                                                         }
const
  tagVar                  = $20;
  tagThreadVar            = $31;
  tagConst                = $25;
  tagDistinctType         = $26;
  tagInitializedVar       = $27;
  tagProc                 = $28;
  tagSysProc              = $29;
  tagType                 = $2A;
  tagLabel                = $2B;

  tagArgValue             = $21;
  tagArgVar               = $22;
  tagArgResult            = $23;
  tagAbsVar               = $24;

  tagField                = $2C;
  tagMethod               = $2D;
  tagConstructor          = $2E;
  tagDestructor           = $2F;
  tagProperty             = $30;

  tagVoid                 = $40;
  tagBoolRangeDef         = $41;
  tagChRangeDef           = $42;
  tagEnumDef              = $43;
  tagRangeDef             = $44;
  tagPtrDef               = $45;
  tagClassDef             = $46;
  tagObjVMTDef            = $47;
  tagProcTypeDef          = $48;
  tagFloatDef             = $49;
  tagSetDef               = $4A;
  tagShortStringDef       = $4B;
  tagStringDef            = $52;
  tagVariantDef           = $53;
  tagWideStringDef        = $55;
  tagArrayDef             = $4C;
  tagRecDef               = $4D;
  tagFileDef              = $4F;
  tagTextDef              = $50;
  tagWideCharRangeDef     = $51;
  tagInterfaceDef         = $54;
  tagWideRangeDef         = $56;

  tagStop                 = $63;
  tagInterfaceImport      = $64;
  tagImplementationImport = $65;
  tagDLLImport            = $68;
  tagImportVal            = $67;
  tagImportType           = $66;
  tagImportTypeDef        = $6E;

  tagEmbeddedProcStart    = $6A;
  tagEmbeddedProcEnd      = $6B;
  tagDataBlock            = $6C;
  tagFixup                = $6D;

  tagSourceFile           = $70;
  tagObjectFile           = $71;
  tagResourceFile         = $72;

  tagCdecl                = $81;
  tagPascal               = $82;
  tagStdCall              = $83;
  tagSafeCall             = $84;

  tagCodeLinesTable       = $90;
  tagLineNumsTable        = $91;
  tagStrucScopeTable      = $92;
  tagSymbolRefTable       = $93;
  tagUnitFlags            = $96;

  tagSetDefault           = $9A;



{ Version                                                                      }
function dcuVersionAsString(const Version : TdcuVersion) : String;
const VersionLookup : Array[TdcuVersion] of String = ('',
          'Delphi 3', 'Delphi 4', 'Delphi 5', 'Delphi 6',
          'Kylix 1', 'Kylix 2');
  begin
    Result := VersionLookup[Version];
  end;



{ FileTime                                                                     }
function KylixFileDateToDateTime(const FileDate : Integer) : TDateTime;
  begin
    Result := EncodeDate (1970, 1, 1) + FileDate / (24 * 60 * 60);
  end;

function dcuFileDateToDateTime(const FileDate : Integer; const IsKylix : Boolean) : TDateTime;
  begin
    if IsKylix then
      Result := KylixFileDateToDateTime (FileDate) else
      Result := FileDateToDateTime (FileDate);
  end;



{                                                                              }
{ EdcuParser                                                                   }
{                                                                              }
Constructor EdcuParser.Create(const UnitName : String; const UnitVersion : TdcuVersion; const Msg : String);
var S : String;
  begin
    if UnitName <> '' then
      begin
        S := UnitName;
        if UnitVersion <> dcuVerUndefined then
          S := S + ' (' + dcuVersionAsString (UnitVersion) + ')';
        S := S + ': ' + Msg;
      end else
      S := Msg;
    S := 'DCU Error: ' + S;
    inherited Create (S);
  end;



{                                                                              }
{ AdcuParser                                                                   }
{                                                                              }

{ AdcuParser                                                                   }
Constructor AdcuParser.Create(const Reader : AReaderEx; const ReaderOwner : Boolean);
  begin
    inherited Create;
    FReader := Reader;
    FReaderOwner := ReaderOwner;
    InitTagLookupTable;
  end;

procedure AdcuParser.Log(const Msg : String);
  begin
    if Assigned (FOnLog) then
      FOnLog (self, Msg);
  end;

{ Exceptions                                                                   }
procedure AdcuParser.RaiseError(const Msg : String);
  begin
    raise EdcuParser.Create (FUnitName, FVersion, Msg);
  end;

procedure AdcuParser.FormatError(const Msg : String);
  begin
    RaiseError ('Format error: ' + Msg + ': Previous tag ' + IntToHex (PrevTag, 2));
  end;

procedure AdcuParser.UnknownTagError(const Section : String);
  begin
    FormatError ('Unknown tag ' + IntToHex (Tag, 2) + ': Section ' + Section);
  end;

procedure AdcuParser.UnexpectedTagError(const Expected : String);
  begin
    FormatError ('Unexpected tag: ' + Expected + ' expected: Found ' + IntToHex (Tag, 2));
  end;

procedure AdcuParser.ReadError;
  begin
    RaiseError ('Read error');
  end;

{ Version                                                                      }
function AdcuParser.IsKylix : Boolean;
  begin
    Result := FVersion in KylixVersions;
  end;

function AdcuParser.IsDelphi : Boolean;
  begin
    Result := FVersion in KylixVersions;
  end;

function AdcuParser.IsDelphi4orLater : Boolean;
  begin
    Result := FVersion in Delphi4AndLaterVersions;
  end;

function AdcuParser.IsDelphi5orLater : Boolean;
  begin
    Result := FVersion in Delphi5AndLaterVersions;
  end;

{ Decoding                                                                     }
function AdcuParser.ReadTag : Byte;
  begin
    PrevTag := Tag;
    Result := FReader.ReadByte;
    Tag := Result;
    {$IFDEF DEBUG}
    Log (IntToHex (Tag, 2));
    {$ENDIF}
  end;

function AdcuParser.ReadUIndex : Int64;
var B  : Array[0..4] of Byte;
    W  : Word absolute B;
    L  : LongWord absolute B;
    R4 : packed record
           B : Byte;
           L : LongWord;
         end absolute B;
  begin
    Int64Rec (Result).Hi := 0;
    B[0] := FReader.ReadByte;
    if B[0] and 1 = 0 then
      Int64Rec (Result).Lo := B[0] shr 1 else
      begin
        B[1] := FReader.ReadByte;
        if B[0] and 2 = 0 then
          Int64Rec (Result).Lo := W shr 2 else
          begin
            B[2] := FReader.ReadByte;
            B[3] := 0;
            if B[0] and 4 = 0 then
              Int64Rec (Result).Lo := L shr 3 else
              begin
                B[3] := FReader.ReadByte;
                if B[0] and 8 = 0 then
                  Int64Rec (Result).Lo := L shr 4 else
                  begin
                    B[4] := FReader.ReadByte;
                    Int64Rec (Result).Lo := R4.L;
                    if IsDelphi4OrLater and (B[0] and $F0 <> 0) then
                      Int64Rec (Result).Hi := ReadLongWord;
                  end;
              end;
          end;
      end;
  end;

function AdcuParser.ReadSIndex : Int64;
var B  : packed array[0..4] of Byte;
    SB : ShortInt absolute B;
    W  : SmallInt absolute B;
    L  : LongInt absolute B;
    R4 : packed record
      B : Byte;
      L : LongInt;
    end absolute B;
    RL : packed record
      W : Word;
      I : SmallInt;
    end absolute B;
  begin
    B[0] := FReader.ReadByte;
    if B[0] and 1 = 0 then
      Result := Int64 (ShortInt (SB shr 1)) else
      begin
        B[1] := FReader.ReadByte;
        if B[0] and 2 = 0 then
          Result := Int64 (SmallInt (W shr 2)) else
          begin
            B[2] := FReader.ReadByte;
            if B[0] and 4 = 0 then
              begin
                RL.I := ShortInt (B[2]);
                L := L shr 3;
                RL.I := ShortInt (B[2]);
                Result := L;
              end else
              begin
                B[3] := FReader.ReadByte;
                if B[0] and 8 = 0 then
                  Result := L shr 4 else
                  begin
                    B[4] := FReader.ReadByte;
                    Result := R4.L;
                    if IsDelphi4OrLater and (B[0] and $F0 <> 0) then
                      Int64Rec (Result).Hi := ReadLongWord;
                  end;
              end;
          end;
      end;
  end;

function AdcuParser.ReadLongWord : LongWord;
  begin
    Result := FReader.ReadLongWord;
  end;

procedure AdcuParser.ReadName (var Identifier : ShortString);
var L : Byte;
  begin
    L := FReader.ReadByte;
    Identifier[0] := Char (L);
    if L > 0 then
      FReader.Read (Identifier[1], L);
  end;

{ Header                                                                       }
const
  IDKylix2  = $0E1011DD;
  IDKylix1  = $F21F148C;
  IDDelphi6 = $0E0000DD;
  IDDelphi5 = $F21F148B;
  IDDelphi4 = $4768A6D8;
  IDDelphi3 = $44518641;
  IDDelphi2 = $50505348;

type
  TdcuHeader = packed record
    FileTime  : LongInt;
    FileStamp : LongWord;
    B         : Byte;
  end;

procedure AdcuParser.ParseHeader(const RequiredVersion : TdcuVersion);
var FileID   : LongWord;
    FileSize : LongWord;
    Header   : TdcuHeader;
  begin
    // File ID (4 bytes)
    if FReader.Read (FileID, Sizeof (FileID)) <> Sizeof (FileID) then
      ReadError;
    if FileID = IDKylix2 then
      FVersion := dcuVerKylix2 else
    if FileID = IDKylix1 then
      FVersion := dcuVerKylix1 else
    if FileID = IDDelphi6 then
      FVersion := dcuVerDelphi6 else
    if FileID = IDDelphi5 then
      FVersion := dcuVerDelphi5 else
    if FileID = IDDelphi4 then
      FVersion := dcuVerDelphi4 else
    if FileID = IDDelphi3 then
      FVersion := dcuVerDelphi3 else
    if FileID = IDDelphi2 then
      RaiseError ('Delphi 2 DCUs not supported') else
      RaiseError ('Not a recognised DCU format: FileID ' + IntToHex (FileID, 8));
    if (RequiredVersion <> dcuVerUndefined) and (FVersion <> RequiredVersion) then
      RaiseError (dcuVersionAsString (RequiredVersion) + ' DCU required: ' + dcuVersionAsString (FVersion) + ' DCU file');
    SetVersion (FVersion);

    // File size (4 bytes)
    if FReader.Read (FileSize, Sizeof (FileSize)) <> Sizeof (FileSize) then
      ReadError;
    if FileSize <> FReader.Size then
      RaiseError ('DCU integrity fail: Stream size mismatch: Expected size ' + IntToStr (FileSize));

    // Rest of header
    if FReader.Read (Header, Sizeof (Header)) <> Sizeof (Header) then
      ReadError;
    if Header.FileTime <> -1 then
      SetFileTime (dcuFileDateToDateTime (Header.FileTime, IsKylix));

    if IsKylix then
      FReader.Skip (4);
  end;

procedure AdcuParser.ParseUnitFlags;
  begin
    if Tag <> tagUnitFlags then
      exit;
    SetUnitFlags (ReadUIndex);
    if IsDelphi4OrLater then
      SetPriorityFlags (ReadUIndex);
    ReadTag;
  end;

procedure AdcuParser.ParseSourceFiles;
var FileName     : ShortString;
    FileTime     : LongWord;
    FileDateTime : TDateTime;
    SourceType   : TdcuSourceFileType;
  begin
    While Tag in [tagSourceFile, tagObjectFile, tagResourceFile] do
      begin
        Case Tag of
          tagObjectFile   : SourceType := dcuObjectFile;
          tagResourceFile : SourceType := dcuResourceFile;
          else SourceType := dcuSourceFile;
        end;
        ReadName (FileName);
        FileTime := ReadLongWord;
        FReader.ReadByte;
        if (FUnitName = '') and (Tag = tagSourceFile) then
          begin
            FUnitName := StrBeforeCharRev (ExtractFileName (FileName), ['.'], True);
            SetUnitName (FUnitName);
          end;
        FileDateTime := dcuFileDateToDateTime (FileTime, IsKylix);
        AddSourceFile (SourceType, FileName, FileDateTime);
        ReadTag;
      end;
  end;

procedure AdcuParser.ParseImport(const Section : TdcuImportSection);
var Name, ImportName : ShortString;
    FileIndex : Integer;
    T : TObject;
  begin
    ReadName (Name);
    ReadLongWord;
    AddAddressItem (AddImportFile (Section, Name, FileIndex));
    ReadTag;
    While Tag <> tagStop do
      begin
        Case Tag of
          tagImportVal :
            begin
              ReadName (ImportName);
              ReadLongWord;
              AddAddressItem (AddImportValue (FileIndex, Section, Name, ImportName));
            end;
          tagImportType, tagImportTypeDef :
            begin
              ReadName (ImportName);
              if Tag = tagImportTypeDef then
                ReadUIndex;
              ReadLongWord;
              T := AddImportType (FileIndex, Section, Name, ImportName);
              AddAddressItem (T);
              AddTypeDefinition (T);
            end;
          else
            Case Section of
              dcuInterfaceImport      : UnknownTagError ('Interface import');
              dcuImplementationImport : UnknownTagError ('Implementation import');
              dcuDLLImport            : UnknownTagError ('DLL import');
            end;
        end;
        ReadTag;
      end;
    ReadTag;
  end;

procedure AdcuParser.ParseImports;
var Fin : Boolean;
  begin
    Fin := False;
    Repeat
      Case Tag of
        tagInterfaceImport      : ParseImport (dcuInterfaceImport);
        tagImplementationImport : ParseImport (dcuImplementationImport);
        tagDLLImport            : ParseImport (dcuDLLImport);
        else Fin := True;
      end;
    Until Fin;
  end;

{ Code                                                                         }
procedure AdcuParser.ParseDataBlock;
var DataBlockSize : Integer;
    DataBlock : String;
  begin
    DataBlockSize := ReadUIndex;
    DataBlock := FReader.ReadStr (DataBlockSize);
    if Length (DataBlock) <> DataBlockSize then
      RaiseError ('Invalid data block size');
    SetDataBlock (DataBlock);
    ReadTag;
  end;

procedure AdcuParser.ParseFixups;
const
  FixOfsMask = $FFFFFF;
var FixupCount, DataBlockOffset,
    CurOfs, Ofs, I, Index, PrevIndex, PrevOfs : Integer;
    FixupType : TdcuFixupType;
  begin
    FixupCount := ReadUIndex;
    SetFixupCount (FixupCount);
    CurOfs := 0;
    DataBlockOffset := 0;
    PrevIndex := 0;
    PrevOfs := -1;
    For I := 0 to FixupCount - 1 do
      begin
        Ofs := ReadUIndex;
        Inc (CurOfs, Ofs);
        FixupType := TdcuFixupType (FReader.ReadByte);
        Index := ReadUIndex;
        if FixupType in [fxStart, fxend] then
          begin
            DataBlockOffset := CurOfs;
            if PrevIndex > 0 then
              SetAddressOffset (PrevIndex, PrevOfs, CurOfs - PrevOfs);
            PrevIndex := Index;
            PrevOfs := CurOfs;
          end;
        SetFixupItem (I, FixupType, CurOfs, Index);
      end;
    SetDataBlockOffset (DataBlockOffset);

    ReadTag;
  end;

procedure AdcuParser.ParseCodeLinesTable;
var I, Count, LineNr, LineOffset : Integer;
  begin
    Count := ReadUIndex;
    SetCodeLinesCount (Count);
    For I := 0 to Count - 1 do
      begin
        LineNr := ReadSIndex;
        LineOffset := ReadUIndex;
        SetCodeLineOffset (I, LineNr, LineOffset);
      end;
  end;

{ Declarations                                                                 }
procedure AdcuParser.ParseIdentifier (var Identifier : String; var AddressIndex : Integer);
var I : ShortString;
  begin
    ReadName (I);
    Identifier := I;
    AddressIndex := AddAddressItem (nil);
    {$IFDEF DEBUG}
    Log (Identifier);
    {$ENDIF}
  end;

procedure AdcuParser.ParseIdentifierWithFlags (var Identifier : String; var AddressIndex : Integer);
var Flags : LongWord;
  begin
    ParseIdentifier (Identifier, AddressIndex);
    Flags := ReadUIndex;
    if Flags and $40 <> 0 then
      ReadLongWord;
  end;

procedure AdcuParser.ParseDeclarationWithType (var Identifier : String; var AddressIndex, TypeIndex : Integer);
  begin
    ParseIdentifierWithFlags (Identifier, AddressIndex);
    TypeIndex := ReadUIndex;
  end;

procedure AdcuParser.ParseLocalField(const Method, InterfaceField : Boolean; var Identifier : String; var AddressIndex, TypeIndex, Offset : Integer);
  begin
    ParseIdentifier (Identifier, AddressIndex);
    ReadUIndex; { LocalFlags }
    TypeIndex := ReadUIndex;
    if InterfaceField then
      ReadUIndex;
    if Method then
      begin
        Offset := ReadUIndex;
        if Identifier = '' then
          ReadUIndex; { ImportIndex }
      end else
      Offset := ReadSIndex;
  end;

procedure AdcuParser.ParseVarDeclarationBase (var Identifier : String; var AddressIndex, TypeIndex, Offset : Integer);
  begin
    ParseDeclarationWithType (Identifier, AddressIndex, TypeIndex);
    Offset := ReadUIndex;
  end;

procedure AdcuParser.ParsePropertyField (var Identifier : String; var AddressIndex, TypeIndex : Integer);
  begin
    ParseIdentifier (Identifier, AddressIndex);
    ReadSIndex; { LocalFlags }
    TypeIndex := ReadUIndex;
    ReadSIndex; { Ndx }
    ReadSIndex; { hIndex }
    ReadUIndex; { hRead }
    ReadUIndex; { hWrite }
    ReadUIndex; { hStored }
    ReadSIndex; { hDeft }
  end;

function AdcuParser.ParseCallingConvention : TdcuProcCallingConvention;
  begin
    Case Tag of
      tagCdecl    : Result := ccCdecl;
      tagPascal   : Result := ccPascal;
      tagStdCall  : Result := ccStdCall;
      tagSafeCall : Result := ccSafeCall;
    else
      begin
        Result := ccRegister;
        exit;
      end;
    end;
    ReadTag;
  end;

procedure AdcuParser.ParseProcDeclarationBase (var Identifier : String; var AddressIndex : Integer; var CallingConvention : TdcuProcCallingConvention; var Arguments, LocalDeclarations : ObjectArray; var ResultTypeIndex : Integer);
  begin
    ParseIdentifierWithFlags (Identifier, AddressIndex);
    ReadUIndex;
    ReadUIndex; { Size }
    if (Identifier = '') or (Identifier = '.') or (Identifier = '..') or
       ((Identifier[1] = '.') and (Identifier[Length (Identifier)] = '.')) then
      begin
        CallingConvention := ccRegister;
        ResultTypeIndex := 0;
        Arguments := nil;
      end else
      begin
        ReadSIndex; { VProc }
        ResultTypeIndex := ReadUIndex;
        ReadTag;
        CallingConvention := ParseCallingConvention;
        ParseArgumentDeclarations (Arguments, LocalDeclarations);
        if Tag <> tagStop then
          UnexpectedTagError ('ProcDeclaration Stop');
      end;
  end;

{ ParseTag                                                                     }
{$WARNINGS OFF}
function AdcuParser.TokenOutOfContext (var Identifier : String; var AddressIndex : Integer) : TObject;
  begin
    FormatError ('Tag ' + IntToHex (Tag, 2) + ' out of context');
  end;
{$WARNINGS ON}

procedure AdcuParser.InitTagLookupTable;
  begin
    DeclLookup[tagConst] := ParseConstDeclaration;
    DeclLookup[tagType] := ParseTypeDeclaration;
    DeclLookup[tagDistinctType] := ParseDistinctTypeDeclaration;
    DeclLookup[tagInitializedVar] := ParseInitializedVarDeclaration;
    DeclLookup[tagProc] := ParseProcDeclaration;
    DeclLookup[tagSysProc] := ParseSysProcDeclaration;
    DeclLookup[tagVar] := ParseVarDeclaration;
    DeclLookup[tagAbsVar] := ParseAbsoluteVarDeclaration;
    DeclLookup[tagThreadVar] := ParseThreadVarDeclaration;
    DeclLookup[tagEmbeddedProcStart] := ParseEmbeddedProcDeclaration;
    DeclLookup[tagSetDefault] := ParseSetDefaultDeclaration;
    DeclLookup[tagLabel] := ParseLabelDeclaration;

    DeclLookup[tagSourceFile] := TokenOutOfContext;
    DeclLookup[tagObjectFile] := TokenOutOfContext;
    DeclLookup[tagResourceFile] := TokenOutOfContext;
    DeclLookup[tagUnitFlags] := TokenOutOfContext;
    DeclLookup[tagInterfaceImport] := TokenOutOfContext;
    DeclLookup[tagImplementationImport] := TokenOutOfContext;
    DeclLookup[tagDLLImport] := TokenOutOfContext;
    DeclLookup[tagImportType] := TokenOutOfContext;
    DeclLookup[tagImportTypeDef] := TokenOutOfContext;
    DeclLookup[tagImportVal] := TokenOutOfContext;
    DeclLookup[tagArgValue] := TokenOutOfContext;
    DeclLookup[tagArgVar] := TokenOutOfContext;
    DeclLookup[tagArgResult] := TokenOutOfContext;
    DeclLookup[tagField] := TokenOutOfContext;
    DeclLookup[tagProperty] := TokenOutOfContext;
    DeclLookup[tagMethod] := TokenOutOfContext;
    DeclLookup[tagConstructor] := TokenOutOfContext;
    DeclLookup[tagDestructor] := TokenOutOfContext;

    DefLookup[tagRecDef] := ParseRecordDefinition;
    DefLookup[tagFileDef] := ParseFileDefinition;
    DefLookup[tagTextDef] := ParseTextDefinition;
    DefLookup[tagClassDef] := ParseClassDefinition;
    DefLookup[tagArrayDef] := ParseArrayDefinition;
    DefLookup[tagRangeDef] := ParseRangeDefinition;
    DefLookup[tagChRangeDef] := ParseCharRangeDefinition;
    DefLookup[tagBoolRangeDef] := ParseBooleanRangeDefinition;
    DefLookup[tagWideCharRangeDef] := ParseWideCharRangeDefinition;
    DefLookup[tagWideRangeDef] := ParseWideRangeDefinition;
    DefLookup[tagEnumDef] := ParseEnumDefinition;
    DefLookup[tagSetDef] := ParseSetDefinition;
    DefLookup[tagShortStringDef] := ParseShortStringDefinition;
    DefLookup[tagStringDef] := ParseStringDefinition;
    DefLookup[tagVariantDef] := ParseVariantDefinition;
    DefLookup[tagWideStringDef] := ParseStringDefinition;
    DefLookup[tagFloatDef] := ParseFloatDefinition;
    DefLookup[tagPtrDef] := ParsePointerDefinition;
    DefLookup[tagObjVMTDef] := ParseObjectVMTDefinition;
    DefLookup[tagVoid] := ParseVoidDefinition;
    DefLookup[tagProcTypeDef] := ParseProcTypeDefinition;
    DefLookup[tagInterfaceDef] := ParseInterfaceDefinition;
  end;

function AdcuParser.ParseTag (var Identifier : String; var Declaration : TObject) : Boolean;
var ParseDeclFunc : TdcuParseDeclarationFunction;
    ParseDefFunc  : TdcuParseDefinitionFunction;
    AddressIndex  : Integer;
  begin
    ParseDeclFunc := DeclLookup[Tag];
    Result := Assigned (@ParseDeclFunc);
    if Result then
      begin
        Declaration := ParseDeclFunc (Identifier, AddressIndex);
        if AddressIndex >= 0 then
          SetAddressItem (AddressIndex, Declaration);
      end else
      begin
        ParseDefFunc := DefLookup[Tag];
        Result := Assigned (@ParseDefFunc);
        if Result then
          AddTypeDefinition (ParseDefFunc);
        Identifier := '';
        Declaration := nil;
      end;
    if Result then
      ReadTag;
  end;

{ Declaration Lists                                                            }
procedure AdcuParser.ParseMainDeclarations;
const MainTerminatorTags = [tagCodeLinesTable, tagLineNumsTable,
          tagStrucScopeTable, tagSymbolRefTable];
var D : TObject;
    I : String;
  begin
    try
      While ParseTag (I, D) do
        if Assigned (D) then
          AddDeclaration (I, D);

      While not (Tag in MainTerminatorTags) do
        Case Tag of
          tagDataBlock : ParseDataBlock;
          tagFixup     : ParseFixups;
          else UnknownTagError ('Main');
        end;
    except
      on EdcuParser do raise;
      on E : Exception do
        RaiseError (E.Message + ': Previous tag ' + IntToHex (PrevTag, 2) + ': Tag ' + IntToHex (Tag, 2));
    end;
  end;

function AdcuParser.ParseEmbeddedDeclarations : ObjectArray;
var D : TObject;
    I : String;
  begin
    Result := nil;
    While Tag <> tagEmbeddedProcend do
      if ParseTag (I, D) then
        begin
          if Assigned (D) then
            Append (Result, D);
        end else
        UnknownTagError ('Embedded');
    ReadTag;
  end;

procedure AdcuParser.ParseArgumentDeclarations (var Arguments, LocalDeclarations : ObjectArray);
var Identifier : String;
    AddrIndex  : Integer;
    TypeIndex  : Integer;
    Offset     : Integer;
    ArgType    : TdcuArgumentType;
    R, IsParam : Boolean;
    D          : TObject;
    I          : String;
  begin
    R := True;
    ArgType := atVar;
    Repeat
      Case Tag of
        tagVar       : ArgType := atVar;
        tagArgValue  : ArgType := atArgValue;
        tagArgVar    : ArgType := atArgVar;
        tagArgResult : ArgType := atArgResult;
        tagAbsVar    : ArgType := atAbsVar;
      else
        R := False;
      end;
      IsParam := Tag in [tagArgValue, tagArgVar];
      if R then
        begin
          ParseLocalField (False, False, Identifier, AddrIndex, TypeIndex, Offset);
          D := CreateArgumentDeclaration (ArgType, Identifier, TypeIndex);
          SetAddressItem (AddrIndex, D);
          ReadTag;
        end else
        R := ParseTag (I, D);
      if R and Assigned (D) then
        if IsParam then
          Append (Arguments, D) else
          Append (LocalDeclarations, D);
    Until not R;
  end;

function AdcuParser.ParseRecordFieldDeclarations : ObjectArray;
var Identifier : String;
    AddrIndex  : Integer;
    TypeIndex  : Integer;
    Offset     : Integer;
    D          : TObject;
  begin
    Result := nil;
    While Tag <> tagStop do
      if Tag = tagField then
        begin
          ParseLocalField (False, False, Identifier, AddrIndex, TypeIndex, Offset);
          D := CreateFieldDeclaration (ltRecord, ftField, Identifier, TypeIndex, Offset);
          if Assigned (D) then
            begin
              SetAddressItem (AddrIndex, D);
              Append (Result, D);
            end;
          ReadTag;
        end else
        UnexpectedTagError ('Field');
  end;

function AdcuParser.ParseFieldListDeclarations(const ListType : TdcuFieldListType) : ObjectArray;
var Identifier      : String;
    AddrIndex       : Integer;
    TypeIndex       : Integer;
    Offset          : Integer;
    InterfaceFields : Boolean;
    FieldType       : TdcuFieldType;
    D               : TObject;
  begin
    Result := nil;
    FieldType := ftField;
    InterfaceFields := ListType in [ltInterface, ltDispInterface];
    While Tag <> tagStop do
      begin
        Case Tag of
          tagField       :
            begin
              FieldType := ftField;
              ParseLocalField (False, InterfaceFields, Identifier, AddrIndex, TypeIndex, Offset);
            end;
          tagProperty    :
            begin
              FieldType := ftProperty;
              ParsePropertyField (Identifier, AddrIndex, TypeIndex);
            end;
          tagMethod      : FieldType := ftMethod;
          tagConstructor : FieldType := ftConstructor;
          tagDestructor  : FieldType := ftDestructor;
        else
          UnexpectedTagError ('Field');
        end;
        if FieldType in [ftMethod, ftConstructor, ftDestructor] then
          ParseLocalField (True, InterfaceFields, Identifier, AddrIndex, TypeIndex, Offset);
        D := CreateFieldDeclaration (ListType, FieldType, Identifier, TypeIndex, Offset);
        if Assigned (D) then
          begin
            SetAddressItem (AddrIndex, D);
            Append (Result, D);
          end;
        ReadTag;
      end;
  end;

{ Declarations                                                                 }
function AdcuParser.ParseTypeDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var DefinitionIndex : Integer;
  begin
    ParseDeclarationWithType (Identifier, AddressIndex, DefinitionIndex);
    Result := CreateTypeDeclaration (Identifier, DefinitionIndex);
  end;

function AdcuParser.ParseDistinctTypeDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var TypeIndex, Ofs : Integer;
  begin
    ParseVarDeclarationBase (Identifier, AddressIndex, TypeIndex, Ofs);
    Result := CreateDistinctTypeDeclaration (Identifier, TypeIndex);
  end;

function AdcuParser.ParseConstDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var TypeIndex  : Integer;
    ValueSize  : Integer;
    Value      : Int64;
  begin
    ParseDeclarationWithType (Identifier, AddressIndex, TypeIndex);
    if IsDelphi5OrLater then
      ReadUIndex;
    ValueSize := ReadUIndex;
    if ValueSize = 0 then
      begin
        Value := ReadSIndex;
        Result := CreateConstDeclaration (Identifier, TypeIndex, Value);
       end else
       Result := CreateConstDeclaration (Identifier, TypeIndex, FReader.ReadStr (ValueSize));
  end;

function AdcuParser.ParseVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var TypeIndex, Ofs : Integer;
  begin
    ParseVarDeclarationBase (Identifier, AddressIndex, TypeIndex, Ofs);
    Result := CreateVarDeclaration (Identifier, TypeIndex);
  end;

function AdcuParser.ParseThreadVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var TypeIndex, Ofs : Integer;
  begin
    ParseVarDeclarationBase (Identifier, AddressIndex, TypeIndex, Ofs);
    Result := CreateThreadVarDeclaration (Identifier, TypeIndex);
  end;

function AdcuParser.ParseInitializedVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var TypeIndex, DataOffset : Integer;
  begin
    ParseVarDeclarationBase (Identifier, AddressIndex, TypeIndex, DataOffset);
    Result := CreateInitializedVarDeclaration (Identifier, TypeIndex, DataOffset);
  end;

function AdcuParser.ParseAbsoluteVarDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var TypeIndex, Ofs : Integer;
  begin
    ParseVarDeclarationBase (Identifier, AddressIndex, TypeIndex, Ofs);
    Result := CreateAbsoluteVarDeclaration (Identifier, TypeIndex, Ofs);
  end;

function AdcuParser.ParseProcDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var ResultTypeIndex : Integer;
    CallingConvention : TdcuProcCallingConvention;
    Arguments, LocalDeclarations : ObjectArray;
  begin
    ParseProcDeclarationBase (Identifier, AddressIndex, CallingConvention, Arguments, LocalDeclarations, ResultTypeIndex);
    Result := CreateProcDeclaration (Identifier, CallingConvention, Arguments, LocalDeclarations, ResultTypeIndex);
  end;

function AdcuParser.ParseSysProcDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
  begin
    ParseIdentifier (Identifier, AddressIndex);
    ReadUIndex;
    ReadSIndex;
    Result := CreateSysProcDeclaration (Identifier);
  end;

function AdcuParser.ParseEmbeddedProcDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var ResultTypeIndex : Integer;
    CallingConvention : TdcuProcCallingConvention;
    Declarations, Arguments, LocalDeclarations : ObjectArray;
  begin
    ReadTag;
    Declarations := ParseEmbeddedDeclarations;
    if Tag <> tagProc then
      UnexpectedTagError ('Proc');
    ParseProcDeclarationBase (Identifier, AddressIndex, CallingConvention, Arguments, LocalDeclarations, ResultTypeIndex);
    Result := CreateEmbeddedProcDeclaration (Identifier, Declarations, CallingConvention,
        Arguments, ResultTypeIndex);
  end;

function AdcuParser.ParseLabelDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var Offset : LongWord;
  begin
    ParseIdentifier (Identifier, AddressIndex);
    Offset := ReadUIndex;
    Result := CreateLabelDeclaration (Identifier, Offset);
  end;

function AdcuParser.ParseSetDefaultDeclaration (var Identifier : String; var AddressIndex : Integer) : TObject;
var ConstIndex, ArgIndex : Integer;
  begin
    ConstIndex := ReadUIndex;
    ArgIndex := ReadUIndex;
    Result := CreateSetDefaultDeclaration (ConstIndex, ArgIndex);
    Identifier := '';
    AddressIndex := -1;
  end;

{ Type Definitions                                                             }
procedure AdcuParser.ParseTypeBase (var RTTISize, Size : Integer);
  begin
    RTTISize := ReadUIndex;
    Size := ReadSIndex;
    ReadUIndex;
  end;

procedure AdcuParser.ParseRangeTypeBase (var ElementTypeIndex : Integer; var LowBound, HighBound : Int64);
var RTTISize, Size : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    ElementTypeIndex := ReadUIndex;
    LowBound := ReadSIndex;
    HighBound := ReadSIndex;
    FReader.ReadByte;
  end;

procedure AdcuParser.ParseArrayTypeBase;
var RTTISize, Size : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    FReader.ReadByte;
    ReadUIndex; { hDTNdx }
    ReadUIndex; { hDTEl }
  end;

function AdcuParser.ParseFloatDefinition : TObject;
var RTTISize, Size : Integer;
    FloatType : TdcuFloatType;
  begin
    ParseTypeBase (RTTISize, Size);
    FloatType := TdcuFloatType (FReader.ReadByte);
    Result := CreateFloatDefinition (FloatType);
  end;

function AdcuParser.ParseVariantDefinition : TObject;
var RTTISize, Size : Integer;
    VariantType : Byte;
  begin
    ParseTypeBase (RTTISize, Size);
    VariantType := FReader.ReadByte;
    Result := CreateVariantDefinition (VariantType);
  end;

function AdcuParser.ParsePointerDefinition : TObject;
var RTTISize, Size, ReferenceTypeIndex : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    ReferenceTypeIndex := ReadUIndex;
    Result := CreatePointerTypeDefinition (ReferenceTypeIndex);
  end;

function AdcuParser.ParseVoidDefinition : TObject;
var RTTISize, Size : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    Result := CreateVoidTypeDefinition;
  end;

function AdcuParser.ParseArrayDefinition : TObject;
  begin
    ParseArrayTypeBase;
    Result := CreateArrayDefinition;
  end;

function AdcuParser.ParseShortStringDefinition : TObject;
  begin
    ParseArrayTypeBase;
    Result := CreateShortStringDefinition;
  end;

function AdcuParser.ParseStringDefinition : TObject;
  begin
    ParseArrayTypeBase;
    Result := CreateStringDefinition;
  end;

function AdcuParser.ParseRangeDefinition : TObject;
var ElementTypeIndex : Integer;
    LowBound, HighBound : Int64;
  begin
    ParseRangeTypeBase (ElementTypeIndex, LowBound, HighBound);
    Result := CreateRangeDefinition (GetTypeCount + 1, ElementTypeIndex, LowBound, HighBound);
  end;

function AdcuParser.ParseCharRangeDefinition : TObject;
var ElementTypeIndex : Integer;
    LowBound, HighBound : Int64;
  begin
    ParseRangeTypeBase (ElementTypeIndex, LowBound, HighBound);
    Result := CreateCharRangeDefinition (GetTypeCount + 1, ElementTypeIndex, LowBound, HighBound);
  end;

function AdcuParser.ParseBooleanRangeDefinition : TObject;
var ElementTypeIndex : Integer;
    LowBound, HighBound : Int64;
  begin
    ParseRangeTypeBase (ElementTypeIndex, LowBound, HighBound);
    Result := CreateBooleanRangeDefinition (GetTypeCount + 1, ElementTypeIndex, LowBound, HighBound);
  end;

function AdcuParser.ParseWideCharRangeDefinition : TObject;
var ElementTypeIndex : Integer;
    LowBound, HighBound : Int64;
  begin
    ParseRangeTypeBase (ElementTypeIndex, LowBound, HighBound);
    Result := CreateWideCharRangeDefinition (GetTypeCount + 1, ElementTypeIndex, LowBound, HighBound);
  end;

function AdcuParser.ParseWideRangeDefinition : TObject;
var ElementTypeIndex : Integer;
    LowBound, HighBound : Int64;
  begin
    ParseRangeTypeBase (ElementTypeIndex, LowBound, HighBound);
    Result := CreateWideRangeDefinition (GetTypeCount + 1, ElementTypeIndex, LowBound, HighBound);
  end;

function AdcuParser.ParseFileDefinition : TObject;
var RTTISize, Size, ElementTypeIndex : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    ElementTypeIndex := ReadUIndex;
    Result := CreateFileDefinition (ElementTypeIndex);
  end;

function AdcuParser.ParseTextDefinition : TObject;
var RTTISize, Size : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    Result := CreateTextDefinition;
  end;

function AdcuParser.ParseEnumDefinition : TObject;
var RTTISize, Size, BaseTypeIndex : Integer;
    Lo, Hi : Int64;
  begin
    ParseTypeBase (RTTISize, Size);
    BaseTypeIndex := ReadUIndex;
    ReadSIndex; { NDX }
    Lo := ReadSIndex;
    Hi := ReadSIndex;
    FReader.ReadByte;
    Result := CreateEnumDefinition (BaseTypeIndex, Lo, Hi);
  end;

function AdcuParser.ParseSetDefinition : TObject;
var RTTISize, Size, ElementTypeIndex : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    FReader.ReadByte; { BStart }
    ElementTypeIndex := ReadUIndex;
    Result := CreateSetDefinition (ElementTypeIndex);
  end;

function AdcuParser.ParseRecordDefinition : TObject;
var RTTISize, Size : Integer;
    Fields : ObjectArray;
  begin
    ParseTypeBase (RTTISize, Size);
    FReader.ReadByte;
    ReadTag;
    Fields := ParseRecordFieldDeclarations;
    Result := CreateRecordDefinition (Size, Fields);
  end;

function AdcuParser.ParseClassDefinition : TObject;
var RTTISize, Size, ParentTypeIndex, ICnt, I : Integer;
    Fields : ObjectArray;
  begin
    ParseTypeBase (RTTISize, Size);
    ParentTypeIndex := ReadUIndex;
    ReadUIndex; { InstBaseRTTISz }
    ReadSIndex; { InstBaseSz }
    ReadUIndex; { InstBaseV }
    ReadUIndex; { Ndx2 }
    ReadUIndex; { NdxFE }
    ReadUIndex; { NDX00a }
    FReader.ReadByte; { B04 }
    ICnt := ReadSIndex;
    For I := 0 to ICnt * 2 - 1 do
      ReadUIndex;
    ReadTag;
    Fields := ParseFieldListDeclarations (ltClass);
    Result := CreateClassDefinition (ParentTypeIndex, Fields);
  end;

function AdcuParser.ParseInterfaceDefinition : TObject;
var RTTISize, Size, ParentTypeIndex : Integer;
    ListType : TdcuFieldListType;
    GUID : TGUID;
    B : Byte;
    Fields : ObjectArray;
  begin
    ParseTypeBase (RTTISize, Size);
    ParentTypeIndex := ReadUIndex;
    ReadSIndex; { Ndx1 }
    FReader.Read (GUID, SizeOf (TGUID));
    B := FReader.ReadByte;
    if B and 4 = 0 then
      ListType := ltInterface else
      ListType := ltDispInterface;
    ReadTag;
    Fields := ParseFieldListDeclarations (ListType);
    Result := CreateInterfaceDefinition (ListType = ltDispInterface, ParentTypeIndex, GUID, Fields);
  end;

function AdcuParser.ParseObjectVMTDefinition : TObject;
var RTTISize, Size, ObjectTypeIndex : Integer;
  begin
    ParseTypeBase (RTTISize, Size);
    ObjectTypeIndex := ReadUIndex;
    ReadUIndex; { Index1 }
    Result := CreateObjectVMTDefinition (ObjectTypeIndex);
  end;

function AdcuParser.ParseProcTypeDefinition : TObject;
var RTTISize, Size, ResultTypeIndex : Integer;
    CallingConvention : TdcuProcCallingConvention;
    Arguments, LocalDeclarations : ObjectArray;
  begin
    ParseTypeBase (RTTISize, Size);
    ReadUIndex; { NDX0 }
    ResultTypeIndex := ReadUIndex;
    ReadTag;
    CallingConvention := ccRegister;
    While not (Tag in [tagEmbeddedProcStart, tagStop]) do
      begin
        CallingConvention := ParseCallingConvention;
        if CallingConvention = ccRegister then
          ReadTag; // Skip other specifiers?
      end;
    if Tag = tagEmbeddedProcStart then
      begin
        ReadTag;
        ParseArgumentDeclarations (Arguments, LocalDeclarations);
      end else
      Arguments := nil;
    Result := CreateProcTypeDefinition (ResultTypeIndex, CallingConvention, Arguments, LocalDeclarations);
  end;

procedure AdcuParser.FinalizeParsing;
  begin
  end;

{ Unit                                                                         }
procedure AdcuParser.ParseUnit(const RequiredVersion : TdcuVersion);
{$IFDEF PROFILE}
var ParseTimer : THPTimer;
{$ENDIF}
  begin
    {$IFDEF PROFILE}
    ParseTimer := StartTimer;
    {$ENDIF}
    ParseHeader (RequiredVersion);
    ReadTag;
    ParseUnitFlags;
    ParseSourceFiles;
    ParseImports;
    ParseMainDeclarations;
    FinalizeParsing;
    {$IFDEF PROFILE}
    Log ('Parse time: ' + IntToStr (MillisecondsElapsed (ParseTimer, True)) + 'ms');
    {$ENDIF}
  end;



end.
