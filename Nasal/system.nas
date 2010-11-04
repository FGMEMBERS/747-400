## Lights ##

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.05, 1.2,], "/controls/lighting/beacon" );
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.05, 3,], "/controls/lighting/strobe" );

## Continious Ignition ##

setlistener("/controls/engines/con-ignition", func(conig){
    var conign= conig.getBoolValue();
    if(conign){
    setprop("controls/engines/engine[0]/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
    setprop("controls/engines/engine[2]/ignition",1);
    setprop("controls/engines/engine[3]/ignition",1);
    }else{
    setprop("controls/engines/engine[0]/ignition",0);
    setprop("controls/engines/engine[1]/ignition",0);
    setprop("controls/engines/engine[2]/ignition",0);
    setprop("controls/engines/engine[3]/ignition",0);
    }
},0,0);

setlistener("/controls/engines/auto-ignition", func(autoig){
    var autoign= autoig.getBoolValue();
    if(autoign){
        if (getprop("controls/engines/engine[0]/starter") == 1){
	    if (getprop("engines/engine[0]/n2") < 50){
	    setprop("controls/engines/engine[0]/ignition",1);
	    }
	}
	elsif (getprop("controls/engines/engine[1]/starter") == 1){
	    if (getprop("engines/engine[1]/n2") < 50){
	    setprop("controls/engines/engine[1]/ignition",1);
	    }
	}
	elsif (getprop("controls/engines/engine[2]/starter") == 1){
	    if (getprop("engines/engine[2]/n2") < 50){
	    setprop("controls/engines/engine[2]/ignition",1);
	    }
	}
	elsif (getprop("controls/engines/engine[3]/starter") == 1){
	    if (getprop("engines/engine[3]/n2") < 50){
	    setprop("controls/engines/engine[3]/ignition",1);
	    }
	}
    }
    else{
    setprop("controls/engines/engine[0]/ignition",0);
    setprop("controls/engines/engine[1]/ignition",0);
    setprop("controls/engines/engine[2]/ignition",0);
    setprop("controls/engines/engine[3]/ignition",0);
    }
},0,0);

## FG Autostart/Shutdown ##

var autostart = func {

	setprop("/controls/engines/engine[0]/starter",1);
	setprop("/controls/engines/engine[1]/starter",1);
	setprop("/controls/engines/engine[2]/starter",1);
	setprop("/controls/engines/engine[3]/starter",1);
	setprop("/controls/engines/engine[0]/cutoff",1);
	setprop("/controls/engines/engine[1]/cutoff",1);
	setprop("/controls/engines/engine[2]/cutoff",1);
	setprop("/controls/engines/engine[3]/cutoff",1);
	setprop("/controls/lighting/beacon",1);
	setprop("/controls/lighting/nav-lights",1);
	setprop("/controls/lighting/strobe",1);
	setprop("/controls/fuel/tank[1]/x-feed",1);
	setprop("/controls/fuel/tank[2]/x-feed",1);
	setprop("/controls/fuel/tank[3]/x-feed",1);
	setprop("/controls/fuel/tank[4]/x-feed",1);
	setprop("/controls/fuel/tank[1]/pump-aft",1);
	setprop("/controls/fuel/tank[1]/pump-fwd",1);
	setprop("/controls/fuel/tank[2]/pump-aft",1);
	setprop("/controls/fuel/tank[2]/pump-fwd",1);
	setprop("/controls/fuel/tank[3]/pump-aft",1);
	setprop("/controls/fuel/tank[3]/pump-fwd",1);
	setprop("/controls/fuel/tank[4]/pump-aft",1);
	setprop("/controls/fuel/tank[4]/pump-fwd",1);
	setprop("/controls/fuel/tank[7]/pump",1);
	if (getprop("/engines/engine[0]/n2") > 25) {
		setprop("/controls/engines/engine[0]/cutoff",0);
		setprop("/controls/engines/engine[1]/cutoff",0);
		setprop("/controls/engines/engine[2]/cutoff",0);
		setprop("/controls/engines/engine[3]/cutoff",0);
		setprop("/controls/engines/autostart",0);
	}
	if (getprop("/controls/engines/autostart")) settimer(autostart,0);
}

## Prevent gear from being retracted on ground ##

controls.gearDown = func(v) {

    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    }
	elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
    }

}