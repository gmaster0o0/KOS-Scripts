runOncePath("../lib/rocket_utils_lib.ks").

//NodeLib
//@Description: Manipulate and execute nodes
//TODO
global NodeLib is ({

  local vecDrawLex is lexicon().
  
  //remove all existing node
  local function removeNodes {
    if not hasNode return.
    for n in allNodes remove n.
    wait 0.
  }
  
  //Generate node from vector
  //@param {orbitable} vecTarget
  //@param {timespan} nodeTime
  //@param {body} localBody=ship:body
  local function nodeFromVector {
    parameter vecTarget,nodeTime,localBody IS ship:body.

    local vecNodePrograde IS velocityAt(ship,nodeTime):orbit.
    local vecNodeNormal IS vCrs(vecNodePrograde,positionAt(ship,nodeTime) - localBody:position).
    local vecNodeRadial IS vCrs(vecNodeNormal,vecNodePrograde).
    
    local nodePrograde IS vDot(vecTarget,vecNodePrograde:normalized).
    local nodeNormal IS vDot(vecTarget,vecNodeNormal:normalized).
    local nodeRadial IS vDot(vecTarget,vecNodeRadial:normalized).

    return node(nodeTime,nodeRadial,nodeNormal,nodePrograde).
  }
  
  //Execute a given node with timewarp.
  //@param {node} _node=nextNode executable node 
  local function executeNode {
    parameter _node is nextNode.
    parameter autoWarp is false.
    
    lock throttle to 0.
    sas off.
    local dv to _node:deltav:mag.
    local burnTime to RocketUtils:burnTimeForDv(dv).
    
    burnDisplay().

    //steering to burn vector
    lock steering to lookdirup(_node:burnvector,ship:facing:upvector).

    //now we need to wait until the burn vector and ship's facing are aligned
    printp("Ship aligning", 12).
    wait until vang(ship:facing:vector,_node:burnvector) < 0.25.
    printp("Wait for arriving", 12).
    //the ship is facing the right direction, let's wait for our burn time
    printO("NODE","Burn Starts: " + round(_node:eta - burnTime/2,2)).

    if autoWarp{
      printp("Warping", 12).
      warpToNode(_node,burnTime).
    }
    until _node:eta <= (burnTime/2) {
      printp(round(_node:deltav:mag,1), 13).
      printp(round(_node:deltav:mag,1), 14).
      printp(formatTime(burnTime), 15).
      printp(0, 16).
      printp(formatTime(_node:eta - burnTime/2) ,17).
    }.

    local th to 0.
    lock throttle to th.
    
    local dv0 to _node:deltav.
    local done to false.
  
    until done  {
      printp("Burning", 12).

      set dv to _node:deltav:mag.
      set th to getThrottle(dv).
      if vdot(dv0, _node:deltav) < 0 {
        break.
      }

      if _node:deltav:mag < min(0.1, dv0:mag/100) {
        wait until vdot(dv0, _node:deltav) < 0.5.
        set done to true.
      }
      checkBoosters().
      printp(round(dv0:mag,1), 13).
      printp(round(dv,2), 14). 
      printp(formatTime(RocketUtils:burnTimeForDv(dv)), 15).
      printp(round(th*100,2), 16).
      printp("-" ,17).
    }
    lock throttle to 0.
    unlock all.
    set ship:control:pilotmainthrottle to 0.
    remove nextnode.
    printp("Finished", 12).
    printO("NODE", "Node Execution Finished:" + round(dv,4) + "m/s left").
  }

  local function getThrottle {
    parameter dv.

    local maxAcc is ship:availablethrust/ship:mass.

    if ship:availableThrust = 0 {
      return 0.
    }

    return min(dv/maxAcc,1).
  }

  local function burnDisplay {
    print "============Node Burn===============" at (60,11).
    print "|STEP:                             |" at (60,12).
    print "|DV:                            m/s|" at (60,13).
    print "|DV LEFT:                       m/s|" at (60,14). 
    print "|BURN TIME:                        |" at (60,15).
    print "|THROTTLE:                        %|" at (60,16).
    print "|ETA:                             s|" at (60,17).
    print "====================================" at (60,18).
  }

  local function formatTime {
    parameter rawTime.

    local formatedTime is "".
    local hours is rawTime / 3600.
    if hours > 1 {
      set rawTime to mod(rawTime,3600).
      set formatedTime to formatedTime + floor(hours) + "h ".
    }
    local minutes is rawTime/60.
    if minutes > 1 {
      set rawTime to mod(rawTime,60).
      set formatedTime to formatedTime + floor(minutes) + "m ".
    }
    set formatedTime to formatedTime + round(rawTime,1) +"s".

    return formatedTime:padright(10).
  }

  local function printp {
    parameter str,line.
    print str:tostring:padright(15) at (72,line).
  }

  return lexicon(
    "execute", executeNode@,
    "fromVector", nodeFromVector@,
    "removeAll", removeNodes@
  ).
}):call().