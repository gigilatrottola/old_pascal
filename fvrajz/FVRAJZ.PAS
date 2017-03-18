       {$n+}
program FunctionDrawer;
uses crt,crtplus,graph,grplus,fvunit,dos,menumake,strinput;
{$L EGAVGA.OBJ }
type
    hely=record
          x,y:byte;
    end;
    keptip=array[1..4000] of byte;
const
    ver='(C) D e l i c''  A''d † m    1995  dec.  ( V1.2 )';
      kezdoxhely:hely=(x:14;y:3);
        vegxhely:hely=(x:14;y:4);
      kozepyhely:hely=(x:14;y:5);
          xlhely:hely=(x:11;y:7);
          ylhely:hely=(x:11;y:8);
          fvhely:hely=(x:9;y:15);
      fvszinhely:hely=(x:60;y:15);
        rajzhely:hely=(x:76;y:15);
 tengelyszinhely:hely=(x:11;y:10);
    racsszinhely:hely=(x:11;y:11);
   keretszinhely:hely=(x:11;y:12);
   szinnev:array[0..15] of string[13]=('Fekete','KÇk','Zîld','Ci†nkÇk',
                                       'Piros','Lila','Barna','Vil†gosszÅrke',
                                       'SîtÇtszÅrke','Vil†goskÇk','Vil†goszîld',
                                       'Vil†gosci†n','Vil†gospiros','Vil†goslila',
                                       'S†rga','FehÇr');
var
   regs   :registers;
   egervan:boolean;
   szin  :array[1..10] of byte;
   szamok:array[1..10] of szamtomb;
   pf    :array[1..10] of bytesor;
   kif   :array[1..10] of str100;
   rajz  :array[1..10] of boolean;
   kezdox,vegx,kozepy:extended;
   xl,yl,tengszin,
   racsszin,keretszin:byte;
   c : char;
   ernyo:keptip absolute $B800:0;
   kep  :keptip;
   xres,yres:word;
   ex,ey:integer;
   g1,g2:boolean;
   vonalrajz:boolean;
   fvrf:file of str100;

procedure EgaVga; External;

procedure DispErr;
begin
    writeln('CGA,MDA,fapapucs,kîbalta,stb. bev†lthat¢ a MêH telepein');
    writeln;
    halt(1);
end;

procedure VGAInit;
var gd,gm:integer;
begin
    gd:=VGA;
    gm:=VGAHi;
    InitGraph(gd,gm,'');
    If GraphResult<>GrOk then DispErr;
    Screen_Init;
    xres:=640;
    yres:=480;
end;

procedure Box(x1,y1,x2,y2,szin:byte); Assembler;
asm
   { paramÇtervizsg†lat }
   cmp x2,80
   jnc @ParError
   cmp y2,25
   jnc @ParError
   mov al,x2
   cmp x1,al
   jnc @ParError
   mov al,y2
   cmp y1,al
   jnc @ParError
   { eltol†si ÇrtÇkek -> BX,DX }
   xor bh,bh
   mov bl,x2
   sub bl,x1
   xor dh,dh
   mov dl,y2
   sub dl,y1
   { kÇpszegmens -> ES }
   mov ax,$b800
   mov es,ax
   { DI,SI be†llit†sa }
   mov al,y1
   mov bh,160
   mul bh
   xor bh,bh
   xor ch,ch
   mov cl,x1
   shl cl,1
   add ax,cx
   mov di,ax
   mov ax,160
   mov cx,bx
   shl cx,1
   sub ax,cx
   mov si,ax
   { AX-be amit kitesz }
   mov al,32
   mov ah,szin
   { kiir†s }
   cld
@cikl:
   mov cx,bx
   rep stosw
   dec dx
   add di,si
   cmp dx,0
   jnz @cikl
@ParError:
end;

procedure Hborder(x,y,hossz,szin,tipus,bcs,jcs:byte);Assembler;
var bv,jv:byte;
asm
   dec x
   dec y

   { paramÇterek ellenîrzÇse }
   cmp x,80
   jnc @parerror
   cmp y,25
   jnc @parerror
   cmp hossz,81
   jnc @parerror
   mov dl,hossz
   add dl,x
   cmp dl,81
   jnc @parerror
   cmp hossz,3
   jc  @parerror

   { kiirand¢ keretkarakterek meghat†roz†sa }
   cmp tipus,1
   jz  @egyszeres
   { kÇtszeres vonal }
   cmp bcs,1  { bal csatlakoz†s }
   jz  @2bcsegysz
   jnc @2bcsketsz
   mov bv,205
   jmp @2tovabb
@2bcsegysz:
   mov bv,198
   jmp @2tovabb
@2bcsketsz:
   mov bv,204
@2tovabb:
   cmp jcs,1  { jobb csatlakoz†s }
   jz  @2jcsegysz
   jnc @2jcsketsz
   mov jv,205
   jmp @tovabb
@2jcsegysz:
   mov jv,181
   jmp @tovabb
@2jcsketsz:
   mov jv,185
   jmp @tovabb
@egyszeres:
   { egyszeres vonal }
   cmp bcs,1  { bal csatlakoz†s }
   jz  @1bcsegysz
   jnc @1bcsketsz
   mov bv,196
   jmp @1tovabb
@1bcsegysz:
   mov bv,195
   jmp @1tovabb
@1bcsketsz:
   mov bv,199
@1tovabb:
   cmp jcs,1  { jobb csatlakoz†s }
   jz  @1jcsegysz
   jnc @1jcsketsz
   mov jv,196
   jmp @tovabb
@1jcsegysz:
   mov jv,180
   jmp @tovabb
@1jcsketsz:
   mov jv,182
   jmp @tovabb
@tovabb:

   { ES:DI be†ll°t†sa }
   mov ax,$B800
   mov es,ax
   mov ax,160
   mul y
   mov bl,x
   xor bh,bh
   shl bl,1
   add ax,bx
   mov di,ax

   { szin }
   mov ah,szin

   { bal vÇge }
   mov al,bv
   stosw
   { vonal }
   xor ch,ch
   mov cl,hossz
   sub cl,2
   mov al,205     { kÇtszeres }
   cmp tipus,1
   jnz @rajzol    { ha = 1 akkor egyszeres }
   mov al,196
@rajzol:
   rep stosw
   { jobb vÇge }
   mov al,jv
   stosw
@parerror:
end;

procedure Vborder(x,y,hossz,szin,tipus,bcs,jcs:byte);Assembler;
var bv,jv:byte;
asm
   dec x
   dec y

   { paramÇterek ellenîrzÇse }
   cmp x,80
   jnc @parerror
   cmp y,25
   jnc @parerror
   cmp hossz,26
   jnc @parerror
   mov dl,hossz
   add dl,y
   cmp dl,26
   jnc @parerror
   cmp hossz,3
   jc  @parerror

   { kiirand¢ keretkarakterek meghat†roz†sa }
   cmp tipus,1
   jz  @egyszeres
   { kÇtszeres vonal }
   cmp bcs,1  { bal csatlakoz†s }
   jz  @2bcsegysz
   jnc @2bcsketsz
   mov bv,186
   jmp @2tovabb
@2bcsegysz:
   mov bv,210
   jmp @2tovabb
@2bcsketsz:
   mov bv,203
@2tovabb:
   cmp jcs,1  { jobb csatlakoz†s }
   jz  @2jcsegysz
   jnc @2jcsketsz
   mov jv,186
   jmp @tovabb
@2jcsegysz:
   mov jv,208
   jmp @tovabb
@2jcsketsz:
   mov jv,202
   jmp @tovabb
@egyszeres:
   { egyszeres vonal }
   cmp bcs,1  { bal csatlakoz†s }
   jz  @1bcsegysz
   jnc @1bcsketsz
   mov bv,179
   jmp @1tovabb
@1bcsegysz:
   mov bv,194
   jmp @1tovabb
@1bcsketsz:
   mov bv,209
@1tovabb:
   cmp jcs,1  { jobb csatlakoz†s }
   jz  @1jcsegysz
   jnc @1jcsketsz
   mov jv,179
   jmp @tovabb
@1jcsegysz:
   mov jv,193
   jmp @tovabb
@1jcsketsz:
   mov jv,207
   jmp @tovabb
@tovabb:

   { ES:DI be†ll°t†sa }
   mov ax,$B800
   mov es,ax
   mov ax,160
   mul y
   mov bl,x
   xor bh,bh
   shl bl,1
   add ax,bx
   mov di,ax

   { szin }
   mov ah,szin

   { bal vÇge }
   mov al,bv
   mov es:[di],ax
   add di,160
   { vonal }
   xor ch,ch
   mov cl,hossz
   sub cl,2
   mov al,186     { kÇtszeres }
   cmp tipus,1
   jnz @rajzol    { ha = 1 akkor egyszeres }
   mov al,179
@rajzol:
   mov es:[di],ax
   add di,160
   loop @rajzol
   { jobb vÇge }
   mov al,jv
   mov es:[di],ax
@parerror:
end;

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

procedure Alapbeallitasok;
var
   i:integer;
   hiba:byte;
   c:char;
begin
    If RegisterBGIdriver(@EgaVga)<0 then Halt(3);
    { alap szîveges m¢d be†ll°t†sa }
    TextMode(CO80);
    If LastMode<>CO80 then DispErr;
    { grafikus bejelentkezî kÇp }
    VGAInit;
    SetTextStyle(0,0,4);
    SetColor(11);
    writemode(2);
    Bbar(20,170,620,300,0);
    writemode(0);
    OutTextXY(50,220,'FÅggvÇny†br†zol†s');
    writemode(2);
    bbar(200,440,600,475,0);
    writemode(0);
    SetTextStyle(0,0,1);
    OutTextXY(210,455,ver);
    { v†ltoz¢k be†ll°t†sa }
    for i:=1 to 10 do begin
      szin[i]:=15-i;
      rajz[i]:=false;
      kif[i]:='';
    end;
    assign(fvrf,'FVRAJZ.ACT');
    {$i-} reset(fvrf); {$i+}
    if ioresult=0 then begin { kifejezesek beolvasasa }
      for i:=1 to 10 do
       if not eof(fvrf) then begin { i-edik kif. beolvasasa }
         read(fvrf,kif[i]);
         Konvertalas(kif[i],hiba,pf[i],szamok[i]);
         if hiba<>0 then kif[i]:=''
         else rajz[i]:=true;
       end;
      close(fvrf);
    end;

    kezdox:=-2*pi;
      vegx:= 2*pi;
    kozepy:=  0;
        xl:=  7;
        yl:=  5;
  tengszin:= 15;
  racsszin:=  1;
 keretszin:=  7;
 vonalrajz:=  true;  { alapÇrtelmezÇsben vonalakkal rajzol }
    { egÇr inic. }
    EgerInit(i);
    If i>0 then egervan:=true
    else egervan:=false;
    while keypressed do c:=readkey;
    c:=readkey;
    CloseGraph;
end;

procedure TextFunction(m:byte);
const
    xres=54;
    yres=23;
var
    kezdox,vegx,kozepy,
    x,y,lepes:extended;
    i,j:integer;
    sz:byte;
begin
    sz:=textattr;
    textattr:=16+11;
    kezdox:=-pi;
    vegx:=-kezdox;
    kozepy:=0;
    lepes:=(vegx-kezdox)/xres;
    Hborder(25,7,54,30,1,0,0);
    Vborder(52,2,12,30,1,0,0);
    x:=kezdox;
    for i:=1 to xres do begin
      case m of
       0:y:=sin(x);
       1:y:=cos(x)/sqrt(abs(x))*x;
       2:y:=sqr(x)/4;
       3:y:=x*x*x/5;
       4:y:=sqrt(abs(x))/2;
      end;{case}
      y:=(y-kozepy)/lepes;
      if (y>-yres/2) and (y<yres/2) then begin
        j:=yres div 2 - round(y);
        gotoxy(i+24,j div 2 + 2);
        if j mod 2 <> 0 then write('‹')
        else write('ﬂ');
      end;
      x:=x+lepes;
    end;
    textattr:=sz;
end;

procedure FvSzinKi(i:byte);
begin
   gotoxy(fvszinhely.x,fvszinhely.y+i-1);
   write('             ');
   gotoxy(fvszinhely.x,fvszinhely.y+i-1);
   write(szinnev[szin[i]]);
end;

procedure FvRajzKi(i:byte);
begin
   gotoxy(rajzhely.x,rajzhely.y+i-1);
   if rajz[i] then write('˚')
   else write('-');
end;

procedure SzinekKi(i:byte);
begin
   case i of
   1:begin
        gotoxy(tengelyszinhely.x,tengelyszinhely.y);
        write('             ');
        gotoxy(tengelyszinhely.x,tengelyszinhely.y);
        write(szinnev[tengszin]);
     end;
   2:begin
        gotoxy(racsszinhely.x,racsszinhely.y);
        write('             ');
        gotoxy(racsszinhely.x,racsszinhely.y);
        write(szinnev[racsszin]);
     end;
   3:begin
        gotoxy(keretszinhely.x,keretszinhely.y);
        write('             ');
        gotoxy(keretszinhely.x,keretszinhely.y);
        write(szinnev[keretszin]);
     end;
   end;{case}
end;

procedure Message(x,y:word;szin:byte;szoveg:string);
var
   c:char;
   x2,y2:word;
   rsz:byte;
begin
    x2:=x+length(szoveg)+1;
    y2:=y+2;
    If (x2>80) or (y2>25) then exit;
    rsz:=textattr;
    textattr:=szin;
    kep:=ernyo;
    while keypressed do c:=readkey;
    gotoxy(x+1,y+1);  write(szoveg);
    DrawBorder(x-1,y-1,x2-1,y2-1,0,szin);
    repeat until keypressed;
    while keypressed do c:=readkey;
    textattr:=rsz;
    ernyo:=kep;
end;

function SzinValasztas:byte;
var
    i : byte;
   mi : menuitemstype;
begin
    mi[0].cim:='Sz°nv†laszt†s';
    for i:=1 to 15 do begin
      mi[i].cim:=szinnev[i];
      mi[i].act:=true;
    end;
    kep:=ernyo;
    Szinvalasztas:=MenuChoice(5,5,mi,15);
    ernyo:=kep;
end;

procedure RajzModKi;
begin
   gotoxy(46,25);
   if vonalrajz then write('vonalas  ')
   else write('pontozott');
end;

procedure KepernyoFelrajzolas;
var
   i,j:byte;
begin
    textattr:=30;
    Box(1,1,79,24,30);
    DrawBorder(0,0,79,24,0,30);
    gotoxy(27,1); write('[F10 : FÅggvÇny†br†zol†s]');
    Hborder(1,14,80,30,1,2,2);
    for i:=1 to 10 do begin
      gotoxy(2,14+i);
      write('f',i,'(x)');
      gotoxy(8,14+i);
      write('=');
      Box(8,13+i,58,14+i,90);
    end;
    Vborder(24,1,14,30,1,2,1);
    gotoxy(25,14);  write('[FÅggvÇnyek]');
    gotoxy(63,14);  write('[Sz°n]');
    gotoxy(74,14);  write('[Rajz]');
    Vborder(59,14,12,30,1,1,2);
    Vborder(73,14,12,30,1,1,2);
    Hborder(1,2,24,30,1,2,1);
    gotoxy(7,2); write('[Tartom†ny]');
    gotoxy(2,3); write('Kezdet    :');
    gotoxy(2,4); write('VÇg       :');
    gotoxy(2,5); write('KîzÇpen Y =');
    for i:=1 to 3 do Box(13,1+i,23,2+i,90);
    Hborder(1,6,24,30,1,2,1);
    gotoxy(9,6); write('[R†cs]');
    gotoxy(2,7); write('X ir†ny :'); Box(11,6,12,7,90);
    gotoxy(2,8); write('Y ir†ny :'); Box(11,7,12,8,90);
    Hborder(1,9,24,30,1,2,1);
    gotoxy(8,9);  write('[Sz°nek]');
    gotoxy(2,10); write('Tengely:');
    gotoxy(2,11); write('R†cs   :');
    gotoxy(2,12); write('Keret  :');
    { akt°v betÅ }
    textattr:=16+11;
    gotoxy(2,3);  write('K');
    gotoxy(2,4);  write('V');
    gotoxy(4,5);  write('z');
    gotoxy(2,7);  write('X');
    gotoxy(2,8);  write('Y');
    gotoxy(2,10); write('T');
    gotoxy(2,11); write('R');
    gotoxy(3,12); write('e');
    textattr:=30;
    { egy fÅggvÇny †br†zol†sa az Åres terÅleten }
    randomize;
    TextFunction(random(5));
    gotoxy(3,25);  write('[ F1 : Help ]');
    gotoxy(19,25);  write('[ ESC : kilÇpÇs ]');
    gotoxy(39,25);  write('[ F2 :           ]'); RajzModKi;
    { v†ltoz¢k ÇrtÇkeinek ki°r†sa }
    For i:=1 to 10 do begin
       FvSzinKi(i);
       FvRajzKi(i);
       textattr:=90;
       gotoxy(fvhely.x,fvhely.y+i-1);
       write(kif[i]);
       textattr:=30;
    end;
    textattr:=90;
    gotoxy(kezdoxhely.x,kezdoxhely.y);
    write(kezdox:3:3);
    gotoxy(vegxhely.x,vegxhely.y);
    write(vegx:3:3);
    gotoxy(kozepyhely.x,kozepyhely.y);
    write(kozepy:3:3);
    gotoxy(xlhely.x,xlhely.y);
    write(xl);
    gotoxy(ylhely.x,ylhely.y);
    write(yl);
    textattr:=30;
    for i:=1 to 4 do SzinekKi(i);
end;

procedure Help;
begin
    If EgerVan then LathatatlanEger;
    kep:=ernyo;
    Box(1,1,79,24,30);
    DrawBorder(0,0,79,24,0,30);
    gotoxy(35,1);
    write('[Help ablak]');
    window(2,2,80,25);
    writeln('FÅggvÇnyek megad†sa :   CTRL - F1,F2,...,F10');
    writeln('FÅggvÇny sz°ne      :   SHIFT - F1,F2,...,F10');
    writeln('Fv. rajzol†s kapcs. :   ALT - F1,F2,...,F10');
    writeln;
    writeln('Haszn†lhat¢ fÅggvÇnyek: ');
    writeln(' SIN() : sinus                         ASN() : arcus sinus');
    writeln(' COS() : cosinus                       ACS() : arcus cosinus');
    writeln(' TAN() : tangens                       ATG() : arcus tangens');
    writeln(' CTG() : cotangens                     ACT() : arcus cotangens');
    writeln(' SHP() : sinus hyperbolicus            ASH() : area sinus hyp.');
    writeln(' CHP() : cosinus hyperbolicus          ASH() : area cosinus hyp.');
    writeln(' THP() : tangens hyperbolicus          ASH() : area tangens hyp.');
    writeln(' ABS() : abszol£tÇrtÇk');
    writeln(' INT() : egÇszrÇsz');
    writeln(' FRA() : tîrtrÇsz');
    writeln(' LOG() : e alap£ logaritmus');
    writeln(' SQR() : nÇgyzetgyîk');
    writeln(' SQ2() : nÇgyzet');
    writeln(' SQ3() : kîb');
    writeln(' EXP() : exponenci†lis ( e ad x )');
    writeln(' F2 : bizonyos fÅggvÇnyek (pl.INT(),FRA()) haszn†latakor a kirajzolt vonalas');
    writeln('      †bra hib†s, ekkor jobb a pontozott †bra haszn†lata.');
    writeln(' T£lcsordul†sellenîrzÇs csak EXP()-nÇl van.');

    window(1,1,80,25);
    while keypressed do c:=readkey;
    repeat until keypressed;
    while keypressed do c:=readkey;
    ernyo:=kep;
    If EgerVan then LathatoEger;
end;

procedure Kilepes;
var i:word;
begin
    If EgerVan then LathatatlanEger;
    textattr:=7;
    clrscr;
    rewrite(fvrf);
    for i:=1 to 10 do write(fvrf,kif[i]);
    close(fvrf);
    writeln(ver);
    writeln;
    CursorOn;
    halt;
end;

procedure TartomanyBevitel(i:byte);
var
   kx,ky,mbsz : byte;
           sz : extended;
            s : string;
         hiba : integer;
begin
    If egervan then LathatatlanEger;
    CursorOn;
    case i of
    1:begin kx:=kezdoxhely.x; ky:=kezdoxhely.y; str(kezdox:3:3,s); end;
    2:begin kx:=vegxhely.x;   ky:=vegxhely.y;   str(vegx:3:3,s);   end;
    3:begin kx:=kozepyhely.x; ky:=kozepyhely.y; str(kozepy:3:3,s); end;
    end;{case}
    repeat
      repeat
       mbsz:=10;
       Beker(kx,ky,mbsz,90,s);
      until mbsz<>0;
      If s='.' then s:='';
      Val(s,sz,hiba);
      If hiba<>0 then Message(30,6,16*4+14,' Hib†s a sz†m ! ');
      If hiba=0 then
       begin
        If (sz<-10000) or (sz>10000) then begin
          Message(30,6,16*4+14,' Csak a [-10000;10000] intervallum j¢ ! ');
          hiba:=1;
        end;
        If i=2 then If (sz<=kezdox) then begin
          Message(30,6,16*4+14,' Ilyen tartom†ny nincs ! ');
          hiba:=1;
        end;
        If i=1 then if (sz>=vegx) then begin
          Message(30,6,16*4+14,' Ilyen tartom†ny nincs ! ');
          hiba:=1;
        end;
       end;
    until hiba=0;
    case i of
    1:kezdox:=sz;
    2:vegx:=sz;
    3:kozepy:=sz;
    end;{case}
    CursorOff;
    if egervan then LathatoEger;
end;

procedure RacsBevitel(i:byte);
var
   kx,ky,mbsz : byte;
           sz : integer;
            s : string;
         hiba : integer;
begin
    If egervan then LathatatlanEger;
    CursorOn;
    case i of
    1:begin kx:=xlhely.x; ky:=xlhely.y; str(xl,s); end;
    2:begin kx:=ylhely.x; ky:=ylhely.y; str(yl,s); end;
    end;{case}
    repeat
      repeat
       mbsz:=2;
       Beker(kx,ky,mbsz,90,s);
      until mbsz<>0;
      Val(s,sz,hiba);
      If hiba<>0 then Message(30,6,16*4+14,' Hib†s a sz†m ! ')
      else if ((sz<2) or (sz>49)) and (sz<>0) then begin
         Message(30,6,16*4+14,' Csak [2;49] vagy 0 j¢ ! ');
         hiba:=1;
      end;
    until hiba=0;
    case i of
    1:xl:=sz;
    2:yl:=sz;
    end;{case}
    CursorOff;
    if egervan then LathatoEger;
end;

procedure FvModositas(i:byte);
var
   hiba,mbsz:byte;
   kesz:boolean;
   kifejezes:string;
begin
    kifejezes:=kif[i];
    If egervan then LathatatlanEger;
    CursorOn;
    kesz:=false;
    repeat
       mbsz:=50;
       Beker(fvhely.x,fvhely.y+i-1,mbsz,90,kifejezes);
       If mbsz>0 then begin
         Konvertalas(kifejezes,hiba,pf[i],szamok[i]);
         If hiba=0 then begin kesz:=true; rajz[i]:=true; end
         else Message(20,11,16*4+14,' Hiba a kifejezÇsben ! ');
       end else begin
         rajz[i]:=false;
         kesz:=true;
       end;
    until kesz;
    FvRajzKi(i);
    CursorOff;
    if egervan then LathatoEger;
    kif[i]:=kifejezes;
end;

procedure SzinekBevitel(i:byte);
var sz:byte;
begin
    if egervan then LathatatlanEger;
    sz:=SzinValasztas;
    if sz<>0 then begin
      case i of
      1:tengszin:=sz;
      2:racsszin:=sz;
      3:keretszin:=sz;
      end;{case}
      SzinekKi(i);
    end;
    if egervan then LathatoEger;
end;

procedure FvSzinModositas(i:byte);
var sz:byte;
begin
    if egervan then LathatatlanEger;
    sz:=SzinValasztas;
    if sz<>0 then begin
      szin[i]:=sz;
      FvSzinKi(i);
    end;
    if egervan then LathatoEger;
end;

procedure FvRajzModositas(i:byte);
begin
    if egervan then LathatatlanEger;
    if rajz[i] then begin rajz[i]:=false; FvRajzKi(i); end
    else
      if kif[i]<>'' then begin rajz[i]:=true; FvRajzKi(i); end;
    if egervan then LathatoEger;
    Delay(300);
end;

procedure Abrazolas;
var
    x,y,lepes : extended;
    i,j,ej    : word;
    ok,eok,
    tul,etul  : boolean;
    st        : string[10];
    o,s       : integer;
    ii        : byte;
    c         : char;
begin
    CursorOn;
    If Egervan then LathatatlanEger;
    kep:=ernyo;
    VGAinit;
    ink:=keretszin;
    GrPlus.Box(0,0,xres-2,yres-15);
    xres:=xres-2;
    yres:=yres-17;
    ink:=15;
    outstrxy(26,yres+3,'Sz†molok . . .');
    ink:=7;
    str(kezdox:2:2,st);
    outstrxy(0,yres+3,st);
    str(vegx:2:2,st);
    outstrxy(80-length(st),yres+3,st);
    
    lepes:=(vegx-kezdox)/xres;
    { r†cs }
    ink:=racsszin;
    if xl<>0 then For i:=1 to xl do Vline(round((xres/(xl+1))*i),1,yres);
    if yl<>0 then For j:=1 to yl do Hline(1,round((yres/(yl+1))*j),xres);
    { x,y tengelyek kirajzol†sa }
    ink:=tengszin;
    y:=yres/2+kozepy/lepes;
    if (y>0) and (y<yres) then Hline(1,round(y),xres);
    if (kezdox<=0) and (vegx>=0) then
      Vline(round(-kezdox/(vegx-kezdox)*xres),1,yres);
    { fÅggvÇny kirajzol†sa }
    writemode(0);  { graph unit csak ebben a modban tud rajzolni }
  For ii:=1 to 10 do if rajz[ii] then begin
    x:=kezdox;
    { elsî pont kisz†m°t†sa }
    y:=Kiszamit(pf[ii],szamok[ii],x,eok);
    { y --> j }
    y:=(y-kozepy)/lepes;   { konvert†l†s }
    { korrig†l†s vonalh£z†shoz }
    etul:=false;
    if y<-yres/2 then begin etul:=true; y:=-yres/2; end;
    if y> yres/2 then begin etul:=true; y:= yres/2; end;
    ej:=yres div 2 - round(y);
    x:=x+lepes;  { £j x }
    setcolor(szin[ii]);
    if (not vonalrajz) and eok and (not etul) then PutPixel(0,ej+1,szin[ii]);
    For i:=2 to xres do
     begin
        { kîvetkezî pont kisz†m°t†sa }
        y:=Kiszamit(pf[ii],szamok[ii],x,ok);
        { y --> j }
        y:=(y-kozepy)/lepes;   { konvert†l†s }
        { korrig†l†s vonalh£z†shoz }
        tul:=false;
        if y<-yres/2 then begin tul:=true; y:=-yres/2; end;
        if y> yres/2 then begin tul:=true; y:= yres/2; end;
        j:=yres div 2 - round(y);
        { vonalrajzol†s , ha Çrtelmezett }
        if vonalrajz then begin
          if ok and eok and not(tul and etul) then line(i-2,ej+1,i-1,j+1);
        end
        else
          if ok and (not tul) then PutPixel(i-1,j+1,szin[ii]);
        { elmentÇs }
        etul:=tul;
        ej:=j;
        eok:=ok;
        x:=x+lepes;
     end;
  end;{if rajz[ii]}
    If Egervan then begin
      EgerAblak(1,1,xres,yres);
      Lathatoeger;
      ink:=11;
      writemode(2);
      outstrxy(26,yres+3,'x ˜ ');
      outstrxy(46,yres+3,'y ˜ ');
    end;
    ink:=11;    c:='p';
    repeat
      If keypressed then c:=readkey;
      If Egervan then begin
       EgerAllapot(o,s,ok,eok);
       WriteMode(2);
       x:=kezdox+(vegx-kezdox)*o/xres;
       str(x:2:2,st);
       while length(st)<10 do st:=st+' ';
       outstrxy(30,yres+3,st);
       y:=kozepy-lepes*(s-yres/2);
       str(y:2:2,st);
       while length(st)<10 do st:=st+' ';
       outstrxy(50,yres+3,st);
      end;
    until c=#27;
    while keypressed do c:=readkey;
    If Egervan then LathatatlanEger;
    CloseGraph;
    textattr:=30;
    ernyo:=kep;
    If Egervan then begin
      EgerMozgatas(1,1);
      LathatoEger;
    end;
    CursorOff;
end;

begin
    Alapbeallitasok;
    KepernyoFelrajzolas;
    CursorOff;
    If EgerVan then begin
      EgerMozgatas(1,1);
      LathatoEger;
    end;
    repeat
       If KeyPressed then begin
         c:=readkey;
         if c=#0 then begin { ha funkci¢bill. }
           c:=readkey;
           case c of
            #59 : Help;
            #60 : begin
                    LathatatlanEger;
                    vonalrajz:=not vonalrajz;
                    RajzModKi;
                    LathatoEger;
                    delay(300);
                  end;
            #68 : Abrazolas;
            { 94-103 : fÅggvÇny m¢dos°t†s }
            #94 : FvModositas(1);
            #95 : FvModositas(2);
            #96 : FvModositas(3);
            #97 : FvModositas(4);
            #98 : FvModositas(5);
            #99 : FvModositas(6);
            #100: FvModositas(7);
            #101: FvModositas(8);
            #102: FvModositas(9);
            #103: FvModositas(10);
            { 84-93 : fÅggvÇny sz°n m¢dos°t†s }
            #84 : FvSzinModositas(1);
            #85 : FvSzinModositas(2);
            #86 : FvSzinModositas(3);
            #87 : FvSzinModositas(4);
            #88 : FvSzinModositas(5);
            #89 : FvSzinModositas(6);
            #90 : FvSzinModositas(7);
            #91 : FvSzinModositas(8);
            #92 : FvSzinModositas(9);
            #93 : FvSzinModositas(10);
            { 104-113 : rajz[i] †ll°t†s }
            #104: FvRajzModositas(1);
            #105: FvRajzModositas(2);
            #106: FvRajzModositas(3);
            #107: FvRajzModositas(4);
            #108: FvRajzModositas(5);
            #109: FvRajzModositas(6);
            #110: FvRajzModositas(7);
            #111: FvRajzModositas(8);
            #112: FvRajzModositas(9);
            #113: FvRajzModositas(10);
           end;{case}
         end
         else begin  { nem funkci¢bill. }
           c:=upcase(c);
           case c of
             #27:Kilepes;
             'K':TartomanyBevitel(1);
             'V':TartomanyBevitel(2);
             'Z':TartomanyBevitel(3);
             'X':RacsBevitel(1);
             'Y':RacsBevitel(2);
             'T':SzinekBevitel(1);
             'R':SzinekBevitel(2);
             'E':SzinekBevitel(3);
           end;{case}
         end;
       end;{keypressed}
       If EgerVan then begin
         EgerAllapot(ex,ey,g1,g2);
         If g1 or g2 then begin
           case ey of
           25:case ex of
               4..14:Help;
              20..34:Kilepes;
              40..55:begin
                       LathatatlanEger;
                       vonalrajz:=not vonalrajz;
                       RajzModKi;
                       LathatoEger;
                       delay(300);
                     end;
              end;
           24:case ex of
               9..58:FvModositas(10);
              60..72:FvSzinModositas(10);
              74..79:FvRajzModositas(10);
              end;
           23:case ex of
               9..58:FvModositas(9);
              60..72:FvSzinModositas(9);
              74..79:FvRajzModositas(9);
              end;
           22:case ex of
               9..58:FvModositas(8);
              60..72:FvSzinModositas(8);
              74..79:FvRajzModositas(8);
              end;
           21:case ex of
               9..58:FvModositas(7);
              60..72:FvSzinModositas(7);
              74..79:FvRajzModositas(7);
              end;
           20:case ex of
               9..58:FvModositas(6);
              60..72:FvSzinModositas(6);
              74..79:FvRajzModositas(6);
              end;
           19:case ex of
               9..58:FvModositas(5);
              60..72:FvSzinModositas(5);
              74..79:FvRajzModositas(5);
              end;
           18:case ex of
               9..58:FvModositas(4);
              60..72:FvSzinModositas(4);
              74..79:FvRajzModositas(4);
              end;
           17:case ex of
               9..58:FvModositas(3);
              60..72:FvSzinModositas(3);
              74..79:FvRajzModositas(3);
              end;
           16:case ex of
               9..58:FvModositas(2);
              60..72:FvSzinModositas(2);
              74..79:FvRajzModositas(2);
              end;
           15:case ex of
               9..58:FvModositas(1);
              60..72:FvSzinModositas(1);
              74..79:FvRajzModositas(1);
              end;
            3:if (ex>1) and (ex<24) then TartomanyBevitel(1);
            4:if (ex>1) and (ex<24) then TartomanyBevitel(2);
            5:if (ex>1) and (ex<24) then TartomanyBevitel(3);
            7:if (ex>1) and (ex<24) then RacsBevitel(1);
            8:if (ex>1) and (ex<24) then RacsBevitel(2);
           10:if (ex>1) and (ex<24) then SzinekBevitel(1);
           11:if (ex>1) and (ex<24) then SzinekBevitel(2);
           12:if (ex>1) and (ex<24) then SzinekBevitel(3);
            1:if (ex>27) and (ex<51) then Abrazolas;
           end;{case}
         end;
       end;{egervan}
    until false;
end.