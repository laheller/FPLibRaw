# FPLibRaw

FreePascal wrapper around [Libraw](https://github.com/LibRaw/LibRaw). It was written using [Lazarus IDE](https://www.lazarus-ide.org/) powered by FreePascal.
Wrapper unit *libraw.pas* includes pascal signatures for all external native methods from *libraw.dll*.

Try the demo console application *demo.pas* which demonstrates key libraw features, like:
- initialize library
- open raw file
- export raw file to TIFF
- export thumbnail from raw file to JPEG
- load raw data, process it and export to Windows bitmap
- error handling

# Demo project

To successfully build wrapper and demo application the following steps are needed:
- Download and install latest **64bit** version of Lazarus IDE (also installs FreePascal).
- Open *demo.lpi* project file in Lazarus (Ctrl+F11) and build (Shift+F9).
- The built executable *demo.exe* requires to have the included *libraw.dll* library in the same folder!
- Note: **64bit build** of the project is **required**, since the included *libraw.dll* is also a 64bit library! 

# Sample usage of wrapper

```pascal
program Sample;
uses Crt, Libraw;
var
	handler: Pointer;
	err: LibRaw_errors;
begin
	handler := libraw_init(LibRaw_init_flags.LIBRAW_OPTIONS_NONE);
	libraw_set_output_tif(handler, LibRaw_output_formats.TIFF);
	libraw_set_no_auto_bright(handler, 0);
	err := libraw_open_file(handler, 'C:\Temp\RawImage01.CR2');
	if (err <> LibRaw_errors.LIBRAW_SUCCESS) then begin
		WriteLn('Open:            ' + libraw_strerror(err));
		libraw_close(handler);
		Write('Press any key...');
		ReadKey;
		Exit;
	end;
	err := libraw_unpack(handler);
	libraw_dcraw_process(handler);
	libraw_dcraw_ppm_tiff_writer(handler, 'C:\Temp\ProcessedImage01.tiff');
	libraw_close(handler);
end.
```