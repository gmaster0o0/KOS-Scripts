
function deOrbitBurn {
  parameter targetPeri is 20000.
  printO("LANDING","Periapsis csokkentese").
  lock  throttle to 1.
  lock steering to retrograde.
  until  periapsis < targetPeri {
    checkBoosters().
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