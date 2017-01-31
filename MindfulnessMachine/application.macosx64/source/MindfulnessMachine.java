import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import processing.video.*; 
import gab.opencv.*; 
import java.io.BufferedWriter; 
import java.io.FileWriter; 
import java.awt.geom.Area; 
import java.awt.Shape; 
import java.awt.Polygon; 
import java.awt.geom.Path2D; 
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D; 
import java.awt.geom.Ellipse2D; 
import java.awt.geom.PathIterator; 
import java.awt.geom.FlatteningPathIterator; 
import java.awt.geom.AffineTransform; 
import java.util.List; 
import java.awt.geom.Area; 
import java.awt.Shape; 
import java.awt.geom.Path2D; 
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D; 
import java.awt.geom.Ellipse2D; 
import java.awt.geom.Rectangle2D; 
import java.awt.geom.RoundRectangle2D; 
import java.awt.Polygon; 
import java.awt.geom.PathIterator; 
import java.awt.geom.FlatteningPathIterator; 
import java.awt.geom.AffineTransform; 
import java.util.List; 
import java.util.Collections; 
import java.util.List; 
import java.util.Comparator; 
import java.awt.Shape; 
import java.awt.geom.Line2D; 
import java.awt.Rectangle; 
import java.util.Collections; 
import de.erichseifert.gral.util.GeometryUtils; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MindfulnessMachine extends PApplet {









final int STATE_CAMERA_SETUP = 0; 
final int STATE_WAIT_PENS = 1; 
final int STATE_WAIT_RECALIBRATE = 2; 
final int STATE_PEN_TEST = 3; 
final int STATE_PEN_TEST_FAILED = 4; 
final int STATE_WAIT_PAPER = 5; 
final int STATE_PRE_DRAWING = 6; 
final int STATE_DRAWING = 7;

final int numTypes = 4; 

boolean TEST_MODE = true;  
//boolean paused = false; 

int state = STATE_CAMERA_SETUP; 
int lastStateChangeTime = 0; 
Plotter plotter; 
MoodManager moodManager; 
ColourChooser colourChooser; 

List<ShapeData> shapes;

PImage plotterGuide; 

float xzoom = 0;
float yzoom =0;
float zoom =1; 
int shapenum = 0; 
int currentColourShape = 0; 
int drawingNumber; // for keeping track of the number for prints
int drawingsPerPenChange = 6; 

boolean finishedDrawing = false; 

int[] colours = new int[11]; 

String currentDateString =""; 

PFont consoleFont; 
PFont bodyFont; 
PFont titleFont; 

PVector previewPos = new PVector(0,0);
PVector previewTargetPos = new PVector(0,0); 


public void setup() { 

  //fullScreen(); 
   
  
  plotterGuide = loadImage("images/PlotterGuide.png");
  loadState(); 
  consoleFont = loadFont("fonts/BitstreamVeraSansMono-Bold-12.vlw");
  bodyFont = loadFont("fonts/BitstreamVeraSansMono-Bold-16.vlw");
  titleFont = loadFont("fonts/AvenirNextCondensed-DemiBoldItalic-48.vlw");

  setConsoleFont();

  moodManager = new MoodManager(this); 
  plotter = new Plotter(this, width, height); 
  if (TEST_MODE) {
    plotter.dry = true; 
    //moodManager.timeSpeed = 1000;
  }
  plotter.addVelocityCommand(1); 



  colourChooser = new ColourChooser(this); 




  for (int i = 0; i<8; i++) { 
    plotter.setPenThicknessMM(i, 0.8f);
  }

  plotter.connectToSerial("usbserial");
}


public void setTitleFont() { 
  textFont(titleFont); 
  textSize(48);
} 
public void setBodyFont() { 
  textFont(bodyFont); 
  textSize(16);
} 

public void setConsoleFont() { 
  textFont(consoleFont); 
  textSize(12);
}
public void changePens() { 
  colourChooser.getSelectionByNumber(floor(drawingNumber/drawingsPerPenChange)); 
  for (int i = 0; i<7; i++) { 
    plotter.setPenColour(i, colourChooser.getColourForPenNum(i) );
    if (drawingNumber%drawingsPerPenChange ==0)  plotter.resetPen(i);
  }
  plotter.setPenColour(7, 0xff000000);
  if ((drawingNumber%drawingsPerPenChange ==0)&&(colourChooser.replaceBlack)) plotter.resetPen(7);
}

public void loadState() { 

  String[] data = loadStrings("data/IssueNum.txt"); 
  if (data==null) { 
    drawingNumber = 0;
  } else { 
    drawingNumber = PApplet.parseInt(data[0]);
  }

  data = loadStrings("data/TestMode.txt"); 
  if (data==null) { 
    TEST_MODE = false;
  } else { 
    TEST_MODE = PApplet.parseInt(data[0])!=0;
  }
}
public void saveState() { 

  String[] data = {str(drawingNumber)}; 
  saveStrings("data/IssueNum.txt", data);
}
public void draw() { 

  moodManager.update();
  currentDateString = moodManager.getCurrentDateString();
  plotter.update();

  switch(state) { 
  case STATE_CAMERA_SETUP : 

    background(0); 
    moodManager.renderCamera(0, 0, width, height); 

    pushStyle(); 
    textAlign(CENTER, CENTER); 

    for (int i =0; i<10; i++) {
      pushMatrix(); 
      if (i<9) { 
        translate((i%3)*2-2, floor(i/3f)*2-2); 
        fill(0, 128);
      } else fill(255); 

      setTitleFont(); 
      text("ADJUST CAMERA", width/2, 120); 
      setBodyFont();
      text("MOVE CAMERA UNTIL THE PLOTTER IS ALIGNED WITH THE GUIDES\n\nPRESS SPACE TO CONTINUE", width/2, 200); 
      popMatrix();
    }

    blendMode(ADD); 
    image(plotterGuide, 0, 0); 
    popStyle(); 



    break;

    // screen that says to check the pens or change them
  case STATE_WAIT_PENS : 
    background(0); 
    //updatePenColours();
    fill(255); 
    textAlign(CENTER, TOP); 
    setTitleFont(); 

    // boolean replacePens = (drawingNumber%drawingsPerPenChange==0);
    // this needs to happen when pen wait starts
    //text("DRAWING #"+drawingNumber, width/2, 200);

    text("PEN CHANGE REQUIRED", width/2, 300);
    setBodyFont();

    text("PLEASE CHANGE PENS TO THE COLOURS INDICATED\n(USING BOX "+(colourChooser.currentPenBox+1)+")\n\n AND PRESS SPACE TO CONTINUE", width/2, 400);
    colourChooser.renderPens(100, 100, 60, 800, true, true);


    break; 
  case STATE_WAIT_RECALIBRATE : 
    background(0); 

    renderTopSectionData(); 


    fill(255); 
    textAlign(CENTER, TOP); 
    setTitleFont(); 
    text("RECALIBRATE", width/2, 480);

    setBodyFont(); 
    // this needs to happen when pen wait starts

    text("PLEASE RECALIBRATE THE PLOTTER\n\nPRESS THE BUTTON ON THE PLOTTER MARKED 'ENTER' AND BEFORE YOU \nLET GO PRESS THE 'VIEW' BUTTON AND THEN RELEASE BOTH\n\n PRESS SPACE TO CONTINUE", width/2, 590);

    break; 
    // test the pen change system, pen test has started, we're waiting for it
  case STATE_PEN_TEST : 
    background(0); 

    setBodyFont();
    colourChooser.renderPens(100, 100, 60, 800, true, false);

    fill(255); 
    textAlign(CENTER, TOP); 
    setTitleFont(); 

    if (!plotter.finished || plotter.waiting) { 
      text("TESTING PEN CHANGE SYSTEM, PLEASE WAIT", width/2, 300);
    } else {
      text("PEN CHANGE TEST FINISHED", width/2, 300);
      setBodyFont();
      text("ARE ALL PENS IN THEIR RESPECTIVE PEN HOLDERS (1-8)\n AND IS THE MOVING PEN HOLDER EMPTY?", width/2, 400);
      text("IF YES, PRESS SPACE\nIF NOT, PRESS THE <N> KEY", width/2, 600);
    }


    break; 
  case STATE_PEN_TEST_FAILED : 
    background(0); 

    //renderTopSectionData(); 

    fill(255); 
    textAlign(CENTER, TOP); 

    setTitleFont(); 
    text("RESET PENS AND PLOTTER", width/2, 300); 
    setBodyFont(); 
    String instructions = "STEP ONE : \nIF PEN IS IN THE MOVING PEN HOLDER TAKE IT OUT\nAND PUT IT IN ITS NUMBERED PEN HOLDER ON THE LEFT\n\n"; 
    instructions = instructions+"STEP TWO : \nMAKE SURE ALL PENS ARE IN THE CORRECT PEN HOLDERS ON THE LEFT\n\n";
    instructions = instructions+"STEP THREE : \nRECALIBRATE AGAIN : PRESS THE BUTTON ON THE PLOTTER MARKED 'ENTER' AND BEFORE YOU \nLET GO PRESS THE 'VIEW' BUTTON AND THEN RELEASE BOTH\n\n"; 
    instructions = instructions+"THEN PRESS SPACE TO RETEST THE PEN CHANGE SYSTEM"; 

    text(instructions, width/2, 400);

    colourChooser.renderPens(100, 100, 60, 800, true, false);


    break; 
  case STATE_WAIT_PAPER : 

    background(0); 



    renderProgressBottomLeft();


    renderTopSectionData(); 

    fill(map(sin(millis()*0.01f), -1, 1, 128, 255)); 
    textAlign(CENTER, TOP); 
    setTitleFont(); 
    text("CHANGE PAPER", width*0.75f, height/2+50); 
    setBodyFont();  
    fill(225);//,230,234); 

    String label = "STEP 1 : TURN OFF 'PAPER HOLD' ON THE PLOTTER (RED LIGHT SHOULD GO OUT),\n\n" +
                   "STEP 2 : REMOVE THE CURRENT DRAWING AND POST ON WALL.\n\n" +
                   "STEP 3 : PLACE BLANK SHEET ON THE PLOTTER BED, LINE UP WITH THE PLACEMENT MARKINGS\n" + 
                   "AND THEN TURN ON THE PAPER HOLD BUTTON (RED LIGHT COMES ON).\n\n"+
                   "PRESS SPACE TO CONTINUE";
                    
    text(label, width*0.75f, height/2+120); 
    
    break;


  case STATE_DRAWING : 


    if ((plotter.finished) && (!finishedDrawing)) { 
      boolean moreToGo = true; 

      moreToGo = colourNextShape();
      if (moreToGo) {
        plotter.startPrinting();
      } else { 
        finishedDrawing = true;
      }
    }  
    // note no break... 
  case STATE_PRE_DRAWING : 
    background(0); 



    if (state == STATE_PRE_DRAWING) {
      if (millis()-lastStateChangeTime > 5000/moodManager.timeSpeed) { 
        changeState(STATE_DRAWING);
      } else { 
        // println("HELLO"); 
        textAlign(CENTER, CENTER);
        setTitleFont(); 
        fill(map(sin(millis()*0.01f), -1, 1, 128, 255)); 

        text("THINKING... PLEASE WAIT", width*0.75f, height/2+100);
      }
      renderProgressBottomLeft(); 
    } else if (finishedDrawing) { 

      //changeState(STATE_WAIT_PAPER); // TODO make function called plotFinished
      //println("PRINT FINISHED AT ", moodManager.getCurrentDateString());
      fill(map(sin(millis()*0.01f), -1, 1, 128, 255)); 
      textAlign(CENTER, CENTER); 
      setTitleFont(); 
      text("STAFF ASSISTANCE REQUIRED", width*0.75f, height/2+100); 
      setConsoleFont();  
      fill(225);//,230,234); 

      text("CHANGE PAPER AND PRESS SPACE TO CONTINUE", width*0.75f, (height/2)+150);
      renderProgressBottomLeft(); 
    } else { 
          renderProgressBottom(); 

    }



  

    //pushMatrix(); 
    //translate(1920f*2f/3f, 400); 
    //scale(0.4, 0.4);

    //fill(250); 
    //rect(0, 0, plotter.screenWidth, plotter.screenHeight); 
    //for (int i = 0; i<shapes.size(); i++) { 
    //  stroke(0); 
    //  fill(plotter.getPenColour(shapes.get(i).getPenNumber())); 
    //  drawPath(shapes.get(i).getShape());
    //}

    //popMatrix();



    renderTopSectionData(); 

    break;
  }


  if (TEST_MODE) { 
    fill(0); 
    rect(0, 0, 100, 20); 
    fill(255); 
    textAlign(LEFT, TOP);
    textSize(12); 
    text("TEST_MODE", 3, 3);
  }
  fill(255); 
  textSize(14);
  text(getShapesRemaining(), 10, 100);
}

public void renderProgressBottom() {  
  renderProgressBottomLeft(); 
  
  ////previewPos;
  
  //pushMatrix(); 
  //translate(16, 400); 
  ////scale(0.6, 0.6); 

  //float imageheight = 680; 
  
  
  ////plotter.renderProgress();
  //CommandRenderer cr = plotter.progressImage; 
  //PVector penPos = cr.penPos; 
  
  //float top = previewPos.y; 
  //float bottom = previewPos.y+imageheight; 
  //if(penPos.y<top) previewPos.y = cr.penPos.y; 
  //else if(penPos.y>bottom) previewPos.y = cr.penPos.y-imageheight; 
  

  ////translate(0,-previewPos.y); 
  
  //PGraphics g = cr.g; 

  //cr.endDrawing();
  //  //scale(0.5,0.5); 
  //image(g, 0, 0);
  //stroke(255,0,0); 
  //noFill(); 
  //rectMode(CORNER);
  //rect(0,previewPos.y, 1920,imageheight);
  
    
  //popMatrix(); 
  
 
}

public void renderProgressBottomLeft() {  
  pushMatrix(); 
  translate(16, 400); 
  scale(0.6f, 0.6f); 

  plotter.renderProgress();
  popMatrix();
}

public void renderTopSectionData() {
  fill(0); 
  rect(0, 0, width, 384+32); 
  setConsoleFont(); 
  moodManager.draw(consoleFont, bodyFont);

  pushMatrix(); 
  pushStyle(); 
  translate(1400, 50);
  textAlign(LEFT, CENTER); 
  textSize(10); 
  colourChooser.renderPens(0, 0, 40, 300);
  for (int i = 0; i<8; i++) { 
    float y = map(i, 7, 0, 20, 280); 
    text(nf(plotter.getPenDistance(i)*0.001f, 0, 2), 50, y);
  }
  popStyle();
  popMatrix();
}


public boolean colourNextShape() { 

  if (currentColourShape<0) {
    currentColourShape = 0;
  } else {
    ShapeData currentShape = shapes.get(currentColourShape); 

    PVector p1 = getEndPoint(currentShape.shape);

    int closestShapeNum=-1; 
    float closestDistance = Float.MAX_VALUE; 
    float closestSameColourDistance = Float.MAX_VALUE; 
    int closestShapeNumSameColour = -1; 

    for (int i = 0; i<shapes.size(); i++) { 
      ShapeData shape = shapes.get(i); 
      if ((shape == currentShape)||shape.colouredIn) continue;

      PVector p2 =  getStartPoint(shape.shape);

      float distance = p1.dist(p2); 
      if (distance<=closestDistance) {
        closestShapeNum = i; 
        closestDistance = distance;
      }

      if (shape.penNumber==currentShape.penNumber) { 
        if (distance<=closestSameColourDistance) {
          closestShapeNumSameColour = i; 
          closestSameColourDistance = distance;
        }
      }
    }

    if (closestShapeNum>=0) { 
      if (closestShapeNumSameColour>=0) {
        currentColourShape = closestShapeNumSameColour;
      } else {
        currentColourShape = closestShapeNum;
      }
    } else { 
      plotter.clearPen(); 
      plotter.startPrinting();
      plotFinished(); 
      return false;
    }
  }

  ShapeData nextShapeData = shapes.get(currentColourShape);
  fillContour(nextShapeData.getShape(), nextShapeData.getPenNumber(), 1.5f);  
  nextShapeData.colouredIn = true;


  return true;
}

public void plotFinished() { 
  // TODO - save data to json file 
  println("-------FINISHED-------");
}

public int getShapesRemaining() { 
  if (shapes==null) return 0; 
  int colouredincount = 0; 
  for (ShapeData shape : shapes) if (!shape.colouredIn)colouredincount++; 
  return colouredincount;
}

Boolean controlPressed = false; 

public void keyPressed() { 
  key = (""+key).toUpperCase().charAt(0);
  println(key);
  if (key == ' ') {
    nextState();
  } else if (key == 'D') {
    printArray(plotter.requestsSent); 
    println("plotter.waiting", plotter.waiting);
  } else if (key == 'P') {
    if (state==STATE_DRAWING) { 
      // paused = !paused;
    }
  } else if (key == 'C') {
    if  (state==STATE_DRAWING) { 
      plotter.clear(); 
      changeState(STATE_WAIT_PAPER);
    }
  } else if (key == 'T') {
    moodManager.skipTimeHours(4);
  } else if (key == '=') {
  } else if (key =='W') {
  } else if (keyCode == RIGHT) {
  } else if (keyCode == LEFT) {
  } else if (keyCode == UP) {
    if (state == STATE_WAIT_PENS) {
      drawingNumber++;
      changePens();
    }
  } else if (keyCode == DOWN) {
    if (state == STATE_WAIT_PENS) {
      drawingNumber--;
      changePens();
    }
  } else if (key=='N') {
    if (state == STATE_PEN_TEST) {
      changeState(STATE_PEN_TEST_FAILED);
    }
  } else if (key=='S') {
    if (state == STATE_WAIT_PENS) {
      changeState(STATE_DRAWING);
    }
  }
}

public void nextState() { 
  if (state == STATE_CAMERA_SETUP) { 
    changeState(STATE_WAIT_PAPER); // assume we always need to change paper on startup
  } else if (state == STATE_WAIT_PAPER) {
    // check if we need to change pens, if so
    //if(replacePens) 
    changeState(STATE_WAIT_PENS);
    //else changeState(STATE_WAIT_RECALIBRATE);
  } else if (state == STATE_WAIT_PENS) {
    // check if we need to change pens, if so
    //if(replacePens) 
    changeState(STATE_WAIT_RECALIBRATE);
    //else changeState(STATE_WAIT_RECALIBRATE);
  } else if ((state == STATE_WAIT_RECALIBRATE) ||(state == STATE_PEN_TEST_FAILED)) { 
    changeState(STATE_PEN_TEST);
  } else if (state == STATE_PEN_TEST) {
    changeState(STATE_PRE_DRAWING);
  } else if((state == STATE_DRAWING) && finishedDrawing) { 
    changeState(STATE_WAIT_PAPER);
    
  }
}

public boolean changeState(int newstate) { 
  if (state==newstate) return false; 

  lastStateChangeTime = millis(); 

  state = newstate; 
  if (state == STATE_DRAWING) {
    startDrawing();
  } else if (state == STATE_PRE_DRAWING) {
    plotter.clear();
  } else if (state == STATE_WAIT_PENS) { 
    changePens();
    boolean replacePens = (drawingNumber%drawingsPerPenChange==0);
    if (!replacePens) changeState(STATE_WAIT_RECALIBRATE);
  } else if (state == STATE_PEN_TEST) { 
    startPenTest();
  }
  return true;
}

public void startPenTest() { 
  int pennum = 0; 
  int timesToTest = 1; 
  for (int i = 0; i<8*timesToTest; i++) { 

    pennum = i%8; 
    plotter.moveTo(200, map(pennum+0.5f, 0, 7, 143, 6) * plotter.plotterUnitsPerMM /plotter.scalePixelsToPlotter); 
    plotter.selectPen(i%8); 
    plotter.moveTo(400, 330);
  }
  plotter.clearPen(); 
  plotter.startPrinting();
}


public void startDrawing() { 

  finishedDrawing = false; 
  //state = STATE_DRAWING; 
  plotter.clear(); 


  int type = drawingNumber%numTypes; 
  int happ = round(moodManager.getHappiness()*100f); 
  int stim = round(moodManager.getStimulation()*100f); 

  //moodManager.skipToNextTimeFrame(); 
  JSONObject drawingData = new JSONObject(); 



  makeShapes(type, drawingNumber, happ/100f, stim/100f, plotter.screenWidth, plotter.screenHeight); 

  drawingData.setInt("type", type); 
  drawingData.setInt("drawingNumber", drawingNumber);
  drawingData.setFloat("happiness", happ);
  drawingData.setFloat("stimulation", stim);
  drawingData.setString("startTime", moodManager.getCurrentDateString()); 
  JSONArray usedPensJSONArray = new JSONArray(); 
  for (int i = 0; i<usedPens.size(); i++) { 
    usedPensJSONArray.setInt(i, usedPens.get(i));
  }
  drawingData.setJSONArray("usedPens", usedPensJSONArray);
  //appendLog(drawingData);

  JSONArray logdata; 
  try { 
    logdata = loadJSONArray("data/drawlog.json");
  } 
  catch(RuntimeException e) { 
    println(e); 
    logdata = new JSONArray();
  }
  if (logdata==null) logdata = new JSONArray(); 
  logdata.append(drawingData); 
  saveJSONArray(logdata, "data/drawlog.json"); 


  for (ShapeData s : shapes) {
    outlineContour(s.getShape(), 7);
  }



  plotter.startPrinting(); 
  currentColourShape = -1;

  drawingNumber++; 

  saveState();
}

public void plotFrame() {
}

public void mousePressed() { 
  zoom = 3-zoom;
}

public void serialEvent(Serial port) {
  moodManager.sensorReader.serialEvent(port);
  plotter.serialEvent(port);
}

//void appendLog(JSONObject json) {

//  String filename = "drawlog.txt"; 
//  String dirname = dataPath("log"); 
//  String fullpath = dirname+"/"+filename; 
//  boolean result = false; 

//  println("attempting to make dir and file for ", fullpath);

//  File dir = new File(dirname);
//  if (!dir.exists()) { // && f.isDirectory()) { 
//    // do something
//   // try {
//      dir.mkdir();
//      result = true;
//    //} 
//    //catch(SecurityException se) {
//    //  //handle it
//    //  println(se); 
//    //}        
//    //if (result) {    
//    //  println("DIR created ", dirname);
//    //}
//  }
//  result = false; 
//  File f = new File(fullpath);
//  if (!f.exists()) {
//    try {
//      f.createNewFile();
//      result = true;
//    } 
//    catch(IOException e) {
//    //  //handle it
//      println(e);
//    } 
//    finally { 
//     println("couldn't make file!", fullpath);  
//    }
//    if (result) {    
//      println("file created ", fullpath);
//    }
//  }


//  BufferedWriter output = null;
//  try {
//    output = new BufferedWriter(new FileWriter(fullpath, true)); //the true will append the new data
//    output.write(json.toString());
//  }
//  catch (IOException e) {
//    println("It Broke");
//    e.printStackTrace();
//  }
//  finally {
//    if (output != null) {
//      try {
//        output.close();
//      } 
//      catch (IOException e) {
//        println("Error while closing the writer");
//      }
//    }
//  }
//}


 

 




 


public void drawPath(Shape path) { 
  beginShape(); 
  PathIterator pi = path.getPathIterator(null);
  //PathIterator pi = new FlatteningPathIterator(path.getPathIterator(null), 0.1);
  PVector lastMove = new PVector(); 

  int shapecount = 0; 
  boolean shapeopen = false; 
  boolean contouropen = false; 

  boolean verbose = false; 

  while (pi.isDone() == false) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);

    switch (type) {

    case PathIterator.SEG_MOVETO:

      if (verbose) println("move to " + coordinates[0] + ", " + coordinates[1]);
      if (shapecount ==0) { 
        beginShape(); 
        shapeopen = true;
      } else {
        if (shapecount>1) { 
          if (contouropen) endContour();
        }
        beginContour(); 
        contouropen = true;
      }
      vertex(coordinates[0], coordinates[1]); 
      lastMove.set(coordinates[0], coordinates[1]); 
      shapecount++; 
      break;
    case PathIterator.SEG_LINETO:
      if (verbose) println("line to " + coordinates[0] + ", " + coordinates[1]);
      vertex(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_QUADTO:
      if (verbose) println("quadratic to " + coordinates[0] + ", " + coordinates[1] + ", "+ coordinates[2] + ", " + coordinates[3]);
      quadraticVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      break;
    case PathIterator.SEG_CUBICTO:
      if (verbose) println("cubic to " + coordinates[0] + ", " + coordinates[1] + ", "   + coordinates[2] + ", " + coordinates[3] + ", " + coordinates[4] + ", " + coordinates[5]);
      bezierVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      break;
    case PathIterator.SEG_CLOSE:
      if (verbose) println("close "+ coordinates[0] + ", " + coordinates[1]);
      vertex(lastMove.x, lastMove.y); 
      break;
    default:
      break;
    }
    pi.next();
  }
  if (contouropen) endContour(); 
  if (shapeopen) endShape();
}

public PVector getStartPoint(Shape a) { 
  PathIterator pi = new FlatteningPathIterator(a.getPathIterator(null), 0.1f);
  float[] coordinates = new float[6];
  if (!pi.isDone() ) {
    int type = pi.currentSegment(coordinates);
  }

  return new PVector(coordinates[0], coordinates[1]);
}

public PVector getEndPoint(Shape a) { 
  PathIterator pi = new FlatteningPathIterator(a.getPathIterator(null), 0.1f);

  float[] coordinates = new float[6];
  while (!pi.isDone() ) {

    int type = pi.currentSegment(coordinates);
    pi.next();
  }
  return new PVector(coordinates[0], coordinates[1]);
}
public List<Shape> breakArea(Area a) { 
  ArrayList<Shape> shapes = new ArrayList<Shape>(); 

  PathIterator pi = a.getPathIterator(null);

  Path2D path = new Path2D.Float(); 

  while (pi.isDone() == false) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);

    switch (type) {

    case PathIterator.SEG_MOVETO:
      shapes.add(path); 
      path = new Path2D.Float(); 
      path.moveTo(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_LINETO:
      path.lineTo(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_QUADTO:
      path.quadTo(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      break;
    case PathIterator.SEG_CUBICTO:
      path.curveTo(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      break;
    case PathIterator.SEG_CLOSE:
      path.closePath(); 
      break;
    default:
      break;
    }
    pi.next();
  }
  shapes.add(path); 

  // subtract holes
  //for (int i = 0; i<shapes.size(); i++) { 
  //  Shape shape1 = shapes.get(i); 
  //  //if(shape1.isEmpty()) continue; 
  //  for (int j = 0; j<shapes.size(); j++) { 
  //    if (j==i) continue; 
  //    Shape shape2 = shapes.get(j); 

  //    //if(shape2.isEmpty()) continue; 

  //    if (shapeContainsShape(shape1, shape2)) { 
  //      Area area;

  //      area = new Area(shape1); 
  //      area.subtract(new Area(shape2));
  //      shapes.set(i, area);
  //      //shapes.set(j, new Area()); 

  //    }
  //  }
  //}
  Collections.reverse(shapes);
  return shapes;
}
public boolean shapeContainsShape(Shape shape1, Shape shape2) { 
  PathIterator pi = new FlatteningPathIterator(shape2.getPathIterator(null), 0.1f);
  while (!pi.isDone()) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);
    if ( (type == PathIterator.SEG_LINETO)) {

      if (!shape1.contains(coordinates[0], coordinates[1])) return false;
    }
    pi.next();
  }

  return true;
}


public Polygon createPolygon(float x, float y, int numsides, float radius) { 
  Polygon p = new Polygon(); 
  for (int i = 0; i < numsides; i++)
    p.addPoint((int) (x + radius * Math.cos(i * 2 * PI / numsides)), 
      (int) (y + radius * Math.sin(i * 2 * PI / numsides)));
  return p;
}  

public Polygon createStar(float x, float y, int numsides, float innerradius, float outerradius) { 
  Polygon p = new Polygon(); 
  for (int i = 0; i < numsides; i++) {
    p.addPoint((int) (x + outerradius * Math.cos(i * 2 * PI / numsides)), 
      (int) (y + outerradius * Math.sin(i * 2 * PI / numsides)));
    p.addPoint((int) (x + innerradius * Math.cos((i+0.5f) * 2 * PI / numsides)), 
      (int) (y + innerradius * Math.sin((i+0.5f) * 2 * PI / numsides)));
  }
  return p;
}

public void removeOverlaps(List<Shape> shapes) { 
  long start = millis(); 

  for (int i = 0; i<shapes.size(); i++) { 

    Area a1 = new Area(shapes.get(i)); 

    boolean shapeChanged = false; 

    for (int j = i+1; j<shapes.size(); j++) {
      Shape s2 = shapes.get(j); 

      if (shapeCollisionTest(a1, s2)) {
        Area a2 = new Area(s2); 
        a1.subtract(a2);
        shapeChanged = true;
      }
    }

    if (shapeChanged) shapes.set(i, a1);
  }

  //// make area with the last shape in it (the one on top); 
  //Area a = new Area(shapes.get(shapes.size()-1)); 

  //for (int i = shapes.size()-2; i>=0; i--) { 

  //  Shape s = shapes.get(i); 
  //  //if (shapeCollisionTest(a, s)) {
  //  Area a2;
  //  if (s instanceof Area) 
  //    a2 = (Area)s;
  //  else 
  //  a2 = new Area(s); 
  //  a2.subtract(a);
  //  shapes.set(i, a2);

  //  a.add(a2);
  //}


  println("ovelap removal took " + (millis()-start) + "ms");
}

public boolean shapeCollisionTest(Shape s1, Shape s2) { 

  if (!rectIntersectsRect(s1.getBounds2D(), s2.getBounds2D())) return false;  

  Area a1; 
  Area a2; 
  a1 = new Area(s1);
  if (s2 instanceof Area) a2 = (Area)s2; 
  else a2 = new Area(s2);
  a1.intersect(a2); 

  return !a1.isEmpty();
}

public boolean rectIntersectsRect(Rectangle2D r1, Rectangle2D r2) { 
  return r1.intersects(r2.getMinX(), r2.getMinY(), r2.getWidth(), r2.getHeight());
}

public Point2D.Float addPoints(Point2D.Float p1, Point2D.Float p2) { 
  return new Point2D.Float(p1.x+p2.x, p1.y+p2.y);
}
public Point2D.Float subPoints(Point2D.Float p1, Point2D.Float p2) { 
  return new Point2D.Float(p1.x-p2.x, p1.y-p2.y);
}
public Point2D.Float scalePoint(Point2D.Float p, float scalar) { 
  return new Point2D.Float(p.x*scalar, p.y*scalar);
}

public Point2D.Double addPoints(Point2D.Double p1, Point2D.Double p2) { 
  return new Point2D.Double(p1.x+p2.x, p1.y+p2.y);
}
public Point2D.Double subPoints(Point2D.Double p1, Point2D.Double p2) { 
  return new Point2D.Double(p1.x-p2.x, p1.y-p2.y);
}
public Point2D.Double scalePoint(Point2D.Double p, double scalar) { 
  return new Point2D.Double(p.x*scalar, p.y*scalar);
}

public Point2D addPoints(Point2D p1, Point2D p2) { 
  return new Point2D.Float((float)(p1.getX()+p2.getX()), (float)(p1.getY()+p2.getY()));
}
public Point2D subPoints(Point2D p1, Point2D p2) { 
  return new Point2D.Float((float)(p1.getX()-p2.getX()), (float)(p1.getY()-p2.getY()));
}
public Point2D scalePoint(Point2D p, double scalar) { 
  return new Point2D.Float((float)(p.getX()*scalar), (float)(p.getY()*scalar));
}



 







 





boolean TEST_SHAPES = false;  
ArrayList<Integer> usedPens;

Area frame;

//float genseed = 5; 
int generationCount = 0; 
public void makeShapes() {
  //makeShapes(generationCount%2, generationCount, 0, 0);
  makeShapes(0, generationCount, 0, 0, ((float)height*plotter.aspectRatio), height);

  generationCount++; 
  //if(generationCount%2==1) 
  //genseed+=1;//r10000;
}


public void plotFrameAndName(float w, float h, float stim, float happy) {
  // remove the bits of shape that are outside of the rectangle

  float textScale = 1.7f; 
  float spacing = 8; 

  String textLabel = "MINDFULNESS MACHINE "+currentDateString+" STIMULATION:"+round(stim*100)+"% HAPPINESS:"+round(happy*100)+"% MOOD:"+moodManager.getMoodDescription(happy, stim)+" #"+drawingNumber+" SEB.LY";
  float textWidth = 6.5f*textScale * (textLabel.length()) ;

  plotter.addVelocityCommand(1); 

  plotText(textLabel, w-textWidth, h-17, textScale); 
  plotter.addVelocityCommand(10); 

  RoundRectangle2D r = new RoundRectangle2D.Float(0, 0, w-0.5f, h, 10, 10); 
  AffineTransform at = new AffineTransform();
  at.translate(w-textWidth - spacing, h-24); 
  at.shear(-0.18f, 0); 

  // Area r2 = new Area(new Rectangle2D.Float(w-textWidth - spacing, h-24, textWidth+spacing*2, 30)); 
  Area r2 = new Area(new Rectangle2D.Float(0, 0, textWidth+spacing*2, 30)); 
  r2.transform(at);
  frame = new Area(r); 
  frame.subtract(new Area(r2));
  outlineContour(frame, 7);
}



public void makeShapes(int type, int seed, float happiness, float stim, float w, float h) {

  usedPens = getPensForMood(happiness, stim, seed); // new ArrayList<Integer>(); 

  randomSeed(seed); 
  noiseSeed(seed);
  println ("makeShapes = ", type, seed, happiness, stim); 

  if ((type==4) || (TEST_SHAPES)) 
    shapes = getTestShapes(w, h, happiness, stim, seed, usedPens);
  else if (type ==0)
    shapes = getLandscapeShapes(w, h, happiness, stim, false); // true is spiral
  else if (type == 1)
    shapes = getTruchetShapes(w, h, happiness, stim, usedPens);
  else if (type ==2)  
    shapes = getLandscapeShapes(w, h, happiness, stim, true);
  else if (type ==3) 
    shapes = getSpiralShapes(w, h, happiness, stim);     





  for (int i=0; i<shapes.size(); i++) { 
    //if (happiness<0.05) { 
    // then distribution is random
    //  shapes.get(i).setPenNumber(usedPens.get(floor(random(0, usedPens.size()))));
    // } else { 
    // distribution is even
    shapes.get(i).setPenNumber(usedPens.get(i%usedPens.size()));
    // }
  }


  removeOverlapsUsingShapeData(shapes);
  plotter.clear();
  plotter.selectPen(7); 
  plotFrameAndName(w, h, stim, happiness);
  // remove the bits of shape that are outside of the rectangle

  for (int i = 0; i<shapes.size(); i++) {
    ShapeData sd = shapes.get(i); 
    Shape s = sd.getShape(); 
    Area a; 
    if (! (s instanceof Area)) { 
      a = new Area(s);
      sd.setShape(a);
    } else { 
      a = (Area)s;
    }
    a.intersect(frame);
  }

  Collections.reverse(shapes);

  // not sure we should do this here...
}

public float mapConstrain(float v, float min1, float max1, float min2, float max2) { 
  float r = map(v, min1, max1, min2, max2); 
  if (min2<=max2) { 
    r = constrain(r, min2, max2);
  } else { 
    r = constrain(r, max2, min2);
  }
  return r;
}
public int mapConstrainRound(float v, float min1, float max1, float min2, float max2) { 
  return round(mapConstrain(v, min1, max1, min2, max2));
}
public int mapConstrainFloor(float v, float min1, float max1, float min2, float max2) { 
  return floor(mapConstrain(v, min1, max1, min2, max2));
}
public ArrayList<Integer> getPensForMood(float happy, float stim, int seed) {

  ArrayList<Integer> pens = new ArrayList<Integer>(); 

  randomSeed(millis()); // TODO TAKE THIS OUT!

  if (happy<0.5f) { 
    // sad and lethargic
    // chose 2 - 3 pens dependent on happiness
    int numdarkpens = mapConstrainFloor(stim, 0, 0.5f, 1, 3.9f); 
    int firstpen=mapConstrainFloor(happy, 0, 0.5f, 0, 2.9f);



    pens.add(firstpen); 

    if (numdarkpens>1) {
      pens.add(firstpen+1);
    }
    if (numdarkpens>2) { 
      if (firstpen>0) pens.add(firstpen-1); 
      else pens.add(7);
    }

    if (stim<0.5f) { 

      // if we're unstimulated 
      // system for adding a colour less frequently used
      if (numdarkpens < 3) { 
        // then add a secondary colour
        // num to add is a decimal from 0 to 0.9
        float numtoadd = mapConstrain(stim, 0, 0.5f, 1, 3.9f)%1;

        //   // the lower it is the less of the secondary colour we add
        int newpentooldratio = mapConstrainFloor(numtoadd, 1, 0, 4.9f, 1); 
        ArrayList<Integer> pensToAdd = new ArrayList<Integer>(); 
        int newpen = firstpen-1; 
        if (newpen<0) newpen = 7; 
        for (int i = 0; i<newpentooldratio; i++) { 
          pensToAdd.add(newpen); 
          pensToAdd.addAll(pens);
        }
        pens.addAll(pensToAdd);
      }
    } else { 
      // sad and jittery 
      // add some higher contrast colours
      int numlightpens = mapConstrainFloor(happy, 0, 0.5f, 1, 2.9f); 
      if (numlightpens>0) { 
        int firstlightpen=mapConstrainFloor(stim, 0.5f, 1, 4, 6.9f);
        ArrayList<Integer> pensToAdd = new ArrayList<Integer>(); 
        pensToAdd.add(firstlightpen); 
        pensToAdd.addAll(pens); 
        if (numlightpens>1) { 
          pensToAdd.add(firstlightpen-1);
        } 
        //if (numlightpens>2) { 
        //  pensToAdd.add(firstlightpen-2);
        //  pensToAdd.addAll(pens);
        //} 
        pens.addAll(pensToAdd);
      }
    }
  } else {
    // if we're happy! 
    // TODO if we're stimulated, spread the colours before using them all

    int numpens = mapConstrainFloor(stim, 0, 1, 2, 7.9f); 
    int centerpen = mapConstrainFloor(happy, 0.5f, 1, 3, 6.9f); 
    pens.add(centerpen); 
    int count = 1;
    while (pens.size()<numpens) { 
      int penNum; 
      if (count%2==1) { 
        penNum = centerpen+(ceil((float)count/2f));
      } else { 
        penNum = centerpen-(ceil((float)count/2f));
      }   
      if ((penNum>=0) && (penNum<=6) && (!pens.contains(penNum))) pens.add(penNum); 
      count++;
    }
  }
  return pens; 

  //  int numPensUsed = round(map(stim, 0, 1, 1, 5)); 
  //  int centrePen = constrain(round(map(happiness, 0, 1, 0, 6.4)+random(-1, 1)), 0, 6); 
  //  int centreOffset =  round(random(-1.4, 1.4));
  //  println("centrePen : "+centrePen+ " number of pens : " + numPensUsed); 
  //  int count = 1;

  //  usedPens.add(centrePen); 

  //  while (usedPens.size()<numPensUsed) { 
  //    int penNum; 
  //    if (count%2==1) { 
  //      penNum = centrePen+(ceil((float)count/2f));
  //    } else { 
  //      penNum = centrePen-(ceil((float)count/2f));
  //    }   
  //    if ((penNum>=0) && (penNum<=6) && (!usedPens.contains(penNum))) usedPens.add(penNum); 
  //    count++;
  //  }

  //  if (usedPens.size()==1) { 
  //    usedPens.add(centrePen); 
  //    if (happiness<0.3) usedPens.add(7); 
  //    else if (centrePen>=1) usedPens.add(centrePen-1);
  //  }

  //  // if we're not too stimulated then let's sort the colours
  //  if (stim<0.8) { 
  //    Collections.sort(usedPens);
  //  }
  //  printArray(usedPens);
}

// yeah yeah I know that shapeDatas is a weird plural for the ShapeData object
public void removeOverlapsUsingShapeData(List<ShapeData> shapeDatas) { 
  ArrayList<Shape> shapes = new ArrayList<Shape>(); 
  for (ShapeData sd : shapeDatas) { 
    shapes.add(sd.getShape());
  }
  removeOverlaps(shapes); 
  // pretty nasty - assumes both lists are same length (which they should be)
  for (int i = 0; i<shapes.size(); i++) { 
    if (shapeDatas.size()<=i) { 
      println("ERROR - shapeDatas size doesn't match shapes size...") ;
    }
    shapeDatas.get(i).setShape(shapes.get(i));
  }
}

public List<ShapeData> getSpiralShapes(float width, float height, float happiness, float stim) {
  List<ShapeData> shapes = new ArrayList<ShapeData>(); 

  println("getSpiralShapes " + stim + " " + happiness);

  JSONObject json = new JSONObject(); 
  // rotation spiral
  // shapeTypes : 
  // 0 : Circle
  // 1 : Square
  // 2 : Polygon with 5 to 10 sides
  // 3 : Star
  int shapeType = (int)random(4); 
  json.setInt("shapeType", shapeType); 

  float c = 20;

  float maxsize = random(20, 120);
  float minsize = maxsize*random(0.5f, 1.2f);
  json.setFloat("maxSize", maxsize); 
  json.setFloat("minSize", minsize);

  int numshapes = 2200; 
  float shaperotation = 1; 


  float rnd = random(1); 
  float rnd2 = random(0, 3); 
  // if it's square then add random shape rotation 
  if (shapeType==2) {
    if (rnd<0.3f) shaperotation = 0;
    else if (rnd<0.66f) shaperotation = 1; 
    else shaperotation = rnd2;
  }

  float rotation = radians(137.5f); 
  //do we use standard Phillotaxis rotation ?  
  // if unhappy then more likely to deviate
  rnd = random(1); 
  rnd2 = random(5, 180); 
  if (rnd>happiness) rotation = radians(rnd2); 
  // reverse the spin
  if (random(1)<0.5f) rotation*=-1; 

  json.setFloat("rotation", rotation); 
  json.setFloat("rotationDegrees", degrees(rotation)); 
  json.setFloat("shapeRotation", shaperotation); 

  // for types 2 and 3
  int numsides = floor(random(3, 6)); 
  json.setInt("numSides", numsides);


  // width/height for circles and rectangles
  float aspect = 1;
  rnd = random(1); 
  if (shapeType<2) { 
    aspect = rnd; 
    if (aspect>0.5f) aspect = 1; 
    else aspect = map(aspect, 0, 0.5f, 0.75f, 1);
  }
  json.setFloat("aspect", aspect); 

  float noiseLevel = 0;//

  // figure out noiselevel dependent on mood. 
  // if unhappy then stimulation creates chaos
  // if happy then stimulation creates detail? 

  if (happiness<0.5f) {
    float happyeffector =(0.5f-happiness)*2; // happyeffector now between 0 and 1 for least happy 
    float stimeffector = stim; //  between 0 and 1 

    noiseLevel = stimeffector*happyeffector; // between 0 and 1
  }

  json.setFloat("noiseLevel", noiseLevel); 

  float noiseFrequency = 0;
  noiseFrequency = random(1)+(stim*2); 
  if (noiseLevel == 0) noiseFrequency = 0; 

  json.setFloat("noiseFrequency", noiseFrequency); 
  rnd = random(0.3f); 
  // TODO - clamp ? 
  float starinnersize = map(stim+rnd, 0, 1.3f, 0.6f, 0.15f); 


  for (int i = numshapes; i >=1; i--) {  

    float a = i * rotation;
    float r = c * sqrt(i);
    float x = r * cos(a) + (width/2);
    float y = r * sin(a) + (height/2);

    float size = constrain(map(i, 0, numshapes, maxsize, minsize), minsize, maxsize); 

    Shape s = new Rectangle2D.Double(); 

    float noiseAmount = (noise(i*noiseFrequency)*2-1) * noiseLevel; 

    switch(shapeType) { 
    case 0 : // Circle
      size*=map(noiseAmount, -1, 1, 0.0f, 1.5f); 
      s = new Ellipse2D.Double(-size/2/aspect, (-size/2)*aspect, size/aspect, size*aspect);  
      break;

    case 1 : // square
      size*=map(noiseAmount, -1, 1, 0.1f, 1.8f); 
      s = new Rectangle2D.Double(-size/2/aspect, -size/2*aspect, size/aspect, size*aspect);  
      break; 

    case 2 : // poly
      size*=map(noiseAmount, -1, 1, 0.0f, 1.5f); 
      s = createPolygon(0, 0, numsides, size);
      break ; 

    case 3 : 
      size*=map(noiseAmount, -1, 1, 0.1f, 1.8f); 
      //s = createStar(0, 0, numsides, size, size*random(0.3, 0.9)); 
      s = createStar(0, 0, numsides, size, size*starinnersize);//;//map(cos(i*0.1), 1, -1, 0.3, 0.9)); 
      break;
    } 

    Area area = new Area(s); 
    AffineTransform at = new AffineTransform(); 
    at.translate(x, y);
    at.rotate(a*shaperotation); 

    area.transform(at);
    shapes.add(new ShapeData(area));
  }
  println(json);

  //removeOverlaps(shapes);
  return shapes;
}


public List<ShapeData> getLandscapeShapes(float width, float height, float happiness, float stim, boolean spiral) {
  List<ShapeData> shapes = new ArrayList<ShapeData>(); 

  JSONObject json = new JSONObject(); 

  float spacing = 10;//random(10, 20); 
  float wavescale = random(5, 100); 
  random(5, 50); 
  float wavelength = random(0.1f, 2);//random(0.1, 5); 
  float shift = random(-2, 2);//random(-5, 5); 
  //float noisedetail = random(1);
  // noisedetail*=noisedetail*noisedetail; 

  //float noisescale = constrain(random(-50, 50), 0, 50);

  float noiseLevel = random(0, 0.03f);//
  if (noiseLevel<0.015f) noiseLevel = 0;

  // figure out noiselevel dependent on mood. 
  // if unhappy then stimulation creates chaos
  // if happy then stimulation creates detail? 

  if (happiness<0.5f) {
    float happyeffector =(0.5f-happiness)*2; // happyeffector now between 0 and 1 for least happy 
    float stimeffector = stim; //  between 0 and 1 

    noiseLevel = stimeffector*happyeffector; // between 0 and 1
  }
  noiseLevel*=200; //50 

  json.setFloat("noiseLevel", noiseLevel); 

  float noiseFrequency = 0;
  noiseFrequency = random(1)+(stim*2); 
  if (noiseLevel == 0) noiseFrequency = 0; 

  json.setFloat("noiseFrequency", noiseFrequency); 



  float resolution = 10;//random(10, 40); 

  json.setFloat("spacing", spacing); 
  json.setFloat("waveScale", wavescale); 
  json.setFloat("waveLength", wavelength); 
  json.setFloat("shift", shift); 

  boolean linear = !spiral; //random(1)<0.5; 

  if (linear) { 
    // linear
    for (float y = -wavescale-noiseLevel; y<height+wavescale+noiseLevel; y+=spacing) { 
      Path2D s = new Path2D.Float();
      s.moveTo(0, height); 
      for (float x = 0; x<=width+resolution; x+=resolution) { 
        float offsetx = 0;//sin(radians(x))*5; 
        float offsety = sin(radians(x+(y*shift))*wavelength)*wavescale; 
        offsety += noise(x*noiseFrequency, y*noiseFrequency)*noiseLevel;
        s.lineTo(x+offsetx, y+offsety);
      }
      s.lineTo(width, height); 
      shapes.add(new ShapeData(s));
    }
  } else {
    // circular
    wavelength = ceil(wavelength);
    //spacing*=0.7; 
    wavescale*=0.3f; 
    resolution = 2; 
    float noisescale = noiseLevel*3;
    float changerate = random(0.001f, 0.1f); // amount of change of noise between layers 

    float extent = dist(0, 0, width/2, height/2)+wavescale+noisescale; 
    for (float r = extent; r>=0; r-=spacing) { 
      resolution = map(r, 0, extent, 5, 1); 
      int iterations = floor(360/resolution); 
      resolution = 360/iterations; 

      Path2D s = new Path2D.Float();
      for (float a = 0; a<360; a+=resolution) { 

        float offsetr = sin(radians(a+(r*shift))*wavelength)*wavescale; 
        offsetr += noise(sin(a)*noiseFrequency*100, r*changerate)*noisescale*map(r/extent, 0, 1, 0.3f, 1);
        float x = width/2 + cos(radians(a))*(r+offsetr); 
        float y = height/2 + sin(radians(a))*(r+offsetr);
        if (a==0) { 
          s.moveTo(x, y);
        } else { 
          s.lineTo(x, y);
        }
      }
      s.closePath();
      shapes.add(new ShapeData(s));
    }
  }

  //removeOverlaps(shapes);
  println(json);
  return shapes;
}



public List<ShapeData> getTruchetShapes(float width, float height, float happiness, float stim, ArrayList<Integer> usedPens) {
  ArrayList<ArrayList<Area>> shapesByColour = new ArrayList<ArrayList<Area>>(); 
  int numColours = usedPens.size();
  for (int i = 0; i<numColours; i++ ) { 
    shapesByColour.add(new ArrayList<Area>());
  }
  //List<Area> shapes1 = new ArrayList<Area>(); 
  //List<Area> shapes2 = new ArrayList<Area>(); 



  float size = 50;//random(20, 40);

  for (int i = 0; i<200; i++) random(2); 
  float shapeTypeF = random(0, 2); 
  int shapeType = floor(shapeTypeF); 
  println("Truchet Shapes type : ", shapeTypeF, shapeType); 
  if (shapeType ==0) size*=0.8f;

  int colcount = floor(width/size);
  int rowcount = ceil(height/size); 
  size = width/colcount; 

  int numshapes = rowcount*colcount; 

  for (int i = 0; i<numshapes; i++) {
    float x = (i%colcount)*size; 
    float y = floor(i/colcount)*size; 
    Path2D.Float s1 = new Path2D.Float();
    Path2D.Float s2 = new Path2D.Float();

    if (shapeType ==0) { 

      Point2D.Float p1 = new Point2D.Float(x, y); 
      Point2D.Float p2 = new Point2D.Float(x+size+0.1f, y); 
      Point2D.Float p3 = new Point2D.Float(x, y+size+0.1f); 
      Point2D.Float p4 = new Point2D.Float(x+size+0.1f, y+size+0.1f); 

      if (random(1)<0.5f) { 
        s1.moveTo(p1.x, p1.y);
        s1.lineTo(p2.x, p2.y); 
        s1.lineTo(p4.x, p4.y); 
        s1.closePath(); 
        s2.moveTo(p1.x, p1.y); 
        s2.lineTo(p4.x, p4.y); 
        s2.lineTo(p3.x, p3.y); 
        s2.closePath();
      } else { 
        s1.moveTo(p1.x, p1.y);
        s1.lineTo(p2.x, p2.y); 
        s1.lineTo(p3.x, p3.y); 
        s1.closePath(); 
        s2.moveTo(p2.x, p2.y); 
        s2.lineTo(p4.x, p4.y); 
        s2.lineTo(p3.x, p3.y); 
        s2.closePath();
      }
      Area a1 = new Area(s1); 
      Area a2 = new Area(s2); 


      int colourindex1 = floor(random(0, numColours)); 
      int colourindex2 = colourindex1; 
      while (colourindex2==colourindex1) colourindex2 = floor(random(0, numColours)); 

      shapesByColour.get(colourindex1).add(a1);
      shapesByColour.get(colourindex2).add(a2);
    } else if (shapeType ==1) { 
      float halfsize = size/2; 
      s1.moveTo(0, 0);
      s1.lineTo(halfsize, 0); 
      s1.lineTo(0, halfsize); 
      s1.closePath(); 

      s1.moveTo(size, size);
      s1.lineTo(halfsize, size); 
      s1.lineTo(size, halfsize); 
      s1.closePath(); 

      s2.moveTo(halfsize, 0); 
      s2.lineTo(size, 0); 
      s2.lineTo(size, halfsize); 
      s2.lineTo(halfsize, size); 
      s2.lineTo(0, size); 
      s2.lineTo(0, halfsize); 
      s2.closePath();

      //Area area = new Area(s); 
      AffineTransform at = new AffineTransform(); 

      at.translate(x, y);
      at.scale(1.0001f, 1.0001f);  
      if (random(1)<0.5f) { 
        at.translate(size, 0);

        at.rotate(PI/2);
      }

      //at.scale(size+0.1/size, size+0.1/size);  


      Area a1 = new Area(s1); 
      Area a2 = new Area(s2); 
      a1.transform(at); 
      a2.transform(at); 


      int colourindex1 = floor(random(0, numColours)); 
      int colourindex2 = colourindex1; 
      while (colourindex2==colourindex1) colourindex2 = floor(random(0, numColours)); 

      shapesByColour.get(colourindex1).add(a1);
      shapesByColour.get(colourindex2).add(a2);
    }
  }

  int start = millis();   

  ArrayList<ShapeData>shapedata = new ArrayList<ShapeData>(); 

  for (int i = 0; i<shapesByColour.size(); i++) { 
    ArrayList<Area> areas = shapesByColour.get(i); 
    Area firstShape = areas.get(0); 
    for (int j =1; j<areas.size(); j++) {
      firstShape.add(areas.get(j));
    }
    ShapeData sd = new ShapeData(firstShape);
    sd.penNumber = usedPens.get(i); 
    shapedata.add(sd);
  }

  // now check to see if we already have 
  for (int i =0; i<shapedata.size(); i++) { 
    ShapeData s1=shapedata.get(i); 
    for (int j =i+1; j<shapedata.size(); j++) { 
      ShapeData s2=shapedata.get(j); 
      if (s1.penNumber==s2.penNumber) { 
        // merge them
        ((Area)(s1.shape)).add((Area)s2.shape); 
        // clear shape2
        s2.shape = new Area();
      }
    }
  }


  println("combining shapes took : " + (millis()-start)); 

  //ArrayList<Shape> shapes = new ArrayList<Shape>(); 

  //shapes.add(shapes1.get(0)); 
  //shapes.add(shapes2.get(0)); 
  //shapes.addAll(breakArea(shapes1.get(0))); 
  //shapes.addAll(breakArea(shapes2.get(0))); 

  //for (Shape shape : shapes) { 
  //  shapedata.add(new ShapeData(shape));
  //}
  return shapedata;
}




public List<ShapeData> getTestShapes(float w, float h, float happiness, float stim, int seed, ArrayList<Integer>usedPens) {

  List<ShapeData> shapes = new ArrayList<ShapeData>(); 

  int cols = floor(w/330); 
  int rows = floor(h/30); 
  float x = (seed%cols)*330;
  float y = floor((float)seed/(float)cols) * 30;


  for (int i =0; i<usedPens.size(); i++) { 

    Shape s = new Rectangle2D.Double(x + (i*20), y, 20, 20);  
    shapes.add(new ShapeData(s));
  }
  return shapes;
}


public class ShapeData { 

  int penNumber; // penIndex for colour, 0 to 6 from dark to light
  boolean outlineDrawn;
  boolean colouredIn; 
  Shape shape; 

  public ShapeData(Shape _shape) { 
    this(_shape, 0);
  }
  public ShapeData(Shape _shape, int _pennumber) { 
    penNumber = _pennumber; 
    shape = _shape; 
    outlineDrawn = false;
    colouredIn = false;
  }
  public void setShape(Shape s) { 
    shape = s;
  }

  public Shape getShape() { 
    return shape;
  }
  public void setPenNumber(int num) { 
    penNumber = num;
  }
  public int getPenNumber() { 
    return penNumber;
  }
}



//import java.awt.geom.Point2D;
//import java.awt.geom.Point2D.Float;
 



 

public void fillContour(Shape origshape, int penNum, float penThickness) { 
  //if(shape.isEmpty()) return; 
  ArrayList<Line> lines = new ArrayList<Line>(); 

  Shape shape = GeometryUtils.grow(origshape, -penThickness/2);

  Rectangle r = shape.getBounds();

  int i, j; 
  //int boundspadding = 1; 

  // convert the first three points to PVectors and draw them
  Point2D.Float p1 = new Point2D.Float(r.x, r.y); 
  Point2D.Float p2 = new Point2D.Float(r.x+r.width, r.y); 
  Point2D.Float p3 =  new Point2D.Float(r.x+r.width, r.y+r.height); 

  //ellipse(p1.x, p1.y, 4, 4); 
  //ellipse(p2.x, p2.y, 4, 4); 
  //ellipse(p3.x, p3.y, 4, 4);

  // if second side is longer than first, switch them! 
  if (p1.distance(p2)<p2.distance(p3)) { 
    p3 = (Point2D.Float)p1.clone(); 
    p1.setLocation(r.x+r.width, r.y+r.height);// = r.getBottomRight();
  }


  // get vectors for the long side of the rectangle...
  Point2D.Float v1 = subPoints(p2, p1); 

  // ... and the short side
  Point2D.Float v2 = subPoints(p3, p2); 

  // if the shape is super teeny, forget it
  // TODO draw a little line
  Point2D.Float zero = new Point2D.Float(); 
  if ((v1.distanceSq(zero)<1) && (v2.distanceSq(zero)<=1)) return;

  float len = (float)v1.distance(zero);

  int linenum = 0; 

  // now iterate along the long side
  for (float d = 0; d<len; d+=penThickness) { 
    Point2D.Float start = scalePoint(v1, d/len); 
    start = addPoints(start, p1); 
    Point2D.Float end = addPoints(start, v2); 

    // make a line that cuts through the shape 
    Line2D.Float line2d = new Line2D.Float(start, end); 

    // and get the intersection points
    List <Point2D> ips = GeometryUtils.intersection(shape, line2d); 
    Collections.sort(ips, new IntersectionComparator(start));

    if ((ips!=null) && (ips.size()>1)) { 

      ArrayList<PVector> ps = new ArrayList<PVector>(); 

      //iterate through points
      // p1 = p at index
      // p2 = p at index+1
      // get midpoint - if it's contained in the shape then make a line between 1 and 2
      // otherwise nothing
      // index++

      ArrayList<Line> newlines = new ArrayList<Line>(); 
      Line l = new Line();

      //for (i = 0; i<ips.size(); i++) {
      //  Point2D ip = ips.get(i); 
      //  ellipseMode(RADIUS);
      //  stroke(255, 50);
      //  ellipse((float)ip.getX(), (float)ip.getY(), 1, 1);
      //}

      // algorithm for making sure that line segments are inside 

      for ( i = 1; i<ips.size(); i++) {
        Point2D ip1 = ips.get(i-1); 
        Point2D ip2 = ips.get(i); 
        Point2D mid = subPoints(ip2, ip1);
        mid = scalePoint(mid, 0.5f);
        mid = addPoints(mid, ip1);
        //ellipse((float)mid.getX(), (float)mid.getY(), 1, 1);
        if (shape.contains(mid)) {
          if ((newlines.size()>0) && (l.p2.equals(new PVector((float)ip1.getX(), (float)ip1.getY())))) {
            l.p2 = new PVector((float)ip2.getX(), (float)ip2.getY());
          } else {
            l = new Line(new PVector((float)ip1.getX(), (float)ip1.getY()), new PVector((float)ip2.getX(), (float)ip2.getY()), linenum);
            newlines.add(l);
          }
        }
      }

      lines.addAll(newlines);
    }
    linenum++;
  }

  if (lines.size()==0) return; 

  ArrayList<Line> sortedLines = new ArrayList<Line>(); 

  // shrink and reset all the lines
  Line l; 
  for ( i =0; i<lines.size(); i++ ) {
    l = lines.get(i); 

    // get the unit vector for the line
    PVector v = l.p2.copy().sub(l.p1); 
    float mag = v.mag();
    // if the length of the line is long enough, shrink it by
    // half the penwidth
    if (mag-(penThickness*2)>0) { 
      v.div(mag); 
      v.mult(penThickness);
      l.p1.add(v); 
      l.p2.sub(v); 

      // otherwise just draw a dot in the middle of the line
      // TODO maybe have to be non zero length?
    } else { 

      v.mult(0.5f).add(l.p1); 
      l.p1.set(v); 
      l.p2.set(v);
    }
    l.tested = false;
    l.reversed = false;
  }
  plotter.selectPen(penNum); 
  // add lines for shape; 
  outlineContour(shape, penNum);   

  boolean reversed = false;
  int currentIndex = 0;

  float shortestDistance = java.lang.Float.MAX_VALUE;

  int nextDotIndex = -1;

  //println("---------------------");

  do {
    //println("currentIndex", currentIndex);
    Line line1 = lines.get(currentIndex);

    line1.tested = true;

    line1.reversed = reversed;
    sortedLines.add(line1);
    shortestDistance = java.lang.Float.MAX_VALUE;
    nextDotIndex = -1;


    for (j = 0; j<lines.size(); j++) {

      //println (currentIndex, j, reversed);  

      Line line2 = lines.get(j);
      if ((line2.tested) || (line1.equals(line2))) continue;

      line2.reversed = false;

      if (line1.getEnd().dist(line2.getStart()) < shortestDistance) {
        shortestDistance = line1.getEnd().dist(line2.getStart());
        nextDotIndex = j;
        reversed = false;
        //println ("\t",shortestDistance, currentIndex, j, reversed);
      }

      if ((line1.getEnd().dist(line2.getEnd()) < shortestDistance)) {
        shortestDistance = line1.getEnd().dist(line2.getEnd());
        nextDotIndex = j;
        reversed = true;
        //println ("\t",shortestDistance, currentIndex, j, reversed);
      }
    }

    currentIndex = nextDotIndex;
  } while (currentIndex>-1);

  // debug : highlight lines points dependent on mouse pos
  int highlightlineindex = (int)map(mouseX, 0, width, 0, 8); 

  //for (i  = 0; i<sortedLines.size(); i++) { 
  //  Line line = sortedLines.get(i); 

  //  //if (highlightlineindex == i) {
  //  //  strokeWeight(2); 
  //  //  stroke(255, 0, 0,128);
  //  //} else { 
  //  //strokeWeight(1);
  //  stroke(0, 255, 0, 255);
  //  // }
  //  line.draw();
  //}


  lines = sortedLines;
  boolean penUp = true; 
  PVector lastPos = new PVector(0, 0); 
  Line lastLine = null; 
  for (Line line : lines) { 
    //line.draw();
    PVector pv1 = line.p1.copy(); 
    PVector pv2 = line.p2.copy(); 

    if (line.reversed) { 
      pv2 = pv1; 
      pv1 = line.p2.copy();
    }

    if (!penUp) { 
      // if it is too far
      if (lastPos.dist(pv1)>penThickness*3) {
        // lift the pen
        penUp = true; 
        
        // although, if we are within 10 x penThickness
        if(lastPos.dist(pv1)<penThickness*10) { 
          
          // and we're doing consecutive lines
          if ( (lastLine!=null)  &&
            (abs(lastLine.posNumber-line.posNumber)==1) &&
            (lastLine.reversed!=line.reversed) ) {
            //  and we aren't crossing over the edget
            
            Point2D.Float start = new Point2D.Float(pv1.x, pv1.y); 
            Point2D.Float end = new Point2D.Float(lastPos.x, lastPos.y); 
            Line2D.Float line2d = new Line2D.Float(start, end); 
            // if we are going over the edge then lift the pen!
            if (GeometryUtils.intersection(origshape, line2d).size()==0) {
              
              // then let's not lift the pen
              penUp = false;
            }
          }

        }

        //// get line between lastpos and pv1
        //Point2D.Float start = new Point2D.Float(pv1.x, pv1.y); 
        //Point2D.Float end = new Point2D.Float(lastPos.x, lastPos.y); 
        //Line2D.Float line2d = new Line2D.Float(start, end); 

        //// unless it doesn't cross over the edge, in which case don't lift it
        //if (GeometryUtils.intersection(origshape, line2d).size()==0)
        //  penUp = false;
      }
    }
    if (penUp) { 
      plotter.moveTo(pv1);
    } else { 
      plotter.lineTo(pv1);
    }
    penUp = false; 
    plotter.lineTo(pv2); 
    lastPos.set(pv2);
    lastLine = line;
  }
  plotter.moveTo(lastPos); // lifts pen?
}

//List <Vec2D> getIntersectionPoints(Shape2D p, Line2D l) {
//  List <Vec2D> intersections = new ArrayList <Vec2D> ();
//  for (Line2D aL : p.getEdges()) {

//    Line2D.LineIntersection isec = aL.intersectLine(l);
//    if (isec.getType()==Line2D.LineIntersection.Type.INTERSECTING) {
//      intersections.add( isec.getPos() );
//    }
//  }

//  // sort the intersection points      
//  Collections.sort(intersections, new IntersectionComparator(l.a));

//  return intersections;
//}

public void outlineContour(Shape shape, int penNum) { 


  //if(shape.isEmpty()) return; 
  plotter.selectPen(penNum); 
  //PathIterator pi = path.getPathIterator(null);
  PathIterator pi = new FlatteningPathIterator(shape.getPathIterator(null), 0.2f);
  PVector lastMove = new PVector(); 

  boolean verbose = false; 

  while (pi.isDone() == false) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);


    switch (type) {

    case PathIterator.SEG_MOVETO:

      if (verbose) println("move to " + coordinates[0] + ", " + coordinates[1]);

      plotter.moveTo(coordinates[0], coordinates[1]); 
      lastMove.set(coordinates[0], coordinates[1]); 

      break;
    case PathIterator.SEG_LINETO:
      if (verbose) println("line to " + coordinates[0] + ", " + coordinates[1]);
      plotter.lineTo(coordinates[0], coordinates[1]); 
      break;
      //case PathIterator.SEG_QUADTO:
      //  if (verbose) println("quadratic to " + coordinates[0] + ", " + coordinates[1] + ", "+ coordinates[2] + ", " + coordinates[3]);
      //  quadraticVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      //  break;
      //case PathIterator.SEG_CUBICTO:
      //  if (verbose) println("cubic to " + coordinates[0] + ", " + coordinates[1] + ", "   + coordinates[2] + ", " + coordinates[3] + ", " + coordinates[4] + ", " + coordinates[5]);
      //  bezierVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      //  break;
    case PathIterator.SEG_CLOSE:
      if (verbose) println("close "+ coordinates[0] + ", " + coordinates[1]);
      plotter.lineTo(lastMove.x, lastMove.y); 
      break;
    default:
      break;
    }
    pi.next();
  }
}

//if (dryrun) return; 
//plotter.selectPen(penNum); 

//if (shape instanceof CompoundPolygon2D) { 
//  for (Polygon2D poly : ((CompoundPolygon2D)shape).polygons) { 
//    outlineContour(poly, penNum, dryrun);
//  }
//} else {
//  Polygon2D poly; 
//  if (!(shape instanceof Polygon2D)) { 
//    poly = shape.toPolygon2D();
//  } else {
//    poly = (Polygon2D)shape;
//  }

//  boolean move = true; 

//  for (int j = 0; j<=poly.getNumVertices(); j++) { 
//    Vec2D p = poly.get(j%poly.getNumVertices()); 
//    if (move) { 
//      plotter.moveTo(p.x, p.y); 
//      move = false;
//    } else { 
//      plotter.lineTo(p.x, p.y);
//    }
//  }
//}
//}


public class IntersectionComparator implements Comparator<Point2D> {

  public Point2D startpoint; 
  public IntersectionComparator(Point2D start) {
    startpoint = (Point2D)start.clone();
  }
  public int compare(Point2D c1, Point2D c2) {
    float dist1 = (float)startpoint.distanceSq(c1); 
    float dist2 = (float)startpoint.distanceSq(c2); 

    if (dist1==dist2) {
      return 0;
    } else if (dist1<dist2) {
      return -1;
    } else {
      return 1;
    }
  }
}

class Line { 

  public PVector p1; 
  public PVector p2;
  public int posNumber; 
  public boolean tested = false; 
  public boolean reversed = false; 

  public Line(PVector start, PVector end, int positionnum) { 
    p1 = start.copy(); 
    p2 = end.copy(); 
    posNumber = positionnum;
  }
  public Line() { 
    this(new PVector(), new PVector(), 0);
  }
  public void draw() { 
    line(p1.x, p1.y, p2.x, p2.y);
  }
  public PVector getStart() { 
    return reversed?p2:p1;
  }
  public PVector getEnd() { 
    return reversed?p1:p2;
  }

  public boolean equals(Line line) { 
    return (((line.p1 == p1) && (line.p2 == p2)) || ((line.p1 == p2) &&(line.p2 == p1)));
  }
}

float glyphWidth, glyphHeight,glyphSpacing;

PVector letterOffset = new PVector(); 
PVector letterScale = new PVector(1, 1); 


public void plotText(String textToPlot, float xpos, float ypos, float scaleFactor) { 


  glyphWidth = 4 * scaleFactor; 
  glyphHeight = 8 * scaleFactor; 
  glyphSpacing = 2.5f * scaleFactor;


  textToPlot = textToPlot.toUpperCase();
  for ( int i = 0; i < textToPlot.length(); i++ ) {
    drawGlyph(textToPlot.charAt(i), xpos, ypos);
    xpos += glyphWidth + glyphSpacing;
  }
}


public void drawGlyph(char glyph, float posX, float posY) {

  letterOffset.set(posX, posY, 0); 
  letterScale.set(glyphWidth / 4.0f, glyphHeight / 6.0f, 0);
  drawLetter(glyph);
}

public void drawLetter(char letter) {

  if ( letter == 'A' ) {
    plotLetterLine(0, 6, 0, 1);
    plotLetterLine(0, 1, 2, 0);
    plotLetterLine(2, 0, 4, 1);
    plotLetterLine(4, 1, 4, 6);
    plotLetterLine(4, 3, 0, 3);
  }

  if ( letter == 'B' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 3, 6);
    plotLetterLine(3, 6, 4, 5);
    plotLetterLine(4, 5, 4, 4);
    plotLetterLine(4, 4, 3, 3);
    plotLetterLine(3, 3, 0, 3);
    plotLetterLine(0, 3, 3, 3);
    plotLetterLine(3, 3, 4, 2);
    plotLetterLine(4, 2, 4, 1);
    plotLetterLine(4, 1, 3, 0);
    plotLetterLine(3, 0, 0, 0);

    
  }
  if ( letter == 'C' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == 'D' ) {
    plotLetterLine(0, 0, 3, 0);
    plotLetterLine(3, 0, 4, 2);
    plotLetterLine(4, 2, 4, 4);
    plotLetterLine(4, 4, 3, 6);
    plotLetterLine(3, 6, 0, 6);
    plotLetterLine(0, 6, 0, 0);
  }
  if ( letter == 'E' ) {

    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 3, 0, 3);
  }
  if ( letter == 'F' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 3, 4, 3);
  }
  if ( letter == 'G' ) {
    plotLetterLine(4, 1, 4, 0);
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 6, 4, 3);
    plotLetterLine(4, 3, 2, 3);
  }
  if ( letter == 'H' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == 'I' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(2, 0, 2, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == 'J' ) {
    plotLetterLine(0, 4, 1, 6);
    plotLetterLine(1, 6, 4, 6);
    plotLetterLine(4, 6, 4, 0);
    plotLetterLine(4, 0, 2, 0);
  }
  if ( letter == 'K' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 3, 4, 0);
    plotLetterLine(0, 3, 4, 6);
  }
  if ( letter == 'L' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == 'M' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 2, 2);
    plotLetterLine(2, 2, 4, 0);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == 'N' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 0, 1);
    plotLetterLine(0, 1, 4, 5);
    plotLetterLine(4, 5, 4, 6);
    plotLetterLine( 4, 6, 4, 0);
  }
  if ( letter == 'O' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
    plotLetterLine(4, 6, 0, 6);
    plotLetterLine(0, 6, 0, 0);
  }
  if ( letter == 'P' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 0, 3);
  }
  if ( letter == 'Q' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 4);
    plotLetterLine(4, 4, 2, 6);
    plotLetterLine(2, 6, 0, 6);
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(2, 4, 4, 6);
  }
  if ( letter == 'R' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 4, 6);
  }
  if ( letter == 'S' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 3);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 3, 4, 6);
    plotLetterLine(4, 6, 0, 6);
  }
  if ( letter == 'T' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(2, 0, 2, 6);
  }
  if ( letter == 'U' ) {
    plotLetterLine(0, 0, 0, 5);
    plotLetterLine(0, 5, 1, 6);
    plotLetterLine(1, 6, 3, 6);
    plotLetterLine(3, 6, 4, 5);
    plotLetterLine(4, 5, 4, 0);
  }
  if ( letter == 'V' ) {
    plotLetterLine(0, 0, 2, 6);
    plotLetterLine(2, 6, 4, 0);
  }
  if ( letter == 'W' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 2, 4);
    plotLetterLine(2, 4, 4, 6);
    plotLetterLine(4, 6, 4, 0);
  }
  if ( letter == 'X' ) {
    plotLetterLine(0, 0, 2, 3);
    plotLetterLine(2, 3, 0, 6);
    plotLetterLine(4, 0, 2, 3);
    plotLetterLine(2, 3, 4, 6);
  }
  if ( letter == 'Y' ) {
    plotLetterLine(0, 0, 2, 2);
    plotLetterLine(2, 2, 4, 0);
    plotLetterLine(2, 2, 2, 6);
  }
  if ( letter == 'Z' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == '0' ) {
    plotLetterLine(0, 6, 4, 0);
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 6, 4, 0);
  }
  if ( letter == '1' ) {
    plotLetterLine(0, 0, 2, 0);
    plotLetterLine(2, 0, 2, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == '2' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == '3' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
    plotLetterLine(4, 6, 0, 6);
    plotLetterLine(0, 3, 4, 3);
  }
  if ( letter == '4' ) {
    plotLetterLine(0, 0, 0, 3);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == '5' ) {
    //plotLetterLine(0, 0, 0, 0);

    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 3);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 3, 4, 6);
    plotLetterLine(4, 6, 0, 6);
  }
  if ( letter == '6' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 6, 4, 3);
    plotLetterLine(4, 3, 0, 3 );
  }
  if ( letter == '7' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == '8' ) {
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 4, 6);
    plotLetterLine(4, 6, 0, 6);
    plotLetterLine(0, 6, 0, 3);
  }
  if ( letter == '9' ) {
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == '!' ) {
    plotLetterLine(2, 0, 2, 4);
    plotLetterLine(2, 5, 2, 6);
  }
  if ( letter == ':' ) {
    plotLetterLine(2, 1.5f, 2, 2.5f);
    plotLetterLine(2, 4.5f, 2, 5.5f);
  }
  if ( letter == '.' ) {
    plotLetterLine(2, 5, 2, 6);
  }
  if ( letter ==',') {
    plotLetterLine(2, 5, 2, 7);
  }
  if (letter == '#') {
    plotLetterLine(1, 1, 1, 5);
    plotLetterLine(0, 2, 4, 2);
    plotLetterLine(0, 4, 4, 4);
    plotLetterLine(3, 1, 3, 5);
  }
  if (letter =='-') {
    plotLetterLine(1, 3, 3, 3);
  }
  if (letter =='_') {
    plotLetterLine(0, 6, 4, 6);
  }

  if (letter == '/') {
    plotLetterLine(0, 6, 4, 0);
  }
  if (letter == '%') {
    plotLetterLine(0, 6, 4, 0);
    plotLetterLine(0,0,0,1); 
    plotLetterLine(5,5,5,6); 
  }
  endShape();
}

public void plotLetterLine(float x1, float y1, float x2, float y2) { 
  //line(x1*letterScale.x + letterOffset.x, y1*letterScale.y + letterOffset.y, x2*letterScale.x + letterOffset.x, y2*letterScale.y + letterOffset.y) ; 

  PVector p1 = new PVector(x1*letterScale.x + letterOffset.x -y1*letterScale.y*0.2f , y1*letterScale.y + letterOffset.y); 
  PVector p2 = new PVector(x2*letterScale.x + letterOffset.x -y2*letterScale.y*0.2f, y2*letterScale.y + letterOffset.y); 

  plotter.plotLine(p1.x, p1.y, p2.x, p2.y);
  

  //letterPoint.set(p2);
}
  public void settings() {  size(1920, 1080);  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#000000", "--hide-stop", "MindfulnessMachine" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
