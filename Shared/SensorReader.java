import processing.serial.Serial;
import processing.core.*;

public class SensorReader { 
  Serial sensorSerialPort;      // The serial port

  String portName = "/dev/tty.usbmodem1421";
  
  int inByte = -1;    // Incoming serial data
  String buffer="";
  String lastReceived = ""; 
  PApplet p5; 

  boolean dirty = false; 

  //public float temperature; 
  public float r, g, b;  
  boolean connected; 

  DataPoint temperature, lux, colourTemperature; 

  public SensorReader(PApplet processing) { 
    p5 = processing;   

    // List all the available serial ports:
    p5.printArray(Serial.list());

    r = 0; 
    g = 0; 
    b = 0; 
    temperature = new DataPoint("temp", 10, 30); 
    lux = new DataPoint("lux", 0, 3000); 
    colourTemperature = new DataPoint("col", 0, 15000); 



    connectToSerial();
  }

  public void update() { 
    if (dirty) { 
      parseData(lastReceived); 
      lux.setValue(getLux()); 
      colourTemperature.setValue(getColourTemperature()); 
      dirty = false;
    }
  }

  public void connectToSerial() { 
    //sensorSerialPort = new Serial(p5, portName, 1200);
    //sensorSerialPort.stop();
    //p5.delay(5000);
    sensorSerialPort = new Serial(p5, portName, 9600);
    p5.println("Connecting to Serial - "+portName);
  }
  public void close() { 
    sensorSerialPort.stop();
  }

  public boolean serialEvent(Serial port) { 
    if (port!=sensorSerialPort) return false; 


    if (port.available()>0) 
      inByte = port.read();

    if ((inByte!=0)&&(inByte!=(int)('\r'))) {

      if ((char)inByte == '\n') { 
        lastReceived = buffer; 

        buffer = ""; 
        dirty = true;
      } else { 
        buffer = buffer + (char)inByte;
      }
    }
    return true;
  }
  public boolean parseData(String data) { 
    //p5.println(data);
    String[] items = p5.split(data, ','); 

    if (items.length!=4) return false; // bad data
    for (int i = 0; i<items.length; i++) { 
      String[] parts = p5.split(items[i], ':'); 
      if (parts.length!=2) return false; // bad data

      float value;
      try { 
        value = Float.parseFloat(parts[1]);
      } 
      catch (RuntimeException e) {
        return false ; // bad data
      } 

      float smooth = 1;//0.1f; 

      switch(parts[0].charAt(0)) { 
      case 'T' : 
        //  // temperature; 
        //temperature += (((float) value/100f)-temperature)*smooth; 
        temperature.setValue((float) value/100f); 
        break; 

      case 'R' : 
        r += (value-r)*smooth; 
        break; 

      case 'G' : 
        g += (value-g)*smooth; 
        break; 

      case 'B' : 
        b += (value-b)*smooth;
        break;
      }
    }
    return true;
  }

  public int getLux() { 
    float illuminance = (-0.32466F * r) + (1.57837F * g) + (-0.73191F * b);

    return (int)illuminance;
  }

  public int getColourTemperature() {

    float X, Y, Z;      /* RGB to XYZ correlation      */
    float xc, yc;       /* Chromaticity co-ordinates   */
    float n;            /* McCamy's formula            */
    float cct;

    /* 1. Map RGB values to their XYZ counterparts.    */
    /* Based on 6500K fluorescent, 3000K fluorescent   */
    /* and 60W incandescent values for a wide range.   */
    /* Note: Y = Illuminance or lux                    */
    X = (-0.14282F * r) + (1.54924F * g) + (-0.95641F * b);
    Y = (-0.32466F * r) + (1.57837F * g) + (-0.73191F * b);
    Z = (-0.68202F * r) + (0.77073F * g) + ( 0.56332F * b);

    /* 2. Calculate the chromaticity co-ordinates      */
    xc = (X) / (X + Y + Z);
    yc = (Y) / (X + Y + Z);

    /* 3. Use McCamy's formula to determine the CCT    */
    n = (xc - 0.3320F) / (0.1858F - yc);

    /* Calculate the final CCT */
    cct = (449.0F * p5.pow(n, 3)) + (3525.0F * p5.pow(n, 2)) + (6823.3F * n) + 5520.33F;

    /* Return the results in degrees Kelvin */
    return (int)cct;
  }

  public int getRGBColourTemperature() { 
    float temperatureInKelvins = p5.constrain((float)getColourTemperature(), 1000.0f, 40000.0f) / 100.0f; 

    float rr, rg, rb; 

    if (temperatureInKelvins <= 66.0)
    {
      rr = 1.0f;
      rg = saturate(0.39008157876901960784f * p5.log(temperatureInKelvins) - 0.63184144378862745098f);
    } else
    {
      float t = temperatureInKelvins - 60.0f;
      rr = saturate(1.29293618606274509804f * p5.pow(t, -0.1332047592f));
      rg = saturate(1.12989086089529411765f * p5.pow(t, -0.0755148492f));
    }

    if (temperatureInKelvins >= 66.0)
      rb = 1.0f;
    else if (temperatureInKelvins <= 19.0)
      rb = 0.0f;
    else
      rb = saturate(0.54320678911019607843f * p5.log(temperatureInKelvins - 10.0f) - 1.19625408914f);

    rr*=255; 
    rg*=255; 
    rb*=255; 

    int col = (0xff<<24) |((int)rr<<16) | ((int)rg<<8) | (int)rb;
    // p5.println(p5.hex(col));
    return col;
  }



  float saturate(float v) { 
    return p5.constrain(v, 0, 1);
  }
}