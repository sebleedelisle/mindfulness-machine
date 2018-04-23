
import java.util.Collections;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import processing.core.*; 

public class ColourChooser { 

  int[] colours = new int[12]; // stores int for actual RGB colours
  String[] colourNames = new String[12]; 

  boolean replaceBlack = true; 
  int currentPenBox = 0 ; 
  int[] pensRemainingByColour = new int[12]; 
  int[] pensUsedByColour = new int[12]; 

  ArrayList<Integer> chosenColours; 

  //int selectionCount = 0; 

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

    getSelectionByNumber(0);
  }

  public void addPenBox() { 
     for (int i = 0; i<11; i++) pensRemainingByColour[i]+=24;
     pensRemainingByColour[11]+=48;
  }
  //public void addPens(int numPerColour) {
  //  for (int i = 0; i<pensRemainingByColour.length; i++) pensRemainingByColour[i]+=numPerColour;
 // }



  public ArrayList<Integer> getSelectionByNumber(int selectionNumber) {
    //p5.println("getSelectionByNumber", selectionNumber);
    pensRemainingByColour = new int[12]; 
    pensUsedByColour = new int[12]; 

    addPenBox();

    currentPenBox = 0; 


    int iteration = 0; 

    //p5.println(iteration, selectionNumber);
    while (iteration<=selectionNumber) { 
      //p5.println(iteration, selectionNumber);
      chosenColours = new ArrayList<Integer>();

      if (coloursAvailable()<7) {
        //p5.println("adding new box of 288"); 
        addPenBox();
        currentPenBox++;
      }

      for (int i = 0; i<7; i++) { 
        int colourindex = (iteration+((i+4)*3))%11;    

        //if we've run out of this colour... 
        if (pensRemainingByColour[colourindex]<=1) { 
          // let's figure out what the highest number of the other colours is.. 
          int mostpenscount = 0; 
          for (int j=0; j<11; j++) { 
            if ((!chosenColours.contains(j)) && (pensRemainingByColour[j]>mostpenscount)) mostpenscount = pensRemainingByColour[j];
          }
          //p5.println("most pens count = "+mostpenscount); 
          while ((pensRemainingByColour[colourindex]<mostpenscount) || (chosenColours.contains(colourindex))) {

            colourindex=(colourindex+1)%11;
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
      iteration++;


      Collections.sort(chosenColours, new ColourComparator());


      int blackpensused = pensUsedByColour[11]; 
      float numberOfSelectionsInPack = (288f-24f)/7f;
      float blackPensPerSelection = 24f/numberOfSelectionsInPack; 
     // p5.println("black pens per selection = "+blackPensPerSelection); 
      //p5.println(blackPensPerSelection*(float)iteration, blackpensused);


      chosenColours.add(11); 

      //if (blackPensPerSelection*(float)iteration>=blackpensused) { 
        replaceBlack= true; 
        pensRemainingByColour[11]--;
        pensUsedByColour[11]++;
      //} else { 
      //  replaceBlack = false;
      //}
    }

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
    renderPens(x, y, w, h, false, false);
  }

  public void renderPens(float x, float y, float w, float h, boolean showColourNames, boolean showRemaining) { 
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
        //p5.textSize(20);
        p5.textAlign(p5.RIGHT, p5.CENTER); 
        p5.text(p5.str(i+1), x-10, ypos);
        p5.textAlign(p5.LEFT, p5.CENTER); 
        String label = getColourNameForPenNum(i).toUpperCase(); 
        if(showRemaining) { 
          int remaining = pensRemainingByColour[chosenColours.get(i)]; 
          label = label + " - ("+remaining+" PEN"+(remaining==1?"":"S")+" LEFT)"; 
        }
        p5.text(label, x+w+10, ypos);
      }
    }
    p5.popStyle();
  }
   public void renderPensSquare(float x, float y, float w, float h, int strokeColour) { 
     
    p5.pushStyle();
    p5.rectMode(p5.CENTER); 
    float r = p5.min(w, (h-14)/8)/2; 

    p5.strokeWeight(1); 

    for (int i = 0; i<8; i++) { 
      float ypos = p5.map(i, 7, 0, y+r, y+h-r); 
      p5.fill(getColourForPenNum(i)); 
      p5.stroke(strokeColour);
     
      p5.rect(x+w/2, ypos, r, r); 
     
    }
    p5.popStyle();
  }

  public int getColour(int index) { 
    return colours[index];
  }


  public int coloursAvailable() { 
    int count = 0; 
    for (int i = 0; i<pensRemainingByColour.length-1; i++) { 
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