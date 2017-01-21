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

ArrayList<RShape> shapes; 
ArrayList<RotatedRect> rects; 

float imageScale = 0.5; 

float penThickness = 2; 

int shapenum = 0; 

void setup() {

  hpglManager = new HPGLManager(this); 

  size(1170, 800);

  surface.setResizable(true);

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);

  hpglManager.updatePlotterScale();

  hpglManager.setVelocity(2); 

  RG.init(this); 

  //RShape s = RShape.createRing(200, 200, 300, 200); 
  //fillContour(s, 0);

  shapes = new ArrayList<RShape>();

  //RShape r = RShape.createRectangle(350,50,100,100);
  //RShape r2 = RShape.createRectangle(360,50,80,80);
  //r.polygonize(); 
  //r2.polygonize();
  //r = r.diff(r2);
  //shapes.add(r);
  getShapesForImage("test-parrot.jpg", imageScale); 

  for (RShape shape : shapes) {

    //if (shape.contains(mouseX, mouseY)) {
    //fillContour(shape, true);
    //}
  }
  //   hpglManager.startPrinting();
  //noLoop();
}


void draw() {
  background(0);
  text(0,0,frameCount); 
  scale(0.5, 0.5);
  //strokeWeight(.5);
  //background(0); 
  pushMatrix(); 
  scale(imageScale, imageScale); 
  //image(dst, src.width, 0);

  //image(dst, 0, 0);

  popMatrix(); 
  
  if(shapenum<shapes.size()) { 
    fillContour(shapes.get(shapenum), (shapenum%8)+1,true);
    shapenum++;     
  }
  hpglManager.update();
}

void getShapesForImage(String filename, float scale) { 

  shapes = new ArrayList<RShape>();
  rects = new ArrayList<RotatedRect>(); 

  src = loadImage(filename); 

  opencv = new OpenCV(this, src);

  opencv.gray();
  //opencv.blur(3);
  //opencv.invert();
  opencv.threshold(100);
  //opencv.erode();
  dst = opencv.getOutput();

  contours = findContours(true);

  int index = 0; 
  int level = 0; 

  do { 

    Contour contour = contours.get(index); 
    //contour.setPolygonApproximationFactor(1);
    double[] h  = hierarchy.get(0, index);
    RShape s = new RShape();
    boolean move = true; 
    for (PVector point : contour.getPoints()) {
      if (move) {
        move = false; 
        s.addMoveTo(point.x*scale, point.y*scale);
      } else { 
        s.addLineTo(point.x*scale, point.y*scale);
      }
    }
    s.addClose();
    if (level == 0 ) { 

      shapes.add(s);
      RotatedRect r = getMinAreaRect(contour); 
      r.size.width*=scale; 
      r.size.height*=scale; 
      r.center.x*=scale; 
      r.center.y*=scale; 
      rects.add(r);
    } else { 
      RShape last = shapes.get(shapes.size()-1); 
      shapes.remove(shapes.size() - 1);
      last = RG.diff(last, s); 
      shapes.add(last);
    }


    if (h[2]>=0) { 
      // if we have a child, use that next
      index = (int)h[2];
      level++;
    } else if (h[0]>=0) { 
      // otherwise use the next in line
      index = (int)h[0];
    } else if (h[3]>=0) { 
      // otherwise if we have a parent, then go up a level, and 
      // use the parent's next sibling
      index = (int)h[3]; 
      h = hierarchy.get(0, index); 
      index = (int)h[0];
      level--;
    } else { 
      index = -1;
    }
  } while ((index>=0) && (index<contours.size()));
}