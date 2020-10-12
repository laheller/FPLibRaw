program Demo;
{$mode Delphi}
{$TYPEDADDRESS ON}

uses
  Crt, Classes, SysUtils, DateUtils, StrUtils, Windows, Graphics, GraphType, IntfGraphics, Generics.Collections, LibRaw;

var
  msg: string;
  handler, cameras: Pointer;
  err: LibRaw_errors;
  result, stride: LongInt;
  imgParams: PImgParams;
  lensInfo: PLensInfo;
  imgOther: PImgOther;
  dt: TDateTime;
  img: PProcImg;
  imgData, padding, line: array of Byte;
  raw: TRawImage;
  bmp: TLazIntfImage;
  li: SmallInt;
  tmp: TList<Byte>;

{ Implementation of the callback function - native code will call this! }
function ProgressCallback(data: Pointer; state: LibRaw_progress; iter: LongInt; expected: LongInt): LongInt; cdecl;
var
  strState: string;
begin
  if (iter = 0) then
  begin
    strState := libraw_strprogress(state);
    WriteLn('Progress: ' + strState + ', expected ' + IntToStr(expected) + ' iterations');
  end;
  ProgressCallback := 0;
end;

begin
  if ParamCount < 1 then begin
    WriteLn('Usage: ');
    WriteLn('  ' + ParamStr(0) + ' <PathToRawFile>');
    ReadKey;
    Exit;
  end;

  if not FileExists(ParamStr(1)) then begin
    WriteLn('Raw file does not exist at: ' + ParamStr(1));
    ReadKey;
    Exit;
  end;

  { Initialize libraw. Enumerate supported cameras. }
  handler := libraw_init(LibRaw_init_flags.LIBRAW_OPTIONS_NONE);
  WriteLn('Libraw version:    ' + libraw_version() + #10#13);
  WriteLn('Supported cameras: ' + IntToStr(libraw_cameraCount()));

  { Display first 5 cameras }
  cameras := libraw_cameraList();
  for li := 0 to 4 do WriteLn('  ' + PChar((cameras + 8 * li)^));
  WriteLn(#10#13);

  { Processing settings: output to TIFF, auto brightness, etc. }
  libraw_set_output_tif(handler, LibRaw_output_formats.TIFF);
  libraw_set_no_auto_bright(handler, 0);
  libraw_set_highlight(handler, LibRaw_highlight_mode.BLEND);
  libraw_set_output_bps(handler, LibRaw_output_bps.BPS8);
  libraw_set_output_color(handler, LibRaw_output_color.SRGB);

  { Make our callback function available. }
  libraw_set_progress_handler(handler, @ProgressCallback, nil);

  { Open raw file, process it and save to TIFF. }
  err := libraw_open_file(handler, PChar(ParamStr(1)));
  if (err <> LibRaw_errors.LIBRAW_SUCCESS) then begin
    { Error handling in libraw. }
    WriteLn('Open:            ' + libraw_strerror(err));
    libraw_close(handler);
    Write('Press any key...');
    ReadKey;
    Exit;
  end;

  { After opening a raw file the order of called functions matters.
    Example: libraw_open_file -> libraw_unpack -> libraw_dcraw_process -> libraw_dcraw_ppm_tiff_writer }
  err := libraw_unpack(handler);
  WriteLn('Unpack function: ' + libraw_unpack_function_name(handler));
  err := libraw_dcraw_process(handler);
  err := libraw_dcraw_ppm_tiff_writer(handler, PChar(ChangeFileExt(ParamStr(1),'.tiff')));

  { Query and display camera information. }
  imgParams := libraw_get_iparams(handler);
  WriteLn(#10#13'Make:        ' + imgParams^.make);
  WriteLn('Model:       ' + imgParams^.model);
  WriteStr(msg, imgParams^.maker_index);
  WriteLn('Maker index: ' + msg);
  WriteLn('RAW count:   ' + IntToStr(imgParams^.raw_count));
  WriteLn('Software:    ' + imgParams^.software);
  WriteLn('CDESC:       ' + imgParams^.cdesc + #10#13);

  { Query and display lens information. }
  lensInfo := libraw_get_lensinfo(handler);
  WriteLn('Lens:        ' + lensInfo^.Lens);
  WriteLn('LensMake:    ' + lensInfo^.LensMake);
  WriteLn('LensSerial:  ' + lensInfo^.LensSerial);
  WriteLn('MinFocal:    ' + FloatToStr(lensInfo^.MinFocal) + 'mm');
  WriteLn('MaxFocal:    ' + FloatToStr(lensInfo^.MaxFocal) + 'mm' + #10#13);

  { Query and display shooting information. }
  imgOther := libraw_get_imgother(handler);
  WriteLn('ISO:         ' + FloatToStr(imgOther^.iso_speed));
  WriteLn('Shutter:     ' + FloatToStr(imgOther^.shutter) + 's');
  WriteLn('Aperture:    f/' + FloatToStr(imgOther^.aperture));
  WriteLn('FocalLength: ' + FloatToStr(imgOther^.focal_len) + 'mm');
  WriteLn('Artist:      ' + imgOther^.artist);
  WriteLn('Description: ' + imgOther^.desc);
  dt := UniversalTimeToLocal(EncodeDate(1970,1,1) + imgOther^.timestamp / 86400);
  msg := FormatDateTime('yyyy"-"mm"-"dd hh":"nn":"ss', dt);
  WriteLn('TimeStamp:   ' + msg + #10#13);

  { Load raw image data into an allocated memory buffer with error handling.
    Allocated memory can be released by calling [libraw_dcraw_clear_mem]. }
  result := 0;
  img := libraw_dcraw_make_mem_image(handler, result);
  if (result <> 0) then
  begin
       WriteLn('Make memory image: ' + strerror(result));
       libraw_close(handler);
       Write('Press any key...');
       ReadKey;
       Exit;
  end;

  { Display raw photo information. }
  WriteLn('Width:    ' + IntToStr(img^.width));
  WriteLn('Height:   ' + IntToStr(img^.height));
  WriteStr(msg, img^.format);
  WriteLn('Format:   ' + msg);
  WriteLn('Colors:   ' + IntToStr(img^.colors));
  WriteLn('Bits:     ' + IntToStr(img^.bits));
  WriteLn('Size:     ' + IntToStr(img^.data_size));
  WriteLn('Checksum: ' + IntToStr(img^.width * img^.height * img^.colors * (img^.bits div 8)) + #10#13);

  { Copy raw image data into a custom buffer for further processing. }
  SetLength(imgData, img^.data_size);
  CopyMemory(@imgData[0], @img^.data, img^.data_size);

  { Pad image rows with necessary bytes before saving to bitmap. }
  SetLength(padding, img^.width mod 4);
  stride := img^.width * img^.colors * (img^.bits div 8);
  SetLength(line, stride);
  tmp := TList<Byte>.Create;
  for li := 0 to img^.height - 1 do begin
    CopyMemory(@line[0], @imgData[stride * li], stride);
    tmp.AddRange(line);
    tmp.AddRange(padding);
  end;

  { Dump image data from processed custom buffer into a Windows Bitmap file. }
  raw.Init;
  raw.Description.Init_BPP24_R8G8B8_BIO_TTB(img^.width, img^.height);
  raw.Data := PByte(tmp.ToArray);
  bmp := TLazIntfImage.Create(0, 0);
  bmp.SetRawImage(raw, True);
  bmp.SaveToFile(ChangeFileExt(ParamStr(1),'.bmp'));
  tmp.Free;

  { Release memory allocated by [libraw_dcraw_make_mem_image] call. }
  libraw_dcraw_clear_mem(img);

  { Get thumbnail image from raw file and save to JPG. }
  err := libraw_unpack_thumb(handler);
  err := libraw_dcraw_process(handler);
  err := libraw_dcraw_thumb_writer(handler, PChar(ChangeFileExt(ParamStr(1),'.jpg')));

  { Release used libraw resources. }
  WriteLn('Cleaning up resources...' + #10#13);
  libraw_close(handler);
  Write('Press any key...');
  ReadKey;
end.
