import processing.core.*;
import java.util.List;
import java.util.ArrayList;

public class DataPoint { 

  // data point tracks a data item over time
  // give it a new value periodically 
  // smooths the data
  // can draw it
  // works out a sensible range
  // stores historic data
  // always a float value

  float max, min; // range values 
  float value; // raw value
  float targetValue; // 
  List<Float> valueHistory; 
  int valueCount = 0; // count the values as they come in
  boolean rangeChanged = false; 
  float smooth; 
  String label; 
  
  public DataPoint(String _label) { 
    this(_label, 0, 100);
  }
  public DataPoint(String _label, float _min, float _max) { 
    label = _label; 
    valueHistory = new ArrayList<Float>();
    min = _min; 
    max = _max; 
    value = targetValue = 0; 
    smooth = 0.01f;
  }

  public void draw(PApplet p5, float x, float y, float w, float h) { 
    
    value +=(targetValue-value)*smooth; 
    
    p5.pushMatrix(); 
    p5.pushStyle(); 
    p5.translate(x, y); 

    float barheight = 14; 
    p5.noFill(); 
    p5.stroke(0, 255, 255); 
    //p5.blendMode(p5.ADD); 
    p5.line(w/2, 0, w/2, h-barheight);
    
    float top = (barheight/2);
    float bottom = h-(barheight*1.5f);
    
    
    float ypos = p5.constrain(p5.map(value, min, max, bottom, top),  top, bottom); 
    p5.rectMode(p5.CENTER);
    p5.fill(0);
    p5.rect(w/2, ypos, w, barheight); 
    p5.fill(0, 255, 255);
    p5.textAlign(p5.CENTER, p5.CENTER);
    String strval; 
    //p5.println(value%1); 
    
    if(p5.abs(value)%1<0.001) strval = p5.str((int)value); 
    else strval = p5.str((int)(value*10)/10.0f);
    p5.text(strval, w/2, ypos-1);
    p5.text(label.toUpperCase(), w/2, h-barheight/2); 
    p5.popStyle(); 
    p5.popMatrix();
  }

  public void setValue(float v) { 
    valueCount++; 
    targetValue = v; 
    valueHistory.add(v); 
    if (valueHistory.size()>1000) valueHistory.remove(0); 
    // todo : histories at different scales

    updateRange();
  }


  public void updateRange() { 
    if (value<min) {
      min = value; 
      rangeChanged = true;
    }
    if (value>max) { 
      max = value; 
      rangeChanged = true;
    }
  }
}