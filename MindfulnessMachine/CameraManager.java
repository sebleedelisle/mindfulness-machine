
import processing.core.*;
import gab.opencv.*;
import org.opencv.video.BackgroundSubtractorMOG;
import processing.video.*;
import java.awt.Rectangle;
import org.opencv.core.Mat;



public class CameraManager { 
String cameraName = "Camera";//"FaceTime HD Camera (Built-in)";// ******* CHANGE TO "Camera"!!!!!!!!
  PImage motionImage; 
  PImage scaledCamImageMotion; 
  PImage scaledCamImageFaces; 
  OpenCV openCVMotion;
  OpenCV openCVFaces;
  BackgroundSubtractorMOG backgroundSubtractor;

  Capture cam; 
  boolean camStarted = false; 
  PApplet p5; 
  int motionLevel; 
  Rectangle[] faces;
  float camMotionScale, camFacesScale, camVerticalPortion; 
  int camWidth, camHeight; 

  DataPoint motion; // amount of motion detected 0->1
  DataPoint crowd; // number of faces it can currently see

  int motionPixelCount; 
  
  int cameraReconnectTime = 0;
  int cameraReconnectTries = 0; 
  int lastImageTime = 0; 


  public CameraManager(PApplet theParent) {
    p5 = theParent;

    motion = new DataPoint("Motion", 0, 1000); 
    crowd = new DataPoint("Crowding", 0, 100); 

    //String[] cameras = Capture.list();
    //p5.printArray(cameras);

    camMotionScale = 0.25f; 
    camFacesScale = 0.5f; 
    camVerticalPortion = 0.6f; 
    camWidth = 1024; 
    camHeight = 768; 
    openCVMotion = new OpenCV(p5, p5.round(camWidth*camMotionScale), p5.round(camHeight*camMotionScale*camVerticalPortion));
    openCVFaces = new OpenCV(p5, p5.round(camWidth*camFacesScale), p5.round(camHeight*camFacesScale*camVerticalPortion));
    openCVFaces.loadCascade(OpenCV.CASCADE_FRONTALFACE); 

    startBackgroundSubtraction(100, 5, 0.1);
   
    scaledCamImageMotion = p5.createImage(p5.round(camWidth*camMotionScale), p5.round(camHeight*camMotionScale), p5.GRAY);
    scaledCamImageFaces = p5.createImage(p5.round(camWidth*camFacesScale), p5.round(camHeight*camFacesScale), p5.GRAY);
  };

  public boolean connectToCamera() { 
    camStarted = false; 
     p5.println("connecting to camera..."); 
     try { 
      cam = new Capture(p5, camWidth, camHeight, cameraName, 30);
      cam.start();
      camStarted = true;
      
    } 
    catch (RuntimeException e) { 
      p5.println("camera error! ", e);
       //camStarted = false; 
    } 
    finally { 
      p5.println("camera error!");
       
    }
    if(!camStarted) {
      try {
       cam.stop();  
        
      }catch (RuntimeException e) { 
       p5.println(e); 
      }
      cameraReconnectTime = p5.millis();
      cameraReconnectTries++; 
       int nextTime = (int)p5.constrain(p5.pow(2, cameraReconnectTries)*1000, 5000, 300000); 
      cameraReconnectTime+=nextTime;

    } else {
      p5.println("...success!", camStarted); 
      lastImageTime = p5.millis();
      cameraReconnectTries = 0; 
    }
    return camStarted;
  }

  public void update() { 
    if (!camStarted) {
      if(cameraReconnectTime<p5.millis()) { 
       
        connectToCamera(); 
      }
      
    }
    if(!camStarted) return; 
    
    if (cam.available()) { 
      lastImageTime = p5.millis(); 
      cam.read();
    } else { 
      if(p5.millis()-lastImageTime>5000) { 
        // no images for five seconds!
        try { 
          cam.stop(); 
          cam.dispose(); 
        } catch (RuntimeException e) { 
          p5.println(e); 
        } 
        camStarted = false; 
        connectToCamera(); 
      }
      
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
    motion.setValue(p5.min(motionPixelCount/2, 1000));
  }

  public float drawData(float x, float y, float w, float barheight, float vspacing) {

   motion.drawHorizontal(p5, x, y, w, barheight); 
   y+=barheight+vspacing;
   crowd.drawHorizontal(p5, x, y, w, barheight);  
   return y+barheight; 
  }
  public void draw(float x, float y) { 
    draw(x, y, 0.5f);
  }
  public void draw(float x, float y,float scale) { 


    p5.pushStyle(); 
    p5.pushMatrix(); 
    p5.translate(x,y); 
    if (camStarted) { 

      p5.translate(p5.width, 0); 
      p5.scale(-1, 1); 
      //p5.image(cam, 0, 0, camWidth, camHeight);
      //p5.set(800,0,cam);


      p5.tint(50, 255, 50);
      p5.translate(p5.width-(camWidth*scale), 0); 
      p5.scale(scale, scale); 
      p5.image(cam, 0, 0);

      if (motionImage!=null) { 
        p5.tint(100, 0, 0);
        p5.blendMode(p5.ADD);

        p5.image(motionImage, 0, 0, camWidth, camHeight*camVerticalPortion);
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
    } else { 
      p5.fill(0,30,0); 
      p5.rect(0, 0, camWidth*scale, camHeight*scale);
      p5.fill(0,255,0);
      p5.textAlign(p5.CENTER, p5.CENTER); 
      //p5.textSize(20);
      p5.text("CAMERA CONNECTION ERROR", camWidth/2*scale, camHeight/2*scale-15); 
       p5.fill(0,100,0);
      p5.text("RETRYING IN " +p5.round((cameraReconnectTime-p5.millis())/1000f), camWidth/2*scale, camHeight/2*scale + 15); 
      
      
      
    }
    p5.popMatrix();
    p5.popStyle();
  }

  boolean renderCamera(int x, int y) { 
    return renderCamera(x, y, camWidth, camHeight);
  }
  
  boolean renderCamera( int x, int y, int w, int h) { 
    float renderAspect =  (float)w/ (float)h; 
    float cameraAspect = (float)camWidth/ (float)camHeight; 

    float renderWidth, renderHeight; 
    if (renderAspect<cameraAspect) { 
      //p5.println('1'); 
      renderWidth = w; 
      renderHeight = w/cameraAspect; 
      y+=(h-renderHeight)/2;
    } else { 
      //p5.println('2'); 
      renderHeight = h; 
      renderWidth = h*cameraAspect; 
      x+=(w-renderWidth)/2;
    }
    if (camStarted) {
      p5.image(cam, x, y, renderWidth, renderHeight);
      return true;
    } else { 
      p5.pushStyle();    
      p5.fill(0,255,0);
      p5.textAlign(p5.CENTER, p5.CENTER); 
      p5.textSize(renderHeight*0.05f);
      p5.text("CAMERA ERROR", x+(renderWidth/2.0f), y+(renderHeight/2.0f)); 
      p5.popStyle(); 
      
    
      return false;
    }
  }

  public float getCrowding(int count) { 

    float n = p5.min(count/5.0f, 1);
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