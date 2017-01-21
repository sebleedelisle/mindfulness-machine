
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
  }



  boolean initHPGL() { 

    String[] interfaces = Serial.list(); 
    println(join(interfaces, "\n")); 
    int serialNumber = -1; 

    for (int i =0; i<interfaces.length; i++) { 

      if (interfaces[i].indexOf("tty.Repleo-PL2303")>-1) {
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
    renderCommands();

    stroke(255); 
    noFill();
    rect(0, 0, screenWidth-1, screenHeight-1); 

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
      //println(c.c); 
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
        if (c.p1==0) stroke(128); 
        else stroke(255, 140, 0);
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

    println(scaleToPlotter); 
    println(screenWidth); 
    println(screenHeight);
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

  //if (!initialised) initHPGL();
  // clone before we fuck with them

  //
  //
  //    p1 = screenToPlotter(p1); 
  //    p2 = screenToPlotter(p2);
  //
  //    if (currentPosition.dist(p1)>0) { 
  //      //penUp(); 
  //      //hpgl.plotAbsolute
  //      moveTo((int)p1.x, (int)p1.y);
  //    }
  //    //penDown(); 
  //    //hpgl.plotAbsolute
  //    lineTo((int)p2.x, (int)p2.y);
  //  }
  //}

  //  void plot(PVector p) { 
  //
  //    //p = screenToPlotter(p); 
  //
  //    if (p.dist(currentPosition) == 0) return; 
  //
  //    hpgl.plotAbsolute((int)(p.x), (int)(p.y));
  //    currentPosition.set(p);
  //  }
  //  void plot(int x, int y) { 
  //    hpgl.plotAbsolute(x, y);
  //    
  //  }

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

    //println("moveTo "+p+" " + currentPosition.dist(p)); 

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

    //println("lineTo "+p+" " + currentPosition.dist(p)); 

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


    //roundVector(plotterPos);



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



PVector getPointAtRectIntersection(Rectangle r, PVector p1, PVector p2) { 

    if (r.containsPoint(p1) && r.containsPoint(p2)) { 
        println("WARNING - both points are inside rectangle - no intersection");
    } else if (!r.containsPoint(p1) && !r.containsPoint(p2)) { 
        println("WARNING - neither point is within rectangle - no intersection");
    } 

    // need to make sure p1 is the one that is outside the rectangle. 
    if (r.containsPoint(p1)) { 
        PVector t = p1; 
        p1 = p2; 
        p2 = t;
    }
    PVector v = p2.copy(); 
    v.sub(p1); 

    PVector intersect = p1.copy(); 
    intersect.x = clamp(p1.x, r.x, r.getRight());
    intersect.y = clamp(p1.y, r.y, r.getBottom());  

    //ellipse(intersect.x, intersect.y, 2,2);
    float intersectionPoint = 1; 
    if ((intersect.x == r.x) || (intersect.x == r.getRight())) {
        // left or right side intersected
        float newIntersectionPoint = map(intersect.x, p1.x, p2.x, 0, 1);
        if (newIntersectionPoint<intersectionPoint) intersectionPoint = newIntersectionPoint;
    } 
    if ((intersect.y == r.y) || (intersect.y == r.getBottom())) {
        // top or bottom side intersected
        float newIntersectionPoint = map(intersect.y, p1.y, p2.y, 0, 1);
        if (newIntersectionPoint<intersectionPoint) intersectionPoint = newIntersectionPoint;
    } 
    v.mult(intersectionPoint);
    v.add(p1); 
    return v;
}


PVector getPositionAtX(PVector p1, PVector p2, float x) { 
    PVector v = p2.copy(); 
    v.sub(p1); 
    v.mult(map(x, p1.x, p2.x, 0, 1)); 
    v.add(p1); 
    return v;
}


void drawStarRandom(float x, float y, float size) { 
    //hpgl.penUp();
    float startAngle = random(360); 
    PVector startPoint = new PVector(0, 0); 
    for (float a = 0; a<=720; a+=720/5) {

        float thisSize = random(size*0.8, size);
        PVector p = new PVector(round(x + (thisSize*cos(radians(a+startAngle)))), round(y+ (thisSize*sin(radians(a+startAngle))))); 
        if (a == 0) { 
            startPoint = p;
            hpglManager.moveTo(p); 
            //hpglManager.lineTo(p);
        } else { 
            hpglManager.lineTo(p);
        }
    }
    hpglManager.lineTo(startPoint);
}

void drawStarSimple(float x, float y, float size) { 
    //hpgl.penUp();
    float startAngle = random(360); 

    for (float a = 0; a<=120; a+=60) {

        float thisSize = random(size*0.6, size*0.8);
        PVector p = new PVector(round(x + (thisSize*cos(radians(a+startAngle)))), round(y+ (thisSize*sin(radians(a+startAngle))))); 
        hpglManager.moveTo(p); 
        //hpglManager.lineTo(p); 
        p = new PVector(round(x + (thisSize*cos(radians(a+startAngle+180)))), round(y+ (thisSize*sin(radians(a+startAngle+180))))); 
        hpglManager.lineTo(p);
    }
}


void warmUpPen() { 
    warmUpPen(15);
}
void warmUpPen(int numLines) { 


    hpglManager.addVelocityCommand(5);
    float size = height/5; 
    PVector p = new PVector(); 
    PVector lastPoint = new PVector(); 
    hpglManager.moveTo(0, 0); 

    for (int i = 0; i<numLines; i++) { 

        // if(i==0)   hpglManager.moveTo(p); 

        while ( (p.dist (lastPoint)< (size/5)) || (size-p.x<p.y)) {    
            p.set(random(size), random(size));
        }

        hpglManager.lineTo(p); 
        lastPoint.set(p);
    }
}


class Rectangle { 

  float x, y, w, h; 
  Rectangle(float x, float y, float w, float h) { 
    set(x, y, w, h);
  }

  void set(float x, float y, float w, float h) {

    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }

  float getRight() { 
    return x+w;
  }
  float getBottom() { 
    return y+h;
  }

  void render() { 

    rect(x, y, w, h);
  }

  boolean containsPoint(PVector p) { 
    return((p.x<getRight()) && (p.x>x) && (p.y<getBottom()) && (p.y>y));
  }
}