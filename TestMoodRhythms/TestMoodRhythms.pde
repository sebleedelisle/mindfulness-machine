

//Calendar c = Calendar.getInstance();
MoodManager moodManager; 
int offset = 0; 

void setup () { 

  size(1200, 600, P3D); 
  noSmooth();
  moodManager = new MoodManager(this); 
  //println(c.get(Calendar.MINUTE), Calendar.SATURDAY);
  //println(c.getTimeZone());


  //noLoop();
}


void draw() { 

  background(0); 

  moodManager.update(); 
  moodManager.draw();

}