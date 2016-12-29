

Boolean controlPressed = false; 
void keyPressed() { 

  println(key); 
  if (key == 'H') {
    println("INIT"); 
    hpglManager.initHPGL();
    hpglManager.setVelocity(40); 
  } else if (key == 'P') {
    println("PRINT"); 
   
      hpglManager.startPrinting();
  } else if (key == 'T') {
    isFindingCircles = !isFindingCircles;
  } else if (key == 'R') {
    circles = new ArrayList<Circle>();
  } else if (key == 'C') {
     printCircles();
  } else if (key == '=') {
  } else if (key =='w') {
  } else if (keyCode == RIGHT) {
  } else if (keyCode == LEFT) {
  } else if (keyCode == UP) {
  } else if (keyCode == DOWN) {
  } else if (key=='l') {
  }
}