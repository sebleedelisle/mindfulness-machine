import java.awt.geom.Area;
import java.awt.Shape;
import java.awt.geom.Path2D;
import java.awt.geom.Line2D; 
import java.awt.geom.Point2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;
import java.awt.Polygon;
import java.awt.geom.PathIterator;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.AffineTransform; 

import java.util.List;
import java.util.Collections;


boolean TEST_SHAPES = false;  
ArrayList<Integer> usedPens;

Area frame;

//float genseed = 5; 
int generationCount = 0; 
void makeShapes() {
  //makeShapes(generationCount%2, generationCount, 0, 0);
  makeShapes(0, generationCount, 0, 0, ((float)height*plotter.aspectRatio), height);

  generationCount++; 
  //if(generationCount%2==1) 
  //genseed+=1;//r10000;
}


void plotFrameAndName(float w, float h, float stim, float happy) {
  // remove the bits of shape that are outside of the rectangle

  float textScale = 1.7; 
  float spacing = 8; 

  String textLabel = "MINDFULNESS MACHINE "+currentDateString+" STIMULATION:"+round(stim*100)+"% HAPPINESS:"+round(happy*100)+"% MOOD:"+moodManager.getMoodDescription(happy, stim)+" #"+(drawingNumber+1000)+" SEB.LY";
  float textWidth = 6.5*textScale * (textLabel.length()) ;

  plotter.addVelocityCommand(1); 

  plotText(textLabel, w-textWidth, h-17, textScale); 
  plotter.addVelocityCommand(10); 

  RoundRectangle2D r = new RoundRectangle2D.Float(0, 0, w-0.5, h, 10, 10); 
  AffineTransform at = new AffineTransform();
  at.translate(w-textWidth - spacing, h-24); 
  at.shear(-0.18, 0); 

  // Area r2 = new Area(new Rectangle2D.Float(w-textWidth - spacing, h-24, textWidth+spacing*2, 30)); 
  Area r2 = new Area(new Rectangle2D.Float(0, 0, textWidth+spacing*2, 30)); 
  r2.transform(at);
  frame = new Area(r); 
  frame.subtract(new Area(r2));
  outlineContour(frame, 7);
}



void makeShapes(int type, int seed, float happiness, float stim, float w, float h) {

  usedPens = getPensForMood(happiness, stim, seed); // new ArrayList<Integer>(); 

  randomSeed(seed); 
  noiseSeed(seed);
  println ("makeShapes = ", type, seed, happiness, stim); 

  if ((type==4) || (TEST_SHAPES)) 
    shapes = getTestShapes(w, h, happiness, stim, seed, usedPens);
  else if (type ==0)
    shapes = getLandscapeShapes(w, h, happiness, stim, false); // true is spiral
  else if (type == 1)
    shapes = getTruchetShapes(w, h, happiness, stim, usedPens);
  else if (type ==2)  
    shapes = getLandscapeShapes(w, h, happiness, stim, true);
  else if (type ==3) 
    shapes = getSpiralShapes(w, h, happiness, stim);     





  for (int i=0; i<shapes.size(); i++) { 
    //if (happiness<0.05) { 
    // then distribution is random
    //  shapes.get(i).setPenNumber(usedPens.get(floor(random(0, usedPens.size()))));
    // } else { 
    // distribution is even
    shapes.get(i).setPenNumber(usedPens.get(i%usedPens.size()));
    // }
  }


  removeOverlapsUsingShapeData(shapes);
  plotter.clear();
  plotter.selectPen(7); 
  plotFrameAndName(w, h, stim, happiness);
  // remove the bits of shape that are outside of the rectangle

  for (int i = 0; i<shapes.size(); i++) {
    ShapeData sd = shapes.get(i); 
    Shape s = sd.getShape(); 
    Area a; 
    if (! (s instanceof Area)) { 
      a = new Area(s);
      sd.setShape(a);
    } else { 
      a = (Area)s;
    }
    a.intersect(frame);
  }

  Collections.reverse(shapes);

  // not sure we should do this here...
}

float mapConstrain(float v, float min1, float max1, float min2, float max2) { 
  float r = map(v, min1, max1, min2, max2); 
  if (min2<=max2) { 
    r = constrain(r, min2, max2);
  } else { 
    r = constrain(r, max2, min2);
  }
  return r;
}
int mapConstrainRound(float v, float min1, float max1, float min2, float max2) { 
  return round(mapConstrain(v, min1, max1, min2, max2));
}
int mapConstrainFloor(float v, float min1, float max1, float min2, float max2) { 
  return floor(mapConstrain(v, min1, max1, min2, max2));
}
ArrayList<Integer> getPensForMood(float happy, float stim, int seed) {

  ArrayList<Integer> pens = new ArrayList<Integer>(); 

  randomSeed(millis()); // TODO TAKE THIS OUT!

  if (happy<0.5) { 
    // sad and lethargic
    // chose 2 - 3 pens dependent on happiness
    int numdarkpens = mapConstrainFloor(stim, 0, 0.5, 1, 3.9); 
    int firstpen=mapConstrainFloor(happy, 0, 0.5, 0, 2.9);



    pens.add(firstpen); 

    if (numdarkpens>1) {
      pens.add(firstpen+1);
    }
    if (numdarkpens>2) { 
      if (firstpen>0) pens.add(firstpen-1); 
      else pens.add(7);
    }

    if (stim<0.5) { 

      // if we're unstimulated 
      // system for adding a colour less frequently used
      if (numdarkpens < 3) { 
        // then add a secondary colour
        // num to add is a decimal from 0 to 0.9
        float numtoadd = mapConstrain(stim, 0, 0.5, 1, 3.9)%1;

        //   // the lower it is the less of the secondary colour we add
        int newpentooldratio = mapConstrainFloor(numtoadd, 1, 0, 4.9, 1); 
        ArrayList<Integer> pensToAdd = new ArrayList<Integer>(); 
        int newpen = firstpen-1; 
        if (newpen<0) newpen = 7; 
        for (int i = 0; i<newpentooldratio; i++) { 
          pensToAdd.add(newpen); 
          pensToAdd.addAll(pens);
        }
        pens.addAll(pensToAdd);
      }
    } else { 
      // sad and jittery 
      // add some higher contrast colours
      int numlightpens = mapConstrainFloor(happy, 0, 0.5, 1, 2.9); 
      if (numlightpens>0) { 
        int firstlightpen=mapConstrainFloor(stim, 0.5, 1, 4, 6.9);
        ArrayList<Integer> pensToAdd = new ArrayList<Integer>(); 
        pensToAdd.add(firstlightpen); 
        pensToAdd.addAll(pens); 
        if (numlightpens>1) { 
          pensToAdd.add(firstlightpen-1);
        } 
        //if (numlightpens>2) { 
        //  pensToAdd.add(firstlightpen-2);
        //  pensToAdd.addAll(pens);
        //} 
        pens.addAll(pensToAdd);
      }
    }
  } else {
    // if we're happy! 
    // TODO if we're stimulated, spread the colours before using them all

    int numpens = mapConstrainFloor(stim, 0, 1, 2, 7.9); 
    int centerpen = mapConstrainFloor(happy, 0.5, 1, 3, 6.9); 
    pens.add(centerpen); 
    int count = 1;
    while (pens.size()<numpens) { 
      int penNum; 
      if (count%2==1) { 
        penNum = centerpen+(ceil((float)count/2f));
      } else { 
        penNum = centerpen-(ceil((float)count/2f));
      }   
      if ((penNum>=0) && (penNum<=6) && (!pens.contains(penNum))) pens.add(penNum); 
      count++;
    }
  }
  return pens; 

  //  int numPensUsed = round(map(stim, 0, 1, 1, 5)); 
  //  int centrePen = constrain(round(map(happiness, 0, 1, 0, 6.4)+random(-1, 1)), 0, 6); 
  //  int centreOffset =  round(random(-1.4, 1.4));
  //  println("centrePen : "+centrePen+ " number of pens : " + numPensUsed); 
  //  int count = 1;

  //  usedPens.add(centrePen); 

  //  while (usedPens.size()<numPensUsed) { 
  //    int penNum; 
  //    if (count%2==1) { 
  //      penNum = centrePen+(ceil((float)count/2f));
  //    } else { 
  //      penNum = centrePen-(ceil((float)count/2f));
  //    }   
  //    if ((penNum>=0) && (penNum<=6) && (!usedPens.contains(penNum))) usedPens.add(penNum); 
  //    count++;
  //  }

  //  if (usedPens.size()==1) { 
  //    usedPens.add(centrePen); 
  //    if (happiness<0.3) usedPens.add(7); 
  //    else if (centrePen>=1) usedPens.add(centrePen-1);
  //  }

  //  // if we're not too stimulated then let's sort the colours
  //  if (stim<0.8) { 
  //    Collections.sort(usedPens);
  //  }
  //  printArray(usedPens);
}

// yeah yeah I know that shapeDatas is a weird plural for the ShapeData object
void removeOverlapsUsingShapeData(List<ShapeData> shapeDatas) { 
  ArrayList<Shape> shapes = new ArrayList<Shape>(); 
  for (ShapeData sd : shapeDatas) { 
    shapes.add(sd.getShape());
  }
  removeOverlaps(shapes); 
  // pretty nasty - assumes both lists are same length (which they should be)
  for (int i = 0; i<shapes.size(); i++) { 
    if (shapeDatas.size()<=i) { 
      println("ERROR - shapeDatas size doesn't match shapes size...") ;
    }
    shapeDatas.get(i).setShape(shapes.get(i));
  }
}

List<ShapeData> getSpiralShapes(float width, float height, float happiness, float stim) {
  List<ShapeData> shapes = new ArrayList<ShapeData>(); 

  println("getSpiralShapes " + stim + " " + happiness);

  JSONObject json = new JSONObject(); 
  // rotation spiral
  // shapeTypes : 
  // 0 : Circle
  // 1 : Square
  // 2 : Polygon with 5 to 10 sides
  // 3 : Star
  int shapeType = (int)random(4); 
  json.setInt("shapeType", shapeType); 

  float c = 20;

  float maxsize = random(20, 120);
  float minsize = maxsize*random(0.5, 1.2);
  json.setFloat("maxSize", maxsize); 
  json.setFloat("minSize", minsize);

  int numshapes = 2200; 
  float shaperotation = 1; 


  float rnd = random(1); 
  float rnd2 = random(0, 3); 
  // if it's square then add random shape rotation 
  if (shapeType==2) {
    if (rnd<0.3) shaperotation = 0;
    else if (rnd<0.66) shaperotation = 1; 
    else shaperotation = rnd2;
  }

  float rotation = radians(137.5); 
  //do we use standard Phillotaxis rotation ?  
  // if unhappy then more likely to deviate
  rnd = random(1); 
  rnd2 = random(5, 180); 
  if (rnd>happiness) rotation = radians(rnd2); 
  // reverse the spin
  if (random(1)<0.5) rotation*=-1; 

  json.setFloat("rotation", rotation); 
  json.setFloat("rotationDegrees", degrees(rotation)); 
  json.setFloat("shapeRotation", shaperotation); 

  // for types 2 and 3
  int numsides = floor(random(3, 6)); 
  json.setInt("numSides", numsides);


  // width/height for circles and rectangles
  float aspect = 1;
  rnd = random(1); 
  if (shapeType<2) { 
    aspect = rnd; 
    if (aspect>0.5) aspect = 1; 
    else aspect = map(aspect, 0, 0.5, 0.75, 1);
  }
  json.setFloat("aspect", aspect); 

  float noiseLevel = 0;//

  // figure out noiselevel dependent on mood. 
  // if unhappy then stimulation creates chaos
  // if happy then stimulation creates detail? 

  if (happiness<0.5) {
    float happyeffector =(0.5-happiness)*2; // happyeffector now between 0 and 1 for least happy 
    float stimeffector = stim; //  between 0 and 1 

    noiseLevel = stimeffector*happyeffector; // between 0 and 1
  }

  json.setFloat("noiseLevel", noiseLevel); 

  float noiseFrequency = 0;
  noiseFrequency = random(1)+(stim*2); 
  if (noiseLevel == 0) noiseFrequency = 0; 

  json.setFloat("noiseFrequency", noiseFrequency); 
  rnd = random(0.3); 
  // TODO - clamp ? 
  float starinnersize = map(stim+rnd, 0, 1.3, 0.6, 0.15); 


  for (int i = numshapes; i >=1; i--) {  

    float a = i * rotation;
    float r = c * sqrt(i);
    float x = r * cos(a) + (width/2);
    float y = r * sin(a) + (height/2);

    float size = constrain(map(i, 0, numshapes, maxsize, minsize), minsize, maxsize); 

    Shape s = new Rectangle2D.Double(); 

    float noiseAmount = (noise(i*noiseFrequency)*2-1) * noiseLevel; 

    switch(shapeType) { 
    case 0 : // Circle
      size*=map(noiseAmount, -1, 1, 0.0, 1.5); 
      s = new Ellipse2D.Double(-size/2/aspect, (-size/2)*aspect, size/aspect, size*aspect);  
      break;

    case 1 : // square
      size*=map(noiseAmount, -1, 1, 0.1, 1.8); 
      s = new Rectangle2D.Double(-size/2/aspect, -size/2*aspect, size/aspect, size*aspect);  
      break; 

    case 2 : // poly
      size*=map(noiseAmount, -1, 1, 0.0, 1.5); 
      s = createPolygon(0, 0, numsides, size);
      break ; 

    case 3 : 
      size*=map(noiseAmount, -1, 1, 0.1, 1.8); 
      //s = createStar(0, 0, numsides, size, size*random(0.3, 0.9)); 
      s = createStar(0, 0, numsides, size, size*starinnersize);//;//map(cos(i*0.1), 1, -1, 0.3, 0.9)); 
      break;
    } 

    Area area = new Area(s); 
    AffineTransform at = new AffineTransform(); 
    at.translate(x, y);
    at.rotate(a*shaperotation); 

    area.transform(at);
    shapes.add(new ShapeData(area));
  }
  println(json);

  //removeOverlaps(shapes);
  return shapes;
}


List<ShapeData> getLandscapeShapes(float width, float height, float happiness, float stim, boolean spiral) {
  List<ShapeData> shapes = new ArrayList<ShapeData>(); 

  JSONObject json = new JSONObject(); 

  float spacing = 10;//random(10, 20); 
  float wavescale = random(5, 100); 
  random(5, 50); 
  float wavelength = random(0.1, 2);//random(0.1, 5); 
  float shift = random(-2, 2);//random(-5, 5); 
  //float noisedetail = random(1);
  // noisedetail*=noisedetail*noisedetail; 

  //float noisescale = constrain(random(-50, 50), 0, 50);

  float noiseLevel = random(0, 0.03);//
  if (noiseLevel<0.015) noiseLevel = 0;

  // figure out noiselevel dependent on mood. 
  // if unhappy then stimulation creates chaos
  // if happy then stimulation creates detail? 

  if (happiness<0.5) {
    float happyeffector =(0.5-happiness)*2; // happyeffector now between 0 and 1 for least happy 
    float stimeffector = stim; //  between 0 and 1 

    noiseLevel = stimeffector*happyeffector; // between 0 and 1
  }
  noiseLevel*=200; //50 

  json.setFloat("noiseLevel", noiseLevel); 

  float noiseFrequency = 0;
  noiseFrequency = random(1)+(stim*2); 
  if (noiseLevel == 0) noiseFrequency = 0; 

  json.setFloat("noiseFrequency", noiseFrequency); 



  float resolution = 10;//random(10, 40); 

  json.setFloat("spacing", spacing); 
  json.setFloat("waveScale", wavescale); 
  json.setFloat("waveLength", wavelength); 
  json.setFloat("shift", shift); 

  boolean linear = !spiral; //random(1)<0.5; 

  if (linear) { 
    // linear
    for (float y = -wavescale-noiseLevel; y<height+wavescale+noiseLevel; y+=spacing) { 
      Path2D s = new Path2D.Float();
      s.moveTo(0, height); 
      for (float x = 0; x<=width+resolution; x+=resolution) { 
        float offsetx = 0;//sin(radians(x))*5; 
        float offsety = sin(radians(x+(y*shift))*wavelength)*wavescale; 
        offsety += noise(x*noiseFrequency, y*noiseFrequency)*noiseLevel;
        s.lineTo(x+offsetx, y+offsety);
      }
      s.lineTo(width, height); 
      shapes.add(new ShapeData(s));
    }
  } else {
    // circular
    wavelength = ceil(wavelength);
    //spacing*=0.7; 
    wavescale*=0.3; 
    resolution = 2; 
    float noisescale = noiseLevel*3;
    float changerate = random(0.001, 0.1); // amount of change of noise between layers 

    float extent = dist(0, 0, width/2, height/2)+wavescale+noisescale; 
    for (float r = extent; r>=0; r-=spacing) { 
      resolution = map(r, 0, extent, 5, 1); 
      int iterations = floor(360/resolution); 
      resolution = 360/iterations; 

      Path2D s = new Path2D.Float();
      for (float a = 0; a<360; a+=resolution) { 

        float offsetr = sin(radians(a+(r*shift))*wavelength)*wavescale; 
        offsetr += noise(sin(a)*noiseFrequency*100, r*changerate)*noisescale*map(r/extent, 0, 1, 0.3, 1);
        float x = width/2 + cos(radians(a))*(r+offsetr); 
        float y = height/2 + sin(radians(a))*(r+offsetr);
        if (a==0) { 
          s.moveTo(x, y);
        } else { 
          s.lineTo(x, y);
        }
      }
      s.closePath();
      shapes.add(new ShapeData(s));
    }
  }

  //removeOverlaps(shapes);
  println(json);
  return shapes;
}



List<ShapeData> getTruchetShapes(float width, float height, float happiness, float stim, ArrayList<Integer> usedPens) {
  ArrayList<ArrayList<Area>> shapesByColour = new ArrayList<ArrayList<Area>>(); 
  int numColours = usedPens.size();
  for (int i = 0; i<numColours; i++ ) { 
    shapesByColour.add(new ArrayList<Area>());
  }
  //List<Area> shapes1 = new ArrayList<Area>(); 
  //List<Area> shapes2 = new ArrayList<Area>(); 



  float size = 50;//random(20, 40);

  for (int i = 0; i<200; i++) random(2); 
  float shapeTypeF = random(0, 2); 
  int shapeType = floor(shapeTypeF); 
  println("Truchet Shapes type : ", shapeTypeF, shapeType); 
  if (shapeType ==0) size*=0.8;

  int colcount = floor(width/size);
  int rowcount = ceil(height/size); 
  size = width/colcount; 

  int numshapes = rowcount*colcount; 

  for (int i = 0; i<numshapes; i++) {
    float x = (i%colcount)*size; 
    float y = floor(i/colcount)*size; 
    Path2D.Float s1 = new Path2D.Float();
    Path2D.Float s2 = new Path2D.Float();

    if (shapeType ==0) { 

      Point2D.Float p1 = new Point2D.Float(x, y); 
      Point2D.Float p2 = new Point2D.Float(x+size+0.1, y); 
      Point2D.Float p3 = new Point2D.Float(x, y+size+0.1); 
      Point2D.Float p4 = new Point2D.Float(x+size+0.1, y+size+0.1); 

      if (random(1)<0.5) { 
        s1.moveTo(p1.x, p1.y);
        s1.lineTo(p2.x, p2.y); 
        s1.lineTo(p4.x, p4.y); 
        s1.closePath(); 
        s2.moveTo(p1.x, p1.y); 
        s2.lineTo(p4.x, p4.y); 
        s2.lineTo(p3.x, p3.y); 
        s2.closePath();
      } else { 
        s1.moveTo(p1.x, p1.y);
        s1.lineTo(p2.x, p2.y); 
        s1.lineTo(p3.x, p3.y); 
        s1.closePath(); 
        s2.moveTo(p2.x, p2.y); 
        s2.lineTo(p4.x, p4.y); 
        s2.lineTo(p3.x, p3.y); 
        s2.closePath();
      }
      Area a1 = new Area(s1); 
      Area a2 = new Area(s2); 


      int colourindex1 = floor(random(0, numColours)); 
      int colourindex2 = colourindex1; 
      while (colourindex2==colourindex1) colourindex2 = floor(random(0, numColours)); 

      shapesByColour.get(colourindex1).add(a1);
      shapesByColour.get(colourindex2).add(a2);
    } else if (shapeType ==1) { 
      float halfsize = size/2; 
      s1.moveTo(0, 0);
      s1.lineTo(halfsize, 0); 
      s1.lineTo(0, halfsize); 
      s1.closePath(); 

      s1.moveTo(size, size);
      s1.lineTo(halfsize, size); 
      s1.lineTo(size, halfsize); 
      s1.closePath(); 

      s2.moveTo(halfsize, 0); 
      s2.lineTo(size, 0); 
      s2.lineTo(size, halfsize); 
      s2.lineTo(halfsize, size); 
      s2.lineTo(0, size); 
      s2.lineTo(0, halfsize); 
      s2.closePath();

      //Area area = new Area(s); 
      AffineTransform at = new AffineTransform(); 

      at.translate(x, y);
      at.scale(1.0001, 1.0001);  
      if (random(1)<0.5) { 
        at.translate(size, 0);

        at.rotate(PI/2);
      }

      //at.scale(size+0.1/size, size+0.1/size);  


      Area a1 = new Area(s1); 
      Area a2 = new Area(s2); 
      a1.transform(at); 
      a2.transform(at); 


      int colourindex1 = floor(random(0, numColours)); 
      int colourindex2 = colourindex1; 
      while (colourindex2==colourindex1) colourindex2 = floor(random(0, numColours)); 

      shapesByColour.get(colourindex1).add(a1);
      shapesByColour.get(colourindex2).add(a2);
    }
  }

  int start = millis();   

  ArrayList<ShapeData>shapedata = new ArrayList<ShapeData>(); 

  for (int i = 0; i<shapesByColour.size(); i++) { 
    ArrayList<Area> areas = shapesByColour.get(i); 
    Area firstShape = areas.get(0); 
    for (int j =1; j<areas.size(); j++) {
      firstShape.add(areas.get(j));
    }
    ShapeData sd = new ShapeData(firstShape);
    sd.penNumber = usedPens.get(i); 
    shapedata.add(sd);
  }

  // now check to see if we already have 
  for (int i =0; i<shapedata.size(); i++) { 
    ShapeData s1=shapedata.get(i); 
    for (int j =i+1; j<shapedata.size(); j++) { 
      ShapeData s2=shapedata.get(j); 
      if (s1.penNumber==s2.penNumber) { 
        // merge them
        ((Area)(s1.shape)).add((Area)s2.shape); 
        // clear shape2
        s2.shape = new Area();
      }
    }
  }


  println("combining shapes took : " + (millis()-start)); 

  //ArrayList<Shape> shapes = new ArrayList<Shape>(); 

  //shapes.add(shapes1.get(0)); 
  //shapes.add(shapes2.get(0)); 
  //shapes.addAll(breakArea(shapes1.get(0))); 
  //shapes.addAll(breakArea(shapes2.get(0))); 

  //for (Shape shape : shapes) { 
  //  shapedata.add(new ShapeData(shape));
  //}
  return shapedata;
}




List<ShapeData> getTestShapes(float w, float h, float happiness, float stim, int seed, ArrayList<Integer>usedPens) {

  List<ShapeData> shapes = new ArrayList<ShapeData>(); 

  int cols = floor(w/330); 
  int rows = floor(h/30); 
  float x = (seed%cols)*330;
  float y = floor((float)seed/(float)cols) * 30;


  for (int i =0; i<usedPens.size(); i++) { 

    Shape s = new Rectangle2D.Double(x + (i*20), y, 20, 20);  
    shapes.add(new ShapeData(s));
  }
  return shapes;
}


public class ShapeData { 

  int penNumber; // penIndex for colour, 0 to 6 from dark to light
  boolean outlineDrawn;
  boolean colouredIn; 
  Shape shape; 

  public ShapeData(Shape _shape) { 
    this(_shape, 0);
  }
  public ShapeData(Shape _shape, int _pennumber) { 
    penNumber = _pennumber; 
    shape = _shape; 
    outlineDrawn = false;
    colouredIn = false;
  }
  public void setShape(Shape s) { 
    shape = s;
  }

  public Shape getShape() { 
    return shape;
  }
  public void setPenNumber(int num) { 
    penNumber = num;
  }
  public int getPenNumber() { 
    return penNumber;
  }
}