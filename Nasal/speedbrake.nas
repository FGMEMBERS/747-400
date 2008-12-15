var speedbrake = func {
 if (getprop("controls/engines/engine/throttle") == 0 and getprop("gear/gear[1]/wow") == 1 and getprop("controls/switches/speedbrake") == 1){
 setprop("controls/flight/speedbrake",1);
 }

settimer(speedbrake, 0.1);
}

_setlistener("/sim/signals/fdm-initialized", speedbrake);