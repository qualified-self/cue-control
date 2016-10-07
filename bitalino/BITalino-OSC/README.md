#BITalino to OSC

##oF app
From: http://gitlab.doc.gold.ac.uk/rapid-mix/BITalino-OSC-OSX

###Step 1
Run the setup-osculator;

###Step2
Run the bitalinoOSCDebug.app;

Good to go! :)


##Python 
By Luis: https://github.com/dropmeaword/prtkl-narcissus/tree/master/bitalino/narc

Also from: https://github.com/chaosct/pd-repovizz

###Step 1
Find out what serial port BITalino uses:
```
ls /dev/tty.*
```

In my case, it is:
```
/dev/tty.bitalino-DevB
```

###Step 2
Use main.py to make the OSC convertion. In my case, for example, that is the command:
```
python main.py /dev/tty.bitalino-DevB --host=127.0.0.1 --port=6448
```

###Step 3
Open whenever client you want (e.g. bitalino-receiver.pd) and have fun! :)