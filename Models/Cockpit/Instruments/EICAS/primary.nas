# ==============================================================================
# Boeing 747-400 EICAS by Gijs de Rooy
# ==============================================================================

var eng1n1 = {};
var eng1n1ref = {};
var eng2n1 = {};
var eng2n1ref = {};
var eng3n1 = {};
var eng3n1ref = {};
var eng4n1 = {};
var eng4n1ref = {};
var eng1n1ref = {};
var text5655 = {};
var msgMemo = {};
var msgWarning = {};
var msgCaution = {};
var msgAdvisory = {};
var eng1n1rect = {};
var eng1n1maxLine = {};
var eng1n1refLine = {};
var eng1n1rpmLine = {};
var eng2n1maxLine = {};
var eng2n1refLine = {};
var eng2n1rpmLine = {};
var eng3n1maxLine = {};
var eng3n1refLine = {};
var eng3n1rpmLine = {};
var eng4n1maxLine = {};
var eng4n1refLine = {};
var eng4n1rpmLine = {};
var canvas_group = {};
var primary_dialog = {};
var eng1egt = {};
var eng2egt = {};
var eng3egt = {};
var eng4egt = {};
var fuelToRemain = {};
var fuelToRemainL = {};
var fuelTotal = {};
var fuelTemp = {};
var fuelTempL = {};
var text4283 = {};
var flapsLine = {};
var flapsL = {};
var flapsBox = {};
var eng1nai = {};
var eng2nai = {};
var eng3nai = {};
var eng4nai = {};
var wai = {};
var eng1n1bar = {};
var eng2n1bar = {};
var eng3n1bar = {};
var eng4n1bar = {};
var eng1n1bar_scale = {};
var eng2n1bar_scale = {};
var eng3n1bar_scale = {};
var eng4n1bar_scale = {};
var eng1egtBar = {};
var eng2egtBar = {};
var eng3egtBar = {};
var eng4egtBar = {};
var eng1egtBar_scale = {};
var eng2egtBar_scale = {};
var eng3egtBar_scale = {};
var eng4egtBar_scale = {};

var canvas_primary = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_primary] };
		
		var eicasP = canvas_group;
		
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(eicasP, "Aircraft/747-400/Models/Cockpit/Instruments/EICAS/primary.svg", {'font-mapper': font_mapper});
		
		eng1n1 = eicasP.getElementById("eng1n1");
		eng1n1ref = eicasP.getElementById("eng1n1ref");
		eng2n1 = eicasP.getElementById("eng2n1");
		eng2n1ref = eicasP.getElementById("eng2n1ref");
		eng3n1 = eicasP.getElementById("eng3n1");
		eng3n1ref = eicasP.getElementById("eng3n1ref");
		eng4n1 = eicasP.getElementById("eng4n1");
		eng4n1ref = eicasP.getElementById("eng4n1ref");
		text5655 = eicasP.getElementById("text5655");
		msgMemo = eicasP.getElementById("msgMemo");
		msgWarning = eicasP.getElementById("msgWarning");
		msgCaution = eicasP.getElementById("msgCaution");
		msgAdvisory = eicasP.getElementById("msgAdvisory");
		eng1n1rect = eicasP.getElementById("eng1n1rect");
		eng1n1maxLine = eicasP.getElementById("eng1n1maxLine");
		eng1n1refLine = eicasP.getElementById("eng1n1refLine");
		eng1n1rpmLine = eicasP.getElementById("eng1n1rpmLine");
		eng2n1maxLine = eicasP.getElementById("eng2n1maxLine");
		eng2n1refLine = eicasP.getElementById("eng2n1refLine");
		eng2n1rpmLine = eicasP.getElementById("eng2n1rpmLine");
		eng3n1maxLine = eicasP.getElementById("eng3n1maxLine");
		eng3n1refLine = eicasP.getElementById("eng3n1refLine");
		eng3n1rpmLine = eicasP.getElementById("eng3n1rpmLine");
		eng4n1maxLine = eicasP.getElementById("eng4n1maxLine");
		eng4n1refLine = eicasP.getElementById("eng4n1refLine");
		eng4n1rpmLine = eicasP.getElementById("eng4n1rpmLine");
		rect3032 =  eicasP.getElementById("rect3032");
		eng1egt =  eicasP.getElementById("eng1egt");
		eng2egt =  eicasP.getElementById("eng2egt");
		eng3egt =  eicasP.getElementById("eng3egt");
		eng4egt =  eicasP.getElementById("eng4egt");
		fuelToRemain =  eicasP.getElementById("fuelToRemain");
		fuelToRemainL =  eicasP.getElementById("fuelToRemainL");
		fuelTemp =  eicasP.getElementById("fuelTemp");
		fuelTempL =  eicasP.getElementById("fuelTempL");
		fuelTotal =  eicasP.getElementById("fuelTotal");
		text4283=  eicasP.getElementById("text4283");
		flapsLine =  eicasP.getElementById("flapsLine");
		flapsL =  eicasP.getElementById("flapsL");
		flapsBox =  eicasP.getElementById("flapsBox");
		eng1nai=  eicasP.getElementById("eng1nai");
		eng2nai=  eicasP.getElementById("eng2nai");
		eng3nai=  eicasP.getElementById("eng3nai");
		eng4nai=  eicasP.getElementById("eng4nai");
		wai=  eicasP.getElementById("wai");
		eng1n1bar = eicasP.getElementById("eng1n1bar").updateCenter();
		eng2n1bar = eicasP.getElementById("eng2n1bar").updateCenter();
		eng3n1bar = eicasP.getElementById("eng3n1bar").updateCenter();
		eng4n1bar = eicasP.getElementById("eng4n1bar").updateCenter();
		eng1egtBar = eicasP.getElementById("eng1egtBar").updateCenter();
		eng2egtBar = eicasP.getElementById("eng2egtBar").updateCenter();
		eng3egtBar = eicasP.getElementById("eng3egtBar").updateCenter();
		eng4egtBar = eicasP.getElementById("eng4egtBar").updateCenter();
		
		var c1 = eng1n1bar.getCenter();
		eng1n1bar.createTransform().setTranslation(-c1[0], -c1[1]);
		eng1n1bar_scale = eng1n1bar.createTransform();
		eng1n1bar.createTransform().setTranslation(c1[0], c1[1]);
		var c2 = eng2n1bar.getCenter();
		eng2n1bar.createTransform().setTranslation(-c2[0], -c2[1]);
		eng2n1bar_scale = eng2n1bar.createTransform();
		eng2n1bar.createTransform().setTranslation(c2[0], c2[1]);
		var c3 = eng3n1bar.getCenter();
		eng3n1bar.createTransform().setTranslation(-c3[0], -c3[1]);
		eng3n1bar_scale = eng3n1bar.createTransform();
		eng3n1bar.createTransform().setTranslation(c3[0], c3[1]);
		var c4 = eng4n1bar.getCenter();
		eng4n1bar.createTransform().setTranslation(-c4[0], -c4[1]);
		eng4n1bar_scale = eng4n1bar.createTransform();
		eng4n1bar.createTransform().setTranslation(c4[0], c4[1]);
		
		var c5 = eng1egtBar.getCenter();
		eng1egtBar.createTransform().setTranslation(-c5[0], -c5[1]);
		eng1egtBar_scale = eng1egtBar.createTransform();
		eng1egtBar.createTransform().setTranslation(c5[0], c5[1]);
		var c6 = eng2egtBar.getCenter();
		eng2egtBar.createTransform().setTranslation(-c6[0], -c6[1]);
		eng2egtBar_scale = eng2egtBar.createTransform();
		eng2egtBar.createTransform().setTranslation(c6[0], c6[1]);
		var c7 = eng3egtBar.getCenter();
		eng3egtBar.createTransform().setTranslation(-c7[0], -c7[1]);
		eng3egtBar_scale = eng3egtBar.createTransform();
		eng3egtBar.createTransform().setTranslation(c7[0], c7[1]);
		var c8 = eng4egtBar.getCenter();
		eng4egtBar.createTransform().setTranslation(-c8[0], -c8[1]);
		eng4egtBar_scale = eng4egtBar.createTransform();
		eng4egtBar.createTransform().setTranslation(c8[0], c8[1]);
		
		return m;
	},
	update: func()
	{	
		# Engine 1 #
		if (getprop("controls/engines/engine[0]/reverser")) {
			eng1n1ref.setText("REV");
			if (getprop("engines/engine/reverser-pos-norm") != 1) {
				eng1n1ref.setColor(1,0.5,0);
			} else {
				eng1n1ref.setColor(0,1.0,0);
			}
			eng1n1refLine.hide();
		} else {
			eng1n1ref.setText(sprintf("%3.01f",92.5*getprop("controls/engines/engine[0]/throttle")+25));
			eng1n1refLine.show();
			eng1n1refLine.setTranslation(0,-150.957*getprop("controls/engines/engine[0]/throttle")-64.043);
		}
		eng1n1.setText(sprintf("%3.01f",getprop("engines/engine[0]/n1")));
		eng1n1maxLine.setTranslation(0,-175);
		eng1n1rpmLine.setTranslation(0,-215);
		if (getprop("engines/engine[0]/n1") != nil){
			eng1n1bar_scale.setScale(1, getprop("engines/engine[0]/n1")/117.5);
			if(getprop("engines/engine[0]/n1") >= 117.5) {
				eng1n1bar.setColor(1,0,0);
			} else {
				eng1n1bar.setColor(1,1,1);
			}
		}
		if (getprop("engines/engine[0]/egt-degf") != nil) {
			eng1egt.setText(sprintf("%3.0f",(getprop("engines/engine[0]/egt-degf")-32)/1.8));
			eng1egtBar_scale.setScale(1, ((getprop("engines/engine[0]/egt-degf")-32)/1.8)/960);
			if ((getprop("engines/engine[0]/egt-degf")-32)/1.8 >= 960) {
				eng1egt.setColor(1,0,0);
				eng1egtBar.setColor(1,0,0);
			} elsif ((getprop("engines/engine[0]/egt-degf")-32)/1.8 >= 925) {
				eng1egt.setColor(1,0.5,0);
				eng1egtBar.setColor(1,0.5,0);
			} else {
				eng1egt.setColor(1,1,1);
				eng1egtBar.setColor(1,1,1);
			}
		}
		
		# Engine 2 #
		if (getprop("controls/engines/engine[1]/reverser")) {
			eng2n1ref.setText("REV");
			if (getprop("engines/engine[1]/reverser-pos-norm") != 1) {
				eng2n1ref.setColor(1,0.5,0);
			} else {
				eng2n1ref.setColor(0,1.0,0);
			}
			eng2n1refLine.hide();
		} else {
			eng2n1ref.setText(sprintf("%3.01f",92.5*getprop("controls/engines/engine[1]/throttle")+25));
			eng2n1refLine.show();
			eng2n1refLine.setTranslation(0,-150.957*getprop("controls/engines/engine[1]/throttle")-64.043);
		}
		eng2n1.setText(sprintf("%3.01f",getprop("engines/engine[1]/n1")));
		eng2n1maxLine.setTranslation(0,-175);
		eng2n1rpmLine.setTranslation(0,-215);
		if (getprop("engines/engine[1]/n1") != nil){
			eng2n1bar_scale.setScale(1, getprop("engines/engine[1]/n1")/117.5);
			if(getprop("engines/engine[1]/n1") == 117.5) {
				eng2n1bar.setColor(1,0,0);
			} else {
				eng2n1bar.setColor(1,1,1);
			}
		}
		if (getprop("engines/engine[1]/egt-degf") != nil) {
			eng2egt.setText(sprintf("%3.0f",(getprop("engines/engine[1]/egt-degf")-32)/1.8));
			eng2egtBar_scale.setScale(1, ((getprop("engines/engine[1]/egt-degf")-32)/1.8)/960);
			if ((getprop("engines/engine[1]/egt-degf")-32)/1.8 >= 960) {
				eng2egt.setColor(1,0,0);
				eng2egtBar.setColor(1,0,0);
			} elsif ((getprop("engines/engine[1]/egt-degf")-32)/1.8 >= 925) {
				eng2egt.setColor(1,0.5,0);
				eng2egtBar.setColor(1,0.5,0);
			} else {
				eng2egt.setColor(1,1,1);
				eng2egtBar.setColor(1,1,1);
			}
		}
		
		# Engine 3 #
		if (getprop("controls/engines/engine[2]/reverser")) {
			eng3n1ref.setText("REV");
			if (getprop("engines/engine[2]/reverser-pos-norm") != getprop("controls/engines/engine[2]/reverser")) {
				eng3n1ref.setColor(1,0.5,0);
			} else {
				eng3n1ref.setColor(0,1.0,0);
			}
			eng3n1refLine.hide();
		} else {
			eng3n1ref.setText(sprintf("%3.01f",92.5*getprop("controls/engines/engine[2]/throttle")+25));
			eng3n1refLine.show();
			eng3n1refLine.setTranslation(0,-150.957*getprop("controls/engines/engine[2]/throttle")-64.043);
		}
		eng3n1.setText(sprintf("%3.01f",getprop("engines/engine[2]/n1")));
		eng3n1maxLine.setTranslation(0,-175);
		eng3n1rpmLine.setTranslation(0,-215);
		if (getprop("engines/engine[2]/n1") != nil){
			eng3n1bar_scale.setScale(1, getprop("engines/engine[2]/n1")/117.5);
			if(getprop("engines/engine[2]/n1") == 117.5) {
				eng3n1bar.setColor(1,0,0);
			} else {
				eng3n1bar.setColor(1,1,1);
			}
		}
		if (getprop("engines/engine[2]/egt-degf") != nil) {
			eng3egt.setText(sprintf("%3.0f",(getprop("engines/engine[2]/egt-degf")-32)/1.8));
			eng3egtBar_scale.setScale(1, ((getprop("engines/engine[2]/egt-degf")-32)/1.8)/960);
			if ((getprop("engines/engine[2]/egt-degf")-32)/1.8 >= 960) {
				eng3egt.setColor(1,0,0);
				eng3egtBar.setColor(1,0,0);
			} elsif ((getprop("engines/engine[2]/egt-degf")-32)/1.8 >= 925) {
				eng3egt.setColor(1,0.5,0);
				eng3egtBar.setColor(1,0.5,0);
			} else {
				eng3egt.setColor(1,1,1);
				eng3egtBar.setColor(1,1,1);
			}
		}
		
		if (getprop("controls/engines/engine[3]/reverser")) {
			eng4n1ref.setText("REV");
			if (getprop("engines/engine[3]/reverser-pos-norm") != 1) {
				eng4n1ref.setColor(1,0.5,0);
			} else {
				eng4n1ref.setColor(0,1.0,0);
			}
			eng4n1refLine.hide();
		} else {
			eng4n1ref.setText(sprintf("%3.01f",92.5*getprop("controls/engines/engine[3]/throttle")+25));
			eng4n1refLine.show();
			eng4n1refLine.setTranslation(0,-150.957*getprop("controls/engines/engine[3]/throttle")-64.043);
		}
		eng4n1.setText(sprintf("%3.01f",getprop("engines/engine[3]/n1")));
		eng4n1maxLine.setTranslation(0,-175);
		eng4n1rpmLine.setTranslation(0,-215);
		if (getprop("engines/engine[3]/n1") != nil){
			eng4n1bar_scale.setScale(1, getprop("engines/engine[3]/n1")/117.5);
			if(getprop("engines/engine[3]/n1") == 117.5) {
				eng4n1bar.setColor(1,0,0);
			} else {
				eng4n1bar.setColor(1,1,1);
			}
		}
		if (getprop("engines/engine[3]/egt-degf") != nil) {
			eng4egt.setText(sprintf("%3.0f",(getprop("engines/engine[3]/egt-degf")-32)/1.8));
			eng4egtBar_scale.setScale(1, ((getprop("engines/engine[3]/egt-degf")-32)/1.8)/960);
			if ((getprop("engines/engine[3]/egt-degf")-32)/1.8 >= 960) {
				eng4egt.setColor(1,0,0);
				eng4egtBar.setColor(1,0,0);
			} elsif ((getprop("engines/engine[3]/egt-degf")-32)/1.8 >= 925) {
				eng4egt.setColor(1,0.5,0);
				eng4egtBar.setColor(1,0.5,0);
			} else {
				eng4egt.setColor(1,1,1);
				eng4egtBar.setColor(1,1,1);
			}
		}
		
		text5655.setText(sprintf("%+03.0f",getprop("environment/temperature-degc")));
		fuelTotal.setText(sprintf("%03.01f",getprop("fdm/jsbsim/propulsion/total-fuel-lbs")*LB2KG/1000));
		if (getprop("/fdm/jsbsim/propulsion/jettison-flow-rates") > 0) {
			fuelToRemain.show();
			fuelToRemainL.show();
			fuelTemp.hide();
			fuelTempL.hide();
			fuelToRemain.setText(sprintf("%03.01f",getprop("controls/fuel/fuel-to-remain-lbs")*LB2KG/1000));
		} else {
			fuelToRemain.hide();
			fuelToRemainL.hide();
			fuelTemp.show();
			fuelTempL.show();
		}
		msgWarning.setText(getprop("instrumentation/eicas/msg/warning"));
		msgCaution.setText(getprop("instrumentation/eicas/msg/caution"));
		msgAdvisory.setText(getprop("instrumentation/eicas/msg/advisory"));
		msgMemo.setText(getprop("instrumentation/eicas/msg/memo"));
		
		if (getprop("surface-positions/flap-pos-norm") == 0 and getprop("controls/flight/flaps") == 0) {
			text4283.hide();
			flapsLine.hide();
			flapsL.hide();
			flapsBox.hide();
		} else {
			text4283.show();
			flapsLine.show();
			flapsL.show();
			flapsBox.show();
			if (getprop("controls/flight/flaps") != getprop("surface-positions/flap-pos-norm")) {
				text4283.setColor(1,0,1);
				flapsLine.setColor(1,0,1);
			} else {
				text4283.setColor(0,1,0);
				flapsLine.setColor(0,1,0);
			}
			text4283.setText(sprintf("%2.0f",getprop("controls/flight/flaps")*30));
			flapsLine.setTranslation(0,157*getprop("controls/flight/flaps"));
			text4283.setTranslation(0,157*getprop("controls/flight/flaps"));
		}
		if (getprop("controls/anti-ice/engine/inlet-heat")) {
			eng1nai.show();
		} else {
			eng1nai.hide();
		}
		if (getprop("controls/anti-ice/engine[1]/inlet-heat")) {
			eng2nai.show();
		} else {
			eng2nai.hide();
		}
		if (getprop("controls/anti-ice/engine[2]/inlet-heat")) {
			eng3nai.show();
		} else {
			eng3nai.hide();
		}
		if (getprop("controls/anti-ice/engine[3]/inlet-heat")) {
			eng4nai.show();
		} else {
			eng4nai.hide();
		}
		if (getprop("controls/anti-ice/wing-heat")) {
			wai.show();
		} else {
			wai.hide();
		}

		settimer(func me.update(), 0);
	}
};

setlistener("/nasal/canvas/loaded", func {
	var my_canvas = canvas.new({
		"name": "EICASPrimary",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	my_canvas.addPlacement({"node": "Upper-EICAS-Screen"});
	var group = my_canvas.createGroup();
	var demo = canvas_primary.new(group);
	demo.update();
}, 1);