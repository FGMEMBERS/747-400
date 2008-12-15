var pushback = func {
if (getprop("controls/pushback") == 1){ 
 setprop("sim/current-view/view-number",9)
}

settimer(pushback, 0.1);
}