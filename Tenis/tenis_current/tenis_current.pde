static int iniWidth=360;
static int iniHeight=320;
static int iniGrayBackground=128;

int iniTxSize=8;
float Xsc=1.0;//Jeśli ekran jest mniejszy lub większy od domyślnego 360x320
float Ysc=1.0;//To współrzędne "buttonów" trzeba przemnożyć 

class TextButton
{
  int x1,y1,x2,y2;
  String title;
  int state;
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

ArrayList<TextButton> buttons = new ArrayList<TextButton>();   //Lista buttonów
ArrayList<TextButton> court   = new ArrayList<TextButton>();   //Przyciski kortu/boiska
ArrayList<TextButton> players = new ArrayList<TextButton>();   //Zawodnicy też się wykluczają
TextButton NextLnButton = null; //Button NEXT ma specjalne znaczenie bo jest z nim związana cala akcja zapisywania
int NextLnCount=0;              //Zliczanie kolejnych nextów
PrintWriter output;             //Plik tekstowy zrobiony jako "tab delimited" żeby był wczytywalny do excela

void view_all()
{
  for (TextButton button : buttons) 
  {
   button.view();
  }
}

void mousePressed() 
{
  //println("Pressed "+mouseX+" x "+mouseY);
  if(NextLnButton.hitted(mouseX,mouseY))
  {
    NextLnButton.set_state(1,true);
    NextLnCount++; //To już kolejna linia
    for (TextButton button : buttons)
     if(button!=NextLnButton)
     {
       //TU AKCJA ZAPISYWANIA
       output.print(button.state+"\t");
       button.set_state(0,true);
     }
     
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

void draw() //Żeby działały zdarzenia myszy to musi być chociaż puste draw()!
{
}


void setup()
{
  background(iniGrayBackground);
  size(iniWidth*2, iniHeight*2);
  Xsc=width/iniWidth;
  Ysc=height/iniHeight;
  iniTxSize*=Ysc; //Używane w inicjacjach bittonów

  //Pierwsza kolumna
  TextButton tmp=NextLnButton=new TextButton("next",10*Xsc,290*Ysc,50*Xsc,310*Ysc); tmp.back=color(255,0,100); buttons.add(tmp);//Button NEXT ma specjalne znaczenie
  tmp=new TextButton("serwis",10*Xsc,160*Ysc,50*Xsc,180*Ysc); buttons.add(tmp);
  //Zawodnicy
  color player_backg=color(0,255,0);
  color player_color=color(255,255,0);
  tmp=new UniqTextButton(players,"player A",130*Xsc,160*Ysc,170*Xsc,180*Ysc); buttons.add(tmp); tmp.txt=player_backg; tmp.back=player_color;tmp.strokW=1; players.add(tmp);
  tmp=new UniqTextButton(players,"player B",130*Xsc,190*Ysc,170*Xsc,210*Ysc); buttons.add(tmp); tmp.txt=player_backg; tmp.back=player_color;tmp.strokW=1; players.add(tmp);
  tmp=new UniqTextButton(players,"player A2",180*Xsc,160*Ysc,220*Xsc,180*Ysc); buttons.add(tmp);tmp.txt=player_backg; tmp.back=player_color;tmp.strokW=1; players.add(tmp);
  tmp=new UniqTextButton(players,"player B2",180*Xsc,190*Ysc,220*Xsc,210*Ysc); buttons.add(tmp);tmp.txt=player_backg; tmp.back=player_color;tmp.strokW=1; players.add(tmp);
  
  //Boisko
  color out_color=color(250,150,150);
  color in_color=color(150,150,250);
  tmp=new UniqTextButton(court,"x6",250*Xsc,10*Ysc,280*Xsc,20*Ysc); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"x5",280*Xsc,10*Ysc,300*Xsc,20*Ysc); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"z5",300*Xsc,10*Ysc,320*Xsc,20*Ysc); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"z6",320*Xsc,10*Ysc,350*Xsc,20*Ysc); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"ax7",250*Xsc,20*Ysc,260*Xsc,40*Ysc);buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"x4",260*Xsc,20*Ysc,270*Xsc,30*Ysc); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"x3",270*Xsc,20*Ysc,280*Xsc,30*Ysc); buttons.add(tmp); tmp.back=out_color;tmp.strokW=1; court.add(tmp);
  //...
  tmp=new UniqTextButton(court,"a7",260*Xsc,30*Ysc,270*Xsc,40*Ysc); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"a8",270*Xsc,30*Ysc,290*Xsc,40*Ysc); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; court.add(tmp);
  tmp=new UniqTextButton(court,"a9",290*Xsc,30*Ysc,300*Xsc,40*Ysc); buttons.add(tmp); tmp.back=in_color;tmp.strokW=1; court.add(tmp);
  
  //Końcowe, na razie nieistotne
  tmp=new TextButton("TV placeholder",10*Xsc,10*Ysc,230*Xsc,140*Ysc); tmp.back=color(210,210,255);buttons.add(tmp);
  tmp=new TextButton("Net-ERROR",300*Xsc,290*Ysc,350*Xsc,310*Ysc);tmp.state=1;buttons.add(tmp);
  
  //Pierwsze wyświetlanie
  view_all();
  
  //Otwarcie pliku i zapis kolumn
  // Create a new file in the program directory
  String FileName="Rec"+millis()+"_"+minute()+"_"+hour()+"_"+day()+"_"+month()+"_"+year()+".dat";
  output = createWriter(FileName); 
  for (TextButton button : buttons) 
  {
    output.print(button.title+"\t");
  }
  output.println();
  output.flush();
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
