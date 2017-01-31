import controlP5.*;

ControlP5 cp5;

int seedValue = 0; 
int shapeType = 0; 
float happy = 0.5; 
float stim = 0.5;
Slider seedSlider, typeSlider;

void initGui() { 

  cp5 = new ControlP5(this);  
  // label, min, max, value, x, y, w,h
  seedSlider = cp5.addSlider("s_seed")
    .setPosition(1600, 50)
    .setSize(250, 20)
    .setRange(0, 100)
    .setNumberOfTickMarks(101) 
    .showTickMarks(false)
    //.snapToTickMarks(true)
    .setValue(14);

  typeSlider = cp5.addSlider("s_type")
    .setPosition(1600, 80)
    .setSize(250, 20)
    .setRange(0, 4)
    .setNumberOfTickMarks(5) 
    .showTickMarks(false)
    .setValue(1);

  cp5.addSlider("s_happy")
    .setPosition(1600, 110)
    .setSize(250, 20)
    .setRange(0, 1)
    .setNumberOfTickMarks(101) 
    .showTickMarks(false)
    .setValue(0.5);
    
  cp5.addSlider("s_stim")
    .setPosition(1600, 140)
    .setSize(250, 20)
    .setRange(0, 1)
    .setNumberOfTickMarks(101) 
    .showTickMarks(false)
    .setValue(0.5);
}



public void controlEvent(ControlEvent theEvent) {
  //println("got a control event from controller with id "+theEvent.getId());
  println(theEvent);
  switch(theEvent.getName()) {
    case("s_seed"): 
    seedValue = issueNumber = (int)theEvent.getValue(); 
    break;

    case("s_type"):  
    shapeType = (int)theEvent.getValue();
    break;  

    case("s_happy"):  
    happy = theEvent.getValue(); 
    break;    

    case("s_stim"):  
    stim = theEvent.getValue(); 
    break;
  }
}