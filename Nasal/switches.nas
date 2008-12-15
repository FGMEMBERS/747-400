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
