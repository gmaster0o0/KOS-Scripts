runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/transfer_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/node_lib.ks").
runPath("../lib/vecDraw_lib.ks").

clearScreen.
clearVecDraws().

parameter fineTune is false.
parameter turningTime is 60.

nodeLib:executeNode(nextNode, turningTime, fineTune).
