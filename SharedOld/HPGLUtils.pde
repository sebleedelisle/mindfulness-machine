import java.util.List;
import java.util.Comparator;
import java.awt.Shape;
//import java.awt.geom.Point2D;
//import java.awt.geom.Point2D.Float;
import java.awt.geom.Line2D; 
import java.awt.Rectangle;


import de.erichseifert.gral.util.GeometryUtils; 

void fillContour(Shape shape, int penNum, float penThickness, boolean dryrun) { 

  ArrayList<Line> lines = new ArrayList<Line>(); 
  //stroke(255, 0, 255); 

  //RG.shape(shape);

  Rectangle r = shape.getBounds();

  int i, j; 
  int boundspadding = 1; 

  // convert the first three points to PVectors and draw them
  Point2D.Float p1 = new Point2D.Float(r.x, r.y); 
  Point2D.Float p2 = new Point2D.Float(r.x+r.width, r.y); 
  Point2D.Float p3 =  new Point2D.Float(r.x+r.width, r.y+r.height); 

  ellipse(p1.x, p1.y, 4, 4); 
  ellipse(p2.x, p2.y, 4, 4); 
  ellipse(p3.x, p3.y, 4, 4);

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

  // now iterate along the long side
  for (float d = 0; d<len; d+=penThickness) { 
    Point2D.Float start = scalePoint(v1, d/len); 
    start = addPoints(start, p1); 
    Point2D.Float end = addPoints(start, v2); 

    // make a line that cuts through the shape 
    Line2D.Float line2d = new Line2D.Float(start, end); 

    // and get the intersection points
    List <Point2D> ips = GeometryUtils.intersection(shape, line2d); 

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
      //  Vec2D ip = ips.get(i); 
      //  ellipseMode(RADIUS);
      //  stroke(0, 50);
      //  gfx.circle(ip, 1);   
      //}

      // algorithm for making sure that line segments are inside 

      for ( i = 1; i<ips.size(); i++) {
        Point2D ip1 = ips.get(i-1); 
        Point2D ip2 = ips.get(i); 
        Point2D mid = subPoints((Point2D.Float)ip2,(Point2D.Float)ip1);
        mid = scalePoint((Point2D.Float)mid,0.5);
        mid = addPoints((Point2D.Float)mid, (Point2D.Float)ip1);
        if (shape.contains(mid)) {
          if ((newlines.size()>0) && (l.p2.equals(new PVector((float)ip1.getX(), (float)ip1.getY())))) {
            l.p2 = new PVector((float)ip2.getX(), (float)ip2.getY());
          } else {
            l = new Line(new PVector((float)ip1.getX(), (float)ip1.getY()), new PVector((float)ip2.getX(), (float)ip2.getY()), 1);
            newlines.add(l);
          }
        }
      }

      lines.addAll(newlines);
    }
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
  hpglManager.addPenCommand(penNum); 
  // add lines for shape; 
  outlineContour(shape, penNum, dryrun);   

  boolean reversed = false;
  int currentIndex = 0;

  float shortestDistance = Float.MAX_VALUE;

  int nextDotIndex = -1;

  //println("---------------------");

  do {
    //println("currentIndex", currentIndex);
    Line line1 = lines.get(currentIndex);

    line1.tested = true;

    line1.reversed = reversed;
    sortedLines.add(line1);
    shortestDistance = Float.MAX_VALUE;
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

  for (i  = 0; i<sortedLines.size(); i++) { 
    Line line = sortedLines.get(i); 

    //if (highlightlineindex == i) {
    //  strokeWeight(2); 
    //  stroke(255, 0, 0,128);
    //} else { 
    //strokeWeight(1);
    stroke(0, 255, 0, 255);
    // }
    line.draw();
  }

  if (!dryrun) { 
    lines = sortedLines;
    boolean penUp = true; 
    PVector lastPos = new PVector(0, 0); 
    for (Line line : lines) { 
      //line.draw();
      PVector pv1 = line.p1.copy(); 
      PVector pv2 = line.p2.copy(); 

      if (line.reversed) { 
        pv2 = pv1; 
        pv1 = line.p2.copy();
      }

      if ((!penUp) && (lastPos.dist(pv1)>penThickness*2)) { 
        penUp = true;
      }
      if (penUp) { 
        hpglManager.moveTo(pv1);
      } else { 
        hpglManager.lineTo(pv1);
      }
      penUp = false; 
      hpglManager.lineTo(pv2); 
      lastPos.set(pv2);
    }
    hpglManager.moveTo(lastPos);
  }
}

List <Vec2D> getIntersectionPoints(Shape2D p, Line2D l) {
  List <Vec2D> intersections = new ArrayList <Vec2D> ();
  for (Line2D aL : p.getEdges()) {

    Line2D.LineIntersection isec = aL.intersectLine(l);
    if (isec.getType()==Line2D.LineIntersection.Type.INTERSECTING) {
      intersections.add( isec.getPos() );
    }
  }

  // sort the intersection points      
  Collections.sort(intersections, new IntersectionComparator(l.a));

  return intersections;
}

void outlineContour(Shape shape, int penNum, boolean dryrun) { 

  if (dryrun) return; 
  hpglManager.addPenCommand(penNum); 

  if (shape instanceof CompoundPolygon2D) { 
    for (Polygon2D poly : ((CompoundPolygon2D)shape).polygons) { 
      outlineContour(poly, penNum, dryrun);
    }
  } else {
    Polygon2D poly; 
    if (!(shape instanceof Polygon2D)) { 
      poly = shape.toPolygon2D();
    } else {
      poly = (Polygon2D)shape;
    }

    boolean move = true; 

    for (int j = 0; j<=poly.getNumVertices(); j++) { 
      Vec2D p = poly.get(j%poly.getNumVertices()); 
      if (move) { 
        hpglManager.moveTo(p.x, p.y); 
        move = false;
      } else { 
        hpglManager.lineTo(p.x, p.y);
      }
    }
  }
}


public class IntersectionComparator implements Comparator<Vec2D> {

  public Vec2D startpoint; 
  public IntersectionComparator(Vec2D start) {
    startpoint = start.copy();
  }
  public int compare(Vec2D c1, Vec2D c2) {
    float dist1 = startpoint.distanceTo(c1); 
    float dist2 = startpoint.distanceTo(c2); 

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
  public int penNumber; 
  public boolean tested = false; 
  public boolean reversed = false; 

  public Line(PVector start, PVector end, int pen) { 
    p1 = start.copy(); 
    p2 = end.copy(); 
    penNumber = pen;
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