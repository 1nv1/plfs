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

function plfs:new(getOS)
  local obj = {
    OS = "unknow"
  }
  setmetatable(obj, self)
  self.__index = self

  if getOS == nil then
    obj.OS = _getOS()
  else
    obj.OS = getOS()
  end

  return obj
end

function plfs:getDirectoryItems(dir)
  local i, mode, popen = 0, {}, io.popen
  local t = {}
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

return plfs
