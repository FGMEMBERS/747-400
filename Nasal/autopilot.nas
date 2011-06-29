####    autopilot help-functions                                                               ####
####    Author: Markus Bulik                                                                   ####
####    This file is licenced under the terms of the GNU General Public Licence V2 or later    ####


var abs = func(n) { return(n < 0 ? -n : n); }
var maxclambed = func(n, m, clamb) {
	if (n > m) {
		return (n < clamb ? n : clamb);
	}
	else {
		return (m < clamb ? m : clamb);
	}
}

var listenerApInitFunc = func {
	# do initializations of new properties

	setprop("/autopilot/internal/target-kp-for-altitude-vspeed-hold", -0.0095);
	setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", 0.00001);
	setprop("/autopilot/internal/target-ti-for-altitude-vspeed-hold", 10.0);
	setprop("/autopilot/internal/target-airspeed-factor-for-altitude-hold", 0.05);
	setprop("/autopilot/internal/target-climb-rate-fps", 0.0);

	setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min", 0.0);
	setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max", 0.0);

	setprop("/autopilot/internal/vertical-speed-fpm-clambed", 2400.0);
	setprop("/autopilot/internal/vspeed-altidude-controller-is-elapsed", 1);

	setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", 0.05);
	setprop("/autopilot/internal/target-ti-for-heading-hold", 15.0);
	setprop("/autopilot/internal/target-td-for-heading-hold", 0.0005);
	setprop("/autopilot/internal/target-kp-for-heading-hold-rudder", -0.005);

	setprop("/autopilot/internal/nav1-stear-ground-mode", 0.0);
	setprop("/autopilot/internal/nav1-pitch-deg-ground-mode", 0.0);
	setprop("/autopilot/internal/nav1-vspeed-ground-mode", 0);
	setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -450.0);
	setprop("/autopilot/internal/nav1-kp-for-throttle-ground-mode", 0.03);
	setprop("/autopilot/internal/VOR-near-by", 0);
	setprop("/autopilot/internal/target-roll-deg-for-VOR-near-by", 0.0);
	setprop("/autopilot/internal/kp-for-gs-hold", -0.015);
	setprop("/autopilot/internal/gs-rate-of-climb-scale-factor", 1.0);

	setprop("/autopilot/internal/route-manager-waypoint-near-by", 0);
}
setlistener("/sim/signals/fdm-initialized", listenerApInitFunc);


###############################################
## altitude hold,                            ##
## vertical speed hold - objects/functions   ##
###############################################

## special pid-control-adjust for altitude-hold
# Params: Kp, Kp-max, Kp-min, Ti, Td
var AltitudeHoldPidControllerAdjust = {
	new : func(kp, kpMinClamb, kpMaxClamb, ti, td) {
	m = { parents : [AltitudeHoldPidControllerAdjust] };

		m.kp = kp;				# initial Kp-value of the pid-controller
		m.correctedKp = m.kp;		# corrected Kp-value of the pid-controller
		m.kpMinClamb = kpMinClamb;		# minimal value for kp
		m.kpMaxClamb = kpMaxClamb;		# maximal value for kp
		m.ti = ti;
		m.td = td;

		m.kpInterpolate = 0;
		m.kpInterpolationIncrement = 0;
		m.kpInterpolationLastKp = m.kp;
		m.kpInterpolationIsRunning = 0;

		m.tdInterpolate = 0;
		m.tdInterpolationCounter = 0;
		m.tdInterpolationIncrement = 0.00001;
		m.tdInterpolationIsRunning = 0;

		# tank-geometry

		m.tank0Geometry = {"y": 0,      "x": 0,    "tank": "/consumables/fuel/tank[0]/level-gal_us"};
		m.tank1Geometry = {"y": -1000,  "x": 500,  "tank": "/consumables/fuel/tank[1]/level-gal_us"};
		m.tank2Geometry = {"y": -700,   "x": 300,  "tank": "/consumables/fuel/tank[2]/level-gal_us"};
		m.tank3Geometry = {"y": -300,   "x": 100,  "tank": "/consumables/fuel/tank[3]/level-gal_us"};
		m.tank4Geometry = {"y": 300,    "x": 100,  "tank": "/consumables/fuel/tank[4]/level-gal_us"};
		m.tank5Geometry = {"y": 700,    "x": 300,  "tank": "/consumables/fuel/tank[5]/level-gal_us"};
		m.tank6Geometry = {"y": 1000,   "x": 500,  "tank": "/consumables/fuel/tank[6]/level-gal_us"};
		m.tank7Geometry = {"y": 0,      "x": 1400, "tank": "/consumables/fuel/tank[7]/level-gal_us"};

		m.totalGalUS = 200000.0;
		m.xMoment = 320.0;
		m.xMomentThreshold = 320.0;

		return m;
	},

	calculateXMoment : func() {
		me.totalGalUS = getprop(me.tank0Geometry["tank"]) +
				getprop(me.tank1Geometry["tank"]) +
				getprop(me.tank2Geometry["tank"]) +
				getprop(me.tank3Geometry["tank"]) +
				getprop(me.tank4Geometry["tank"]) +
				getprop(me.tank5Geometry["tank"]) +
				getprop(me.tank6Geometry["tank"]) +
				getprop(me.tank7Geometry["tank"]);
		if (me.totalGalUS > 0) {	# avoid division by zero
			me.xMoment = (getprop(me.tank0Geometry["tank"]) * me.tank0Geometry["x"] +
					getprop(me.tank1Geometry["tank"]) * me.tank1Geometry["x"] +
					getprop(me.tank2Geometry["tank"]) * me.tank2Geometry["x"] +
					getprop(me.tank3Geometry["tank"]) * me.tank3Geometry["x"] +
					getprop(me.tank4Geometry["tank"]) * me.tank4Geometry["x"] +
					getprop(me.tank5Geometry["tank"]) * me.tank5Geometry["x"] +
					getprop(me.tank6Geometry["tank"]) * me.tank6Geometry["x"] +
					getprop(me.tank7Geometry["tank"]) * me.tank7Geometry["x"]) / me.totalGalUS;
		}
	},

	# Params: Kp, Kp-max, Kp-min, Ti, Td
	init : func(kp, kpMinClamb, kpMaxClamb, ti, td) {
		me.kp = kp;
		me.kpMinClamb = kpMinClamb;
		me.kpMaxClamb = kpMaxClamb;
		me.ti = ti;
		me.td = td;
		me.correctedKp = me.kp;

		me.kpInterpolate = 0;
		me.kpInterpolationIncrement = 0;
		me.kpInterpolationLastKp = m.kp;
		me.kpInterpolationIsRunning = 0;

		me.tdInterpolate = 0;
		me.tdInterpolationCounter = 0;
		me.tdInterpolationIncrement = 0.00001;
		me.tdInterpolationIsRunning = 0;
	},

	# may be called from outside, if smooth iterpolation of Kp value is required
	interpolateKp : func(iterations) {
		if (me.kpInterpolationIsRunning == 0) {
			me.kpInterpolate = 0.0;
			me.kpInterpolationLastKp = me.correctedKp;
			me.kpInterpolationIncrement = me.kpInterpolationLastKp / iterations;

			#print ("AltitudeHoldPidControllerAdjust: kpInterpolationIncrement=", me.kpInterpolationIncrement);

			me.kpInterpolationIsRunning = 1;
		}
	},

	clambKp : func() {
		# clamb kp

		if (me.kpInterpolationIsRunning == 0) {
			me.correctedKp = (me.correctedKp < me.kpMinClamb ? me.kpMinClamb : me.correctedKp);
			me.correctedKp = (me.correctedKp > me.kpMaxClamb ? me.kpMaxClamb : me.correctedKp);
		}
		else {
			me.kpInterpolate += me.kpInterpolationIncrement;
			if (me.kpInterpolationIncrement > 0) {
				if (me.kpInterpolate >= me.kpInterpolationLastKp) {
					me.kpInterpolationIsRunning = 0;
				}
			}
			else {
				if (me.kpInterpolate <= me.kpInterpolationLastKp) {
					me.kpInterpolationIsRunning = 0;
				}
			}
			me.correctedKp = me.kpInterpolate;
		}

		#print ("AltitudeHoldPidControllerAdjust: clambKp -> me.correctedKp=", me.correctedKp);
	},

	# deal with altitude
	kpAltitudeFunc : func (altitudeFt, kp, kpFactor) {
		if (altitudeFt > 10000.0) {
			if (altitudeFt < 35000.0) {
				kp = kp  + ((altitudeFt - 10000.0) * kpFactor);
			}
			else {
				# substruction clambed at 35000 ft and higher
				kp = kp  + ((35000.0 - 10000.0) * kpFactor);
			}
		}
		return kp;
	},

	# overwrite this method from parent 'PidControllerKpAdjust'
	# params: lbs : the total weight in lbs
	calculateKp : func(lbs, airspeedKt, altitudeFt) {

		me.correctedKp = me.kp;

		if (airspeedKt < 190.0) {
			me.correctedKp = -0.015;
		}
		else {
			# deal with weight
			if (lbs > 160000.0) {
				# -> gets '-0.00149' at 400.0000 lbs
				me.correctedKp += (lbs - 160000.0) * 0.000000037;

				# deal with altitude - gets a substraction of '-0.0004' at 300000 feet
				me.correctedKp = me.kpAltitudeFunc(altitudeFt, me.correctedKp, 0.00000002);
			}
			else {
				# deal with altitude - gets a substraction of '-0.0006' at 300000 feet
				me.correctedKp = me.kpAltitudeFunc(altitudeFt, me.correctedKp, 0.00000003);
			}

			# experimental: Kp must depend on xMoment

			me.calculateXMoment();

			if (lbs < 200000.0 and airspeedKt < 270.0) {
				me.correctedKp = me.correctedKp + ((me.xMomentThreshold - me.xMoment) * 0.000016);
			}
			else {
				me.correctedKp = me.correctedKp - ((me.xMomentThreshold - me.xMoment) * 0.00003);
				if (lbs < 250000.0) {
					me.correctedKp = ((me.correctedKp < -0.008) ? -0.008 : me.correctedKp); # clamb
				}
				else {
					me.correctedKp = ((me.correctedKp < -0.003) ? -0.003 : me.correctedKp); # clamb
				}
			}

			if (airspeedKt > 360.0) {
				me.correctedKp += (airspeedKt - 360.0) * 0.00004;
				me.correctedKp = ((me.correctedKp > -0.001) ? -0.001 : me.correctedKp); # clamb
			}
		}
	},


	# adjusts 'Kp' value
	# params: error: the error of the controlled parameter
	#         xMoment: the actual x-moment
	#         lbs  : the total weight in lbs
	#         airspeedKt: the actual airspeed in knots
	#         altitudeFt: actual altitude in feet
	# this routine must be called cyclic in certain time-intervalls
	adjustKp : func(lbs, airspeedKt, altitudeFt) {

		if (me.kpInterpolationIsRunning == 0) {
			me.calculateKp(lbs, airspeedKt, altitudeFt);
		}
		me.clambKp();

		#print("AltitudeHoldPidControllerAdjust: correctedKp=", me.correctedKp);
		setprop("/autopilot/internal/target-kp-for-altitude-vspeed-hold", me.correctedKp);
	},


	# may be called from outside, if smooth iterpolation of Td value is required
	interpolateTd : func() {
		#print ("AltitudeHoldPidControllerAdjust: interpolateTd ...");
		me.tdInterpolationCounter = 30;
		me.tdInterpolate = 0.0;
		me.tdInterpolationIsRunning = 1;
		me.tdInterpolationIncrement = 0.00001;
	},

	# adusts 'Td' value
	# this routine must be called cyclic in certain time-intervalls
	adjustTd : func(lbs, airspeedKt, altitudeFt) {

		# experimental me.td: initial: 1.5

		if (airspeedKt < 190.0) {
			#setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", 0.16);
			setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", 0.002);
 		}
		else {
			var td = me.td;
			if (me.tdInterpolationIsRunning == 1 and me.tdInterpolate < me.td) {

				if (me.tdInterpolationCounter > 0) {
					me.tdInterpolationCounter -= 1;
					if (me.tdInterpolationCounter > 1) {
						# begin increment: increasing reciprocal with time (me.tdInterpolationCounter) from 0.00167 to 0.05
						me.tdInterpolationIncrement = 1 / (me.tdInterpolationCounter * me.tdInterpolationCounter);
					}
				}

				me.tdInterpolate += me.tdInterpolationIncrement;
				setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", me.tdInterpolate);
				#print ("AltitudeHoldPidControllerAdjust: adjustTd -> me.tdInterpolate=", me.tdInterpolate);
			}
			else {
				me.tdInterpolationCounter = 0;
				tdInterpolationIsRunning = 0;
				setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", td);
			}
		}
		#print ("AltitudeHoldPidControllerAdjust: td=", getprop("/autopilot/internal/target-td-for-altitude-vspeed-hold"));
	},

	# adusts 'Ti' value
	# this routine must be called cyclic in certain time-intervalls
	adjustTi : func(lbs, airspeedKt, altitudeFt) {

		if (airspeedKt < 190.0) {
			me.ti = 50.0;
		}
		else {
			me.ti = 10.0;
			if (lbs > 160000.0) {
				if (airspeedKt < 250.0) {
					me.ti = 30.0;
				}
			}
		}
		#print ("AltitudeHoldPidControllerAdjust: me.ti=", me.ti);
		setprop("/autopilot/internal/target-ti-for-altitude-vspeed-hold", me.ti);
	},

	# adusts 'Kp' value for first altitude-PID-controller (Stage 1: determine appropriate vertical-speed)
	adjustAirspeedKp : func(airspeedKt) {
		# deal with airspeed (own factor), airspeed-dependent factor (0.011 - 0.0176), if speed < 220 kts, 0.05 if speed > 250 kts

		var airspeedKp = 0.05;

		#print ("Airspeed-KT=", airspeedKt);

		if (airspeedKt < 190.0) {
			airspeedKp = 0.02;
		}
		else {
			airspeedDiff = (airspeedKt - 240.0);
			if (airspeedDiff < 0) {
				# if airspeed < 240 kt substruct an amount from 'airspeedKp'
				var newAirspeedKp = airspeedKp - (abs(airspeedDiff) * 0.001);
				if (newAirspeedKp > 0.011) {
					airspeedKp = newAirspeedKp;
				}
				else {
					# not less than '0.011'
					airspeedKp = 0.011;
				}
				#print ("1: airspeedDiff=", airspeedDiff, "  airspeedKp=", airspeedKp);

				# if airspeed < 200 add a small amount to 'airspeedKp' again
				if (airspeedDiff < -40.0) {
					airspeedDiff = (airspeedDiff + 40.0);
					airspeedKp = airspeedKp + (abs(airspeedDiff) * 0.0001);
					#print ("2: airspeedDiff=", airspeedDiff, "  airspeedKp=", airspeedKp);
				}
			}
		}
		#print ("airspeedKp=", airspeedKp);
		setprop("/autopilot/internal/target-airspeed-factor-for-altitude-hold", airspeedKp);

		return airspeedKp;
	}
};


var altitudePidControllerAdjust = AltitudeHoldPidControllerAdjust.new(-0.0095, -0.017, -0.002, 10.0, 1.5);


# vars for vertical-speed-hold
var apVerticalSpeedFpm = getprop("/autopilot/settings/vertical-speed-fpm");
var apVerticalSpeedFpmClambed = getprop("/autopilot/internal/vertical-speed-fpm-clambed");

var apVerticalSpeedTimerFunc = func {
	#print ("-> apVerticalSpeedTimerFunc -> running");
	apVerticalSpeedFpm = getprop("/autopilot/settings/vertical-speed-fpm");

	var verticalSpeedDiff = apVerticalSpeedFpm - apVerticalSpeedFpmClambed;
	if (abs(verticalSpeedDiff) > 40) {
		if (verticalSpeedDiff > 0) {
			apVerticalSpeedFpmClambed += 40.0;
		}
		else {
			apVerticalSpeedFpmClambed -= 40.0;
		}
		setprop("/autopilot/internal/vertical-speed-fpm-clambed", apVerticalSpeedFpmClambed);
		#print("apVerticalSpeedFpmClambed=", apVerticalSpeedFpmClambed);

		settimer(apVerticalSpeedTimerFunc, 0.2);
	}
}

var apAltitudeClambClimbRate = func(interpolateSeconds) {
	var targetClimbRateFps = getprop("/velocities/vertical-speed-fps");
	#print("targetClimbRateFps=", targetClimbRateFps);
	setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min", targetClimbRateFps);
	setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max", targetClimbRateFps + 0.0001);

	# set min-/max-climbrate
	var initMaxClimbRate = 30.0;
	var totalFuelLbs = getTotalFuelLbs();
	var initMinClimbRate = -18.0;
	if (totalFuelLbs > 160000.0) {
		initMaxClimbRate = 18.0;
		initMinClimbRate = -15.0;
	}
	if (getprop("/velocities/airspeed-kt") < 190.0) {
		initMaxClimbRate -= (190.0 - getprop("/velocities/airspeed-kt")) * 0.6;
		initMaxClimbRate = (initMaxClimbRate < 1 ? 1 : initMaxClimbRate);
	}

	interpolate("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min",
			initMinClimbRate, interpolateSeconds);
	interpolate("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max",
			initMaxClimbRate, interpolateSeconds);
}

var listenerApAltitudeClambFunc = func {
	if (getprop("/autopilot/locks/altitude") == "altitude-hold") {
		apAltitudeClambClimbRate(5.0);
	}
	elsif (getprop("/autopilot/locks/altitude") == "vertical-speed-hold") {
		apVerticalSpeedFpm = getprop("/autopilot/settings/vertical-speed-fpm");
		# initialize with actual vertical-speed
		apVerticalSpeedFpmClambed = getprop("/velocities/vertical-speed-fps") * 60;
		apVerticalSpeedTimerFunc();
	}

	altitudePidControllerAdjust.interpolateKp(50);
	altitudePidControllerAdjust.interpolateTd();
}

setlistener("/autopilot/locks/altitude", listenerApAltitudeClambFunc);
setlistener("/autopilot/settings/target-altitude-ft", listenerApAltitudeClambFunc);
setlistener("/autopilot/settings/vertical-speed-fpm", listenerApAltitudeClambFunc);


var getTotalFuelLbs = func {
	return( getprop("/consumables/fuel/tank/level-lbs") +
		getprop("/consumables/fuel/tank[1]/level-lbs") +
		getprop("/consumables/fuel/tank[2]/level-lbs") +
		getprop("/consumables/fuel/tank[3]/level-lbs") +
		getprop("/consumables/fuel/tank[4]/level-lbs") +
		getprop("/consumables/fuel/tank[5]/level-lbs") +
		getprop("/consumables/fuel/tank[6]/level-lbs") +
		getprop("/consumables/fuel/tank[7]/level-lbs") );
}


var lbs = 0.0;
var altitudeFt = 0.0;
var airspeedKt = 0.0;

var listenerApAltitudeKpFunc = func {

	if (  getprop("/autopilot/locks/altitude") == "altitude-hold" or
		getprop("/autopilot/locks/altitude") == "vertical-speed-hold" or
		getprop("/autopilot/locks/altitude") == "gs1-hold") {

		#print("listenerApAltitudeKpFunc -> altitude-hold");

		# get live parameter
		lbs = getTotalFuelLbs();
		altitudeFt = getprop("/position/altitude-ft");
		altitudeFtError = getprop("/autopilot/settings/target-altitude-ft") - getprop("/instrumentation/altimeter/indicated-altitude-ft");
		airspeedKt = getprop("/velocities/airspeed-kt");
		pitchDeg = getprop("/orientation/pitch-deg");


		## adjusts Kp-, Ti-, Td-properties ##
		altitudePidControllerAdjust.adjustAirspeedKp(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustKp(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustTi(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustTd(lbs, airspeedKt, altitudeFt);

		settimer(listenerApAltitudeKpFunc, 0.2);
	}
}

setlistener("/autopilot/locks/altitude", listenerApAltitudeKpFunc);



#################################################
## heading bug / true heading hold / NAV1-hold ##
#################################################

var listenerApHeadingClambFunc = func {
	if (	getprop("/autopilot/locks/heading") == "dg-heading-hold" or
		getprop("/autopilot/locks/heading") == "true-heading-hold" or
		getprop("/autopilot/locks/heading") == "nav1-hold") {

		setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", 0.0);
		#print ("-> listenerApHeadingValueChangeClambFunc -> installed");
	}
}

# do not enable 'true-heading-deg', because of route-manager activates the function permanently
# setlistener("/autopilot/settings/true-heading-deg", listenerApHeadingClambFunc);
setlistener("/autopilot/settings/heading-bug-deg", listenerApHeadingClambFunc);
setlistener("/autopilot/locks/heading", listenerApHeadingClambFunc);
# setlistener("/autopilot/settings/gps-driving-true-heading", listenerApHeadingClambFunc);

# make adjustments for heading-hold controllers
var listenerApHeadingFunc = func {
	if (	getprop("/autopilot/locks/heading") == "dg-heading-hold" or
		getprop("/autopilot/locks/heading") == "true-heading-hold" or
		getprop("/autopilot/locks/heading") == "nav1-hold") {

		var tiAirspeedForHeadingHold = 10.0;
		airspeedKt = getprop("/velocities/airspeed-kt");
		if (airspeedKt < 220.0) {
			tiAirspeedForHeadingHold += (220.0 - airspeedKt);
		}
		setprop("/autopilot/internal/target-ti-airspeed-for-heading-hold", tiAirspeedForHeadingHold);


		# experimantal:
		#<!-- lt 180 kts -->
		#<!--<gain>-0.007</gain>-->
		#
		#<!-- gt 180 kts, lt 300 kts -->
		#<!--<gain>-0.01</gain>-->
		#
		#<!-- gt 300 kts -->
		#<!--<gain>-0.006</gain>-->
		#
		#<!-- 310 kts, 35000 ft ==> altitude-factor NEEDED !!! -->
		#<gain>-0.003</gain>
		#

		altitudeFt = getprop("/position/altitude-ft");

		var gainForAirspeedFactor = -0.01;
		if (airspeedKt < 180.0) {
			gainForAirspeedFactor += (180.0 - airspeedKt) * 0.0002;
			gainForAirspeedFactor = (gainForAirspeedFactor > -0.002 ? -0.002 : gainForAirspeedFactor);
		}
		elsif (airspeedKt > 300.0) {
			gainForAirspeedFactor += (airspeedKt - 300.0) * 0.00008;
			gainForAirspeedFactor = (gainForAirspeedFactor > -0.003 ? -0.003 : gainForAirspeedFactor);
		}

		if (altitudeFt > 18000.0) {
			gainForAirspeedFactor += (altitudeFt -18000.0) * 0.0000004;
			gainForAirspeedFactor = (gainForAirspeedFactor > -0.003 ? -0.003 : gainForAirspeedFactor);
		}
		#print ("gainForAirspeedFactor=", gainForAirspeedFactor);
		setprop("/autopilot/internal/target-gain-airspeed-factor-for-heading-hold", gainForAirspeedFactor);


		# Kp, Ti, Td experimantal:
		# <!-- 150 kts -->
		# <Kp>0.09</Kp>
		# <Ti>50.0</Ti>
		# <Td>6.0</Td>
		#
		# <!-- 200-300 kts -->
		# <Kp>0.05</Kp>
		# <Ti>20.0</Ti>
		# <Td>0.0001</Td>
		#
		# <!-- 300 -350 kts -->
		# <Kp>0.08</Kp>
		# <Ti>60.0</Ti>
		# <Td>0.02</Td>
		#
		# <!-- 340 -450 kts (still bad) -->
		# <Kp>0.07</Kp>
		# <Ti>200.0</Ti>
		# <Td>0.02</Td>

		# interpolate 'Kp' according to airspeed
		var kpForHeadingHold = getprop("/autopilot/internal/target-kp-for-heading-hold-clambed");
		if (airspeedKt < 250.0) {
			if (kpForHeadingHold > 0.12) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold - 0.003);
			}
			elsif (kpForHeadingHold < 0.12) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold + 0.003);
			}
		}
		elsif (airspeedKt < 300.0) {
			if (kpForHeadingHold > 0.05) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold - 0.001667);
			}
			elsif (kpForHeadingHold < 0.05) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold + 0.001667);
			}
		}
		elsif (airspeedKt < 350.0) {
			if (kpForHeadingHold > 0.08) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold - 0.002667);
			}
			elsif (kpForHeadingHold < 0.08) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold + 0.002667);
			}
		}
		else {
			if (kpForHeadingHold > 0.07) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold - 0.002333);
			}
			elsif (kpForHeadingHold < 0.07) {
				setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold + 0.002333);
			}
		}
		#print ("target-kp-for-heading-hold-clambed=", getprop("/autopilot/internal/target-kp-for-heading-hold-clambed"));


		# interpolate 'Ti' according to airspeed
		var tiForHeadingHold = getprop("/autopilot/internal/target-ti-for-heading-hold");
		if (airspeedKt < 170.0) {
			if (getprop("/autopilot/locks/heading") == "nav1-hold") {
				if (tiForHeadingHold > 15.0) {
					setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold - 1.0);
				}
				elsif (tiForHeadingHold < 15.0) {
					setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold + 1.0);
				}
			}
			else {
				if (tiForHeadingHold > 50.0) {
					setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold - 5.0);
				}
				elsif (tiForHeadingHold < 50.0) {
					setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold + 5.0);
				}
			}
		}
		elsif (airspeedKt < 300.0) {
			if (tiForHeadingHold > 20.0) {
				setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold - 1.0);
			}
			elsif (tiForHeadingHold < 20.0) {
				setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold + 1.0);
			}
		}
		elsif (airspeedKt < 350.0) {
			if (tiForHeadingHold > 60.0) {
				setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold - 5.0);
			}
			elsif (tiForHeadingHold < 60.0) {
				setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold + 5.0);
			}
		}
		else {
			if (tiForHeadingHold < 200.0) {
				setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold + 10.0);
			}
		}
		#print ("target-ti-for-heading-hold=", getprop("/autopilot/internal/target-ti-for-heading-hold"));

		# set 'Td' according to airspeed
		if (airspeedKt < 160.0) {
			if (getprop("/autopilot/locks/heading") == "nav1-hold") {
				setprop("/autopilot/internal/target-td-for-heading-hold", 0.002);
			}
			else {
				setprop("/autopilot/internal/target-td-for-heading-hold", 6.0);
			}
		}
		else {
			setprop("/autopilot/internal/target-td-for-heading-hold", 0.001); # preset to lowest value
		}
		var tdForHeadingHold = getprop("/autopilot/internal/target-td-for-heading-hold");
		if (airspeedKt < 190.0) {
			if (tdForHeadingHold > 0.002) {
				setprop("/autopilot/internal/target-td-for-heading-hold", tdForHeadingHold - 0.0001);
			}
			elsif (tdForHeadingHold < 0.002) {
				setprop("/autopilot/internal/target-td-for-heading-hold", tdForHeadingHold + 0.0001);
			}
		}
		elsif (airspeedKt < 300.0) {
			if (tdForHeadingHold > 0.001) {
				setprop("/autopilot/internal/target-td-for-heading-hold", tdForHeadingHold - 0.0001);
			}
			elsif (tdForHeadingHold < 0.001) {
				setprop("/autopilot/internal/target-td-for-heading-hold", tdForHeadingHold + 0.0001);
			}
		}
		else {
			if (tdForHeadingHold < 0.02) {
				setprop("/autopilot/internal/target-td-for-heading-hold", tdForHeadingHold + 0.001);
			}
		}
		#print ("target-td-for-heading-hold=", getprop("/autopilot/internal/target-td-for-heading-hold"));

		# Kp for rudder
		var targetKpRudder = -0.005;
		if (airspeedKt < 190.0) {
			targetKpRudder += (190.0 - airspeedKt) * 0.0002;
			targetKpRudder = (targetKpRudder > 0.0 ? 0.0 : targetKpRudder);
		}
		setprop("/autopilot/internal/target-kp-for-heading-hold-rudder", targetKpRudder);

		settimer(listenerApHeadingFunc, 0.2);
	}
}
setlistener("/autopilot/locks/heading", listenerApHeadingFunc);


#################################################
## GS hold                                     ##
#################################################

var listenerApGSInterpolationFunc = func {
	if (getprop("/autopilot/locks/altitude") == "gs1-hold") {
		setprop("/autopilot/internal/kp-for-gs-hold", 0.0);
		interpolate("/autopilot/internal/kp-for-gs-hold", -0.015, 2);
	}
}
setlistener("/autopilot/locks/altitude", listenerApGSInterpolationFunc);


#################################################
## NAV1 hold                                   ##
#################################################

setprop("/autopilot/internal/target-kp-for-nav1-hold-clambed", 0.0);
var listenerApNav1ClambFunc = func {
	if (getprop("/autopilot/locks/heading") == "nav1-hold") {
		#print ("-> listenerApNav1ClambFunc -> installed");
		setprop("/autopilot/internal/target-kp-for-nav1-hold-clambed", 0.0);
		interpolate("/autopilot/internal/target-kp-for-nav1-hold-clambed", -0.6, 10);

		var targetKpForHeadingHoldClambed = getprop("/autopilot/internal/target-kp-for-heading-hold-clambed");
		setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", 0.0);
		interpolate("/autopilot/internal/target-kp-for-heading-hold-clambed", targetKpForHeadingHoldClambed, 8);
	}
}
setlistener("/autopilot/locks/heading", listenerApNav1ClambFunc);
setlistener("/instrumentation/nav[0]/nav-id", listenerApNav1ClambFunc);
setlistener("/instrumentation/nav/radials/selected-deg", listenerApNav1ClambFunc);

setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", 0.0);
var listenerApNav1NearFarFunc = func {
	if (getprop("/autopilot/locks/heading") == "nav1-hold") {
		#print ("-> listenerApNav1NearFarFunc -> installed");
		if (getprop("/instrumentation/nav[0]/gs-in-range") == 1 and getprop("/instrumentation/nav[0]/gs-rate-of-climb") < -2.0) {
			setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered",
				getprop("/instrumentation/nav[0]/gs-rate-of-climb"));
		}
		else {
			setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", 1.67); # 100 fpm
		}

		# 'smooth' VOR-transition
		if (getprop("instrumentation/nav[0]/gs-in-range") == 0 and getprop("instrumentation/nav[0]/nav-distance") < 2000.0) {
			if (getprop("/autopilot/internal/VOR-near-by") == 0) {
				listenerApNav1ClambFunc();

				var targetRollDeg = getprop("/autopilot/internal/target-roll-deg");
				setprop("/autopilot/internal/target-roll-deg-for-VOR-near-by", 0.0);

				setprop("/autopilot/internal/VOR-near-by", 1);

				interpolate("/autopilot/internal/target-roll-deg-for-VOR-near-by", targetRollDeg, 8.0);
			}
		}
		else {
			if (getprop("/autopilot/internal/VOR-near-by") == 1) {
				listenerApNav1ClambFunc();

				setprop("/autopilot/internal/VOR-near-by", 0);
			}
		}

		settimer(listenerApNav1NearFarFunc, 0.05);
	}
}
setlistener("/autopilot/locks/heading", listenerApNav1NearFarFunc);


#################################################
## NAV1 hold - ground-mode (automatic landing) ##
#################################################

var nav1StearGroundMode = 0;
var nav1PitchDegGroundMode = 0.0;
var nav1VspeedGroundMode = 0;
var nav1KpForThrottle = 0.0;

var listenerApNav1GroundModeFunc = func {

	setprop("/autopilot/internal/nav1-stear-ground-mode-corrected", 0.0);

	if (	getprop("/autopilot/locks/heading") == "nav1-hold" or
		getprop("/autopilot/locks/altitude") == "gs1-hold") {

		if (getprop("/instrumentation/nav[0]/in-range")) {
			#print ("-> listenerApNav1GroundModeFunc -> installed");

			nav1StearGroundMode = 0.0;
			nav1VspeedGroundMode = 0;
			nav1PitchDegGroundMode = 0.0;

			var gearTouchedGround = 0;
			if (	getprop("/gear/gear[0]/wow") or
				getprop("/gear/gear[1]/wow") or
				getprop("/gear/gear[2]/wow") or
				getprop("/gear/gear[3]/wow") or
				getprop("/gear/gear[4]/wow") or
				getprop("/gear/gear[5]/wow")) {
				gearTouchedGround = 1;
			}

			if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

				var totalFuelLbs = getTotalFuelLbs();
				# print("totalFuelLbs=", totalFuelLbs);

				# calculate 'Kp' for 'glideslope with throttle' on ground-mode
				nav1KpForThrottle = 0.5;
				if (totalFuelLbs < 100000.0) {
					nav1KpForThrottle = 0.5 - ((100000.0 - totalFuelLbs) * 0.000004);
					if (nav1KpForThrottle < 0.2) {
						nav1KpForThrottle = 0.2;
					}
				}


#				if (getprop("velocities/groundspeed-kt") != 0.0) {
#					# ratio 0.085 - 0.095 seams to be appropriate
#					print("SPEED-RATIO=", getprop("velocities/vertical-speed-fps") / getprop("velocities/groundspeed-kt"));
#				}

				var gsRateOfClimb = 0.0;

				var altitudeAglFt = getprop("/position/altitude-agl-ft");

				# print("airspeed-kt=", getprop("/velocities/airspeed-kt"));
				# print("altitude-agl-ft=", altitudeAglFt);


				# calculate pitch for gs1-hold - ground-mode (NOTICE: 'nav1PitchDegGroundMode' must be set in
				# each 'if-elsif'-block instead of the last, which activates only speedbeaks !!!)

				if (altitudeAglFt < 40.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 8.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.5, 4.5);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 9.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.5, 5.5);
						}
					}

					if (gearTouchedGround == 0) { # to not confuse the reverser
						setprop("/controls/engines/engine[0]/throttle", 0.0);
						setprop("/controls/engines/engine[1]/throttle", 0.0);
						setprop("/controls/engines/engine[2]/throttle", 0.0);
						setprop("/controls/engines/engine[3]/throttle", 0.0);
					}
					nav1VspeedGroundMode = 2; # avoid vspeed-controller running

					setprop("/controls/flight/speedbrake", 1);
				}
				elsif (altitudeAglFt < 80.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 8.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.5, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 9.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.0, 6.5);
						}
					}

					if (nav1VspeedGroundMode < 2 and gearTouchedGround == 0) { # before touchdown, to not confuse the reverser
						if (totalFuelLbs < 60000) {
							interpolate("/controls/engines/engine[0]/throttle", 0.0, 0.2);
							interpolate("/controls/engines/engine[1]/throttle", 0.0, 0.2);
							interpolate("/controls/engines/engine[2]/throttle", 0.0, 0.2);
							interpolate("/controls/engines/engine[3]/throttle", 0.0, 0.2);
						}
						else {
							interpolate("/controls/engines/engine[0]/throttle", 0.0, 1.0);
							interpolate("/controls/engines/engine[1]/throttle", 0.0, 1.0);
							interpolate("/controls/engines/engine[2]/throttle", 0.0, 1.0);
							interpolate("/controls/engines/engine[3]/throttle", 0.0, 1.0);
						}
					}
					nav1VspeedGroundMode = 2; # avoid vspeed-controller running

					setprop("/controls/flight/speedbrake", 1);
				}
				elsif (altitudeAglFt < 120.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 9.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 10.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 6.0);
						}
					}

					# control vertical speed with throttle, fixed vspeed (activate appropriate controller)
					setprop("/autopilot/locks/speed", "");
					if (totalFuelLbs < 100000) {
						setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -450.0);
					}
					else {
						if (getprop("/velocities/airspeed-kt") < 140.0) {
							if (getprop("/controls/flight/flaps") < 0.833) {
								setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -420.0);
							}
							else {
								setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -410.0);
							}
						}
						else {
							if (getprop("/controls/flight/flaps") < 0.833) {
								setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -450.0);
							}
							else {
								setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -430.0);
							}
						}
					}
					nav1VspeedGroundMode = 1;

					setprop("/controls/flight/speedbrake", 1);
				}
				elsif (altitudeAglFt < 220.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 9.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 10.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 6.0);
						}
					}

					# control vertical speed with throttle (vspeed dependent on groundspeed)
					setprop("/autopilot/locks/speed", "");

					if (totalFuelLbs < 100000) {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.12;
					}
					else {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.095;
					}
					gsRateOfClimb = (gsRateOfClimb < -20.0 ? -20.0 : gsRateOfClimb);
					gsRateOfClimb = (gsRateOfClimb > -10.0 ? -10.0 : gsRateOfClimb);
					setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", gsRateOfClimb * 33.333);

					nav1VspeedGroundMode = 1;

					if (getprop("/velocities/airspeed-kt") > 145.0 or getprop("/orientation/pitch-deg") < 1.0) {
						setprop("/controls/flight/speedbrake", 1);
					}
				}
				elsif (altitudeAglFt < 400.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 9.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.0, 10.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 6.0);
						}
					}

					# control vertical speed with throttle, follow (clambed) glideslope-signal
					setprop("/autopilot/locks/speed", "");
					gsRateOfClimb = getprop("/instrumentation/nav[0]/gs-rate-of-climb");

					if (totalFuelLbs < 100000) {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.12;
					}
					else {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.09;
					}
					gsRateOfClimb = (gsRateOfClimb < -20.0 ? -20.0 : gsRateOfClimb);
					gsRateOfClimb = (gsRateOfClimb > -10.0 ? -10.0 : gsRateOfClimb);
					setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", gsRateOfClimb * 33.333);

					nav1VspeedGroundMode = 1;

					if (getprop("/velocities/airspeed-kt") > 145.0 or getprop("/orientation/pitch-deg") < 1.0) {
						setprop("/controls/flight/speedbrake", 1);
					}
					else {
						setprop("/controls/flight/speedbrake", 0);
					}
				}
			}


			# calculate stearing-correction due to heading-error
			if (	gearTouchedGround == 1) {

				if (getprop("/autopilot/internal/nav1-stear-ground-mode-uncorrected") == nil) {
					setprop("/autopilot/internal/nav1-stear-ground-mode-uncorrected", 0.0);
				}
				var nav1StearGroundModeUncorrected = getprop("/autopilot/internal/nav1-stear-ground-mode-uncorrected");
				nav1StearGroundMode = nav1StearGroundModeUncorrected * 0.001;

				var navError = getprop("/autopilot/internal/nav1-track-error-deg");

				var correction = (getprop("/orientation/heading-deg") - getprop("/instrumentation/nav[0]/heading-deg")) * 0.02;
				nav1StearGroundMode += correction;
			}

			if (gearTouchedGround == 1) {

				setprop("/controls/flight/speedbrake", 1);

				# break speed down to 20 kts and disengage autopilot (altitude-/speed-hold)

				if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

					# reverse-thrust
					if (getprop("/gear/gear[0]/wow")) {
						if (getprop("/velocities/airspeed-kt") > 100.0) {
							if (getprop("/engines/engine/reversed") == 0) {
								# start thrust-reversers
								setprop("/controls/engines/engine[0]/throttle", 0.0);
								setprop("/controls/engines/engine[1]/throttle", 0.0);
								setprop("/controls/engines/engine[2]/throttle", 0.0);
								setprop("/controls/engines/engine[3]/throttle", 0.0);
							
								interpolate("/controls/flight/elevator", 0.0, 3.0);
								interpolate("/controls/flight/elevator-trim", 0.0, 3.0);

								settimer(startReverserProgram, 1.5);
							}
						}
					}

					# breaks
					if (getprop("/velocities/airspeed-kt") > 120.0) {
						if (getprop("/controls/gear/brake-right") < 0.3) {
							setprop("/controls/gear/brake-right", 0.3);
						}
						if (getprop("/controls/gear/brake-left") < 0.3) {
							setprop("/controls/gear/brake-left", 0.3);
						}
					}
					elsif (getprop("/velocities/airspeed-kt") > 80.0) {
						if (getprop("/controls/gear/brake-right") < 0.7) {
							setprop("/controls/gear/brake-right", 0.7);
						}
						if (getprop("/controls/gear/brake-left") < 0.7) {
							setprop("/controls/gear/brake-left", 0.7);
						}
					}
					elsif (getprop("/velocities/airspeed-kt") > 20.0) {
						if (getprop("/controls/gear/brake-right") < 1.0) {
							setprop("/controls/gear/brake-right", 1.0);
						}
						if (getprop("/controls/gear/brake-left") < 1.0) {
							setprop("/controls/gear/brake-left", 1.0);
						}
					}
					else {
						# stop breaking at 20 kts to keep some speed for taxiing
						setprop("/controls/engines/engine[0]/throttle", 0.0);
						setprop("/controls/engines/engine[1]/throttle", 0.0);
						setprop("/controls/engines/engine[2]/throttle", 0.0);
						setprop("/controls/engines/engine[3]/throttle", 0.0);

						setprop("/controls/gear/brake-right", 0.0);

						setprop("/controls/gear/brake-left", 0.0);

						setprop("/autopilot/locks/heading", "");
						setprop("/autopilot/locks/altitude", "");

						# if reversers still running, stop them now
						if (getprop("/engines/engine[0]/reversed") == 1) {
							reversethrust.togglereverser();
						}
					}
				}
			}

			setprop("/autopilot/internal/nav1-stear-ground-mode-corrected", nav1StearGroundMode);
			setprop("/autopilot/internal/nav1-pitch-deg-ground-mode", nav1PitchDegGroundMode);
			setprop("/autopilot/internal/nav1-vspeed-ground-mode", nav1VspeedGroundMode);
			setprop("/autopilot/internal/nav1-kp-for-throttle-ground-mode", nav1KpForThrottle);
		}
		else {
			setprop("/autopilot/internal/nav1-hold-near-by-or-ground-mode", 0);
		}

		settimer(listenerApNav1GroundModeFunc, 0.1);
	}
}

## handle thrust-reversers for NAV1 ground-mode ##
var startReverserProgram = func {
	reversethrust.togglereverser();
	settimer(reverserProgramFunc, 0.5);
}
var reverserProgramFunc = func {
	if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

		if (getprop("/engines/engine[0]/reversed") == 1) {
			if (getprop("/velocities/airspeed-kt") > 80.0) {
				if (	getprop("/controls/engines/engine[0]/throttle") < 0.8) {
					setprop("/controls/engines/engine[0]/throttle", getprop("/controls/engines/engine[0]/throttle") + 0.005);
				}
				if (	getprop("/controls/engines/engine[1]/throttle") < 0.8) {
					setprop("/controls/engines/engine[1]/throttle", getprop("/controls/engines/engine[1]/throttle") + 0.005);
				}
				if (	getprop("/controls/engines/engine[2]/throttle") < 0.8) {
					setprop("/controls/engines/engine[2]/throttle", getprop("/controls/engines/engine[2]/throttle") + 0.005);
				}
				if (	getprop("/controls/engines/engine[3]/throttle") < 0.8) {
					setprop("/controls/engines/engine[3]/throttle", getprop("/controls/engines/engine[3]/throttle") + 0.005);
				}
			}
			else {
				if (	getprop("/controls/engines/engine[0]/throttle") > 0.0) {
					setprop("/controls/engines/engine[0]/throttle", getprop("/controls/engines/engine[0]/throttle") - 0.005);
				}
				if (	getprop("/controls/engines/engine[1]/throttle") > 0.0) {
					setprop("/controls/engines/engine[1]/throttle", getprop("/controls/engines/engine[1]/throttle") - 0.005);
				}
				if (	getprop("/controls/engines/engine[2]/throttle") > 0.0) {
					setprop("/controls/engines/engine[2]/throttle", getprop("/controls/engines/engine[2]/throttle") - 0.005);
				}
				if (	getprop("/controls/engines/engine[3]/throttle") > 0.0) {
					setprop("/controls/engines/engine[3]/throttle", getprop("/controls/engines/engine[3]/throttle") - 0.005);
				}
				if (	getprop("/controls/engines/engine[0]/throttle") <= 0.01 and
					getprop("/controls/engines/engine[1]/throttle") <= 0.01 and
					getprop("/controls/engines/engine[2]/throttle") <= 0.01 and
					getprop("/controls/engines/engine[3]/throttle") <= 0.01) {

					setprop("/controls/engines/engine[0]/throttle", 0.0);
					setprop("/controls/engines/engine[1]/throttle", 0.0);
					setprop("/controls/engines/engine[2]/throttle", 0.0);
					setprop("/controls/engines/engine[3]/throttle", 0.0);
					if (getprop("/engines/engine[0]/reversed") == 1) {
						reversethrust.togglereverser();
					}
				}
			}

			settimer(reverserProgramFunc, 0.1);
		}
	}
}

setlistener("/autopilot/locks/altitude", listenerApNav1GroundModeFunc);

