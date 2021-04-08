function launch {
  parameter countDownTime is 10.
  if status = "PRELAUNCH" {
    countDown(countDownTime).
    stage.
    printO("LAUNCH","Kilövés").
  }
}

function waitUntilEndOfAtmosphere {
  printO("LAUNCH", "Várakozás amíg a hajó kiér a légkörből").
  lock throttle to 0.
  until altitude > body:atm:height {
    flightData().
  }
  printO("LAUNCH", "Kilépés a légkörből").
  lock steering to prograde.
  wait 3.
}

function gravityTurn {
  parameter targetApo is 80000.
  
  lock pitch  to max(8,90*(1-apoapsis/body:atm:height)).
  lock steering to heading(90,pitch).
  lock throttle to 1.
  printO("LAUNCH", "Emelkedés "+targetApo + "m").
  until apoapsis > targetApo {
    flightData().
    checkBoosters().
  }
}
 