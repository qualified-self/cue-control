/////////////////////////////////////////////////////////////////
inlets = 4;
outlets = 1;
autowatch = 1;

// arguments in the js object
var litenum = jsarguments[1]; 
var red = jsarguments[2]; 
var green = jsarguments[3]; 
var blue = jsarguments[4]; 

// global array for all light fixtures
liteArr = [];
liteIn = []

initLite();

//
function initLite(){
	
	for (var n=0; n<255; ++n){
		liteArr[n] = 0;
		
	}
	
}


///

function Lite(litenum, mode, red, green, blue, dim){

mylite = (litenum-1) * 4;	

liteArr[mylite] = mode;	
liteArr[mylite + 1] = red;
liteArr[mylite + 2] = green;
liteArr[mylite + 3] = blue;
liteArr[mylite + 4] = dim;
		
		outlet(0,liteArr);
	
}


post(liteArr);
////