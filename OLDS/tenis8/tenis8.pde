static int iniWidth=370;
static int iniHeight=330;
static int iniGrayBackground=128;

int iniTxSize=8;
float Xsc=1.0;//Jeśli ekran jest mniejszy lub większy od domyślnego 360x320
float Ysc=1.0;//To współrzędne "buttonów" trzeba przemnożyć 
PrintWriter output;             //Plik tekstowy zrobiony jako "tab delimited" żeby był wczytywalny do excela

void validation(String name) //Sprawdzenie czy data ważności niejest przekroczona
{
  if( year() >=2015  
   && month() >=6
   && day()   >=1
   && hour()  >=13
   && minute()>=13 
  )
  {
    output = createWriter(name); 
    output.print(" no ");
    output.close();
    //println("Po czasie");
    exit(); //Nie kontynuuj - ale setup lub draw się przedtem skończy!
  }
    
}

int default_text_corner_radius=6;

class RectArea 
{
  int x1,y1,x2,y2;
  color back;
  
  RectArea(float iX1,float iY1,float iX2,float iY2)
  {
    back=color(178,178,178);
    if(iX1<iX2) { x1=round(iX1);x2=round(iX2);}
      else {x1=round(iX2);x2=round(iX1);}
    if(iY1<iY2) { y1=round(iY1);y2=round(iY2);}
      else {y1=round(iY2);y2=round(iY1);}
    //println(x1+" "+y1+" "+x2+" "+y2);
  }
  
  void view()
  {
        rectMode(CORNERS);
        fill(red(back),green(back),blue(back));
        noStroke();
        rect(x1,y1,x2,y2);
  }
  
  boolean hitted(int x,int y)
  {
    return x1<=x && x<=x2
        && y1<=y && y<=y2;
  }
}

class TextButton extends RectArea
{
  color  txt,strok;
  int strokW;
  int txtSiz;
  int corner=default_text_corner_radius;
  
  String title;
  protected int state;
  
  TextButton(String iTitle,float iX1,float iY1,float iX2,float iY2)
  {
    super(iX1,iY1,iX2,iY2);
    state=0; 
    txt=color(255,255,255); back=color(0,0,0);corner=default_text_corner_radius;
    strok=color(100,100,100); strokW=3;
    title=iTitle; 
    txtSiz=iniTxSize; //Trochę to chmmm...
    
    //Dopasowywanie rozmiaru fontu żeby się zmieściło title
    textSize(txtSiz);
    while(textWidth(title) > x2-x1) textSize(--txtSiz);
    while(textAscent()+textDescent() > y2-y1) textSize(--txtSiz);
  }
  
  void view()
  {
    if(state==0)
    {
        rectMode(CORNERS);
        fill(red(back),green(back),blue(back));
        stroke(strok);
        strokeWeight(strokW);  
        rect(x1,y1,x2,y2,corner);
        fill(txt);
        textSize(txtSiz);
        textAlign(CENTER, CENTER);
        text(title,x1,y1,x2,y2); 
    }
    else
    {
        rectMode(CORNERS);
        fill(red(txt),green(txt),blue(txt));
        stroke(strok);
        strokeWeight(strokW);  
        rect(x1,y1,x2,y2,corner);
        fill(back);
        textSize(txtSiz);
        textAlign(CENTER, CENTER);
        text(title,x1,y1,x2,y2); 
    }
  }
  
  void flip_state(boolean visual) //Zmienia stan na przeciwny (0 na 1, inna na 0) i ewentualnie wizualizuje
  {
    if(state==0) state=1;
    else state=0;
    if(visual)
        view();
  }
  
  void set_state(int new_state,boolean visual) //Zmienia stan na przeciwny (0 na 1, inna na 0) i ewentualnie wizualizuje
  {
    if(new_state!=state)
    {
      state=new_state;
      if(visual)
          view();
    }
  }
  
}

class StateLabel extends TextButton //Klasa pseudobuttonu która wyświetla stan a nie title, ignoruje flip_state() 
{                                   //a zmiany stanu przez set_state ma zabezpieczone
  private boolean allowChng;//Normalnie uzycie set_state() nic nie zmienia, trzeba ustawić to pole, które po zmnianie się kasuje
                      //Więc tylko kod działający na obiektach tej klasy może to zrobić, akod działajacy na klasi ebazowej nie
  StateLabel(int iState,String iTitle,float iX1,float iY1,float iX2,float iY2)
  {
    super(iTitle,iX1,iY1,iX2,iY2);
    state=iState;allowChng=false;
  }
 
  void view()
  {
    if(allowChng)
    {
      rectMode(CORNERS);
      fill(red(txt),green(txt),blue(txt));
      stroke(back);
      strokeWeight(strokW);  
      rect(x1,y1,x2,y2);
      fill(strok);
      textSize(txtSiz);
      textAlign(CENTER, CENTER);
      text(state+"",x1,y1,x2,y2); 
    }
    else
    {
      rectMode(CORNERS);
      fill(red(txt),green(txt),blue(txt));
      stroke(strok);
      strokeWeight(strokW);  
      rect(x1,y1,x2,y2);
      fill(back);
      textSize(txtSiz);
      textAlign(CENTER, CENTER);
      text(state+"",x1,y1,x2,y2); 
    }
  }
 
  void allow()
  {
    allowChng=true;
    view();
  }
  
  void flip_state(boolean visual) //Zmienia stan na przeciwny (0 na 1, inna na 0) i ewentualnie wizualizuje
  { //Nie zmienia stanu przez flip, najwyżej ponawia wyświetlenie - choć i to chyba nieprzydatne
    if(visual)
        view();
  }
  
  void set_state(int new_state,boolean visual) //Zmienia stan na przeciwny (0 na 1, inna na 0) i ewentualnie wizualizuje
  {
    if(allowChng)
    {
      if(new_state!=state)
      {
        state=new_state;
      }
      allowChng=false;//Czy była faktyczna zmiana czy nie
      if(visual)
          view();
    }
  }
}

class StateLabelInc extends TextButton //Klasa buttonu inkrementująca jakieś state label, ewentualnie cofająca działanie drugiej pary
{
  StateLabel target;
  StateLabelInc opponent;
  
  StateLabelInc(String iTitle,float iX1,float iY1,float iX2,float iY2,StateLabel iTarget,StateLabelInc iOpponent)
  {
    super(iTitle,iX1,iY1,iX2,iY2);
    target=iTarget;opponent=iOpponent;
  }
  
  void flip_state(boolean visual) //Nakładka metody
  { 
    super.flip_state(visual);
    if(opponent.state!=0) 
            opponent.decrement(visual);
    target.allow(); //Odbezpieczenie        
    if(state>0) target.set_state(target.state+1,visual);
           else target.set_state(target.state-1,visual);
   } 
    
   void decrement(boolean visual) //Metoda cofająca zmianę
   {
     state=0;view();
     target.allow(); //Odbezpieczenie       
     target.set_state(target.state-1,visual);
   }
}

class UniqTextButton extends TextButton //Klasa buttonu którego kliknięcie zeruje stan wszystkich innych z listy
{
  ArrayList<TextButton> siblings; //Lista wykluczających się
  UniqTextButton(ArrayList<TextButton> iSibl,String iTitle,float iX1,float iY1,float iX2,float iY2)
  {
    super(iTitle,iX1,iY1,iX2,iY2);
    siblings=iSibl;
  }
  
  //Jeśli stan przycisku kliknieciem zmienia się na różny od 0 to jego rodzeństwo musi zostac wyzerowane
  void flip_state(boolean visual) //Zmienia stan na przeciwny (0 na 1, inna na 0) i ewentualnie wizualizuje
  {
    if(state==0) state=1;
    else state=0;
    if(visual)
    {
        view();
        if(state!=0)
        for(TextButton button : siblings)
        if(button!=this)
          button.set_state(0,true); //set_state jest po klasie bazowej żeby uniknąć niechcianej rekurencji
    }
  }
}

class WrTextButton extends TextButton //Button pamiętający kolumnę do jakiej ma zapisać swój unikalny marker
{   
  int column;
  String marker; 
  WrTextButton(String iTitle,float iX1,float iY1,float iX2,float iY2,String iMarker,int iColumn)
  {
    super(iTitle,iX1,iY1,iX2,iY2);
    marker=iMarker;
    column=iColumn;
  }
}

class WrUniqTextButton extends UniqTextButton //UniqButton pamiętający kolumnę do jakiej ma zapisać swój unikalny marker
{   
  int column;
  String marker; 
  WrUniqTextButton(ArrayList<TextButton> iSibl,String iTitle,float iX1,float iY1,float iX2,float iY2,String iMarker,int iColumn)
  {
    super(iSibl,iTitle,iX1,iY1,iX2,iY2);
    marker=iMarker;
    column=iColumn;
  }
}


class Panel extends RectArea
{
  ArrayList<TextButton> list; 
  Panel(float iX1,float iY1,float iX2,float iY2)
  {
    super(iX1,iY1,iX2,iY2);
    list = new ArrayList<TextButton>();
  }
  
  void view()
  {
     super.view();
     for( RectArea area: list)   //Lista obszarów do wyświetlania
     {
      area.view();
     }
  }
  
  void add(TextButton but)
  {
    list.add(but);
    but.x1+=x1;
    but.x2+=x1;
    but.y1+=y1;
    but.y2+=y1; //Przy move() trzeba z powrotem odjąć a potem dodać nowe
  }
  
}

ArrayList<String> columnNames = new ArrayList<String>(); 
String[] columnValues = null;
ArrayList<RectArea>   viAreas = new ArrayList<RectArea>();   //Lista obszarów do wyświetlania
ArrayList<TextButton> buttons = new ArrayList<TextButton>();  //Lista buttonów
//Panele związanych przycisków
Panel NextLeft;   //Panel dla dających "NEXT" przycisków KPKR z lewej strony
Panel NextRight;  //Panel dla dających  "NEXT" przycisków z prawej strony
Panel points;  //Punktacja
Panel others;  //Wymiany siatka itp inne różne
Panel WPlusMinusNO; //Prawy drugi od góry
Panel FHBHWSm; //Prawy lekko z lewej - pod punktacją
Panel BWBN;
Panel PAPB;
Panel KodowanieReczne;

//Listy wykluczeń
//ArrayList<TextButton> courtT   = new ArrayList<TextButton>();
Panel courtT;//Przyciski kortu/boiska
//ArrayList<TextButton> courtB   = new ArrayList<TextButton>();
Panel courtB;//Przyciski kortu/boiska
//ArrayList<TextButton> serves = new ArrayList<TextButton>();  
Panel serves;//Przyciski zagrywek
//ArrayList<TextButton> players = new ArrayList<TextButton>(); 
Panel players; //Zawodnicy też się wykluczają

StateLabel Exch,PktA,PktB,GemA,GemB,SetA,SetB;//Uchwyty do liczników punktów używane w nadpisanych akcjach przycisków punktowych
  
TextButton NextLnButton = null; //Button NEXT ma specjalne znaczenie bo jest z nim związana cala akcja zapisywania
int NextLnCount=0;              //Zliczanie kolejnych nextów
PImage photo;

void mousePressed() 
{
  //println("Pressed "+mouseX+" x "+mouseY);
  if(NextLnButton.hitted(mouseX,mouseY))
  {
    NextLnButton.set_state(1,true);
    NextLnCount++; //To już kolejna linia
    Exch.allow();Exch.set_state(Exch.state+1,true);
    output.print(NextLnCount+"\t"); //Jako "TimeStamp"
    
    for(int i=0;i<columnValues.length;i++) //Czyszczenie starej zawartosci kolumn specjalnych
          columnValues[i] = "";            //nie można użyć uproszczonego for(String...) bo String idzie przez wartość i nie ma zmian
          
    FillColumnValues(); //Osobna procedura do wypełniania kolumn specjalnych
    
    for(String str : columnValues) //Jako kolumny specjalne
      output.print(str+"\t");
      
    for (TextButton button : buttons)//Jako kolumny binarne
     if(button!=NextLnButton)
     {
       //TU AKCJA ZAPISYWANIA
       output.print(button.state+"\t");
       button.set_state(0,true);
     }
     else output.print(NextLnCount+"\t");
     
    output.println();
    output.flush();
  }
}

void mouseReleased() 
{
  //println("Released "+mouseX+" x "+mouseY);
  for (TextButton button : buttons) 
  {
    if(button.hitted(mouseX,mouseY))
    {
      button.flip_state(true);
      println(button.title);
    } 
  }
}  

void FillColumnValues()//Osobna procedura do wypełniania kolumn specjalnych
{
   for (TextButton button : buttons) 
   if(button.state!=0)
   {
     try{
     WrUniqTextButton tmp=(WrUniqTextButton)button;
     columnValues[tmp.column]=tmp.marker;
     }catch(Exception e)
     {/*Ignore*/}
     try{
     WrTextButton tmp=(WrTextButton)button;
     columnValues[tmp.column]=tmp.marker;
     }catch(Exception e)
     {/*Ignore*/}
   }
   //PktA,PktB,GemA,GemB,SetA,SetB;
   columnValues[4]=PktA.state+PktB.state+"";
   columnValues[5]=GemA.state+GemB.state+"";
   columnValues[6]=SetA.state+SetB.state+"";
}

void draw() //Żeby działały zdarzenia myszy to musi być chociaż puste draw()!
{
  textSize(10);
  fill(150,150,150);
  textAlign(LEFT, CENTER);
  text(" TENNIS:  Programmed by Wojciech BORKOWSKI <wborkowsk@gmail.com>. Prerelase version for Iwona PILCHOWSKA <ipilchowska@gmail.com>",0,0,width,10*Ysc); 
}
/*
boolean sketchFullScreen() //W ten sposób robi się tryb full screen jeszcze przed setupem
{
  return true;
}
*/
void setup()
{
  background(iniGrayBackground);
  size(iniWidth*3, iniHeight*2);
  //size(iniWidth*4, displayHeight);//displayWidth
  Xsc=width/iniWidth;
  Ysc=height/iniHeight;
  iniTxSize*=Ysc; //Używane w inicjacjach bittonów
  
  //Nazwy kolumn zbiorczych umieszczane przed binarnymi
  columnNames.add("Players");//0
  columnNames.add("CourtT"); //1 
  columnNames.add("CourtB"); //2
  columnNames.add("Serves"); //3
  columnNames.add("Pkt_Sum");//4  - uwaga! 
  columnNames.add("Gem_Sum");//5  - te są "ręcznie" wypełniane
  columnNames.add("ServSum");//6  - kodem w obsłudze klikniecia w "Next"
  
  columnValues = new String[columnNames.size()]; //Lista i tablica muszą być równej długości
    
  //BAZOWY EKRAN MA   static int iniWidth=370;
  //  370x330         static int iniHeight=330;
  //Musi być zaraz za kolumnami zbiorczymi, więc pierwsza na liście przycisków
  others = new Panel(105*Xsc,150*Ysc,220*Xsc,180*Ysc); others.back=color(100,100,100); viAreas.add(others);
  TextButton tmp=new TextButton("Net",15*Xsc,10*Ysc,115*Xsc,20*Ysc);buttons.add(tmp);others.add(tmp);tmp.strokW=1;tmp.corner=0; //courtT.add(tmp); 
  //wymiany
  tmp=Exch=new StateLabel(0,"exchange",2*Xsc,4*Ysc,13*Xsc,23*Ysc); buttons.add(tmp);others.add(tmp);
  //Bez panelu przycisk specjalny BP
  tmp=new TextButton("BP",5*Xsc,10*Ysc,30*Xsc,30*Ysc);buttons.add(tmp);viAreas.add(tmp); 
  //Przyciski dające NEXT
  NextLeft=new Panel(35*Xsc,10*Ysc,100*Xsc,40*Ysc); NextLeft.back=color(100,100,100); viAreas.add(NextLeft);   //Panel dla dających "NEXT" przycisków KPKR z lewej strony
  NextRight=new Panel(230*Xsc,10*Ysc,360*Xsc,40*Ysc); NextRight.back=color(100,100,100); viAreas.add(NextRight);  //Panel dla dających  "NEXT" przycisków z prawej strony
  //Przyciski W+-NO
  WPlusMinusNO=new Panel(230*Xsc,55*Ysc,360*Xsc,75*Ysc); WPlusMinusNO.back=color(100,100,100); viAreas.add(WPlusMinusNO);  
  //Reszta strony prawej
  FHBHWSm= ; //Prawy lekko z lewej - pod punktacją
  BWBN= ;
  PAPB= ;
  KodowanieReczne= ;
  
  //Blok logiki zliczania punktów 
  points = new Panel(230*Xsc,90*Ysc,360*Xsc,170*Ysc); viAreas.add(points);
  tmp=PktA=new StateLabel(0,"P(A)",43*Xsc,0*Ysc,63*Xsc,20*Ysc); buttons.add(tmp); points.add(tmp);
  tmp=PktB=new StateLabel(0,"P(B)",67*Xsc,0*Ysc,87*Xsc,20*Ysc); buttons.add(tmp); points.add(tmp);
  tmp=GemA=new StateLabel(0,"G(A)",43*Xsc,30*Ysc,63*Xsc,50*Ysc); buttons.add(tmp); points.add(tmp);
  tmp=GemB=new StateLabel(0,"G(B)",67*Xsc,30*Ysc,87*Xsc,50*Ysc); buttons.add(tmp); points.add(tmp);
  tmp=SetA=new StateLabel(0,"S(A)",43*Xsc,60*Ysc,63*Xsc,80*Ysc); buttons.add(tmp); points.add(tmp);
  tmp=SetB=new StateLabel(0,"S(B)",67*Xsc,60*Ysc,87*Xsc,80*Ysc); buttons.add(tmp); points.add(tmp);
  

  StateLabelInc  incPktA,incPktB,incGemA,incGemB,incSetA,incSetB;//Uchwyty do inkrementatorów
  tmp=incPktA=new StateLabelInc("p(A)",0*Xsc,0*Ysc,40*Xsc,20*Ysc,PktA,null); buttons.add(tmp); points.add(tmp);
  tmp=incPktB=new StateLabelInc("p(B)",90*Xsc,0*Ysc,130*Xsc,20*Ysc,PktB,null); buttons.add(tmp); points.add(tmp);
  tmp=incGemA=new StateLabelInc("g(A)",0*Xsc,30*Ysc,40*Xsc,50*Ysc,GemA,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();
                  }}; buttons.add(tmp); points.add(tmp);
  tmp=incGemB=new StateLabelInc("g(B)",90*Xsc,30*Ysc,130*Xsc,50*Ysc,GemB,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();
                  }}; buttons.add(tmp);  points.add(tmp);
  tmp=incSetA=new StateLabelInc("s(A)",0*Xsc,60*Ysc,40*Xsc,80*Ysc,SetA,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();GemA.allow();GemB.allow();
                  }}; buttons.add(tmp); points.add(tmp);
  tmp=incSetB=new StateLabelInc("s(B)",90*Xsc,60*Ysc,130*Xsc,80*Ysc,SetB,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();GemA.allow();GemB.allow();
                  }}; buttons.add(tmp); points.add(tmp);   
  incPktA.opponent=incPktB;
  incPktB.opponent=incPktA;
  incGemA.opponent=incGemB;
  incGemB.opponent=incGemA;
  incSetA.opponent=incSetB;
  incSetB.opponent=incSetA;

  //Pierwsza kolumna przycisków
  serves=new Panel(10*Xsc,160*Ysc,100*Xsc,240*Ysc);  viAreas.add(serves);
  tmp=new WrUniqTextButton(serves.list,"servis",0*Xsc,0*Ysc,40*Xsc,20*Ysc,"srv",3){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);Exch.allow();Exch.set_state(0,true); 
  }}; buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves.list,"smecz",50*Xsc,0*Ysc,90*Xsc,20*Ysc,"sme",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves.list,"FH",0*Xsc,30*Ysc,40*Xsc,50*Ysc,"FH",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves.list,"BH",50*Xsc,30*Ysc,90*Xsc,50*Ysc,"BH",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves.list,"W-FH",0*Xsc,60*Ysc,40*Xsc,80*Ysc,"W-FH",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves.list,"W-BH",50*Xsc,60*Ysc,90*Xsc,80*Ysc,"W-BH",3); buttons.add(tmp);serves.add(tmp);  
  
  //Zawodnicy
  color playerA_backg=color(0,200,0);
  color playerA_color=color(250,250,0);
  color playerB_backg=color(0,150,0);
  color playerB_color=color(200,200,0);
  players = new Panel(10*Xsc,55*Ysc,100*Xsc,105*Ysc); viAreas.add(players);
  tmp=new WrUniqTextButton(players.list,"player A",0*Xsc,0*Ysc,40*Xsc,20*Ysc,"A",0); buttons.add(tmp); tmp.txt=playerA_backg; tmp.back=playerA_color;tmp.strokW=1; players.add(tmp);
  tmp=new WrUniqTextButton(players.list,"player B",0*Xsc,30*Ysc,40*Xsc,50*Ysc,"B",0); buttons.add(tmp); tmp.txt=playerB_backg; tmp.back=playerB_color;tmp.strokW=1; players.add(tmp);
  tmp=new WrUniqTextButton(players.list,"player A2",50*Xsc,0*Ysc,90*Xsc,20*Ysc,"A2",0); buttons.add(tmp);tmp.txt=playerA_backg; tmp.back=playerA_color;tmp.strokW=1; players.add(tmp);
  tmp=new WrUniqTextButton(players.list,"player B2",50*Xsc,30*Ysc,90*Xsc,50*Ysc,"B2",0); buttons.add(tmp);tmp.txt=playerB_backg; tmp.back=playerB_color;tmp.strokW=1; players.add(tmp);
  
  //Boisko
  color out_color=color(250,150,150);
  color in_color=color(150,150,250);
  color outL_color=color(210,130,130);
  color inL_color=color(170,170,255);
  
  courtT = new Panel(120*Xsc,10*Ysc,220*Xsc,160*Ysc); viAreas.add(courtT);
  default_text_corner_radius=0;
  
  tmp=new WrUniqTextButton(courtT.list,"x6",0*Xsc,0*Ysc,30*Xsc,10*Ysc,"x6",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"x5",30*Xsc,0*Ysc,50*Xsc,10*Ysc,"x5",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"z5",50*Xsc,0*Ysc,70*Xsc,10*Ysc,"z5",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"z6",70*Xsc,0*Ysc,100*Xsc,10*Ysc,"z6",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  
  tmp=new WrUniqTextButton(courtT.list,"a7x",0*Xsc,10*Ysc,10*Xsc,50*Ysc,"a7x",1);buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"x4",10*Xsc,10*Ysc,20*Xsc,30*Ysc,"x4",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"x3",20*Xsc,10*Ysc,30*Xsc,30*Ysc,"x3",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"x2",30*Xsc,10*Ysc,40*Xsc,30*Ysc,"x2",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"x1",40*Xsc,10*Ysc,50*Xsc,30*Ysc,"x1",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"z1",50*Xsc,10*Ysc,60*Xsc,30*Ysc,"z1",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"z2",60*Xsc,10*Ysc,70*Xsc,30*Ysc,"z2",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"z3",70*Xsc,10*Ysc,80*Xsc,30*Ysc,"z3",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"z4",80*Xsc,10*Ysc,90*Xsc,30*Ysc,"z4",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s6x",90*Xsc,10*Ysc,100*Xsc,50*Ysc,"s6x",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  
  tmp=new WrUniqTextButton(courtT.list,"a7",10*Xsc,30*Ysc,20*Xsc,50*Ysc,"a7",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a8",20*Xsc,30*Ysc,40*Xsc,50*Ysc,"a8",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp); 
  tmp=new WrUniqTextButton(courtT.list,"a9",40*Xsc,30*Ysc,50*Xsc,50*Ysc,"a9",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  
  tmp=new WrUniqTextButton(courtT.list,"s8",50*Xsc,30*Ysc,60*Xsc,50*Ysc,"s8",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s7",60*Xsc,30*Ysc,80*Xsc,50*Ysc,"s7",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s6",80*Xsc,30*Ysc,90*Xsc,50*Ysc,"s6",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);

  tmp=new WrUniqTextButton(courtT.list,"a4x",0*Xsc,50*Ysc,10*Xsc,70*Ysc,"a4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a4",10*Xsc,50*Ysc,20*Xsc,70*Ysc,"a4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a5",20*Xsc,50*Ysc,40*Xsc,70*Ysc,"a5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a6",40*Xsc,50*Ysc,50*Xsc,70*Ysc,"a6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s6",50*Xsc,50*Ysc,60*Xsc,70*Ysc,"s6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s5",60*Xsc,50*Ysc,80*Xsc,70*Ysc,"s5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s4",80*Xsc,50*Ysc,90*Xsc,70*Ysc,"s4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s4x",90*Xsc,50*Ysc,100*Xsc,70*Ysc,"s4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);  
 
   
  tmp=new WrUniqTextButton(courtT.list,"a1x",0*Xsc,70*Ysc,10*Xsc,90*Ysc,"a1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a1",10*Xsc,70*Ysc,20*Xsc,90*Ysc,"a1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a2",20*Xsc,70*Ysc,40*Xsc,90*Ysc,"a2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"a3",40*Xsc,70*Ysc,50*Xsc,90*Ysc,"a3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s3",50*Xsc,70*Ysc,60*Xsc,90*Ysc,"s3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s2",60*Xsc,70*Ysc,80*Xsc,90*Ysc,"s2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s1",80*Xsc,70*Ysc,90*Xsc,90*Ysc,"s1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"s1x",90*Xsc,70*Ysc,100*Xsc,90*Ysc,"s1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);  

  tmp=new WrUniqTextButton(courtT.list,"q7x",0*Xsc,90*Ysc,10*Xsc,110*Ysc,"q7x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q7",10*Xsc,90*Ysc,20*Xsc,110*Ysc,"q7",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q8",20*Xsc,90*Ysc,40*Xsc,110*Ysc,"q8",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q9",40*Xsc,90*Ysc,50*Xsc,110*Ysc,"q9",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w9",50*Xsc,90*Ysc,60*Xsc,110*Ysc,"w9",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w8",60*Xsc,90*Ysc,80*Xsc,110*Ysc,"w8",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w7",80*Xsc,90*Ysc,90*Xsc,110*Ysc,"w7",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w7x",90*Xsc,90*Ysc,100*Xsc,110*Ysc,"w7x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);  
    
  tmp=new WrUniqTextButton(courtT.list,"q4x",0*Xsc,110*Ysc,10*Xsc,130*Ysc,"q4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q4",10*Xsc,110*Ysc,20*Xsc,130*Ysc,"q4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q5",20*Xsc,110*Ysc,40*Xsc,130*Ysc,"q5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q6",40*Xsc,110*Ysc,50*Xsc,130*Ysc,"q6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w6",50*Xsc,110*Ysc,60*Xsc,130*Ysc,"w6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w5",60*Xsc,110*Ysc,80*Xsc,130*Ysc,"w5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w4",80*Xsc,110*Ysc,90*Xsc,130*Ysc,"w4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w4x",90*Xsc,110*Ysc,100*Xsc,130*Ysc,"w4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);   
   
  tmp=new WrUniqTextButton(courtT.list,"q1x",0*Xsc,130*Ysc,10*Xsc,150*Ysc,"q1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q1",10*Xsc,130*Ysc,20*Xsc,150*Ysc,"q1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q2",20*Xsc,130*Ysc,40*Xsc,150*Ysc,"q2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"q3",40*Xsc,130*Ysc,50*Xsc,150*Ysc,"q3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w3",50*Xsc,130*Ysc,60*Xsc,150*Ysc,"w3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w2",60*Xsc,130*Ysc,80*Xsc,150*Ysc,"w2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w1",80*Xsc,130*Ysc,90*Xsc,150*Ysc,"w1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT.list,"w1x",90*Xsc,130*Ysc,100*Xsc,150*Ysc,"w1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp); 
  
  
  //Tu miejsce na siate, ale siata musi być wcześniej na liście ze względu na porządek kolumn
  //tmp=new TextButton("Net",250*Xsc,160*Ysc,350*Xsc,170*Ysc);buttons.add(tmp);tmp.strokW=1; //court?.add(tmp); 
  courtB = new Panel(120*Xsc,170*Ysc,220*Xsc,320*Ysc); viAreas.add(courtB);
  
  tmp=new WrUniqTextButton(courtB.list,"w1x",0*Xsc,0*Ysc,10*Xsc,20*Ysc,"w1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w1",10*Xsc,0*Ysc,20*Xsc,20*Ysc,"w1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w2",20*Xsc,0*Ysc,40*Xsc,20*Ysc,"w2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w3",40*Xsc,0*Ysc,50*Xsc,20*Ysc,"w3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q3",50*Xsc,0*Ysc,60*Xsc,20*Ysc,"q3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q2",60*Xsc,0*Ysc,80*Xsc,20*Ysc,"q2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q1",80*Xsc,0*Ysc,90*Xsc,20*Ysc,"q1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q1x",90*Xsc,0*Ysc,100*Xsc,20*Ysc,"q1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
 
  tmp=new WrUniqTextButton(courtB.list,"w4x",0*Xsc,20*Ysc,10*Xsc,40*Ysc,"w4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w4",10*Xsc,20*Ysc,20*Xsc,40*Ysc,"w4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w5",20*Xsc,20*Ysc,40*Xsc,40*Ysc,"w5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w6",40*Xsc,20*Ysc,50*Xsc,40*Ysc,"w6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q6",50*Xsc,20*Ysc,60*Xsc,40*Ysc,"q6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q5",60*Xsc,20*Ysc,80*Xsc,40*Ysc,"q5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q4",80*Xsc,20*Ysc,90*Xsc,40*Ysc,"q4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q4x",90*Xsc,20*Ysc,100*Xsc,40*Ysc,"q4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
   
  tmp=new WrUniqTextButton(courtB.list,"w7x",0*Xsc,40*Ysc,10*Xsc,60*Ysc,"w7x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w7",10*Xsc,40*Ysc,20*Xsc,60*Ysc,"w7",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w8",20*Xsc,40*Ysc,40*Xsc,60*Ysc,"w8",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"w9",40*Xsc,40*Ysc,50*Xsc,60*Ysc,"w9",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q9",50*Xsc,40*Ysc,60*Xsc,60*Ysc,"q9",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q8",60*Xsc,40*Ysc,80*Xsc,60*Ysc,"q8",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q7",80*Xsc,40*Ysc,90*Xsc,60*Ysc,"q7",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"q7x",90*Xsc,40*Ysc,100*Xsc,60*Ysc,"q7x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp); 
  
  tmp=new WrUniqTextButton(courtB.list,"s1x",0*Xsc,60*Ysc,10*Xsc,80*Ysc,"s1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s1",10*Xsc,60*Ysc,20*Xsc,80*Ysc,"s1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s2",20*Xsc,60*Ysc,40*Xsc,80*Ysc,"s2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s3",40*Xsc,60*Ysc,50*Xsc,80*Ysc,"s3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a3",50*Xsc,60*Ysc,60*Xsc,80*Ysc,"a3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a2",60*Xsc,60*Ysc,80*Xsc,80*Ysc,"a2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a1",80*Xsc,60*Ysc,90*Xsc,80*Ysc,"a1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a1x",90*Xsc,60*Ysc,100*Xsc,80*Ysc,"a1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  
  tmp=new WrUniqTextButton(courtB.list,"s4x",0*Xsc,80*Ysc,10*Xsc,100*Ysc,"s4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s4",10*Xsc,80*Ysc,20*Xsc,100*Ysc,"s4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s5",20*Xsc,80*Ysc,40*Xsc,100*Ysc,"s5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s6",40*Xsc,80*Ysc,50*Xsc,100*Ysc,"s6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a6",50*Xsc,80*Ysc,60*Xsc,100*Ysc,"a6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a5",60*Xsc,80*Ysc,80*Xsc,100*Ysc,"a5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a4",80*Xsc,80*Ysc,90*Xsc,100*Ysc,"a4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a4x",90*Xsc,80*Ysc,100*Xsc,100*Ysc,"a4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  
  /* Obszar lini koĹ„cowej*/
  
  tmp=new WrUniqTextButton(courtB.list,"s7",10*Xsc,100*Ysc,20*Xsc,120*Ysc,"s7",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s8",20*Xsc,100*Ysc,40*Xsc,120*Ysc,"s8",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"s9",40*Xsc,100*Ysc,50*Xsc,120*Ysc,"s9",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a9",50*Xsc,100*Ysc,60*Xsc,120*Ysc,"a9",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a8",60*Xsc,100*Ysc,80*Xsc,120*Ysc,"a8",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a7",80*Xsc,100*Ysc,90*Xsc,120*Ysc,"a7",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
 
  tmp=new WrUniqTextButton(courtB.list,"s7x",0*Xsc,100*Ysc,10*Xsc,140*Ysc,"s7x",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"z4",10*Xsc,120*Ysc,20*Xsc,140*Ysc,"z4",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"z3",20*Xsc,120*Ysc,30*Xsc,140*Ysc,"z3",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"z2",30*Xsc,120*Ysc,40*Xsc,140*Ysc,"z2",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"z1",40*Xsc,120*Ysc,50*Xsc,140*Ysc,"z1",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"x1",50*Xsc,120*Ysc,60*Xsc,140*Ysc,"x1",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"x2",60*Xsc,120*Ysc,70*Xsc,140*Ysc,"x2",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"x3",70*Xsc,120*Ysc,80*Xsc,140*Ysc,"x3",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"x4",80*Xsc,120*Ysc,90*Xsc,140*Ysc,"x4",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"a7x",90*Xsc,100*Ysc,100*Xsc,140*Ysc,"a7x",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  
  tmp=new WrUniqTextButton(courtB.list,"z6",0*Xsc,140*Ysc,30*Xsc,150*Ysc,"z6",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"z5",30*Xsc,140*Ysc,50*Xsc,150*Ysc,"z5",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"x5",50*Xsc,140*Ysc,70*Xsc,150*Ysc,"x5",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB.list,"x6",70*Xsc,140*Ysc,100*Xsc,150*Ysc,"x6",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  
 
  //Końcowe  
  validation("hello.txt");
 
  /* 
  //tmp=new TextButton("TV placeholder",10*Xsc,10*Ysc,210*Xsc,140*Ysc); tmp.back=color(210,210,255);buttons.add(tmp); //na razie nieistotne
  tmp=new TextButton(" TV ",0,0,10*Xsc,10*Ysc); tmp.back=color(210,210,255);tmp.strokW=0;buttons.add(tmp); //na razie nieistotne
  tint(255, 50);  // Apply transparency without changing color
 
  photo = loadImage("Puchar.jpg");
  if(photo == null || photo.width<=0 || photo.height<=0 )
        {
          println("Wadliwa grafika");
          exit();
        }
  imageMode(CORNERS);
  image(photo, 10*Xsc,10*Ysc,210*Xsc,140*Ysc);  // Draw image using CORNERS mode. Niestety zaokraglenie rogów nie jest proste
  viAreas.add( new RectArea(10*Xsc,10*Ysc,210*Xsc,140*Ysc) );
  */
  
  tmp=( new TextButton("quit",150*Xsc,330*Ysc,200*Xsc,350*Ysc) {
             public void flip_state(boolean visual){exit();} //Nakładka metody robiąca wyjście z programu             
             } );
  tmp.back=color(255,0,0); buttons.add(tmp);//Button QUIT
  
  tmp=NextLnButton=new TextButton("next",10*Xsc,270*Ysc,100*Xsc,320*Ysc); tmp.back=color(255,0,100); buttons.add(tmp); viAreas.add(tmp); //Button NEXT ma specjalne znaczenie

  //Pierwsze wyświetlanie
  view_all();
  
  //Otwarcie pliku i zapis kolumn
  // Create a new file in the program directory
  String FileName="Rec_"+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second()+"_"+millis()+".dat";
  output = createWriter(FileName); 
  //Kolumny specjalne
  output.print("TimeStamp"+"\t");
  for(String str : columnNames)
    output.print(str+"\t");
  //Kolumny binarne
  for (TextButton button : buttons) 
    output.print(button.title+"\t");
 
  output.println();
  output.flush();
}

void view_all()
{
  for( RectArea area: viAreas)   //Lista obszarów do wyświetlania
  {
    area.view();
  }
}

/* TESTY
 int x1,y1,x2,y2;
  
  x1=width/2-iniTxSize*2;
  x2=width/2+iniTxSize*2;
  y1=height/2-iniTxSize;
  y2=height/2+iniTxSize;
  
  fill(0);
  rectMode(CORNERS);
  rect(x1,y1,x2,y2);
  fill(255,0,0);  // Set fill to red
  String title="wraped";
  textAlign(CENTER, CENTER);
  text(title,x1,y1,x2,y2);
  
  fill(255);  // Set fill to white
  rectMode(CENTER);  // Set rectMode to CENTER
  text((String)"center?",(x1+x2)/2,(y1+y2)/2,iniTxSize*4,iniTxSize*2); 
*/
