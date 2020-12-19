static int iniWidth=360;
static int iniHeight=330;
static int iniGrayBackground=128;

int iniTxSize=8;
float Xsc=1.0;//Jeśli ekran jest mniejszy lub większy od domyślnego 360x320
float Ysc=1.0;//To współrzędne "buttonów" trzeba przemnożyć 

class TextButton
{
  int x1,y1,x2,y2;
  String title;
  protected int state;
  color txt,back,strok;
  int strokW;
  int txtSiz;
  
  TextButton(String iTitle,float iX1,float iY1,float iX2,float iY2)
  {
    state=0; 
    txt=color(255,255,255); back=color(0,0,0);
    strok=color(100,100,100); strokW=3;
    title=iTitle; 
    txtSiz=iniTxSize; //Trochę to chmmm...
    if(iX1<iX2) { x1=round(iX1);x2=round(iX2);}
      else {x1=round(iX2);x2=round(iX1);}
    if(iY1<iY2) { y1=round(iY1);y2=round(iY2);}
      else {y1=round(iY2);y2=round(iY1);}
    //println(x1+" "+y1+" "+x2+" "+y2);
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
        rect(x1,y1,x2,y2);
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
        rect(x1,y1,x2,y2);
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
 
  boolean hitted(int x,int y)
  {
    return x1<=x && x<=x2
        && y1<=y && y<=y2;
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

ArrayList<String> columnNames = new ArrayList<String>(); 
String[] columnValues = null;
ArrayList<TextButton> buttons = new ArrayList<TextButton>();   //Lista buttonów
//Listy wykluczeń
ArrayList<TextButton> courtT   = new ArrayList<TextButton>();//Przyciski kortu/boiska
ArrayList<TextButton> courtB   = new ArrayList<TextButton>();//Przyciski kortu/boiska
ArrayList<TextButton> serves = new ArrayList<TextButton>();  //Przyciski zagrywek
ArrayList<TextButton> players = new ArrayList<TextButton>(); //Zawodnicy też się wykluczają
StateLabel Exch,PktA,PktB,GemA,GemB,SetA,SetB;//Uchwyty do liczników punktów używane w nadpisanych akcjach przycisków punktowych
  
TextButton NextLnButton = null; //Button NEXT ma specjalne znaczenie bo jest z nim związana cala akcja zapisywania
int NextLnCount=0;              //Zliczanie kolejnych nextów
PrintWriter output;             //Plik tekstowy zrobiony jako "tab delimited" żeby był wczytywalny do excela
    

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
  text("  TENIS: Programmed by Wojciech BORKOWSKI <wborkowsk@gmail.com>. Prerelase version for Iwona PILCHOWSKA <ipilchowska@gmail.com>",0,0,width,10*Ysc); 
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
  //size(iniWidth*3, iniHeight*2);
  size(iniWidth*4, displayHeight);//displayWidth
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
    
  //Musi być zaraz za kolumnami zbiorczymi, więc pierwsza na liście przycisków
  TextButton tmp=new TextButton("Net",250*Xsc,160*Ysc,350*Xsc,170*Ysc);buttons.add(tmp);tmp.strokW=1; //courtT.add(tmp); 
  
  //Blok logiki zliczania punktów 
  tmp=PktA=new StateLabel(0,"PktA",153*Xsc,230*Ysc,173*Xsc,250*Ysc); buttons.add(tmp);
  tmp=PktB=new StateLabel(0,"PktB",177*Xsc,230*Ysc,197*Xsc,250*Ysc); buttons.add(tmp);
  tmp=GemA=new StateLabel(0,"GemA",153*Xsc,260*Ysc,173*Xsc,280*Ysc); buttons.add(tmp);
  tmp=GemB=new StateLabel(0,"GemB",177*Xsc,260*Ysc,197*Xsc,280*Ysc); buttons.add(tmp);
  tmp=SetA=new StateLabel(0,"SemA",153*Xsc,290*Ysc,173*Xsc,310*Ysc); buttons.add(tmp);
  tmp=SetB=new StateLabel(0,"SemB",177*Xsc,290*Ysc,197*Xsc,310*Ysc); buttons.add(tmp);
  //i wymian
  tmp=Exch=new StateLabel(0,"exchange",105*Xsc,160*Ysc,120*Xsc,180*Ysc); buttons.add(tmp);

  StateLabelInc  incPktA,incPktB,incGemA,incGemB,incSetA,incSetB;//Uchwyty do inkrementatorów
  tmp=incPktA=new StateLabelInc("pktA",110*Xsc,230*Ysc,150*Xsc,250*Ysc,PktA,null); buttons.add(tmp);  
  tmp=incPktB=new StateLabelInc("pktB",200*Xsc,230*Ysc,240*Xsc,250*Ysc,PktB,null); buttons.add(tmp);
  tmp=incGemA=new StateLabelInc("gemA",110*Xsc,260*Ysc,150*Xsc,280*Ysc,GemA,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();
                  }}; buttons.add(tmp);
  tmp=incGemB=new StateLabelInc("gemB",200*Xsc,260*Ysc,240*Xsc,280*Ysc,GemB,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();
                  }}; buttons.add(tmp); 
  tmp=incSetA=new StateLabelInc("setA",110*Xsc,290*Ysc,150*Xsc,310*Ysc,SetA,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();GemA.allow();GemB.allow();
                  }}; buttons.add(tmp);
  tmp=incSetB=new StateLabelInc("setB",200*Xsc,290*Ysc,240*Xsc,310*Ysc,SetB,null){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);PktA.allow();PktB.allow();GemA.allow();GemB.allow();
                  }}; buttons.add(tmp);   
  incPktA.opponent=incPktB;
  incPktB.opponent=incPktA;
  incGemA.opponent=incGemB;
  incGemB.opponent=incGemA;
  incSetA.opponent=incSetB;
  incSetB.opponent=incSetA;

  //Pierwsza kolumna przycisków
  tmp=new WrUniqTextButton(serves,"servis",10*Xsc,160*Ysc,50*Xsc,180*Ysc,"srv",3){ public void flip_state(boolean visual){ //Nakładka metody 
                  super.flip_state(visual);Exch.allow();Exch.set_state(0,true); 
  }}; buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves,"smecz",60*Xsc,160*Ysc,100*Xsc,180*Ysc,"sme",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves,"FH",10*Xsc,190*Ysc,50*Xsc,210*Ysc,"FH",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves,"BH",60*Xsc,190*Ysc,100*Xsc,210*Ysc,"BH",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves,"W-FH",10*Xsc,220*Ysc,50*Xsc,240*Ysc,"W-FH",3); buttons.add(tmp);serves.add(tmp);
  tmp=new WrUniqTextButton(serves,"W-BH",60*Xsc,220*Ysc,100*Xsc,240*Ysc,"W-BH",3); buttons.add(tmp);serves.add(tmp);  
  
  //Zawodnicy
  color playerA_backg=color(0,200,0);
  color playerA_color=color(250,250,0);
  color playerB_backg=color(0,150,0);
  color playerB_color=color(200,200,0);
  tmp=new WrUniqTextButton(players,"player A",130*Xsc,160*Ysc,170*Xsc,180*Ysc,"A",0); buttons.add(tmp); tmp.txt=playerA_backg; tmp.back=playerA_color;tmp.strokW=1; players.add(tmp);
  tmp=new WrUniqTextButton(players,"player B",130*Xsc,190*Ysc,170*Xsc,210*Ysc,"B",0); buttons.add(tmp); tmp.txt=playerB_backg; tmp.back=playerB_color;tmp.strokW=1; players.add(tmp);
  tmp=new WrUniqTextButton(players,"player A2",180*Xsc,160*Ysc,220*Xsc,180*Ysc,"A2",0); buttons.add(tmp);tmp.txt=playerA_backg; tmp.back=playerA_color;tmp.strokW=1; players.add(tmp);
  tmp=new WrUniqTextButton(players,"player B2",180*Xsc,190*Ysc,220*Xsc,210*Ysc,"B2",0); buttons.add(tmp);tmp.txt=playerB_backg; tmp.back=playerB_color;tmp.strokW=1; players.add(tmp);
  
  //Boisko
  color out_color=color(250,150,150);
  color in_color=color(150,150,250);
  color outL_color=color(210,130,130);
  color inL_color=color(170,170,255);
  tmp=new WrUniqTextButton(courtT,"x6",250*Xsc,10*Ysc,280*Xsc,20*Ysc,"x6",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"x5",280*Xsc,10*Ysc,300*Xsc,20*Ysc,"x5",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"z5",300*Xsc,10*Ysc,320*Xsc,20*Ysc,"z5",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"z6",320*Xsc,10*Ysc,350*Xsc,20*Ysc,"z6",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  
  tmp=new WrUniqTextButton(courtT,"a7x",250*Xsc,20*Ysc,260*Xsc,60*Ysc,"a7x",1);buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"x4",260*Xsc,20*Ysc,270*Xsc,40*Ysc,"x4",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"x3",270*Xsc,20*Ysc,280*Xsc,40*Ysc,"x3",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"x2",280*Xsc,20*Ysc,290*Xsc,40*Ysc,"x2",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"x1",290*Xsc,20*Ysc,300*Xsc,40*Ysc,"x1",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"z1",300*Xsc,20*Ysc,310*Xsc,40*Ysc,"z1",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"z2",310*Xsc,20*Ysc,320*Xsc,40*Ysc,"z2",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"z3",320*Xsc,20*Ysc,330*Xsc,40*Ysc,"z3",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"z4",330*Xsc,20*Ysc,340*Xsc,40*Ysc,"z4",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s6x",340*Xsc,20*Ysc,350*Xsc,60*Ysc,"s6x",1); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtT.add(tmp);
  
  tmp=new WrUniqTextButton(courtT,"a7",260*Xsc,40*Ysc,270*Xsc,60*Ysc,"a7",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a8",270*Xsc,40*Ysc,290*Xsc,60*Ysc,"a8",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp); 
  tmp=new WrUniqTextButton(courtT,"a9",290*Xsc,40*Ysc,300*Xsc,60*Ysc,"a9",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  
  tmp=new WrUniqTextButton(courtT,"s8",300*Xsc,40*Ysc,310*Xsc,60*Ysc,"s8",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s7",310*Xsc,40*Ysc,330*Xsc,60*Ysc,"s7",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s6",330*Xsc,40*Ysc,340*Xsc,60*Ysc,"s6",1); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtT.add(tmp);

  tmp=new WrUniqTextButton(courtT,"a4x",250*Xsc,60*Ysc,260*Xsc,80*Ysc,"a4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a4",260*Xsc,60*Ysc,270*Xsc,80*Ysc,"a4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a5",270*Xsc,60*Ysc,290*Xsc,80*Ysc,"a5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a6",290*Xsc,60*Ysc,300*Xsc,80*Ysc,"a6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s6",300*Xsc,60*Ysc,310*Xsc,80*Ysc,"s6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s5",310*Xsc,60*Ysc,330*Xsc,80*Ysc,"s5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s4",330*Xsc,60*Ysc,340*Xsc,80*Ysc,"s4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s4x",340*Xsc,60*Ysc,350*Xsc,80*Ysc,"s4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);  
 
   
  tmp=new WrUniqTextButton(courtT,"a1x",250*Xsc,80*Ysc,260*Xsc,100*Ysc,"a1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a1",260*Xsc,80*Ysc,270*Xsc,100*Ysc,"a1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a2",270*Xsc,80*Ysc,290*Xsc,100*Ysc,"a2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"a3",290*Xsc,80*Ysc,300*Xsc,100*Ysc,"a3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s3",300*Xsc,80*Ysc,310*Xsc,100*Ysc,"s3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s2",310*Xsc,80*Ysc,330*Xsc,100*Ysc,"s2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s1",330*Xsc,80*Ysc,340*Xsc,100*Ysc,"s1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"s1x",340*Xsc,80*Ysc,350*Xsc,100*Ysc,"s1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);  

  tmp=new WrUniqTextButton(courtT,"q7x",250*Xsc,100*Ysc,260*Xsc,120*Ysc,"q7x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q7",260*Xsc,100*Ysc,270*Xsc,120*Ysc,"q7",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q8",270*Xsc,100*Ysc,290*Xsc,120*Ysc,"q8",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q9",290*Xsc,100*Ysc,300*Xsc,120*Ysc,"q9",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w9",300*Xsc,100*Ysc,310*Xsc,120*Ysc,"w9",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w8",310*Xsc,100*Ysc,330*Xsc,120*Ysc,"w8",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w7",330*Xsc,100*Ysc,340*Xsc,120*Ysc,"w7",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w7x",340*Xsc,100*Ysc,350*Xsc,120*Ysc,"w7x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);  
    
  tmp=new WrUniqTextButton(courtT,"q4x",250*Xsc,120*Ysc,260*Xsc,140*Ysc,"q4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q4",260*Xsc,120*Ysc,270*Xsc,140*Ysc,"q4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q5",270*Xsc,120*Ysc,290*Xsc,140*Ysc,"q5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q6",290*Xsc,120*Ysc,300*Xsc,140*Ysc,"q6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w6",300*Xsc,120*Ysc,310*Xsc,140*Ysc,"w6",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w5",310*Xsc,120*Ysc,330*Xsc,140*Ysc,"w5",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w4",330*Xsc,120*Ysc,340*Xsc,140*Ysc,"w4",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w4x",340*Xsc,120*Ysc,350*Xsc,140*Ysc,"w4x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);   
   
  tmp=new WrUniqTextButton(courtT,"q1x",250*Xsc,140*Ysc,260*Xsc,160*Ysc,"q1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q1",260*Xsc,140*Ysc,270*Xsc,160*Ysc,"q1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q2",270*Xsc,140*Ysc,290*Xsc,160*Ysc,"q2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"q3",290*Xsc,140*Ysc,300*Xsc,160*Ysc,"q3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w3",300*Xsc,140*Ysc,310*Xsc,160*Ysc,"w3",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w2",310*Xsc,140*Ysc,330*Xsc,160*Ysc,"w2",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w1",330*Xsc,140*Ysc,340*Xsc,160*Ysc,"w1",1); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtT.add(tmp);
  tmp=new WrUniqTextButton(courtT,"w1x",340*Xsc,140*Ysc,350*Xsc,160*Ysc,"w1x",1); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtT.add(tmp); 
  
  //Tu miejsce na siate, ale siata musi być wcześniej na liście ze względu na porządek kolumn
  //tmp=new TextButton("Net",250*Xsc,160*Ysc,350*Xsc,170*Ysc);buttons.add(tmp);tmp.strokW=1; //courtT.add(tmp); 
 
  tmp=new WrUniqTextButton(courtB,"w1x",250*Xsc,170*Ysc,260*Xsc,190*Ysc,"w1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w1",260*Xsc,170*Ysc,270*Xsc,190*Ysc,"w1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w2",270*Xsc,170*Ysc,290*Xsc,190*Ysc,"w2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w3",290*Xsc,170*Ysc,300*Xsc,190*Ysc,"w3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q3",300*Xsc,170*Ysc,310*Xsc,190*Ysc,"q3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q2",310*Xsc,170*Ysc,330*Xsc,190*Ysc,"q2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q1",330*Xsc,170*Ysc,340*Xsc,190*Ysc,"q1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q1x",340*Xsc,170*Ysc,350*Xsc,190*Ysc,"q1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
 
  tmp=new WrUniqTextButton(courtB,"w4x",250*Xsc,190*Ysc,260*Xsc,210*Ysc,"w4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w4",260*Xsc,190*Ysc,270*Xsc,210*Ysc,"w4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w5",270*Xsc,190*Ysc,290*Xsc,210*Ysc,"w5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w6",290*Xsc,190*Ysc,300*Xsc,210*Ysc,"w6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q6",300*Xsc,190*Ysc,310*Xsc,210*Ysc,"q6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q5",310*Xsc,190*Ysc,330*Xsc,210*Ysc,"q5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q4",330*Xsc,190*Ysc,340*Xsc,210*Ysc,"q4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q4x",340*Xsc,190*Ysc,350*Xsc,210*Ysc,"q4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
   
  tmp=new WrUniqTextButton(courtB,"w7x",250*Xsc,210*Ysc,260*Xsc,230*Ysc,"w7x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w7",260*Xsc,210*Ysc,270*Xsc,230*Ysc,"w7",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w8",270*Xsc,210*Ysc,290*Xsc,230*Ysc,"w8",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"w9",290*Xsc,210*Ysc,300*Xsc,230*Ysc,"w9",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q9",300*Xsc,210*Ysc,310*Xsc,230*Ysc,"q9",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q8",310*Xsc,210*Ysc,330*Xsc,230*Ysc,"q8",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q7",330*Xsc,210*Ysc,340*Xsc,230*Ysc,"q7",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"q7x",340*Xsc,210*Ysc,350*Xsc,230*Ysc,"q7x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp); 
  
  tmp=new WrUniqTextButton(courtB,"s1x",250*Xsc,230*Ysc,260*Xsc,250*Ysc,"s1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s1",260*Xsc,230*Ysc,270*Xsc,250*Ysc,"s1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s2",270*Xsc,230*Ysc,290*Xsc,250*Ysc,"s2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s3",290*Xsc,230*Ysc,300*Xsc,250*Ysc,"s3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a3",300*Xsc,230*Ysc,310*Xsc,250*Ysc,"a3",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a2",310*Xsc,230*Ysc,330*Xsc,250*Ysc,"a2",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a1",330*Xsc,230*Ysc,340*Xsc,250*Ysc,"a1",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a1x",340*Xsc,230*Ysc,350*Xsc,250*Ysc,"a1x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  
  tmp=new WrUniqTextButton(courtB,"s4x",250*Xsc,250*Ysc,260*Xsc,270*Ysc,"s4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s4",260*Xsc,250*Ysc,270*Xsc,270*Ysc,"s4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s5",270*Xsc,250*Ysc,290*Xsc,270*Ysc,"s5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s6",290*Xsc,250*Ysc,300*Xsc,270*Ysc,"s6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a6",300*Xsc,250*Ysc,310*Xsc,270*Ysc,"a6",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a5",310*Xsc,250*Ysc,330*Xsc,270*Ysc,"a5",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a4",330*Xsc,250*Ysc,340*Xsc,270*Ysc,"a4",2); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a4x",340*Xsc,250*Ysc,350*Xsc,270*Ysc,"a4x",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  
  /* Obszar lini końcowej*/
  
  tmp=new WrUniqTextButton(courtB,"s7",260*Xsc,270*Ysc,270*Xsc,290*Ysc,"s7",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s8",270*Xsc,270*Ysc,290*Xsc,290*Ysc,"s8",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"s9",290*Xsc,270*Ysc,300*Xsc,290*Ysc,"s9",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a9",300*Xsc,270*Ysc,310*Xsc,290*Ysc,"a9",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a8",310*Xsc,270*Ysc,330*Xsc,290*Ysc,"a8",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a7",330*Xsc,270*Ysc,340*Xsc,290*Ysc,"a7",2); buttons.add(tmp); tmp.back=inL_color;tmp.strokW=1; courtB.add(tmp);
 
  tmp=new WrUniqTextButton(courtB,"s7x",250*Xsc,270*Ysc,260*Xsc,310*Ysc,"s7x",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"z4",260*Xsc,290*Ysc,270*Xsc,310*Ysc,"z4",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"z3",270*Xsc,290*Ysc,280*Xsc,310*Ysc,"z3",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"z2",280*Xsc,290*Ysc,290*Xsc,310*Ysc,"z2",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"z1",290*Xsc,290*Ysc,300*Xsc,310*Ysc,"z1",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"x1",300*Xsc,290*Ysc,310*Xsc,310*Ysc,"x1",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"x2",310*Xsc,290*Ysc,320*Xsc,310*Ysc,"x2",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"x3",320*Xsc,290*Ysc,330*Xsc,310*Ysc,"x3",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"x4",330*Xsc,290*Ysc,340*Xsc,310*Ysc,"x4",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"a7x",340*Xsc,270*Ysc,350*Xsc,310*Ysc,"a7x",2); buttons.add(tmp); tmp.back=outL_color;tmp.strokW=1; courtB.add(tmp);
  
  tmp=new WrUniqTextButton(courtB,"z6",250*Xsc,310*Ysc,280*Xsc,320*Ysc,"z6",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"z5",280*Xsc,310*Ysc,300*Xsc,320*Ysc,"z5",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"x5",300*Xsc,310*Ysc,320*Xsc,320*Ysc,"x5",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  tmp=new WrUniqTextButton(courtB,"x6",320*Xsc,310*Ysc,350*Xsc,320*Ysc,"x6",2); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; courtB.add(tmp);
  
  //CR, L,C
  tmp=new TextButton("CR",220*Xsc,10*Ysc,240*Xsc,30*Ysc);buttons.add(tmp); 
  tmp=new TextButton("L",220*Xsc,40*Ysc,240*Xsc,60*Ysc);buttons.add(tmp); 
  tmp=new TextButton("C",220*Xsc,70*Ysc,240*Xsc,90*Ysc);buttons.add(tmp); 
  
  //Końcowe  
  tmp=new TextButton("TV placeholder",10*Xsc,10*Ysc,210*Xsc,140*Ysc); tmp.back=color(210,210,255);buttons.add(tmp); //na razie nieistotne
    
  tmp=( new TextButton("quit",150*Xsc,330*Ysc,200*Xsc,350*Ysc) {
             public void flip_state(boolean visual){exit();} //Nakładka metody robiąca wyjście z programu             
             } );
  tmp.back=color(255,0,0); buttons.add(tmp);//Button QUIT
  
  tmp=NextLnButton=new TextButton("next",10*Xsc,270*Ysc,100*Xsc,320*Ysc); tmp.back=color(255,0,100); buttons.add(tmp);//Button NEXT ma specjalne znaczenie

  //Pierwsze wyświetlanie
  view_all();
  
  //Otwarcie pliku i zapis kolumn
  // Create a new file in the program directory
  String FileName="Rec"+millis()+"_"+minute()+"_"+hour()+"_"+day()+"_"+month()+"_"+year()+".dat";
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
  for (TextButton button : buttons) 
  {
   button.view();
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
