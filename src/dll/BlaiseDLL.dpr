library BlaiseDLL;

uses
  SysUtils,
  cUtils in '..\..\..\..\Fundamentals3\Source\Utils\cUtils.pas',
  cStrings in '..\..\..\..\Fundamentals3\Source\Utils\cStrings.pas',
  cDateTime in '..\..\..\..\Fundamentals3\Source\Utils\cDateTime.pas',
  cRandom in '..\..\..\..\Fundamentals3\Source\Utils\cRandom.pas',
  cReaders in '..\..\..\..\Fundamentals3\Source\Streams\cReaders.pas',
  cWriters in '..\..\..\..\Fundamentals3\Source\Streams\cWriters.pas',
  cStreams in '..\..\..\..\Fundamentals3\Source\Streams\cStreams.pas',
  cUnicodeCodecs in '..\..\..\..\Fundamentals3\Source\Unicode\cUnicodeCodecs.pas',
  cUnicodeChar in '..\..\..\..\Fundamentals3\Source\Unicode\cUnicodeChar.pas',
  cUnicode in '..\..\..\..\Fundamentals3\Source\Unicode\cUnicode.pas',
  cFileUtils in '..\..\..\..\Fundamentals3\Source\System\cFileUtils.pas',
  cWindows in '..\..\..\..\Fundamentals3\Source\System\cWindows.pas',
  cRegistry in '..\..\..\..\Fundamentals3\Source\System\cRegistry.pas',
  cLog in '..\..\..\..\Fundamentals3\Source\System\cLog.pas',
  cThreads in '..\..\..\..\Fundamentals3\Source\System\cThreads.pas',
  cDynLib in '..\..\..\..\Fundamentals3\Source\System\cDynLib.pas',
  cCallConventions in '..\..\..\..\Fundamentals3\Source\System\cCallConventions.pas',
  cMicroThreads in '..\..\..\..\Fundamentals3\Source\MicroThreads\cMicroThreads.pas',
  cTypes in '..\..\..\..\Fundamentals3\Source\DataStructs\cTypes.pas',
  cLinkedLists in '..\..\..\..\Fundamentals3\Source\DataStructs\cLinkedLists.pas',
  cArrays in '..\..\..\..\Fundamentals3\Source\DataStructs\cArrays.pas',
  cDictionaries in '..\..\..\..\Fundamentals3\Source\DataStructs\cDictionaries.pas',
  cStatistics in '..\..\..\..\Fundamentals3\Source\Maths\cStatistics.pas',
  cMaths in '..\..\..\..\Fundamentals3\Source\Maths\cMaths.pas',
  cRational in '..\..\..\..\Fundamentals3\Source\Maths\cRational.pas',
  cComplex in '..\..\..\..\Fundamentals3\Source\Maths\cComplex.pas',
  cVectors in '..\..\..\..\Fundamentals3\Source\Maths\cVectors.pas',
  cMatrix in '..\..\..\..\Fundamentals3\Source\Maths\cMatrix.pas',
  cMaths3D in '..\..\..\..\Fundamentals3\Source\Maths\cMaths3D.pas',
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
  cBlazeProfilesStd in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeProfilesStd.pas',
  cBlazeClasses in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeClasses.pas',
  cBlazeRPC in '..\..\..\..\Fundamentals3\Source\BPP\cBlazeRPC.pas',
  cDCUParser in '..\Units\cDCUParser.pas',
  cBlaiseConsts in '..\Units\cBlaiseConsts.pas',
  cBlaiseTypes in '..\Units\cBlaiseTypes.pas',
  cBlaiseFuncs in '..\Units\cBlaiseFuncs.pas',
  cBlaiseStructs in '..\Units\cBlaiseStructs.pas',
  cBlaiseStructsSimple in '..\Units\cBlaiseStructsSimple.pas',
  cBlaiseStructsCollections in '..\Units\cBlaiseStructsCollections.pas',
  cBlaiseStructsObject in '..\Units\cBlaiseStructsObject.pas',
  cBlaiseStructsCode in '..\Units\cBlaiseStructsCode.pas',
  cBlaiseVMTypes in '..\Units\cBlaiseVMTypes.pas',
  cBlaiseVMCompiler in '..\Units\cBlaiseVMCompiler.pas',
  cBlaiseVM in '..\Units\cBlaiseVM.pas',
  cBlaiseMachineTypes in '..\Units\cBlaiseMachineTypes.pas',
  cBlaiseMachineNameSpace in '..\Units\cBlaiseMachineNameSpace.pas',
  cBlaiseMachineIdentifiers in '..\Units\cBlaiseMachineIdentifiers.pas',
  cBlaiseMachineExpressions in '..\Units\cBlaiseMachineExpressions.pas',
  cBlaiseMachineStatements in '..\Units\cBlaiseMachineStatements.pas',
  cBlaiseMachineCode in '..\Units\cBlaiseMachineCode.pas',
  cBlaiseMachineDCU in '..\Units\cBlaiseMachineDCU.pas',
  cBlaiseMachineStructs in '..\Units\cBlaiseMachineStructs.pas',
  cBlaiseMachine in '..\Units\cBlaiseMachine.pas',
  cBlaiseNameSpaceTypes in '..\Units\cBlaiseNameSpaceTypes.pas',
  cBlaiseNameSpaceTcp in '..\Units\cBlaiseNameSpaceTcp.pas',
  cBlaiseNameSpaceRemote in '..\Units\cBlaiseNameSpaceRemote.pas',
  cBlaiseNameSpacePeer in '..\Units\cBlaiseNameSpacePeer.pas',
  cBlaiseParserLexer in '..\Units\cBlaiseParserLexer.pas',
  cBlaiseParserNodes in '..\Units\cBlaiseParserNodes.pas',
  cBlaiseParserNodesExpr in '..\Units\cBlaiseParserNodesExpr.pas',
  cBlaiseParserNodesDecl in '..\Units\cBlaiseParserNodesDecl.pas',
  cBlaiseParserNodesStmt in '..\Units\cBlaiseParserNodesStmt.pas',
  cBlaiseParser in '..\Units\cBlaiseParser.pas',
  cBlaise in '..\Units\cBlaise.pas';

{$R *.res}



{ Constants                                                                    }
const
  BlaiseDLLReleaseInt   = 1;
  BlaiseDLLRelease      = '1';
  BlaiseDLLVersion      = BlaiseLanguageVersion + '.' +
                          BlaiseDLLRelease + '.' +
                          BlaiseParserVersion + '.' +
                          BlaiseMachineVersion;



{ Functions                                                                    }
function GetBlaiseLanguageVersion: PChar; stdcall;
begin
  Result := PChar(BlaiseLanguageVersion);
end;

function GetBlaiseDLLRelease: Integer; stdcall;
begin
  Result := BlaiseDLLReleaseInt;
end;

function GetBlaiseDLLVersion: PChar; stdcall;
begin
  Result := PChar(BlaiseDLLVersion);
end;

function ExecuteBlaiseScript(const Data: PChar; const DataSize: Integer): Integer; stdcall;
var S : AStatementNode;
    T : AStatement;
begin
  S := ParseBlaiseScriptStatement(Data, DataSize);
  T := S.GetAsStatement;
  T.Execute(nil);
  Result := 0;
end;



{ Export                                                                       }
exports
  GetBlaiseLanguageVersion,
  GetBlaiseDLLRelease,
  GetBlaiseDLLVersion,
  ExecuteBlaiseScript;



begin
end.

