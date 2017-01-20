import processing.serial.*;

Plotter plotter; 
Serial serial;

void setup() { 


  size(1170, 800);
  
  plotter = new Plotter(this);
  plotter.connectToSerial("usbserial"); 
}

void draw() { 
  ///plotter.update();
}