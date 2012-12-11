unit fMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, frBlaisePrompt;

type
  TfrmMain = class(TForm)
    frameBlaisePrompt: TframeBlaisePrompt;
    procedure FormShow(Sender: TObject);
  protected
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ TfrmMain                                                                     }
procedure TfrmMain.FormShow(Sender: TObject);
begin
  frameBlaisePrompt.Init;
end;

end.
