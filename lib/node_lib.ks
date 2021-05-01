function nodeFromVector {
  parameter vecTarget,nodeTime,localBody IS ship:body.

  local vecNodePrograde IS velocityAt(ship,nodeTime):orbit.
  local vecNodeNormal IS vCrs(vecNodePrograde,positionAt(ship,nodeTime) - localBody:position).
  local vecNodeRadial IS vCrs(vecNodeNormal,vecNodePrograde).
  
  local nodePrograde IS vDot(vecTarget,vecNodePrograde:normalized).
  local nodeNormal IS vDot(vecTarget,vecNodeNormal:normalized).
  local nodeRadial IS vDot(vecTarget,vecNodeRadial:normalized).

  return node(nodeTime,nodeRadial,nodeNormal,nodePrograde).
}

function removeNodes {
  if not hasNode return.
	for n in allNodes remove n.
	wait 0.
}