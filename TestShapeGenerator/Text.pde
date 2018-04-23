
float glyphWidth, glyphHeight,glyphSpacing;

PVector letterOffset = new PVector(); 
PVector letterScale = new PVector(1, 1); 


void plotText(String textToPlot, float xpos, float ypos, float scaleFactor) { 


  glyphWidth = 4 * scaleFactor; 
  glyphHeight = 8 * scaleFactor; 
  glyphSpacing = 2.5 * scaleFactor;


  textToPlot = textToPlot.toUpperCase();
  for ( int i = 0; i < textToPlot.length(); i++ ) {
    drawGlyph(textToPlot.charAt(i), xpos, ypos);
    xpos += glyphWidth + glyphSpacing;
  }
}


void drawGlyph(char glyph, float posX, float posY) {

  letterOffset.set(posX, posY, 0); 
  letterScale.set(glyphWidth / 4.0, glyphHeight / 6.0, 0);
  drawLetter(glyph);
}

void drawLetter(char letter) {

  if ( letter == 'A' ) {
    plotLetterLine(0, 6, 0, 1);
    plotLetterLine(0, 1, 2, 0);
    plotLetterLine(2, 0, 4, 1);
    plotLetterLine(4, 1, 4, 6);
    plotLetterLine(4, 3, 0, 3);
  }

  if ( letter == 'B' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 3, 6);
    plotLetterLine(3, 6, 4, 5);
    plotLetterLine(4, 5, 4, 4);
    plotLetterLine(4, 4, 3, 3);
    plotLetterLine(3, 3, 0, 3);
    plotLetterLine(0, 3, 3, 3);
    plotLetterLine(3, 3, 4, 2);
    plotLetterLine(4, 2, 4, 1);
    plotLetterLine(4, 1, 3, 0);
    plotLetterLine(3, 0, 0, 0);

    
  }
  if ( letter == 'C' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == 'D' ) {
    plotLetterLine(0, 0, 3, 0);
    plotLetterLine(3, 0, 4, 2);
    plotLetterLine(4, 2, 4, 4);
    plotLetterLine(4, 4, 3, 6);
    plotLetterLine(3, 6, 0, 6);
    plotLetterLine(0, 6, 0, 0);
  }
  if ( letter == 'E' ) {

    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 3, 0, 3);
  }
  if ( letter == 'F' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 3, 4, 3);
  }
  if ( letter == 'G' ) {
    plotLetterLine(4, 1, 4, 0);
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 6, 4, 3);
    plotLetterLine(4, 3, 2, 3);
  }
  if ( letter == 'H' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == 'I' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(2, 0, 2, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == 'J' ) {
    plotLetterLine(0, 4, 1, 6);
    plotLetterLine(1, 6, 4, 6);
    plotLetterLine(4, 6, 4, 0);
    plotLetterLine(4, 0, 2, 0);
  }
  if ( letter == 'K' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 3, 4, 0);
    plotLetterLine(0, 3, 4, 6);
  }
  if ( letter == 'L' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == 'M' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 2, 2);
    plotLetterLine(2, 2, 4, 0);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == 'N' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 0, 1);
    plotLetterLine(0, 1, 4, 5);
    plotLetterLine(4, 5, 4, 6);
    plotLetterLine( 4, 6, 4, 0);
  }
  if ( letter == 'O' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
    plotLetterLine(4, 6, 0, 6);
    plotLetterLine(0, 6, 0, 0);
  }
  if ( letter == 'P' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 0, 3);
  }
  if ( letter == 'Q' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 4);
    plotLetterLine(4, 4, 2, 6);
    plotLetterLine(2, 6, 0, 6);
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(2, 4, 4, 6);
  }
  if ( letter == 'R' ) {
    plotLetterLine(0, 6, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 4, 6);
  }
  if ( letter == 'S' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 3);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 3, 4, 6);
    plotLetterLine(4, 6, 0, 6);
  }
  if ( letter == 'T' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(2, 0, 2, 6);
  }
  if ( letter == 'U' ) {
    plotLetterLine(0, 0, 0, 5);
    plotLetterLine(0, 5, 1, 6);
    plotLetterLine(1, 6, 3, 6);
    plotLetterLine(3, 6, 4, 5);
    plotLetterLine(4, 5, 4, 0);
  }
  if ( letter == 'V' ) {
    plotLetterLine(0, 0, 2, 6);
    plotLetterLine(2, 6, 4, 0);
  }
  if ( letter == 'W' ) {
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 2, 4);
    plotLetterLine(2, 4, 4, 6);
    plotLetterLine(4, 6, 4, 0);
  }
  if ( letter == 'X' ) {
    plotLetterLine(0, 0, 2, 3);
    plotLetterLine(2, 3, 0, 6);
    plotLetterLine(4, 0, 2, 3);
    plotLetterLine(2, 3, 4, 6);
  }
  if ( letter == 'Y' ) {
    plotLetterLine(0, 0, 2, 2);
    plotLetterLine(2, 2, 4, 0);
    plotLetterLine(2, 2, 2, 6);
  }
  if ( letter == 'Z' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == '0' ) {
    plotLetterLine(0, 6, 4, 0);
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 6, 4, 0);
  }
  if ( letter == '1' ) {
    plotLetterLine(0, 0, 2, 0);
    plotLetterLine(2, 0, 2, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == '2' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 0, 6);
    plotLetterLine(0, 6, 4, 6);
  }
  if ( letter == '3' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
    plotLetterLine(4, 6, 0, 6);
    plotLetterLine(0, 3, 4, 3);
  }
  if ( letter == '4' ) {
    plotLetterLine(0, 0, 0, 3);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == '5' ) {
    //plotLetterLine(0, 0, 0, 0);

    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 3);
    plotLetterLine(0, 3, 4, 3);
    plotLetterLine(4, 3, 4, 6);
    plotLetterLine(4, 6, 0, 6);
  }
  if ( letter == '6' ) {
    plotLetterLine(4, 0, 0, 0);
    plotLetterLine(0, 0, 0, 6);
    plotLetterLine(0, 6, 4, 6);
    plotLetterLine(4, 6, 4, 3);
    plotLetterLine(4, 3, 0, 3 );
  }
  if ( letter == '7' ) {
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == '8' ) {
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 3);
    plotLetterLine(4, 3, 4, 6);
    plotLetterLine(4, 6, 0, 6);
    plotLetterLine(0, 6, 0, 3);
  }
  if ( letter == '9' ) {
    plotLetterLine(4, 3, 0, 3);
    plotLetterLine(0, 3, 0, 0);
    plotLetterLine(0, 0, 4, 0);
    plotLetterLine(4, 0, 4, 6);
  }
  if ( letter == '!' ) {
    plotLetterLine(2, 0, 2, 4);
    plotLetterLine(2, 5, 2, 6);
  }
  if ( letter == ':' ) {
    plotLetterLine(2, 1.5, 2, 2.5);
    plotLetterLine(2, 4.5, 2, 5.5);
  }
  if ( letter == '.' ) {
    plotLetterLine(2, 5, 2, 6);
  }
  if ( letter ==',') {
    plotLetterLine(2, 5, 2, 7);
  }
  if (letter == '#') {
    plotLetterLine(1, 1, 1, 5);
    plotLetterLine(0, 2, 4, 2);
    plotLetterLine(0, 4, 4, 4);
    plotLetterLine(3, 1, 3, 5);
  }
  if (letter =='-') {
    plotLetterLine(1, 3, 3, 3);
  }
  if (letter =='_') {
    plotLetterLine(0, 6, 4, 6);
  }

  if (letter == '/') {
    plotLetterLine(0, 6, 4, 0);
  }
  if (letter == '%') {
    plotLetterLine(0, 6, 4, 0);
    plotLetterLine(0,0,0,1); 
    plotLetterLine(5,5,5,6); 
  }
  endShape();
}

void plotLetterLine(float x1, float y1, float x2, float y2) { 
  //line(x1*letterScale.x + letterOffset.x, y1*letterScale.y + letterOffset.y, x2*letterScale.x + letterOffset.x, y2*letterScale.y + letterOffset.y) ; 

  PVector p1 = new PVector(x1*letterScale.x + letterOffset.x -y1*letterScale.y*0.2 , y1*letterScale.y + letterOffset.y); 
  PVector p2 = new PVector(x2*letterScale.x + letterOffset.x -y2*letterScale.y*0.2, y2*letterScale.y + letterOffset.y); 

  plotter.plotLine(p1.x, p1.y, p2.x, p2.y);
  

  //letterPoint.set(p2);
}