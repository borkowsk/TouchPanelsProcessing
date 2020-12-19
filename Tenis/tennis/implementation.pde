ArrayList<String> columnNames = new ArrayList<String>(); 
String[] columnValues = null;

//Panele związanych przycisków
Panel NextLeft;   //Panel dla dających "NEXT" przycisków KPKR z lewej strony
Panel NextRight;  //Panel dla dających "NEXT" przycisków z prawej strony
Panel points;     //Punktacja
Panel others;     //Wymiany siatka itp inne różne
Panel WPlusMinusNO;//Prawy drugi od góry
Panel FHBHWSm;    //Prawy lekko z lewej - pod punktacją
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

void mousePressed() /// Zdarzenie naciśniecia konkretnego przycisku NEXT wymusza zapis linii pliku danych
{
  //println("Pressed "+mouseX+" x "+mouseY);
  if(NextLnButton.hitted(mouseX,mouseY))
  {
    NextLnButton.set_state(1,true);
    NextLnCount++; //To już kolejna linia
    Exch.allow();Exch.set_state(Exch.state+1,true);
    
    output.print(NextLnCount+"\t");//print(NextLnCount+"\t"); //Jako "TimeStamp"
    
    for(int i=0;i<columnValues.length;i++) //Czyszczenie starej zawartosci kolumn specjalnych
          columnValues[i] = "";            //nie można użyć uproszczonego for(String...) bo String idzie przez wartość i nie ma zmian
          
    FillColumnValues(); //Osobna procedura do wypełniania kolumn specjalnych
    
    for(String str : columnValues) //Jako kolumny specjalne
    {
      output.print(str+"\t");//print(str+"\t");
    }
      
    for (TextButton button : buttons)//Jako kolumny binarne
     if(button!=NextLnButton)
     {
       //TU AKCJA ZAPISYWANIA
       output.print(button.state+"\t");//print(button.state+"\t");
       button.set_state(0,true);
     }
     else
     {
       output.print(NextLnCount+"\t");//print(NextLnCount+"\t");
     }
     
    output.println();//println();
    output.flush();
  }
}
