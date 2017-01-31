import gab.opencv.*;
import processing.video.*;
import processing.serial.Serial;

MoodManager moodManager; 

void setup () { 
  size(1920,1080,P2D); 
  //fullScreen(P2D);
  textSize(12); 
  noSmooth();

  moodManager = new MoodManager(this); 
 // moodManager.timeSpeed = 1000; 
}

void draw() { 
  // scale to fit window
  pushMatrix();
  float scalefactor = (float)width/1920; 
  if(scalefactor>1) scalefactor =1; 
  scale(scalefactor); 
  background(30);
  fill(0); 
  rect(0, 0, 1920, 1080); 


  moodManager.update();

  moodManager.draw();

  float dataheight = 384; 


  popMatrix();
}

void drawData(int x, int y, int w, int h) {
}

void serialEvent(Serial port) {
  moodManager.sensorReader.serialEvent(port);
}