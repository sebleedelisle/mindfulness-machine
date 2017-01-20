import java.awt.geom.Area;
import java.awt.Shape;
import java.awt.geom.Path2D;
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.Polygon;
import java.awt.geom.PathIterator;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.AffineTransform; 

import java.util.List;
import java.util.Collections;

public class PatternGenerator {
}

//float genseed = 5; 
int generationCount = 0; 
void makeShapes() {
  makeShapes(generationCount%2, generationCount, 0, 0);
  
  generationCount++; 
  //if(generationCount%2==1) 
  //genseed+=1;//r10000;
}



void makeShapes(int type, int seed, float stim, float happiness) {
  
  randomSeed(seed); 
  
  float rnd = random(1); 
  println(rnd);
  if (type ==0)
    shapes = getLandscapeShapes(width, height, stim, happiness);
  else if(type == 1)
    shapes = getSpiralShapes(width, height, stim, happiness);     
  else if(type ==2)   
    shapes = getTruchetShapes(width, height, stim, happiness);
  //shapes = getTestShapes(width, height);


  Rectangle2D r = new Rectangle2D.Float(0, 0, width, height); 
  Area boundingRect = new Area(r); 
  for (int i = 0; i<shapes.size(); i++) {
    Shape s = shapes.get(i); 
    Area a; 
    if (! (s instanceof Area)) { 
      a = new Area(s);
      shapes.set(i, a);
    } else { 
      a = (Area)s;
    }
    a.intersect(boundingRect);
  }
  removeOverlaps(shapes);

  Collections.reverse(shapes);

   hpglManager.clearBuffer();
  for (Shape s : shapes) {
    outlineContour(s, 0, false);
  }
}


List<Shape> getTestShapes(float width, float height, float stim, float happiness) {
  Path2D.Float s1 = new Path2D.Float();
  List<Shape> shapes = new ArrayList<Shape>(); 

  float x = 100;
  float y = 100; 
  float size = 100; 

  Point2D.Float p1 = new Point2D.Float(x, y); 
  Point2D.Float p2 = new Point2D.Float(x+size+0.1, y); 
  Point2D.Float p3 = new Point2D.Float(x, y+size+0.1); 
  Point2D.Float p4 = new Point2D.Float(x+size+0.1, y+size+0.1);

  s1.moveTo(p1.x, p1.y);
  s1.lineTo(p2.x, p2.y); 
  s1.lineTo(p4.x, p4.y); 
  s1.lineTo(p3.x, p3.y); 
  s1.closePath();
  
  Area a1 = new Area(s1); 
  shapes.add(a1); 
  
   x = 120;
   y = 120; 
   size =60; 

   p1 = new Point2D.Float(x, y); 
   p2 = new Point2D.Float(x+size+0.1, y); 
   p3 = new Point2D.Float(x, y+size+0.1); 
   p4 = new Point2D.Float(x+size+0.1, y+size+0.1);
  s1 = new Path2D.Float();
  s1.moveTo(p1.x, p1.y);
  s1.lineTo(p2.x, p2.y); 
  s1.lineTo(p4.x, p4.y); 
  s1.lineTo(p3.x, p3.y); 
  s1.closePath();

     a1 = new Area(s1); 
  shapes.add(a1); 
  
  
  
  return shapes;
}


List<Shape> getTruchetShapes(float width, float height, float stim, float happiness) {
  List<Area> shapes1 = new ArrayList<Area>(); 
  List<Area> shapes2 = new ArrayList<Area>(); 



  float size = 50;//random(20, 40);
  int colcount = floor(width/size);
  int rowcount = floor(height/size); 
  size = width/colcount; 

  int shapeType = floor(random(2)); 

  int numshapes = rowcount*colcount; 

  for (int i = 0; i<numshapes; i++) {
    float x = (i%colcount)*size; 
    float y = floor(i/colcount)*size; 
    Path2D.Float s1 = new Path2D.Float();
    Path2D.Float s2 = new Path2D.Float();

    if (shapeType ==0) { 

      Point2D.Float p1 = new Point2D.Float(x, y); 
      Point2D.Float p2 = new Point2D.Float(x+size+0.1, y); 
      Point2D.Float p3 = new Point2D.Float(x, y+size+0.1); 
      Point2D.Float p4 = new Point2D.Float(x+size+0.1, y+size+0.1); 

      if (random(1)<0.5) { 
        s1.moveTo(p1.x, p1.y);
        s1.lineTo(p2.x, p2.y); 
        s1.lineTo(p4.x, p4.y); 
        s1.closePath(); 
        s2.moveTo(p1.x, p1.y); 
        s2.lineTo(p4.x, p4.y); 
        s2.lineTo(p3.x, p3.y); 
        s2.closePath();
      } else { 
        s1.moveTo(p1.x, p1.y);
        s1.lineTo(p2.x, p2.y); 
        s1.lineTo(p3.x, p3.y); 
        s1.closePath(); 
        s2.moveTo(p2.x, p2.y); 
        s2.lineTo(p4.x, p4.y); 
        s2.lineTo(p3.x, p3.y); 
        s2.closePath();
      }
      Area a1 = new Area(s1); 
      Area a2 = new Area(s2); 



      if (random(1)<0.5) { 
        shapes1.add(a1);
        shapes2.add(a2);
      } else { 
        shapes1.add(a2);
        shapes2.add(a1);
      }
    } else if (shapeType ==1) { 
      float halfsize = size/2; 
      s1.moveTo(0, 0);
      s1.lineTo(halfsize, 0); 
      s1.lineTo(0, halfsize); 
      s1.closePath(); 

      s1.moveTo(size, size);
      s1.lineTo(halfsize, size); 
      s1.lineTo(size, halfsize); 
      s1.closePath(); 

      s2.moveTo(halfsize, 0); 
      s2.lineTo(size, 0); 
      s2.lineTo(size, halfsize); 
      s2.lineTo(halfsize, size); 
      s2.lineTo(0, size); 
      s2.lineTo(0, halfsize); 
      s2.closePath();

      //Area area = new Area(s); 
      AffineTransform at = new AffineTransform(); 

      at.translate(x, y);
      at.scale(1.0001, 1.0001);  
      if (random(1)<0.5) { 
        at.translate(size, 0);

        at.rotate(PI/2);
      }

      //at.scale(size+0.1/size, size+0.1/size);  


      Area a1 = new Area(s1); 
      Area a2 = new Area(s2); 
      a1.transform(at); 
      a2.transform(at); 


      if (random(1)<0.5) { 
        shapes1.add(a1);
        shapes2.add(a2);
      } else { 
        shapes1.add(a2);
        shapes2.add(a1);
      }
    }
  }

  int start = millis();   
  for (int i =1; i<shapes1.size(); i++) { 
    shapes1.get(0).add(shapes1.get(i)); 
    shapes2.get(0).add(shapes2.get(i));
  }
  println("combining shapes took : " + (millis()-start)); 

  ArrayList<Shape> shapes = new ArrayList<Shape>(); 

  //shapes.add(shapes1.get(0)); 
  //shapes.add(shapes2.get(0)); 
  shapes.addAll(breakArea(shapes1.get(0))); 
  //shapes.addAll(breakArea(shapes2.get(0))); 


  return shapes;
}








List<Shape> getSpiralShapes(float width, float height, float stim, float happiness) {
  List<Shape> shapes = new ArrayList<Shape>(); 


  // rotation spiral

  int shapeType = (int)random(4); //millis()%4;

  float c = 20;

  float maxsize = random(20, 120);
  float minsize = maxsize*random(0.2, 1);
  int numshapes = 1500; 
  float shaperotation = 0; 
  float rotation = radians(137.5); 

  float rnd = random(1); 

  // do shapes rotate around with the main rotation? 
  if (rnd<0.3) shaperotation = 0;
  else if (rnd<0.66) shaperotation = 1; 
  else shaperotation = random(0, 3); 

  //do we use standard Phillotaxis rotation ?  
  rnd = random(1); 
  if (rnd<0.7) rotation = radians(random(5, 180)); 
  if (random(1)<0.5) rotation*=-1; 

  for (int i = numshapes; i >=1; i--) {  

    float a = i * rotation;
    float r = c * sqrt(i);
    float x = r * cos(a) + (width/2);
    float y = r * sin(a) + (height/2);

    float size = constrain(map(i, 0, numshapes, maxsize, minsize), maxsize, minsize); 

    Shape s = new Rectangle2D.Double(); 

    switch(shapeType) { 
    case 0 : // Circle
      s = new Ellipse2D.Double(-size/2, -size/2, size, size);  
      break;

    case 1 : // square
      s = new Rectangle2D.Double(-size/2, -size/2, size, size);  
      break; 

    case 2 : // poly
      s = createPolygon(0, 0, floor(random(5, 10)), size);
      break ; 

    case 3 : 
      s = createStar(0, 0, floor(random(5, 10)), size, size*random(0.3, 0.9)); 
      break;
    } 

    Area area = new Area(s); 
    AffineTransform at = new AffineTransform(); 
    at.translate(x, y);
    at.rotate(a*shaperotation); 

    area.transform(at);
    shapes.add(area);
  }

  //removeOverlaps(shapes);
  return shapes;
}


List<Shape> getLandscapeShapes(float width, float height, float stim, float happiness) {
  List<Shape> shapes = new ArrayList<Shape>(); 

  float spacing = 10;//random(10, 20); 
  float wavescale = random(5, 50); 
  float wavelength = random(0.1, 5); 
  float shift = random(-5, 5); 
  float noisedetail = random(1);
  noisedetail*=noisedetail*noisedetail; 
  float noisescale = constrain(random(-50, 50), 0, 50);

  float resolution = 10;//random(10, 40); 

  boolean linear = random(1)<0.5; 

  if (linear) { 
    // linear
    for (float y = -wavescale-noisescale; y<height+wavescale+noisescale; y+=spacing) { 
      Path2D s = new Path2D.Float();
      s.moveTo(0, height); 
      for (float x = 0; x<=width+resolution; x+=resolution) { 
        float offsetx = 0;//sin(radians(x))*5; 
        float offsety = sin(radians(x+(y*shift))*wavelength)*wavescale; 
        offsety += noise(x*noisedetail, y*noisedetail)*noisescale;
        s.lineTo(x+offsetx, y+offsety);
      }
      s.lineTo(width, height); 
      shapes.add(s);
    }
  } else {
    // circular
    wavelength = ceil(wavelength);
    //spacing*=0.7; 
    wavescale*=0.3; 
    resolution = 2; 
    noisescale*=3;
    float changerate = random(0.001, 0.1); // amount of change of noise between layers 

    float extent = dist(0, 0, width/2, height/2)+wavescale+noisescale; 
    for (float r = extent; r>=0; r-=spacing) { 
      resolution = map(r, 0, extent, 5, 1); 
      int iterations = floor(360/resolution); 
      resolution = 360/iterations; 

      Path2D s = new Path2D.Float();
      for (float a = 0; a<360; a+=resolution) { 

        float offsetr = sin(radians(a+(r*shift))*wavelength)*wavescale; 
        offsetr += noise(sin(a)*noisedetail*100, r*changerate)*noisescale;
        float x = width/2 + cos(radians(a))*(r+offsetr); 
        float y = height/2 + sin(radians(a))*(r+offsetr);
        if (a==0) { 
          s.moveTo(x, y);
        } else { 
          s.lineTo(x, y);
        }
      }
      s.closePath();
      shapes.add(s);
    }
  }

  //removeOverlaps(shapes);

  return shapes;
}