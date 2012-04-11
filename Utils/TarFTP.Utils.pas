unit TarFTP.Utils;

interface

uses
  SysUtils;

function GetFileSize(const FileName : String) : Int64;

function SizeToStr(Size : Int64) : String;

implementation

function GetFileSize(const FileName : String) : Int64;
var
  SearchRec : TSearchRec;
begin
  if FindFirst( FileName, faAnyFile, SearchRec ) = 0 then
    try
      Result := SearchRec.Size;
    finally
      FindClose( SearchRec );
    end
  else
    Result := 0;
end;

type
  TSizeOrder = (
    soBytes, soKBytes, soMBytes, soGBytes, soTBytes
  );

const
  KB = 1024;
  MB = KB * 1024;
  GB = MB * Int64(1024);
  TB = GB * Int64(1024);

  SIZES : array[ TSizeOrder ] of Int64 = (
    1, KB, MB, GB, TB
  );

  SIZE_STR : array[ TSizeOrder ] of String = (
    'bytes', 'KB', 'MB', 'GB', 'TB'
  );

function SizeToStr(Size : Int64) : String;
var
  order : TSizeOrder;
  value : Extended;
begin
  order := soBytes;

  while order < High( order ) do
  begin
    if Size < SIZES[ order ] then
      begin
        if order > soBytes then order := Pred( order );
        Break;
      end;
    order := Succ( order );
  end;

  value := Size / SIZES[ order ];
  Result := Format( '%.2f %s', [ value, SIZE_STR[ order ] ] );
end;

end.
