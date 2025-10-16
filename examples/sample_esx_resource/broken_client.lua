-- Broken sample (missing ESX export usage)
-- ScriptDoctor should detect ESX patterns and add modern fallback

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Intentional typo to demonstrate fixes:
-- triggerserverevent('someEvent', 123) -- lowercase typo
