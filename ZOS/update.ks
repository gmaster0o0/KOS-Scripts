runOncePath("0:/zurugynokseg/ZOS/fileIO").

local rootDir is volume(0):open("zurugynokseg").

function updateFileList {
  parameter dir is rootDir.
  
  local fileList is list().

  for f in dir:list:values {
    if f <> ".git" {
      if f:isfile() {
        fileList:add(f:name:split(".")[0]).
      }else{
        updateFileList(f).
      }
    }
  }
  update(fileList,dir).
}
updateFileList(rootDir).