{$INCLUDE ..\cDefines.inc}
unit cTCPStream;

{                                                                              }
{                           TCP Socket Stream v3.03                            }
{                                                                              }
{             This unit is copyright © 2001-2003 by David J Butler             }
{                                                                              }
{                  This unit is part of Delphi Fundamentals.                   }
{                Its original file name is cSocketClient.pas                   }
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
{   [ cSockets ]                                                               }
{   15/01/2001  0.01  Moved TSocketStream from cStreams into cSockets.         }
{   [ cTCPStream ]                                                             }
{   01/07/2002  3.02  Refactored for Fundamentals 3                            }
{   16/10/2003  3.03  Added OutBufferMaxSize property. If not -1 (default) the }
{                     Write methods can block until the outgoing buffer has    }
{                     space for data.                                          }
{                                                                              }

interface

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cUtils,
  cReaders,
  cWriters,
  cStreams,
  cSocketsTCP,
  cSocketsTCPClient;



{                                                                              }
{ TSocketStream                                                                }
{   Provides streaming functionality for a TCP socket.                         }
{   Can be used when blocking I/O is required on a TCP socket.                 }
{                                                                              }
const
  DefaultSocketStreamTimeOut = 5 * 60 * 1000; // Five minutes

type
  TSocketStream = class; // forward

  { TSocketReader                                                              }
  TSocketReader = class(AReaderEx)
  protected
    FStream    : TSocketStream;
    FBytesRead : Int64;

    function  GetPosition: Int64; override;
    procedure SetPosition(const Position: Int64); override;
    function  GetSize: Int64; override;

    function  WaitData(const Count: Integer): Boolean;

  public
    constructor Create(const Stream: TSocketStream);

    function  Read(var Buf; const Size: Integer): Integer; override;
    function  Connected: Boolean;
    function  EOF: Boolean; override;

    function  ReadAvailable: String;
    function  AvailableToRead: Integer;
    function  ReadToEOF: String;

    function  ReadByte: Byte; override;
    function  ReadStr(const Count: Integer): String; override;

    function  PeekByte: Byte; override;
    function  PeekStr(const Count: Integer): String; override;

    procedure Skip(const Count: Integer); override;

    function  Locate(const Ch: Char; const LocateNonMatch: Boolean = False;
              const MaxOffset: Integer = -1): Integer; override;
    function  Locate(const Ch: CharSet; const LocateNonMatch: Boolean = False;
              const MaxOffset: Integer = -1): Integer; override;
    function  LocateStr(const S: String; const MaxOffset: Integer = -1;
              const CaseSensitive: Boolean = True): Integer; override;

    function  MatchStr(const S: String; const CaseSensitive: Boolean = True): Boolean; override;
  end;

  { TSocketWriter                                                              }
  TSocketWriter = class(AWriterEx)
  protected
    FStream       : TSocketStream;
    FBytesWritten : Int64;

    function  GetPosition: Int64; override;
    procedure SetPosition(const Position: Int64); override;
    function  GetSize: Int64; override;
    procedure SetSize(const Size: Int64); override;
    function  WaitBufferSpace: Boolean;

  public
    constructor Create(const Stream: TSocketStream);

    function  Write(const Buf; const Size: Integer): Integer; override;
    procedure WriteStr(const S: String); override;
  end;

  { TSocketStreamMode                                                          }
  TSocketStreamMode = (
      smAsynchronous,          // Non-blocking
      smBlockWaitMessage,      // Block: Wait for messages
      smBlockProcessMessages,  // Block: ProcessMessages
      smBlockSleep,            // Block: Sleep short periods
      smBlockNotify);          // Block: Notifications

  { TSocketStream                                                              }
  TSocketStreamEvent = procedure (const Stream: TSocketStream) of object;
  TSocketStream = class(AStream)
  protected
    FSocket           : ATCPClientSocket;
    FTimeOut          : LongWord;
    FStreamMode       : TSocketStreamMode;
    FCloseOnDestroy   : Boolean;
    FSocketOwner      : Boolean;
    FOutBufferMaxSize : Integer;
    FOnBlockNotify    : TSocketStreamEvent;
    FReader           : TSocketReader;
    FWriter           : TSocketWriter;

    procedure Init;
    procedure RaiseError(const Msg: String);
    procedure InitSocket(const Socket: ATCPClientSocket;
              const StreamMode: TSocketStreamMode;
              const TimeOut: Integer;
              const OutBufferMaxSize: Integer);
    procedure InitNewSocket(const Host, Port: String;
              const Proxy: ATCPClientSocketProxy;
              const StreamMode: TSocketStreamMode;
              const TimeOut: LongWord; const OutBufferMaxSize: Integer;
              const InBufferMaxSize: Integer);
    function  DoWait: Boolean;

    function  GetReader: AReaderEx; override;
    function  GetWriter: AWriterEx; override;
    function  GetPosition: Int64; override;
    procedure SetPosition(const Position: Int64); override;
    function  GetSize: Int64; override;
    procedure SetSize(const Size: Int64); override;

  public
    constructor Create(const Socket: ATCPClientSocket;
                const SocketOwner: Boolean = True;
                const StreamMode: TSocketStreamMode = smBlockWaitMessage;
                const TimeOut: LongWord = DefaultSocketStreamTimeOut;
                const OutBufferMaxSize: Integer = -1);
    constructor CreateSocket(const Host, Port: String;
                const Proxy: ATCPClientSocketProxy = nil;
                const StreamMode: TSocketStreamMode = smBlockWaitMessage;
                const TimeOut: LongWord = DefaultSocketStreamTimeOut;
                const OutBufferMaxSize: Integer = -1;
                const InBufferMaxSize: Integer = -1);
    constructor CreateConnection(const Host, Port: String;
                const Proxy: ATCPClientSocketProxy = nil;
                const StreamMode: TSocketStreamMode = smBlockWaitMessage;
                const TimeOut: LongWord = DefaultSocketStreamTimeOut;
                const OutBufferMaxSize: Integer = -1;
                const InBufferMaxSize: Integer = -1);
    destructor Destroy; override;

    property  Socket: ATCPClientSocket read FSocket;
    property  SocketOwner: Boolean read FSocketOwner;
    property  CloseOnDestroy: Boolean read FCloseOnDestroy write FCloseOnDestroy;

    property  StreamMode: TSocketStreamMode read FStreamMode write FStreamMode;
    property  TimeOut: LongWord read FTimeOut write FTimeOut;
    property  OutBufferMaxSize: Integer read FOutBufferMaxSize write FOutBufferMaxSize;
    property  OnBlockNotify: TSocketStreamEvent read FOnBlockNotify write FOnBlockNotify;
    property  Reader: TSocketReader read FReader;
    property  Writer: TSocketWriter read FWriter;

    function  Wait: Boolean;
    procedure HandleMessage;
    procedure ProcessMessages;

    procedure Flush;
    procedure Close;
    function  Connected: Boolean;
    function  Connecting: Boolean;
    procedure ConnectSocket;

    function  Read(var Buf; const Size: Integer): Integer; override;
    function  Write(const Buf; const Size: Integer): Integer; override;
    function  EOF: Boolean; override;
  end;
  ESocketStream = class(Exception);



{                                                                              }
{ TunnelSocketStreams                                                          }
{                                                                              }
function  TunnelSocketStreams(const Stream1, Stream2: TSocketStream;
          const BlockSize: Integer = 0): Int64;



implementation

uses
  { Delphi }
  Windows,

  { Fundamentals }
  cSockets;



{                                                                              }
{ TunnelSocketStreams                                                          }
{                                                                              }
const
  DefaultBlockSize = 2048;

// Pre: Both socket handles were created in the same thread
// Post: Returns number of bytes 'tunnelled' either way
function TunnelSocketStreams(const Stream1, Stream2: TSocketStream;
    const BlockSize: Integer): Int64;
var I1, I2, L : Integer;
    T1, T2    : Int64;
    Buf       : Pointer;
    Aborted   : Boolean;
    M1, M2    : TSocketStreamMode;
begin
  if not Assigned(Stream1) or not Assigned(Stream2) then
    raise EStream.Create ('Invalid stream');
  L := BlockSize;
  if L <= 0 then
    L := DefaultBlockSize;
  T1 := 0;
  T2 := 0;
  Aborted := False;
  M1 := Stream1.StreamMode;
  M2 := Stream2.StreamMode;
  GetMem(Buf, L);
  try
    While not Stream1.EOF and not Stream2.EOF do
      begin
        // Read from Stream1 and Write to Stream2
        Stream1.StreamMode := smAsynchronous;
        I1 := Stream1.Read(Buf^, L);
        if I1 > 0 then
          begin
            Stream2.StreamMode := smBlockWaitMessage;
            Stream2.WriteBuffer(Buf^, I1);
            Inc(T1, I1);
            Stream1.TriggerCopyProgressEvent(Stream1, Stream2, T1, Aborted);
            if not Aborted then
              Stream2.TriggerCopyProgressEvent(Stream1, Stream2, T1, Aborted);
            if Aborted then
              raise EStreamOperationAborted.Create;
          end;

        // Read from Stream2 and Write to Stream1
        Stream2.StreamMode := smAsynchronous;
        I2 := Stream2.Read(Buf^, L);
        if I2 > 0 then
          begin
            Stream1.StreamMode := smBlockWaitMessage;
            Stream1.WriteBuffer(Buf^, I2);
            Inc(T2, I2);
            Stream1.TriggerCopyProgressEvent(Stream2, Stream1, T2, Aborted);
            if not Aborted then
              Stream2.TriggerCopyProgressEvent(Stream2, Stream1, T2, Aborted);
            if Aborted then
              raise EStreamOperationAborted.Create;
          end;

        // Wait if no data was available from either stream
        if (I1 = 0) and (I2 = 0) then
          begin
            Stream1.StreamMode := smBlockWaitMessage;
            Stream1.Wait;
          end;
      end;
  finally
    FreeMem(Buf);
    Stream1.StreamMode := M1;
    Stream2.StreamMode := M2;
  end;
  Result := T1 + T2;
end;



{                                                                              }
{ TSocketReader                                                                }
{                                                                              }
constructor TSocketReader.Create(const Stream: TSocketStream);
begin
  Assert(Assigned(Stream));
  inherited Create;
  FStream := Stream;
end;

function TSocketReader.GetPosition: Int64;
begin
  Result := FBytesRead;
end;

procedure TSocketReader.SetPosition(const Position: Int64);
var P : Int64;
begin
  P := GetPosition;
  if Position >= P then
    Skip(Position - P) else
    RaiseReadError('Seeking not supported');
end;

function TSocketReader.GetSize: Int64;
begin
  Result := -1;
end;

function TSocketReader.Connected: Boolean;
begin
  Result := not FStream.Socket.Terminated and
            ((FStream.Socket.State = ssConnected) or
             (FStream.Socket.InBufferSize > 0));
end;

function TSocketReader.EOF: Boolean;
begin
  Result := not Connected;
end;

function TSocketReader.ReadAvailable: String;
begin
  Result := FStream.Socket.ReadAvailable;
  Inc(FBytesRead, Length(Result));
end;

function TSocketReader.AvailableToRead: Integer;
begin
  Result := FStream.Socket.AvailableToRead;
end;

function TSocketReader.WaitData(const Count: Integer): Boolean;
var T : LongWord;
    M : Integer;
    R : Boolean;
begin
  Result := True;
  if FStream.FStreamMode = smAsynchronous then
    exit;
  if FStream.Socket.InBufferSize >= Count then
    exit;
  M := FStream.Socket.InBufferMaxSize;
  R := (M >= 0) and (Count > M);
  if R then
    FStream.Socket.InBufferMaxSize := Count;
  try
    T := GetTickCount;
    Repeat
      if not FStream.Wait then
        begin
          Result := False;
          exit;
        end;
      if FStream.Socket.InBufferSize >= Count then
        exit;
      if (FStream.FTimeOut > 0) and (GetTickCount - T > FStream.FTimeOut) then
        begin
          Result := False;
          exit;
        end;
    Until False;
  finally
    if R then
      FStream.Socket.InBufferMaxSize := M;
  end;
end;

function TSocketReader.ReadToEOF: String;
begin
  FStream.Socket.InBufferMaxSize := -1;
  While FStream.Socket.State = ssConnected do
    if not FStream.Wait then
      exit;
  Result := ReadAvailable;
end;

function TSocketReader.Read(var Buf; const Size: Integer): Integer;
begin
  if Size <= 0 then
    begin
      Result := 0;
      exit;
    end;
  if FStream.FStreamMode <> smAsynchronous then
    WaitData(Size);
  Result := FStream.Socket.Read(Buf, Size);
  if Result > 0 then
    Inc(FBytesRead, Result);
end;

function TSocketReader.ReadByte: Byte;
begin
  if Read(Result, 1) <> 1 then
    RaiseReadError;
end;

function TSocketReader.ReadStr(const Count: Integer): String;
begin
  if Count <= 0 then
    begin
      Result := '';
      exit;
    end;
  if (FStream.FStreamMode <> smAsynchronous) and not WaitData(Count) then
    RaiseReadError;
  Result := FStream.Socket.ReadStr(Count);
  Inc(FBytesRead, Count);
end;

function TSocketReader.PeekByte: Byte;
begin
  if (FStream.FStreamMode <> smAsynchronous) and not WaitData(1) then
    RaiseReadError;
  if FStream.Socket.Peek(Result, 1) <> 1 then
    RaiseReadError;
end;

function TSocketReader.PeekStr(const Count: Integer): String;
begin
  if Count <= 0 then
    begin
      Result := '';
      exit;
    end;
  if (FStream.FStreamMode <> smAsynchronous) and not WaitData(Count) then
    RaiseReadError;
  Result := FStream.Socket.PeekStr(Count);
end;

procedure TSocketReader.Skip(const Count: Integer);
begin
  if Count <= 0 then
    exit;
  if (FStream.FStreamMode <> smAsynchronous) and not WaitData(Count) then
    RaiseReadError;
  FStream.Socket.Skip(Count);
end;

function TSocketReader.MatchStr(const S: String; const CaseSensitive: Boolean): Boolean;
var L : Integer;
begin
  L := Length(S);
  if L = 0 then
    begin
      Result := False;
      exit;
    end;
  if (FStream.FStreamMode <> smAsynchronous) and not WaitData(L) then
    RaiseReadError;
  Result := FStream.Socket.MatchSequence(S, CaseSensitive);
end;

function TSocketReader.LocateStr(const S: String; const MaxOffset: Integer;
    const CaseSensitive: Boolean): Integer;
var I : Integer;
begin
  I := FStream.Socket.InBufferSize;
  Result := FStream.Socket.LocateSequence(S, CaseSensitive);
  if FStream.FStreamMode = smAsynchronous then
    exit;
  While (Result < 0) and not EOF and ((MaxOffset < 0) or (I <= MaxOffset)) do
    begin
      if not WaitData(I + 1) then
        break;
      I := FStream.Socket.InBufferSize;
      Result := FStream.Socket.LocateSequence(S, CaseSensitive);
      if Result >= 0 then
        break;
    end;
  if (Result >= 0) and (MaxOffset >= 0) and (Result > MaxOffset) then
    Result := -1;
end;

function TSocketReader.Locate(const Ch: Char; const LocateNonMatch: Boolean;
    const MaxOffset: Integer): Integer;
var I : Integer;
begin
  I := FStream.Socket.InBufferSize;
  Result := FStream.Socket.LocateChar(Ch, LocateNonMatch);
  if FStream.FStreamMode = smAsynchronous then
    exit;
  While (Result < 0) and not EOF and ((MaxOffset < 0) or (I <= MaxOffset)) do
    begin
      if not WaitData(I + 1) then
        break;
      I := FStream.Socket.InBufferSize;
      Result := FStream.Socket.LocateChar(Ch, LocateNonMatch);
      if Result >= 0 then
        break;
    end;
  if (Result >= 0) and (MaxOffset >= 0) and (Result > MaxOffset) then
    Result := -1;
end;

function TSocketReader.Locate(const Ch: CharSet; const LocateNonMatch: Boolean;
    const MaxOffset: Integer): Integer;
var I : Integer;
begin
  I := FStream.Socket.InBufferSize;
  Result := FStream.Socket.LocateChar(Ch, LocateNonMatch);
  if FStream.FStreamMode = smAsynchronous then
    exit;
  While (Result < 0) and not EOF and ((MaxOffset < 0) or (I <= MaxOffset)) do
    begin
      if not WaitData(I + 1) then
        break;
      I := FStream.Socket.InBufferSize;
      Result := FStream.Socket.LocateChar(Ch, LocateNonMatch);
      if Result >= 0 then
        break;
    end;
  if (Result >= 0) and (MaxOffset >= 0) and (Result > MaxOffset) then
    Result := -1;
end;



{                                                                              }
{ TSocketWriter                                                                }
{                                                                              }
constructor TSocketWriter.Create(const Stream: TSocketStream);
begin
  Assert(Assigned(Stream), 'Assigned(Stream)');
  inherited Create;
  FStream := Stream;
end;

function TSocketWriter.GetPosition: Int64;
begin
  Result := FBytesWritten;
end;

procedure TSocketWriter.SetPosition(const Position: Int64);
begin
  if Position = FBytesWritten then
    exit;
  raise EWriter.Create('SetPosition failed');
end;

function TSocketWriter.GetSize: Int64;
begin
  Result := -1
end;

procedure TSocketWriter.SetSize(const Size: Int64);
begin
  raise EWriter.Create('SetSize failed');
end;

function TSocketWriter.WaitBufferSpace: Boolean;
var T : LongWord;
    M : Integer;
    R : Boolean;
begin
  Result := True;
  if FStream.FStreamMode = smAsynchronous then
    exit;
  M := FStream.FOutBufferMaxSize;
  if M < 0 then
    exit;
  R := (M > 0) and FStream.Socket.UseSendBuffer;
  if (R and (FStream.Socket.OutBufferSize < M)) or
     (not R and FStream.Socket.IsSendFlushed) then
    exit;
  T := GetTickCount;
  Repeat
    if not FStream.Wait then
      begin
        Result := False;
        exit;
      end;
    if (R and (FStream.Socket.OutBufferSize < M)) or
       (not R and FStream.Socket.IsSendFlushed) then
      exit;
    if (FStream.FTimeOut > 0) and (GetTickCount - T > FStream.FTimeOut) then
      begin
        Result := False;
        exit;
      end;
  Until False;
end;

function TSocketWriter.Write(const Buf; const Size: Integer): Integer;
begin
  if (Size <= 0) or not WaitBufferSpace then
    Result := 0
  else
    begin
      Result := FStream.Socket.Send(Buf, Size);
      Inc(FBytesWritten, Result);
    end;
end;

procedure TSocketWriter.WriteStr(const S: String);
var L, M : Integer;
begin
  M := Length(S);
  if M = 0 then
    exit;
  if not WaitBufferSpace then
    RaiseWriteError; 
  L := FStream.Socket.SendStr(S);
  Inc(FBytesWritten, L);
  if L < M then
    RaiseWriteError;
end;



{                                                                              }
{ TSocketStream                                                                }
{                                                                              }
constructor TSocketStream.Create(const Socket: ATCPClientSocket;
    const SocketOwner: Boolean; const StreamMode: TSocketStreamMode;
    const TimeOut: LongWord; const OutBufferMaxSize: Integer);
begin
  inherited Create;
  InitSocket(Socket, StreamMode, TimeOut, OutBufferMaxSize);
  FSocketOwner := SocketOwner;
end;

constructor TSocketStream.CreateSocket(const Host, Port: String;
    const Proxy: ATCPClientSocketProxy;
    const StreamMode: TSocketStreamMode;
    const TimeOut: LongWord; const OutBufferMaxSize: Integer;
    const InBufferMaxSize: Integer);
begin
  inherited Create;
  InitNewSocket(Host, Port, Proxy, StreamMode, TimeOut, OutBufferMaxSize,
      InBufferMaxSize);
end;

constructor TSocketStream.CreateConnection(const Host, Port: String;
    const Proxy: ATCPClientSocketProxy; const StreamMode: TSocketStreamMode;
    const TimeOut: LongWord; const OutBufferMaxSize: Integer;
    const InBufferMaxSize: Integer);
begin
  inherited Create;
  InitNewSocket(Host, Port, Proxy, StreamMode, TimeOut, OutBufferMaxSize,
      InBufferMaxSize);
  ConnectSocket;
end;

destructor TSocketStream.Destroy;
begin
  FreeAndNil(FReader);
  FreeAndNil(FWriter);
  if FCloseOnDestroy and Assigned(FSocket) then
    FSocket.Close(False);
  if FSocketOwner then
    FreeAndNil(FSocket);
  inherited Destroy;
end;

procedure TSocketStream.RaiseError(const Msg: String);
begin
  raise ESocketStream.Create(Msg);
end;

procedure TSocketStream.Init;
begin
  FCloseOnDestroy := True;
  FSocketOwner := True;
end;

procedure TSocketStream.InitSocket(const Socket: ATCPClientSocket;
    const StreamMode: TSocketStreamMode; const TimeOut: Integer;
    const OutBufferMaxSize: Integer);
begin
  FSocket := Socket;
  FStreamMode := StreamMode;
  FTimeOut := TimeOut;
  FOutBufferMaxSize := OutBufferMaxSize;
  FReader := TSocketReader.Create(self);
  FWriter := TSocketWriter.Create(self);
end;

procedure TSocketStream.InitNewSocket(const Host, Port: String;
    const Proxy: ATCPClientSocketProxy;
    const StreamMode: TSocketStreamMode;
    const TimeOut: LongWord; const OutBufferMaxSize: Integer;
    const InBufferMaxSize: Integer);
begin
  InitSocket(TTCPClientSocket.Create(Host, Port, Proxy), StreamMode, TimeOut,
      OutBufferMaxSize);
  FSocketOwner := True;
  FSocket.InBufferMaxSize := InBufferMaxSize;
end;

function TSocketStream.DoWait: Boolean;
begin
  Result := Assigned(FSocket) and not FSocket.Terminated;
  if not Result then
    exit;
  if FStreamMode = smAsynchronous then
    exit;
  Case FStreamMode of
    smBlockWaitMessage :
      Result := FSocket.HandleMessage;
    smBlockProcessMessages :
      FSocket.ProcessMessages;
    smBlockSleep :
      Sleep(1);
    smBlockNotify :
      if Assigned(FOnBlockNotify) then
        FOnBlockNotify(self);
  end;
end;

procedure TSocketStream.HandleMessage;
begin
  if Assigned(FSocket) and not FSocket.Terminated then
    FSocket.HandleMessage;
end;

procedure TSocketStream.ProcessMessages;
begin
  if Assigned(FSocket) and not FSocket.Terminated then
    FSocket.ProcessMessages;
end;

function TSocketStream.Wait: Boolean;
begin
  Result := (FSocket.State = ssConnected) and DoWait;
end;

procedure TSocketStream.ConnectSocket;
var T : LongWord;
    C : TTCPClientSocket;
begin
  Assert(Assigned(FSocket), 'Assigned(Socket)');
  if FSocket.Connected or FSocket.Terminated then
    exit;
  C := FSocket as TTCPClientSocket;
  if not C.Connecting then
    C.Connect;
  if FStreamMode = smAsynchronous then
    exit;
  T := GetTickCount;
  While C.Connecting do
    if not DoWait then
      RaiseError('Connect terminated') else
      if (FTimeOut > 0) and (GetTickCount - T > FTimeOut) then
        RaiseError('Connect timed out');
  if Socket.State <> ssConnected then
    RaiseError('Connect failed: ' + Socket.ErrorMessage);
end;

function TSocketStream.Connecting: Boolean;
begin
  Result := Assigned(FSocket) and
            not FSocket.Terminated and
            (FSocket.State in [ssResolving, ssResolved, ssConnecting, ssNegotiating]);
end;

function TSocketStream.Connected: Boolean;
begin
  Result := Assigned(FSocket) and
            not FSocket.Terminated and
            ((FSocket.State = ssConnected) or (FSocket.InBufferSize > 0));
end;

procedure TSocketStream.Flush;
begin
  if FStreamMode = smAsynchronous then
    exit;
  While not FSocket.IsSendFlushed do
    if not Wait then
      exit;
end;

procedure TSocketStream.Close;
begin
  if Assigned(FSocket) then
    FSocket.Close(True);
  if FStreamMode = smAsynchronous then
    exit;
  While FSocket.State <> ssClosed do
    if not Wait then
      exit;
end;

function TSocketStream.GetReader: AReaderEx;
begin
  Assert(Assigned(FReader), 'Assigned(FReader)');
  Result := FReader;
end;

function TSocketStream.GetWriter: AWriterEx;
begin
  Assert(Assigned(FWriter), 'Assigned(FWriter)');
  Result := FWriter;
end;

function TSocketStream.GetPosition: Int64;
begin
  Assert(Assigned(FReader), 'Assigned(FReader)');
  Result := FReader.Position;
end;

procedure TSocketStream.SetPosition(const Position: Int64);
begin
  Assert(Assigned(FReader), 'Assigned(FReader)');
  FReader.Position := Position;
end;

function TSocketStream.GetSize: Int64;
begin
  Result := -1;
end;

procedure TSocketStream.SetSize(const Size: Int64);
begin
  raise ESocketStream.Create('SetSize failed');
end;

function TSocketStream.Read(var Buf; const Size: Integer): Integer;
begin
  Assert(Assigned(FReader), 'Assigned(FReader)');
  Result := FReader.Read(Buf, Size);
end;

function TSocketStream.Write(const Buf; const Size: Integer): Integer;
begin
  Assert(Assigned(FWriter), 'Assigned(FWriter)');
  Result := FWriter.Write(Buf, Size);
end;

function TSocketStream.EOF: Boolean;
begin
  Assert(Assigned(FReader), 'Assigned(FReader)');
  Result := FReader.EOF;
end;



end.

