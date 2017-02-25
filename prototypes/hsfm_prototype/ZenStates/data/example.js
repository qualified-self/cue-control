//you can declare variables that will be sent to the blackboard as in here
var example = (5+4)*19;

//you can directly get values from the blackboard as follows...
print ('my mouseX is ' + mouseX);
example = example * mouseX;

//and similarly you can set new values on the blackboard as follows...
blackboard.put("my_js_example", example);

//you can create funtions like this one
var fun1 = function(name) {
    print('Hi there from Javascript, ' + name);
    return "greetings from javascript";
};
