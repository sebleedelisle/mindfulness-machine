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


PImage source; 

  
void setup() {
  
  size(400, 400);
  surface.setResizable(true);
  
  hpglManager = new HPGLManager(this); 

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);
  hpglManager.updatePlotterScale();

source = loadImage("portrait.jpg");
  drawCirclePixels(true);


}


void draw() {
 


  boolean shiftDown = false; 

  if ((keyPressed) && (key == CODED) && (keyCode == SHIFT)) { 

    shiftDown = true;
  } 

  if(mouseDown) { 
    if(!drawing) hpglManager.moveTo(mouseX, mouseY); 
    else hpglManager.lineTo(mouseX, mouseY);
    drawing = true; 
    dirty = true; 
    
    
  } else { 
    drawing = false;
  } 
  
 
  if(dirty || hpglManager.printing) { 
    background(0); 
    hpglManager.update(); 

  }

  dirty = false;
}



PVector getPointAtRectIntersection(Rectangle r, PVector p1, PVector p2) { 

  if (r.containsPoint(p1) && r.containsPoint(p2)) { 
    println("WARNING - both points are inside rectangle - no intersection");
  } 
  else if (!r.containsPoint(p1) && !r.containsPoint(p2)) { 
    println("WARNING - neither point is within rectangle - no intersection");
  } 

  // need to make sure p1 is the one that is outside the rectangle. 
  if (r.containsPoint(p1)) { 
    PVector t = p1; 
    p1 = p2; 
    p2 = t;
  }
  PVector v = p2.copy(); 
  v.sub(p1); 

  PVector intersect = p1.copy(); 
  intersect.x = clamp(p1.x, r.x, r.getRight());
  intersect.y = clamp(p1.y, r.y, r.getBottom());  

  //ellipse(intersect.x, intersect.y, 2,2);
  float intersectionPoint = 1; 
  if ((intersect.x == r.x) || (intersect.x == r.getRight())) {
    // left or right side intersected
    float newIntersectionPoint = map(intersect.x, p1.x, p2.x, 0, 1);
    if (newIntersectionPoint<intersectionPoint) intersectionPoint = newIntersectionPoint;
  } 
  if ((intersect.y == r.y) || (intersect.y == r.getBottom())) {
    // top or bottom side intersected
    float newIntersectionPoint = map(intersect.y, p1.y, p2.y, 0, 1);
    if (newIntersectionPoint<intersectionPoint) intersectionPoint = newIntersectionPoint;
  } 
  v.mult(intersectionPoint);
  v.add(p1); 
  return v;
}

float clamp(float v, float minV, float maxV) { 
  return max(minV, min(maxV, v));
} 


int clamp(int v, int minV, int maxV) { 
  return max(minV, min(maxV, v));
} 

PVector getPositionAtX(PVector p1, PVector p2, float x) { 
  PVector v = p2.copy(); 
  v.sub(p1); 
  v.mult(map(x, p1.x, p2.x, 0, 1)); 
  v.add(p1); 
  return v;
}


void mousePressed() { 
  if (!focused) return; 


  mousePressPoint.set(mouseX, mouseY);
  mouseDown = true;
}

void mouseReleased() {
  mouseDown = false;
}

//------------------------------------------------------

//void changeDataScale(float scaleMultiplier) { 
//
//
//  float oldWidth =  hpglManager.plotWidth / hpglManager.scaleToPlotter / dataScale;    
//  float oldHeight =  hpglManager.plotHeight / hpglManager.scaleToPlotter / dataScale; 
//  dataScale *=scaleMultiplier;  
//  float newWidth =  hpglManager.plotWidth / hpglManager.scaleToPlotter / dataScale; 
//  float newHeight =  hpglManager.plotHeight / hpglManager.scaleToPlotter / dataScale; 
//  float offsetChangeX = ((newWidth-oldWidth)/2f);
//  float offsetChangeY = ((newHeight-oldHeight)/2f);
//
//  dataOffset.x += offsetChangeX; 
//  dataOffset.y += offsetChangeY; 
//
//  dirty = true;
//}

void warmUpPen() { 
  warmUpPen(15);
}
void warmUpPen(int numLines) { 


  hpglManager.addVelocityCommand(5);
  float size = height/5; 
  PVector p = new PVector(); 
  PVector lastPoint = new PVector(); 
  hpglManager.moveTo(0, 0); 
  
  for (int i = 0; i<numLines; i++) { 
  
   // if(i==0)   hpglManager.moveTo(p); 
  
    while ( (p.dist (lastPoint)< (size/5)) || (size-p.x<p.y)) {    
      p.set(random(size), random(size));
    }

    hpglManager.lineTo(p); 
    lastPoint.set(p);
  }
}


void drawCirclePixels() { 
  
  drawCirclePixels(false);
}

void drawCirclePixels(boolean small) { 
  float threshold = 200; 
  float plotterScale = hpglManager.screenHeight / source.height; 
  noFill();
  for(float y = 0; y<source.height; y+= 10) { 

    //threshold = ((linenum%3)+1)*50;
    
    for(float x = 0; x<source.width; x+=10) { 
      color c = source.get(clamp(floor(x+random(-6,6)), 0, source.width-1),clamp(floor(y+random(-6,6)),0,source.height));   
     
        if(brightness(c)<threshold){
          float size = (float)(threshold-brightness(c))/(float)threshold*0.5; 
          //ellipse(x*screenScale,y*screenScale,size*screenScale*60,size*screenScale*60); 
          //hpgl.plotAbsolute(round((x*plotterScale)), round(plotHeight*0.8 -(y*plotterScale)));
          //hpgl.rawCommand("CI"+(round(size*screenScale*300)), false);  
          if(small) { 
             drawStarSimple( (x*plotterScale), (y*plotterScale), size*plotterScale*50); 
          } else { 
            drawStarRandom( (x*plotterScale), (y*plotterScale), size*plotterScale*50); 
          }
          //println(round((x*plotterScale))+" "+ round(plotHeight*0.8 -(y*plotterScale)));
        }
     } 
   
  }
}


//
//void drawStar(float x, float y, float size) { 
// hpgl.penUp();
// for(float a = 0; a<=720; a+=720/5) {
//   
//   hpgl.plotAbsolute(round(x + (size*cos(radians(a)))), round(y+ (size*sin(radians(a)))));  
//   hpgl.penDown(); 
//   
// }
//  hpgl.penUp();
//  
//}
void drawStarRandom(float x, float y, float size) { 
 //hpgl.penUp();
 float startAngle = random(360); 
 PVector startPoint = new PVector(0,0); 
 for(float a = 0; a<=720; a+=720/5) {
   
   float thisSize = random(size*0.8, size);
   PVector p = new PVector(round(x + (thisSize*cos(radians(a+startAngle)))), round(y+ (thisSize*sin(radians(a+startAngle))))); 
   if(a == 0) { 
     startPoint = p;
      hpglManager.moveTo(p); 
      //hpglManager.lineTo(p); 
   } else { 
      hpglManager.lineTo(p); 
   } 
     
 }
  hpglManager.lineTo(startPoint);   
}

void drawStarSimple(float x, float y, float size) { 
 //hpgl.penUp();
 float startAngle = random(360); 
 
 for(float a = 0; a<=120; a+=60) {
   
   float thisSize = random(size*0.6, size*0.8);
   PVector p = new PVector(round(x + (thisSize*cos(radians(a+startAngle)))), round(y+ (thisSize*sin(radians(a+startAngle))))); 
   hpglManager.moveTo(p); 
   //hpglManager.lineTo(p); 
   p = new PVector(round(x + (thisSize*cos(radians(a+startAngle+180)))), round(y+ (thisSize*sin(radians(a+startAngle+180))))); 
     hpglManager.lineTo(p); 
 }
}



void stop() {

  hpglManager.close(); 
  super.stop();
}