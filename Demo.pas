program Demo;
{$TYPEDADDRESS ON}

uses
  Crt, Classes, SysUtils, DateUtils, Windows, Graphics, GraphType, IntfGraphics, LibRaw;

const
  raw1: PChar = '.\IMG_3367.cr2';
  tif1: PChar = '.\IMG_3367.tiff';
  bmp1: PChar = '.\IMG_3367.bmp';
  jpg1: PChar = '.\IMG_3367.jpg';

type
  logLevel = (error = 1, warning, info = 7, debug);   { this is enumeration in pascal }

  { Win32 API - OutputDebugStringA }
  procedure WriteDebug(Message: PChar); cdecl;  external 'kernel32' Name 'OutputDebugStringA';

var
  msg: string;
  handler, cameras: Pointer;
  err: LibRaw_errors;
  result: LongInt;
  imgParams: PImgParams;
  lensInfo: PLensInfo;
  imgOther: PImgOther;
  dt: TDateTime;
  img: PProcImg;
  imgData: array of Byte;
  raw: TRawImage;
  bmp: TLazIntfImage;
  li: SmallInt;

{ Az ún. callback függvény implemetációja.
  Ezt a függvényt a natív C kód fogja meghívni, NEM mi magunk.
  A callback függvény tipikus példa arra, mikor a natív kód hívja a Pascal kódot! }
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
  { Ez itt csak pár kísérleti próbálkozás. }
  WriteDebug('Hello from Lazarus!');
  Writeln('Console output codepage: ', GetTextCodePage(Output));
  Writeln('System codepage: ', DefaultSystemCodePage);
  SetTextCodePage(OutPut, CP_UTF8);

  { A LibRaw könyvtár inicializációja és a támogatott fényképezőgépek listájának lekérése. }
  handler := libraw_init(LibRaw_init_flags.LIBRAW_OPTIONS_NONE);
  WriteLn('Libraw version:    ' + libraw_version() + #10#13);
  WriteLn('Supported cameras: ' + IntToStr(libraw_cameraCount()));
  { A kameralistából mi csak az első 5-öt [0..4] íratjuk ki.
    Mivel a libraw_cameraList függvény egy szöveg tömbre mutató pointert ad vissza,
    a kezdő memóriacímhez hozzáadjuk az aktulis kameranév címét és kiíratjuk. }
  cameras := libraw_cameraList();
  for li := 0 to 4 do WriteLn('  ' + PChar((cameras + 8 * li)^));
  WriteLn(#10#13);

  { Képfeldolgozási beállítások: kimenet formátuma TIFF, auto világosítás, stb. }
  libraw_set_output_tif(handler, LibRaw_output_formats.TIFF);
  libraw_set_no_auto_bright(handler, 0);
  libraw_set_highlight(handler, LibRaw_highlight_mode.BLEND);
  libraw_set_output_bps(handler, LibRaw_output_bps.BPS8);
  libraw_set_output_color(handler, LibRaw_output_color.SRGB);

  { Az általunk definiált callback függvény beállítása. }
  libraw_set_progress_handler(handler, @ProgressCallback, nil);

  { Fájl megnyitása, kicsomagolása, feldolgozása és TIFF-be mentése. }
  err := libraw_open_file(handler, raw1);
  if (err <> LibRaw_errors.LIBRAW_SUCCESS) then begin
    { A legtöbb LibRaw függvény egy hibakóddal tér vissza, ami a művelet sikerességét jelzi.
      Ha a hibakód érteke NEM egyenlő a LIBRAW_SUCCESS konstanssal, akkor a művelet sikertlen volt.
      A libraw_strerror függvény segítségével kiíratható a hiba oka. }
    WriteLn('Open:            ' + libraw_strerror(err));
    libraw_close(handler);
    Write('Press any key...');
    ReadKey;
    Exit;
  end;

  { Fontos a megnyitás után meghívott függvények sorrendje, különben a programunk nem fog megfelelően működni!
    Példa: libraw_open_file -> libraw_unpack -> libraw_dcraw_process -> libraw_dcraw_ppm_tiff_writer }
  err := libraw_unpack(handler);
  WriteLn('Unpack function: ' + libraw_unpack_function_name(handler));
  err := libraw_dcraw_process(handler);
  err := libraw_dcraw_ppm_tiff_writer(handler, tif1);

  { Kamera információk lekérése is kiíratása. }
  imgParams := libraw_get_iparams(handler);
  WriteLn(#10#13'Make:        ' + imgParams^.make);
  WriteLn('Model:       ' + imgParams^.model);
  WriteStr(msg, imgParams^.maker_index);
  WriteLn('Maker index: ' + msg);
  WriteLn('RAW count:   ' + IntToStr(imgParams^.raw_count));
  WriteLn('Software:    ' + imgParams^.software);
  WriteLn('CDESC:       ' + imgParams^.cdesc + #10#13);

  { Objektív információk lekérése is kiíratása. }
  lensInfo := libraw_get_lensinfo(handler);
  WriteLn('Lens:        ' + lensInfo^.Lens);
  WriteLn('LensMake:    ' + lensInfo^.LensMake);
  WriteLn('LensSerial:  ' + lensInfo^.LensSerial);
  WriteLn('MinFocal:    ' + FloatToStr(lensInfo^.MinFocal) + 'mm');
  WriteLn('MaxFocal:    ' + FloatToStr(lensInfo^.MaxFocal) + 'mm' + #10#13);

  { Fénykép készítési információk lekérése és kiíratása. }
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

  { Nyers képadatok memóriába töltése. Hiba esetén kilépés.
    Ez a függvényhívás memóriát foglal le,
    amit a [libraw_dcraw_clear_mem] függvény meghívásával kell felszabadítani. }
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

  { Képadatok kiíratása, pl. szélesség, magasság, színmélység. }
  WriteLn('Width:    ' + IntToStr(img^.width));
  WriteLn('Height:   ' + IntToStr(img^.height));
  WriteStr(msg, img^.format);
  WriteLn('Format:   ' + msg);
  WriteLn('Colors:   ' + IntToStr(img^.colors));
  WriteLn('Bits:     ' + IntToStr(img^.bits));
  WriteLn('Size:     ' + IntToStr(img^.data_size));
  WriteLn('Checksum: ' + IntToStr(img^.width * img^.height * img^.colors * (img^.bits div 8)) + #10#13);

  { Nyers képadatok saját pufferbe másolása további feldolgozáshoz. }
  SetLength(imgData, img^.data_size);
  CopyMemory(@imgData[0], @img^.data, img^.data_size);

  { Nyers képadatok kimentésa Bitmap képfájlba.
    Megjegyzés: Nem működik rendesen, mert a Libraw által tárolt nyers adatok tömörítve vannak a memóriában.
    Bitmap formátumba való mentéshez valamiképp igazítani kell az adatokon, különben a kimentett kép hibás lesz.}
  raw.Init;
  raw.Description.Init_BPP24_R8G8B8_BIO_TTB(img^.width, img^.height);
  raw.Data := @imgData[0];
  bmp := TLazIntfImage.Create(0, 0);
  bmp.SetRawImage(raw, True);
  bmp.SaveToFile(bmp1);

  { A [libraw_dcraw_make_mem_image] függvény által lefoglalt memória felszabadítása. }
  libraw_dcraw_clear_mem(img);

  { Thumbnail JPEG file kinyerése és fájlba írása. }
  err := libraw_unpack_thumb(handler);
  err := libraw_dcraw_process(handler);
  err := libraw_dcraw_thumb_writer(handler, jpg1);

  { A libraw által használt erőforrások felszabadítása. }
  WriteLn('Cleaning up resources...' + #10#13);
  libraw_close(handler);
  Write('Press any key...');
  ReadKey;
end.
