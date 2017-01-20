import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
Rectangle[] faces;
void setup() {
  size(640, 480);
  //video = new Capture(this, 640/2, 480/2);
  video = new Capture(this, 640, 480, "HD Pro Webcam C920", 30);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
}

void draw() {
 
  opencv.loadImage(video);
  opencv.

  image(video, 0, 0,640,480 );

  if (frameCount%10==0) { 

    faces = opencv.detect();
    //println(faces.length);
  }
  noFill();
  stroke(0, 255, 0);
  strokeWeight(1);
  if(faces!=null) { 
    for (int i = 0; i < faces.length; i++) {
      //println(faces[i].x + "," + faces[i].y);
      rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    }
  }
}

void captureEvent(Capture c) {
  c.read();
}