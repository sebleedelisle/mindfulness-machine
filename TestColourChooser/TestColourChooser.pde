import java.util.Collections;
import java.util.List;
import java.util.Comparator;

color[] colours = new color[11]; 
int[] colourCounts = new int[11]; 
int totalPenCount = 0; 


void setup () { 

  size(800, 800); 

  colours[0] = #FF4DD6; // pink
  colours[1] = #DE2B30;   // red
  colours[2] = #A05C2F;// light brown
  colours[3] = #5A371F;  // dark brown
  colours[4] = #338149; // dark green 
  colours[5] = #45C953; // light green 
  colours[6] = #FFE72E ; // yellow
  colours[7] = #FF8B17 ; // orange
  colours[8] = #6522AF ; // purple
  colours[9] = #293FB2 ; // navy blue
  colours[10] = #6FC6FF ; // sky blue

  for(int i = 0; i<colours.length; i++) { 
   println(brightness(colours[i]), saturation(colours[i]));  
    
  }

  noSmooth();

  noLoop();
}

public class ColourComparator implements Comparator<Integer> {

  
  public int compare(Integer n1, Integer n2) {
      float b1 = brightness(colours[n1]) + saturation(colours[n1]); 
      float b2 = brightness(colours[n2]) + saturation(colours[n1]); 
      println(b1, b2, b1-b2);
      return (int)(b1-b2);
    
  }
}

void draw() { 
  background(250);
  int startColour = 0; 
  noSmooth();
  float y = 10; 
  strokeWeight(7); 
  strokeCap(SQUARE);
  
  for(int i = 0; i<colourCounts.length; i++) colourCounts[i]=24;
  
  boolean cancelled = false; 
  totalPenCount = 132*2; 
  
  while ((totalPenCount-7>0) && (!cancelled)) { 
    strokeWeight(10); 
    
    ArrayList<Integer> chosencolours = new ArrayList<Integer>();
    for (int i = 0; i<7; i++) chosencolours.add(-1);  
    
    for (int i = 0; i<7; i++) { 
      int colourindex = (startColour+((i+9)*3))%11;    
      //if(colourCounts[colourindex]>=24) {
        
      //  while(i>0) { 
      //    i--;
      //    colourindex = (startColour+(i*2))%11;  
      //    colourCounts[colourindex]--;
      //    totalPenCount--;
      //  }
      //  cancelled = true; 
      //  break;
      //}
      int trynextcount = 0; 
      while((colourCounts[colourindex]<=0) || (chosencolours.contains(colourindex))) {
        colourindex=(colourindex+1)%11; 
        trynextcount++;
        if(trynextcount>=10) { 
          println("run out at ", i); 
          cancelled =true; 
          break;
        }
      }
      colourCounts[colourindex]--; 
      
      totalPenCount--; 


      chosencolours.set(i,colourindex); 
      stroke(colours[colourindex]); 
      float x = (colourindex*15)+10;
      line(x, y, x, y+10);
    }
    Collections.sort(chosencolours, new ColourComparator());
    
    //chosencolours = sort(chosencolours); 
    strokeWeight(21); 
    //if(cancelled) break;
    for (int i = 0; i<7; i++) { 
      if(chosencolours.get(i)<0) continue; 
      float x = (i*28)+200;
      strokeWeight(25); 
      stroke(0);
      line(x, y-2, x, y+17);
      strokeWeight(21); 
      stroke(colours[chosencolours.get(i)]);

      line(x, y, x, y+15);
    }

    startColour++; 
    y+= 20;
  }

  println("total pens left : ", totalPenCount);
  for (int i =0; i<11; i++) { 
    println("colour "+i+" : "+colourCounts[i]);
  }
}