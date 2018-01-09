import java.util.ArrayList;
import processing.core.*; 

public class PenManager {

  ArrayList<Pen> pens; 
  PApplet p5; 
  
  boolean statusDirty = true; 


  PenManager(PApplet processing) { 
    p5 = processing; 
    pens = new ArrayList<Pen>(); 
    for (int i = 0; i<8; i++) { 
      pens.add(new Pen(p5));
    }
    loadStatus(); 
  }



  public boolean setColour(int penNumber, int c) { 
    if ((penNumber<0) || penNumber>pens.size()) return false; 
    pens.get(penNumber).setColour(c); 
    return true;
  }
  public int getColour(int penNumber) { 
    if ((penNumber<0) || penNumber>pens.size()) return 0; 
    else return pens.get(penNumber).getColour();
  }

  public void setThickness(int penNumber, float thickness) { 
    pens.get(penNumber).setThickness(thickness);
  }
  public float getThickness(int penNumber) { 
    if ((penNumber<0) || (penNumber>7) ) return 0; 
    return pens.get(penNumber).getThickness();
  }
  public float getDistance(int penNumber) { 
    if ((penNumber<0) || (penNumber>7) ) return 0; 
    return pens.get(penNumber).getDistance();
    
  }
  public void trackUsage(int penNumber, float distanceDrawnMM, float speed) {  
    if ((penNumber<0) || penNumber>pens.size()) return;

    pens.get(penNumber).trackUsage(distanceDrawnMM, speed);
    statusDirty = true; 
  }
  public void resetPen(int penNumber) { 
    if ((penNumber<0) || penNumber>pens.size()) return;
    p5.println("resetPan("+penNumber+")"); 
    pens.get(penNumber).reset();
  }

  public boolean loadStatus() { 
    String[] data = p5.loadStrings("data/penUsage.txt"); 
    if(data==null) { 
       for(int i =0;i<pens.size(); i++) resetPen(i);  
       return false; 
    } else { 
        for(int i =0;i<pens.size(); i++) { 
           Pen pen = pens.get(i); 
           pen.distanceDrawn = p5.parseFloat(data[i]); 
          
        }
        return true;
    }
    
  }

  public boolean saveStatus() { 
    if(statusDirty) { 
      String[] data = new String[pens.size()];
      for(int i = 0; i<pens.size(); i++) { 
        data[i] = p5.str(pens.get(i).distanceDrawn); 
      }
      p5.saveStrings("data/penUsage.txt", data); 
      statusDirty = false; 
    }
    return true;
  }
}