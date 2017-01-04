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
import de.erichseifert.gral.util.GeometryUtils; 

List<Shape> shapes;

float xzoom = 0;
float yzoom =0;

void setup() { 
  size(1000, 800);

  shapes = new ArrayList<Shape>();
  for (int i=0; i<200; i++) { 
    Ellipse2D.Double e = new Ellipse2D.Double(random(width-80), random(height-80), 80, 80);  
    Ellipse2D.Double e2 = new Ellipse2D.Double(e.x+10, e.y+10, e.width-20, e.height-20); 
    if (random(1)<0.8) { 
      Area a = new Area(e); 
      a.subtract(new Area(e2)); 
      shapes.add(a);
    } else { 
      shapes.add(e2);
    }
  }
  long start = millis(); 
  removeOverlaps(shapes);

  println("ovelap removal too " + (millis()-start) + "ms"); 
  //noLoop(); 
}

void draw() { 
  
  float zoom =3; 
  scale(zoom);

  xzoom += (clamp(map(mouseX, width*0.1, width*0.9, 0, - width * (zoom-1)/zoom), -width * (zoom-1)/zoom, 0)-xzoom)*0.1; 
  yzoom += (clamp(map(mouseY, height*0.1, height*0.9, 0, - height * (zoom-1)/zoom), -height * (zoom-1)/zoom, 0)-yzoom)*0.1; 
  translate(xzoom, yzoom); 

  
  background(0);
  noFill(); 
  strokeWeight(2);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  blendMode(ADD); 
  stroke(255, 50, 50);
  for (Shape s : shapes) { 
    drawPath(s);
  }
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



void removeOverlaps(List<Shape> shapes) { 
  //shapes = new ArrayList<Shape>(shapes);
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
}

boolean shapeCollisionTest(Shape s1, Shape s2) { 

  Area a1; 
  Area a2; 
  a1 = new Area(s1);
  if (s2 instanceof Area) a2 = (Area)s2; 
  else a2 = new Area(s2);
  a1.intersect(a2); 

  return !a1.isEmpty();
}
//List<Polygon2D> polys = builder.computeShapes(); 

//if (polys.size()==0) {
//  shapes.remove(i); 
//  i--;
//} else if (polys.size()>0) { 
//  shapes.remove(i); 

//  shapes.add(i, polys.get(0));

//  for (int k=1; k<polys.size(); k++) {
//    Polygon2D p = polys.get(k); 
//    if(p.getEdges().size()>2) { 
//      shapes.add(i, polys.get(k));
//      i++;
//    }
//  }
//}
// }
//
// // for (int i = 0; i<shapes.size(); i++) { 

//Shape2D s1 = (Polygon2D)shapes.get(i); 

//BooleanShapeBuilder2 builder = new BooleanShapeBuilder2(); 
//builder.addShape(s1); 

//for (int j = i+1; j<shapes.size(); j++) {
//  Shape2D s2 = shapes.get(j); 

//  if(s1.containsPolygon(s2)) { 
//    CompoundPolygon cp;
//    if(s1 instanceof CompoundPolygon) {
//      cp = (CompoundPolygon)s1; 

//    } else {
//      // make new compound poly
//      cp  = new CompoundPolygon(s1);
//    }
//    // add child of s2
//    cp.addPoly(s2); 
//    // replace it in array
//    shapes.set(i, cp); 
//    // remove s2
//    shapes.remove(j); 
//    j--;
//  }

//}
//}//

//r//e//turn shapes;
//}