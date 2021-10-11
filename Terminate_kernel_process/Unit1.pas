unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, SD.Kernel;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.Button1Click(Sender: TObject);
var
  ProcessHandle: THandle;
begin
{$IFDEF WIN64 }
  if SD_PsOpenProcess(PROCESS_TERMINATE, StrToIntDef(Edit1.Text, 0), ProcessHandle) = STATUS_SUCCESS then
    SD_ZwTerminateProcess(ProcessHandle, STATUS_SUCCESS);
{$ENDIF }
{$IFDEF WIN32 }
  SD_PsTerminateProcess(StrToIntDef(Edit1.Text, 0), STATUS_SUCCESS);
{$ENDIF }
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SD_InstallDriver(GetCurrentDir + '\kernel.sys');
  SD_StartDriver;
  SD_ConnectDriver;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SD_DisconnectDriver;
  SD_StopDriver;
  SD_UnInstallDriver;
end;

end.
