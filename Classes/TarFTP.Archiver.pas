unit TarFTP.Archiver;

interface

uses
  SysUtils, Classes, TarFTP.Interfaces, LibTar, IOUtils;

type
  TTarArchiver = class(TInterfacedObject, IArchiver)
  private
    FOnProgress: TProgressEvent;
    FSourceFiles : TStringList;
    FClean : Boolean;
    FTar : TTarWriter;
    FOutStream : TStream;

    procedure DoProgress(CurrentItem, TotalItems : Integer;
      BytesProcessed, TotalBytes : Int64);
    procedure CompressFile(Tar : TTarWriter; const FileName : String);

    procedure Cleanup;
  public
  { IArchiver }
    function GetOnProgress : TProgressEvent;
    procedure SetOnProgress(Value : TProgressEvent);
    property OnProgress : TProgressEvent read GetOnProgress
        write SetOnProgress;

    procedure AddFile(const FileName : String);
    procedure CompressToFile(const OutputFile : String);

  { Common }
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses TarFTP.Types, TarFTP.Utils;

{ TTarArchiver }

procedure TTarArchiver.AddFile(const FileName: String);
var
  fullPath : String;
begin
  Cleanup;
  fullPath := TPath.GetFullPath( FileName );
  FSourceFiles.Add( fullPath );
end;

procedure TTarArchiver.Cleanup;
begin
  if not FClean then
    begin
      FClean := True;
      FSourceFiles.Clear;
      FreeAndNil( FTar );
      FreeAndNil( FOutStream );
    end;
end;

procedure TTarArchiver.CompressFile(Tar: TTarWriter; const FileName: String);
begin
  Tar.AddFile( FileName, AnsiString(ExtractFileName( FileName )) );
end;

procedure TTarArchiver.CompressToFile(const OutputFile: String);
var
  tar : TTarWriter;
  outStream : TStream;
  srcFile : String;
  bytesProcessed, totalBytes : Int64;
  I : Integer;
begin
  if FSourceFiles.Count = 0 then
    raise ENoFilesToCompress.Create( 'Nothing to compress. Please select ' +
                                     'at least a single file' );

  Cleanup;
  outStream := TFileStream.Create( OutputFile, fmCreate );
  try
    FClean := False;
    FOutStream := outStream;

    tar := TTarWriter.Create( outStream );
    try
      FTar := tar;

      totalBytes := 0;
      for srcFile in FSourceFiles do
        totalBytes := totalBytes + GetFileSize( srcFile );

      bytesProcessed := 0;
      for I := 0 to FSourceFiles.Count - 1 do
      begin
        srcFile := FSourceFiles[ I ];
        DoProgress( I + 1, FSourceFiles.Count, bytesProcessed, totalBytes );
        CompressFile( tar, srcFile );
        bytesProcessed := bytesProcessed + GetFileSize( srcFile );
      end;

      tar.Finalize;
    finally
      tar.Free;
    end;
  finally
    FClean := True;
    FTar := nil;
    FOutStream := nil;
    FSourceFiles.Clear;
    outStream.Free;
  end;
end;

constructor TTarArchiver.Create;
begin
  FClean := True;
  FSourceFiles := TStringList.Create;
  FSourceFiles.CaseSensitive := False;
  FSourceFiles.Duplicates := dupIgnore;
end;

destructor TTarArchiver.Destroy;
begin
  Cleanup;
  FreeAndNil( FSourceFiles );
  inherited;
end;

procedure TTarArchiver.DoProgress(CurrentItem, TotalItems: Integer;
  BytesProcessed, TotalBytes: Int64);
begin
  if Assigned( FOnProgress ) then
    FOnProgress( CurrentItem, TotalItems, BytesProcessed, TotalBytes );
end;

function TTarArchiver.GetOnProgress: TProgressEvent;
begin
  Result := FOnProgress;
end;

procedure TTarArchiver.SetOnProgress(Value: TProgressEvent);
begin
  FOnProgress := Value;
end;

end.
