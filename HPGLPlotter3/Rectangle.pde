
class Rectangle { 

  float x, y, w, h; 
  Rectangle(float x, float y, float w, float h) { 
    set(x, y, w, h);
  }

  void set(float x, float y, float w, float h) {

    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }

  float getRight() { 
    return x+w;
  }
  float getBottom() { 
    return y+h;
  }

  void render() { 

    rect(x, y, w, h);
  }

  boolean containsPoint(PVector p) { 
    return((p.x<getRight()) && (p.x>x) && (p.y<getBottom()) && (p.y>y));
  }
}