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
	setprop("/controls/electric/battery",1);
	setprop("/controls/lighting/beacon",1);
	setprop("/controls/lighting/nav-lights",1);
	setprop("/controls/lighting/strobe",1);
	setprop("/controls/lighting/logo-lights",1);
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

## Mouse drag&drop handler ##

var MouseHandler = {
  new : func() {
    var obj = { parents : [ MouseHandler ] };

    obj.property = nil;
    obj.factor = 1.0;

    obj.YListenerId = setlistener( "devices/status/mice/mouse/accel-y", 
      func(n) { obj.YListener(n); }, 1, 0 );

    return obj;
  },

  YListener : func(n) {
    me.property == nil and return;
    me.factor == 0 and return;
    n == nil and return;
    var v = n.getValue();
    v == nil and return;
    fgcommand("property-adjust", props.Node.new({ 
      "offset" : v,
      "factor" : me.factor,
      "property" : me.property
    }));
  },

  set : func( property = nil, factor = 1.0 ) {
    me.property = property;
    me.factor = factor;
  },

};

var mouseHandler = MouseHandler.new();

## Lights ##

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.05, 1.2,], "/controls/lighting/beacon" );
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.05, 3,], "/controls/lighting/strobe" );

## Liveries ##

aircraft.livery.init("Aircraft/747-400/Models/Liveries");

## Prevent gear from being retracted on ground ##

controls.gearDown = func(v) {
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    }
	elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
    }
}

## Switch click sound ##
var click_reset = func(propName) {
	setprop(propName,0);
}
controls.click = func {
	if (getprop("sim/freeze/replay-state"))
		return;
	var propName="sim/sound/click";
	setprop(propName,1);
	settimer(func { click_reset(propName) },0.4);
}

## Yoke charts ##
_setlistener("/sim/signals/fdm-initialized", func {
	setprop("/instrumentation/groundradar/id", getprop("/sim/airport/closest-airport-id"));
});