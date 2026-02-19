function createResouceTransfers {
  parameter resTag.
  parameter amount is -1.

  local resouceMap is createTransferMap(resTag).
  
  local transferList is list().

  for r in resouceMap:keys {
    if amount = -1 {
      transferList:add(transferall(r,resouceMap[r]["OUT"],resouceMap[r]["IN"])).
    }else {
      transferList:add(transfer(r,resouceMap[r]["OUT"],resouceMap[r]["IN"], amount)).
    }
  }

  return transferList.
}

function executeResouceTransfer {
  parameter resTransfer.

  set resTransfer:active to true.
  until resTransfer:status <> "transferring" {
    wait 0.2.
    print resTransfer:status at (25,4).
    print resTransfer:resource at (25,5).
    print resTransfer:transferred + "/" + resTransfer:goal at (25,6).
  }
}

local function createTransferMap {
  parameter resTag. 
  
  local resourceList is availableResources(resTag).
  local resourceMap is lex().
  for p in ship:parts {
    for r in p:resources {
      if resourceList:contains(r:name) {
        if p:tag = resTag {     
          set resourceMap to addResouce(resourceMap,p,r,"OUT").
        }else {
          set resourceMap to addResouce(resourceMap,p,r,"IN").
        }
      }
    }
  }
  return resourceMap.
}

local function addResouce{
  parameter resLex.
  parameter p.
  parameter res.
  parameter _direction.

  if resLex:hasKey(res:name){
    if resLex[res:name]:hasKey(_direction){
      resLex[res:name][_direction]:add(p).
    }else{
      resLex[res:name]:add(_direction,list(p)).
    }
  }else{
    resLex:add(res:name,lex(_direction,list(p))).
  }
  return resLex.
}

local function availableResources {
  parameter resTag. 
  local resourceList is list().

  for p in ship:partstagged(resTag) {
    for res in p:resources{
      if not resourceList:contains(res:name){
        resourceList:add(res:name).
      }
    }
  }

  return resourceList.
}
