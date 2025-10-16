-- Broken sample (old QBCore bootstrap)
local QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- Intentional typo:
-- triggercliantevent('someEvent', -1, true) -- misspelled
