# ScriptDoctor

**ScriptDoctor** — created and maintained by **SEYA-CODING**.  
Discord: `seya_coding #6497`  
Community: https://discord.gg/RT3uJRdXSC

ScriptDoctor is an automatic fixer and diagnostic toolkit for FiveM resources, focused on ESX and QBCore. It scans resource folders, detects common issues (manifests, framework bootstraps, typos, syntax problems) and applies safe fixes with backups.

## Quick start

1. Place the `ScriptDoctor` folder in your server `resources` directory.  
2. Add `start ScriptDoctor` to your `server.cfg`.  
3. Configure `config.lua` to adjust scan paths and options.  
4. From the server console run: `scriptdoctor_scan` to scan and apply (or test with `Config.auto_apply = false` first).  
5. Backups are stored in `ScriptDoctor_backups` by default.

## Commands

- `scriptdoctor_scan` — run a scan (server console).  
- `scriptdoctor_owner` — show banner and owner info (server console).  
- `scriptdoctor_revert_last` — lists backup folder to help manual restore.

## Protection & Licensing (notes)

- ScriptDoctor includes **stubs** for licensing and tamper detection. These require a license server and secret keys you host. They are disabled by default.
- Do **not** store private keys/secrets in public repositories.
- Best practice: keep critical logic on a server you control and use signed short-lived tokens for verification.

## Contribution & Support

Contact `seya_coding #6497` on Discord or join the community: https://discord.gg/RT3uJRdXSC

## License

MIT — see LICENSE file.
