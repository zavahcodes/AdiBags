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

	addon:Debug('DataStoreCompat module enabled')
end

function mod:OnDisable()
	addon:Debug('DataStoreCompat module disabled')
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
end

--------------------------------------------------------------------------------
-- DataStore hooking
--------------------------------------------------------------------------------

function mod:HookDataStore()
	if dataStoreHooked then return end

	local DataStore = _G.DataStore
	if not DataStore then
		addon:Debug('DataStore not found, skipping compatibility fix')
		return
	end

	-- Try to get DataStore_Containers
	local DSContainers = DataStore:GetModule("DataStore_Containers", true)
	if not DSContainers then
		addon:Debug('DataStore_Containers module not found')
		return
	end

	-- Strategy: Intercept the events BEFORE they reach DataStore_Containers
	-- Register our own handlers with higher priority (register first)

	-- Hook GUILDBANKFRAME_OPENED to detect Personal Bank
	self:RegisterEvent('GUILDBANKFRAME_OPENED', function()
		if IsPersonalBank() then
			addon:Debug('Personal Bank detected - blocking DataStore_Containers events')
			-- Temporarily unregister DataStore's problematic events
			if DSContainers.GUILDBANKBAGSLOTS_CHANGED then
				DSContainers:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
				addon:Debug('Unregistered DataStore GUILDBANKBAGSLOTS_CHANGED')
			end
			if DSContainers.GUILDBANK_UPDATE_TABS then
				DSContainers:UnregisterEvent("GUILDBANK_UPDATE_TABS")
				addon:Debug('Unregistered DataStore GUILDBANK_UPDATE_TABS')
			end
		end
	end)

	-- Hook GUILDBANKFRAME_CLOSED to re-enable DataStore
	self:RegisterEvent('GUILDBANKFRAME_CLOSED', function()
		-- Re-register DataStore events
		if DSContainers.GUILDBANKBAGSLOTS_CHANGED then
			DSContainers:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
			addon:Debug('Re-registered DataStore GUILDBANKBAGSLOTS_CHANGED')
		end
		if DSContainers.GUILDBANK_UPDATE_TABS then
			DSContainers:RegisterEvent("GUILDBANK_UPDATE_TABS")
			addon:Debug('Re-registered DataStore GUILDBANK_UPDATE_TABS')
		end
	end)

	dataStoreHooked = true
	addon:Debug('DataStore_Containers compatibility hooks installed successfully')
end--------------------------------------------------------------------------------
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

addon:Debug('DataStoreCompat module loaded')
