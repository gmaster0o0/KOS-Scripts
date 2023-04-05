//TODO remove this maybe
runPath("../lib/vecDraw_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/node_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/change_orbit_lib.ks").
runPath("../lib/hohhman_lib.ks").

parameter targetInc is "".
parameter autoWarp is false.

local orbitLib is ChangeOrbitLib().
local nodeLib is NodeLib(true).



clearVecDraws().
clearScreen.
nodeLib:removeAll().

print "                    CHANGE ORBIT INCLINATION                           " at (20,0).
print "Status                               " at (60,1).
print "TA of AN               -          deg" at (60,2).
print "ETA:                                s" at (60,3).
print "velAtAn:                          m/s" at (60,4).
print "BT:                                 s" at (60,5).
print "burnVec:                          m/s" at (60,6).
print "relInc:                           deg" at (60,7).
print "throttle:                           %" at (60,8).

if targetInc = "" {
  orbitLib:changeInclination().
}else{
  orbitLib:changeInclination(targetInc).
}
//nodeLib:execute().