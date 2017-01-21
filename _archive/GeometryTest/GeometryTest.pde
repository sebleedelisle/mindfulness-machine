import gab.opencv.*;
import org.opencv.core.Mat; 
import geomerative.*;
import java.util.Collections;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
MatOfInt4 hierarchy;

ArrayList<RShape> shapes; 
ArrayList<RotatedRect> rects; 


void setup() {
  RG.init(this); 

  shapes = new ArrayList<RShape>();
  rects = new ArrayList<RotatedRect>(); 

  src = loadImage("test-flowers.png"); 
  surface.setSize(src.width*2, src.height);
  opencv = new OpenCV(this, src);

  opencv.gray();
  opencv.blur(3);
  opencv.threshold(50);
  dst = opencv.getOutput();

  contours = findContours(true);

  int index = 0; 
  int level = 0; 

  do { 

    Contour contour = contours.get(index); 
    contour.setPolygonApproximationFactor(1);
    double[] h  = hierarchy.get(0, index);
    RShape s = new RShape();
    boolean move = true; 
    for (PVector point : contour.getPolygonApproximation().getPoints()) {

      if (move) {
        move = false; 
        s.addMoveTo(point.x, point.y);
      } else { 
        s.addLineTo(point.x, point.y);
      }
    }
    s.addClose();
    if (level == 0 ) { 
      
      shapes.add(s);
      rects.add(getMinAreaRect(contour));
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
  //noLoop();
}


void draw() { 

  background(50); 
  //image(src, 0, 0);
  image(dst, src.width, 0);

  for (int i = 0; i<shapes.size(); i++) {

    RShape s = shapes.get(i);

    colorMode(HSB, 255); 
    noStroke();
    fill( (i*5)%255, 255, 50, 128 );
    RG.shape(s);

    if (s.contains(mouseX, mouseY)) {
      noFill(); 
      stroke(255); 

      RG.shape(s);

      RotatedRect r = rects.get(i).clone(); 
      //drawRotatedRect(r);
      r.size.width+=10; 
      r.size.height+=10; 
      drawRotatedRect(r);

      Point[] points = new Point[4]; 
      // get points out of rotated rectangle
      r.points(points); 
      // take out the first three points and draw them
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


      float penthickness = 5; 
      float len = v1.mag(); 

      // now iterate along the long side
      for (float d = 0; d<len; d+=penthickness) { 
        PVector start = v1.copy(); 
        start.mult(d/len); 
        start.add(p1); 
        PVector end = start.copy(); 
        end.add(v2); 


        RShape cuttingLine = RG.getLine(start.x, start.y, end.x, end.y); 
        RPoint[] tps = s.getIntersections(cuttingLine);
        if ((tps!=null) && (tps.length>1)) { 
          ArrayList<PVector> ps = new ArrayList<PVector>(); 

          for (int j = 0; j<tps.length; j++) { 
            PVector newp = new PVector(tps[j].x, tps[j].y); 
            if((ps.size()<1)  || (newp.dist(ps.get(ps.size()-1))>0.1)) ps.add(newp);
          }
          
          if(ps.size()<=1) continue;
          
          Collections.sort(ps, new IntersectionComparator(start));
          stroke(255);
          ellipse(start.x, start.y, 5, 5);
          
          if(ps.size()%2==1) {
            stroke(255,120);
            strokeWeight(3); 
            println(d, "odd number of intersections! THIS SHOULDN'T HAPPEN!");
            line(start.x, start.y, end.x, end.y);
            strokeWeight(1);
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
            line(pt1.x, pt1.y, pt2.x, pt2.y); 
            //ellipse(ps[j].x, ps[j].y, 2, 2);
          }

          for (int j=0; j<ps.size(); j++) {
            stroke(j*60%255, 255, 255); 
            ellipse(ps.get(j).x, ps.get(j).y, 2, 2);
          }
        }
      }
    }
  }
}