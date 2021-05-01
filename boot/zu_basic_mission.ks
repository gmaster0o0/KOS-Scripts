CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

if not exists("1:/lib"){
  createDir("1:/lib").
}

if not exists("1:/missions"){
  createDir("1:/missions").
}

copyPath("0:/zurugynokseg/lib/staging_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/landing_lib.ks","1:/lib").
copyPath("0:/zurugynokseg/lib/ui_lib.ks","1:/lib").

copyPath("0:/zurugynokseg/basic/haul.ks","1:/missions").
copyPath("0:/zurugynokseg/basic/test.ks","1:/missions").
copyPath("0:/zurugynokseg/basic/splash.ks","1:/missions").
copyPath("0:/zurugynokseg/basic/common_missions.ks","1:/missions").

cd("missions").
