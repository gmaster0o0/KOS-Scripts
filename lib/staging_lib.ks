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