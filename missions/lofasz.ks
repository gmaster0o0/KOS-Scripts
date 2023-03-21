set config:ipu to 2000.
runOncePath("0:/examples/rsvp/main").
local options is lexicon("create_maneuver_nodes", "both", "verbose", true, "final_orbit_type","none").
parameter targetBody is duna.
rsvp:goto(targetBody, options).