local rootDir is "zurugynokseg".

function listToPath {
  parameter pathList.

  return pathList:join("/") + ".ks".
}

function download {
  parameter filename.
  parameter namespace.
  parameter delay is 0.

  local archivePath is listToPath(list("0:",rootDir,namespace,filename)).
  local targetPath is listToPath(list(core:volume:name,namespace,filename)).

  if not exists(targetPath){
    if exists(archivePath){
      wait delay.
      copyPath(archivePath,targetPath).
      return true.
    }
    print "IOERROR: FILE NOT FOUND:" + archivePath.
    return false.
  }
  return false.
}

function copyFiles {
  parameter fileList.
  parameter namespace.
  parameter updateMode is false.

  local allFilesSize is 0.
  local iospeed is 20*1024.

  if calculateFileSpace(fileList,namespace) < core:volume:freespace {
    for f in fileList {
      local fsize is getFileSize(f, namespace,volume(0)).
      local targetPath is listToPath(list(core:volume:name,namespace,f)).
      if exists(targetPath) and updateMode {
        deletePath(targetPath).
      }
      local delay is fsize / iospeed.
      local downloaded is download(f,namespace,delay).
      if downloaded {
        if updateMode {
          print f + "...updated:["+ fsize +"]".
        }else{
          print f + "...copied:["+ fsize +"]".
        }
        set allFilesSize to allFilesSize + fsize.
      }
    }
  }else{
    print "IOERROR: NOT ENOGUTH FREE SPACE.".
  }

  return allFilesSize.
}


function getFileSize {
  parameter f.
  parameter namespace.
  parameter vol.
  
  local vf is vol:open(listToPath(list(rootDir,namespace,f))).

  if vf:istype("boolean"){
    return 0.
  }
  return vf:size.
}

function calculateFileSpace {
  parameter fileList.
  parameter namespace.
  parameter updateMode is false.

  local programSize is 0.

  for f in filelist {
    local targetPath is listToPath(list("1:",namespace,f)).

    if not exists(targetPath) or updateMode {
      set programSize to programSize + getFileSize(f,namespace,volume(0)).
    }
  }

  return programSize.
}

function update {
  parameter fileList.
  parameter namespace.

  copyFiles(fileList,namespace,true).
}