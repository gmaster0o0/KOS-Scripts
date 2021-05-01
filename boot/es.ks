//copy all script
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

function bootConsole {
	parameter msg.

	print "T+" + round(time:seconds) + " boot: " + msg.
}

function bootError {
	parameter msg.

	print "T+" + round(time:seconds) + " boot: " + msg.

	hudtext(msg, 10, 4, 36, RED, false).

	local vAlarm to GetVoice(0).
	set vAlarm:wave to "TRIANGLE".
	set vAlarm:volume to 0.5.
	vAlarm:play(
		list(
			note("A#4", 0.2, 0.25),
			note("A4",  0.2, 0.25),
			note("A#4", 0.2, 0.25),
			note("A4",  0.2, 0.25),
			note("R",   0.2, 0.25),
			note("A#4", 0.2, 0.25),
			note("A4",  0.2, 0.25),
			note("A#4", 0.2, 0.25),
			note("A4",  0.2, 0.25)
		)
	).
	shutdown.
}

function calculateFileSpace {
  parameter _harddrive.
  parameter _filelist.

  local programSize is 0.

  for f in _filelist {
    if f:name:endswith(".ks") {
      if _harddrive:exists(f:name) _harddrive:delete(f:name).
      set programSize to programSize + f:size.
    }
  }

  return programSize.
}

function copyFiles{
  parameter _harddrive.
  parameter _filelist.

  local successFull is true.

  for f in _filelist {
    if f:name:endswith(".ks") {
      if not copypath(f, _harddrive) { 
        successFull off. 
      }else{
         bootConsole(f + " copied").
      }
    }
	}

  return successFull.
}

set harddrive to core:volume.
set archive to volume(0).

switch to archive.

if exists("epiteszsuli") {
  cd ("epiteszsuli").
}else{
  bootError("Cannot find scripts").
  shutdown.
}

list files in fileList.

//check the free space on the harddrive and copy the files if can
if calculateFileSpace(harddrive,fileList) < core.volume.freespace {
  if(copyFiles(harddrive,fileList)){
    bootConsole("Files initialized").
  }else{
    bootError("File copy failed.").
  }
} else {
  bootError("Core volume too small.").
}
IF NOT SHIP:UNPACKED AND SHIP:LOADED { PRINT "waiting for unpack". WAIT UNTIL SHIP:UNPACKED AND SHIP:LOADED. WAIT 1. PRINT "unpacked". }
IF NOT EXISTS("1:/lib/") {CREATEDIR("1:/lib/").}       //creates lib sub

wait 2.
print "ES-Auto ready for commands:". print "".