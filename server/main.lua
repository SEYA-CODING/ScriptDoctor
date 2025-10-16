-- =========================================================================
-- ScriptDoctor - server/main.lua
-- Created by: SEYA-CODING
-- Discord: seya_coding #6497
-- Community: https://discord.gg/RT3uJRdXSC
-- =========================================================================

local repair = require("lib.repair_engine")
local fs = require("lib.file_utils")

-- safe json encode fallback
local safe_json_encode = (json and json.encode) or function(t) return "{}" end

-- Helper: find resources based on Config.scan_paths
local function find_resources()
  local res = {}
  for _, p in ipairs(Config.scan_paths or {}) do
    if fs.exists(p) then
      for _, name in ipairs(fs.list_dir(p)) do
        local full = p .. "/" .. name
        if fs.exists(full .. "/fxmanifest.lua") or fs.exists(full .. "/__resource.lua") then
          table.insert(res, full)
        end
      end
    end
  end
  return res
end

-- Run scan over discovered resources
local function run_scan()
  local resources = find_resources()
  local global_report = {}
  for _, rpath in ipairs(resources) do
    print(("[ScriptDoctor - SEYA-CODING] 🔍 Scanning %s"):format(rpath))
    local rep = repair.scan_resource(rpath, { max_size = Config.max_file_size })
    global_report[rpath] = rep
  end

  if Config.log_changes then
    fs.mkdir(Config.log_dir or "ScriptDoctor_logs")
    local fname = (Config.log_dir or "ScriptDoctor_logs") .. "/last_scan_" .. os.time() .. ".json"
    pcall(fs.write, fname, safe_json_encode(global_report or {}))
  end

  print("✅ [ScriptDoctor] Scan completed successfully.")
  print("📁 Logs saved in: " .. (Config.log_dir or "ScriptDoctor_logs"))
  print("---------------------------------------------------------------")
  print(" Developed by SEYA CODING | Discord: seya_coding #6497")
  print(" Join the community: https://discord.gg/RT3uJRdXSC")
  print("---------------------------------------------------------------")
  return global_report
end

-- Console banner (prints owner and links)
local function banner()
  print("\n")
  print("===============================================================")
  print("     🩺  ScriptDoctor v1.2.0 - The Ultimate Script Fixer       ")
  print("---------------------------------------------------------------")
  print("       🔧  Created & Developed by: SEYA CODING                 ")
  print("       💬  Discord: seya_coding #6497                          ")
  print("       🌐  Community: https://discord.gg/RT3uJRdXSC            ")
  print("---------------------------------------------------------------")
  print("    Helping you fix ESX & QBCore scripts — safely & reliably    ")
  print("===============================================================\n")
end

-- Server console command: run scan
RegisterCommand("scriptdoctor_scan", function(source)
  if source ~= 0 then
    TriggerClientEvent("chat:addMessage", source, {
      args = {"ScriptDoctor", "⚠️ Run this command from the server console only."}
    })
    return
  end
  banner()
  run_scan()
end, true)

-- Show owner/banner
RegisterCommand("scriptdoctor_owner", function(source)
  if source == 0 then
    banner()
  else
    TriggerClientEvent("chat:addMessage", source, {
      args = {"ScriptDoctor", "⚠️ This command is for console use only."}
    })
  end
end, true)

-- Simple revert helper: not automatic restore, lists backups to help manual restore
RegisterCommand("scriptdoctor_revert_last", function(source)
  if source ~= 0 then
    TriggerClientEvent("chat:addMessage", source, {
      args = {"ScriptDoctor", "⚠️ Run from the server console only."}
    })
    return
  end
  local bdir = Config.backup_dir or "ScriptDoctor_backups"
  if not fs.exists(bdir) then
    print("[ScriptDoctor] ❌ No backups found.")
    return
  end
  print("[ScriptDoctor] 🔁 Backups are stored in: " .. bdir)
  print("[ScriptDoctor] To restore: copy the desired .bak file back to its original path.")
end, true)

-- Optionally run initial scan when resource starts
CreateThread(function()
  Wait(1000)
  banner()
  Wait(500)
  if Config.auto_apply and Config.auto_apply_mode ~= "off" then
    print("[ScriptDoctor] Auto-scan enabled: running initial scan.")
    run_scan()
  else
    print("[ScriptDoctor] Auto-scan disabled. Use 'scriptdoctor_scan' to run manually.")
  end
end)
