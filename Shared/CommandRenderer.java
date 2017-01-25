import processing.core.*; 


public class CommandRenderer { 

  PGraphics g; 
  PApplet p5; 
  float plotterToPixelsScale; 
  boolean drawing; 
  PVector penPos; 
  PenManager penManager; 
  int paperColour; 
  int currentPen; 

  public CommandRenderer(PApplet processing, PenManager penmanager, int w, int h, float pixelToPlotterScale) {
    p5 = processing;
    penManager = penmanager; 
    g = p5.createGraphics(w*2, h*2);

    plotterToPixelsScale = 1/pixelToPlotterScale * 2; 
    penPos = new PVector(0, 0); 
    g.smooth();
    
    paperColour = p5.color(240,248,255); 
    
    clear();
  }

  public void clear() { 

    endDrawing(); 

    g.beginDraw(); 
    g.blendMode(g.BLEND);
    g.noFill(); 
    g.stroke(0); 
    g.strokeWeight(1);
    g.background(250); 
    g.rect(0, 0, g.width-1, g.height-1); 
    g.endDraw();

    drawing = false;
  }

  public void renderCommand(Command c) { 
    g.blendMode(p5.MULTIPLY);

    if (c.c == Plotter.COMMAND_MOVETO) { 
      penPos.set(c.p1, c.p2);
    } else if (c.c == Plotter.COMMAND_LINETO) { 
      startDrawing(); 
      g.line(penPos.x, penPos.y, c.p1, c.p2); 
      penPos.set(c.p1, c.p2);
    } else if (c.c == Plotter.COMMAND_CIRCLE) { 
      startDrawing(); 
      //PVector p = plotterToScreen(new PVector(c.p1, c.p2));
      g.ellipseMode(p5.RADIUS); 
      //float r = (float)c.p3/scalePixelsToPlotter; 
      g.ellipse(c.p1, c.p2, c.p3, c.p3); 
      //drawing = false;
    } else if (c.c == Plotter.COMMAND_PEN_CHANGE) { 

      startDrawing(); 
      
      g.stroke(penManager.getColour(c.p1), 150);
      g.strokeWeight(penManager.getThickness(c.p1)*0.7f);
      //p5.println("Command Renderer set stroke weight : ", penManager.getThickness(c.p1)*0.7f);
      
    }
  }

  public void startDrawing() { 
    if (!drawing) { 
      g.beginDraw();
      g.pushMatrix(); 
      g.translate(0,g.height); 
      g.scale(plotterToPixelsScale, -plotterToPixelsScale); 

      g.strokeJoin(g.ROUND);
      g.strokeCap(g.ROUND);
      
       drawing = true;
    }
  }
  public void endDrawing() { 
    if (drawing) { 
      g.popMatrix();
      g.endDraw();
      drawing = false; 
    }
  }
  // add screenVertex command!
  public void screenVertex(int x, int y) { 
    g.vertex(x*plotterToPixelsScale, y*plotterToPixelsScale);
  }

  public void render() { 
    endDrawing();
    p5.pushMatrix(); 
    p5.scale(0.5f,0.5f); 
    p5.image(g, 0, 0);
    p5.popMatrix(); 
  }
}