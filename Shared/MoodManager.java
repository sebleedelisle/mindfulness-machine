
import processing.core.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Calendar;
import java.text.SimpleDateFormat; 

public class MoodManager {

  CameraManager cameraManager; 

  SensorReader sensorReader;

  DataPoint happy; 

  DataPoint sentiment; 
  DataPoint stimulation; 

  DataPoint vhorm; 
  DataPoint vcirc; 

  PApplet p5; 

  float timeSpeed = 1; 

  Calendar startTime, currentTime; 

  SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy kk:mm");
  SimpleDateFormat dayFormat = new SimpleDateFormat("E dd/MM/yy");

  //int updateInterval = 1000*60; // update every minute. 
  //int updateCount = 0; 
  public MoodManager(PApplet processing) {

    p5 = processing; 


    cameraManager = new CameraManager(p5); 

    sensorReader = new SensorReader(p5);

    startTime = Calendar.getInstance();

    happy = new DataPoint("happy", -1, 1);
    vhorm = new DataPoint("vhorm", -1, 1); 
    vcirc = new DataPoint("vcirc", -1, 1);

    sentiment = new DataPoint("joy", -1, 1);
    stimulation = new DataPoint("stim", -1, 1);

    happy.smooth=1; 
    vhorm.smooth=1; 
    vcirc.smooth=1;
  }

  public void update() { 
    //while (p5.millis()*timeSpeed/updateInterval>updateCount) { 
    currentTime = (Calendar)startTime.clone();
    currentTime.add(Calendar.MILLISECOND, p5.round(p5.millis()*timeSpeed));
    //updateCount++;
    //}
    vcirc.setValue(calculateDailyCircadian(currentTime)*1.15f);
    vhorm.setValue(calculateWeeklyCircadian(currentTime));
    // add a little noise to the happiness factor
    happy.setValue((vcirc.value*0.2f) + (vhorm.value*0.8f) + ((p5.noise((float)p5.millis()*timeSpeed*0.0001f)-0.5f)*0.1f));



    float sent = sentiment.targetValue; 
    // eases towards happy value based on virtual hormones and circadian rhythm
    sent += (happy.value-sent)*0.01;  
    // add colour temperature; 
    float colourtemp = sensorReader.temperature.value; 
    float lux = sensorReader.lux.value; 

    // need to log what's happening somewhere and check that those values have an impact
    // maybe store them as settings? 
    if ((lux>800) && (colourtemp>10000)) {
      // we're probably in daylight
      sent+=0.005f;
    } else if (lux<500) { 
      // we're in the dark 
      sent-=0.005f;
    }
    sentiment.setValue(sent); 

    // TODO maybe don't update stimulation so frequently? 

    float stim = stimulation.targetValue; 
    //stim-=0.001f; // stimulation will always reduce unless more input happens
    float stimtarget = p5.map(cameraManager.motion.value, 0, 1000, 0, 1);
    stimtarget += p5.map(cameraManager.crowd.value, 0, 100, 0, 1.5f); 
    stimtarget-=1; // put it in -1 to +1 range
    //if(stimtarget>1) stimtarget = 1; 

    // if stimulation is rising then raise quickly... 
    if (stim<stimtarget) stim = stimtarget; 
    // otherwise ease towards lower target
    else stim+=(stimtarget-stim)*0.01; 
    stim = p5.constrain(stim, -1, 1);
    // TODO add temperature effect
    stimulation.setValue(stim);


    cameraManager.update();
    sensorReader.update();
  }

  public void draw() { 

    float dataheight = 384; 

    cameraManager.draw();  
    cameraManager.motion.draw(p5, 700, 0, 40, dataheight); 
    cameraManager.crowd.draw(p5, 760, 0, 40, dataheight); 

    sensorReader.temperature.draw(p5, 520, 0, 40, dataheight); 
    sensorReader.lux.draw(p5, 580, 0, 40, dataheight); 
    sensorReader.colourTemperature.draw(p5, 640, 0, 40, dataheight); 
    vhorm.draw(p5, 820, 0, 40, dataheight); 
    vcirc.draw(p5, 880, 0, 40, dataheight); 
    happy.draw(p5, 940, 0, 40, dataheight);

    stimulation.draw(p5, 1060, 0, 60, dataheight); 
    sentiment.draw(p5, 1140, 0, 60, dataheight);
  }

  public void renderCamera(int x, int y, int w, int h) { 
    float renderAspect =  (float)w/ (float)h; 
    float cameraAspect = (float)cameraManager.camWidth/ (float)cameraManager.camHeight; 

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

    p5.image(cameraManager.cam, x, y, renderWidth, renderHeight);
  }

  // returns normalised value
  float getHappiness() {
    return p5.map(sentiment.getValue(), -1,1,0,1); 
  }

  float getStimulation() {
    
    return p5.map(stimulation.getValue(), -1,1,0,1); 
  }

  float calculateWeeklyCircadian(Calendar c) { 

    int day = c.get(Calendar.DAY_OF_WEEK);
    int hours = c.get(Calendar.HOUR_OF_DAY);
    int mins = c.get(Calendar.MINUTE);
    // day is from 1 (SUNDAY) to 7 (SATURDAY), 
    // hour is from 0 (midnight) to 23 (11pm)
    // minute is from 0 to 59

    // fix so range is between 0 and 6
    float time = day-1; 
    // add normalised hour value
    time  += (float)hours/24f; 
    // add normalised minute value
    time += (float)mins/60f/24f;
    time = p5.map(time, 0, 7, 0, p5.PI*2); 
    // println(time, cos(time));

    return p5.cos(time);
  }

  float calculateDailyCircadian(Calendar c) { 

    int hours = c.get(Calendar.HOUR_OF_DAY);
    int mins = c.get(Calendar.MINUTE);

    // hour is from 0 (midnight) to 23 (11pm)
    // minute is from 0 to 59

    // normalise for 0 to 1 
    float time = (float)hours; 
    // add normalised minute value
    time += (float)mins/60f;
    time = p5.map(time, 0, 24, 0, p5.PI*2) - p5.PI/4; 
    //println(time, sin(time));
    float v = p5.cos(time)- (p5.cos(time*3)/3); 
    //v*=v; 
    return -v;
  }
}




/*
  public void draw(int width, int height) { 
 
 float zoom = 0.5f; //p5.map(p5.mouseY, 0, 300, 0.2f,20); 
 
 p5.pushStyle(); 
 p5.blendMode(p5.ADD); 
 p5.fill(255); 
 
 p5.text(dateFormat.format(currentTime.getTime()), 10, 20);
 p5.noFill(); 
 p5.stroke(0, 255, 255); 
 int startIndex = (happyHistory.size()-(p5.round((float)width/zoom)));
 p5.beginShape(); 
 for (int i = startIndex; i<happyHistory.size(); i++) {
 //stroke(0,255,255); 
 if (i>=0) {
 float x = (i-startIndex)*zoom; 
 p5.vertex(x, happyHistory.get(i)*-299+300);
 }
 }
 p5.endShape(); 
 
 Calendar labelDate = (Calendar)currentTime.clone();
 // Draw 24 hour day dividers
 float milsperpixel = updateInterval/zoom; 
 int milsinday = 24*60*60*1000; 
 int milsofday = (currentTime.get(Calendar.HOUR_OF_DAY) * 60*60*1000) 
 + (currentTime.get(Calendar.MINUTE) * 60*1000)
 + (currentTime.get(Calendar.SECOND) * 1000) 
 + currentTime.get(Calendar.MILLISECOND); 
 
 float x = width - (milsofday/milsperpixel); 
 p5.stroke(0, 100, 100); 
 
 while (x>0) { 
 p5.line(x, 0, x, 600);
 p5.text(dayFormat.format(labelDate.getTime()), x+10, 590); 
 x-= (milsinday/milsperpixel);
 labelDate.add(Calendar.DAY_OF_MONTH, -1);
 }
 
 int milsinhalfday = milsinday/2; 
 int milsofhalfday = milsofday - (12*60*60*1000); 
 x = width - (milsofhalfday/milsperpixel); 
 p5.stroke(0, 50, 50); 
 while (x>0) { 
 p5.line(x, 0, x, 600);
 x-= (milsinday/milsperpixel);
 }
 
 int milsinhour = milsinday/24; 
 int milsofhour = milsofday - (23*60*60*1000); 
 x = width - (milsofhour/milsperpixel); 
 p5.stroke(0, 50, 50); 
 while (x>0) { 
 p5.line(x, 0, x, 600);
 x-= (milsinhour/milsperpixel);
 }
 
 
 p5.popStyle();
 }*/