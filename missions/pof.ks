
runPath("../lib/utils_lib.ks").
runPath("../lib/node_lib.ks").

clearScreen.
removeNodes().

local PE_GOAL is 0.
//Kerbin Arrival Orbit
local centerBody is body:body.
local RET_AP to minmus:altitude + centerBody:radius.
local RET_PE to PE_GOAL + centerBody:radius.
local RET_SMA to (RET_PE+RET_AP)/2.
local V_AP to sqrt(body:body:mu * (2/(RET_AP) - (1/RET_SMA))).
//CURRENT DATAS
local V_OBT to body:OBT:VELOCITY:ORBIT:MAG.
local V_REL to V_OBT - V_AP.
local R_PE is  periapsis +body:radius.
local R_AP is  apoapsis +body:radius.
local V_ESC to sqrt(2*body:mu / R_PE).
local V_BO to sqrt(V_REL^2 + V_ESC^2).
local V_CURRENT to VELOCITY:ORBIT:MAG.
local DeltaV to V_BO - V_CURRENT.
//HYPERBLOIC TRAJECTORY DATA
local SMA_HYP is 1/(2/R_PE-(V_BO^2/body:mu)).
local HYP_ECC is 1 - R_PE/SMA_HYP.
//angle betwee dep asymptote and periapsis vector
local A_ANGLE is ARCCOS(-1/HYP_ECC).
local ORBIT_ANGLE is calcSignAngle().
local PHASE_ETA is calcPhaseETA(A_ANGLE,ORBIT_ANGLE).

print "RET_AP:     " + RET_AP.
print "RET_PE:     " + RET_PE.
print "RET_SMA:     " + RET_SMA.
print "V_AP:     " + V_AP.
print "V_OBT:     " + V_OBT.
print "V_REL:     " + V_REL.  
print "R_PE:     " + R_PE.
print "R_AP:     " + R_AP.
print "V_ESC:     " + V_ESC.
print "V_BO:     " + V_BO.
print "V_CURRENT:     " + V_CURRENT.
print "DeltaV:      " + DeltaV.
print "SMA_HYP:     " + SMA_HYP.
print "HYP_ECC:     " + HYP_ECC.
print "A_ANGLE:       " +  A_ANGLE.
print "PHASE_ETA:     " + PHASE_ETA.

local testnode to node(time:seconds + PHASE_ETA, 0, 0, DeltaV).
add testnode.

function calcPhaseETA {
  parameter targetAng.
  parameter currentAng.

  local shipAngularVelocity is 360/ship:orbit:period.
  return utilReduceTo360(targetAng - currentAng) / shipAngularVelocity.
}

function calcSignAngle {
  local BODY_VEL_V is BODY:OBT:VELOCITY:ORBIT.
  local SHIP_V_V is SHIP:VELOCITY:ORBIT.
  local SHIP_P_V to body:position.
  local SHIP_N_V to vCrs(SHIP_P_V,SHIP_V_V):normalized.
  //signed Angle between body velocity and ship velocity vector
  //LOCAL ANG to lngToDegrees(arcTan2(vDot(vCrs(SHIP_V_V,BODY_VEL_V),SHIP_N_V),vDot(SHIP_V_V,BODY_VEL_V))).
  local ANG is signAngle(SHIP_V_V, BODY_VEL_V,SHIP_N_V).
  return ANG.
}