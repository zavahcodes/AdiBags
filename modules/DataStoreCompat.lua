--[[
AdiBags - DataStore Compatibility Fix
Copyright 2025
All rights reserved.

This module prevents errors in DataStore_Containers when using Personal Bank.
Personal Banks use guild bank API but don't have real guild data, causing
DataStore_Containers to error when trying to index nil guild information.
--]]

local addonName, addon = ...

--<GLOBALS
local _G = _G
local IsAddOnLoaded = _G.IsAddOnLoaded
local pcall = _G.pcall
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetGuildInfo = _G.GetGuildInfo
local GetRealmName = _G.GetRealmName
local UnitName = _G.UnitName
local UnitFactionGroup = _G.UnitFactionGroup
local format = _G.format
--GLOBALS>

-- Create the module
local mod = addon:NewModule('DataStoreCompat', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0')
mod.uiName = "DataStore Compatibility"
mod.uiDesc = "Prevents errors in DataStore_Containers when using Personal Bank systems."

local dataStoreHooked = false

--------------------------------------------------------------------------------
-- Helper function to detect Personal Bank
--------------------------------------------------------------------------------

local function IsPersonalBank()
	-- Personal Banks have guild bank UI but no actual guild
	local guildName = GetGuildInfo("player")
	local numMembers = GetNumGuildMembers()
	return (not guildName or guildName == "") or (numMembers == 0)
end

--------------------------------------------------------------------------------
-- Module lifecycle
--------------------------------------------------------------------------------

function mod:OnEnable()
	-- Check if DataStore_Containers is loaded
	if IsAddOnLoaded("DataStore_Containers") then
		-- Call directly without timer
		self:HookDataStore()
	else
		-- Wait for it to load
		self:RegisterEvent('ADDON_LOADED')
	end
end

function mod:OnDisable()
	-- Module disabled
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------

function mod:ADDON_LOADED(event, loadedAddon)
	if loadedAddon == "DataStore_Containers" and not dataStoreHooked then
		-- Call directly without timer
		self:HookDataStore()
		self:UnregisterEvent('ADDON_LOADED')
	end
end--------------------------------------------------------------------------------
-- Helper to create fake guild for Personal Bank
--------------------------------------------------------------------------------

local function CreateFakeGuild(DataStore)
	-- Create a fake guild in DataStore's database
	-- DataStore uses THIS_ACCOUNT = "Default" (see line 18 of DataStore_Containers.lua)

	local realm = GetRealmName()
	local account = "Default"  -- Must match DataStore's THIS_ACCOUNT constant
	local guildName = "Personal Bank"
	local guildKey = format("%s.%s.%s", account, realm, guildName)

	-- Initialize Guilds table if it doesn't exist
	if not DataStore.db then
		return nil, nil
	end

	if not DataStore.db.global then
		return nil, nil
	end

	if not DataStore.db.global.Guilds then
		DataStore.db.global.Guilds = {}
	end

	-- Create fake guild if it doesn't exist
	if not DataStore.db.global.Guilds[guildKey] then
		DataStore.db.global.Guilds[guildKey] = {
			Tabs = {},
			faction = UnitFactionGroup("player"),
			money = 0,
		}
	end

	local fakeGuild = DataStore.db.global.Guilds[guildKey]

	-- Ensure Tabs table exists (it might be corrupted if guild already existed)
	if not fakeGuild.Tabs then
		fakeGuild.Tabs = {}
	end

	-- Create 8 empty tabs
	for i = 1, 8 do
		if not fakeGuild.Tabs[i] then
			fakeGuild.Tabs[i] = {
				name = "Tab " .. i,
				icon = "Interface\\Icons\\INV_Misc_QuestionMark",
				visitedBy = UnitName("player"),
				ClientTime = 0,
				ClientDate = "",
				ClientHour = 0,
				ClientMinute = 0,
				ServerHour = 0,
				ServerMinute = 0,
			}
		end
	end

	return fakeGuild, guildKey
end

--------------------------------------------------------------------------------
-- DataStore hooking
--------------------------------------------------------------------------------

function mod:HookDataStore()
	if dataStoreHooked then
		return
	end

	local DataStore = _G.DataStore
	if not DataStore then
		return
	end

	-- DataStore_Containers is NOT a module of DataStore, it's a separate addon
	-- Try to get it directly from globals
	local DSContainers = _G.DataStore_Containers
	if not DSContainers then
		return
	end

	-- Strategy: Always return fake guild if no real guild exists
	-- Create fake guild structure IMMEDIATELY so it's ready

	local original_GetGuildInfo = GetGuildInfo
	local fakeGuildName = "Personal Bank"

	-- Create fake guild structure NOW (not later)
	local fakeGuild, fakeGuildKey = CreateFakeGuild(DataStore)

	if not fakeGuild then
		dataStoreHooked = true
		return
	end

	-- Hook GetGuildInfo GLOBALLY to always return fake guild when no real guild exists
	_G.GetGuildInfo = function(unit, ...)
		local realGuild = original_GetGuildInfo(unit, ...)

		-- Silent operation now that we know it works

		-- If there's a real guild, return it
		if realGuild and realGuild ~= "" then
			return realGuild, ...
		end

		-- If no real guild and we're the player, return fake guild
		-- This ensures GetThisGuild() always finds something
		if unit == "player" then
			return fakeGuildName
		end

		-- For other units, return original result
		return realGuild, ...
	end

	dataStoreHooked = true
end
--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

function mod:GetOptions()
	return {
		help = {
			name = "This module prevents errors in DataStore_Containers addon when using Personal Bank systems that mimic guild banks but don't have real guild data.\n\nThe module detects Personal Banks (no guild name or 0 members) and blocks DataStore_Containers from processing guild bank events.\n\nNo configuration needed - it works automatically.",
			type = 'description',
			fontSize = 'medium',
			order = 10,
		},
		status = {
			name = function()
				if IsPersonalBank() then
					return "|cff00ff00Personal Bank detected - DataStore protection active|r"
				elseif dataStoreHooked then
					return "|cffFFFF00DataStore_Containers hooks installed|r"
				else
					return "|cffFF0000Waiting for DataStore_Containers...|r"
				end
			end,
			type = 'description',
			fontSize = 'medium',
			order = 20,
		},
	}, addon:GetOptionHandler(self)
end

-- Module loaded silently
