-- =========================================================================
-- ScriptDoctor - client/main.lua
-- Created by: SEYA-CODING
-- Discord: seya_coding #6497
-- =========================================================================

print("[ScriptDoctor - SEYA-CODING] Client helper loaded. Type /scriptdoctor_info in F8 or run from console.")

RegisterCommand("scriptdoctor_info", function()
  if exports and exports["qb-core"] then
    print("[ScriptDoctor] QBCore exports detected.")
  end
  if exports and exports["es_extended"] then
    print("[ScriptDoctor] ESX exports detected.")
  end
  print("[ScriptDoctor] Use 'scriptdoctor_scan' on the server console to run a full scan.")
end, false)
