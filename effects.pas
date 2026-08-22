unit effects;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

// Declare functions
procedure ApplyChannelSwap(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
procedure ApplyInvertBlock(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
procedure ApplyEchoSmear(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
procedure ApplyVaporwavePosterizer(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
procedure ApplyCRTScanlines(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);

implementation

procedure ApplyChannelSwap(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
var
  I: Int64;
  Temp: Byte;
  ModValue, BurstSize: Integer;
begin
  ModValue := 20000 - (Intensity * 180);
  BurstSize := Intensity * 40;

  I := 0;
  while I < DataSize - 3 do
  begin
    if (I mod ModValue < BurstSize) then
    begin
      Temp := PixelBuffer[I];       // Save Blue
      PixelBuffer[I] := PixelBuffer[I + 2]; // Move Red to Blue
      PixelBuffer[I + 2] := Temp;   // Move Blue to Red
    end;
    Inc(I, 3);
  end;
end;

procedure ApplyInvertBlock(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
var
  I: Int64;
  ModValue, BurstSize: Integer;
begin
  // Audacity-style raw inversion effect
  ModValue := 30000 - (Intensity * 250);
  BurstSize := Intensity * 80;

  I := 0;
  while I < DataSize - 1 do
  begin
    if (I mod ModValue < BurstSize) then
    begin
      PixelBuffer[I] := 255 - PixelBuffer[I]; // Flip the byte bits completely
    end;
    Inc(I, 1); //move 1 byte at a time
  end;
end;

procedure ApplyEchoSmear(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
var
  I: Int64;
  EchoOffset: Int64;
  ModValue, BurstSize: Integer;
begin
  // Calculate how far back into memory
  // Higher intensity = further back
  EchoOffset := Intensity * 1500;

  ModValue := 15000 - (Intensity * 120);
  BurstSize := Intensity * 20;

  // EchoOffset, don't look past index 0 (memory errors)
  I := EchoOffset;
  while I < DataSize do
  begin
    // Check if we are inside
    if (I mod ModValue < BurstSize) then
    begin
      // Copy the pixel data from 'EchoOffset' bytes
      PixelBuffer[I] := PixelBuffer[I - EchoOffset];
    end;

    Inc(I);
  end;
end;

procedure ApplyVaporwavePosterizer(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
var
  I: Int64;
  ShiftVal: Byte;
begin
  // Intensity controls the severity of the color bit mask
  ShiftVal := Intensity * 2;

  I := 0;
  while I < DataSize - 3 do
  begin
    // Blue Channel: Bitwise XOR creates sharp color boundaries
    PixelBuffer[I] := PixelBuffer[I] xor (ShiftVal and $C0);

    // Green Channel: Scale to push towards teal/cyan
    if PixelBuffer[I + 1] > 100 then
      PixelBuffer[I + 1] := Byte(PixelBuffer[I + 1] + (ShiftVal div 2));

    // Red Channel: Shift for warm contrast on highlights
    PixelBuffer[I + 2] := Byte(PixelBuffer[I + 2] xor $40);

    Inc(I, 3);
  end;
end;

procedure ApplyCRTScanlines(var PixelBuffer: array of Byte; DataSize: Int64; Intensity: Integer);
var
  I, Offset: Int64;
  DarkenFactor: Byte;
begin
  Offset := Intensity * 12; // Channel displacement distance
  DarkenFactor := 180 - (Intensity * 1); // Depth of scanline dark stripes

  I := Offset * 3;
  while I < DataSize - 3 do
  begin
    //Chromatic Edge Shift: Pull Blue channel from several pixels back
    PixelBuffer[I] := PixelBuffer[I - (Offset * 3)];

    // Scanline Grid: Darken every alternating 6-byte group
    if (I mod 12 < 6) then
    begin
      PixelBuffer[I]     := (PixelBuffer[I] * DarkenFactor) div 255;     // Blue
      PixelBuffer[I + 1] := (PixelBuffer[I + 1] * DarkenFactor) div 255; // Green
      PixelBuffer[I + 2] := (PixelBuffer[I + 2] * DarkenFactor) div 255; // Red
    end;

    Inc(I, 3);
  end;
end;

end.
