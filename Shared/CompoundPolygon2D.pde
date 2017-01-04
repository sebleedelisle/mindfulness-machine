import java.awt.Shape;
import java.awt.geom.Area;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Path2D;
import java.awt.geom.PathIterator;
import java.awt.geom.Rectangle2D;

class CompoundPolygon implements Shape2D { 

  public List<Polygon2D> polygons; 

  public CompoundPolygon(Polygon2D poly) { 
    polygons = new  ArrayList<Polygon2D>(); 
    if (!poly.isClockwise()) {
      poly.flipVertexOrder();
    }
    polygons.add(poly);
  }

  public void addPoly(Polygon2D poly) { 
    if (poly.isClockwise()) {
      poly.flipVertexOrder();
    }
    polygons.add(poly);
  }
  public Polygon2D getParent() { 
    return polygons.get(0);
  }

  public void subtract(CompoundPolygon p) { 
    BooleanShapeBuilder2 builder = new BooleanShapeBuilder2(); 
    // if p is outside of this shape completely, do nothing

    // if p is completely contained within parent shape 
    if (getParent().containsPolygon(p.getParent())) { 
      boolean overlapschild = false; 
      //         iterate through children
      for (Polygon2D poly : 
        //         if it overlaps child, union the child and delete it

        //     if it doesn't overlap any children, just add p to children
        //     if it overlaps any children, union it with the child
    }
  }

  public List<Polygon2D> getPolygons() {
    return polygons;
  }

  boolean containsPolygon(CompoundPolygon p) { 

    if (!getParent().containsPolygon(p.getParent())) { 
      // no overlap at all
      return false;
    } else { 
      for (Polygon2D poly : polygons) { 
        // entirely contained in a hole 
        if (poly.containsPolygon(p.getParent())) return false;
      }
      return true;
    }
  }

  boolean intersectsPolygon(CompoundPolygon p) { 
    for (Polygon2D poly1 : getPolygons()) { 
      for (Polygon2D poly2 : p.getPolygons()) { 
        // entirely contained in a hole 
        if (poly1.intersectsPolygon(poly2)) return true;
      }
    }
    return false;
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

  // TODO doesn't take into account children - is this possible? 
  Polygon2D toPolygon2D() {
    return polygons.get(0);
  }

  CompoundPolygon smooth(float amount, float baseWeight) {
    for (Polygon2D poly : polygons) { 
      poly.smooth(amount, baseWeight);
    }
    return this;
  }
}

void drawCompoundPolygon(CompoundPolygon cp) { 
  beginShape(); 
    for (Polygon2D poly : cp.getPolygons()) { 
    if (!poly.isClockwise()) beginContour(); 
      for (Vec2D v : poly.vertices) { 
      vertex(v.x, v.y);
    }
    if (!poly.isClockwise()) endContour();
  }
  endShape();
}

public class BooleanShapeBuilder2 extends BooleanShapeBuilder {

  private Type type; 

    public BooleanShapeBuilder2() {
    super(Type.UNION);
  }

  public BooleanShapeBuilder2(Type type, int bezierRes) {
    super(Type.UNION, bezierRes);
  }

  public BooleanShapeBuilder2 xorShape(Shape2D s) { 

    Area a = new Area(convertToAWTShape(s)); 
      getArea().exclusiveOr(a); 

      return this;
  }

  public BooleanShapeBuilder2 addShape(Shape2D s) { 

    Area a = new Area(convertToAWTShape(s)); 
      getArea().add(a); 

      return this;
  }

  public BooleanShapeBuilder2 intersectShape(Shape2D s) { 

    Area a = new Area(convertToAWTShape(s)); 
      getArea().intersect(a); 

      return this;
  }
  public BooleanShapeBuilder2 subtractShape(Shape2D s) { 

    Area a = new Area(convertToAWTShape(s)); 
      getArea().subtract(a); 

      return this;
  }
  public Type setType(Type type) { 
    this.type = type; 
      return this.type;
  }


  Shape convertToAWTShape(Shape2D s) {
    if (s instanceof Rect) {
      Rect r = (Rect) s; 
        return new Rectangle2D.Float(r.x, r.y, r.width, r.height);
    }
    if (s instanceof Triangle2D) {
      Triangle2D t = (Triangle2D) s; 
        Path2D path = new Path2D.Float(); 
        path.moveTo(t.a.x, t.a.y); 
        path.lineTo(t.b.x, t.b.y); 
        path.lineTo(t.c.x, t.c.y); 
        path.closePath(); 
        return path;
    }
    if (s instanceof Ellipse) {
      Ellipse e = (Ellipse) s; 
        Vec2D r = e.getRadii(); 
        return new Ellipse2D.Float(e.x - r.x, e.y - r.y, r.x * 2, r.y * 2);
    }
    if (!(s instanceof Polygon2D)) {
      s = s.toPolygon2D();
    }
    Polygon2D poly = (Polygon2D) s; 
      Path2D path = new Path2D.Float(); 
      Vec2D p = poly.get(0); 
      path.moveTo(p.x, p.y); 
      for (int i = 1, num = poly.getNumVertices(); i < num; i++) {
      p = poly.get(i); 
        path.lineTo(p.x, p.y);
    }
    path.closePath(); 
      return path;
  }
}