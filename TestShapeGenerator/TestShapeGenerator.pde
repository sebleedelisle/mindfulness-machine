
import processing.serial.*;

import java.awt.geom.Area;
import java.awt.Shape;
import java.awt.geom.Path2D;
import java.awt.geom.Path2D.Float;
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.PathIterator;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.AffineTransform; 
import java.util.List;

Plotter plotter; 

List<ShapeData> shapes;

String currentDateString = "00:00:00"; 

float xzoom = 0;
float yzoom =0;
float zoom =1; 
int shapenum = 0; 

float penThickness = 1.5; 
int issueNumber; 
color[] colours = new color[11]; 
int drawingNumber; 

void setup() { 

  size(1620, 1080, P2D);
  noSmooth();
  plotter = new Plotter(this, width, height); 
  plotter.connectToSerial("usbserial"); 
  //println(plotter.aspectRatio);
  //surface.setSize((int)(1080*plotter.aspectRatio), 1080);

  colours[0] = #FF4DD6; // pink
  colours[1] = #DE2B30;   // red
  colours[2] = #A05C2F;// light brown
  colours[3] = #744627;  // dark brown
  colours[4] = #266238; // dark green 
  colours[5] = #49AF55; // light green 
  colours[6] = #FFE72E ; // yellow
  colours[7] = #FF8B17 ; // orange
  colours[8] = #6722B2 ; // purple
  colours[9] = #293FB2 ; // navy blue
  colours[10] = #6FC6FF ; // sky blue

  int[] selectedpens = new int[8];
  selectedpens[0] = 3;
  selectedpens[1] = 8;
  selectedpens[2] = 9;
  selectedpens[3] = 5;
  selectedpens[4] = 1;
  selectedpens[5] = 0;
  selectedpens[6] = 6;

  for (int i = 0; i<7; i++) { 
    plotter.setPenColour(i, colours[selectedpens[i]]);
  }
  plotter.setPenColour(7, #000000);  

  for (int i = 0; i<8; i++) { 
    plotter.setPenThicknessMM(i, 0.8);
  }

  initGui();

  // makeShapes();
}

void draw() { 
  drawingNumber = seedValue; 
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

  strokeJoin(ROUND);
  strokeCap(ROUND);

  plotter.update();


  if (plotter.printing) plotter.renderPreview();
  else { 

    if (shapes!=null) { 
      fill(250); 
      rect(0, 0, plotter.screenWidth, plotter.screenHeight); 
      for (int i = 0; i<shapes.size(); i++) { 
        stroke(0); 
        fill(plotter.getPenColour(shapes.get(i).getPenNumber())); 
        drawPath(shapes.get(i).getShape());
      }
    }
  }
  popMatrix();

  for (int i = 0; i<8; i++) { 
    stroke(255);
    fill(plotter.getPenColour(i)); 
    rect(50, 400+((7-i)*60), 50, 50);
  }
  fill(255);
  text(moodManager.getMoodDescription(happy, stim), 1500, 500);
}


void mousePressed() {
}

void keyPressed() { 

  if (key=='z') {
    zoom = 3-zoom; 
    xzoom += (constrain(map(mouseX, width*0.1, width*0.9, 0, - width * (zoom-1)/zoom), -width * (zoom-1)/zoom, 0)-xzoom); 
    yzoom += (constrain(map(mouseY, height*0.1, height*0.9, 0, - height * (zoom-1)/zoom), -height * (zoom-1)/zoom, 0)-yzoom);
  }
  key = (""+key).toUpperCase().charAt(0);
  println(key);
  if (key == 'H') {
    println("INIT"); 
    //plotter.initHPGL();
  } else if (key == 'P') {
    println("PRINT"); 
    //for (ShapeData shape : shapes) {
    //  outlineContour((Shape)shape.getShape(), 7,false);
    //}
    plotter.startPrinting();
  } else if (key == 'C') {
    shapenum = 0;
    for (ShapeData shape : shapes) {
      fillContour((Shape)shape.getShape(), shape.getPenNumber(), penThickness);
      shapenum++;
    }
  } else if (key == 'S') {
    makeShapes(shapeType, seedValue, happy, stim, plotter.screenWidth, plotter.screenHeight);
  } else if (key == '=') {
  } else if (key =='w') {
  } else if (keyCode == RIGHT) {
    typeSlider.setValue(typeSlider.getValue()+1);
  } else if (keyCode == LEFT) {
    typeSlider.setValue(typeSlider.getValue()-1);
  } else if (keyCode == UP) {
    seedSlider.setValue(seedSlider.getValue()+1);
  } else if (keyCode == DOWN) {
    seedSlider.setValue(seedSlider.getValue()-1);
  } else if (key=='l') {
  }
}


void serialEvent(Serial port) { 
  plotter.serialEvent(port);
}
MoodManager moodManager = new MoodManager();
class MoodManager { 

 String getMoodDescription(float happiness, float stimulation) { 
    String[][] moods = { 
      {"Miserable", "Melancholy", "Stressed", "Panicking"}, // sad
      {"Lethargic", "Dissatisfied", "On edge", "Jittery" }, 
      {"Satisfied", "Calm", "Focussed", "Confident"},     
      {"Carefree", "Cheerful", "Engaged", "Ecstatic"}  // happy 
 
    };

    int happyIndex = mapConstrainFloor(happiness, 0, 1, 0, 3.99f); 
    int stimIndex = mapConstrainFloor(stimulation, 0, 1, 0, 3.99f); 
    return moods[happyIndex][stimIndex];
  }
}