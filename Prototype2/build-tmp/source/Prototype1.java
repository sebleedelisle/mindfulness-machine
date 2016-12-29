import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gab.opencv.*; 
import org.opencv.core.Mat; 
import geomerative.*; 
import java.util.Collections; 
import org.opencv.imgproc.Imgproc; 
import org.opencv.core.*; 
import gab.opencv.Contour; 
import java.util.Collections; 
import java.util.Comparator; 
import fup.hpgl.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Prototype1 extends PApplet {


 



PImage src, dst;
OpenCV opencv;

HPGLManager hpglManager; 

ArrayList<Contour> contours;
MatOfInt4 hierarchy;

ArrayList<RShape> shapes; 
ArrayList<RotatedRect> rects; 


public void setup() {

  hpglManager = new HPGLManager(this); 
  surface.setResizable(true);
  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);
  hpglManager.updatePlotterScale();
  
  RG.init(this); 
  getShapesForImage("test2.jpg"); 

  for (int i = 0; i<shapes.size(); i++) {

    RShape s = shapes.get(i);

    RG.shape(s);
    hpglManager.addPenCommand((i%8)+1); 
    ArrayList<Line> lines = getLinesForShape(s, rects.get(i)); 
    
    for (Line line : lines) { 
      //line.draw();
      PVector p1 = line.p1.copy(); 
      PVector p2 = line.p2.copy(); 
      PVector offset = new PVector(100,20); 
      float scale = 0.3f; 
      p1.add(offset); 
      p2.add(offset); 
      p1.mult(scale); 
      p2.mult(scale); 
      hpglManager.plotLine(p1, p2);
    }
  }
}


public void draw() {
      background(0); 
    image(dst, src.width, 0);
  //background(50); 
  //image(src, 0, 0);
   //if (hpglManager.printing) { 


  
    hpglManager.update();
 // }
}

public void getShapesForImage(String filename) { 

  shapes = new ArrayList<RShape>();
  rects = new ArrayList<RotatedRect>(); 

  src = loadImage(filename); 
  
  opencv = new OpenCV(this, src);

  opencv.gray();
  opencv.blur(3);
  opencv.threshold(50);
  dst = opencv.getOutput();

  contours = findContours(true);

  int index = 0; 
  int level = 0; 

  do { 

    Contour contour = contours.get(index); 
    contour.setPolygonApproximationFactor(1);
    double[] h  = hierarchy.get(0, index);
    RShape s = new RShape();
    boolean move = true; 
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      if (move) {
        move = false; 
        s.addMoveTo(point.x, point.y);
      } else { 
        s.addLineTo(point.x, point.y);
      }
    }
    s.addClose();
    if (level == 0 ) { 

      shapes.add(s);
      rects.add(getMinAreaRect(contour));
    } else { 
      RShape last = shapes.get(shapes.size()-1); 
      shapes.remove(shapes.size() - 1);
      last = RG.diff(last, s); 
      shapes.add(last);
    }


    if (h[2]>=0) { 
      // if we have a child, use that next
      index = (int)h[2];
      level++;
    } else if (h[0]>=0) { 
      // otherwise use the next in line
      index = (int)h[0];
    } else if (h[3]>=0) { 
      // otherwise if we have a parent, then go up a level, and 
      // use the parent's next sibling
      index = (int)h[3]; 
      h = hierarchy.get(0, index); 
      index = (int)h[0];
      level--;
    } else { 
      index = -1;
    }
  } while ((index>=0) && (index<contours.size()));
}

public ArrayList<Line> getLinesForShape(RShape s, RotatedRect boundingRect) { 

  // should prob be a param

  float penthickness = 8; 

  ArrayList<Line> lines = new ArrayList<Line>(); 

  noFill(); 
  //stroke(255); 

  // draw the shape
  RG.shape(s);

  RotatedRect rect = boundingRect.clone(); 

  // expand the bounding rectangle - not sure this is necessary
  rect.size.width+=10; 
  rect.size.height+=10; 
  drawRotatedRect(rect);

  // get points out of rotated rectangle
  Point[] points = new Point[4]; 
  // this rather obscurely named function puts the points from the rectangle
  // into the provided array. 
  rect.points(points); 

  // convert the first three points to PVectors and draw them
  PVector p1 = new PVector((float)points[0].x, (float)points[0].y);
  PVector p2 = new PVector((float)points[1].x, (float)points[1].y);
  PVector p3 = new PVector((float)points[2].x, (float)points[2].y);
  ellipse(p1.x, p1.y, 10, 10); 
  ellipse(p2.x, p2.y, 10, 10); 
  ellipse(p3.x, p3.y, 10, 10);

  // if second side is longer than first, switch them! 
  if (p1.dist(p2)<p2.dist(p3)) { 
    p3 = p1.copy(); 
    p1 = new PVector((float)points[2].x, (float)points[2].y);
  }


  // get vectors for the long side of the rectangle...
  PVector v1 = p2.copy(); 
  v1.sub(p1); 
  // ... and the short side
  PVector v2 = p3.copy(); 
  v2.sub(p2); 

  float len = v1.mag(); 

  // now iterate along the long side
  for (float d = 0; d<len; d+=penthickness) { 
    PVector start = v1.copy(); 
    start.mult(d/len); 
    start.add(p1); 
    PVector end = start.copy(); 
    end.add(v2); 


    RShape cuttingLine = RG.getLine(start.x, start.y, end.x, end.y); 
    RPoint[] tps = s.getIntersections(cuttingLine);
    if ((tps!=null) && (tps.length>1)) { 
      ArrayList<PVector> ps = new ArrayList<PVector>(); 

      for (int j = 0; j<tps.length; j++) { 
        PVector newp = new PVector(tps[j].x, tps[j].y); 
        if ((ps.size()<1)  || (newp.dist(ps.get(ps.size()-1))>0.01f)) ps.add(newp);
      }

      if (ps.size()<=1) continue;

      Collections.sort(ps, new IntersectionComparator(start));
      //stroke(255);
      //ellipse(start.x, start.y, 5, 5);

      if (ps.size()%2==1) {
        //stroke(255, 120);
        //strokeWeight(3); 
        println(d, "odd number of intersections! THIS SHOULDN'T HAPPEN!");
        //line(start.x, start.y, end.x, end.y);
        //strokeWeight(1);
        for (int j=0; j<ps.size(); j++) {
          println("\t"+j+" " +ps.get(j));
        }
      }

      for (int j=0; j<ps.size(); j+=2) {
        if (j+1>=ps.size()) { 
          break; //too many points for some reason
        } 
        stroke(255);
        PVector pt1 = ps.get(j); 
        PVector pt2 = ps.get(j+1); 
        //line(pt1.x, pt1.y, pt2.x, pt2.y); 
        lines.add(new Line(pt1, pt2)); 
        //ellipse(ps[j].x, ps[j].y, 2, 2);
      }

      //for (int j=0; j<ps.size(); j++) {
      //  stroke(j*60%255, 255, 255); 
      //  ellipse(ps.get(j).x, ps.get(j).y, 2, 2);
      //}
    }
  }
  return lines;
}

 
 




public double getOptimumColouringAngle(Contour c) { 


  return getMinAreaRect(c).angle;
}

public RotatedRect getMinAreaRect(Contour c) { 
  MatOfPoint src = c.pointMat;

  MatOfPoint2f dst = new MatOfPoint2f();
  src.convertTo(dst, CvType.CV_32F);


  return Imgproc.minAreaRect(dst);
}

public void drawRotatedRect(RotatedRect r) {

  pushMatrix(); 
  translate((float)r.center.x, (float)r.center.y); 
  rotate(radians((float)r.angle)); 
  rectMode(CENTER);
  rect(0, 0, (float)r.size.width, (float)r.size.height); 
  popMatrix();
}

public ArrayList<Contour> findContours(boolean findHoles) {

  hierarchy = new MatOfInt4();

  ArrayList<Contour> result = new ArrayList<Contour>();


  ArrayList<MatOfPoint> contourMat = new ArrayList<MatOfPoint>();


  try {
    int contourFindingMode = Imgproc.RETR_CCOMP;//(findHoles ? Imgproc.RETR_LIST : Imgproc.RETR_EXTERNAL);

    Imgproc.findContours(opencv.matGray, contourMat, hierarchy, contourFindingMode, Imgproc.CHAIN_APPROX_NONE);
  } 
  catch(CvException e) {
    PApplet.println("ERROR: findContours only works with a gray image.");
  }
  for (MatOfPoint c : contourMat) {
    result.add(new Contour(this, c));
  }
  println(hierarchy);

  // if (sort) {
  //   Collections.sort(result, new ContourComparator());
  // }

  return result;
}

public class IntersectionComparator implements Comparator<PVector> {

  public PVector startpoint; 
  public IntersectionComparator(PVector start) {
    startpoint = start.copy();
  }
  public int compare(PVector c1, PVector c2) {
    float dist1 = startpoint.dist(c1); 
    float dist2 = startpoint.dist(c2); 

    if (dist1==dist2) {
      return 0;
    } else if (dist1<dist2) {
      return -1;
    } else {
      return 1;
    }
  }
}




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
  int[] penColours = new int[8]; 

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



  public boolean initHPGL() { 

    
    
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

  public boolean update() {
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

  public void renderCommands() {
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
        stroke(penColours[c.p1-1]); 
       
      }
     
    }
    
     if (drawing) {
        endShape(); 
        // println("endShape");
      }
  }

  public void screenVertex(Command c) { 

    PVector p = new PVector(c.p1, c.p2); 
    p = plotterToScreen(p); 
    vertex(p.x, p.y); 
    //ellipse(p.x, p.y, 5, 5); 
    // println("vertex "+p.x + " " +p.y);
  }

  public void circleAtPoint(Command c) { 

    PVector p = new PVector(c.p1, c.p2); 
    p = plotterToScreen(p); 
    //vertex(p.x, p.y); 
    ellipse(p.x, p.y, 5, 5); 
    // println("vertex "+p.x + " " +p.y);
  }
  public void processCommand(int numCommands) { 

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

  public void setOffset(float xMils, float yMils) { 
    offsetX = round( xMils * (plotHeight/275)); 
    offsetY = round( -yMils * (plotHeight/275));
  }
  public void updatePlotterScale() { 

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

  public void plotLine(PVector p1, PVector p2) { 

    moveTo(p1); 
    lineTo(p2);
  }

  public void plotLine(float x1, float y1, float x2, float y2) { 
    plotLine(new PVector(x1, y1), new PVector(x2, y2));
  }


  public void plotRect(float x, float y, float w, float h) { 
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

  public void setVelocity(float v) { 
    if (!initialised) initHPGL();

    hpgl.rawCommand("VS"+v, false);
  }


  public void penUp() {
    if (!penIsDown) return; 
    hpgl.penUp(); 
    penIsDown = false;
  }
  public void penDown() {
    if (penIsDown) return; 
    hpgl.penDown(); 
    penIsDown = true;
  }

  public void roundVector(PVector p) { 
    p.x = round(p.x); 
    p.y = round(p.y);
    p.z = 0;
  }

  public void close() { 
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

  public void moveTo(PVector p) { 

    //println("moveTo "+p+" " + currentPosition.dist(p)); 

    p = screenToPlotter(p); 
    if (currentPosition.dist(p)>accuracy) { 
      commands.add(new Command(COMMAND_MOVE, (int)p.x, (int)p.y));
      currentPosition.set(p);
    }
  }

  public void moveTo(float x, float y) { 
    moveTo(new PVector(x, y));
  }
  public void lineTo(float x, float y) { 
    lineTo(new PVector(x, y));
  }

  public void lineTo(PVector p) { 
    p = screenToPlotter(p);

    //println("lineTo "+p+" " + currentPosition.dist(p)); 

    if (currentPosition.dist(p)>accuracy) { 
      commands.add(new Command(COMMAND_DRAW, p.x, p.y));
      currentPosition.set(p);
    }
  }

  public void plotPoint(float x, float y) { 
    plotPoint(new PVector(x, y));
  }
  public void plotPoint(PVector p ) { 
    p = screenToPlotter(p);
    commands.add(new Command(COMMAND_MOVE, p.x, p.y));
    commands.add(new Command(COMMAND_DRAW, p.x+1, p.y));
  }

  public void addForceCommand(int f) { 
    commands.add(new Command(COMMAND_FORCE, f, 0));
  }
  public void addVelocityCommand(int v) { 
    commands.add(new Command(COMMAND_VELOCITY, v, 0));
  }
  public void addPenCommand(int p) { 
    currentPen = p; 
    commands.add(new Command(COMMAND_PEN_CHANGE, p, 0));
  }

  public PVector screenToPlotter(PVector screenPos) { 

    PVector plotterPos = screenPos.get();  

    plotterPos.z = 0; 
    plotterPos.mult(scaleToPlotter); 

    roundVector(plotterPos);

    plotterPos.y = plotHeight - (plotterPos.y);

    return plotterPos;
  }

  public PVector plotterToScreen(PVector plotterPos) { 

    PVector screenPos = plotterPos.get();  

    screenPos.y = plotHeight - (screenPos.y);

    screenPos.z = 0; 
    screenPos.mult(1/scaleToPlotter); 
    screenPos.x+=offsetX; 
    screenPos.y+=offsetY; 


    //roundVector(plotterPos);



    return screenPos;
  }

  public void startPrinting() { 
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

  public void set(int _c, int _p1, int _p2) { 
    c = _c; 
    p1 = _p1; 
    p2 = _p2; 
    //println("CMD : "+c+" "+p1+" "+p2);
  }
};


Boolean controlPressed = false; 
public void keyPressed() { 


  if (key == 'h') {
    println("INIT"); 
    hpglManager.initHPGL();
  } else if (key == 'p') {
    println("PRINT"); 

    hpglManager.startPrinting();
  } else if (key == 't') {
  } else if (key == '-') {
  } else if (key == '=') {
  } else if (key =='w') {
  } else if (keyCode == RIGHT) {
  } else if (keyCode == LEFT) {
  } else if (keyCode == UP) {
  } else if (keyCode == DOWN) {
  } else if (key=='l') {
  }
}
class Line { 

  public PVector p1; 
  public PVector p2;
  
  public Line(PVector start, PVector end) { 
    p1 = start.copy(); 
    p2 = end.copy(); 
  }
  public void draw() { 
     line(p1.x, p1.y, p2.x, p2.y);  
    
  }
}

float glyphWidth = 4, glyphHeight = 6, glyphSpacing = 2;

PVector letterOffset = new PVector(); 
PVector letterScale = new PVector(1, 1); 
//PVector letterPoint = new PVector(0, 0); 
boolean penUp = true; 
boolean sendToPlotter = false; 

public void plotText(String textToPlot, float xpos, float ypos, float scaleFactor) { 
  plotText(textToPlot, xpos, ypos, scaleFactor, false);
}
public void plotText(String textToPlot, float xpos, float ypos, float scaleFactor, boolean sendtoplotter) { 

  sendToPlotter = sendtoplotter; 

  glyphWidth = 4 * scaleFactor; 
  glyphHeight = 6 * scaleFactor; 
  glyphSpacing = 2 * scaleFactor;


  textToPlot = textToPlot.toUpperCase();
  for ( int i = 0; i < textToPlot.length(); i++ ) {
    drawGlyph(textToPlot.charAt(i), xpos, ypos);
    xpos += glyphWidth + glyphSpacing;
  }
}


public void drawGlyph(char glyph, float posX, float posY) {

  letterOffset.set(posX, posY, 0); 


  //stroke(255);
  //strokeWeight(1);
  letterScale.set(glyphWidth / 4.0f, glyphHeight / 6.0f, 0);
  drawLetter(glyph);
}

public void drawLetter(char letter) {
  penUp = true; 
  if ( letter == 'A' ) {
    plotLine(0, 6, 0, 1);
    plotLine(0, 1, 2, 0);
    plotLine(2, 0, 4, 1);
    plotLine(4, 1, 4, 6);
    plotLine(4, 3, 0, 3);
  }

  if ( letter == 'B' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 3, 6);
    plotLine(3, 6, 4, 5);
    plotLine(4, 5, 4, 4);
    plotLine(4, 4, 3, 3);
    plotLine(3, 3, 0, 3);
    plotLine(0, 3, 3, 3);
    plotLine(3, 3, 4, 2);
    plotLine(4, 2, 4, 1);
    plotLine(4, 1, 3, 0);
    plotLine(3, 0, 0, 0);

    
  }
  if ( letter == 'C' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == 'D' ) {
    plotLine(0, 0, 3, 0);
    plotLine(3, 0, 4, 2);
    plotLine(4, 2, 4, 4);
    plotLine(4, 4, 3, 6);
    plotLine(3, 6, 0, 6);
    plotLine(0, 6, 0, 0);
  }
  if ( letter == 'E' ) {

    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 3, 0, 3);
  }
  if ( letter == 'F' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 3, 4, 3);
  }
  if ( letter == 'G' ) {
    plotLine(4, 1, 4, 0);
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 6, 4, 3);
    plotLine(4, 3, 2, 3);
  }
  if ( letter == 'H' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 3, 4, 3);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == 'I' ) {
    plotLine(0, 0, 4, 0);
    plotLine(2, 0, 2, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == 'J' ) {
    plotLine(0, 4, 1, 6);
    plotLine(1, 6, 4, 6);
    plotLine(4, 6, 4, 0);
    plotLine(4, 0, 2, 0);
  }
  if ( letter == 'K' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 3, 4, 0);
    plotLine(0, 3, 4, 6);
  }
  if ( letter == 'L' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == 'M' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 2, 2);
    plotLine(2, 2, 4, 0);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == 'N' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 0, 1);
    plotLine(0, 1, 4, 5);
    plotLine(4, 5, 4, 6);
    plotLine( 4, 6, 4, 0);
  }
  if ( letter == 'O' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
    plotLine(4, 6, 0, 6);
    plotLine(0, 6, 0, 0);
  }
  if ( letter == 'P' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 0, 3);
  }
  if ( letter == 'Q' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 4);
    plotLine(4, 4, 2, 6);
    plotLine(2, 6, 0, 6);
    plotLine(0, 6, 0, 0);
    plotLine(2, 4, 4, 6);
  }
  if ( letter == 'R' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 4, 6);
  }
  if ( letter == 'S' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 3);
    plotLine(0, 3, 4, 3);
    plotLine(4, 3, 4, 6);
    plotLine(4, 6, 0, 6);
  }
  if ( letter == 'T' ) {
    plotLine(0, 0, 4, 0);
    plotLine(2, 0, 2, 6);
  }
  if ( letter == 'U' ) {
    plotLine(0, 0, 0, 5);
    plotLine(0, 5, 1, 6);
    plotLine(1, 6, 3, 6);
    plotLine(3, 6, 4, 5);
    plotLine(4, 5, 4, 0);
  }
  if ( letter == 'V' ) {
    plotLine(0, 0, 2, 6);
    plotLine(2, 6, 4, 0);
  }
  if ( letter == 'W' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 2, 4);
    plotLine(2, 4, 4, 6);
    plotLine(4, 6, 4, 0);
  }
  if ( letter == 'X' ) {
    plotLine(0, 0, 2, 3);
    plotLine(2, 3, 0, 6);
    plotLine(4, 0, 2, 3);
    plotLine(2, 3, 4, 6);
  }
  if ( letter == 'Y' ) {
    plotLine(0, 0, 2, 2);
    plotLine(2, 2, 4, 0);
    plotLine(2, 2, 2, 6);
  }
  if ( letter == 'Z' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == '0' ) {
    plotLine(0, 6, 4, 0);
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 6, 4, 0);
  }
  if ( letter == '1' ) {
    plotLine(0, 0, 2, 0);
    plotLine(2, 0, 2, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == '2' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == '3' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
    plotLine(4, 6, 0, 6);
    plotLine(0, 3, 4, 3);
  }
  if ( letter == '4' ) {
    plotLine(0, 0, 0, 3);
    plotLine(0, 3, 4, 3);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == '5' ) {
    //plotLine(0, 0, 0, 0);

    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 3);
    plotLine(0, 3, 4, 3);
    plotLine(4, 3, 4, 6);
    plotLine(4, 6, 0, 6);
  }
  if ( letter == '6' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 6, 4, 3);
    plotLine(4, 3, 0, 3 );
  }
  if ( letter == '7' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == '8' ) {
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 4, 6);
    plotLine(4, 6, 0, 6);
    plotLine(0, 6, 0, 3);
  }
  if ( letter == '9' ) {
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == '!' ) {
    plotLine(2, 0, 2, 4);
    plotLine(2, 5, 2, 6);
  }
  if ( letter == ':' ) {
    plotLine(2, 1.5f, 2, 2.5f);
    plotLine(2, 4.5f, 2, 5.5f);
  }
  if ( letter == '.' ) {
    plotLine(2, 5, 2, 6);
  }
  if ( letter ==',') {
    plotLine(2, 5, 2, 7);
  }
  if (letter == '#') {
    plotLine(1, 1, 1, 5);
    plotLine(0, 2, 4, 2);
    plotLine(0, 4, 4, 4);
    plotLine(3, 1, 3, 5);
  }
  if (letter =='-') {
    plotLine(1, 3, 3, 3);
  }
  if (letter =='_') {
    plotLine(0, 6, 4, 6);
  }

  if (letter == '/') {
    plotLine(0, 6, 4, 0);
  }
  endShape();
}

public void plotLine(float x1, float y1, float x2, float y2) { 
  //line(x1*letterScale.x + letterOffset.x, y1*letterScale.y + letterOffset.y, x2*letterScale.x + letterOffset.x, y2*letterScale.y + letterOffset.y) ; 

  PVector p1 = new PVector(x1*letterScale.x + letterOffset.x, y1*letterScale.y + letterOffset.y); 
  PVector p2 = new PVector(x2*letterScale.x + letterOffset.x, y2*letterScale.y + letterOffset.y); 

  if (sendToPlotter) { 
    hpglManager.plotLine(p1.x, p1.y, p2.x, p2.y);
  } else { 
    line(p1.x, p1.y, p2.x, p2.y);
  }


  //letterPoint.set(p2);
}




public float clamp(float v, float minV, float maxV) { 
    return max(minV, min(maxV, v));
} 


public int clamp(int v, int minV, int maxV) { 
    return max(minV, min(maxV, v));
} 
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Prototype1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
