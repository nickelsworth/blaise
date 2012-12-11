{                                                                              }
{                     Blaise name space base classes v0.01                     }
{                                                                              }
{        This unit is copyright © 2003 by David J Butler (david@e.co.za)       }
{                            All rights reserved.                              }
{                                                                              }
{                    This unit is part of Blaise Script.                       }
{             Its original file name is cBlaiseNameSpaceTypes.pas              }
{                                                                              }
{ Description:                                                                 }
{   This unit implements Blaise name space base classes.                       }
{                                                                              }
{ Revision history:                                                            }
{   28/04/2003  0.01  Initial version                                          }
{                                                                              }

{$INCLUDE cHeader.inc}
unit cBlaiseNameSpaceTypes;

interface

uses
  { Fundamentals }
  cUtils,

  { Blaise }
  cBlaiseTypes,
  cBlaiseStructsCollections;



{                                                                              }
{ ANameSpaceEx                                                                 }
{   Extended base class for name spaces.                                       }
{                                                                              }
type
  ANameSpaceDomainEx = class;
  ANameSpaceEx = class(ANameSpace)
  protected
    FDomain   : ANameSpaceDomain;
    FDomainEx : ANameSpaceDomainEx;
    FPath     : String;

    procedure Log(const LogMessage: String);

    function  ExtractStr(const Name: String; var Position: Integer;
              const StrDelim, NameDelim: CharSet): String;
    function  ExtractName(const Name: String; var Position: Integer;
              const NameDelim: Char): String;

  public
    property  Domain: ANameSpaceDomain read FDomain;
    property  DomainEx: ANameSpaceDomainEx read FDomainEx;
    property  Path: String read FPath;

    procedure Start(const Domain: ANameSpaceDomain; const Path: String); override;
  end;



{                                                                              }
{ ANameSpaceDomainEx                                                           }
{   Extended base class for name space domains.                                }
{                                                                              }
  ANameSpaceDomainEx = class(ANameSpaceDomain)
  protected
    procedure Log(const LogMessage: String); virtual;
  end;



{                                                                              }
{ ANameSpaceCollection                                                         }
{   Base class for a name space collections implemented using a dictionary.    }
{                                                                              }
type
  ANameSpaceCollection = class(ANameSpaceEx)
  protected
    FItems : TObjectDictionaryByString;

    procedure Add(const Key: String; const Value: TObject);

  public
    constructor Create;
    destructor Destroy; override;

    function  Exists(const Key: String): Boolean; override;
    function  GetItem(const Key: String): TObject; override;
    procedure SetItem(const Key: String; const Value: TObject); override;
    procedure Delete(const Key: String); override;
    function  Directory(const Key: String): TObject; override;
  end;



{                                                                              }
{ AServerNameSpace                                                             }
{   Base class for the name space of a server.                                 }
{                                                                              }
type
  AServerNameSpace = class(ANameSpaceCollection)
  public
    function  Accept(var Abort: Boolean): TObject; virtual; abstract;
  end;



implementation

uses
  { Fundamentals }
  cStrings,

  { Blaise }
  cBlaiseFuncs;



{                                                                              }
{ ANameSpaceEx                                                                 }
{                                                                              }
function ANameSpaceEx.ExtractStr(const Name: String; var Position: Integer;
    const StrDelim, NameDelim: CharSet): String;
var I : Integer;
    D : CharSet;
begin
  D := StrDelim;
  Union(D, NameDelim);
  I := PosChar(D, Name, Position);
  if I = 0 then
    begin
      Result := CopyFrom(Name, Position);
      Position := Length(Name) + 1;
    end
  else
    begin
      Result := CopyRange(Name, Position, I - 1);
      if Name[I] in StrDelim then
        Position := I + 1
      else
        Position := I;
    end;
end;

function ANameSpaceEx.ExtractName(const Name: String; var Position: Integer;
    const NameDelim: Char): String;
var D    : CharSet;
    I, J : Integer;
begin
  D := ['{'];
  Include(D, NameDelim);
  I := PosChar(D, Name, Position);
  if (I = 0) or (Name[I] <> '{') then
    Result := ''
  else
    begin
      J := StrFindClosingBracket(Name, I, '}');
      if J = 0 then
        raise ENameSpace.Create('Mismatched bracket }');
      Result := CopyRange(Name, I + 1, J - 1);
      Position := J + 1;
    end;
end;

procedure ANameSpaceEx.Log(const LogMessage: String);
begin
  if Assigned(FDomainEx) then
    FDomainEx.Log(LogMessage);
end;

procedure ANameSpaceEx.Start(const Domain: ANameSpaceDomain; const Path: String);
begin
  inherited Start(Domain, Path);
  FDomain := Domain;
  FPath := Path;
  if Domain is ANameSpaceDomainEx then
    FDomainEx := ANameSpaceDomainEx(Domain)
  else
    FDomainEx := nil;
end;



{                                                                              }
{ ANameSpaceDomainEx                                                           }
{                                                                              }
procedure ANameSpaceDomainEx.Log(const LogMessage: String);
begin
end;



{                                                                              }
{ ANameSpaceCollection                                                         }
{                                                                              }
constructor ANameSpaceCollection.Create;
begin
  inherited Create;
  FItems := TObjectDictionaryByString.Create;
  ObjectAddReference(FItems);
end;

destructor ANameSpaceCollection.Destroy;
begin
  ObjectReleaseReferenceAndNil(FItems);
  inherited Destroy;
end;

procedure ANameSpaceCollection.Add(const Key: String; const Value: TObject);
begin
  Assert(Assigned(Value));
  FItems.AddItemByString(Key, Value);
end;

function ANameSpaceCollection.Exists(const Key: String): Boolean;
begin
  if Key = '' then
    Result := True
  else
    Result := FItems.Dictionary.HasKey(Key);
end;

function ANameSpaceCollection.GetItem(const Key: String): TObject;
begin
  if Key = '' then
    Result := self
  else
    Result := FItems.Dictionary.Item[Key];
end;

procedure ANameSpaceCollection.SetItem(const Key: String; const Value: TObject);
begin
  raise ENameSpace.Create('Name space operation not supported: SetItem');
end;

procedure ANameSpaceCollection.Delete(const Key: String);
begin
  FItems.DeleteByString(Key);
end;

function ANameSpaceCollection.Directory(const Key: String): TObject;
begin
  Result := FItems;
end;


end.
