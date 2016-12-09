package fup.hpgl;

import java.util.ArrayList;

import processing.core.*;
import processing.serial.*;

/**
 * HPGL plotter class
 * @author Edwin Jakobs
 */

public class HPGL {
	PApplet applet;
	boolean debug;
	boolean dry;
	ArrayList<String> buffer;
	int commandDelay = 50;

	/**
	 * Constructor
	 * @param applet the parent processing applet
	 * @param serial an initialized serial instance to which the plotter is connected
	 */
	public HPGL(PApplet applet, Serial serial) {
		this.serial = serial;
		this.applet = applet;
		this.debug = false;
		this.dry = false;
		buffer = null;
		
		if (serial != null) {
			serial.bufferUntil('\n');
		}
		else {
			this.dry = true;
		}
	}

	/**
	 * Sets the delay between sending HPGL commands to the plotter.
	 * The default value is 50ms. Setting the delay too low may result in overflowing the plotter's buffer.  
	 * @param delay the delay in milliseconds
	 */
	public void setCommandDelay(int delay) {
		this.commandDelay = delay;
	}
	
	/**
	 * Starts buffering HPGL commands. Commands will be sent to the plotter when pushBuffer() is invoked.
	 */
	
	public void startBuffer() {
		buffer = new ArrayList<String>();
	}
	
	/**
	 * Pushes buffered HPGL commands to plotter.
	 */
	public void pushBuffer() {
		if (buffer != null) {
			
			for (String command: buffer) {
				rawCommand(command, false);
			}
			
			
			buffer = null;
		}
	}
	
	
	/**
	 * Sets dry mode. In a dry mode no commands will be send to the plotter.
	 * @param state dry mode enabled when true
	 */
	public void setDry(boolean state) {
		this.dry = state;
	}
	
	/** 
	 * Sends a raw command to the plotter
	 @param command the command to send to the plotter
	 @param should we wait for a response from the plotter after sending
	*/
	public String rawCommand(String command, boolean wait) {
		
		if (debug)
			PApplet.println("raw command: " + command);
		
		if (!this.dry)
			this.serial.write(command);

		applet.delay(this.commandDelay);

		
		String result = null;;
		if (wait) {

			if (debug)
				PApplet.println("waiting for reply");
			while (result == null) {
				result = this.serial.readString();
			}
		}
		return result;
 	}
	
	private String request(boolean wait, String command, Object ... arguments) {
		String output = new String(command);

		boolean needComma = false;
		for (Object arg : arguments) {
			if (needComma)
				output = output+",";

			output = output + arg.toString();
			needComma = true;
		}
		output = output + ";";
		
		String result = rawCommand(output, wait);
		
		if (debug)
			PApplet.println("result: "+ result);
		
		if (debug)
			PApplet.println("request: " + output);
		
		return result;
	}

	public String read(String command) {
		return request(true, command);
	}

	/**
	 * Selects the acceleration for all pens.
	 * @param accel the acceleration to use for all pens
	 */
	public void accelerationSelect(int accel) {
		send("AS", new Integer(accel));
	}

	/**
	 * Selects the acceleration for a given pen
	 * @param accel the acceleration to use
	 * @param pen the pen to set the acceleration for
	 */
	public void accelerationSelect(int accel, int pen) {
		send("AS", new Integer(accel), new Integer(pen));
	}
	
	/**
	 * Selects the force to be applied on all pens
	 * @param force the force to be applied on all pens
	 */
	public void forceSelect(int force) {
		send("FS", new Integer(force));
	}
	
	/**
	 * Selects to be applied on a single pen
	 * @param force the force to be applied
	 * @param pen the pen to apply the force to
	 */
	public void forceSelect(int force, int pen) {
		send("FS", new Integer(force), new Integer(pen));
	}

	/**
	 * Sends a command to the plotter
	 * @param command the command to send
	 * @param arguments the arguments to the command
	 */
	public void send(String command, Object... arguments) {
		if (debug)
			PApplet.println("send: "+command);
		request(false, command, arguments);
	}

	/**
	 * Lift the pen up.
	 */
	public void penUp() {
		send("PU"); 
	}

	
	/** 
	 * Lower the pen.
	 */
	public void penDown() {
		send("PD");
	}  
	
	/**
	 * Select the pen to use for drawing.
	 * @param pen the pen to use for drawing
	 */
	public void selectPen(int pen) {
		send("SP", new Integer(pen));
	}

	/** Sets the line type.
	 * @param pattern the pattern type
	 * @param length the length of the pattern
	 */
	public void lineType(int pattern, float length) {
		send("LT", new Integer(pattern), new Float(length)); 
	}

	/**
	 * Move the pen position the given absolute coordinates.
	 * @param x the x coordinate
	 * @param y the y coordinate
	 */
	public void plotAbsolute(int x, int y) {
		send("PA", new Integer(x), new Integer(y)); 
	}

	/**
	 * Move the pen position to the given relative coordinates
	 * @param x the x coordinate
	 * @param y the y coordinate
	 */
	public void plotRelative(int x, int y) {
		send("PR", new Integer(x), new Integer(y));
	}  

	/**
	 * Initialize the plotter.
	 */
	public void initialize() {
		send("IN"); 
	}

	/**
	 * Get the actual pen position
	 * @return the current pen position
	 */
	public int[] actualPosition() {
		String result = request(true, "OA");
		String[] tokens = result.split(",");
		int[] coords = new int[2];
		coords[0] = new Integer(tokens[0]).intValue();
		coords[1] = new Integer(tokens[1]).intValue();
		return coords;
	}

	/**
	 * Get the plotter status.
	 * @return the current status of the plotter
	 */
	public String status() {
		return request(true, "OS");
	}
	
	/**
	 * Get the plotter id.
	 * @return the id of the plotter
	 */
	public String id() {
		return request(true, "OI");
	}
	
	/**
	 * Get the hard clip limits
	 * @return the hard clip limits 
	 */
	public int[] hardClipLimits() {
		String r = read("OH");
		String[] tokens = r.split(",");
		
		int res[] = new int[4];
		for (int i = 0; i < 4; ++i) {
			res[i] = new Integer(tokens[i].trim()).intValue();			
		}
		return res;
	}
	
	public String options() {
		return read("OO");
	}
	
	private Serial serial;
}