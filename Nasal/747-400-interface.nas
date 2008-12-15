# ====
# MENU
# ====

Menu = {};

Menu.new = func {
   obj = { parents : [Menu],

           crew : nil,
           fuel : nil,
           radios : nil,
           menu : nil
         };

   obj.init();

   return obj;
};

Menu.init = func {
   # B747-400, because property system refuses 747-400
   me.menu = gui.Dialog.new("/sim/gui/dialogs/B747-400/menu/dialog",
                            "Aircraft/747-400/Dialogs/747-400-menu.xml");
   me.crew = gui.Dialog.new("/sim/gui/dialogs/B747-400/crew/dialog",
                            "Aircraft/747-400/Dialogs/747-400-crew.xml");
   me.fuel = gui.Dialog.new("/sim/gui/dialogs/B747-400/fuel/dialog",
                            "Aircraft/747-400/Dialogs/747-400-fuel.xml");
   me.radios = gui.Dialog.new("/sim/gui/dialogs/B747-400/radios/dialog",
                            "Aircraft/747-400/Dialogs/747-400-radios.xml");
}