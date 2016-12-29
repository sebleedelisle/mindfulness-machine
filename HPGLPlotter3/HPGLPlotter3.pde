import fup.hpgl.*;
import processing.serial.*;
import java.util.Date;


HPGLManager hpglManager; 

//Date startTime = new Date();  // MM/DD/YY

PVector mousePressPoint = new PVector(); 
boolean mouseDown = false; 

boolean drawing = false; 

boolean[] keys = new boolean[526];
int keysPressedCount = 0; 

boolean dirty = true; 




void setup() {

  size(400, 400);
  surface.setResizable(true);

  hpglManager = new HPGLManager(this); 

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);
  hpglManager.updatePlotterScale();

  //drawCirclePixels(true);
  drawTestSquares();
}
void drawTestSquares() {

  int w = width; 
  int h = height; 
  int size = width/20;
  int counter = 0; 
  for (int x = 0; x<width; x+= size) { 
    for (int y = 0; y<height; y+=size) { 
      //hpglManager.addPenCommand(counter%2); 
      drawFilledRect(counter%2, x, y, size, size);

      counter ++;
    }
  }
  hpglManager.addPenCommand(0); 
  hpglManager.addPenCommand(0);
}

void drawFilledRect(int pencolour, int x, int y, int w, int h) {  
  
  int linewidth = 2; 
  hpglManager.addPenCommand(pencolour); 
  hpglManager.moveTo(x,y); 
  
  for(int xpos = x; xpos<x+w; xpos+=linewidth) { 
    hpglManager.lineTo(xpos, y+h);
    hpglManager.lineTo(xpos+linewidth, y); 
    
  }
}



void draw() {

  boolean shiftDown = false; 

  if ((keyPressed) && (key == CODED) && (keyCode == SHIFT)) { 

    shiftDown = true;
  } 

  //  this is some simple code that draws what you draw to the plotter 
  //    if (mouseDown) { 
  //        if (!drawing) hpglManager.moveTo(mouseX, mouseY); 
  //        else hpglManager.lineTo(mouseX, mouseY);
  //        drawing = true; 
  //        dirty = true;
  //    } else { 
  //        drawing = false;
  //    } 


  if (dirty || hpglManager.printing) { 
    background(0); 
    hpglManager.update();
  }

  dirty = false;
}



void mousePressed() { 
  if (!focused) return; 


  mousePressPoint.set(mouseX, mouseY);
  mouseDown = true;
}

void mouseReleased() {
  mouseDown = false;
}



//void drawCirclePixels() { 

//    drawCirclePixels(false);
//}

//void drawCirclePixels(boolean small) { 
//    float threshold = 200; 
//    float plotterScale = hpglManager.screenHeight / source.height; 
//    noFill();
//    for (float y = 0; y<source.height; y+= 10) { 

//        //threshold = ((linenum%3)+1)*50;

//        for (float x = 0; x<source.width; x+=10) { 
//            color c = source.get(clamp(floor(x+random(-6, 6)), 0, source.width-1), clamp(floor(y+random(-6, 6)), 0, source.height));   

//            if (brightness(c)<threshold) {
//                float size = (float)(threshold-brightness(c))/(float)threshold*0.5; 
//                //ellipse(x*screenScale,y*screenScale,size*screenScale*60,size*screenScale*60); 
//                //hpgl.plotAbsolute(round((x*plotterScale)), round(plotHeight*0.8 -(y*plotterScale)));
//                //hpgl.rawCommand("CI"+(round(size*screenScale*300)), false);  
//                if (small) { 
//                    drawStarSimple( (x*plotterScale), (y*plotterScale), size*plotterScale*50);
//                } else { 
//                    drawStarRandom( (x*plotterScale), (y*plotterScale), size*plotterScale*50);
//                }
//                //println(round((x*plotterScale))+" "+ round(plotHeight*0.8 -(y*plotterScale)));
//            }
//        }
//    }
//}



void stop() {

  hpglManager.close(); 
  super.stop();
}