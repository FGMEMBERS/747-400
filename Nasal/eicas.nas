configflapsline = 0;
configgearline = 0;
configparkbrkline = 0;
eng1fireline = 0;
eng2fireline = 0;
eng3fireline = 0;
eng4fireline = 0;

var messages = func {
	var throttle1 = getprop("/controls/engines/engine[0]/throttle");
	var throttle2 = getprop("/controls/engines/engine[0]/throttle");
	var throttle3 = getprop("/controls/engines/engine[0]/throttle");
	var throttle4 = getprop("/controls/engines/engine[0]/throttle");
	configflaps = (getprop("/gear/gear[0]/wow") == 1) and (getprop("/surface-positions/flap-pos-norm") < 0.33) and (throttle2 > 0.5) and (throttle3 > 0.5);
	configgear = (getprop("/controls/gear/gear-down") != 1) and ((throttle1 == 0) or (throttle2 == 0) or (throttle3 == 0) or (throttle4 == 0)) and ((getprop("/controls/flight/flaps/") < 0.833) or (getprop("/instrumentation/altimter/indicated-altitude-ft") < 800));
	configparkbrk = (getprop("/controls/gear/brake-parking") == 1) and (throttle2 > 0.5) and (throttle3 > 0.5);
	eng1fire = getprop("/controls/engines/engine[0]/on-fire");
	eng2fire = getprop("/controls/engines/engine[1]/on-fire");
	eng3fire = getprop("/controls/engines/engine[2]/on-fire");
	eng4fire = getprop("/controls/engines/engine[3]/on-fire");
	line1 = getprop("/instrumentation/eicas/messages/line1");
	line2 = getprop("/instrumentation/eicas/messages/line2");
	line3 = getprop("/instrumentation/eicas/messages/line3");
	line4 = getprop("/instrumentation/eicas/messages/line4");
	
	if (eng1fire == 1) {
		if ((line1 == "") and ((eng1fireline == 0) or (eng1fireline > 1))){
			line1 = "ENGINE FIRE 1";
			eng1fireline = 1;
			}
		if ((line2 == "") and ((eng1fireline == 0) or (eng1fireline > 2))){
			line2 = "ENGINE FIRE 1";
			eng1fireline = 2;
			}
		if ((line3 == "") and ((eng1fireline == 0) or (eng1fireline > 3))){
			line3 = "ENGINE FIRE 1";
			eng1fireline = 3;
			}
		if ((line4 == "") and ((eng1fireline == 0) or (eng1fireline > 4))){
			line4 = "ENGINE FIRE 1";
			eng1fireline = 4;
			}
		if ((eng1fireline != 1) and (line1 == "ENGINE FIRE 1")){
			line1 = "";
			}
		if ((eng1fireline != 2) and (line2 == "ENGINE FIRE 1")){
			line2 = "";
			}
		if ((eng1fireline != 3) and (line3 == "ENGINE FIRE 1")){
			line3 = "";
			}
		if ((eng1fireline != 4) and (line4 == "ENGINE FIRE 1")){
			line4 = "";
			}
	}
	elsif (eng1fire == 0){
		if (eng1fireline == 1){
			line1 = "";
			}
		if (eng1fireline == 2){
			line2 = "";
			}
		if (eng1fireline == 3){
			line3 = "";
			}
		if (eng1fireline == 4){
			line4 = "";
			}
		eng1fireline = 0;
	}
	
	if (eng2fire == 1) {
		if ((line1 == "") and ((eng2fireline == 0) or (eng2fireline > 1))){
			line1 = "ENGINE FIRE 2";
			eng2fireline = 1;
			}
		if ((line2 == "") and ((eng2fireline == 0) or (eng2fireline > 2))){
			line2 = "ENGINE FIRE 2";
			eng2fireline = 2;
			}
		if ((line3 == "") and ((eng2fireline == 0) or (eng2fireline > 3))){
			line3 = "ENGINE FIRE 2";
			eng2fireline = 3;
			}
		if ((line4 == "") and ((eng2fireline == 0) or (eng2fireline > 4))){
			line4 = "ENGINE FIRE 2";
			eng2fireline = 4;
			}
		if ((eng2fireline != 1) and (line1 == "ENGINE FIRE 2")){
			line1 = "";
			}
		if ((eng2fireline != 2) and (line2 == "ENGINE FIRE 2")){
			line2 = "";
			}
		if ((eng2fireline != 3) and (line3 == "ENGINE FIRE 2")){
			line3 = "";
			}
		if ((eng2fireline != 4) and (line4 == "ENGINE FIRE 2")){
			line4 = "";
			}
	}
	elsif (eng2fire == 0){
		if (eng2fireline == 1){
			line1 = "";
			}
		if (eng2fireline == 2){
			line2 = "";
			}
		if (eng2fireline == 3){
			line3 = "";
			}
		if (eng2fireline == 4){
			line4 = "";
			}
		eng2fireline = 0;
	}
	
	if (eng3fire == 1) {
		if ((line1 == "") and ((eng3fireline == 0) or (eng3fireline > 1))){
			line1 = "ENGINE FIRE 3";
			eng3fireline = 1;
			}
		if ((line2 == "") and ((eng3fireline == 0) or (eng3fireline > 2))){
			line2 = "ENGINE FIRE 3";
			eng3fireline = 2;
			}
		if ((line3 == "") and ((eng3fireline == 0) or (eng3fireline > 3))){
			line3 = "ENGINE FIRE 3";
			eng3fireline = 3;
			}
		if ((line4 == "") and ((eng3fireline == 0) or (eng3fireline > 4))){
			line4 = "ENGINE FIRE 3";
			eng3fireline = 4;
			}
		if ((eng3fireline != 1) and (line1 == "ENGINE FIRE 3")){
			line1 = "";
			}
		if ((eng3fireline != 2) and (line2 == "ENGINE FIRE 3")){
			line2 = "";
			}
		if ((eng3fireline != 3) and (line3 == "ENGINE FIRE 3")){
			line3 = "";
			}
		if ((eng3fireline != 4) and (line4 == "ENGINE FIRE 3")){
			line4 = "";
			}
	}
	elsif (eng3fire == 0){
		if (eng3fireline == 1){
			line1 = "";
			}
		if (eng3fireline == 2){
			line2 = "";
			}
		if (eng3fireline == 3){
			line3 = "";
			}
		if (eng3fireline == 4){
			line4 = "";
			}
		eng3fireline = 0;
	}
	
	if (eng4fire == 1) {
		if ((line1 == "") and ((eng4fireline == 0) or (eng4fireline > 1))){
			line1 = "ENGINE FIRE 4";
			eng4fireline = 1;
			}
		if ((line2 == "") and ((eng4fireline == 0) or (eng4fireline > 2))){
			line2 = "ENGINE FIRE 4";
			eng4fireline = 2;
			}
		if ((line3 == "") and ((eng4fireline == 0) or (eng4fireline > 3))){
			line3 = "ENGINE FIRE 4";
			eng4fireline = 3;
			}
		if ((line4 == "") and ((eng4fireline == 0) or (eng4fireline > 4))){
			line4 = "ENGINE FIRE 4";
			eng4fireline = 4;
			}
		if ((eng4fireline != 1) and (line1 == "ENGINE FIRE 4")){
			line1 = "";
			}
		if ((eng4fireline != 2) and (line2 == "ENGINE FIRE 4")){
			line2 = "";
			}
		if ((eng4fireline != 3) and (line3 == "ENGINE FIRE 4")){
			line3 = "";
			}
		if ((eng4fireline != 4) and (line4 == "ENGINE FIRE 4")){
			line4 = "";
			}
	}
	elsif (eng4fire == 0){
		if (eng4fireline == 1){
			line1 = "";
			}
		if (eng4fireline == 2){
			line2 = "";
			}
		if (eng4fireline == 3){
			line3 = "";
			}
		if (eng4fireline == 4){
			line4 = "";
			}
		eng4fireline = 0;
	}
	
	if (configflaps) {
		if ((line1 == "") and ((configflapsline == 0) or (configflapsline > 1))){
			line1 = ">CONFIG FLAPS";
			configflapsline = 1;
			}
		if ((line2 == "") and ((configflapsline == 0) or (configflapsline > 2))){
			line2 = ">CONFIG FLAPS";
			configflapsline = 2;
			}
		if ((line3 == "") and ((configflapsline == 0) or (configflapsline > 3))){
			line3 = ">CONFIG FLAPS";
			configflapsline = 3;
			}
		if ((line4 == "") and ((configflapsline == 0) or (configflapsline > 4))){
			line4 = ">CONFIG FLAPS";
			configflapsline = 4;
			}
		if ((configflapsline != 1) and (line1 == ">CONFIG FLAPS")){
			line1 = "";
			}
		if ((configflapsline != 2) and (line2 == ">CONFIG FLAPS")){
			line2 = "";
			}
		if ((configflapsline != 3) and (line3 == ">CONFIG FLAPS")){
			line3 = "";
			}
		if ((configflapsline != 4) and (line4 == ">CONFIG FLAPS")){
			line4 = "";
			}
	}
	elsif (!configflaps){
		if (configflapsline == 1){
			line1 = "";
			}
		if (configflapsline == 2){
			line2 = "";
			}
		if (configflapsline == 3){
			line3 = "";
			}
		if (configflapsline == 4){
			line4 = "";
			}
		configflapsline = 0;
	}
	
	if (configgear) {
		if ((line1 == "") and ((configgearline == 0) or (configgearline > 1))){
			line1 = ">CONFIG GEAR";
			configgearline = 1;
			}
		if ((line2 == "") and ((configgearline == 0) or (configgearline > 2))){
			line2 = ">CONFIG GEAR";
			configgearline = 2;
			}
		if ((line3 == "") and ((configgearline == 0) or (configgearline > 3))){
			line3 = ">CONFIG GEAR";
			configgearline = 3;
			}
		if ((line4 == "") and ((configgearline == 0) or (configgearline > 4))){
			line4 = ">CONFIG GEAR";
			configgearline = 4;
			}
		if ((configgearline != 1) and (line1 == ">CONFIG GEAR")){
			line1 = "";
			}
		if ((configgearline != 2) and (line2 == ">CONFIG GEAR")){
			line2 = "";
			}
		if ((configgearline != 3) and (line3 == ">CONFIG GEAR")){
			line3 = "";
			}
		if ((configgearline != 4) and (line4 == ">CONFIG GEAR")){
			line4 = "";
			}
	}
	elsif (!configgear){
		if (configgearline == 1){
			line1 = "";
			}
		if (configgearline == 2){
			line2 = "";
			}
		if (configgearline == 3){
			line3 = "";
			}
		if (configgearline == 4){
			line4 = "";
			}
		configgearline = 0;
	}
	
	if (configparkbrk) {
		if ((line1 == "") and ((configparkbrkline == 0) or (configparkbrkline > 1))){
			line1 = ">CONFIG PARK BRK";
			configparkbrkline = 1;
			}
		if ((line2 == "") and ((configparkbrkline == 0) or (configparkbrkline > 2))){
			line2 = ">CONFIG PARK BRK";
			configparkbrkline = 2;
			}
		if ((line3 == "") and ((configparkbrkline == 0) or (configparkbrkline > 3))){
			line3 = ">CONFIG PARK BRK";
			configparkbrkline = 3;
			}
		if ((line4 == "") and ((configparkbrkline == 0) or (configparkbrkline > 4))){
			line4 = ">CONFIG PARK BRK";
			configparkbrkline = 4;
			}
		if ((configparkbrkline != 1) and (line1 == ">CONFIG PARK BRK")){
			line1 = "";
			}
		if ((configparkbrkline != 2) and (line2 == ">CONFIG PARK BRK")){
			line2 = "";
			}
		if ((configparkbrkline != 3) and (line3 == ">CONFIG PARK BRK")){
			line3 = "";
			}
		if ((configparkbrkline != 4) and (line4 == ">CONFIG PARK BRK")){
			line4 = "";
			}
	}
	elsif (!configparkbrk){
		if (configparkbrkline == 1){
			line1 = "";
			}
		if (configparkbrkline == 2){
			line2 = "";
			}
		if (configparkbrkline == 3){
			line3 = "";
			}
		if (configparkbrkline == 4){
			line4 = "";
			}
		configparkbrkline = 0;
	}

	setprop("/instrumentation/eicas/messages/line1",line1);
	setprop("/instrumentation/eicas/messages/line2",line2);
	setprop("/instrumentation/eicas/messages/line3",line3);
	setprop("/instrumentation/eicas/messages/line4",line4);
	
	settimer(messages, 0.1);
}

_setlistener("/sim/signals/fdm-initialized", messages);