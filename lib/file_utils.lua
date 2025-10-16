-- =========================================================================
-- ScriptDoctor - lib/file_utils.lua
-- Created by: SEYA-CODING
-- Discord: seya_coding #6497
-- =========================================================================

local fs = {}

-- read file
function fs.read(path)
  local f, err = io.open(path, "rb")
  if not f then return nil, err end
  local content = f:read("*a")
  f:close()
  return content
end

-- write file (overwrites)
function fs.write(path, content)
  local f, err = io.open(path, "wb")
  if not f then return nil, err end
  f:write(content)
  f:close()
  return true
end

-- append to file
function fs.append(path, content)
  local f, err = io.open(path, "ab")
  if not f then return nil, err end
  f:write(content)
  f:close()
  return true
end

-- copy file
function fs.copy(src, dst)
  local content, err = fs.read(src)
  if not content then return nil, err end
  -- ensure parent dir exists
  local parent = dst:match("(.+)/[^/]+$")
  if parent then os.execute(("mkdir -p %q"):format(parent)) end
  return fs.write(dst, content)
end

-- mkdir (recursive)
function fs.mkdir(path)
  os.execute(("mkdir -p %q"):format(path))
  return true
end

-- exists
function fs.exists(path)
  local f = io.open(path, "rb")
  if f then f:close() return true end
  return false
end

-- list directory entries (non-recursive)
function fs.list_dir(path)
  local p = io.popen('ls -a "' .. path .. '" 2>/dev/null')
  if not p then return {} end
  local t = {}
  for name in p:lines() do
    if name ~= "." and name ~= ".." then t[#t+1] = name end
  end
  p:close()
  return t
end

return fs
