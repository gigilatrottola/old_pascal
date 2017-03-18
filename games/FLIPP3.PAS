program flipp;
uses graph,crt;

type
   golyoadat=record  { a goly¢k îsszes adat†t tartalmaz¢ rekord }
      van : boolean;   { lÇtezik-e ; TRUE ha igen }
      x,y,    { aktu†lis helyzet }
      rx,ry,  { rÇgi helyzetet ide mentem }
      vx,vy,  { sebessÇg }
      ax,ay : real;  { gyorsul†s }
   end;

const
   maxgolyo=30;   { a goly¢k max. sz†ma }

var
   { îsszes goly¢ adata }
   g : array[1..maxgolyo] of golyoadat;
   mennyi : integer;  { goly¢k akt. sz†ma }
   i : integer;  { akt. goly¢ }

   { robban†s adatai }
   robbanasvan : boolean; { Çppen van-e robban†s }
   utkx,utky : integer;   { robban†s kîzÇppontja }
   a : integer;           { sugara               }

   { a fal¢k helyzete }
   f1x,f1y,f2x,f2y : integer;
   i1x,i1y,i2x,i2y : integer;   { fal¢k mozg†sir†nya }
   falo1van,falo2van : boolean; { lÇtezik-e a fal¢ }
   { adatok a gÇpi mozgat†shoz }
   uldoz1,uldoz2 : boolean;
   uldozott1,uldozott2 : integer;
   kaja1,kaja2 : integer;

   
   geppeljatszik,demo : boolean; { j†tÇkm¢dok }
   zaj : boolean;  { TRUE ha van csipog†s }
   ujjatek : boolean;  { true ha uj j†tÇkot kell kezdeni, egyÇbkÇnt false }

{ Falhoz ÅtkîzÇsnÇl csippen }
procedure hang(i:integer);  {  i a hang magass†g†t adja  }
begin
   sound(400*i div 2);
   delay(20);
   nosound;
end;

{ grafikus m¢dba v†lt†s }
procedure vgainit;
var
   dr,m : integer; { grafikus m¢d }
begin
   dr:=VGA;  m:=VGAHi; { csak VGA 640*480/16 m¢dban indul }
   initgraph(dr,m,'');
   if (graphresult<>0) then begin
    writeln('Csak VGA m¢dban indulok.');
    halt(1);
   end;
end;

{ a bejelentkezî kÇpet rajzolja ki }
procedure kezdokep;
var
   i,k,m,
   kdh,kds,kdh2,kds2,kdhuj,kdhuj2 : integer;   {  segÇdv†ltoz¢k  }
   ch : char;
begin
   setcolor(1);
   for i:=0 to 11 do circle(319,239,i*35);
   setcolor(14);
   randomize;
   for i:=1 to 20 do begin
    k:=random(640);
    m:=random(480);
    circle(k,m,3);
   end;
   setcolor(12);
   outtextxy(259,20,' F L I P P  ');
   rectangle(140,16,465,30);
   setcolor(15);
   outtextxy(150,110,'Ir†nyv†ltoztat†s: ');
   outtextxy(150,130,'Elsî j†tÇkos       :  kurzormozgat¢kkal');
   outtextxy(150,150,'M†sodik j†tÇkos    :       "w"   ');
   outtextxy(150,170,'                       "a"     "d" ');
   outtextxy(150,190,'                           "s"     ');
   outtextxy(150,210,'KilÇpÇs ak†rmikor ESC-el');
   setcolor(13);
   outtextxy(150,230,'A gÇppel is j†tszhatsz : ');
   outtextxy(150,250,' g  -   gÇp/ember v†lt†s');
   setcolor(11);
   outtextxy(150,270,' h  -  demo/j†tÇk v†lt†s');
   setcolor(2);
   outtextxy(150,290,' m  -   hang ki/be');
   setcolor(10);
   outtextxy(150,310,' k  -   HELP ');
   setcolor(15);
   outtextxy(150,330,'Indul†s ENTER-el');
   setcolor(14);
   outtextxy(260,350,' J¢ KAPèST ! ');
   setcolor(5);
   setfillstyle(1,5);
   pieslice(319,400,0,360,9);
   for i:=1 to 17 do begin
    arc(319,400,345,15,i*18);
    arc(319,400,165,195,i*18);
   end;
   setcolor(9);
   outtextxy(100,470,'D e l i c''  è d † m');
   kdh:=145;  kds:=17;
   kdh2:=460; kds2:=-17;
   i:=0;   ch:='q';
   repeat
    if keypressed then ch:=readkey;
    setcolor(14);
    circle(kdh,23,4);
    circle(kdh2,23,4);
    kdhuj:=kdh+kds;
    kdhuj2:=kdh2+kds2;
    if kdhuj<145 then begin kdhuj:=145; kds:=-kds; end;
    if kdhuj>262 then begin kdhuj:=262; kds:=-kds; end;
    if kdhuj2<343 then begin kdhuj2:=343; kds2:=-kds2; end;
    if kdhuj2>460 then begin kdhuj2:=460; kds2:=-kds2; end;
    i:=i+1;
    if i>17 then i:=1;
    setcolor(5);
    if i=1 then begin
     arc(319,400,345,15,17*18);
     arc(319,400,165,195,17*18);
    end else begin
     arc(319,400,345,15,(i-1)*18);
     arc(319,400,165,195,(i-1)*18);
    end;
    setcolor(14);
    arc(319,400,345,15,i*18);
    arc(319,400,165,195,i*18);
    if i<4  then delay(30);
    if i<11 then delay(30);
    setcolor(0);
    circle(kdh,23,4);
    circle(kdh2,23,4);
    kdh:=kdhuj;
    kdh2:=kdhuj2;
   until ch=#13;
end;

{ adott helyÅ goly¢ tîbbi paramÇterÇt vÇletlenszerÅen gener†lja }
procedure letrehoz(i:integer);
begin
   g[i].van:=true;
   g[i].rx:=g[i].x;
   g[i].ry:=g[i].y;
   g[i].vx:=(random-0.5)*4.0;
   g[i].vy:=(random-0.5)*4.0;
   if random<0.2 then g[i].ax:=random-0.5
   else g[i].ax:=0.0;
   if random>0.8 then g[i].ay:=random-0.5
   else g[i].ax:=0.0;
end;

{ uj j†tÇk kezdÇsÇhez be†ll°tja az îsszes v†ltoz¢t }
procedure ujjatekbeallit;
var i:integer;
begin
   randomize;
   ujjatek:=false;

   { robban†s st†tusza (nincs) }
   robbanasvan:=false;
   a:=0;

   { fal¢k adatai }
   falo1van:=true; falo2van:=true;
   f1x:=553; f1y:=403;
   f2x:=13;  f2y:=28;
   uldoz1:=false; uldoz2:=false;
   kaja1:=0; kaja2:=0;
   i1x:=-1;  i1y:=-1;
   i2x:=1; i2y:=1;

   { goly¢k adatai (vÇletlenszerÅ) }
   mennyi:=maxgolyo div 2;
   for i:=1 to mennyi do begin
    g[i].van:=true;
    g[i].x:=random(500)+40.0;
    g[i].y:=random(400)+30.0;
    letrehoz(i);
   end;
   for i:=mennyi+1 to maxgolyo do g[i].van:=false;
end;

{ kirajzolja a j†tÇkteret }
procedure jatekterki;
begin
   setcolor(15);
   Cleardevice;
   line(6,21,635,21);
   line(6,455,635,455);
   line(6,464,635,464);
   line(6,476,635,476);
   line(6,464,6,476);
   line(635,464,635,476);
   line(322,464,322,476);
   line(6,21,6,455);
   line(635,21,635,455);
end;


procedure csendtext;
begin
   setfillstyle(1,1);
   setcolor(14);
   bar(10,1,110,16);
   outtextxy(25,6,'SOUND OFF');
end;

procedure geppeljatsziktext;
begin
   setfillstyle(1,1);
   setcolor(14);
   bar(120,1,293,16);
   outtextxy(135,6,'PLAY WITH COMPUTER');
end;

procedure demotext;
begin
   setfillstyle(1,1);
   setcolor(14);
   bar(303,1,364,16);
   outtextxy(318,6,'DEMO');
end;

{ egy goly¢ helyÇnek v†ltoztat†sa }
procedure helyzetvaltoztatas(i:integer);  { i - hanyadik golyo }
begin
   g[i].rx:=g[i].x;        { akt. helyzet elmentÇse }
   g[i].ry:=g[i].y;
   g[i].x:=g[i].x+g[i].vx;   { akt. helyzet frissitÇse }
   g[i].y:=g[i].y+g[i].vy;
   g[i].vx:=g[i].vx+g[i].ax; { akt. sebessÇg frissitÇse }
   g[i].vy:=g[i].vy+g[i].ay;
   { ha t£llÇpte volna a falat akkor visszapattan }
   if (g[i].x+g[i].vx>631.0) then begin
    g[i].x:=630.0;
    g[i].vx:=-g[i].vx;
    if zaj then hang(i);
   end;
   if (g[i].x+g[i].vx<10.0) then begin
    g[i].x:=11.0;
    g[i].vx:=-g[i].vx;
    if zaj then hang(i);
   end;
   if (g[i].y+g[i].vy>451.0) then begin
    g[i].y:=450.0;
    g[i].vy:=-g[i].vy;
    if zaj then hang(i);
   end;
   if (g[i].y+g[i].vy<25.0) then begin
    g[i].y:=26.0;
    g[i].vy:=-g[i].vy;
    if zaj then hang(i);
   end;
end;


{ tîrli a goly¢t Çs kirakja az uj helyÇre }
procedure golyoki(i:integer);
begin
   setcolor(0);
   circle(round(g[i].rx),round(g[i].ry),3);
   setcolor(14);
   circle(round(g[i].x),round(g[i].y),3);
end;

{ megvizsg†lja hogy tal†lkozott-e kÇt goly¢,
  Çs ha igen akkor robbant vagy szapor°t      }
procedure golyovizsgalat(i:integer);  { i - az aktu†lis goly¢ }
var
   j,k : integer; { ciklusv†ltoz¢k }
begin
   if i<maxgolyo then
    for j:=i+1 to maxgolyo do
     if g[j].van and (abs(g[i].x-g[j].x)<6) and (abs(g[i].y-g[j].y)<6) then begin
      if ((maxgolyo-mennyi)/maxgolyo>random) then begin { szapor°t†s }
       k:=1;
       while g[k].van do inc(k); { megkeresi az elsî szabad helyet a tîmbben }
       g[k].x:=g[i].x+random(10)-5.0;
       g[k].y:=g[i].y+random(10)-5.0;
       letrehoz(k);
       inc(mennyi);
      end else begin { robbant†s }
       { goly¢k eltÅntetÇse }
       g[i].van:=false; g[j].van:=false;
       mennyi:=mennyi-2;
       setcolor(0);
       circle(round(g[i].x),round(g[i].y),3);
       circle(round(g[j].x),round(g[j].y),3);
       if robbanasvan then begin { ha Çppen folyamatban van egy robban†s akkor }
        setcolor(0);             { azt megszÅnteti, hogy ujat kezdhessen       }
        circle(utkx,utky,a);
        a:=0;                    { robban†shull†m kezdeti sugara }
       end;
       robbanasvan:=true;
       utkx:=round(g[i].x);
       utky:=round(g[i].y);
      end;
      exit; { tov†bb nem vizsg†l , az lass°tan† a programot }
     end;
end;

{ kirajzolja a robban†st Çs megnÇzi hogy belekerÅltek-e a fal¢k }
procedure robbanaski;
begin
   setcolor(0); { elîzî robban†shull†m tîrlÇse }
   circle(utkx,utky,a);
   inc(a);      { nî a sug†r }
   setcolor(random(7)+9); { uj ki }
   circle(utkx,utky,a);
   if zaj and (a mod 2 <> 0) then sound(200) else nosound; { robban†szaj }
   if a=20 then begin  { robban†s vÇge }
    robbanasvan:=false;
    setcolor(0); circle(utkx,utky,a);
    a:=0;
   end;
   { ha egy fal¢ robban†sba kerÅl akkor meghal }
   if falo1van and (abs(f1x-utkx)<a+5) and (abs(f1y-utky)<a+5) then
    falo1van:=false;
   if falo2van and (abs(f2x-utkx)<a+5) and (abs(f2y-utky)<a+5) then
    falo2van:=false;
end;

procedure pause;
var ch:char;
begin
   setfillstyle(1,1);
   setcolor(14);
   bar(374,1,441,16);
   outtextxy(389,6,'PAUSE');
   repeat
    ch:=readkey;
   until (ch=#13) or (ch='p') or (ch=#32);
   setfillstyle(1,0);
   bar(374,1,441,16);
end;

procedure hangallitas;
begin
   if zaj then begin
    zaj:=false;
    csendtext;
   end else begin
    zaj:=true;
    setfillstyle(1,0);
    bar(10,1,110,16);
   end;
end;

procedure boss;
var ch : char;
begin
   restorecrtmode;
   repeat
    ch:=readkey;
   until (ch=#27);
   setgraphmode(getgraphmode);
end;

procedure help;
var ch : char;
begin
   setfillstyle(1,1);
   setcolor(14);
   bar(451,1,510,16);
   outtextxy(466,6,'HELP');
   setfillstyle(1,8);
   bar(200,70,438,300);
   setcolor(15);
   rectangle(200,70,438,300);
   outtextxy(210,80,'Kapcsol¢k:');
   outtextxy(210,100,'m  -  hang ki/be');
   outtextxy(210,120,'g  -  j†tÇk a gÇp ellen');
   outtextxy(210,140,'h  -  demo');
   outtextxy(210,160,'p  -  pause');
   outtextxy(210,180,'k  -  help');
   outtextxy(210,200,'b  -  fînîk');
   repeat
    ch:=readkey;
   until (ch=#13) or (ch='k') or (ch=#32);
   setfillstyle(1,0);
   bar(200,70,438,300);
   bar(451,1,510,16);
end;

procedure geppeljatszikallit;
begin
   if geppeljatszik then begin
    geppeljatszik:=false;
    setfillstyle(1,0);
    bar(120,1,293,16);
   end else begin
    geppeljatszik:=true;
    geppeljatsziktext;
   end;
end;

procedure demoallit;
begin
   if demo then begin
    demo:=false;
    geppeljatszik:=false;
    setfillstyle(1,0);
    bar(303,1,370,16);
   end else begin
    geppeljatszik:=true; demo:=true;
    setfillstyle(1,0);
    bar(120,1,293,16);
    demotext;
   end;
end;

procedure eredmeny(i:integer);
var  c : char;
     j : integer;
begin
   setcolor(14);
   setfillstyle(1,14);
   if i=1 then
    for j:=1 to kaja1 do begin
     pieslice(5+10*j,470,0,360,3);
     if zaj then sound(400+30*j);
     delay(100);
    end;
   if i=2 then
    for j:=1 to kaja2 do begin
     pieslice(319+10*j,470,0,360,3);
     if zaj then sound(400+30*j);
     delay(100);
    end;
   if zaj then nosound;
   case i of
   1:setfillstyle(1,5);
   2:setfillstyle(1,3);
   3:setfillstyle(1,8);
   0:setfillstyle(1,8);
   end;{case}
   bar(220,200,440,220);
   Setcolor(15);
   Rectangle(220,200,440,220);
   case i of
   0:outtextxy(260,207,'KILêPêS : ENTER');
   1:outtextxy(280,207,'LILA NYERT !!!');
   2:if geppeljatszik  and (not demo) then
      outtextxy(229,207,'Ez csak vÇletlen lehetett!')
     else outtextxy(280,207,'KêK NYERT !!! ');
   3:outtextxy(275,207,'DôNTETLEN ...');
   end;{case}
   if demo and (i<>0) then begin
     delay(1500);
     exit;
   end;
   if i<>0 then begin
    repeat c:=readkey; until (c=#13) or (c=#27) or (c=#32);
    if c=#27 then begin
     i:=0;
     setfillstyle(1,8);
     bar(220,200,440,220);
     Setcolor(15);
     Rectangle(220,200,440,220);
     outtextxy(260,207,'KILêPêS : ENTER');
    end;
   end;
   if i=0 then begin
    repeat c:=readkey; until (c=#13) or (c=#27);
    if c=#13 then begin
     closegraph;
     writeln('  Good byte !');
     writeln(' ');
     halt;
    end;
   end;
end;

procedure billentyuzetvizsgalat;
var ch : char;
begin
   ch:=readkey;
   case ch of
   'p':pause;
   'm':hangallitas;
   'b':begin boss; ujjatek:=true; end;
   'k':help;
   #27:begin eredmeny(0); ujjatek:=true; end;
   'g':if not demo then geppeljatszikallit;
   'h':demoallit;
   #0 :if not demo then begin
        ch:=readkey;
        case ch of
        #71:begin i2x:=-1; i2y:=-1; end;
        #72:begin i2x:=0;  i2y:=-1; end;
        #73:begin i2x:=1;  i2y:=-1; end;
        #75:begin i2x:=-1; i2y:=0;  end;
        #77:begin i2x:=1;  i2y:=0;  end;
        #79:begin i2x:=-1; i2y:=1;  end;
        #80:begin i2x:=0;  i2y:=1;  end;
        #81:begin i2x:=1;  i2y:=1;  end;
        #82:begin i2x:=0;  i2y:=0;  end;
        end;
       end;
   end;{case}
   if not geppeljatszik then
    case ch of
    'q':begin i1x:=-1; i1y:=-1; end;
    'w':begin i1x:=0;  i1y:=-1; end;
    'e':begin i1x:=1;  i1y:=-1; end;
    'a':begin i1x:=-1; i1y:=0;  end;
    'd':begin i1x:=1;  i1y:=0;  end;
    'z':begin i1x:=-1; i1y:=1;  end;
    'x':begin i1x:=0;  i1y:=1;  end;
    'c':begin i1x:=1;  i1y:=1;  end;
    's':begin i1x:=0;  i1y:=0;  end;
    end;
end;

{ tîrli a fal¢kat a kÇprîl }
procedure falole;
begin
   setcolor(0);
   circle(f1x,f1y,5);
   circle(f1x,f1y,6);
   circle(f2x,f2y,5);
   circle(f2x,f2y,6);
end;

{ kiteszi a fal¢kat a kÇpre }
procedure faloki;
begin
   setcolor(5);
   circle(f1x,f1y,5);
   circle(f1x,f1y,6);
   setcolor(11);
   circle(f2x,f2y,5);
   if (f1x=f2x) and (f1y=f2y) then setcolor(5);
   circle(f2x,f2y,6);
end;

procedure falomozgatas;
begin
   if (i1x=1) and (f1x<620) then f1x:=f1x+15
   else if (i1x=-1) and (f1x>25) then f1x:=f1x-15;
   if (i1y=1) and (f1y<445) then f1y:=f1y+15
   else if (i1y=-1) and (f1y>40) then f1y:=f1y-15;

   if (i2x=1) and (f2x<620) then f2x:=f2x+15
   else if (i2x=-1) and (f2x>25) then f2x:=f2x-15;
   if (i2y=1) and (f2y<445) then f2y:=f2y+15
   else if (i2y=-1) and (f2y>40) then f2y:=f2y-15;
end;

procedure evesvizsgalat;
var i:integer;
begin
   if falo1van then
    for i:=1 to maxgolyo do
     if g[i].van and (abs(f1x-g[i].x)<10) and (abs(f1y-g[i].y)<10) then begin
      dec(mennyi);
      g[i].van:=false;
      setcolor(0);
      circle(round(g[i].x),round(g[i].y),3);
      inc(kaja1);
      setcolor(5);
      circle(5+10*kaja1,470,3);
      if kaja1=31 then exit;
     end;
   if falo2van then
    for i:=1 to maxgolyo do
     if g[i].van and (abs(f2x-g[i].x)<10) and (abs(f2y-g[i].y)<10) then begin
      dec(mennyi);
      g[i].van:=false;
      setcolor(0);
      circle(round(g[i].x),round(g[i].y),3);
      inc(kaja2);
      setcolor(11);
      circle(319+10*kaja2,470,3);
      if kaja2=31 then exit;
     end;
end;

procedure gepiiranyitas;
var tav,at : longint;
         i : integer;
begin
   if geppeljatszik then begin
    if uldoz1 then
     if g[uldozott1].van then begin
      if (g[uldozott1].x-f1x>0) then i1x:=1
      else i1x:=-1;
      if (g[uldozott1].y-f1y>0) then i1y:=1
      else i1y:=-1;
     end else uldoz1:=false;
    if not uldoz1 then begin
     uldozott1:=0;
     tav:=maxlongint;
     for i:=1 to maxgolyo do begin
      if g[i].van then begin
       at:=sqr(round(f1x-g[i].x))+sqr(round(f1y-g[i].y));
       if at<=tav then begin
        tav:=at;
        uldozott1:=i;
       end;
      end;
     end;
     if uldozott1<>0 then uldoz1:=true;
    end;
   end;
      
   if demo then begin
    if uldoz2 then
     if g[uldozott2].van then begin
      if (g[uldozott2].x-f2x>0) then i2x:=1
      else i2x:=-1;
      if (g[uldozott2].y-f2y>0) then i2y:=1
      else i2y:=-1;
     end else uldoz2:=false;
    if not uldoz2 then begin
     uldozott2:=0;
     tav:=maxlongint;
     for i:=1 to maxgolyo do begin
      if g[i].van then begin
       at:=sqr(round(f2x-g[i].x))+sqr(round(f2y-g[i].y));
       if at<=tav then begin
        tav:=at;
        uldozott2:=i;
       end;
      end;
     end;
     if uldozott2<>0 then uldoz2:=true;
    end;
   end;
end;

begin
   vgainit;
   kezdokep;
   { alapÇrtelmezÇsek }
   geppeljatszik:=false; demo:=false; zaj:=true;
   repeat
    ujjatekbeallit;
    jatekterki;
    if not zaj then csendtext;
    if (not demo) and geppeljatszik then geppeljatsziktext;
    if demo then demotext;

    repeat
     for i:=1 to maxgolyo do
      if g[i].van then begin
       helyzetvaltoztatas(i);
       golyoki(i);
       golyovizsgalat(i);
      end;
     falole;
     if robbanasvan then robbanaski;
     if keypressed then billentyuzetvizsgalat;
     gepiiranyitas;
     falomozgatas;
     evesvizsgalat;
     faloki;
    until ujjatek or (mennyi=0) or (not falo1van) or (not falo2van) or
          (kaja1=31) or (kaja2=31);
    if not ujjatek then begin
     if falo2van and not falo1van then eredmeny(2)
     else if falo1van and not falo2van then eredmeny(1)
     else begin
      if kaja1>kaja2 then eredmeny(1);
      if kaja1<kaja2 then eredmeny(2);
      if kaja1=kaja2 then eredmeny(3);
     end;
    end;
   until false;
end.