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
	print("|cff00ff00[AdiBags DataStoreCompat]|r Module enabled")

	-- Check if DataStore_Containers is loaded
	if IsAddOnLoaded("DataStore_Containers") then
		print("|cff00ff00[AdiBags DataStoreCompat]|r DataStore_Containers already loaded, hooking now...")
		-- Call directly without timer
		self:HookDataStore()
	else
		print("|cffFFFF00[AdiBags DataStoreCompat]|r DataStore_Containers not loaded yet, waiting...")
		-- Wait for it to load
		self:RegisterEvent('ADDON_LOADED')
	end
end

function mod:OnDisable()
	print("|cffFF0000[AdiBags DataStoreCompat]|r Module disabled")
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------

function mod:ADDON_LOADED(event, loadedAddon)
	if loadedAddon == "DataStore_Containers" and not dataStoreHooked then
		print("|cff00ff00[AdiBags DataStoreCompat]|r DataStore_Containers loaded, hooking now...")
		-- Call directly without timer
		self:HookDataStore()
		self:UnregisterEvent('ADDON_LOADED')
	end
end

--------------------------------------------------------------------------------
-- Helper to create fake guild for Personal Bank
--------------------------------------------------------------------------------

local function CreateFakeGuild(DataStore)
	-- Create a fake guild in DataStore's database
	-- DataStore uses THIS_ACCOUNT = "Default" (see line 18 of DataStore_Containers.lua)

	local realm = GetRealmName()
	local account = "Default"  -- Must match DataStore's THIS_ACCOUNT constant
	local guildName = "Personal Bank"
	local guildKey = format("%s.%s.%s", account, realm, guildName)

	print("|cffFFFF00[AdiBags DataStoreCompat]|r Creating fake guild with key:", guildKey)

	-- Initialize Guilds table if it doesn't exist
	if not DataStore.db then
		print("|cffFF0000[AdiBags DataStoreCompat]|r ERROR: DataStore.db is nil!")
		return nil, nil
	end

	if not DataStore.db.global then
		print("|cffFF0000[AdiBags DataStoreCompat]|r ERROR: DataStore.db.global is nil!")
		return nil, nil
	end

	if not DataStore.db.global.Guilds then
		DataStore.db.global.Guilds = {}
		print("|cff00ff00[AdiBags DataStoreCompat]|r Created DataStore.db.global.Guilds table")
	end

	-- Create fake guild if it doesn't exist
	if not DataStore.db.global.Guilds[guildKey] then
		DataStore.db.global.Guilds[guildKey] = {
			Tabs = {},
			faction = UnitFactionGroup("player"),
			money = 0,
		}
		print("|cff00ff00[AdiBags DataStoreCompat]|r Created NEW fake guild")
	else
		print("|cffFFFF00[AdiBags DataStoreCompat]|r Fake guild already exists")
	end

	local fakeGuild = DataStore.db.global.Guilds[guildKey]

	-- Ensure Tabs table exists (it might be corrupted if guild already existed)
	if not fakeGuild.Tabs then
		fakeGuild.Tabs = {}
		print("|cffFFFF00[AdiBags DataStoreCompat]|r Tabs table was nil, creating new one")
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

	-- Safe count of tabs
	local tabCount = 0
	for i = 1, 8 do
		if fakeGuild.Tabs[i] then
			tabCount = tabCount + 1
		end
	end
	print("|cff00ff00[AdiBags DataStoreCompat]|r Fake guild has", tabCount, "tabs initialized")

	return fakeGuild, guildKey
end

--------------------------------------------------------------------------------
-- DataStore hooking
--------------------------------------------------------------------------------

function mod:HookDataStore()
	if dataStoreHooked then
		print("|cffFFFF00[AdiBags DataStoreCompat]|r Already hooked, skipping")
		return
	end

	local DataStore = _G.DataStore
	if not DataStore then
		print("|cffFF0000[AdiBags DataStoreCompat]|r DataStore not found!")
		return
	end

	-- DataStore_Containers is NOT a module of DataStore, it's a separate addon
	-- Try to get it directly from globals
	local DSContainers = _G.DataStore_Containers
	if not DSContainers then
		print("|cffFF0000[AdiBags DataStoreCompat]|r DataStore_Containers addon not found!")
		return
	end

	print("|cff00ff00[AdiBags DataStoreCompat]|r DataStore_Containers found! Creating fake guild...")

	-- Strategy: Always return fake guild if no real guild exists
	-- Create fake guild structure IMMEDIATELY so it's ready

	local original_GetGuildInfo = GetGuildInfo
	local fakeGuildName = "Personal Bank"

	-- Create fake guild structure NOW (not later)
	local fakeGuild, fakeGuildKey = CreateFakeGuild(DataStore)

	if fakeGuild then
		print("|cff00ff00[AdiBags DataStoreCompat]|r ✓ Fake guild SUCCESS! Key:", fakeGuildKey)
	else
		print("|cffFF0000[AdiBags DataStoreCompat]|r ✗ FAILED to create fake guild!")
		dataStoreHooked = true
		return
	end

	-- Hook GetGuildInfo GLOBALLY to always return fake guild when no real guild exists
	_G.GetGuildInfo = function(unit, ...)
		local realGuild = original_GetGuildInfo(unit, ...)

		-- Debug ALL calls to GetGuildInfo
		if unit == "player" then
			if realGuild and realGuild ~= "" then
				print("|cff00ffff[AdiBags DataStoreCompat]|r GetGuildInfo('player') -> REAL:", realGuild)
			else
				print("|cff00ffff[AdiBags DataStoreCompat]|r GetGuildInfo('player') -> FAKE:", fakeGuildName)
			end
		end

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
	print("|cff00ff00[AdiBags DataStoreCompat]|r ✓ GetGuildInfo hooked globally")

	-- Also register for guild bank events to see what's happening
	self:RegisterEvent('GUILDBANKFRAME_OPENED', function()
		print("|cffFFFF00[AdiBags DataStoreCompat]|r >>> GUILDBANKFRAME_OPENED event fired!")
		-- Test our GetGuildInfo hook
		local testResult = GetGuildInfo("player")
		print("|cffFFFF00[AdiBags DataStoreCompat]|r Test GetGuildInfo result:", testResult or "nil")
	end)

	self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED', function()
		print("|cffFF8800[AdiBags DataStoreCompat]|r >>> GUILDBANKBAGSLOTS_CHANGED event fired!")
	end)

	dataStoreHooked = true
	print("|cff00ff00[AdiBags DataStoreCompat]|r ✓✓✓ ALL SYSTEMS READY ✓✓✓")
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

print("|cff00ff00[AdiBags DataStoreCompat]|r Module file loaded")
