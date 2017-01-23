
import processing.core.*;
import gab.opencv.*;
import org.opencv.video.BackgroundSubtractorMOG;
import processing.video.*;
import java.awt.Rectangle;
import org.opencv.core.Mat;


public class CameraManager { 

  PImage motionImage; 
  PImage scaledCamImageMotion; 
  PImage scaledCamImageFaces; 
  OpenCV openCVMotion;
  OpenCV openCVFaces;
  BackgroundSubtractorMOG backgroundSubtractor;

  Capture cam; 
  PApplet p5; 
  int motionLevel; 
  Rectangle[] faces;
  float camMotionScale, camFacesScale; 
  int camWidth, camHeight; 

  DataPoint motion; // amount of motion detected 0->1
  DataPoint crowd; // number of faces it can currently see
  
  int motionPixelCount; 
  
  

  public CameraManager(PApplet theParent) {
    p5 = theParent;
    
    motion = new DataPoint("Motion", 0,1000); 
    crowd = new DataPoint("Crowd", 0,100); 
    
    //String[] cameras = Capture.list();
    //p5.printArray(cameras);
    
    camMotionScale = 0.125f; 
    camFacesScale = 0.3f; 
    camWidth = 512*2; 
    camHeight = 384*2; 
    openCVMotion = new OpenCV(p5, p5.round(camWidth*camMotionScale), p5.round(camHeight*camMotionScale));
    openCVFaces = new OpenCV(p5, p5.round(camWidth*camFacesScale), p5.round(camHeight*camFacesScale));
    openCVFaces.loadCascade(OpenCV.CASCADE_FRONTALFACE); 

    startBackgroundSubtraction(100, 5, 0.1);

    cam = new Capture(p5, camWidth, camHeight, "Camera", 30);
    cam.start();

    scaledCamImageMotion = p5.createImage(p5.round(camWidth*camMotionScale), p5.round(camHeight*camMotionScale), p5.GRAY);
    scaledCamImageFaces = p5.createImage(p5.round(camWidth*camFacesScale), p5.round(camHeight*camFacesScale), p5.GRAY);
  };

  public void update() { 
    if (cam.available()) { 
      cam.read();
    }

    if (p5.frameCount%2==1) { 
      scaledCamImageMotion.copy(cam, 0, 0, camWidth, camHeight, 0, 0, p5.round(camWidth*camMotionScale), p5.round(camHeight*camMotionScale));
      openCVMotion.loadImage(scaledCamImageMotion);
      updateBackground();


      motionImage = openCVMotion.getOutput();
      motionPixelCount = 0; 
      motionImage.loadPixels();
      for ( int pixel : motionImage.pixels) { 
        if (p5.red(pixel)>0) motionPixelCount++;
      }
      //p5.println(motionImage.pixels[100]);
    }

    if (p5.frameCount%10==0) { 
      scaledCamImageFaces.copy(cam, 0, 0, camWidth, camHeight, 0, 0, p5.round(camWidth*camFacesScale), p5.round(camHeight*camFacesScale));

      openCVFaces.loadImage(scaledCamImageFaces);
      faces = openCVFaces.detect();
    }

    crowd.setValue(getCrowding((faces==null)?0:faces.length));//-crowd)*0.01; 
    motion.setValue(p5.min(motionPixelCount,1000));
    
  }

  public void draw() { 
    draw(0.5f); 
  }
  public void draw(float scale) { 
    
    
    p5.pushStyle(); 
    p5.pushMatrix(); 

    p5.translate(p5.width, 0); 
    p5.scale(-1, 1); 
    //p5.image(cam, 0, 0, camWidth, camHeight);
    //p5.set(800,0,cam);
    
    p5.tint(50, 255, 50);
    p5.translate(p5.width-(camWidth*scale),0); 
    p5.scale(scale, scale); 
    p5.image(cam, 0, 0);

    if (motionImage!=null) { 
      p5.tint(100, 0, 0);
      p5.blendMode(p5.ADD);

      p5.image(motionImage, 0, 0, camWidth, camHeight);
    }
    if (faces!=null) { 
      p5.pushMatrix(); 


      p5.strokeWeight(4); 

      p5.scale(1/camFacesScale, 1/camFacesScale); 
      for (Rectangle r : faces) { 
        //p5.stroke(0,0,255); 
        //p5.noFill(); 
        p5.fill(0, 0, 255);
        p5.noStroke(); 
        p5.rect(r.x, r.y, r.width, r.height);
      }
      p5.popMatrix();
    }

    p5.popMatrix();
    p5.popStyle();

    p5.pushStyle(); 
    p5.stroke(0); 

    //p5.fill(255, 0, 0); 
    //p5.rect(10, 10, getMotion()*640, 10); 
    //p5.rect(10, 30, getCrowding()*640, 10);
    p5.popStyle();
  }

  //public float getMotion() { 
  //  return p5.min(p5.map(motion, 0, (160*120*0.4f), 0, 1), 1);
  //}

  public float getCrowding(int count) { 
    
    float n = p5.min(count/5.0f,1);
    n=1-n; 
    n=n*n; 
    n= 1-n; 
    return p5.round(n*100);
  }

  public void startBackgroundSubtraction(int history, int nMixtures, double backgroundRatio) {
    backgroundSubtractor = new BackgroundSubtractorMOG(history, nMixtures, backgroundRatio);
  }

  public void updateBackground() {
    Mat foreground = openCVMotion.imitate(openCVMotion.matGray);
    backgroundSubtractor.apply(openCVMotion.matGray, foreground, 0.005);
    openCVMotion.setGray(foreground);
  }
}