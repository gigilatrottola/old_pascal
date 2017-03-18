(****************************************************************************)
(*                                                                          *)
(*  GRPLUS-UNIT: Hasznos rutinok a 16 sz°nÅ grafikus m¢dokhoz               *)
(*                                                                          *)
(*  Az egysÇg a legfontosabb grafikus elj†r†sokat tartalmazza               *)
(*                                                                          *)
(****************************************************************************)
Unit Grplus;
{$G+,X+,L char8x14.obj}

 INTERFACE

 const
     Lsize = 80;        { 640 pixeles v°zszintes felbont†st feltÇtelez }

   segA000 : word = $A000;    { A grafikus kÇp szegmensc°me         }
   segB000 : word = $B000;    { A kÇp m†sodik 64K-s rÇsze           }

     Ink   : byte = 15; { Tintasz°n a rajzol†shoz                   }
     Paper : byte = 00; { Pap°rsz°n a karakterek kii°r†s†hoz        }
     Over  : byte = 00; { Ki°r†skor a h†ttÇr/pap°rsz°n kiv†laszt†sa }
     Light : byte = 15; { A keretezett BAR-ok bal Çs felsî oldala   }
     Back  : byte = 07; { A keretezett BAR-ok alapsz°ne             }
     Dark  : byte = 08; { A keretezett BAR-ok jobb Çs als¢ oldala   }

     { Bitmaszkok }
     Bit   : Array[0..7]  of byte=($80,$40,$20,$10,$08,$04,$02,$01);
     { "Elsî" b†jtmaszkok a v°zszintes vonalh£z†shoz }
     fMsk  : Array[0..7]  of byte=($ff,$7f,$3f,$1f,$0f,$07,$03,$01);
     { "Utols¢" b†jtmaszkok a v°zszintes vonalh£z†shoz }
     lMsk  : Array[0..7]  of byte=($80,$c0,$e0,$f0,$f8,$fc,$fe,$ff);
     { Elîre defini†lt sz°nek a keretezett BAR-okhoz (4 t°pus) }
     Cols  : Array[0..11] of byte=(15,8,15,8,7,7,3,3,8,15,8,15);

  { Optimaliz†lt, gyors°tott elj†r†sok }

  Procedure WriteMode(Mode:word);         { Az °r†s m¢d v†ltoztat†s      }
  Procedure OutCharXY(X,Y:word;C:char);   { Egy karakter ki°r†sa         }
  Procedure OutStrXY(X,Y:word; S:string); { Egy sztring ki°r†sa          }
  Procedure _OutCharXY(X,Y:word;C:char);  { Egy karakter ki°r†sa         }
  Procedure _OutStrXY(X,Y:word; S:string);{ Egy sztring ki°r†sa          }
  Procedure Screen_Init;                  { A kÇpernyî inicializ†l†sa    }
  Procedure Vline(X,Y,Long:word);         { FÅggîleges vonal             }
  Procedure Hline(X,Y,Long:word);         { V°zszintes vonal             }
  Procedure Plot(X,Y:Word;Color:byte);    { Pixel kirajzol†sa            }
  Procedure Box(X1,Y1,X2,Y2:word);        { öres tÇglalap rajzol†sa      }
  Procedure SolidBar(X1,Y1,X2,Y2:word);   { Kitîltîtt tÇglalap rajzol†sa }
  Procedure Bbar(X1,Y1,X2,Y2,Ty:word);    { Vastagon keretezett tÇglalap }
  Procedure Cbar(X1,Y1,X2,Y2,Ty:word);    { VÇkonyan keretezett tÇglalap }
  Function  Point(X,Y:Word):byte;         { Egy pixel lekÇrdezÇse        }
  Procedure ClearScreen;                  { KÇpterÅlet tîrlÇs            }

 IMPLEMENTATION

 { Belsî v†ltoz¢k Çs †lland¢k }

 const
     sadr  : word = 00;       { Karakterki°r†s c°me a kÇpen           }
     s_x   : byte = 00;       { Pixeles ki°r†sn†l a biteltol†s ÇrtÇke }


 var
       Rbuff : array [0..13] of word;   { Forgat¢buffer a pixeles k°°r†shoz }
 r0,r1,r2,r3 : word;                    { T†rol¢ Çs †tmeneti v†ltoz¢k       }

(***************************************************************************)
(*                                                                         *)
(* Ez az elj†r†s tartalmazzza a k¢dszegmensben a 8x14-es karakterkÇszletet *)
(*                                                                         *)
(***************************************************************************)
 Procedure Charset; External;

(***************************************************************************)
(*                                                                         *)
(* Belsî haszn†lat£ rutin: be†ll°t†s a megfelelî °r†sm¢dra                 *)
(*                                                                         *)
(***************************************************************************)
 Procedure WriteMode(Mode:word);Assembler;
  Asm
   mov   dx,$3c4        { Plane °r†smaszk regiszter }
   mov   ax,$0f02
   out   dx,ax          { Plane mask }
   mov   al,5           { Read/Write mode regiszter }
   mov   ah,byte [Mode] { a Mode csak 0,1,2,3 lehet !! }
   mov   dx,$3ce
   out   dx,ax          { Write Mode }
   mov   ax,$ff08
   out   dx,ax          { Bitmask    }
  End;

(***************************************************************************)
(*                                                                         *)
(* Belsî haszn†lat£ rutin, az AL k¢d£ karakter ki°r†sa karakterhat†rra     *)
(*                                                     ---------------     *)
(***************************************************************************)
 Procedure Char8x14; Assembler;
  Asm
    cld
    mov   bh,96h
    mov   bl,paper              { BX a pap°r-t†bl†zatra mutat }
    mov   di,sadr               { DI-be rakja a kÇpc°met      }
    inc   sadr
    mov   ah,14                 { 14*k¢d+k.c°m = karakter  k.c°m }
    mul   ah
    lea   si,Charset
    add   si,ax                 { Kisz†m°tja a karakter c°mÇt (SI) }
    mov   dx,03ceh
    mov   al,08h
    out   dx,al
    inc   dx                    { DX a bitmaszkregiszterre mutat }
    mov   cx,14
    mov   al,Ink                { Ez lesz a rajzol†s sz°ne }
    cmp   over,00               { Az OVER meghat†rozza a ki°r†si m¢dot }
    jz    @paper
@nopaper:                       { OVER<>0, ekkor nincs pap°rsz°n }
    segcs outsb                 { a karakter bitminta a bitmaszkba kerÅl }
    mov   ah,ES:[di]            { feltîlti a latch-et }
    stosb                       { ki°r†s a kÇpre }
    add   di,Lsize-1
    loop  @nopaper              { Ki°rja a 14 karaktersort }
    jmp   @exit
@paper:                         { OVER=0, ekkor van pap°rsz°n }
    segcs outsb                 { a karakter bitminta a bitmaszkba kerÅl }
    mov   ah,ES:[bx]            { A latch-et a pap°rsz°nnel tîlti fel }
    stosb                       { ki°r†s a kÇpre }
    add   di,Lsize-1
    loop  @paper                { Ki°rja a 14 karaktersort }
@exit:
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy karakter ki°r†sa adott poz°ci¢ba (az X karakteres poz°ci¢ [0..79])  *)
(*                                                                         *)
(***************************************************************************)
 Procedure OutCharXY(X,Y:word;C:char); Assembler;
  Asm
    mov   ax,Lsize
    mul   Y
    add   ax,X
    mov   sadr,ax               { Kisz†m°tja a kÇpc°met }
    mov   al,C
    mov   ES,SegA000
    call  Char8x14              { Ki°rja a karaktert    }
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy sztring ki°r†sa adott poz°ci¢ba (az X karakteres poz°ci¢ [0..79])   *)
(*                                                                         *)
(***************************************************************************)
 Procedure OutStrXY(X,Y:word; S:string); Assembler;
  Asm
    cld
    mov   ax,Lsize
    mul   Y
    add   ax,X
    mov   sadr,ax               { Kisz†m°tja a c°met }
    mov   ES,SegA000
    mov   bx,DS                 { BX az eredeti adatszegmens c°mÇt t†rolja }
    lds   si,S
    mov   dx,DS                 { DX a sztring szegmensc°mÇt t†rolja }
    xor   ch,ch
    lodsb
    mov   cl,al                 { CX-be kerÅl a sztring hossza }
    jcxz  @exit                 { KilÇp, ha a sztring 0 hossz£s†g£ }
@outchars:
    mov   DS,dx
    lodsb                       { Veszi a kîvetkezî karaktert }
    mov   DS,bx
    pusha                       { T†rolja az †ltal†nos regisztereket }
    call  Char8x14              { Ki°rja a karaktert }
    popa                        { Visszatîti a regisztereket }
    loop  @outchars             { Minden karaktert ki°r }
@exit:
    mov   DS,bx                 { A DS-be az eredeti ÇrtÇkÇt tîlti }
  End;

(***************************************************************************)
(*                                                                         *)
(* Belsî haszn†lat£ rutin, az AL k¢d£ karakter ki°r†sa pixelhat†rra        *)
(*                                                     ------------        *)
(***************************************************************************)
 Procedure _Char8x14; Assembler;
  Asm
    push  DS
    pusha                       { Menti a regisztereket }
    mov   ah,14
    mul   ah
    lea   si,Charset
    add   si,ax                 { Kisz†m°tja a karakter kezdîc°mÇt }
    mov   dx,Seg @data
    mov   ES,dx
    cld
    lea   di,Rbuff              { ES:DI a forgat¢bufferre mutat }
    mov   cx,14
    xor   al,al
@tobuff:
    stosb                       { a forgat†s miatt egy 0 b†jt }
    segcs movsb                 { a karakter egy sora }
    loop  @tobuff               { Kim†solja a karaktert a kÇszletbîl }
    mov   al,s_x
    and   al,7
    mov   cl,8
    sub   cl,al                 { CL megadja a balra forat†sok sz†m†t }
    lea   si,Rbuff              { SI a forgat¢bufferre mutat }
    rol   word [si+00],cl
    rol   word [si+02],cl
    rol   word [si+04],cl
    rol   word [si+06],cl
    rol   word [si+08],cl
    rol   word [si+10],cl
    rol   word [si+12],cl
    rol   word [si+14],cl
    rol   word [si+16],cl
    rol   word [si+18],cl
    rol   word [si+20],cl
    rol   word [si+22],cl
    rol   word [si+24],cl
    rol   word [si+26],cl       { A karakter minden sor†t elforgatja }
    mov   di,sadr               { DI a kÇpc°met tartalmazza }
    inc   sadr
    mov   dx,ES
    mov   DS,dx                 { DS:SI mostm†r a bufferre mutat (forr†s) }
    mov   ES,SegA000            { ES:DI mostm†r a kÇpre mutat    (cÇl)    }
    mov   dx,03ceh
    mov   al,08h
    out   dx,al
    inc   dx                    { A DX a bitmaszkregiszterre mutat }
    mov   cx,14
    mov   al,Ink                { Ez a rajzol†s sz°ne }
@outchr:
    outsb                       { A bitminta a bitmaszkba kerÅl }
    mov   ah,ES:[di]            { Feltîlti a latch-et }
    stosb                       { Kiviszi az adatot}
    outsb
    mov   ah,ES:[di]
    stosb
    add   di,Lsize-2
    loop  @outchr               { a karakter minden sor†t kiviszi }
    popa
    pop   DS                    { a regisztereket visszatîlti Çs visszatÇr }
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy karakter ki°r†sa adott X,Y pixeles poz°ci¢ba                        *)
(*                                                                         *)
(***************************************************************************)
 Procedure _OutCharXY(X,Y:word;C:char); Assembler;
  Asm
    mov   ax,Lsize
    mul   Y
    mov   di,X
    shr   di,3
    add   ax,di
    mov   sadr,ax               { Kisz†m°tja a koordin†t†kb¢l a kÇpc°met }
    mov   al,byte [X]
    and   al,7
    mov   s_x,al                { Çs az X biteltol†s ÇrtÇkÇt }
    mov   al,C
    mov   ES,SegA000
    call  _Char8x14             { Ki°rja a karaktert }
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy sztring ki°r†sa adott X,Y pixeles poz°ci¢ba                         *)
(*                                                                         *)
(***************************************************************************)
 Procedure _OutStrXY(X,Y:word; S:string); Assembler;
  Asm
    cld
    mov   ax,Lsize
    mul   Y
    mov   di,X
    shr   di,3
    add   ax,di
    mov   sadr,ax               { Kisz†m°tja a kÇpc°met }
    mov   al,byte [X]
    and   al,7
    mov   s_x,al                { Çs az X biteltol†st }
    mov   bx,DS
    lds   si,S                  { DS:SI a sztringre mutat }
    mov   dx,DS
    xor   ch,ch
    lodsb                       { Az elsî adat a sztring hossza }
    mov   cl,al
    jcxz  @exit                 { kilÇp, ha a sztring 0 hossz£s†g£ }
@outchars:
    mov   DS,dx
    lodsb                       { Veszi a kîvetkezî karaktert }
    mov   DS,bx
    call  _Char8x14             { Ki°rja a karaktert }
    loop  @outchars
@exit:
    mov   DS,bx
  End;

(***************************************************************************)
(*                                                                         *)
(* A 640x480/c16-os grafikus m¢d be†ll°t†sa Çs inicializ†l†sok             *)
(*                                                                         *)
(***************************************************************************)
 Procedure Screen_Init; Assembler;
  Asm
    mov   ax,0012h
    int   10h           { 640x480/16 }
    mov   ES,SegA000
    mov   di,38400      { A kÇp mîgîtti elsî b†jt }
    cld
    mov   dx,03ceh
    mov   ax,0205h      { mode 2-es °r†s m¢d }
    out   dx,ax
    mov   ax,0ff08h
    out   dx,ax
    mov   cx,16
    xor   al,al
@cikl:
    stosb               { 16 sz°nes b†jt lÇtrehoz†sa a pap°rsz°nek miatt }
    inc   al
    loop  @cikl
  End;

(***************************************************************************)
(*                                                                         *)
(* FÅggîleges vonal h£z†sa az X,Y pontb¢l Long hossz£s†gban                *)
(*                                                                         *)
(***************************************************************************)
 Procedure Vline(X,Y,Long:word);Assembler;
  Asm
   mov   cx,Long
   jcxz  @exit                  { KilÇp, ha a hossz£s†g nulla }
   mov   ax,Lsize               { KÇpc°msz†m°t†s }
   mul   Y
   mov   di,X
   mov   si,di
   shr   di,3
   add   di,ax                  { A DI-ben a kÇpc°m tal†lhat¢ }
   and   si,7
   add   si,offset Bit
   mov   ah,[si]                { Az AH-ban a bitpoz°ci¢ }
   mov   al,8
   mov   dx,03ceh
   out   dx,ax                  { A bitpoz°ci¢ a bitmaszkregiszterbe kerÅl }
   mov   al,Ink
   mov   ES,SegA000             { ES:DI a vonal legelsî b†jtj†ra mutat }
@cikl:
   mov   ah,ES:[di]             { A latch feltîltÇse }
   mov   ES:[di],al             { A vonal egy pixelÇnek ki°r†sa }
   add   di,Lsize               { A c°met nîveli }
   loop  @cikl                  { Kirakja az îsszes pixelt }
@exit:
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy v°zszintes vonal h£z†sa az X,Y kezdîpontt¢l Long hossz£s†gban       *)
(*                                                                         *)
(***************************************************************************)
 Procedure Hline(X,Y,Long:word);Assembler;
  Asm
   cmp   Long,0
   jz    @exit                  { KilÇp, ha a hossz£s†g nulla }
   mov   ES,SegA000
   cld
   mov   ax,Lsize               { C°msz†m°t†s }
   mul   Y
   mov   di,X
   mov   dx,di                  { DX = X kezdîpont }
   shr   di,3
   add   di,ax                  { DI = kÇpkezdîc°m }

   mov   cx,dx
   add   cx,Long                { CX= X vÇgpont   }
   dec   cx
   lea   bx,lMsk                { Az utols¢ maszkb†jt meghat†roz†sa }
   mov   al,cl
   and   al,7
   xlat
   mov   si,ax                  { lo(SI) = last mask }
   lea   bx,fMsk                { Az elsî maszkb†jt meghat†roz†sa }
   mov   al,dl
   and   al,7
   xlat                         { al = first mask  }
   shr   cx,3
   shr   dx,3
   sub   cx,dx                  { A vonal t°pus†nak meghat†roz†sa }
   mov   dx,03ceh
   jz    @one_byte              { Ugr†s, ha a vÇgpontok ugyanabban a
                                  b†jtban vannak                   }

   dec   cx                     { cx darab 255-îs b†jt kell }
   mov   ah,al
   mov   al,8
   out   dx,ax                  { First mask }
   mov   al,ES:[di]             { latch feltîltÇs }
   mov   al,Ink
   stosb                        { Az elsî b†jt kirak†sa }
   jcxz  @nx                    { Ugr†s, ha nincs kîztes b†jt }
   mov   ax,0ff08h
   out   dx,ax
   mov   al,Ink
   rep stosb                    { Kirakja a kîztes b†jtokat }
@nx:
   mov   ax,si
   mov   ah,al
   mov   al,8
   out   dx,ax
   mov   al,ES:[di]             { A latch feltîltÇse }
   mov   al,Ink
   stosb                        { Az utols¢ b†jt kirak†sa }
   jmp   @exit

@one_byte:                      { Egy b†jtban van a kezdî- Çs a vÇgpont }
   mov   bx,si
   and   al,bl                  { A bitminta az AL-be, }
   mov   ah,al
   mov   al,8                   { majd a bitmaszkregiszterbe }
   out   dx,ax
   mov   al,ES:[di]             { A latch feltîltÇs }
   mov   al,Ink
   stosb                        { A vonal kirak†sa a kÇpre }
@exit:
  End;

(***************************************************************************)
(*                                                                         *)
(* Egyetlen kÇppont kigy£jt†sa, megfelel a PutPixel elj†r†snak             *)
(*                                                                         *)
(***************************************************************************)
 Procedure Plot(X,Y:Word;Color:byte);Assembler;
  Asm
   mov   ax,Lsize               { C°msz†m°t†s }
   mul   Y
   mov   di,X
   mov   si,di
   shr   di,3
   add   di,ax                  { DI a kÇpc°met tartalmazza }
   and   si,7
   add   si,offset Bit
   mov   ah,[si]                { AH a bitmaszkot }
   mov   al,08h
   mov   dx,03ceh
   out   dx,ax                  { A bitmaszk ki°r†sa }
   mov   ES,SegA000
   mov   al,Color
   mov   ah,ES:[di]             { A latch feltîltÇse }
   mov   ES:[di],al             { A pont kigy£jt†sa  }
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy pixel sz°nÇnek lekÇrdezÇse, megfelel a GetPixel fÅggvÇnynek         *)
(*                                                                         *)
(***************************************************************************)
 Function Point(X,Y:Word):byte;Assembler;
  Asm
   lea   bx,Bit
   mov   es,SegA000
   mov   ax,Lsize
   mul   Y
   mov   di,X
   shr   di,3
   add   di,ax                  { Az ES:DI a kÇpb†jtra mutat }
   mov   al,byte ptr [X]
   and   al,7
   xlat
   mov   bl,al                  { A BL adja a bitmaszkot }
   xor   bh,bh                  { BH-ban jelenik meg az eredmÇny }
   mov   ch,8                   { CH a bitÇrtÇkeket adja majd    }

   mov   dx,03ceh
   mov   ax,0304h               { Az olvas†sregiszter a 3. plane-re mutat }
@getc:
   out   dx,ax                  { Az olvasand¢ plane kiv†laszt†sa }
   test  ES:[di],bl             { Az adott plane-en a bit megvizsg†l†sa }
   jz    @nobit
@bit:
   or    bh,ch                  { Ha 1 van ott, akkor az eredmÇnybe is kell }
@nobit:
   shr   ch,1                   { A kîvetkezî bit }
   dec   ah                     { A kîvetkezî plane }
   jns   @getc                  { 4 plane-re vizsg†l r† }
   mov   al,bh                  { A visszatÇrÇsi ÇrtÇket az AL-be kell tenni }
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy tÇglalap rajzol†sa, megfelel a Rectangle elj†r†snak                 *)
(*                                                                         *)
(***************************************************************************)
 Procedure Box(X1,Y1,X2,Y2:word);Assembler;
  Asm
   push  2
   call  Writemode              { Kettes °r†s m¢dba kapcsol }
   mov   ax,X2
   sub   ax,X1
   mov   r0,ax                  { Kisz†m°tja a v°zszintes hosszot }
   mov   ax,Y2
   sub   ax,Y1
   inc   ax
   mov   r1,ax                  { Kisz†m°tja a fÅggîleges hosszot }

   push  X1
   push  Y1
   push  r0
   call  Hline                  { Felsî v°zszintes }
   push  X1
   push  Y2
   push  r0
   call  Hline                  { Als¢  v°zszintes }
   push  X1
   push  Y1
   push  r1
   call  Vline                  { Bal fÅggîleges   }
   push  X2
   push  Y1
   push  r1
   call  Vline                  { Jobb fÅggîleges  }
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy norm†l-fillezett tÇglalap rajzol†sa   ( Bar elj†r†s )               *)
(*                                                                         *)
(***************************************************************************)
 Procedure SolidBar(X1,Y1,X2,Y2:word);Assembler;
  Asm
   push  2
   call  Writemode              { kettes °r†s m¢d }
   mov   ES,SegA000
   cld

   mov   ax,Lsize
   mul   Y1
   mov   di,X1
   mov   dx,di
   shr   di,3
   add   di,ax                  { KÇpkezdîc°m }

   mov   cx,X2
   lea   bx,lMsk                { Az utols¢ maszk meghat†roz†sa }
   mov   al,cl
   and   al,7
   xlat
   mov   si,ax                  { lo(SI) = last mask }
   lea   bx,fMsk                { Az elsî maszk meghat†roz†sa }
   mov   al,dl
   and   al,7
   xlat                         { al = first mask  }
   shr   cx,3
   shr   dx,3
   sub   cx,dx
   mov   dx,$3ce
   jz    @one_byte              { Ugr†s, ha 1 b†jtban elfÇr v°zszintesen }

   mov   bx,Y2
   sub   bx,Y1
   inc   bx                     { BX a fÅggîleges mÇretet adja  }

   dec   cx                     { CX a kîzbensî 255 b†jtokat }
   mov   ah,al
   mov   al,8
   out   dx,ax                  { Elsî b†jt maszk }

   mov   r0,bx
   mov   r1,di
   mov   al,Ink
@ficikl:                        { A tÇglalap bal szÇlsî b†jtjai }
   mov   ah,es:[di]
   mov   es:[di],al
   add   di,Lsize
   dec   bx
   jnz   @ficikl

   mov   di,r1
   inc   di

   jcxz  @nx                    { Ugr†s, ha nincsenek kîzbensî b†jtok }

   mov   ax,$ff08               { A kîzbensî b†jtok 255 ÇrtÇkÅek }
   out   dx,ax
   mov   al,Ink

   mov   bx,r0
   mov   r1,di
   mov   r2,cx
   mov   r3,di                  { T†rolja kÇsîbbi haszn†latra az ÇrtÇkeket }

   push  si
   mov   si,cx
   mov   dx,di
@mdcikl:
   mov   cx,si
   mov   di,dx
   rep stosb                    { Egy v°zszintes sor }
   add   dx,Lsize
   dec   bx
   jnz   @mdcikl                { BX darab fÅggîleges sor kell }

   mov   dx,$3ce
   pop   si

   mov   di,r1
   add   di,r2
                                { A jobb szÇlsî b†jtok kîvetkeznek }
@nx:
   mov   ax,si
   mov   ah,al
   mov   al,8
   out   dx,ax

   mov   bx,r0
   mov   al,Ink
@lacikl:                        { A bal szÇl kirajzol†sa }
   mov   ah,es:[di]
   mov   es:[di],al
   add   di,Lsize
   dec   bx
   jnz   @lacikl

   jmp   @exit

   { Rajzol†s, ha v°zszintesen 1 b†jt a szÇlessÇg }

@one_byte:
   mov   bx,si
   and   al,bl
   mov   ah,al
   mov   al,8
   out   dx,ax
   mov   cx,Y2
   sub   cx,Y1
   inc   cx
   mov   al,Ink
@oncikl:                        { A tÇglalap kirajzol†sa }
   mov   ah,es:[di]
   mov   es:[di],al
   add   di,Lsize
   loop  @oncikl
@exit:
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy vastagon keretezett tÇglalap rajzol†sa                              *)
(*                                                                         *)
(***************************************************************************)
 Procedure Bbar(X1,Y1,X2,Y2,Ty:word);Assembler;
  Asm
   push  2
   call  Writemode              { kettes °r†s m¢d }
   mov   al,Ink
   push  ax
   cmp   Ty,4                   { nincs t°pusdefin°ci¢, ha a Ty>=4 }
   jnc   @nodeftype
                                { T°pusdefin°ci¢, a sz°nek feltîltÇse }
   lea   si,Cols
   add   si,Ty
   mov   al,[si]
   mov   light,al
   mov   al,[si+4]
   mov   back,al
   mov   al,[si+8]
   mov   dark,al

@nodeftype:
   mov   al,Back
   mov   Ink,al
   push  X1
   push  Y1
   push  X2
   push  Y2
   call  SolidBar               { A h†ttÇrtÇglalap kirajzol†sa BACK sz°nnel }
   mov   al,Light
   mov   Ink,al
   mov   ax,Y1
   push  X1
   push  ax
   push  X2
   inc   ax
   push  ax
   call  SolidBar               { A felsî szÇle LIGHT sz°nÅ }
   mov   ax,X1
   push  ax
   push  Y1
   inc   ax
   push  ax
   push  Y2
   call  SolidBar               { A bal szÇle is LIGHT sz°nÅ }
   mov   al,Dark
   mov   Ink,al
   push  X1
   push  Y2
   mov   ax,X2
   sub   ax,X1
   inc   ax
   push  ax
   call  Hline                  { Az als¢ szÇle egyik fele (DARK) }
   push  X2
   push  Y1
   mov   ax,Y2
   sub   ax,Y1
   push  ax
   call  Vline                  { A jobb szÇle egyik fele (DARK) }
   mov   ax,X1
   inc   ax
   push  ax
   mov   ax,Y2
   dec   ax
   push  ax
   mov   ax,X2
   sub   ax,X1
   push  ax
   call  Hline                  { Az als¢ oldal megvastag°t†sa }
   mov   ax,X2
   dec   ax
   push  ax
   mov   ax,Y1
   inc   ax
   push  ax
   mov   ax,Y2
   sub   ax,Y1
   push  ax
   call  Vline                  { A jobb oldal megvastag°t†sa }
   pop   ax
   mov   Ink,al
  End;

(***************************************************************************)
(*                                                                         *)
(* Egy vÇkonyan keretezett tÇglalap rajzol†sa                              *)
(*                                                                         *)
(***************************************************************************)
 Procedure Cbar(X1,Y1,X2,Y2,Ty:word);Assembler;
  Asm
   push  2
   call  Writemode              { kettes °r†s m¢d }
   mov   al,Ink
   push  ax
   cmp   Ty,4                   { nincs t°pusdefin°ci¢, ha a Ty>=4 }
   jnc   @nodeftype
                                { T°pusdefin°ci¢, a sz°nek feltîltÇse }
   lea   si,Cols
   add   si,Ty
   mov   al,[si]
   mov   light,al
   mov   al,[si+4]
   mov   back,al
   mov   al,[si+8]
   mov   dark,al
@nodeftype:
   mov   al,Back
   mov   Ink,al
   push  X1
   push  Y1
   push  X2
   push  Y2
   call  SolidBar               { A h†ttÇrtÇglalap BACK sz°nÅ }
   mov   al,Light
   mov   Ink,al
   push  X1
   push  Y1
   mov   ax,X2
   sub   ax,X1
   push  ax
   call  Hline                  { Felsî szÇle LIGHT sz°nÅ }
   push  X1
   push  Y1
   mov   ax,Y2
   sub   ax,y1
   push  ax
   call  Vline                  { A bal oldala szintÇn LIGHT sz°nÅ }
   mov   al,Dark
   mov   Ink,al
   push  X1
   push  Y2
   mov   ax,X2
   sub   ax,X1
   inc   ax
   push  ax
   call  Hline                  { Az als¢ szÇle DARK sz°nÅ }
   push  X2
   push  Y1
   mov   ax,Y2
   sub   ax,Y1
   push  ax
   call  Vline                  { A jobb oldal szintÇn DARK sz°nÅ }
   pop   ax
   mov   Ink,al
  End;

(***************************************************************************)
(*                                                                         *)
(* A 640x480-as 16 sz°nÅ VGA kÇp letîrlÇse , 38400 sz°nes b†jt kinull†z†sa *)
(*                                                                         *)
(***************************************************************************)
 Procedure ClearScreen; Assembler;
  Asm
   push  00
   call  Writemode
   xor   ax,ax
   mov   cx,38400/2
   mov   di,ax
   mov   ES,SegA000
   cld
   rep stosw
  End;

 END.