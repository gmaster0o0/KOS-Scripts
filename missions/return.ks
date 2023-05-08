runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/transfer_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/warp_lib.ks").

parameter missionStatus is 0.

clearScreen.

if missionStatus = 0 {
  escapeTransfer().
  set missionStatus to 1.
}
if missionStatus = 1 {
  waitUntilLeaveSOI().
  set missionStatus to 2.
}
if missionStatus = 2{
  waitToEnterToATM().
  set missionStatus to 3.
}
if missionStatus = 3{
  reachSafeLandingSpeed().
  set missionStatus to 4.
}
doSafeParachute().