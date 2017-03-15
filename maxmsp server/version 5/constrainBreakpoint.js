autowatch = 1;
inlets=1;
outlets=2;
var outlet_state;

function list(l){
post("outlet", outlet_state);
	//if(outlet_state==0) setPointZero();
	//else {
	outlet(0,15);
	//else if (checkAmplitude(l[3],l[5]));
	 sendCorrectMessage(l[1],l[3],l[4],l[5]);
	 outlet_state=0;
// }
}

function bang(){
	var a = new Array();
	a.push(0);
	a.push(0);
	a.push(0);
	
 	outlet(1, a);
	outlet(1, "bang");
}

//set the first point to 0,0
function setPointZero(val){
	outlet_state=1;
	var a = new Array();
	a.push(0);
	a.push(0);
	a.push(0);
	
 	outlet(1, a);
	outlet(1, "bang");
}

//update the amplitude and set both points 1$2
function checkAmplitude(p1, p2){

}	

//output a correct envelope
function sendCorrectMessage(p1, p2, p3, p4){
	outlet(0, p1);
}	

