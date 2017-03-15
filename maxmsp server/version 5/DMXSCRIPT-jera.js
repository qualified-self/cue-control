/////////////////////////////////////////////////////////////////
inlets = 8;
outlets = 1;
autowatch = 1;

// arguments in the js object
var intensity_p1 = jsarguments[1]; 
var intensity_p2  = jsarguments[2]; 
var intensity_s1 = jsarguments[1]; 
var duration_s1  = jsarguments[2]; 
var rate_s1 	 = jsarguments[3]; 
var intensity_s2 = jsarguments[1]; 
var duration_s2  = jsarguments[2]; 
var rate_s2 	 = jsarguments[3]; 

// global array for all light fixtures
liteArr = [];
liteIn = []

initLite();

//
function initLite(){
	
	for (var n=0; n<255; ++n){
		liteArr[n] = 0;
		
	}
	
	outlet(0,liteArr);	
}



///
function Dimmer(dimmernum, dimmervalue){
	mydimmer = (dimmernum-1) ;	
	liteArr[mydimmer] = dimmervalue;			
	outlet(0,liteArr);	
}


///
function Nitro1(intensity, rate, duration){
	liteArr[6] = intensity;	
	liteArr[7] = rate;	
	liteArr[8] = duration;			
	outlet(0,liteArr);	
}

///
function Nitro2(intensity, rate, duration){	
	liteArr[9] = intensity;	
	liteArr[10] = rate;	
	liteArr[11] = duration;			
	outlet(0,liteArr);	
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