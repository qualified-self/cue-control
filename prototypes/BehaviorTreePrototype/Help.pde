class Help {
  final String FILE = "help_file.csv";
  final String EDIT = "help_edit.csv";
  final int BUTTON_SIZE = 40;

  final int SIZE    = 24;
  final int LEADING = 10;

  Table file;
  Table edit;

  boolean isVisible;

  Help() {
    file = loadTable(FILE, "header");
    edit = loadTable(EDIT, "header");
    isVisible = false;
  }

  void draw() {
    float buttonX = width-BUTTON_SIZE;
    float buttonY = TOOLBAR_HEIGHT/2;

    if (click.roundButtonWasClicked(buttonX, buttonY, BUTTON_SIZE))
      isVisible = !isVisible;

    // Help button.
    pushStyle();
    textSize(BUTTON_SIZE/2);
    textAlign(CENTER);
    fill(isVisible ? 255 : 0);
    stroke(isVisible ? 0 : 255);
    strokeWeight(2);
    ellipse(buttonX, buttonY, BUTTON_SIZE, BUTTON_SIZE);
    fill(isVisible ? 0 : 255);
    text("?", buttonX, TOOLBAR_HEIGHT*0.6);
    popStyle();

    if (isVisible) {
      pushStyle();
      fill(color(0, 0, 0, 200));
      rectMode(CORNERS);
      textLeading(LEADING);
      int PADDING = (int)(INDENT*1.5);
      rect(PADDING, 0, width-PADDING, height);
      fill(#ffffff);
      int x = PADDING*2;
      int y = TOOLBAR_HEIGHT+PADDING;
      y = _drawTable("FILE", null, null, file, x, y);
      y += SIZE + LEADING;
      y = _drawTable("EDIT",
                     "These commands apply to currently selected node or decorator.",
                     "(*) Switches to node/decorator creation mode. When a node or decorator is added, \nthe user needs to input the node/decorator type followed by arguments (if applicable).\nUser can interrupt node/decorator creation by pressing DELETE.",
                     edit, x, y);
      popStyle();
    }
  }

  int _drawTable(String title, String header, String footer, Table table, int x, int y) {
    // Title.
    textSize(SIZE*1.5);
    text(title, x, y);
    y += SIZE + LEADING;

    // Header.
    if (header != null) {
      textSize(SIZE*0.75);
      text(header, x, y);
      y += SIZE + LEADING;
    }

    // Commands.
    textSize(SIZE);
    for (TableRow row : table.rows()) {
      text(row.getString("key"),         x, y);
      text(row.getString("action"),      x+150, y);
      text(row.getString("description"), x+350, y);
      y += SIZE + LEADING;
    }

    // Footer.
    if (footer != null) {
      textSize(SIZE*0.75);
      text(footer, x, y);
      y += SIZE + LEADING;
    }

    return y;
  }
}
