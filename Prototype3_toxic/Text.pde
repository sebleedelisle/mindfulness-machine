
float glyphWidth = 4, glyphHeight = 6, glyphSpacing = 2;

PVector letterOffset = new PVector(); 
PVector letterScale = new PVector(1, 1); 
//PVector letterPoint = new PVector(0, 0); 
boolean penUp = true; 
boolean sendToPlotter = false; 

void plotText(String textToPlot, float xpos, float ypos, float scaleFactor) { 
  plotText(textToPlot, xpos, ypos, scaleFactor, false);
}
void plotText(String textToPlot, float xpos, float ypos, float scaleFactor, boolean sendtoplotter) { 

  sendToPlotter = sendtoplotter; 

  glyphWidth = 4 * scaleFactor; 
  glyphHeight = 6 * scaleFactor; 
  glyphSpacing = 2 * scaleFactor;


  textToPlot = textToPlot.toUpperCase();
  for ( int i = 0; i < textToPlot.length(); i++ ) {
    drawGlyph(textToPlot.charAt(i), xpos, ypos);
    xpos += glyphWidth + glyphSpacing;
  }
}


void drawGlyph(char glyph, float posX, float posY) {

  letterOffset.set(posX, posY, 0); 


  //stroke(255);
  //strokeWeight(1);
  letterScale.set(glyphWidth / 4.0, glyphHeight / 6.0, 0);
  drawLetter(glyph);
}

void drawLetter(char letter) {
  penUp = true; 
  if ( letter == 'A' ) {
    plotLine(0, 6, 0, 1);
    plotLine(0, 1, 2, 0);
    plotLine(2, 0, 4, 1);
    plotLine(4, 1, 4, 6);
    plotLine(4, 3, 0, 3);
  }

  if ( letter == 'B' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 3, 6);
    plotLine(3, 6, 4, 5);
    plotLine(4, 5, 4, 4);
    plotLine(4, 4, 3, 3);
    plotLine(3, 3, 0, 3);
    plotLine(0, 3, 3, 3);
    plotLine(3, 3, 4, 2);
    plotLine(4, 2, 4, 1);
    plotLine(4, 1, 3, 0);
    plotLine(3, 0, 0, 0);

    
  }
  if ( letter == 'C' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == 'D' ) {
    plotLine(0, 0, 3, 0);
    plotLine(3, 0, 4, 2);
    plotLine(4, 2, 4, 4);
    plotLine(4, 4, 3, 6);
    plotLine(3, 6, 0, 6);
    plotLine(0, 6, 0, 0);
  }
  if ( letter == 'E' ) {

    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 3, 0, 3);
  }
  if ( letter == 'F' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 3, 4, 3);
  }
  if ( letter == 'G' ) {
    plotLine(4, 1, 4, 0);
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 6, 4, 3);
    plotLine(4, 3, 2, 3);
  }
  if ( letter == 'H' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 3, 4, 3);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == 'I' ) {
    plotLine(0, 0, 4, 0);
    plotLine(2, 0, 2, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == 'J' ) {
    plotLine(0, 4, 1, 6);
    plotLine(1, 6, 4, 6);
    plotLine(4, 6, 4, 0);
    plotLine(4, 0, 2, 0);
  }
  if ( letter == 'K' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 3, 4, 0);
    plotLine(0, 3, 4, 6);
  }
  if ( letter == 'L' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == 'M' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 2, 2);
    plotLine(2, 2, 4, 0);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == 'N' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 0, 1);
    plotLine(0, 1, 4, 5);
    plotLine(4, 5, 4, 6);
    plotLine( 4, 6, 4, 0);
  }
  if ( letter == 'O' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
    plotLine(4, 6, 0, 6);
    plotLine(0, 6, 0, 0);
  }
  if ( letter == 'P' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 0, 3);
  }
  if ( letter == 'Q' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 4);
    plotLine(4, 4, 2, 6);
    plotLine(2, 6, 0, 6);
    plotLine(0, 6, 0, 0);
    plotLine(2, 4, 4, 6);
  }
  if ( letter == 'R' ) {
    plotLine(0, 6, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 4, 6);
  }
  if ( letter == 'S' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 3);
    plotLine(0, 3, 4, 3);
    plotLine(4, 3, 4, 6);
    plotLine(4, 6, 0, 6);
  }
  if ( letter == 'T' ) {
    plotLine(0, 0, 4, 0);
    plotLine(2, 0, 2, 6);
  }
  if ( letter == 'U' ) {
    plotLine(0, 0, 0, 5);
    plotLine(0, 5, 1, 6);
    plotLine(1, 6, 3, 6);
    plotLine(3, 6, 4, 5);
    plotLine(4, 5, 4, 0);
  }
  if ( letter == 'V' ) {
    plotLine(0, 0, 2, 6);
    plotLine(2, 6, 4, 0);
  }
  if ( letter == 'W' ) {
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 2, 4);
    plotLine(2, 4, 4, 6);
    plotLine(4, 6, 4, 0);
  }
  if ( letter == 'X' ) {
    plotLine(0, 0, 2, 3);
    plotLine(2, 3, 0, 6);
    plotLine(4, 0, 2, 3);
    plotLine(2, 3, 4, 6);
  }
  if ( letter == 'Y' ) {
    plotLine(0, 0, 2, 2);
    plotLine(2, 2, 4, 0);
    plotLine(2, 2, 2, 6);
  }
  if ( letter == 'Z' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == '0' ) {
    plotLine(0, 6, 4, 0);
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 6, 4, 0);
  }
  if ( letter == '1' ) {
    plotLine(0, 0, 2, 0);
    plotLine(2, 0, 2, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == '2' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 0, 6);
    plotLine(0, 6, 4, 6);
  }
  if ( letter == '3' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
    plotLine(4, 6, 0, 6);
    plotLine(0, 3, 4, 3);
  }
  if ( letter == '4' ) {
    plotLine(0, 0, 0, 3);
    plotLine(0, 3, 4, 3);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == '5' ) {
    //plotLine(0, 0, 0, 0);

    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 3);
    plotLine(0, 3, 4, 3);
    plotLine(4, 3, 4, 6);
    plotLine(4, 6, 0, 6);
  }
  if ( letter == '6' ) {
    plotLine(4, 0, 0, 0);
    plotLine(0, 0, 0, 6);
    plotLine(0, 6, 4, 6);
    plotLine(4, 6, 4, 3);
    plotLine(4, 3, 0, 3 );
  }
  if ( letter == '7' ) {
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == '8' ) {
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 3);
    plotLine(4, 3, 4, 6);
    plotLine(4, 6, 0, 6);
    plotLine(0, 6, 0, 3);
  }
  if ( letter == '9' ) {
    plotLine(4, 3, 0, 3);
    plotLine(0, 3, 0, 0);
    plotLine(0, 0, 4, 0);
    plotLine(4, 0, 4, 6);
  }
  if ( letter == '!' ) {
    plotLine(2, 0, 2, 4);
    plotLine(2, 5, 2, 6);
  }
  if ( letter == ':' ) {
    plotLine(2, 1.5, 2, 2.5);
    plotLine(2, 4.5, 2, 5.5);
  }
  if ( letter == '.' ) {
    plotLine(2, 5, 2, 6);
  }
  if ( letter ==',') {
    plotLine(2, 5, 2, 7);
  }
  if (letter == '#') {
    plotLine(1, 1, 1, 5);
    plotLine(0, 2, 4, 2);
    plotLine(0, 4, 4, 4);
    plotLine(3, 1, 3, 5);
  }
  if (letter =='-') {
    plotLine(1, 3, 3, 3);
  }
  if (letter =='_') {
    plotLine(0, 6, 4, 6);
  }

  if (letter == '/') {
    plotLine(0, 6, 4, 0);
  }
  endShape();
}

void plotLine(float x1, float y1, float x2, float y2) { 
  //line(x1*letterScale.x + letterOffset.x, y1*letterScale.y + letterOffset.y, x2*letterScale.x + letterOffset.x, y2*letterScale.y + letterOffset.y) ; 

  PVector p1 = new PVector(x1*letterScale.x + letterOffset.x, y1*letterScale.y + letterOffset.y); 
  PVector p2 = new PVector(x2*letterScale.x + letterOffset.x, y2*letterScale.y + letterOffset.y); 

  if (sendToPlotter) { 
    hpglManager.plotLine(p1.x, p1.y, p2.x, p2.y);
  } else { 
    line(p1.x, p1.y, p2.x, p2.y);
  }


  //letterPoint.set(p2);
}