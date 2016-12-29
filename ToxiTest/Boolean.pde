
import toxi.geom.*;
import java.awt.Shape;
import java.awt.geom.Area;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Path2D;
import java.awt.geom.PathIterator;
import java.awt.geom.Rectangle2D;
import java.lang.reflect.Field;

public class BooleanShapeBuilder2 extends BooleanShapeBuilder {

    private Type type;

    public BooleanShapeBuilder2(Type type) {
        super(type);
    }

    public BooleanShapeBuilder2(Type type, int bezierRes) {
        super(type, bezierRes);
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