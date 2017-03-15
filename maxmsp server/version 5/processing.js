inlets=1;
outlets=4;

outlet(0, "a");
outlet(1, "b");
outlet(2, "c");
outlet(3, "d");

function bang() { outlet(0, "bang"); }