import processing.serial.*;

SensorReader sensorReader; 

PImage dataImage; 
String serialName = "/dev/tty.usbmodem1421";

void setup() {
  size(800, 600);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);

  // List all the available serial ports:
  printArray(Serial.list());

  sensorReader = new SensorReader(this, serialName); 

  dataImage = createImage(800, 300, RGB);
}

void draw() {
  sensorReader.update();

  background(0);

  fill(255); 
  text(frameCount%60, 10, 10);
  text(sensorReader.temperature + "º " +sensorReader.r + " "+sensorReader.g + " "+sensorReader.b + " ", 10, 130);
  text(sensorReader.getColourTemperature()+ " " +sensorReader.getLux(), 10, 160);

  fill(sensorReader.getRGBColourTemperature()); 
  //println(hex(sensorReader.getRGBColourTemperature()));
  rect(100, 0, 100, 100);


  if (frameCount%6==0) { 
    updateDataImage();
  }
  fill(255);
  image(dataImage, 0, 300);
}

void updateDataImage() { 

  dataImage.loadPixels();
  if (frameCount%(60*60)==0) scrollPixelsLeft(dataImage); 

  setRightPixelForValue(dataImage, sensorReader.getColourTemperature(), 3000, 18000, sensorReader.getRGBColourTemperature() ); 
  setRightPixelForValue(dataImage, sensorReader.temperature, 0, 40, 0xffff0000 ); 
  setRightPixelForValue(dataImage, sensorReader.getLux(), 0, 5000, 0xff00ffff ); 

  dataImage.updatePixels();
}

void scrollPixelsLeft(PImage img) { 
  color[] pixelsToScroll = img.pixels;  
  // scroll everything one to the left
  for (int i = 1; i<pixelsToScroll.length; i++) { 
    if ((i-1)%img.width == img.width-1) pixelsToScroll[i-1] = 0x000000; 
    else pixelsToScroll[i-1] = pixelsToScroll[i];
  }
  pixelsToScroll[pixelsToScroll.length-1] = 0x00000000;
}
void setRightPixelForValue(PImage img, float v, float min, float max, color c) { 
  int y = round(constrain(map(v, min, max, img.height, 0), 0, img.height));
  setPixel(img, img.width-1, y, c);
}
void setPixel(PImage img, int x, int y, color c) { 
  if ((x<0) || (x>=img.width) || (y<0) || (y>=img.height)) return;
  int index = x+(y*img.width); 
  img.pixels[index] = c;
}

void serialEvent(Serial port) {
  //println("serial Event " + port);
  sensorReader.serialEvent(port);
}

void keyPressed() {
  // Send the keystroke out:
  //sensorSerialPort.write(key);
  //whichKey = key;
}

//void exit() { 
//  sensorReader.close();
//  println("DONE"p);
//}