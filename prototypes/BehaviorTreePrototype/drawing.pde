// Drawing functions for behavior tree.
int editorX;
int editorY;

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
  // Draw decorator's own decorator.
  if (dec.hasDecorator())
    y = drawDecorator(app, dec.getDecorator(), x, y);

  // Check for clicking on decorator.
  if (click.rectButtonWasClicked(x, y, width-INDENT, y+NODE_HEIGHT))
  {
    selectedNode = dec;
  }

  if (isEditing() && dec == placeholderNode) {
    // Generate text area.
  	drawItem(app, x, y, color(#dddddd), true, true);

  	// Draw item text.
  	drawItemText(app, "", dec.getDescription(), x, y, NODE_TEXT_COLOR);

    // Save values for later.
    editorX = x;
    editorY = y;
  }
  else {
    // Draw decorator.
  	drawItem(app, x, y, DECORATOR_FILL_COLOR, !dec.hasDecorator(), false, selectedNode == dec);
  	drawItemText(app, dec.type(), dec.getDescription(), x, y, DECORATOR_TEXT_COLOR);
  }

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

    // Save values for later.
    editorX = x;
    editorY = y;
  }
  else {
    // Draw node.
    color nodeColor;
    if (node.isEnabled())
      nodeColor = stateToColor(node.getState());
    else
      nodeColor = color(#777777);
  	drawItem(app, x, y, nodeColor, !node.hasDecorator(), true, selectedNode == node);

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
  	drawItemText(app, node.type(), node.getDescription(), x+NODE_HEIGHT, y, NODE_TEXT_COLOR);

    // Draw enable button.
    float enableXPosition = x+INDENT/4;
    app.strokeWeight(3);
    app.stroke(#000000);
    app.fill( node.isEnabled() ? color(#000000) : color(255, 255, 255, 0) );
    app.ellipseMode(CENTER);
    app.ellipse(enableXPosition, y+NODE_HEIGHT/2, NODE_HEIGHT/2, NODE_HEIGHT/2);

		// Check for click.
		if (click.roundButtonWasClicked(enableXPosition, y+NODE_HEIGHT/2, NODE_HEIGHT/2))
		{
			node.toggleEnabled();
			click.reset();
      reset(); // reset everything
		}

  	// Draw expand button and deal with it.
  	if (node instanceof CompositeNode)
  	{
      float expandXPosition = x+INDENT/4+NODE_HEIGHT/2+INDENT/4;
  		CompositeNode cn = (CompositeNode)node;
  		// Draw button.
      app.noStroke();
  		app.fill(NODE_EXPANSION_BUTTON_COLOR);
  		app.pushMatrix();
  		app.translate(expandXPosition, y+NODE_HEIGHT/2);
  		app.scale(NODE_HEIGHT/4);
  		if (!cn.isExpanded())
  			app.rotate(radians(-90));
  		app.triangle(-1, -1, 1, -1, 0, 1);
  //		app.ellipse(x, y+NODE_HEIGHT/2, NODE_HEIGHT/2, NODE_HEIGHT/2);
  		app.popMatrix();

  		// Check for click.
  		if (click.roundButtonWasClicked(expandXPosition, y+NODE_HEIGHT/2, NODE_HEIGHT/2))
  		{
  			cn.toggleExpanded();
  			click.reset();
  		}

  	}
  }

  return (y + NODE_HEIGHT + NODE_SPACING);
}

void drawMainTree(PApplet app)
{
  orderedVisibleNodes = new ArrayList<BaseNode>(orderedVisibleNodes == null ? 10 : orderedVisibleNodes.size());

  int y = (int)yOffset+NODE_HEIGHT;
  for (BaseNode child : ((CompositeNode)root).getChildren())
	{
    y = drawTree(this, child, INDENT, y);
  }
}

int drawTree(PApplet app, BaseNode node, int x, int y)
{
  // Draw node.
  y = drawNode(app, node, x, y);

  // Add node to visible nodes.
  orderedVisibleNodes.add(node);

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

void drawEditor(PApplet app) {
  // Draw contextual menu.
  if (isEditing())
  {
    ArrayList<String> autocompleteOptions = factory.nodesStartingWith(placeholderNode.getDescription(), placeholderNode.isDecorator());
    int indexSelected = autocompleteOptions.indexOf(autocompleteListCurrentSelected);

    int yOption = editorY;
    for (int i=0; i<autocompleteOptions.size(); i++)
    {
      yOption += NODE_HEIGHT;

      // Generate text area.
      drawItem(app, editorX, yOption, indexSelected == i ? color(#aaaaaa) : color(#bbbbbb), i == 0, i == autocompleteOptions.size()-1);

      // Draw item text.
      drawItemText(app, "", autocompleteOptions.get(i), editorX, yOption, NODE_TEXT_COLOR);

      float x2 = width-INDENT;
      float y2 = yOption+NODE_HEIGHT;

      // Check if hover on list element.
      if (editorX <= app.mouseX && app.mouseX <= x2 && yOption <= app.mouseY && app.mouseY <= y2) {
        autocompleteListCurrentSelected = autocompleteOptions.get(i);
      }

      // Check if click on list element.
      if (click.rectButtonWasClicked(editorX, yOption, x2, y2)) {
        placeholderNode.assign(autocompleteOptions.get(i) + " ");
        autocompleteListCurrentSelected = null;
      }
    }
  }
}

void drawToolBar(PApplet app) {
  app.fill(32);
  app.rect(0, 0, app.width, TOOLBAR_HEIGHT);

  app.textSize(TOOLBAR_HEIGHT/2);
  app.textAlign(CENTER);

  String text;
  color textColor;
  if (isEditing()) {
    text = "EDITING";
    textColor = #ffffff;
  }
  else if (isPlaying()) {
    text = "PLAY";
    textColor = stateToColor(State.RUNNING);
  }
  else if (isFinished()) {
    text = "FINISHED";
    textColor = stateToColor(rootState);
  }
  else
  {
    text = "PAUSE";
    textColor = stateToColor(State.RUNNING);
  }

  app.fill(textColor);
  app.text(text, app.width/2, TOOLBAR_HEIGHT/2+10);
  app.textAlign(LEFT); // switch back to normal
}

void drawHelp(PApplet app) {
  help.draw();
}

color stateToColor(State state) {
  if (state == State.RUNNING)
    return color(#52F3F7);
  else if (state == State.SUCCESS)
    return color(#73FC74);
  else if (state == State.FAILURE)
    return color(#E33535);
  else
    return color(#AAAAAA);
}
