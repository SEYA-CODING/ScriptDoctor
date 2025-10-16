-- =========================================================================
-- ScriptDoctor - lib/repair_engine.lua
-- Created by: SEYA-CODING
-- Discord: seya_coding #6497
-- =========================================================================

local fs = require("lib.file_utils")
local repair = {}

local function safe_load_string(code)
  local f, err = load(code)
  if f then return true end
  return false, err
end

local function timestamp()
  return os.date("%Y%m%d%H%M%S")
end

local function create_backup(path)
  if not fs.exists(path) then return false, "file not found" end
  local destdir = Config.backup_dir or "ScriptDoctor_backups"
  fs.mkdir(destdir)
  local safe_name = path:gsub("[/\\]", "_")
  local dst = destdir .. "/" .. safe_name .. "_" .. timestamp() .. ".bak"
  return fs.copy(path, dst)
end

-- Detect manifest type
function repair.detect_manifest(resource_path)
  local fx = resource_path .. "/fxmanifest.lua"
  local res = resource_path .. "/__resource.lua"
  if fs.exists(fx) then return "fxmanifest" end
  if fs.exists(res) then return "__resource" end
  return nil
end

-- Convert __resource.lua -> fxmanifest.lua (best-effort, safe)
function repair.convert_resource_to_fx(resource_path)
  local resfile = resource_path .. "/__resource.lua"
  if not fs.exists(resfile) then return false, "no __resource.lua" end
  local content, err = fs.read(resfile)
  if not content then return false, err end

  local fx = [[
fx_version 'cerulean'
game 'gta5'

-- Converted by ScriptDoctor (SEYA-CODING)
author 'SEYA-CODING'
description 'Converted fxmanifest'
version '1.0.0'
]]

  local function extract_list(block)
    if not block then return nil end
    local out = {}
    for s in block:gmatch("[\"']([^\"']+)[\"']") do
      out[#out+1] = "    '" .. s .. "'"
    end
    if #out == 0 then return nil end
    return table.concat(out, "\n")
  end

  local client = content:match("client_scripts%s*=%s*{(.-)}")
  local server = content:match("server_scripts%s*=%s*{(.-)}")

  if client then
    fx = fx .. "\nclient_scripts {\n" .. (extract_list(client) or "") .. "\n}\n"
  end
  if server then
    fx = fx .. "\nserver_scripts {\n" .. (extract_list(server) or "") .. "\n}\n"
  end

  local fxpath = resource_path .. "/fxmanifest.lua"
  if fs.exists(fxpath) then return false, "fxmanifest already exists" end

  pcall(create_backup, resfile)
  local ok, werr = fs.write(fxpath, fx)
  if not ok then return false, werr end
  return true
end

-- Ensure minimal fxmanifest presence/fields
function repair.ensure_minimal_fx(resource_path)
  local fx = resource_path .. "/fxmanifest.lua"
  if fs.exists(fx) then
    local content, _ = fs.read(fx)
    if content and content:match("fx_version") and content:match("game") then
      return true, "ok"
    else
      local new = "fx_version 'cerulean'\ngame 'gta5'\n\n" .. (content or "")
      pcall(create_backup, fx)
      fs.write(fx, new)
      return true, "patched"
    end
  else
    local manifest = "fx_version 'cerulean'\ngame 'gta5'\n\nauthor 'SEYA-CODING'\ndescription 'Auto-generated manifest'\nversion '1.0.0'\n"
    fs.write(fx, manifest)
    return true, "created"
  end
end

-- Detect framework (ESX or QBCore) based on file content heuristics
function repair.detect_framework_patterns(file_content)
  if not file_content then return nil end
  local lower = file_content:lower()
  if lower:find("esx =") or lower:find("es_extended") or lower:find("esx:getsharedobject") or lower:find("getsharedobject") then
    return "esx"
  end
  if lower:find("qbcore") or lower:find("exports['qb-core']") or lower:find("getcoreobject") or lower:find("exports['qb-core']:getcoreobject") then
    return "qbcore"
  end
  return nil
end

-- Fixes (safe, minimal)
function repair.fix_esx_bootstrap(path)
  local content, err = fs.read(path)
  if not content then return nil, err end
  local changed = false

  if content:match("TriggerEvent%(%s*['\"]esx:getSharedObject['\"]") and not content:match("exports%['es_extended'%]") then
    local add = "\n-- ScriptDoctor (SEYA-CODING): modern ESX retrieval fallback\nif not ESX then\n  ESX = exports['es_extended']:getSharedObject()\nend\n"
    content = add .. content
    changed = true
  end

  if changed then
    pcall(create_backup, path)
    fs.write(path, content)
    return true, "patched"
  end
  return false, "no change"
end

function repair.fix_qb_bootstrap(path)
  local content, err = fs.read(path)
  if not content then return nil, err end
  local changed = false

  if (content:match("local QBCore = nil") or content:match("GetCoreObject") or content:match("exports%['qb-core'%]")) and not content:match("exports%['qb-core'%]:GetCoreObject%(%)") then
    local add = "\n-- ScriptDoctor (SEYA-CODING): modern QBCore initialization fallback\nif not QBCore then\n  QBCore = exports['qb-core']:GetCoreObject()\nend\n"
    content = add .. content
    changed = true
  end

  if changed then
    pcall(create_backup, path)
    fs.write(path, content)
    return true, "patched"
  end
  return false, "no change"
end

-- Fix common event typos (safe replacement)
function repair.fix_event_typos(path)
  local content, err = fs.read(path)
  if not content then return nil, err end
  local changed = false

  -- Simple replacements for common mistakes (case-insensitive)
  local patterns = {
    {"[Tt][Rr][Ii][Gg][Gg][Ee][Rr][Ss][Ee][Rr][Vv][Ee][Rr][Ee][Vv][Ee][Nn][Tt]", "TriggerServerEvent"},
    {"[Tt][Rr][Ii][Gg][Gg][Ee][Rr][Cc][Ll][Ii][Ee][Nn][Tt][Ee][Vv][Ee][Nn][Tt]", "TriggerClientEvent"},
    {"triggerserverevent", "TriggerServerEvent"},
    {"triggercliantevent", "TriggerClientEvent"}
  }

  for _, pat in ipairs(patterns) do
    local p, repl = pat[1], pat[2]
    local newc, n = content:gsub(p, repl)
    if n > 0 then
      content = newc
      changed = true
    end
  end

  if changed then
    pcall(create_backup, path)
    fs.write(path, content)
    return true, "patched"
  end
  return false, "no change"
end

-- Syntax check
function repair.syntax_check(path)
  local content, err = fs.read(path)
  if not content then return false, "read error" end
  local ok, message = safe_load_string(content)
  if ok then return true, "syntax ok" end
  return false, message
end

-- Analyze & fix single file
function repair.analyze_and_fix_file(path, options)
  options = options or {}
  local result = {path = path, fixes = {}, notes = {}}

  local content, err = fs.read(path)
  if not content then
    result.error = err or "read failed"
    return result
  end

  if #content > (options.max_size or Config.max_file_size or 200*1024) then
    result.skipped = "file too large"
    return result
  end

  local framework = repair.detect_framework_patterns(content)
  if framework == "esx" then
    local ok, msg = repair.fix_esx_bootstrap(path)
    if ok then table.insert(result.fixes, "esx_bootstrap:"..msg) end
  elseif framework == "qbcore" then
    local ok, msg = repair.fix_qb_bootstrap(path)
    if ok then table.insert(result.fixes, "qb_bootstrap:"..msg) end
  end

  local ok2, msg2 = repair.fix_event_typos(path)
  if ok2 then table.insert(result.fixes, "event_typos:"..msg2) end

  local ok3, synmsg = repair.syntax_check(path)
  if not ok3 then
    table.insert(result.fixes, "syntax_error:"..(synmsg or "unknown"))
  else
    table.insert(result.fixes, "syntax_ok")
  end

  return result
end

-- Scan a single resource folder
function repair.scan_resource(resource_path, options)
  options = options or {}
  local reports = {}

  local list = fs.list_dir(resource_path)
  for _, name in ipairs(list) do
    if name ~= "." and name ~= ".." then
      local full = resource_path .. "/" .. name
      -- detect directory
      local p = io.popen('test -d "'..full..'" && echo dir || echo file')
      local isdir = false
      if p then
        local v = p:read("*l")
        p:close()
        if v == "dir" then isdir = true end
      end
      if isdir then
        for _, child in ipairs(fs.list_dir(full)) do
          local childfull = full .. "/" .. child
          if child:match("%.lua$") then
            local r = repair.analyze_and_fix_file(childfull, options)
            reports[#reports+1] = r
          end
        end
      else
        if name:match("%.lua$") or name:match("%.json$") then
          local r = repair.analyze_and_fix_file(full, options)
          reports[#reports+1] = r
        end
      end
    end
  end

  -- manifest repairs
  local m = repair.detect_manifest(resource_path)
  if not m then
    local ok, msg = repair.convert_resource_to_fx(resource_path)
    if ok then
      reports[#reports+1] = {fixes = {"converted_resource_to_fx"}, note = msg}
    end
  else
    local ok, msg = repair.ensure_minimal_fx(resource_path)
    if ok and msg ~= "ok" then
      reports[#reports+1] = {fixes = {"ensure_fxmanifest"}, note = msg}
    end
  end

  return reports
end

return repair
