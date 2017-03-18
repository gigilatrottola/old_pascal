{$G+}
{$DEFINE SeqRESET}
Unit CrtPlus;

 INTERFACE

 Uses Crt,Dos;

 Type
   BorderType = Array[0..7] of char;

 Var
   KTB         : Array[0..127] of Boolean;
   LastCrtMode : byte;     { Az utols¢ be ll¡tott sz”veges m¢d }
   LastCTop    : byte;
   LastCBottom : byte;     { Az utols¢ be ll¡tott kurzorm‚ret  }
   LogicalSize : word;     { Az aktu lis m¢d sorhossz£s ga     }

 { M¢dkonstansok a SetCRTmode elj r s sz m ra   }
 Const
     _40x25 = 0;
     _40x28 = 1;
     _40x50 = 2;
     _80x25 = 3;
     _80x28 = 4;
     _80x30 = 5;
     _80x34 = 6;
     _80x50 = 7;
     _80x60 = 8;

 { Keretdefin¡ci¢k a DrawBorder elj r s sz m ra }
 Border : Array[0..7] of BorderType=( 'É»¼ÈÍºÍº',
                                      'Ú¿ÙÀÄ³Ä³',
                                      'Õ¸¾ÔÍ³Í³',
                                      'Ö·½ÓÄºÄº',
                                      'ÜÜßßÜÞßÝ',
                                      '±±±±±±±±',
                                      '²²²²²²²²',
                                      'ÛÛÛÛÛÛÛÛ');

 Procedure ScrollUp(x1,y1,x2,y2,e:word);
 Procedure ScrollDn(x1,y1,x2,y2,e:word);
 Procedure ScrollLf(x1,y1,x2,y2,e:word);
 Procedure ScrollRg(x1,y1,x2,y2,e:word);
 Procedure Box8;
 Procedure Box9;
 Procedure SetCursorSize(Top,Bottom:byte);
 Procedure CursorOff;
 Procedure CursorOn;
 Procedure Flash(B:boolean);
 Procedure SetCrtMode(mode:byte);
 Procedure NewWindow(x1,y1,x2,y2:integer);
 Procedure InstallKEYirq;
 Procedure UninstallKeyirq;
 Procedure SetEGApalette(Regnum,Vaule:byte);
 Procedure SetRGB(Palnum,Red,Green,Blue:byte);
 Procedure Settimer(p:word);
 Procedure DefChars(dat:pointer; fm:byte; car,db:word);
 Procedure DefChar(dat:pointer; car,fm:word);
 Function  Framesise(x1,y1,x2,y2:integer):word;
 Procedure GetFrame(x1,y1,x2,y2:word; p:pointer);
 Procedure HexStr(X:word; var S:string);
 Procedure BinStr(X:word; var S:string);
 Procedure StrBin(var S:string; var X:word);
 Procedure StrHex(var S:string; var X:word);
 Procedure PutFrame(x1,y1,x2,y2:word; p:pointer);
 Procedure CharChange(x1,y1,x2,y2:word; oldCH,newCH:char);
 Procedure AttrChange(x1,y1,x2,y2:word; oldAT,newAT:byte);
 Procedure DrawBorder(x1,y1,x2,y2:word; tp,col:byte);
 Function  EQ(var x; var y; Size:Word):Boolean;
 Function  NE(var x; var y; Size:Word):Boolean;

  IMPLEMENTATION

 Var
   OldKeyIRQ   : procedure;     { Haszn lja:  Install-,UninstallKEYIRQ }

 Const

 Wmaxs : Array[0..8] of word=
  ( $1827,$1b27,$3127,$184f,$1b4f,$1d4f,$214f,$314f,$3b4f );

 Curli : Array[0..8] of byte=(14,13,06,14,13,13,13,06,06);

 LSize : Array[0..8] of word=(80,80,80,160,160,160,160,160,160);

 Digit : Array[0..15] of char='0123456789ABCDEF';
 Bits  : Array[0..15] of word=
         (32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1);
 Hdig  : Array[0..3] of word=(1,16,256,4096);

 (**************************************************************************)
 (**         A billentyzetet lekezel” saj t megszak¡t si rutin           **)
 (**************************************************************************)
 Procedure KeyIRQ;Assembler;
  Asm
   push    ds               { A haszn lt regiszterek elment‚se }
   push    ax
   push    bx
   push    cx
   mov     ax,SEG Ktb       { Inicializ l sok }
   mov     ds,ax
   xor     bh,bh
   mov     cl,bh
   in      al,60H           { A billenty SCAN k¢d beolvas sa }
   mov     bl,al
   and     bl,7fH
   shl     al,1
   cmc
   adc     cl,00            { T rol s a t bl zatban }
   mov     [bx+OFFSET Ktb],cl
   in      al,61H           { A megszak¡t s csatorna vissza ll¡t sa }
   mov     ah,al
   or      al,80H
   out     61H,al
   mov     al,ah
   nop
   nop
   nop
   out     61H,al
   cli
   mov     al,20H
   out     20H,al
   sti
   pop     cx               { Regiszterek vissza a veremb”l }
   pop     bx
   pop     ax
   pop     ds
   iret                     { Megszak¡t s v‚ge }
  End;

 (**************************************************************************)
 (**         Egy ablak felfel‚ scroll-oz sa                               **)
 (**************************************************************************)
 Procedure ScrollUp(x1,y1,x2,y2,e:word);Assembler;
  var ls:word;
  Asm
    mov   ax,LogicalSize
    mov   ls,ax
    push  ds
    push  es
    mov   ax,$b800
    mov   ds,ax
    mov   es,ax
    cld
    mov   ax,ls
    mul   y1
    mov   bx,x1
    shl   bx,1
    add   bx,ax         { BX k‚pc¡m }
    mov   ax,y2
    sub   ax,y1         { AX fgg”leges m‚ret }
    mov   dx,x2
    sub   dx,x1
    inc   dx            { DX v¡zszintes m‚ret }
@cik:
    mov   cx,dx
    mov   di,bx
    mov   si,bx
    add   si,ls
    add   bx,ls
    rep movsw
    dec   ax
    jnz   @cik
    mov   ax,e
    mov   cx,dx
    mov   di,bx
    rep stosw
    pop   es
    pop   ds
  End;

 (**************************************************************************)
 (**         Egy ablak lefel‚ scroll-oz sa                                **)
 (**************************************************************************)
 Procedure ScrollDn(x1,y1,x2,y2,e:word);Assembler;
  var ls:word;
  Asm
    mov   ax,LogicalSize
    mov   ls,ax
    push  ds
    push  es
    mov   ax,$b800
    mov   ds,ax
    mov   es,ax
    cld
    mov   ax,ls
    mul   y2
    mov   bx,x1
    shl   bx,1
    add   bx,ax         { BX k‚pc¡m }
    mov   ax,y2
    sub   ax,y1         { AX fgg”leges m‚ret }
    mov   dx,x2
    sub   dx,x1
    inc   dx            { DX v¡zszintes m‚ret }
@cik:
    mov   cx,dx
    mov   di,bx
    mov   si,bx
    sub   si,ls
    sub   bx,ls
    rep movsw
    dec   ax
    jnz   @cik
    mov   ax,e
    mov   cx,dx
    mov   di,bx
    rep stosw
    pop   es
    pop   ds
  End;

 (**************************************************************************)
 (**         Egy ablak balra scroll-oz sa                                 **)
 (**************************************************************************)
 Procedure ScrollLf(x1,y1,x2,y2,e:word);Assembler;
  var ls:word;
  Asm
    mov   ax,LogicalSize
    mov   ls,ax
    push  ds
    push  es
    mov   ax,$b800
    mov   ds,ax
    mov   es,ax
    cld
    mov   ax,ls
    mul   y1
    mov   bx,x1
    shl   bx,1
    add   bx,ax         { BX k‚pc¡m }
    mov   ax,y2
    sub   ax,y1         { AX fgg”leges m‚ret }
    inc   ax
    mov   dx,x2
    sub   dx,x1         { DX v¡zszintes m‚ret }
@cik:
    mov   cx,dx
    mov   di,bx
    mov   si,bx
    add   si,2
    add   bx,ls
    rep movsw
    mov   si,e
    mov   es:[di],si
    dec   ax
    jnz   @cik
    pop   es
    pop   ds
  End;

 (**************************************************************************)
 (**         Egy ablak jobbra scroll-oz sa                                **)
 (**************************************************************************)
 Procedure ScrollRg(x1,y1,x2,y2,e:word);Assembler;
  var ls:word;
  Asm
    mov   ax,LogicalSize
    mov   ls,ax
    push  ds
    push  es
    mov   ax,$b800
    mov   ds,ax
    mov   es,ax
    std
    mov   ax,ls
    mul   y1
    mov   bx,x2
    shl   bx,1
    add   bx,ax         { BX k‚pc¡m }
    mov   ax,y2
    sub   ax,y1         { AX fgg”leges m‚ret }
    inc   ax
    mov   dx,x2
    sub   dx,x1         { DX v¡zszintes m‚ret }
@cik:
    mov   cx,dx
    mov   di,bx
    mov   si,bx
    sub   si,2
    add   bx,ls
    rep movsw
    mov   si,e
    mov   es:[di],si
    dec   ax
    jnz   @cik
    pop   es
    pop   ds
  End;

 (**************************************************************************)
 (**  A 8 pixeles karaktersz‚less‚g bekapcsol sa                          **)
 (**************************************************************************)
 Procedure Box8;Assembler;
  Asm
    mov  dx,$3cc
    in   al,dx
    and  al,$f3
    mov  dx,$3c2
    out  dx,al
    mov  dx,$3c4
{$IFDEF SeqRESET}
    mov  ax,0100h
    out  dx,ax
{$ENDIF}
    mov  al,1
    out  dx,al
    inc  dx
    in   al,dx
    or   al,1
    out  dx,al
{$IFDEF SeqRESET}
    dec  dx
    mov  ax,0300h
    out  dx,ax
{$ENDIF}
    mov  dx,$3da
    in   al,dx
    mov  dx,$3c0
    mov  al,$13
    out  dx,al
    xor  al,al
    out  dx,al
    mov  al,$20
    out  dx,al
  End;

 (**************************************************************************)
 (**  A 9 pixeles karaktersz‚less‚g bekapcsol sa                          **)
 (**************************************************************************)
 Procedure Box9;Assembler;
  Asm
    mov  dx,$3cc
    in   al,dx
    or   al,4
    mov  dx,$3c2
    out  dx,al
    mov  dx,$3c4
{$IFDEF SeqRESET}
    mov  ax,0100h
    out  dx,ax
{$ENDIF}
    mov  al,1
    out  dx,al
    inc  dx
    in   al,dx
    and  al,$fe
    out  dx,al
{$IFDEF SeqRESET}
    dec  dx
    mov  ax,0300h
    out  dx,ax
{$ENDIF}
    mov  dx,$3da
    in   al,dx
    mov  dx,$3c0
    mov  al,$13
    out  dx,al
    mov  al,8
    out  dx,al
    mov  al,$20
    out  dx,al
  End;

 (**************************************************************************)
 (**                                                                      **)
 (**  A k”vetkez” m¢dbe ll¡t¢ elj r sokat a SetCrtMode haszn lja          **)
 (**                                                                      **)
 (**************************************************************************)
 Procedure ClockMode480; Assembler;
  Asm
    mov  dx,03c2h
    mov  al,0e7h
    out  dx,al
  End;

 Procedure Char80x25;Assembler;
  Asm
    mov  ax,0003h
    int  10h
  End;
 Procedure Char40x25;Assembler;
  Asm
    mov  ax,0000h
    int  10h
  End;
 Procedure Char80x28;Assembler;
  Asm
    mov  ax,0003h
    int  10h
    mov  ax,1111h
    xor  dx,dx
    mov  bx,0800h
    mov  cx,256
    int  10h
  End;
 Procedure Char40x28;Assembler;
  Asm
    mov  ax,0000h
    int  10h
    mov  ax,1111h
    xor  dx,dx
    mov  bx,0800h
    mov  cx,256
    int  10h
  End;
 Procedure Char80x50;Assembler;
  Asm
    mov  ax,0003h
    int  10h
    mov  ax,1112h
    xor  dx,dx
    mov  bx,0800h
    mov  cx,256
    int  10h
  End;
 Procedure Char40x50;Assembler;
  Asm
    mov  ax,0000h
    int  10h
    mov  ax,1112h
    xor  dx,dx
    mov  bx,0800h
    mov  cx,256
    int  10h
  End;
 Procedure Char80x30;Assembler;
  Asm
    mov  ax,0003h
    int  10h
    mov  dx,03d4h
    mov  ax,0e11h
    out  dx,ax
    mov  cx,18h
    xor  al,al
    lea  si,@dat480
@cikl:
    mov  ah,cs:[si]
    out  dx,ax
    inc  si
    inc  al
    loop @cikl
    call ClockMode480
    jmp  @vege
@dat480:
    db   5fh,4fh,50h,82h,55h,81h
    db   0bh,3eh,00h,4fh,0dh,0eh,00h,00h,00h,00h
    db   0eah,8ch,0dfh,28h,1fh,0e7h,04h,0a3h,0ffh
@vege:
  End;
 Procedure Char80x34;Assembler;
  Asm
    mov  ax,0003h
    int  10h
    mov  ax,1111h
    xor  dx,dx
    mov  bx,0800h
    mov  cx,256
    int  10h
    mov  dx,03d4h
    mov  ax,0e11h
    out  dx,ax
    mov  cx,18h
    xor  al,al
    lea  si,@dat480
@cikl:
    mov  ah,cs:[si]
    out  dx,ax
    inc  si
    inc  al
    loop @cikl
    call ClockMode480
    jmp  @vege
@dat480:
    db   5fh,4fh,50h,82h,55h,81h
    db   0bh,3eh,00h,04dh,0dh,0eh,00h,00h,00h,00h
    db   0eah,8ch,0dfh,28h,1fh,0dbh,04h,0a3h,0ffh
@vege:
  End;
 Procedure Char80x60;Assembler;
  Asm
    mov  ax,0003h
    int  10h
    mov  ax,1112h
    xor  dx,dx
    mov  bx,0800h
    mov  cx,256
    int  10h
    mov  dx,03d4h
    mov  ax,0e11h
    out  dx,ax
    mov  cx,18h
    xor  al,al
    lea  si,@dat480
@cikl:
    mov  ah,cs:[si]
    out  dx,ax
    inc  si
    inc  al
    loop @cikl
    call ClockMode480
    jmp  @vege
@dat480:
    db   5fh,4fh,50h,82h,55h,81h
    db   0bh,3eh,00h,047h,0dh,0eh,00h,00h,00h,00h
    db   0eah,8ch,0dfh,28h,1fh,0e7h,04h,0a3h,0ffh
@vege:
  End;

 (**************************************************************************)
 (**  A kurzor m‚ret‚nek be ll¡t sa                                       **)
 (**************************************************************************)
 Procedure SetCursorSize(Top,Bottom:byte);Assembler;
  Asm
   mov  ah,1
   mov  ch,Top
   mov  cl,Bottom
   and  cx,$1f1f
   mov  LastCTop,ch
   mov  LastCBottom,cl
   int  $10
  End;

 (**************************************************************************)
 (**  A kurzor kikapcsol sa (eltntet‚se a k‚pr”l)                        **)
 (**************************************************************************)
 Procedure CursorOff;Assembler;
  Asm
    mov  ah,1
    mov  ch,127
    int  $10
  End;

 (**************************************************************************)
 (**  A kurzor bekapcsol sa (l that¢v  t‚tele)                            **)
 (**************************************************************************)
 Procedure CursorOn;
  Begin
   SetCursorSize(LastCtop,LastCbottom);
  End;

 (**************************************************************************)
 (**  A villog s/16 h tt‚rsz¡n  llapot be ll¡t sa                         **)
 (**************************************************************************)
 Procedure Flash(B:boolean);Assembler;
  Asm
    mov  ax,$1003
    mov  bl,B
    and  bl,1
    int  $10
  End;

 Const Rt:Array[0..8] of pointer=(
  @Char40x25,@Char40x28,@Char40x50,
  @Char80x25,@Char80x28,@Char80x30,@Char80x34,@Char80x50,@Char80x60);

 (**************************************************************************)
 (**  Egy VGA karakteres m¢d be ll¡t sa                                   **)
 (**************************************************************************)
 Procedure SetCrtMode(mode:byte);
  var Rut:Procedure;
  Begin
   if mode>8 then mode:=8;
   @Rut:=Rt[mode];
   Rut;
   SetCursorSize(Curli[mode]-1,Curli[mode]);
   LastCrtMode:=mode;
   LogicalSize:=Lsize[mode];
   WindMax:=Wmaxs[mode];
   TextAttr:=7;
  End;

 (**************************************************************************)
 (**  Egy £j ablak megnyit sa                                             **)
 (**************************************************************************)
 Procedure NewWindow(x1,y1,x2,y2:integer);
  Begin
   Windmin:=y1*256+x1;
   Windmax:=y2*256+x2;
  End;
 { Figyelem !!
   A NewWindow a kurzort nem mozd¡tja el a hely‚r”l, ez‚rt kiad sa ut n egy
   CLRSCR utas¡t s szks‚ges, ami t”rli az ablakot, ‚s a kurzort be ll¡ja !
 }

 (**************************************************************************)
 (**  A m¢dos¡tott billentyzetmegszak¡t s aktiv l sa                     **)
 (**************************************************************************)
 Procedure InstallKEYirq;
  Begin
   GetintVec($09,@OldKeyIRQ);
   SetintVec($09,@KeyIRQ);
   fillchar(ktb,128,0);
  End;

 (**************************************************************************)
 (**  A BIOS billentyzetmegszak¡t s vissza ll¡t sa                       **)
 (**************************************************************************)
 Procedure UninstallKeyirq;
  Begin
   SetintVec($09,@OldKeyIRQ);
  End;

 (**************************************************************************)
 (**  Egy els”dleges (EGA) palettaregiszter be ll¡t sa                    **)
 (**************************************************************************)
 Procedure SetEGApalette(Regnum,Vaule:byte);Assembler;
  Asm
   mov  dx,$3da
   in   al,dx
   mov  dx,$3c0
   mov  al,regnum
   out  dx,al
   mov  al,vaule
   out  dx,al
   mov  al,$20
   out  dx,al
  End;

 (**************************************************************************)
 (**  Egy RGB regiszter be ll¡t sa                                        **)
 (**************************************************************************)
 Procedure SetRGB(Palnum,Red,Green,Blue:byte);Assembler;
  Asm
   mov  dx,$3c8
   mov  al,palnum
   out  dx,al
   inc  dx
   mov  al,red
   out  dx,al
   mov  al,green
   out  dx,al
   mov  al,blue
   out  dx,al
  End;

 (**************************************************************************)
 (**        A TIMER megszak¡t si intervallum be ll¡t sa                   **)
 (**************************************************************************)
 Procedure Settimer(p:word);Assembler;
  Asm
   mov   al,$36
   out	 $43,al
   mov   ax,P
   out   $40,al
   mov   al,ah
   out   $40,al
  End;

 (**************************************************************************)
 (**  T”bb karakter egyttes  tdefini l sa                                **)
 (**************************************************************************)
 Procedure DefChars(dat:pointer; fm:byte; car,db:word);Assembler;
  Asm
    push  es
    push  bp
    mov   ax,$1110
    mov   cx,db
    mov   dx,car
    xor   bl,bl
    mov   bh,fm
    les   bp,dat
    int   $10
    pop   bp
    pop   es
  End;

 (**************************************************************************)
 (**  Egy karakter  tdefini l sa                                          **)
 (**************************************************************************)
 Procedure DefChar(dat:pointer; car,fm:word);Assembler;
  Asm
    push ds
    push es
    mov  ax,0a000h
    mov  es,ax
    lds  si,dat
    mov  di,car
    shl  di,5
    mov  cx,fm
    cld

    mov  dx,03ceh
    mov  ax,0005h
    out  dx,ax
    mov  ax,0406h
    out  dx,ax
    mov  dx,03c4h
    mov  ax,0402h
    out  dx,ax
    mov  ax,0704h
    out  dx,ax

    rep movsb

    mov  ax,0302h
    out  dx,ax
    mov  ax,0304h
    out  dx,ax
    mov  dx,03ceh
    mov  ax,1005h
    out  dx,ax
    mov  ax,0e06h
    out  dx,ax

    pop  es
    pop  ds
  End;

 (**************************************************************************)
 (**  Egy ablak mem¢riaig‚ny‚nek meg llap¡t sa                            **)
 (**************************************************************************)
 Function Framesise(x1,y1,x2,y2:integer):word;Assembler;
  Asm
    mov  bx,x2
    sub  bx,x1
    inc  bx
    shl  bx,1
    mov  ax,y2
    sub  ax,y1
    inc  ax
    mul  bx
  End;

 (**************************************************************************)
 (**  Egy ablak elt rol sa a mem¢ri ban                                   **)
 (**************************************************************************)
 Procedure Getframe(x1,y1,x2,y2:word; p:pointer);Assembler;
  Asm
    push es
    push ds

    cld
    les  di,p
    mov  si,x1
    shl  si,1
    mov  ax,y1
    mul  LogicalSize
    add  si,ax

    mov  ax,LogicalSize
    mov  dx,$b800
    mov  ds,dx
    mov  dx,y2
    sub  dx,y1
    inc  dx

    mov  bx,x2
    sub  bx,x1
    inc  bx
@cikl:
    mov  cx,bx
    push si
    rep movsw
    pop  si
    add  si,ax
    dec  dx
    jnz  @cikl

    pop  ds
    pop  es
  End;

 (**************************************************************************)
 (**  Egy mem¢ri ban t rolt ablak megjelen¡t‚se                           **)
 (**************************************************************************)
 Procedure PutFrame(x1,y1,x2,y2:word; p:pointer);Assembler;
  Asm
    push es
    push ds
    cld

    mov  di,x1
    shl  di,1
    mov  ax,y1
    mul  LogicalSize
    add  di,ax

    mov  ax,LogicalSize
    mov  dx,$b800
    mov  es,dx
    lds  si,p

    mov  dx,y2
    sub  dx,y1
    inc  dx
    mov  bx,x2
    sub  bx,x1
    inc  bx
@Cikl:
    mov  cx,bx
    push di
    rep movsw
    pop  di
    add  di,ax
    dec  dx
    jnz  @Cikl

    pop  ds
    pop  es
  End;

 (**************************************************************************)
 (**  Egy sz m hexadecim lis form ja ( DEC->HEX konverzi¢ )               **)
 (**************************************************************************)
 Procedure HexStr(X:word; var S:string);Assembler;
  Asm
    push es

    lea  bx,digit
    les  di,S
    cld
    mov  al,4
    stosb
    mov  cx,X

    mov  al,ch
    shr  al,4
    xlat
    stosb
    mov  al,ch
    and  al,15
    xlat
    stosb
    mov  al,cl
    shr  al,4
    xlat
    stosb
    mov  al,cl
    and  al,15
    xlat
    stosb

    pop  es
  End;

 (**************************************************************************)
 (**  Egy sz m bin ris form ja ( DEC->BIN konverzi¢ )                     **)
 (**************************************************************************)
 Procedure BinStr(X:word; var S:string);Assembler;
  Asm
    push es
    cld
    les  di,S
    mov  al,16
    stosb

    mov  ah,$30
    mov  bx,X
    mov  cx,16
@Cikl:
    shl  bx,1
    mov  al,ah
    adc  al,0
    stosb
    loop @Cikl

    pop  es
  End;

 (**************************************************************************)
 (**  Bin ris string sz mm  alak¡t sa ( BIN->DEC konverzi¢)               **)
 (**************************************************************************)
 Procedure StrBin(var S:string; var X:word);
  var i:byte;
  Begin
   x:=0;
   s:='0000000000000000'+s;
   for i:=0 to 15 do if s[length(s)-i]='1' then inc(x,Bits[15-i]);
  End;

 (**************************************************************************)
 (**  Hexadecim lis string sz mm  alak¡t sa ( HEX->DEC konverzi¢)         **)
 (**************************************************************************)
 Procedure StrHex(var S:string; var X:word);
  var i:byte;
  Begin
   x:=0;
   s:='0000'+s;
   for i:=0 to 3 do
    case s[length(s)-i] of
     '0'..'9': inc(x,(byte(s[length(s)-i])-48)*Hdig[i]);
     'a'..'f': inc(x,(byte(s[length(s)-i])-87)*Hdig[i]);
     'A'..'F': inc(x,(byte(s[length(s)-i])-55)*Hdig[i]);
    end;
  End;

 (**************************************************************************)
 (**  Karaktercsere egy ablakban                                          **)
 (**************************************************************************)
 Procedure CharChange(x1,y1,x2,y2:word; oldCH,newCH:char);Assembler;
  Asm
    push es
    cld
    mov  di,x1
    shl  di,1
    mov  ax,y1
    mul  LogicalSize
    add  di,ax
    mov  bx,LogicalSize

    mov  dx,$B800
    mov  es,dx

    mov  dx,y2
    sub  dx,y1
    inc  dx
    mov  si,x2
    sub  si,x1
    inc  si
@Cikl2:
    push di
    mov  cx,si
@Cikl1:
    mov  ax,es:[di]
    cmp  al,oldCH
    jnz  @c1
    mov  al,newCH
@c1:
    stosw
    loop @Cikl1
    pop  di
    add  di,bx
    dec  dx
    jnz  @Cikl2

    pop  es
  End;

 (**************************************************************************)
 (**  Sz¡nb jtcsere egy ablakban                                          **)
 (**************************************************************************)
 Procedure AttrChange(x1,y1,x2,y2:word; oldAT,newAT:byte);Assembler;
  Asm
    push es
    cld
    mov  di,x1
    shl  di,1
    mov  ax,y1
    mul  LogicalSize
    add  di,ax
    mov  bx,LogicalSize

    mov  dx,$B800
    mov  es,dx

    mov  dx,y2
    sub  dx,y1
    inc  dx
    mov  si,x2
    sub  si,x1
    inc  si
@Cikl2:
    push di
    mov  cx,si
@Cikl1:
    mov  ax,es:[di]
    cmp  ah,oldAT
    jnz  @c1
    mov  ah,newAT
@c1:
    stosw
    loop @Cikl1
    pop  di
    add  di,bx
    dec  dx
    jnz  @Cikl2

    pop  es
  End;

 (**************************************************************************)
 (**  Keret rajzol sa                                                     **)
 (**************************************************************************)
 Procedure DrawBorder(x1,y1,x2,y2:word; tp,col:byte);Assembler;
  Asm
    push es
    cld
    mov  al,tp
    and  ax,7
    shl  ax,3
    lea  si,Border
    add  si,ax

    mov  ax,$B800
    mov  es,ax

    mov  ax,y1
    mul  LogicalSize
    mov  di,x1
    shl  di,1
    push di
    add  di,ax
    mov  ax,y2
    mul  LogicalSize
    pop  bx
    add  bx,ax

    mov  cx,x2
    sub  cx,x1
    dec  cx
    mov  ah,col

    push di

    mov  al,[si]
    stosw
    mov  al,[si+3]
    mov  es:[bx],ax
    add  bx,2
@Cikl1:
    mov  al,[si+4]
    stosw
    mov  al,[si+6]
    mov  es:[bx],ax
    add  bx,2
    loop @Cikl1

    mov  dx,LogicalSize
    mov  al,[si+1]
    mov  es:[di],ax
    mov  al,[si+2]
    mov  es:[bx],ax
    add  di,dx
    pop  bx
    add  bx,dx

    mov  cx,y2
    sub  cx,y1
    dec  cx
@Cikl2:
    mov  al,[si+5]
    mov  es:[di],ax
    mov  al,[si+7]
    mov  es:[bx],ax
    add  di,dx
    add  bx,dx
    loop @Cikl2

    pop  es
  End;

 (**************************************************************************)
 (**  K‚t v ltoz¢ ekvivalenci j nak meg llap¡t sa    X=Y ?                **)
 (**************************************************************************)
 Function EQ(var x; var y; size:word):Boolean;Assembler;
  Asm
    push ds
    push es

    mov  al,1
    lds  si,x
    les  di,y
    cld
    mov  cx,size
    repe cmpsb
    jcxz @ki
    xor  al,al
@ki:
    pop  es
    pop  ds
  End;

 (**************************************************************************)
 (**  K‚t v ltoz¢ antivalenci j nak meg llap¡t sa    X<>Y ?               **)
 (**************************************************************************)
 Function NE(var x; var y; size:word):Boolean;Assembler;
  Asm
    push ds
    push es

    xor  al,al
    lds  si,x
    les  di,y
    cld
    mov  cx,size
    repe cmpsb
    jcxz @ki
    inc  al
@ki:
    pop  es
    pop  ds
  End;

 (**************************************************************************)
 (**  Az egys‚g v ltoz¢inak inicializ l sa indul skor                     **)
 (**************************************************************************)
 BEGIN
  LogicalSize:=$a0;
  LastCrtMode:=$03;
  LastCtop:=   $0d;
  LastCBottom:=$0e;
 END.