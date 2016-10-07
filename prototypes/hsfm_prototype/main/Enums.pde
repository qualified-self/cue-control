/************************************************
 ** Basic enum for running machine
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

public static enum Status {
    INACTIVE,
    RUNNING,
    DONE,
}

//define here what input conditions this state machine has. these were set based in our scenario.
public static enum Input {
    PUSH, //used only inside the Testing_Connection_Class. delete this whenever done with the testing.
    COIN, //used only inside the Testing_Connection_Class. delete this whenever done with the testing.
    //EMPTY,//used to make shortcuts to the state machine
    START_MAIN_LOOP,
//    START_INTRODUCTION,
    START_SELF_APPEARS,
    DATA_SYNCED_OR_TIMEOUT,
    FINISH;
}