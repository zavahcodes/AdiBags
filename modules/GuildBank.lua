--[[
AdiBags - Guild Bank Support
Copyright 2025
All rights reserved.

This module adds support for viewing Guild Bank contents in AdiBags.
Items are displayed in read-only mode to prevent reorganization issues.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo
local GetGuildBankItemLink = _G.GetGuildBankItemLink
local GetGuildBankTabInfo = _G.GetGuildBankTabInfo
local GetNumGuildBankTabs = _G.GetNumGuildBankTabs
local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98
local QueryGuildBankTab = _G.QueryGuildBankTab
local pairs = _G.pairs
local select = _G.select
local type = _G.type
--GLOBALS>

-- Create the module
local mod = addon:NewModule('GuildBank', 'AceEvent-3.0', 'AceHook-3.0')
mod.uiName = L['Guild Bank'] or "Guild Bank"
mod.uiDesc = L['Display guild bank contents in AdiBags (read-only mode).'] or "Display guild bank contents in AdiBags (read-only mode)."

-- Guild Bank constants
local GUILD_BANK_TAB_MIN = 1
local GUILD_BANK_TAB_MAX = 8

-- State tracking
local currentTab = 1
local guildBankOpen = false

--------------------------------------------------------------------------------
-- Module lifecycle
--------------------------------------------------------------------------------

function mod:OnEnable()
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
	self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
	self:RegisterEvent('GUILDBANK_UPDATE_TABS')
	
	addon:Debug('GuildBank module enabled')
	
	-- Check if guild bank is already open
	if addon:GetInteractingWindow() == "GUILDBANKFRAME" then
		self:GUILDBANKFRAME_OPENED()
	end
end

function mod:OnDisable()
	self:UnregisterAllEvents()
	guildBankOpen = false
	addon:Debug('GuildBank module disabled')
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------

function mod:GUILDBANKFRAME_OPENED(event)
	addon:Debug('Guild Bank opened')
	guildBankOpen = true
	currentTab = GetCurrentGuildBankTab() or 1
	
	-- Query the current tab to ensure we have data
	QueryGuildBankTab(currentTab)
	
	-- Trigger bag update for guild bank
	self:UpdateGuildBank()
end

function mod:GUILDBANKFRAME_CLOSED(event)
	addon:Debug('Guild Bank closed')
	guildBankOpen = false
	
	-- Trigger cleanup
	self:UpdateGuildBank()
end

function mod:GUILDBANKBAGSLOTS_CHANGED(event, tab, slot)
	if not guildBankOpen then return end
	
	addon:Debug('Guild Bank slot changed:', tab, slot)
	
	-- Only update if it's the current tab
	if tab == currentTab then
		self:UpdateGuildBank()
	end
end

function mod:GUILDBANK_UPDATE_TABS(event)
	if not guildBankOpen then return end
	
	addon:Debug('Guild Bank tabs updated')
	currentTab = GetCurrentGuildBankTab() or currentTab
	self:UpdateGuildBank()
end

--------------------------------------------------------------------------------
-- Guild Bank data retrieval
--------------------------------------------------------------------------------

function mod:UpdateGuildBank()
	-- Notify AdiBags that guild bank data has changed
	addon:SendMessage('AdiBags_GuildBankUpdated', currentTab)
end

function mod:GetCurrentTab()
	return currentTab
end

function mod:IsOpen()
	return guildBankOpen
end

function mod:GetTabInfo(tab)
	tab = tab or currentTab
	local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tab)
	
	return {
		name = name,
		icon = icon,
		isViewable = isViewable,
		canDeposit = canDeposit,
		numWithdrawals = numWithdrawals,
		remainingWithdrawals = remainingWithdrawals,
	}
end

function mod:GetSlotInfo(tab, slot)
	tab = tab or currentTab
	
	if not tab or not slot then
		return nil
	end
	
	local texture, itemCount, locked = GetGuildBankItemInfo(tab, slot)
	
	if not texture then
		return nil
	end
	
	local itemLink = GetGuildBankItemLink(tab, slot)
	
	return {
		texture = texture,
		count = itemCount or 1,
		locked = locked,
		link = itemLink,
		tab = tab,
		slot = slot,
	}
end

function mod:IterateSlots(tab)
	tab = tab or currentTab
	
	local slot = 0
	return function()
		slot = slot + 1
		if slot > MAX_GUILDBANK_SLOTS_PER_TAB then
			return nil
		end
		
		local info = self:GetSlotInfo(tab, slot)
		if info then
			return slot, info
		else
			-- Continue to next slot even if this one is empty
			return slot, nil
		end
	end
end

--------------------------------------------------------------------------------
-- Tooltip support
--------------------------------------------------------------------------------

function mod:SetupTooltip(tooltip, tab, slot)
	if not tooltip or not tab or not slot then return end
	
	tooltip:SetGuildBankItem(tab, slot)
end

addon:Debug('GuildBank module loaded')
