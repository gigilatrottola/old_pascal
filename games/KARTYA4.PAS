program kartyajatek;
uses graph,crt,dos;
label ujrajatszas;
const
    cim='N a p ¢ l e o n   s ° r j a';
    TalonHely:array[1..2] of integer=(565,0);
    SorHely:array[1..3,1..2] of integer=((565,134),(565,254),(565,374));
    KozepHely:array[1..2] of integer=(255,180);
    LeforditottHely:
     array[1..4,1..2] of integer=((170,120),(340,120),(170,240),(340,240));
    KulsoHely:
     array[1..4,1..2] of integer=((42,180),(255,0),(467,180),(255,360));
    KeresztHely:
     array[1..4,1..2] of integer=((85,60),(425,60),(85,300),(425,300));
    LszHely:
     array[1..4,1..2] of integer=((255,130),(325,130),(255,330),(325,330));
    TszHely:array[1..2] of integer=(550,15);
type
    kartya=record
           szin:byte;  { 1..4 }
           szam:byte;  { 1..13 }
    end;

    pakli=array[1..52] of kartya;

    kep=array[1..3822] of byte;  { egy kartya grafikus kepet tarolja }

var
    p0:pakli;      { egy alap-pakli francia kartya }
    i,j,l:integer;
    ch:char;
    po1,po2,po3,po4:^kep;
    talon:array[1..104] of kartya;
    tsz:integer;                  { legfelso kartya a talonban }
    sor:array[1..3,1..35] of kartya; { also 3 sor }
    ssz:array[1..3] of integer;   { legfelso kartya a sorban }
    kirakottszam:integer;
    kozepen:kartya;
    leforditott:array[1..4,1..12] of kartya;
    lsz:array[1..4] of integer;   { legfelso leforditott }
    felso:array[1..4] of kartya;
    ksz      :array[1..4] of integer;
    keresztbe:array[1..4] of kartya;
    kulso:array[1..4] of kartya;
    klikkx,klikky:integer;
    KijeloltKartya:kartya;
    jokijeloles,jocel,balgomb,jobbgomb,nincsilyenszin:boolean;
    jeloltx,jelolty,jeloltszint,jeloltszam:integer;
    regs:registers;

{$L EGAVGA.OBJ}
procedure EGAVGA; External;

{$L TRIP.OBJ}
procedure TRIP; External;

procedure egerinit(var egergombok:integer);
begin  egergombok:=0; { nincs eger }
       regs.ax:=0;
       intr($33,regs);
       if regs.ax=$ffff then
       egergombok:=regs.bx;
end;

procedure lathatoeger;
begin regs.ax:=1; intr($33,regs); end;

procedure lathatatlaneger;
begin regs.ax:=2; intr($33,regs); end;

procedure egerallapot(var oszlop,sor:integer; var g1,g2:boolean);
var   kmod:byte absolute $0:$449;
begin  regs.ax:=3;  intr($33,regs); g1:=false; g2:=false;
       If regs.bl and 1 = 1 then g1:=true;
       If regs.bl and 2 = 2 then g2:=true;
       if (kmod=0) or (kmod=1) then
          begin
                oszlop:=regs.cx div 16 + 1;
                   sor:=regs.dx div  8 + 1;
          end  else
                    if (kmod=2) or (kmod=3) or (kmod=7) then
                       begin
                             oszlop:=regs.cx div 8 + 1;
                                sor:=regs.dx div 8 + 1;
                       end else
                               begin
                                     oszlop:=regs.cx;  sor:=regs.dx;
                               end;
end;

procedure egermozgatas(oszlop,sor:integer);
var kmod:byte absolute $0:$449;
begin
      regs.ax:=4;
      if (kmod=0) or (kmod=1) then
          begin
                regs.cx:=(oszlop-1)*16;
                regs.dx:=(sor-1)*8;
          end  else
                    if (kmod=2) or (kmod=3) or (kmod=7) then
                       begin
                             regs.cx:=(oszlop-1)*8;
                             regs.dx:=(sor-1)*8;
                       end else
                               begin
                                     regs.cx:=oszlop;  regs.dx:=sor;
                               end;
       intr($33,regs);
end;

procedure egerablak(x1,y1,x2,y2:integer);
var kmod:byte absolute $0:$449;
begin   regs.ax:=7;
        if (kmod=0) or (kmod=1) then
          begin if (x1<1) or (x1>40) or (x1>=x2) or (x2<1) or (x2>40)
                  then exit;
                regs.cx:=(x1-1)*16;
                regs.dx:=(x2-1)*16;
          end  else
                    if (kmod=2) or (kmod=3) or (kmod=7) then
                       begin  if (x1<1) or (x1>80) or (x1>=x2) or (x2<1) or
                       (x2>80) then exit;
                             regs.cx:=(x1-1)*8;
                             regs.dx:=(x2-1)*8;
                       end else
                               begin
                                     regs.cx:=x1;  regs.dx:=x2;
                               end;
                  intr($33,regs);
          regs.ax:=8;
          if (kmod=0) or (kmod=1) then
          begin if (y1<1) or (y1>25) or (y1>=x2) or (y2<1) or (y2>25)
                  then exit;
                regs.cx:=(y1-1)*8;
                regs.dx:=(y2-1)*8;
          end  else
                    if (kmod=2) or (kmod=3) or (kmod=7) then
                       begin  if (y1<1) or (y1>25) or (y1>=x2) or (y2<1) or
                       (y2>25) then exit;
                             regs.cx:=(y1-1)*8;
                             regs.dx:=(y2-1)*8;
                       end else
                               begin
                                     regs.cx:=y1;  regs.dx:=y2;
                               end;
                  intr($33,regs);
end;


procedure kartyakepbetoltes;
var
    f:file of kep;
begin
     if maxavail<15300 then
       begin
          writeln('KevÇs a mem¢ria !');
          halt(2);
       end;
     {  memoriafoglalas a kartyalapoknak  }
     new(po1);  new(po2);  new(po3);  new(po4);

     assign(f,'kartya.dat');
     {$i-}  reset(f);  {$i+}
     if ioresult<>0 then
       begin
         closegraph;
         writeln('Nem tal†lom a KARTYA.DAT file-t !');
         halt(3);
       end;
     {  kartyalapok  beolvasasa  }
     read(f,po1^,po2^,po3^,po4^);
     close(f);
end;

procedure hatulrol(x,y:integer);
begin
     setfillstyle(9,7);  setcolor(7);
     bar(x,y,x+70,y+105);
     rectangle(x,y,x+70,y+105);
end;

procedure eltuntet(x,y:integer);
var i:integer;
begin
     setfillstyle(1,0);
     bar(x,y,x+70,y+105);
     setcolor(8);
     rectangle(x,y,x+70,y+105);
     settextstyle(0,0,1);  {  betukeszlet kivalasztasa  }
     settextjustify(1,1);
     for i:=1 to 4 do
      if (x=kulsohely[i,1]) and (y=kulsohely[i,2]) then
       begin
          outtextxy(kulsohely[i,1]+35,kulsohely[i,2]+30,'Kir†ly');
          outtextxy(kulsohely[i,1]+35,kulsohely[i,2]+50,'Ezen');
          outtextxy(kulsohely[i,1]+35,kulsohely[i,2]+70,'lefelÇ');
       end;
     if (x=kozephely[1]) and (y=kozephely[2]) then
      begin
         outtextxy(kozephely[1]+35,kozephely[2]+30,'èsz');
         outtextxy(kozephely[1]+35,kozephely[2]+50,'Ezen');
         outtextxy(kozephely[1]+35,kozephely[2]+70,'felfelÇ');
      end;
end;

procedure kartyakep(x,y:integer;k:kartya);
var sztr:string;
begin
     case k.szin of
     1:putimage(x,y,po1^,normalput);
     2:putimage(x,y,po2^,normalput);
     3:putimage(x,y,po3^,normalput);
     4:putimage(x,y,po4^,normalput);
     else begin sound(400); delay(30); nosound; end;
     end;
     if (k.szin=1) or (k.szin=2) then setcolor(4);
     if (k.szin=3) or (k.szin=4) then setcolor(0);
     settextstyle(1,0,4);
     settextjustify(1,1);
     case k.szam of
     1:outtextxy(x+35,y+82,'A');
     2..10:begin
                str(k.szam,sztr);
                outtextxy(x+35,y+82,sztr);
           end;
     11:outtextxy(x+35,y+82,'J');
     12:outtextxy(x+35,y+82,'Q');
     13:outtextxy(x+35,y+82,'K');
     else begin sound(400); delay(30); nosound; end;
     end;
end;

procedure keveres(p:pakli;var ujp:pakli);
var
   a:array[1..52] of integer;
   r,v,sorszam:integer;

begin
     v:=52;
     for i:=1 to 52 do a[i]:=i;
     for i:=1 to 52 do
      begin
           randomize;
           r:=random(v)+1;
           v:=v-1;
           sorszam:=a[r];
           for j:=r to v do a[j]:=a[j+1];
           ujp[sorszam].szin:=p[i].szin;
           ujp[sorszam].szam:=p[i].szam;
      end;
end;

procedure emeles(var p:pakli);
var
   a:pakli;
   r:integer;
begin
     randomize;
     r:=random(52)+1;
     j:=0;
     for i:=r to 52 do
      begin
           j:=j+1;
           a[j]:=p[i];
      end;
     for i:=1 to (r-1) do a[j+i]:=p[i];
     p:=a;
end;

procedure TszKiiras;
var s:string[3];
begin
   setcolor(15);
   setfillstyle(1,0);
   settextstyle(0,0,1);
   settextjustify(1,1);
   bar(tszhely[1]-10,tszhely[2]-10,tszhely[1]+10,tszhely[2]+10);
   str(tsz,s);
   outtextxy(tszhely[1],tszhely[2],s);
end;

procedure LszKiiras(i:integer);
var s:string[3];
begin
   setcolor(15);
   setfillstyle(1,0);
   settextstyle(0,0,1);
   settextjustify(1,1);
   bar(lszhely[i,1]-10,lszhely[i,2]-10,lszhely[i,1]+10,lszhely[i,2]+10);
   str(lsz[i],s);
   outtextxy(lszhely[i,1],lszhely[i,2],s);
end;

procedure KszKiiras;
var s:string[3];
begin
   settextstyle(0,0,1);
   settextjustify(1,1);
   setfillstyle(1,0);
   bar(168,429,188,449);
   setcolor(15);
   str(kirakottszam,s);
   outtextxy(178,439,s);
end;

procedure HelpDuma(b:byte);
begin
   setfillstyle(1,0);
   bar(351,430,549,470);
   setcolor(7);
   settextstyle(0,0,1);  {  betukeszlet kivalasztasa  }
   settextjustify(1,1);
   if b=1 then
    begin
       outtextxy(450,440,'Jelîlj ki egy k†rty†t');
       outtextxy(450,460,'(jobb gomb)');
    end
   else
    begin
       outtextxy(450,440,'Jobb gomb: egy k†rtya');
       outtextxy(450,460,'Bal gomb : îsszes k. ');
    end;
end;

procedure JatekInit;
var sp,p1,p2:pakli;  { segedpaklik kevereshez }
     i,j:integer;
begin
     { kepernyo torlese }
     ClearDevice;
     settextstyle(0,0,1);  {  betukeszlet kivalasztasa  }
     settextjustify(1,1);
     setcolor(14);
     setfillstyle(1,1);
     bar(60 ,0,160,30);
     bar(400,0,500,30);
     rectangle(60 ,0,160,30);
     rectangle(400,0,500,30);
     outtextxy(110,15,'Uj j†tÇk');
     outtextxy(450,15,'KilÇpÇs');
     { cim kiirasa }
     setfillstyle(1,1);
     bar(0,0,30,479);
     rectangle(0,0,30,479);
     settextstyle(0,1,2);  {  betukeszlet kivalasztasa  }
     settextjustify(1,1);
     outtextxy(15,240,cim);

     { kevert talon letrehozasa }
     Keveres(p0,p1);  { tobbszori keveres }
     Keveres(p1,sp);
     Keveres(sp,p1);
     Keveres(p0,p2);
     Keveres(p2,sp);
     Keveres(sp,p2);
     for i:=1 to 52 do talon[i]   :=p1[i];
     for i:=1 to 52 do talon[i+52]:=p2[i];
     tsz:=104;

     { leforditott kartyak kivetele a talonbol }
     for i:=1 to 4 do lsz[i]:=0;
     for i:=1 to 4 do
      for j:=1 to 12 do
       begin
          leforditott[i,j]:=talon[tsz];
          tsz:=tsz-1;
          lsz[i]:=lsz[i]+1;
       end;

     { ahol nincs semmi }
     kozepen.szin:=0;
     kirakottszam:=0;
     for i:=1 to 4 do
      begin
         felso[i].szin:=0;
         ksz[i]:=0;
         keresztbe[i].szin:=0;
         kulso[i].szin:=0;
      end;
     for i:=1 to 3 do ssz[i]:=0;

     for i:=1 to 3 do Eltuntet(sorhely[i,1],sorhely[i,2]);
     for i:=1 to 4 do Hatulrol(leforditotthely[i,1],leforditotthely[i,2]);
     for i:=1 to 4 do Eltuntet(kulsohely[i,1],kulsohely[i,2]);
     for i:=1 to 4 do Eltuntet(kereszthely[i,1],kereszthely[i,2]);
     Eltuntet(kozephely[1],kozephely[2]);
     Hatulrol(talonhely[1],talonhely[2]);
     For i:=1 to 4 do LszKiiras(i);
     TszKiiras;
     setcolor(7);
     rectangle(40,428,240,450);
     settextstyle(0,0,1);
     settextjustify(1,1);
     outtextxy(140,439,'Eddig kirakt†l    sort.');
     KszKiiras;
     setcolor(7);
     rectangle(350,425,550,475);
     EgerMozgatas(leforditotthely[1,1]+35,leforditotthely[1,2]+52);
     LathatoEger;
end;

procedure Kilepes;
begin
   {  memoria  felszabaditasa  }
     Dispose(po1);  Dispose(po2);  Dispose(po3);  Dispose(po4);
     { grafika lezarasa }
     closegraph;
     writeln(' >>>  Good-Byte  <<<');
     Halt(0);
end;

{ igaz ha az eger rajta van az (x,y) koordinataju kartyan }
function EgerRajta(x,y:integer):boolean;
begin
     EgerRajta:= (x<=klikkx) and (x+70>=klikkx) and
                 (y<=klikky) and (y+105>=klikky);
end;

function UjJatek:boolean;
begin
   UjJatek:=(klikkx>=60) and (klikkx<=160) and
            (klikky>=0 ) and (klikky<=30);
end;

procedure KilepesVizsgalat;
begin
   If (klikkx>=400) and (klikkx<=500) and
      (klikky>=0 ) and (klikky<=30) then
     begin
        LathatatlanEger;
        Kilepes;
     end;
end;

{ leveszi az (x,y) helyÅ k†rty†t a helyÇrîl }
procedure LeVesz(x,y:integer);
var i:integer;
begin
   if (x=kozephely[1]) and (y=kozephely[2]) then
    if kozepen.szam=1 then
      begin
         kozepen.szin:=0;
         Eltuntet(x,y);
      end
    else
      begin
         kozepen.szam:=kozepen.szam-1;
         KartyaKep(x,y,kozepen);
      end;
   for i:=1 to 3 do
    if (x=sorhely[i,1]) and (y=sorhely[i,2]) then
     begin
        ssz[i]:=ssz[i]-1;
        if ssz[i]=0 then  Eltuntet(x,y)
        else  KartyaKep(x,y,sor[i,ssz[i]]);
     end;
   for i:=1 to 4 do
    if (x=kulsohely[i,1]) and (y=kulsohely[i,2]) then
     if kulso[i].szam=13 then
       begin
          kulso[i].szin:=0;
          Eltuntet(x,y);
       end
     else
       begin
          Inc(kulso[i].szam);
          KartyaKep(x,y,kulso[i]);
       end;
   for i:=1 to 4 do
    if (x=leforditotthely[i,1]) and (y=leforditotthely[i,2]) then
     begin
        felso[i].szin:=0;
        if lsz[i]=0 then Eltuntet(x,y)
        else Hatulrol(x,y);
     end;
   for i:=1 to 4 do
    if (x=kereszthely[i,1]) and (y=kereszthely[i,2]) then
     if ksz[i]=1 then
      begin
         ksz[i]:=0; keresztbe[i].szin:=0;
         Eltuntet(x,y);
      end
     else
      begin
         ksz[i]:=ksz[i]-1;
         keresztbe[i].szam:=keresztbe[i].szam-1;
         KartyaKep(x,y,keresztbe[i]);
      end;
   setcolor(0);
   Rectangle(x-3,y-3,x+73,y+108);
end;

begin
     { eger inicializalasa }
     EgerInit(i);
     if i=0 then
      begin
         Writeln('A j†tÇkhoz egÇr szÅksÇges');
         Halt(1);
      end;

     { EGAVGA.BGI Çs TRIP.CHR az EXE file-ban van }
     If RegisterBGIDriver(@EGAVGA) < 0 then  halt(3);
     If RegisterBGIFont(@TRIP) < 0  then  halt(4);

     { VGA inicializalas }
     i:=VGA; j:=VGAHi;
     Initgraph(i,j,'');
     i:=GraphResult;
     if i<>0 then begin
                     Writeln('Graphic error: ',GraphErrorMsg(i));
                     Halt(1);
                  end;

     { Kartyak grafikajanak betoltese a KARTYA.DAT file-bol }
     Kartyakepbetoltes;

     { p0 pakli feltoltese }
     for i:=1 to 4 do
      for j:=1 to 13 do
       begin
            p0[(i-1)*13+j].szin:=i;
            p0[(i-1)*13+j].szam:=j;
       end;

     EgerAblak(35,5,630,450);
     { jatek }
     repeat
ujrajatszas:
        JatekInit;

        repeat
           repeat
              HelpDuma(1);
              jokijeloles:=false;
              delay(200);
              repeat
                 EgerAllapot(klikkx,klikky,balgomb,jobbgomb);
              until jobbgomb;
              KilepesVizsgalat;
              If UjJatek then begin
                                 LathatatlanEger;
                                 Goto ujrajatszas;
                              end;
              if EgerRajta(talonhely[1],talonhely[2]) then
               if tsz=0 then  { sorok --> talon }
                begin
                   for i:=1 to 3 do
                    begin
                       for j:=1 to ssz[i] do
                        begin
                           tsz:=tsz+1;
                           talon[tsz]:=sor[i,j];
                        end;
                       ssz[i]:=0;
                       lathatatlaneger;
                       Eltuntet(sorhely[i,1],sorhely[i,2]);
                       lathatoeger;
                    end;
                   if tsz>0 then
                    begin
                       lathatatlaneger;
                       Hatulrol(talonhely[1],talonhely[2]);
                       lathatoeger;
                    end;
                   TszKiiras;
                end
               else   { talon --> sorok }
                begin
                   for i:=1 to 3 do
                    if tsz>0 then
                     begin
                        ssz[i]:=ssz[i]+1;
                        sor[i,ssz[i]]:=talon[tsz];
                        tsz:=tsz-1;
                        KartyaKep(sorhely[i,1],sorhely[i,2],sor[i,ssz[i]]);
                     end;
                    if tsz=0 then
                     begin
                       lathatatlaneger;
                       Eltuntet(talonhely[1],talonhely[2]);
                       lathatoeger;
                     end;
                    TszKiiras;
                end;

              { sorok vizsgalata }
              for i:=1 to 3 do
               If EgerRajta(sorhely[i,1],sorhely[i,2]) then
                If ssz[i]>0 then
                 begin
                    jeloltx:=sorhely[i,1];
                    jelolty:=sorhely[i,2];
                    KijeloltKartya:=sor[i,ssz[i]];
                    jeloltszint:=1;
                    lathatatlaneger;
                    setcolor(15);
                    Rectangle(jeloltx-3,jelolty-3,jeloltx+73,jelolty+108);
                    lathatoeger;
                    jokijeloles:=true;
                 end;

              { kÅlsîk vizsgalata }
              for i:=1 to 4 do
               if EgerRajta(kulsohely[i,1],kulsohely[i,2]) then
                if kulso[i].szin<>0 then
                 begin
                    jeloltx:=kulsohely[i,1];
                    jelolty:=kulsohely[i,2];
                    KijeloltKartya:=kulso[i];
                    jeloltszam:=14-kulso[i].szam;
                    jeloltszint:=3;
                    lathatatlaneger;
                    setcolor(15);
                    Rectangle(jeloltx-3,jelolty-3,jeloltx+73,jelolty+108);
                    lathatoeger;
                    jokijeloles:=true;
                 end;

              { leforditottak Çs felsîk vizsgalata }
              for i:=1 to 4 do
               if EgerRajta(leforditotthely[i,1],leforditotthely[i,2]) then
                if felso[i].szin=0 then { ha nincs felso kartya }
                 begin
                    if lsz[i]>0 then
                     begin
                        felso[i]:=leforditott[i,lsz[i]];
                        Lathatatlaneger;
                        KartyaKep(leforditotthely[i,1],leforditotthely[i,2],
                                  felso[i]);
                        lathatoeger;
                        lsz[i]:=lsz[i]-1;
                        LszKiiras(i);
                     end;
                 end
                else
                 begin
                    jeloltx:=leforditotthely[i,1];
                    jelolty:=leforditotthely[i,2];
                    KijeloltKartya:=felso[i];
                    jeloltszint:=5;
                    lathatatlaneger;
                    setcolor(15);
                    Rectangle(jeloltx-3,jelolty-3,jeloltx+73,jelolty+108);
                    lathatoeger;
                    jokijeloles:=true;
                 end;

              { keresztben †ll¢k vizsgalata }
              for i:=1 to 4 do
               if EgerRajta(kereszthely[i,1],kereszthely[i,2]) then
                if ksz[i]>0 then
                 begin
                    jeloltx:=kereszthely[i,1];
                    jelolty:=kereszthely[i,2];
                    KijeloltKartya:=keresztbe[i];
                    jeloltszam:=ksz[i];
                    jeloltszint:=4;
                    lathatatlaneger;
                    setcolor(15);
                    Rectangle(jeloltx-3,jelolty-3,jeloltx+73,jelolty+108);
                    lathatoeger;
                    jokijeloles:=true;
                 end;
              { kîzÇpen levî vizsgalata }
               if EgerRajta(kozephely[1],kozephely[2]) then
                if kozepen.szin<>0 then
                 begin
                    jeloltx:=kozephely[1];
                    jelolty:=kozephely[2];
                    KijeloltKartya:=kozepen;
                    jeloltszam:=kozepen.szam;
                    jeloltszint:=2;
                    lathatatlaneger;
                    setcolor(15);
                    Rectangle(jeloltx-3,jelolty-3,jeloltx+73,jelolty+108);
                    lathatoeger;
                    jokijeloles:=true;
                 end;
           until JoKijeloles;

           repeat
              HelpDuma(2);
              jocel:=false;
              delay(200);
              repeat
                 EgerAllapot(klikkx,klikky,balgomb,jobbgomb);
              until jobbgomb or balgomb;
              KilepesVizsgalat;
              If UjJatek then begin
                                 LathatatlanEger;
                                 Goto ujrajatszas;
                              end;
              If EgerRajta(jeloltx,jelolty) then
               begin
                  jocel:=true;
                  lathatatlaneger;
                  setcolor(0);
                  Rectangle(jeloltx-3,jelolty-3,jeloltx+73,jelolty+108);
                  lathatoeger;
               end
              else
               begin  { ha nem a jelolt hely a cel }
                 if EgerRajta(kozephely[1],kozephely[2]) then
                   if (kozepen.szin=0) and
                      (KijeloltKartya.szam=1) then
                     begin
                        kozepen:=kijeloltkartya;
                        lathatatlaneger;
                        KartyaKep(kozephely[1],kozephely[2],kozepen);
                        lathatoeger;
                        LeVesz(jeloltx,jelolty);
                        jocel:=true;
                     end
                   else
                    if (KijeloltKartya.szam=kozepen.szam+1) and
                       (kijeloltkartya.szin=kozepen.szin) then
                     begin
                        if jobbgomb then
                         begin
                            kozepen:=kijeloltkartya;
                            lathatatlaneger;
                            KartyaKep(kozephely[1],kozephely[2],kozepen);
                            lathatoeger;
                            LeVesz(jeloltx,jelolty);
                            if kozepen.szam=13 then
                              begin
                                 kozepen.szin:=0;
                                 Inc(kirakottszam);
                                 KszKiiras;
                                 lathatatlaneger;
                                 Eltuntet(jeloltx,jelolty);
                                 lathatoeger;
                              end;
                         end
                        else { bal gomb lett megnyomva }
                         if jeloltszint=3 then { jelolt kiralysor }
                          begin
                             kozepen.szin:=0;
                             lathatatlaneger;
                             Eltuntet(kozephely[1],kozephely[2]);
                             lathatoeger;
                             for j:=1 to 4 do
                              if (jeloltx=kulsohely[j,1]) and
                                 (jelolty=kulsohely[j,2]) then
                                begin
                                   kulso[j].szin:=0;
                                   Eltuntet(jeloltx,jelolty);
                                   setcolor(0);
                                   rectangle(jeloltx-3,jelolty-3,
                                             jeloltx+73,jelolty+108);
                                end;
                             Inc(kirakottszam);
                             KszKiiras;
                          end;
                        jocel:=true;
                     end;
                  for i:=1 to 4 do
                   if EgerRajta(leforditotthely[i,1],leforditotthely[i,2]) then
                    if (felso[i].szin=0) and (jeloltszint=5) then
                     begin
                        felso[i]:=kijeloltkartya;
                        lathatatlaneger;
                        KartyaKep(leforditotthely[i,1],leforditotthely[i,2],
                                  felso[i]);
                        lathatoeger;
                        LeVesz(jeloltx,jelolty);
                        jocel:=true;
                     end;
                 for i:=1 to 4 do
                  if EgerRajta(kereszthely[i,1],kereszthely[i,2]) then
                   if (ksz[i]=0) and (jeloltszint<>1) then
                     begin
                        Inc(ksz[i]);
                        keresztbe[i]:=KijeloltKartya;
                        lathatatlaneger;
                        KartyaKep(kereszthely[i,1],kereszthely[i,2],
                                  keresztbe[i]);
                        lathatoeger;
                        LeVesz(jeloltx,jelolty);
                        jocel:=true;
                     end
                   else { van keresztben kartya }
                    if (kijeloltkartya.szam=keresztbe[i].szam+1) and
                       (kijeloltkartya.szin=keresztbe[i].szin) then
                     begin
                        Inc(ksz[i]);
                        keresztbe[i]:=KijeloltKartya;
                        lathatatlaneger;
                        KartyaKep(kereszthely[i,1],kereszthely[i,2],
                                  keresztbe[i]);
                        lathatoeger;
                        LeVesz(jeloltx,jelolty);
                        jocel:=true;
                     end;
                  for i:=1 to 4 do
                   if EgerRajta(kulsohely[i,1],kulsohely[i,2]) then
                    if (kulso[i].szin=0) and { ha nincs ott kartya }
                       (kijeloltkartya.szam=13) then { es kiraly }
                      begin
                         NincsIlyenSzin:=true;
                         for j:=1 to 4 do
                           if (kulso[j].szin=kijeloltkartya.szin) and
                              (jeloltszint<>3)  then
                             NincsIlyenSzin:=false;
                         If NincsIlyenSzin then
                          begin
                           if jobbgomb then
                            begin
                               kulso[i]:=kijeloltkartya;
                               lathatatlaneger;
                               KartyaKep(kulsohely[i,1],kulsohely[i,2],
                                         kulso[i]);
                               lathatoeger;
                               LeVesz(jeloltx,jelolty);
                               jocel:=true;
                            end
                           else
                            if jeloltszint=4 then
                             for j:=1 to 4 do
                              if (jeloltx=kereszthely[j,1]) and
                                 (jelolty=kereszthely[j,2]) then
                                begin
                                   kulso[i].szam:=14-ksz[j];
                                   kulso[i].szin:=keresztbe[j].szin;
                                   ksz[j]:=0;
                                   keresztbe[j].szin:=0;
                                   lathatatlaneger;
                                   setcolor(0);
                                   rectangle(jeloltx-3,jelolty-3,jeloltx+73,
                                             jelolty+108);
                                   Eltuntet(kereszthely[j,1],kereszthely[j,2]);
                                   Kartyakep(kulsohely[i,1],kulsohely[i,2],
                                             kulso[i]);
                                   Eltuntet(kereszthely[j,1],kereszthely[j,2]);
                                   lathatoeger;
                                   jocel:=true;
                                end;
                          end;
                      end
                    else { ha van kartya }
                      if (kulso[i].szin=kijeloltkartya.szin) and
                         (kulso[i].szam=kijeloltkartya.szam+1) then
                        begin
                           if jobbgomb then
                            begin
                               kulso[i]:=kijeloltkartya;
                               lathatatlaneger;
                               KartyaKep(kulsohely[i,1],kulsohely[i,2],
                                         kulso[i]);
                               lathatoeger;
                               LeVesz(jeloltx,jelolty);
                               jocel:=true;
                            end
                           else  { bal gomb lett lenyomva }
                            if (jeloltszint=2) or (jeloltszint=4) then
                             begin
                                if (jeloltx=kozephely[1]) and
                                   (jelolty=kozephely[2]) then
                                  begin
                                     kozepen.szin:=0;
                                     kulso[i].szam:=1;
                                     lathatatlaneger;
                                     Eltuntet(jeloltx,jelolty);
                                     setcolor(0);
                                     rectangle(jeloltx-3,jelolty-3,jeloltx+73,
                                               jelolty+108);
                                     lathatoeger;
                                     jocel:=true;
                                  end;
                                for j:=1 to 4 do
                                 if (jeloltx=kereszthely[j,1]) and
                                    (jelolty=kereszthely[j,2]) then
                                   begin
                                      kulso[i].szam:=kulso[i].szam-ksz[j];
                                      keresztbe[j].szin:=0;
                                      ksz[j]:=0;
                                      lathatatlaneger;
                                      Eltuntet(jeloltx,jelolty);
                                      setcolor(0);
                                      rectangle(jeloltx-3,jelolty-3,jeloltx+73,
                                                jelolty+108);
                                      if kulso[i].szam>1 then
                                       KartyaKep(kulsohely[i,1],kulsohely[i,2],
                                                 kulso[i]);
                                      lathatoeger;
                                      jocel:=true;
                                   end;
                             end;
                           if kulso[i].szam=1 then
                            begin
                               Inc(kirakottszam);
                               KszKiiras;
                               kulso[i].szin:=0;
                               lathatatlaneger;
                               Eltuntet(kulsohely[i,1],kulsohely[i,2]);
                               lathatoeger;
                            end;
                        end;

               end;
           until JoCel;
        until (kirakottszam=8);   { amig ki nem rakta a 8 sort }
        LathatatlanEger;
        setfillstyle(9,1);
        setcolor(14);
        bar(100,200,540,260);
        rectangle(100,200,540,260);
        settextstyle(0,0,1);
        settextjustify(1,1);
        outtextxy(320,220,'SikerÅlt!  NyeremÇnyed egy £jabb j†tÇk.');
        outtextxy(320,240,'ESC:kilÇpÇs, m†s billentyÅ:j†tÇk');
        Sound(440); Delay(140); Nosound;
        Delay(50); Nosound;
        Sound(440); Delay(140); Nosound;
        Delay(50); Nosound;
        Sound(620); Delay(250); Nosound;
        Delay(100); Nosound;
        Sound(620); Delay(300); Nosound;
        While Keypressed do ch:=Readkey;
        ch:=Readkey;
     until ch=#27;

     Kilepes;
end.