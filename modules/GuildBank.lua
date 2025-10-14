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
local mod = addon:NewModule('GuildBankSupport', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0')
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
	print("GUILD BANK DEBUG: OnEnable called")
	print("GUILD BANK DEBUG: Initial GuildBankFrame check:", GuildBankFrame ~= nil)
	
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
	self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
	self:RegisterEvent('GUILDBANK_UPDATE_TABS')

	-- Set up frame hiding using AdiBags pattern
	self:SetupFrameHiding()

	addon:Debug('GuildBank module enabled')

	-- Check if guild bank is already open
	if addon:GetInteractingWindow() == "GUILDBANKFRAME" then
		print("GUILD BANK DEBUG: Guild bank already open, calling GUILDBANKFRAME_OPENED")
		self:GUILDBANKFRAME_OPENED()
	end
	
	print("GUILD BANK DEBUG: OnEnable complete")
end

function mod:OnDisable()
	self:UnregisterAllEvents()

	-- Restore original GuildBankFrame functionality if it was hooked
	if GuildBankFrame and self.hooks and self.hooks[GuildBankFrame] then
		if self.hooks[GuildBankFrame].Show then
			self.hooks[GuildBankFrame].Show(GuildBankFrame)
		end
	end

	guildBankOpen = false
	addon:Debug('GuildBank module disabled')
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------

function mod:GUILDBANKFRAME_OPENED(event)
	print("GUILD BANK DEBUG: GUILDBANKFRAME_OPENED event fired")
	print("GUILD BANK DEBUG: GuildBankFrame exists:", GuildBankFrame ~= nil)
	if GuildBankFrame then
		print("GUILD BANK DEBUG: GuildBankFrame:IsShown():", GuildBankFrame:IsShown())
	end
	
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
	
	print("GUILD BANK DEBUG: GUILDBANKFRAME_OPENED processing complete")
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
-- Hide original Guild Bank frame using AdiBags pattern
--------------------------------------------------------------------------------

local function NOOP() 
	print("GUILD BANK DEBUG: NOOP function called")
end

function mod:SetupFrameHiding()
	print("GUILD BANK DEBUG: SetupFrameHiding called")
	
	-- Wait for GuildBankFrame to be created and then hook it
	local function SetupHooks()
		print("GUILD BANK DEBUG: SetupHooks called, GuildBankFrame exists:", GuildBankFrame ~= nil)
		
		if GuildBankFrame then
			print("GUILD BANK DEBUG: Found GuildBankFrame, setting up hooks")
			print("GUILD BANK DEBUG: GuildBankFrame type:", type(GuildBankFrame))
			print("GUILD BANK DEBUG: GuildBankFrame:IsShown():", GuildBankFrame:IsShown())
			
			-- Hide the frame immediately
			GuildBankFrame:Hide()
			print("GUILD BANK DEBUG: Called GuildBankFrame:Hide()")
			
			-- Use the exact same pattern as AdiBags uses for BankFrame
			self:RawHookScript(GuildBankFrame, "OnEvent", function(...)
				print("GUILD BANK DEBUG: OnEvent hook called with args:", ...)
				-- Block all events
			end, true)
			
			self:RawHook(GuildBankFrame, "Show", function()
				print("GUILD BANK DEBUG: Show() hook called - BLOCKING")
				-- Do nothing to block showing
			end, true)
			
			self:RawHook(GuildBankFrame, "Hide", function()
				print("GUILD BANK DEBUG: Hide() hook called")
				-- Allow hiding
			end, true)
			
			if GuildBankFrame.IsShown then
				self:RawHook(GuildBankFrame, "IsShown", function() 
					print("GUILD BANK DEBUG: IsShown() hook called - returning false")
					return false 
				end, true)
			end
			
			print("GUILD BANK DEBUG: All hooks installed successfully")
			addon:Debug('GuildBankFrame hooks installed successfully')
			return true
		else
			print("GUILD BANK DEBUG: GuildBankFrame not found, will retry")
			addon:Debug('GuildBankFrame not found, will retry')
			return false
		end
	end	-- Try to set up hooks immediately
	if not SetupHooks() then
		-- If frame doesn't exist yet, wait for it to be created
		local attempts = 0
		local function RetrySetup()
			attempts = attempts + 1
			if SetupHooks() then
				return -- Success, stop retrying
			elseif attempts < 10 then
				-- Retry in 0.5 seconds
				self:ScheduleTimer(RetrySetup, 0.5)
			else
				addon:Debug('Failed to find GuildBankFrame after 10 attempts')
			end
		end

		-- Start retrying
		self:ScheduleTimer(RetrySetup, 0.1)
	end
end

addon:Debug('GuildBank module loaded')
