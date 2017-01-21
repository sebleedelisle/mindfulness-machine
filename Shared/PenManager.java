import java.util.ArrayList;
import processing.core.*; 

public class PenManager {

  ArrayList<Pen> pens; 
  PApplet p5; 


  PenManager(PApplet processing) { 
    p5 = processing; 
    pens = new ArrayList<Pen>(); 
    for (int i = 0; i<8; i++) { 

      pens.add(new Pen(p5));
    }
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
    return pens.get(penNumber).getThickness(); 
  }
  
  public void trackUsage(int penNumber, float distanceDrawn, float speed) {  
    if ((penNumber<0) || penNumber>pens.size()) return;
    
    pens.get(penNumber).trackUsage(distanceDrawn, speed); 
    
  }
  
  public boolean loadStatus() { 
    return true;
  }

  public boolean saveStatus() { 
    return true;
  }
}