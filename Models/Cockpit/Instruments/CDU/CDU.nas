var CDUinput = func(v) {
		setprop("/instrumentation/cdu/input",getprop("/instrumentation/cdu/input")~v);
	}

var cdu = func{
		var page = getprop("/instrumentation/cdu/display");
		line1l = "";
		line2l = "";
		line3l = "";
		line4l = "";
		line5l = "";
		line6l = "";
		line1c = "";
		line2c = "";
		line3c = "";
		line4c = "";
		line5c = "";
		line6c = "";
		line1r = "";
		line2r = "";
		line3r = "";
		line4r = "";
		line5r = "";
		line6r = "";
		if (page == "MENU") {
			title = "MENU";
			line1l = "<FMC";
			line2l = "<ACARS";
			line6l = "<ACMS";
			line1r = "SELECT>";
			line2r = "SELECT>";
			line6r = "CMC>";
		}
		if (page == "ALTN_NAV_RAD") {
			title = "ALTN NAV RADIO";
		}
		if (page == "APP_REF") {
			title = "APPROACH REF";
			line6l = "<INDEX";
			line6r = "THRUST LIM>";
		}
		if (page == "DEP_ARR_INDEX") {
			title = "DEP/ARR INDEX";
			line1l = "<DEP";
			line1c = getprop("/autopilot/route-manager/departure/airport");
			line2c = getprop("/autopilot/route-manager/destination/airport");
			line1r = "ARR>";
			line2r = "ARR>";
		}
		if (page == "EICAS_MODES") {
			title = "EICAS MODES";
			line1l = "<ENG";
			line2l = "<STAT";
			line5l = "<CANC";
			line1r = "FUEL>";
			line2r = "GEAR>";
			line5r = "RCL>";
			line6r = "SYNOPTICS>";
		}
		if (page == "EICAS_SYN") {
			title = "EICAS SYNOPTICS";
			line1l = "<ELEC";
			line2l = "<ECS";
			line5l = "<CANC";
			line1r = "HYD>";
			line2r = "DOORS>";
			line5r = "RCL>";
			line6r = "MODES>";
		}
		if (page == "FIX_INFO") {
			title = "FIX INFO";
			line1l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
			line2l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/radials/selected-deg"));
			line6l = "<ERASE FIX";
			line1r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
			line2r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/radials/selected-deg"));
		}
		if (page == "IDENT") {
			title = "IDENT";
			line6l = "<INDEX";
			line6r = "POS INIT>";
		}
		if (page == "INIT_REF") {
			title = "INIT/REF INDEX";
			line1l = "<IDENT";
			line2l = "<POST";
			line3l = "<PERF";
			line4l = "<THRUST LIM";
			line5l = "<TAKEOFF";
			line6l = "<APPROACH";
			line1r = "NAV DATA>";
			line6r = "MAINT>";
		}
		if (page == "NAV_RAD") {
			title = "NAV RADIO";
			line1l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
			line2l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/radials/selected-deg"));
			line1r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
			line2r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/radials/selected-deg"));
		}
		if (page == "PERF_INIT") {
			title = "PERF INIT";
			line1l = sprintf("%3.1f", (getprop("/fdm/jsbsim/inertia/weight-lbs")/1000));
			line2l = sprintf("%3.1f", (getprop("/fdm/jsbsim/propulsion/total-fuel-lbs")/1000));
			line3l = sprintf("%3.1f", (getprop("/fdm/jsbsim/inertia/empty-weight-lbs")/1000));
			line6l = "<INDEX";
			line6r = "THRUST LIM>";
		}
		if (page == "POS_INIT") {
			title = "POS INIT";
			line6l = "<INDEX";
			line6r = "ROUTE>";
		}
		if (page == "POS_REF") {
			title = "POS REF";
			line5l = "<PURGE";
			line6l = "<INDEX";
			line1r = sprintf("%3.0f", getprop("/velocities/groundspeed-kt"));
			line5r = "INHIBIT>";
			line6r = "BRG/DIST>";
		}
		if (page == "RTE1_1") {
			title = "RTE 1";
			line1l = getprop("/autopilot/route-manager/departure/airport");
			line2l = getprop("/autopilot/route-manager/departure/runway");
			line5l = "<RTE COPY";
			line6l = "<RTE 2";
			line1r = getprop("/autopilot/route-manager/destination/airport");
			line6r = "ACTIVATE>";
		}
		if (page == "RTE1_DEP") {
			title = getprop("/autopilot/route-manager/departure/airport")~" DEPARTURES";
			line6l = "<ERASE";
			line1r = getprop("/autopilot/route-manager/departure/runway");
			line6r = "ROUTE>";
		}
		if (page == "RTE1_ARR") {
			title = getprop("/autopilot/route-manager/destination/airport")~" ARRIVALS";
			line6l = "<INDEX";
			line1r = getprop("/autopilot/route-manager/destination/runway");
			line6r = "ROUTE>";
		}
		if (page == "TO_REF") {
			title = "TAKEOFF REF";
			line1l = getprop("/instrumentation/fmc/to-flap");
			line6l = "<INDEX";
			line1r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V1"));
			line2r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/VR"));
			line3r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V2"));
			line6r = "POST INIT>";
		}
		setprop("/instrumentation/cdu/output/title",title);
		setprop("/instrumentation/cdu/output/line1/left",line1l);
		setprop("/instrumentation/cdu/output/line2/left",line2l);
		setprop("/instrumentation/cdu/output/line3/left",line3l);
		setprop("/instrumentation/cdu/output/line4/left",line4l);
		setprop("/instrumentation/cdu/output/line5/left",line5l);
		setprop("/instrumentation/cdu/output/line6/left",line6l);
		setprop("/instrumentation/cdu/output/line1/center",line1c);
		setprop("/instrumentation/cdu/output/line2/center",line2c);
		setprop("/instrumentation/cdu/output/line3/center",line3c);
		setprop("/instrumentation/cdu/output/line4/center",line4c);
		setprop("/instrumentation/cdu/output/line5/center",line5c);
		setprop("/instrumentation/cdu/output/line6/center",line6c);
		setprop("/instrumentation/cdu/output/line1/right",line1r);
		setprop("/instrumentation/cdu/output/line2/right",line2r);
		setprop("/instrumentation/cdu/output/line3/right",line3r);
		setprop("/instrumentation/cdu/output/line4/right",line4r);
		setprop("/instrumentation/cdu/output/line5/right",line5r);
		setprop("/instrumentation/cdu/output/line6/right",line6r);
		settimer(cdu,0.2);
    }
_setlistener("/sim/signals/fdm-initialized", cdu); 