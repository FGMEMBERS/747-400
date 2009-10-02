settimer(func {

  # Add listener for engine fire
  setlistener("controls/engines/engine/on-fire", func(n) {
      wildfire.ignite;
  });

}, 0);