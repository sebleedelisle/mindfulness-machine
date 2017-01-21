import java.awt.geom.Area;
import java.awt.Shape;
import java.awt.geom.Path2D;
import java.awt.geom.Path2D.Float;
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.PathIterator;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.AffineTransform; 
import java.util.List;

HPGLManager hpglManager; 

List<Shape> shapes;

float xzoom = 0;
float yzoom =0;
float zoom =1; 
int shapenum = 0; 

float penThickness = 1.5; 

color[] colours = new color[11]; 

void setup() { 
  size(1920, 1080, JAVA2D);
  noSmooth();
  hpglManager = new HPGLManager(this); 
  surface.setSize((int)(1080*hpglManager.aspectRatio), 1080);

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
  
  for (int i = 0; i<7; i++) { 
    hpglManager.setPenColour(i+1, colours[selectedpens[i]]);
  }
  hpglManager.setPenColour(0, #000000);  

  makeShapes();
}

void draw() { 


  scale(zoom);
  if (zoom==1) {
    xzoom = 0; 
    yzoom = 0;
  }
  xzoom += (constrain(map(mouseX, width*0.1, width*0.9, 0, - width * (zoom-1)/zoom), -width * (zoom-1)/zoom, 0)-xzoom)*0.1; 
  yzoom += (constrain(map(mouseY, height*0.1, height*0.9, 0, - height * (zoom-1)/zoom), -height * (zoom-1)/zoom, 0)-yzoom)*0.1; 
  translate(xzoom, yzoom); 


  background(250, 250, 255);
  noFill(); 

  strokeJoin(ROUND);
  strokeCap(ROUND);
  //blendMode(ADD); 
  //noFill();
  
  
  
  //for (int i = 0; i<shapes.size(); i++) {
  //  fill(hpglManager.getPenColour(i%3+5));
  //  stroke(0, 0, 0);
  //  strokeWeight(2);
  //  if (shapes.get(i).contains(mouseX, mouseY)) {
  //    stroke(255, 0, 0);
  //    strokeWeight(10);
  //    fill(0, 100);
  //  }
  //  drawPath(shapes.get(i));
  //}

  //if (shapenum<shapes.size()) { 
  //  Shape shape = shapes.get(pshapenum);
  //  //if(shape.getBounds().width<dst.width) 
  //  fillContour(shape, (shapenum%8)+1, penThickness, false);
  //  //fillContour(shape, 1, penThickness, false);
  //  shapenum++;
  //}
  hpglManager.update();
  hpglManager.renderCurrent();
}

void mousePressed() { 
  zoom = 3-zoom;
}