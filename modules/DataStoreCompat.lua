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

	-- Strategy: Hook the event handlers directly and wrap them with error protection
	-- This is more reliable than trying to unregister/register events

	-- Save original handlers
	local original_GUILDBANKFRAME_OPENED = DSContainers.GUILDBANKFRAME_OPENED
	local original_GUILDBANKBAGSLOTS_CHANGED = DSContainers.GUILDBANKBAGSLOTS_CHANGED
	local original_GUILDBANK_UPDATE_TABS = DSContainers.GUILDBANK_UPDATE_TABS

	-- Replace GUILDBANKFRAME_OPENED with protected version
	if original_GUILDBANKFRAME_OPENED then
		DSContainers.GUILDBANKFRAME_OPENED = function(self, event, ...)
			if IsPersonalBank() then
				addon:Debug('Personal Bank detected - skipping DataStore GUILDBANKFRAME_OPENED')
				return
			end
			return original_GUILDBANKFRAME_OPENED(self, event, ...)
		end
		addon:Debug('Protected DataStore_Containers.GUILDBANKFRAME_OPENED')
	end

	-- Replace GUILDBANKBAGSLOTS_CHANGED with protected version
	if original_GUILDBANKBAGSLOTS_CHANGED then
		DSContainers.GUILDBANKBAGSLOTS_CHANGED = function(self, event, ...)
			if IsPersonalBank() then
				addon:Debug('Personal Bank detected - skipping DataStore GUILDBANKBAGSLOTS_CHANGED')
				return
			end
			-- Wrap in pcall for extra safety
			local success, err = pcall(original_GUILDBANKBAGSLOTS_CHANGED, self, event, ...)
			if not success then
				addon:Debug('Error in DataStore GUILDBANKBAGSLOTS_CHANGED:', err)
			end
		end
		addon:Debug('Protected DataStore_Containers.GUILDBANKBAGSLOTS_CHANGED')
	end

	-- Replace GUILDBANK_UPDATE_TABS with protected version
	if original_GUILDBANK_UPDATE_TABS then
		DSContainers.GUILDBANK_UPDATE_TABS = function(self, event, ...)
			if IsPersonalBank() then
				addon:Debug('Personal Bank detected - skipping DataStore GUILDBANK_UPDATE_TABS')
				return
			end
			-- Wrap in pcall for extra safety
			local success, err = pcall(original_GUILDBANK_UPDATE_TABS, self, event, ...)
			if not success then
				addon:Debug('Error in DataStore GUILDBANK_UPDATE_TABS:', err)
			end
		end
		addon:Debug('Protected DataStore_Containers.GUILDBANK_UPDATE_TABS')
	end

	dataStoreHooked = true
	addon:Debug('DataStore_Containers event handlers wrapped successfully')
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

addon:Debug('DataStoreCompat module loaded')
