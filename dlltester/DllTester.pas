unit DllTester;

interface

uses
  Windows, SysUtils, Classes;

procedure DllTesting;

{$IFDEF CPUX64} // for 64-bit DLL
function ColumnToIndex(const Col: PChar; var Idx: integer): boolean;
                       stdcall; external 'PinnUtil64.dll' name 'ColumnToIndexA';
function IndexToColumn(const index: integer; Col: PChar; var Len: integer): boolean;
                       stdcall; external 'PinnUtil64.dll' name 'IndexToColumnA';
function ColumnToIndexW(const Col: PWideChar; var Idx: integer): boolean;
                       stdcall; external 'PinnUtil64.dll';
function IndexToColumnW(const index: integer; Col: PWideChar; var Len: integer): boolean;
                       stdcall; external 'PinnUtil64.dll';
{$ELSE} // for 32-bit DLL
function ColumnToIndex(const Col: PChar; var Idx: integer): boolean;
                       stdcall; external 'PinnUtil32.dll' name 'ColumnToIndexA';
function IndexToColumn(const index: integer; Col: PChar; var Len: integer): boolean;
                       stdcall; external 'PinnUtil32.dll' name 'IndexToColumnA';
function ColumnToIndexW(const Col: PWideChar; var Idx: integer): boolean;
                       stdcall; external 'PinnUtil32.dll';
function IndexToColumnW(const index: integer; Col: PWideChar; var Len: integer): boolean;
                       stdcall; external 'PinnUtil32.dll';
{$ENDIF}

implementation

procedure InitializeTestData(var list: TStrings); forward;

procedure DllTesting;
var
    col: WideString;
    colBuf: WideString;
    pCol: PWideChar;
    idx, cLen, cLenX: integer;
    cNames: TStrings;
    i: integer;
    sp, sp2: string;
begin
    // Build test data
    cNames := TStringList.Create;
    InitializeTestData(cNames);

    // Get buffer address and size
    SetLength(colBuf, 2);
    pCol := @colBuf[1];
    cLen := Length(colBuf);
    cLenX := Length(colBuf);

    // Perform tests by traversing test data
    for i := 0 to cNames.Count-1 do
    begin
        col := WideString(cNames[i]);
        ColumnToIndexW(PWideChar(col), idx);
        IndexToColumnW(idx, pCol, cLenX);
        if cLenX > cLen then
        begin
            SetLength(colBuf, cLenX);
            pCol := @colBuf[1];
            cLen := Length(colBuf);
            IndexToColumnW(idx, pCol, cLenX);
        end;
        // Formatting for output alignment
        sp := StringOfChar(' ', 5 - Length(pCol));
        sp2 := StringOfChar(' ', 5 - Length(IntToStr(idx)));
        WriteLn(String(col), sp, ' => ', idx, sp2, ' => ', String(pCol));
    end;
    cNames.Free;
end;

procedure InitializeTestData(var list: TStrings);
begin
    list.Append('A');
    list.Append('Aa');
    list.Append('CF');
    list.Append('DFP');
    list.Append('WZZ');
    list.Append('XFD');
    list.Append('AAA');
    list.Append('AAZ');
end;

end.

