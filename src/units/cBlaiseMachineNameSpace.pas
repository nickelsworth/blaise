{                                                                              }
{                   Blaise name space implementations v0.03                    }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{            Its original file name is cBlaiseMachineNameSpace.pas             }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise name spaces.                                   }
{                                                                              }
{ Revision history:                                                            }
{   16/03/2003  0.01  Initial version.                                         }
{   17/03/2003  0.02  Added TFileNameSpace.                                    }
{   30/05/2003  0.03  Added GlobalRootNameSpace.                               }
{                                                                              }

{$INCLUDE cHeader.inc}
{$DEFINE NAMESPACE_FILE}
{$DEFINE NAMESPACE_TCP}
{$DEFINE NAMESPACE_TCPD}
{.DEFINE NAMESPACE_HTTP}
{.DEFINE NAMESPACE_HOST}
{.DEFINE NAMESPACE_SHARE}
unit cBlaiseMachineNameSpace;

interface

uses
  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseNameSpaceTypes,
  cBlaiseStructsCollections;



{                                                                              }
{ TRootNameSpace                                                               }
{                                                                              }
type
  TRootNameSpace = class(ANameSpaceCollection)
  protected
    procedure InitNameSpace(const Name: String; const NameSpace: ANameSpace);

  public
    constructor Create;

    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;

    procedure Start(const Domain: ANameSpaceDomain; const Path: String); override;
    procedure Stop; override;
  end;

function GetGlobalRootNameSpace: TRootNameSpace;



{$IFDEF NAMESPACE_FILE}
{                                                                              }
{ TFileNameSpace                                                               }
{                                                                              }
type
  TFileNameSpace = class(ANameSpaceEx)
  protected
    function  GetFile(const Key: String): TObject;
    function  KeyIsDirectory(const Key: String): Boolean;

  public
    function  GetNameSpace(const RootNameSpace: TObject; const Name: String;
              var Position: Integer): TObject; override;
    function  Exists(const Key: String): Boolean; override;
    function  GetItem(const Key: String): TObject; override;
    procedure SetItem(const Key: String; const Value: TObject); override;
    procedure Delete(const Key: String); override;
    function  Directory(const Key: String): TObject; override;
  end;
{$ENDIF}



implementation

uses
  { Delphi }
  SysUtils,

  { Fundamentals }
  cStrings,
  cDictionaries,

  {$IFDEF NAMESPACE_FILE}
  cFileUtils,
  cStreams,
  {$ENDIF}

  { Blaise }
  {$IFDEF NAMESPACE_TCP}   cBlaiseNameSpaceTcp, {$ELSE}
  {$IFDEF NAMESPACE_TCPD}  cBlaiseNameSpaceTcp, {$ENDIF}{$ENDIF}
  {$IFDEF NAMESPACE_HTTP}  cBlaiseNameSpaceHttp, {$ENDIF}
  {$IFDEF NAMESPACE_HOST}  cBlaiseNameSpacePeer, {$ELSE}
  {$IFDEF NAMESPACE_SHARE} cBlaiseNameSpacePeer, {$ENDIF}{$ENDIF}
  cBlaiseFuncs,
  cBlaiseStructs,
  cBlaiseStructsSimple;



{                                                                              }
{ TRootNameSpace                                                               }
{                                                                              }
constructor TRootNameSpace.Create;
begin
  inherited Create;
  {$IFDEF NAMESPACE_FILE}  InitNameSpace('file', TFileNameSpace.Create); {$ENDIF}
  {$IFDEF NAMESPACE_TCP}   InitNameSpace('tcp', TTcpNameSpace.Create); {$ENDIF}
  {$IFDEF NAMESPACE_TCPD}  InitNameSpace('tcpd', TTcpdNameSpace.Create); {$ENDIF}
  {$IFDEF NAMESPACE_HTTP}  InitNameSpace('http', THttpNameSpace.Create); {$ENDIF}
  {$IFDEF NAMESPACE_HOST}  InitNameSpace('host', THostNameSpace.Create); {$ENDIF}
  {$IFDEF NAMESPACE_SHARE} InitNameSpace('share', TShareNameSpace.Create); {$ENDIF}
end;

procedure TRootNameSpace.InitNameSpace(const Name: String;
    const NameSpace: ANameSpace);
begin
  FItems.ItemByString[Name] := NameSpace;
end;

function TRootNameSpace.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
var I   : Integer;
    Key : String;
begin
  I := PosChar(':', Name, Position);
  if I = 0 then
    begin
      Result := self;
      exit;
    end;
  Key := CopyRange(Name, Position, I - 1);
  Result := FItems.Dictionary.Item[Key];
  Position := I + 1;
end;

procedure TRootNameSpace.Start(const Domain: ANameSpaceDomain; const Path: String);
var I : Integer;
    D : TObjectDictionary;
    K : String;
begin
  inherited Start(Domain, Path);
  D := FItems.Dictionary;
  For I := 0 to D.Count - 1 do
    begin
      K := D.GetKeyByIndex(I);
      ANameSpace(D.GetItemByIndex(I)).Start(Domain,
          Path + K + ':');
      Log(K + ': started');
    end;
end;

procedure TRootNameSpace.Stop;
var I : Integer;
    D : TObjectDictionary;
begin
  D := FItems.Dictionary;
  For I := 0 to D.Count - 1 do
    ANameSpace(D.GetItemByIndex(I)).Stop;
end;

{ Global root name space                                                       }
var
  GlobalRootNameSpace: TRootNameSpace = nil;

function GetGlobalRootNameSpace: TRootNameSpace;
begin
  Result := GlobalRootNameSpace;
  if not Assigned(Result) then // Create on first access
    begin
      // Create
      Result := TRootNameSpace.Create;
      ObjectAddReference(Result);
      GlobalRootNameSpace := Result;
      // Start
      Result.Start(nil, '');
    end;
end;



{$IFDEF NAMESPACE_FILE}
{                                                                              }
{ TFileNameSpace                                                               }
{                                                                              }
function TFileNameSpace.GetFile(const Key: String): TObject;
begin
  Result := TTStream.Create(nil, TFileStream.Create(Key, fsomCreateOnWrite),
      True);
end;

function TFileNameSpace.KeyIsDirectory(const Key: String): Boolean;
begin
  Result := PathIsDirectory(Key) or
            DirEntryIsDirectory(Key);
end;

function TFileNameSpace.GetNameSpace(const RootNameSpace: TObject;
    const Name: String; var Position: Integer): TObject;
begin
  Result := self;
end;

function TFileNameSpace.Exists(const Key: String): Boolean;
begin
  Result := (Key = '') or
            PathIsDriveLetter(Key) or
            PathIsDriveRoot(Key) or
            (DirEntryGetAttr(Key) >= 0);
end;

function TFileNameSpace.GetItem(const Key: String): TObject;
begin
  if Key = '' then
    Result := self else
  if PathIsDriveLetter(Key) or PathIsDriveRoot(Key) or
     KeyIsDirectory(Key) then
    Result := Directory(Key)
  else
    Result := GetFile(Key);
end;

procedure TFileNameSpace.SetItem(const Key: String; const Value: TObject);
var F : TObject;
begin
  if (Key = '') or PathIsDriveLetter(Key) or PathIsDriveRoot(Key) or
     KeyIsDirectory(Key) then
    raise ENameSpace.Create('Not a file');
  F := GetFile(Key);
  try
    ObjectAssign(F, Value);
  finally
    ObjectReleaseUnreferenced(F);
  end;
end;

procedure TFileNameSpace.Delete(const Key: String);
begin
  if (Key = '') or PathIsDriveLetter(Key) or PathIsDriveRoot(Key) then
    raise ENameSpace.Create('Can not delete');
  if KeyIsDirectory(Key) then
    RmDir(Key) else
    if not DeleteFile(Key) then
      raise ENameSpace.Create('Delete failed');
end;

function TFileNameSpace.Directory(const Key: String): TObject;
var S : TSearchRec;
    D : TObjectDictionaryByString;
    A : TObjectDictionaryByString;
    P : String;
    I : Integer;
    L : Int64;
begin
  // FileNameSpace root directory
  if Key = '' then
    begin
      D := TObjectDictionaryByString.Create;
      try
        For I := 1 to 26 do
          begin
            L := DiskSize(I);
            if L >= 0 then
              begin
                A := TObjectDictionaryByString.Create;
                try
                  A['Size'] := TTInteger.Create(L);
                  A['Free'] := TTInteger.Create(DiskFree(I));
                except
                  A.Free;
                  raise;
                end;
                D[Char(Ord('A') + I - 1) + ':\'] := A;
              end;
          end;
      except
        D.Free;
        raise;
      end;
      Result := D;
      exit;
    end;
  // File system directory
  if not PathIsDriveLetter(Key) and
     not PathIsDriveRoot(Key) and
     not DirEntryIsDirectory(Key) then
    raise ENameSpace.Create('Directory not found');
  P := DirectoryExpand(Key);
  D := TObjectDictionaryByString.Create;
  try
    if FindFirst(P + '*.*', faAnyFile, S) = 0 then
      try
        Repeat
          if (S.Name <> '.') and (S.Name <> '..') then
            begin
              A := TObjectDictionaryByString.Create;
              try
                A['Size'] := TTInteger.Create(S.Size);
                A['Attr'] := GetImmutableInteger(S.Attr);
                A['Time'] := TTDateTime.Create(FileDateToDateTime(S.Time));
              except
                A.Free;
                raise;
              end;
              D[S.Name] := A;
            end;
        Until FindNext(S) <> 0;
      finally
        FindClose(S);
      end;
  except
    D.Free;
    raise;
  end;
  Result := D;
end;
{$ENDIF}



initialization
finalization
  ObjectReleaseReferenceAndNil(GlobalRootNameSpace);
end.

