CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

if not exists("1:/lib"){
  createDir("1:/lib").
}

if not exists("1:/missions"){
  createDir("1:/missions").
}

copyPath("0:/zurugynokseg/lib/staging_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/ui_lib.ks","1:/lib").

copyPath("0:/zurugynokseg/missions/haul.ks","1:/missions").
copyPath("0:/zurugynokseg/missions/test.ks","1:/missions").
copyPath("0:/zurugynokseg/missions/splash.ks","1:/missions").
copyPath("0:/zurugynokseg/missions/common_missions.ks","1:/missions").

cd("missions").
