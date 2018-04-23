import java.awt.geom.Area;
import java.awt.Shape;
import java.awt.Polygon; 
import java.awt.geom.Path2D;
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.PathIterator;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.AffineTransform; 
import java.util.List;

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

      if (verbose) println("move to " + coordinates[0] + ", " + coordinates[1]);
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
      if (verbose) println("line to " + coordinates[0] + ", " + coordinates[1]);
      vertex(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_QUADTO:
      if (verbose) println("quadratic to " + coordinates[0] + ", " + coordinates[1] + ", "+ coordinates[2] + ", " + coordinates[3]);
      quadraticVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      break;
    case PathIterator.SEG_CUBICTO:
      if (verbose) println("cubic to " + coordinates[0] + ", " + coordinates[1] + ", "   + coordinates[2] + ", " + coordinates[3] + ", " + coordinates[4] + ", " + coordinates[5]);
      bezierVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      break;
    case PathIterator.SEG_CLOSE:
      if (verbose) println("close "+ coordinates[0] + ", " + coordinates[1]);
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

PVector getStartPoint(Shape a) { 
  PathIterator pi = new FlatteningPathIterator(a.getPathIterator(null), 0.1);
  float[] coordinates = new float[6];
  if (!pi.isDone() ) {
    int type = pi.currentSegment(coordinates);
  }

  return new PVector(coordinates[0], coordinates[1]);
}

PVector getEndPoint(Shape a) { 
  PathIterator pi = new FlatteningPathIterator(a.getPathIterator(null), 0.1);

  float[] coordinates = new float[6];
  while (!pi.isDone() ) {

    int type = pi.currentSegment(coordinates);
    pi.next();
  }
  return new PVector(coordinates[0], coordinates[1]);
}
List<Shape> breakArea(Area a) { 
  ArrayList<Shape> shapes = new ArrayList<Shape>(); 

  PathIterator pi = a.getPathIterator(null);

  Path2D path = new Path2D.Float(); 

  while (pi.isDone() == false) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);

    switch (type) {

    case PathIterator.SEG_MOVETO:
      shapes.add(path); 
      path = new Path2D.Float(); 
      path.moveTo(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_LINETO:
      path.lineTo(coordinates[0], coordinates[1]); 
      break;
    case PathIterator.SEG_QUADTO:
      path.quadTo(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      break;
    case PathIterator.SEG_CUBICTO:
      path.curveTo(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      break;
    case PathIterator.SEG_CLOSE:
      path.closePath(); 
      break;
    default:
      break;
    }
    pi.next();
  }
  shapes.add(path); 

  // subtract holes
  //for (int i = 0; i<shapes.size(); i++) { 
  //  Shape shape1 = shapes.get(i); 
  //  //if(shape1.isEmpty()) continue; 
  //  for (int j = 0; j<shapes.size(); j++) { 
  //    if (j==i) continue; 
  //    Shape shape2 = shapes.get(j); 

  //    //if(shape2.isEmpty()) continue; 

  //    if (shapeContainsShape(shape1, shape2)) { 
  //      Area area;

  //      area = new Area(shape1); 
  //      area.subtract(new Area(shape2));
  //      shapes.set(i, area);
  //      //shapes.set(j, new Area()); 

  //    }
  //  }
  //}
  Collections.reverse(shapes);
  return shapes;
}
boolean shapeContainsShape(Shape shape1, Shape shape2) { 
  PathIterator pi = new FlatteningPathIterator(shape2.getPathIterator(null), 0.1);
  while (!pi.isDone()) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);
    if ( (type == PathIterator.SEG_LINETO)) {

      if (!shape1.contains(coordinates[0], coordinates[1])) return false;
    }
    pi.next();
  }

  return true;
}


Polygon createPolygon(float x, float y, int numsides, float radius) { 
  Polygon p = new Polygon(); 
  for (int i = 0; i < numsides; i++)
    p.addPoint((int) (x + radius * Math.cos(i * 2 * PI / numsides)), 
      (int) (y + radius * Math.sin(i * 2 * PI / numsides)));
  return p;
}  

Polygon createStar(float x, float y, int numsides, float innerradius, float outerradius) { 
  Polygon p = new Polygon(); 
  for (int i = 0; i < numsides; i++) {
    p.addPoint((int) (x + outerradius * Math.cos(i * 2 * PI / numsides)), 
      (int) (y + outerradius * Math.sin(i * 2 * PI / numsides)));
    p.addPoint((int) (x + innerradius * Math.cos((i+0.5) * 2 * PI / numsides)), 
      (int) (y + innerradius * Math.sin((i+0.5) * 2 * PI / numsides)));
  }
  return p;
}

void removeOverlaps(List<Shape> shapes) { 
  long start = millis(); 

  for (int i = 0; i<shapes.size(); i++) { 

    Area a1 = new Area(shapes.get(i)); 

    boolean shapeChanged = false; 

    for (int j = i+1; j<shapes.size(); j++) {
      Shape s2 = shapes.get(j); 

      if (shapeCollisionTest(a1, s2)) {
        Area a2 = new Area(s2); 
        a1.subtract(a2);
        shapeChanged = true;
      }
    }

    if (shapeChanged) shapes.set(i, a1);
  }

  //// make area with the last shape in it (the one on top); 
  //Area a = new Area(shapes.get(shapes.size()-1)); 

  //for (int i = shapes.size()-2; i>=0; i--) { 

  //  Shape s = shapes.get(i); 
  //  //if (shapeCollisionTest(a, s)) {
  //  Area a2;
  //  if (s instanceof Area) 
  //    a2 = (Area)s;
  //  else 
  //  a2 = new Area(s); 
  //  a2.subtract(a);
  //  shapes.set(i, a2);

  //  a.add(a2);
  //}


  println("ovelap removal took " + (millis()-start) + "ms");
}

boolean shapeCollisionTest(Shape s1, Shape s2) { 

  if (!rectIntersectsRect(s1.getBounds2D(), s2.getBounds2D())) return false;  

  Area a1; 
  Area a2; 
  a1 = new Area(s1);
  if (s2 instanceof Area) a2 = (Area)s2; 
  else a2 = new Area(s2);
  a1.intersect(a2); 

  return !a1.isEmpty();
}

boolean rectIntersectsRect(Rectangle2D r1, Rectangle2D r2) { 
  return r1.intersects(r2.getMinX(), r2.getMinY(), r2.getWidth(), r2.getHeight());
}

Point2D.Float addPoints(Point2D.Float p1, Point2D.Float p2) { 
  return new Point2D.Float(p1.x+p2.x, p1.y+p2.y);
}
Point2D.Float subPoints(Point2D.Float p1, Point2D.Float p2) { 
  return new Point2D.Float(p1.x-p2.x, p1.y-p2.y);
}
Point2D.Float scalePoint(Point2D.Float p, float scalar) { 
  return new Point2D.Float(p.x*scalar, p.y*scalar);
}

Point2D.Double addPoints(Point2D.Double p1, Point2D.Double p2) { 
  return new Point2D.Double(p1.x+p2.x, p1.y+p2.y);
}
Point2D.Double subPoints(Point2D.Double p1, Point2D.Double p2) { 
  return new Point2D.Double(p1.x-p2.x, p1.y-p2.y);
}
Point2D.Double scalePoint(Point2D.Double p, double scalar) { 
  return new Point2D.Double(p.x*scalar, p.y*scalar);
}

Point2D addPoints(Point2D p1, Point2D p2) { 
  return new Point2D.Float((float)(p1.getX()+p2.getX()), (float)(p1.getY()+p2.getY()));
}
Point2D subPoints(Point2D p1, Point2D p2) { 
  return new Point2D.Float((float)(p1.getX()-p2.getX()), (float)(p1.getY()-p2.getY()));
}
Point2D scalePoint(Point2D p, double scalar) { 
  return new Point2D.Float((float)(p.getX()*scalar), (float)(p.getY()*scalar));
}