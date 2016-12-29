import geomerative.*;

RShape shp1;
RShape shp2;
RShape shp3;
RShape cursorShape;

void setup()
{
  size(400, 400);
  smooth();

  RG.init(this);

  shp1 = new RShape();
  RG.beginShape(); 
  shp1.addMoveTo(0,0); 
  shp1.addLineTo(100,0); 
  shp1.addLineTo(100,100); 
  shp1.addLineTo(0,100); 
  shp1.addClose(); 
  
  RShape temp = new RShape();

  temp.addMoveTo(20,20); 
      println(temp.getPoints()==null);
  temp.addLineTo(80,20); 
      println(temp.getPoints()==null);
  temp.addLineTo(80,80); 
      println(temp.getPoints()==null);
  temp.addLineTo(20,80); 
  temp.addClose();

  shp1 = RG.diff( shp1, temp );
  

  shp1.addClose(); 
  shp2 = RShape.createStar(0, 0, 100.0, 80.0, 20);
}

void draw()
{
  background(255);    
  translate(width/2,height/2);

  cursorShape = new RShape(shp2);
  cursorShape.translate(mouseX - width/2, mouseY - height/2);
  
  // Only intersection() does not work for shapes with more than one path
  shp3 = RG.diff( shp1, cursorShape );
  
  strokeWeight( 1 );

  if(mousePressed){
    fill( 220 , 0 , 0 , 30 );
    stroke( 120 , 0 , 0 );
    RG.shape(cursorShape);

    fill( 0 , 220 , 0 , 30 );
    stroke( 0 , 120 , 0 );
    RG.shape(shp1);
  }
  else{
    fill( 220 );
    stroke( 120 );
    RG.shape(shp3);
  }
}