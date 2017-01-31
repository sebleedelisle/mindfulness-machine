import java.util.Calendar;
import java.text.SimpleDateFormat; 

SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy kk:mm");
TestDate test;

int offsetDays = 0; 
void setup() { 
  size(800, 600);
  test = new TestDate(this); 
}


void draw() { 
  background(0);  
  test.update();
  
  text(str( test.days ), 10, 10);
  text(str( test.mils ), 10, 30);

  text(dateFormat.format(test.currentTime.getTime()), 10, 50);

}