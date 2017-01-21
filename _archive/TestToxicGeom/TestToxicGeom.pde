
import gab.opencv.OpenCV; 
import org.opencv.core.Mat; 
import org.opencv.core.MatOfInt4; 
import toxi.color.*;
import toxi.geom.*;
import toxi.processing.*;
import java.util.Collections;

List<CompoundPolygon> shapes; 
HPGLManager hpglManager; 
ToxiclibsSupport gfx;
float xzoom = 0;
float yzoom =0;
int shapenum = 0; 


void setup() {

  hpglManager = new HPGLManager(this); 
  gfx=new ToxiclibsSupport(this);
  size(1170, 800, FX2D);

  surface.setResizable(true);

  surface.setSize(round(800 * hpglManager.plotWidth/hpglManager.plotHeight), 800);

  hpglManager.updatePlotterScale();


  int rowcount = 6; 
  int colcount = 6; 
  int numshapes = rowcount*colcount; 
  float spacing = 120; 
  float size = 50; 

  shapes = new ArrayList<CompoundPolygon>();
  
  Circle bigc = new Circle(width/2, height/2, 200);
  shapes.add(bigc.toPolygon2D());
  
  for (int i = 0; i<numshapes; i++) { 
    Circle c = new Circle((i%colcount)*spacing + size, floor((float)i/(float)colcount)*spacing + size, size);
    shapes.add(new CompoundPolygon(c.toPolygon2D()));
  }
  shapes.add(new CompoundPolygon(new Rect(20, 20, 200, 20).toPolygon2D()));
  shapes.add(new CompoundPolygon(new Rect(120, 120, 20, 20).toPolygon2D()));
  //for(int i = 0; i<100; i++) { 
  //  Circle c = new Circle(random(width), random(height), random(10,40));
  //  shapes.add(c.toPolygon2D());
    
  //}

  shapes = removeOverlaps(shapes);
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

  colorMode(RGB);
  //strokeWeight(penThickness);
  //background(0); 

  noFill();

  hpglManager.update();

  strokeWeight(1/zoom);
  blendMode(ADD);
  for (int i = 0; i<shapes.size(); i++) {
    Shape2D shape = shapes.get(i); 
    stroke(255, 0, 0);
    //if (shape.containsPoint(new Vec2D(mouseX/zoom-xzoom, mouseY/zoom-yzoom))) {
    //fillContour(shape, 1, true);
    //stroke(0,255,0);
    //}
    noFill(); 
    if (floor(map(mouseX, 0, width, 0, shapes.size())) == i) {
      stroke(255, 0, 255);
      Rect r = shape.getBounds(); 
      
      gfx.polygon2D(r.toPolygon2D().offsetShape(10));
      fill(255, 0, 255);
    }
    if(shape instanceof CompoundPolygon) {
      drawCompoundPolygon((CompoundPolygon)shape); 
//      gfx.polygon2D((Polygon2D)shape);
    } else { 
      gfx.polygon2D((Polygon2D)shape);
    }
  }

  if (shapenum<shapes.size()) { 
    Shape2D shape = shapes.get(shapenum);
    //if(shape.getBounds().width<dst.width) 
    //fillContour(shape, (shapenum%8)+1, false);
    fillContour(shape, 1, 10, false);
    shapenum++;
  }
}

void mousePressed() { 
  for (int i = 0; i<shapes.size(); i++) {
    Shape2D shape = shapes.get(i); 
    stroke(255);

    if (floor(map(mouseX, 0, width, 0, shapes.size())) == i) {
      gfx.polygon2D((Polygon2D)shape);
      println(shape.getEdges());
    }
  }
}

//---------------------------------------------------------------------


List<CompoundPolygon> removeOverlaps(List<CompoundPolygon> shapes) { 
  shapes = new ArrayList<CompoundPolygon>(shapes);
  for (int i = 0; i<shapes.size(); i++) { 

    CompoundPolygon s1 = shapes.get(i); 

    BooleanShapeBuilder2 builder = new BooleanShapeBuilder2(); 
    builder.addShape(s1); 

    for (int j = i+1; j<shapes.size(); j++) {
      CompoundPolygon s2 = shapes.get(j); 
      builder.subtractShape(s2);
    }

    List<Polygon2D> polys = builder.computeShapes(); 

    if (polys.size()==0) {
      shapes.remove(i); 
      i--;
    } else if (polys.size()>0) { 
      shapes.remove(i); 
      
      shapes.add(i, polys.get(0));
      
      for (int k=1; k<polys.size(); k++) {
        Polygon2D p = polys.get(k); 
        if(p.getEdges().size()>2) { 
          shapes.add(i, polys.get(k));
          i++;
        }
      }
    }
  }

   for (int i = 0; i<shapes.size(); i++) { 

    Shape2D s1 = (Polygon2D)shapes.get(i); 

    BooleanShapeBuilder2 builder = new BooleanShapeBuilder2(); 
    builder.addShape(s1); 

    for (int j = i+1; j<shapes.size(); j++) {
      Shape2D s2 = shapes.get(j); 
      
      if(s1.containsPolygon(s2)) { 
        CompoundPolygon cp;
        if(s1 instanceof CompoundPolygon) {
          cp = (CompoundPolygon)s1; 
          
        } else {
          // make new compound poly
          cp  = new CompoundPolygon(s1);
        }
        // add child of s2
        cp.addPoly(s2); 
        // replace it in array
        shapes.set(i, cp); 
        // remove s2
        shapes.remove(j); 
        j--;
      }
      
    }
   }
   
  return shapes;
}


List<Shape2D> getInteriors(List<Shape2D> shapes) { 
  List<Shape2D> newshapes = new ArrayList<Shape2D>(); 

  //shapes.addAll(srcshapes); 

  for (int i = 0; i<shapes.size(); i++) { 
    println("i="+i); 
    Polygon2D s1 = (Polygon2D)shapes.get(i); 

    for (int j = i+1; j<shapes.size(); j++) {
      println("j="+j); 

      if (i==j) continue; 

      println("before : ", shapes.size(), i, j);
      Polygon2D s2 = (Polygon2D)shapes.get(j); 
      println("got shape");
      if (s1.intersectsPolygon(s2)) { 
        List<Polygon2D> polys = new ArrayList<Polygon2D>();
        BooleanShapeBuilder2 intersectbuilder = new BooleanShapeBuilder2(); 
        intersectbuilder.addShape(s1); 
        intersectbuilder.intersectShape(s2); 
        polys.addAll(intersectbuilder.computeShapes()); 

        BooleanShapeBuilder2 xorbuilder = new BooleanShapeBuilder2(); 
        xorbuilder.addShape(s1); 
        xorbuilder.xorShape(s2); 
        polys.addAll(xorbuilder.computeShapes()); 


        newshapes.addAll(polys); 

        println("after : ", shapes.size(), i, j);
      }
    }
  }

  return newshapes;
}