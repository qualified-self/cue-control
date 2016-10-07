
import OSC
import bitalino
import os.path
try:
    import bluetooth
except ImportError:
    bluetooth = None
#config
#
devices = ["/dev/rfcomm0", "/dev/tty.bitalino-DevB"]

macAddr = None
for d in devices:
    if os.path.exists(d):
        macAddr = d
if not macAddr:
    print "ERROR: DEVICE NOT FOUND"
    print "list of possible devices:"
    print "\n".join(devices)
    print
    print "May be you want to run:"
    print "$ sudo rfcomm connect rfcomm0"
    exit(1)

simuladorAddr = ('localhost',6448)
acqChannels = [0,5]
#acqChannels = [0]
samplingRate = 100
nSamples = 50

def main():
    #setting up OSC
    osc = OSC.OSCClient()
    osc.connect(simuladorAddr)

    #setting up BITalino
    device = bitalino.BITalino(macAddr)
    if not device.start(samplingRate, acqChannels):
        print "Error opening BITalino"
        print "addr: {} , sampling rate: {}".format(macAddr,samplingRate)
        exit()

    #print "Device version:"
    #print device.version()
    #Start Acquisition in Analog Channels 0 and 3
    #device.start([2])

    #led ON
#    device.trigger([0,0,0,1])
    try:
        while True:
            data = device.read(nSamples)
            tosend = list(data[5]/1024)
            #do something with data ?

            msg = OSC.OSCMessage("/ECG")
            msg += tosend
            try:
                osc.send(msg)
            except OSC.OSCClientError:
                pass
    except KeyboardInterrupt:
        pass
    finally:
        device.stop()
        device.close()
#        osc.close()

            
if __name__ == '__main__':
    main()