import java.util.ArrayList;
import processing.core.*;
import processing.serial.*;

// currently uses Roland RD-GL language
// NOTES : 
// ESC.B - gives you the buffer size
// ESC.K - aborts and clears the buffer



public class Plotter { 

  final static int COMMAND_MOVETO = 0; 
  final int COMMAND_LINETO = 1; 
  final int COMMAND_CIRCLE = 2;
  final int COMMAND_DOT = 3; 
  final int COMMAND_VELOCITY = 4;  
  final int COMMAND_FORCE = 5; 
  final int COMMAND_PEN_CHANGE = 6; 

  ArrayList<Command> commands; 

  PApplet p5; 
  Serial serial;
  boolean debug;
  boolean dry;
  String plotterID; 
  char escapeChar = (char)27;
  char termChar = (char)'\r';

  int plotWidth, plotHeight;
  float aspectRatio, scalePixelsToPlotter; 
  float plotterUnitsPerMM;
  int screenWidth = 800; 
  int screenHeight = 600; 

  PGraphics previewImage; 
  //boolean previewDirty = true; 
  PGraphics progressImage;

  int currentPen; 
   boolean isPenDown; 
  PVector lastPlotPosition; 
  float currentVelocity; 

  boolean initialised; 
  boolean printing; 

  /**
   * Constructor
   * @param applet the parent processing applet
   * @param serial an initialized serial instance to which the plotter is connected
   */

  public Plotter(PApplet processing) { 

    //serial = null;
    p5 = processing;
    debug = false;
    dry = false;

    printing = false;  // if true, we're sending commands to the plotter
    initialised = false;  // true once we're sure we have a handshake with the plotter
    lastPlotPosition = new PVector(0, 0); // used to store where the plotter is so we can measure how far it's drawn
    currentPen = 0;
    isPenDown = false; 
  }


  public boolean update() {

    if (!initialised) return false; 

    // TODO check buffer!
    //float buffer = read( escapeChar+".B")


    if ((printing) && (commands.size()>0)) { 

      processCommand(10); 
      //previewDirty = true; 
      //if ((commands.size()%100) ==0) 
      //println("COMMANDS TO PROCESS : " + commands.size()); 
      return true;
    } else { 
      return false ;
    }
  }


  void processCommand(int numCommands) { 

    int processedCount = 0; 
    while ((processedCount<numCommands) && (commands.size()>0)) {

      Command c = (Command)commands.get(0);
      commands.remove(0); 

      if (c.c == COMMAND_MOVETO) { 
        plotMoveTo(c.p1, c.p2);
      } else if (c.c == COMMAND_LINETO) { 
        plotLineTo(c.p1, c.p2);
        //penManager.trackUsage(currentPen, lastPlotPosition.dist(new PVector(c.p1 + offsetX, c.p2 + offsetY)), currentVelocity);
      } else if (c.c == COMMAND_DOT) { 
        plotMoveTo(c.p1, c.p2 );
        penDown();
        penUp();
      } else if (c.c == COMMAND_VELOCITY) {
        setVelocity(c.p1);
      } else if (c.c == COMMAND_FORCE) {
        //forceSelect(c.p1); // NOTE doesn't work on DXY1300 plotters
      } else if (c.c == COMMAND_PEN_CHANGE) {
        selectPen(c.p1+1); // PEN NUMBERS FROM 0 to 7 translater to pen positions 1 to 8
        currentPen = c.p1;
      } else if (c.c == COMMAND_CIRCLE) {
        // TODO - maybe not use the built-in circle command? 
        penUp();
        float circleres = p5.constrain(2*p5.asin((float)30/(2*c.p3)), 0.1f, 30); // automatically calculate the resolution of the circle dependent on size
        String cmd = "PU"+c.p1+","+c.p2+";CI"+c.p3+","+p5.round(circleres)+";";
        rawCommand(cmd, false); 
        isPenDown = true; 
        penUp();
      }
      processedCount++;
    }

    // this automatically stops printing when we're done - should probably be an option! 
    if (commands.size()==0) {
      printing = false;
    }
    if (commands.size()==0) {
      penUp();
    }
  }

  private void setVelocity(float v) { 
    // should be between 1 and 42 (although 0-128 are valid syntactically)
    send("VS", v);
    currentVelocity = v;
  }

  private void penUp() {
    if (!isPenDown) return; 
    send("PU"); 
    isPenDown = false;
  }
  private void penDown() {
    if (isPenDown) return; 
    send("PD"); 
    isPenDown = true;
  }

  /**
   * Select the pen to use for drawing.
   * @param pen the pen to use for drawing
   */
  public void selectPen(int pen) {
    send("SP", new Integer(pen));
  }

  public void plotMoveTo(int x, int y) {
    send("PU", x, y); 
    isPenDown = false;
    lastPlotPosition.set(x, y);
  }
  public void plotLineTo(int x, int y) {
    send("PD", x, y); 
    isPenDown = true;
    lastPlotPosition.set(x, y);
  }

  ///**
  // * Move the pen position to the given relative coordinates
  // * @param x the x coordinate
  // * @param y the y coordinate
  // */
  //public void plotRelative(int x, int y) {
  //  send("PR", new Integer(x), new Integer(y));
  //}  

  //// SERIAL FUNCTIONS... 

  public boolean connectToSerial(String portname) { 
    String[] interfaces = Serial.list(); 
    p5.printArray(interfaces);//(join(interfaces, "\n"));
    int serialNumber = -1; 

    for (int i =0; i<interfaces.length; i++) { 
      if (interfaces[i].indexOf(portname)!=-1) {
        serialNumber = i;
      }
    }
    // TODO try catch around serial connection - to allow retries for serial
    if (serialNumber!=-1) {
      p5.println("FOUND USB SERIAL at index "+serialNumber);
      p5.println(interfaces[serialNumber]);

      serial = new Serial(p5, interfaces[serialNumber]);

      getInitDataFromPlotter(); 

      return true;
    } else { 
      return false;
    }
  }

  void getInitDataFromPlotter() { 

    plotterID = read( "OI"); 
    p5.println("Plotter ID       : ", plotterID); 

    // The command OH returns the "hard clip limits", in other words the output area in 
    // plotter units. Assumes top left of 0,0 which is probably bad
    // TODO - don't assume top left of 0,0 :) 
    String r = read("OH");
    String[] tokens = r.split(",");
    plotWidth = Integer.parseInt(tokens[2]); 
    plotHeight = Integer.parseInt(tokens[3]); 

    // The OF commmand returns the plotter units per mm in both the x and y axis
    // This assumes that they are the same, which is probably an OK assumption. 
    r = read("OF"); 
    tokens = r.split(",");
    plotterUnitsPerMM = Integer.parseInt(tokens[0]); 

    p5.println("Plotter dpmm     : "+plotterUnitsPerMM);
    p5.println("Plotter size     : "+plotWidth+" x "+plotHeight);
    p5.println("Plotter size (mm): "+plotWidth/plotterUnitsPerMM+" x "+plotHeight/plotterUnitsPerMM);

    // OO command returns "options" I think just to show whether the plotter can change pens 
    // and do arcs and circles. 
    //p5.println("Plotter opts     : "+request(true, "OO"));

    // OS command returns plotter status as an integer representing several binary flags
    // The important one is :
    // Bit 5 (32) : error flag - use command OE to find out what the error is
    p5.println("Plotter status   : "+stringIntToBinaryString(read( "OS")));

    // OE command returns error status with binary flags with bits (note 4, 7, 8 unused): 
    // 0 : no bits set, so no error
    // 1 : unrecognisable command
    // 2 : Wrong number of params
    // 3 : Unusable parameter
    // 5 : Unusable character set designated
    // 6 : Coordinate overflow
    p5.println("Plotter error    : "+stringIntToBinaryString(read( "OE")));

    // OW will return window width and height, should be same as OF, except I think it can be changed
    p5.println("Plotter window   : "+read( "OW"));

    // ESC.B will return the available buffer. Might be useful
    p5.println("Buffer remaining : "+read( escapeChar+".B"));
    // ESC.O returns the plotter status :
    // 0 buffer is not empty
    // 8 buffer is empty
    // 16 buffer is not empty and plotter is paused (pause button pressed)
    // 24 Buffer is empty and plotter is paused
    p5.println("Plotter status   : "+read( escapeChar+".O"));

    // set plotter in absolute mode
    send("PA"); 

    initialised = true;
  }

  String stringIntToBinaryString(String intString) { 
    return Integer.toBinaryString(Integer.parseInt(intString));
  }

  /** 
   * Sends a raw command to the plotter
   @param command the command to send to the plotter
   @param should we wait for a response from the plotter after sending
   */

  public String rawCommand(String command, boolean wait) {

    if (debug)
      PApplet.println("raw command: " + command);

    if (!this.dry)
      this.serial.write(command);

    String result = null;

    if (wait) {

      if (debug)
        p5.println("waiting for reply");

      result = ""; 
      // waiting for a LF ended string - TODO timeout? 
      while (result.indexOf(termChar)<0) {
        if (serial.available()>0) 
          result = result+ serial.readString();
      }
      result = result.replace(Character.toString(termChar), "");
    }

    return result;
  }

  private String request(boolean wait, String command, Object ... arguments) {

    String output = new String(command);

    boolean needComma = false;

    for (Object arg : arguments) {
      if (needComma)
        output = output+",";

      output = output + arg.toString();
      needComma = true;
    }
    output = output + ";";

    String result = rawCommand(output, wait);

    if (debug)
      p5.println("request: " + output);
    if (debug)
      p5.println("result: "+ result);

    return result;
  }

  public String read(String command) {
    return request(true, command);
  }

  public void send(String command, Object... arguments) {
    if (debug)
      PApplet.println("send: "+command);
    request(false, command, arguments);
  }
}