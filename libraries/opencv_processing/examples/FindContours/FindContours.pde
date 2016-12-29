import gab.opencv.*;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

void setup() {
  src = loadImage("test.jpg"); 
  surface.setSize(src.width*2, src.height);
  opencv = new OpenCV(this, src);

  opencv.gray();
  opencv.threshold(70);
  dst = opencv.getOutput();

  contours = opencv.findContours(true, true);
  println("found " + contours.size() + " contours");
}

void draw() {
  //scale(0.5);
  image(src, 0, 0);
  image(dst, src.width, 0);

  noFill();
  strokeWeight(3);
  
  for (Contour contour : contours) {
    stroke(0, 255, 0);
    contour.draw();
    contour.setPolygonApproximationFactor(5);
    stroke(255, 0, 0);
    beginShape();
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      vertex(point.x, point.y);
    }
    endShape();
  }
}