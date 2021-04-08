CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

if not exists("1:/lib"){
  createDir("1:/lib").
}

if not exists("1:/missions"){
  createDir("1:/missions").
}

copyPath("0:/zurugynokseg/lib/staging_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/ui_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/landing_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/launch_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/circ_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/transfer_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/hohhman_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/rocket_utils_lib.ks","1:/lib").

copyPath("0:/zurugynokseg/missions/kerbintours.ks","1:/missions").
copyPath("0:/zurugynokseg/missions/parkingOrbit.ks","1:/missions").
copyPath("0:/zurugynokseg/missions/flybymun.ks","1:/missions").

cd("missions").