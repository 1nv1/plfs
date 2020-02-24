local plfs = {}

-- Return OS names like love.system.getOS
local function _getOS()
  local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
  if BinaryFormat == "dll" then
    return "Windows"
  end
  if BinaryFormat == "so" then
    return "Linux"
  end
  if BinaryFormat == "dylib" then
    return "OS X"
  end
  return "unknow"
end

local function _getDirItemLnx(dir)
  local i, mode, popen = 0, {}, io.popen
  local t = {}
  -- windows
  -- for /f "delims=" %a in ('cd') do @for /f %b in ('dir /b /a-h /d') do @echo %a\%b
  local pfile = popen('ls -l -d -1 "'..dir..'"/*')
  for line in pfile:lines() do
    if line:sub(1,1) == "d" then
      mode = "directory"
    else
      mode = "file"
    end
    local filename = "/"..string.match(line, "/(.*)")
    local basename = filename:reverse()
    local s, e = string.find(basename, "[^/]+", pos)
    basename = basename:sub(s, e)
    basename = basename:reverse()
    table.insert(t, { path = filename, name = basename, mode = mode })
  end
  pfile:close()
  return t
end

function _getDirItemWin(dir)
  local i
  local t = {}
  local fullpath = "for /f \"delims=\" %a in ('cd') do @for /f %b in ('dir /b /a-h /d "..dir.."') do @echo "..dir.."\\%b"
  local pfile = io.popen(fullpath)
  for line in pfile:lines() do
    local filename = line
    local basename = filename:reverse()
    local s, e = string.find(basename, "[^\\]+", pos)
    basename = basename:sub(s, e)
    basename = basename:reverse()
    local pcmd = "if exist \""..filename.."\" (2>nul pushd \""..filename.."\" && (popd& echo directory) || echo file ) else echo unknow"
    local pmode = io.popen(pcmd)
    local mode = pmode:read()
    mode = mode:gsub("%s+", "")
    table.insert(t, { path = filename, name = basename, mode = mode })
  end
  pfile:close()
  return t
end

function plfs:new(getOS)
  local obj = {
    OS = "unknow",
    pathsep = ""
  }
  setmetatable(obj, self)
  self.__index = self

  if getOS == nil then
    obj.OS = _getOS()
  else
    obj.OS = getOS()
  end

  if obj.OS == "Linux" then obj.pathsep = "/" end
  if obj.OS == "Windows" then obj.pathsep = "\\" end

  return obj
end

function plfs:adaptPath(path)
  if self.OS == "Windows" then
    path = path:gsub('%/', '')
  end
  if self.OS == "Linux" then
    path = path:gsub('%\\', '/')
  end
  return path
end

function plfs:getDirectoryItems(dir)
  if self.OS == "Linux" then
    return _getDirItemLnx(dir)
  end
  if self.OS == "Windows" then
    return _getDirItemWin(dir)
  end
  return {}
end

return plfs
