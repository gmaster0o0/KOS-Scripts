
function deOrbitBurn {
  printO("LANDING","Periapsis csokkentese").
  lock  throttle to 1.
  lock steering to retrograde.
  until  periapsis < 20000 {
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