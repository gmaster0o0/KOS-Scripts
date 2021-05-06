
function waitToApoapsis {
  parameter lead is 10.

  lock  throttle to 0.
  printO("CIRC","Varunk aming az apoapsishoz erunk").
  until eta:apoapsis < lead {
    cancelWarpBeforeEta(eta:apoapsis,lead).
  }
}

function waitToPeriapsis {
  parameter lead is 10.

  lock  throttle to 0.
  printO("CIRC","Varunk aming az periapsishoz erunk").
  until eta:periapsis < lead {
    cancelWarpBeforeEta(eta:periapsis,lead).
  }
}

function waitToEnterToATM {
  printO("LANDING","Varunk aming az atmoszferaba erunk").
  lock  throttle to 0.
  lock steering to retrograde.
  until altitude < body:atm:height {
    flightData().
  }

  panels off.
  retractAntenna().
}

function waitUntilEndOfAtmosphere {
  parameter autoDeploy is true.
  parameter targetApo is 0.

  printO("LAUNCH", "Várakozás amíg a hajó kiér a légkörből").
  local adjustThrottle is 0.
  lock throttle to adjustThrottle.
  until altitude > body:atm:height {
    if targetApo > 0 and apoapsis < targetApo {
      set adjustThrottle to 0.2*(1 - apoapsis/targetApo).
      checkBoosters().
    }else {
      set adjustThrottle to 0.
    }

    flightData().
  }
  printO("LAUNCH", "Kilépés a légkörből").
  lock steering to prograde.
  wait until steeringManager:ANGLEERROR < 1.
  if autoDeploy {
    deployFairing().
    wait 2.
    panels on.
    rcs on.
    extendAntenna().
  }
}

function waitToEncounter {
  parameter targetBody.
  wait until obt:transition <> "ENCOUNTER" and body:name <> targetBody.
  printO("TRANSFER",body:name + "Vonzáskörzete elérve").
}

function waitUntilLeaveSOI {
  parameter home is "KERBIN".
  local OldSOI is body:name.
  wait until body:name <> home.
  printO("TRANSFER",OldSOI + "Vonzáskörzete elhagyva").
}