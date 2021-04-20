function launch {
  parameter countDownTime is 10.
  sas off.
  if status = "PRELAUNCH" or status = "LANDED" {
    countDown(countDownTime).
    stage.
    printO("LAUNCH","Kilövés").
  }
}

function gravityTurn {
  parameter targetApo is 80000.
  
  lock pitch  to getPitch(targetApo).
  lock steering to heading(90,pitch).
  lock throttle to 1.
  printO("LAUNCH", "Emelkedés "+targetApo + "m").
  until apoapsis > targetApo {
    flightData().
    checkBoosters().
  }
}

function getPitch {
  parameter targetApo.
  if body:atm:height > 0 {
     max(8,90*(1-apoapsis/body:atm:height)).
  }
  return max(3,90*(1-apoapsis/targetApo)).
}
 