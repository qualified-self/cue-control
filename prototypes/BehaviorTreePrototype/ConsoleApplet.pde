public class ConsoleApplet extends PApplet {

  final int MAX_LOGS = 10;
  int logOffset = 0; // current log offset

	ConsoleApplet() {
		super();
		PApplet.runSketch(new String[] { "Console" }, this);
	}

  public void settings() {
    this.size(BLACKBOARD_WIDTH, displayHeight);
  }

  public void draw() {
    background(255);

    // Draw blackboard.
		int x = INDENT;
		int y = NODE_HEIGHT;
		y = drawRow("Name", "Value", x, y, #555555, #ffffff, true, false);

		boolean odd = true;
		int nElements = board.size();
		int i=0;
		try {
			java.util.Set<Map.Entry<String, Object>> entries = board.entrySet();
	    for (Map.Entry<String, Object> element : entries) {
				Object val = element.getValue();
				// Format value.
				String str;
				if (val == null)
					str = "NULL";
				if (val instanceof Double || val instanceof Float)
					str = this.nf(((Number)val).floatValue(), 0, 5);
				else
					str = val.toString();
			  // Draw row.
				y = drawRow(element.getKey(), str, x, y, odd ? #cccccc : #aaaaaa, #000000, false, (i == nElements-1));
				odd = !odd;
				i++;
	    }
		} catch (Exception exception) {
			java.io.StringWriter writer = new java.io.StringWriter();
			java.io.PrintWriter printWriter = new java.io.PrintWriter( writer );
			exception.printStackTrace( printWriter );
			printWriter.flush();

			String stackTrace = writer.toString();
			println(stackTrace);
		}

    // Draw console.
    y = max(y + NODE_HEIGHT, height/2);
    drawItem(this, x, y, #555555, true, false);
		drawItemText(this, "", "Console",  x, y, #ffffff);

    int startIndex = max(console.nLogs() - MAX_LOGS + logOffset, 0);
    ArrayList<Console.Entry> logs = console.getLogs(startIndex, MAX_LOGS);
    for (Console.Entry log : logs) {
      y += NODE_HEIGHT;
      drawItem(this, x, y, #dddddd, false, false);
      String logMessage = "[" + log.getFormattedTime() + "] : " + log.getMessage();
		  drawItemText(this, "", logMessage,  x, y, logColor(log));
    }
  }

	int drawRow(String name, String value, int x, int y, color fillColor, color textColor, boolean roundTops, boolean roundBottoms)
	{
		drawItem(this, x, y, fillColor, roundTops, roundBottoms);
		drawItemText(this, "", name,  x,           y, textColor);
		drawItemText(this, "", value, x+width*1/3, y, textColor);

		return (y + NODE_HEIGHT);
	}

  color logColor(Console.Entry log) {
    if (log.getType() == Console.MessageType.NOTICE) return color(#000000);
    else if (log.getType() == Console.MessageType.WARNING) return color(#F06D02);
    else return color(#ff0000);
  }

}
