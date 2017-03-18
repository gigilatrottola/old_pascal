UNIT MenuMake;

INTERFACE
const
    MaxMenuSor=20;
type
    ItemType=record
       cim:string[40];
       act:boolean;
    end;
    MenuItemsType=array[0..MaxMenuSor] of ItemType;

procedure ShadowOn;
procedure ShadowOff;
procedure ItemOn(var MenuItems:MenuItemsType;i:byte);
procedure ItemOff(var MenuItems:MenuItemsType;i:byte);
procedure DrawDirectly;
procedure UseCrt;
procedure FirstChosen(c:byte);
procedure BigMenu;
procedure SmallMenu;
procedure MenuColors(ah,kh,k,ak,kk,ab,kab,c,pa,kp:byte);
procedure MenuBorders(fugg,viz:byte);
function MenuChoice(x,y:byte;MenuItems:MenuItemsType;MenuPontSzam:byte):byte;

IMPLEMENTATION
uses Crt;
var
    { sz°nek }
    AlapHatterSzin,
    KiemeltHatterSzin,
    KeretSzin,
    AlapSzin,
    KiemeltSzin,
    AktivBetuSzin,
    KiemeltAktivBetuSzin,
    CimSzin,
    PasszivAlapSzin,
    KiemeltPasszivSzin  : byte;
    { keret }
    FuggolegesKeret,
    VizszintesKeret : char;
    { MenÅ sarok-karakterei }
    BalFelsoSarok,
    JobbFelsoSarok,
    BalAlsoSarok,
    JobbAlsoSarok : char;
    { menÅnagys†g , elsî kiemelt , van-e †rnyÇkol†s }
    ElsoKiemelt : byte;
    KisMenu     : boolean;
    Shadow      : boolean;
    { hogyan rajzol a kÇpernyîre : CRT-vel vagy direkt mem¢ri†ba °r†ssal }
    DirectDrawToScreen : boolean;
    NincsBekeres       : boolean;


procedure ShadowOn;  { bekapcsolja az †rnyÇkol†st }
begin
    Shadow:=true;
end;
procedure ShadowOff;  { kikapcsolja az †rnyÇkol†st }
begin
    Shadow:=false;
end;
{ †tadott MenuItemsType t°pusu tîmb egyik sor†t passzivra †ll°tja }
procedure ItemOn(var MenuItems:MenuItemsType;i:byte);
begin
    if (i>0) and (i<=MaxMenuSor) then
      MenuItems[i].act:=true;
end;
procedure ItemOff(var MenuItems:MenuItemsType;i:byte);
begin
    if (i>0) and (i<=MaxMenuSor) then
      MenuItems[i].act:=false;
end;
{ direkt kÇpernyîre °r†s }
procedure DrawDirectly;
begin
    DirectDrawToScreen:=true;
end;
{ CRT unit haszn†lata }
procedure UseCrt;
begin
    DirectDrawToScreen:=false;
end;
{ az automatikusan elsînek kiv†lasztott menÅpont be†llit†sa }
procedure FirstChosen(c:byte);
begin
   NincsBekeres:=128=(c and 128);
   c:=c and 127;
   If (c>0) and (c<=MaxMenuSor) then ElsoKiemelt:=c;
end;
{ menÅ nagys†g†nak †ll°t†sa }
procedure BigMenu;
begin
    KisMenu:=false;
end;
procedure SmallMenu;
begin
    KisMenu:=true;
end;
{      menÅ îsszes sz°nÇnek be†ll°t†sa
  !!!  ha a sz°n>15 akkor marad a rÇgi !!!  }
procedure MenuColors(ah,kh,k,ak,kk,ab,kab,c,pa,kp:byte);
begin
   If ah<16 then AlapHatterSzin:=ah;
   If kh<16 then KiemeltHatterSzin:=kh;
   If k<16  then KeretSzin:=k;
   If ak<16 then AlapSzin:=ak;
   If kk<16 then KiemeltSzin:=kk;
   If ab<16 then AktivBetuSzin:=ab;
   If kab<16 then KiemeltAktivBetuSzin:=kab;
   If c<16  then CimSzin:=c;
   If pa<16 then PasszivAlapSzin:=pa;
   If kp<16 then KiemeltPasszivSzin:=kp;
end;
{ menÅkeret be†llit†s:  1 - egyszeres   2 - kÇtszeres }
procedure MenuBorders(fugg,viz:byte);
begin
    If ( (fugg<>1) and (fugg<>2) ) or
       ( (viz<>1) and (viz<>2) )  then exit;
    If fugg=1 then FuggolegesKeret:='≥'
    else FuggolegesKeret:='∫';
    if viz=1 then VizSzintesKeret:='ƒ'
    else VizSzintesKeret:='Õ';
    { sarkok be†ll°t†sa }
    If fugg=1 then
      If viz=1 then
       begin
          BalFelsoSarok :='⁄';
          JobbFelsoSarok:='ø';
          BalAlsoSarok  :='¿';
          JobbAlsoSarok :='Ÿ';
       end
      else
       begin
          BalFelsoSarok :='’';
          JobbFelsoSarok:='∏';
          BalAlsoSarok  :='‘';
          JobbAlsoSarok :='æ';
       end
    else { fugg=2 }
      If viz=1 then
       begin
          BalFelsoSarok :='÷';
          JobbFelsoSarok:='∑';
          BalAlsoSarok  :='”';
          JobbAlsoSarok :='Ω';
       end
      else
       begin
          BalFelsoSarok :='…';
          JobbFelsoSarok:='ª';
          BalAlsoSarok  :='»';
          JobbAlsoSarok :='º';
       end;
end;

procedure Kiemel(ki:boolean;Item:ItemType;x,y,AktBetuX:byte);
var
    Ernyo : array[1..25,1..80,1..2] of char absolute $b800:$0;
    szin  : char;
    sz2   : char;
    i     : byte;
begin
    If Ki then
      If Item.act then
        begin
           szin:=chr(16*KiemeltHatterSzin+KiemeltSzin);
           sz2 :=chr(16*KiemeltHatterSzin+KiemeltAktivBetuSzin);
        end
      else
        begin
           szin:=chr(16*KiemeltHatterSzin+KiemeltPasszivSzin);
           sz2 :=szin;
        end
    else
      If Item.act then
        begin
           szin:=chr(16*AlapHatterSzin+AlapSzin);
           sz2 :=chr(16*AlapHatterSzin+AktivBetuSzin);
        end
      else
        begin
           szin:=chr(16*AlapHatterSzin+PasszivAlapSzin);
           sz2 :=szin;
        end;
    If DirectDrawToScreen then
      begin
         For i:=1 to ord(Item.cim[0]) do
           begin
              Ernyo[y,x+i-1,1]:=Item.cim[i];
              Ernyo[y,x+i-1,2]:=szin;
           end;
         If AktBetuX>0 then
           begin
              Ernyo[y,x+AktBetuX-1,1]:=Item.cim[AktBetuX];
              Ernyo[y,x+AktBetuX-1,2]:=sz2;
           end;
      end
    else
      begin
         TextAttr:=ord(szin);
         GotoXY(x,y);  Write(Item.cim);
         If AktBetuX>0 then
           begin
              TextAttr:=ord(sz2);
              GotoXY(x+AktBetuX-1,y);  Write(Item.cim[AktBetuX]);
           end;
      end;
end;

function MenuChoice(x,y:byte;MenuItems:MenuItemsType;MenuPontSzam:byte):byte;
var
    i,j,k,kiemelt : byte;
    CimHossz      : byte;
    kilepes       : boolean;
    AktivBetuHely : array[1..MaxMenuSor] of byte;
    Ernyo         : array[1..25,1..80,1..2] of char absolute $b800:$0;
    Elvalasztas   : array[1..MaxMenuSor-1] of byte;
    ElvSzam       : byte;
    ItemY         : array[1..MaxMenuSor] of byte;
    szin          : char;
    bal,job,c     : char;
    kx,ky,RegiSzin: byte;
begin
    { adatellenîrzÇs }
    If (MenuPontSzam<2) or (MenuPontSzam>MaxMenuSor) then exit;
    { adathiba ? }
    For i:=0 to MenuPontSzam do
     If Ord(MenuItems[i].cim[0])>40 then MenuItems[i].cim:='ERROR';
    { elv†laszt†sok vizsg†lata }
    ElvSzam:=0;
    For i:=1 to MenuPontSzam-1 do
      If MenuItems[i].cim[ord(MenuItems[i].cim[0])]='/' then
       begin
          Elvalasztas[i]:=1;
          Inc(ElvSzam);
          MenuItems[i].cim[0]:=chr( ord(MenuItems[i].cim[0])-1 );
       end
      else
        If MenuItems[i].cim[ord(MenuItems[i].cim[0])]='%' then
         begin
            Elvalasztas[i]:=2;
            Inc(ElvSzam);
            MenuItems[i].cim[0]:=chr( ord(MenuItems[i].cim[0])-1 );
         end
        else elvalasztas[i]:=0;
    { aktiv betÅ kiv†laszt†sa , csillagok tîrlÇse }
    For i:=1 to MenuPontSzam do
     begin
        j:=1;
        While (j<ord(MenuItems[i].cim[0])) and (MenuItems[i].cim[j]<>'*') do
          Inc(j);
        If j<ord(MenuItems[i].cim[0]) then
          begin
             AktivBetuHely[i]:=j;
             For k:=j to ord(MenuItems[i].cim[0])-1 do
               MenuItems[i].cim[k]:=MenuItems[i].cim[k+1];
             MenuItems[i].cim[0]:=Chr(k);
          end
        else AktivBetuHely[i]:=0;  { nincs akt°v betÅ a sorban }
     end;
    { menÅc°m bîv°tÇse hat†rol¢kkal }
    If (ord(MenuItems[0].cim[0])>0) and
       (ord(MenuItems[0].cim[0])<39) then
      MenuItems[0].cim:='['+MenuItems[0].cim+']';
    { CimHossz meghat†roz†sa }
    CimHossz:=ord(MenuItems[0].cim[0]);
    For i:=1 to MenuPontSzam do
     If ord(MenuItems[i].cim[0])>CimHossz then
       CimHossz:=ord(MenuItems[i].cim[0]);
    If CimHossz=0 then exit;
    { Itemek kiegÇsz°tÇse }
    For i:=1 to MenuPontSzam do
      begin
         For j:=ord(MenuItems[i].cim[0])+1 to CimHossz do
           MenuItems[i].cim[j]:=#32;
         MenuItems[i].cim[0]:=chr(CimHossz);
      end;
    CimHossz:=CimHossz+2;
    { x,y ellenîrzÇse }
    If not KisMenu then
      If (x=0) or (y=0) or (x+CimHossz+5>80) or
         (y+ElvSzam+MenuPontSzam+3>25) then exit
      else { semmi }
    else
      If (x=0) or (y=0) or (x+CimHossz-1>80) or
         (y+ElvSzam+MenuPontSzam+1>25) then exit;
    { menÅ felrajzol†sa }
    If DirectDrawToScreen then
      begin
         If KisMenu then
           begin
              k:=16*AlapHatterSzin+AlapSzin;
              szin:=chr(k);
              For i:=0 to CimHossz-1 do
               For j:=0 to ElvSzam+MenuPontSzam+1 do
                 begin
                    ernyo[y+j,x+i,1]:=#32;
                    ernyo[y+j,x+i,2]:=szin;
                 end;
              For i:=1 to CimHossz do ernyo[y+j+1,x+i,2]:=chr(8);
              For j:=1 to ElvSzam+MenuPontSzam+1 do ernyo[y+j,x+i,2]:=chr(8);
           end
         else
           begin
              k:=16*AlapHatterSzin+AlapSzin;
              szin:=chr(k);
              For i:=0 to CimHossz+5 do
               For j:=0 to ElvSzam+MenuPontSzam+3 do
                 begin
                    ernyo[y+j,x+i,1]:=#32;
                    ernyo[y+j,x+i,2]:=szin;
                 end;
              For i:=1 to CimHossz+6 do ernyo[y+j+1,x+i,2]:=chr(8);
              For j:=1 to ElvSzam+MenuPontSzam+3 do ernyo[y+j,x+i,2]:=chr(8);
              x:=x+3;
              y:=y+1;
           end;
         { keret kirajzol†sa }
         k:=16*AlapHatterSzin+KeretSzin;
         szin:=chr(k);
         ernyo[y,x,1]:=BalFelsoSarok;
         ernyo[y,x,2]:=szin;
         ernyo[y,x+CimHossz-1,1]:=JobbFelsoSarok;
         ernyo[y,x+CimHossz-1,2]:=szin;
         ernyo[y+ElvSzam+MenuPontSzam+1,x,1]:=BalAlsoSarok;
         ernyo[y+ElvSzam+MenuPontSzam+1,x,2]:=szin;
         ernyo[y+ElvSzam+MenuPontSzam+1,x+CimHossz-1,1]:=JobbAlsoSarok;
         ernyo[y+ElvSzam+MenuPontSzam+1,x+CimHossz-1,2]:=szin;
         For i:=1 to CimHossz-2 do
           begin
              ernyo[y,x+i,1]:=VizszintesKeret;
              ernyo[y,x+i,2]:=szin;
              ernyo[y+ElvSzam+MenuPontSzam+1,x+i,1]:=VizszintesKeret;
              ernyo[y+ElvSzam+MenuPontSzam+1,x+i,2]:=szin;
           end;
         For i:=1 to ElvSzam+MenuPontSzam do
           begin
              ernyo[y+i,x,1]:=FuggolegesKeret;
              ernyo[y+i,x,2]:=szin;
              ernyo[y+i,x+CimHossz-1,1]:=FuggolegesKeret;
              ernyo[y+i,x+CimHossz-1,2]:=szin;
           end;
         { menÅc°m ki°r†sa }
         j:=16*AlapHatterSzin+CimSzin;
         k:=x+(CimHossz-ord(MenuItems[0].cim[0])) div 2;
         For i:=1 to ord(MenuItems[0].cim[0]) do
           begin
              Ernyo[y,k+i-1,1]:=MenuItems[0].cim[i];
              Ernyo[y,k+i-1,2]:=chr(j);
           end;
         { kiemelt be†ll°t†sa }
         If ElsoKiemelt>MenuPontSzam then
           ElsoKiemelt:=MenuPontSzam;
         Kiemelt:=ElsoKiemelt;
         { elv†laszt¢vonalak Çs szîveg kirajzol†sa }
         k:=1;
         For i:=1 to MenuPontSzam-1 do
           begin
              {  i-edik Item kiir†sa y+k-adik sorba }
              Kiemel(i=kiemelt,MenuItems[i],x+1,y+k,AktivBetuHely[i]);
              ItemY[i]:=k;
              Inc(k);
              If Elvalasztas[i]<>0 then
                begin
                   { vonal kirajzol†sa y+k sorba }
                   If FuggolegesKeret='≥' then
                     If Elvalasztas[i]=1 then
                       begin  bal:='√'; job:='¥';  end
                     else
                       begin  bal:='∆'; job:='µ';  end
                   else
                     If Elvalasztas[i]=1 then
                       begin  bal:='«'; job:='∂';  end
                     else
                       begin  bal:='Ã'; job:='π';  end;
                   Ernyo[y+k,x,1]:=bal;
                   Ernyo[y+k,x,2]:=szin;
                   Ernyo[y+k,x+CimHossz-1,1]:=job;
                   Ernyo[y+k,x+CimHossz-1,2]:=szin;
                   For j:=1 to CimHossz-2 do
                     begin
                        If Elvalasztas[i]=1 then Ernyo[y+k,x+j,1]:='ƒ'
                        else Ernyo[y+k,x+j,1]:='Õ';
                        Ernyo[y+k,x+j,2]:=szin;
                     end;
                   Inc(k);
                end;
           end;
         Inc(i);
         Kiemel(i=kiemelt,MenuItems[i],x+1,y+k,AktivBetuHely[i]);
         ItemY[i]:=k;
      end
    else    { CRT-vel }
      begin
         RegiSzin:=TextAttr;  kx:=Wherex;  ky:=Wherey;
         If KisMenu then
           begin
              TextAttr:=16*AlapHatterSzin+AlapSzin;
              For i:=0 to CimHossz-1 do
               For j:=0 to ElvSzam+MenuPontSzam+1 do
                 begin
                    GotoXY(x+i,y+j);
                    Write(#32);
                 end;
           end
         else
           begin
              TextAttr:=16*AlapHatterSzin+AlapSzin;
              For i:=0 to CimHossz+5 do
               For j:=0 to ElvSzam+MenuPontSzam+3 do
                 begin
                    GotoXY(x+i,y+j);
                    Write(#32);
                 end;
              x:=x+3;
              y:=y+1;
           end;
         { keret kirajzol†sa }
         TextAttr:=16*AlapHatterSzin+KeretSzin;
         GotoXY(x,y);  Write(BalFelsoSarok);
         GotoXY(x+CimHossz-1,y);  Write(JobbFelsoSarok);
         GotoXY(x,y+ElvSzam+MenuPontSzam+1);  Write(BalAlsoSarok);
         GotoXY(x+CimHossz-1,y+ElvSzam+MenuPontSzam+1);  Write(JobbAlsoSarok);
         For i:=1 to CimHossz-2 do
           begin
              GotoXY(x+i,y); Write(VizszintesKeret);
              GotoXY(x+i,y+ElvSzam+MenuPontSzam+1); Write(VizszintesKeret);
           end;
         For i:=1 to ElvSzam+MenuPontSzam do
           begin
              GotoXY(x,y+i);  Write(FuggolegesKeret);
              GotoXY(x+CimHossz-1,y+i);  Write(FuggolegesKeret);
           end;
         { menÅc°m ki°r†sa }
         TextAttr:=16*AlapHatterSzin+CimSzin;
         k:=x+(CimHossz-ord(MenuItems[0].cim[0])) div 2;
         GotoXY(k,y);  Write(MenuItems[0].cim);
         { kiemelt be†ll°t†sa }
         If ElsoKiemelt>MenuPontSzam then
           ElsoKiemelt:=MenuPontSzam;
         Kiemelt:=ElsoKiemelt;
         { elv†laszt¢vonalak Çs szîveg kirajzol†sa }
         k:=1;
         For i:=1 to MenuPontSzam-1 do
           begin
              {  i-edik Item kiir†sa y+k-adik sorba }
              Kiemel(i=kiemelt,MenuItems[i],x+1,y+k,AktivBetuHely[i]);
              ItemY[i]:=k;
              Inc(k);
              If Elvalasztas[i]<>0 then
                begin
                   { vonal kirajzol†sa y+k sorba }
                   If FuggolegesKeret='≥' then
                     If Elvalasztas[i]=1 then
                       begin  bal:='√'; job:='¥';  end
                     else
                       begin  bal:='∆'; job:='µ';  end
                   else
                     If Elvalasztas[i]=1 then
                       begin  bal:='«'; job:='∂';  end
                     else
                       begin  bal:='Ã'; job:='π';  end;
                   TextAttr:=16*AlapHatterSzin+KeretSzin;
                   GotoXY(x,y+k);  Write(bal);
                   GotoXY(x+CimHossz-1,y+k); Write(job);
                   For j:=1 to CimHossz-2 do
                     If Elvalasztas[i]=1 then
                       begin
                          GotoXY(x+j,y+k);
                          Write('ƒ');
                       end
                     else
                       begin
                          GotoXY(x+j,y+k);
                          Write('Õ');
                       end;
                   Inc(k);
                end;
           end;
         Inc(i);
         Kiemel(i=kiemelt,MenuItems[i],x+1,y+k,AktivBetuHely[i]);
         ItemY[i]:=k;
      end;
   If not NincsBekeres then
   begin
    { billentyÅzetpuffer kiÅr°tÇse }
    While keypressed do c:=readkey;
    Kilepes:=false;
    repeat
       c:=readkey;
       if c=#0 then
         begin
            c:=readkey;
            case c of
            #72,
            #75:begin
                   Kiemel(false,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                   If Kiemelt=1 then Kiemelt:=MenuPontSzam
                   else Dec(Kiemelt);
                   Kiemel(true,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                end;
            #80,
            #77:begin
                   Kiemel(false,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                   If Kiemelt=MenuPontSzam then Kiemelt:=1
                   else Inc(Kiemelt);
                   Kiemel(true,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                end;
            #71,
            #73:begin
                   Kiemel(false,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                   Kiemelt:=1;
                   Kiemel(true,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                end;
            #79,
            #81:begin
                   Kiemel(false,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                   Kiemelt:=MenuPontSzam;
                   Kiemel(true,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                end;
            end; { case }
         end
       else
         begin
            Case c of
            #13:If MenuItems[Kiemelt].act then
                  begin
                     Kilepes:=True;
                     MenuChoice:=Kiemelt;
                  end;
            #27:begin
                   Kilepes:=true;
                   MenuChoice:=0;
                end;
            else  { megnÇzem hogy c akt°v betÅ-e }
              begin
                 i:=1;
                 While (i<MenuPontSzam) and
                       ( (UpCase(c)<>UpCase(MenuItems[i].cim[AktivBetuHely[i]])) or
                         (AktivBetuHely[i]=0) or
                         (not MenuItems[i].act) )   do  Inc(i);
                 If (AktivBetuHely[i]<>0) and  MenuItems[i].act  and
                    (UpCase(MenuItems[i].cim[AktivBetuHely[i]])=UpCase(c)) then
                   begin
                       Kiemel(false,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                       Kiemelt:=i;
                       Kiemel(true,MenuItems[kiemelt],x+1,y+ItemY[kiemelt],
                          AktivBetuHely[kiemelt]);
                       Kilepes:=true;
                       MenuChoice:=i;
                   end;
              end;
            end; { case }
         end;
    until kilepes;
   end;
    If not DirectDrawToScreen then
     begin TextAttr:=RegiSzin;  GotoXY(kx,ky); end;
end; { MenuChoice }

begin
    { alapÇrtelmezÇs }
    MenuColors(7,2,0,0,0,4,4,0,8,8);
    BigMenu;
    DrawDirectly;
    FirstChosen(1);
    MenuBorders(2,2);
    ShadowOn;
end.