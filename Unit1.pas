unit Unit1;

interface

uses Classes, Generics.Collections, Generics.Defaults;

type
	TMenuItem = (
    	miAdd, 
        miCheck, 
        miDelete, 
        miCross, 
        miSub,
        miSymSub, 
        miDecMul, 
        miQuit);

	Square = record
		a, b: Real;
	end;

	TSquareList = TList<Square>;
    TSets = array ['A' .. 'B'] of TSquareList; 
var
	Sets: TSets;
	MenuItems: array [miAdd .. miQuit] of String = (
		'Добавить элемент во множество',
		'Проверить элемент во множестве',
		'Удалить элемент из множества',
		'Пересечение множеств A & B',
		'Разность множеств',
		'Симметричная разность B Δ A',
		'Декартово произведение B × A',
        'Выход'
	);

procedure Menu;
procedure Init;
procedure Deinit;

implementation
Var
	Comparer: IComparer<Square>;

procedure Print(List: TSquareList);
var
	I: Integer;
begin
	if List.Count = 0 then
    	Writeln('Пустое множество')
    else
        for I := 0 to List.Count - 1 do
            Writeln(List[I].a:0:0, ', ', List[I].b:0:0, ' = ', (List[I].a * List[I].b):0:0);
end;

procedure Add(List: TSquareList);
Var
	a, b: Real;
	Sq: Square;
	I: Integer;
begin
	Writeln('Введите стороны прямоугольника (A,B):');
	readln(a, b);
	Sq.a := a;
	Sq.b := b;
	List.BinarySearch(Sq, I);
	List.Insert(I, Sq);
	Print(List);
end;

procedure Delete(List: TSquareList);
Var
	I: Integer;
begin
	Writeln('Введите индекс прямоугольника для удаления из множества:');
	readln(I);
	List.Delete(I);
	Print(List);
end;

procedure Check(List: TSquareList);
Var
	a, b: Real;
	I: Integer;
begin
	Writeln('Введите искомые стороны прямоугольника (A,B):');
	readln(a, b);

	for I := 0 to List.Count - 1 do
		if	((a = List[I].a) and (b = List[I].b)) or 
        	((b = List[I].a) and (a = List[I].b))
        then
		begin
			Writeln('Прямоугольник с искомыми сторонами найден');
			Exit;
		end;
	Writeln('Прямоугольник с искомыми сторонами НЕ найден');
end;

function Conj(Sets: TSets): TSquareList;
var
  	I: Char;
    J: Integer;
    Prev: Square;
begin
	Result := TSquareList.Create(Comparer);
    
    // добавляем оба множества
    for I := Low(Sets) to High(Sets) do
    begin
    	Result.AddRange(Sets[i]);    		
    end;
    Result.Sort;

    // удаляем дубликаты
    for J := Result.Count - 1 downto 1 do
    begin
    	Prev := Result[j];
        if Comparer.Compare(Prev, Result[j-1]) = 0 then
    		Result.Remove(Prev);
    end;
end;

function Cross(Sets: TSets): TSquareList;
var
  	I, J: Char;
    K: Integer;
begin
	Result := TSquareList.Create(Comparer);
    
    // перебираем все множества с одной стороны (по i)
    for I := Low(Sets) to High(Sets) do
    begin
        // перебираем множества с другой стороны (с которыми будем сравнивать, по j)
    	for J := Succ(I) to High(Sets) do
        	// перебираем элементы 1-го множества по k и ищем их во 2-м.
    		for K := 0 to Sets[i].Count - 1 do
            	// Если элемент k в 1-ом множестве (по i) найден во 2-м множестве (по j)...
            	if Sets[j].Contains(Sets[i][k]) and
                	// ...и ещё не содержится в пересечении...
                	(not Result.Contains(Sets[i][k])) 
                then
                	//...то мы его добавляем
                	Result.Add(Sets[i][k]);			
    end;
    Result.Sort;
end;

function Subtract(Sets: TSets; From, What: Char): TSquareList;
var
  	I: Integer;
begin
	Result := TSquareList.Create(Comparer);
    Result.AddRange(Sets[From]);
    
    // перебираем все множества с одной стороны (по i)
    for I := 0 to Sets[What].Count - 1 do
    begin
    	if Result.Contains(Sets[What][I]) then
        	Result.Remove(Sets[What][I]);	
    end;
    Result.Sort;
end;

function SymSubtract(Sets: TSets): TSquareList;
var
  	I: Char;
    NewSets: TSets;
begin
	NewSets['A'] := Subtract(Sets, 'A', 'B');
	NewSets['B'] := Subtract(Sets, 'B', 'A');
    Result := Conj(NewSets);
    for I := Low(NewSets) to High(NewSets) do
		NewSets[I].Destroy; 
end;

// Декартово (прямое) произведение
procedure DirectMul(Sets: TSets);
var
  	I, J: Char;
    K, L: Integer;
    Result: TSquareList;
begin
	Result := TSquareList.Create(Comparer);
    
    // перебираем все множества с одной стороны (по i)
    for I := Low(Sets) to High(Sets) do
    begin
        // перебираем множества с другой стороны (с которыми будем сравнивать, по j)
    	for J := Succ(I) to High(Sets) do
        	// перебираем элементы 1-го множества по k
    		for K := 0 to Sets[i].Count - 1 do
		    	// перебираем элементы 2-го множества по l 
    			for L := 0 to Sets[j].Count - 1 do
                	Write('([', Sets[i][k].a:0:0, ',', Sets[i][k].b:0:0, 
                    		'],[', 
                        		Sets[j][l].a:0:0, ',', Sets[j][l].b:0:0, ']) ');	
    end;
    WriteLn;
    Result.Destroy;
end;

Function GetTheSet(msg: String): Char;
begin
    repeat
        Writeln(msg);
        readln(Result);
        Result := UpCase(Result);
        if (Result = 'A') or (Result = 'B') then
            break
        else
            Writeln('Введите A или B');
    until False;
end;

procedure Menu;
var
	I: TMenuItem;
    MenuItem: Integer;
	ASet, BSet: Char;
    ResultSet: TSquareList;
begin
	while True do
	begin

		for I := miAdd to miDecMul do
			Writeln(Integer(I), ' - ', MenuItems[I]);

		readln(MenuItem);
		case TMenuItem(MenuItem) of
		miAdd, miDelete, miCheck:
			begin
                Aset := GetTheSet('Какое множество? (A или B)');
                
				case TMenuItem(MenuItem) of
				miAdd:
					Add(Sets[Aset]);
				miDelete:
					Delete(Sets[Aset]);
				miCheck:
					Check(Sets[Aset]);
				end;
			end;
		miCross:
       		begin
                ResultSet := Cross(Sets);
                Print(ResultSet);
                ResultSet.Destroy;
            end; 	
		miSub:
            begin
            	ASet := GetTheSet('Из какого множества вычитаем? (A или B)');
                BSet := GetTheSet('Какое множество вычитаем из первого? (A или B)');
                
                ResultSet := Subtract(Sets, ASet, BSet);
                Print(ResultSet);
                ResultSet.Destroy;
            end;
        miSymSub:
            begin
                ResultSet := SymSubtract(Sets);
                Print(ResultSet);
                ResultSet.Destroy;
            end;
        miDecMul:
        	begin
            	DirectMul(Sets);    
            end;
		miQuit:
			break;
		end;
	end;
end;

procedure Init;
var
	I: Char;
begin
	Comparer := TComparer<Square>.Construct( 
    	function(const Left, Right: Square): Integer
		begin 
        	if Left.a * Left.b > Right.a * Right.b then 
            	Result := 1 
            else if Left.a * Left.b < Right.a * Right.b then 
            	Result := -1 
            else 
            	Result := 0; 
        end);

	for I := Low(Sets) to High(Sets) do
		Sets[I] := TSquareList.Create(Comparer);
end;

procedure Deinit;
var
	I: Char;
begin
	for I := Low(Sets) to High(Sets) do
		Sets[I].Destroy;
end;

end.
