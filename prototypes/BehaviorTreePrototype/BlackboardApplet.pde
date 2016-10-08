public class BlackboardApplet extends PApplet {

	BlackboardApplet() {
		super();
		PApplet.runSketch(new String[] { "Blackboard" }, this);
	}

  public void settings() {
    this.size(500, 1000);
  }

  public void draw() {
    background(255);

		int x = INDENT;
		int y = NODE_HEIGHT;
		y = drawRow("Name", "Value", x, y, #555555, #ffffff, true);

		boolean odd = true;
    for (HashMap.Entry<String, Integer> element : board.entrySet()) {
			y = drawRow(element.getKey(), element.getValue().toString(), x, y, odd ? #cccccc : #aaaaaa, #000000, false);
			odd = !odd;
    }
  }

	int drawRow(String name, String value, int x, int y, color fillColor, color textColor, boolean header)
	{
	  rectMode(CORNERS);
	  fill(fillColor);
		int topCorners = header ? 10 : 0;
		int bottomCorners = header ? 0 : 10;
		rect(x, y, width-INDENT, y+NODE_HEIGHT, topCorners, topCorners, bottomCorners, bottomCorners);
	  fill(textColor);
	  textSize(NODE_HEIGHT/2);
	  text(name,  x+INDENT/2, y+NODE_HEIGHT*0.65);
	  text(value, x+width/2+INDENT/2, y+NODE_HEIGHT*0.65);
	  y += NODE_HEIGHT;
		return y;
	}

}
