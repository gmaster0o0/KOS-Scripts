
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
  //retractAntenna().
}

function waitUntilEndOfAtmosphere {
  printO("LAUNCH", "Várakozás amíg a hajó kiér a légkörből").
  lock throttle to 0.
  until altitude > body:atm:height {
    flightData().
  }
  printO("LAUNCH", "Kilépés a légkörből").
  lock steering to prograde.
  wait until steeringManager:ANGLEERROR < 1.

  deployFairing().
  wait 2.
  panels on.
  rcs on.
  //extendAntenna().
}

function waitToEncounter {
  wait until status = "ESCAPE".
  printO("TRANSFER",target:name + "Vonzáskörzete elérve").
}

function waitUntilLeaveSOI {
  parameter home is "KERBIN".
  local OldSOI is body:name.
  wait until body:name <> home.
  printO("TRANSFER",OldSOI + "Vonzáskörzete elhagyva").
}