
import geomerative.*;

ArrayList<RShape> shapes; 
ArrayList<RPolygon> polygons; 


void setup() { 

  RG.init(this);


  shapes = new ArrayList<RShape>(); 
  polygons = new ArrayList<RPolygon>(); 

  size(800, 600);

  for (int i = 0; i<6; i++) { 
    RShape s = new RShape();

    shapes.add(s);

    s.addLineTo(300, 0);
    s.addLineTo(300, 200);
    s.addLineTo(0, 200);
    s.addLineTo(0, 0);

    s.addMoveTo(70, 120);
    s.addLineTo(70, 70);
    s.addLineTo(140, 70);
    s.addLineTo(140, 120);

    //    s.addMoveTo(0, 0);
    //    s.addLineTo(150, -100);
    //    s.addLineTo(300, 0);

    s.scale(0.5);
    s.translate(i%2*200+100, (int)(i/2)*150+100);
  }

  for (int i = 0; i<6; i++) { 
    RPolygon p = RPolygon.createRing(100, 80);
    p.translate(i%2*200+100, (int)(i/2)*150+100);
    polygons.add(p);
  }
}



void draw() {

  //translate(400, 400);

  for(int i = 0; i<shapes.size(); i++) { 
     shapes.get(i).draw(); 

  }
  for (int i = 0; i<polygons.size(); i++) { 
    //polygons.get(i).draw();
  }
}