runpath("common_missions").
runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").

parameter targetSpeed is 100.
parameter targetAlt is 1000.
parameter runTest is false.

testMission(targetSpeed,targetAlt,runTest).
