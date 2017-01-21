

ColourChooser colourChooser; 
float y = 10; 
void setup () { 

  size(800, 800); 

  colourChooser = new ColourChooser(this); 


  //for(int i = 0; i<colours.length; i++) { 
  // println(brightness(colours[i]), saturation(colours[i]));  

  //}

  noSmooth();

  //noLoop();
  //colourChooser.addPens(24);
    background(250);
}


void draw() { 

  
  
}

void mousePressed() { 
  
  if (colourChooser.pensAvailable()) { 
    ArrayList<Integer> chosencolours = colourChooser.getNextSelection(); 
    
    PApplet p5 = this; 
    
    p5.strokeWeight(21); 
    
    p5.strokeCap(p5.SQUARE);
    //if(cancelled) break;
    for (int i = 0; i<chosencolours.size(); i++) { 

      float x = (i*28)+200;
      p5.strokeWeight(25); 
      p5.stroke(0);
      p5.line(x, y-2, x, y+9);
      p5.strokeWeight(21); 
      p5.stroke(colourChooser.getColour(chosencolours.get(i)));

      p5.line(x, y, x, y+7);
    }
    p5.strokeWeight(10);
    for (int i = 0; i<colourChooser.colours.length; i++) { 
      if(!chosencolours.contains(i)) continue; 

      p5.stroke(colourChooser.getColour(i));

     float x = (i*15)+10;
     p5.line(x, y, x, y+7);
     
    }
    
    
     y+= 10;
  }
  printArray(colourChooser.pensRemainingByColour);
}

void keyPressed() { 
  colourChooser.addPens(24);
}