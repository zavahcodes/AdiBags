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
--GLOBALS>

-- Create the module
local mod = addon:NewModule('DataStoreCompat', 'AceEvent-3.0')
mod.uiName = "DataStore Compatibility"
mod.uiDesc = "Prevents errors in DataStore_Containers when using Personal Bank systems."

local dataStoreHooked = false

--------------------------------------------------------------------------------
-- Module lifecycle
--------------------------------------------------------------------------------

function mod:OnEnable()
	-- Check if DataStore_Containers is loaded
	if IsAddOnLoaded("DataStore_Containers") then
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

function mod:ADDON_LOADED(event, addonName)
	if addonName == "DataStore_Containers" and not dataStoreHooked then
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

	-- Hook the problematic event handlers
	if DSContainers.GUILDBANKFRAME_OPENED then
		local original_GUILDBANKFRAME_OPENED = DSContainers.GUILDBANKFRAME_OPENED
		DSContainers.GUILDBANKFRAME_OPENED = function(self, event, ...)
			local success, err = pcall(original_GUILDBANKFRAME_OPENED, self, event, ...)
			if not success then
				-- Silently catch the error
				addon:Debug('Caught DataStore_Containers error on GUILDBANKFRAME_OPENED:', err)
			end
		end
		addon:Debug('Hooked DataStore_Containers.GUILDBANKFRAME_OPENED')
	end

	if DSContainers.GUILDBANKBAGSLOTS_CHANGED then
		local original_GUILDBANKBAGSLOTS_CHANGED = DSContainers.GUILDBANKBAGSLOTS_CHANGED
		DSContainers.GUILDBANKBAGSLOTS_CHANGED = function(self, event, ...)
			local success, err = pcall(original_GUILDBANKBAGSLOTS_CHANGED, self, event, ...)
			if not success then
				-- Silently catch the error
				addon:Debug('Caught DataStore_Containers error on GUILDBANKBAGSLOTS_CHANGED:', err)
			end
		end
		addon:Debug('Hooked DataStore_Containers.GUILDBANKBAGSLOTS_CHANGED')
	end

	if DSContainers.GUILDBANK_UPDATE_TABS then
		local original_GUILDBANK_UPDATE_TABS = DSContainers.GUILDBANK_UPDATE_TABS
		DSContainers.GUILDBANK_UPDATE_TABS = function(self, event, ...)
			local success, err = pcall(original_GUILDBANK_UPDATE_TABS, self, event, ...)
			if not success then
				-- Silently catch the error
				addon:Debug('Caught DataStore_Containers error on GUILDBANK_UPDATE_TABS:', err)
			end
		end
		addon:Debug('Hooked DataStore_Containers.GUILDBANK_UPDATE_TABS')
	end

	dataStoreHooked = true
	addon:Debug('DataStore_Containers compatibility hooks installed')
end

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

function mod:GetOptions()
	return {
		help = {
			name = "This module prevents errors in DataStore_Containers addon when using Personal Bank systems that mimic guild banks but don't have real guild data.\n\nNo configuration needed - it works automatically.",
			type = 'description',
			fontSize = 'medium',
			order = 10,
		},
	}, addon:GetOptionHandler(self)
end

addon:Debug('DataStoreCompat module loaded')
