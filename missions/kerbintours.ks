clearScreen.

set steering to UP.
set throttle to 1.

stage.

until apoapsis > 90000 {
  print "APOAPSIS: " + round(apoapsis) at (2,3).
  print "SPEED: " + round(airspeed) at (2,4).

  if(checkEngines()){
    stage.
  }
}
set throttle to 0.

doSafeParachute().

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
