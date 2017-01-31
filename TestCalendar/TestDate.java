import processing.core.*;
import java.util.Calendar;
public class TestDate { 

  public int days; 
  public int mils; 

  int timeSpeed = 1000000; 
  PApplet p5; 
  public Calendar startTime, currentTime; 

  public TestDate(PApplet processing) { 
    p5 = processing; 
    startTime = Calendar.getInstance();
  } 

  public void update() { 
    currentTime = (Calendar)startTime.clone();

    int milsinday = 1000*60*60*24;
    days = (int)(long)((long)p5.millis()*(long)timeSpeed/(long)milsinday); 

    mils = (int)(((long)p5.millis()*(long)timeSpeed)%milsinday); 

    currentTime.add(Calendar.DAY_OF_YEAR, days);
  }
}