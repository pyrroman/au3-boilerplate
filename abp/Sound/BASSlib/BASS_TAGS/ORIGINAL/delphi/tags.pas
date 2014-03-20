{
Tags.dll written by Wraith, 2k5-2k6
Delphi Wrapper written by Chris Troesken 
}

unit tags;

interface

uses
  Windows;

function TAGS_Read(handle: DWORD; const fmt: PAnsiChar): PAnsiChar; stdcall; external 'tags.dll';
function TAGS_GetLastErrorDesc: PAnsiChar; stdcall; external 'tags.dll';
function TAGS_GetVersion(): DWORD; stdcall; external 'tags.dll';

implementation
end.
