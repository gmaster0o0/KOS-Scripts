runOncePath("0:/zurugynokseg/ZOS/fileIO").

local rootDir is volume(0):open("zurugynokseg").

function updateFileList {
  parameter dir is rootDir.
  parameter includeList is list("lib").

  local fileList is list().

  for f in dir:list:values {
    if f <> ".git" {
      if f:isfile() {
        fileList:add(f:name:split(".")[0]).
      }else{
        if includeList:contains(f:name) {
          updateFileList(f).
        }
      }
    }
  }
  update(fileList,dir).
  print dir + " updated.".
}

function inputCheck {
  if not(terminal:input:haschar()){
    return false.
  }
  local ch is terminal:input:getchar().
  if ch = 0 {
    return updateFileList(rootDir, list("lib","missions","runners","ZOS")).
  }
  if ch = 1 {
    updateFileList(rootDir,list("lib")). 
    return true.
  }
  if ch = 2 {
    updateFileList(rootDir,list("missions")). 
    return true.
  }
  if ch = 3 {
    updateFileList(rootDir,list("runners")). 
    return true.
  }if ch = 4 {
    updateFileList(rootDir,list("ZOS")). 
    return true.
  }
  return false.
}

print "Pls choose an update mode:".
print "0: all".
print "1: lib".
print "2: missions".
print "3: runners".
print "4: ZOS".

local valid is false.
until valid {
  set valid to inputCheck().
}

print "Free space:" + volume(1):freespace + "/" + volume(1):capacity.