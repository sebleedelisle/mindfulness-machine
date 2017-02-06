import processing.core.*; 


public class CommandRendererData { 

  PGraphics g; 
  PApplet p5; 
  float plotterToPixelsScale; 

  PVector penPos; 
  PenManager penManager; 

  int currentPen; 
  final int maxCommands = 1000; 

  PVector offsetPos; 


  ArrayList<Command> commands; 

  int viewWidth, viewHeight; 
  float plotWidth, plotHeight; 


  PVector start, end, v, pos, screenPenPos, target, diff;


  public CommandRendererData(PApplet processing, PenManager penmanager, int w, int h, float pixelToPlotterScale) {
    commands = new ArrayList<Command>(); 
    p5 = processing;
    penManager = penmanager; 

    start = new PVector(); 
    end = new PVector(); 
    v = new PVector(); 
    pos = new PVector(); 

    screenPenPos = new PVector(); 
    target = new PVector(); 
    diff = new PVector();


    plotterToPixelsScale = 1/pixelToPlotterScale * 3; 
    penPos = new PVector(0, 0); 
    offsetPos = new PVector(0, 0); 

    viewWidth = 1920-940;  
    viewHeight = 660; 


    plotWidth = w; 
    plotHeight = h; 

    g = p5.createGraphics(viewWidth, viewHeight); 

    clear();
  }

  public void clear() { 
    // clear stored commands
    commands.clear();
  }

  public void renderCommands(ArrayList<Command> commands) { 

    for (Command c : commands) renderCommand(c);
  }
  public void renderCommand(Command c) { 
    commands.add(c); 
    while (commands.size()>maxCommands) commands.remove(0);
  }

  public void renderCommandActual(Command c, int num) { 


    int size = commands.size(); 

    float weight = p5.constrain(p5.map(num, size-100, size, 1, 3), 1, 3) / plotterToPixelsScale;
    int brightness =255; 
    if (size>maxCommands-100) {
      int toprange = size-maxCommands+100; 
      brightness = (int)constrain(map(num, toprange-100, toprange, 0, 255), 0, 255);
    }
    g.stroke(0, brightness, 0); 
    g.strokeWeight(weight);

    if (c.c == Plotter.COMMAND_MOVETO) { 
      g.strokeWeight(1); 
      brightness = (int)constrain(map(num, commands.size()-100, commands.size(), 0, 255), 0, 255);
      g.stroke(0, brightness, 0); 
      if (num>2) drawDottedLine(penPos.x, penPos.y, c.p1, c.p2); 
      penPos.set(c.p1, c.p2);
    }  
    if (c.c == Plotter.COMMAND_LINETO) { 
      if (num>2) g.line(penPos.x, penPos.y, c.p1, c.p2); 
      penPos.set(c.p1, c.p2);
    } else if (c.c == Plotter.COMMAND_CIRCLE) { 

      g.ellipseMode(p5.RADIUS); 
      //float r = (float)c.p3/scalePixelsToPlotter; 
      g.ellipse(c.p1, c.p2, c.p3, c.p3); 
      //drawing = false;
    } else if (c.c == Plotter.COMMAND_PEN_CHANGE) { 
      if (c.p1>=0) {
      }
    }
  }


  public void drawDottedLine(float x1, float y1, float x2, float y2) { 

    float space = 5/plotterToPixelsScale;

    start.set(x1, y1); 
    end.set(x2, y2); 
    v.set(end); 
    v.sub(start); 
    float d = v.mag(); 
    g.beginShape(p5.POINTS); 
    for (float p=0; p<d; p+=space) { 
      pos.set(v); 
      pos.mult(p/d); 
      pos.add(start); 
      vertex(pos.x, pos.y);
    }
    g.endShape();
  }

  //  public void startDrawing() { 

  //  }
  //  public void endDrawing() { 
  //    //if (drawing) { 
  //    //  g.popMatrix();
  //    //  g.endDraw();
  //    //  drawing = false;
  //    //}
  //  }
  // add screenVertex command!
  public void screenVertex(int x, int y) { 
    g.vertex(x*plotterToPixelsScale, y*plotterToPixelsScale);
  }

  public void render() { 

    g.beginDraw();
    g.background(0);
    g.blendMode(p5.ADD); 

    // this whole system is in screen space!

    screenPenPos.x = penPos.x*plotterToPixelsScale; 
    screenPenPos.y= g.height-(penPos.y*plotterToPixelsScale); 

    target.set(offsetPos); 

    float padding = 150; 
    float top = offsetPos.y+padding; 
    float bottom = offsetPos.y+viewHeight-padding; 
    float left = offsetPos.x+padding; 
    float right = offsetPos.x+viewWidth-padding; 

    if (screenPenPos.x<left) target.x-=(left-screenPenPos.x); 
    else if (screenPenPos.x>right) target.x+=(screenPenPos.x-right); 
    if (screenPenPos.y<top) target.y-=(top-screenPenPos.y); 
    else if (screenPenPos.y>bottom) target.y+=(screenPenPos.y-bottom); 

    if (target.x<0) target.x = 0; 
    else if (target.x+viewWidth>(plotWidth*plotterToPixelsScale)) target.x = (plotWidth*plotterToPixelsScale)-viewWidth; 
    if (target.y-viewHeight<-(plotHeight*plotterToPixelsScale)) target.y = -(plotHeight*plotterToPixelsScale)+viewHeight; //target.y = 0; 
    else if (target.y>60) target.y = 60; 

    //p5.ellipse(screenPenPos.x, screenPenPos.y, 100,100); 
    diff.set(target); 
    diff.sub(offsetPos); 
    //if (diff.mag()<800) { 
    diff.mult(0.08);
    //} else { 
    //  diff.mult(0.3);
    //}
    offsetPos.add(diff); 


    // render last few commands
    g.pushMatrix(); 
    g.pushStyle(); 
    g.translate(-offsetPos.x, -offsetPos.y);
    g.translate(0, g.height); 

    g.scale(plotterToPixelsScale, -plotterToPixelsScale); 


    g.stroke(0, 80, 0); 
    g.strokeWeight(1);
    g.beginShape(p5.LINES); 
    for (float x = 0; x<plotWidth-1; x+=(plotWidth-1)/26) { 
      g.vertex(x, 0); 
      g.vertex(x, plotHeight);
    }
    for (float y = 0; y<plotHeight-1; y+=(plotHeight-1)/20) { 
      g.vertex(0, y); 
      g.vertex(plotWidth, y);
    }
    g.endShape(); 


    g.stroke(0, 255, 0); 

    //g.blendMode(p5.ADD);
    for (int i =0; i<commands.size(); i++) {
      Command c = commands.get(i);
      renderCommandActual(c, i);
    }

    g.strokeJoin(g.ROUND);
    g.strokeCap(g.ROUND);
    g.popStyle();
    g.popMatrix();
    g.endDraw(); 
    p5.pushStyle() ;
    p5.blendMode(p5.ADD); 
    p5.image(g, 0, 0);
    p5.popStyle();
  }
}