public class BlackboardApplet extends PApplet {

	BlackboardApplet() {
		super();
		PApplet.runSketch(new String[] { "Blackboard" }, this);
	}

  public void settings() {
    this.size(BLACKBOARD_WIDTH, displayHeight);
  }

  public void draw() {
    background(255);

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
  }

	int drawRow(String name, String value, int x, int y, color fillColor, color textColor, boolean roundTops, boolean roundBottoms)
	{
		drawItem(this, x, y, fillColor, roundTops, roundBottoms);
		drawItemText(this, name,  x,         y, textColor);
		drawItemText(this, value, x+width*1/3, y, textColor);

		return (y + NODE_HEIGHT);
	}

}
