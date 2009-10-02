
var altitude = func {
	setprop("/autopilot/internals/lookahead-10-sec-altitude", getprop("/position/altitude-ft") + getprop("/velocities/vertical-speed-fps")*10 );

	settimer(altitude, 0.1);
}

_setlistener("/sim/signals/fdm-initialized", altitude); 