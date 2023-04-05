runPath("../lib/landing_lib.ks").
runPath("../lib/ui_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/landVac_lib.ks").
runPath("../lib/vecDraw_lib.ks").

parameter killHorSpeed is false.
//STARTING HERE

waitForStart().
activateEngines().

//deOrbitBurn(0).
if killHorSpeed {
  killhorizontalspeed().  
}
suicideburn().

clearVecDraws().