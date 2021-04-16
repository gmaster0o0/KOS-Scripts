runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/warp_lib.ks").
//CLEAR
clearScreen.
CLEARVECDRAWS().
//DEFAULT VARS
local verbose is true.
local vecDrawLex is lex().
local minAlt is 10.
//CREATE DISPLAY
if verbose {
  print "STATUS" at (40,0).
  print "verticalspeed" at (40,1).
  print "altRadar" at (40,2).
  print "maxAccUp" at (40,3).
  print "gravity" at (40,4).
  print "ffSpeed" at (40,5).
  print "impactTime" at (40,6).
  print "burningTime" at (40,7).
  print "breakingDistance" at (40,8).
  print "throttle" at (40,9).
  print "P_INP" at (40,10).
  print "StopTime" at (40,11).
  print "SurfaceSpeed" at (40,12).
  print "Slope" at (40,13).
  print "Target Cord:" at (40,14).
}
//calc gravity over altitude
function gravity {
  parameter h is altitude.
  return body:mu / (body:radius + h) ^ 2.
}
//calc max acceleration over altitude
function maxAccUp {
  parameter h is altitude.

  local shipMaxAcceleration is ship:availablethrust / ship:mass.
  return shipMaxAcceleration - (gravity(0) + gravity(h)).
}
//calc avarage gravity between 2 point
function avgGrav {
  parameter startAlt is altitude.
  parameter dist is altitude.

  return (gravity(startAlt) + gravity(startAlt - dist))/2.
}

// vf^2 = vi^2 + 2*a*d
function freeFallSpeedFromDistance {
  parameter dist. //distance
  parameter startAlt is alt:radar. // initial altitude
  parameter v0 is verticalSpeed. // initial velocity

  return sqrt(max(0,v0^2 + 2 * avgGrav(startAlt,dist)*dist)).
}
//simple breaking distance EQ
function breakingDistance {
  parameter breakingTime.
  parameter speed.

  return breakingTime * speed.
}
//calc stopping distance. Basic kinetic EQs
function calculateStoppingDistance {
  local groundVelVec is vxcl(up:vector, ship:velocity:surface).
  local bt is burnTimeForDv(groundVelVec:mag).
  //t=v/a
  local stopTime is abs(verticalSpeed) / maxAccUp.
  print stopTime at (60,11).
  // d = 1/2 *a* t^2
  local stopDistance is 1/2 * maxAccUp() * stopTime^2.
    
  fdata(stopDistance,bt).

  return stopDistance.
}
//performing suicid burn in 2 step.
//1st is hard slow down until a hover alt
//2nd state is just hover and slowly touch down
function suicideBurn {
  parameter hoverSpeed is -1.

  local hoverPID to PIDLOOP(0.5,0.1,0.05,0,1).
  set hoverPID:SETPOINT to minALT.
  local th is 0.
  lock throttle to th.

  printO("SBTESt", "wait until falling").
  wait until verticalSpeed < 0.
  
  rcs on.
  panels off.
  gear on.
  local done is false.
  lock steering to srfRetrograde.

  until done {
    print "SUICIDE BURN" at (60,0).
    local groundDistance is ship:bounds:bottomaltradar-minALT.
    set th to hoverPID:UPDATE(time:seconds,alt:radar - calculateStoppingDistance()).
    set done to groundDistance < minALT.
  }

  hoverPID:reset().
  set hoverPID:setpoint to hoverSpeed.
  until status = "LANDED"{
    print "FINAL TOUCH     " at (60,0).
    print hoverPID:input at (60,10).
    set th to hoverPID:UPDATE(time:seconds,verticalSpeed).
    wait 0.
  }
  print "LANDED      " at (60,0).
  wait 1.
  unlock all.
  sas on.
  wait 3.
  panels on.
  rcs off.
}
//Vector drawing function.
function vecDrawAdd {
  parameter vlex, vs, vend, color, label,
  scale is 1, 
  width is 0.1.

  if vlex:keys:contains(label) {
    set vlex[label]:START to vs.
    set vlex[label]:VEC to vend.
    set vlex[label]:COLOR to color.
    set vlex[label]:SCALE to scale.
    set vlex[label]:WIDTH to width.
  }else{
    vlex:add(label,vecDraw(vs,vend,color,label,scale,true,width)).
  }
}
//display fligth data
function fdata { 
  parameter stopDistance is "",
  bt is "",
  ffs is "".

  local groundVelVec is vxcl(up:vector, ship:velocity:surface).
  //local surfVelVec is ship:velocity:surface.
  local slope is groundSlope().
  if verbose {
    print verticalSpeed at (60,1).
    print alt:radar at (60,2).
    print maxAccUp(altitude) at (60,3).
    print gravity(altitude) at (60,4).
    print ffs at (60,5).
    print calcImpactTime() at (60,6).
    print bt at (60,7).
    print stopDistance at (60,8).
    print throttle at (60,9).
    //print hoverPID:input at (60,10).
    print groundVelVec:mag at (60,12).
    print slope at (60,13).
  }

  //vecDrawAdd(vecDrawLex,ship:position,groundVelVec,RED,"GVV").
  //vecDrawAdd(vecDrawLex,ship:position,surfVelVec,BLUE,"velVec").
}
//calculate ground slope around the impact position.
//form plane from triangular around the center
function groundSlope {
  local center is ship:position.
  if ADDONS:TR:HASIMPACT {
    set center to ADDONS:TR:IMPACTPOS:position.
  }
  local tri is createTriangle(50,center).
  local a is body:geopositionOf(tri["north"]).
  local b is body:geopositionOf(tri["east"]).
  local c is body:geopositionOf(tri["west"]).

  local a_vec is a:altitudePosition(a:terrainHeight).
  local b_vec is b:altitudePosition(b:terrainHeight).
  local c_vec is c:altitudePosition(c:terrainHeight).

  vecDrawAdd(vecDrawLex,ship:position,a_vec,WHITE,"a_vec").
  vecDrawAdd(vecDrawLex,ship:position,b_vec,WHITE,"b_vec").
  vecDrawAdd(vecDrawLex,ship:position,c_vec,WHITE,"c_vec").
  //vecDrawAdd(vecDrawLex,ship:position,center,WHITE,"c").

  local slopeNormVec is  vectorCrossProduct(c_vec - a_vec, b_vec - a_vec):normalized.
  return vang(slopeNormVec, center - body:position).
}
//create vector triangle
function createTriangle {
  parameter height is 10.
  parameter center is ship:position.

  local east is vectorCrossProduct(north:vector, up:vector) * height * sin(60) .
  return lexicon(
    "north", center + height * north:vector,
    "east", center - height * cos(60) * north:vector + east,
    "west", center - height * cos(60) * north:vector - east
  ).
}
//calc impact from basic kinetic EQs
function calcImpactTime {
  return (sqrt(verticalSpeed^2 + 2 * avgGrav(alt:radar) * alt:radar) - abs(verticalSpeed)) / avgGrav(alt:radar).
}
//looking for low slope landing slope on desceending
function seekLanding {
  print "SEEKING LANDING" at (60,0).
  parameter maxSpeed is 20.
  parameter maxSlope is 10.
  //immediate slow down if the landing spot is OK
  parameter goodSpotMargin is 100.

  local done is false.

  lock steering to seekSteering(maxSpeed, maxSlope, goodSpotMargin).
  lock throttle to seekThrottle(maxSpeed, maxSlope, goodSpotMargin).
  until done {
    local groundVelVec is vxcl(up:vector, ship:velocity:surface).
    print groundSlope() at (60,13).

    local bt is burnTimeForDv(ship:velocity:surface:mag).
    fdata(bt).
    //add burning time as a safety
    set done to  (groundVelVec:mag < maxSpeed and groundSlope < maxSlope) or  bt > calcImpactTime().
  }
  lock throttle to 0.
  lock steering to srfRetrograde.
}
//handle steering on seeking descent
function seekSteering {
  parameter maxspeed.
  parameter maxslope.
  parameter goodSpotMargin is 50.

  local groundVelVec is vxcl(up:vector, ship:velocity:surface).
  if groundVelVec:mag < goodSpotMargin and groundSlope() < maxslope {
    return -groundVelVec.
  }
  local done is groundVelVec:mag < maxSpeed.
  if done {
    return srfRetrograde.
  }
  return -groundVelVec.
}
//handle throttle on seeking descent
function seekThrottle {
  parameter maxspeed.
  parameter maxslope.
  parameter goodSpotMargin is 50.
  parameter speedDecMultiplaier is 3.
  parameter minSpeedDecreesing is 0.2.
  
  local groundVelVec is vxcl(up:vector, ship:velocity:surface).
  if groundVelVec:mag < goodSpotMargin and groundSlope() < maxslope {
    return 1.
  }
  local done is groundVelVec:mag < maxSpeed.
  if done {
    return 0.
  }
  return max(minSpeedDecreesing, speedDecMultiplaier*(-verticalSpeed/alt:radar)).
}
//STARTING HERE
print "DEORBIT                " at (60,0).
deOrbitBurn(15000).
print "WAIT TO PREIAPSIS      " at (60,0).
waitToPeriapsis().
seekLanding(5,7).
suicideBurn().