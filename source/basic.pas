{==============================================================================}
{        UNIT: basic                                                           }
{ DESCRIPTION: lysee basic functions                                           }
{   COPYRIGHT: Copyright (c) 2003-2016, Li Yun Jie. All Rights Reserved.       }
{     LICENSE: modified BSD license                                            }
{     CREATED: 2003/02/28                                                      }
{    MODIFIED: 2016/11/15                                                      }
{==============================================================================}
{ Contributor(s):                                                              }
{==============================================================================}
unit basic;

{$IFDEF FPC}
{$MODE objfpc}{$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes, SyncObjs, DateUtils, Math;

const

  CS_PATHDELIM = {$IFDEF MSWINDOWS}'\'{$ELSE}'/'{$ENDIF};
  CS_DIGIT     = ['0'..'9'];
  CS_UPPER     = ['A'..'Z'];
  CS_LOWER     = ['a'..'z'];
  CS_ALPHA     = CS_UPPER + CS_LOWER;
  CS_ALNUM     = CS_ALPHA + CS_DIGIT;
  CS_UPNUM     = CS_UPPER + CS_DIGIT;
  CS_ID        = CS_ALNUM + ['_'];
  CS_HEAD      = CS_ALPHA + ['_'];
  CS_CONST     = CS_UPNUM + ['_'];
  CS_PUNCT     = ['!'..'~'] - CS_ALNUM;
  CS_CONTROL   = [#0..#31, #127];
  CS_QUOTE     = ['"', ''''];
  CS_SPACE     = [#9, #10, #12, #13, ' '];
  CS_HEX       = ['A'..'F', 'a'..'f'] + CS_DIGIT;
  CS_FMTINT    = ['d', 'u', 'x'];
  CS_FMTFLOAT  = ['e', 'f', 'g', 'n', 'm'];
  CS_FMTCHAR   = ['c'];
  CS_FMTSTRING = ['s'];
  CS_FMTPTR    = ['p'];
  CS_FORMAT    = CS_FMTINT + CS_FMTFLOAT + CS_FMTCHAR + CS_FMTSTRING + CS_FMTPTR;
  CS_LOWER_A   = Ord('a');
  CS_LOWER_F   = Ord('f');
  CS_LOWER_Z   = Ord('z');
  CS_UPPER_A   = Ord('A');
  CS_UPPER_F   = Ord('F');
  CS_UPPER_Z   = Ord('Z');
  CS_DISTANCE  = CS_LOWER_A - CS_UPPER_A;

type

  TLiCompare  = (crEqual, crLess, crMore, crDiff);
  TLiCompares = set of TLiCompare;
  TLiException = class(Exception);

  { TLiObject }

  TLiObject = class
  private
    FRefCount: integer;
  public
    function IncRefcount: integer;virtual;
    function DecRefcount: integer;virtual;
    function RefCount: integer;
  end;

  { TLiNamedObject }

  TLiNamedObject = class(TLiObject)
  protected
    FName: string;
    procedure SetName(const AName: string);virtual;
  public
    constructor Create(const AName: string);virtual;
    destructor Destroy;override;
    function SafeName: string;
    property Name: string read FName write SetName;
  end;

  { TLiNamedObjectList }

  TLiNamedObjectFunc = function(Nobj: TLiNamedObject; Data: pointer): boolean;

  TLiNamedObjectList = class(TLiObject)
  private
    FItems: TList;
    FCaseSensitive: boolean;
    FUnique: boolean;
    FSorted: boolean;
    FInOrder: boolean;
    FAllowNil: boolean;
    function GetCount: integer;
    function GetItem(Index: integer): TLiNamedObject;
    function GetName(Index: integer): string;
    procedure SetCaseSensitive(Value: boolean);
    procedure SetUnique(Value: boolean);
    procedure SetSorted(Value: boolean);
    procedure SetAllowNil(Value: boolean);
    function GetNameList: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TLiNamedObjectList);
    procedure Clear;
    procedure Delete(Index: integer);
    procedure Remove(const Name: string);overload;
    procedure Remove(Nobj: TLiNamedObject);overload;
    function IndexOf(const Name: string): integer;overload;
    function IndexOf(Nobj: TLiNamedObject): integer;overload;
    function Add(Nobj: TLiNamedObject): integer;
    function Get(const Name: string): TLiNamedObject;
    procedure Each(Func: TLiNamedObjectFunc; Data: pointer);
    procedure Sort;
    property Count: integer read GetCount;
    property Items[Index: integer]: TLiNamedObject read GetItem;default;
    property Names[Index: integer]: string read GetName;
    property NameList: string read GetNameList;
    property CaseSensitive: boolean read FCaseSensitive write SetCaseSensitive;
    property Unique: boolean read FUnique write SetUnique;
    property Sorted: boolean read FSorted write SetSorted;
    property AllowNil: boolean read FAllowNil write SetAllowNil;
  end;

  { TLiLock }

  TLiLock = class(TLiObject)
  public
    procedure Enter;virtual;abstract;
    procedure Leave;virtual;abstract;
    function TryEnter: boolean;virtual;abstract;
  end;

  { TLiSpinLock }

  TLiSpinLock = class(TLiLock)
  private
    FCriticalSection: SyncObjs.TCriticalSection;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Enter;override;
    procedure Leave;override;
    function TryEnter: boolean;override;
  end;

  { TLiMD5 }

  TLiMD5 = class(TLiObject)
  private
    FBuffer: array[0..15] of cardinal;
    FA, FB, FC, FD: cardinal;
    PA, PB, PC, PD: PCardinal;
    procedure Init;
    procedure Transform;
    procedure FF(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
    procedure GG(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
    procedure HH(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
    procedure II(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
    function ROL(A: cardinal; Amount: byte): cardinal;
    function GetDigest: string;
  public
    function SumBuffer(const Buffer: pointer; Count: integer): string;
    function SumString(const S: string): string;
    function SumAnsiString(const S: AnsiString): string;
    function SumWideString(const S: WideString): string;
    function SumStream(const Stream: TStream): string;
    function SumFile(const FileName: string): string;
  end;

function Addref(A: TLiObject): integer;
function Release(A: TLiObject): integer;

{ exception handling }

function ExceptionStr: string;
procedure Throw(const Msg: string);overload;
procedure Throw(const Msg: string; const Args: array of const);overload;
procedure Check(OK: boolean; const Msg: string);overload;
procedure Check(OK: boolean; const Msg: string; const Args: array of const);overload;

{ environment }

function GetEnvCount: integer;
function GetEnv(Index: integer): string;overload;
function GetEnv(const ID: string): string;overload;
function GetEnv(const ID: array of string; const DefValue: string): string;overload;

{ memory }

function MemAlloc(Count: integer): pointer;
function MemAllocZero(Count: integer): pointer;
function MemFree(const Mem: pointer; Count: integer = 0): boolean;
function MemZero(const Mem: pointer; Count: integer): pointer;

{ charset }

function InChars(const S: string; Chars: TSysCharSet): boolean;
function SkipChar(const S: pchar; Chars: TSysCharSet): pchar;
function SeekChar(const S: pchar; Chars: TSysCharSet): pchar;
function UpperChar(ch: char): char;
function LowerChar(ch: char): char;
function UpperHead(const S: string): string;
function LowerHead(const S: string): string;
function IsUpperHead(const S: string): boolean;
function IsLowerHead(const S: string): boolean;

{ string }

function IsEmptyStr(const S: string): boolean;
function InStrings(const S: string; const List: array of string): boolean;
function RepeatString(const S: string; Times: integer): string;
function RepeatChar(C: char; Times: integer): string;
function StringOf(const S: pchar): string;overload;
function StringOf(const S: pchar; L: integer): string;overload;
function LengthOf(const S: pchar): integer;
function HashOf(S: pchar): cardinal;overload;
function HashOf(const S: string): cardinal;overload;
function TrimAll(const S: string): string;
function ReplaceAll(const S, Patten, NewString: string): string;
function PosLineBreak(const S: string): integer;

{ identity }

function GenID: string;
function GenName: string;overload;
function GenName(P: pointer): string;overload;
function GiveName(AComponent: TComponent): string;
function IsID(const S: string): boolean;

{ compare }

function IntToCompare(I: integer): TLiCompare;overload;
function IntToCompare(I: int64): TLiCompare;overload;
function CompareFloat(V1, V2: double): TLiCompare;
function CompareInt64(V1, V2: int64): TLiCompare;
function CompareInteger(V1, V2: integer): TLiCompare;
function CompareMoney(V1, V2: currency): TLiCompare;
function CompareChar(V1, V2: char): TLiCompare;overload;
function CompareChar(const V1, V2: char; CaseSensitive: boolean): TLiCompare;overload;
function CompareString(const S1, S2: string): TLiCompare;overload;
function CompareString(const S1, S2: string; CaseSensitive: boolean): TLiCompare;overload;

{ patten }

function MatchPatten(const S, Patten: string): boolean;

{ parse string }

function ExtractNameValue(const S: string; var V: string; const separator: string = '='): string;
function ExtractName(const S: string; const separator: string = '='): string;
function ExtractValue(const S: string; const separator: string = '='): string;
function ExtractNext(var S: string; const separator: string = ':'): string;
function ParseConfig(const S: string; var ID, Value: string): boolean;
function HexValue(ch: char): byte;overload;
function HexValue(c1, c2: char): byte;overload;

{ string format }

function IntToStrExt(Value: int64; const Ext: string = ''): string;
function FloatToStrExt(Value: double; const Ext: string = ''): string;
function CurrToStrExt(Value: currency; const Ext: string = ''): string;

{ encoding }

function StrToAnsi(const S: string): AnsiString;
function AnsiToStr(const S: AnsiString): string;
function StrToUnicode(const S: string): UnicodeString;
function UnicodeToStr(const S: UnicodeString): string;
function AnsiToUnicode(const S: AnsiString): UnicodeString;
function UnicodeToAnsi(const S: UnicodeString): AnsiString;
function StrToWide(const S: string): WideString;
function WideToStr(const S: WideString): string;
function AnsiToWide(const S: AnsiString): WideString;
function WideToAnsi(const S: WideString): AnsiString;
function IsUTF8(const S: AnsiString): boolean;overload;
function IsUTF8(S: PAnsiChar; Count: integer): boolean;overload;
function TryUTF8Decode(const S: AnsiString): UnicodeString;
function TryUTF8ToUnicode(const S: string): UnicodeString;
function WideToCanvas(const S: WideString): string;

{ pointer }

function IntToPtr(Value: integer): pointer;
function PtrToInt(Value: pointer): integer;
function IncPtr(const P: pointer; Offset: integer): pointer;
function DecPtr(const P: pointer; Offset: integer): pointer;overload;
function DecPtr(const P1, P2: pointer): integer;overload;

{ file }

function FileCode(const FileName: string): string;
function FullPath(const Path: string): string;
function FullFileName(const FileName: string): string;
function RelativeFileName(const FileName, BaseFileName: string): string;
function MakeDir(const Dir: string): boolean;
function SetUD(const URL: string): string;
function SetPD(const Path: string): string;
function IncPD(const FileName: string): string;
function ExcPD(const FileName: string): string;
function OpenFileMode(const S: string): integer;
function OpenFileStream(const FileName: string; Mode:Word): TFileStream;

{ index }

function ResetIndex(Index, Length: integer; Check: boolean = false): integer;overload;
function ResetRange(Index, Length: integer; var Count: integer): integer;overload;
function ResetIndex(Index, Length: int64; Check: boolean = false): int64;overload;
function ResetRange(Index, Length: int64; var Count: int64): int64;overload;
function CheckIndex(Index, Length: int64): boolean;overload;
function CheckIndex(Index, MinX, MaxX: int64): boolean;overload;

{ ym }

function GetYM: integer;overload;
function GetYM(Date: TDateTime): integer;overload;
function IsYM(Y, M: integer): boolean;overload;
function IsYM(YM: integer): boolean;overload;
function IsYM(YM, MinYM, MaxYM: integer): boolean;overload;
function IsYM(const YM: string): boolean;overload;
function YMToStr(YM: integer): string;
function StrToYM(const S: string; DefValue: integer = 0): integer;
function DecodeYM(YM: integer; var Y, M: integer): boolean;
function PrevYM(YM: integer; Offset: integer = 1): integer;overload;
function PrevYM(const YM: string): string;overload;
function NextYM(YM: integer; Offset: integer = 1): integer;overload;
function NextYM(const YM: string): string;overload;

{ ymd }

function GetYMD: integer;overload;
function GetYMD(Date: TDateTime): integer;overload;
function Today: integer;
function IsYMD(Y, M, D: integer): boolean;overload;
function IsYMD(YMD: integer): boolean;overload;
function IsYMD(const YMD: string): boolean;overload;
function YMDToStr(YMD: integer): string;overload;
function YMDToStr(YMD: integer; const Delimiter: string): string;overload;
function StrToYMD(const S: string; DefValue: integer = 0): integer;
function YMDToDate(YMD: integer): TDateTime;
function DecodeYMD(YMD: integer; var Y, M, D: integer): boolean;
function NextYMD(YMD: integer; Offset: integer = 1): integer;
function PrevYMD(YMD: integer; Offset: integer = 1): integer;

{ md5 }

function MD5SumBuffer(const Buffer: pointer; Count: integer): string;
function MD5SumString(const S: string): string;
function MD5SumAnsiString(const S: AnsiString): string;
function MD5SumWideString(const S: WideString): string;
function MD5SumStream(const Stream: TStream): string;
function MD5SumFile(const FileName: string): string;
function MD5TrySumFile(const FileName: string): string;

{ object }

procedure FreeAll(const Objects: TList);overload;
procedure FreeAll(const Objects: array of TObject);overload;

{ library }

function LoadDLL(const FileName: string; var Handle: THandle): boolean;
procedure FreeDLL(Handle: THandle);
function GetProcAddr(Handle: THandle; const ProcName: string): pointer;

{ stdio }

function stdin: integer;
function stdout: integer;
function stderr: integer;

function Gets: string;
function Puts(const Text: string): integer;overload;
function Puts(S: TStream; const Text: string): integer;overload;
function Putln: integer;overload;
function Putln(const Text: string): integer;overload;
function Putln(S: TStream; const Text: string): integer;overload;
function Putln(S: TStream): integer;overload;

{ http }

function HTTPDecode(const AStr: AnsiString): AnsiString;
function HTTPEncode(const AStr: AnsiString): AnsiString;
function HTMLEncode(const AStr: string): string;
function HTMLDecode(const AStr: string): string;

{ misc }

procedure Swap(var V1, V2: integer);

implementation

uses
  {$IFDEF MSWINDOWS}Windows{$ELSE}dynlibs{$ENDIF},
  {$IFDEF FPC}regexpr{$ELSE}RegularExpressions{$ENDIF};

function Addref(A: TLiObject): integer;
begin
  if A <> nil then
    Result := A.IncRefcount else
    Result := 0;
end;

function Release(A: TLiObject): integer;
begin
  if A <> nil then
    Result := A.DecRefcount else
    Result := 0;
end;

function ExceptionStr: string;
var
  E: TObject;
begin
  E := ExceptObject;
  if E = nil then Result := '' else
  if not (E is Exception) or (E is EAbort) then
    Result := Format('%s<%p> was raised', [E.ClassName, pointer(E)]) else
    Result := Exception(E).Message;
end;

procedure Throw(const Msg: string);
begin
  raise TLiException.Create(Msg);
end;

procedure Throw(const Msg: string; const Args: array of const);
begin
  Throw(Format(Msg, Args));
end;

procedure Check(OK: boolean; const Msg: string);
begin
  if not OK then Throw(Msg);
end;

procedure Check(OK: boolean; const Msg: string; const Args: array of const);
begin
  if not OK then Throw(Msg, Args);
end;

function GetEnvCount: integer;
{$IFNDEF FPC}
var
  H, P: PChar;
{$ENDIF}
begin
  {$IFDEF FPC}
  Result := SysUtils.GetEnvironmentVariableCount;
  {$ELSE}
  Result := 0;
  P := GetEnvironmentStrings;
  H := P;
  if H <> nil then
    while H^ <> #0 do
    begin
      Inc(Result);
      H := H + StrLen(H) + 1;
    end;
  FreeEnvironmentStrings(P);
  {$ENDIF}
end;

function GetEnv(Index: integer): string;
{$IFNDEF FPC}
var
  H, P: PChar;
{$ENDIF}
begin
  {$IFDEF FPC}
  Result := SysUtils.GetEnvironmentString(Index + 1);
  {$ELSE}
  Result := '';
  P := GetEnvironmentStrings;
  H := P;
  if H <> nil then
  begin
    while (H^ <> #0) and (Index > 0) do
    begin
      H := H + StrLen(H) + 1;
      Dec(Index);
    end;
    if (H^ <> #0) and (Index = 0) then
      Result := H;
  end;
  FreeEnvironmentStrings(P);
  {$ENDIF}
end;

function GetEnv(const ID: string): string;
begin
  Result := SysUtils.GetEnvironmentVariable(ID);
end;

function GetEnv(const ID: array of string; const DefValue: string): string;
var
  I: integer;
begin
  for I := 0 to length(ID) - 1 do
  begin
    Result := SysUtils.GetEnvironmentVariable(ID[I]);
    if Result <> '' then Exit;
  end;
  Result := DefValue;
end;

function GenID: string;
var
  G: TGuid;
  I: integer;
begin
  CreateGuid(G);
  Result := UpperCase(GuidToString(G));
  for I := Length(Result) downto 1 do
    if not CharInSet(Result[I], CS_HEX) then
      System.Delete(Result, I, 1);
end;

function GenName: string;
begin
  Result := '_' + GenID;
end;

function GenName(P: pointer): string;
begin
  Result := Format('_%p', [P]);
end;

function GiveName(AComponent: TComponent): string;
begin
  if (AComponent <> nil) and (AComponent.Name = '') then
  begin
    Result := Copy(AComponent.ClassName, 2, 32) + GenName(pointer(AComponent));
    AComponent.Name := Result;
  end
  else Result := '';
end;

function HexValue(ch: char): byte;
begin
  case ch of
    '0'..'9': Result := Ord(ch) - Ord('0');
    'A'..'F': Result := Ord(ch) - Ord('A') + 10;
    'a'..'f': Result := Ord(ch) - Ord('a') + 10;
    else begin
      Result := 0;
      Throw('invalid HEX char: %c', [ch]);
    end;
  end;
end;

function HexValue(c1, c2: char): byte;
begin
  Result := (HexValue(c1) shl 4) or HexValue(c2);
end;

function StringOf(const S: pchar): string;
begin
  Result := StringOf(S, LengthOf(S));
end;

function StringOf(const S: pchar; L: integer): string;
begin
  if (S <> nil) and (L > 0) then
    SetString(Result, S, L) else
    Result := '';
end;

function LengthOf(const S: pchar): integer;
var
  P: pchar;
begin
  if (S <> nil) and (S^ <> #0) then
  begin
    P := S + 1;
    while P^ <> #0 do Inc(P);
    Result := (P - S);
  end
  else Result := 0;
end;

function MemAlloc(Count: integer): pointer;
begin
  Result := nil;
  if Count > 0 then
    GetMem(Result, Count);
end;

function MemAllocZero(Count: integer): pointer;
begin
  Result := MemAlloc(Count);
  if Result <> nil then
    FillChar(Result^, Count, 0);
end;

function MemFree(const Mem: pointer; Count: integer): boolean;
begin
  Result := (Mem <> nil) and (Count >= 0);
  if Result then
    if Count > 0 then
      FreeMem(Mem, Count) else
      FreeMem(Mem);
end;

function MemZero(const Mem: pointer; Count: integer): pointer;
begin
  FillChar(Mem^, Count, 0);
  Result := Mem;
end;

function FullFileName(const FileName: string): string;
begin
  if FileName <> '' then
    Result := ExpandFileName(SetPD(FileName)) else
    Result := '';
end;

function FullPath(const Path: string): string;
begin
  Result := ExpandFileName(Path);
  if Result <> '' then
    Result := IncPD(Result);
end;

function RelativeFileName(const FileName, BaseFileName: string): string;
var
  F: string;
begin
  F := SetPD(FileName);
  if (F <> '') and (F[1] = '.') then
    F := ExtractFilePath(SetPD(BaseFileName)) + F;
  Result := FullFileName(F);
end;

function MakeDir(const Dir: string): boolean;
begin
  Result := ForceDirectories(Dir);
end;

function vary_index(index, length: int64): int64;
begin
  if index < 0 then
    Result := index + length else
    Result := index;
end;

function vary_range(index, length: int64; var count: int64): int64;
begin
  if index < 0 then
  begin
    Result := index + length;
    if Result < 0 then
    begin
      Inc(count, Result);
      Result := 0;
    end;
  end
  else Result := index;
  count := Max(0, Min(length - Result, count));
end;

function FileCode(const FileName: string): string;
var
  L: TStrings;
begin
  L := TStringList.Create;
  try
    L.LoadFromFile(FileName);
    Result := L.Text;
  finally
    L.Free;
  end;
end;

function SetPD(const Path: string): string;
var
  X: integer;
  C: char;
begin
  Result := Path;
  for X := 1 to Length(Path) do
  begin
    C := Path[X];
    if CharInSet(C, ['\', '/']) then
      if C <> PathDelim then
        Result[X] := PathDelim;
  end;
end;

function SetUD(const URL: string): string;
var
  X: integer;
begin
  Result := URL;
  for X := 1 to Length(URL) do
    if URL[X] = '\' then
      Result[X] := '/';
end;

function IncPD(const FileName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(FileName);
end;

function ExcPD(const FileName: string): string;
begin
  Result := ExcludeTrailingPathDelimiter(FileName);
end;

function OpenFileMode(const S: string): integer;
var
  I: integer;
  C, E, R, W: boolean;
begin
  Result := fmShareDenyWrite;
  C := false;
  E := false;
  R := false;
  W := false;
  for I := 1 to Length(S) do
    case S[I] of
      'c', 'C': C := true; // create
      'e', 'E': E := true; // exclusive
      'r', 'R': R := true; // read
      'w', 'W': W := true; // write
    end;
  if C or E or R or W then
  begin
    if C then
    begin
      Result := fmCreate;
//    R := true;
//    W := true;
    end
    else
    if R then
    begin
      if W then Result := fmOpenReadWrite or fmShareExclusive else
      if E then Result := fmOpenRead or fmShareExclusive else
                Result := fmShareDenyWrite;
    end
    else
    if W then
      Result := fmOpenWrite or fmShareExclusive else
      Result := fmOpenRead or fmShareExclusive;
  end
end;

function OpenFileStream(const FileName: string; Mode:Word): TFileStream;
begin
  Result := TFileStream.Create(FileName, Mode);
end;

function ResetIndex(Index, Length: int64; Check: boolean): int64;
begin
  if Index < 0 then
    Result := Index + Length else
    Result := Index;
  if Check then
    CheckIndex(Result, Length);
end;

function ResetRange(Index, Length: int64; var Count: int64): int64;
begin
  if Index < 0 then
  begin
    Result := Index + Length;
    if Result < 0 then
    begin
      Inc(Count, Result);
      Result := 0;
    end;
  end
  else Result := Index;
  Count := Max(0, Min(Length - Result, Count));
end;

function ResetIndex(Index, Length: integer; Check: boolean): integer;
begin
  if Index < 0 then
    Result := Index + Length else
    Result := Index;
  if Check then
    CheckIndex(Result, Length);
end;

function ResetRange(Index, Length: integer; var Count: integer): integer;
begin
  if Index < 0 then
  begin
    Result := Index + Length;
    if Result < 0 then
    begin
      Inc(Count, Result);
      Result := 0;
    end;
  end
  else Result := Index;
  Count := Max(0, Min(Length - Result, Count));
end;

function CheckIndex(Index, Length: int64): boolean;
begin
  Result := (Index >= 0) and (Index < Length);
  if not Result then
    Throw('index %d is out of range %d', [Index, Length]);
end;

function CheckIndex(Index, MinX, MaxX: int64): boolean;
begin
  Result := (Index >= MinX) and (Index <= MaxX);
  if not Result then
    Throw('index %d is out of range %d..%d', [Index, MinX, MaxX]);
end;

function IntToPtr(Value: integer): pointer;
var
  P: pbyte;
begin
  P := nil;
  Inc(P, Value);
  Result := P;
end;

function PtrToInt(Value: pointer): integer;
begin
  Result := PByte(Value) - PByte(nil);
end;

function IncPtr(const P: pointer; Offset: integer): pointer;
begin
  Result := PByte(P) + Offset;
end;

function DecPtr(const P: pointer; Offset: integer): pointer;
begin
  Result := PByte(P) - Offset;
end;

function DecPtr(const P1, P2: pointer): integer;
begin
  Result := PByte(P1) - PByte(P2);
end;

function InChars(const S: string; Chars: TSysCharSet): boolean;
var
  I: integer;
begin
  for I := 1 to Length(S) do
    if not CharInSet(S[I], Chars) then
    begin
      Result := false;
      Exit;
    end;
  Result := (S <> '');
end;

function SkipChar(const S: pchar; Chars: TSysCharSet): pchar;
begin
  Result := S;
  if Result <> nil then
  begin
    while (Result^ <> #0) and CharInSet(Result^, Chars) do Inc(Result);
    if Result^ = #0 then Result := nil;
  end;
end;

function SeekChar(const S: pchar; Chars: TSysCharSet): pchar;
begin
  Result := S;
  if Result <> nil then
  begin
    while (Result^ <> #0) and not CharInSet(Result^, Chars) do Inc(Result);
    if Result^ = #0 then Result := nil;
  end;
end;

function IsID(const S: string): boolean;
begin
  Result := (S <> '') and CharInSet(S[1], CS_HEAD) and InChars(S, CS_ID);
end;

function IsUpperHead(const S: string): boolean;
begin
  Result := (S <> '') and CharInSet(S[1], CS_UPPER);
end;

function IsLowerHead(const S: string): boolean;
begin
  Result := (S <> '') and CharInSet(S[1], CS_LOWER);
end;

function IsUTF8(const S: AnsiString): boolean;
begin
  Result := IsUTF8(PAnsiChar(S), Length(S));
end;

function IsUTF8(S: PAnsiChar; Count: integer): boolean;
var
  I, rest: integer;
  B: byte;
  asc_II: boolean;
begin
  Result := false;
  asc_II := true;
  rest := 0;
  for I := 0 to Count - 1 do
  begin
    B := Ord(S^);
    if rest > 0 then // check following rest: 10XXXXXX
    begin
      if (B and $C0) <> $80 then Exit;
      Dec(rest);
    end
    else
    if B >= $80 then // head byte: 1XXXXXXX
    begin
      if (B >= $FC) and (B <= $FD) then rest := 5 else
      if (B >= $F8) then rest := 4 else
      if (B >= $F0) then rest := 3 else
      if (B >= $E0) then rest := 2 else
      if (B >= $C0) then rest := 1 else Exit;
      asc_II := false;
    end;
    Inc(S);
  end;
  Result := not asc_II and (rest = 0);
end;

function TryUTF8Decode(const S: AnsiString): UnicodeString;
begin
  if IsUTF8(S) then
    Result := {$IFDEF FPC}UTF8Decode(S){$ELSE}UTF8ToString(S){$ENDIF} else
    Result := AnsiToUnicode(S);
end;

function TryUTF8ToUnicode(const S: string): UnicodeString;
begin
  {$IFDEF UNICODE}
  Result := S;
  {$ELSE}
  Result := TryUTF8Decode(S);
  {$ENDIF};
end;

function WideToStr(const S: WideString): string;
begin
  Result := UnicodeToStr(S);
end;

function StrToWide(const S: string): WideString;
begin
  Result := StrToUnicode(S);
end;

function WideToCanvas(const S: WideString): string;
begin
  {$IFDEF UNICODE}
  Result := S;
  {$ELSE}
  {$IFDEF FPC}
  Result := UTF8Encode(S);
  {$ELSE}
  Result := S;
  {$ENDIF}
  {$ENDIF};
end;

function WideToAnsi(const S: WideString): AnsiString;
begin
  Result := UnicodeToAnsi(S);
end;

function AnsiToWide(const S: AnsiString): WideString;
begin
  Result := AnsiToUnicode(S);
end;

function StrToAnsi(const S: string): AnsiString;
begin
  {$IFDEF UNICODE}
  Result := AnsiString(S);
  {$ELSE}
  Result := S;
  {$ENDIF};
end;

function AnsiToStr(const S: AnsiString): string;
begin
  {$IFDEF UNICODE}
  Result := string(S);
  {$ELSE}
  Result := S;
  {$ENDIF};
end;

function StrToUnicode(const S: string): UnicodeString;
begin
  {$IFDEF UNICODE}
  Result := S;
  {$ELSE}
  Result := UnicodeString(S);
  {$ENDIF};
end;

function UnicodeToStr(const S: UnicodeString): string;
begin
  {$IFDEF UNICODE}
  Result := S;
  {$ELSE}
  Result := string(S);
  {$ENDIF};
end;

function AnsiToUnicode(const S: AnsiString): UnicodeString;
begin
  {$IFDEF UNICODE}
  Result := AnsiToStr(S);
  {$ELSE}
  Result := UnicodeString(S);
  {$ENDIF};
end;

function UnicodeToAnsi(const S: UnicodeString): AnsiString;
begin
  {$IFDEF UNICODE}
  Result := StrToAnsi(S);
  {$ELSE}
  Result := AnsiString(S);
  {$ENDIF};
end;

function IntToStrExt(Value: int64; const Ext: string): string;
begin
  if Value = 0 then
    Result := '' else
    Result := IntToStr(Value);
  if (Result <> '') and (Ext <> '') then
    Result := Result + Ext;
end;

function FloatToStrExt(Value: double; const Ext: string): string;
begin
  if IsZero(Value) then
    Result := '' else
    Result := FloatToStr(Value);
  if (Result <> '') and (Ext <> '') then
    Result := Result + Ext;
end;

function CurrToStrExt(Value: currency; const Ext: string): string;
begin
  if Value = 0 then
    Result := '' else
    Result := CurrToStr(Value);
  if (Result <> '') and (Ext <> '') then
    Result := Result + Ext;
end;

function PosLineBreak(const S: string): integer;
var
  I: integer;
begin
  for I := 1 to Length(S) do
    if CharInSet(S[I], [#10, #13]) then
    begin
      Result := I;
      Exit;
    end;
  Result := 0;
end;

function IntToCompare(I: integer): TLiCompare;
begin
  if I = 0 then Result := crEqual else
  if I < 0 then Result := crLess else
                Result := crMore;
end;

function IntToCompare(I: int64): TLiCompare;overload;
begin
  if I = 0 then Result := crEqual else
  if I < 0 then Result := crLess else
                Result := crMore;
end;

function CompareFloat(V1, V2: double): TLiCompare;
begin
  V1 := V1 - V2;
  if IsZero(V1) then
    Result := crEqual else
  if V1 < 0 then
    Result := crLess else
    Result := crMore;
end;

function CompareInt64(V1, V2: int64): TLiCompare;
begin
  if V1 = V2 then Result := crEqual else
  if V1 < V2 then Result := crLess else
                  Result := crMore;
end;

function CompareInteger(V1, V2: integer): TLiCompare;
begin
  if V1 = V2 then Result := crEqual else
  if V1 < V2 then Result := crLess else
                  Result := crMore;
end;

function CompareMoney(V1, V2: currency): TLiCompare;
begin
  if V1 = V2 then Result := crEqual else
  if V1 < V2 then Result := crLess else
                  Result := crMore;
end;

function CompareChar(V1, V2: char): TLiCompare;
begin
  Result := IntToCompare(Ord(V1) - Ord(V2));
end;

function CompareChar(const V1, V2: char; CaseSensitive: boolean): TLiCompare;
begin
  if CaseSensitive then
    Result := IntToCompare(Ord(V1) - Ord(V2)) else
    Result := IntToCompare(Ord(LowerChar(V1)) - Ord(LowerChar(V2)));
end;

function CompareString(const S1, S2: string): TLiCompare;
begin
  Result := IntToCompare(SysUtils.CompareStr(S1, S2));
end;

function CompareString(const S1, S2: string; CaseSensitive: boolean): TLiCompare;
begin
  if CaseSensitive then
    Result := IntToCompare(SysUtils.CompareStr(S1, S2)) else
    Result := IntToCompare(SysUtils.CompareText(S1, S2));
end;

function MatchPatten(const S, Patten: string): boolean;
begin
  {$IFDEF FPC}
  Result := regexpr.ExecRegExpr(Patten, S);
  {$ELSE}
  Result := TRegEx.IsMatch(S, Patten);
  {$ENDIF}
end;

function IsEmptyStr(const S: string): boolean;
begin
  Result := (S = '');
end;

function UpperChar(ch: char): char;
begin
  Result := ch;
  if CharInSet(Result, CS_LOWER) then
    Dec(Result, CS_DISTANCE);
end;

function LowerChar(ch: char): char;
begin
  Result := ch;
  if CharInSet(Result, CS_UPPER) then
    Inc(Result, CS_DISTANCE);
end;

function UpperHead(const S: string): string;
begin
  Result := S;
  if Result <> '' then
    Result[1] := UpperChar(Result[1]);
end;

function LowerHead(const S: string): string;
begin
  Result := S;
  if Result <> '' then
    Result[1] := LowerChar(Result[1]);
end;

function ExtractNameValue(const S: string; var V: string; const separator: string): string;
var
  X: integer;
begin
  X := Pos(separator, S);
  if X > 0 then
  begin
    V := Copy(S, X + Length(separator), Length(S));
    Result := Trim(Copy(S, 1, X - 1));
  end
  else
  begin
    V := '';
    Result := '';
  end;
end;

function ExtractName(const S, separator: string): string;
var
  X: integer;
begin
  X := Pos(separator, S);
  if X > 1 then
    Result := Trim(Copy(S, 1, X - 1)) else
    Result := '';
end;

function ExtractValue(const S, separator: string): string;
var
  X: integer;
begin
  X := Pos(separator, S);
  if X > 0 then
    Result := Copy(S, X + Length(separator), MaxInt) else
    Result := '';
end;

function ExtractNext(var S: string; const separator: string): string;
var
  X: integer;
begin
  X := Pos(separator, S);
  if X > 0 then
  begin
    Result := Copy(S, 1, X - 1);
    S := Copy(S, X + Length(separator), Length(S));
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

function InStrings(const S: string; const List: array of string): boolean;
var
  T: string;
begin
  for T in List do
    if T = S then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end;

function HashOf(S: pchar): cardinal;
begin
  Result := 0;
  if (S <> nil) and (S^ <> #0) then
  repeat
    Result := ((Result shl 2) or (Result shr (sizeof(Result) * 8 - 2))) xor Ord(S^);
    Inc(S);
  until S^ = #0;
end;

function HashOf(const S: string): cardinal;
begin
  Result := HashOf(pchar(S));
end;

function ParseConfig(const S: string; var ID, Value: string): boolean;
begin
  ID := ExtractNameValue(S, Value);
  Result := (ID <> '');
  if Result then
    Value := Trim(Value);
end;

function RepeatString(const S: string; Times: integer): string;
begin
  Result := '';
  if S <> '' then
    while Times > 0 do
    begin
      Result := Result + S;
      Dec(Times);
    end;
end;

function TrimAll(const S: string): string;
var
  I, N, L, Z: integer;
begin
  L := Length(S);
  N := 0;
  for I := 1 to L do
    if S[I] <= ' ' then
      Inc(N);
  if N = 0 then Result := S else
  if N = L then Result := '' else
  begin
    Z := L - N;
    SetLength(Result, Z);
    N := 0;
    for I := 1 to L do
      if S[I] > ' ' then
      begin
        Inc(N);
        Result[N] := S[I];
        if N = Z then Exit;
      end;
  end;
end;

function ReplaceAll(const S, Patten, NewString: string): string;
begin
  Result := StringReplace(S, Patten, NewString, [rfReplaceAll]);
end;

function RepeatChar(C: char; Times: integer): string;
begin
  Result := StringOfChar(C, Times);
end;

function GetYM: integer;
begin
  Result := GetYM(Date);
end;

function GetYM(Date: TDateTime): integer;
var
  Y, M, D: word;
begin
  DecodeDate(Date, Y, M, D);
  Result := (Y * 100) + M;
end;

function IsYM(Y, M: integer): boolean;
begin
  Result := (Y >= 1) and (Y <= 9999) and (M >= 1) and (M <= 12);
end;

function IsYM(YM: integer): boolean;
begin
  Result := IsYM(YM div 100, YM mod 100);
end;

function IsYM(YM, MinYM, MaxYM: integer): boolean;
begin
  Result := (YM >= MinYM) and (YM <= MaxYM) and IsYM(YM);
end;

function IsYM(const YM: string): boolean;
begin
  Result := IsYM(StrToYM(YM));
end;

function YMToStr(YM: integer): string;
begin
  if YM > 0 then
    Result := Format('%.6d', [YM]) else
    Result := '';
end;

function StrToYM(const S: string; DefValue: integer): integer;
var
  L: integer;
begin
  L := Length(S);
  if L = 6 then  {yyyymm}
    Result := StrToIntDef(S, DefValue) else
  if L = 7 then  {yyyy-mm}
    Result := StrToIntDef(Copy(S, 1, 4) + Copy(S, 6, 2), DefValue) else
    Result := DefValue;
end;

function DecodeYM(YM: integer; var Y, M: integer): boolean;
begin
  Y := YM div 100;
  M := YM mod 100;
  Result := IsYM(Y, M);
end;

function PrevYM(YM, Offset: integer): integer;
begin
  Result := NextYM(ym, - Offset);
end;

function PrevYM(const YM: string): string;
begin
  Result := YMToStr(PrevYM(StrToYM(YM)));
end;

function NextYM(YM, Offset: integer): integer;
var
  Y, M: integer;
begin
  {$IFDEF FPC}
  Y := 0; M := 0;
  {$ENDIF}
  if Offset = 0 then Result := YM else
  if DecodeYM(YM, Y, M) then
  begin
    Inc(Offset, Y * 12 + M - 1);
    Y := Offset div 12;
    M := Offset mod 12 + 1;
    Result := (Y * 100) + M;
  end
  else Result := 0;
end;

function NextYM(const YM: string): string;
begin
  Result := YMToStr(NextYM(StrToYM(YM)));
end;

function GetYMD: integer;
begin
  Result := GetYMD(Date);
end;

function GetYMD(Date: TDateTime): integer;
var
  Y, M, D: word;
begin
  DecodeDate(Date, Y, M, D);
  Result := (Y * 10000) + (M * 100) + D;
end;

function Today: integer;
begin
  Result := GetYMD;
end;

function IsYMD(Y, M, D: integer): boolean;
var
  T: TDateTime;
begin
  Result := TryEncodeDate(Y, M, D, T);
end;

function IsYMD(YMD: integer): boolean;overload;
var
  Y, M, D: integer;
begin
  {$IFDEF FPC}
  Y := 0; M := 0; D := 0;
  {$ENDIF}
  Result := DecodeYMD(YMD, Y, M, D);
end;

function IsYMD(const YMD: string): boolean;
begin
  Result := IsYMD(StrToYMD(YMD));
end;

function YMDToStr(YMD: integer): string;
begin
  if YMD > 0 then
    Result := Format('%.8d', [YMD]) else
    Result := '';
end;

function YMDToStr(YMD: integer; const Delimiter: string): string;
var
  Y, M, D: integer;
begin
  if YMD > 0 then
  begin
    D := YMD mod 100; YMD := YMD div 100;
    M := YMD mod 100;
    Y := YMD div 100;
    Result := Format('%.4d%s%.2d%s%.2d', [Y, Delimiter, M, Delimiter, D]);
  end
  else Result := '';
end;

function StrToYMD(const S: string; DefValue: integer): integer;
begin
  try
    Result := StrToInt(Copy(S, 1, 4)) * 10000;
    if Length(S) <= 8 then {yyyymmdd}
    begin
      Inc(Result, StrToInt(Copy(S, 5, 2)) * 100);
      Inc(Result, StrToInt(Copy(S, 7, 2)));
    end
    else {yyyy-mm-dd}
    begin
      Inc(Result, StrToInt(Copy(S, 6, 2)) * 100);
      Inc(Result, StrToInt(Copy(S, 9, 2)));
    end;
    if not IsYMD(Result) then
      Result := DefValue;
  except
    Result := DefValue;
  end;
end;

function YMDToDate(YMD: integer): TDateTime;
var
  Y, M, D: integer;
begin
  D := YMD mod 100; YMD := YMD div 100;
  M := YMD mod 100;
  Y := YMD div 100;
  if not TryEncodeDate(Y, M, D, Result) then Result := 0;
end;

function DecodeYMD(YMD: integer; var Y, M, D: integer): boolean;
begin
  D := YMD mod 100; YMD := YMD div 100;
  M := YMD mod 100;
  Y := YMD div 100;
  Result := IsYMD(Y, M, D);
end;

function NextYMD(YMD, Offset: integer): integer;
var
  T: TDateTime;
begin
  if Offset = 0 then Result := YMD else
  begin
    T := YmdToDate(YMD);
    if T > 1 then
      Result := GetYMD(IncDay(T, Offset)) else
      Result := 0;
  end;
end;

function PrevYMD(YMD, Offset: integer): integer;
begin
  Result := NextYMD(YMD, - Offset);
end;

{ md5 }

function MD5SumBuffer(const Buffer: pointer; Count: integer): string;
var
  M: TLiMD5;
begin
  M := TLiMD5.Create;
  try
    Result := M.SumBuffer(Buffer, Count);
  finally
    M.Free;
  end;
end;

function MD5SumString(const S: string): string;
var
  M: TLiMD5;
begin
  M := TLiMD5.Create;
  try
    Result := M.SumString(S);
  finally
    M.Free;
  end;
end;

function MD5SumAnsiString(const S: AnsiString): string;
var
  M: TLiMD5;
begin
  M := TLiMD5.Create;
  try
    Result := M.SumAnsiString(S);
  finally
    M.Free;
  end;
end;

function MD5SumWideString(const S: WideString): string;
var
  M: TLiMD5;
begin
  M := TLiMD5.Create;
  try
    Result := M.SumWideString(S);
  finally
    M.Free;
  end;
end;

function MD5SumStream(const Stream: TStream): string;
var
  M: TLiMD5;
begin
  M := TLiMD5.Create;
  try
    Result := M.SumStream(Stream);
  finally
    M.Free;
  end;
end;

function MD5SumFile(const FileName: string): string;
var
  M: TLiMD5;
begin
  M := TLiMD5.Create;
  try
    Result := M.SumFile(FileName);
  finally
    M.Free;
  end;
end;

function MD5TrySumFile(const FileName: string): string;
var
  S: TFileStream;
begin
  try
    Result := '';
    if FileExists(FileName) then
    begin
      S := TFileStream.Create(FileName, fmShareDenyWrite);
      try
        Result := MD5SumStream(S);
      finally
        S.Free;
      end;
    end;
  except
    Result := '';
  end;
end;

{ object }

procedure FreeAll(const Objects: TList);
var
  I: integer;
  M: TObject;
begin
  if Objects <> nil then
    for I := Objects.Count - 1 downto 0 do
      if I < Objects.Count then
      begin
        M := TObject(Objects[I]);
        Objects.Delete(I);
        if M <> nil then M.Free;
      end;
end;

procedure FreeAll(const Objects: array of TObject);
var
  I: integer;
  M: TObject;
begin
  for I := Length(Objects) - 1 downto 0 do
  begin
    M := TObject(Objects[I]);
    if M <> nil then M.Free;
  end;
end;

function LoadDLL(const FileName: string; var Handle: THandle): boolean;
var
  F: AnsiString;
begin
  F := FileName;
  Handle := LoadLibrary(PChar(F));
  Result := (Handle <> 0);
end;

procedure FreeDLL(Handle: THandle);
begin
  FreeLibrary(Handle);
end;

function GetProcAddr(Handle: THandle; const ProcName: string): pointer;
var
  F: AnsiString;
begin
  F := ProcName;
  Result := GetProcAddress(Handle, PAnsiChar(F));
end;

function stdin: integer;
begin
  {$IFDEF FPC}
  Result := StdInputHandle;
  {$ELSE}
  Result := GetStdhandle(STD_INPUT_HANDLE);
  {$ENDIF}
end;

function stdout: integer;
begin
  {$IFDEF FPC}
  Result := StdOutputHandle;
  {$ELSE}
  Result := GetStdhandle(STD_OUTPUT_HANDLE);
  {$ENDIF}
end;

function stderr: integer;
begin
  {$IFDEF FPC}
  Result := StdErrorHandle;
  {$ELSE}
  Result := GetStdhandle(STD_ERROR_HANDLE);
  {$ENDIF}
end;

function Gets: string;
begin
  System.Readln(Result);
end;

function Puts(const Text: string): integer;
begin
  Result := Length(Text);
  System.Write(Text);
end;

function Puts(S: TStream; const Text: string): integer;
begin
  Result := Length(Text);
  if Result > 0 then
    Result := S.Write(pchar(Text)^, Result
      {$IFDEF UNICODE}* sizeof(char){$ENDIF});
end;

function Putln: integer;
begin
  Result := Putln(sLineBreak);
end;

function Putln(const Text: string): integer;
begin
  Result := Length(Text);
  System.Writeln(Text);
end;

function Putln(S: TStream; const Text: string): integer;
begin
  Result := Puts(S, Text) + Puts(S, sLineBreak);
end;

function Putln(S: TStream): integer;
begin
  Result := Puts(S, sLineBreak);
end;

function HTTPDecode(const AStr: AnsiString): AnsiString;
var
  Sp, Rp, Cp: PAnsiChar;
  S: AnsiString;
begin
  SetLength(Result, Length(AStr));
  Sp := PAnsiChar(AStr);
  Rp := PAnsiChar(Result);
  Cp := Sp;
  try
    while Sp^ <> #0 do
    begin
      case Sp^ of
        '+': Rp^ := ' ';
        '%': begin
               // Look for an escaped % (%%) or %<hex> encoded character
               Inc(Sp);
               if Sp^ = '%' then
                 Rp^ := '%'
               else
               begin
                 Cp := Sp;
                 Inc(Sp);
                 if (Cp^ <> #0) and (Sp^ <> #0) then
                 begin
                   S := AnsiChar('$') + Cp^ + Sp^;
                   Rp^ := AnsiChar(StrToInt(string(S)));
                 end
                 else
                   Throw('Error decoding URL style (%%XX) encoded string at position %d',
                     [Cp - PAnsiChar(AStr)]);
               end;
             end;
      else
        Rp^ := Sp^;
      end;
      Inc(Rp);
      Inc(Sp);
    end;
  except
    on E:EConvertError do
      Throw('Invalid URL encoded character (%s) at position %d',
        [AnsiChar('%') + Cp^ + Sp^, Cp - PAnsiChar(AStr)])
  end;
  SetLength(Result, Rp - PAnsiChar(Result));
end;

function HTTPEncode(const AStr: AnsiString): AnsiString;
// The NoConversion set contains characters as specificed in RFC 1738 and
// should not be modified unless the standard changes.
const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')'];
var
  Sp, Rp: PAnsiChar;
begin
  SetLength(Result, Length(AStr) * 3);
  Sp := PAnsiChar(AStr);
  Rp := PAnsiChar(Result);
  while Sp^ <> #0 do
  begin
    if Sp^ in NoConversion then
      Rp^ := Sp^
    else
      if Sp^ = ' ' then
        Rp^ := '+'
      else
      begin
        FormatBuf(Rp^, 3, AnsiString('%%%.2x'), 6, [Ord(Sp^)]);
        Inc(Rp,2);
      end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - PAnsiChar(Result));
end;

function HTMLEncode(const AStr: string): string;
var
  Sp, Rp: pchar;
begin
  SetLength(Result, Length(AStr) * 10);
  Sp := pchar(AStr);
  Rp := pchar(Result);
  while Sp^ <> #0 do
  begin
    case Sp^ of
      '&': begin
             FormatBuf(Rp, 5, '&amp;', 5, []);
             Inc(Rp,4);
           end;
      '<',
      '>': begin
             if Sp^ = '<' then
               FormatBuf(Rp, 4, '&lt;', 4, [])
             else
               FormatBuf(Rp, 4, '&gt;', 4, []);
             Inc(Rp,3);
           end;
      '"': begin
             FormatBuf(Rp, 6, '&quot;', 6, []);
             Inc(Rp,5);
           end;
    else
      Rp^ := Sp^
    end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - pchar(Result));
end;

function HTMLDecode(const AStr: string): string;
var
  Sp, Rp, Cp, Tp: pchar;
  S: String;
  I, Code: Integer;
begin
  SetLength(Result, Length(AStr));
  Sp := pchar(AStr);
  Rp := pchar(Result);
  Cp := Sp;
  try
    while Sp^ <> #0 do
    begin
      case Sp^ of
        '&': begin
               Cp := Sp;
               Inc(Sp);
               case Sp^ of
                 'a': if StrPos(Sp, 'amp;') = Sp then  { do not localize }
                      begin
                        Inc(Sp, 3);
                        Rp^ := '&';
                      end;
                 'l',
                 'g': if (StrPos(Sp, 'lt;') = Sp) or (StrPos(Sp, 'gt;') = Sp) then { do not localize }
                      begin
                        Cp := Sp;
                        Inc(Sp, 2);
                        while (Sp^ <> ';') and (Sp^ <> #0) do
                          Inc(Sp);
                        if Cp^ = 'l' then
                          Rp^ := '<'
                        else
                          Rp^ := '>';
                      end;
                 'q': if StrPos(Sp, 'quot;') = Sp then  { do not localize }
                      begin
                        Inc(Sp,4);
                        Rp^ := '"';
                      end;
                 '#': begin
                        Tp := Sp;
                        Inc(Tp);
                        while (Sp^ <> ';') and (Sp^ <> #0) do
                          Inc(Sp);
                        SetString(S, Tp, Sp - Tp);
                        Val(S, I, Code);
                        if I >= $10000 then
                        begin
                          // Decode surrogate pair
                          Rp^ := Char(((I - $10000) div $400) + $d800);
                          Inc(Rp);
                          Rp^ := Char(((I - $10000) and $3ff) + $dc00);
                        end
                        else
                          Rp^ := Chr((I));
                      end;
                 else
                   Throw('Invalid HTML encoded character (%s) at position %d',
                     [Cp^ + Sp^, Cp - pchar(AStr)])
               end;
           end
      else
        Rp^ := Sp^;
      end;
      Inc(Rp);
      Inc(Sp);
    end;
  except
    on E:EConvertError do
      Throw('Invalid HTML encoded character (%s) at position %d',
        [Cp^ + Sp^, Cp - pchar(AStr)])
  end;
  SetLength(Result, Rp - pchar(Result));
end;

procedure Swap(var V1, V2: integer);
var
  T: integer;
begin
  T := V1;
  V1 := V2;
  V2 := T;
end;

{ TLiObject }

function TLiObject.RefCount: integer;
begin
  if Self <> nil then
    Result := FRefCount else
    Result := 0;
end;

function TLiObject.DecRefcount: integer;
begin
  if Self <> nil then
  begin
    Dec(FRefCount);
    Result := FRefCount;
    if Result = 0 then Free;
  end
  else Result := 0;
end;

function TLiObject.IncRefcount: integer;
begin
  if Self <> nil then
  begin
    Inc(FRefCount);
    Result := FRefCount;
  end
  else Result := 0;
end;

{ TLiNamedObject }

constructor TLiNamedObject.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

destructor TLiNamedObject.Destroy;
begin
  FName := '';
  inherited;
end;

function TLiNamedObject.SafeName: string;
begin
  if Self <> nil then Result := FName else Result := '';
end;

procedure TLiNamedObject.SetName(const AName: string);
begin
  FName := AName;
end;

{ TLiNamedObjectList }

function TLiNamedObjectList.GetCount: integer;
begin
  Result := FItems.Count;
end;

function TLiNamedObjectList.GetItem(Index: integer): TLiNamedObject;
begin
  Result := TLiNamedObject(FItems[Index]);
end;

function TLiNamedObjectList.GetName(Index: integer): string;
var
  M: TLiNamedObject;
begin
  M := GetItem(Index);
  if M <> nil then
    Result := M.FName else
    Result := '';
end;

function TLiNamedObjectList.GetNameList: string;
var
  I: integer;
begin
  Result := '';
  if GetCount > 0 then
  begin
    Result := GetItem(0).FName;
    for I := 1 to GetCount - 1 do
      Result := Result + ',' + GetItem(I).FName;
  end;
end;

procedure TLiNamedObjectList.SetAllowNil(Value: boolean);
var
  I: integer;
begin
  if FAllowNil <> Value then
  begin
    FAllowNil := Value;
    if not FAllowNil then
      for I := GetCount - 1 downto 0 do
        if FItems[I] = nil then
          FItems.Delete(I);
  end;
end;

procedure TLiNamedObjectList.SetCaseSensitive(Value: boolean);
begin
  if FCaseSensitive <> Value then
  begin
    FCaseSensitive := Value;
    if FSorted then
    begin
      FSorted := false;
      SetSorted(true);
    end;
  end;
end;

procedure TLiNamedObjectList.SetSorted(Value: boolean);
begin
  if FSorted <> Value then
  begin
    FSorted := Value;
    if FSorted then Sort;
  end;
end;

procedure TLiNamedObjectList.SetUnique(Value: boolean);

  procedure unique_sort(L, R: integer);
  var
    I, J: integer;
    M: pointer;
  begin
    repeat
      I := L;
      J := R;
      M := FItems[(L + R) div 2];
      repeat
         while PByte(M) > PByte(FItems[I]) do Inc(I);
         while PByte(M) < PByte(FItems[J]) do Dec(J);
         If I <= J then
         begin
           FItems.Exchange(I, J);
           Inc(I);
           Dec(J);
         end;
      until I > J;
      if L < J then unique_sort(L, J);
      L := I;
    until I >= R;
  end;

var
  I: integer;
begin
  if FUnique <> Value then
  begin
    FUnique := Value;
    if FUnique and (GetCount > 1) then
    try
      FInOrder := false;
      unique_sort(0, GetCount - 1);
      for I := GetCount - 1 downto 1 do
        if FItems[I] = FItems[I - 1] then
          Delete(I);
    finally
      if FSorted then
      begin
        FSorted := false;
        SetSorted(true);
      end;
    end;
  end;
end;

procedure TLiNamedObjectList.Sort;

  procedure name_sort(L, R: integer);
  var
    I, J: integer;
    S: string;
  begin
    repeat
      I := L;
      J := R;
      S := GetName((L + R) div 2);
      repeat
         while CompareString(S, GetName(I), FCaseSensitive) = crMore do Inc(I);
         while CompareString(S, GetName(J), FCaseSensitive) = crLess do Dec(J);
         If I <= J then
         begin
           FItems.Exchange(I, J);
           Inc(I);
           Dec(J);
         end;
      until I > J;
      if L < J then name_sort(L, J);
      L := I;
    until I >= R;
  end;

begin
  if GetCount > 1 then name_sort(0, GetCount - 1);
  FInOrder := true;
end;

procedure TLiNamedObjectList.Each(Func: TLiNamedObjectFunc; Data: pointer);
var
  I: integer;
begin
  for I := 0 to GetCount - 1 do
    if not Func(GetItem(I), Data) then
      Exit;
end;

constructor TLiNamedObjectList.Create;
begin
  FItems := TList.Create;
  FCaseSensitive := false;
  FUnique := false;
  FSorted := false;
  FInOrder := false;
  FAllowNil := true;
end;

destructor TLiNamedObjectList.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TLiNamedObjectList.Assign(Source: TLiNamedObjectList);
var
  I: integer;
begin
  if Self <> Source then
  begin
    Clear;
    for I := 0 to Source.GetCount - 1 do
      Add(Source[I]);
  end;
end;

procedure TLiNamedObjectList.Clear;
var
  I: integer;
begin
  for I := GetCount - 1 downto 0 do Delete(I);
end;

procedure TLiNamedObjectList.Delete(Index: integer);
var
  nobj: TLiNamedObject;
begin
  nobj := GetItem(Index);
  FItems.Delete(Index);
  nobj.DecRefcount;
end;

procedure TLiNamedObjectList.Remove(const Name: string);
var
  I: integer;
begin
  I := IndexOf(Name);
  if I >= 0 then Delete(I);
end;

procedure TLiNamedObjectList.Remove(Nobj: TLiNamedObject);
var
  I: integer;
begin
  I := IndexOf(Nobj);
  if I >= 0 then Delete(I);
end;

function TLiNamedObjectList.IndexOf(const Name: string): integer;
var
  L, R: Integer;
  V: TLiCompare;
begin
  R := GetCount - 1;
  if FSorted or FInOrder then
  begin
    L := 0;
    while L <= R do
    begin
      Result := (L + R) div 2;
      V := CompareString(Name, GetName(Result), FCaseSensitive);
      if V = crEqual then Exit else
      if V > crMore then
        L := Result + 1 else
        R := Result - 1;
    end;
  end
  else
  for L := 0 to R do
    if CompareString(Name, GetName(L), FCaseSensitive) = crEqual then
    begin
      Result := L;
      Exit;
    end;
  Result := -1;
end;

function TLiNamedObjectList.IndexOf(Nobj: TLiNamedObject): integer;
begin
  Result := FItems.IndexOf(Nobj);
end;

function TLiNamedObjectList.Add(Nobj: TLiNamedObject): integer;
var
  L, R, I: Integer;
  S: string;
begin
  if (Nobj = nil) and not FAllowNil then
  begin
    Result := -1;
    Exit;
  end;

  if FUnique then
  begin
    Result := FItems.IndexOf(Nobj);
    if Result >= 0 then Exit;
  end
  else Result := -1;

  if not FSorted or (GetCount = 0) then
  begin
    Result := FItems.Add(Nobj);
    FInOrder := false;
  end
  else
  if Nobj = nil then FItems.Insert(0, Nobj) else
  if Result < 0 then
  begin
    S := Nobj.FName;
    L := 0;
    R := GetCount - 1;
    repeat
      I := (L + R) div 2;
      if CompareString(S, GetName(I), FCaseSensitive) in [crMore, crEqual] then
        L := I + 1 else
        R := I - 1;
    until L > R;
    Result := L;
    FItems.Insert(L, Nobj);
  end
  else FItems.Insert(Result + 1, Nobj);

  Nobj.IncRefcount;
end;

function TLiNamedObjectList.Get(const Name: string): TLiNamedObject;
var
  I: integer;
begin
  I := IndexOf(Name);
  if I >= 0 then
    Result := GetItem(I) else
    Result := nil;
end;

{ TLiSpinLock }

constructor TLiSpinLock.Create;
begin
  FCriticalSection := SyncObjs.TCriticalSection.Create;
end;

destructor TLiSpinLock.Destroy;
begin
  FreeAndNil(FCriticalSection);
end;

procedure TLiSpinLock.Enter;
begin
  FCriticalSection.Enter;
end;

procedure TLiSpinLock.Leave;
begin
  FCriticalSection.Leave;
end;

function TLiSpinLock.TryEnter: boolean;
begin
  {$IFDEF FPC}
  FCriticalSection.Enter;
  Result := true;
  {$ELSE}
  Result := FCriticalSection.TryEnter;
  {$ENDIF}
end;

{ TLiMD5 }

procedure TLiMD5.FF(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
begin
  a^ := ROL(a^ + ((b^ and c^) or ((not b^) and d^)) + x^ + ac, s) + b^;
end;

function TLiMD5.GetDigest: string;

  function VS(V: cardinal): string;
  var
    B: array[0..3] of byte;
  begin
    {$IFDEF FPC}
    B[0] := 0;
    {$ENDIF}
    Move(V, B[0], 4);
    Result := Format('%.2x%.2x%.2x%.2x', [B[0], B[1], B[2], B[3]]);
  end;

begin
  Result := Format('%s%s%s%s', [VS(PA^), VS(PB^), VS(PC^), VS(PD^)]);
end;

procedure TLiMD5.GG(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
begin
  a^ := ROL(a^ + ((b^ and d^) or (c^ and (not d^))) + x^ + ac, s) + b^;
end;

procedure TLiMD5.HH(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
begin
  a^ := ROL(a^ + (b^ xor c^ xor d^) + x^ + ac, s) + b^;
end;

procedure TLiMD5.II(a, b, c, d, x: PCardinal; s: byte; ac: cardinal);
begin
  a^ := ROL(a^ + (c^ xor (b^ or (not d^))) + x^ + ac, s) + b^;
end;

procedure TLiMD5.Init;
begin
  FA := cardinal($67452301); PA := @FA;
  FB := cardinal($efcdab89); PB := @FB;
  FC := cardinal($98badcfe); PC := @FC;
  FD := cardinal($10325476); PD := @FD;
end;

function TLiMD5.ROL(A: cardinal; Amount: byte): cardinal;
const
  CARMASK = $80000000;
var
  X: byte;
begin
  for X := 1 to Amount do
    if (A and CARMASK) = CARMASK then
      A := (A shl 1) or $01 else
      A := (A shl 1);
   Result := A;
end;

function TLiMD5.SumAnsiString(const S: AnsiString): string;
begin
  Result := SumBuffer(pointer(S), Length(S));
end;

function TLiMD5.SumBuffer(const Buffer: pointer; Count: integer): string;
var
  buf: array[0..4159] of byte;
  src: pbyte;
  len: int64;
  eob: boolean;
  bytes, index: integer;
begin
  Init;
  src := pbyte(Buffer);
  eob := False;
  len := 0;
  repeat
    bytes := Min(4096, Count);
    Move(src^, buf[0], bytes);
    Inc(src, bytes);
    Dec(Count, bytes);
    len := len + bytes;
    if bytes <> 4096 then
    begin
      buf[bytes] := $80;
      Inc(bytes);
      while (bytes mod 64) <> 56 do
      begin
        buf[bytes] := 0;
        Inc(bytes);
      end;
      len := len * 8;
      Move(len, buf[bytes], 8);
      Inc(bytes, 8);
      eob := True;
    end;
    index := 0;
    repeat
      Move(buf[index], FBuffer, 64);
      Transform;
      Inc(index, 64);
    until index = bytes;
  until eob;
  Result := GetDigest;
end;

function TLiMD5.SumFile(const FileName: string): string;
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmShareDenyWrite);
  try
    Result := SumStream(F);
  finally
    F.Free;
  end;
end;

function TLiMD5.SumString(const S: string): string;
begin
  Result := SumBuffer(pointer(S), Length(S) * sizeof(char));
end;

function TLiMD5.SumWideString(const S: WideString): string;
begin
  Result := SumBuffer(pointer(S), Length(S) * sizeof(WideChar));
end;

function TLiMD5.SumStream(const Stream: TStream): string;
var
  buf: array[0..4159] of byte;
  len: int64;
  eof: Boolean;
  bytes, index: integer;
begin
  Init;
  eof := False;
  len := 0;
  repeat
    bytes := Stream.Read(buf[0], 4096);
    len := len + bytes;
    if bytes <> 4096 then
    begin
      buf[bytes] := $80;
      Inc(bytes);
      while (bytes mod 64) <> 56 do
      begin
        buf[bytes] := 0;
        Inc(bytes);
      end;
      len := len * 8;
      Move(len, buf[bytes], 8);
      Inc(bytes, 8);
      eof := True;
    end;
    index := 0;
    repeat
      Move(buf[index], FBuffer, 64);
      Transform;
      Inc(index, 64);
    until index = bytes;
  until eof;
  Result := GetDigest;
end;

procedure TLiMD5.Transform;
const
  S11 = 7;  S12 = 12;  S13 = 17;  S14 = 22;
  S21 = 5;  S22 = 9;   S23 = 14;  S24 = 20;
  S31 = 4;  S32 = 11;  S33 = 16;  S34 = 23;
  S41 = 6;  S42 = 10;  S43 = 15;  S44 = 21;
var
  FAA, FBB, FCC, FDD: cardinal;
begin
  FAA := FA;
  FBB := FB;
  FCC := FC;
  FDD := FD;

  { Round 1 }

  FF (PA, PB, PC, PD, @FBuffer[ 0], S11, cardinal($d76aa478)); {  1 }
  FF (PD, PA, PB, PC, @FBuffer[ 1], S12, cardinal($e8c7b756)); {  2 }
  FF (PC, PD, PA, PB, @FBuffer[ 2], S13, cardinal($242070db)); {  3 }
  FF (PB, PC, PD, PA, @FBuffer[ 3], S14, cardinal($c1bdceee)); {  4 }
  FF (PA, PB, PC, PD, @FBuffer[ 4], S11, cardinal($f57c0faf)); {  5 }
  FF (PD, PA, PB, PC, @FBuffer[ 5], S12, cardinal($4787c62a)); {  6 }
  FF (PC, PD, PA, PB, @FBuffer[ 6], S13, cardinal($a8304613)); {  7 }
  FF (PB, PC, PD, PA, @FBuffer[ 7], S14, cardinal($fd469501)); {  8 }
  FF (PA, PB, PC, PD, @FBuffer[ 8], S11, cardinal($698098d8)); {  9 }
  FF (PD, PA, PB, PC, @FBuffer[ 9], S12, cardinal($8b44f7af)); { 10 }
  FF (PC, PD, PA, PB, @FBuffer[10], S13, cardinal($ffff5bb1)); { 11 }
  FF (PB, PC, PD, PA, @FBuffer[11], S14, cardinal($895cd7be)); { 12 }
  FF (PA, PB, PC, PD, @FBuffer[12], S11, cardinal($6b901122)); { 13 }
  FF (PD, PA, PB, PC, @FBuffer[13], S12, cardinal($fd987193)); { 14 }
  FF (PC, PD, PA, PB, @FBuffer[14], S13, cardinal($a679438e)); { 15 }
  FF (PB, PC, PD, PA, @FBuffer[15], S14, cardinal($49b40821)); { 16 }

  { Round 2 }

  GG (PA, PB, PC, PD, @FBuffer[ 1], S21, cardinal($f61e2562)); { 17 }
  GG (PD, PA, PB, PC, @FBuffer[ 6], S22, cardinal($c040b340)); { 18 }
  GG (PC, PD, PA, PB, @FBuffer[11], S23, cardinal($265e5a51)); { 19 }
  GG (PB, PC, PD, PA, @FBuffer[ 0], S24, cardinal($e9b6c7aa)); { 20 }
  GG (PA, PB, PC, PD, @FBuffer[ 5], S21, cardinal($d62f105d)); { 21 }
  GG (PD, PA, PB, PC, @FBuffer[10], S22,  cardinal($2441453)); { 22 }
  GG (PC, PD, PA, PB, @FBuffer[15], S23, cardinal($d8a1e681)); { 23 }
  GG (PB, PC, PD, PA, @FBuffer[ 4], S24, cardinal($e7d3fbc8)); { 24 }
  GG (PA, PB, PC, PD, @FBuffer[ 9], S21, cardinal($21e1cde6)); { 25 }
  GG (PD, PA, PB, PC, @FBuffer[14], S22, cardinal($c33707d6)); { 26 }
  GG (PC, PD, PA, PB, @FBuffer[ 3], S23, cardinal($f4d50d87)); { 27 }
  GG (PB, PC, PD, PA, @FBuffer[ 8], S24, cardinal($455a14ed)); { 28 }
  GG (PA, PB, PC, PD, @FBuffer[13], S21, cardinal($a9e3e905)); { 29 }
  GG (PD, PA, PB, PC, @FBuffer[ 2], S22, cardinal($fcefa3f8)); { 30 }
  GG (PC, PD, PA, PB, @FBuffer[ 7], S23, cardinal($676f02d9)); { 31 }
  GG (PB, PC, PD, PA, @FBuffer[12], S24, cardinal($8d2a4c8a)); { 32 }

  { Round 3 }

  HH (PA, PB, PC, PD, @FBuffer[ 5], S31, cardinal($fffa3942)); { 33 }
  HH (PD, PA, PB, PC, @FBuffer[ 8], S32, cardinal($8771f681)); { 34 }
  HH (PC, PD, PA, PB, @FBuffer[11], S33, cardinal($6d9d6122)); { 35 }
  HH (PB, PC, PD, PA, @FBuffer[14], S34, cardinal($fde5380c)); { 36 }
  HH (PA, PB, PC, PD, @FBuffer[ 1], S31, cardinal($a4beea44)); { 37 }
  HH (PD, PA, PB, PC, @FBuffer[ 4], S32, cardinal($4bdecfa9)); { 38 }
  HH (PC, PD, PA, PB, @FBuffer[ 7], S33, cardinal($f6bb4b60)); { 39 }
  HH (PB, PC, PD, PA, @FBuffer[10], S34, cardinal($bebfbc70)); { 40 }
  HH (PA, PB, PC, PD, @FBuffer[13], S31, cardinal($289b7ec6)); { 41 }
  HH (PD, PA, PB, PC, @FBuffer[ 0], S32, cardinal($eaa127fa)); { 42 }
  HH (PC, PD, PA, PB, @FBuffer[ 3], S33, cardinal($d4ef3085)); { 43 }
  HH (PB, PC, PD, PA, @FBuffer[ 6], S34, cardinal($04881d05)); { 44 }
  HH (PA, PB, PC, PD, @FBuffer[ 9], S31, cardinal($d9d4d039)); { 45 }
  HH (PD, PA, PB, PC, @FBuffer[12], S32, cardinal($e6db99e5)); { 46 }
  HH (PC, PD, PA, PB, @FBuffer[15], S33, cardinal($1fa27cf8)); { 47 }
  HH (PB, PC, PD, PA, @FBuffer[ 2], S34, cardinal($c4ac5665)); { 48 }

  { Round 4 }

  II (PA, PB, PC, PD, @FBuffer[ 0], S41, cardinal($f4292244)); { 49 }
  II (PD, PA, PB, PC, @FBuffer[ 7], S42, cardinal($432aff97)); { 50 }
  II (PC, PD, PA, PB, @FBuffer[14], S43, cardinal($ab9423a7)); { 51 }
  II (PB, PC, PD, PA, @FBuffer[ 5], S44, cardinal($fc93a039)); { 52 }
  II (PA, PB, PC, PD, @FBuffer[12], S41, cardinal($655b59c3)); { 53 }
  II (PD, PA, PB, PC, @FBuffer[ 3], S42, cardinal($8f0ccc92)); { 54 }
  II (PC, PD, PA, PB, @FBuffer[10], S43, cardinal($ffeff47d)); { 55 }
  II (PB, PC, PD, PA, @FBuffer[ 1], S44, cardinal($85845dd1)); { 56 }
  II (PA, PB, PC, PD, @FBuffer[ 8], S41, cardinal($6fa87e4f)); { 57 }
  II (PD, PA, PB, PC, @FBuffer[15], S42, cardinal($fe2ce6e0)); { 58 }
  II (PC, PD, PA, PB, @FBuffer[ 6], S43, cardinal($a3014314)); { 59 }
  II (PB, PC, PD, PA, @FBuffer[13], S44, cardinal($4e0811a1)); { 60 }
  II (PA, PB, PC, PD, @FBuffer[ 4], S41, cardinal($f7537e82)); { 61 }
  II (PD, PA, PB, PC, @FBuffer[11], S42, cardinal($bd3af235)); { 62 }
  II (PC, PD, PA, PB, @FBuffer[ 2], S43, cardinal($2ad7d2bb)); { 63 }
  II (PB, PC, PD, PA, @FBuffer[ 9], S44, cardinal($eb86d391)); { 64 }

  FA := FA + FAA;
  FB := FB + FBB;
  FC := FC + FCC;
  FD := FD + FDD;

  FillChar(FBuffer, SizeOf(FBuffer), #0);
end;

end.