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

color[] penColours = new color[8];
List<Shape> shapes;

void setup() { 

  size(1170, 800);

  penColours[0] = color(255, 0, 0); 
  penColours[1] = color(255, 128, 0); 
  penColours[2] = color(255, 255, 0); 
  penColours[3] = color(0, 255, 0); 
  penColours[4] = color(0, 255, 255); 
  penColours[5] = color(0, 0, 255); 
  penColours[6] = color(100, 0, 255); 
  penColours[7] = color(255, 64, 128);

  background(255); 
  stroke(0); 
  strokeWeight(2);
  makeShapes();
}


void draw() {
  background(255); 
  
  for (int i = 0; i<shapes.size(); i++) {
    Shape s = shapes.get(i); 
    fill(penColours[i%7]); 
    drawPath(s);
  }
  
  int index = floor((float)mouseX/(float)width*shapes.size()); 
  fill(0,255,255);
  println(millis(), index);
  drawPath(shapes.get(index));
  
  
  
}

void mousePressed() { 
    background(0);
  makeShapes();
}


float clamp(float v, float min, float max) { 
  if (max<min) { 
    float _min = min; 
    min = max;
    max = _min;
  }
  return max(min(v, max), min);
}