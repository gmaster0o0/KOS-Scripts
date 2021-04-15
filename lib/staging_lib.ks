function doSafeParachute {
  lock steering to srfRetrograde.     
  until status = "LANDED" or status = "SPLASHED" {
    if NOT chutesSafe and altitude < body:atm:height and verticalSpeed < 0 {
        print("STAGING:Ejtőernyő kinyitva").
        chutesSafe ON.
        gear ON.
    }
  }
}

function getBoosterProcessors {
  list processors in processorList.
  local procList to list().
  local maxStage to -2.
  for p in processorList {
    if p:part:decoupledin > maxStage {
      set maxStage to p:part:decoupledin.
      procList:clear().
    }
    set p:part:tag to p:part:uid.
    procList:add(p:part).
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
  list engines in engines.
  if(engines:length <> 0){
    return ship:availableThrust = 0.
  }
  return false.
}

function checkBoosters {
  if(checkEngines()){
    local procs to getBoosterProcessors().
    for p in procs {
      doBoosterStaging(p).
    }
    doSafeStage().
  }
}

function doSafeStage {
  wait until stage:ready.
  printO("STAGING","Fokozat szétválasztva").
  stage.
}