import java.util.ArrayList;
import processing.core.*;
import processing.serial.*;

// currently uses Roland RD-GL language
// NOTES : 
// ESC.B - gives you the buffer size
// ESC.K - aborts and clears the buffer



public class Plotter extends Thread { 

  final char escapeChar = (char)27;
  final char termChar = (char)'\r';

  final static int COMMAND_MOVETO = 0; 
  final static int COMMAND_LINETO = 1; 
  final static int COMMAND_CIRCLE = 2;
  final static int COMMAND_DOT = 3; 
  final static int COMMAND_VELOCITY = 4;  
  final static int COMMAND_FORCE = 5; 
  final static int COMMAND_PEN_CHANGE = 6; 

  ArrayList<Command> commands; 
  ArrayList<Command> commandsProcessed; 

  PApplet p5; 
  volatile Serial serial;

  boolean debug; // outputs serial data to console

  boolean dry = false; // doesn't send drawing commands to the plotter

  String plotterID; 

  int plotWidth, plotHeight;
  float aspectRatio, scalePixelsToPlotter; 
  float plotterUnitsPerMM;
  int screenWidth = 800; 
  int screenHeight = 600; 

  float commandsPerSecond; 

  CommandRenderer previewImage; 
  CommandRenderer progressImage; 

  int previewWidth = 940; 

  PenManager penManager;  
  int currentPen; 
  boolean isPenDown; 
  PVector lastPlotPosition; 
  float currentVelocity; 


  boolean initialised; // have we got back all the init data from the plotter?  

  boolean printing; // are we currently sending the commands to the plotter? 

  boolean finished;  // have we finished sending all the commands to the printer? 

  boolean waiting;  // are we waiting for an OA command from the printer? (tells us it's ready for more)
  int lastRequestSent; // the time we sent the last request

  // used to moderate the rate of sending commands
  int printingStartedTime; 
  int commandsSentSincePrintingStarted; 

  //ArrayList<String> requestsSent; 
  String receivedString = "" ; 
  String receivedBuffer = ""; 

  /**
   * Constructor
   * @param applet the parent processing applet
   * @param serial an initialized serial instance to which the plotter is connected
   */

  public Plotter(PApplet processing, int screenwidth, int screenheight) { 

    //serial = null;
    p5 = processing;
    debug = true;

    //requestsSent = new ArrayList<String>(); 

    printing = false;  // if true, we're sending commands to the plotter
   // waiting = false; 
    initialised = false;  // true once we're sure we have a handshake with the plotter

    lastPlotPosition = new PVector(0, 0); // used to store where the plotter is so we can measure how far it's drawn
    currentPen = 0;
    isPenDown = false; 
    commands = new ArrayList<Command>();
    commandsProcessed = new ArrayList<Command>();
    commandsPerSecond = 20; 
    commandsSentSincePrintingStarted = 0; 

    this.screenWidth = screenwidth; 
    this.screenHeight = screenheight;

    // defaults
    plotWidth = 16158; 
    plotHeight = 11040; 
    plotterUnitsPerMM = 40; 


    penManager = new PenManager(p5);
    updatePlotterScale();

    start();
  }

  public void start()
  {
    super.start();
  }

  public void run()
  {

    while (true) { 

      if (serial==null) continue; 

      if ( !initialised) {
        getInitDataFromPlotter(); 
        initialised = true;
      } else {  
        
        if(commands.size()==0) { 
          finished = true;  
        } else { 
          finished = false;
        }
         
        if((printing) && (!finished)) {
          int buffer; 
          buffer = Integer.parseInt(request(escapeChar+".B"));
          if(buffer>800) processCommand(1); 
        }
          
        
        //while (serial.available()>0) {
        //} // end serial read loop
      }
      p5.delay(1);
      super.yield();
    } // end thread loop
  }

  public boolean update() {
      return true; 
//    commandsProcessed.clear(); 
//    // if ((!initialised)&&(!dry)) return false; 
//    if (!initialised) return false; 

//    if (p5.frameCount%60==0) penManager.saveStatus(); 

//    if (commands.size()==0) {
//      if (!finished) {  
//        finished = true;
//      }
//    } else { 
//      finished = false;
//    }

//    // if we haven't heard back from the plotter for a while, give it a nudge
//    if ((waiting) && (p5.millis()-lastRequestSent>10000)) { 
//      p5.println("resetting plotter", p5.millis(), lastRequestSent); 

//      //read("OA");
//    }

//    if ((printing) && (commands.size()>0) && (!waiting)) { 

//      float totalPrintTime = (float) (p5.millis()-printingStartedTime)/1000f; 

//      float commandrate = commandsPerSecond; 
//      if (dry) commandrate = 10000;//10000; 
//      while ((commands.size()>0) &&(float)commandsSentSincePrintingStarted/(float)totalPrintTime<commandrate) {
//        processCommand(1);
//      }

//      return true;
//    } else { 
//      return false ;
//    }
  }

  public void startPrinting() { 
    printing = true; 

    printingStartedTime = p5.millis(); 
    commandsSentSincePrintingStarted = 0;
    //p5.println("startPrinting", finished);
  }


  void moveTo(float x, float y) { 
    moveTo(new PVector(x, y));
  }

  void moveTo(PVector p) { 
    p = screenToPlotter(p); 
    //if (currentPosition.dist(p)>accuracy) { 
    addCommand(COMMAND_MOVETO, p.x, p.y);
    //   currentPosition.set(p);
    //}
  }

  void lineTo(float x, float y) { 
    lineTo(new PVector(x, y));
  }

  void lineTo(PVector p) { 
    p = screenToPlotter(p);
    addCommand(COMMAND_LINETO, p.x, p.y);
  }

  void plotDot(float x, float y) { 
    plotDot(new PVector(x, y));
  }
  void plotDot(PVector p ) { 
    p = screenToPlotter(p);
    addCommand(COMMAND_DOT, p.x, p.y);
    //previewDirty = true;
  }

  void plotLine(float x1, float y1, float x2, float y2) { 
    plotLine(new PVector(x1, y1), new PVector(x2, y2));
  }

  void plotLine(PVector p1, PVector p2) { 

    moveTo(p1); 
    lineTo(p2);
  }



  void addCommand(int type, float p1, float p2) { 
    //p5.println("add command float ", type, p1, p2); 
    addCommand(type, (int)p1, new int[]{(int)p2});
  }

  void addCommand(int type, int p1, int ... arguments) { 
    Command c;  
    //p5.println("add command args ", type, p1, arguments.length); 
    if (arguments.length==0) { 
      c = new Command(type, p1);
    } else if (arguments.length==1) { 
      c = new Command(type, p1, arguments[0]);
    } else if (arguments.length==2) { 
      c = new Command(type, p1, arguments[0], arguments[1]);
    } else { 
      c = new Command(type, p1);
    }

    commands.add(c); 
    previewImage.renderCommand(c);
  }

  void addForceCommand(int f) { 
    addCommand(COMMAND_FORCE, f, 0);
  }
  void addVelocityCommand(int v) { 
    addCommand(COMMAND_VELOCITY, v, 0);
  }
  void selectPen(int p) { 
    //currentPen = p; 
    addCommand(COMMAND_PEN_CHANGE, p, 0);
  }

  void clearPen() { 
    addCommand(COMMAND_PEN_CHANGE, -1, 0);
  }
  void plotRect(float x, float y, float w, float h) { 
    plotLine(new PVector(x, y), new PVector(x+w, y));    
    plotLine(new PVector(x+w, y), new PVector(x+w, y+h));
    plotLine(new PVector(x+w, y+h), new PVector(x, y+h));
    plotLine(new PVector(x, y+h), new PVector(x, y));
  }


  void plotCircle(float x, float y, float r) { 
    PVector p = screenToPlotter(new PVector(x, y)); 
    int cr = p5.round(r * scalePixelsToPlotter); 
    addCommand(COMMAND_CIRCLE, p5.round(p.x), p5.round(p.y), cr) ;
    //previewDirty = true;
  }

  void processCommand(int numCommands) { 
    //p5.println("processCommand", numCommands, commands.size()); 
    int processedCount = 0; 
    while ((processedCount<numCommands) && (commands.size()>0)) {

      Command c = (Command)commands.get(0);
      commands.remove(0); 

      commandsProcessed.add(c); 
      while(commandsProcessed.size()>100) commandsProcessed.remove(0);

      progressImage.renderCommand(c); 

      if (c.c == COMMAND_MOVETO) { 
        if (plotMoveTo(c.p1, c.p2)) { 

          waiting = true;
          //waitStartTime = p5.millis(); 
          request("OA");
        }
      } else if (c.c == COMMAND_LINETO) { 
        plotLineTo(c.p1, c.p2);
      } else if (c.c == COMMAND_DOT) { 
        plotMoveTo(c.p1, c.p2 );
        penDown();
        penUp();
      } else if (c.c == COMMAND_VELOCITY) {
        setVelocity(c.p1);
      } else if (c.c == COMMAND_FORCE) {
        //forceSelect(c.p1); // NOTE doesn't work on DXY1300 plotters
      } else if (c.c == COMMAND_PEN_CHANGE) {
        plotSelectPen(c.p1+1); // PEN NUMBERS FROM 0 to 7 translater to pen positions 1 to 8
        currentPen = c.p1;
      } else if (c.c == COMMAND_CIRCLE) {
        // TODO - maybe not use the built-in circle command? 
        penUp();
        float circleres = p5.constrain(2*p5.asin((float)30/(2*c.p3)), 0.1f, 30); // automatically calculate the resolution of the circle dependent on size
        String cmd = "PU"+c.p1+","+c.p2+";CI"+c.p3+","+p5.round(circleres)+";";
        //rawCommand(cmd, false);  // needs to be added to command list 

        isPenDown = true; 
        penUp();
      }
      processedCount++;
    }

    commandsSentSincePrintingStarted+=processedCount; 
    //p5.println("processCommand done", numCommands, commands.size()); 
    // this automatically stops printing when we're done - should probably be an option! 
    if (commands.size()==0) {
      printing = false;
    }
    if (commands.size()==0) {
      penUp();
    }
  }



  // FUNCTIONS THAT ACTUALLY DO THE DRAWING

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
  public void plotSelectPen(int pen) {
    if (!dry) send("SP", new Integer(pen));
  }

  public boolean plotMoveTo(int x, int y) {
    if ((lastPlotPosition.x!=x)||(lastPlotPosition.y!=y)) { 
      if (!dry) send("PU", x, y); 
      isPenDown = false;
      lastPlotPosition.set(x, y);
      return !dry;
    } else {
      return false;
      //penUp();
    }
  }
  public void plotLineTo(int x, int y) {
    penManager.trackUsage(currentPen, lastPlotPosition.dist(new PVector(x, y))/plotterUnitsPerMM, currentVelocity);
    if (!dry) send("PD", x, y); 
    isPenDown = true;
    lastPlotPosition.set(x, y);
  }


  /** 
   * Sends a raw command to the plotter
   @param command the command to send to the plotter
   @param should we wait for a response from the plotter after sending
   */

  public String rawCommand(String command, boolean wait) {

    if (debug)
      PApplet.println("raw command: " + command);

    // if (!this.dry)
    this.serial.write(command);

    String result = "";

    if (wait) {

      if (debug)
        p5.println("waiting for reply");

      if (wait) {

        if (debug)
          PApplet.println("waiting for reply");
        int receiveByte = 0; 
        while (receiveByte != 13) {

          // TODO ADD TIMEOUT
          if (serial.available()>0) { 
            receiveByte = this.serial.read(); 

            if ((receiveByte!=13)&&(receiveByte!=-1)) {
              result = result + (char)receiveByte;
              //p5.println((char)receiveByte);
            }
          } else { 
            p5.delay(1);
            super.yield();
          }
        }
      }
      if (debug)
        p5.println(result); 
      lastRequestSent = p5.millis(); 

      //result = result.replace(Character.toString(termChar), "");
    }

    return result;
  }


  private String request(String command, Object ... arguments) {
    return request(true, command, arguments);
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

  //  public String read(String command) {
  //    return request(true, command);
  //  }

  public void send(String command, Object... arguments) {
    if (debug)
      PApplet.println("send: "+command);
    request(false, command, arguments);
  }

  public void close() { 
    if (serial==null) return; 
    //send(escapeChar+".K");
    send(escapeChar+".K");
    p5.delay(1000);
    serial.clear();
    serial.stop();
  }




  void getInitDataFromPlotter() { 
    // reset plotter and empty buffer
    send(escapeChar+".K");
    plotterID = request( "OI"); 
    p5.println("Plotter ID       : ", plotterID); 

    // The command OH returns the "hard clip limits", in other words the output area in 
    // plotter units. Assumes top left of 0,0 which is probably bad
    // TODO - don't assume top left of 0,0 :) 
    String r = request("OH");
    String[] tokens = r.split(",");
    plotWidth = Integer.parseInt(tokens[2]); 
    plotHeight = Integer.parseInt(tokens[3]); 



    // The OF commmand returns the plotter units per mm in both the x and y axis
    // This assumes that they are the same, which is probably an OK assumption. 
    r = request("OF"); 
    tokens = r.split(",");
    plotterUnitsPerMM = Integer.parseInt(tokens[0]); 

    updatePlotterScale();

    // OO command returns "options" I think just to show whether the plotter can change pens 
    // and do arcs and circles. 
    //p5.println("Plotter opts     : "+request(true, "OO"));

    // OS command returns plotter status as an integer representing several binary flags
    // The important one is :
    // Bit 5 (32) : error flag - use command OE to find out what the error is
    // p5.println("Plotter status   : "+stringIntToBinaryString(read( "OS")));

    // OE command returns error status with binary flags with bits (note 4, 7, 8 unused): 
    // 0 : no bits set, so no error
    // 1 : unrecognisable command
    // 2 : Wrong number of params
    // 3 : Unusable parameter
    // 5 : Unusable character set designated
    // 6 : Coordinate overflow
    //p5.println("Plotter error    : "+stringIntToBinaryString(read( "OE")));

    // OW will return window width and height, should be same as OF, except I think it can be changed
    //p5.println("Plotter window   : "+read( "OW"));

    // ESC.B will return the available buffer. Might be useful
    //p5.println("Buffer remaining : "+read( escapeChar+".B"));
    // ESC.O returns the plotter status :
    // 0 buffer is not empty
    // 8 buffer is empty
    // 16 buffer is not empty and plotter is paused (pause button pressed)
    // 24 Buffer is empty and plotter is paused
    //p5.println("Plotter status   : "+read( escapeChar+".O"));

    p5.println("Plotter id       : "+plotterID);
    p5.println("Plotter dpmm     : "+plotterUnitsPerMM);
    p5.println("Plotter size     : "+plotWidth+" x "+plotHeight);
    p5.println("Plotter size (mm): "+plotWidth/plotterUnitsPerMM+" x "+plotHeight/plotterUnitsPerMM);

    // set plotter in absolute mode
    send("PA"); 

    selectPen(0);
  }


  //----------------------------- CONVERSION FUNCTIONS -------------------------------------


  void updatePlotterScale() { 

    aspectRatio = (float)plotWidth/(float)plotHeight; 
    float screenAspectRatio = (float)screenWidth/(float)screenHeight; 

    // if the screen aspect is wider than the plotter
    if (aspectRatio>screenAspectRatio) { 
      scalePixelsToPlotter = plotWidth/(float)screenWidth;
    } else { 
      scalePixelsToPlotter = plotHeight/(float)screenHeight;
    } 

    screenWidth = p5.round((float)plotWidth/scalePixelsToPlotter); 
    screenHeight = p5.round((float)plotHeight/scalePixelsToPlotter);

    p5.println("scalePixelsToPlotter", scalePixelsToPlotter); 
    p5.println("screenWidth", screenWidth); 
    p5.println("screenHeight", screenHeight);
    p5.println("aspect ratio", aspectRatio);

    //previewImage = new CommandRenderer(p5, penManager, screenWidth, screenHeight, scalePixelsToPlotter);
    //progressImage = new CommandRenderer(p5, penManager, screenWidth, screenHeight, scalePixelsToPlotter);
    //previewImage.smooth(); 
    //previewDirty = true;
    previewImage = new CommandRenderer(p5, penManager, previewWidth, (int)((float)previewWidth/aspectRatio), scalePixelsToPlotter*screenWidth/previewWidth, 8); 
    progressImage = new CommandRenderer(p5, penManager, previewWidth, (int)((float)previewWidth/aspectRatio), scalePixelsToPlotter*screenWidth/previewWidth, 8);
  }

  PVector screenToPlotter(PVector screenPos) { 

    PVector plotterPos = screenPos.get();  

    plotterPos.z = 0; 
    plotterPos.mult(scalePixelsToPlotter); 

    roundVector(plotterPos);

    plotterPos.y = plotHeight - (plotterPos.y);

    return plotterPos;
  }
  void roundVector(PVector p) { 
    p.x = p5.round(p.x); 
    p.y = p5.round(p.y);
    p.z = 0;
  }




  //-------------------------------- SERIAL FUNCTIONS... 

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

      p5.println("connecting to " + interfaces[serialNumber]); 
      serial = new Serial(p5, interfaces[serialNumber]);

      // thread should kick in at this point

      //p5.println("getting init data"); 

      //getInitDataFromPlotter(); 

      //selectPen(0);

      return true;
    } else { 
      return false;
    }
  }

  public void clear() { 
    commands.clear();
    previewImage.clear(); 
    progressImage.clear();
  }

  String stringIntToBinaryString(String intString) { 
    return Integer.toBinaryString(Integer.parseInt(intString));
  }


  //-------------------------- RENDERING ---------------------------------
  public void renderPreview() { 
    previewImage.render();
  }
  public void renderProgress() { 
    progressImage.render();
  }
  //-------------------------- PEN MANAGER ------------------------------



  public void setPenColour(int index, int c) { 
    penManager.setColour(index, c);
  }

  public int getPenColour(int index) { 
    return penManager.getColour(index);
  }

  public void setPenThicknessMM(int index, float t) { 
    penManager.setThickness(index, t*plotterUnitsPerMM);
  }
  public void setPenThicknessPixels(int index, float t) { 
    penManager.setThickness(index, t*scalePixelsToPlotter);
  }

  public float getPenThicknessMM(int index) { 
    return penManager.getThickness(index)/plotterUnitsPerMM;
  }
  public float getPenThicknessPixels(int index) { 
    return penManager.getThickness(index)/scalePixelsToPlotter;
  }

  public void resetPen(int index) { 
    penManager.resetPen(index);
  }  

  public float getPenDistance(int index) { 
    return penManager.getDistance(index);
  }
}