#Server
This server controls wirelessly all media used in the piece via OSC messages.

These are the steps you need to follow for configuring the server:

##Setting up Audio & Haptics

![image](photos/aura.jpg)

![image](photos/sound.jpg)

1. Wire up the speakers and the aura to the firestudio. The firestudio should be connected to the computer;

2. Make sure this audio setup is properly configured in your computer before continuing;

#Setting up rounter & DMX

![image](photos/router.jpg)

![image](photos/dmx.jpg)

1. Connect the DMX strobe into the Enttec device;

2. Connect the Enttec to the D-Link router. Make sure your Enttec device is properly configured to work wirelessly with the router. See details [here](https://d2lsjit0ao211e.cloudfront.net/pdf/manuals/70305.pdf));

3. Test and make sure the DMX system is properly working (e.g. ping the Enttec device) before continuing;

#Setting up the server

![image](photos/server.jpg)

1. Download the MAX patch for the server (avaìlable [here](https://github.com/qualified-self/cue-control/tree/master/maxmsp%20server/version%202));

2. Everything should be running fine by now. You can make sure the system is properly working by using the controls inside the [p osc-send-simulator] object.

If you any have any question, don't hesitate to contact me (Jeronimo) via email.
