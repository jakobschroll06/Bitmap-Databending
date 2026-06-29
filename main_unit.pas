unit main_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItemEffects: TMenuItem;
    MenuItemOpenImage: TMenuItem;
    MenuItemSaveImage: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemReset: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemOpenImageClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItemOpenImageClick(Sender: TObject);
begin
  // Write a thing so it can work with image
     OpenDialog1.Filter := 'BMP Images (*.bmp)|*.bmp';
  if OpenDialog1.Execute then
  begin
    Image1.Picture.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TForm1.MenuItemExitClick(Sender: TObject);
begin
    Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  InStream, OutStream: TFileStream;

  HeaderBuffer: array[0..53] of Byte;
  PixelBuffer: array of Byte;
  PixelDataSize: Int64;
  I: Int64;
  CurrentByte: Byte;

  OutputPath: String;
  Intensity: Integer;
  ModValue, BurstSize: Integer;
begin
  // 1. Safety check: make sure a file was actually loaded first
  if OpenDialog1.FileName = '' then
  begin
    ShowMessage('Please load a BMP image from the File menu first!');
    Exit;
  end;


end;

end.

