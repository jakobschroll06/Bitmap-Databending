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
    SaveDialog1: TSaveDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemOpenImageClick(Sender: TObject);
    procedure MenuItemResetClick(Sender: TObject);
    procedure MenuItemSaveImageClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  OriginalFilePath: String;
  WorkingBMPPath : String;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItemOpenImageClick(Sender: TObject);
var
  TempBitmap: TBitmap;
begin
  OpenDialog1.Filter := 'BMP Images (*.bmp)|*.bmp';

  if OpenDialog1.Execute then
  begin
    // Store
    OriginalFilePath := OpenDialog1.FileName;
    WorkingBMPPath := ExtractFilePath(ParamStr(0)) + 'working.bmp';

    // Initialize
    TempBitmap := TBitmap.Create;
    try
      //Read
      TempBitmap.LoadFromFile(OriginalFilePath);

      //24-bit BMP structure
      TempBitmap.PixelFormat := pf24bit;

      //Save
      TempBitmap.SaveToFile(WorkingBMPPath);

      //Update
      Image1.Picture.LoadFromFile(WorkingBMPPath);

    finally
      //Clear
      TempBitmap.Free;
    end;
  end;
end;

procedure TForm1.MenuItemResetClick(Sender: TObject);
begin
  if WorkingBMPPath <> '' then
    Image1.Picture.LoadFromFile(WorkingBMPPath);
end;

procedure TForm1.MenuItemSaveImageClick(Sender: TObject);
var
TargetFile: String;
SourceStream, DestStream: TFileStream;
BMP_DataBend_Path: String;
begin
  if OriginalFilePath = '' then
  begin
    ShowMessage('There is no image to save yet.');
    Exit;
  end;

  BMP_DataBend_Path := ExtractFilePath(OriginalFilePath) + 'new.bmp';


  if not FileExists(BMP_DataBend_Path) then
  begin
    ShowMessage('Error, no filepath.');
    Exit;
  end;

  // 3. Set up the save file explorer parameters
  SaveDialog1.Title := 'Save Image As';
  SaveDialog1.Filter := 'BMP Images (*.bmp)|*.bmp';
  SaveDialog1.DefaultExt := 'bmp';


  if SaveDialog1.Execute then
  begin
    TargetFile := SaveDialog1.FileName;

    SourceStream := TFileStream.Create(BMP_DataBend_Path, fmOpenRead);
    try
      DestStream := TFileStream.Create(TargetFile, fmCreate);
      try
        DestStream.CopyFrom(SourceStream, SourceStream.Size);
      finally
        DestStream.Free;
      end;
    finally
      SourceStream.Free;
    end;

    ShowMessage('Saved successfully!');
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

  if OpenDialog1.FileName = '' then
  begin
    ShowMessage('Please load a BMP image from the File menu.');
    Exit;
  end;
  Intensity := TrackBar1.Position;


  ModValue := 20000 - (Intensity * 180);
  BurstSize := Intensity * 40;


  OutputPath := ExtractFilePath(OriginalFilePath) + 'new.bmp';


  InStream := TFileStream.Create(WorkingBMPPath, fmOpenRead);
  OutStream := TFileStream.Create(OutputPath, fmCreate);

  try
    InStream.Read(HeaderBuffer, 54);
    OutStream.Write(HeaderBuffer, 54);

    PixelDataSize := InStream.Size - 54;
    SetLength(PixelBuffer, PixelDataSize);
    InStream.Read(PixelBuffer[0], PixelDataSize);

    I := 0;
    while I < PixelDataSize - 3 do
    begin
      if (I mod ModValue < BurstSize) then
      begin
        //Swap Blue [I] and Red [I+2]
        CurrentByte := PixelBuffer[I];
        PixelBuffer[I] := PixelBuffer[I + 2];
        PixelBuffer[I + 1] := CurrentByte;

        //Green
        //if PixelBuffer[I + 1] < 155 then
        //  PixelBuffer[I + 1] := PixelBuffer[I + 1] + 1;
      end;

      Inc(I, 3);
    end;

    // 6. Write the glitched RAM buffer to disk
    OutStream.Write(PixelBuffer[0], PixelDataSize);
    SetLength(PixelBuffer, 0); // Clear dynamic array from memory

  finally
    // Always free stream resources to unlock the files!
    InStream.Free;
    OutStream.Free;
  end;

  // 7. Update the screen preview with the newly created glitched file
  Image1.Picture.LoadFromFile(OutputPath);

end;

end.

