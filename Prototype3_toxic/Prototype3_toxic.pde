//import gab.opencv.*; //<>//
import gab.opencv.OpenCV; 
import org.opencv.core.Mat; 
import org.opencv.core.MatOfInt4; 
import toxi.color.*;
import toxi.geom.*;
import toxi.processing.*;
import java.util.Collections;

PImage src, dst;
OpenCV opencv;

HPGLManager hpglManager; 

ArrayList<Contour> contours;
MatOfInt4 hierarchy;

ArrayList<Shape2D> shapes; 
//ArrayList<RotatedRect> rects; 

float imageScale = 0.3; 

float penThickness = 1; 

int shapenum = 0; 

float xzoom = 0;
float yzoom =0;

ToxiclibsSupport gfx;

boolean dirty = true; 

void setup() {

  hpglManager = new HPGLManager(this); 
  gfx=new ToxiclibsSupport(this);
  size(1170, 800, FX2D);

  surface.setResizable(true);

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);

  hpglManager.updatePlotterScale();

  hpglManager.setVelocity(20); 

  //RShape s = RShape.createRing(200, 200, 300, 200); 
  //fillContour(s, 0);

  shapes = new ArrayList<Shape2D>();

  //RShape r = RShape.createRectangle(350,50,100,100);
  //RShape r2 = RShape.createRectangle(360,50,80,80);
  //r.polygonize(); 
  //r2.polygonize();
  //r = r.diff(r2);
  //shapes.add(r);
  getShapesForImage("test-circles.png", imageScale); 

  //for(int i =0; i<shapes.size(); i++) { 
  //   Shape2D shape = shapes.get(i); 
  //   if(shape instanceof Polygon2D) ((Polygon2D)shape).smooth(0.125,0.125); 
  //   else if(shape instanceof CompoundPolygon2D) ((CompoundPolygon2D)shape).smooth(0.25,0.125); 
  //}

  //   hpglManager.startPrinting();
  //noLoop();
}


void draw() {

  float zoom = 1; 

  background(0);
  //    tint(255, 128);

  text(frameCount, 0, 0); 
  scale(zoom);




  xzoom += (clamp(map(mouseX, width*0.1, width*0.9, 0, - width * (zoom-1)/zoom), -width * (zoom-1)/zoom, 0)-xzoom)*0.1; 
  yzoom += (clamp(map(mouseY, height*0.1, height*0.9, 0, - height * (zoom-1)/zoom), -height * (zoom-1)/zoom, 0)-yzoom)*0.1; 
  translate(xzoom, yzoom); 

  pushMatrix(); 
  scale(imageScale, imageScale); 
  //image(dst, src.width, 0);
  image(dst, 0, 0);
  popMatrix();
  colorMode(RGB);
  //strokeWeight(penThickness);
  //background(0); 

  noFill();

  hpglManager.update();

  strokeWeight(1/zoom);

  //for (Shape2D shape : shapes) {
  //  //stroke(255,0,255);
  //  if (shape.containsPoint(new Vec2D(mouseX/zoom-xzoom, mouseY/zoom-yzoom))) {
  //    fillContour(shape, 1, true);
  //    //stroke(0,255,0);
  //  }

  //  // gfx.polygon2D(shape);
  //}

  if (shapenum<shapes.size()) { 
    Shape2D shape = shapes.get(shapenum);
    //if(shape.getBounds().width<dst.width) 
    //fillContour(shape, (shapenum%8)+1, false);
    fillContour(shape, 1, false);
    shapenum++;
  }
}

void getShapesForImage(String filename, float scale) { 

  shapes = new ArrayList<Shape2D>();

  src = loadImage(filename); 

  opencv = new OpenCV(this, src);

  opencv.gray();
  //opencv.blur(3);
  opencv.invert();
  opencv.threshold(100);
  //opencv.erode();
  dst = opencv.getOutput();

  contours = findContours(true);

  int index = 0; 
  int level = 0; 

  do { 

    // hierarchy gives you an array of ints that store 
    // the contour indices in the format : 
    // h[0] the index for the next contour
    // h[1] the index for the previous contout
    // h[2] the index for a child contour
    // h[3] the index for the parent contour
    // all would be -1 if not applicable
    // the indices for the hierarchy list match the indices
    // for the contours list so you know that hierarchy.get(0,4) 
    // would give you hierarchy information for contours.get(4); 

    Contour contour = contours.get(index); 
    double[] h  = hierarchy.get(0, index);
    Polygon2D s = new Polygon2D();

    
    for (int i = 0; i<contour.getPoints().size();i++) {
        PVector point = contour.getPoints().get(i); 
        s.add(point.x*scale, point.y*scale);
    }

    if ((level == 0 ) || (shapes.size()==0)) { 
      if (s.getNumVertices()>3) shapes.add(s);

    } else { 
      Shape2D last = shapes.get(shapes.size()-1); 
      shapes.remove(shapes.size() - 1);
      if (last instanceof Polygon2D) { 
        last = new CompoundPolygon2D((Polygon2D)last);
      } 
      ((CompoundPolygon2D)last).polygons.add(s); 

      //last = RG.diff(last, s); 

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

class CompoundPolygon2D implements Shape2D { 

  public List<Polygon2D> polygons; 

  public CompoundPolygon2D(Polygon2D poly) { 
    polygons = new  ArrayList<Polygon2D>(); 
    polygons.add(poly);
  }

  boolean containsPoint(ReadonlyVec2D p) {
    if (polygons.size()>0) { 
      boolean inside = polygons.get(0).containsPoint(p); 
      for (int i = 1; i<polygons.size(); i++) { 
        if (polygons.get(i).containsPoint(p)) inside = !inside;
      }
      return inside;
    } else { 
      return false;
    }
  }
  float getArea() {
    if (polygons.size()==0) return 0; 

    float a = polygons.get(0).getArea(); 
    for (int i = 1; i<polygons.size(); i++) { 
      a-=polygons.get(i).getArea();
    }
    return a;
  }

  Circle getBoundingCircle() {
    if (polygons.size()==0) return new Circle(0, 0, 0); 
    return polygons.get(0).getBoundingCircle();
  }

  Rect getBounds() {
    if (polygons.size()==0) return new Rect(0, 0, 0, 0); 
    return polygons.get(0).getBounds();
  }

  float getCircumference() {
    if (polygons.size()==0) return 0; 
    return polygons.get(0).getCircumference();
  }

  List<Line2D> getEdges() {
    List<Line2D> edges = new ArrayList<Line2D>(); 
    for (int i = 0; i<polygons.size(); i++) { 
      edges.addAll(polygons.get(i).getEdges());
    }
    return edges;
  };


  Vec2D getRandomPoint() {
    Vec2D p;
    boolean valid = true; 

    do { 
      p = polygons.get(0).getRandomPoint();  
      for (int i = 1; i<polygons.size(); i++) {
        if (polygons.get(i).containsPoint(p)) { 
          valid = false; 
          break;
        }
      }
    } while (!valid); 
    return p;
  }
  Polygon2D toPolygon2D() {
    return polygons.get(0);
  }

  CompoundPolygon2D smooth(float amount, float baseWeight) {
    for (Polygon2D poly : polygons) { 
      poly.smooth(amount, baseWeight);
    }
    return this;
  }
}