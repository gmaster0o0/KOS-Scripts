//unpack space station.
runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").

parameter command.

local function releaseSafetyStruts {
  local safeties is ship:partstagged("safety").
  for s in safeties {
    decoupleDock(s:parent).  
  }
}

local function sendCommand {
  parameter cmd.
  local proc to processor("solar").
  if not proc:connection:sendmessage(cmd:TOUPPER) {
    printO("STATION", "Nem sikerült elküldeni a parancsot").
  }
}

local function decoupleDock {
  parameter dockingPort.
  for f in dockingPort:modulesnamed("ModuleDockingNode") {
    if f:hasaction("decouple node"){
      f:doEvent("decouple node").
    }
  }
} 

if command = "PACK" {
  retractAntenna().
  sendCommand("FOLD").
}

if command = "UNPACK" {
  deployFairing().
  wait 3.
  extendAntenna().
  releaseSafetyStruts().
  sendCommand("UNFOLD").
}