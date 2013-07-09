
## Brake heating ##
var gearHeating =
{
	new : func()
    {
       var m = { parents : [gearHeating]};
		me.LastSimTime = 0.0;
		me.LastSpeed = 0.0;
		me.Temperature = getprop("/environment/temperature-degc");

       m.reset();

       return m;
    },
	
	reset : func()
    {
        for(var i=0; i<5; i+=1) {
			setprop("/gear/gear["~i~"]/btms",0);
		}
		me.LastSimTime = 0.0;
		me.LastSpeed = 0.0;
		me.Temperature = getprop("/environment/temperature-degc");
    },
	
	update : func()
    {
		var CurrentTime = getprop("/sim/time/elapsed-sec");
		var CurrentSpeed = getprop("/velocities/groundspeed-kt")*KT2MPS;
        var dt = CurrentTime - me.LastSimTime;
		var dv = CurrentSpeed - me.LastSpeed;
		
		if (dt<1.0)
		{
			var OnGround = getprop("/gear/gear[1]/wow");

            if (getprop("/controls/gear/brake-parking"))
                var BrakeLevel=1.0;
            else
                var BrakeLevel = (getprop("/controls/gear/brake-left")+getprop("/controls/gear/brake-right"))/2;
			if ((OnGround)and(BrakeLevel>0))
            {
				dT = 0.5*getprop("/fdm/jsbsim/inertia/weight-lbs")*LB2KG*(me.LastSpeed*me.LastSpeed - CurrentSpeed*CurrentSpeed)/(2500*709);
				me.Temperature += dT*(1/BrakeLevel);
				
				if (me.Temperature < 176) { 
					var btms = 0;
				} else {
					# BTMS units: 0 = <176C, 9 = >788C
					var btms = int((me.Temperature-176)/72+0.5);
				}
				if (btms > 9)
					btms = 9;
					
				for(var i=1; i<5; i+=1) {
					setprop("/gear/gear["~i~"]/btms",btms);
				}
			}
			if (me.Temperature > getprop("/environment/temperature-degc")) {
				if (OnGround) 
					me.Temperature += -0.12*dt; # -0.12 C/sec = cooldown in 70 minutes from 500 degrees (BTMS 5)
				else if (getprop("/gear/gear/position-norm") == 0)
					me.Temperature += -1.2*dt; # -0.12 C/sec = cooldown in 70 minutes from 500 degrees (BTMS 5)
			}
			
			for(var i=1; i<5; i+=1) {
				setprop("/gear/gear["~i~"]/temperature-degc",me.Temperature);
			}
		}
		
		me.LastSimTime = CurrentTime;
		me.LastSpeed = CurrentSpeed;
		settimer(func { gearHeating.update(); },0.2);
	},
};

var gearHeat = gearHeating.new();

setlistener("/sim/signals/fdm-initialized",
            # executed on _every_ FDM reset (but not installing new listeners)
            func(idle) { gearHeat.reset(); },
            0,0);

settimer(func()
{
	gearHeat.update();
	print("Brake heating system... OK");
}, 5);
		 
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
	}else{
		setprop("controls/engines/engine[0]/ignition",0);
		setprop("controls/engines/engine[1]/ignition",0);
		setprop("controls/engines/engine[2]/ignition",0);
		setprop("controls/engines/engine[3]/ignition",0);
	}
},0,0);

## FG Autostart/Shutdown ##

var autostart = func {
	setprop("/sim/multiplay/chat","I'm too lazy to go through the startup procedure");
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
	setprop("/controls/lighting/landing-light-inbdl",1);
	setprop("/controls/lighting/landing-light-inbdr",1);
	setprop("/controls/lighting/landing-light-outbdl",1);
	setprop("/controls/lighting/landing-light-outbdr",1);
	setprop("/controls/lighting/logo-lights",1);
	setprop("/controls/lighting/nav-lights",1);
	setprop("/controls/lighting/strobe",1);
	setprop("/controls/lighting/taxi-lights",1);
	setprop("/controls/lighting/turnoff-light-l",1);
	setprop("/controls/lighting/turnoff-light-r",1);
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
	#setprop("/controls/engines/auto-ignition",1);
	var autostartCutoff = func {
		if (getprop("/engines/engine[0]/n2") > 25) {
			setprop("/controls/engines/engine[0]/cutoff",0);
			setprop("/controls/engines/engine[1]/cutoff",0);
			setprop("/controls/engines/engine[2]/cutoff",0);
			setprop("/controls/engines/engine[3]/cutoff",0);
			setprop("/controls/engines/autostart",0);
		} else {
			settimer(autostartCutoff,1);
		}
	};
	autostartCutoff();
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

## Repair failures/malfunctions ##
var repair = func() {
	setprop("/controls/failures/wings/broken",0);
	setprop("/controls/engines/engine[0]/on-fire",0);
	setprop("/controls/engines/engine[1]/on-fire",0);
	setprop("/controls/engines/engine[2]/on-fire",0);
	setprop("/controls/engines/engine[3]/on-fire",0);
	setprop("/controls/failures/gear[0]/stuck",0);
	setprop("/controls/failures/gear[1]/stuck",0);
	setprop("/controls/failures/gear[2]/stuck",0);
	setprop("/controls/failures/gear[3]/stuck",0);
	setprop("/controls/failures/gear[4]/stuck",0);
	gearHeating.reset();
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

## Yoke charts and other late-initialisation stuff ##
_setlistener("/sim/signals/fdm-initialized", func {
	setprop("/instrumentation/groundradar/id", getprop("/sim/airport/closest-airport-id"));
});