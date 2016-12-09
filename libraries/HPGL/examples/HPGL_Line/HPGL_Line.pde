import fup.hpgl.*;
import processing.serial.*;

HPGL hpgl;

void setup() {
  /*
  !!! change the serial port here !!!
  */
  println(Serial.list());
  Serial serial = new Serial(this, Serial.list()[0]);
  
  hpgl = new HPGL(this, serial);
}

void draw() {
  // get the limits from the plotter
  int[] limits = (hpgl.hardClipLimits());
  
  hpgl.selectPen(1);
  hpgl.penDown();
  //hpgl.plotAbsolute(limits[2], limits[3]);
  
  
  float radius = limits[3]/4; 
  int halfWidth = limits[2]/2; 
  int halfHeight = limits[3]/2; 
  int plotWidth = limits[2]; 
  int plotHeight = limits[3]; 
  //hpgl.plotAbsolute(halfWidth, halfHeight); 
 // hpgl.rawCommand("CI250", false); 
  
  float angle = 0;
  for(float i = 0; i<180; i++) { 
    angle+=122; 
    hpgl.plotAbsolute(halfWidth + round(cos(radians(angle))*radius), halfHeight + round(sin(radians(angle))*radius));
    
  }

//  for(float i = 0; i<plotHeight/2; i+=plotHeight/100)  {
//   
//      hpgl.plotAbsolute(round(halfWidth-plotHeight/4 + i),  round(halfHeight/4) );
//      //hpgl.plotAbsolute(round(halfWidth-plotHeight/4), round(halfHeight - i) );
//    
//  }


  hpgl.penUp();
  hpgl.selectPen(0);
  
  exit(); 
  
}
