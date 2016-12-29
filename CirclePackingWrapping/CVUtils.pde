import org.opencv.imgproc.Imgproc;
import org.opencv.core.*; 
import gab.opencv.Contour; 
import java.util.Collections;
import java.util.Comparator;
import org.opencv.core.MatOfPoint;


double getOptimumColouringAngle(Contour c) { 


  return getMinAreaRect(c).angle;
}

RotatedRect getMinAreaRect(Contour c) { 
  MatOfPoint src = c.pointMat;

  MatOfPoint2f dst = new MatOfPoint2f();
  src.convertTo(dst, CvType.CV_32F);


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
  catch(CvException e) {
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

public class IntersectionComparator implements Comparator<PVector> {

  public PVector startpoint; 
  public IntersectionComparator(PVector start) {
    startpoint = start.copy();
  }
  public int compare(PVector c1, PVector c2) {
    float dist1 = startpoint.dist(c1); 
    float dist2 = startpoint.dist(c2); 

    if (dist1==dist2) {
      return 0;
    } else if (dist1<dist2) {
      return -1;
    } else {
      return 1;
    }
  }
}