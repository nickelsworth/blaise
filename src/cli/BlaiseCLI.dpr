{                                                                              }
{                      Blaise Command Line Interface v1.03                     }
{                                                                              }
{      This program is copyright © 2003 by David J Butler (david@e.co.za)      }
{                             All rights reserved.                             }
{                                                                              }
{                                                                              }
{ Revision history:                                                            }
{   08/04/2003  1.00  Initial version                                          }
{   15/04/2003  1.01  Switch to output re-formatted source.                    }
{                     Switch to output HTML of source code.                    }
{   30/05/2003  1.02  Support for units.                                       }
{   29/10/2003  1.03  Silent switch.                                           }
{                                                                              }

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IOCHECKS ON}
{$LONGSTRINGS ON}
{$BOOLEVAL OFF}
{$OPTIMIZATION ON}
{$IFDEF DEBUG}
  {$DEBUGINFO ON}
  {$OVERFLOWCHECKS ON}
  {$RANGECHECKS ON}
{$ELSE}
  {$DEBUGINFO OFF}
  {$OVERFLOWCHECKS OFF}
  {$RANGECHECKS OFF}
{$ENDIF}
{$IFDEF VER150}
  {$DEFINE DELPHI7_UP}
{$ENDIF}
{$IFDEF DELPHI7_UP}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

program BlaiseCLI;

uses
  SysUtils,
  Windows,
  cUtils in '..\..\..\..\Fundamentals3\Source\Utils\cUtils.pas',
  cStrings in '..\..\..\..\Fundamentals3\Source\Utils\cStrings.pas',
  cDateTime in '..\..\..\..\Fundamentals3\Source\Utils\cDateTime.pas',
  cRandom in '..\..\..\..\Fundamentals3\Source\Utils\cRandom.pas',
  cReaders in '..\..\..\..\Fundamentals3\Source\Streams\cReaders.pas',
  cWriters in '..\..\..\..\Fundamentals3\Source\Streams\cWriters.pas',
  cStreams in '..\..\..\..\Fundamentals3\Source\Streams\cStreams.pas',
  cUnicodeCodecs in '..\..\..\..\Fundamentals3\Source\Unicode\cUnicodeCodecs.pas',
  cUnicode in '..\..\..\..\Fundamentals3\Source\Unicode\cUnicode.pas',
  cDynLib in '..\..\..\..\Fundamentals3\Source\System\cDynLib.pas',
  cCallConventions in '..\..\..\..\Fundamentals3\Source\System\cCallConventions.pas',
  cWindows in '..\..\..\..\Fundamentals3\Source\System\cWindows.pas',
  cRegistry in '..\..\..\..\Fundamentals3\Source\System\cRegistry.pas',
  cThreads in '..\..\..\..\Fundamentals3\Source\System\cThreads.pas',
  cLog in '..\..\..\..\Fundamentals3\Source\System\cLog.pas',
  cFileUtils in '..\..\..\..\Fundamentals3\Source\System\cFileUtils.pas',
  cWinExecute in '..\..\..\..\Fundamentals3\Source\System\cWinExecute.pas',
  cMicroThreads in '..\..\..\..\Fundamentals3\Source\MicroThreads\cMicroThreads.pas',
  cTypes in '..\..\..\..\Fundamentals3\Source\DataStructs\cTypes.pas',
  cLinkedLists in '..\..\..\..\Fundamentals3\Source\DataStructs\cLinkedLists.pas',
  cArrays in '..\..\..\..\Fundamentals3\Source\DataStructs\cArrays.pas',
  cDictionaries in '..\..\..\..\Fundamentals3\Source\DataStructs\cDictionaries.pas',
  cMaths in '..\..\..\..\Fundamentals3\Source\Maths\cMaths.pas',
  cStatistics in '..\..\..\..\Fundamentals3\Source\Maths\cStatistics.pas',
  cVectors in '..\..\..\..\Fundamentals3\Source\Maths\cVectors.pas',
  cMatrix in '..\..\..\..\Fundamentals3\Source\Maths\cMatrix.pas',
  cRational in '..\..\..\..\Fundamentals3\Source\Maths\cRational.pas',
  cComplex in '..\..\..\..\Fundamentals3\Source\Maths\cComplex.pas',
  cInternetUtils in '..\..\..\..\Fundamentals3\Source\Internet\cInternetUtils.pas',
  cSocks in '..\..\..\..\Fundamentals3\Source\Sockets\cSocks.pas',
  cWinSock in '..\..\..\..\Fundamentals3\Source\Sockets\cWinSock.pas',
  cSockets in '..\..\..\..\Fundamentals3\Source\Sockets\cSockets.pas',
  cSocketHostLookup in '..\..\..\..\Fundamentals3\Source\Sockets\cSocketHostLookup.pas',
  cSocketsTCP in '..\..\..\..\Fundamentals3\Source\Sockets\cSocketsTCP.pas',
  cSocketsTCPClient in '..\..\..\..\Fundamentals3\Source\Sockets\cSocketsTCPClient.pas',
  cSocketsTCPServer in '..\..\..\..\Fundamentals3\Source\Sockets\cSocketsTCPServer.pas',
  cTCPStream in '..\..\..\..\Fundamentals3\Source\Sockets\cTCPStream.pas',
  cTCPClient in '..\..\..\..\Fundamentals3\Source\Sockets\cTCPClient.pas',
  cTCPServer in '..\..\..\..\Fundamentals3\Source\Sockets\cTCPServer.pas',
  cBlazeUtils in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeUtils.pas',
  cBlazeUtilsMessages in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeUtilsMessages.pas',
  cBlazeUtilsControlChannel in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeUtilsControlChannel.pas',
  cBlazeClasses in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeClasses.pas',
  cBlazeProfilesStd in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeProfilesStd.pas',
  cBlazeRPC in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeRPC.pas',
  cBlaiseConsts in '..\Units\cBlaiseConsts.pas',
  cBlaiseTypes in '..\Units\cBlaiseTypes.pas',
  cBlaiseStructsSimple in '..\Units\cBlaiseStructsSimple.pas',
  cBlaiseStructsCollections in '..\Units\cBlaiseStructsCollections.pas',
  cBlaiseStructs in '..\Units\cBlaiseStructs.pas',
  cBlaiseStructsObject in '..\Units\cBlaiseStructsObject.pas',
  cBlaiseStructsCode in '..\Units\cBlaiseStructsCode.pas',
  cBlaiseFuncs in '..\Units\cBlaiseFuncs.pas',
  cBlaiseVMTypes in '..\Units\cBlaiseVMTypes.pas',
  cBlaiseVMCompiler in '..\Units\cBlaiseVMCompiler.pas',
  cBlaiseVM in '..\Units\cBlaiseVM.pas',
  cBlaiseMachineTypes in '..\Units\cBlaiseMachineTypes.pas',
  cBlaiseMachineIdentifiers in '..\Units\cBlaiseMachineIdentifiers.pas',
  cBlaiseMachineExpressions in '..\Units\cBlaiseMachineExpressions.pas',
  cBlaiseMachineStatements in '..\Units\cBlaiseMachineStatements.pas',
  cBlaiseMachineCode in '..\Units\cBlaiseMachineCode.pas',
  cBlaiseMachineNameSpace in '..\Units\cBlaiseMachineNameSpace.pas',
  cBlaiseMachineStructs in '..\Units\cBlaiseMachineStructs.pas',
  cBlaiseMachine in '..\Units\cBlaiseMachine.pas',
  cDCUParser in '..\Units\cDCUParser.pas',
  cBlaiseMachineDCU in '..\Units\cBlaiseMachineDCU.pas',
  cBlaiseNameSpaceTypes in '..\Units\cBlaiseNameSpaceTypes.pas',
  cBlaiseNameSpaceRemote in '..\Units\cBlaiseNameSpaceRemote.pas',
  cBlaiseNameSpacePeer in '..\Units\cBlaiseNameSpacePeer.pas',
  cBlaiseNameSpaceTcp in '..\Units\cBlaiseNameSpaceTcp.pas',
  cBlaiseParserLexer in '..\Units\cBlaiseParserLexer.pas',
  cBlaiseParserNodes in '..\Units\cBlaiseParserNodes.pas',
  cBlaiseParserNodesExpr in '..\Units\cBlaiseParserNodesExpr.pas',
  cBlaiseParserNodesStmt in '..\Units\cBlaiseParserNodesStmt.pas',
  cBlaiseParserNodesDecl in '..\Units\cBlaiseParserNodesDecl.pas',
  cBlaiseParser in '..\Units\cBlaiseParser.pas',
  cBlaise in '..\Units\cBlaise.pas';

{ Self testing code                                                            }
{.DEFINE SELFTEST}
{$IFDEF SELFTEST}
{$R-,Q-}
{$HINTS OFF}
procedure SelfTest;
var B : TBlaise;
    I, P, K : Integer;
    T : THPTimer;
    S : String;
    H : LongWord;
    D : TObjectDictionary;
    Keys : StringArray;
    A : TObjectArray;
begin
  Writeln('Self test:');
  cUtils.SelfTest;
  cStrings.SelfTest;
  cDateTime.SelfTest;
  cReaders.SelfTest;
  cStreams.SelfTest;
  cUnicodeCodecs.SelfTest;
  cUnicode.SelfTest;
  cFileUtils.SelfTest;
  cArrays.SelfTest;
  cDictionaries.SelfTest;
  cMaths.SelfTest;
  cRational.SelfTest;
  cInternetUtils.SelfTest;

  T := StartTimer;
  S := 'X';
  P := $FF;
  K := Length(S);
  For I := 1 to 1000000 do
    H := HashStrBufNoCase(Pointer(S), K, 0) and LongWord(P);
  I := MillisecondsElapsed(T, True);
  Writeln('+ HashStrBufNoCase: ', Round((1000.0 / (I / 1000000)) / 100000) / 10:0:1, 'Mbs');

{  InitHashTable;
  T := StartTimer;
  S := 'X';
  P := $FF;
  K := Length(S);
  For I := 1 to 1000000 do
    H := HashNoCase($FFFFFFFF, Pointer(S)^, K) and LongWord(P);
  I := MillisecondsElapsed(T, True);
  Writeln('+ HashBuf: ', Round((1000.0 / (I / 1000000)) / 100000) / 10:0:1, 'Mbs'); }

  T := StartTimer;
  S := 'X';
  For I := 1 to 3000000 do
    StrEqualNoCase('X', 'X');
  I := MillisecondsElapsed(T, True);
  Writeln('+ StrEqualNoCase: ', Round((1000.0 / (I / 3000000)) / 100000) / 10:0:1, 'Mbs');

  T := StartTimer;
  S := 'X';
  For I := 1 to 10000000 do
    if S = 'Y' then ;
  I := MillisecondsElapsed(T, True);
  Writeln('+ Str=Str: ', Round((1000.0 / (I / 10000000)) / 100000) / 10:0:1, 'Mbs');

  A := TObjectArray.Create(nil, False);
  
  T := StartTimer;
  For I := 1 to 100000 do
    A.AppendItem(nil);
  I := MillisecondsElapsed(T, True);
  Writeln('+ ArrayAdd: ', Round((1000.0 / (I / 100000)) / 100000) / 10:0:1, 'MHz');

  T := StartTimer;
  For P := 1 to 15 do
    For I := 0 to 99999 do
      A.Item[I] := A;
  I := MillisecondsElapsed(T, True);
  Writeln('+ ArraySet: ', Round((1000.0 / (I / 1500000)) / 100000) / 10:0:1, 'MHz');

  T := StartTimer;
  For P := 1 to 15 do
    For I := 0 to 99999 do
      A.Item[I];
  I := MillisecondsElapsed(T, True);
  Writeln('+ ArrayGet: ', Round((1000.0 / (I / 1500000)) / 100000) / 10:0:1, 'MHz');

  A.Free;

  D := TObjectDictionary.CreateEx(nil, nil, False, False, True, ddAccept);
  SetLength(Keys, 10000);
  For I := 0 to 9999 do
    Keys[I] := 'X' + IntToStr(I);

  T := StartTimer;
  For I := 0 to 9999 do
    D.Add(Keys[I], nil);
  I := MillisecondsElapsed(T, True);
  Writeln('+ DictAdd: ', Round((1000.0 / (I / 10000)) / 100) / 10:0:1, 'KHz');

  T := StartTimer;
  For P := 1 to 15 do
    For I := 0 to 9999 do
      D.Item[Keys[I]];
//      D.FastGetItem(Keys[I]);
//      D.LocateKey(Keys[I], K, False);
  I := MillisecondsElapsed(T, True);
  Writeln('+ DictGet: ', Round((1000.0 / (I / 150000)) / 100000) / 10:0:1, 'MHz');
  D.Free;

  B := TBlaise.Create;
  B.SetApplicationScope(nil, nil, nil);

  B.SetCodeCompiled(DupChar(Char(BLAISE_VM_NOP), 5000000) +
      Char(BLAISE_VM_RET));
  B.Run;
  K := Round((1000.0 / B.GetRunTimeMs) * 5000000 / 1000);
  Writeln('+ Max VM speed: ', Round(K/100) / 10:0:1, 'Mhz');

  B.SetCodeCompiled(DupStr(Char(BLAISE_VM_PUSH_A) + Char(BLAISE_VM_POP),
      100000) + Char(BLAISE_VM_RET));
  B.Run;
  K := Round((1000.0 / B.GetRunTimeMs) * 200000 / 1000);
  Writeln('+ VM stack operations: ', Round(K/100) / 10:0:1, 'Mhz');

  B.Compiler.Clear;
  For I := 1 to 500000 do
    begin
      P := B.Compiler.Jump;
      B.Compiler.SetJumpPosition(P);
    end;
  B.Compiler.Return;
  B.SetCodeCompiled(B.Compiler.AsString);
  B.Run;
  K := Round((1000.0 / B.GetRunTimeMs) * 500000 / 1000);
  Writeln('+ VM jump operation: ', Round(K/100) / 10:0:1, 'Mhz');

  B.Compiler.Clear;
  B.Compiler.PushInteger(1);
  For I := 1 to 50000 do
    begin
      B.Compiler.LoadAFromStack0;
      B.Compiler.PushAccumulator;
      B.Compiler.AssignIdentifier('X');
    end;
  B.Compiler.Return;
  B.SetCodeCompiled(B.Compiler.AsString);
  B.Run;
  K := Round((1000.0 / B.GetRunTimeMs) * 50000 / 1000);
  Writeln('+ VM assign operation: ', Round(K/100) / 10:0:1, 'Mhz');

  B.Compiler.Clear;
  B.Compiler.PushInteger(1);
  B.Compiler.AssignIdentifier('X');
  For I := 1 to 50000 do
    B.Compiler.EvaluateUnique('X');
  B.Compiler.Return;
  B.SetCodeCompiled(B.Compiler.AsString);
  B.Run;
  K := Round((1000.0 / B.GetRunTimeMs) * 50000 / 1000);
  Writeln('+ VM evaluate unique operation: ', Round(K/100) / 10:0:1, 'Mhz');

  B.Compiler.Clear;
  For I := 1 to 50000 do
    B.Compiler.LoadUTF8('X');
  B.Compiler.Return;
  B.SetCodeCompiled(B.Compiler.AsString);
  B.Run;
  K := Round((1000.0 / B.GetRunTimeMs) * 50000 / 1000);
  Writeln('+ VM load utf8 operation: ', Round(K/100) / 10:0:1, 'Mhz');

  B.Free;
  Writeln;
end;
{$HINTS ON}
{$ENDIF}



{ Constants                                                                    }
const
  BlaiseCLIVersion = '1.03';



{ Parameters                                                                   }
type
  TRunMode = (
      rmDefault,
      rmRun,
      rmRunCompiled,
      rmExecute,
      rmLex,
      rmParse,
      rmReformat,
      rmGenHtml,
      rmCompile,
      rmHelp,
      rmAbout);
  TCommandLineSwitches = class
    FileName    : String;
    RunMode     : TRunMode;
    LexTokens   : Boolean;
    ShowSynTree : Boolean;
    Silent      : Boolean;

    procedure ApplyCommandLine;
  end;

var
  Switches : TCommandLineSwitches = nil;

procedure TCommandLineSwitches.ApplyCommandLine;
var I, L : Integer;
    S    : String;
begin
  // Default values
  FileName := '';
  RunMode := rmDefault;
  LexTokens := False;
  ShowSynTree := False;
  Silent := False;
  // Check command line parameters
  L := ParamCount;
  For I := 1 to L do
    begin
      S := ParamStr(I);
      if S <> '' then
        if S[1] = '-' then
          begin
            if StrEqualNoCase(S, '-lex') then
              RunMode := rmLex else
            if StrEqualNoCase(S, '-parse') then
              RunMode := rmParse else
            if StrEqualNoCase(S, '-reformat') then
              RunMode := rmReformat else
            if StrEqualNoCase(S, '-genhtml') then
              RunMode := rmGenHtml else
            if StrEqualNoCase(S, '-compile') then
              RunMode := rmCompile else
            if StrEqualNoCase(S, '-exec') then
              RunMode := rmExecute else
            if StrEqualNoCase(S, '-run') then
              RunMode := rmRun else
            if StrEqualNoCase(S, '-tokens') then
              LexTokens := True else
            if StrEqualNoCase(S, '-syntree') then
              ShowSynTree := True else
            if StrEqualNoCase(S, '-silent') then
              Silent := True else
            if StrEqualNoCase(S, '-help') then
              RunMode := rmHelp else
            if StrEqualNoCase(S, '-about') then
              RunMode := rmAbout;
          end
        else
          FileName := S;
    end;
  // Check switches
  if L = 0 then
    RunMode := rmHelp else
  if (RunMode in [rmDefault, rmRun, rmExecute, rmLex, rmParse, rmReformat,
      rmGenHtml, rmCompile]) and (FileName = '') then
    RunMode := rmHelp else
  if RunMode in [rmDefault, rmRun] then
    begin
      S := ExtractFileExt(FileName);
      if StrEqualNoCase(S, BLAISE_EXT_CompiledApp) then
        RunMode := rmRunCompiled;
    end;
end;



{ Source tree                                                                  }
function NodeDesc(const Node: TObject; const AbsPos: Integer): String;
var N : ABlaiseScriptNode;
    S : String;
begin
  Result := '-' + BlaiseNodeName(Node);
  if Node is ABlaiseScriptNode then
    begin
      N := ABlaiseScriptNode(Node);
      S := N.GetNodeParameterStr;
      if S <> '' then
        Result := Result + '(' + S + ')';
      Result := Result + ' [' + IntToStr(AbsPos + N.RelSourcePos) + ',' +
          IntToStr(N.SourceLen) + ']';
    end;
end;

procedure ShowTreeNode(const Node: TObject; const AbsPos, Level: Integer);
var P    : Integer;
    N, I : ABlaiseScriptNode;
begin
  Writeln(DupChar(' ', Level), NodeDesc(Node, AbsPos));
  if not Assigned(Node) then
    exit;
  if Node is ABlaiseScriptNode then
    begin
      N := ABlaiseScriptNode(Node);
      P := AbsPos + N.RelSourcePos;
      I := N.First;
      While Assigned(I) do
        begin
          ShowTreeNode(I, P, Level + 1);
          I := I.Next;
        end;
    end;
end;



{ ProcessFile                                                                  }
procedure ProcessFile(const FileName: String);
var Blaise : TBlaise;
    Node   : ABlaiseScriptNode;
    R      : Boolean;
    S      : String;
begin
  Node := nil;
  Blaise := TBlaise.Create;
  try
    Case Switches.RunMode of
      rmLex :
        begin
          Blaise.LoadSourceCode(FileName);
          Blaise.LexParsingInit;
          R := Switches.LexTokens;
          While not Blaise.Parser.EOF do
            begin
              Blaise.Parser.GetToken;
              if R then
                Writeln(PadRight('[' + LongWordToHex(Blaise.Parser.TokenType, 2) + ']',
                    ' ', 8) + ' ' +
                    StrHexEscape(CopyLeft(Blaise.Parser.TokenText, 16),
                    [#0..#31, #128..#255]));
            end;
          Blaise.LexParsingFin;
          if not R and not Switches.Silent then
            Writeln('Tokens parsed: ' + Blaise.GetLexTimeStr);
        end;
      rmDefault,
      rmParse,
      rmReformat,
      rmGenHtml,
      rmCompile,
      rmRun,
      rmExecute :
        begin
          try
            Node := Blaise.ParseSourceFile(FileName);
          except
            on E : EBlaiseScriptParser do
              raise Exception.Create(E.Message + #13#10 +
                    'Line ' + IntToStr(E.LineNr) + ' Col ' + IntToStr(E.Column) + #13#10 +
                    E.Parser.CurrentLine + #13#10 +
                    DupChar(' ', E.Column - 1) + '^');
          end;
          if not Switches.Silent then
            Writeln('Source parsed: ' + Blaise.GetParseTimeStr + ': ' +
                BlaiseNodeName(Node));
          if Switches.ShowSynTree then
            begin
              Writeln;
              Writeln('Syntactic tree:');
              ShowTreeNode(Node, 0, 0);
              Writeln('End of syntactic tree.');
            end;
        end;
    end;
    Case Switches.RunMode of
      rmReformat :
        begin
          S := ChangeFileExt(FileName, BLAISE_EXT_Reformat);
          WriteStrToFile(S, Blaise.GetNodeSource, fwomCreate);
          if not Switches.Silent then
            begin
              Writeln;
              Writeln('Output file: ' + S);
            end;
        end;
      rmGenHtml :
        begin
          S := ChangeFileExt(FileName, '.html');
          WriteStrToFile(S, Blaise.GetNodeSourceAsHtml, fwomCreate);
          if not Switches.Silent then
            begin
              Writeln;
              Writeln('Output file: ' + S);
            end;
        end;
      rmDefault,
      rmCompile :
        begin
          Case Blaise.CompileNode of
            btApp  : S := ChangeFileExt(FileName, BLAISE_EXT_CompiledApp);
            btUnit : S := ChangeFileExt(FileName, BLAISE_EXT_CompiledUnit);
          else
            raise Exception.Create('Not compilable');
          end;
          Blaise.SaveCompiledCode(S);
          if not Switches.Silent then
            begin
              Writeln;
              Writeln('Output file: ' + S);
            end;
        end;
    end;
    Case Switches.RunMode of
      rmDefault,
      rmRun,
      rmRunCompiled :
        begin
          if (Switches.RunMode <> rmDefault) or
             ((Switches.RunMode = rmDefault) and (Blaise.TreeType = btApp)) then
            begin
              Blaise.SetApplicationScope(nil, TOutputWriter.Create, nil);
              Case Switches.RunMode of
                rmDefault  : Blaise.Run;
                rmRun      : Blaise.RunNode;
              else
                Blaise.RunCompiledFile(FileName);
              end;
              if not Switches.Silent then
                begin
                  Writeln;
                  Writeln ('Execution complete: ' + Blaise.GetRunTimeStr);
                end;
            end;
        end;
      rmExecute :
        begin
          Assert(Assigned(Node), 'Assigned(Node)');
          if Node is TApplicationNode then
            begin
              Blaise.SetApplicationScope(nil, TOutputWriter.Create, nil);
              Blaise.ExecuteNode;
              if not Switches.Silent then
                begin
                  Writeln;
                  Writeln ('Execution complete: ' + Blaise.GetExecTimeStr);
                end;
            end
          else
            raise Exception.Create('Not executable');
        end;
    end;
  finally
    Blaise.Free;
  end;
end;



{ Help                                                                         }
procedure ShowHelp;
begin
  Writeln('Usage: Blaise [<switches>] <filename> [<switches>]');
  Writeln;
  Writeln('Switches:');
  Writeln('  -help      Display this information');
  Writeln('  -lex       Only do lexical parsing');
  Writeln('  -tokens    Display lexer tokens if used with -lex');
  Writeln('  -parse     Only do syntactic parsing');
  Writeln('  -reformat  Reformat the source code');
  Writeln('  -genhtml   Generate html of source code');
  Writeln('  -syntree   Display the syntactic tree');
//  Writeln('  -exec      Execute the tree');
  Writeln('  -compile   Generate compiled byte-code');
  Writeln('  -run       Run compiled byte-code');
  Writeln('  -silent    Silent mode');
  Writeln('  -about     About');
end;



{ Main                                                                         }
begin
  Switches := TCommandLineSwitches.Create;
  try
    Switches.ApplyCommandLine;
    if not Switches.Silent then
      begin
        Writeln('Blaise CLI ' + BlaiseCLIVersion +
                ' - Blaise ' + BlaiseFullVersion +
                ' - ' + BlaiseCopyright);
        Writeln;
      end;
    {$IFDEF SELFTEST}
    SelfTest;
    {$ENDIF}
    Case Switches.RunMode of
      rmHelp :
        begin
          ShowHelp;
          Halt(0);
        end;
      rmAbout :
        begin
          Writeln('Blaise v' + BlaiseFullVersion);
          Halt(0);
        end;
    else
      try
        ProcessFile(Switches.FileName);
      except
        on E : Exception do
          Writeln(#13#10'Error: ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(Switches);
  end;
  Writeln;
end.

