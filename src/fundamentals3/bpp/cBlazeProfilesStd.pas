{                                                                              }
{                Blaze Peering Protocol Standard Profiles v0.01                }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{ Description:                                                                 }
{   Standard profiles for the Blaze Peering Protocol (BPP).                    }
{                                                                              }
{ Revision history:                                                            }
{   01/08/2003  0.01  Initial version.                                         }
{                                                                              }

{$INCLUDE ..\cDefines.inc}
unit cBlazeProfilesStd;

interface

uses
  { Fundamentals }
  cThreads,

  { Blaze }
  cBlazeUtils,
  cBlazeUtilsMessages,
  cBlazeClasses;



{                                                                              }
{ Standard profiles                                                            }
{                                                                              }
const
  BPP_PROFILE_NULL = 'NULL';
  BPP_PROFILE_ECHO = 'ECHO';
  BPP_PROFILE_TIME = 'TIME';
  BPP_PROFILE_USER = 'USER';
  BPP_PROFILE_CHAT = 'CHAT';



{                                                                              }
{ TbppNullChannelProfile                                                       }
{                                                                              }
type
  TbppNullChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
    procedure HandleBroadcastMessage(const Channel: AbppChannel;
              const ChannelMask: String;
              const Header: TbppMessageHeader; const Payload: String); override;
  end;

  TbppNullChannel = class(AbppChannel)
  protected
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
  end;



{                                                                              }
{ TbppEchoChannelProfile                                                       }
{                                                                              }
type
  TbppEchoChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
  end;

  TbppEchoChannel = class(AbppChannel)
  protected
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
  end;



{                                                                              }
{ TbppDefaultChannelProfile                                                    }
{                                                                              }
type
  TbppDefaultChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
  end;

  TbppDefaultChannel = class(AbppChannel)
  protected
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
  end;



{                                                                              }
{ TbppTimeChannelProfile                                                       }
{                                                                              }
type
  TbppTimeChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
  end;

  TbppTimeChannel = class(AbppChannel)
  protected
    FThread : TThreadEx;

    procedure InitChannel(const ChannelType: TbppChannelType;
              const ChannelIndex: LongWord); override;
    procedure Execute;
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;

  public
    destructor Destroy; override;
  end;



{                                                                              }
{ TbppUserChannelProfile                                                       }
{                                                                              }
type
  TbppUserChannel = class(AbppChannel)
  protected
    FName : String;

    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;

  public
    constructor Create(const Profile: AbppProfile; const Name: String);
  end;

  TbppUserChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
    function  GetChannelByUserName(const Name: String): AbppChannel;
  end;



{                                                                              }
{ TbppChatChannelProfile                                                       }
{                                                                              }
type
  TbppChatChannel = class(AbppChannel)
  protected
    procedure HandleRequestMessage(const Header: TbppMessageHeader;
              const Payload: String); override;
  end;

  TbppChatChannelProfile = class(AbppProfile)
  protected
    function  CreateChannel(const Param: String;
              var InitParam: String): AbppChannel; override;
  end;



implementation

uses
  { Delphi }
  SysUtils,
  Classes,

  { Fundamentals }
  cUtils,
  cStrings;



{                                                                              }
{ TbppNullChannelProfile                                                       }
{                                                                              }
function TbppNullChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppNullChannel.Create(self);
end;

procedure TbppNullChannelProfile.HandleBroadcastMessage(const Channel: AbppChannel;
    const ChannelMask: String; const Header: TbppMessageHeader; const Payload: String);
begin
end;

procedure TbppNullChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  SendResponseMessage(Header, '', True);
end;



{                                                                              }
{ TbppEchoChannelProfile                                                       }
{                                                                              }
function TbppEchoChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppEchoChannel.Create(self);
end;

procedure TbppEchoChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  SendResponseMessage(Header, Payload, True);
end;



{                                                                              }
{ TbppDefaultChannelProfile                                                    }
{                                                                              }
function TbppDefaultChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppDefaultChannel.Create(self);
end;

procedure TbppDefaultChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  SendResponseMessage(Header, '', True);
end;



{                                                                              }
{ TbppTimeChannelProfile                                                       }
{                                                                              }
type
  TTimeThread = class(TThreadEx)
  protected
    FChannel : TbppTimeChannel;
    procedure Execute; override;
  public
    constructor Create(const Channel: TbppTimeChannel);
  end;

constructor TTimeThread.Create(const Channel: TbppTimeChannel);
begin
  FChannel := Channel;
  FreeOnTerminate := False;
  inherited Create(False);
end;

procedure TTimeThread.Execute;
begin
  FChannel.Execute;
end;

function TbppTimeChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppTimeChannel.Create(self);
end;

procedure TbppTimeChannel.InitChannel(const ChannelType: TbppChannelType;
    const ChannelIndex: LongWord);
begin
  inherited InitChannel(ChannelType, ChannelIndex);
  FThread := TTimeThread.Create(self);
end;

destructor TbppTimeChannel.Destroy;
begin
  if Assigned(FThread) then
    FThread.Terminate;
  FreeAndNil(FThread);
  inherited Destroy;
end;

procedure TbppTimeChannel.Execute;
var I : Integer;
begin
  Repeat
    I := 0;
    While I < 100 do
      begin
        if not Assigned(FThread) or FThread.Terminated then
          exit;
        Sleep(10);
        Inc(I);
      end;
    SendControlMessage(FormatDateTime('d mmm yyyy - hh:nn:ss', Now));
  Until False;
end;

procedure TbppTimeChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  SendResponseMessage(Header, FormatDateTime('d mmm yyyy - hh:nn:ss', Now), True);
end;



{                                                                              }
{ TbppUserChannelProfile                                                       }
{                                                                              }
function TbppUserChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppUserChannel.Create(self, Param);
end;

function TbppUserChannelProfile.GetChannelByUserName(const Name: String): AbppChannel;
var I : Integer;
begin
  For I := 0 to FChannels.ChannelCount - 1 do
    if TbppUserChannel(FChannels.GetChannelByIndex(I)).FName = Name then
      begin
        Result := FChannels.GetChannelByIndex(I);
        exit;
      end;
  Result := nil;
end;

constructor TbppUserChannel.Create(const Profile: AbppProfile; const Name: String);
begin
  inherited Create(Profile);
  FName := Name;
end;

procedure TbppUserChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
var S : StringArray;
    P : TbppUserChannelProfile;
    C : TbppUserChannel;
    I : Integer;
    T : String;
begin
  P := TbppUserChannelProfile(FProfile);
  S := StrSplit(Payload, ':');
  if (Length(S) >= 4) and (S[0] = 'NOTIFY') then
    begin
      C := TbppUserChannel(P.GetChannelByUserName(S[1]));
      if Assigned(C) then
        begin
          C.SendControlMessage(Payload);
          SendResponseMessage(Header, 'OK', True);
        end else
        SendResponseMessage(Header, 'ERROR:User name not found:' + S[1], False);
    end else
  if (Length(S) >= 1) and (S[0] = 'DIR') then
    begin
      T := '';
      For I := 0 to P.FChannels.ChannelCount - 1 do
        begin
          C := TbppUserChannel(P.FChannels.GetChannelByIndex(I));
          T := T + C.FName + #13#10;
        end;
      SendResponseMessage(Header, T, True);
    end
  else
    SendResponseMessage(Header, 'ERROR:Invalid message format', False);
end;



{                                                                              }
{ TbppChatChannelProfile                                                       }
{                                                                              }
function TbppChatChannelProfile.CreateChannel(const Param: String;
    var InitParam: String): AbppChannel;
begin
  Result := TbppChatChannel.Create(self);
end;

procedure TbppChatChannel.HandleRequestMessage(const Header: TbppMessageHeader;
    const Payload: String);
begin
  SendResponseMessage(Header, 'ERR: Not supported', False);
end;



end.

