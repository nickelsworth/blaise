{                                                                              }
{                           Blaise constants v0.02                             }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{               Its original file name is cBlaiseConsts.pas                    }
{                                                                              }
{ Description:                                                                 }
{   This unit defines global Blaise constants.                                 }
{                                                                              }
{ Revision history:                                                            }
{   29/03/2003  0.01  Initial version.                                         }
{   17/05/2003  0.02  Revised Type IDs.                                        }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseConsts;

interface



{                                                                              }
{ Blaise constants                                                             }
{                                                                              }
const
  BlaiseLanguageVersion      = '0.90 Beta 1';
  BlaiseCopyright            = 'Copyright (c) 2003 by DJ Butler';
  BlaiseFullVersion          = BlaiseLanguageVersion;
  BlaiseLanguageMajorVersion = 0;
  BlaiseLanguageMinorVersion = 90;
  BlaiseLanguageBetaVersion  = 1;



{                                                                              }
{ Type IDs                                                                     }
{   Used by Blaise types and Blaise type definitions.                          }
{                                                                              }
const
  BLAISE_TYPE_ID_Invalid                  = $FF;

  // Special
  BLAISE_TYPE_ID_FIRST_Special            = Ord('0'); // $30
  BLAISE_TYPE_ID_VALUE_FIRST              = Ord('0'); // $30
  BLAISE_TYPE_ID_VALUE_Nil                = Ord('0');
  BLAISE_TYPE_ID_VALUE_Unassigned         = Ord('1');
  BLAISE_TYPE_ID_VALUE_Unknown            = Ord('2');
  BLAISE_TYPE_ID_VALUE_LAST               = Ord('2'); // $32
  BLAISE_TYPE_ID_DEF_FIRST                = Ord('3'); // $33
  BLAISE_TYPE_ID_DEF_None                 = Ord('3');
  BLAISE_TYPE_ID_DEF_Unknown              = Ord('4');
  BLAISE_TYPE_ID_DEF_Identifier           = Ord('5');
  BLAISE_TYPE_ID_DEF_LAST                 = Ord('5'); // $35
  BLAISE_TYPE_ID_LAST_Special             = Ord('5'); // $35

  // Abstract
  BLAISE_TYPE_ID_FIRST_Abstract           = Ord('A'); // $41
  BLAISE_TYPE_ID_GEN_Object               = Ord('A');
  BLAISE_TYPE_ID_FIRST_BlaiseAbstract     = Ord('B'); // $42
  BLAISE_TYPE_ID_GEN_BlaiseType           = Ord('B');
  BLAISE_TYPE_ID_GEN_TypeDefinition       = Ord('C');
  BLAISE_TYPE_ID_GEN_MathType             = Ord('D');
  BLAISE_TYPE_ID_GEN_SimpleType           = Ord('E');
  BLAISE_TYPE_ID_GEN_Number               = Ord('F');
  BLAISE_TYPE_ID_GEN_Integer              = Ord('G');
  BLAISE_TYPE_ID_GEN_SubRange             = Ord('H');
  BLAISE_TYPE_ID_GEN_Real                 = Ord('I');
  BLAISE_TYPE_ID_GEN_Boolean              = Ord('J');
  BLAISE_TYPE_ID_GEN_DateTime             = Ord('K');
  BLAISE_TYPE_ID_GEN_Function             = Ord('L');
  BLAISE_TYPE_ID_GEN_Iterator             = Ord('M');
  BLAISE_TYPE_ID_GEN_Stream               = Ord('N');
  BLAISE_TYPE_ID_GEN_NameSpace            = Ord('O');
  BLAISE_TYPE_ID_GEN_Expression           = Ord('P');
  BLAISE_TYPE_ID_GEN_Composite            = Ord('Q');
  BLAISE_TYPE_ID_GEN_Sequence             = Ord('R');
  BLAISE_TYPE_ID_GEN_Mapping              = Ord('S');
  BLAISE_TYPE_ID_LAST_BlaiseAbstract      = Ord('S'); // $52
  BLAISE_TYPE_ID_LAST_Abstract            = Ord('S'); // $52

  // Built-in
  BLAISE_TYPE_ID_FIRST_BuiltIn            = $61; // Built-in
  BLAISE_TYPE_ID_FIRST_SimpleType         = $61; // Simple
  BLAISE_TYPE_ID_FIRST_Number             = $61; // Number
  BLAISE_TYPE_ID_INTEGER_BYTE             = $61;
  BLAISE_TYPE_ID_INTEGER_16               = $62;
  BLAISE_TYPE_ID_INTEGER_32               = $63;
  BLAISE_TYPE_ID_INTEGER_64               = $64;
  BLAISE_TYPE_ID_FLOAT_SINGLE             = $65;
  BLAISE_TYPE_ID_FLOAT_DOUBLE             = $66;
  BLAISE_TYPE_ID_FLOAT_EXTENDED           = $67;
  BLAISE_TYPE_ID_RATIONAL                 = $68;
  BLAISE_TYPE_ID_COMPLEX                  = $69;
  BLAISE_TYPE_ID_STATISTIC                = $6A;
  BLAISE_TYPE_ID_INFINITY                 = $6B;
  BLAISE_TYPE_ID_SUBRANGE_INT             = $6C;
  BLAISE_TYPE_ID_SUBRANGE_ENUMERATION     = $6D;
  BLAISE_TYPE_ID_CURRENCY                 = $6E;
  BLAISE_TYPE_ID_LAST_Number              = $6E; // Number
  BLAISE_TYPE_ID_STRING                   = $6F;
  BLAISE_TYPE_ID_STRING_URL               = $70;
  BLAISE_TYPE_ID_BINARY_BASE64            = $71;
  BLAISE_TYPE_ID_CHAR                     = $72;
  BLAISE_TYPE_ID_UNICODE                  = $73;
  BLAISE_TYPE_ID_UNICODECHAR              = $74;
  BLAISE_TYPE_ID_BOOLEAN                  = $75;
  BLAISE_TYPE_ID_DATETIME                 = $76;
  BLAISE_TYPE_ID_DATETIME_ANSI            = $77;
  BLAISE_TYPE_ID_DATETIME_RFC             = $78;
  BLAISE_TYPE_ID_DURATION                 = $79;
  BLAISE_TYPE_ID_DURATION_TIMER           = $7A;
  BLAISE_TYPE_ID_LAST_SimpleType          = $7A; // Simple
  BLAISE_TYPE_ID_STREAM                   = $7B;
  BLAISE_TYPE_ID_RECORD                   = $7C;
  BLAISE_TYPE_ID_CLASS                    = $7D;
  BLAISE_TYPE_ID_OBJECT                   = $7E;
  BLAISE_TYPE_ID_ARRAY                    = $7F;
  BLAISE_TYPE_ID_VECTOR                   = $80;
  BLAISE_TYPE_ID_MATRIX                   = $81;
  BLAISE_TYPE_ID_DICTIONARY               = $82;
  BLAISE_TYPE_ID_LAST_BuiltIn             = $82; // Built-in

function  TypeIDIsNoValue(const ID: Byte): Boolean;
function  TypeIDIsBlaiseType(const ID: Byte): Boolean;
function  TypeIDIsTypeDefinition(const ID: Byte): Boolean;
function  TypeIDIsFunction(const ID: Byte): Boolean;
function  TypeIDIsSimpleType(const ID: Byte): Boolean;
function  TypeIDIsNumber(const ID: Byte): Boolean;
function  TypeIDIsSubRange(const ID: Byte): Boolean;
function  TypeIDIsInteger(const ID: Byte): Boolean;
function  TypeIDIsFloat(const ID: Byte): Boolean;
function  TypeIDIsReal(const ID: Byte): Boolean;
function  TypeIDIsOrdinal(const ID: Byte): Boolean;
function  TypeIDIsBoolean(const ID: Byte): Boolean;
function  TypeIDIsDateTime(const ID: Byte): Boolean;
function  TypeIDIsStream(const ID: Byte): Boolean;
function  TypeIDIsSequence(const ID: Byte): Boolean;
function  TypeIDIsMapping(const ID: Byte): Boolean;



{                                                                              }
{ Field Definition IDs                                                         }
{                                                                              }
const
  BLAISE_FIELD_ID_None             = $00;

  BLAISE_FIELD_ID_VAR              = Ord('A'); // $41
  BLAISE_FIELD_ID_CONST            = Ord('B');
  BLAISE_FIELD_ID_TYPE             = Ord('C');

  BLAISE_FIELD_ID_CODE_PROCEDURE   = Ord('J'); // $4A
  BLAISE_FIELD_ID_CODE_FUNCTION    = Ord('K');
  BLAISE_FIELD_ID_CODE_CONSTRUCTOR = Ord('L');
  BLAISE_FIELD_ID_CODE_DESTRUCTOR  = Ord('M');
  BLAISE_FIELD_ID_CODE_TASK        = Ord('N');
  BLAISE_FIELD_ID_CODE_EXTERNAL    = Ord('O');

  BLAISE_FIELD_ID_PAR_CONST        = Ord('a'); // $61
  BLAISE_FIELD_ID_PAR_VAR          = Ord('b');
  BLAISE_FIELD_ID_PAR_LOCAL        = Ord('c');

  BLAISE_FIELD_ID_RECORD_VAR       = Ord('j'); // $6A
  BLAISE_FIELD_ID_RECORD_CONST     = Ord('k');

  BLAISE_FIELD_ID_PROPERTY         = Ord('p'); // $70




{                                                                              }
{ Virtual Machine Byte Codes                                                   }
{                                                                              }
const
  BLAISE_VM_INVALID_OP_00         = $00;
  BLAISE_VM_NOP                   = $01;

  BLAISE_VM_LOAD_UTF8_CONST       = $10;      // UTF8 := <constant>
  BLAISE_VM_LOAD_BOOL_A           = $11;      // Bool := A
  BLAISE_VM_LOAD_STR_A            = $12;      // Str := A
  BLAISE_VM_LOAD_INT_A            = $13;      // Int := A
  BLAISE_VM_LOAD_FLOAT_A          = $14;      // Float := A
  BLAISE_VM_LOAD_CMP_A            = $15;      // Cmp := A
  BLAISE_VM_REVERSE_CMP           = $16;      // Cmp := reversed Cmp
  BLAISE_VM_LOAD_A_STACK0         = $17;      // A := Stack0
  BLAISE_VM_LOAD_A_STACK1         = $18;      // A := Stack1
  BLAISE_VM_LOAD_BOOL_TRUE        = $19;      // Bool := True
  BLAISE_VM_LOAD_BOOL_FALSE       = $1A;      // Bool := False

  BLAISE_VM_PUSH_NIL              = $20;
  BLAISE_VM_PUSH_CONST_OBJECT     = $21;
  BLAISE_VM_PUSH_CONST_BOOL       = $22;
  BLAISE_VM_PUSH_CONST_STR        = $23;
  BLAISE_VM_PUSH_CONST_INT        = $24;
  BLAISE_VM_PUSH_CONST_FLOAT      = $25;
  BLAISE_VM_PUSH_CONST_COMPLEX    = $26;
  BLAISE_VM_PUSH_A                = $27;
  BLAISE_VM_POP                   = $28;
  BLAISE_VM_POP_A                 = $29;
  BLAISE_VM_PUSH_BOOL             = $2A;
  BLAISE_VM_STACK_SWAP_TOP2       = $2B;

  BLAISE_VM_EVAL_COERCE_BOOL      = $30;      // A := A.AsBoolean
  BLAISE_VM_EVAL_COERCE_STR       = $31;      // A := A.AsString
  BLAISE_VM_EVAL_COERCE_INT       = $32;      // A := A.AsInteger
  BLAISE_VM_EVAL_COERCE_FLOAT     = $33;      // A := A.AsFloat
  BLAISE_VM_EVAL_CMP              = $34;      // Cmp := Compare(Stack1, Stack0), A := undefined, Stack unchanged
  BLAISE_VM_EVAL_DUP              = $35;      // A := Duplicate(A)
  BLAISE_VM_EVAL_UNIQUE           = $36;      // A := Unique(A)
  BLAISE_VM_EVAL_ITERATE          = $37;      // A := Iterate(Stack0)
  BLAISE_VM_EVAL_HASNEXT          = $38;      // A := Stack0.HasNext
  BLAISE_VM_EVAL_NEXT             = $39;      // A := Stack0.Next
  BLAISE_VM_EVAL_IS_TYPE          = $3A;      // Bool := Stack1 is Stack0
  BLAISE_VM_EVAL_IS_IN            = $3B;      // Bool := Stack1 in Stack0
  BLAISE_VM_EVAL_APPEND_LIST      = $3C;      // Stack1.AppendList(Stack0)

  BLAISE_VM_EVAL_L_COERCE_ADD     = $40;      // A := LeftCoerce(bmoAdd, Stack1, Stack0)
  BLAISE_VM_EVAL_R_COERCE_ADD     = $41;      // A := RightCoerce(bmoAdd, Stack1, Stack0)
  BLAISE_VM_EVAL_L_COERCE_SUB     = $42;
  BLAISE_VM_EVAL_R_COERCE_SUB     = $43;
  BLAISE_VM_EVAL_L_COERCE_MUL     = $44;
  BLAISE_VM_EVAL_R_COERCE_MUL     = $45;
  BLAISE_VM_EVAL_L_COERCE_DIV     = $46;
  BLAISE_VM_EVAL_R_COERCE_DIV     = $47;
  BLAISE_VM_EVAL_L_COERCE_POWER   = $48;
  BLAISE_VM_EVAL_R_COERCE_POWER   = $49;
  BLAISE_VM_EVAL_L_COERCE_IDIV    = $4A;
  BLAISE_VM_EVAL_R_COERCE_IDIV    = $4B;
  BLAISE_VM_EVAL_L_COERCE_MOD     = $4C;
  BLAISE_VM_EVAL_R_COERCE_MOD     = $4D;
  BLAISE_VM_EVAL_L_COERCE_AND     = $4E;
  BLAISE_VM_EVAL_R_COERCE_AND     = $4F;
  BLAISE_VM_EVAL_L_COERCE_OR      = $50;
  BLAISE_VM_EVAL_R_COERCE_OR      = $51;
  BLAISE_VM_EVAL_L_COERCE_XOR     = $52;
  BLAISE_VM_EVAL_R_COERCE_XOR     = $53;
  BLAISE_VM_EVAL_L_COERCE_SHL     = $54;
  BLAISE_VM_EVAL_R_COERCE_SHL     = $55;
  BLAISE_VM_EVAL_L_COERCE_SHR     = $56;
  BLAISE_VM_EVAL_R_COERCE_SHR     = $57;

  BLAISE_VM_EVAL_L_ADD            = $60;      // A.Add(Stack0), A := A + Stack0
  BLAISE_VM_EVAL_R_ADD            = $61;      // A.RevAdd(Stack0), A := Stack0 + A
  BLAISE_VM_EVAL_L_SUB            = $62;
  BLAISE_VM_EVAL_R_SUB            = $63;
  BLAISE_VM_EVAL_L_MUL            = $64;
  BLAISE_VM_EVAL_R_MUL            = $65;
  BLAISE_VM_EVAL_L_DIV            = $66;
  BLAISE_VM_EVAL_R_DIV            = $67;
  BLAISE_VM_EVAL_L_POWER          = $68;
  BLAISE_VM_EVAL_R_POWER          = $69;
  BLAISE_VM_EVAL_L_IDIV           = $6A;
  BLAISE_VM_EVAL_R_IDIV           = $6B;
  BLAISE_VM_EVAL_L_MOD            = $6C;
  BLAISE_VM_EVAL_R_MOD            = $6D;
  BLAISE_VM_EVAL_L_AND            = $6E;
  BLAISE_VM_EVAL_R_AND            = $6F;
  BLAISE_VM_EVAL_L_OR             = $70;
  BLAISE_VM_EVAL_R_OR             = $71;
  BLAISE_VM_EVAL_L_XOR            = $72;
  BLAISE_VM_EVAL_R_XOR            = $73;
  BLAISE_VM_EVAL_L_SHL            = $74;
  BLAISE_VM_EVAL_R_SHL            = $75;
  BLAISE_VM_EVAL_L_SHR            = $76;
  BLAISE_VM_EVAL_R_SHR            = $77;

  BLAISE_VM_EVAL_COERCE_SQR       = $80;      // A := UnaryCoerce(umoSqr, Stack0)
  BLAISE_VM_EVAL_COERCE_SQRT      = $81;
  BLAISE_VM_EVAL_COERCE_EXP       = $82;
  BLAISE_VM_EVAL_COERCE_LN        = $83;
  BLAISE_VM_EVAL_COERCE_SIN       = $84;
  BLAISE_VM_EVAL_COERCE_COS       = $85;

  BLAISE_VM_EVAL_SQR              = $90;      // A.Sqr
  BLAISE_VM_EVAL_SQRT             = $91;
  BLAISE_VM_EVAL_EXP              = $92;
  BLAISE_VM_EVAL_LN               = $93;
  BLAISE_VM_EVAL_SIN              = $94;
  BLAISE_VM_EVAL_COS              = $95;
  BLAISE_VM_EVAL_NEGATE           = $96;      // A.Negate
  BLAISE_VM_EVAL_ABS              = $97;
  BLAISE_VM_EVAL_INC              = $98;      // A.Inc
  BLAISE_VM_EVAL_DEC              = $99;      // A.Dec
  BLAISE_VM_EVAL_NOT              = $9A;

  BLAISE_VM_RET                   = $A0;
  BLAISE_VM_JMP                   = $A1;
  BLAISE_VM_JMP_TRUE              = $A2;
  BLAISE_VM_JMP_FALSE             = $A3;
  BLAISE_VM_JMP_CMP               = $A4;
  BLAISE_VM_JMP_EQ                = $A5;
  BLAISE_VM_JMP_NE                = $A6;
  BLAISE_VM_JMP_GR                = $A7;
  BLAISE_VM_JMP_LE                = $A8;
  BLAISE_VM_JMP_ASSIGNED          = $A9;
  BLAISE_VM_JMP_NOT_ASSIGNED      = $AA;

  BLAISE_VM_FLOW_EXIT             = $B0;
  BLAISE_VM_FLOW_BREAK            = $B1;
  BLAISE_VM_FLOW_CONTINUE         = $B2;
  BLAISE_VM_FLOW_ENTER_LOOP       = $B3;
  BLAISE_VM_FLOW_LEAVE_LOOP       = $B4;
  BLAISE_VM_FLOW_RAISE            = $B5;
  BLAISE_VM_FLOW_RERAISE          = $B6;
  BLAISE_VM_FLOW_ENTER_TRY_FIN    = $B7;
  BLAISE_VM_FLOW_LEAVE_TRY_FIN    = $B8;
  BLAISE_VM_FLOW_END_TRY_FIN      = $B9;
  BLAISE_VM_FLOW_ENTER_TRY_EXCEPT = $BA;
  BLAISE_VM_FLOW_LEAVE_TRY_EXCEPT = $BB;
  BLAISE_VM_FLOW_END_TRY_EXCEPT   = $BC;

  BLAISE_VM_IDEN_UNIQUE           = $C0;      // RegA = Unique(GetValue(Identifier)), Identifier not updated
  BLAISE_VM_IDEN_EVAL             = $C1;      // RegA = Eval(Identifier, Stack0 params on stack)
  BLAISE_VM_IDEN_EXEC             = $C2;
  BLAISE_VM_IDEN_ASSIGN           = $C3;      // Identifier := Stack0, Pop
  BLAISE_VM_IDEN_SCOPE            = $C4;      // Scope for next IDEN_ command := Stack0, Pop
  BLAISE_VM_IDEN_EVAL_IDX         = $C5;      // RegA = Eval(Stack1[Stack0]), (Pop Pop), Bool = ReversedIndex
  BLAISE_VM_IDEN_EXEC_IDX         = $C6;
  BLAISE_VM_IDEN_ASSIGN_IDX       = $C7;      // (Pop Pop Pop), Stack1[Stack0] := Stack2
  BLAISE_VM_IDEN_EVAL_CALL        = $C8;
  BLAISE_VM_IDEN_EXEC_CALL        = $C9;
  BLAISE_VM_IDEN_SELF             = $CA;      // RegA = self
  BLAISE_VM_IDEN_SCOPE_INHERITED  = $CB;      // Scope for next IDEN_ command is inherited scope

  BLAISE_VM_CREATE_RATIONAL       = $D0;
  BLAISE_VM_CREATE_ARRAY          = $D1;
  BLAISE_VM_CREATE_DICT           = $D2;

  BLAISE_VM_NAMED_DELETE          = $E0;      // NamedDelete(Utf8)
  BLAISE_VM_NAMED_ASSIGN          = $E1;      // NamedAssign(Utf8, Stack0), Pop
  BLAISE_VM_NAMED_EXISTS          = $E2;      // Push NamedExists(Utf8)
  BLAISE_VM_NAMED_GET             = $E3;      // Push NamedGet(Utf8)
  BLAISE_VM_NAMED_DIR             = $E4;      // Push NamedDir(Utf8)

  BLAISE_VM_MODULE_TYPE_ID        = $F0;
  BLAISE_VM_USE_UNIT              = $F1;
  BLAISE_VM_DECLARATION           = $F2;
  BLAISE_VM_TEXTOUT               = $F3;
  BLAISE_VM_ENTER_FUNC_SCOPE      = $F4;
  BLAISE_VM_LEAVE_FUNC_SCOPE      = $F5;
  BLAISE_VM_START_TASK            = $F6;
  BLAISE_VM_TASK_RETURN           = $F7;
  BLAISE_VM_IMPORT                = $F8;

  BLAISE_VM_INVALID_OP_FF         = $FF;



{                                                                              }
{ Virtual Machine Module Type IDs                                              }
{                                                                              }
const
  BLAISE_VM_MODULE_TYPE_ID_Invalid     = $00;
  BLAISE_VM_MODULE_TYPE_ID_APPLICATION = Ord('A');
  BLAISE_VM_MODULE_TYPE_ID_UNIT        = Ord('U');



{                                                                              }
{ Virtual Machine Constants                                                    }
{                                                                              }
const
  BLAISE_VM_INVALID_REL_OFFSET = LongInt($7FFFFFFF);



{                                                                              }
{ File extentions                                                              }
{                                                                              }
const
  BLAISE_EXT_Source_Legacy     = '.pas';
  BLAISE_EXT_Source            = '.bla';
  BLAISE_EXT_Source_WebScript  = '.blw';
  BLAISE_EXT_Reformat          = '.ble';
  BLAISE_EXT_CompiledApp       = '.bca';
  BLAISE_EXT_CompiledUnit      = '.bcu';
  BLAISE_EXT_CompiledWebScript = '.bcw';



implementation



{                                                                              }
{ Type IDs                                                                     }
{                                                                              }
function TypeIDIsNoValue(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_VALUE_Nil,
      BLAISE_TYPE_ID_VALUE_Unassigned,
      BLAISE_TYPE_ID_Invalid];
end;

function TypeIDIsBlaiseType(const ID: Byte): Boolean;
begin
  Result := (ID in [
      BLAISE_TYPE_ID_FIRST_BlaiseAbstract..BLAISE_TYPE_ID_LAST_BlaiseAbstract,
      BLAISE_TYPE_ID_FIRST_BuiltIn..BLAISE_TYPE_ID_LAST_BuiltIn]);
end;

function TypeIDIsTypeDefinition(const ID: Byte): Boolean;
begin
  Result := ID = BLAISE_TYPE_ID_GEN_TypeDefinition;
end;

function TypeIDIsFunction(const ID: Byte): Boolean;
begin
  Result := ID = BLAISE_TYPE_ID_GEN_Function;
end;

function TypeIDIsSimpleType(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_SimpleType,
      BLAISE_TYPE_ID_GEN_Number,
      BLAISE_TYPE_ID_GEN_Integer,
      BLAISE_TYPE_ID_GEN_SubRange,
      BLAISE_TYPE_ID_GEN_Real,
      BLAISE_TYPE_ID_GEN_Boolean,
      BLAISE_TYPE_ID_GEN_DateTime,
      BLAISE_TYPE_ID_FIRST_SimpleType..BLAISE_TYPE_ID_LAST_SimpleType];
end;

function TypeIDIsNumber(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Number,
      BLAISE_TYPE_ID_GEN_Integer,
      BLAISE_TYPE_ID_GEN_SubRange,
      BLAISE_TYPE_ID_GEN_Real,
      BLAISE_TYPE_ID_FIRST_Number..BLAISE_TYPE_ID_LAST_Number];
end;

function TypeIDIsSubRange(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_SubRange,
      BLAISE_TYPE_ID_SUBRANGE_INT,
      BLAISE_TYPE_ID_SUBRANGE_ENUMERATION];
end;

function TypeIDIsInteger(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Integer,
      BLAISE_TYPE_ID_INTEGER_BYTE,
      BLAISE_TYPE_ID_INTEGER_16,
      BLAISE_TYPE_ID_INTEGER_32,
      BLAISE_TYPE_ID_INTEGER_64];
end;

function TypeIDIsFloat(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_FLOAT_SINGLE,
      BLAISE_TYPE_ID_FLOAT_DOUBLE,
      BLAISE_TYPE_ID_FLOAT_EXTENDED];
end;

function TypeIDIsReal(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Real,
      BLAISE_TYPE_ID_FLOAT_SINGLE,
      BLAISE_TYPE_ID_FLOAT_DOUBLE,
      BLAISE_TYPE_ID_FLOAT_EXTENDED,
      BLAISE_TYPE_ID_RATIONAL,
      BLAISE_TYPE_ID_CURRENCY];
end;

function TypeIDIsOrdinal(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Integer,
      BLAISE_TYPE_ID_GEN_SubRange,
      BLAISE_TYPE_ID_GEN_Boolean,
      BLAISE_TYPE_ID_INTEGER_BYTE,
      BLAISE_TYPE_ID_INTEGER_16,
      BLAISE_TYPE_ID_INTEGER_32,
      BLAISE_TYPE_ID_INTEGER_64,
      BLAISE_TYPE_ID_SUBRANGE_INT,
      BLAISE_TYPE_ID_SUBRANGE_ENUMERATION,
      BLAISE_TYPE_ID_CHAR,
      BLAISE_TYPE_ID_BOOLEAN];
end;

function TypeIDIsBoolean(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Boolean,
      BLAISE_TYPE_ID_BOOLEAN];
end;

function TypeIDIsDateTime(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_DateTime,
      BLAISE_TYPE_ID_DATETIME,
      BLAISE_TYPE_ID_DATETIME_ANSI,
      BLAISE_TYPE_ID_DATETIME_RFC,
      BLAISE_TYPE_ID_DURATION,
      BLAISE_TYPE_ID_DURATION_TIMER];
end;

function TypeIDIsStream(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Stream,
      BLAISE_TYPE_ID_STREAM];
end;

function TypeIDIsSequence(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Sequence,
      BLAISE_TYPE_ID_ARRAY,
      BLAISE_TYPE_ID_VECTOR,
      BLAISE_TYPE_ID_MATRIX];
end;

function TypeIDIsMapping(const ID: Byte): Boolean;
begin
  Result := ID in [
      BLAISE_TYPE_ID_GEN_Mapping,
      BLAISE_TYPE_ID_DICTIONARY];
end;



end.

