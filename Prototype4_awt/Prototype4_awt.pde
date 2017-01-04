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

void setup() { 
  size(1170, 800);
  hpglManager = new HPGLManager(this); 
  makeShapes();
//  shapes = new ArrayList<Shape>();
//  int rows = 3; 
//  int cols = 5; 

//  for (int i=0; i<rows*cols; i++) { 

//    double xpos = i%cols*60; 
//    double ypos = floor(i/cols)*60; 
//    //xpos+=random(-10, 10)+20; 
//    //ypos+=random(-10, 10)+20;
//    xpos+=20;
//    ypos+=20; 

//    Ellipse2D.Double e = new Ellipse2D.Double(xpos, ypos, 70, 70);  
//    Ellipse2D.Double e2 = new Ellipse2D.Double(e.x+20, e.y+20, e.width-40, e.height-40); 
//    //if (random(1)<0.8) { 
//    Area a = new Area(e); 
//    a.subtract(new Area(e2)); 

//    //AffineTransform at = new AffineTransform(); 
//    //at.scale(0.5,0.5);
//    //a.transform(at);

//    shapes.add(a);
//    //} else { 
//    //  shapes.add(e2);
//    //}
//  }

  long start = millis(); 
  removeOverlaps(shapes);
  Collections.reverse(shapes);
  for (Shape s : shapes) {
    outlineContour(s, 1, false);
  }
  println("ovelap removal too " + (millis()-start) + "ms"); 
  //noLoop();
}

void draw() { 


  scale(zoom);

  xzoom += (clamp(map(mouseX, width*0.1, width*0.9, 0, - width * (zoom-1)/zoom), -width * (zoom-1)/zoom, 0)-xzoom)*0.1; 
  yzoom += (clamp(map(mouseY, height*0.1, height*0.9, 0, - height * (zoom-1)/zoom), -height * (zoom-1)/zoom, 0)-yzoom)*0.1; 
  translate(xzoom, yzoom); 


  background(0);
  noFill(); 
  strokeWeight(1);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  blendMode(ADD); 

  //for (Shape s : shapes) { 

  //  if (s.contains(new Point2D.Float(mouseX/zoom-xzoom, mouseY/zoom-yzoom))) { 
  //    //fill(255,0,0);  
  //    fillContour(s, 1, 2, true);
  //  } else { 
  //    //noFill();
  //  }
  //  stroke(255, 50, 50);
  //  drawPath(s);
  //}

  //if (shapenum<shapes.size()) { 
  //  Shape shape = shapes.get(shapenum);
  //  //if(shape.getBounds().width<dst.width) 
  //  fillContour(shape, (shapenum%8)+1, penThickness, false);
  //  //fillContour(shape, 1, penThickness, false);
  //  shapenum++;
  //}
  hpglManager.update();
}

void mousePressed() { 
  zoom = 3-zoom;
}