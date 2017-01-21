

import toxi.color.*;
import toxi.geom.*;
import toxi.processing.*;
import java.util.List;
import java.util.Comparator;
import java.util.Collections;

// number of vertices in each polygon
int num=30;

List<ColoredPolygon> polygons = new ArrayList<ColoredPolygon>();

ToxiclibsSupport gfx;

void setup() {
    size(800, 600);
    noStroke();
    smooth();
    gfx=new ToxiclibsSupport(this);

    // pick a random bright color and set its alpha to 50-80%
    TColor col=ColorRange.BRIGHT.getColor().setAlpha(random(0.5, 0.8));
    // add randomized vertices
    ColoredPolygon poly=new ColoredPolygon(col);
    float radius=random(50, 400);
    for (int i=0; i<num; i++) {
        poly.add(Vec2D.fromTheta((float)i/num*TWO_PI).scaleSelf(random(0.2, 1)*radius).addSelf(width/2, height/2));
    }
    // add poly to list of polygons
    polygons.add(poly);
}

void draw() {

    //int lineNum = floor(map(mouseX, 0, width, 1,8)); 

    float penThickness = 3; 
    background(255);
    // iterate over all polygon created so far
    for (ColoredPolygon p : polygons) {

        Polygon2D op = p.copy().offsetShape(-3); 
        Rect r = p.getBounds(); 
        // and draw
        noFill();
        stroke(p.col.toARGB());
        gfx.polygon2D(p);
        gfx.polygon2D(op);
        gfx.rect(r);

        stroke(0, 0, 0, 70); 
        Vec2D p1 = r.getTopLeft(); 
        Vec2D p2 = r.getTopRight(); 
        Vec2D p3 = r.getBottomRight(); 

        Vec2D v1 = p3.sub(p2); 
        Vec2D v2 = p2.sub(p1); 
        float mag = v2.magnitude(); 
        for (float t = 0; t<mag; t+=penThickness) { 
            Vec2D start = p1.interpolateTo(p2, t/mag);
            Vec2D end = start.add(v1); 
            Line2D l = new Line2D(start, end); 

            stroke(0, 0, 0, 70);

            List <Vec2D> ips = getIntersectionPoints(p, l); 
            
            for (int i = 0; i<ips.size(); i++) {
                Vec2D ip = ips.get(i); 
                ellipseMode(RADIUS);
                stroke(0, 50);
                gfx.circle(ip, 1);   

                if (i>0) { 
                    if (i%2<1) {
                        stroke(255, 0, 0, 50);
                    } else {
                        stroke(0, 255, 0, 50);
                    }
                    //if(i==lineNum) 
                    gfx.line(ips.get(i-1), ip);
                }
            }
        }
    }
}


List <Vec2D> getIntersectionPoints(Polygon2D p, Line2D l) {
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



// extend the standard Polygon2D class to include color information
class ColoredPolygon extends Polygon2D {
    ReadonlyTColor col;

    public ColoredPolygon(ReadonlyTColor col) {
        this.col=col;
    }
}

void mousePressed() { 

    polygons.clear();
    // pick a random bright color and set its alpha to 50-80%
    TColor col=ColorRange.BRIGHT.getColor().setAlpha(random(0.5, 0.8));
    // add randomized vertices
    ColoredPolygon poly=new ColoredPolygon(col);
    float radius=random(50, 400);
    for (int i=0; i<num; i++) {
        poly.add(Vec2D.fromTheta((float)i/num*TWO_PI).scaleSelf(random(0.2, 1)*radius).addSelf(width/2, height/2));
    }
    // add poly to list of polygons
    polygons.add(poly);
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