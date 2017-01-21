import gab.opencv.*;
import org.opencv.core.Mat; 
PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;
color[] colours = new color[100]; 
  MatOfInt4 hierarchy;
  
ArrayList<PShape> shapes; 
  
void setup() {
  // 
  shapes = new ArrayList<PShape>();
  
  
  src = loadImage("test-flowers.png"); 
  surface.setSize(src.width*2, src.height);
  opencv = new OpenCV(this, src);

 
  opencv.gray();
  opencv.blur(3);
  opencv.invert();
  opencv.threshold(50);
  dst = opencv.getOutput();

  contours = findContours(true);
  println("found " + contours.size() + " contours");
  //noLoop();

  colorMode(HSB, 255);

  
  int index = 0; 
  int counter =0 ; 
  int level = 0; 
  
  PShape s = createShape(); 
  s.beginShape(); 
  do { 
    
    for(int i =0; i< level; i++) { 
      print('\t');
    }
    print(index+" - ");
    //println("hierarchy size", hierarchy.size()); 
    
    Contour contour = contours.get(index); 
    contour.setPolygonApproximationFactor(0.3);
    double[] h  = hierarchy.get(0, index);
    
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      s.vertex(point.x, point.y);
    }
 
 //   for(int i = 0; i<h.length; i++) { 
 //     print( h[i] +",");  
 //   }  
 //   println(""); 
    
    if(h[2]>=0) { 
      // if we have a child, use that
      index = (int)h[2];
      level++;   
      
      println("beginContour"); 
      s.beginContour();
      
    } else if(h[0]>=0) { 
      // otherwise use the next in line
      index = (int)h[0];
      if(level==0) s = startNewShape(s); 
      else { 
        s.endContour(); 
        s.beginContour();
      }
      
    } else if(h[3]>=0) { 
      // otherwise if we have a parent, then go up a level, and 
      // use the parent's next sibling
      index = (int)h[3]; 
      h = hierarchy.get(0, index); 
      index = (int)h[0];
      level--; 
      println("endContour"); 
      s.endContour(); 
      s = startNewShape(s); 
    
  } else { 
      index = -1; 
      s = startNewShape(s); 
    }

    counter++; 

  } while((index>=0) && (index<contours.size())); 
  
  println(counter, contours.size()); 

}

PShape startNewShape(PShape s) { 
  println("endShape"); 
  s.endShape(); 
  shapes.add(s); 
  println("createShape"); 
  s = createShape(); 
  println("beginShape"); 
  s.beginShape(); 
  s.noStroke();
  s.fill(color(random(0, 255), 255, 255, 128)); 
  return s; 
  
}

void draw() {
  scale(0.5);
  image(src, 0, 0);
  image(dst, src.width, 0);
  
  noStroke();
  for (int i = 0; i<shapes.size(); i++) {
    
  
    PShape s = shapes.get(i);
    //rprintln(s.getVertexCount());
    shape(s,0,0);
  }
  /*noFill();
  strokeWeight(3);

  for (int i = 0; i<contours.size(); i++) {
    Contour contour = contours.get(i); 
    //stroke(0, 255, 0);
    //contour.draw();
    contour.setPolygonApproximationFactor(0.3);
    //strokeWeight(0.5); 
    //stroke(255, 0, 0);
    noStroke(); 
    //color c = color(random(0,255),255,255, 128); 


    fill(colours[i%colours.length]);
    //beginShape();

    contour.getPolygonApproximation().draw(); 
    stroke(colours[i%colours.length]);
    noFill();
    drawRotatedRect(getMinAreaRect(contour));

    if (contour.containsPoint(mouseX, mouseY)) { 
      noFill(); 
      pushMatrix(); 
      translate(src.width, 0); 
      colorMode(RGB, 255);

      stroke(0, 255, 0);
      contour.getPolygonApproximation().draw(); 
      double childIndex = hierarchy.get(0,i)[2]; 
      println(i,hierarchy.get(0,i));
      popMatrix();
    }
  }*/
}