global RocketUtils to ({

  //library for rocket parameter calculations
  local function burnTimeForDv {
    parameter dv.

    local stagedDeltaV to dv.
    local stagenumber to stage:number.
    local totalBurningTime to 0.
    local stagedMass is ship:mass.

    until  stagedDeltaV < ship:stagedeltav(stagenumber):current  or ship:stagedeltav(stagenumber):current = 0 {
      set stagedDeltaV to stagedDeltaV - ship:stagedeltav(stagenumber):current.
      set totalBurningTime to totalBurningTime + ship:stagedeltav(stagenumber):duration.

      local stageIsp is getAvarageISP(stagenumber).
      set stagedMass to getFinalMass(ship:stagedeltav(stagenumber):current,stageIsp,stagedMass) - getStagedPartsMass(stagenumber).
      set stagenumber to stagenumber - 1.
    }

    local stageBurningTime is getStageBurningTime(stagedDeltaV, 
                                                  getAvarageISP(stagenumber),
                                                  getStageThrust(stagenumber),
                                                  stagedMass).

    if stageBurningTime = 0  and stagedDeltaV <> 0 {
      return 0. 
    }

    return totalBurningTime + stageBurningTime.
  }

  //calculate the final mass after burning for given deltaV
  local function getFinalMass {
    parameter dv.
    parameter isp is calculateISP().
    parameter m0 is ship:mass.

    if( isp = 0 ) {
      return m0.
    }

    return m0 / constant:e ^ (dv / isp).
  }

  //get the burn time for deltaV from given ship parameters
  local function getStageBurningTime {
    parameter dv.
    parameter isp is calculateISP().
    parameter thrust is ship:availableThrust.
    parameter m0 is ship:mass.
    
    if( isp = 0 or thrust = 0) {
      return 0.
    }
    local mf is getFinalMass(dv,isp,m0).

    return (m0-mf) / (thrust / isp ).
  }

  //calculate the avage ISP of engines of the given stage.
  local function getAvarageISP {
    parameter stagenumber is stage:number.

    local thrust is getStageThrust(stagenumber).
    local stagedEngines is getStagedEngines(stagenumber).

    return calculateISP(thrust, stagedEngines).
  }

  //calculate the given stage thrust
  local function getStageThrust {
    parameter stagenumber is stage:number.

    local thrust is 0.

    for e in getStagedEngines(stagenumber) {
      set thrust to thrust + e:possiblethrust.
    }

    return thrust.
  }
  //calculate the the given engines ISP
  local function calculateISP {
    parameter totalThrust is getTotalThrust().
    parameter el is activateEngines().

    local totalFlowRate is 0.
    
    for e in el {
      set totalFlowRate to totalFlowRate + e:maxmassflow.
    }

    if totalFlowRate = 0 {
      return 0.
    }
    return totalThrust / totalFlowRate.
  }

  //sum total thrust of the active engines
  local function getTotalThrust {
    local totalThrust is 0.
    local activeEngines is listActiveEngines().
    for e in activeEngines {
      set totalThrust to totalThrust + e:availableThrust.
    }

    return totalThrust.
  }

  //calculate the thrust to reach the DV in given time
  local function thrustFromBurnTime {
      parameter dV, shipIsp, burnTime, shipMass.
      
      local finalMass to shipMass / (constant:e^(dV / shipIsp)).
      local shipThrust to ((shipMass - finalMass) * shipIsp) / burnTime.

      return shipThrust.
  }

  //list all engines in the craft
  local function listEngines {
    list engines in elist.
    return elist.
  }

  //filter the active engines in the given engine list
  local function listActiveEngines {
    parameter engineList is listEngines().

    local activeEngines is list().
    for e in engineList {
      if e:ignition and not e:flameout {
        activeEngines:add(e).
      }
    }
    return activeEngines.
  }

  //Filter engines in the given stage from the give engine list
  //TODO buggy function sometimes return with empty list. NEED TO FIX IT.
  local function getStagedEngines {
    parameter stagenumber is stage:number.

    local stagedEngines is list().

    for e in listEngines() {
          //print e:name.
          //print "stage="+e:stage.
          //print "stagenumber="+stagenumber.
          //print "decoupledin="+e:decoupledin.
          //print "-----".
      if e:stage >= stagenumber {
        if (e:decoupledin < stagenumber and e:decoupledin < e:stage) or (e:decoupledin = -1 and stagenumber = e:stage){
          //already in active stage
          if e:stage >= stage:number and e:ignition and not e:flameout {
            stagedEngines:add(e).
          }
          //future stage
          if e:stage < stage:number and not e:ignition {
            stagedEngines:add(e).
          }
        }
      }
    }

    return stagedEngines.
  }

  local function handleThrottle {
    parameter currentValue.
    parameter targetValue.

    if currentValue / targetValue > 0.9 {
      return 0.1.
    }
    return 1.
  }

  local function TWR {
    return ship:availableThrust / (ship:mass * gravity(altitude)).
  }

  local function maxTWR {
    return ship:maxthrust / (ship:mass * gravity(altitude)).
  }
  return lex(
    "burnTimeForDv",burnTimeForDv@,
    "getStageBurningTime",getStageBurningTime@,
    "getAvarageISP",getAvarageISP@,
    "thrustFromBurnTime",thrustFromBurnTime@,
    "listActiveEngines",listActiveEngines@,
    "getStagedEngines",getStagedEngines@,
    "TWR",TWR@,
    "maxTWR",maxTWR@
  ).
}):call().