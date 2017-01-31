
import java.util.Collections;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import processing.core.*; 

public class ColourChooser { 

  boolean reset = true; 
  int[] colours = new int[12]; // stores int for actual RGB colours
  int[] pensRemainingByColour = new int[12]; 
  int[] pensUsedByColour = new int[12]; 
  String[] colourNames = new String[12]; 

  //int totalNumberPerColour = 0; 

  ArrayList<Integer> chosenColours; 

  //int totalPenCount = 0;
  int selectionCount = 0; 

  PApplet p5; 

  public ColourChooser(PApplet processing) {
    p5 = processing; 
    colours[0] = 0xFF4DD6; // pink
    colours[1] = 0xDE2B30;   // red
    colours[2] = 0xA05C2F;  // light brown
    colours[3] = 0x5A371F;  // dark brown
    colours[4] = 0x338149;  // dark green 
    colours[5] = 0x45C953;  // light green 
    colours[6] = 0xFFE72E ; // yellow
    colours[7] = 0xFF8B17 ; // orange
    colours[8] = 0x6522AF ; // purple
    colours[9] = 0x293FB2 ; // navy blue
    colours[10] = 0x6FC6FF ; // sky blue
    colours[11] = 0x000000 ; // black

    colourNames[0] = "pink"; 
    colourNames[1] = "red"; 
    colourNames[2] = "light brown"; 
    colourNames[3] = "dark brown"; 
    colourNames[4] = "dark green"; 
    colourNames[5] = "light green"; 
    colourNames[6] = "yellow"; 
    colourNames[7] = "orange"; 
    colourNames[8] = "purple"; 
    colourNames[9] = "navy blue"; 
    colourNames[10] = "sky blue"; 
    colourNames[11] = "black"; 

    // Add FF as the alpha value for colours
    for (int i = 0; i<colours.length; i++) colours[i]|=0xff000000;
    loadData();
  }

  public void addPens(int numPerColour) {
    for (int i = 0; i<pensRemainingByColour.length; i++) pensRemainingByColour[i]+=numPerColour;
    saveData();
  }


  public void saveData() {
    p5.println("saveData()"); 
    p5.saveStrings("data/PensRemaining.txt", p5.str(pensRemainingByColour));
    p5.saveStrings("data/PensUsed.txt", p5.str(pensUsedByColour));
    p5.saveStrings("data/SelectionCount.txt", p5.split(p5.str(selectionCount), ",")); 
    // is this needed? 
    if(chosenColours!=null) { 
      String[] chosenColoursString = new String[chosenColours.size()]; 
      for (int i = 0; i<chosenColours.size(); i++) chosenColoursString[i] = p5.nf(chosenColours.get(i)); 
      p5.saveStrings("data/CurrentSelection.txt", chosenColoursString);
    }
  }
  public void loadData() { 

    String[] pensRemainingByColourStrings = p5.loadStrings("data/PensRemaining.txt");
    if (pensRemainingByColourStrings==null) {
      addPens(24);
      
      reset = true;
    } else { 
      for (int i = 0; i<pensRemainingByColourStrings.length && i<pensRemainingByColour.length; i++) { 
        pensRemainingByColour[i] = Integer.parseInt(pensRemainingByColourStrings[i]);
      }
    }
    String[] pensUsedByColourStrings = p5.loadStrings("data/PensUsed.txt");
    if ((pensUsedByColourStrings==null) || (reset)) {
      for (int i= 0; i<11; i++) { 
        pensUsedByColour[i] = 0;
      }
    } else { 
      for (int i = 0; i<pensUsedByColourStrings.length && i<pensUsedByColour.length; i++) { 
        pensUsedByColour[i] = Integer.parseInt(pensUsedByColourStrings[i]);
      }
    }
    String[] selectionCountStrings = p5.loadStrings("data/PensUsed.txt");
    if ((selectionCountStrings == null) || reset) { 
      selectionCount = 0;
    } else { 
      selectionCount = Integer.parseInt(selectionCountStrings[0]);
    }
    String[] chosenColourStrings = p5.loadStrings("data/CurrentSelection.txt");
    if ((selectionCountStrings == null) || reset) { 
      getNextSelection();
    } else { 
      //p5.println(PApplet.parseInt("24")); 
      int[] chosenColourArray =  p5.parseInt(chosenColourStrings);//new Integer[8]; //p5.int("24"); 
      chosenColours = new ArrayList<Integer>(); // (Arrays.asList(chosenColourArray));  
      for (int i = 0; i<chosenColourArray.length; i++) chosenColours.add(chosenColourArray[i]);
    }
  }


  public ArrayList<Integer> getNextSelection() {
    chosenColours = new ArrayList<Integer>();

    if (coloursAvailable()<7) {
      p5.println("adding new box of 288"); 
      addPens(24);
    }


    for (int i = 0; i<7; i++) { 
      int colourindex = (selectionCount+((i+9)*3))%11;    

      //if we've run out of this colour... 
      if (pensRemainingByColour[colourindex]<=1) { 
        // let's figure out what the highest number of the other colours is.. 
        int mostpenscount = 0; 
        for (int j=0; j<11; j++) { 
          if ((!chosenColours.contains(j)) && (pensRemainingByColour[j]>mostpenscount)) mostpenscount = pensRemainingByColour[j];
        }
        p5.println("most pens count = "+mostpenscount); 
        while ((pensRemainingByColour[colourindex]<mostpenscount) || (chosenColours.contains(colourindex))) {

          colourindex=(colourindex+1)%11; 

          /*
          trynextcount++;
           // this should never happen
           if (trynextcount>=10) { 
           p5.println("run out at ", i); 
           //cancelled =true; 
           break;
           }*/
        }
      }
      pensRemainingByColour[colourindex]--; 
      pensUsedByColour[colourindex]++; 

      // totalPenCount--; 


      chosenColours.add(colourindex); 
      //p5.stroke(colours[colourindex]); 
      //float x = (colourindex*15)+10;
      //p5.line(x, y, x, y+10);
    }


    Collections.sort(chosenColours, new ColourComparator());

    int blackpensused = pensUsedByColour[11]; 
    float numberOfSelectionsInPack = (288f-24f)/7f;
    float blackPensPerSelection = 24f/numberOfSelectionsInPack; 
    p5.println("black pens per selection = "+blackPensPerSelection); 
    p5.println(blackPensPerSelection*(float)selectionCount, blackpensused);

    chosenColours.add(11); 

    //if ((blackpensused==0) || (((float)(blackpensused)/(float)selectionCount) < (24f/37f))) {
    if (blackPensPerSelection*(float)selectionCount>=blackpensused) { 
      // TODO MARK NEW BLACK REQUIRED  
      pensRemainingByColour[11]--;
      pensUsedByColour[11]++;
    }
    selectionCount++;
    saveData();
    return chosenColours;
  }

  public int getColourForPenNum(int num) { 

    int colourindex = chosenColours.get(num); 

    return colours[colourindex];
  }

  public String getColourNameForPenNum(int num) { 

    int colourindex = chosenColours.get(num); 

    return colourNames[colourindex];
  }


  public void renderPens(float x, float y, float w, float h) { 
    renderPens(x, y, w, h, false);
  }

  public void renderPens(float x, float y, float w, float h, boolean showColourNames) { 
    p5.pushStyle();
    p5.ellipseMode(p5.RADIUS); 
    float r = p5.min(w, (h-14)/8)/2; 


    p5.strokeWeight(2); 

    for (int i = 0; i<8; i++) { 
      float ypos = p5.map(i, 7, 0, y+r, y+h-r); 
      p5.fill(0); 
      p5.stroke(255); 
      p5.ellipse(x+w/2, ypos, r, r); 
      p5.fill(getColourForPenNum(i)); 
      p5.noStroke();
      p5.ellipse(x+w/2, ypos, r-4, r-4);
      if (showColourNames) { 
        p5.fill(255); 
        p5.textSize(20);
        p5.textAlign(p5.RIGHT, p5.CENTER); 
        p5.text(p5.str(i+1), x-10, ypos);
        p5.textAlign(p5.LEFT, p5.CENTER); 
        p5.text((getColourNameForPenNum(i).toUpperCase()), x+w+10, ypos);
      }
    }
    p5.popStyle();
  }
  /*
  public void chooseColours () { 
   int startColour = 0; 
   
   float y = 10; 
   p5.strokeWeight(7); 
   p5.strokeCap(p5.SQUARE);
   
   boolean cancelled = false; 
   totalPenCount = 132*2; 
   
   while ((totalPenCount-7>0) && (!cancelled)) { 
   p5.strokeWeight(10); 
   
   ArrayList<Integer> chosencolours = new ArrayList<Integer>();
   for (int i = 0; i<7; i++) chosencolours.add(-1);  
   
   for (int i = 0; i<7; i++) { 
   int colourindex = (startColour+((i+9)*3))%11;    
   
   int trynextcount = 0; 
   
   while ((pensRemainingByColour[colourindex]<=0) || (chosencolours.contains(colourindex))) {
   colourindex=(colourindex+1)%11; 
   trynextcount++;
   if (trynextcount>=10) { 
   p5.println("run out at ", i); 
   cancelled =true; 
   break;
   }
   }
   pensRemainingByColour[colourindex]--; 
   
   totalPenCount--; 
   
   
   chosencolours.set(i, colourindex); 
   p5.stroke(colours[colourindex]); 
   float x = (colourindex*15)+10;
   p5.line(x, y, x, y+10);
   }
   Collections.sort(chosencolours, new ColourComparator());
   
   //chosencolours = sort(chosencolours); 
   p5.strokeWeight(21); 
   //if(cancelled) break;
   for (int i = 0; i<7; i++) { 
   if (chosencolours.get(i)<0) continue; 
   float x = (i*28)+200;
   p5.strokeWeight(25); 
   p5.stroke(0);
   p5.line(x, y-2, x, y+17);
   p5.strokeWeight(21); 
   p5.stroke(colours[chosencolours.get(i)]);
   
   p5.line(x, y, x, y+15);
   }
   
   startColour++; 
   y+= 20;
   }
   
   p5.println("total pens left : ", totalPenCount);
   for (int i =0; i<11; i++) { 
   p5.println("colour "+i+" : "+pensRemainingByColour[i]);
   }
   }*/

  public int getColour(int index) { 
    return colours[index];
  }

  public boolean pensAvailable() { 
    return coloursAvailable()>=7;
  }
  public int coloursAvailable() { 
    int count = 0; 
    for (int i = 0; i<pensRemainingByColour.length; i++) { 
      if (pensRemainingByColour[i]>0) count++;
    }
    return count;
  }

  public class ColourComparator implements Comparator<Integer> {


    public int compare(Integer n1, Integer n2) {
      float b1 = p5.brightness(colours[n1]) + p5.saturation(colours[n1]); 
      float b2 = p5.brightness(colours[n2]) + p5.saturation(colours[n1]); 

      return (int)(b1-b2);
    }
  }
}