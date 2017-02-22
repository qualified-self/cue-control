
/******************************************************************************
 ******************************************************************************
 ** MULTILAYER PIE MENU *******************************************************
 ******************************************************************************
 *** jeraman.info, Jan. 12 2017 ***********************************************
 *****************************************************************************/


import processing.core.PApplet;

class MultiLevelPieMenu {

  private String[] task_list       = {"Blackboard", "", "", "", "Sound", "Haptics", "Light", "Meta"};
  private String[] light_list      = {"Stop DMX", "", "Start DMX", "Control DMX"};
  private String[] sound_list      = {"Stop audio", "", "Start audio", "Control audio"};
  private String[] haptics_list    = {"Stop aura", "", "Start aura", "Control aura"};
  private String[] meta_list 	   = {"OSC", "", "State Mechine", "Script (not implemented)"};
  private String[] blackboard_list = {"Default", "", "", "Random", "Oscillator", "Ramp"};


  //MLP_Status status;

  private PieMenu main;
  private PieMenu light;
  private PieMenu sound;
  private PieMenu haptics;
  private PieMenu meta;
  private PieMenu blackboard;

  private boolean is_opening;
  private PApplet  p;

  public MultiLevelPieMenu (PApplet p) {
    this.p = p;

    //status = MLP_Status.CLOSED;
    is_opening = true;

    main    = new PieMenu(p);
    main.set_options(task_list);

    light   =  new PieMenu(p, main.getX(), main.getY(), (int)(main.getDiam()*1.75));
    light.set_inner_circle_diam(main.getDiam());
    light.set_options(light_list);

    sound   =  new PieMenu(p, main.getX(), main.getY(), (int)(main.getDiam()*1.75));
    sound.set_inner_circle_diam(main.getDiam());
    sound.set_options(sound_list);

    haptics =  new PieMenu(p, main.getX(), main.getY(), (int)(main.getDiam()*1.75));
    haptics.set_inner_circle_diam(main.getDiam());
    haptics.set_options(haptics_list);
    
    meta	=  new PieMenu(p, main.getX(), main.getY(), (int)(main.getDiam()*1.75));
    meta.set_inner_circle_diam(main.getDiam());
    meta.set_options(meta_list);

    blackboard = new PieMenu(p, main.getX(), main.getY(), (int)(main.getDiam()*1.75));
    blackboard.set_inner_circle_diam(main.getDiam());
    blackboard.set_options(blackboard_list);
  }

  void setup() {
    main.setup();
    light.setup();
    sound.setup();
    haptics.setup();
    meta.setup();
    blackboard.setup();
    
    hide();
  }

  void draw() {
    p.noStroke();
    light.draw();
    sound.draw();
    haptics.draw();
    meta.draw();
    blackboard.draw();

    main.draw();

    //if is showing, try to update the second layer
    if (is_showing())
      update_second_layer_selection();
  }

  //sets the diam of the inner circle
  void set_inner_circle_diam (float newdiam) {
    this.main.set_inner_circle_diam(newdiam);
  }

  boolean is_showing() {
    return main.is_showing();
  }

  boolean is_fading_away() {
    return main.is_fading_away();
  }

  void update_second_layer_selection () {

	  switch(get_main_selection()) {
	  case 0: // Blackboard
		  if (p.mousePressed) show_blackboard();
		  is_opening = true;
		  break;
	  case 4: // Sound
		  if (p.mousePressed) show_sound();
		  is_opening = true;
		  break;
	  case 5: // Haptics
		  if (p.mousePressed) show_haptics();
		  is_opening = true;
		  break;
	  case 6: // Light
		  if (p.mousePressed) show_light();
		  is_opening = true;
		  break;
	  case 7: // Meta
		  if (p.mousePressed) show_meta();
		  is_opening = true;
		  break;
	  }
  }

  void set_position (int x, int y) {
    main.set_position(x, y);
    light.set_position(x, y);
    sound.set_position(x, y);
    haptics.set_position(x, y);
    meta.set_position(x, y);
    blackboard.set_position(x, y);
  }


  //reimplement this according to the new structure
  int get_main_selection() {
    return main.get_selection();
  }

  //reimplement this according to the new structure
  int get_selection() {
    int result = -1;

    //testing if the result is an osc message (between 0 and 9)
    //if (result != -1) return result;

    //testing if selection is a sound message (between 10 and 19)
    result = sound.get_selection();    
    if (result != -1) return result+10;

    //testing if selection is a haptics message (between 20 and 29)
    result = haptics.get_selection();
    if (result != -1) return result+20;

    //testing if selection is a light message (between 30 and 39)
    result = light.get_selection();
    if (result != -1) return result+30;

    //testing if selection is a blackboard message (between 40 and 49)
    result = blackboard.get_selection();
    if (result != -1) return result+40;
    
	//testing if selection is a meta message (between 50 and 59)
    result = meta.get_selection();
    if (result != -1) return result+50;
    

    return result;
  }

  void show() {
    main.show();
  }
  

  void show_light() {
    sound.hide();
    haptics.hide();
    blackboard.hide();
    meta.hide();
    light.show();
  }

  void show_sound() {
    light.hide();
    haptics.hide();
    blackboard.hide();
    meta.hide();
    sound.show();
  }

  void show_haptics() {
    light.hide();
    sound.hide();
    blackboard.hide();
    meta.hide();
    haptics.show();
  }

  void show_blackboard() {
    light.hide();
    sound.hide();
    haptics.hide();
    meta.hide();
    blackboard.show();
  }
  
  void show_meta() {
    light.hide();
    sound.hide();
    haptics.hide();
    blackboard.hide();
    meta.show();
  }

  void hide() {
    main.hide();
    direct_hide_second_layer();
  }

  void direct_hide_second_layer() {
    light.direct_hide();
    sound.direct_hide();
    haptics.direct_hide();
    meta.direct_hide();
    blackboard.direct_hide();
    //status = MLP_Status.CLOSING;
    is_opening = false;
  }
}
