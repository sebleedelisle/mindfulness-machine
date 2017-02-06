
import processing.serial.*;
import processing.video.*;
import gab.opencv.*;

import java.io.BufferedWriter;
import java.io.FileWriter;

import toxi.math.noise.*;

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

color[] colours = new color[11]; 

String currentDateString =""; 

PFont consoleFont; 
PFont bodyFont; 
PFont titleFont; 
PFont logoFont; 

PVector previewPos = new PVector(0, 0);
PVector previewTargetPos = new PVector(0, 0); 

CommandRendererData greenDataRenderer; 


void setup() { 

  //fullScreen(); 
  size(1920, 1080); 
  noSmooth();
  plotterGuide = loadImage("images/PlotterGuide.png");
  loadState(); 
  consoleFont = loadFont("fonts/BitstreamVeraSansMono-Bold-12.vlw");
  bodyFont = loadFont("fonts/BitstreamVeraSansMono-Bold-16.vlw");
  titleFont = loadFont("fonts/AvenirNextCondensed-DemiBoldItalic-32.vlw");
  logoFont = loadFont("fonts/AvenirNextCondensed-DemiBoldItalic-48.vlw");


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
    plotter.setPenThicknessMM(i, 0.8);
  }

  plotter.connectToSerial("usbserial");
}


void setTitleFont() { 
  textFont(titleFont); 
  textSize(32);
} 
void setBodyFont() { 
  textFont(bodyFont); 
  textSize(16);
} 

void setConsoleFont() { 
  textFont(consoleFont); 
  textSize(12);
}
void changePens() { 
  colourChooser.getSelectionByNumber(floor(drawingNumber/drawingsPerPenChange)); 
  for (int i = 0; i<7; i++) { 
    plotter.setPenColour(i, colourChooser.getColourForPenNum(i) );
    if (drawingNumber%drawingsPerPenChange ==0)  plotter.resetPen(i);
  }
  plotter.setPenColour(7, #000000);
  if ((drawingNumber%drawingsPerPenChange ==0)&&(colourChooser.replaceBlack)) plotter.resetPen(7);
}

void loadState() { 

  String[] data = loadStrings("data/IssueNum.txt"); 
  if (data==null) { 
    drawingNumber = 0;
  } else { 
    drawingNumber = int(data[0]);
  }

  data = loadStrings("data/TestMode.txt"); 
  if (data==null) { 
    TEST_MODE = false;
  } else { 
    TEST_MODE = int(data[0])!=0;
  }
}
void saveState() { 

  String[] data = {str(drawingNumber)}; 
  saveStrings("data/IssueNum.txt", data);
}
void draw() { 

  moodManager.update();
  currentDateString = moodManager.getCurrentDateString();
  plotter.update();

  if ((greenDataRenderer==null) && (plotter.initialised)) { 
    greenDataRenderer = new CommandRendererData(this, plotter.penManager, plotter.plotWidth, plotter.plotHeight, plotter.scalePixelsToPlotter);
  }

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
    text("CHANGE PAPER", width*0.75, height/2+50); 
    setBodyFont();  
    fill(225);//,230,234); 

    String label = "STEP 1 : TURN OFF 'PAPER HOLD' ON THE PLOTTER (RED LIGHT SHOULD GO OUT),\n\n" +
      "STEP 2 : REMOVE THE CURRENT DRAWING AND POST ON WALL.\n\n" +
      "STEP 3 : PLACE BLANK SHEET ON THE PLOTTER BED, LINE UP WITH THE PLACEMENT MARKINGS\n" + 
      "AND THEN TURN ON THE PAPER HOLD BUTTON (RED LIGHT COMES ON).\n\n"+
      "PRESS SPACE TO CONTINUE";

    text(label, width*0.75, height/2+120); 

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
        text("THINKING... PLEASE WAIT", width- ((width-996)/2), height/2+100);
      }
      renderProgressBottomLeft();
    } else if (finishedDrawing) { 

      //println("PRINT FINISHED AT ", moodManager.getCurrentDateString());
      fill(map(sin(millis()*0.01f), -1, 1, 128, 255)); 
      textAlign(CENTER, CENTER); 
      setTitleFont(); 
      text("STAFF ASSISTANCE REQUIRED", width*0.75, height/2+100); 
      setConsoleFont();  
      fill(225);//,230,234); 

      text("CHANGE PAPER AND PRESS SPACE TO CONTINUE", width*0.75, (height/2)+150);
      renderProgressBottomLeft();
    } else { 
      renderProgressBottom();
    }




    renderTopSectionData(); 

    if (greenDataRenderer!=null) { 
      greenDataRenderer.renderCommands(plotter.commandsProcessed); 
      pushMatrix(); 
      pushStyle(); 
      translate(940, 420); 
      greenDataRenderer.render(); 
      popStyle();
      popMatrix();
    }



    break;
  }

  fill(0); 
  //stroke(255);
  rect(1448, 1028, 1920-1448, 52);
  textFont(logoFont); 
  textSize(48);
  fill(150); 
  textAlign(RIGHT, BOTTOM); 
  text("MINDFULNESS MACHINE", 1910, 1084); 

  if (TEST_MODE) { 
    fill(0); 
    rect(0, 0, 100, 20); 
    fill(255); 
    textAlign(LEFT, TOP);
    textSize(12); 
    text("TEST_MODE", 3, 3);
  }
  //fill(255); 
  //textSize(14);
  //text(getShapesRemaining(), 10, 100);
}

void renderProgressBottom() {  
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

void renderProgressBottomLeft() {  
  pushMatrix(); 
  translate(0, 416); 
  //scale(0.6, 0.6); 

  plotter.renderProgress();
  if (!plotter.initialised) { 
    textAlign(LEFT, TOP);
    setConsoleFont(); 
    fill(0); 
    text("PLOTTER NOT INITIALISED", 10, 10);
  }
  popMatrix();
}

void renderTopSectionData() {

  fill(0); 
  rect(0, 0, width, 384+32); 
  pushMatrix(); 
  //translate(0,0); 
  setConsoleFont(); 
  moodManager.draw(consoleFont, bodyFont);

  setConsoleFont(); 
  textAlign(CENTER, TOP); 
  fill(0, 255, 255);
  text("PEN DISTANCE\nTRAVELLED", 1810, 30); 
  renderPenUsage(1760, 70);
  popMatrix();
}

void renderPenUsage(float xpos, float ypos) { 
  pushMatrix(); 
  pushStyle(); 
  translate(xpos, ypos);
  textAlign(LEFT, CENTER); 
  setConsoleFont();
  fill(0, 255, 255);
  float w = 30, h = 300; 
  colourChooser.renderPensSquare(0, 0, w, h, color(0, 128, 128));
  float spacing = w; 
  if ((h/8)>spacing) spacing = h/8; 

  for (int i = 0; i<8; i++) { 
    float y = map(i, 7, 0, w/2, h-(w/2)); 
    text(nfc(round(plotter.getPenDistance(i)))+"mm", w+6, y);
  }
  popStyle();
  popMatrix();
}

boolean colourNextShape() { 

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
  fillContour(nextShapeData.getShape(), nextShapeData.getPenNumber(), 1.5);  
  nextShapeData.colouredIn = true;


  return true;
}

void plotFinished() { 
  // TODO - save data to json file 
  println("-------FINISHED-------");
}

int getShapesRemaining() { 
  if (shapes==null) return 0; 
  int colouredincount = 0; 
  for (ShapeData shape : shapes) if (!shape.colouredIn)colouredincount++; 
  return colouredincount;
}

Boolean controlPressed = false; 

void keyPressed() { 
  System.gc();
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
  } else if (key == 'J') {
    moodManager.skipTimeHours(4);
  } else if (key == 'T') {
    moodManager.timeSpeed*=2; 
    if (moodManager.timeSpeed>100000) {

      moodManager.resetTimeSpeed();
    }
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
  } else if (key=='F') {
    if (state != STATE_DRAWING) {
      plotFrame();
    }
  }
}

void nextState() { 
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
  } else if ((state == STATE_DRAWING) && finishedDrawing) { 
    changeState(STATE_WAIT_PAPER);
  }
}

boolean changeState(int newstate) { 
  if (state==newstate) return false; 

  lastStateChangeTime = millis(); 

  state = newstate; 
  if (state == STATE_DRAWING) {
    startDrawing();
  } else if (state == STATE_PRE_DRAWING) {
    if (greenDataRenderer!=null) greenDataRenderer.clear();
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

void startPenTest() { 
  int pennum = 0; 
  int timesToTest = 1; 
  for (int i = 0; i<8*timesToTest; i++) { 

    pennum = i%8; 
    plotter.moveTo(200, map(pennum+0.5, 0, 7, 143, 6) * plotter.plotterUnitsPerMM /plotter.scalePixelsToPlotter); 
    plotter.selectPen(i%8); 
    plotter.moveTo(400, 330);
  }
  plotter.clearPen(); 
  plotter.startPrinting();
}


void startDrawing() { 

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

void plotFrame() {
  println("plotFrame()");
  float w = ((float)height*plotter.aspectRatio);
  float h = height;
  RoundRectangle2D r = new RoundRectangle2D.Float(0, 0, w-0.5, h, 10, 10); 
  frame = new Area(r); 
  plotter.addVelocityCommand(10); 
  outlineContour(frame, 7);
  plotter.startPrinting();
}



void mousePressed() { 
  zoom = 3-zoom;
}

void serialEvent(Serial port) {
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