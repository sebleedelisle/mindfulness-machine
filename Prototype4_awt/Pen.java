import processing.core.*;

public class Pen { 

  public int colour = 0; 
  public float distanceDrawn; // in mm
  public PApplet p5; 
  public float thickness = 2f; 

  public Pen(PApplet processing) { 
    p5=processing;
  }

  public void setColour(int c) { 
    colour = c;
  }
  
  public void setThickness(float t) { 
    thickness = t; 
  } 
  public float getThickness() { 
    return thickness; 
  } 

  public int getColour() { 
    return colour; 
  }
  public void trackUsage(float mmDrawn, float speed) {
    
     distanceDrawn+=mmDrawn;  
    
  }
}