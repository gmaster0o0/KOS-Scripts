runOncePath("utils_lib").
runOncePath("ui_lib").

function getPistons {
  parameter parentPart.
  local pistons is parentPart:partsnamedpattern("Piston").
  
  return pistons.
}

function getSolarPanels {
  parameter parentPart.
  local solarPanels is parentPart:partsnamed("LargeSolarPanel").
  return solarPanels.
}

function getSolarSystem {
  local hinges is ship:partsnamedpattern("Hinge.*").
  local solarSystem is list().

  for h in hinges {
    local solarPanels is getSolarPanels(h).
    if solarPanels:length > 0 {
      local solarArm is lexicon().
      local pistons is getPistons(h).
      set solarArm["hinge"] to h.
      set solarArm["solars"] to solarPanels.
      set solarArm["pistons"] to pistons.
      solarSystem:add(solarArm).
    }
  }

  return solarSystem.
}

function unfold {
  parameter solarSystem is getSolarSystem().

  for s in solarSystem {
    extendHinge(s["hinge"]).
    for p in s["pistons"] {
      extendPistion(p).
    }
  }
  wait 20.
  panels on.
  printO("SOLAR","Unfold finished").
}

function fold {
  parameter solarSystem is getSolarSystem().
  panels off.
  wait 5.
  for s in solarSystem {
    retractHinge(s["hinge"]).
    for p in s["pistons"] {
      retractPistion(p).
    }    
  }

  print "Fold finished".
}

function retractHinge {
  parameter hinge.
  local hmodule is hinge:getmodule("ModuleRoboticServoHinge"). 
  hmodule:setField("target angle",-90).
}

function extendHinge {
  parameter hinge.
  local hmodule is hinge:getmodule("ModuleRoboticServoHinge").
  hmodule:setField("target angle",0).
}

function extendPistion {
  parameter piston.
  local pmodule is piston:getmodule("ModuleRoboticServoPiston").
  pmodule:setField("target extension",getMaxExtension(piston)).
}

function retractPistion {
  parameter piston.
  local pmodule is piston:getmodule("ModuleRoboticServoPiston").
  pmodule:setField("target extension",0).
}

function getMaxExtension {
  parameter piston.

  local maxExtensions is lex(
    "piston.01", 1.6,
    "piston.02", 0.8,
    "piston.03", 4.8,
    "piston.04", 2.4
  ).
  return maxExtensions[piston:name].
}
until false {
  wait until not core:messages:empty.
  set received to core:messages:pop.
  if received:content = "FOLD" {
    printO("SOLAR","Solar system folding").
    fold().
  }else if received:content = "UNFOLD"{
    printO("SOLAR","Solar system unfolding").
    unfold().
  }
  else{
    printO("SOLAR","Invalid message: " + received:content).
  }
}
