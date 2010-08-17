# 744 electrical system
# by reeed (Feb 2010)
# see 747-400 Acft Operating Manual

var apu_started = 0;

var sys = 'systems/electrical/';
var controls = 'controls/electric/';
var pbrake_time = getprop('sim/time/elapsed-sec') - 50;

props.globals.initNode(controls~'ground-service', 1, 'BOOL');
props.globals.initNode(controls~'standby-power', 0, 'INT');
props.globals.initNode(controls~'battery', 1, 'BOOL');
props.globals.initNode(controls~'apu', 0, 'INT');	# probably redundant

for (var i = 0; i < 2; i += 1) {
  props.globals.initNode(controls~'utility['~i~']', 1, 'BOOL');
}
for (var i = 0; i < 4; i += 1) {
  props.globals.initNode(controls~'bus-tie['~i~']', 1, 'BOOL');
  props.globals.initNode(controls~'generator-control['~i~']', 1, 'BOOL');
}

props.globals.initNode(sys~'battery-off', 0, 'BOOL');

for (var i = 0; i < 2; i += 1) {
  props.globals.initNode(sys~'utility-off['~i~']', 1, 'BOOL');
  props.globals.initNode(sys~'external-power['~i~']', 0, 'INT');
  props.globals.initNode(sys~'apu-generator['~i~']', 0, 'INT');
  props.globals.initNode(sys~'ac-sync-bus-source['~i~']', 'idg', 'STRING');
}
for (var i = 0; i < 4; i += 1) {
  props.globals.initNode(sys~'bus-isolation['~i~']', 1, 'BOOL');
  props.globals.initNode(sys~'generator-off['~i~']', 1, 'BOOL');
  props.globals.initNode(sys~'generator-drive['~i~']', 1, 'BOOL');
  props.globals.initNode(sys~'ac-bus['~i~']', 0, 'BOOL');
}

var i = 28;
#setprop(sys, 'suppliers/main-batt-v', i);
#setprop(sys, 'suppliers/apu-batt-v', i);
#setprop(sys, 'outputs/main-hot-batt-bus-v', i);
#setprop(sys, 'outputs/apu-hot-batt-bus-v', i);

var turn_stby_pwr_sw = func(n = 0)
{
  var a = getprop(controls, 'standby-power');

  a += n;
  if (a > 2) a = 2;
  if (a < 0) a = 0;
  setprop(controls, 'standby-power', a);
}

var turn_apu_sw = func(n = -1)
{
  var a = getprop(controls, 'apu');

      # set APU fuel ctrl to RUN if N2 > 15,
      # try again after 3 sec if not (as long as starter is still running)
      var igniter = func
      {
	var n2 = getprop('engines/apu/n2');
	if (n2 > 15) {
	  setprop('controls/engines/engine[4]/cutoff', 0);
	  print('>>> APU fuel run');
	} else {
	  if (getprop('engines/engine[4]/starter') == 1)
	    settimer(igniter, 3);
	}
      }

      var apu_shutdown = func
      {
	if (getprop(controls, 'apu') == 0) {
	  setprop('controls/engines/engine[4]/cutoff', 1);
	  print('>>> APU fuel cutoff');
	  apu_started = 0;
	}
      }

  a += n;
  if (a < 0) a = 0;
  setprop(controls, 'apu', a);

  if (a == 0 and apu_started) {
    var pwrL = getprop(sys, 'ac-sync-bus-source[0]');
    var pwrR = getprop(sys, 'ac-sync-bus-source[1]');

    # APU no longer available, unload it
    if (pwrL == 'apu') setprop(sys, 'ac-sync-bus-source[0]', '');
    if (pwrR == 'apu') setprop(sys, 'ac-sync-bus-source[1]', '');
    setprop(sys, 'apu-generator[0]', 0);
    setprop(sys, 'apu-generator[1]', 0);
      # XXX but refresh_bus would set this to '1' again

    # 60 sec cooldown
    settimer(apu_shutdown, 60);

  } elsif (a == 2) {
    if (apu_started == 0) {
      # check that the necessary batt busses are powered

      # APU start sequence
      setprop('controls/engines/engine[4]/cutoff', 1);
      setprop('controls/engines/engine[4]/starter', 1);
      settimer(igniter, 3);
      apu_started = 1;
    }
    # return the switch to ON
    settimer(func { setprop(controls, 'apu', 1); }, 0.6);
  } 
}

var push_utility = func(n)
{
  var p = controls ~ 'utility['~n~']';
  var i = getprop(p);
  i = !i;
  setprop(p, i);
}

var push_batt_sw = func
{
  var p = controls ~ 'battery';
  var i = getprop(p);
  setprop(sys, 'battery-off', i);
  i = !i;
  setprop(p, i);

  #settimer(elec_bus_refresh, 1);
}

var push_bus_tie = func(n)
{
  var p = props.globals.getNode(controls~'bus-tie['~n~']');
  var i = p.getValue();
  i = !i;
  p.setValue(i);

  if (i == 0)
    setprop(sys, 'bus-isolation['~n~']', 1);

  elec_bus_refresh();
}

var _connect_generator = func(n)
{
  # reconnect ac-sync-bus if IDG powered
  var idg = getprop(sys, 'suppliers/idg-v['~n~']');
  if (idg > 110) {
    # disconnect EXT/APU
    var n2 = n < 2 ? 0 : 1;
    var ext = props.globals.getNode(sys~'external-power['~n2~']');
    var apu = props.globals.getNode(sys~'apu-generator['~n2~']');
    var p = props.globals.getNode(sys~'ac-sync-bus-source['~n2~']');

    if (p == 'apu') apu.setValue(1);
    elsif (p == 'ext') ext.setValue(1);
    p.setValue('idg');
  }
}

var push_gen_cont = func(n)
{
  var p = controls~'generator-control['~n~']';
  var i = getprop(p);
  i = !i;
  setprop(p, i);

  if (i == 0)		# now off
    setprop(sys, 'generator-off['~n~']', 1);
  else {
    _connect_generator(n);
    elec_bus_refresh();
  }

  #settimer(elec_bus_refresh, 1);
}

var push_drive_disc = func(n)
{
  # set irreversible var

  # open gen cont breaker
  setprop('systems/electrical/generator-off['~n~']', 1);

  #settimer(elec_bus_refresh, 1);
}

var push_ext_apu = func(type, n)
{
  var ext = [getprop(sys, 'external-power[0]'), getprop(sys, 'external-power[1]')];
  var apu = [getprop(sys, 'apu-generator[0]'), getprop(sys, 'apu-generator[1]')];
  var pwr = [ props.globals.getNode(sys~'ac-sync-bus-source[0]'),
	      props.globals.getNode(sys~'ac-sync-bus-source[1]') ];

  if (type == 'ext') {
    if (ext[n] == 1) {
      # connect EXT
      settimer(func
	    {
	      setprop(sys, 'external-power['~n~']', 2);
	      pwr[n].setValue('ext');
	      if (apu[n] == 2)
		setprop(sys, 'apu-generator['~n~']', 1);
	      elec_bus_refresh();
	    }, 3 + rand() * 3);
    }
    if (ext[n] == 2) {
      # disconnect EXT
      setprop(sys, 'external-power['~n~']', 1);
      pwr[n].setValue('');
      # connect GEN CONT if online
      _connect_generator(n*2);
      #_connect_generator(n*2+1);
      elec_bus_refresh();
    }
  }

  if (type == 'apu') {
    if (apu[n] == 1) {
      # connect APU
      settimer(func
	    {
	      setprop(sys, 'apu-generator['~n~']', 2);
	      pwr[n].setValue('apu');
	      if (ext[n] == 2)
		setprop(sys, 'external-power['~n~']', 1);
	      elec_bus_refresh();
	    }, 3 + rand() * 3);
    } elsif (apu[n] == 2) {
      # disconnect APU
      setprop(sys, 'apu-generator['~n~']', 1);
      pwr[n].setValue('');
      elec_bus_refresh();
    }
  }
}

var batt_sw = func(n)
{
  if (n.getValue() == 1) {
    # if DC 3 n/a, hot batt buses power the batt buses
    if (getprop('systems/electrical/outputs/dc-bus[2]').getValue() < 25) {
      var v = getprop('systems/electrical/main-batt-v');
      setprop('systems/electrical/outputs/main-batt-bus-v', v.getValue());
      v = getprop('systems/electrical/apu-batt-v');
      setprop('systems/electrical/outputs/apu-batt-bus-v', v);
      # batt discharging if GSB n/a
    }
  } else {		# batt-sw off
    if (getprop('systems/electrical/outputs/dc-bus[2]').getValue() < 25) {
      setprop('systems/electrical/outputs/main-batt-bus-v', 0);
      setprop('systems/electrical/outputs/apu-batt-bus-v', 0);
    }
  }
  print('batt_sw ', n.getValue());
  print('apu-batt-bus-v ', v.getValue(), 'main-batt-bus-v ', getprop('systems/electrical/main-batt-v').getValue());
}

var main_batt_bus = func(n)
{
  print('main_batt_bus ', n.getValue());
}

var elec_bus_refresh = func
{
  var ext1 = getprop(sys, 'suppliers/external-v[0]') > 110 ? 1 : 0;
  var ext2 = getprop(sys, 'suppliers/external-v[1]') > 110 ? 1 : 0;
  var apu1 = getprop(sys, 'suppliers/apu-v[0]') > 110 ? 1 : 0;
  var apu2 = getprop(sys, 'suppliers/apu-v[1]') > 110 ? 1 : 0;
  var sync_src = [ props.globals.getNode(sys~'ac-sync-bus-source[0]'),
		   props.globals.getNode(sys~'ac-sync-bus-source[1]') ];
  var pwrL = sync_src[0].getValue();
  var pwrR = sync_src[1].getValue();
  var on_ground = getprop('gear/gear[2]/wow') or getprop('gear/gear[3]/wow');
  #var ac_sync_L = ext1 or apu1 or (
  var ac = [0, 0, 0, 0];

  var ghb = ext1 or apu1;
  #var gsb = ac1 or (ghb and getprop(controls, 'ground-service'));

  #var apu_hot_batt = getprop(sys, 'outputs/apu-hot-batt-bus-v') > 25 ? 1 : 0;
  #var main_hot_batt = getprop(sys, 'outputs/main-hot-batt-bus-v') > 25 ? 1 : 0;

  #var ac1 = 

  # ext-pwr avail if park-brake set > 60sec
  var t = getprop('sim/time/elapsed-sec');
  var ep = [0, 0];
  #if (!ext1) ep[0] = 0;
  #if (!ext2) ep[1] = 0;
  if (pbrake_time == 0) {	# brake released
    if (pwrL == 'ext') {
      pwrL = '';
      sync_src[0].setValue(pwrL);
    }
    if (pwrR == 'ext') {
      pwrR = '';
      sync_src[1].setValue(pwrR);
    }
  } else {
    if (t - pbrake_time > 60) {
      if (ext1)
	if (pwrL == 'ext') ep[0] = 2; else ep[0] = 1;
      if (ext2)
	if (pwrR == 'ext') ep[1] = 2; else ep[1] = 1;
    }
  }
  setprop(sys, 'external-power[0]', ep[0]);
  setprop(sys, 'external-power[1]', ep[1]);

  # APU
  var apu_sel_on = getprop(controls, 'apu');
  ep = [0, 0];
  #if (!apu1) ep[0] = 0;
  #if (!apu2) ep[1] = 0;
  if (!apu1 and pwrL == 'apu') {
    pwrL = '';
    sync_src[0].setValue(pwrL);
  }
  if (!apu2 and pwrR == 'apu') {
    pwrR = '';
    sync_src[1].setValue(pwrR);
  }
  if (apu1 and on_ground and apu_sel_on)
    if (pwrL == 'apu') ep[0] = 2; else ep[0] = 1;
  if (apu2 and on_ground and apu_sel_on)
    if (pwrR == 'apu') ep[1] = 2; else ep[1] = 1;
  setprop(sys, 'apu-generator[0]', ep[0]);
  setprop(sys, 'apu-generator[1]', ep[1]);

  for (var i = 0; i < 4; i += 1) {
    # drive lights out if engines running
    var idg = getprop(sys, 'suppliers/idg-v['~i~']');
    var d = 1;
    if (idg > 110) d = 0;
    setprop(sys, 'generator-drive['~i~']', d);

    # isln lights
    var bt = getprop(controls, 'bus-tie['~i~']');
    d = 0;
    if (bt == 0) d = 1;
    setprop(sys, 'bus-isolation['~i~']', d);

    # gen cont lights -- depends on who's feeding the AC bus
      # if idg-v < 110, or
      # gen-cont OFF, or
      # ac-sync-bus-source[0] != 'idg' and bus-tie AUTO
    var genoff = props.globals.getNode(sys~'generator-off['~i~']');
    var gc = getprop(controls, 'generator-control['~i~']');
    var p = i < 2 ? pwrL : pwrR;
    d = 0;
    if (idg < 110 or gc == 0 or (p != 'idg' and bt == 1)) {
      d = 1;
      # ac-sync-bus-source is detached from IDG
      if (p == 'idg') sync_src[i<2?0:1].setValue('');

      # XXX turning 1 GEN CONT off causes same half of sync bus to switch source
      # XXX SSB

    } else {
      # connect GEN CONT and update ac-sync-src when engine is started
      # (ie GCB just closed)
      if (genoff.getValue() == 1) _connect_generator(i);
    }
    genoff.setValue(d);

    # define ac-bus[0123]
    ac[i] = genoff.getValue() == 0 or 
	    (getprop(sys, 'bus-isolation['~i~']') == 0 and p != '') ? 1 : 0;
    setprop(sys, 'ac-bus['~i~']', ac[i]);
  }

  # utility lights
  d = 1;
  d = ac[0] and ac[1] ? 0 : 1;
  setprop(sys, 'utility-off[0]', d);
  d = 1;
  d = ac[2] and ac[3] ? 0 : 1;
  setprop(sys, 'utility-off[1]', d);
}

var resched_bus_refresh = func
{
  elec_bus_refresh();
  settimer(resched_bus_refresh, 5);
}

var mark_pbrake = func(n)
{
  if (n.getValue() == 1)
    pbrake_time = getprop('sim/time/elapsed-sec');
  else
    pbrake_time = 0;
}

resched_bus_refresh();
print('744_elec: so far so good');
#setlistener("controls/electric/battery", batt_sw);
#setlistener("systems/electrical/outputs/main-batt-bus-v", main_batt_bus);
setlistener('controls/gear/brake-parking', mark_pbrake);


# /controls/electric/
# battery-switch
# external-power
# APU-generator
# engine[0]/generator
# engine[0]/bus-tie
# 
# battery
# standby-power
# apu
# utility[2]
# apu-gen[2]
# external-power[2]
# bus-tie[4]
# generator-control[4]
# drive-disconnect[4]
# 
# /controls/APU/apu-sw
# 
# /systems/electrical/outputs/
# ground-service-bus
# ground-handling-bus
# apu-standby-bus
# main-standby-bus
# capt-transfer-bus
# fo-transfer-bus
# apu-batt-bus
# main-batt-bus
# apu-hot-batt-bus
# main-hot-batt-bus
# ac-bus[4]
# dc-bus[4]
