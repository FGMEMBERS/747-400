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

setlistener("/sim/model/start-idling", func(idle){
    var run= idle.getBoolValue();
    if(run){
    Startup();
    }else{
    Shutdown();
    }
},0,0);

var Startup = func{
setprop("controls/lighting/nav-lights",1);
setprop("controls/lighting/beacon",1);
setprop("controls/lighting/strobe",1);
setprop("controls/lighting/wing-lights",1);
setprop("controls/lighting/taxi-lights",1);
setprop("controls/lighting/logo-lights",1);
setprop("controls/lighting/cabin-lights",1);
setprop("controls/lighting/landing-lights",1);
setprop("controls/engines/con-ignition",1);
setprop("controls/engines/engine[0]/starter",1);
setprop("controls/engines/engine[1]/starter",1);
setprop("controls/engines/engine[2]/starter",1);
setprop("controls/engines/engine[3]/starter",1);
setprop("controls/engines/engine[0]/cutoff",0);
setprop("controls/engines/engine[1]/cutoff",0);
setprop("controls/engines/engine[2]/cutoff",0);
setprop("controls/engines/engine[3]/cutoff",0);
setprop("controls/engines/engine[0]/starter",0);
setprop("controls/engines/engine[1]/starter",0);
setprop("controls/engines/engine[2]/starter",0);
setprop("controls/engines/engine[3]/starter",0);
}

var Shutdown = func{
setprop("controls/lighting/nav-lights",0);
setprop("controls/lighting/beacon",0);
setprop("controls/lighting/strobe",0);
setprop("controls/lighting/wing-lights",0);
setprop("controls/lighting/taxi-lights",0);
setprop("controls/lighting/logo-lights",0);
setprop("controls/lighting/cabin-lights",0);
setprop("controls/lighting/landing-lights",0);
setprop("controls/engines/con-ignition",0);
setprop("controls/engines/engine[0]/starter",0);
setprop("controls/engines/engine[1]/starter",0);
setprop("controls/engines/engine[2]/starter",0);
setprop("controls/engines/engine[3]/starter",0);
setprop("controls/engines/engine[0]/cutoff",1);
setprop("controls/engines/engine[1]/cutoff",1);
setprop("controls/engines/engine[2]/cutoff",1);
setprop("controls/engines/engine[3]/cutoff",1);
}