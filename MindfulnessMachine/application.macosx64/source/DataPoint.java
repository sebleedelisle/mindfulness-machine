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
  //int valueCount = 0; // count the values as they come in
  boolean rangeChanged = false; 
  float smooth; 
  String label; 
  boolean useHistoryAverage; 
  int historyNumberUsed; 
  float averageValue; 
  boolean historyAverageDirty = true; 
  String unitSuffix = ""; 
  boolean showAsPercentage = false; 
  boolean showTicks = false; 
  int numTicks = 0; 

  int decimalPlaces = 2; 

  public DataPoint(String _label) { 
    this(_label, 0, 100);
  }
  public DataPoint(String _label, float _min, float _max) { 
    label = _label; 
    valueHistory = new ArrayList<Float>();
    min = _min; 
    max = _max; 
    value = targetValue = 0; 
    smooth = 1;//0.01f;
    useHistoryAverage = false; 
    historyNumberUsed = 0;
  }

  public void update() { 
    value +=(targetValue-value)*smooth; 
    if (useHistoryAverage) { 
      valueHistory.add(value); 
      while (valueHistory.size()>historyNumberUsed) { 
        valueHistory.remove(0);
      }
      historyAverageDirty = true;
    }
  }
  public void drawHorizontal(PApplet p5, float x, float y, float w, float h) { 
    p5.pushMatrix(); 
    p5.pushStyle(); 
    p5.translate(x, y); 
    int colour = 0xff00ffff; 
    p5.fill(colour); 
    p5.textSize(12); 
    p5.textAlign(p5.RIGHT, p5.CENTER); 
    p5.text(label.toUpperCase(), -8, h/2);
    p5.textAlign(p5.LEFT, p5.CENTER); 
    p5.text(getValueAsString(), w+8, h/2); 
    p5.noFill(); 


    if (showTicks) { 
      p5.stroke(0, 100, 100); 
      p5.beginShape(p5.LINES); 
      for (int i=1; i<numTicks; i++) { 
        float xpos = p5.map(i, 0, numTicks, 0, w);
        p5.vertex(xpos, 0); 
        p5.vertex(xpos, h*0.1f); 
        p5.vertex(xpos, h*0.9f); 
        p5.vertex(xpos, h);
      }
      p5.endShape();
    }
    
    p5.stroke(colour); 
    p5.rect(0, 0, w, h);

    float xpos = p5.constrain(p5.map(getValue(), min, max, 1, w-1), 0, w); 
    p5.strokeCap(p5.SQUARE);
    p5.strokeWeight(3); 
    p5.line(xpos, 0, xpos, h); 

    p5.popStyle(); 
    p5.popMatrix();
  }

  public void draw(PApplet p5, float x, float y, float w, float h) { 

    p5.pushMatrix(); 
    p5.pushStyle(); 
    p5.translate(x, y); 
    p5.textSize(10); 
    float barheight = 14; 
    p5.noFill(); 
    p5.stroke(0, 255, 255); 
    //p5.blendMode(p5.ADD); 
    p5.line(w/2, 0, w/2, h-barheight);

    float top = (barheight/2);
    float bottom = h-(barheight*1.5f);

    float ypos = p5.constrain(p5.map(getValue(), min, max, bottom, top), top, bottom); 
    p5.rectMode(p5.CENTER);
    p5.fill(0);
    p5.rect(w/2, ypos, w, barheight); 
    p5.fill(0, 255, 255);
    p5.textAlign(p5.CENTER, p5.CENTER);

    //p5.println(value%1); 

    //if(p5.abs(value)%1<0.001) strval = p5.str((int)value); 
    //else strval = p5.str((int)(getValue()*10)/10.0f);

    // p5.println(getValue(), strval);
    p5.text(getValueAsString(), w/2, ypos-1);
    p5.text(label.toUpperCase(), w/2, h-barheight/2); 
    p5.popStyle(); 
    p5.popMatrix();
  }

  public String getValueAsString() { 
    String strval; 
    if (showAsPercentage) { 
      strval = PApplet.str( (int)PApplet.round(getValue()*100)) + "%";
    } else if (decimalPlaces ==0) { 
      strval = PApplet.str( (int)PApplet.round(getValue()));
    } else { 
      float pow = PApplet.pow(10, decimalPlaces); 

      strval = PApplet.str( PApplet.round(getValue()*pow)/pow);
    }
    return strval+unitSuffix;
  }

  public void setUseHistoryAverage(int numvalues) { 
    useHistoryAverage = true;
    historyNumberUsed = numvalues; 
    historyAverageDirty = true;
  }
  public void setValue(float v) { 
    targetValue = v; 
    updateRange();
  }

  public float getValue() { 
    if (useHistoryAverage) { 

      if (historyAverageDirty) {   
        averageValue = 0; 
        // recalc averages  
        for (float v : valueHistory) { 
          averageValue+=v;
        }
        averageValue/=(float)valueHistory.size(); 
        historyAverageDirty = false;
      }
      return averageValue;
    } else { 
      return value;
    }
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