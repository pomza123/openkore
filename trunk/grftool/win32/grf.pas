{ Delphi bindings for libgrf }
unit grf;

interface

uses
  Types, Windows;

const
  GRF_NAMELEN = $100;

type
  TGrfFileName = array[0..GRF_NAMELEN-1] of Char;

  TGrfFile = packed record
    compressed_len_aligned: Cardinal;
    compressed_len: Cardinal;
    RealLen: Cardinal;
    pos: Cardinal;

    flags: Byte;

    hash: Cardinal;
    name: TGrfFileName;

    data: PChar;
    next: Pointer;
    prev: Pointer;
  end;
  PGrfFile = ^TGrfFile;
  TGrfFiles = array of TGrfFile;

  RGrf = packed record
    filename: PChar;
    len: Cardinal;
    TheType: Cardinal;

    version: Cardinal;
    nfiles: Cardinal;
    files: TGrfFiles;

    first: PGrfFile;
    last: PGrfFile;

    // Private fields
    allowCrypt: Byte;
    f: Pointer;
    allowWrite: Byte;
    zbuf: Pointer;
  end;
  TGrf = ^RGrf;

  TGrfError = packed record
    TheType: Cardinal;
    line: Cardinal;
    FileName: PChar;
    Func: PChar;
    extra: Pointer;
  end;
  PGrfError = ^TGrfError;

  TGrfOpenCallback = function(TheFile: PGrfFile; error: PGrfError): Integer; cdecl;

const
  GRFFILE_DIR_SZFILE = $0714;
  GRFFILE_DIR_SZSMALL = $0449;
  GRFFILE_DIR_SZORIG = $055C;
  GRFFILE_DIR_OFFSET = $058A;

  GRFFILE_FLAG_FILE = $01;
  GRFFILE_FLAG_MIXCRYPT = $02;
  GRFFILE_FLAG_0x14_DES = $04;


function grf_callback_open(const fname: PChar; const mode: PChar; var error: TGrfError; callback: TGrfOpenCallback): TGrf; cdecl; external 'grf.dll';
function grf_get(Grf: TGrf; const fname: PChar; var size: Cardinal; var Error: TGrfError): Pointer; cdecl; external 'grf.dll';
function grf_extract(Grf: TGrf; const grfname: PChar; const f: PChar; var Error: TGrfError): Integer; cdecl; external 'grf.dll';
function grf_find(Grf: TGrf; const fname: PChar; var Index: Cardinal): PGrfFile; cdecl; external 'grf.dll';
procedure grf_free(Grf: TGrf); cdecl; external 'grf.dll';
function grf_strerror(err: TGrfError): PChar; cdecl; external 'grf.dll';

function GRFFILE_IS_DIR(F: PGrfFile): Boolean; overload;
function GRFFILE_IS_DIR(var F: TGrfFile): Boolean; overload;

implementation

function GRFFILE_IS_DIR(F: PGrfFile): Boolean;
begin
  Result := ((f.flags and GRFFILE_FLAG_FILE) = 0) or
    (
       (f.compressed_len_aligned = GRFFILE_DIR_SZFILE) and
       (f.compressed_len = GRFFILE_DIR_SZSMALL) and
       (f.RealLen = GRFFILE_DIR_SZORIG) and
       (f.pos = GRFFILE_DIR_OFFSET)
    );
end;

function GRFFILE_IS_DIR(var F: TGrfFile): Boolean;
begin
  Result := ((f.flags and GRFFILE_FLAG_FILE) = 0) or
    (
       (f.compressed_len_aligned = GRFFILE_DIR_SZFILE) and
       (f.compressed_len = GRFFILE_DIR_SZSMALL) and
       (f.RealLen = GRFFILE_DIR_SZORIG) and
       (f.pos = GRFFILE_DIR_OFFSET)
    );
end;

end.
