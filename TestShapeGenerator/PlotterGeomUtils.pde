import java.util.List;
import java.util.Comparator;
import java.awt.Shape;
//import java.awt.geom.Point2D;
//import java.awt.geom.Point2D.Float;
import java.awt.geom.Line2D; 
import java.awt.Rectangle;
import java.util.Collections;

import de.erichseifert.gral.util.GeometryUtils; 

void fillContour(Shape origshape, int penNum, float penThickness) { 
  //if(shape.isEmpty()) return; 
  ArrayList<Line> lines = new ArrayList<Line>(); 

  Shape shape = GeometryUtils.grow(origshape, -penThickness/2);

  Rectangle r = shape.getBounds();

  int i, j; 
  //int boundspadding = 1; 

  // convert the first three points to PVectors and draw them
  Point2D.Float p1 = new Point2D.Float(r.x, r.y); 
  Point2D.Float p2 = new Point2D.Float(r.x+r.width, r.y); 
  Point2D.Float p3 =  new Point2D.Float(r.x+r.width, r.y+r.height); 

  //ellipse(p1.x, p1.y, 4, 4); 
  //ellipse(p2.x, p2.y, 4, 4); 
  //ellipse(p3.x, p3.y, 4, 4);

  // if second side is longer than first, switch them! 
  if (p1.distance(p2)<p2.distance(p3)) { 
    p3 = (Point2D.Float)p1.clone(); 
    p1.setLocation(r.x+r.width, r.y+r.height);// = r.getBottomRight();
  }


  // get vectors for the long side of the rectangle...
  Point2D.Float v1 = subPoints(p2, p1); 

  // ... and the short side
  Point2D.Float v2 = subPoints(p3, p2); 

  // if the shape is super teeny, forget it
  // TODO draw a little line
  Point2D.Float zero = new Point2D.Float(); 
  if ((v1.distanceSq(zero)<1) && (v2.distanceSq(zero)<=1)) return;

  float len = (float)v1.distance(zero);

  int linenum = 0; 

  // now iterate along the long side
  for (float d = 0; d<len; d+=penThickness) { 
    Point2D.Float start = scalePoint(v1, d/len); 
    start = addPoints(start, p1); 
    Point2D.Float end = addPoints(start, v2); 

    // make a line that cuts through the shape 
    Line2D.Float line2d = new Line2D.Float(start, end); 

    // and get the intersection points
    List <Point2D> ips = GeometryUtils.intersection(shape, line2d); 
    Collections.sort(ips, new IntersectionComparator(start));

    if ((ips!=null) && (ips.size()>1)) { 

      ArrayList<PVector> ps = new ArrayList<PVector>(); 

      //iterate through points
      // p1 = p at index
      // p2 = p at index+1
      // get midpoint - if it's contained in the shape then make a line between 1 and 2
      // otherwise nothing
      // index++

      ArrayList<Line> newlines = new ArrayList<Line>(); 
      Line l = new Line();

      //for (i = 0; i<ips.size(); i++) {
      //  Point2D ip = ips.get(i); 
      //  ellipseMode(RADIUS);
      //  stroke(255, 50);
      //  ellipse((float)ip.getX(), (float)ip.getY(), 1, 1);
      //}

      // algorithm for making sure that line segments are inside 

      for ( i = 1; i<ips.size(); i++) {
        Point2D ip1 = ips.get(i-1); 
        Point2D ip2 = ips.get(i); 
        Point2D mid = subPoints(ip2, ip1);
        mid = scalePoint(mid, 0.5);
        mid = addPoints(mid, ip1);
        //ellipse((float)mid.getX(), (float)mid.getY(), 1, 1);
        if (shape.contains(mid)) {
          if ((newlines.size()>0) && (l.p2.equals(new PVector((float)ip1.getX(), (float)ip1.getY())))) {
            l.p2 = new PVector((float)ip2.getX(), (float)ip2.getY());
          } else {
            l = new Line(new PVector((float)ip1.getX(), (float)ip1.getY()), new PVector((float)ip2.getX(), (float)ip2.getY()), linenum);
            newlines.add(l);
          }
        }
      }

      lines.addAll(newlines);
    }
    linenum++;
  }

  if (lines.size()==0) return; 

  ArrayList<Line> sortedLines = new ArrayList<Line>(); 

  // shrink and reset all the lines
  Line l; 
  for ( i =0; i<lines.size(); i++ ) {
    l = lines.get(i); 

    // get the unit vector for the line
    PVector v = l.p2.copy().sub(l.p1); 
    float mag = v.mag();
    // if the length of the line is long enough, shrink it by
    // half the penwidth
    if (mag-(penThickness*2)>0) { 
      v.div(mag); 
      v.mult(penThickness);
      l.p1.add(v); 
      l.p2.sub(v); 

      // otherwise just draw a dot in the middle of the line
      // TODO maybe have to be non zero length?
    } else { 

      v.mult(0.5).add(l.p1); 
      l.p1.set(v); 
      l.p2.set(v);
    }
    l.tested = false;
    l.reversed = false;
  }
  plotter.selectPen(penNum); 
  // add lines for shape; 
  outlineContour(shape, penNum);   

  boolean reversed = false;
  int currentIndex = 0;

  float shortestDistance = java.lang.Float.MAX_VALUE;

  int nextDotIndex = -1;

  //println("---------------------");

  do {
    //println("currentIndex", currentIndex);
    Line line1 = lines.get(currentIndex);

    line1.tested = true;

    line1.reversed = reversed;
    sortedLines.add(line1);
    shortestDistance = java.lang.Float.MAX_VALUE;
    nextDotIndex = -1;


    for (j = 0; j<lines.size(); j++) {

      //println (currentIndex, j, reversed);  

      Line line2 = lines.get(j);
      if ((line2.tested) || (line1.equals(line2))) continue;

      line2.reversed = false;

      if (line1.getEnd().dist(line2.getStart()) < shortestDistance) {
        shortestDistance = line1.getEnd().dist(line2.getStart());
        nextDotIndex = j;
        reversed = false;
        //println ("\t",shortestDistance, currentIndex, j, reversed);
      }

      if ((line1.getEnd().dist(line2.getEnd()) < shortestDistance)) {
        shortestDistance = line1.getEnd().dist(line2.getEnd());
        nextDotIndex = j;
        reversed = true;
        //println ("\t",shortestDistance, currentIndex, j, reversed);
      }
    }

    currentIndex = nextDotIndex;
  } while (currentIndex>-1);

  // debug : highlight lines points dependent on mouse pos
  int highlightlineindex = (int)map(mouseX, 0, width, 0, 8); 

  //for (i  = 0; i<sortedLines.size(); i++) { 
  //  Line line = sortedLines.get(i); 

  //  //if (highlightlineindex == i) {
  //  //  strokeWeight(2); 
  //  //  stroke(255, 0, 0,128);
  //  //} else { 
  //  //strokeWeight(1);
  //  stroke(0, 255, 0, 255);
  //  // }
  //  line.draw();
  //}


  lines = sortedLines;
  boolean penUp = true; 
  PVector lastPos = new PVector(0, 0); 
  Line lastLine = null; 
  for (Line line : lines) { 
    //line.draw();
    PVector pv1 = line.p1.copy(); 
    PVector pv2 = line.p2.copy(); 

    if (line.reversed) { 
      pv2 = pv1; 
      pv1 = line.p2.copy();
    }

    if (!penUp) { 
      // if it is too far
      if (lastPos.dist(pv1)>penThickness*3) {
        // lift the pen
        penUp = true; 
        
        // although, if we are within 10 x penThickness
        if(lastPos.dist(pv1)<penThickness*10) { 
          
          // and we're doing consecutive lines
          if ( (lastLine!=null)  &&
            (abs(lastLine.posNumber-line.posNumber)==1) &&
            (lastLine.reversed!=line.reversed) ) {
            //  and we aren't crossing over the edget
            
            Point2D.Float start = new Point2D.Float(pv1.x, pv1.y); 
            Point2D.Float end = new Point2D.Float(lastPos.x, lastPos.y); 
            Line2D.Float line2d = new Line2D.Float(start, end); 
            // if we are going over the edge then lift the pen!
            if (GeometryUtils.intersection(origshape, line2d).size()==0) {
              
              // then let's not lift the pen
              penUp = false;
            }
          }

        }

        //// get line between lastpos and pv1
        //Point2D.Float start = new Point2D.Float(pv1.x, pv1.y); 
        //Point2D.Float end = new Point2D.Float(lastPos.x, lastPos.y); 
        //Line2D.Float line2d = new Line2D.Float(start, end); 

        //// unless it doesn't cross over the edge, in which case don't lift it
        //if (GeometryUtils.intersection(origshape, line2d).size()==0)
        //  penUp = false;
      }
    }
    if (penUp) { 
      plotter.moveTo(pv1);
    } else { 
      plotter.lineTo(pv1);
    }
    penUp = false; 
    plotter.lineTo(pv2); 
    lastPos.set(pv2);
    lastLine = line;
  }
  plotter.moveTo(lastPos); // lifts pen?
}

//List <Vec2D> getIntersectionPoints(Shape2D p, Line2D l) {
//  List <Vec2D> intersections = new ArrayList <Vec2D> ();
//  for (Line2D aL : p.getEdges()) {

//    Line2D.LineIntersection isec = aL.intersectLine(l);
//    if (isec.getType()==Line2D.LineIntersection.Type.INTERSECTING) {
//      intersections.add( isec.getPos() );
//    }
//  }

//  // sort the intersection points      
//  Collections.sort(intersections, new IntersectionComparator(l.a));

//  return intersections;
//}

void outlineContour(Shape shape, int penNum) { 


  //if(shape.isEmpty()) return; 
  plotter.selectPen(penNum); 
  //PathIterator pi = path.getPathIterator(null);
  PathIterator pi = new FlatteningPathIterator(shape.getPathIterator(null), 0.2);
  PVector lastMove = new PVector(); 

  boolean verbose = false; 

  while (pi.isDone() == false) {
    float[] coordinates = new float[6];
    int type = pi.currentSegment(coordinates);


    switch (type) {

    case PathIterator.SEG_MOVETO:

      if (verbose) println("move to " + coordinates[0] + ", " + coordinates[1]);

      plotter.moveTo(coordinates[0], coordinates[1]); 
      lastMove.set(coordinates[0], coordinates[1]); 

      break;
    case PathIterator.SEG_LINETO:
      if (verbose) println("line to " + coordinates[0] + ", " + coordinates[1]);
      plotter.lineTo(coordinates[0], coordinates[1]); 
      break;
      //case PathIterator.SEG_QUADTO:
      //  if (verbose) println("quadratic to " + coordinates[0] + ", " + coordinates[1] + ", "+ coordinates[2] + ", " + coordinates[3]);
      //  quadraticVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3]); 
      //  break;
      //case PathIterator.SEG_CUBICTO:
      //  if (verbose) println("cubic to " + coordinates[0] + ", " + coordinates[1] + ", "   + coordinates[2] + ", " + coordinates[3] + ", " + coordinates[4] + ", " + coordinates[5]);
      //  bezierVertex(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], coordinates[5]); 
      //  break;
    case PathIterator.SEG_CLOSE:
      if (verbose) println("close "+ coordinates[0] + ", " + coordinates[1]);
      plotter.lineTo(lastMove.x, lastMove.y); 
      break;
    default:
      break;
    }
    pi.next();
  }
}

//if (dryrun) return; 
//plotter.selectPen(penNum); 

//if (shape instanceof CompoundPolygon2D) { 
//  for (Polygon2D poly : ((CompoundPolygon2D)shape).polygons) { 
//    outlineContour(poly, penNum, dryrun);
//  }
//} else {
//  Polygon2D poly; 
//  if (!(shape instanceof Polygon2D)) { 
//    poly = shape.toPolygon2D();
//  } else {
//    poly = (Polygon2D)shape;
//  }

//  boolean move = true; 

//  for (int j = 0; j<=poly.getNumVertices(); j++) { 
//    Vec2D p = poly.get(j%poly.getNumVertices()); 
//    if (move) { 
//      plotter.moveTo(p.x, p.y); 
//      move = false;
//    } else { 
//      plotter.lineTo(p.x, p.y);
//    }
//  }
//}
//}


public class IntersectionComparator implements Comparator<Point2D> {

  public Point2D startpoint; 
  public IntersectionComparator(Point2D start) {
    startpoint = (Point2D)start.clone();
  }
  public int compare(Point2D c1, Point2D c2) {
    float dist1 = (float)startpoint.distanceSq(c1); 
    float dist2 = (float)startpoint.distanceSq(c2); 

    if (dist1==dist2) {
      return 0;
    } else if (dist1<dist2) {
      return -1;
    } else {
      return 1;
    }
  }
}

class Line { 

  public PVector p1; 
  public PVector p2;
  public int posNumber; 
  public boolean tested = false; 
  public boolean reversed = false; 

  public Line(PVector start, PVector end, int positionnum) { 
    p1 = start.copy(); 
    p2 = end.copy(); 
    posNumber = positionnum;
  }
  public Line() { 
    this(new PVector(), new PVector(), 0);
  }
  public void draw() { 
    line(p1.x, p1.y, p2.x, p2.y);
  }
  public PVector getStart() { 
    return reversed?p2:p1;
  }
  public PVector getEnd() { 
    return reversed?p1:p2;
  }

  public boolean equals(Line line) { 
    return (((line.p1 == p1) && (line.p2 == p2)) || ((line.p1 == p2) &&(line.p2 == p1)));
  }
}