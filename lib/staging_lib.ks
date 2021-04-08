function doSafeParachute {
  until status = "LANDED" or status = "SPLASHED" {
    if NOT CHUTESSAFE and altitude < body:atm:height and verticalSpeed < 0 {
        print("STAGING:Ejtőernyő kinyitva").
        CHUTESSAFE ON.
    }
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
    doSafeStage().
  }
}

function doSafeStage {
  wait until stage:ready.
  printO("STAGING","Fokozat szétválasztva").
  stage.
}