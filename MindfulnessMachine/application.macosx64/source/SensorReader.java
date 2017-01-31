import processing.serial.Serial;
import processing.core.*;

public class SensorReader { 
  Serial sensorSerialPort;      // The serial port

  String[] portNames = {"/dev/tty.usbmodem1411", "/dev/tty.usbmodem1421", "/dev/tty.usbmodem1431", "/dev/tty.usbmodem1441"};
  String portName = ""; 

  int inByte = -1;    // Incoming serial data
  String buffer="";
  String lastReceived = ""; 
  PApplet p5; 
  int lastReceivedTime = 0; 

  boolean dirty = false; 

  //public float temperature; 
  public float r, g, b;  
  boolean connected = false; 
  int retrySerialTime = 0; 

  boolean serialReset = false; 

  DataPoint temperature, lux, colourTemperature; 

  public SensorReader(PApplet processing) { 
    p5 = processing;   



    r = 0; 
    g = 0; 
    b = 0; 
    temperature = new DataPoint("temperature", 10, 30); 
    lux = new DataPoint("brightness", 0, 3000); 
    colourTemperature = new DataPoint("colour temperature", 0, 15000); 
    temperature.smooth = 0.1f; 
    lux.smooth = 0.1f; 
    colourTemperature.smooth = 0.1f; 
    temperature.decimalPlaces = 1; 
    temperature.unitSuffix = "ºC"; 
    colourTemperature.unitSuffix = "K"; 
    lux.unitSuffix = "LX"; 
    lux.decimalPlaces = 0; 
    colourTemperature.decimalPlaces = 0;

    //retrySerialTime = p5.millis()+5000; 

    connectToSerial();
  }
  public float drawData(float x, float y, float w, float barheight, float vspacing) {
    

    temperature.drawHorizontal(p5, x, y, w, barheight); 
    
    y+=barheight+vspacing; 
    
    lux.drawHorizontal(p5, x, y, w, barheight);
    y+=barheight+vspacing; 
    colourTemperature.drawHorizontal(p5, x, y, w, barheight);
       
    return y+barheight; 
  }
  public void update(float happiness, float stimulation) { 

    if (!connected) { 
      if (retrySerialTime<p5.millis()) { 
        connectToSerial();
      }
    } else if (p5.millis()-lastReceivedTime>10000) {
      connected = false; 
      serialReset = false; 
      try { 
        sensorSerialPort.clear(); 
        sensorSerialPort.stop(); 
        sensorSerialPort.dispose();
      } 
      catch (RuntimeException e) { 
        p5.println("Serial.stop failed", e);
      }
      connectToSerial();
    } else if (dirty) { 

      lastReceivedTime = p5.millis(); 
      parseData(lastReceived); 
      lux.setValue(getLux()); 
      colourTemperature.setValue(getColourTemperature()); 

      sendMoodToArduino(happiness, stimulation); 

      dirty = false;
    }
  }

  public boolean sendMoodToArduino(float happiness, float stimulation) { 

    if (!connected) return false; 
    String sendString =(p5.round(happiness*100))+","+p5.round(stimulation*100)+"\n"; 
    // p5.println(sendString); 
    sensorSerialPort.write(sendString);

    return true;
  }



  public void connectToSerial() { 

    // List all the available serial ports:
    String[] interfaces = Serial.list(); 

    for (int i = 0; i<portNames.length; i++) { 
      for (int j =0; j<interfaces.length; j++) { 
        if (interfaces[j].indexOf(portNames[i])!=-1) {
          portName = interfaces[j];
          p5.println("Sensor Reader Serial port : "+portName);
          break;
        }
      }
    }
    // this code resets the Arduino Leonardo - hacky though!   
    if (!serialReset) { 
      p5.println("Resetting to Serial - "+portName);
      try { 
        sensorSerialPort = new Serial(p5, portName, 1200);
        sensorSerialPort.stop();
        sensorSerialPort.dispose(); 
        serialReset = true;
        retrySerialTime = p5.millis()+10000;
      } 
      catch(RuntimeException e) { 
        p5.println(p5.millis(), e); 
        retrySerialTime = p5.millis()+5000;
      }
    } else { 
      //p5.delay(5000);
      lastReceivedTime = p5.millis(); 
      p5.println("Connecting to Serial - "+portName);
      try { 
        sensorSerialPort = new Serial(p5, portName, 9600);
        connected = true;
      } 
      catch (RuntimeException e) { 
        p5.println(p5.millis(), e); 
        retrySerialTime = p5.millis()+5000; 
        serialReset = false;
      }
    }
  }
  public void close() { 
    sensorSerialPort.stop();
  }

  public boolean serialEvent(Serial port) { 
    if (port!=sensorSerialPort) return false; 

    if (port==null) return false; 
    while (port.available()>0) {
      inByte = port.read();
      //p5.println("received "+inByte); 
      if ((inByte!=0)&&(inByte!=(int)('\r'))) {

        if ((char)inByte == '\n') { 
          lastReceived = buffer; 

          buffer = ""; 
          dirty = true;
          inByte = 0;
        } else { 
          buffer = buffer + (char)inByte;
        }
      }
    }
    return true;
  }
  public boolean parseData(String data) { 
    p5.println(data);
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
        temperature.setValue((float) (value/100f) -3); // -3 is to adjust for the heat from the camera 
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