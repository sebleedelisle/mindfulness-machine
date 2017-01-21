
import fup.hpgl.*;
import processing.serial.*;
import java.util.Comparator;

final int COMMAND_MOVETO = 0; 
final int COMMAND_LINETO = 1; 
final int COMMAND_CIRCLE = 2;
final int COMMAND_DOT = 3; 
final int COMMAND_VELOCITY = 4;  
final int COMMAND_FORCE = 5; 
final int COMMAND_PEN_CHANGE = 6; 

class HPGLManager { 

  HPGL hpgl;
  Serial serial;

  float scalePixelsToPlotter =1; 

  PGraphics previewImage; 
  boolean previewDirty = true; 

  // the width and height of the plotter coordinate system
  float plotWidth = 16158; 
  float plotHeight = 11040; 
  float aspectRatio = plotWidth/plotHeight; 
  float screenWidth = 800; 
  float screenHeight = 600; 
  int offsetX = 0;
  int offsetY = 0; 

  int accuracy = 0; // used to remove ridiculously small movements. Value of zero should disable it 

  int[] limits;
  PApplet p5; 
  //color[] penColours = new color[8]; 
  PenManager penManager;   

  boolean isPenDown; 

  PVector currentPosition = new PVector(-1, -1); // used to see if we have come far enough to warrant a new line (part of the accuracy system)
  PVector lastPlotPosition = new PVector(0, 0);  // used to measure distance of plotted lines so we can tell the penmanager

  boolean initialised = false;
  ArrayList commands; 

  int currentPen = 0; 

  int currentCommand = 0; 

  boolean printing = false; 

  float currentVelocity;  // on my plotter goes between 1 and 42mm/s

  HPGLManager(PApplet p5) {

    this.p5 = p5; 
    penManager = new PenManager(p5); 
    currentVelocity = 42; // default (and maximum) on Roland DXY 1300 plotters

    isPenDown = true; 

    updatePlotterScale();

    commands = new ArrayList();
  }

  void setPenColour(int index, color c) { 
    penManager.setColour(index, c);
  }

  int getPenColour(int index) { 
    return penManager.getColour(index);
  }

  void clearBuffer() { 

    commands = new ArrayList();
    previewDirty = true;
  }

  boolean initHPGL() { 

    String[] interfaces = Serial.list(); 
    println(join(interfaces, "\n")); 
    int serialNumber = -1; 

    for (int i =0; i<interfaces.length; i++) { 

      //      if (interfaces[i].indexOf("/dev/tty.usbserial")>-1) {
      if (interfaces[i].equals("/dev/tty.usbserial")) {
        serialNumber = i;
      }
    }

    if (serialNumber!=-1) {
      println("FOUND USB SERIAL at index "+serialNumber);

      serial = new Serial(p5, interfaces[serialNumber]);
      hpgl = new HPGL(p5, serial);


      limits = (hpgl.hardClipLimits());
      println(limits[0]);
      println(limits[1]);
      println(limits[2]);
      println(limits[3]);
      plotWidth = limits[2]; 
      plotHeight = limits[3]; 
      aspectRatio = plotWidth/plotHeight; 

      //hpgl.selectPen(1); 
      // TODO maybe send reset? 

      updatePlotterScale();

      // hpgl.setCommandDelay(50); // default is 50

      initialised = true; 

      return true;
    } else { 
      println("NO USB SERIAL DEVICE DETECTED");
      exit();
      return false;
    }
  }

  boolean update() {

    if (!initialised) return false; 

    if ((printing) && (commands.size()>0)) { 

      processCommand(10); 
      previewDirty = true; 
      //if ((commands.size()%100) ==0) 
      //println("COMMANDS TO PROCESS : " + commands.size()); 
      return true;
    } else { 
      return false ;
    }
  }

  void renderCurrent() { 

    if (previewDirty) renderCommands(previewImage);

    image(previewImage, 0, 0, screenWidth, screenHeight); 
    stroke(255); 
    noFill();

    rect(0, 0, screenWidth-1, screenHeight-1);
  }

  void renderCommands(PGraphics g) {
    println("updating graphic"); 
    if (g!=null) {
      g.beginDraw();
      g.background(250);
    } else g = p5.g; 

    g.pushMatrix(); 
    g.scale(2, 2); 
    g.blendMode(p5.MULTIPLY);
    g.noFill(); 
    g.stroke(penManager.getColour(0));
    g.strokeWeight(penManager.getThickness(0)); // should probably convert from mm to pixels

    boolean drawing = false; 
    for (int i = 0; i<commands.size(); i++) { 

      Command c = (Command)commands.get(i); 

      //if (i==currentCommand) { 
      //  circleAtPoint(c, g);
      //}
      //println(i, c.c); 
      if (c.c == COMMAND_MOVETO) { 
        if (drawing) {
          g.endShape();
        }

        g.beginShape(); 

        screenVertex(c, g); 

        drawing = true;
      } else if (c.c == COMMAND_LINETO) { 

        screenVertex(c, g);
        drawing = true;
      } else if (c.c == COMMAND_CIRCLE) { 
        if (drawing) {
          g.endShape(); 
          drawing = false;
        }
        PVector p = plotterToScreen(new PVector(c.p1, c.p2));
        g.ellipseMode(RADIUS); 
        float r = (float)c.p3/scalePixelsToPlotter; 
        g.ellipse(p.x, p.y, r, r); 
        drawing = false;
      } else if (c.c == COMMAND_PEN_CHANGE) { 
        if (drawing) {
          g.endShape(); 
          drawing = false;
        }

        g.stroke(penManager.getColour(c.p1));
        g.strokeWeight(penManager.getThickness(c.p1));
      }
    }

    if (drawing) {
      g.endShape(); 
      // println("endShape");
    }

    if (g!=p5.g) g.endDraw();
    g.popMatrix(); 
    previewDirty = false;
  }

  void screenVertex(Command c, PGraphics g) { 

    PVector p = new PVector(c.p1, c.p2); 
    p = plotterToScreen(p); 
    g.vertex(p.x, p.y); 
    //ellipse(p.x, p.y, 5, 5); 
    // println("vertex "+p.x + " " +p.y);
  }


  void circleAtPoint(Command c) { 
    circleAtPoint(c, p5.g);
  }

  void circleAtPoint(Command c, PGraphics g) { 

    PVector p = new PVector(c.p1, c.p2); 
    p = plotterToScreen(p); 
    //vertex(p.x, p.y); 
    g.ellipseMode(CENTER); 
    g.ellipse(p.x, p.y, 5, 5); 
    // println("vertex "+p.x + " " +p.y);
  }

  void processCommand(int numCommands) { 


    int processedCount = 0; 
    while ((processedCount<numCommands) && (commands.size()>0)) {

      Command c = (Command)commands.get(0);
      commands.remove(0); 

      if (c.c == COMMAND_MOVETO) { 
        penUp(); 
        hpgl.plotAbsolute(c.p1 + offsetX, c.p2 + offsetY);
        lastPlotPosition.set(c.p1 + offsetX, c.p2 + offsetY);
      } else if (c.c == COMMAND_LINETO) { 
        penDown(); 
        hpgl.plotAbsolute(c.p1 + offsetX, c.p2 + offsetY);
        penManager.trackUsage(currentPen, lastPlotPosition.dist(new PVector(c.p1 + offsetX, c.p2 + offsetY)), currentVelocity); 
        lastPlotPosition.set(c.p1 + offsetX, c.p2 + offsetY);
      } else if (c.c == COMMAND_DOT) { 

        penUp(); 
        hpgl.plotAbsolute(c.p1 + offsetX, c.p2 + offsetY);
        penDown();
        penUp();
        lastPlotPosition.set(c.p1 + offsetX, c.p2 + offsetY);
      } else if (c.c == COMMAND_VELOCITY) {
        setVelocity(c.p1);
      } else if (c.c == COMMAND_FORCE) {
        hpgl.forceSelect(c.p1);
      } else if (c.c == COMMAND_PEN_CHANGE) {
        hpgl.selectPen(c.p1+1); // PEN NUMBERS FROM 0 to 7
        currentPen = c.p1;
      } else if (c.c == COMMAND_CIRCLE) {
        penUp();
        float circleres = constrain(2*asin((float)30/(2*c.p3)), 0.1, 30); // automatically calculate the resolution of the circle dependent on size
        String cmd = "PU"+c.p1+","+c.p2+";CI"+c.p3+","+round(circleres)+";";
        hpgl.rawCommand(cmd, false); 
        println(cmd, degrees(circleres)); 
        //hpgl.rawCommand("C"+c.p1+","+c.p2+","+c.p3+",0,360;", false); 
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



  void setOffset(float xMils, float yMils) { 
    offsetX = round( xMils * (plotHeight/275)); 
    offsetY = round( -yMils * (plotHeight/275));
  }

  void updatePlotterScale() { 

    float plotAspectRatio = plotWidth/plotHeight; 
    float screenAspectRatio = (float)width/(float)height; 

    // if the screen aspect is wider than the plotter
    if (plotAspectRatio>screenAspectRatio) { 
      scalePixelsToPlotter = plotWidth/(float)width;
    } else { 
      scalePixelsToPlotter = plotHeight/(float)height;
    } 

    screenWidth = (float)plotWidth/scalePixelsToPlotter; 
    screenHeight = (float)plotHeight/scalePixelsToPlotter;

    println("scalePixelsToPlotter", scalePixelsToPlotter); 
    println("screenWidth", screenWidth); 
    println("screenHeight", screenHeight);

    previewImage = createGraphics((int)screenWidth*2, (int)screenHeight*2, JAVA2D);

    previewImage.smooth(); 
    previewDirty = true;
  }

  void plotLine(float x1, float y1, float x2, float y2) { 
    plotLine(new PVector(x1, y1), new PVector(x2, y2));
  }

  void plotLine(PVector p1, PVector p2) { 

    moveTo(p1); 
    lineTo(p2);
  }




  void plotRect(float x, float y, float w, float h) { 
    plotLine(new PVector(x, y), new PVector(x+w, y));    
    plotLine(new PVector(x+w, y), new PVector(x+w, y+h));
    plotLine(new PVector(x+w, y+h), new PVector(x, y+h));
    plotLine(new PVector(x, y+h), new PVector(x, y));
  }

  void plotCircle(HPGLCircle c) { 

    plotCircle(c.x, c.y, c.r);
  }
  void plotCircle(float x, float y, float r) { 
    PVector p = screenToPlotter(new PVector(x, y)); 
    int cr = round(r * scalePixelsToPlotter); 
    commands.add(new Command(COMMAND_CIRCLE, round(p.x), round(p.y), cr)) ;
    //hpgl.penUp();
    //hpgl.plotAbsolute(cx, cy); 
    //hpgl.penDown(); 
    //hpgl.rawCommand("CI"+cr, false); 
    //hpgl.penUp();
    previewDirty = true;
  }

  private void setVelocity(float v) { 
    // should be between 1 and 42 (although 0-128 are valid syntactically)
    if (!initialised) initHPGL();
    hpgl.rawCommand("VS"+v, false);
    currentVelocity = v;
  }

  private void penUp() {
    if (!isPenDown) return; 
    hpgl.penUp(); 
    isPenDown = false;
  }
  private void penDown() {
    if (isPenDown) return; 
    hpgl.penDown(); 
    isPenDown = true;
  }

  void roundVector(PVector p) { 
    p.x = round(p.x); 
    p.y = round(p.y);
    p.z = 0;
  }

  void close() { 
    if (!initialised) return;
    serial.clear(); 
    serial.stop();
  }






  void moveTo(float x, float y) { 
    moveTo(new PVector(x, y));
  }

  void moveTo(PVector p) { 
    p = screenToPlotter(p); 
    if (currentPosition.dist(p)>accuracy) { 
      commands.add(new Command(COMMAND_MOVETO, (int)p.x, (int)p.y));
      currentPosition.set(p);
    }
  }

  void lineTo(float x, float y) { 
    lineTo(new PVector(x, y));
  }

  void lineTo(PVector p) { 
    p = screenToPlotter(p);

    if (currentPosition.dist(p)>accuracy) { 
      commands.add(new Command(COMMAND_LINETO, p.x, p.y));
      currentPosition.set(p);
      previewDirty = true;
    }
  }

  void plotDot(float x, float y) { 
    plotDot(new PVector(x, y));
  }
  void plotDot(PVector p ) { 
    p = screenToPlotter(p);
    commands.add(new Command(COMMAND_DOT, p.x, p.y));
    previewDirty = true;
  }

  void addForceCommand(int f) { 
    commands.add(new Command(COMMAND_FORCE, f, 0));
  }
  void addVelocityCommand(int v) { 
    commands.add(new Command(COMMAND_VELOCITY, v, 0));
  }
  void addPenCommand(int p) { 
    //currentPen = p; 
    commands.add(new Command(COMMAND_PEN_CHANGE, p, 0));
  }

  PVector screenToPlotter(PVector screenPos) { 

    PVector plotterPos = screenPos.get();  

    plotterPos.z = 0; 
    plotterPos.mult(scalePixelsToPlotter); 

    roundVector(plotterPos);

    plotterPos.y = plotHeight - (plotterPos.y);

    return plotterPos;
  }

  PVector plotterToScreen(PVector plotterPos) { 

    PVector screenPos = plotterPos.get();  

    screenPos.y = plotHeight - (screenPos.y);

    screenPos.z = 0; 
    screenPos.mult(1/scalePixelsToPlotter); 
    screenPos.x+=offsetX; 
    screenPos.y+=offsetY; 

    return screenPos;
  }

  void startPrinting() { 
    printing=true;
  }
}



class HPGLCircle {

  float x, y, r;
  int pen;
  boolean filled; 
  public HPGLCircle(float cx, float cy, float cr) {
    x = cx; 
    y = cy; 
    r = cr;
    pen = 0;
  } 

  public void draw() { 

    int col = (pen==0)?255:180; 

    stroke(col); 

    if (filled)  
      fill(col);
    else 
    noFill(); 

    ellipseMode(RADIUS);
    ellipse(x, y, r, r);
  }
  public boolean contains(float px, float py) { 
    return (distSq(px, py) < (r*r));
  }
  public float distSq(float px, float py) { 
    float dx = x-px; 
    float dy = y-py; 
    return (dx*dx)+(dy*dy);
  }
  public float dist(float px, float py) { 

    return sqrt(distSq(px, py))-r;
  }
}
public class CircleComparator implements Comparator<HPGLCircle> {


  //public IntersectionComparator() {
  //}
  public int compare(HPGLCircle c1, HPGLCircle c2) {
    float stripwidth = 20; 
    if (floor(c1.x/stripwidth)==(floor(c2.x/stripwidth))) {
      int strip = floor(c1.x/stripwidth); 
      if (strip%2==0) return c1.y==c2.y ? 0 : (c1.y<c2.y) ? -1 : 1;  
      else return c1.y==c2.y ? 0 : (c1.y<c2.y) ? 1 : -1;
    } else { 
      return c1.x==c2.x ? 0 : (c1.x<c2.x) ? -1 : 1;
    }
    //if (c1.distSq(c2.x, c2.y)==0) {
    //  return 0;
    //} else if (c1.x<c2.x) {
    //  return -1;
    //} else {
    //  return 1;
    //}
  }
}

class Command { 

  int c; 
  int p1, p2, p3;

  Command (int _c, int _p1, int _p2) { 
    set(_c, _p1, _p2, 0);
  }
  Command (int _c, int _p1, int _p2, int _p3) { 
    set(_c, _p1, _p2, _p3);
  }

  Command (int _c, float _p1, float _p2, float _p3) { 
    set(_c, round(_p1), round(_p2), round(_p3)) ;
  }
  Command (int _c, float _p1, float _p2) { 
    set(_c, round(_p1), round(_p2)) ;
  }
  void set(int _c, int _p1, int _p2) { 
    set(_c, _p1, _p2, 0); 
    //println("CMD : "+c+" "+p1+" "+p2);
  }
  void set(int _c, int _p1, int _p2, int _p3) { 
    c = _c; 
    p1 = _p1; 
    p2 = _p2; 
    p3 = _p3;
  }
};