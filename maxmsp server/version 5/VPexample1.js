var size=10;
var theList = new Array();

function loadbang()
{
size=Math.floor(Math.random()*10+2);
post("size: " + size + "n");
theList = new Array();

}

function makeList()
{
var l = new Array();
for (var i=0; i
l.push(i);

return l;
}

// output list of numbers
function bang()
{
theList = makeList();
//post(theList + "n");

var a = new Array();

for (var n=0; n
{
var e = theList.splice(0,1);

// this should add a number!
a.push(e);

// this will print out a number
post(e + "n");
}

// now outputs array of js objects?
outlet(0, a);
}