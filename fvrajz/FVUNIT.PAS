  {$n+,e+}
unit fvunit;

INTERFACE
type
    str100=string[100];
    bytesor=array[0..100] of byte;
    szamtomb=array[1..100] of extended;

procedure Konvertalas(kif:str100;var hiba:byte;
                      var postfix:bytesor;var szamok:szamtomb);
function Kiszamit(pf:bytesor;szamok:szamtomb;x:extended;
                  var ertelmezve:boolean):extended;

IMPLEMENTATION
const
    fvszam=22;
    MuveletHalmaz : set of char=['*','/','+','-'];
    SzamjegyHalmaz: set of char=['0'..'9','.'];
    fvnevek:array[102..101+fvszam] of string[3]=
             ('SIN','COS','TAN','CTG','ABS','INT','FRA','LOG','SQR',
              'SQ2','SQ3','EXP','ATG','ACT','ASN','ACS','SHP','CHP',
              'THP','ASH','ACH','ATH');

function arcsin(x:extended):extended;  { abs(x)<1 - re jo }
begin
  arcsin:=arctan(x/sqrt((1.0-x)*(1.0+x)));
end;
function arccos(x:extended):extended;
begin
  arccos:=arctan(sqrt((1.0-x)*(1.0+x))/x);
end;
function arcctg(x:extended):extended;
begin
  arcctg:=arctan(1/x);
end;

procedure Konvertalas(kif:str100;var hiba:byte;
                      var postfix:bytesor;var szamok:szamtomb);
var
    pmut:byte;
    prior:array[0..255] of byte;
    infix,verem:bytesor;
    ifmut,vmut :byte;
    szmut:byte;
    i,j,m,k:byte;
    szam:string[15];
    szamvolt,talalt:boolean;
    err:integer;
    fv:string[3];
    elso,masodik,jel:byte;
begin
    { space-ek kit”rl‚se }
    i:=1;
    while i<=length(kif) do
      if kif[i]=' ' then delete(kif,i,1)
      else inc(i);
    { nagybetv‚ alak¡t s }
    for i:=1 to length(kif) do kif[i]:=upcase(kif[i]);
    if length(kif)=0 then begin hiba:=20; exit; end;
    { mveletek priorit sa }
    prior[0]:=0;
    prior[200]:=1;  prior[201]:=1;
    prior[202]:=2;  prior[203]:=2;
    for i:=102 to 199 do prior[i]:=3;
    prior[204]:=5;
    { nincs hiba }
    hiba:=0;
    { "--"  --> "+" }
    i:=1;
    while i<length(kif) do
     begin
        if (kif[i]='-') and (kif[i+1]='-') then
          begin
             kif[i+1]:='+';
             delete(kif,i,1);
          end;
        inc(i);
     end;
    { !!!  trkk :  el”jel --> kivon s 0-b¢l  !!! }
    If kif[1]='-' then kif:='0'+kif;
    i:=2;
    while i<length(kif) do
      begin
         If (kif[i]='-') and not(kif[i-1] in SzamjegyHalmaz) and
            (kif[i-1]<>')') and (kif[i-1]<>'X') then Insert('0',kif,i);
         inc(i);
      end;
    { infix felt”lt‚se }
    ifmut:=0; i:=1; szam:=''; szamvolt:=false; szmut:=0;
    While (i<=length(kif)) do
      begin
         If kif[i] in SzamjegyHalmaz then
           If SzamVolt then
             begin
                if length(szam)=15 then begin hiba:=21; exit; end;
                szam:=szam+kif[i];
             end
           else begin szam:=kif[i]; szamvolt:=true; end
         else begin
           If szamvolt then
             begin
                szamvolt:=false;
                Inc(szmut);
                val(szam,szamok[szmut],err);
                if err<>0 then begin hiba:=1; exit; end;
                inc(ifmut);
                infix[ifmut]:=szmut;
                szam:='';
             end;
           If kif[i] in MuveletHalmaz then begin
             inc(ifmut);
             case kif[i] of
              '+':Infix[ifmut]:=200;
              '-':Infix[ifmut]:=201;
              '*':Infix[ifmut]:=202;
              '/':Infix[ifmut]:=203;
             end; {case}
           end
           else
            case kif[i] of
             '(':begin inc(ifmut); infix[ifmut]:=204; end;
             ')':begin inc(ifmut); infix[ifmut]:=205; end;
             'X':begin inc(ifmut); infix[ifmut]:=255; end;
             else
              begin
                 If length(kif)<(i+2) then begin hiba:=2; exit; end;
                 fv:=kif[i]+kif[i+1]+kif[i+2];
                 talalt:=false; j:=101;
                 While (j<101+fvszam) and not talalt do
                   begin
                      inc(j);
                      if fvnevek[j]=fv then talalt:=true;
                   end;
                 if talalt then begin
                   i:=i+2;
                   inc(ifmut);
                   infix[ifmut]:=j;
                 end
                 else begin hiba:=3; exit; end;
              end; {case else}
            end; {case}
         end;
         inc(i);
      end; {while}
      if szam<>'' then
        begin
           Inc(szmut);
           val(szam,szamok[szmut],err);
           if err<>0 then begin hiba:=1; exit; end;
           inc(ifmut);
           infix[ifmut]:=szmut;
        end;
    { v‚gjel kirak sa }
    inc(ifmut);
    infix[ifmut]:=0;
    { els” ‚s utols¢ jel vizsg lata }
    jel:=infix[1];
    case jel of
    200..203:begin hiba:=18; exit; end;
         205:begin hiba:=18; exit; end;
    end;{case}
    jel:=infix[ifmut-1];
    case jel of
    200..203:begin hiba:=19; exit; end;
         204:begin hiba:=19; exit; end;
    102..199:begin hiba:=19; exit; end;
    end;{case}
    { sorrendvizsg lat }
    for i:=1 to ifmut-2 do begin
      elso:=infix[i];
      masodik:=infix[i+1];
      case elso of
      1..100,
           255:case masodik of
               1..100,
                    255:begin hiba:=4; exit; end;
               102..199:begin hiba:=5; exit; end;
                    204:begin hiba:=6; exit; end;
               end;{case masodik}
      102..199:case masodik of
               1..100,
                    255:begin hiba:=22; exit; end;
               102..199:begin hiba:=23; exit; end;
               200..203:begin hiba:=7; exit; end;
                    205:begin hiba:=8; exit; end;
               end;{case masodik}
      200..203:case masodik of
               200..203:begin hiba:=9; exit; end;
                    205:begin hiba:=10; exit; end;
               end;{case masodik}
           204:case masodik of
               200..203:begin hiba:=11; exit; end;
                    205:begin hiba:=12; exit; end;
               end;{case masodik}
           205:case masodik of
               1..100,
                    255:begin hiba:=13; exit; end;
               102..199:begin hiba:=14; exit; end;
                    204:begin hiba:=15; exit; end;
               end;{case masodik}
      end;{case elso}
    end;{for}
    { infix --> postfix }
    vmut:=0; pmut:=0; verem[0]:=0;
    i:=0;
    repeat
       inc(i);
       jel:=infix[i];
       { jel vizsg lata }
       case jel of
       1..100,255:begin inc(pmut); postfix[pmut]:=jel; end;
              204:begin inc(vmut); verem[vmut]:=jel; end;
              205:begin
                     while verem[vmut]<>204 do
                       begin
                          if vmut=0 then begin hiba:=16; exit; end;
                          inc(pmut);
                          postfix[pmut]:=verem[vmut];
                          dec(vmut);
                       end;
                     dec(vmut);
                  end;
         102..203:begin
                    while (prior[verem[vmut]]>=prior[jel]) and
                        (verem[vmut]<>204) do
                      begin
                         if vmut=0 then begin hiba:=16; exit; end;
                         inc(pmut);
                         postfix[pmut]:=verem[vmut];
                         dec(vmut);
                      end;
                    inc(vmut);
                    verem[vmut]:=jel;
                  end;
                0:while vmut>0 do
                   begin
                      inc(pmut);
                      if verem[vmut]=204 then begin hiba:=17; exit; end;
                      postfix[pmut]:=verem[vmut];
                      dec(vmut);
                   end;
       end;{case}
    until jel=0;
    j:=81;
    for i:=1 to pmut do
      if postfix[i]=255 then
        begin
           postfix[i]:=j;
           inc(j);
           if j>101 then begin hiba:=24; exit; end;
        end;
    { jelek sz ma }
    postfix[0]:=pmut;
end;

function Kiszamit(pf:bytesor;szamok:szamtomb;x:extended;
                  var ertelmezve:boolean):extended;
var
   valt:extended;
   i,j,eleje,vind,vind2:byte;
begin
   for i:=81 to 100 do szamok[i]:=x;
   ertelmezve:=true;
   if pf[0]=1 then
     begin
        kiszamit:=szamok[pf[1]];
        exit;
     end;
   eleje:=1; { innent”l kell m solni }
   for i:=1 to pf[0] do
    if (pf[i]>=102) and (pf[i]<=199) then
     begin
       { v ltoz¢ }
       vind:=pf[i-1];
       { l‚ptet‚s }
       for j:=i-2 downto eleje do pf[j+1]:=pf[j];
       inc(eleje);
       case pf[i] of
       { fggv‚nyek }
       102:szamok[vind]:=sin(szamok[vind]);
       103:szamok[vind]:=cos(szamok[vind]);
       106:szamok[vind]:=abs(szamok[vind]);
       107:szamok[vind]:=int(szamok[vind]);
       104:begin
              valt:=cos(szamok[vind]);
              if valt=0 then begin ertelmezve:=false; exit; end
              else szamok[vind]:=sin(szamok[vind])/valt;
           end;
       105:begin
              valt:=sin(szamok[vind]);
              if valt=0 then begin ertelmezve:=false; exit; end
              else szamok[vind]:=cos(szamok[vind])/valt;
           end;
       110:if szamok[vind]<0 then begin ertelmezve:=false; exit; end
           else szamok[vind]:=sqrt(szamok[vind]);
       109:if szamok[vind]<=0 then begin ertelmezve:=false; exit; end
            else szamok[vind]:=ln(szamok[vind]);
       108:szamok[vind]:=frac(szamok[vind]);
       111:szamok[vind]:=sqr(szamok[vind]);
       112:szamok[vind]:=sqr(szamok[vind])*szamok[vind];
       113:if szamok[vind]>2839 then szamok[vind]:=exp(2839)
           else if (szamok[vind]<-2839) then szamok[vind]:=exp(-2839)
           else szamok[vind]:=exp(szamok[vind]);
       114:szamok[vind]:=arctan(szamok[vind]);
       115:if szamok[vind]=0 then begin ertelmezve:=false; exit; end
            else szamok[vind]:=arcctg(szamok[vind]);
       116:if (szamok[vind]<=-1) or (szamok[vind]>=1) then
             begin ertelmezve:=false; exit; end
             else szamok[vind]:=arcsin(szamok[vind]);
       117:if (szamok[vind]<-1) or (szamok[vind]>1) or (szamok[vind]=0) then
             begin ertelmezve:=false; exit; end
             else szamok[vind]:=arccos(szamok[vind]);
       118:begin
             if szamok[vind]>2839 then valt:=exp(2839)
             else if (szamok[vind]<-2839) then valt:=exp(-2839)
             else valt:=exp(szamok[vind]);
             szamok[vind]:=(valt-1/valt)/2;
           end;
       119:begin
             if szamok[vind]>2839 then valt:=exp(2839)
             else if (szamok[vind]<-2839) then valt:=exp(-2839)
             else valt:=exp(szamok[vind]);
             szamok[vind]:=(valt+1/valt)/2;
           end;
       120:begin
             if (szamok[vind]>2839) then valt:=exp(2839)
             else if (szamok[vind]<-2839) then valt:=exp(-2839)
             else valt:=exp(szamok[vind]);
             szamok[vind]:=1/valt;
             szamok[vind]:=(valt-szamok[vind])/(valt+szamok[vind]);
           end;
       122:if szamok[vind]<1 then begin ertelmezve:=false; exit; end
           else begin
             valt:=sqr(szamok[vind]);
             szamok[vind]:=ln(szamok[vind]+sqrt(valt-1));
           end;
       121:begin
             valt:=sqr(szamok[vind]);
             szamok[vind]:=ln(szamok[vind]+sqrt(valt+1));
           end;
       123:if (szamok[vind]<=-1) or (szamok[vind]>=1) then
             begin ertelmezve:=false; exit; end
           else szamok[vind]:=0.5*ln((1+szamok[vind])/(1-szamok[vind]));
       end;{case}
       { eredm‚ny a fggv‚ny hely‚re }
       pf[i]:=vind;
     end
     else
     if (pf[i]>=200) and (pf[i]<=203) then
     begin
       vind :=pf[i-2];
       vind2:=pf[i-1];
       for j:=i-3 downto eleje do pf[j+2]:=pf[j];
       eleje:=eleje+2;
       case pf[i] of
       { mveletek }
       200:szamok[vind]:=szamok[vind]+szamok[vind2];
       201:szamok[vind]:=szamok[vind]-szamok[vind2];
       202:szamok[vind]:=szamok[vind]*szamok[vind2];
       203:if szamok[vind2]=0 then begin ertelmezve:=false; exit; end
           else szamok[vind]:=szamok[vind]/szamok[vind2];
       end;{case}
       pf[i]:=vind;
     end;{else}
   kiszamit:=szamok[vind];
end;

end.