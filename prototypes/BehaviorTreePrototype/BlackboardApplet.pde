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
		java.util.Set<HashMap.Entry<String, Double>> entries = board.entrySet();
    for (HashMap.Entry<String, Double> element : entries) {
			y = drawRow(element.getKey(), this.nf(element.getValue().floatValue(), 0, 5), x, y, odd ? #cccccc : #aaaaaa, #000000, false, (i == nElements-1));
			odd = !odd;
			i++;
    }
  }

	int drawRow(String name, String value, int x, int y, color fillColor, color textColor, boolean roundTops, boolean roundBottoms)
	{
		drawItem(this, x, y, fillColor, roundTops, roundBottoms);
		drawItemText(this, name,  x, y, textColor);
		drawItemText(this, value, x+width/2, y, textColor);

		return (y + NODE_HEIGHT);
	}

}
