#!/usr/bin/env python
"""
BITalino signal bridge.
Usage:
  main <serial> [--host=<ip>] [--port=<port>]
  main -h | --help

  Send signals from the BITalino serial as OSC to the destination host.

Options:
  -h --help              Show this screen.
"""
from docopt import docopt
import os, sys
import time
import traceback
import bitalino
from OSC import OSCClient, OSCServer, OSCMessage

#send_address = ('192.168.1.68', 55551) #('127.0.0.1', 55551)
#osctx = None

samplingRate = 10
#samplingRate = 100
#samplingRate = 1000


def osc_init( address=('localhost', 12000) ):
    print "Opening OSC connection to", address[0], "on", address[1]
    retval = OSCClient()
    retval.connect(address)
    return retval

def bitalino_init(port='/dev/tty.bitalino-DevB'):
    print "Opening bitalino on port ", port

    #batteryThreshold = 30    
    #acqChannels=[4]
    acqChannels = [0, 1, 2, 3, 4, 5]

    
    #samplingRate = 10
    #samplingRate = 100
    #samplingRate = 1000
    
    bitadev = None

    try:
        bitadev = bitalino.BITalino(port)
        time.sleep(.2)
        #print bitadev.battery(batteryThreshold)

        print "Bitalino version", bitadev.version()
        bitadev.start(samplingRate, acqChannels)
        
        time.sleep(.2)
    except OSError as e:
        traceback.print_exc()
        print
        print "(!!!) Seems like the BITalino isn't online, pair your BITalino before trying again."
        print
        sys.exit(2)
    finally:
        return bitadev

def loop(serial, host, port):
    osctx = osc_init( (host, port) )
    bitadev = bitalino_init(serial)
    
    if not bitadev:
        raise Exception("Coultdn't open the BITalino device")

    try:
        print "Entering reading loop..."
        while True:
            samples = bitadev.read(1)
            #instead of sleeping a fixed time
            #time.sleep(0.005)
            #now it depends on the refresh rate
            #time.sleep((1/samplingRate)-(1/samplingRate*10))
            #bitadev.trigger(digitalOutput)
            
            for s in samples:
                
                #getting the last 6 messages
                subarray = s[-6:]
                counter = 0
                for nm in subarray:
                
                    msg = OSCMessage()
                    msg.setAddress("/bitalino/"+str(counter))
                    out = []
                    counter = counter+1
                    
                    #print "my samples are " + str(subarray) + "\n"

                    msg.append(nm)
                    #print msg
                    osctx.send(msg)
                
    except KeyboardInterrupt as e:
        print "Looks like you wanna leave. Good bye!"
    finally:
        bitadev.stop()
        bitadev.close()

if __name__ == '__main__':
    print "(cc) 2015 Luis Rodil-Fernandez <zilog@protokol.cc>"
    print 
    print "October 31th 2016 - modified to support realtime stream of the 6 bitalino ports - jeraman.info."
    print 

    arguments = docopt(__doc__, version='BITalino')
    
    if ('--host' in arguments) and (arguments['--host']):
        host = arguments['--host']
    else:
        host = '127.0.0.1'

    loop(arguments['<serial>'], arguments['--host'], int(arguments['--port']) )
    
    raw_input()
    
    print 'Holy shit!'
