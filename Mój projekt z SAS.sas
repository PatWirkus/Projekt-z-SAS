/* PROJEKT na zaliczenie */
/* Patryk Wirkus */
/*Tytu≥: Wyszukiwanie zwiπzkÛw oraz zaleønoúci miÍdzy danymi poszczegÛlnuch zawodnikÛw z gry FIFA19.*/
/* èrÛd≥o zaimportowanej bazy danych: KAGGLE, plik "data" - zawodnicy z gry FIFA 19. */
/* Cel projektu: G≥Ûwnym celem projektu jest dokonanie analizy porÛwnawczej zawodnikÛw z gry FIFA 19,
				 na podstawie danych zawartych w tabeli, czyli m.in: dane osobiste, umiejÍtnoúci 
				 pi≥karskie, atrybuty fizyczne, a takøe aktualna wartoúÊ rynkowa.*/

/*
WST PNA uwaga dotyczπca dwÛch uøytych funkcji.
"Unable to load the Java Virtual Machine. Please see the installation instructions or system administrator."
WYåWIETLA SI  TO PRZY:
- uøyciu PROC FREQ do wykresÛw, tj.  4 uøycie tej procedury	(ROBIONE NA PODSTAWIE SKRYPTU)
- uøcyiu SGPLOT												(ROBIONE NA PODSTAWIE HELP)
Po wyjaúnieniu:
Kod tych dwÛch procedur jest prawid≥owy. Z tym øe, prawdopodobnie NIE zainstalowa≥em pewnej czÍúci programu, 
stπd te dwie funkcje nie dzia≥ajπ. Natomiast, na PG wszystko odzia≥a poprawnie.
*/ 

/* Pierwszym krokiem naszego projektu jest import danych, tu: plik 'data' w formacie csv. */
LIBNAME DANE BASE "Z:\Studiav2\SAS\Workspace" ;
/* LIBNAME DANE BASE "C:\Users\student\Desktop\"; - Tak bym tworzy≥ na PG. */
proc import datafile='C:\Users\Patryk\Desktop\data.csv'
/* proc import datafile='C:\Users\student\Desktop\data.csv' - Tak bym tworzy≥ na PG. */
			out=dane.mydata
            dbms=csv
            replace;
			getnames=yes;
run;

/* Pocedura proc contents */
proc contents data=dane.mydata;
run;

/* Do wykonania wykresÛw bÍdÍ mÛg≥ wykorzystaÊ zmienne dwucz≥onowe, wykonujπc poniøszπ procedurÍ. */
data dane.wykresy;
set dane.mydata;
rename "Weak Foot"n = Weak_Foot; 
rename "Preferred Foot"n = Preferred_Foot;
rename "International reputation"n = International_reputation;
rename "Skill moves"n = Skill_moves;
rename "Jersey Number"n = Jersey_Number;
run;

/* Wyúwietlenie pierwszych 100 obserwacji z zaimportowanej tabeli. */
data dane.obserwacje;
set dane.mydata(firstobs=1 obs=100); 
run;
title "100 obserwacji z zaimportowanej tabeli";
proc print data=dane.obserwacje noobs;		
run;
/*
UWAGA, bardzo waøne !!!
Tutaj, za pomocπ funkcji NOOBS, wyúwietli≥a mi siÍ w LOGU informacja o dodaniu 100 obserwacji, 
czyli w pe≥ni prawid≥owo. ALE w wytycznych chodzi≥o o to, by wykonaÊ
"porÛwnanie liczby obserwacji z obserwacjami w pliku ürÛd≥owym".
I pojawi≥ siÍ pewien problem, gdyø na poczπtku wykona≥em instrukcjÍ:
"proc print data=dane.mydata noobs;		
run;"
Wtedy, wyúwietli≥ mi siÍ raport dla tabeli ürÛd≥owej, a takøe informacja w LOGU, øe 18207 obserwacji
zosta≥o przeczytanych. Tyle teø zawiera tabela ürÛd≥owa. Czyli wniosek stπd, øe wszytskie wiersze 
z importowanego pliku siÍ pobra≥y. Ale drukowanie tabeli pierwotnej trwa≥o bardzo d≥ugo, lecz dzia≥a≥o.
Jednak w pewnym momencie wyskakiwa≥ b≥πd, øe tabela wejúciowa zawiera b≥πd, i NIE moøna wygenerowaÊ raportu.
Dlatego teø, wykona≥em tÍ samπ instrukcjÍ dla mniejszego zbioru. I wtedy wszystko znÛw zadzia≥a≥o.
*/ 

/* Uøycie 'WHERE', by pokazaÊ umiejÍtnoúci pi≥karzy z krajÛw, ktÛre zwyciÍøa≥y na dwÛch ostatnich
mistrzostwach úwiata, odpowiednio w roku 2014 i 2018. */
DATA WHERE;
SET dane.mydata;
WHERE Nationality = 'Germany' | Nationality = 'France';
RUN;

/* Uøycie procedury statystycznej - PROC  FREQ do:/ 
/* 1. Wzrost pi≥karzy */
title "Rozk≥ad wzrostu wszystkich zawodnikÛw";
PROC FREQ DATA = dane.mydata/*dane.obserwacje; tak zrobi≥em pierwotnie, bo nie chcia≥o dzia≥aÊ.*/;
	TABLES height /nocum;
RUN;
/* 2. ZaleønoúÊ potencja≥u zawodnika od danej narodowoúci. */
title "ZaleønoúÊ potencja≥u zawodnika od danej narodowoúci";
PROC FREQ DATA = dane.mydata;
	TABLES Potential*Nationality;
RUN;
/* 3. Rozk≥ad pensji pi≥karzy w stosunku do ich wieku, gdzie format odnosi sie do etapu kariery;
utworzony w≥asny format typu 'value'.*/
title "Rozk≥ad Pensji pi≥karzy w stosunku do ich wieku";
PROC FORMAT ;
	value age
		low-23 = "Poczatek"
		23 < -32 = "Optymalna forma"
		32 < -high = "Schylek"
	;
RUN;
title "Rozk≥ad wzrostu pi≥karzy w stosunku do ich wieku";
PROC FREQ DATA = dane.mydata;
	TABLES Value*Age;
	format Age age.;
RUN;
/* 4. Wykres przedstawia rozk≥ad wzrostu pi≥karzy. */
PROC SORT DATA = dane.mydata;
BY Height;
RUN;
ods graphics on;
PROC FREQ DATA=dane.mydata order=DATA;
TABLES Height /PLOTS(ONLY)=FREQPLOT;
weight Age;
RUN;
ods graphics off;

/* Uøycie funkcji matematycznych na wybranych zmiennych, w tym wymagane w wytycznych:
sprawdzenie za pomocπ funkcji 'NMISS', czy w zbiorze danych istniejπ braki danych na liúcie wartoúci
numerycznych.
'Na marginesie': Bez uøycia tej funkcji widaÊ, øe S• braki danych, gdyø przy pierwszym wykonaniu PROC FREQ, 
wygenerowa≥a siÍ w raporcie (na samym dole) liczebnoúÊ brakÛw danych dotyczπca wzrostu.*/
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
liczba_brakow=nmiss (of col1-col18207);/*NMISS-zwraca liczbÍ brakÛw danych na liúcie wartoúci numerycznych*/
liczba_NIEbrakow=N (of col1-col18207);/*N-zwraca liczbÍ wartoúci NIEbedπcych brakami danych na liúcie 
									  wartoúci numerycznych*/
run;

/* WYKRESY */
/* Wykres przedstawia rozk≥ad wieku pi≥karzy  z automatycznym podzia≥em lat. */
title "Rozk≥ad wieku pi≥karzy z automatycznym podzia≥em lat";
PROC gchart DATA = dane.mydata;
block Age;
RUN;
/* Wykres przedstawia rozk≥ad wieku pi≥karzy ze zmienionym podzia≥em lat. */
title "Rozk≥ad wieku pi≥karzy ze zmienionym podzia≥em lat";
PROC gchart DATA = dane.mydata;
block Age / midpoints=16 18 20 22 24 26 28 30 32 34 36 38 40 42 44;	
/*wyszczegÛlniam za pomocπ instrukcji 'midpoint' punkty úrodkowe przedzia≥Ûw*/
RUN;
/* Wykres z uøyciem opcji i funkcji: Sumvar, Hbar, Pattern, Color. */
title "åredni wiek zawodnika wzglÍdem jego potencja≥u";
pattern value=empty color=bip;	/*'pattern value=empty'-powoduje rysowanie pustych s≥upkÛw*/
								/*color-decyduje o kolorze obramowania s≥upkÛw*/
PROC gchart DATA = dane.mydata;
hbar Potential / sumvar=Age type=mean;
/*sumvar - definuije zmiennπ, dla ktÛrej wartoúci (úrednie/sumy) wyúwietla siÍ na wykresie*/
RUN;
/* Wykres ko≥owy ukazujπcy zaleønoúÊ umiejÍtnoúci gry s≥abszπ nogπ pi≥karza, 
w stosunku do jego preferowanej nogi. */
title "ZaleønoúÊ s≥abszej nogi od preferowanej nogi";
PROC gchart DATA = dane.wykresy;
pie Preferred_Foot / sumvar=Weak_foot type=mean;
RUN;
/* Wykres punktowy z uøyciem funkcji gplot. */
title "ZaleønoúÊ wieku od pozycji zawodnika";
PROC gplot DATA = dane.mydata;
plot Age*Position;
run;
/* Wykres bπbelkowy, tj. z uøyciem funkcji 'bubble'. */
title "Wiek pi≥karza, a jego potencja≥ i obecne uúrednione umiejÍtnoúci";
PROC gplot DATA = dane.wykresy;
bubble overall*potential=age;
run;
/* Uøycie SGPLOT - wykres przedstawiwa iloúÊ zawodnikÛw na poszczegolnych pozycjach */
PROC SGPLOT DATA = dane.wykresy;
yaxis label="Ilosc graczy na poszczegolnych pozycjach";
vbar Position;
RUN;

/* £πczenie zbiorÛw za pomocπ 'merge'. */
data dane.tabela_≥πczπca;
merge dane.mydata dane.wykresy;
drop VAR1 ID;
run;

/* Uøycie procedury statystycznej - PROC  MEANS do:/ 
/* 1. Obliczenie 3 wartoúci (z uøyciem f-cji matematycznych), dla zmiennych:
Overall, Potential, Age, ktÛre ≥πczy 1 cecha wspÛlna - klub.*/
title "Wskazanie wartoúci statystycznych w poszczegÛlnych klubach danych wartoúci zmiennych";
PROC MEANS DATA = dane.mydata
	MAX
	MIN
	MEAN
;
	class Club;
	var Overall Potential Age;
RUN;
/* 2.  Obliczenie 2 wartoúci (z uøyciem f-cji matematycznych), dla zmiennych:
Weak_Foot Preferred_Foot International_Reputation Skill_Moves, ktÛre ≥πczy 1 cecha wspÛlna - narodowoúÊ.*/
title "Wskazanie wartoúci statystycznych w poszczegÛlnych krajach danych wartoúci zmiennych";
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
/* 3 - NAJLEPSZE uøycie instrukcji */
/* Celem uøycia GOTO w tej tabeli jest zsumowanie wieku wszystkich zawodnikÛw z danej nacji. */ 
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
/* 1 - Rozbudowana prÛba */
data TABLICA_wstÍp;
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
/* 2 - Ta na pewno dzia≥a */
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
/* 1 - dzia≥a na pewno poprawnie */
/* Ma ono za zadanie wyúwietliÊ informacje o CR7 z tabeli 'TABLICA_wstÍp' */
%LET pilkarz=Cristiano Ronaldo;
data CR7;
set TABLICA_wstÍp;
put "&pilkarz";
where Name = "&pilkarz";
run;
/* !!! Do tego momentu WSZYSTKO dzia≥a (tj. NIE wyskakujπ b≥Ídy), wiÍc pozosta≥a czÍúÊ to 
(nieudane) dodatki !!! */
/* 2 - robione analogicznie do przyk≥adu pod zadaniem nr_2 */
/* Ma ono za zadanie wyúwietliÊ raport na temat zawodnika o imieniu i nazwisku danym jako parametr. 
Nazwa tego makra to 'pilkarz', zaú parametrem jest 'sportowiec'. */
%JEDEN pilkarz(sportowiec);
title "Dane zawodnika: &sportowiec";
proc report data=TABLICA_wstÍp(WHERE=(Name=&sportowiec));
column Name Club Age Overall;
run;
%mend;
options mprint;
/* 
A tak (CHYBA) sprawdzam dzia≥anie makra:
%JEDEN pilkarz(Neymar JR);
*/
/* 3 */
/* Ma ono za zadanie wyúwietliÊ informacje z tabeli 'TABLICA_wstÍp',
ponadto P - numer pierwszej wczytywanej obserwacji, zaú I - iloúÊ obserwacji. */
%DWA Napisz(P, I, dane.mydata);
PROC PRINT data = &dane.mydata (firstobs=&P obs=&I);
RUN;
%mend;
options mprint;


/*
" Czego mogÍ dowiedzieÊ siÍ analizujπc ten zbiÛr danych ? " 
Do najwaøniejszych/najistotniejszych rzeczy moøemy zaliczyÊ:
- wskazanie iloúci zawodnikÛw reprezentujπcych nacje, ktÛre zdoby≥y mistzostwo úwiata w roku 2014 i 2018
- rozk≥ad wzrostu zawodnikÛw
- zaleønoúÊ potencja≥u od narodowoúci
- pokazanie wp≥ywu wieku pi≥karza na jego aktualnπ pensjÍ
- prezentacja danych statystycznych, takich jak m. in.: úrednia oraz wartoúci skrajne dla:
  wieku, uúrednionych umiejÍtnoúci, a takøe wzrostu zawodnika
- rozk≥ad wieku zawodnikÛw
- zaleønoúÊ potencja≥u pi≥karza od jego wieku
- wyszczegÛlnienie danych statystycznych zawodnika zaleønie od reprezenowanego klubu lub narodowoúÊ
- zsumowanie wieku wszytskich zawodnikÛw reprezentujπcych nacje, ktÛre zdoby≥y mistzostwo úwiata w 
  roku 2014 i 2018
*/

/*
" Odpowiedü na pytania dotyczπce projektu: "
- Zawodnikiem o najwyøszych uúrednionych umiejÍtnoúciach sπ: Lionel Messi oraz Cristiano Ronaldo
- Mamy 2112 zawodnikÛw reprezentujπcy paÒstwa, ktÛre zdoby≥y mistzostwo úwiata w roku 2014 i 2018
- Najm≥odszy zawodnik ma 16 lat, zaú najstarszy 45
- Najniøszy 'Overall' to 46, zaú najwiÍkszy to 94
- NajwiÍkszy wzrost zawodnika to 6'9, zaú najmniejszy to 5'1
- NajwiÍcej mamy pi≥karzy w przedziale wiekowym 22-26 lat
- W grze, pozycjπ na ktÛrej jest najmniej brakÛw danych jeúli chodzi o kaødy kolejny rocznik jest bramkarz
*/
