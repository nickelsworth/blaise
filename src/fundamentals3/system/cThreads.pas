{$INCLUDE ..\cDefines.inc}
unit cThreads;

interface

uses
  { Delphi }
  Classes;



{                                                                              }
{ TThreadEx                                                                    }
{   Extended base class for thread implementations.                            }
{                                                                              }
type
  TThreadEx = class(TThread)
  public
    // Make TThread's Synchronize method public
    procedure Synchronize(Method: TThreadMethod);

    // Make TThread's Terminate method virtual
    procedure Terminate; virtual;

    // Make Terminated property public
    property  Terminated;
  end;



{                                                                              }
{ TThreadComponent                                                             }
{   VCL component implementation of a thread.                                  }
{                                                                              }
type
  TThreadComponent = class;
  TThreadComponentExecuteEvent = procedure (Sender: TThreadComponent) of object;
  TThreadComponent = class(TComponent)
  protected
    FActive     : Boolean;
    FLoadActive : Boolean;
    FOnExecute  : TThreadComponentExecuteEvent;
    FThread     : TThreadEx;

    procedure Loaded; override;
    procedure SetActive(const Active: Boolean);
    function  GetTerminated: Boolean;
    procedure ThreadExecute; virtual;

  public
    destructor Destroy; override;

    property  Active: Boolean read FActive write SetActive default False;
    property  OnExecute: TThreadComponentExecuteEvent read FOnExecute write FOnExecute;

    property  Terminated: Boolean read GetTerminated;
    procedure Terminate;

    property  Thread: TThreadEx read FThread;
  end;

  { TfndThreadComponent                                                        }
  {   Published Thread component.                                              }
  TfndThreadComponent = class(TThreadComponent)
  published
    property  Active;
    property  OnExecute;
  end;



implementation

uses
  { Delphi }
  SysUtils;



{                                                                              }
{ TThreadEx                                                                    }
{                                                                              }
procedure TThreadEx.Synchronize(Method: TThreadMethod);
begin
  inherited Synchronize(Method);
end;

procedure TThreadEx.Terminate;
begin
  inherited Terminate;
end;



{                                                                              }
{ TThreadComponentThread                                                       }
{                                                                              }
type
  TThreadComponentThread = class(TThreadEx)
  protected
    FComponent : TThreadComponent;
    procedure Execute; override;
  public
    constructor Create(const Component: TThreadComponent);
  end;

constructor TThreadComponentThread.Create(const Component: TThreadComponent);
begin
  Assert(Assigned(Component));
  FComponent := Component;
  FreeOnTerminate := False;
  inherited Create(False);
end;

procedure TThreadComponentThread.Execute;
begin
  if Assigned(FComponent) then
    FComponent.ThreadExecute;
end;



{                                                                              }
{ TThreadComponent                                                             }
{                                                                              }
destructor TThreadComponent.Destroy;
begin
  FreeAndNil(FThread);
  inherited Destroy;
end;

procedure TThreadComponent.Loaded;
begin
  inherited Loaded;
  if FLoadActive then
    SetActive(True);
end;

procedure TThreadComponent.SetActive(const Active: Boolean);
begin
  if Active = FActive then
    exit;
  if csDesigning in ComponentState then
    exit;
  if csLoading in ComponentState then
    begin
      FLoadActive := True;
      exit;
    end;
  FActive := Active;
  if Active then
    begin
      FreeAndNil(FThread);
      FThread := TThreadComponentThread.Create(self);
    end
  else
    Terminate;
end;

function TThreadComponent.GetTerminated: Boolean;
begin
  Result := Assigned(FThread) and FThread.Terminated;
end;

procedure TThreadComponent.Terminate;
begin
  if Assigned(FThread) then
    try try
      FThread.Terminate;
      FThread.WaitFor;
    except end;
    finally
      FreeAndNil(FThread);
    end;
end;

procedure TThreadComponent.ThreadExecute;
begin
  try
    if Assigned(FOnExecute) then
      FOnExecute(self);
  finally
    FActive := False;
  end;
end;



end.

