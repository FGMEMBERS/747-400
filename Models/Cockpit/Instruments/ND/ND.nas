var nd_display = {};

var myCockpit_switches = {
	# symbolic alias : relative property (as used in bindings), initial value, type
	'toggle_range': 	{path: '/inputs/range-nm', value:40, type:'INT'},
	'toggle_weather': 	{path: '/inputs/wxr', value:0, type:'BOOL'},
	'toggle_airports': 	{path: '/inputs/arpt', value:0, type:'BOOL'},
	'toggle_stations': 	{path: '/inputs/sta', value:0, type:'BOOL'},
	'toggle_waypoints': 	{path: '/inputs/wpt', value:0, type:'BOOL'},
	'toggle_position': 	{path: '/inputs/pos', value:0, type:'BOOL'},
	'toggle_data': 		{path: '/inputs/data',value:0, type:'BOOL'},
	'toggle_terrain': 	{path: '/inputs/terr',value:0, type:'BOOL'},
	'toggle_traffic': 		{path: '/inputs/tfc',value:0, type:'BOOL'},
	'toggle_centered': 		{path: '/inputs/nd-centered',value:0, type:'BOOL'},
	'toggle_lh_vor_adf':	{path: '/inputs/lh-vor-adf',value:0, type:'INT'},
	'toggle_rh_vor_adf':	{path: '/inputs/rh-vor-adf',value:0, type:'INT'},
	'toggle_display_mode': 	{path: '/mfd/display-mode', value:'MAP', type:'STRING'},
	'toggle_display_type': 	{path: '/mfd/display-type', value:'CRT', type:'STRING'},
	'toggle_true_north': 	{path: '/mfd/true-north', value:0, type:'BOOL'},
	# add new switches here
};

setlistener("sim/signals/fdm-initialized", func() {
	var ND = canvas.NavDisplay;

	# TODO: is this just an object decsribing a ND? Can we move this out of the listener?
	# Also applies below and to the 777.
	var NDCpt = ND.new("instrumentation/efis",myCockpit_switches);
	
	nd_display.cpt = canvas.new({
		"name": "ND",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	var plc_cpt = nd_display.cpt.addPlacement({"node": "ndScreenL"});
	settimer(func {
		if (plc_cpt.getValue("status-msg") == "Ok") return;
		#print("retry "~plc_cpt.getValue("status-msg"));
		plc_cpt.remove();
		nd_display.cpt.addPlacement({"node": "ndScreenL"});
		#if (nd_display.cpt.texture.getValue("placement/status-msg") == "No match")
		#	print(".. failed: "~nd_display.cpt.texture.getValue("placement/status-msg"));
	}, 0);
	var group = nd_display.cpt.createGroup();
	NDCpt.newMFD(group, nd_display.cpt);
	NDCpt.update();
	
	var NDFo = ND.new("instrumentation/efis[1]",myCockpit_switches);
	
	nd_display.fo = canvas.new({
		"name": "ND",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	var plc_fo = nd_display.fo.addPlacement({"node": "ndScreenR"});
	settimer(func {
		if (plc_fo.getValue("status-msg") == "Ok") return;
		#print("retry "~plc_fo.getValue("status-msg"));
		plc_fo.remove();
		nd_display.fo.addPlacement({"node": "ndScreenR"});
		#if (nd_display.fo.texture.getValue("placement/status-msg") == "No match")
		#	print(".. failed: "~nd_display.fo.texture.getValue("placement/status-msg"));
	}, 0);
	var group = nd_display.fo.createGroup();
	NDFo.newMFD(group, nd_display.fo);
	NDFo.update();
	
});

var showNd = func(pilot='cpt') {
	var dlg = canvas.Window.new([400, 400], "dialog");
	dlg.setCanvas( nd_display[pilot] );
}
