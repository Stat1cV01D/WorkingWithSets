program WorkingWithSets;

{$APPTYPE CONSOLE}

uses
	Windows,
	SysUtils,
	Unit1 in 'Unit1.pas';

begin
	SetConsoleCP(1251);
	SetConsoleOutputCP(1251);

	Init;
	Menu;
	Deinit;
end.
