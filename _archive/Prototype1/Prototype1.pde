import gab.opencv.*; //<>//
import org.opencv.core.Mat; 
import geomerative.*;
import java.util.Collections;
////////// HELLO
PImage src, dst;
OpenCV opencv;

HPGLManager hpglManager; 

ArrayList<Contour> contours;
MatOfInt4 hierarchy;

ArrayList<RShape> shapes; 
ArrayList<RotatedRect> rects; 

float imageScale = 0.7; 

float penThickness = 2.0; 

void setup() {

  hpglManager = new HPGLManager(this); 

  size(1170, 800);

  surface.setResizable(true);

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);

  hpglManager.updatePlotterScale();

  //hpglManager.setVelocity(2); 

  RG.init(this); 
  
  RShape s = RShape.createRing(100,100,300,200); 
  fillContour(s);
  shapes.add(s);

//  getShapesForImage("test3.jpg", imageScale); 

//  for (int pen = 0; pen<8; pen++) { 

//    hpglManager.addPenCommand(pen+1); 

//    for (int i = 0; i<shapes.size(); i++) {

//      if ((i%8)!=pen) continue; 

//      RShape s = shapes.get(i);

//      RG.shape(s);

//      ArrayList<Line> lines = getLinesForShape(s, rects.get(i), i%8); 

//      boolean penUp = true; 
//      PVector lastPos = new PVector(0, 0); 
//      for (Line line : lines) { 
//        //line.draw();
//        PVector p1 = line.p1.copy(); 
//        PVector p2 = line.p2.copy(); 

//        if (line.reversed) { 
//          p2 = p1; 
//          p1 = line.p2.copy();
//        }

//        //PVector offset = new PVector(0, 0); 
//        //float scale = 1; 
//        //p1.add(offset); 
//        //p2.add(offset); 
//        // p1.mult(scale); 
//        // p2.mult(scale); 

//        //hpglManager.plotLine(p1, p2);

//        if ((!penUp) && (lastPos.dist(p1)>penThickness*4)) { 
//          penUp = true;
//        }
//        if (penUp) { 
//          hpglManager.moveTo(p1);
//        } else { 
//          hpglManager.lineTo(p1);
//        }
//        penUp = false; 
//        hpglManager.lineTo(p2); 
//        lastPos.set(p2);
//      }
//    }
//  }

}


void draw() {
  
  background(0); 
  pushMatrix(); 
  scale(imageScale, imageScale); 
  image(dst, src.width, 0);
  //background(50); 
  image(src, 0, 0);
  //if (hpglManager.printing) { 
  popMatrix(); 


  hpglManager.update();

  for (RShape shape : shapes) {
    stroke(0, 255, 0); 
    if (shape.contains(mouseX, mouseY)) {
      stroke(255, 0, 0);
    }
    RG.shape(shape);
  }

  // }
}

void getShapesForImage(String filename, float scale) { 

  shapes = new ArrayList<RShape>();
  rects = new ArrayList<RotatedRect>(); 

  src = loadImage(filename); 

  opencv = new OpenCV(this, src);

  opencv.gray();
  //opencv.blur(3);
  opencv.invert();
  opencv.threshold(10);
  //opencv.erode();
  dst = opencv.getOutput();

  contours = findContours(true);

  int index = 0; 
  int level = 0; 

  do { 

    Contour contour = contours.get(index); 
    //contour.setPolygonApproximationFactor(1);
    double[] h  = hierarchy.get(0, index);
    RShape s = new RShape();
    boolean move = true; 
    for (PVector point : contour.getPoints()) {
      if (move) {
        move = false; 
        s.addMoveTo(point.x*scale, point.y*scale);
      } else { 
        s.addLineTo(point.x*scale, point.y*scale);
      }
    }
    s.addClose();
    if (level == 0 ) { 

      shapes.add(s);
      RotatedRect r = getMinAreaRect(contour); 
      r.size.width*=scale; 
      r.size.height*=scale; 
      r.center.x*=scale; 
      r.center.y*=scale; 
      rects.add(r);
    } else { 
      RShape last = shapes.get(shapes.size()-1); 
      shapes.remove(shapes.size() - 1);
      last = RG.diff(last, s); 
      shapes.add(last);
    }


    if (h[2]>=0) { 
      // if we have a child, use that next
      index = (int)h[2];
      level++;
    } else if (h[0]>=0) { 
      // otherwise use the next in line
      index = (int)h[0];
    } else if (h[3]>=0) { 
      // otherwise if we have a parent, then go up a level, and 
      // use the parent's next sibling
      index = (int)h[3]; 
      h = hierarchy.get(0, index); 
      index = (int)h[0];
      level--;
    } else { 
      index = -1;
    }
  } while ((index>=0) && (index<contours.size()));
}

ArrayList<Line> getLinesForShape(RShape s, RotatedRect boundingRect, int pen) { 

  // should prob be a param


  ArrayList<Line> lines = new ArrayList<Line>(); 

  noFill(); 
  //stroke(255); 

  // draw the shape
  RG.shape(s);

  RotatedRect rect = boundingRect.clone(); 

  // expand the bounding rectangle - not sure this is necessary
  rect.size.width+=1; 
  rect.size.height+=1; 
  drawRotatedRect(rect);

  // get points out of rotated rectangle
  Point[] points = new Point[4]; 
  // this rather obscurely named function puts the points from the rectangle
  // into the provided array. 
  rect.points(points); 

  // convert the first three points to PVectors and draw them
  PVector p1 = new PVector((float)points[0].x, (float)points[0].y);
  PVector p2 = new PVector((float)points[1].x, (float)points[1].y);
  PVector p3 = new PVector((float)points[2].x, (float)points[2].y);
  ellipse(p1.x, p1.y, 10, 10); 
  ellipse(p2.x, p2.y, 10, 10); 
  ellipse(p3.x, p3.y, 10, 10);

  // if second side is longer than first, switch them! 
  if (p1.dist(p2)<p2.dist(p3)) { 
    p3 = p1.copy(); 
    p1 = new PVector((float)points[2].x, (float)points[2].y);
  }


  // get vectors for the long side of the rectangle...
  PVector v1 = p2.copy(); 
  v1.sub(p1); 
  // ... and the short side
  PVector v2 = p3.copy(); 
  v2.sub(p2); 

  float len = v1.mag(); 

  // now iterate along the long side
  for (float d = 0; d<len; d+=penThickness) { 
    PVector start = v1.copy(); 
    start.mult(d/len); 
    start.add(p1); 
    PVector end = start.copy(); 
    end.add(v2); 
    
    // make a line that cuts through the shape 
    RShape cuttingLine = RG.getLine(start.x, start.y, end.x, end.y); 
    // and get the intersection points
    RPoint[] tps = s.getIntersections(cuttingLine);
    
    if ((tps!=null) && (tps.length>1)) { 
      ArrayList<PVector> ps = new ArrayList<PVector>(); 

      for (int j = 0; j<tps.length; j++) { 
        PVector newp = new PVector(tps[j].x, tps[j].y); 
        //if ((ps.size()<1)  || (newp.dist(ps.get(ps.size()-1))>0.01)) 
        ps.add(newp);
      }

      if (ps.size()<=1) continue;

      Collections.sort(ps, new IntersectionComparator(start));

      if (ps.size()%2==1) {

        println(d, "odd number of intersections! THIS SHOULDN'T HAPPEN!");

        for (int j=0; j<ps.size(); j++) {
          println("\t"+j+" " +ps.get(j));
        }
      }

      for (int j=0; j<ps.size(); j+=2) {
        if (j+1>=ps.size()) { 
          break; //too many points for some reason
        } 
        stroke(255);
        PVector pt1 = ps.get(j); 
        PVector pt2 = ps.get(j+1); 
        //line(pt1.x, pt1.y, pt2.x, pt2.y); 
        lines.add(new Line(pt1, pt2, pen));
      }
    }
  }

  if (lines.size()==0) return lines; 

  ArrayList<Line> sortedLines = new ArrayList<Line>(); 

  for (int i =0; i<lines.size(); i++ ) {
    lines.get(i).tested = false;
    lines.get(i).reversed = false;
  }

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


    for (int j = 0; j<lines.size(); j++) {

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

  return sortedLines;
}