runOncePath("../lib/rocket_utils_lib.ks").

local startingDV is stage:deltaV.

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
  
  lock pitchAng  to getPitch(targetApo).
  lock steering to heading(90,pitchAng).
  lock throttle to 1.
  local maxQ is 0.
  printO("LAUNCH", "Emelkedés "+targetApo + "m").
  until apoapsis > targetApo {
    print round(apoapsis) at (80,1).
    print round(periapsis) at (80,2).
    print round(altitude) at (80,3).
    print round(ship:Q,5) at (80,4).
    print round(RocketUtils:TWR(),5) at (80,6).
    if ship:Q > maxQ {
      set maxQ to ship:Q.
    }else {
      if body:atm:height>0 {
        lock throttle to 2.5 / max(2.5,RocketUtils:TWR()).
      }
    }
    print round(maxQ,5) at (80,5).
    print round(getPitch(targetApo),1) at (80,7).
    checkBoosters().
  }
}

local function getPitch {
  parameter targetApo.
  if body:atm:height > 0 {
     return max(3,90*(1-apoapsis/body:atm:height)).
  }
  return max(3,90*(1-apoapsis/targetApo)).
}
 