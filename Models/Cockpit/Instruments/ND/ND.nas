# ==============================================================================
# Boeing Navigation Display by Gijs de Rooy
# ==============================================================================

var nd_display = {};

var wpActiveDist = {};
var wpActiveId = {};
var hdg = {};
var windArrow = {};
var wind = {};
var gs = {};
var tas = {};
var selHdg = {};
var rotateComp = {};
var dmeLDist = {};
var dmeRDist = {};
var vorLId = {};
var vorRId = {};
var eta = {};
var compass = {};
var range = {};
var taOnly = {};
var wpt = {};
var sta = {};
var arpt = {};
var curHdgPtr = {};
var staFromL = {};
var staToL = {};
var staFromR = {};
var staToR = {};

var rangeNm = 0;

var m1 = 111132.92;
var m2 = -559.82;
var m3 = 1.175;	
var m4 = -0.0023;
var p1 = 111412.84;	
var p2 = -93.5;	
var p3 = 0.118;	
var latNm = 60;
var lonNm = 60;

var apt_group = {};
var tcas_group = {};
var dme_group = {};
var fix_group = {};
var vor_group = {};
var route_group = {};
var wp = [];
var text_wp = [];
var nd = {};
var map = {};
var fp = {};
var altArc = {};

var i = 0;

var draw_fix = func (lat, lon, name) {
	var fix_grp = fix_group.createChild("group","fix");
	var icon_fix = fix_grp .createChild("path", "fix-" ~ i)
		.moveTo(-15,15)
		.lineTo(0,-15)
		.lineTo(15,15)
		.close()
		.setStrokeLineWidth(3)
		.setColor(0,0.6,0.85);
	var text_fix = fix_grp.createChild("text", "fix-" ~ i)
		.setDrawMode( canvas.Text.TEXT )
		.setText(name)
		.setFont("LiberationFonts/LiberationSans-Regular.ttf")
		.setFontSize(28)
		.setTranslation(5,25);
	fix_grp.setGeoPosition(lat, lon)
		.set("z-index",3);
}
var draw_vor = func (lat, lon, name, freq, range) {
	var vor_grp = vor_group.createChild("group","vor");
	var icon_vor = vor_grp.createChild("path", "vor-" ~ i)
		.moveTo(-15,0)
		.lineTo(-7.5,12.5)
		.lineTo(7.5,12.5)
		.lineTo(15,0)
		.lineTo(7.5,-12.5)
		.lineTo(-7.5,-12.5)
		.close()
		.setStrokeLineWidth(3)
		.setColor(0,0.6,0.85);
	if (freq == getprop("instrumentation/nav[0]/frequencies/selected-mhz") or freq == getprop("instrumentation/nav[1]/frequencies/selected-mhz")) {
		var radius = (range/rangeNm)*345;
		var range_vor = vor_grp.createChild("path", "range-vor-" ~ i)
			.moveTo(-radius,0)
			.arcSmallCW(radius,radius,0,2*radius,0)
			.arcSmallCW(radius,radius,0,-2*radius,0)
			.setStrokeLineWidth(3)
			.setStrokeDashArray([5, 15, 5, 15, 5])
			.setColor(0,1,0);
		if (freq == getprop("instrumentation/nav[0]/frequencies/selected-mhz"))
			var course = getprop("instrumentation/nav[0]/radials/selected-deg");
		else 
			var course = getprop("instrumentation/nav[1]/radials/selected-deg");
		vor_grp.createChild("path", "radial-vor-" ~ i)
			.moveTo(0,-radius)
			.vert(2*radius)
			.setStrokeLineWidth(3)
			.setStrokeDashArray([15, 5, 15, 5, 15])
			.setColor(0,1,0)
			.setRotation(course*D2R);
		icon_vor.setColor(0,1,0);
	}
	vor_grp.setGeoPosition(lat, lon)
		.set("z-index",3);
}
var draw_dme = func (lat, lon, name, freq) {
	var dme_grp = dme_group.createChild("group","dme");
	var icon_dme = dme_grp .createChild("path", "dme-" ~ i)
		.moveTo(-15,0)
		.line(-12.5,-7.5)
		.line(7.5,-12.5)
		.line(12.5,7.5)
		.lineTo(7.5,-12.5)
		.line(12.5,-7.5)
		.line(7.5,12.5)
		.line(-12.5,7.5)
		.lineTo(15,0)
		.lineTo(7.5,12.5)
		.vert(14.5)
		.horiz(-14.5)
		.vert(-14.5)
		.close()
		.setStrokeLineWidth(3)
		.setColor(0,0.6,0.85);
	dme_grp.setGeoPosition(lat, lon)
		.set("z-index",3);
	if (freq == getprop("instrumentation/nav[0]/frequencies/selected-mhz") or freq == getprop("instrumentation/nav[1]/frequencies/selected-mhz"))
		icon_dme.setColor(0,1,0);
}
var draw_apt = func (lat, lon, name) {
	var apt_grp = apt_group.createChild("group");
	if (getprop("instrumentation/efis/inputs/arpt")) {
		var icon_apt = apt_grp.createChild("path", "apt-" ~ i)
			.moveTo(-17,0)
			.arcSmallCW(17,17,0,34,0)
			.arcSmallCW(17,17,0,-34,0)
			.close()
			.setColor(0,0.6,0.85)
			.setStrokeLineWidth(3);
		var text_apt = apt_grp.createChild("text", "apt-" ~ i)
			.setDrawMode( canvas.Text.TEXT )
			.setTranslation(17,35)
			.setText(name)
			.setFont("LiberationFonts/LiberationSans-Regular.ttf")
			.setColor(0,0.6,0.85)
			.setFontSize(28);
		apt_grp.setGeoPosition(lat, lon)
			.set("z-index",1);
	}
}
var draw_rwy = func (group, lat, lon, length, width, rwyhdg) {
	var apt = airportinfo("EHAM");
	var rwy = apt.runway("18R");

	var crds = [];
	var coord = geo.Coord.new();
	width=width*20; # Else rwy is too thin to be visible
	coord.set_latlon(lat, lon);
	coord.apply_course_distance(rwyhdg, -14.2*NM2M);
	append(crds,"N"~coord.lat());
	append(crds,"E"~coord.lon());
	coord.apply_course_distance(rwyhdg, 28.4*NM2M+length);
	append(crds,"N"~coord.lat());
	append(crds,"E"~coord.lon());
	icon_rwy = group.createChild("path", "rwy-cl")
		.setStrokeLineWidth(3)
		.setDataGeo([2,4],crds)
		.setColor(1,1,1)
		.setStrokeDashArray([10, 20, 10, 20, 10]);
	var crds = [];
	coord.set_latlon(lat, lon);
    coord.apply_course_distance(rwyhdg + 90, width/2);
	append(crds,"N"~coord.lat());
	append(crds,"E"~coord.lon());
	coord.apply_course_distance(rwyhdg, length);
	append(crds,"N"~coord.lat());
	append(crds,"E"~coord.lon());
	icon_rwy = group.createChild("path", "rwy")
		.setStrokeLineWidth(3)
		.setDataGeo([2,4],crds)
		.setColor(1,1,1);
	var crds = [];
    coord.apply_course_distance(rwyhdg - 90, width);
	append(crds,"N"~coord.lat());
	append(crds,"E"~coord.lon());
	coord.apply_course_distance(rwyhdg, -length);
	append(crds,"N"~coord.lat());
	append(crds,"E"~coord.lon());
	icon_rwy = group.createChild("path", "rwy")
		.setStrokeLineWidth(3)
		.setDataGeo([2,4],crds)
		.setColor(1,1,1);
}

var EFIS = {
    new : func(prop1){
        var m = { parents : [EFIS]};
        m.radio_list=["instrumentation/comm/frequencies","instrumentation/comm[1]/frequencies","instrumentation/nav/frequencies","instrumentation/nav[1]/frequencies"];
        m.mfd_mode_list=["APP","VOR","MAP","PLAN"];

        m.efis = props.globals.initNode(prop1);
        m.mfd = m.efis.initNode("mfd");
        m.mfd_mode_num = m.mfd.initNode("mode-num",2,"INT");
        m.mfd_display_mode = m.mfd.initNode("display-mode",m.mfd_mode_list[2],"STRING");
        m.std_mode = m.efis.initNode("inputs/setting-std",0,"BOOL");
        m.previous_set = m.efis.initNode("inhg-previos",29.92);
        m.kpa_mode = m.efis.initNode("inputs/kpa-mode",0,"BOOL");
        m.kpa_output = m.efis.initNode("inhg-kpa",29.92);
        m.kpa_prevoutput = m.efis.initNode("inhg-kpa-previous",29.92);
        m.temp = m.efis.initNode("fixed-temp",0);
        m.alt_meters = m.efis.initNode("inputs/alt-meters",0,"BOOL");
        m.fpv = m.efis.initNode("inputs/fpv",0,"BOOL");
        m.nd_centered = m.efis.initNode("inputs/nd-centered",0,"BOOL");
		
        m.mins_mode = m.efis.initNode("inputs/minimums-mode",0,"BOOL");
        m.mins_mode_txt = m.efis.initNode("minimums-mode-text","RADIO","STRING");
        m.minimums = m.efis.initNode("minimums",250,"INT");
        m.mk_minimums = props.globals.getNode("instrumentation/mk-viii/inputs/arinc429/decision-height");
        m.wxr = m.efis.initNode("inputs/wxr",0,"BOOL");
        m.range = m.efis.initNode("inputs/range-nm",40);
        m.sta = m.efis.initNode("inputs/sta",0,"BOOL");
        m.wpt = m.efis.initNode("inputs/wpt",0,"BOOL");
        m.arpt = m.efis.initNode("inputs/arpt",0,"BOOL");
        m.data = m.efis.initNode("inputs/data",0,"BOOL");
        m.pos = m.efis.initNode("inputs/pos",0,"BOOL");
        m.terr = m.efis.initNode("inputs/terr",0,"BOOL");
        m.rh_vor_adf = m.efis.initNode("inputs/rh-vor-adf",0,"INT");
        m.lh_vor_adf = m.efis.initNode("inputs/lh-vor-adf",0,"INT");
		m.nd_plan_wpt = m.efis.initNode("inputs/plan-wpt-index", 0, "INT");

        return m;
    },
	newMFD: func(canvas_group)
	{
		nd = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
			
		canvas.parsesvg(nd, "Aircraft/747-400/Models/Cockpit/Instruments/ND/ND.svg", {'font-mapper': font_mapper});
		wpActiveId = nd.getElementById("wpActiveId");
		wpActiveDist = nd.getElementById("wpActiveDist");
		hdg = nd.getElementById("hdg");
		rotateComp = nd.getElementById("rotate").updateCenter();
		wind = nd.getElementById("wind");
		gs = nd.getElementById("gs");
		tas = nd.getElementById("tas");
		windArrow = nd.getElementById("windArrow").updateCenter();
		selHdg = nd.getElementById("selHdg").updateCenter();
		dmeLDist = nd.getElementById("dmeLDist");
		dmeRDist = nd.getElementById("dmeRDist");
		vorLId = nd.getElementById("vorLId");
		vorRId = nd.getElementById("vorRId");
		eta = nd.getElementById("eta");
		range = nd.getElementById("range");
		taOnly = nd.getElementById("taOnly");
		wpt = nd.getElementById("wpt");
		sta = nd.getElementById("sta");
		arpt = nd.getElementById("arpt");
		curHdgPtr = nd.getElementById("curHdgPtr").updateCenter();
		staFromL = nd.getElementById("staFromL").updateCenter();
		staToL = nd.getElementById("staToL").updateCenter();
		staFromR = nd.getElementById("staFromR").updateCenter();
		staToR = nd.getElementById("staToR").updateCenter();
		compass = nd.getElementById("compass").updateCenter();
		
		map = nd.createChild("map","map")
			.setTranslation(512,824)
			.set("clip", "rect(124, 1024, 1024, 0)");
		apt_group = map.createChild("map","apt-map");
		fix_group = map.createChild("map","fix-map");
		vor_group = map.createChild("map","vor-map");
		dme_group = map.createChild("map","dme-map");
		tcas_group = map.createChild("map","tcas-map");
		route_group = map.createChild("map","route-map");
		altArc = nd.createChild("path","alt-arc")
			.setStrokeLineWidth(3)
			.setColor(0,1,0)
			.set("clip", "rect(124, 1024, 1024, 0)");
		
		rangeNm = getprop("/instrumentation/efis/inputs/range-nm");
		me.drawairports();
		me.drawfixes();
		me.drawvor();
		me.drawdme();
		me.drawtraffic();
	},
	# Draw a route with tracks and waypoints
	drawroute: func()
	{
		route_group.removeAllChildren();
		if (getprop("/autopilot/route-manager/active") == 1) {
			var cmds = [];
			var coords = [];

			var fp = flightplan();
			var fpSize = fp.getPlanSize();
			
			wp = [];
			text_wp = [];
			setsize(wp,fpSize);
			setsize(text_wp,fpSize);
			
			var route = route_group.createChild("path","route")
				.setStrokeLineWidth(5)
				.setColor(1,0,1);
			# Retrieve route coordinates
			for (var i=0; i<(fpSize); i += 1)
			{
				if (i == 0) {
					var leg = fp.getWP(1);
					append(coords,"N"~leg.path()[0].lat);
					append(coords,"E"~leg.path()[0].lon);
					append(cmds,2);
					me.drawwp(leg.path()[0].lat,leg.path()[0].lon,fp.getWP(0).wp_name,i);
					i+=1;
				}
				var leg = fp.getWP(i);
				append(coords,"N"~leg.path()[1].lat);
				append(coords,"E"~leg.path()[1].lon);
				append(cmds,4);
				me.drawwp(leg.path()[1].lat,leg.path()[1].lon,leg.wp_name,i);
			}
			
			# Update route coordinates
			debug.dump(cmds);
			debug.dump(coords);
			route.setDataGeo(cmds, coords);
			me.updatewp(0);
		}
	},
	# Draw a waypoint symbol and waypoint name
	drawwp: func (lat, lon, name, i)
	{
		var wp_group = route_group.createChild("group","wp");
		wp[i] = wp_group.createChild("path", "wp-" ~ i)
			.setStrokeLineWidth(3)
			.moveTo(0,-25)
			.lineTo(-5,-5)
			.lineTo(-25,0)
			.lineTo(-5,5)
			.lineTo(0,25)
			.lineTo(5,5)
			.lineTo(25,0)
			.lineTo(5,-5)
			.setColor(1,1,1)
			.close();
		#####
		# The commented code leads to a segfault when a route is replaced by a new one
		#####
		#
		# text_wp[i] = wp_group.createChild("text", "wp-text-" ~ i)
		#
		var text_wps = wp_group.createChild("text", "wp-text-" ~ i)
			.setDrawMode( canvas.Text.TEXT )
			.setText(name)
			.setFont("LiberationFonts/LiberationSans-Regular.ttf")
			.setFontSize(28)
			.setTranslation(25,35)
			.setColor(1,0,1);
		wp_group.setGeoPosition(lat, lon)
			.set("z-index",4);
	},
	# Change color of active waypoints
	updatewp: func(activeWp)
	{
		forindex(i; wp) {
			if(i == activeWp) {
				wp[i].setColor(1,0,1);
				#text_wp[i].setColor(1,0,1);
			} else {
				wp[i].setColor(1,1,1);
				#text_wp[i].setColor(1,1,1);
			}
		}
	},
	# Draw off-route waypoints (currently on-route waypoints are duplicated)
	drawfixes: func()
	{
		fix_group.removeAllChildren();
		if(rangeNm <= 40 and getprop("instrumentation/efis/inputs/wpt") and getprop("/instrumentation/efis/mfd/display-mode") == "MAP"){
			var results = positioned.findWithinRange(rangeNm*2,"fix");
			foreach(result; results) {
				draw_fix(result.lat,result.lon,result.id);
			}
		}
	},
	drawvor: func()
	{
		vor_group.removeAllChildren();
		if(rangeNm <= 40 and getprop("instrumentation/efis/inputs/sta") and getprop("/instrumentation/efis/mfd/display-mode") == "MAP"){
			var results = positioned.findWithinRange(rangeNm*2,"vor");
			foreach(result; results) {
				draw_vor(result.lat,result.lon,result.id,result.frequency/100,result.range_nm);
			}
		}
	},
	drawdme: func()
	{
		dme_group.removeAllChildren();
		if(rangeNm <= 40 and getprop("instrumentation/efis/inputs/sta") and getprop("/instrumentation/efis/mfd/display-mode") == "MAP"){
			var results = positioned.findWithinRange(rangeNm*2,"dme");
			foreach(result; results) {
				draw_dme(result.lat,result.lon,result.id,result.frequency/100);
			}
		}
	},
	drawairports: func()
	{
		apt_group.removeAllChildren();
		if (rangeNm <= 80 and getprop("/instrumentation/efis/mfd/display-mode") == "MAP") {
			var results = positioned.findWithinRange(rangeNm*2,"airport");
			var numResults = 0;
			foreach(result; results) {
				if (numResults < 50) {
					var apt = airportinfo(result.id);
					var runways = apt.runways;
					var runway_keys = sort(keys(runways),string.icmp);
					var validApt = 0;
					foreach(var rwy; runway_keys){
						var r = runways[rwy];
						if (r.length > 1890) # Only display suitably large airports
							validApt = 1;
						if (result.id == getprop("autopilot/route-manager/destination/airport") or result.id == getprop("autopilot/route-manager/departure/airport"))
							validApt = 1;
					}
					if(validApt) {
						draw_apt(result.lat,result.lon,result.id);
						numResults += 1;
					}
				}
			}
		}
	},
	drawtraffic: func()
	{
		tcas_group.removeAllChildren();
		var traffic = props.globals.initNode("/ai/models/").getChildren("multiplayer");
		foreach(var a; traffic) {
			var lat = a.getNode("position/latitude-deg").getValue();
			var lon = a.getNode("position/longitude-deg").getValue();
			var alt = a.getNode("position/altitude-ft").getValue();
			var dist =  a.getNode("radar/range-nm").getValue();
			var threatLvl =  a.getNode("tcas/threat-level",1).getValue();
			var raSense =  a.getNode("tcas/ra-sense",1).getValue();
			var vspeed =  a.getNode("velocities/vertical-speed-fps").getValue()*60;
			var altDiff = alt - getprop("/position/altitude-ft");
			
			var tcas_grp = tcas_group.createChild("group");
			
			var text_tcas = tcas_grp.createChild("text")
				.setDrawMode( canvas.Text.TEXT )
				.setText(sprintf("%+02.0f",altDiff/100))
				.setFont("LiberationFonts/LiberationSans-Regular.ttf")
				.setColor(1,1,1)
				.setFontSize(28)
				.setAlignment("center-center");
			if (altDiff > 0)
				text_tcas.setTranslation(0,-40);
			else
				text_tcas.setTranslation(0,40);
			if(vspeed >= 500) {
				var arrow_tcas = tcas_grp.createChild("path")
					.moveTo(0,-17)
					.vertTo(17)
					.lineTo(-10,0)
					.moveTo(0,17)
					.lineTo(10,0)
					.setColor(1,1,1)
					.setTranslation(25,0)
					.setStrokeLineWidth(3);
			} elsif (vspeed < 500) {
				var arrow_tcas = tcas_grp.createChild("path")
					.moveTo(0,17)
					.vertTo(-17)
					.lineTo(-10,0)
					.moveTo(0,-17)
					.lineTo(10,0)
					.setColor(1,1,1)
					.setTranslation(25,0)
					.setStrokeLineWidth(3);
			}
				
			var icon_tcas = tcas_grp.createChild("path")
				.setStrokeLineWidth(3);
			if (threatLvl == 3) {
				# resolution advisory
				icon_tcas.moveTo(-17,-17)
					.horiz(34)
					.vert(34)
					.horiz(-34)
					.close()
					.setColor(1,0,0)
					.setColorFill(1,0,0);
				text_tcas.setColor(1,0,0);
				arrow_tcas.setColor(1,0,0);
			} elsif (threatLvl == 2) {
				# traffic advisory
				icon_tcas.moveTo(-17,0)
					.arcSmallCW(17,17,0,34,0)
					.arcSmallCW(17,17,0,-34,0)
					.setColor(1,0.5,0)
					.setColorFill(1,0.5,0);
				text_tcas.setColor(1,0.5,0);
				arrow_tcas.setColor(1,0.5,0);
			} elsif (threatLvl == 1) {
				# proximate traffic
				icon_tcas.moveTo(-10,0)
					.lineTo(0,-17)
					.lineTo(10,0)
					.lineTo(0,17)
					.close()
					.setColor(1,1,1)
					.setColorFill(1,1,1);
			} else {
				# other traffic
				icon_tcas.moveTo(-10,0)
					.lineTo(0,-17)
					.lineTo(10,0)
					.lineTo(0,17)
					.close()
					.setColor(1,1,1);
			}
			
			tcas_grp.setGeoPosition(lat, lon)
				.set("z-index",1);
		}
		settimer(func me.drawtraffic(), 2);
	},
	drawrunways: func()
	{
		if(rangeNm <= 40 and getprop("autopilot/route-manager/active")){
			var desApt = airportinfo(getprop("/autopilot/route-manager/destination/airport"));
			var depApt = airportinfo(getprop("/autopilot/route-manager/departure/airport"));
			var desRwy = desApt.runway(getprop("/autopilot/route-manager/destination/runway"));
			var depRwy = depApt.runway(getprop("/autopilot/route-manager/departure/runway"));
			draw_rwy(map,depRwy.lat,depRwy.lon,depRwy.length,depRwy.width,depRwy.heading);
			draw_rwy(map,desRwy.lat,desRwy.lon,desRwy.length,desRwy.width,desRwy.heading);
		}
	},
	update: func()
	{
		var userHdg = getprop("orientation/heading-deg");
		var userTrkMag = getprop("orientation/heading-deg"); # orientation/track-magnetic-deg is noisy
		var userLat = getprop("/position/latitude-deg");
		var userLon = getprop("/position/longitude-deg");
		rangeNm = getprop("/instrumentation/efis/inputs/range-nm");
		
		# Calculate length in NM of one degree at current location
		var userLatR = userLat*D2R;
		var userLonR = userLon*D2R;
		var latlen = m1 + (m2 * math.cos(2 * userLatR)) + (m3 * math.cos(4 * userLatR)) + (m4 * math.cos(6 * userLatR));
		var lonlen = (p1 * math.cos(userLatR)) + (p2 * math.cos(3 * userLatR)) + (p3 * math.cos(5 * userLatR));
		latNm = latlen*M2NM; #60 at equator
		lonNm = lonlen*M2NM; #60 at equator
		
		hdg.setText(sprintf("%03.0f",userHdg));
		windArrow.setRotation((getprop("/environment/wind-from-heading-deg")-userHdg)*D2R);
		wind.setText(sprintf("%3.0f / %2.0f",getprop("/environment/wind-from-heading-deg"),getprop("/environment/wind-speed-kt")));
		if (getprop("/velocities/groundspeed-kt") >= 30)
			gs.setFontSize(36);
		else
			gs.setFontSize(52);
		gs.setText(sprintf("%3.0f",getprop("/velocities/groundspeed-kt")));
		
		if (getprop("instrumentation/nav/nav-id") != nil)
			vorLId.setText(getprop("instrumentation/nav/nav-id"));
		if (getprop("instrumentation/nav[1]/nav-id") != nil)
			vorRId.setText(getprop("instrumentation/nav[1]/nav-id"));
		if(getprop("instrumentation/nav/nav-distance") != nil)
			dmeLDist.setText(sprintf("%3.1f",getprop("instrumentation/nav/nav-distance")*0.000539));
		if(getprop("instrumentation/nav[1]/nav-distance") != nil)
			dmeRDist.setText(sprintf("%3.1f",getprop("instrumentation/nav[1]/nav-distance")*0.000539));
			
		if(getprop("autopilot/route-manager/wp/eta") != nil) {
			var etaWp = split(":",getprop("autopilot/route-manager/wp/eta"));
			var h = getprop("/sim/time/utc/hour");
			var m = getprop("/sim/time/utc/minute")+sprintf("%02f",etaWp[0]);
			var s = getprop("/sim/time/utc/second")+sprintf("%02f",etaWp[1]);
			eta.setText(sprintf("%02.0f%02.0f.%02.0fz",h,m,s));
			eta.show();
		} else
			eta.hide();
			
		if(getprop("/velocities/airspeed-kt") > 100) {
			tas.setText(sprintf("%3.0f",getprop("/velocities/airspeed-kt")));
			tas.show();
		} else
			tas.hide();

		range.setText(sprintf("%3.0f",rangeNm));
		rangeNm=rangeNm*2;
		
		if(getprop("/autopilot/route-manager/active")) {
			wpActiveId.setText(getprop("/autopilot/route-manager/wp/id"));
			wpActiveDist.setText(sprintf("%3.01fNM",getprop("/autopilot/route-manager/wp/dist")));
		}
		map._node.getNode("ref-lat",1).setDoubleValue(userLat);
		map._node.getNode("ref-lon",1).setDoubleValue(userLon);
		map._node.getNode("hdg",1).setDoubleValue(userHdg);
		map._node.getNode("range",1).setDoubleValue(rangeNm/4);
		if (abs(getprop("velocities/vertical-speed-fps")) > 10) {
			altArc.reset();
			var altRangeNm = (getprop("autopilot/settings/target-altitude-ft")-getprop("instrumentation/altimeter/indicated-altitude-ft"))/getprop("velocities/vertical-speed-fps")*getprop("/velocities/groundspeed-kt")*KT2MPS*M2NM;
			if(altRangeNm > 1) {
				var altRangePx = (256/rangeNm)*altRangeNm;
				altArc.moveTo(-altRangePx*2.25,0)
					.arcSmallCW(altRangePx*2.25,altRangePx*2.25,0,altRangePx*4.5,0)
					.setTranslation(512,824);
			}
		}
		rotateComp.setRotation(-userTrkMag*D2R);
		if (getprop("/instrumentation/efis/mfd/display-mode") != "APP" or getprop("/instrumentation/efis/mfd/display-mode") != "MAP" or getprop("/instrumentation/efis/mfd/display-mode") != "PLAN" or getprop("/instrumentation/efis/mfd/display-mode") != "VOR"){
			compass.setRotation(-userTrkMag*D2R);
			compass.show();
		} else
			compass.hide();
		curHdgPtr.setRotation(userHdg*D2R);
		selHdg.setRotation(getprop("autopilot/settings/true-heading-deg")*D2R);
		if (getprop("instrumentation/nav/heading-deg") != nil)
			staFromL.setRotation((getprop("instrumentation/nav/heading-deg")-userHdg+180)*D2R);
		if (getprop("instrumentation/nav/heading-deg") != nil)
			staToL.setRotation((getprop("instrumentation/nav/heading-deg")-userHdg)*D2R);
		if (getprop("instrumentation/nav[1]/heading-deg") != nil)
			staFromR.setRotation((getprop("instrumentation/nav[1]/heading-deg")-userHdg+180)*D2R);
		if (getprop("instrumentation/nav[1]/heading-deg") != nil)
			staToR.setRotation((getprop("instrumentation/nav[1]/heading-deg")-userHdg)*D2R);
		if(getprop("instrumentation/tcas/inputs/mode") == 2)
			taOnly.show();
		else
			taOnly.hide();
		wpt.setVisible(me.wpt.getValue());
		arpt.setVisible(me.arpt.getValue());
		sta.setVisible(me.sta.getValue());

		settimer(func me.update(), 0.05);
	}
};

setlistener("sim/signals/fdm-initialized", func() {
	var Efis = EFIS.new("instrumentation/efis");
	
	nd_display = canvas.new({
		"name": "ND",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	nd_display.addPlacement({"node": "ndScreen"});
	var group = nd_display.createGroup();
	Efis.newMFD(group);
	Efis.update();
	
	setlistener("/instrumentation/efis/inputs/range-nm", func() {
		rangeNm = getprop("/instrumentation/efis/inputs/range-nm");
		Efis.drawairports();
		Efis.drawfixes();
		Efis.drawvor();
		Efis.drawdme();
		Efis.drawrunways();
		Efis.drawtraffic();
	});
	setlistener("instrumentation/efis/inputs/arpt", func() {
		Efis.drawairports();
	});
	setlistener("instrumentation/efis/inputs/wpt", func() {
		Efis.drawfixes();
	});
	setlistener("instrumentation/efis/inputs/sta", func() {
		Efis.drawdme();
		Efis.drawvor();
	});
	setlistener("instrumentation/nav/frequencies/selected-mhz", func() {
		Efis.drawvor();
		Efis.drawdme();
	});
	setlistener("instrumentation/nav[1]/frequencies/selected-mhz", func() {
		Efis.drawvor();
		Efis.drawdme();
	});
	setlistener("instrumentation/efis/mfd/display-mode", func() {
		Efis.drawairports();
		Efis.drawroute();
		Efis.drawrunways();
	});
	setlistener("/autopilot/route-manager/active", func(active) {
		if(active.getValue()) {
			Efis.drawroute();
			Efis.drawrunways();
		} else {
			route_group.removeAllChildren();
		}
	});
	setlistener("/autopilot/route-manager/current-wp", func(activeWp) {
		Efis.updatewp(activeWp.getValue());
	});
});

# The optional second arguments enables creating a window decoration
var showNd = func() {
	var dlg = canvas.Window.new([400, 400], "dialog");
	dlg.setCanvas(nd_display);
}