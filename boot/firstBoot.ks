parameter goalAlt is 15000.
parameter goalSpeed is 1700.

set steering to UP.
set throttle to 1.
stage.

until altitude > goalAlt {
  if airspeed > goalSpeed {
    set throttle to 0.
  }else {
    set throttle to 1.
  }
}

set throttle to 0.
//ejtnyoernyo
until CHUTESSAFE and verticalSpeed > 0 {
  print verticalSpeed > 0.
  CHUTESSAFE ON.
}
