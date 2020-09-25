unit LibRaw;
{$TYPEDADDRESS ON}
{$mode objfpc}{$H+}

interface

uses Crt, Classes, SysUtils;

const
  LibraryName = 'libraw';

type
  { LibRaw - enumerations }
  LibRaw_init_flags = (
    LIBRAW_OPTIONS_NONE = 0,
    LIBRAW_OPIONS_NO_MEMERR_CALLBACK = 1,
    LIBRAW_OPIONS_NO_DATAERR_CALLBACK = 1 shl 1
  );

  LibRaw_errors = (
    LIBRAW_SUCCESS = 0,
    LIBRAW_UNSPECIFIED_ERROR = -1,
    LIBRAW_FILE_UNSUPPORTED = -2,
    LIBRAW_REQUEST_FOR_NONEXISTENT_IMAGE = -3,
    LIBRAW_OUT_OF_ORDER_CALL = -4,
    LIBRAW_NO_THUMBNAIL = -5,
    LIBRAW_UNSUPPORTED_THUMBNAIL = -6,
    LIBRAW_INPUT_CLOSED = -7,
    LIBRAW_NOT_IMPLEMENTED = -8,
    LIBRAW_UNSUFFICIENT_MEMORY = -100007,
    LIBRAW_DATA_ERROR = -100008,
    LIBRAW_IO_ERROR = -100009,
    LIBRAW_CANCELLED_BY_CALLBACK = -100010,
    LIBRAW_BAD_CROP = -100011,
    LIBRAW_TOO_BIG = -100012,
    LIBRAW_MEMPOOL_OVERFLOW = -100013
  );

  LibRaw_output_formats = (
    PPM = 0,
    TIFF = 1
  );

  LibRaw_progress = (
    LIBRAW_PROGRESS_START = 0,
    LIBRAW_PROGRESS_OPEN = 1,
    LIBRAW_PROGRESS_IDENTIFY = 1 shl 1,
    LIBRAW_PROGRESS_SIZE_ADJUST = 1 shl 2,
    LIBRAW_PROGRESS_LOAD_RAW = 1 shl 3,
    LIBRAW_PROGRESS_RAW2_IMAGE = 1 shl 4,
    LIBRAW_PROGRESS_REMOVE_ZEROES = 1 shl 5,
    LIBRAW_PROGRESS_BAD_PIXELS = 1 shl 6,
    LIBRAW_PROGRESS_DARK_FRAME = 1 shl 7,
    LIBRAW_PROGRESS_FOVEON_INTERPOLATE = 1 shl 8,
    LIBRAW_PROGRESS_SCALE_COLORS = 1 shl 9,
    LIBRAW_PROGRESS_PRE_INTERPOLATE = 1 shl 10,
    LIBRAW_PROGRESS_INTERPOLATE = 1 shl 11,
    LIBRAW_PROGRESS_MIX_GREEN = 1 shl 12,
    LIBRAW_PROGRESS_MEDIAN_FILTER = 1 shl 13,
    LIBRAW_PROGRESS_HIGHLIGHTS = 1 shl 14,
    LIBRAW_PROGRESS_FUJI_ROTATE = 1 shl 15,
    LIBRAW_PROGRESS_FLIP = 1 shl 16,
    LIBRAW_PROGRESS_APPLY_PROFILE = 1 shl 17,
    LIBRAW_PROGRESS_CONVERT_RGB = 1 shl 18,
    LIBRAW_PROGRESS_STRETCH = 1 shl 19,
    LIBRAW_PROGRESS_STAGE20 = 1 shl 20,
    LIBRAW_PROGRESS_STAGE21 = 1 shl 21,
    LIBRAW_PROGRESS_STAGE22 = 1 shl 22,
    LIBRAW_PROGRESS_STAGE23 = 1 shl 23,
    LIBRAW_PROGRESS_STAGE24 = 1 shl 24,
    LIBRAW_PROGRESS_STAGE25 = 1 shl 25,
    LIBRAW_PROGRESS_STAGE26 = 1 shl 26,
    LIBRAW_PROGRESS_STAGE27 = 1 shl 27,
    LIBRAW_PROGRESS_THUMB_LOAD = 1 shl 28,
    LIBRAW_PROGRESS_TRESERVED1 = 1 shl 29,
    LIBRAW_PROGRESS_TRESERVED2 = 1 shl 30
  );

  LibRaw_image_formats = (
    LIBRAW_IMAGE_JPEG = 1,
    LIBRAW_IMAGE_BITMAP = 2
  );

  LibRaw_cameramaker_index = (
    LIBRAW_CAMERAMAKER_Unknown = 0,
    LIBRAW_CAMERAMAKER_Agfa,
    LIBRAW_CAMERAMAKER_Alcatel,
    LIBRAW_CAMERAMAKER_Apple,
    LIBRAW_CAMERAMAKER_Aptina,
    LIBRAW_CAMERAMAKER_AVT,
    LIBRAW_CAMERAMAKER_Baumer,
    LIBRAW_CAMERAMAKER_Broadcom,
    LIBRAW_CAMERAMAKER_Canon,
    LIBRAW_CAMERAMAKER_Casio,
    LIBRAW_CAMERAMAKER_CINE,
    LIBRAW_CAMERAMAKER_Clauss,
    LIBRAW_CAMERAMAKER_Contax,
    LIBRAW_CAMERAMAKER_Creative,
    LIBRAW_CAMERAMAKER_DJI,
    LIBRAW_CAMERAMAKER_DXO,
    LIBRAW_CAMERAMAKER_Epson,
    LIBRAW_CAMERAMAKER_Foculus,
    LIBRAW_CAMERAMAKER_Fujifilm,
    LIBRAW_CAMERAMAKER_Generic,
    LIBRAW_CAMERAMAKER_Gione,
    LIBRAW_CAMERAMAKER_GITUP,
    LIBRAW_CAMERAMAKER_Google,
    LIBRAW_CAMERAMAKER_GoPro,
    LIBRAW_CAMERAMAKER_Hasselblad,
    LIBRAW_CAMERAMAKER_HTC,
    LIBRAW_CAMERAMAKER_I_Mobile,
    LIBRAW_CAMERAMAKER_Imacon,
    LIBRAW_CAMERAMAKER_JK_Imaging,
    LIBRAW_CAMERAMAKER_Kodak,
    LIBRAW_CAMERAMAKER_Konica,
    LIBRAW_CAMERAMAKER_Leaf,
    LIBRAW_CAMERAMAKER_Leica,
    LIBRAW_CAMERAMAKER_Lenovo,
    LIBRAW_CAMERAMAKER_LG,
    LIBRAW_CAMERAMAKER_Logitech,
    LIBRAW_CAMERAMAKER_Mamiya,
    LIBRAW_CAMERAMAKER_Matrix,
    LIBRAW_CAMERAMAKER_Meizu,
    LIBRAW_CAMERAMAKER_Micron,
    LIBRAW_CAMERAMAKER_Minolta,
    LIBRAW_CAMERAMAKER_Motorola,
    LIBRAW_CAMERAMAKER_NGM,
    LIBRAW_CAMERAMAKER_Nikon,
    LIBRAW_CAMERAMAKER_Nokia,
    LIBRAW_CAMERAMAKER_Olympus,
    LIBRAW_CAMERAMAKER_OmniVison,
    LIBRAW_CAMERAMAKER_Panasonic,
    LIBRAW_CAMERAMAKER_Parrot,
    LIBRAW_CAMERAMAKER_Pentax,
    LIBRAW_CAMERAMAKER_PhaseOne,
    LIBRAW_CAMERAMAKER_PhotoControl,
    LIBRAW_CAMERAMAKER_Photron,
    LIBRAW_CAMERAMAKER_Pixelink,
    LIBRAW_CAMERAMAKER_Polaroid,
    LIBRAW_CAMERAMAKER_RED,
    LIBRAW_CAMERAMAKER_Ricoh,
    LIBRAW_CAMERAMAKER_Rollei,
    LIBRAW_CAMERAMAKER_RoverShot,
    LIBRAW_CAMERAMAKER_Samsung,
    LIBRAW_CAMERAMAKER_Sigma,
    LIBRAW_CAMERAMAKER_Sinar,
    LIBRAW_CAMERAMAKER_SMaL,
    LIBRAW_CAMERAMAKER_Sony,
    LIBRAW_CAMERAMAKER_ST_Micro,
    LIBRAW_CAMERAMAKER_THL,
    LIBRAW_CAMERAMAKER_VLUU,
    LIBRAW_CAMERAMAKER_Xiaomi,
    LIBRAW_CAMERAMAKER_XIAOYI,
    LIBRAW_CAMERAMAKER_YI,
    LIBRAW_CAMERAMAKER_Yuneec,
    LIBRAW_CAMERAMAKER_Zeiss,
    // Insert additional indexes here
    LIBRAW_CAMERAMAKER_TheLastOne
  );

  LibRaw_interpolation_quality = (
    LINEAR = 0,
    VNG = 1,
    PPG = 2,
    AHD = 3,
    DCB = 4,
    DHT = 11,
    MODIFIED_AHD = 12
  );

  LibRaw_output_color = (
    RAW = 0,
    SRGB = 1,
    ADOBE = 2,
    WIDE = 3,
    PROPHOTO = 4,
    XYZ = 5,
    ACES = 6
  );

  LibRaw_output_bps = (
    BPS8 = 8,
    BPS16 = 16
  );

  LibRaw_highlight_mode = (
    CLIP = 0,
    UNCLIP = 1,
    BLEND = 2,
    REBUILD = 3,
    REBUILD4 = 4,
    REBUILD5 = 5,
    REBUILD6 = 6,
    REBUILD7 = 7,
    REBUILD8 = 8,
    REBUILD9 = 9
  );

  LibRaw_FBDD_noise_reduction = (
    NO_FBDD = 0,
    LIGHT_FBDD = 1,
    FULL_FBDD = 2
  );

  LibRaw_runtime_capabilities = (
    LIBRAW_CAPS_UNDEFINED = 0,
    LIBRAW_CAPS_RAWSPEED = 1,
    LIBRAW_CAPS_DNGSDK = 2,
    LIBRAW_CAPS_GPRSDK = 4,
    LIBRAW_CAPS_UNICODEPATHS = 8,
    LIBRAW_CAPS_X3FTOOLS = 16,
    LIBRAW_CAPS_RPI6BY9 = 32
  );

  LibRaw_decoder_flags = (
    LIBRAW_DECODER_HASCURVE = 1 shl 4,
    LIBRAW_DECODER_SONYARW2 = 1 shl 5,
    LIBRAW_DECODER_TRYRAWSPEED = 1 shl 6,
    LIBRAW_DECODER_OWNALLOC = 1 shl 7,
    LIBRAW_DECODER_FIXEDMAXC = 1 shl 8,
    LIBRAW_DECODER_ADOBECOPYPIXEL = 1 shl 9,
    LIBRAW_DECODER_LEGACY_WITH_MARGINS = 1 shl 10,
    LIBRAW_DECODER_3CHANNEL = 1 shl 11,
    LIBRAW_DECODER_SINAR4SHOT = 1 shl 11,
    LIBRAW_DECODER_FLATDATA = 1 shl 12,
    LIBRAW_DECODER_FLAT_BG2_SWAPPED = 1 shl 13,
    LIBRAW_DECODER_NOTSET = 1 shl 15
  );

  { LibRaw - callback types }
  TProgressCallback = function(data: Pointer; state: LibRaw_progress; iter: LongInt; expected: LongInt): LongInt; cdecl;
  TDataCallback = procedure(data: Pointer; filename: PChar; offset: LongInt); cdecl; //no external
  TMemoryCallback = procedure(data: Pointer; filename: PChar; where: PChar); cdecl; //no external
  TEXIFParserCallback = procedure(context: Pointer; tag: LongInt; ttype: LongInt; len: LongInt; ord: LongInt; ifp: Pointer; base: LongInt); cdecl;

  { LibRaw - record types}
  libraw_processed_image_t = packed record
    format: LibRaw_image_formats;
    height: SmallInt;
    width: SmallInt;
    colors: SmallInt;
    bits: SmallInt;
    data_size: LongInt;
    data: array[0..0] of Byte;
  end;
  PProcImg = ^libraw_processed_image_t;

  libraw_iparams_t = packed record
    guard: array[0..3] of Char;
    make: array[0..63] of Char;
    model: array[0..63] of Char;
    software: array[0..63] of Char;
    normalized_make: array[0..63] of Char;
    normalized_model: array[0..63] of Char;
    maker_index: LibRaw_cameramaker_index;
    raw_count: LongInt;
    dng_version: LongInt;
    is_foveon: LongInt;
    colors: LongInt;
    filters: LongInt;
    xtrans: array[0..35] of Byte;
    xtrans_abs: array[0..35] of Byte;
    cdesc: array[0..4] of Char;
    xmplen: LongInt;
    xmpdata: Pointer;
  end;
  PImgParams = ^libraw_iparams_t;

  libraw_nikonlens_t = packed record
    EffectiveMaxAp: Single;
    LensIDNumber: Byte;
    LensFStops: Byte;
    MCUVersion: Byte;
    LensType: Byte;
  end;

  libraw_dnglens_t = packed record
    MinFocal: Single;
    MaxFocal: Single;
    MaxAp4MinFocal: Single;
    MaxAp4MaxFocal: Single;
  end;

  libraw_makernotes_lens_t = packed record
    LensID: Int64;
    Lens: array[0..127] of Char;
    LensFormat: SmallInt;
    LensMount: SmallInt;
    CamID: Int64;
    CameraFormat: SmallInt;
    CameraMount: SmallInt;
    body: array[0..63] of Char;
    FocalType: SmallInt;
    LensFeatures_pre: array[0..15] of Char;
    LensFeatures_suf: array[0..15] of Char;
    MinFocal: Single;
    MaxFocal: Single;
    MaxAp4MinFocal: Single;
    MaxAp4MaxFocal: Single;
    MinAp4MinFocal: Single;
    MinAp4MaxFocal: Single;
    MaxAp: Single;
    MinAp: Single;
    CurFocal: Single;
    CurAp: Single;
    MaxAp4CurFocal: Single;
    MinAp4CurFocal: Single;
    MinFocusDistance: Single;
    FocusRangeIndex: Single;
    LensFStops: Single;
    TeleconverterID: Int64;
    Teleconverter: array[0..127] of Char;
    AdapterID: Int64;
    Adapter: array[0..127] of Char;
    AttachmentID: Int64;
    Attachment: array[0..127] of Char;
    FocalUnits: SmallInt;
    FocalLengthIn35mmFormat: Single;
  end;

  libraw_lensinfo_t = packed record
    MinFocal: Single;
    MaxFocal: Single;
    MaxAp4MinFocal: Single;
    MaxAp4MaxFocal: Single;
    EXIF_MaxAp: Single;
    LensMake: array[0..127] of Char;
    Lens: array[0..127] of Char;
    LensSerial: array[0..127] of Char;
    InternalLensSerial: array[0..127] of Char;
    FocalLengthIn35mmFormat: SmallInt;
    nikon: libraw_nikonlens_t;
    dng: libraw_dnglens_t;
    makernotes: libraw_makernotes_lens_t;
  end;
  PLensInfo = ^libraw_lensinfo_t;

  libraw_gps_info_t = packed record
    latitude: array[0..2] of Single;
    longitude: array[0..2] of Single;
    gpstimestamp: array[0..2] of Single;
    altitude: Single;
    altref: Byte;
    latref: Byte;
    longref: Byte;
    gpsstatus: Byte;
    gpsparsed: Byte;
  end;

  libraw_imgother_t = packed record
    iso_speed: Single;
    shutter: Single;
    aperture: Single;
    focal_len: Single;
    timestamp: Int64;
    shot_order: LongInt;
    gpsdata: array[0..31] of LongInt;
    parsed_gps: libraw_gps_info_t;
    desc: array[0..511] of Char;
    artist: array[0..63] of Char;
    analogbalance: array[0..3] of Single;
  end;
  PImgOther = ^libraw_imgother_t;

  libraw_decoder_info_t = packed record
    decoder_name: PChar;
    decoder_flags: LibRaw_decoder_flags;
  end;

  { Microsoft Visual C runtime signatures }
  function strerror(errnum: LongInt): PChar; cdecl; external 'msvcrt';

  { LibRaw - pascal function/procedure signatures }
  // Initialization and denitialization
  function libraw_init(flags: LibRaw_init_flags): Pointer; cdecl; external LibraryName;
  procedure libraw_close(handler: Pointer); cdecl; external LibraryName;

  // Data Loading from a File/Buffer
  function libraw_open_file(handler: Pointer; filename: PChar): LibRaw_errors; cdecl; external LibraryName;
  function libraw_open_file_ex(handler: Pointer; filename: PChar; max_buff_sz : Int64): LibRaw_errors; cdecl; external LibraryName;
  function libraw_open_wfile(handler: Pointer; filename: PUnicodeChar): LibRaw_errors; cdecl; external LibraryName;
  function libraw_open_wfile_ex(handler: Pointer; filename: PUnicodeChar; max_buff_sz : Int64): LibRaw_errors; cdecl; external LibraryName;
  function libraw_open_buffer(handler: Pointer; buffer: array of Byte; size: Int64): LibRaw_errors; cdecl; external LibraryName;
  function libraw_unpack(handler: Pointer): LibRaw_errors; cdecl; external LibraryName;
  function libraw_unpack_thumb(handler: Pointer): LibRaw_errors; cdecl; external LibraryName;

  // Parameters setters/getters
  function libraw_get_raw_height(handler: Pointer): LongInt; cdecl; external LibraryName;
  function libraw_get_raw_width(handler: Pointer): LongInt; cdecl; external LibraryName;
  function libraw_get_iheight(handler: Pointer): LongInt; cdecl; external LibraryName;
  function libraw_get_iwidth(handler: Pointer): LongInt; cdecl; external LibraryName;
  function libraw_get_cam_mul(handler: Pointer; index: LongInt): Single; cdecl; external LibraryName;
  function libraw_get_pre_mul(handler: Pointer; index: LongInt): Single; cdecl; external LibraryName;
  function libraw_get_rgb_cam(handler: Pointer; index1: LongInt; index2: LongInt): Single; cdecl; external LibraryName;
  function libraw_get_iparams(handler: Pointer): PImgParams; cdecl; external LibraryName;
  function libraw_get_lensinfo(handler: Pointer): PLensInfo; cdecl; external LibraryName;
  function libraw_get_imgother(handler: Pointer): PImgOther; cdecl; external LibraryName;
  function libraw_get_color_maximum(handler: Pointer): LongInt; cdecl; external LibraryName;
  procedure libraw_set_user_mul(handler: Pointer; index: LongInt; val: Single); cdecl; external LibraryName;
  procedure libraw_set_demosaic(handler: Pointer; value: LibRaw_interpolation_quality); cdecl; external LibraryName;
  procedure libraw_set_output_color(handler: Pointer; value: LibRaw_output_color); cdecl; external LibraryName;
  procedure libraw_set_output_bps(handler: Pointer; value: LibRaw_output_bps); cdecl; external LibraryName;
  procedure libraw_set_gamma(handler: Pointer; index: LongInt; val: Single); cdecl; external LibraryName;
  procedure libraw_set_no_auto_bright(handler: Pointer; value: LongInt); cdecl; external LibraryName;
  procedure libraw_set_bright(handler: Pointer; value: Single); cdecl; external LibraryName;
  procedure libraw_set_highlight(handler: Pointer; value: LibRaw_highlight_mode); cdecl; external LibraryName;
  procedure libraw_set_fbdd_noiserd(handler: Pointer; value: LibRaw_FBDD_noise_reduction); cdecl; external LibraryName;
  procedure libraw_set_output_tif(handler: Pointer; value: LibRaw_output_formats); cdecl; external LibraryName;

  // Auxiliary Functions
  function libraw_version(): PChar; cdecl; external LibraryName;
  function libraw_versionNumber(): LongInt; cdecl; external LibraryName;
  function libraw_capabilities(): LibRaw_runtime_capabilities; cdecl; external LibraryName;
  function libraw_cameraCount(): LongInt; cdecl; external LibraryName;
  function libraw_cameraList(): Pointer; cdecl; external LibraryName;
  function libraw_get_decoder_info(handler: Pointer; var decoder: libraw_decoder_info_t): LibRaw_errors; cdecl; external LibraryName;
  function libraw_unpack_function_name(handler: Pointer): PChar; cdecl; external LibraryName;
  function libraw_COLOR(handler: Pointer; row: LongInt; col: LongInt): LongInt; cdecl; external LibraryName;
  procedure libraw_subtract_black(handler: Pointer); cdecl; external LibraryName;
  procedure libraw_recycle_datastream(handler: Pointer); cdecl; external LibraryName;
  procedure libraw_recycle(handler: Pointer); cdecl; external LibraryName;
  function libraw_strerror(errorcode: LibRaw_errors): PChar; cdecl; external LibraryName;
  function libraw_strprogress(progress: LibRaw_progress): PChar; cdecl; external LibraryName;
  procedure libraw_set_memerror_handler(handler: Pointer; callback: TMemoryCallback; datap: Pointer); cdecl; external LibraryName;
  procedure libraw_set_exifparser_handler(handler: Pointer; callback: TEXIFParserCallback; datap: Pointer); cdecl; external LibraryName;
  procedure libraw_set_dataerror_handler(handler: Pointer; func: TDataCallback; datap: Pointer); cdecl; external LibraryName;
  procedure libraw_set_progress_handler(handler: Pointer; callback: TProgressCallback; datap: Pointer); cdecl; external LibraryName;

  // Data Postprocessing, Emulation of dcraw Behavior
  function libraw_dcraw_process(handler: Pointer): LibRaw_errors; cdecl; external LibraryName;
  function libraw_raw2image(handler: Pointer): LibRaw_errors; cdecl; external LibraryName;
  procedure libraw_free_image(handler: Pointer); cdecl; external LibraryName;
  function libraw_adjust_sizes_info_only(handler: Pointer): LibRaw_errors; cdecl; external LibraryName;

  // Writing to Output Files
  function libraw_dcraw_ppm_tiff_writer(handler: Pointer; filename: PChar): LibRaw_errors; cdecl; external LibraryName;
  function libraw_dcraw_thumb_writer(handler: Pointer; filename: PChar): LibRaw_errors; cdecl; external LibraryName;

  // Writing processing results to memory buffer
  function libraw_dcraw_make_mem_image(handler: Pointer; var errc: LongInt): PProcImg; cdecl; external LibraryName;
  function libraw_dcraw_make_mem_thumb(handler: Pointer; var errc: LongInt): PProcImg; cdecl; external LibraryName;
  procedure libraw_dcraw_clear_mem(img: PProcImg); cdecl; external LibraryName;

implementation

end.

