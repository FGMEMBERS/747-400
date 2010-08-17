V1announced = 0;
VRannounced = 0;
V2announced = 0;
V1 = "";
VR = "";
V2 = "";

var vspeeds = func {
	WT = getprop("/fdm/jsbsim/inertia/weight-lbs")*0.00045359237;
	flaps = getprop("/instrumentation/fmc/to-flap");
	if (flaps == 10) {
		V1 = (0.3*(WT-200))+100;
		VR = (0.3*(WT-200))+115;
		V2 = (0.3*(WT-200))+135;
	}
	elsif (flaps == 20) {
		V1 = (0.3*(WT-200))+95;
		VR = (0.3*(WT-200))+110;
		V2 = (0.3*(WT-200))+130;
	}
	setprop("/instrumentation/fmc/vspeeds/V1",V1);
	setprop("/instrumentation/fmc/vspeeds/VR",VR);
	setprop("/instrumentation/fmc/vspeeds/V2",V2);
	settimer(vspeeds, 1);
}

_setlistener("/sim/signals/fdm-initialized", vspeeds);