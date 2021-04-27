CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

set terminal:width to 100.
set terminal:height to 50.

local silent is true.
clearScreen.

print "========================================ZURUGYNOKSEG OS 0.1=========================================".

if not exists("1:/lib"){
  createDir("1:/lib").
}

if not exists("1:/missions"){
  createDir("1:/missions").
}

if not exists("1:/ZOS"){
  createDir("1:/ZOS").
}
copyPath("0:/zurugynokseg/ZOS/fileIO", "1:/ZOS").
runOncePath("ZOS/fileIO").

copyAllFilesToBoot().

cd("ZOS").


//FUNCTIONS
function copyAllFilesToBoot {

  print " ".
  print " ".
  print "COPY FILES....".
  if not silent {
    print " ".
    print "ZOS FILES:".
  }
  local zosFiles is copyFiles(list(
    "dev",
    "fileIO",
    "init",
    "start",
    "update"
  ),"ZOS").
  if not silent {
    print "-----------------------------------:" + zosfiles.
    print "LIBARIES FILES:".
  }
  local libfiles is copyFiles(list(
  "circ_lib",
  "hohhman_lib",
  "landing_lib",
  "launch_lib",
  "rendezvous_lib",
  "rocket_utils_lib",
  "transfer_lib",
  "staging_lib",
  "ui_lib",
  "utils_lib",
  "wait_lib",
  "warp_lib",
  "docking_lib",
  "vecDraw_lib",
  "landVac_lib"
  ),"lib").
  if not silent {
    print "-----------------------------------:" + libfiles.
    print "MISSIONS:".
  }
  local missionfiles is copyFiles(list(
  "launch",
  "return",
  "rescue",
  "landV",
  "transfer",
  "dock",
  "station"
  ),"missions").
  print "-----------------------------------:" + missionfiles.
  print zosFiles + missionfiles + libfiles + " bytes copied".
  print "Free space:" + volume(1):freespace + "/" + volume(1):capacity.
}