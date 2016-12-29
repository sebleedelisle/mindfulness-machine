import org.opencv.imgproc.Imgproc;
//import org.opencv.core.*; 
import gab.opencv.Contour; 
import org.opencv.core.RotatedRect;
import java.util.Collections;
import java.util.Comparator;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;



double getOptimumColouringAngle(Contour c) { 
  return getMinAreaRect(c).angle;
}

RotatedRect getMinAreaRect(Contour c) { 
  MatOfPoint src = c.pointMat;
  MatOfPoint2f dst = new MatOfPoint2f();
  src.convertTo(dst, org.opencv.core.CvType.CV_32F);
  return Imgproc.minAreaRect(dst);
}

void drawRotatedRect(RotatedRect r) {

  pushMatrix(); 
  translate((float)r.center.x, (float)r.center.y); 
  rotate(radians((float)r.angle)); 
  rectMode(CENTER);
  rect(0, 0, (float)r.size.width, (float)r.size.height); 
  rectMode(CORNER);
  popMatrix();
}

public ArrayList<Contour> findContours(boolean findHoles) {

  hierarchy = new MatOfInt4();

  ArrayList<Contour> result = new ArrayList<Contour>();


  ArrayList<MatOfPoint> contourMat = new ArrayList<MatOfPoint>();


  try {
    int contourFindingMode = Imgproc.RETR_CCOMP;//(findHoles ? Imgproc.RETR_LIST : Imgproc.RETR_EXTERNAL);

    Imgproc.findContours(opencv.matGray, contourMat, hierarchy, contourFindingMode, Imgproc.CHAIN_APPROX_SIMPLE);
  } 
  catch(org.opencv.core.CvException e) {
    PApplet.println("ERROR: findContours only works with a gray image.");
  }
  for (MatOfPoint c : contourMat) {
    result.add(new Contour(this, c));
  }
  println(hierarchy);

  // if (sort) {
  //   Collections.sort(result, new ContourComparator());
  // }

  return result;
}