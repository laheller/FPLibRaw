# FPLibRaw
&nbsp;
FreePascal wrapper around [Libraw](https://github.com/LibRaw/LibRaw). It was written using [Lazarus IDE](https://www.lazarus-ide.org/) powered by FreePascal.
Wrapper unit *libraw.pas* includes pascal signatures for all external native methods from *libraw.dll*.

Try the demo console application *demo.pas* which demonstrates key libraw features, like:
- initialize library
- open raw file
- export raw file to TIFF
- export thumbnail from raw file to JPEG
- load raw data, process it and export to Windows bitmap
- error handling
&nbsp;
# Demo project
&nbsp;
To successfully build wrapper and demo application the following steps are needed:
- Download and install latest Lazarus IDE (also installs FreePascal).
- Open *demo.lpi* project file in Lazarus (Ctrl+F11) and build (Shift+F9).
- The built executable *demo.exe* requires to have the included *libraw.dll* library in the same folder!
&nbsp;
# Sample usage of wrapper
&nbsp;
`program Sample;`
`uses Crt, Libraw;`
`var`
&emsp;`handler: Pointer;`
&emsp;`err: LibRaw_errors;`
`begin`
&emsp;`handler := libraw_init(LibRaw_init_flags.LIBRAW_OPTIONS_NONE);`
&emsp;`libraw_set_output_tif(handler, LibRaw_output_formats.TIFF);`
&emsp;`libraw_set_no_auto_bright(handler, 0);`
&emsp;`err := libraw_open_file(handler, 'C:\Temp\RawImage01.CR2');`
&emsp;`if (err <> LibRaw_errors.LIBRAW_SUCCESS) then begin`
&emsp;&emsp;`WriteLn('Open:            ' + libraw_strerror(err));`
&emsp;&emsp;`libraw_close(handler);`
&emsp;&emsp;`Write('Press any key...');`
&emsp;&emsp;`ReadKey;`
&emsp;&emsp;`Exit;`
&emsp;`end;`
&emsp;`err := libraw_unpack(handler);`
&emsp;`libraw_dcraw_process(handler);`
&emsp;`libraw_dcraw_ppm_tiff_writer(handler, 'C:\Temp\ProcessedImage01.tiff');`
&emsp;`libraw_close(handler);`
`end.`