import processing.core.*;
import java.util.List;

public class DataPoint { 
  
  // data point tracks a data item over time
  // give it a new value periodically 
  // smooths the data
  // can draw it
  // works out a sensible range
  // stores historic data
  // always a float value
  PApplet p5; 
  float max, min; // range values 
  float value; // raw value
  List<Float> valueHistory; 
  int valueCount = 0; // count the values as they come in
  boolean rangeChanged = false; 
  
  public DataPoint(PApplet processing, float _max, float _min) { 
    p5 = processing;
    min = 0; 
    max = 100; 
    value = 0; 
    
  }
  
  public void setNewValue(float v) { 
    valueCount++; 
    value = v; 
    valueHistory.add(value); 
    if(valueHistory.size()>1000) valueHistory.remove(0); 
    // todo : histories at different scales
   
    updateRange();  
    
    
    
  }
  
  public void updateRange() { 
    if(value<min) {
       min = value; 
       rangeChanged = true; 
    }
    if(value>max) { 
      max = value; 
      rangeChanged = true; 
    } 
    
  }
  
  
}