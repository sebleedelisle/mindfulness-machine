import gab.opencv.*; //<>//
import org.opencv.core.Mat; 
import geomerative.*;
import java.util.Collections;
////////// HELLO
PImage src, dst;
OpenCV opencv;

HPGLManager hpglManager; 

ArrayList<Contour> contours;
MatOfInt4 hierarchy;

ArrayList<Circle> circles; 
RShape mask; 

//float imageScale = 0.5; 


float penThickness = 0.7; 
float scale = 0.5; 

int shapenum = 0; 

boolean isFindingCircles = true; 
int frameStartTime; 

void setup() {

  hpglManager = new HPGLManager(this); 

  size(1170, 800, FX2D );

  surface.setResizable(true);

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);

  hpglManager.updatePlotterScale();



  RG.init(this); 

  RShape s = RG.loadShape("lottie.svg");
  mask = RG.centerIn(s, g);
  mask.scale(0.7, 0.7); 
  //mask.translate(width/2, height/2);

  circles = new ArrayList<Circle>();
  float y =  470; 
  //hpglManager.plotRect(150,y,40,40); 
  //hpglManager.plotCircle(20,y,20);
  //hpglManager.plotCircle(60,y,20); 
  //  hpglManager.plotRect(100,y,40,40); 
  //float x = 10;  

  //while(x<width) { 
  //   hpglManager.plotCircle(x,y,x/3);
  //   x+=x; 
  //}
}


void draw() {
  background(0);
  frameStartTime = millis(); 

  float zoom = 2; 
  PVector centre = new PVector(width/2, height/2); 
  pushMatrix(); 

  translate(centre.x, centre.y); 
  scale(zoom, zoom); 
  translate(-centre.x, -centre.y); 


  if ((isFindingCircles) && (circles.size()<5000)) { 

    rect(0, 0, 10, 10); 
    for (int i =0; i<30; i++) { 
      addCircle();
    }
  }

  pushMatrix(); 
  translate(width/2, height/2); 
  scale(scale, scale);
  for (int i = 0; i<circles.size(); i++) { 
    Circle c = circles.get(i);
    c.draw();
  }
  popMatrix(); 


  hpglManager.update();
  popMatrix();
}
void printCircles() { 
  Collections.sort(circles, new CircleComparator()); 
  for (int i = 0; i<8; i++) { 
    for (Circle c : circles) { 
      if (c.pen!=i) continue; 
      float r = c.r*scale; 
      float x = width/2 + (c.x*scale);
      float y = height/2 + (c.y*scale);

      if (c.r*scale<1) {
        hpglManager.addPenCommand(c.pen+1); 
        hpglManager.plotPoint(x, y);
      } else if (c.filled) {
        RShape cs = RG.getEllipse(x, y, r*2);
        if (!fillContour(cs, c.pen+1, false)) {
          hpglManager.addPenCommand(c.pen+1); 
          hpglManager.plotLine(x, y, x+0.1, y+0.1);
        }
      } else { 
        hpglManager.addPenCommand(c.pen+1); 
        hpglManager.plotCircle(x, y, r);
      }
    }
  }
}
void addCircle() { 

  float padding = 2; 
  float maxpadding = 50, minpadding = 4, minsize = 2, maxsize = 30, mindistance = 200, maxdistance = 600;
  float xscale = 1.6; 
  float yscale = 0.8; 
  RPoint p;
  boolean pointInShape; 
  int count = 0; 
  do { 

    float l = random(1); 
    //l = l*l; 
    l*=maxdistance; 
    float a = random(0, PI*2); 

    p = new RPoint(cos(a)*l*xscale, sin(a)*l*yscale); 
    pointInShape = mask.contains(p);
    if (!pointInShape) {
      for (Circle c : circles) { 
        if (c.contains(p.x, p.y)) { 
          pointInShape = true; 
          break;
        }
      }
    }
    count++;
  } while (pointInShape && (count<5000) &&(millis()-frameStartTime < 200));

  if (pointInShape) {
    //println("couldn't find any space"); 
    return;
  }

  RShape dot = RG.getEllipse(p.x, p.y, 0.1); 
  float closestDistance = maxsize; 
  float d = mask.getClosest(dot).distance;
  if (d<closestDistance) closestDistance = d; 

  for (Circle c : circles) { 
    float dist = c.dist(p.x, p.y);
    if (dist<closestDistance) closestDistance = dist;
  }

  //float closestDistance = sqrt(closestDistanceSq); 
  padding = clamp(map(distSq(0, 0, (p.x)/xscale, (p.y)/yscale), mindistance*mindistance, maxdistance*maxdistance, minpadding, maxpadding), minpadding, maxpadding); 

  float size = closestDistance-padding;
  if (size<minsize) return; 

  Circle circle = new Circle(p.x, p.y, size ); 
  /*
  circle.pen = floor(random(2)); 
   if(circle.pen ==0 ) {
   if ((size<10) && (random(3)<1)) circle.filled  = true; 
   } else {
   circle.filled  = true; 
   //    if ((size<20) && (random(2)<1)) circle.filled  = true; 
   }*/
  circle.pen = 0; 
  if ((size<6) && (random(3)<1)) circle.filled  = true; 
  circles.add(circle);
}

float distSq(float x1, float y1, float x2, float y2) { 
  float x = x2-x1; 
  float y = y2-y1; 
  return (x*x)+(y*y);
}

class Circle {

  float x, y, r;
  int pen;
  boolean filled; 
  public Circle(float cx, float cy, float cr) {
    x = cx; 
    y = cy; 
    r = cr;
    pen = 0;
  } 

  public void draw() { 

    int col = (pen==0)?255:180; 

    stroke(col); 

    if (filled)  
      fill(col);
    else 
    noFill(); 

    ellipseMode(RADIUS);
    ellipse(x, y, r, r);
  }
  public boolean contains(float px, float py) { 
    return (distSq(px, py) < (r*r));
  }
  public float distSq(float px, float py) { 
    float dx = x-px; 
    float dy = y-py; 
    return (dx*dx)+(dy*dy);
  }
  public float dist(float px, float py) { 

    return sqrt(distSq(px, py))-r;
  }
}
public class CircleComparator implements Comparator<Circle> {


  //public IntersectionComparator() {
  //}
  public int compare(Circle c1, Circle c2) {
    float stripwidth = 20; 
    if (floor(c1.x/stripwidth)==(floor(c2.x/stripwidth))) {
      int strip = floor(c1.x/stripwidth); 
      if (strip%2==0) return c1.y==c2.y ? 0 : (c1.y<c2.y) ? -1 : 1;  
      else return c1.y==c2.y ? 0 : (c1.y<c2.y) ? 1 : -1;
    } else { 
      return c1.x==c2.x ? 0 : (c1.x<c2.x) ? -1 : 1;
    }
    //if (c1.distSq(c2.x, c2.y)==0) {
    //  return 0;
    //} else if (c1.x<c2.x) {
    //  return -1;
    //} else {
    //  return 1;
    //}
  }
}