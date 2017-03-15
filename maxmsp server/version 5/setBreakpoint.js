autowatch=1;

var envTime = new Array();
var envAmp = new Array();
var envLength = 1000;

function loadbang(){
	envTime[0]=0;
	envTime[1]=100;
	envTime[2]=200;
	envTime[3]=1000;
	
	envAmp[0]=0;
	envAmp[1]=1.;
	envAmp[2]=1.;
	envAmp[3]=0.;
}

function attack(val){
	val= (val) ;
	if(val> (100-envTime[2]) ) val = 100-envTime[2];
	envTime[1]=val;
	outputEnvelope();
}

function decay(val){
	val =  (val);
	if(val> (100-envTime[1]) ) val = 100-envTime[1];
	envTime[2]=val;
	outputEnvelope();
}

function amp(val){
	envAmp[1]=val;
	envAmp[2]=val;
	outputEnvelope();
}

function length(val){
	envTime[3]=val;
	//envTime[1] = envTime[3] * (val/100) + 1;
	//envTime[2] = (envTime[3]-1) * ((100-val) / 100);
	////env[3] = envLength - envTime[2];
	outputEnvelope();
}



function outputEnvelope(){
	var set_point=new Array();
	
	for(var i=0;i<4;i++){
		set_point[0]=i;
		set_point[2]=envAmp[i];
		
		switch(i){
			case 0:
			set_point[1]=envTime[i];
			break;
			
			case 1:
			set_point[1]=((envTime[i]/100) * envTime[3])+1;
			break;
			
			case 2:
			set_point[1]=envTime[3] - (envTime[3] * (envTime[i]/100)) - 1;
			break;
			
			case 3:
			set_point[1]=envTime[i];
			break;
		}
		outlet(0,set_point);
	}
}
