
import processing.core.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Calendar;
import java.text.SimpleDateFormat; 

public class MoodManager {
  // MoodManager
  // looks after relaxation and happiness values for the robot
  // stores history of data too
  // possibly reads and writes the history or at least current
  // values, in case of a restart

  // unit values for stimulation and happiness. 
  float stim; 
  float happy; 
  float stimVel; // current velocity for stimulation
  float happyVel; // current velocity for happiness; 

  // the history lists store values for every what... second? 
  // throughout time. 
  List<Float> stimHistory; 
  List<Float> happyHistory;
  
  PApplet p5; 

  float timeSpeed = 30000; 

  Calendar startTime, currentTime; 

  SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy kk:mm");
  SimpleDateFormat dayFormat = new SimpleDateFormat("E dd/MM/yy");


  int updateInterval = 1000*60; // update every minute. 
  int updateCount = 0; 
  public MoodManager(PApplet processing) {
    
    p5 = processing; 
    
    stim = 0.5f; 
    happy = 0.5f; 
    happyHistory = new ArrayList<Float>(); 
    stimHistory = new ArrayList<Float>(); 

    startTime = Calendar.getInstance();
    currentTime = Calendar.getInstance();
    // tell the robot that it woke up at 11am today - we only need that if we restart
    // or if we're testing
    //wakeUpTime.set(Calendar.HOUR_OF_DAY, 11);  
    //currentTime = Calendar.getInstance();
  }

  public void update() { 
    while (p5.millis()*timeSpeed/updateInterval>updateCount) { 
      // do update
      currentTime = (Calendar)startTime.clone();
      currentTime.add(Calendar.MILLISECOND, updateInterval*updateCount); 

      happy = (calculateDailyCircadian(currentTime)*0.2f) + (calculateWeeklyCircadian(currentTime)*0.8f); 
      happyHistory.add(happy); 
      if (happyHistory.size()>10000) happyHistory.remove(0);
      updateCount++;
    }
  }

  public void draw() { 

    float zoom = 0.5f; //p5.map(p5.mouseY, 0, 300, 0.2f,20); 

    p5.pushStyle(); 
    p5.blendMode(p5.ADD); 
    p5.fill(255); 
    p5.text(dateFormat.format(currentTime.getTime()), 10, 20);
    p5.noFill(); 
    p5.stroke(0, 255, 255); 
    int startIndex = (happyHistory.size()-(p5.round((float)p5.width/zoom)));
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
      
    float x = p5.width - (milsofday/milsperpixel); 
    p5.stroke(0, 100, 100); 
    
    while (x>0) { 
      p5.line(x, 0, x, 600);
      p5.text(dayFormat.format(labelDate.getTime()), x+10,590); 
      x-= (milsinday/milsperpixel);
      labelDate.add(Calendar.DAY_OF_MONTH,-1); 
    }

    int milsinhalfday = milsinday/2; 
    int milsofhalfday = milsofday - (12*60*60*1000); 
    x = p5.width - (milsofhalfday/milsperpixel); 
    p5.stroke(0, 50, 50); 
    while (x>0) { 
      p5.line(x, 0, x, 600);
      x-= (milsinday/milsperpixel);
    }

    int milsinhour = milsinday/24; 
    int milsofhour = milsofday - (23*60*60*1000); 
    x = p5.width - (milsofhour/milsperpixel); 
    p5.stroke(0, 50, 50); 
    while (x>0) { 
      p5.line(x, 0, x, 600);
      x-= (milsinhour/milsperpixel);
    }


    p5.popStyle();
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