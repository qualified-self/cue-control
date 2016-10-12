// Drawing functions for behavior tree.

// General function that draws a single "row".
void drawItem(PApplet app, int x, int y, color fillColor, boolean roundTops, boolean roundBottoms)
{
	int topCorners    = roundTops    ? 10 : 0;
	int bottomCorners = roundBottoms ? 10 : 0;
  app.rectMode(CORNERS);
  app.fill(fillColor);
	app.rect(x, y, app.width-INDENT, y+NODE_HEIGHT, topCorners, topCorners, bottomCorners, bottomCorners);
}

// General function to draw text.
void drawItemText(PApplet app, String text, int x, int y, color textColor)
{
	app.fill(textColor);
	app.textSize(NODE_HEIGHT/2);
	app.text(text, x+INDENT/2, y+NODE_HEIGHT*0.65);
}

int drawDecorator(Decorator dec, int x, int y)
{
  if (dec.hasDecorator())
    y = drawDecorator(dec.getDecorator(), x, y);

  // Draw decorator.
	drawItem(this, x, y, DECORATOR_FILL_COLOR, true, false);
	drawItemText(this, dec.type() + " " + dec.getDescription(), x, y, DECORATOR_TEXT_COLOR);

  return (y + NODE_HEIGHT);
}

int drawNode(BaseNode node, int x, int y)
{
  // Draw decorators (if any).
  if (node.hasDecorator())
  {
    y = drawDecorator(node.getDecorator(), x, y);
  }

  // Draw node.
	drawItem(this, x, y, stateToColor(node.getState()), !node.hasDecorator(), true);

  // Animation for running nodes.
  if (node.getState() == State.RUNNING) {
    final int SPREAD=100;
    int start = x+frameCount%SPREAD;
    int end   = width-INDENT-SPREAD;
    for (int xx=start; xx<end; xx+=SPREAD) {
      fill(255, 255, 255, map(xx, start, end, 100, 0));
      rect(xx, y, xx+SPREAD*0.5, y+NODE_HEIGHT);
    }
  }

	// Draw item text.
	drawItemText(this, node.type() + " " + node.getDescription(), x, y, NODE_TEXT_COLOR);

  return (y + NODE_HEIGHT + NODE_SPACING);
}

int drawTree(BaseNode node, int x, int y)
{
  // Draw node.
  y = drawNode(node, x, y);

 if (node instanceof CompositeNode) {
    CompositeNode cn = (CompositeNode)node;
    for (BaseNode child : cn.children) {
      y = drawTree(child, x+INDENT, y);
    }
  }

  return y;
}

color stateToColor(State state) {
  if (state == State.RUNNING)
    return color(#52F3F7);
  else if (state == State.SUCCESS)
    return color(#73FC74);
  else if (state == State.FAILURE)
    return color(#E33535);
  else
    return color(#999999);
}
