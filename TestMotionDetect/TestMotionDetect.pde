
import gab.opencv.*;
import processing.video.*;


OpenCV opencv;
PImage  before, after, grayDiff;
CameraManager camMan; 

void setup() { 

  size(1280, 800);
  //noSmooth();
  camMan = new CameraManager(this); 
  //opencv = new OpenCV(this, 640, 480);
}


void draw() { 
  background(0);
  camMan.update();
  camMan.draw();
}