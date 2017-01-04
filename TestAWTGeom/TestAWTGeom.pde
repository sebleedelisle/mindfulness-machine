import java.awt.geom.Area;
import java.awt.Shape;
import java.awt.geom.Path2D;
import java.awt.geom.Path2D.Float;
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D;
import java.awt.geom.PathIterator;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.AffineTransform; 
import java.util.List;
import de.erichseifert.gral.util.GeometryUtils; 

Path2D path1 = new Path2D.Float(); 
Path2D path2 = new Path2D.Float(); 


void setup() { 
  size(1000, 800);
  path1.setWindingRule( PathIterator.WIND_EVEN_ODD );
  path1.moveTo(100, 100);
  path1.lineTo(200, 100); 
  path1.quadTo(200, 200, 100, 200); 
  //path1.lineTo(100, 100);
  path1.closePath();
  path1.moveTo(120, 120); 
  path1.lineTo(180, 120); 
  path1.quadTo(180, 180, 120, 180); 
  path1.closePath(); 


  AffineTransform a = new AffineTransform(); 
  a.translate(-150, -150);
  path1.transform(a);
  //noLoop();
}

void draw() { 
  background(0);


  path2 = (Path2D)path1.clone(); 
  AffineTransform a = new AffineTransform(); 
  a.translate(mouseX, mouseY);
  path2.transform(a);

  Path2D path = (Path2D)path1.clone(); 
  a = new AffineTransform(); 
  a.translate(width/2, height/2); 
  path.transform(a); 
  Area a1 = new Area(path); 
  Area a2 = new Area(path2); 
  //a2 = GeometryUtils.grow(a2, map(mouseX, 0, width, -10, 40));
  a1.exclusiveOr(a2);

  if (a1.contains(mouseX, mouseY)) { 
    fill(255, 0, 0);
  } else { 
    fill(255);
  }
  stroke(0, 255, 0);

  Area a3 = GeometryUtils.grow(a1, -3);
  
  drawPath(a1);
  drawPath(a3);
  
  for(float xoffset = -200; xoffset<200; xoffset+=20) { 
    Line2D.Float l = new Line2D.Float(mouseX-100+xoffset, 0, mouseX+100+xoffset, 800); 
    line(l.x1, l.y1, l.x2, l.y2); 
    List<Point2D> ips = GeometryUtils.intersection(a3, l); 
    for(Point2D ip : ips) { 
      ellipse((float)ip.getX(), (float)ip.getY(), 5, 5);  
      
    }
  }
 a = new AffineTransform(); 
  a.translate(200, 0);
  a3.transform(a);
  Line2D[] lines = GeometryUtils.shapeToLines(a3, true);
  noFill();
  drawPath(a3);
  stroke(255,0,0);
  for(Line2D line : lines) { 
   line((float)line.getX1(), (float)line.getY1(),(float)line.getX2(), (float)line.getY2());
  }
  
  
  //drawPath(path2);
}

void drawPath(Shape path) { 
  beginShape(); 
  PathIterator pi = path.getPathIterator(null);
  //PathIterator pi = new FlatteningPathIterator(path.getPathIterator(null), 0.1);
  PVector lastMove = new PVector(); 

  int shapecount = 0; 
  boolean shapeopen = false; 
  boolean contouropen = false; 
  
  boolean verbose = false; 

  while (pi.isDone() == false) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);


    switch (type) {

    case PathIterator.SEG_MOVETO:

      if(verbose) println("move to " + coordinates[0] + ", " + coordinates[1]);
      if (shapecount ==0) { 
        beginShape(); 
        shapeopen = true;
      } else {
        if (shapecount>1) { 
          if (contouropen) endContour();
        }
        beginContour(); 
        contouropen = true;
      }
      vertex(coordinates[0], coordinates[1]); 
      lastMove.set(coordinates[0], coordinates[1]); 
      shapecount++; 
      break;
    case PathIterator.SEG_LINETO:
      if(verbose) println("line to " + coordinates[0] + ", " + coordinates[1]);
      vertex(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_QUADTO:
      if(verbose) println("quadratic to " + coordinates[0] + ", " + coordinates[1] + ", "+ coordinates[2] + ", " + coordinates[3]);
      quadraticVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      break;
    case PathIterator.SEG_CUBICTO:
      if(verbose) println("cubic to " + coordinates[0] + ", " + coordinates[1] + ", "   + coordinates[2] + ", " + coordinates[3] + ", " + coordinates[4] + ", " + coordinates[5]);
      quadraticVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      break;
    case PathIterator.SEG_CLOSE:
      if(verbose) println("close "+ coordinates[0] + ", " + coordinates[1]);
      vertex(lastMove.x, lastMove.y); 
      break;
    default:
      break;
    }
    pi.next();
  }
  if (contouropen) endContour(); 
  if (shapeopen) endShape();
}