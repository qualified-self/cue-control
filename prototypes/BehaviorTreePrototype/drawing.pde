// Drawing functions for behavior tree.

// General function that draws a single "row".
void drawItem(PApplet app, int x, int y, color fillColor, boolean roundTops, boolean roundBottoms)
{
  drawItem(app, x, y, fillColor, roundTops, roundBottoms, false);
}

void drawItem(PApplet app, int x, int y, color fillColor, boolean roundTops, boolean roundBottoms, boolean selected)
{
	int topCorners    = roundTops    ? 10 : 0;
	int bottomCorners = roundBottoms ? 10 : 0;
	app.rectMode(CORNERS);
  if (selected)
  {
    app.stroke(255);
    app.strokeWeight(3);
  }
  else
	  app.noStroke();
  app.fill(fillColor);
	app.rect(x, y, app.width-INDENT, y+NODE_HEIGHT, topCorners, topCorners, bottomCorners, bottomCorners);
  app.noStroke();
}

// General function to draw text.
void drawItemText(PApplet app, String type, String text, int x, int y, color textColor)
{
	app.textSize(NODE_HEIGHT/2);
	app.fill(#0000ff);
	app.text(type, x+INDENT/2, y+NODE_HEIGHT*0.65);
	app.fill(textColor);
	app.text(text, x+INDENT/2+textWidth(type)+5, y+NODE_HEIGHT*0.65);
}

int drawDecorator(PApplet app, Decorator dec, int x, int y)
{
  if (dec.hasDecorator())
    y = drawDecorator(app, dec.getDecorator(), x, y);

  // Draw decorator.
	drawItem(app, x, y, DECORATOR_FILL_COLOR, true, false);
	drawItemText(app, dec.type(), dec.getDescription(), x, y, DECORATOR_TEXT_COLOR);

  return (y + NODE_HEIGHT);
}

int drawNode(PApplet app, BaseNode node, int x, int y)
{
  // Draw decorators (if any).
  if (node.hasDecorator())
  {
    y = drawDecorator(app, node.getDecorator(), x, y);
  }

  // Check for clicking on node.
  if (click.rectButtonWasClicked(x, y, width-INDENT, y+NODE_HEIGHT))
    selectedNode = node;

  if (isEditing() && node == placeholderNode) {
    // Generate text area.
  	drawItem(app, x, y, color(#dddddd), true, true);

  	// Draw item text.
  	drawItemText(app, "", node.getDescription(), x, y, NODE_TEXT_COLOR);
  }
  else {
    // Draw node.
  	drawItem(app, x, y, stateToColor(node.getState()), !node.hasDecorator(), true, selectedNode == node);

    // Animation for running nodes.
    if (node.getState() == State.RUNNING) {
      final int SPREAD=100;
      int start = x+nSteps%SPREAD;
      int end   = width-INDENT-SPREAD;
      for (int xx=start; xx<end; xx+=SPREAD) {
        fill(255, 255, 255, map(xx, start, end, 100, 0));
        rect(xx, y, xx+SPREAD*0.5, y+NODE_HEIGHT);
      }
    }

  	// Draw item text.
  	drawItemText(app, node.type(), node.getDescription(), x, y, NODE_TEXT_COLOR);

  	// Draw expand button and deal with it.
  	if (node instanceof CompositeNode)
  	{
  		CompositeNode cn = (CompositeNode)node;
  		// Draw button.
  		app.fill(NODE_EXPANSION_BUTTON_COLOR);
  		app.pushMatrix();
  		app.translate(x+INDENT/4, y+NODE_HEIGHT/2);
  		app.scale(NODE_HEIGHT/4);
  		if (!cn.isExpanded())
  			app.rotate(radians(-90));
  		app.triangle(-1, -1, 1, -1, 0, 1);
  //		app.ellipse(x, y+NODE_HEIGHT/2, NODE_HEIGHT/2, NODE_HEIGHT/2);
  		app.popMatrix();

  		// Check for click.
  		if (click.roundButtonWasClicked(x+INDENT/4, y+NODE_HEIGHT/2, NODE_HEIGHT/2))
  		{
  			cn.toggleExpanded();
  			click.reset();
  		}

  	}
  }

  return (y + NODE_HEIGHT + NODE_SPACING);
}

int drawTree(PApplet app, BaseNode node, int x, int y)
{
  // Draw node.
  y = drawNode(app, node, x, y);

  if (node instanceof CompositeNode)
  {
    CompositeNode cn = (CompositeNode)node;

		if (cn.isExpanded())
		{
	    for (BaseNode child : cn.getChildren())
			{
	      y = drawTree(app, child, x+INDENT, y);
	    }
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
