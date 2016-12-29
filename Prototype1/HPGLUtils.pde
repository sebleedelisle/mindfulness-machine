import geomerative.RRectangle; 


// to fill a shape 
// send an RShape object from Geomerative
// convert top level shape to openCV contour
// get minAreaRect rotated rectangle 
// create lines for RShape by intersection lines
// sort the lines
// send to plotter

void fillContour(RShape shape, float angle) { 

  RRectangle r = shape.getBounds();
  
}