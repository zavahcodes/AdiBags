--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.

RefreshLayout Module - Added by zavahcodes
]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local CreateFrame = _G.CreateFrame
local PlaySound = _G.PlaySound
--GLOBALS>

local mod = addon:NewModule('RefreshLayout', 'AceEvent-3.0')
mod.uiName = L['Refresh layout']
mod.uiDesc = L['Add a button to manually refresh the bag layout and reorganize items. Click the "R" button to force a complete refresh of all bags.']

local buttons = {}

function mod:OnEnable()
	addon:HookBagFrameCreation(self, 'OnBagFrameCreated')
	for button in pairs(buttons) do
		button:Show()
	end
end

function mod:OnDisable()
	for button in pairs(buttons) do
		button:Hide()
	end
end

local function RefreshButton_OnClick(button)
	PlaySound("igMainMenuOptionCheckBoxOn")
	local container = button.container
	
	-- Force a complete refresh
	container.forceLayout = true
	container.filtersChanged = true
	
	-- Redispatch all items
	container:RedispatchAllItems()
	
	-- Force layout update
	container:LayoutSections(0)
	
	-- Send a message that refresh was triggered
	addon:SendMessage('AdiBags_RefreshLayout', container.name)
	
	-- Debug info
	addon:Debug('Manual refresh triggered for', container.name)
end

function mod:OnBagFrameCreated(bag)
	local container = bag:GetFrame()
	
	local button = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
	button:SetText("R")
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetScript("OnClick", RefreshButton_OnClick)
	button.container = container
	
	-- Add the button with order 15 (after T=0, V=5, N=10)
	container:AddHeaderWidget(button, 15)
	
	addon.SetupTooltip(button, {
		L["Refresh layout"],
		L["Click to manually refresh the bag layout and reorganize all items."]
	}, "ANCHOR_TOPLEFT", 0, 8)
	
	buttons[button] = true
end
