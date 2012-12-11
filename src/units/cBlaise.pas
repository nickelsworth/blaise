{                                                                              }
{                                Blaise v0.02                                  }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{                   Its original file name is cBlaise.pas                      }
{                                                                              }
{ Description:                                                                 }
{   This unit implements top level access to Blaise.                           }
{                                                                              }
{ Revision history:                                                            }
{   05/04/2003  0.01  Initial version for Blaise Prompt.                       }
{   08/04/2003  0.02  Functions for Blaise CLI.                                }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaise;

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cDateTime,
  cReaders,
  cWriters,

  { Blaise }
  cBlaiseTypes,
  cBlaiseVMCompiler,
  cBlaiseVM,
  cBlaiseMachineTypes,
  cBlaiseMachine,
  cBlaiseParserNodes,
  cBlaiseParser;

  

{                                                                              }
{ TBlaise                                                                      }
{   Encapsulates the Blaise Scripting functionality.                           }
{                                                                              }
type
  TBlaiseCodeType = (bcSource, bcNode, bcTree, bcCompiled);
  TBlaiseCodeTypes = Set of TBlaiseCodeType;
  TBlaiseTreeType = (btNone, btStatement, btDef, btApp, btUnit);
  TBlaise = class
  protected
    FScope         : TApplicationScope;
    FParser        : TBlaiseScriptParser;
    FCompiler      : TBlaiseVMCompiler;
    FMachine       : TBlaiseVM;
    FCodeTypes     : TBlaiseCodeTypes;
    FTreeType      : TBlaiseTreeType;
    FSource        : String;
    FNode          : ABlaiseScriptNode;
    FTreeStatement : AStatement;
    FTreeDef       : AScopeFieldDefinitionArray;
    FTreeApp       : TBlaiseApplication;
    FTreeUnit      : TBlaiseUnit;
    FCompiled      : String;
    FLexTimer      : THPTimer;
    FParseTimer    : THPTimer;
    FExecTimer     : THPTimer;
    FRunTimer      : THPTimer;

    function  GetParser: TBlaiseScriptParser;
    function  GetCompiler: TBlaiseVMCompiler;
    function  GetMachine: TBlaiseVM;

    procedure RequireSource;
    procedure RequireNode;
    procedure RequireTree;
    procedure RequireCompiled;

    procedure ClearCodeTree;
    procedure ClearCodeNode;

    procedure InitParsing;
    procedure FinalizeParsing;

  public
    destructor Destroy; override;

    property  Parser: TBlaiseScriptParser read GetParser;
    property  Compiler: TBlaiseVMCompiler read GetCompiler;
    property  Machine: TBlaiseVM read GetMachine;
    property  Scope: TApplicationScope read FScope;

    procedure ClearCode;
    procedure SetCodeSource(const S: String);
    procedure SetCodeNode(const N: ABlaiseScriptNode);
    procedure SetCodeStatement(const V: AStatement);
    procedure SetCodeCompiled(const S: String);

    procedure LoadSourceCode(const FileName: String);
    procedure SaveSourceCode(const FileName: String);
    procedure LoadCompiledCode(const FileName: String);
    procedure SaveCompiledCode(const FileName: String);

    procedure SetScope(const Scope: TApplicationScope);
    procedure SetApplicationScope(const Input: AReaderEx;
              const Output, Log: AWriterEx);

    procedure LexParsingInit;
    procedure LexParsingFin;

    function  ParseImmediate: ABlaiseScriptNode;
    function  ParseSource: ABlaiseScriptNode;

    function  CreateTree: TBlaiseTreeType;
    property  TreeType: TBlaiseTreeType read FTreeType;
    procedure OptimizeTree;
    procedure Execute;
    procedure Compile;
    procedure Run;

    function  GetLexTimeStr: String;
    function  GetParseTimeStr: String;
    function  GetExecTimeStr: String;
    function  GetRunTimeMs: Integer;
    function  GetRunTimeStr: String;

    function  ParseSourceCode(const S: String): ABlaiseScriptNode;
    function  ParseImmediateSource(const S: String): ABlaiseScriptNode;
    function  ParseSourceFile(const FileName: String): ABlaiseScriptNode;

    function  GetNodeSource: String;
    function  GetNodeSourceAsHtml: String;
    procedure ExecuteNode;
    function  CompileNode: TBlaiseTreeType;
    function  RunNode: TBlaiseTreeType;

    function  RunImmediateSource(const S: String): TBlaiseTreeType;
    procedure RunSourceCode(const S: String);
    procedure RunSourceFile(const FileName: String);
    procedure RunCompiledFile(const FileName: String);
    procedure RunFile(const FileName: String);
    procedure ExecuteImmediateSource(const S: String);
  end;
  EBlaise = class(Exception);



implementation

uses
  { Fundamentals }
  cUtils,
  cStrings,

  { Blaise }
  cBlaiseConsts,
  cBlaiseFuncs;



{                                                                              }
{ TBlaise                                                                      }
{                                                                              }
destructor TBlaise.Destroy;
begin
  FreeAndNil(FNode);
  FreeAndNil(FTreeUnit);
  FreeAndNil(FTreeApp);
  FreeAndNil(FTreeStatement);
  FreeAndNilObjectArray(ObjectArray(FTreeDef));
  FreeAndNil(FMachine);
  FreeAndNil(FCompiler);
  FreeAndNil(FParser);
  ObjectReleaseReferenceAndNil(FScope);
  inherited Destroy;
end;

function TBlaise.GetParser: TBlaiseScriptParser;
begin
  if not Assigned(FParser) then
    FParser := TBlaiseScriptParser.Create;
  Result := FParser;
end;

function TBlaise.GetCompiler: TBlaiseVMCompiler;
begin
  if not Assigned(FCompiler) then
    FCompiler := TBlaiseVMCompiler.Create;
  Result := FCompiler;
end;

function TBlaise.GetMachine: TBlaiseVM;
begin
  if not Assigned(FMachine) then
    FMachine := TBlaiseVM.Create;
  Result := FMachine;
end;

procedure TBlaise.RequireSource;
begin
  if not (bcSource in FCodeTypes) then
    raise EBlaise.Create('No source');
end;

procedure TBlaise.RequireNode;
begin
  if not (bcNode in FCodeTypes) then
    raise EBlaise.Create('No node');
end;

procedure TBlaise.RequireTree;
begin
  if not (bcTree in FCodeTypes) then
    raise EBlaise.Create('No tree');
end;

procedure TBlaise.RequireCompiled;
begin
  if not (bcCompiled in FCodeTypes) then
    raise EBlaise.Create('No compiled code');
end;

procedure TBlaise.ClearCodeTree;
begin
  Exclude(FCodeTypes, bcTree);
  FTreeType := btNone;
  FreeAndNil(FTreeUnit);
  FreeAndNil(FTreeApp);
  FreeAndNil(FTreeStatement);
  FreeAndNilObjectArray(ObjectArray(FTreeDef));
end;

procedure TBlaise.ClearCodeNode;
begin
  Exclude(FCodeTypes, bcNode);
  FreeAndNil(FNode);
end;

procedure TBlaise.ClearCode;
begin
  FCodeTypes := [];
  FSource := '';
  FreeAndNil(FNode);
  ClearCodeTree;
  FCompiled := '';
end;

procedure TBlaise.SetCodeSource(const S: String);
begin
  ClearCode;
  FCodeTypes := [bcSource];
  FSource := S;
end;

procedure TBlaise.SetCodeNode(const N: ABlaiseScriptNode);
begin
  ClearCode;
  FCodeTypes := [bcNode];
  FNode := N;
end;

procedure TBlaise.SetCodeStatement(const V: AStatement);
begin
  ClearCode;
  FCodeTypes := [bcTree];
  FTreeType := btStatement;
  FTreeStatement := V;
end;

procedure TBlaise.SetCodeCompiled(const S: String);
begin
  ClearCode;
  FCodeTypes := [bcCompiled];
  FCompiled := S;
end;

procedure TBlaise.LoadSourceCode(const FileName: String);
begin
  SetCodeSource(ReadFileToStr(FileName));
end;

procedure TBlaise.SaveSourceCode(const FileName: String);
begin
  RequireSource;
  WriteStrToFile(FileName, FSource, fwomCreate);
end;

procedure TBlaise.LoadCompiledCode(const FileName: String);
begin
  SetCodeCompiled(ReadFileToStr(FileName));
end;

procedure TBlaise.SaveCompiledCode(const FileName: String);
begin
  RequireCompiled;
  WriteStrToFile(FileName, FCompiled, fwomCreate);
end;

procedure TBlaise.SetScope(const Scope: TApplicationScope);
begin
  ObjectReleaseReferenceAndNil(FScope);
  ObjectAddReference(Scope);
  FScope := Scope;
end;

procedure TBlaise.SetApplicationScope(const Input: AReaderEx;
    const Output, Log: AWriterEx);
begin
  SetScope(TApplicationScope.Create(Input, Output, Log));
end;

procedure TBlaise.LexParsingInit;
begin
  RequireSource;
  GetParser.SetText(FSource);
  FLexTimer := StartTimer;
end;

procedure TBlaise.LexParsingFin;
begin
  StopTimer(FLexTimer);
end;

procedure TBlaise.InitParsing;
begin
  RequireSource;
  GetParser.SetText(FSource);
  ClearCodeNode;
  FParseTimer := StartTimer;
end;

procedure TBlaise.FinalizeParsing;
begin
  StopTimer(FParseTimer);
  Include(FCodeTypes, bcNode);
  if not FParser.EOF then
    raise EBlaise.Create('Unexpected symbol: ' + FParser.TokenText);
end;

function ElapsedTimeToStr(const Timer: THPTimer): String;
var I : Integer;
begin
  I := MilliSecondsElapsed(Timer, False);
  if I < 1000 then
    Result := FloatToStr(MicrosecondsElapsed(Timer, False) / 1000.0) + 'ms' else
  if I < 10000 then
    Result := IntToStr(I) + 'ms' else
    Result := FloatToStr(I / 1000.0) + 's';
end;

function TBlaise.GetLexTimeStr: String;
begin
  Result := ElapsedTimeToStr(FLexTimer);
end;

function TBlaise.GetParseTimeStr: String;
begin
  Result := ElapsedTimeToStr(FParseTimer);
end;

function TBlaise.GetExecTimeStr: String;
begin
  Result := ElapsedTimeToStr(FExecTimer);
end;

function TBlaise.GetRunTimeMs: Integer;
begin
  Result := MillisecondsElapsed(FRunTimer, False);
end;

function TBlaise.GetRunTimeStr: String;
begin
  Result := ElapsedTimeToStr(FRunTimer);
end;

function TBlaise.ParseImmediate: ABlaiseScriptNode;
begin
  InitParsing;
  Result := FParser.ExtractImmediate;
  FNode := Result;
  FinalizeParsing;
end;

function TBlaise.ParseSource: ABlaiseScriptNode;
begin
  InitParsing;
  Result := FParser.ExtractSource;
  FNode := Result;
  FinalizeParsing;
end;

function TBlaise.CreateTree: TBlaiseTreeType;
begin
  RequireNode;
  ClearCodeTree;
  if not Assigned(FNode) then
    FTreeType := btNone else
  if FNode is AStatementNode then
    begin
      FTreeStatement := AStatementNode(FNode).GetAsStatement;
      FTreeType := btStatement;
    end else
  if FNode is ADeclarationNode then
    begin
      FTreeDef := ADeclarationNode(FNode).GetAsFieldDefinitions;
      FTreeType := btDef;
    end else
  if FNode is TApplicationNode then
    begin
      FTreeApp := TApplicationNode(FNode).GetApplication;
      FTreeType := btApp;
    end else
  if FNode is TUnitNode then
    begin
      FTreeUnit := TUnitNode(FNode).GetUnit;
      FTreeType := btUnit;
    end
  else
    raise EBlaise.Create('Unrecognised node: ' + ObjectClassName(FNode));
  Include(FCodeTypes, bcTree);
  Result := FTreeType;
end;

procedure TBlaise.OptimizeTree;
begin
  RequireTree;
  Case FTreeType of
    btStatement :
      if Assigned(FTreeStatement) then
        FTreeStatement := FTreeStatement.Optimize(FScope);
    btApp :
      if Assigned(FTreeApp) then
        FTreeApp.Optimize;
    btUnit :
      if Assigned(FTreeUnit) then
        FTreeUnit.Optimize;
  end;
end;

procedure TBlaise.Execute;
begin
  RequireTree;
  FExecTimer := StartTimer;
  Case FTreeType of
    btStatement :
      if Assigned(FTreeStatement) then
        FTreeStatement.Execute(FScope);
    btDef :
      if Assigned(FTreeDef) then
        ScopeAddFieldDefinitions(FScope, FTreeDef, FScope, nil);
    btApp :
      if Assigned(FTreeApp) then
        begin
          FTreeApp.InitScope(FScope);
          FTreeApp.Execute;
        end;
    btUnit :
      raise EBlaise.Create('Unit can not execute');
  end;
  StopTimer(FExecTimer);
end;

procedure TBlaise.Compile;
begin
  RequireTree;
  GetCompiler.Clear;
  Case FTreeType of
    btStatement :
      if Assigned(FTreeStatement) then
        begin
          FTreeStatement.Compile(FCompiler);
          FCompiler.Return;
        end;
    btDef :
      if Assigned(FTreeDef) then
        begin
          FCompiler.Declare(FTreeDef);
          FCompiler.Return;
        end;
    btApp :
      if Assigned(FTreeApp) then
        FTreeApp.Compile(FCompiler);
    btUnit :
      if Assigned(FTreeUnit) then
        FTreeUnit.Compile(FCompiler);
  end;
  FCompiled := Compiler.AsString;
  Include(FCodeTypes, bcCompiled);
end;

procedure TBlaise.Run;
begin
  RequireCompiled;
  FRunTimer := StartTimer;
  if FCompiled <> '' then
    GetMachine.Run(FScope, FCompiled);
  StopTimer(FRunTimer);
end;

function TBlaise.ParseSourceCode(const S: String): ABlaiseScriptNode;
begin
  SetCodeSource(S);
  Result := ParseSource;
end;

function TBlaise.ParseImmediateSource(const S: String): ABlaiseScriptNode;
begin
  SetCodeSource(S);
  Result := ParseImmediate;
end;

function TBlaise.ParseSourceFile(const FileName: String): ABlaiseScriptNode;
begin
  LoadSourceCode(FileName);
  Result := ParseSource;
end;

function TBlaise.GetNodeSource: String;
begin
  RequireNode;
  Result := FNode.GetSource;
end;

function TBlaise.GetNodeSourceAsHtml: String;
begin
  RequireNode;
  Result := FNode.GetSourceAsHtml;
end;

procedure TBlaise.ExecuteNode;
begin
  CreateTree;
  Execute;
end;

function TBlaise.CompileNode: TBlaiseTreeType;
begin
  Result := CreateTree;
  Compile;
end;

function TBlaise.RunNode: TBlaiseTreeType;
begin
  Result := CompileNode;
  Run;
end;

function TBlaise.RunImmediateSource(const S: String): TBlaiseTreeType;
begin
  ParseImmediateSource(S);
  Result := RunNode;
end;

procedure TBlaise.RunSourceCode(const S: String);
begin
  ParseSourceCode(S);
  RunNode;
end;

procedure TBlaise.RunSourceFile(const FileName: String);
begin
  ParseSourceFile(FileName);
  RunNode;
end;

procedure TBlaise.RunCompiledFile(const FileName: String);
begin
  LoadCompiledCode(FileName);
  Run;
end;

procedure TBlaise.RunFile(const FileName: String);
var Ext : String;
begin
  Ext := ExtractFileExt(FileName);
  if StrEqualNoCase(Ext, BLAISE_EXT_Source_Legacy) or
     StrEqualNoCase(Ext, BLAISE_EXT_Source) or
     StrEqualNoCase(Ext, BLAISE_EXT_Source_WebScript) or
     StrEqualNoCase(Ext, BLAISE_EXT_Reformat) then
    RunSourceFile(FileName) else
  if StrEqualNoCase(Ext, BLAISE_EXT_CompiledApp) or
     StrEqualNoCase(Ext, BLAISE_EXT_CompiledWebScript) then
    RunCompiledFile(FileName)
  else
    raise EBlaise.Create('Unrecognised file type');
end;

procedure TBlaise.ExecuteImmediateSource(const S: String);
begin
  ParseImmediateSource(S);
  ExecuteNode;
end;



end.
