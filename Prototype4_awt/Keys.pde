

Boolean controlPressed = false; 
void keyPressed() { 
  key = (""+key).toUpperCase().charAt(0);
  println(key);
  if (key == 'H') {
    println("INIT"); 
    hpglManager.initHPGL();
  } else if (key == 'P') {
    println("PRINT"); 
    hpglManager.setVelocity(200);
    hpglManager.startPrinting();
  } else if (key == 'C') {
    shapenum = 0;
    for (Shape shape : shapes) {
      fillContour(shape, (shapenum%7)+2, penThickness, false);
      shapenum++;
    }
  } else if (key == 'S') {
    makeShapes(); 
  } else if (key == '=') {
  } else if (key =='w') {
  } else if (keyCode == RIGHT) {
  } else if (keyCode == LEFT) {
  } else if (keyCode == UP) {
  } else if (keyCode == DOWN) {
  } else if (key=='l') {
  }
}