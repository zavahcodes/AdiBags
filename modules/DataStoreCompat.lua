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
--GLOBALS>

-- Create the module
local mod = addon:NewModule('DataStoreCompat', 'AceEvent-3.0', 'AceHook-3.0')
mod.uiName = "DataStore Compatibility"
mod.uiDesc = "Prevents errors in DataStore_Containers when using Personal Bank systems."

local dataStoreHooked = false
local isInPersonalBank = false

--------------------------------------------------------------------------------
-- Module lifecycle
--------------------------------------------------------------------------------

function mod:OnEnable()
	-- Register guild bank events to detect Personal Bank usage
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
	
	-- Check if DataStore_Containers is loaded
	if IsAddOnLoaded("DataStore_Containers") then
		self:ScheduleTimer(function() self:HookDataStore() end, 1)
	else
		-- Wait for it to load
		self:RegisterEvent('ADDON_LOADED')
	end

	addon:Debug('DataStoreCompat module enabled')
end

function mod:OnDisable()
	isInPersonalBank = false
	addon:Debug('DataStoreCompat module disabled')
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------

function mod:GUILDBANKFRAME_OPENED()
	-- Detect if this is a Personal Bank (no real guild)
	local numMembers = GetNumGuildMembers()
	isInPersonalBank = (numMembers == 0)
	
	if isInPersonalBank then
		addon:Debug('Personal Bank detected (no guild members)')
	end
end

function mod:GUILDBANKFRAME_CLOSED()
	isInPersonalBank = false
end

function mod:ADDON_LOADED(event, loadedAddon)
	if loadedAddon == "DataStore_Containers" and not dataStoreHooked then
		-- Wait a bit for DataStore_Containers to fully initialize
		self:ScheduleTimer(function() self:HookDataStore() end, 1)
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

	-- Use SecureHook to intercept events WITHOUT replacing the handler
	if DSContainers.GUILDBANKFRAME_OPENED then
		self:RawHook(DSContainers, 'GUILDBANKFRAME_OPENED', function(self, event, ...)
			if isInPersonalBank then
				addon:Debug('Blocking DataStore_Containers.GUILDBANKFRAME_OPENED (Personal Bank)')
				return
			end
			return mod.hooks[DSContainers]['GUILDBANKFRAME_OPENED'](self, event, ...)
		end, true)
		addon:Debug('Hooked DataStore_Containers.GUILDBANKFRAME_OPENED')
	end

	if DSContainers.GUILDBANKBAGSLOTS_CHANGED then
		self:RawHook(DSContainers, 'GUILDBANKBAGSLOTS_CHANGED', function(self, event, ...)
			if isInPersonalBank then
				addon:Debug('Blocking DataStore_Containers.GUILDBANKBAGSLOTS_CHANGED (Personal Bank)')
				return
			end
			return mod.hooks[DSContainers]['GUILDBANKBAGSLOTS_CHANGED'](self, event, ...)
		end, true)
		addon:Debug('Hooked DataStore_Containers.GUILDBANKBAGSLOTS_CHANGED')
	end

	if DSContainers.GUILDBANK_UPDATE_TABS then
		self:RawHook(DSContainers, 'GUILDBANK_UPDATE_TABS', function(self, event, ...)
			if isInPersonalBank then
				addon:Debug('Blocking DataStore_Containers.GUILDBANK_UPDATE_TABS (Personal Bank)')
				return
			end
			return mod.hooks[DSContainers]['GUILDBANK_UPDATE_TABS'](self, event, ...)
		end, true)
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
			name = "This module prevents errors in DataStore_Containers addon when using Personal Bank systems that mimic guild banks but don't have real guild data.\n\nThe module detects when you're in a Personal Bank (no guild members) and blocks DataStore_Containers from processing the events.\n\nNo configuration needed - it works automatically.",
			type = 'description',
			fontSize = 'medium',
			order = 10,
		},
		status = {
			name = function()
				if isInPersonalBank then
					return "|cff00ff00Currently in Personal Bank - DataStore protection active|r"
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
