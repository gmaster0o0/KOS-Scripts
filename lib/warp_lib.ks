function cancelWarpBeforeEta {
  parameter currentEta.
  parameter before.
  parameter threshold is 1.2.

  if warp > 0 {
    if currentEta < threshold*before * getWarprate()[warp-1]{
      set warp to warp -1.
    }
  }
  if currentEta < threshold* before {
    KUNIVERSE:TIMEWARP:CANCELWARP().
    WAIT UNTIL SHIP:UNPACKED.
  }
}

function getWarprate {
  if warpmode = "RAILS" {
    return kuniverse:TimeWarp:RAILSRATELIST.
  }
  return kuniverse:TimeWarp:PHYSICSRATELIST.
}