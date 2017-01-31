import processing.serial.*;

Plotter plotter; 
Serial serial;

void setup() { 


  size(1170, 800);
  
  color[] colours = new color[11]; 
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
 
  plotter = new Plotter(this, width, height);
  plotter.connectToSerial("usbserial"); 
  
   for (int i = 0; i<7; i++) { 
    plotter.setPenColour(i+1, colours[selectedpens[i]]);
  }
  plotter.setPenColour(0, #000000);  
   for (int i = 0; i<8; i++) { 
    plotter.setPenThickness(i, 0.8);
  }
  
  float xpos = 40; 
  float ypos = 0; 
 // plotter.setVelocity(1); 
  
  float s = 30; 
  float t = 5; 
  plotter.selectPen(7);
  plotter.addVelocityCommand(1);
  for(int i = 0; i<16; i++) { 
     plotter.moveTo(xpos, ypos); 
     plotter.lineTo(xpos+s,ypos); 
     plotter.lineTo(xpos+s, ypos+t); 
     plotter.lineTo(xpos+t, ypos+t); 
     plotter.lineTo(xpos+t, ypos+s); 
     plotter.lineTo(xpos, ypos+s);
     plotter.lineTo(xpos, ypos); 
     if(i%4==3) {
       xpos+=t; 
       ypos+=t; 
     }
  }
  //fo//r(float x = 0; x<100; x+=20) { 
  // p//lotter.selectPen(floor(random(8)));
  // p//lotter.moveTo(x, 0); 
  // p//lotter.lineTo(x,800); 
   
  // p//lotter.plotCircle(random(width), random(height), random(10,40));
    
  //}
//  //float x = 200;
  //plotter.moveTo(x, 0); 
  // plotter.lineTo(x,800);
  
 // plotter.printing = true;
}

void draw() { 
  plotter.update();
  plotter.renderPreview();
  //if(plotter.printing) plotter.plotCircle(random(width), random(height), random(10,40));
  
}


void keyPressed() { 
  if(key==ESC) { 
      plotter.close(); 
  }
   plotter.printing = true;  
  
}