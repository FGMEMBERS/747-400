var autobrake = func {
if (getprop("controls/engines/engine/throttle") == 0 and getprop("gear/gear[1]/wow") == 1 and getprop("controls/switches/autobrake") > 0){ 
 setprop("controls/gear/brake-left", getprop("controls/switches/autobrake") / 5); 
 setprop("controls/gear/brake-right", getprop("controls/switches/autobrake") / 5); 
}
settimer(autobrake, 0.1);
}

_setlistener("/sim/signals/fdm-initialized", autobrake);


var speedbrake = func { 

 if (getprop("controls/engines/engine/throttle") == 0 and getprop("gear/gear[1]/wow") == 1 and getprop("controls/switches/speedbrake") == 1){
 setprop("controls/flight/speedbrake",1);
 }


settimer(speedbrake, 0.1);
}

_setlistener("/sim/signals/fdm-initialized", speedbrake);


var update_seatbelt_sign = func { 
  if (getprop("position/altitude-agl-ft") > 10000){
  setprop("controls/switches/seatbelt-sign",0);
 }
  if (getprop("position/altitude-agl-ft") < 10000){
  setprop("controls/switches/seatbelt-sign",1);
 }
settimer(update_seatbelt_sign, 1); 
}

_setlistener("/sim/signals/fdm-initialized", update_seatbelt_sign); 
