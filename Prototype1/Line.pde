class Line { 

  public PVector p1; 
  public PVector p2;
  public int penNumber; 
  public boolean tested = false; 
  public boolean reversed = false; 

  public Line(PVector start, PVector end, int pen) { 
    p1 = start.copy(); 
    p2 = end.copy(); 
    penNumber = pen;
  }
  public void draw() { 
    line(p1.x, p1.y, p2.x, p2.y);
  }
  public PVector getStart() { 
    return reversed?p2:p1;
  }
  public PVector getEnd() { 
    return reversed?p1:p2;
  }

  public boolean equals(Line line) { 
    return (((line.p1 == p1) && (line.p2 == p2)) || ((line.p1 == p2) &&(line.p2 == p1)));
  }
}