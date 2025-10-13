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

-- Create the module (using different name to avoid conflict with GuildBank bag)
local mod = addon:NewModule('GuildBankSupport', 'AceEvent-3.0', 'AceHook-3.0')
mod.uiName = L['Guild Bank Support'] or "Guild Bank Support"
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

	-- Get current tab, default to 1 if not available (Personal Bank case)
	local tab = GetCurrentGuildBankTab()
	if not tab or tab < 1 or tab > 8 then
		tab = 1
		addon:Debug('GetCurrentGuildBankTab returned invalid value, defaulting to tab 1')
	end
	currentTab = tab

	-- Query the current tab to ensure we have data
	QueryGuildBankTab(currentTab)

	-- Send update for the current tab's virtual bag
	local virtualBagId = 100 + currentTab
	addon:SendMessage('AdiBags_BagUpdated', virtualBagId)
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

	-- For Personal Bank implementations, tab might be nil
	-- In that case, use the current tab
	tab = tab or currentTab

	-- Validate tab number
	if not tab or tab < 1 or tab > 8 then
		addon:Debug('Invalid tab number:', tab, '- using currentTab:', currentTab)
		tab = currentTab
	end

	-- Send update for the virtual bag ID corresponding to this tab
	-- Virtual bag ID = 100 + tab number
	local virtualBagId = 100 + tab
	addon:SendMessage('AdiBags_BagUpdated', virtualBagId)
end

function mod:GUILDBANK_UPDATE_TABS(event)
	if not guildBankOpen then return end

	addon:Debug('Guild Bank tabs updated')
	local newTab = GetCurrentGuildBankTab()

	-- For Personal Banks, GetCurrentGuildBankTab might return nil
	-- In that case, keep using the current tab (default to 1)
	if newTab and newTab >= 1 and newTab <= 8 then
		currentTab = newTab
	elseif not currentTab or currentTab < 1 or currentTab > 8 then
		-- Ensure we always have a valid tab
		currentTab = 1
	end

	-- Query tab if we have a valid one
	if currentTab and currentTab >= 1 and currentTab <= 8 then
		QueryGuildBankTab(currentTab)
	end

	-- Send update for the current tab's virtual bag
	local virtualBagId = 100 + currentTab
	addon:SendMessage('AdiBags_BagUpdated', virtualBagId)
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

--------------------------------------------------------------------------------
-- Hide original Guild Bank frame
--------------------------------------------------------------------------------

-- Function to hide the original guild bank frame
local function HideOriginalGuildBankFrame()
	-- Hide the main guild bank frame
	if GuildBankFrame then
		GuildBankFrame:Hide()
	end

	-- Also hide any related frames that might appear
	if GuildBankTabButton1 then
		for i = 1, 8 do
			local tabButton = _G["GuildBankTabButton" .. i]
			if tabButton then
				tabButton:Hide()
			end
		end
	end
end

-- Hook into the guild bank opening to hide the original frame
local originalGuildBankFrame_OnEvent = nil
if GuildBankFrame and GuildBankFrame:GetScript("OnEvent") then
	originalGuildBankFrame_OnEvent = GuildBankFrame:GetScript("OnEvent")
	GuildBankFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "GUILDBANKFRAME_OPENED" then
			-- Call original handler first
			if originalGuildBankFrame_OnEvent then
				originalGuildBankFrame_OnEvent(self, event, ...)
			end
			-- Then hide the frame
			HideOriginalGuildBankFrame()
		else
			-- Call original handler for other events
			if originalGuildBankFrame_OnEvent then
				originalGuildBankFrame_OnEvent(self, event, ...)
			end
		end
	end)
end

-- Alternative approach: Hook the frame show function
if GuildBankFrame then
	local originalShow = GuildBankFrame.Show
	GuildBankFrame.Show = function(self)
		-- Don't show the original frame
		addon:Debug('Blocked original Guild Bank frame from showing')
	end
end

addon:Debug('GuildBank module loaded')
