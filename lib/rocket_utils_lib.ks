
function burnTimeForDv {
  parameter dv.
  parameter isp is calculateISP().
  parameter thrust is ship:availableThrust.
  parameter m0 is ship:mass.

  if( isp = 0 or thrust = 0 ) {
    return 0.
  }
  
  local mf is m0 / constant:e ^ (dv / isp).
  return (m0-mf) / (thrust / isp ).
}

function calculateISP {
  local totalThrust is 0.
  local totalFlowRate is 0.
  local activeEngines is listActiveEngines().

  for e in activeEngines {
    set totalFlowRate to totalFlowRate + e:maxmassflow.
    set totalThrust to totalThrust + e:availableThrust.
  }

  if totalFlowRate = 0 {
    return 0.
  }
  return totalThrust / totalFlowRate.
}

function listEngines {
  list engines in elist.
  return elist.
}

function listActiveEngines {
  local engineList is listEngines().
  local activeEngines is list().
  for e in engineList {
    if e:ignition and not e:flameout {
      activeEngines:add(e).
    }
  }
  return activeEngines.
}

function handleThrottle {
  parameter currentValue.
  parameter targetValue.

  if currentValue / targetValue > 0.9 {
    return 0.1.
  }
  return 1.
}

function TWR {
  return ship:availableThrust / (ship:mass * gravity(altitude)).
}

function maxTWR {
  return ship:maxthrust / (ship:mass * gravity(altitude)).
}