/* PROJEKT na zaliczenie */
/* Patryk Wirkus */
/*Tytu�: Wyszukiwanie zwi�zk�w oraz zale�no�ci mi�dzy danymi poszczeg�lnuch zawodnik�w z gry FIFA19.*/
/* �r�d�o zaimportowanej bazy danych: KAGGLE, plik "data" - zawodnicy z gry FIFA 19. */
/* Cel projektu: G��wnym celem projektu jest dokonanie analizy por�wnawczej zawodnik�w z gry FIFA 19,
				 na podstawie danych zawartych w tabeli, czyli m.in: dane osobiste, umiej�tno�ci 
				 pi�karskie, atrybuty fizyczne, a tak�e aktualna warto�� rynkowa.*/

/*
WST�PNA uwaga dotycz�ca dw�ch u�ytych funkcji.
"Unable to load the Java Virtual Machine. Please see the installation instructions or system administrator."
WY�WIETLA SI� TO PRZY:
- u�yciu PROC FREQ do wykres�w, tj.  4 u�ycie tej procedury	(ROBIONE NA PODSTAWIE SKRYPTU)
- u�cyiu SGPLOT												(ROBIONE NA PODSTAWIE HELP)
Po wyja�nieniu:
Kod tych dw�ch procedur jest prawid�owy. Z tym �e, prawdopodobnie NIE zainstalowa�em pewnej cz�ci programu, 
st�d te dwie funkcje nie dzia�aj�. Natomiast, na PG wszystko odzia�a poprawnie.
*/ 

/* Pierwszym krokiem naszego projektu jest import danych, tu: plik 'data' w formacie csv. */
LIBNAME DANE BASE "Z:\Studiav2\SAS\Workspace" ;
/* LIBNAME DANE BASE "C:\Users\student\Desktop\"; - Tak bym tworzy� na PG. */
proc import datafile='C:\Users\Patryk\Desktop\data.csv'
/* proc import datafile='C:\Users\student\Desktop\data.csv' - Tak bym tworzy� na PG. */
			out=dane.mydata
            dbms=csv
            replace;
			getnames=yes;
run;

/* Pocedura proc contents */
proc contents data=dane.mydata;
run;

/* Do wykonania wykres�w b�d� m�g� wykorzysta� zmienne dwucz�onowe, wykonuj�c poni�sz� procedur�. */
data dane.wykresy;
set dane.mydata;
rename "Weak Foot"n = Weak_Foot; 
rename "Preferred Foot"n = Preferred_Foot;
rename "International reputation"n = International_reputation;
rename "Skill moves"n = Skill_moves;
rename "Jersey Number"n = Jersey_Number;
run;

/* Wy�wietlenie pierwszych 100 obserwacji z zaimportowanej tabeli. */
data dane.obserwacje;
set dane.mydata(firstobs=1 obs=100); 
run;
title "100 obserwacji z zaimportowanej tabeli";
proc print data=dane.obserwacje noobs;		
run;
/*
UWAGA, bardzo wa�ne !!!
Tutaj, za pomoc� funkcji NOOBS, wy�wietli�a mi si� w LOGU informacja o dodaniu 100 obserwacji, 
czyli w pe�ni prawid�owo. ALE w wytycznych chodzi�o o to, by wykona�
"por�wnanie liczby obserwacji z obserwacjami w pliku �r�d�owym".
I pojawi� si� pewien problem, gdy� na pocz�tku wykona�em instrukcj�:
"proc print data=dane.mydata noobs;		
run;"
Wtedy, wy�wietli� mi si� raport dla tabeli �r�d�owej, a tak�e informacja w LOGU, �e 18207 obserwacji
zosta�o przeczytanych. Tyle te� zawiera tabela �r�d�owa. Czyli wniosek st�d, �e wszytskie wiersze 
z importowanego pliku si� pobra�y. Ale drukowanie tabeli pierwotnej trwa�o bardzo d�ugo, lecz dzia�a�o.
Jednak w pewnym momencie wyskakiwa� b��d, �e tabela wej�ciowa zawiera b��d, i NIE mo�na wygenerowa� raportu.
Dlatego te�, wykona�em t� sam� instrukcj� dla mniejszego zbioru. I wtedy wszystko zn�w zadzia�a�o.
*/ 

/* U�ycie 'WHERE', by pokaza� umiej�tno�ci pi�karzy z kraj�w, kt�re zwyci�a�y na dw�ch ostatnich
mistrzostwach �wiata, odpowiednio w roku 2014 i 2018. */
DATA WHERE;
SET dane.mydata;
WHERE Nationality = 'Germany' | Nationality = 'France';
RUN;

/* U�ycie procedury statystycznej - PROC  FREQ do:/ 
/* 1. Wzrost pi�karzy */
title "Rozk�ad wzrostu wszystkich zawodnik�w";
PROC FREQ DATA = dane.mydata/*dane.obserwacje; tak zrobi�em pierwotnie, bo nie chcia�o dzia�a�.*/;
	TABLES height /nocum;
RUN;
/* 2. Zale�no�� potencja�u zawodnika od danej narodowo�ci. */
title "Zale�no�� potencja�u zawodnika od danej narodowo�ci";
PROC FREQ DATA = dane.mydata;
	TABLES Potential*Nationality;
RUN;
/* 3. Rozk�ad pensji pi�karzy w stosunku do ich wieku, gdzie format odnosi sie do etapu kariery;
utworzony w�asny format typu 'value'.*/
title "Rozk�ad Pensji pi�karzy w stosunku do ich wieku";
PROC FORMAT ;
	value age
		low-23 = "Poczatek"
		23 < -32 = "Optymalna forma"
		32 < -high = "Schylek"
	;
RUN;
title "Rozk�ad wzrostu pi�karzy w stosunku do ich wieku";
PROC FREQ DATA = dane.mydata;
	TABLES Value*Age;
	format Age age.;
RUN;
/* 4. Wykres przedstawia rozk�ad wzrostu pi�karzy. */
PROC SORT DATA = dane.mydata;
BY Height;
RUN;
ods graphics on;
PROC FREQ DATA=dane.mydata order=DATA;
TABLES Height /PLOTS(ONLY)=FREQPLOT;
weight Age;
RUN;
ods graphics off;

/* U�ycie funkcji matematycznych na wybranych zmiennych, w tym wymagane w wytycznych:
sprawdzenie za pomoc� funkcji 'NMISS', czy w zbiorze danych istniej� braki danych na li�cie warto�ci
numerycznych.
'Na marginesie': Bez u�ycia tej funkcji wida�, �e S� braki danych, gdy� przy pierwszym wykonaniu PROC FREQ, 
wygenerowa�a si� w raporcie (na samym dole) liczebno�� brak�w danych dotycz�ca wzrostu.*/
DATA funkcje_matematyczne1;
SET dane.mydata;
RUN;
proc transpose data=funkcje_matematyczne1 out=funkcje_matematyczne2;
var Age Overall Height;
run;
data funkcje_matematyczne3;
set funkcje_matematyczne2;
suma=sum(of col1-col18207);
srednia=mean(of col1-col18207);
wartosc_najmniejsza=min (of col1-col18207);
wartosc_najwieksza=max (of col1-col18207);
liczba_brakow=nmiss (of col1-col18207);/*NMISS-zwraca liczb� brak�w danych na li�cie warto�ci numerycznych*/
liczba_NIEbrakow=N (of col1-col18207);/*N-zwraca liczb� warto�ci NIEbed�cych brakami danych na li�cie 
									  warto�ci numerycznych*/
run;

/* WYKRESY */
/* Wykres przedstawia rozk�ad wieku pi�karzy  z automatycznym podzia�em lat. */
title "Rozk�ad wieku pi�karzy z automatycznym podzia�em lat";
PROC gchart DATA = dane.mydata;
block Age;
RUN;
/* Wykres przedstawia rozk�ad wieku pi�karzy ze zmienionym podzia�em lat. */
title "Rozk�ad wieku pi�karzy ze zmienionym podzia�em lat";
PROC gchart DATA = dane.mydata;
block Age / midpoints=16 18 20 22 24 26 28 30 32 34 36 38 40 42 44;	
/*wyszczeg�lniam za pomoc� instrukcji 'midpoint' punkty �rodkowe przedzia��w*/
RUN;
/* Wykres z u�yciem opcji i funkcji: Sumvar, Hbar, Pattern, Color. */
title "�redni wiek zawodnika wzgl�dem jego potencja�u";
pattern value=empty color=bip;	/*'pattern value=empty'-powoduje rysowanie pustych s�upk�w*/
								/*color-decyduje o kolorze obramowania s�upk�w*/
PROC gchart DATA = dane.mydata;
hbar Potential / sumvar=Age type=mean;
/*sumvar - definuije zmienn�, dla kt�rej warto�ci (�rednie/sumy) wy�wietla si� na wykresie*/
RUN;
/* Wykres ko�owy ukazuj�cy zale�no�� umiej�tno�ci gry s�absz� nog� pi�karza, 
w stosunku do jego preferowanej nogi. */
title "Zale�no�� s�abszej nogi od preferowanej nogi";
PROC gchart DATA = dane.wykresy;
pie Preferred_Foot / sumvar=Weak_foot type=mean;
RUN;
/* Wykres punktowy z u�yciem funkcji gplot. */
title "Zale�no�� wieku od pozycji zawodnika";
PROC gplot DATA = dane.mydata;
plot Age*Position;
run;
/* Wykres b�belkowy, tj. z u�yciem funkcji 'bubble'. */
title "Wiek pi�karza, a jego potencja� i obecne u�rednione umiej�tno�ci";
PROC gplot DATA = dane.wykresy;
bubble overall*potential=age;
run;
/* U�ycie SGPLOT - wykres przedstawiwa ilo�� zawodnik�w na poszczegolnych pozycjach */
PROC SGPLOT DATA = dane.wykresy;
yaxis label="Ilosc graczy na poszczegolnych pozycjach";
vbar Position;
RUN;

/* ��czenie zbior�w za pomoc� 'merge'. */
data dane.tabela_��cz�ca;
merge dane.mydata dane.wykresy;
drop VAR1 ID;
run;

/* U�ycie procedury statystycznej - PROC  MEANS do:/ 
/* 1. Obliczenie 3 warto�ci (z u�yciem f-cji matematycznych), dla zmiennych:
Overall, Potential, Age, kt�re ��czy 1 cecha wsp�lna - klub.*/
title "Wskazanie warto�ci statystycznych w poszczeg�lnych klubach danych warto�ci zmiennych";
PROC MEANS DATA = dane.mydata
	MAX
	MIN
	MEAN
;
	class Club;
	var Overall Potential Age;
RUN;
/* 2.  Obliczenie 2 warto�ci (z u�yciem f-cji matematycznych), dla zmiennych:
Weak_Foot Preferred_Foot International_Reputation Skill_Moves, kt�re ��czy 1 cecha wsp�lna - narodowo��.*/
title "Wskazanie warto�ci statystycznych w poszczeg�lnych krajach danych warto�ci zmiennych";
PROC MEANS DATA = dane.wykresy
	MIN
	MAX
;
	class Nationality;
	var Weak_Foot International_Reputation Skill_Moves Jersey_Number;
RUN;

/* GOTO */
/* 1 */
data goto;
goto = zbior;
set dane.mydata;
zbior: set dane.wykresy;
run;
/* 2 */
data goto_1;
label = goto_1;
goto_1 = zbior_1;
set dane.mydata;
zbior: set dane.wykresy;
run;
/* 3 - NAJLEPSZE u�ycie instrukcji */
/* Celem u�ycia GOTO w tej tabeli jest zsumowanie wieku wszystkich zawodnik�w z danej nacji. */ 
data GermanyGermany(drop=sumaFRA) FranceFrance(drop=sumaGER);
set WHERE;
if Nationality = 'Germany' then goto plik;
sumaFRA+Age;
output FranceFrance;
return;
plik: sumaGER+Age;
output GermanyGermany;
run;

/* LINK */
data link;
link zbiory;
set dane.mydata;
return; 
zbiory: set dane.wykresy;
return; 
run;

/* TABLICE */
/* 1 - Rozbudowana pr�ba */
data TABLICA_wst�p;
set dane.wykresy(firstobs=1 obs=40); 
keep Name Overall Weak_Foot Skill_moves International_reputation;
suma=0;
/*array technika (3) International_reputation--Weak_Foot;*/
array technika (3) International_reputation Skill_moves Weak_Foot;
array dobra_technika (3) _temporary_ (3 3 3);
do i=1 to 3;
if technika(i)>=dobra_technika(i) then suma+1;
end;
drop i;
run;
/* 2 - Ta na pewno dzia�a */
data tab_pomocnicza;
set funkcje_matematyczne3;
drop suma srednia wartosc_najmniejsza wartosc_najwieksza liczba_brakow liczba_NIEbrakow; 
run;
data tab_1;
set funkcje_matematyczne3;
array kw (*) _NAME_ col1-col18207; 
do i=1 to dim(kw);
kw(i)=kw(i)*3;
end;
drop i;
run;

/* MAKRO */
/* 1 - dzia�a na pewno poprawnie */
/* Ma ono za zadanie wy�wietli� informacje o CR7 z tabeli 'TABLICA_wst�p' */
%LET pilkarz=Cristiano Ronaldo;
data CR7;
set TABLICA_wst�p;
put "&pilkarz";
where Name = "&pilkarz";
run;
/* !!! Do tego momentu WSZYSTKO dzia�a (tj. NIE wyskakuj� b��dy), wi�c pozosta�a cz�� to 
(nieudane) dodatki !!! */
/* 2 - robione analogicznie do przyk�adu pod zadaniem nr_2 */
/* Ma ono za zadanie wy�wietli� raport na temat zawodnika o imieniu i nazwisku danym jako parametr. 
Nazwa tego makra to 'pilkarz', za� parametrem jest 'sportowiec'. */
%JEDEN pilkarz(sportowiec);
title "Dane zawodnika: &sportowiec";
proc report data=TABLICA_wst�p(WHERE=(Name=&sportowiec));
column Name Club Age Overall;
run;
%mend;
options mprint;
/* 
A tak (CHYBA) sprawdzam dzia�anie makra:
%JEDEN pilkarz(Neymar JR);
*/
/* 3 */
/* Ma ono za zadanie wy�wietli� informacje z tabeli 'TABLICA_wst�p',
ponadto P - numer pierwszej wczytywanej obserwacji, za� I - ilo�� obserwacji. */
%DWA Napisz(P, I, dane.mydata);
PROC PRINT data = &dane.mydata (firstobs=&P obs=&I);
RUN;
%mend;
options mprint;


/*
" Czego mog� dowiedzie� si� analizuj�c ten zbi�r danych ? " 
Do najwa�niejszych/najistotniejszych rzeczy mo�emy zaliczy�:
- wskazanie ilo�ci zawodnik�w reprezentuj�cych nacje, kt�re zdoby�y mistzostwo �wiata w roku 2014 i 2018
- rozk�ad wzrostu zawodnik�w
- zale�no�� potencja�u od narodowo�ci
- pokazanie wp�ywu wieku pi�karza na jego aktualn� pensj�
- prezentacja danych statystycznych, takich jak m. in.: �rednia oraz warto�ci skrajne dla:
  wieku, u�rednionych umiej�tno�ci, a tak�e wzrostu zawodnika
- rozk�ad wieku zawodnik�w
- zale�no�� potencja�u pi�karza od jego wieku
- wyszczeg�lnienie danych statystycznych zawodnika zale�nie od reprezenowanego klubu lub narodowo��
- zsumowanie wieku wszytskich zawodnik�w reprezentuj�cych nacje, kt�re zdoby�y mistzostwo �wiata w 
  roku 2014 i 2018
*/

/*
" Odpowied� na pytania dotycz�ce projektu: "
- Zawodnikiem o najwy�szych u�rednionych umiej�tno�ciach s�: Lionel Messi oraz Cristiano Ronaldo
- Mamy 2112 zawodnik�w reprezentuj�cy pa�stwa, kt�re zdoby�y mistzostwo �wiata w roku 2014 i 2018
- Najm�odszy zawodnik ma 16 lat, za� najstarszy 45
- Najni�szy 'Overall' to 46, za� najwi�kszy to 94
- Najwi�kszy wzrost zawodnika to 6'9, za� najmniejszy to 5'1
- Najwi�cej mamy pi�karzy w przedziale wiekowym 22-26 lat
- W grze, pozycj� na kt�rej jest najmniej brak�w danych je�li chodzi o ka�dy kolejny rocznik jest bramkarz
*/
