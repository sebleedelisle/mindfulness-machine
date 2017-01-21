

Boolean controlPressed = false; 
void keyPressed() { 
  //println(key); 
 
  
  println(keysPressedCount); 
  if(!keys[keyCode]) {
    keys[keyCode] = true;
    keysPressedCount ++;   
  }
  if (keyCode == CONTROL) { 
    controlPressed = true; 
    println("CONTROL PRESSED");
  }


  if (key == 'h') {
    println("INIT"); 
    hpglManager.initHPGL();
    hpglManager.setVelocity(1);
    //hpglManager.setOffset(0,-6); // for board
  } else if (key == 'p') {
    println("PRINT"); 

  hpglManager.startPrinting(); 
//
//    hpglManager.addPenCommand(1); 
//    warmUpPen(); 
//
//    hpglManager.addVelocityCommand(1); 
//
//
//
//    hpglManager.addPenCommand(2);
//    warmUpPen();
//    hpglManager.addVelocityCommand(1); 
//
//
//    hpglManager.addPenCommand(2);
//
//    hpglManager.addPenCommand(1);
//
//    hpglManager.addPenCommand(1);
//
//    hpglManager.addVelocityCommand(20); 
   
  } else if (key == 't') { 

  } else if (key == '-') { 


   // changeDataScale(0.98); 
    dirty = true;
  } else if (key == '=') { 
   // changeDataScale(1.02);
  } else if (key =='w') { 
    warmUpPen();
  } else if (keyCode == RIGHT) {    
  
  } else if (keyCode == LEFT) {     
 
  } else if (keyCode == UP) { 
 
  } else if (keyCode == DOWN) { 
 
  } else if (key=='l') { 
 
  }
  

  
 
  
}


void keyReleased() { 
  
  if(keys[keyCode]) keysPressedCount--; 
  
  //keys[keyCode] = false;
  if(keysPressedCount ==0) { 
    keys = new boolean[526];
  }
  
  println(keysPressedCount); 
  
  if (key == CODED) { 
    if (keyCode == CONTROL) { 
      controlPressed = false; 
      println("CONTROL RELEASED");
    }
  }
}


boolean isKeyPressed(int k)
{
  //println(keyEvent.getKeyCode()); 
  //for(int i = 0; i < keys.length; i++)
  //  if(KeyEvent.getKeyText(i).toLowerCase().equals(k.toLowerCase())) 
  
  return keys[k];  
    
  
  //return false;
}