
import fup.hpgl.*;
import processing.serial.*;

final int COMMAND_MOVE = 0; 
final int COMMAND_DRAW = 1; 
final int COMMAND_DRAW_DIRECT = 2; 
final int COMMAND_RESTART = 3; 
final int COMMAND_FINISH = 4; 
final int COMMAND_VELOCITY = 5; 
final int COMMAND_FORCE = 6; 
final int COMMAND_PEN_CHANGE = 7; 

class HPGLManager { 

  HPGL hpgl;
  Serial serial;
  float scaleToPlotter =1; 

  // the width and height of the plotter coordinate system
  float plotWidth = 16158; 
  float plotHeight = 11040; 
  float screenWidth = 800; 
  float screenHeight = 600; 
  int offsetX = 0;
  int offsetY = 0; 

  int accuracy = 2;
  int[] limits;
  PApplet pa; 
  color[] penColours = new color[8]; 

  boolean penIsDown; 
  PVector currentPosition = new PVector(-1, -1); 

  boolean initialised = false;
  ArrayList commands; 

  int currentPen = 1; 

  int currentCommand = 0; 

  boolean printing = false; 

  HPGLManager(PApplet pa) {

    this.pa = pa; 

    penIsDown = true; 

    updatePlotterScale();

    commands = new ArrayList();

    penColours[0] = color(255,0,0); 
    penColours[1] = color(255,128,0); 
    penColours[2] = color(255,255,0); 
    penColours[3] = color(0,255,0); 
    penColours[4] = color(0,255,255); 
    penColours[5] = color(0,0,255); 
    penColours[6] = color(100,0,255); 
    penColours[7] = color(255,64,128); 
    
  }



  boolean initHPGL() { 

    String[] interfaces = Serial.list(); 
    println(join(interfaces, "\n")); 
    int serialNumber = -1; 

    for (int i =0; i<interfaces.length; i++) { 

      if (interfaces[i].indexOf("tty.usbserial")>-1) {
        serialNumber = i;
      }
    }

    if (serialNumber!=-1) {
      println("FOUND USB SERIAL at index "+serialNumber);

      serial = new Serial(pa, interfaces[serialNumber]);
      hpgl = new HPGL(pa, serial);


      limits = (hpgl.hardClipLimits());
      println(limits[0]);
      println(limits[1]);
      println(limits[2]);
      println(limits[3]);
      plotWidth = limits[2]; 
      plotHeight = limits[3]; 

      hpgl.selectPen(1); 

      updatePlotterScale();
      //setVelocity(127); 
      hpgl.setCommandDelay(35);

      initialised = true; 

      return true;
    } else { 
      println("NO USB SERIAL DEVICE DETECTED");
      exit();
      return false;
    }
  }

  boolean update() {

    stroke(255); 
    noFill();
    //println(screenWidth, screenHeight);
    rect(0, 0, screenWidth-1, screenHeight-1); 

    renderCommands();

    if (!initialised) return false; 

    if ((printing) && (commands.size()>0)) { 

      processCommand(1); 


      if ((commands.size()%100) ==0) 
        println("COMMANDS TO PROCESS : " + commands.size()); 
      return true;
    } else { 
      return false ;
    }
  }

  void renderCommands() {

    noFill(); 
    stroke(255);

    boolean drawing = false; 
    for (int i = 0; i<commands.size(); i++) { 

      Command c = (Command)commands.get(i); 

      if (i==currentCommand) { 
        circleAtPoint(c);
      }
      //println(i, c.c); 
      if (c.c == COMMAND_MOVE) { 
        if (drawing) {
          endShape();
        }

        beginShape(); 

        screenVertex(c); 

        drawing = true;
      } else if (c.c == COMMAND_DRAW) { 

        screenVertex(c);
        drawing = true;
      } else if (c.c == COMMAND_PEN_CHANGE) { 
        if (drawing) {
          endShape(); 
          drawing = false; 
       }
       stroke(penColours[c.p1-1]); 
       
     }
     
   }

   if (drawing) {
    endShape(); 
        // println("endShape");
      }
    }

    void screenVertex(Command c) { 

      PVector p = new PVector(c.p1, c.p2); 
      p = plotterToScreen(p); 
      vertex(p.x, p.y); 
    //ellipse(p.x, p.y, 5, 5); 
    // println("vertex "+p.x + " " +p.y);
  }

  void circleAtPoint(Command c) { 

    PVector p = new PVector(c.p1, c.p2); 
    p = plotterToScreen(p); 
    //vertex(p.x, p.y); 
    ellipse(p.x, p.y, 5, 5); 
    // println("vertex "+p.x + " " +p.y);
  }
  void processCommand(int numCommands) { 

    int lastcommand = currentCommand+numCommands; 
    if (lastcommand>commands.size()) lastcommand = commands.size()-1; 
    int i; 
    for ( i = currentCommand; i<lastcommand; i++) { 
      Command c = (Command)commands.get(i); 
      //commands.remove(0); 
      if (c.c == COMMAND_MOVE) { 
        penUp(); 
        hpgl.plotAbsolute(c.p1 + offsetX, c.p2 + offsetY);
      } else if (c.c == COMMAND_DRAW) { 
        penDown(); 
        hpgl.plotAbsolute(c.p1 + offsetX, c.p2 + offsetY);
      } else if (c.c == COMMAND_VELOCITY) {
        setVelocity(c.p1);
      } else if (c.c == COMMAND_FORCE) {
        hpgl.forceSelect(c.p1);
      } else if (c.c == COMMAND_PEN_CHANGE) {
        hpgl.selectPen(c.p1);
      }
    }
    currentCommand = i; 
    if (currentCommand>=commands.size()) printing = false;
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
      scaleToPlotter = plotWidth/(float)width;
    } else { 
      scaleToPlotter = plotHeight/(float)height;
    } 

    screenWidth = (float)plotWidth/scaleToPlotter; 
    screenHeight = (float)plotHeight/scaleToPlotter;

    println("scaleToPlotter", scaleToPlotter); 
    println("screenWidth", screenWidth); 
    println("screenHeight", screenHeight);
  }

  void plotLine(PVector p1, PVector p2) { 

    moveTo(p1); 
    lineTo(p2);
  }

  void plotLine(float x1, float y1, float x2, float y2) { 
    plotLine(new PVector(x1, y1), new PVector(x2, y2));
  }


  void plotRect(float x, float y, float w, float h) { 
    plotLine(new PVector(x, y), new PVector(x+w, y));    
    plotLine(new PVector(x+w, y), new PVector(x+w, y+h));
    plotLine(new PVector(x+w, y+h), new PVector(x, y+h));
    plotLine(new PVector(x, y+h), new PVector(x, y));
  }

  void setVelocity(float v) { 
    if (!initialised) initHPGL();
    hpgl.rawCommand("VS"+v, false);
  }


  void penUp() {
    if (!penIsDown) return; 
    hpgl.penUp(); 
    penIsDown = false;
  }
  void penDown() {
    if (penIsDown) return; 
    hpgl.penDown(); 
    penIsDown = true;
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


  /*
  void plotterDrawCircle(Circle circle) { 
   
   int cx = round(circle.x * scaleToPlotter); 
   int cy = round(circle.y * scaleToPlotter); 
   int cr = round(circle.radius * scaleToPlotter); 
   
   hpgl.penUp();
   hpgl.plotAbsolute(cx, cy); 
   hpgl.penDown(); 
   hpgl.rawCommand("CI"+cr, false); 
   hpgl.penUp();
   }
   */

   void moveTo(PVector p) { 

    p = screenToPlotter(p); 
    if (currentPosition.dist(p)>accuracy) { 
      commands.add(new Command(COMMAND_MOVE, (int)p.x, (int)p.y));
      currentPosition.set(p);
    }
  }

  void moveTo(float x, float y) { 
    moveTo(new PVector(x, y));
  }
  void lineTo(float x, float y) { 
    lineTo(new PVector(x, y));
  }

  void lineTo(PVector p) { 
    p = screenToPlotter(p);

    if (currentPosition.dist(p)>accuracy) { 
      commands.add(new Command(COMMAND_DRAW, p.x, p.y));
      currentPosition.set(p);
    }
  }

  void plotPoint(float x, float y) { 
    plotPoint(new PVector(x, y));
  }
  void plotPoint(PVector p ) { 
    p = screenToPlotter(p);
    commands.add(new Command(COMMAND_MOVE, p.x, p.y));
    commands.add(new Command(COMMAND_DRAW, p.x+1, p.y));
  }

  void addForceCommand(int f) { 
    commands.add(new Command(COMMAND_FORCE, f, 0));
  }
  void addVelocityCommand(int v) { 
    commands.add(new Command(COMMAND_VELOCITY, v, 0));
  }
  void addPenCommand(int p) { 
    currentPen = p; 
    commands.add(new Command(COMMAND_PEN_CHANGE, p, 0));
  }

  PVector screenToPlotter(PVector screenPos) { 

    PVector plotterPos = screenPos.get();  

    plotterPos.z = 0; 
    plotterPos.mult(scaleToPlotter); 

    roundVector(plotterPos);

    plotterPos.y = plotHeight - (plotterPos.y);

    return plotterPos;
  }

  PVector plotterToScreen(PVector plotterPos) { 

    PVector screenPos = plotterPos.get();  

    screenPos.y = plotHeight - (screenPos.y);

    screenPos.z = 0; 
    screenPos.mult(1/scaleToPlotter); 
    screenPos.x+=offsetX; 
    screenPos.y+=offsetY; 

    return screenPos;
  }

  void startPrinting() { 
    printing=true;
  }
}


class Command { 

  int c; 
  int p1, p2;

  Command (int _c, int _p1, int _p2) { 

    set(_c, _p1, _p2);
  }

  Command (int _c, float _p1, float _p2) { 
    set(_c, round(_p1), round(_p2)) ;
  }

  void set(int _c, int _p1, int _p2) { 
    c = _c; 
    p1 = _p1; 
    p2 = _p2; 
    //println("CMD : "+c+" "+p1+" "+p2);
  }
};