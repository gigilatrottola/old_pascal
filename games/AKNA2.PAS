  {$M 32768,0,655360}   { stack novelese a FELEMEL eljaras szamara }
program aknakereso;
uses graph,crt,dos;
label ujra;
const
     maxx=29;
     maxy=29;
var
     {  tabla  nagyobb a szeleken }
     tabla:array[0..maxx+1,0..maxy+1] of byte;
     fent :array[0..maxx+1,0..maxy+1] of boolean;
     x,y,i,j,grdr,grm,xhossz,yhossz,aknaszam,kilott,maxkilott,
     tx,ty    :integer;  { tabla  helyzete }
     jobb,bal:boolean;   { egergombok }
     ex,ey:integer; { eger helyzete }
     vesztett:boolean;
     l:longint;
     scroll:byte absolute $0:$417;
     vanbgi:boolean;
     regs:registers;
     c:char;

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



procedure Init(px,py,pasz:integer);
label ismet;
begin
     lathatatlaneger;
     { alapbeallitasok }
     xhossz:=px;  yhossz:=py;  aknaszam:=pasz;
     kilott:=0;     maxkilott:=xhossz*yhossz-aknaszam;

     for i:=0 to xhossz+1 do   {  szelek  feltoltese  }
       begin
            fent[i,0]:=true;
            fent[i,yhossz+1]:=true;
            tabla[i,0]:=10;
            tabla[i,yhossz+1]:=10;
       end;
     for i:=0 to yhossz+1 do
       begin
            fent[0,i]:=true;
            fent[xhossz+1,i]:=true;
            tabla[0,i]:=10;
            tabla[xhossz+1,i]:=10;
       end;

     {  tabla helye }
     tx:=240 - (xhossz*16) div 2;
     ty:=240 - (yhossz*16) div 2;
     { tabla alapfeltoltese  }
     for i:=1 to xhossz do
       for j:=1 to yhossz do
        begin
              tabla[i,j]:=0;
              fent[i,j]:=false;
        end;
     { aknak elhelyezese }
     randomize;
     i:=0;
     repeat
ismet:     x:=random(xhossz)+1;
           y:=random(yhossz)+1;
           if tabla[x,y]<>0 then goto ismet;
           tabla[x,y]:=9;
           i:=i+1;
     until i>=aknaszam;

     { regi tabla torlese }
     setfillstyle(1,0);
     bar(0,0,479,479);
     {  tabla kirajzolasa  }
     setfillstyle(1,8);
     bar(tx,ty,tx+xhossz*16,ty+yhossz*16);
     setcolor(3);
     for i:=0 to xhossz do  line(tx+i*16,ty,tx+i*16,ty+yhossz*16);
     for i:=0 to yhossz do  line(tx,ty+i*16,tx+xhossz*16,ty+i*16);
     SettextJustify(centertext,centertext);
     { szomszedsagi adatok beallitasa }
     for x:=1 to xhossz do
      for y:=1 to yhossz do
       if tabla[x,y]<>9 then
         begin       {  i -> a szomszedos aknak szama }
            i:=0;
            if tabla[x-1,y-1]=9 then i:=i+1;
            if tabla[x+1,y+1]=9 then i:=i+1;
            if tabla[x-1,y+1]=9 then i:=i+1;
            if tabla[x+1,y-1]=9 then i:=i+1;
            if tabla[x,y-1]=9   then i:=i+1;
            if tabla[x,y+1]=9   then i:=i+1;
            if tabla[x-1,y]=9   then i:=i+1;
            if tabla[x+1,y]=9   then i:=i+1;
            tabla[x,y]:=i;
         end;
     {  eger beallitasa  }
     egerablak(tx+1,ty+1,tx+16*xhossz-1,ty+16*yhossz-1);
     egermozgatas(tx+(16*xhossz) div 2,ty+(16*yhossz) div 2);
     vesztett:=false;
     lathatoeger;
end;

procedure felhoz2(x,y:integer);
var  xx,yy,i,j:integer;
       c:string[1];
begin
     lathatatlaneger;
     setfillstyle(1,3);
     xx:=tx+3+(x-1)*16;
     yy:=ty+3+(y-1)*16;

              { keret }
               setcolor(0);
               line(xx-2,yy-2,xx-2,yy+12);
               line(xx-1,yy-2,xx-1,yy+12);
               line(xx-2,yy-2,xx+12,yy-2);
               line(xx-2,yy-1,xx+12,yy-1);
               setcolor(7);
               line(xx+11,yy-1,xx+11,yy+12);
               line(xx+12,yy-2,xx+12,yy+12);
               line(xx-1,yy+11,xx+12,yy+11);
               line(xx-2,yy+12,xx+12,yy+12);
     if tabla[x,y]<>9 then
       begin
             if tabla[x,y]<>0 then
               begin
                  setcolor(14);
                  str(tabla[x,y],c);
                  outtextxy(xx+5,yy+6,c);
               end;
       end
        else
        begin
           if vesztett then
              begin
                 setfillstyle(1,12);
                 setcolor(12);
                 pieslice(xx+5,yy+5,0,360,3);
              end
            else
              begin
                 setfillstyle(1,12);
                 setcolor(12);
                 circle(xx+5,yy+5,3);
              end;
        end;
     lathatoeger;
end;

procedure felhoz(x,y:integer);
var  xx,yy,i,j:integer;
       c:string[1];
begin
     if scroll<>scroll or 16 then
      begin sound(1000); delay(20); nosound; end;
     lathatatlaneger;
     setfillstyle(1,3);
     xx:=tx+3+(x-1)*16;
     yy:=ty+3+(y-1)*16;

               { keret }
               setcolor(0);
               line(xx-2,yy-2,xx-2,yy+12);
               line(xx-1,yy-2,xx-1,yy+12);
               line(xx-2,yy-2,xx+12,yy-2);
               line(xx-2,yy-1,xx+12,yy-1);
               setcolor(7);
               line(xx+11,yy-1,xx+11,yy+12);
               line(xx+12,yy-2,xx+12,yy+12);
               line(xx-1,yy+11,xx+12,yy+11);
               line(xx-2,yy+12,xx+12,yy+12);

          if tabla[x,y]<>0 then
              begin
               setcolor(14);
               str(tabla[x,y],c);
               outtextxy(xx+5,yy+6,c);
              end;

     fent[x,y]:=true;
     kilott:=kilott+1;
     lathatoeger;
end;

procedure felemel(x,y:integer);
var szomszed:array[1..8] of byte;
    szf:array[1..8] of boolean;
    i:integer;
begin
     felhoz(x,y);
     szomszed[1]:=tabla[x-1,y-1];
     szomszed[2]:=tabla[x+1,y-1];
     szomszed[3]:=tabla[x+1,y+1];
     szomszed[4]:=tabla[x-1,y+1];
     szomszed[5]:=tabla[x,y-1];
     szomszed[6]:=tabla[x,y+1];
     szomszed[7]:=tabla[x-1,y];
     szomszed[8]:=tabla[x+1,y];

     for i:=1 to 8 do
      begin
       szf[1]:=fent[x-1,y-1];
       szf[2]:=fent[x+1,y-1];
       szf[3]:=fent[x+1,y+1];
       szf[4]:=fent[x-1,y+1];
       szf[5]:=fent[x,y-1];
       szf[6]:=fent[x,y+1];
       szf[7]:=fent[x-1,y];
       szf[8]:=fent[x+1,y];
       if not szf[i] then
        if szomszed[i]=0 then
          begin
              case i of
              1:felemel(x-1,y-1);
              2:felemel(x+1,y-1);
              3:felemel(x+1,y+1);
              4:felemel(x-1,y+1);
              5:felemel(x,y-1);
              6:felemel(x,y+1);
              7:felemel(x-1,y);
              8:felemel(x+1,y);
              end; { case }
          end
         else
          if szomszed[i]<9 then
              case i of
              1:felhoz(x-1,y-1);
              2:felhoz(x+1,y-1);
              3:felhoz(x+1,y+1);
              4:felhoz(x-1,y+1);
              5:felhoz(x,y-1);
              6:felhoz(x,y+1);
              7:felhoz(x-1,y);
              8:felhoz(x+1,y);
              end; { case }
      end;
end;

procedure Egervizsgalat;
begin
  if jobb then
   begin
       ex:=ex-tx;
       ey:=ey-ty;
       x:=ex div 16 + 1;
       y:=ey div 16 + 1;
       if (x<1) or (x>xhossz) or (y<1) or (y>yhossz) then
         begin write(#7); lathatatlaneger;
          halt(3); end;
       if not fent[x,y] then
        case tabla[x,y] of
        9:vesztett:=true;
        1..8:felhoz(x,y);
        0:felemel(x,y);
        end; { case }
   end;

end;

procedure menuki(i:integer);
var  m:integer;
begin
     m:=(i-1)*20;
     setcolor(0);
     line(505,135+m,615,135+m);
     line(505,136+m,614,136+m);
     line(505,135+m,505,155+m);
     line(506,135+m,506,154+m);
     setcolor(7);
     line(506,155+m,615,155+m);
     line(507,154+m,615,154+m);
     line(614,136+m,614,155+m);
     line(615,135+m,615,155+m);
end;

procedure menube(i:integer);
var  m:integer;
begin
     m:=(i-1)*20;
     setcolor(8);
     line(505,135+m,615,135+m);
     line(505,136+m,614,136+m);
     line(505,135+m,505,155+m);
     line(506,135+m,506,154+m);
     line(506,155+m,615,155+m);
     line(507,154+m,615,154+m);
     line(614,136+m,614,155+m);
     line(615,135+m,615,155+m);
end;

function beolvas(m:byte;s:string):integer;
label vege,ujbol,beir,be;
var  w,i,hiba:integer;  st:string[10];  c:char;
     ki:boolean;
begin
     ki:=true;
ujbol:
     setfillstyle(1,8);
     bar(490,300,635,320);
     setcolor(7);
     line(491,321,636,321);
     line(490,320,636,320);
     line(635,300,635,321);
     line(636,301,636,321);
     setcolor(15);
     outtextxy(545,310,s);
     i:=1;  st:='';
     repeat
       if keypressed then
         begin
be:           c:=readkey;
              if (ord(c)>=$30) and (ord(c)<=$39)
                then begin          {  szamjegy  }
                          setcolor(15);
                          outtextxy(603+(i-1)*9,310,c);
                          st:=st+c;
                          i:=i+1;
                          if i>3 then
                           begin
                               val(st,w,hiba);
                               goto beir;
                           end;
                     end;
              if (c=#27) and ki then
               begin
                    case m of
                    1:beolvas:=xhossz;
                    2:beolvas:=yhossz;
                    3:beolvas:=aknaszam;
                    end;
                    goto vege;
               end;
              if (c=#13) and (i>1) then
                begin
                     val(st,w,hiba);
                     goto beir;
                end;
         end;
       setcolor(15);
       line(600+(i-1)*8,316,608+(i-1)*8,316);
       delay(50);
       if keypressed then
         begin
            setcolor(8);
            line(600+(i-1)*8,316,608+(i-1)*8,316);
            goto be;
         end;
       setcolor(8);
       line(600+(i-1)*8,316,608+(i-1)*8,316);
       delay(100);
     until  false;
beir:
     case m of
     1:if (w<2) or (w>maxx)  then begin ki:=false; goto ujbol; end;
     2:if (w<2) or (w>maxy)  then begin ki:=false; goto ujbol; end;
     3:if (w<1) or (w>=xhossz*yhossz) then begin ki:=false; goto ujbol; end;
     end; { case }
     {  tabla valtoztatasa }
     if m=1 then
      if aknaszam>=w*yhossz then aknaszam:=w*yhossz div 2;
     if m=2 then
      if aknaszam>=w*xhossz then aknaszam:=w*xhossz div 2;
     beolvas:=w;
vege:
     setfillstyle(1,0);
     bar(490,300,636,321);
end;

procedure menu(var m:integer);
label ism;
var  kiemelt,maxkiemelt:integer; c:char;
begin
     maxkiemelt:=5;
     if m=2 then maxkiemelt:=6;
     kiemelt:=1;
     if m=2 then kiemelt:=6;
     setfillstyle(1,8);  setcolor(15);
     if m=2 then bar(500,130,620,260)
      else bar(500,130,620,240);
     outtextxy(550,146,'Uj j†tÇk');
     If m=2 then setcolor(0);
     outtextxy(550,166,'Sor');
     outtextxy(550,186,'Oszlop');
     outtextxy(550,206,'Aknasz†m');
     If m=2 then setcolor(15);
     outtextxy(550,226,'KilÇp');
     if m=2 then  outtextxy(550,247,'Vissza');
     setcolor(7);
     if m=2 then
      begin
           line(501,261,621,261);
           line(502,262,622,262);
           line(621,131,621,261);
           line(622,132,622,262);
      end
      else
      begin
           line(501,241,621,241);
           line(502,242,622,242);
           line(621,131,621,241);
           line(622,132,622,242);
      end;

     menuki(kiemelt);
      repeat
ism:     c:=readkey;  if c=#0 then c:=readkey;
         case c of
         #72:begin
                 menube(kiemelt);
                 kiemelt:=kiemelt-1;
                 if kiemelt<1 then kiemelt:=maxkiemelt;
                 menuki(kiemelt);
             end;
         #80:begin
                  menube(kiemelt);
                  kiemelt:=kiemelt+1;
                  if kiemelt>maxkiemelt then kiemelt:=1;
                  menuki(kiemelt);
             end;
         end;
      until (c=#13)  or  (c=#32)  or  ((m=2) and (c=#27));

      if (m=2) and (kiemelt=1) then m:=1;  { uj jatek }
      if kiemelt=5 then
         begin
              closegraph;
              lathatatlaneger;
              if scroll=scroll or 16 then scroll:=scroll-16;
              halt(0);
         end;
      if m<>2 then
       begin
        if kiemelt=2 then begin xhossz  :=beolvas(1,'Sorok sz†ma :'); goto ism; end;
        if kiemelt=3 then begin yhossz  :=beolvas(2,'Oszlopok sz.:'); goto ism; end;
        if kiemelt=4 then begin aknaszam:=beolvas(3,'Akn†k sz†ma :'); goto ism; end;
       end
      else if (kiemelt=2) or (kiemelt=3) or (kiemelt=4) then goto ism;
      setfillstyle(1,0);
      bar(500,130,622,262);
end;

function Billentyuzetvizsgalat:boolean;
var c:char;   jj:integer;
begin;
     billentyuzetvizsgalat:=false;
     c:=readkey;
     if c=#0 then c:=readkey;
     case c of
     #27:begin
              closegraph;
              lathatatlaneger;
              if scroll=scroll or 16 then scroll:=scroll-16;
              halt(0);
         end;
     #32,#13:
         begin
              jj:=2;
              menu(jj);
              if jj=1 then billentyuzetvizsgalat:=true;
         end;
     end; { case }
end;

procedure atnevez(s1,s2:string);
var  f:file;
begin
     assign(f,s1);
     rename(f,s2);
end;

begin
     {  ha nincs eger : kilepes  }
     EgerInit(i);
     if i=0 then begin
                      writeln('A j†tÇkhoz egÇr szÅksÇges');
                      halt(2);
                 end;

     if fsearch('egavga.bgi','')<>'' then  vanbgi:=true
      else vanbgi:=false;
     {  VGA grafika inicializalas  }
     if ( not vanbgi ) and ( fsearch('akna.drv','')='' )  then
      begin
         writeln('Nem tal†lom az AKNA.DRV file-t');
         halt(4);
      end;
     grdr:=VGA;   grm:=VGAHi;
     if not vanbgi then atnevez('akna.drv','egavga.bgi');
     InitGraph(grdr,grm,'akna.drv');
     if not vanbgi then atnevez('egavga.bgi','akna.drv');
     i:=graphresult;
     If i<>0 then
       begin
            writeln(grapherrormsg(i));
            halt(1);
       end;

     setfillstyle(1,8);  setcolor(15);
     bar(500,370,620,390);
     outtextxy(510,377,'SCROLL: hang');
     setcolor(7);
     line(501,391,621,391);
     line(502,392,622,392);
     line(621,371,621,391);
     line(622,372,622,392);

     setfillstyle(1,8);  setcolor(15);
     bar(500,400,620,420);
     outtextxy(510,407,'ENTER : menÅ');
     setcolor(7);
     line(501,421,621,421);
     line(502,422,622,422);
     line(621,401,621,421);
     line(622,402,622,422);
     setfillstyle(1,8);  setcolor(15);
     bar(500,430,620,450);
     outtextxy(510,437,'ESC   : kilÇp');
     setcolor(7);
     line(501,451,621,451);
     line(502,452,622,452);
     line(621,431,621,451);
     line(622,432,622,452);
     lathatoeger;
     xhossz:=8;
     yhossz:=8;
     aknaszam:=10;
     Init(xhossz,yhossz,aknaszam);
ujra:
     repeat
           Egerallapot(ex,ey,bal,jobb);
           if jobb or bal then Egervizsgalat;
           if keypressed then
             if Billentyuzetvizsgalat then
              begin
                   Init(xhossz,yhossz,aknaszam);
                   goto ujra;
              end;
           if kilott>=maxkilott then
             begin
               for i:=1 to xhossz do
                  for j:=1 to yhossz do
                    if not fent[i,j] then felhoz2(i,j);
               setfillstyle(1,8);  setcolor(15);
               bar(500,50,620,70);
               outtextxy(560,60,'NYERT !');
               setcolor(7);
               line(501,71,621,71);
               line(502,72,622,72);
               line(621,51,621,71);
               line(622,52,622,72);
               if scroll<>scroll or 16 then
                begin
                    for l:=625 to 7500 do sound(l div 13);
                    nosound;
                end;
             repeat
                 setcolor(12);
                 outtextxy(560,60,'NYERT !');
                 delay(200);
                 setcolor(15);
                 outtextxy(560,60,'NYERT !');
                 delay(200);
             until keypressed;
             While keypressed do c:=readkey;
               j:=1;
               menu(j);
               setfillstyle(1,0);
               bar(500,50,622,72);
               Init(xhossz,yhossz,aknaszam);
             end;
     until vesztett;
           if scroll<>scroll or 16 then  sound(600);
           for i:=1 to xhossz do
               for j:=1 to yhossz do
                 if not fent[i,j] then felhoz2(i,j);
             setfillstyle(1,8);  setcolor(15);
             bar(500,50,620,70);
             outtextxy(560,60,'BUMM !');
             setcolor(7);
             line(501,71,621,71);
             line(502,72,622,72);
             line(621,51,621,71);
             line(622,52,622,72);
            if scroll<>scroll or 16 then
             begin
               for l:=7500 downto 625 do sound(l div 13);
               nosound;
             end;
             repeat
                 setcolor(12);
                 outtextxy(560,60,'BUMM !');
                 delay(200);
                 setcolor(15);
                 outtextxy(560,60,'BUMM !');
                 delay(200);
             until keypressed;
             While keypressed do c:=readkey;
             j:=1;
             menu(j);
             setfillstyle(1,0);
             bar(500,50,622,72);
             Init(xhossz,yhossz,aknaszam);
             goto ujra;
end.