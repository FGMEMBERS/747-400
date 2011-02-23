####    autopilot/route-manager help-functions                                                 ####
####    Author: Markus Bulik                                                                   ####
####    This file is licenced under the terms of the GNU General Public Licence V2 or later    ####

##############################################################################
## Route-Manager - AP - routines                                            ##
## AP- route-manager driven (in passive-mode, controls 'true-heading-hold', ##
##                       'vertical-speed-hold', 'altitude-hold')            ##
##############################################################################


var listenerApInitFunc = func {
	# do initializations of new properties

	setprop("/autopilot/internal/route-manager-waypoint-near-by", 0);
	setprop("autopilot/locks/passive-mode", 0);
}
setlistener("/sim/signals/fdm-initialized", listenerApInitFunc);


# notes:
# if 'passive-mode' is switched on, the autopilot is controlled by the route-manager, that means the settings for 'true-heading-hold'
# and 'altitude-hold' come from the route-manager, additionally the route-manager activates 'true-heading-hold'.
# This procedure calculates the appropriate vertical-speed and activated 'vertical-speed-hold', 'altitude-hold' as needed.
# Also provides a 'smooting'-procedure on the transition of waypoints.

var waypointIdPrev = nil;
var waypointVspeedChangedManually = 0;
var waypointVspeedMaxValue = 999999.0;
var waypointVspeedPrev = waypointVspeedMaxValue;

# need this for workarround for error in 'settimer()' ?!?
var apHeadingWaypointSetVSpeed_force = 0;
var apHeadingWaypointSetVSpeed_lastCalled = getprop("/sim/time/elapsed-sec");

var apHeadingWaypointSetVSpeed = func {
	if (	getprop("autopilot/locks/passive-mode") == 1 and
		getprop("autopilot/route-manager/active") == 1 and getprop("autopilot/route-manager/airborne") == 1) {

		if (apHeadingWaypointSetVSpeed_force == 0) {
			var now = getprop("/sim/time/elapsed-sec");
			if (now - apHeadingWaypointSetVSpeed_lastCalled < 28) {
				return;
			}
			apHeadingWaypointSetVSpeed_lastCalled = now;
		}
		
		var currentWaypointIndex = getprop("autopilot/route-manager/current-wp");
		var waypointId = getprop("autopilot/route-manager/wp/id");
		var waypointDistanceNm = getprop("autopilot/route-manager/wp/dist");
		#print("apHeadingWaypointSetVSpeed: waypointDistanceNm=", waypointDistanceNm);

		if (waypointId != nil and waypointId != "" and waypointDistanceNm != nil) {

			var groundspeedKt = getprop("velocities/groundspeed-kt");
			#print("apHeadingWaypointSetVSpeed: groundspeedKt=", groundspeedKt);

			var currentWaypointIndex = getprop("autopilot/route-manager/current-wp");
			#print("apHeadingWaypointSetVSpeed: currentWaypointIndex=", currentWaypointIndex);
			var altitudeFt = getprop("position/altitude-ft");
			var autopilotSettingAltitudeFt = getprop("autopilot/settings/target-altitude-ft");
			var waypointAlt = getprop("autopilot/route-manager/route/wp["~currentWaypointIndex~"]/altitude-ft");

			if (autopilotSettingAltitudeFt == nil or autopilotSettingAltitudeFt < 0) {
				if (waypointAlt != nil) {
					autopilotSettingAltitudeFt = waypointAlt;
				}
				else {
					autopilotSettingAltitudeFt = 0.0;
				}
			}
			var altitudeDistFt = autopilotSettingAltitudeFt - altitudeFt;
			#print("apHeadingWaypointSetVSpeed: altitudeDistFt=", altitudeDistFt);

			# calculate vspeed
			var vspeed = 0.0;
			if (waypointDistanceNm > 0.0) {
				vspeed = (altitudeDistFt * groundspeedKt / waypointDistanceNm) * 0.01; # nm/h -> ft/min : factor=0.01
				vspeed += vspeed * 0.15; # make sure to reach the destination altitude before reaching the waypoint (add 15%)
			}
			# clamb: limit vspeed to min., max. values
			if (vspeed > 0) {
				vspeed = (vspeed > 2000.0) ? 2000.0 : vspeed;
				if (getprop("/position/altitude-agl-ft") < 5000) {
					vspeed = (vspeed < 1500.0) ? 1500.0 : vspeed;
				}
				else {
					vspeed = (vspeed < 500.0) ? 500.0 : vspeed;
				}
			}
			else {
				vspeed = (vspeed < -1000.0) ? -1000.0 : vspeed;
				vspeed = (vspeed > -200.0) ? -200.0 : vspeed;
			}
			#print("apHeadingWaypointSetVSpeed: listenerApHeadingWaypoint: vspeed=", vspeed);
			var vspeedPrev = getprop("autopilot/settings/vertical-speed-fpm");
			# set vspeed, only if vspeed has not been changed mannually and the change is greater than 5%
			if (vspeedPrev == waypointVspeedPrev or waypointVspeedPrev == waypointVspeedMaxValue) {
				waypointVspeedChangedManually = 0;
			}
			else {
				waypointVspeedChangedManually = 1;
			}
			if (waypointVspeedChangedManually == 0 and (abs(vspeed) > abs(vspeedPrev * 0.05))) {
				setprop("autopilot/settings/vertical-speed-fpm", vspeed);
				waypointVspeedPrev = vspeed;
			}

			if (	getprop("autopilot/locks/altitude") != "vertical-speed-hold" and
				getprop("autopilot/locks/altitude") != "altitude-hold") {
				setprop("autopilot/locks/altitude", "vertical-speed-hold");
			}

			setprop("autopilot/settings/altitude-ft", autopilotSettingAltitudeFt);
		}
	}
}

var apHeadingWaypointSetVSpeedRepeat = func() {

	if (	getprop("autopilot/locks/passive-mode") == 1 and
		getprop("autopilot/route-manager/active") == 1 and getprop("autopilot/route-manager/airborne") == 1) {

		apHeadingWaypointSetVSpeed_force = 0;

		apHeadingWaypointSetVSpeed();

		# settimer for corretion of vspeed each 30 seconds
		if (waypointVspeedChangedManually == 0 and getprop("autopilot/locks/altitude") == "vertical-speed-hold") {
			settimer(apHeadingWaypointSetVSpeedRepeat, 30.0);
		}
	}
}
var apHeadingWaypointSetVSpeedStart = func() {

	apHeadingWaypointSetVSpeed_force = 1;

	apHeadingWaypointSetVSpeed();

	apHeadingWaypointSetVSpeed_force = 0;

	# settimer for corretion of vspeed each 30 seconds
	if (waypointVspeedChangedManually == 0) {
		settimer(apHeadingWaypointSetVSpeedRepeat, 30.0);
	}
}

var switchedToAltHold = 0;
setlistener("autopilot/route-manager/current-wp", func {switchedToAltHold = 0;} );
setlistener("autopilot/route-manager/current-wp", listenerApHeadingClambFunc);

var listenerApPassiveMode = func {

	var routeManagerWaypointNearBy = 0;

	if (getprop("autopilot/locks/passive-mode") == 1) {

		var timerInterval = 0.5;

		var groundspeedKt = getprop("velocities/groundspeed-kt");

		if (getprop("autopilot/route-manager/active") == 1 and getprop("autopilot/route-manager/airborne") == 1) {

			var currentWaypointIndex = getprop("autopilot/route-manager/current-wp");
			var waypointId = getprop("autopilot/route-manager/wp/id");
			var waypointDistanceNm = getprop("autopilot/route-manager/wp/dist");

			if (waypointId != nil and waypointId != "" and waypointDistanceNm != nil) {

				if (getprop("autopilot/locks/heading") != "true-heading-hold") {
					setprop("autopilot/locks/heading", "true-heading-hold");
				}

				if (waypointId == waypointIdPrev) {
					# 'smoothing' on waypoint-transition:
					# avoid heading change near active waypoint due to great angle difference -> keep actual heading
					if (waypointDistanceNm < 1.0) {
						if (getprop("autopilot/internal/route-manager-waypoint-near-by") == 0) {
							# smoothing: interpolate Kp for heading-hold
							var kpForHeadingHold = getprop("/autopilot/internal/target-kp-for-heading-hold-clambed");
							setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", 0.0);
							interpolate("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold, 2);
						}
						routeManagerWaypointNearBy = 1;
					}
					# don't need to do this, the route manager does it already
					#else {
					#	setprop("autopilot/settings/true-heading-deg", getprop("autopilot/route-manager/wp["~currentWaypointIndex~"]/bearing-deg"));
					#}
				}

				if (waypointId != waypointIdPrev) {
					waypointVspeedPrev = waypointVspeedMaxValue;
					waypointVspeedChangedManually = 0;

					setprop("autopilot/locks/altitude", "");

					routeManagerWaypointNearBy = 1;
					settimer(apHeadingWaypointSetVSpeedStart , 1.0);

					# set higher timer-interval to keep 'near-by-mode' for some seconds after crossing waypoint
					# (hopefully this avoids sporadically occuring 360 degree turns, if we wait until route-manager has completed calculation of new heading)
				}

				var altitudeFt = getprop("position/altitude-ft");
				var autopilotSettingAltitudeFt = getprop("autopilot/settings/target-altitude-ft");
				var waypointAlt = getprop("autopilot/route-manager/route/wp["~currentWaypointIndex~"]/altitude-ft");
				if (autopilotSettingAltitudeFt == nil or autopilotSettingAltitudeFt < 0) {
					if (waypointAlt != nil) {
						autopilotSettingAltitudeFt = waypointAlt;
					}
					else {
						autopilotSettingAltitudeFt = 0.0;
					}
				}
				var altitudeDistFt = autopilotSettingAltitudeFt - altitudeFt;
				var altitudeDistFtSwitch = 350.0;
				if (getprop("velocities/vertical-speed-fps") < 25.0) {
					# abs(vspeed) < 1500.0 fpm -> switch to altitude-hold a bit later
					altitudeDistFtSwitch -= ((25.0 - abs(getprop("velocities/vertical-speed-fps")) * 10.0));
				}
				var waypointDistanceNmSwitch = 1.0 + (groundspeedKt * 0.003);
				if (abs(altitudeDistFt) < altitudeDistFtSwitch or waypointDistanceNm < waypointDistanceNmSwitch) {
					if (switchedToAltHold == 0 and getprop("autopilot/locks/altitude") == "vertical-speed-hold") {
						setprop("autopilot/locks/altitude", "altitude-hold");
						switchedToAltHold = 1;
					}
				}

				waypointIdPrev = waypointId;
			}
		}

		if (groundspeedKt != nil) {
			timerInterval -= (groundspeedKt * 0.005);
		}

		setprop("autopilot/internal/route-manager-waypoint-near-by", routeManagerWaypointNearBy);

		settimer(listenerApPassiveMode , timerInterval);
	}
	else {
		# we are switched off -> cleanup

		if (getprop("autopilot/locks/heading") == "true-heading-hold") {
			setprop("autopilot/locks/heading", "");
		}
		setprop("autopilot/internal/route-manager-waypoint-near-by", 0);

		switchedToAltHold = 0;
		waypointIdPrev = nil;
		waypointVspeedChangedManually = 0;
		waypointVspeedPrev = waypointVspeedMaxValue;
		apHeadingWaypointSetVSpeed_force = 0;
	}
}
setlistener("autopilot/locks/passive-mode", listenerApHeadingClambFunc);
setlistener("autopilot/locks/passive-mode", listenerApPassiveMode);



