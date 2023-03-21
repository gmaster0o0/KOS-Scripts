function ChangeOrbitLib {
  local vecDrawLex is lex().
  local nodeLib is NodeLib().
  
  local function ellipseToCircle {
    parameter targetRadius is apoapsis.
    local dv is 0.
    //increase orbit size.
    if targetRadius > periapsis {
      set dv to finalHohhmanDV(body:radius + periapsis,targetRadius + body:radius).
      add node(time:seconds + eta:apoapsis,0,0,dv).
      return. 
    }
    //descrease orbit size.
    set dv to finalHohhmanDV(body:radius + apoapsis,body:radius + targetRadius).
    add node(time:seconds + eta:periapsis,0,0,dv).
  }

  local function hyperbolicToCircular {
    clearVecDraws().
    local lead is max(0,eta:periapsis).
    local targetRadius is (positionAt(ship,lead + time:seconds)- body:position):mag.
    local velocityAtAP is sqrt(body:mu * (1/targetRadius)).
    local maxBT is burnTimeForDv(ship:velocity:orbit:mag-velocityAtAP).
    local utime is time:seconds + max(lead,maxBT/2 + 50).
    //local utime is time:seconds + lead.
    local positionAtBurn is positionAt(ship, utime) - body:position.
    local velocityAtBurn is velocityAt(ship, utime):orbit.
    local sma is positionAtBurn:mag.
    local velocityAtPeriapsis is sqrt(body:mu * (2/positionAtBurn:mag - 1/sma)).

    local fligthPathAngle is 90-vang(velocityAtBurn,positionAtBurn).
    local proV is velocityAtPeriapsis*cos(fligthPathAngle) - velocityAtBurn:mag.
    local radV is -velocityAtPeriapsis*sin(fligthPathAngle).  
    add node(utime,radV, 0, proV).
    //alternative solution
    //local desiredVeloVec is -velocityAtPeriapsis*vCrs(positionAtBurn,vCrs(positionAtBurn,velocityAtBurn)):normalized.
    //local burnV is desiredVeloVec - velocityAtBurn.
    //add nodeLib:fromVector(burnV,utime).

    vecDrawAdd(vecDrawLex,body:position,positionAtBurn,BLUE,"positionAtBurn").
    vecDrawAdd(vecDrawLex,positionAt(ship, utime),velocityAtBurn*50,RED,"velocityAtBurn").
    vecDrawAdd(vecDrawLex,ship:position,body:position,white,"pos").
    //vecDrawAdd(vecDrawLex,positionAt(ship, utime)-velocityAtBurn,burnV*50,green,"bVec").
    //vecDrawAdd(vecDrawLex,positionAt(ship, utime),desiredVeloVec*50,yellow,"desVVec").

    print "lead:" + lead.
    print "targetRadius:" + (targetRadius-body:radius).
    print "minV:" + velocityAtAP.
    print "maxBT:" + maxBT.
    print "utime:" + utime.
    print "sma:" + sma.
    print "velocityAtPeriapsis:" + velocityAtPeriapsis.
    print "velocityAtBurn:" + velocityAtBurn:mag.
    print "positionAtBurn:" + positionAtBurn:mag.
    print "FPA:" + fligthPathAngle.
    print "proV:" + proV.
    print "radV:" + radV.
  }
  //transfer from hyberbolic orbit to the larges eliptical orbit
  local function hyperbolicToElliptic {
    clearVecDraws().
    if hasNode {
      remove nextNode.
    }
    local lead is max(0,eta:periapsis).
    //minimal velocity for maximum elliptical orbit
    local minV is sqrt(body:mu * (2/(altitude+body:radius)-1/((altitude+body:radius*2+periapsis)/2))).
    local maxBT is burnTimeForDv(ship:velocity:orbit:mag-minV).
    //add 50sec for align.
    local utime is time:seconds + max(lead,maxBT/2 + 50).
    //local utime is time:seconds + lead.
    local positionAtBurn is positionAt(ship, utime) - body:position.
    //predicted velocity when burn starts
    local velocityAtBurn is velocityAt(ship, utime):orbit.
    local smaOfEclipse is (body:soiradius + positionAtBurn:mag-1)/2.
    //velocity at periapis of the new orbit
    local velocityAtPeriapsis is sqrt(body:mu * (2/positionAtBurn:mag - 1/smaOfEclipse)).
    //solution 1    
    local fligthPathAngle is 90-vang(velocityAtBurn,positionAtBurn).
    local proV is velocityAtPeriapsis*cos(fligthPathAngle) - velocityAtBurn:mag.
    local radV is -velocityAtPeriapsis*sin(fligthPathAngle).  
    add node(utime,radV, 0, proV).
    //solution 2
    //calculate the desired velocity vector. calculate the normal vector from position vector
    //1st vCrs gives a plane of the 2 atBurn vector and the 2nd vCrs gives the direction of the desired velocity vector.
    //local desiredVeloVec is -velocityAtPeriapsis*vCrs(positionAtBurn,vCrs(positionAtBurn,velocityAtBurn)):normalized.
    //local burnV is desiredVeloVec - velocityAtBurn.
    //add nodeLib:fromVector(burnV,utime).
    vecDrawAdd(vecDrawLex,body:position,positionAtBurn,BLUE,"positionAtBurn").
    vecDrawAdd(vecDrawLex,positionAt(ship, utime),velocityAtBurn*50,RED,"velocityAtBurn").
    vecDrawAdd(vecDrawLex,ship:position,body:position,white,"pos").
    //vecDrawAdd(vecDrawLex,positionAt(ship, utime)-velocityAtBurn,burnV*50,green,"bVec").
    //vecDrawAdd(vecDrawLex,positionAt(ship, utime),desiredVeloVec*50,yellow,"desVVec").
    //vecDrawAdd(vecDrawLex,positionAt(ship, utime)-velocityAtBurn,burnV*50,green,"bVec").
    //vecDrawAdd(vecDrawLex,positionAt(ship, utime),desiredVeloVec*50,yellow,"desVVec").

    print "lead:" + lead.
    print "minV:" + minV.
    print "maxBT" + maxBT.
    print "utime" + utime.
    print "sma:" + smaOfEclipse.
    print "v1:" + velocityAtPeriapsis.
    print "velocityAtBurn:" + velocityAtBurn:mag.
    print "FPA:" + fligthPathAngle.
    print "proV:" + proV.
    print "radV:" + radV.
    //print vAng(ship:velocity:orbit,body:position).
    //print vAng(positionAt(ship,time:seconds+eta:periapsis)-body:position,velocityAt(ship,time:seconds + eta:periapsis):orbit).
  }

  local function changeInclination {
    parameter targetInc is "".

    if hasTarget or targetInc = "" {
      set targetObj to target.
      set relInc to getRelInc().
      set ANTA to TAofANNode(ship,targetObj).
      set ETAto to ETAtoTA(ship:orbit,ANTA).

      set velAt to velocityAt(ship, ETAto + time:seconds):orbit.
      set burnVec to getBurnVector(ship,targetObj,ETAto).
      set dv to burnVec:mag.
      set bt to burnTimeForDv(dv).
    
      print "Waiting for AN"  at (80,1).
      print round(ANTA) at(80,2).
      add nodeLib:FromVector(burnVec,ETAto + time:seconds + bt/2).
    }else{
      set relInc to getRelInc(targetInc).
      if orbit:eccentricity > 1 { 
        set ETAto to 60.
      }else{
        set ETAto to eta:apoapsis.
     }
  
      set velAt to velocityAt(ship, ETAto + time:seconds):orbit.

      set dv to 2 * velAt:mag * sin (relInc/2).
      local nv is dv * cos(relInc/2).
      local pv is dv * -sin(relInc/2).  
      set burnVec to v(0,nv,pv).
      set bt to burnTimeForDv(burnVec:mag).
      add node(ETAto + time:seconds + bt/2, 0, nv,pv).
      
      print "Waiting for AP" at (80,1).
    }
  }

  local function getRelInc {
    parameter targetInc is "".
    if hasTarget or targetInc = "" {
      return relativeInc(ship,targetObj).
    }else{
      return targetInc - obt:inclination.
    }
  }

  return lexicon(
    "ellipseToCircle",ellipseToCircle@,
    "hyperbolicToElliptic",hyperbolicToElliptic@,
    "hyperbolicToCircular",hyperbolicToCircular@,
    "changeInclination",changeInclination@,
    "getRelInc",getRelInc@
  ).
}


//LEGACY FUNCTIONS
function raisePeriapsis {
  parameter targetPeri is apoapsis.
  parameter errorTreshold is 1.05.

  local dv is deltaVToPeriapsis().
  local bt is burnTimeForDv(dv).

  lock steering to circPrograde().
  wait until steeringManager:ANGLEERROR < 1.
  printO("CIRC","Periapsis emelese:[DV:"+round(dv,1)+"][BT:"+round(bt,1)+"][AP:"+round(targetPeri)+"]").
  waitToApoapsis(bt/2).
  
  local th is 0.
  lock throttle to th.
  until status = "ORBITING" and (
    (orbit:eccentricity < 0.0005 and isCloseTo(targetPeri,periapsis,targetPeri*0.01)) or
    periapsis > targetPeri*errorTreshold or
    apoapsis > targetPeri * errorTreshold
  ) {
    set th to burnTimeForDv(deltaVToPeriapsis()).
    flightData().
    checkBoosters().
  }
  printO("CIRC","Körpálya elérve:"+ orbit:eccentricity).
  lock throttle to 0.
}

function lowerApoapsis {
  parameter targetApo is periapsis.
  parameter errorTreshold is 0.95.
  print targetApo.
  local dv to deltaVToPeriapsis().
  local bt to burnTimeForDv(dv).
  
  lock steering to circRetrograde().
  wait until steeringManager:ANGLEERROR < 1.
  waitToPeriapsis(bt/2).

  printO("CIRC", "Gyorsítás a körpálya eléréséhez. DV:" + round(dv,1) + "  BT:"+round(bt)).
  local th to 1.
  lock throttle to th.
  local startPeri is periapsis.
  until status="ORBITING" and (
    periapsis < startPeri*errorTreshold or 
    (apoapsis < targetApo*errorTreshold and apoapsis > 0) or 
    orbit:eccentricity < 0.0005
  ) {
    set th to burnTimeForDv(deltaVToPeriapsis()).
    checkBoosters().
    wait 0.1.
  }
  printO("CIRC", "Körpálya elérve:" + round(obt:eccentricity,7)).
  lock throttle to 0.
}

local function circPrograde {
  parameter threshold is 30.

  if(eta:apoapsis < eta:periapsis){
    return prograde:vector + r(0,max(-eta:apoapsis,-threshold),0).
  }
  return prograde:vector + r(0,min(orbit:period - eta:apoapsis,threshold),0).
}

local function circRetrograde {
  parameter threshold is 30.

  if orbit:eccentricity > 1 {
    if eta:periapsis > 0 {
      return retrograde:vector + r(0,max(-eta:periapsis,-threshold),0).
    }
    return retrograde:vector + r(0,min(-eta:periapsis,threshold),0).
  }
  if eta:periapsis < eta:apoapsis {
    return retrograde:vector + r(0,max(-eta:periapsis,-threshold),0).
  }
  return retrograde:vector + r(0,min(orbit:period - eta:periapsis,threshold),0).
}