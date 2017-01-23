
import processing.serial.*;
import processing.video.*;
import gab.opencv.*;

final int STATE_CAMERA_SETUP = 0; 
final int STATE_WAIT_PENS = 1; 
final int STATE_WAIT_PAPER = 2; 
final int STATE_DRAWING = 3; 

int state = STATE_WAIT_PAPER; 

Plotter plotter; 
MoodManager moodManager; 
ColourChooser colourChooser; 

List<Shape> shapes;

float xzoom = 0;
float yzoom =0;
float zoom =1; 
int shapenum = 0; 
int currentColourShape = 0; 

color[] colours = new color[11]; 

void setup() { 

  fullScreen(); 
  noSmooth();

  moodManager = new MoodManager(this); 
  plotter = new Plotter(this, width, height); 

  colourChooser = new ColourChooser(this); 

  //  int[] selectedpens = new int[8];
  //  selectedpens[0] = 3;
  //  selectedpens[1] = 8;
  //  selectedpens[2] = 9;
  //  selectedpens[3] = 5;
  //  selectedpens[4] = 1;
  //  selectedpens[5] = 0;
  //  selectedpens[6] = 6;

  //  for (int i = 0; i<7; i++) { 
  //    plotter.setPenColour(i+1, colours[selectedpens[i]]);
  //  }
  //  plotter.setPenColour(0, #000000);  

  //  for (int i = 0; i<8; i++) { 
  //    plotter.setPenThickness(i, 0.8);
  //  }

  //startDrawing(); 
  //makeShapes();

  plotter.connectToSerial("usbserial");
  
}

void draw() { 

  moodManager.update();
  plotter.update();

  switch(state) { 
  case STATE_CAMERA_SETUP : 

    background(0); 
    moodManager.renderCamera(0, 0, width, height); 
    break;

  case STATE_WAIT_PAPER : 

    background(0); 
    moodManager.draw();
    fill(255);
    textAlign(CENTER, CENTER); 
    text("CHANGE PAPER AND PRESS SPACE", width/2, height/2); 
    break;


  case STATE_DRAWING : 


    if (plotter.finished) { 
      if (currentColourShape>=shapes.size()) {
        state = STATE_WAIT_PAPER; // TODO make function called plotFinished
      } else { 
        fillContour(shapes.get(currentColourShape), currentColourShape%7+1, 1.5, false);   
        currentColourShape++; 
        plotter.startPrinting();
      }
    }
    pushMatrix(); 
    scale(zoom);
    if (zoom==1) {
      xzoom = 0; 
      yzoom = 0;
    }
    xzoom += (constrain(map(mouseX, width*0.1, width*0.9, 0, - width * (zoom-1)/zoom), -width * (zoom-1)/zoom, 0)-xzoom)*0.1; 
    yzoom += (constrain(map(mouseY, height*0.1, height*0.9, 0, - height * (zoom-1)/zoom), -height * (zoom-1)/zoom, 0)-yzoom)*0.1; 
    translate(xzoom, yzoom); 


    background(0);
    noFill(); 


    //blendMode(ADD); 
    //noFill();
    //blendMode(BLEND);
    //tint(255,255); 
    //pushStyle(); 
    //plotter.renderPreview(); 
    //blendMode(ADD); 
    //fill(200); 
    //rect(0,0,width, height);
    //tint(255,220); 
    //blendMode(MULTIPLY);
    plotter.renderProgress();
    //popStyle(); 
    popMatrix(); 

    fill(0); 
    rect(0, 0, width, 400); 
    moodManager.draw();
    break;
  }
}




Boolean controlPressed = false; 
void keyPressed() { 
  key = (""+key).toUpperCase().charAt(0);
  println(key);
  if (key == ' ') {
    println("SPACE"); 
    nextState();
  } else if (key == 'H') {
    println("INIT"); 
    //plotter.initHPGL();
  } else if (key == 'P') {
    println("PRINT"); 
    plotter.startPrinting();
  } else if (key == 'C') {
    shapenum = 0;
    for (Shape shape : shapes) {
      int colourIndex = (shapenum%7)+1;
      fillContour(shape, colourIndex, plotter.getPenThicknessPixels(colourIndex), false);
      shapenum++;
    }
  } else if (key == 'S') {
    makeShapes();
  } else if (key == '=') {
  } else if (key =='w') {
  } else if (keyCode == RIGHT) {
  } else if (keyCode == LEFT) {
  } else if (keyCode == UP) {
  } else if (keyCode == DOWN) {
  } else if (key=='l') {
  }
}

void nextState() { 
  if (state == STATE_CAMERA_SETUP) { 
    state = STATE_WAIT_PAPER; // assume we always need to change paper on startup
  } else if (state == STATE_WAIT_PAPER) {
    // check if we need to change pens, if so
    // ask PenManager? 
    state = STATE_WAIT_PENS; 
    // else 
    startDrawing();
  }
}

void startDrawing() { 

  state = STATE_DRAWING; 
  makeShapes(); 
  plotter.startPrinting(); 
  currentColourShape = 0;
}


void mousePressed() { 
  zoom = 3-zoom;
}

void serialEvent(Serial port) {
  moodManager.sensorReader.serialEvent(port);
  plotter.serialEvent(port);
}