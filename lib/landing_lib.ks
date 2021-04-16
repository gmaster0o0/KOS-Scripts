
function deOrbitBurn {
  parameter targetPeri is 20000.
  printO("LANDING","Periapsis csokkentese").
  lock  throttle to 1.
  lock steering to retrograde.
  until  periapsis < targetPeri {
    flightData().
    checkBoosters().
  }
}

function waitToEnterToATM {
  printO("LANDING","Varunk aming az atmoszferaba erunk").
  lock  throttle to 0.
  lock steering to retrograde.
  until altitude < body:atm:height {
    flightData().
  }
}

function reachSafeLandingSpeed {
  printO("LANDING","Fékezés biztonságos sebességre").
  lock  throttle to 1.
  lock steering to retrograde.
  until airspeed < 1500 {
    flightData().
    checkBoosters().
  }
  lock  throttle to 0.
}