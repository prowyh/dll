unit XlUtil;

interface

uses
    SysUtils, Variants;

function ColumnToIndexA(const Col: PAnsiChar; var Idx: integer): boolean; stdcall;
function IndexToColumnA(const Idx: Integer; Col: PAnsiChar; var ColLen: integer): boolean; stdcall;
function ColumnToIndexW(const Col: PWideChar; var Idx: integer): boolean; stdcall;
function IndexToColumnW(const Idx: Integer; Col: PWideChar; var ColLen: integer): boolean; stdcall;

exports
    ColumnToIndexA,
    IndexToColumnA,
    ColumnToIndexW,
    IndexToColumnW;

implementation

function ColumnToIndexA(const Col: PAnsiChar; var Idx: integer): boolean; stdcall;
var
    ci: integer;
    i, n: integer;
    c: AnsiChar;
    succeed: boolean;
begin
    if not Assigned(Col) then       // NULL pointer to column name
    begin
        result := false;
        exit;
    end;

    ci := 0;
    succeed := true;
    for i := 0 to Length(Col) - 1 do    // Col is a pointer to NULL-terminated column name
    begin
        c := Col[i];

        if c in ['a'..'z'] then
          n := Ord(c) - 32 - Ord('A') + 1
        else if c in ['A'..'Z'] then
          n := Ord(c) - Ord('A') + 1
        else begin
            succeed := false;       // There is illegal char in column name
            break;
        end;

        ci := ci * 26 + n;
    end;

    Idx := ci;
    result := succeed;
end;

function IndexToColumnA(const Idx: Integer; Col: PAnsiChar; var ColLen: integer): boolean; stdcall;
var
    aCol: array[0..10] of AnsiChar;
    aColLen: integer;
    qi: integer;
    i: integer;
begin
    if (Idx <= 0) Or (not Assigned(Col)) Or (ColLen <= 0) then
    begin
        result := false;
        exit;
    end;

    qi := Idx;
    i := 0;
    while qi > 0 do
    begin
        dec(qi);
        aCol[i] := AnsiChar(qi mod 26 + Ord('A'));
        inc(i);
        qi := qi div 26;
    end;
    aCol[i] := AnsiChar(0);

    aColLen := i;
    if aColLen + 1 > ColLen then
    begin
        ColLen := aColLen + 1;
        aColLen := 0;
    end;
    // Copy chars from aCol to Col reversely
    for i := 0 to aColLen - 1 do
    begin
        Col[i] := aCol[aColLen - i - 1];
    end;
    Col[aColLen] := AnsiChar(0); // Append NULL char

    result := true;
end;

function ColumnToIndexW(const Col: PWideChar; var Idx: integer): boolean; stdcall;
var
    ci: integer;
    i, n: integer;
    c: WideChar;
    succeed: boolean;
begin
    if not Assigned(Col) then
    begin
        result := false;
        exit;
    end;

    succeed := true;
    ci := 0;
    for i := 0 to Length(col) - 1 do
    begin
        c := col[i];
        if (c >= WideChar('a')) And (c <= WideChar('z')) then
            n := Ord(c) - 32 - Ord(WideChar('A')) + 1
        else if (c >= WideChar('A')) And (c <= WideChar('Z')) then
            n := Ord(c) - Ord(WideChar('A')) + 1
        else begin
            succeed := false;
            break;
        end;

        ci := ci * 26 + n;
    end;

    Idx := ci;
    result := succeed;
end;

function IndexToColumnW(const Idx: Integer; Col: PWideChar; var ColLen: integer): boolean; stdcall;
var
    aCol: array[0..10] of WideChar;
    aColLen: integer;
    qi: integer;
    i: integer;
begin
    if (Idx <= 0) Or (not Assigned(Col)) Or (ColLen <= 0) then
    begin
        result := false;        // Parameters validation
        exit;
    end;

    qi := Idx;
    i := 0;
    while qi > 0 do
    begin
        dec(qi);
        aCol[i] := WideChar(qi mod 26 + Ord(WideChar('A')));
        inc(i);
        qi := qi div 26;
    end;
    aCol[i] := WideChar(0);

    aColLen := i;
    if aColLen + 1 > ColLen then
    begin
        ColLen := aColLen + 1;  // Return the required buf size
        aColLen := 0;
    end;
    // Copy WideChar from aCol to Col reversely
    for i := 0 to aColLen - 1 do
    begin
        Col[i] := aCol[aColLen - i - 1];
    end;
    Col[aColLen] := WideChar(0); // Empty string when buf too small

    result := true;
end;

end.

