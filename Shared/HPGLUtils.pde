import toxi.geom.*;
import java.util.List;

void fillContour(Shape2D shape, int penNum, boolean dryrun) { 
  //RG.setPolygonizer(RG.UNIFORMLENGTH);
  //RG.setPolygonizerLength(10);
  //shape = RG.polygonize(shape);
  ArrayList<Line> lines = new ArrayList<Line>(); 
  //stroke(255, 0, 255); 

  //RG.shape(shape);

  toxi.geom.Rect r = shape.getBounds();

  int i, j; 
  int boundspadding = 1; 

  // convert the first three points to PVectors and draw them
  Vec2D p1 = r.getTopLeft(); 
  Vec2D p2 = r.getTopRight(); 
  Vec2D p3 = r.getBottomRight(); 

  ellipse(p1.x, p1.y, 4, 4); 
  ellipse(p2.x, p2.y, 4, 4); 
  ellipse(p3.x, p3.y, 4, 4);

  // if second side is longer than first, switch them! 
  if (p1.distanceTo(p2)<p2.distanceTo(p3)) { 
    p3 = p1.copy(); 
    p1 = r.getBottomRight();
  }


  // get vectors for the long side of the rectangle...
  Vec2D v1 = p2.sub(p1); 

  // ... and the short side
  Vec2D v2 = p3.sub(p2); 

  // if the shape is super teeny, forget it
  // TODO draw a little line
  if ((v1.magSquared()<1) && (v2.magSquared()<=1)) return;

  float len = v1.magnitude(); 

  // now iterate along the long side
  for (float d = 0; d<len; d+=penThickness) { 
    Vec2D start = v1.scale(d/len); 
    start.addSelf(p1); 
    Vec2D end = start.add(v2); 


    // make a line that cuts through the shape 
    Line2D line2d = new Line2D(start, end); 


    // and get the intersection points
    List <Vec2D> ips = getIntersectionPoints(shape, line2d); 

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
        Vec2D ip1 = ips.get(i-1); 
        Vec2D ip2 = ips.get(i); 
        Vec2D mid = ip2.sub(ip1).scale(0.5).add(ip1);
        if (shape.containsPoint(mid)) {
          if ((newlines.size()>0) && (l.p2.equals(new PVector(ip1.x, ip1.y)))) {
            l.p2 = new PVector(ip2.x, ip2.y);
          } else {
            l = new Line(new PVector(ip1.x, ip1.y), new PVector(ip2.x, ip2.y), 1);
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

void outlineContour(Shape2D shape, int penNum, boolean dryrun) { 
  
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