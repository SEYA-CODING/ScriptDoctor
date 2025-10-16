-- =========================================================================
-- ScriptDoctor - config.lua
-- Created by: SEYA-CODING
-- Discord: seya_coding #6497
-- Community: https://discord.gg/RT3uJRdXSC
-- Detailed config with explanations
-- =========================================================================

Config = {}

-- PATHS TO SCAN
-- These folders are scanned for resources. Adjust to your server layout.
-- Scanning many paths increases startup time and CPU usage.
Config.scan_paths = {"resources", "resources/[local]"}

-- AUTO APPLY
-- true  = ScriptDoctor will automatically apply SAFE fixes at startup (if auto_apply_mode allows).
-- false = only generate a report and suggestions.
Config.auto_apply = false

-- BACKUPS
-- When true, every file that will be modified is backed up with a timestamp.
Config.backup = true
Config.backup_dir = "ScriptDoctor_backups"  -- backups saved here

-- LOGGING
-- JSON logs of scans are written to Config.log_dir if log_changes = true.
-- Do not publicly share logs if they contain private code.
Config.log_changes = true
Config.log_dir = "ScriptDoctor_logs"

-- MAX FILE SIZE
-- Skip scanning/patching very large files to avoid editing binary assets.
Config.max_file_size = 200 * 1024 -- 200 KB

-- IGNORE PATTERNS
-- Files or folders containing these substrings will be ignored.
Config.ignore_patterns = {
  ".git",
  "node_modules",
  ".png", ".jpg", ".jpeg", ".dds",
  ".dll", ".exe", ".so", ".dat",
  "vendor"
}

-- AUTO APPLY MODE
-- "off"          = never auto apply
-- "conservative" = only very safe, minimal changes (recommended for production)
-- "aggressive"   = more invasive changes (use only on dev)
Config.auto_apply_mode = "conservative"

-- LICENSING / PROTECTION (stubs)
-- To fully use licensing you'd host a license server. Keep 'secret' only on your server.
Config.licensing = {
  enabled = false,
  license_server_url = "https://your-license-server.example/verify", -- example
  resource_id = "ScriptDoctor_SEYA_CODING",
  check_interval_seconds = 3600,
  secret = nil,
  allow_offline = true,
  offline_grace_seconds = 86400
}

-- PROTECTION FLAGS (disabled by default)
-- These are hooks the script can use; actual secure protection requires a server and keys.
Config.protection = {
  enable_checksums = true,
  enable_obfuscation = false,
  require_server_verification = true
}

-- DEBUG / LOG LEVEL
-- 0 = none, 1 = errors, 2 = info, 3 = debug
Config.log_level = 2

-- EXAMPLES PATH
Config.examples_path = "examples"

-- REVERT & SAFE-GUARDS
-- If a patch introduces syntax error, ScriptDoctor can revert automatically.
Config.revert_on_error = true
Config.max_changes_per_file = 20

-- Notes & Best Practices:
-- 1) Keep any secrets (license HMAC keys, private keys) only on your separate license server.
-- 2) Put critical logic on server-side resources; client code is never fully secure.
-- 3) Test in a controlled dev environment before enabling aggressive auto-fixes.
