####    2 Generator Jet Electrical system    ####
####    Syd Adams    ####
#### Based on Curtis Olson's nasal electrical code ####

var ammeter_ave = 0.0;
var outPut = "systems/electrical/outputs/";
var Breakers = "systems/electrical/breakers/";
var switch_list=[];
var output_list=[];
var breaker_list=[];
var load_list=[];

var Volts = props.globals.getNode("/systems/electrical/bus-volts",1);
var Amps = props.globals.getNode("/systems/electrical/amps",1);
var EXT  = props.globals.getNode("/controls/electric/external-power",1);

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.05, 1.2,], "/controls/lighting/beacon" );
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.05, 3,], "/controls/lighting/strobe" );


#var battery = Battery.new(switch-prop,volts,amps,amp_hours,charge_percent,charge_amps);
Battery = {
    new : func(swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(0);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp;
            m.charge_amps = cha;
            m.output = props.globals.getNode("systems/electrical/batt-volts",1);
            m.output.setDoubleValue(0);
    return m;
    },

    apply_load : func(load,dt) {
        var pwr = me.switch.getValue();
        if(pwr){
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else{return 0;}
    },

    get_output_volts : func {
        var pwr = me.switch.getValue();
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        var output =me.ideal_volts * factor;
        output=output *pwr;
        me.output.setValue(output);
        return output;
    },

    get_output_amps : func {
        var pwr = me.switch.getValue();
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        var output =me.ideal_amps * factor;
        return output*pwr;
    }
};

# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        if(m.switch.getValue()==nil)m.switch.setBoolValue(0);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        return m;
    },

    apply_load : func(load) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load * factor);
            if(gout>1)gout=1;
        }else{
            gout=0;
        }
        if(cur_amp > gout)me.meter.setValue(cur_amp - 0.01);
        if(cur_amp < gout)me.meter.setValue(cur_amp + 0.01);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        return out;
    },

    get_output_amps : func {
        var ampout =0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    }
};

var battery = Battery.new("/controls/electric/battery-switch",24,30,34,1.0,7.0);
alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator","/engines/engine[0]/rpm",40.0,28.0,60.0);
alternator2 = Alternator.new(1,"controls/electric/engine[1]/generator","/engines/engine[1]/rpm",40.0,28.0,60.0);
var bus_norm= 1/28;

#####################################
setlistener("/sim/signals/fdm-initialized", func {
    init_electrical();
    settimer(update_electrical,5);
    print("Electrical System ... ok");
});

var init_electrical = func{

    setprop("controls/lighting/instruments-norm",0);
    setprop("controls/lighting/eng-norm",0);
    setprop("controls/lighting/efis-norm",0);
    setprop("controls/lighting/panel-norm",0);

    append(switch_list,"controls/engines/engine[0]/starter");
    append(output_list,"starter[0]");
    append(load_list,10.0);
    append(switch_list,"controls/engines/engine[1]/starter");
    append(output_list,"starter[1]");
    append(load_list,10.0);
    append(switch_list,"controls/cabin/fan");
    append(output_list,"cabin-fan");
    append(load_list,0.5);
    append(switch_list,"controls/cabin/heat");
    append(output_list,"cabin-heat");
    append(load_list,0.5);
    append(switch_list,"controls/anti-ice/prop-heat");
    append(output_list,"prop-heat");
    append(load_list,0.5);
    append(switch_list,"controls/anti-ice/pitot-heat");
    append(output_list,"pitot-heat");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/landing-lights");
    append(output_list,"landing-lights");
    append(load_list,1.0);
    append(switch_list,"controls/lighting/beacon-state/state");
    append(output_list,"beacon");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/nav-lights");
    append(output_list,"nav-lights");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/cabin-lights");
    append(output_list,"cabin-lights");
    append(load_list,1.0);
    append(switch_list,"controls/lighting/wing-lights");
    append(output_list,"wing-lights");
    append(load_list,1.0);
    append(switch_list,"controls/lighting/recog-lights");
    append(output_list,"recog-lights");
    append(load_list,1.0);
    append(switch_list,"controls/lighting/logo-lights");
    append(output_list,"logo-lights");
    append(load_list,1.0);
    append(switch_list,"controls/lighting/taxi-lights");
    append(output_list,"taxi-lights");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/strobe-state/state");
    append(output_list,"strobe");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/instruments-norm");
    append(output_list,"instrument-lights");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/efis-norm");
    append(output_list,"efis-lights");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/panel-norm");
    append(output_list,"panel-lights");
    append(load_list,0.5);
    append(switch_list,"controls/lighting/eng-norm");
    append(output_list,"eng-lights");
    append(load_list,0.5);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"adf");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"adf[1]");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"dme");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"gps");
    append(load_list,1.5);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"DG");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"transponder");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"mk-viii");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"tacan");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"turn-coordinator");
    append(load_list,0.5);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"comm");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"comm[1]");
    append(load_list,1.0);
    append(switch_list,"instrumentation/nav/power-btn");
    append(output_list,"nav");
    append(load_list,1.0);
    append(switch_list,"instrumentation/nav[1]/power-btn");
    append(output_list,"nav[1]");
    append(load_list,1.0);
    append(switch_list,"controls/electric/avionics-switch");
    append(output_list,"KNS80");
    append(load_list,1.0);
    append(switch_list,"controls/engines/engine[0]/fuel-pump");
    append(output_list,"fuel-pump[0]");
    append(load_list,1.0);
    append(switch_list,"controls/engines/engine[1]/fuel-pump");
    append(output_list,"fuel-pump[1]");
    append(load_list,1.0);

    for(var i=0; i<size(switch_list); i+=1) {
        var tmp = props.globals.getNode(switch_list[i],1);
        if(tmp.getValue()==nil)tmp.setBoolValue(0);
        var tmp2 = props.globals.getNode(Breakers~output_list[i],1);
        tmp2.setBoolValue(1);
    }
}


var update_virtual_bus = func( tm ) {
    var dt = tm;
    var PWR = getprop("systems/electrical/serviceable");
    var battery_volts = battery.get_output_volts();
    var alternator1_volts = alternator1.get_output_volts();
    var alternator2_volts = alternator2.get_output_volts();
    var external_volts = 24.0;

    var load = 0.0;
    var bus_volts = 0.0;
    var power_source = nil;

        bus_volts = battery_volts;
        power_source = "battery";

    if (alternator1_volts > bus_volts) {
        bus_volts = alternator1_volts;
        power_source = "alternator1";
        }

    if (alternator2_volts > bus_volts) {
        bus_volts = alternator2_volts;
        power_source = "alternator2";
        }
    if ( EXT.getBoolValue() and ( external_volts > bus_volts) ) {
        bus_volts = external_volts;
        }

    bus_volts *=PWR;


    load += electrical_bus(bus_volts);

    ammeter = 0.0;
    if ( power_source == "battery" ) {
        ammeter = -load;
        } else {
        ammeter = battery.charge_amps;
    }

    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
        } elsif ( bus_volts > battery_volts ) {
        battery.apply_load( -battery.charge_amps, dt );
        }

    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

   Amps.setValue(ammeter_ave);
    Volts.setValue(bus_volts);
    alternator1.apply_load(load);
    alternator2.apply_load(load);

return load;
}
#######################
var electrical_bus = func(vlt) {
    var bus_volts = vlt;
    var load = 0.0;
    var srvc = 0.0;

    for(var i=0; i<size(switch_list); i+=1) {
        var srvc = getprop(switch_list[i]);
        var brkr = getprop(Breakers~output_list[i]);
        srvc = srvc*brkr;
        setprop(outPut~output_list[i],bus_volts * srvc);
        load = load + srvc * load_list[i];
    }
setprop(outPut~"instrument-lights-norm",0.035714 * getprop(outPut~"instrument-lights"));
    setprop(outPut~"flaps",bus_volts);

    return load;
}
#######################

var update_electrical = func {
    var scnd = getprop("sim/time/delta-sec");
    update_virtual_bus( scnd );
settimer(update_electrical, 0);
}
