--[[
AdiBags - Adirelle's bag addon.
Gold Tracker Module - Track gold across all characters per realm
Copyright 2010-2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local GetMoney = _G.GetMoney
local UnitName = _G.UnitName
local GetRealmName = _G.GetRealmName
local pairs = _G.pairs
local time = _G.time
--GLOBALS>

local mod = addon:NewModule('GoldTracker', 'AceEvent-3.0')
mod.uiName = L['Gold Tracker']
mod.uiDesc = L['Track gold amounts for all characters on this realm.']

-- Database structure will be: AdiBagsGoldTrackerDB[realm][characterName] = { gold = amount, lastUpdate = timestamp }
local db

function mod:OnInitialize()
	-- Initialize the saved variable
	if not AdiBagsGoldTrackerDB then
		AdiBagsGoldTrackerDB = {}
	end
	db = AdiBagsGoldTrackerDB

	-- Get current realm
	local realm = GetRealmName()
	if not db[realm] then
		db[realm] = {}
	end
end

function mod:OnEnable()
	self:RegisterEvent('PLAYER_MONEY', 'UpdateGold')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateGold')

	-- Update gold immediately on enable
	self:UpdateGold()
end

function mod:OnDisable()
	-- Update one last time before disabling
	self:UpdateGold()
end

function mod:UpdateGold()
	local playerName = UnitName("player")
	local realm = GetRealmName()
	local currentGold = GetMoney()

	if not db[realm] then
		db[realm] = {}
	end

	-- Update character's gold
	db[realm][playerName] = {
		gold = currentGold,
		lastUpdate = time()
	}
end

-- Get all characters gold data for current realm
function mod:GetRealmGoldData()
	local realm = GetRealmName()
	if not db[realm] then
		return {}
	end
	return db[realm]
end

-- Get total gold across all characters on current realm
function mod:GetTotalRealmGold()
	local realm = GetRealmName()
	if not db[realm] then
		return 0
	end

	local total = 0
	for charName, data in pairs(db[realm]) do
		total = total + (data.gold or 0)
	end

	return total
end

-- Get current character's gold
function mod:GetCurrentCharacterGold()
	local playerName = UnitName("player")
	local realm = GetRealmName()

	if db[realm] and db[realm][playerName] then
		return db[realm][playerName].gold or 0
	end

	return GetMoney()
end

-- Format gold into gold, silver, copper display
function mod:FormatMoney(amount)
	if not amount or amount == 0 then
		return "0|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
	end

	local gold = math.floor(amount / 10000)
	local silver = math.floor((amount % 10000) / 100)
	local copper = amount % 100

	local str = ""

	if gold > 0 then
		str = str .. gold .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
	end

	if silver > 0 or gold > 0 then
		if str ~= "" then str = str .. " " end
		str = str .. silver .. "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
	end

	if copper > 0 or str == "" then
		if str ~= "" then str = str .. " " end
		str = str .. copper .. "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
	end

	return str
end
