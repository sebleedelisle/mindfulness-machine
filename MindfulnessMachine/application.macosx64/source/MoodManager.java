
import processing.core.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Calendar;
import java.text.SimpleDateFormat; 

public class MoodManager {

  CameraManager cameraManager; 

  SensorReader sensorReader;

  DataPoint vbio; 

  DataPoint happiness; 
  DataPoint stimulation; 

  DataPoint vhorm; 
  DataPoint vcirc; 

  PApplet p5; 

  int timeSpeed = 1; 

  Calendar startTime, currentTime; 

  SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy kk:mm");
  SimpleDateFormat dayFormat = new SimpleDateFormat("E dd/MM/yy");

  int updateInterval = 100; // update every second/10. 
  int updateCount = 0; 
  int timeOffsetHours = 0; 

  int days, mils;

  public MoodManager(PApplet processing) {

    p5 = processing; 


    cameraManager = new CameraManager(p5); 

    sensorReader = new SensorReader(p5);

    startTime = Calendar.getInstance();

    vbio = new DataPoint("vbio", -1, 1);
    vhorm = new DataPoint("vhormones", -1, 1); 
    vcirc = new DataPoint("vcircadian", -1, 1);

    happiness = new DataPoint("happiness", 0, 1);
    stimulation = new DataPoint("stimulation", 0, 1);
    happiness.setUseHistoryAverage(3600); 
    stimulation.setUseHistoryAverage(3600); 
    happiness.showAsPercentage = true; 
    stimulation.showAsPercentage = true; 
    happiness.showTicks = stimulation.showTicks = true; 
    happiness.numTicks = stimulation.numTicks= 20; 
    
    cameraManager.motion.decimalPlaces = 1; 
    cameraManager.motion.setUseHistoryAverage(1000); 
    cameraManager.crowd.setUseHistoryAverage(1000); 

    vbio.smooth=1; 
    vhorm.smooth=1; 
    vcirc.smooth=1;
  }
  public String getCurrentDateString() { 
    if ((dateFormat!=null) && (currentTime!=null)) {
      return dateFormat.format(currentTime.getTime());
    } else {
      return "";
    }
  }
  public void update() { 

    cameraManager.update();
    sensorReader.update(getHappiness(), getStimulation());


    Calendar time = Calendar.getInstance(); 
    time.add(Calendar.HOUR, timeOffsetHours); 
    long elapsedMils = time.getTime().getTime() - startTime.getTime().getTime(); 

    int requiredUpdateCount = (int)(((long)elapsedMils*(long)timeSpeed)/(long)updateInterval); 

    while (requiredUpdateCount>updateCount) { 

      cameraManager.motion.update(); 
      cameraManager.crowd.update();

      currentTime = (Calendar)startTime.clone();

      int milsinday = 1000*60*60*24;
      //days = (int)((long)((long)elapsedMils*(long)timeSpeed)/milsinday); 
      days = (int)(long)((long)elapsedMils*(long)timeSpeed/(long)milsinday); 

      mils = (int)(((long)elapsedMils*(long)timeSpeed)%milsinday); 

      currentTime.add(Calendar.DAY_OF_YEAR, days);
      currentTime.add(Calendar.MILLISECOND, mils);


      vcirc.setValue(calculateDailyCircadian(currentTime)*1.15f);
      vhorm.setValue(calculateWeeklyCircadian(currentTime));
      // add a little noise to the happiness factor
      float noisevalue = ((p5.noise((float)elapsedMils*timeSpeed*0.0002f)-0.5f)*0.1f);
      vbio.setValue( vhorm.value + noisevalue);



      float happ;// = happiness.targetValue; 
      // eases towards vbio value based on virtual hormones and circadian rhythm
      happ = vbio.value;//-happ)*0.01;  
      // add colour temperature; 
      float colourtemp = sensorReader.temperature.value; 
      float lux = sensorReader.lux.value; 

      // need to log what's happening somewhere and check that those values have an impact
      // maybe store them as settings? 
      // TODO implement light into happiness
      //if ((lux>800) && (colourtemp>10000)) {
      //  // we're probably in daylight
      //  happ+=0.005f;
      //} else if (lux<500) { 
      //  // we're in the dark 
      //  happ-=0.005f;
      //}
      happiness.setValue(p5.map(happ, -1, 1,0,1)); 

      // TODO maybe don't update stimulation so frequently? 

      float stim = stimulation.targetValue; 
      //stim-=0.001f; // stimulation will always reduce unless more input happens
      float stimtarget = p5.map(cameraManager.motion.value, 0, 1000, 0, 1);
      stimtarget += p5.map(cameraManager.crowd.value, 0, 100, 0, 1.5f); 
      stimtarget-=1; // put it in -1 to +1 range
      stimtarget*=0.5; // now in -0.5 to +0.5 range

      stim = stimtarget+(p5.noise((float)(elapsedMils*0.001f))*4f-1.2f); 

      // if stimulation is rising then raise quickly... 
      //if (stim<stimtarget) stim = stimtarget; 
      // otherwise ease towards lower target
      //else stim+=(stimtarget-stim)*0.01; 

      stim = p5.constrain(stim, -1, 1);
      // TODO add temperature effect
      stimulation.setValue(p5.map(stim,-1,1,0,1));

      sensorReader.temperature.update(); 
      sensorReader.lux.update(); 
      sensorReader.colourTemperature.update(); 
      vhorm.update(); 
      vcirc.update(); 
      vbio.update();

      stimulation.update(); 
      happiness.update();

      updateCount++;
    }
  }

  public void skipTimeHours(int hours) { 
    timeOffsetHours+=hours; 
  }
  public void draw(PFont smallFont12, PFont bodyFont16) { 

    float dataheight = 384; 

    cameraManager.draw(16,16);  
    
    p5.fill(0,255,255); 
    p5.textSize(16); 
    p5.textFont(bodyFont16); 
    p5.textAlign(p5.CENTER, p5.CENTER); 
    p5.text("MOOD : "+getMoodDescription().toUpperCase(), 700+(384/2), 40);
    
    float barheight = 30; 
    float vspacing = 6; 
    float separator = 20; 
    float y = 80; 
    p5.textFont(smallFont12);
     
    happiness.drawHorizontal(p5, 700, y, 384, barheight); 
    y+=barheight+vspacing;
    stimulation.drawHorizontal(p5, 700, y, 384, barheight); 

    y+=barheight+separator; 
    barheight = 20; 
    y = cameraManager.drawData(700, y, 384, barheight, vspacing); 
    y+=separator; 
    y = sensorReader.drawData(700,y,384,barheight, vspacing);
    y+=separator; 
    
    vhorm.drawHorizontal(p5, 700, y, 384, barheight); 
    vcirc.drawHorizontal(p5, 700, y+barheight+vspacing, 384, barheight); 
    
   // vbio.drawHorizontal(p5, 700, y+(barheight+vspacing)*2, 384, barheight);
    

  
    //stimulation.draw(p5, 1060, 0, 60, dataheight); 
    //happiness.draw(p5, 1140, 0, 60, dataheight);
    p5.fill(255);

    //int milsinday = 1000*60*60*24;
    //int days = (int)((long)((long)elapsedMils*(long)timeSpeed)/milsinday); 
    //int mils = (int)(((long)elapsedMils*(long)timeSpeed)%milsinday); 
    p5.textAlign(p5.LEFT); 
    p5.text(p5.str( days ), 10, 10);
    p5.text(p5.str( mils ), 10, 30);
    p5.text(dateFormat.format(currentTime.getTime()), 10, 50);

  }
  String getMoodDescription() { 
    return getMoodDescription(getHappiness(), getStimulation());
  }
  String getMoodDescription(float happiness, float stimulation) { 
    String[][] moods = { 
      {"Miserable", "Melancholy", "Stressed", "Panicking"}, // sad
      {"Lethargic", "Dissatisfied", "On edge", "Jittery" }, 
      {"Satisfied", "Calm", "Focussed", "Confident"},     
      {"Carefree", "Cheerful", "Engaged", "Ecstatic"}  // happy 
 
    };

    int happyIndex = mapConstrainFloor(happiness, 0, 1, 0, 3.99f); 
    int stimIndex = mapConstrainFloor(stimulation, 0, 1, 0, 3.99f); 
    return moods[happyIndex][stimIndex];
  }

  public void renderCamera(int x, int y, int w, int h) { 
    cameraManager.renderCamera(x, y, w, h);
  }

  // returns normalised value
  float getHappiness() {
    return happiness.getValue();//p5.map(happiness.getValue(), -1, 1, 0, 1);
  }

  float getStimulation() {

    return stimulation.getValue();//p5.map(stimulation.getValue(), -1, 1, 0, 1);
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

  float mapConstrain(float v, float min1, float max1, float min2, float max2) { 
    float r = p5.map(v, min1, max1, min2, max2); 
    if (min2<=max2) { 
      r = p5.constrain(r, min2, max2);
    } else { 
      r = p5.constrain(r, max2, min2);
    }
    return r;
  }
  int mapConstrainRound(float v, float min1, float max1, float min2, float max2) { 
    return p5.round(mapConstrain(v, min1, max1, min2, max2));
  }
  int mapConstrainFloor(float v, float min1, float max1, float min2, float max2) { 
    return p5.floor(mapConstrain(v, min1, max1, min2, max2));
  }
}