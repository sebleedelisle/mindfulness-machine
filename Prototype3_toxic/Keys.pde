

Boolean controlPressed = false; 
void keyPressed() { 


  if (key == 'H') {
    println("INIT"); 
    hpglManager.initHPGL();
  } else if (key == 'P') {
    println("PRINT"); 

    hpglManager.startPrinting();
  } else if (key == 't') {
  } else if (key == '-') {
  } else if (key == '=') {
  } else if (key =='w') {
  } else if (keyCode == RIGHT) {
  } else if (keyCode == LEFT) {
  } else if (keyCode == UP) {
  } else if (keyCode == DOWN) {
  } else if (key=='l') {
  }
}