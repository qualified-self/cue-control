autowatch = 1
inlets = 3
outlets = 2

var cur_ID =0;
var cur_number =1;
var cur_spread = 1;
var num_of_IDs = 9;

function ID( num){
	cur_ID=num;
	for(cur_ID; cur_ID<1; cur_ID+=9);
	
	calcOutput();
}

function number( num){
	if(num<1)num=1;
	else if (num>9) num=9;
	cur_number=num;
}

function spread( num){
	if(num<1)num=1;
	else if (num>8) num=8;
	cur_spread=num;
}

function calcOutput(){
	var output_array = new Array();
	
	for(var i=0 ; i<cur_number ; i++ ){
		var val = (cur_ID + (i*cur_spread)) % num_of_IDs;
		val = checkForDuplicates(val, output_array);
		//outlet(0,val);
		output_array.push(val);
		}
	for(var i=0; i < output_array.length ;i++){
		positionY = (output_array[i])/3;
		positionX = (output_array[i])%3;
		//outlet(0,output_array[i]);
		outlet(0,positionX);
		outlet(0,positionY);
		outlet(0,1);
		}
	
	outlet(0,"bang"); //trigger zl.join
	outlet(1,"bang"); // trigger main output
}

function checkForDuplicates(val,output_array){
	for (var i=0;i<num_of_IDs;i++){
		if(val==output_array[i]) val+=1;
		if(val>8)val=0;
		}
	return val;
}