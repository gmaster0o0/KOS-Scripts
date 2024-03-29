function getBoosterProcessors {
  list processors in processorList.
  local procList to list().
  local maxStage to -2.
  for p in processorList {
    if p:part:decoupledin >= maxStage {
      if p:part:decoupledin > maxStage {
        set maxStage to p:part:decoupledin.
        procList:clear().
      }
      if p:bootfilename = "/boot/booster.ks"{
        set p:part:tag to p:part:uid.
        procList:add(p:part).
      }
    }
  }
  return procList.
}

function getSolarProcessor {
  list processors in processorList.
  for p in processorList {
    if p:bootfilename = "/boot/solar.ks"{
      set p:part:tag to "Solar".
      return p.
    }
  }
}
//Do booster stage and sending a undock command to the booster processor
function doBoosterStaging {
  parameter proc.

  local message to "undock".
  if not proc:tag {
    printO("STAGING", "Missing processor nametag").
    return.
  }
  set proc to processor(proc:tag).
  if not proc:connection:sendmessage(message) {
    printO("STAGING", "Command sending was unsuccessful").
  }
}

function checkEngines {
  local boosters to getCurrentStageBoosters().

  if boosters:length = 0 {
    return false.
  }
  local empty to true.
  for b in boosters {
    set empty to (empty and b:flameout).
  }
  return empty.
}

function checkTanks {
  local tanks to getStagedTanks().

  if tanks:length = 0 {
    return false.
  }

  local empty to true.
  for t in tanks{
    set empty to (empty and isTankEmpty(t)).
  }
  
  return empty.
}

function isTankEmpty {
  parameter t.
  parameter fuelTypes is list("Oxidizer", "LiquidFuel").

  for r in t:resources {
    if(fuelTypes:contains(r:name)){
      return r:amount < 0.01.
    }
  }.
  return false.
}

function getStagedTanks {
  local stagingTankFuels is list("LiquidFuel").
  local fuelTanks to list().

  for p in getStagedParts() {
    for r in p:resources {
      if stagingTankFuels:contains(r:name) {
        if not fuelTanks:contains(p) {
          fuelTanks:add(p).
        }
      }
    }
  }

  return fuelTanks.
}

function getCurrentStageBoosters {
  local boosters to list().
  local engineList is list().
  list engines in engineList.
  local currentStageNumber to getMaxStageNumber(engineList).
  
  for e in  engineList {
    if e:decoupledin = currentStageNumber and e:ignition{
      boosters:add(e).
    }
  }
  return boosters.
}

function getCurrentStageTanks {

}

function getStagedPartsMass {
  parameter stagenumber is stage:number.

  local totalMass to 0.
  for p in getStagedParts(stagenumber) {
    set totalMass to totalMass + p:drymass.
  }

  return totalMass.
}

function getStagedParts {
  parameter stagenumber is stage:number.

  list parts in partsList.
  local stagedParts to list().

  for p in partsList {
    if p:decoupledin = stagenumber - 1 or (p:decoupledin = -1 and stagenumber = p:stage){
      stagedParts:add(p).
    }
  }
  return stagedParts.
}

function getMaxStageNumber {
  parameter _parts.
  local _max to -1.

  for p in _parts {
    if p:decoupledin > _max {
      set _max to p:decoupledin.
    }
  }
  return _max.
}

function checkBoosters {
  if(checkEngines() or checkTanks()){
    local procs to getBoosterProcessors().
    for p in procs {
      doBoosterStaging(p).
    }
    if stage:number > 0{
      wait 1.
      doSafeStage().
    }
  }
}

function activateEngines {
  local engineList is list().
  list engines in engineList.

  for e in engineList {
    if not e:flameout and not e:ignition and e:stage = stage:number {
      e:activate().
    }
  }
  
  if(engineList:length = 1){
    local e is engineList[0].
    if not e:flameout and not e:ignition and e:stage+1 = stage:number {
      doSafeStage().
    }
  }
  return engineList.
}

function doSafeStage {
  wait until stage:ready.
  printO("STAGING","Stage safely separated").
  stage.
}

function deployFairing {
  for f in ship:modulesnamed("ModuleProceduralFairing") {
    if f:hasevent("deploy"){
      f:doevent("deploy").
    }
  }
}

function extendAntenna {
  for f in ship:modulesnamed("ModuleDeployableAntenna") {
    if f:hasevent("extend antenna"){
      f:doevent("extend antenna").
    }
  }
}

function retractAntenna {
  for f in ship:modulesnamed("ModuleDeployableAntenna") {
    if f:hasevent("retract antenna"){
      f:doevent("retract antenna").
    }
  }
}