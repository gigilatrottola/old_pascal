unit StrInput;

INTERFACE
const
     F1Key   =#59;
     F2Key   =#60;
     HomeKey =#71;
     UpKey   =#72;
     LeftKey =#77;
     RightKey=#75;
     EndKey  =#79;
     DownKey =#80;
     InsKey  =#82;
     DelKey  =#83;
   BackDelKey=#8;
     PgUpKey =#73;
     PgDnKey =#81;
     F10Key  =#68;
     ESCKey  =#27;
     EnterKey=#13;

procedure Beker(kezdox,kezdoy:byte;
                var maxbetuszam:byte;
                szin:byte;
                var s:string);
procedure GrBeker(kezdox,kezdoy:word;
                  var maxbetuszam:byte;
                  meret:byte;
                  st:string;
                  var s:string);

IMPLEMENTATION

uses crt,graph;

procedure Beker(kezdox,kezdoy:byte;
                var maxbetuszam:byte;
                szin:byte;
                var s:string);
var
     betuszam :byte;
     kurzorpoz:byte;
     regiszin :byte;
     i,j      :byte;
     c        :char;
     magyar   :boolean;

begin
    { bill.puffer kiÅritÇse }
    While KeyPressed do c:=ReadKey; c:='l';
    { alapÇrtÇkek be†llit†sa }
    magyar:=false;
    kurzorpoz:=1;
    regiszin:=TextAttr;
    if length(s)>maxbetuszam then begin maxbetuszam:=0; exit; end;
    betuszam:=length(s);
    kurzorpoz:=betuszam+1;
    { £j szin be†llit†sa }
    TextAttr:=szin;
    { tîrlÇs }
    For i:=0 to maxbetuszam-1 do
     begin
        Gotoxy(kezdox+i,kezdoy); write(' ');
     end;
    { kurzor alappozicioba }
    Gotoxy(kezdox,kezdoy);
    write(s);
    repeat
     { betÅk beolvas†sa }
     repeat
        c:=ReadKey;
        If c=#0 then
         begin
            c:=ReadKey;
            Case c of
            F1Key:magyar:=false;
            F2Key:magyar:=true;
            RightKey:If kurzorpoz>1 then Dec(kurzorpoz);
            LeftKey :If kurzorpoz<=betuszam then Inc(kurzorpoz);
            HomeKey :kurzorpoz:=1;
            EndKey  :kurzorpoz:=betuszam+1;
            DelKey  :If (betuszam>0) and (kurzorpoz<=betuszam) then
                      begin
                         For i:=kurzorpoz+1 to betuszam do s[i-1]:=s[i];
                         Dec(betuszam);
                         s[0]:=chr(betuszam);
                         For i:=kurzorpoz to betuszam do write(s[i]);
                         write(' ');
                      end;
            end; { case }
            Gotoxy(kezdox+kurzorpoz-1,kezdoy);
         end
        else
         Case c of
         chr(32)..chr(126):
           begin
              If magyar then
               Case c of
                'q':c:=chr(160);
                'w':c:=chr(130);
                'Q':c:=chr(143);
                'W':c:=chr(144);
                'x':c:=chr(163);
                'X':c:=chr(147);
                '[':c:=chr(148);
                '{':c:=chr(153);
                ']':c:=chr(129);
                '}':c:=chr(154);
                '\':c:=chr(162);
                '|':c:=chr(161);
                '`':c:=chr(171);
                '~':c:=chr(172);
                '@':c:=chr(224);
                '#':c:=chr(225);
                '^':c:=chr(226);
                '$':c:=chr(227);
                '%':c:=chr(228);
                '&':c:=chr(251);
                '*':c:=chr(243);
                '(':c:=chr(242);
                ')':c:=chr(241);
               end; { case }
              If (kurzorpoz>betuszam) and (betuszam<maxbetuszam) then
               begin
                  Inc(betuszam);
                  s:=s+c;
                  write(c);
                  Inc(kurzorpoz);
               end;
              If kurzorpoz<=betuszam then
                begin
                   If betuszam<maxbetuszam then
                     begin
                        Inc(betuszam);
                        s[0]:=chr(betuszam);
                        For i:=betuszam downto kurzorpoz+1 do s[i]:=s[i-1];
                        Gotoxy(kezdox+kurzorpoz,kezdoy);
                        For i:=kurzorpoz+1 to betuszam do write(s[i]);
                     end;
                   s[kurzorpoz]:=c;
                   Gotoxy(kezdox+kurzorpoz-1,kezdoy);
                   write(c);
                   Inc(kurzorpoz);
                end;
           end;
         BackDelKey       :
           If kurzorpoz>1 then { ha nem az elsî betÅn †ll }
             begin
                { kurzorpoz-tol a vÇgÇig îsszes betÅ egyel elîrÇbb lÇp }
                For i:=kurzorpoz to betuszam do s[i-1]:=s[i];
                { uj ÇrtÇkek : }
                Dec(betuszam);
                Dec(kurzorpoz);
                { sztring hossza csîkken }
                s[0]:=chr(betuszam);
                { betÅk eltol†sa a kÇpen }
                Gotoxy(kezdox+kurzorpoz-1,kezdoy);
                For i:=kurzorpoz to betuszam do write(s[i]);
                write(' ');
                Gotoxy(kezdox+kurzorpoz-1,kezdoy);
             end;
         ESCKey           :
           If betuszam>0 then
            begin
               Gotoxy(kezdox,kezdoy);
               For i:=1 to betuszam do write(' ');
               betuszam:=0;
               kurzorpoz:=1;
               s:='';
               gotoxy(kezdox,kezdoy);
            end
           else
            begin
               maxbetuszam:=0;
               TextAttr:=regiszin;
               Exit;
            end;
         end; { case }
     until c=EnterKey;
    j:=0;  i:=0;
    For i:=1 to ord(s[0]) do If s[i]=' ' then Inc(j);
    until (j<>i);
    TextAttr:=regiszin;
end;

procedure GrBeker(kezdox,kezdoy:word;
                  var maxbetuszam:byte;
                  meret:byte;
                  st:string;
                  var s:string);
label betubeolvasas;
var
     betuszam :byte;
     kurzorpoz:byte;
     i,j      :byte;
     c        :char;
     magyar   :boolean;
     eltolas  :byte;
     hatterszin,
     karszin  :byte;
     szovegmod:TextSettingsType;
begin
    { bill.puffer kiÅritÇse }
    While KeyPressed do c:=ReadKey; c:='.';

    { alapÇrtÇkek be†llit†sa }
    magyar:=false;
    if length(s)>maxbetuszam then begin maxbetuszam:=0; exit; end;
    betuszam:=length(s);
    kurzorpoz:=betuszam+1;
    eltolas:=8*meret;

    { rÇgi szîvegjellemzîk mentÇse }
    GetTextSettings(szovegmod);
    karszin    := GetColor;
    hatterszin := GetBkColor;

    { uj szîvegjellemzîk be†llit†sa }
    SetTextStyle(0,HorizDir,meret);
    SetTextJustify(0,2);

    { st kiir†sa }
    OutTextxy(kezdox,kezdoy,st);
    kezdox:=kezdox+eltolas*length(st);

    { alapÇrtelmezett szîveg kiir†sa }
    for i:=1 to length(s) do
      Outtextxy(kezdox+eltolas*(i-1),kezdoy,s[i]);

    { kurzor alappozicioba }
    OutTextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');

    repeat
     { betÅk beolvas†sa }
     repeat
      Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
      Delay(40);
      If keypressed then goto betubeolvasas;
      Delay(40);
      If keypressed then goto betubeolvasas;
      Delay(40);
      If keypressed then goto betubeolvasas;

      Setcolor(hatterszin);
      Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
      Setcolor(karszin);
      Delay(40);
      If keypressed then goto betubeolvasas;
      Delay(40);
      If keypressed then goto betubeolvasas;
      Delay(40);
      if keypressed then
       begin
betubeolvasas:
        c:=ReadKey;
        If c=#0 then
         begin
            Setcolor(hatterszin);
            Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
            Setcolor(karszin);
            If kurzorpoz<=betuszam then
              Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,s[kurzorpoz]);
            c:=ReadKey;
            Case c of
            F1Key:magyar:=false;
            F2Key:magyar:=true;
            RightKey:If kurzorpoz>1 then Dec(kurzorpoz);
            LeftKey :If kurzorpoz<=betuszam then Inc(kurzorpoz);
            HomeKey :kurzorpoz:=1;
            EndKey  :kurzorpoz:=betuszam+1;
            DelKey  :If (betuszam>0) and (kurzorpoz<=betuszam) then
                      begin
                         Setcolor(hatterszin);
                         For i:=kurzorpoz to betuszam do
                          OutTextxy(kezdox+eltolas*(i-1),kezdoy,s[i]);
                         Setcolor(karszin);
                         For i:=kurzorpoz+1 to betuszam do s[i-1]:=s[i];
                         Dec(betuszam);
                         s[0]:=chr(betuszam);
                         st:='';
                         For i:=kurzorpoz to betuszam do st:=st+s[i];
                         OutTextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,st);
                      end;
            end; { case }
            Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
         end
        else
         Case c of
         chr(32)..chr(126):
           begin
              Setcolor(hatterszin);
              Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
              Setcolor(karszin);
              If magyar then
               Case c of
                'q':c:=chr(160);
                'w':c:=chr(130);
                'Q':c:=chr(143);
                'W':c:=chr(144);
                'x':c:=chr(163);
                'X':c:=chr(147);
                '[':c:=chr(148);
                '{':c:=chr(153);
                ']':c:=chr(129);
                '}':c:=chr(154);
                '\':c:=chr(162);
                '|':c:=chr(161);
                '`':c:=chr(171);
                '~':c:=chr(172);
                '@':c:=chr(224);
                '#':c:=chr(225);
                '^':c:=chr(226);
                '$':c:=chr(227);
                '%':c:=chr(228);
                '&':c:=chr(251);
                '*':c:=chr(243);
                '(':c:=chr(242);
                ')':c:=chr(241);
               end; { case }
              If (kurzorpoz>betuszam) and (betuszam<maxbetuszam) then
               begin
                  Inc(betuszam);
                  s:=s+c;
                  Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,c);
                  Inc(kurzorpoz);
               end;
              If kurzorpoz<=betuszam then
                begin
                   If betuszam<maxbetuszam then
                     begin
                        st:='';
                        For i:=kurzorpoz to betuszam do st:=st+s[i];
                        Setcolor(hatterszin);
                        OutTextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,st);
                        Setcolor(karszin);
                        Inc(betuszam);
                        s[0]:=chr(betuszam);
                        For i:=betuszam downto kurzorpoz+1 do s[i]:=s[i-1];
                        st:='';
                        For i:=kurzorpoz+1 to betuszam do st:=st+s[i];
                        Outtextxy(kezdox+eltolas*kurzorpoz,kezdoy,st);
                     end;
                   s[kurzorpoz]:=c;
                   OutTextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,c);
                   Inc(kurzorpoz);
                end;
              Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
           end;
         BackDelKey       :
           If kurzorpoz>1 then { ha nem az elsî betÅn †ll }
             begin
                { kurzorpoz-tol a vÇgÇig îsszes betÅ egyel elîrÇbb lÇp }
                Setcolor(hatterszin);
                Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
                For i:=kurzorpoz-1 to betuszam do
                  OutTextxy(kezdox+eltolas*(i-1),kezdoy,s[i]);
                Setcolor(karszin);
                For i:=kurzorpoz to betuszam do s[i-1]:=s[i];
                { uj ÇrtÇkek : }
                Dec(betuszam);
                Dec(kurzorpoz);
                { sztring hossza csîkken }
                s[0]:=chr(betuszam);
                { betÅk eltol†sa a kÇpen }
                st:='';
                For i:=kurzorpoz to betuszam do st:=st+s[i];
                OutTextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,st);
                OutTextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
             end;
         ESCKey           :
           If betuszam>0 then
            begin
               Setcolor(hatterszin);
               Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
               OutTextxy(kezdox,kezdoy,s);
               Setcolor(karszin);
               betuszam:=0;
               kurzorpoz:=1;
               s:='';
               Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
            end
           else
            begin
               maxbetuszam:=0;
               Setcolor(hatterszin);
               Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
               Setcolor(karszin);
               { rÇgi szîvegjellemzîk be†llit†sa }
               SetTextStyle(szovegmod.font,szovegmod.direction,szovegmod.charsize);
               SetTextJustify(szovegmod.horiz,szovegmod.vert);
               Exit;
            end;
         end; { case }
       end;
     until c=EnterKey;
     j:=0;  i:=0;
     For i:=1 to ord(s[0]) do If s[i]=' ' then Inc(j);
    until (j<>i);
    Setcolor(hatterszin);
    Outtextxy(kezdox+eltolas*(kurzorpoz-1),kezdoy,'_');
    Setcolor(karszin);
    { rÇgi szîvegjellemzîk be†llit†sa }
    SetTextStyle(szovegmod.font,szovegmod.direction,szovegmod.charsize);
    SetTextJustify(szovegmod.horiz,szovegmod.vert);
end;

end.