import geomerative.RRectangle; 


// to fill a shape 
// send an RShape object from Geomerative
// convert top level shape to openCV contour
// get minAreaRect rotated rectangle 
// create lines for RShape by intersection lines
// sort the lines
// send to plotter


//void fillContour(RShape shape) { 
//  fillContour(shape, false);
//}

void fillContour(RShape shape, int penNum, boolean dryrun) { 
  //RG.setPolygonizer(RG.UNIFORMLENGTH);
  //RG.setPolygonizerLength(10);
  //shape = RG.polygonize(shape);
  ArrayList<Line> lines = new ArrayList<Line>(); 
  //stroke(255, 0, 255); 

  //RG.shape(shape);

  RRectangle r = shape.getBounds();

  RPoint[] rps = r.getPoints();
  int i, j; 
  int boundspadding = 1; 

  // convert the first three points to PVectors and draw them
  PVector p1 = new PVector(rps[0].x-boundspadding, rps[0].y-boundspadding);
  PVector p2 = new PVector(rps[1].x+boundspadding, rps[1].y-boundspadding);
  PVector p3 = new PVector(rps[2].x+boundspadding, rps[2].y+boundspadding);
  //ellipse(p1.x, p1.y, 4, 4); 
  //ellipse(p2.x, p2.y, 4, 4); 
  //ellipse(p3.x, p3.y, 4, 4);

  // if second side is longer than first, switch them! 
  if (p1.dist(p2)<p2.dist(p3)) { 
    p3 = p1.copy(); 
    p1 = new PVector(rps[2].x+boundspadding, rps[2].y+boundspadding);
  }


  // get vectors for the long side of the rectangle...
  PVector v1 = p2.copy(); 
  v1.sub(p1); 
  // ... and the short side
  PVector v2 = p3.copy(); 
  v2.sub(p2); 

  // if the shape is super teeny, forget it
  // TODO draw a little line
  if ((v1.magSq()<1) && (v2.magSq()<=1)) return;

  float len = v1.mag(); 

  // now iterate along the long side
  for (float d = 0; d<len; d+=penThickness) { 
    PVector start = v1.copy(); 
    start.mult(d/len); 
    start.add(p1); 
    PVector end = start.copy(); 
    end.add(v2); 

    //println(d, start.y);
    // make a line that cuts through the shape 
    RShape cuttingLine = RG.getLine(start.x, start.y, end.x, end.y); 
    //stroke(200);
    //line(start.x, start.y, end.x, end.y);

    // and get the intersection points
    RPoint[] tps = shape.getIntersections(cuttingLine);

    if ((tps!=null) && (tps.length>1)) { 

      ArrayList<PVector> ps = new ArrayList<PVector>(); 

      for ( j = 0; j<tps.length; j++) { 
        PVector newp = new PVector(tps[j].x, tps[j].y); 
        ps.add(newp);
        //stroke(0,255,255);
        //ellipse(newp.x, newp.y, 3, 3);
      }


      // sort the intersection points      
      Collections.sort(ps, new IntersectionComparator(start));

      //iterate through points
      // p1 = p at index
      // p2 = p at index+1
      // get midpoint - if it's contained in the shape then make a line between 1 and 2
      // otherwise nothing
      // index++

      ArrayList<Line> newlines = new ArrayList<Line>(); 
      Line l = new Line();

      for ( i = 1; i<ps.size(); i++) {
        PVector ip1 = ps.get(i-1); 
        PVector ip2 = ps.get(i); 
        PVector mid = ip2.copy(); 
        mid.sub(ip1).mult(0.5).add(ip1);
        if (shape.contains(new RPoint(mid.x, mid.y))) {
          if ((newlines.size()>0) && (l.p2.equals(ip1))) {
            l.p2 = ip2.copy();
          } else {
            l = new Line(ip1, ip2, 1);
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
    if(mag-penThickness>0) { 
      v.div(mag); 
      v.mult(penThickness/2);
      l.p1.add(v); 
      l.p2.sub(v); 
      
    // otherwise just draw a dot in the middle of the line
    // TODO maybe have to be non zero length? 
    } else { 
      
      v.mult(0.5).add(p1); 
      l.p1.set(v); 
      l.p2.set(v); 
    }
    l.tested = false;
    l.reversed = false;
  }

  // add lines for shape; 
  outlineContour(shape, penNum);   



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

  //for (i  = 0; i<sortedLines.size(); i++) { 
  //  Line l = sortedLines.get(i); 

  //  //if (highlightlineindex == i) {
  //  //  strokeWeight(2); 
  //  //  stroke(255, 0, 0,128);
  //  //} else { 
  //  //strokeWeight(1);
  //  stroke(0, 255, 0, 255);
  //  // }
  //  l.draw();
  //}

  lines = sortedLines;
  boolean penUp = true; 
  PVector lastPos = new PVector(0, 0); 
  for (Line line : lines) { 
    //line.draw();
    p1 = line.p1.copy(); 
    p2 = line.p2.copy(); 

    if (line.reversed) { 
      p2 = p1; 
      p1 = line.p2.copy();
    }

    if ((!penUp) && (lastPos.dist(p1)>penThickness*4)) { 
      penUp = true;
    }
    if (penUp) { 
      hpglManager.moveTo(p1);
    } else { 
      hpglManager.lineTo(p1);
    }
    penUp = false; 
    hpglManager.lineTo(p2); 
    lastPos.set(p2);
  }
  hpglManager.moveTo(lastPos);
}

void outlineContour(RShape shape, int penNum) { 

  hpglManager.addPenCommand(penNum); 


  int numPaths = shape.countPaths();
  if (numPaths!=0) {

    boolean closed = false;
    boolean move = true;    


    for (int i=0; i<numPaths; i++) {

      RPath path = shape.paths[i];
      RPoint[] points = path.getPoints(); 

      for (int j = 0; j<points.length; j++) { 
        if (move) { 
          hpglManager.moveTo(points[j].x, points[j].y); 
          move = false;
        } else { 
          hpglManager.lineTo(points[j].x, points[j].y);
        }
      }
      //    for (int j = 0; j < path.countCommands(); j++ ) {
      //      RPoint[] pnts = path.commands[j].getHandles();
      //      if (j==0) {
      //        g.vertex(pnts[0].x, pnts[0].y);
      //      }
      //      switch( path.commands[j].getCommandType() )
      //      {
      //      case RCommand.LINETO:
      //        g.vertex( pnts[1].x, pnts[1].y );
      //        break;
      //      case RCommand.QUADBEZIERTO:
      //        g.bezierVertex( pnts[1].x, pnts[1].y, pnts[2].x, pnts[2].y, pnts[2].x, pnts[2].y );
      //        break;
      //      case RCommand.CUBICBEZIERTO:
      //        g.bezierVertex( pnts[1].x, pnts[1].y, pnts[2].x, pnts[2].y, pnts[3].x, pnts[3].y );
      //        break;
      //      }
      //    }
    }
    //g.endShape(closed ? PConstants.CLOSE : PConstants.OPEN);
  }
}