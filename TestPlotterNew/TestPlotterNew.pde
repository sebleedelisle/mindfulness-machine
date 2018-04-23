import processing.serial.*;

Plotter plotter; 

void setup() { 


  size(1170, 800);

  color[] colours = new color[11]; 
  // default colours
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
  // default pen set up
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
    plotter.setPenThicknessMM(i, 0.8);
  }
  
  plotter.selectPen(floor(random(8)));
  
  for (float x = 0; x<1000; x+=20) { 
    
    float y = random(790); 
    plotter.moveTo(x, y); 
    plotter.lineTo(x, y+10); 

    //plotter.plotCircle(random(width), random(height), random(10, 40));
  }
  
  plotter.debug = true;
  //float x = 200;
  //plotter.moveTo(x, 0); 
  // plotter.lineTo(x,800);
  //plotter.dry =true; 
  // plotter.printing = true;
}

void draw() { 
  plotter.update();
  plotter.renderPreview();
  //if(plotter.printing) plotter.plotCircle(random(width), random(height), random(10,40));
}


void keyPressed() { 
  if (key==ESC) { 
    plotter.close();
  }
  plotter.printing = true;
}

void serialEvent(Serial port) { 
  //plotter.serialEvent(port);
}