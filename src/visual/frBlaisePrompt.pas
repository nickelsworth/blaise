unit frBlaisePrompt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, cBlaise;

type
  TframeBlaisePrompt = class(TFrame)
    ePrompt: TRichEdit;
    mPrompt: TPopupMenu;
    mPromptCut: TMenuItem;
    mPromptCopy: TMenuItem;
    mPromptPaste: TMenuItem;
    mPromptDelete: TMenuItem;
    mPromptSelectAll: TMenuItem;
    mPromptN1: TMenuItem;
    mPromptClear: TMenuItem;
    procedure ePromptKeyPress(Sender: TObject; var Key: Char);
    procedure mPromptPopup(Sender: TObject);
    procedure mPromptCutClick(Sender: TObject);
    procedure mPromptCopyClick(Sender: TObject);
    procedure mPromptPasteClick(Sender: TObject);
    procedure mPromptDeleteClick(Sender: TObject);
    procedure mPromptSelectAllClick(Sender: TObject);
    procedure mPromptClearClick(Sender: TObject);
  private
    FBlaise : TBlaise;

    procedure WriteText(const S: String);
    procedure WritePrompt;
    procedure ClearScreen;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;
    property  Blaise: TBlaise read FBlaise;
  end;

implementation

uses
  { Fundamentals }
  cUtils,
  cStrings,
  cWriters,

  { Blaise }
  cBlaiseConsts;

{$R *.dfm}

const
  BlaisePromptVersion = '1.0';
  Prompt = ':->';

{ TOutputWriter                                                                }
type
  TOutputWriter = class(AWriterEx)
  private
    FFrame : TframeBlaisePrompt;

  public
    constructor Create(const Frame: TframeBlaisePrompt);
    function  Write(const Buffer; const Size: Integer): Integer; override;
  end;

constructor TOutputWriter.Create(const Frame: TframeBlaisePrompt);
begin
  inherited Create;
  FFrame := Frame;
end;

function TOutputWriter.Write(const Buffer; const Size: Integer): Integer;
var S: String;
begin
  Result := Size;
  if Result <= 0 then
    exit;
  SetLength(S, Size);
  MoveMem(Buffer, Pointer(S)^, Size);
  FFrame.WriteText(S);
end;

{ TframeBlaisePrompt                                                           }
constructor TframeBlaisePrompt.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBlaise := TBlaise.Create;
end;

destructor TframeBlaisePrompt.Destroy;
begin
  FreeAndNil(FBlaise);
  inherited Destroy;
end;

procedure TframeBlaisePrompt.Init;
begin
  FBlaise.SetApplicationScope(nil, TOutputWriter.Create(self), nil);
  WriteText('Blaise Prompt ' + BlaisePromptVersion +
            ' - Blaise ' + BlaiseFullVersion + #13#10);
  WriteText(BlaiseCopyright + #13#10);
  WritePrompt;
end;

procedure TframeBlaisePrompt.WriteText(const S: String);
begin
  ePrompt.SelText := S;
  ePrompt.SelLength := 0;
end;

procedure TframeBlaisePrompt.WritePrompt;
begin
  WriteText(Prompt);
end;

procedure TframeBlaisePrompt.ClearScreen;
begin
  ePrompt.Text := '';
  WritePrompt;
end;

procedure TframeBlaisePrompt.ePromptKeyPress(Sender: TObject; var Key: Char);
var S    : String;
    I, J : Integer;
    T    : TBlaiseTreeType;
begin
  if Key = #12 then // Ctrl-L
    ClearScreen else
  if Key = #13 then // Return
    try try
      Key := #0;
      S := ePrompt.Text;
      J := ePrompt.SelStart;
      I := PosStrRevIdx(Prompt, S, J, True);
      WriteText(#13#10);
      if I > 0 then
        begin
          S := Trim(CopyRange(S, I + Length(Prompt), J), csWhiteSpace);
          if S <> '' then
            begin
              T := Blaise.RunImmediateSource(S);
              if T = btStatement then
                WriteText(#13#10);
              // Blaise.ExecuteImmediateSource(S);
            end;
        end;
    except
      on E: Exception do
        WriteText(#13#10'Error: ' + E.Message + #13#10);
    end;
    finally
      WritePrompt;
    end;
end;

procedure TframeBlaisePrompt.mPromptPopup(Sender: TObject);
var R : Boolean;
begin
  R := ePrompt.SelLength > 0;
  mPromptCut.Enabled := R;
  mPromptCopy.Enabled := R;
  mPromptDelete.Enabled := R;
end;

procedure TframeBlaisePrompt.mPromptCutClick(Sender: TObject);
begin
  ePrompt.CutToClipboard;
end;

procedure TframeBlaisePrompt.mPromptCopyClick(Sender: TObject);
begin
  ePrompt.CopyToClipboard;
end;

procedure TframeBlaisePrompt.mPromptPasteClick(Sender: TObject);
begin
  ePrompt.PasteFromClipboard;
end;

procedure TframeBlaisePrompt.mPromptDeleteClick(Sender: TObject);
begin
  ePrompt.SelText := '';
end;

procedure TframeBlaisePrompt.mPromptSelectAllClick(Sender: TObject);
begin
  ePrompt.SelectAll;
end;

procedure TframeBlaisePrompt.mPromptClearClick(Sender: TObject);
begin
  ClearScreen;
end;

end.
