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
      set p:part:tag to p:part:uid.
      procList:add(p:part).
    }
  }
  return procList.
}

function doBoosterStaging {
  parameter proc.

  local message to "undock".
  if not proc:tag {
    printO("STAGING", "Missing processor nametag").
    return.
  }
  set proc to processor(proc:tag).
  if not proc:connection:sendmessage(message) {
    printO("STAGING", "Nem sikerült elküldeni a parancsot").
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

function getCurrentStageBoosters {
  local boosters to list().
  list engines in engineList.
  local currentStageNumber to getMaxStageNumber(engineList).
  
  for e in  engineList {
    if e:decoupledin = currentStageNumber {
      boosters:add(e).
    }
  }
  return boosters.
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
  if(checkEngines()){
    local procs to getBoosterProcessors().
    for p in procs {
      doBoosterStaging(p).
    }
    doSafeStage().
  }
  wait 1.
}

function doSafeStage {
  wait until stage:ready.
  printO("STAGING","Fokozat szétválasztva").
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
    if f:hasaction("extend antenna"){
      f:doaction("extend antenna", true).
    }
  }
}

function retractAntenna {
  for f in ship:modulesnamed("ModuleDeployableAntenna") {
    if f:hasaction("retract antenna"){
      f:doaction("retract antenna", true).
    }
  }
}