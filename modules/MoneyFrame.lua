--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local pairs = _G.pairs
local table = _G.table
--GLOBALS>

local mod = addon:NewModule('MoneyFrame', 'AceEvent-3.0', 'AceTimer-3.0')
mod.uiName = L['Money']
mod.uiDesc = L['Display character money at bottom right of the backpack.']

function mod:OnEnable()
	addon:HookBagFrameCreation(self, 'OnBagFrameCreated')
	if self.widget then
		self.widget:Show()
	end
end

function mod:OnDisable()
	if self.widget then
		self.widget:Hide()
	end
end

function mod:OnBagFrameCreated(bag)
	if bag.bagName ~= "Backpack" then return end
	local frame = bag:GetFrame()
	self.widget = CreateFrame("Frame", addonName.."MoneyFrame", frame, "MoneyFrameTemplate")
	self.widget:SetHeight(19)
	frame:AddBottomWidget(self.widget, "RIGHT", 50, nil, 13, 0)

	-- Enable mouse interaction for tooltip on the main frame
	self.widget:EnableMouse(true)
	self.widget:SetScript("OnEnter", function(self)
		mod:ShowGoldTooltip(self)
	end)
	self.widget:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	-- Also enable tooltip on all child buttons (Gold, Silver, Copper buttons)
	-- The MoneyFrameTemplate creates these buttons automatically
	local function SetupChildTooltips(parent)
		local regions = {parent:GetChildren()}
		for _, child in pairs(regions) do
			if child:GetObjectType() == "Button" then
				child:SetScript("OnEnter", function(self)
					mod:ShowGoldTooltip(self:GetParent())
				end)
				child:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
			end
		end
	end

	-- Set up tooltips on child buttons after a short delay to ensure they exist
	if _G.C_Timer then
		_G.C_Timer.After(0.1, function() SetupChildTooltips(self.widget) end)
	else
		-- Fallback for older clients
		self:ScheduleTimer(function() SetupChildTooltips(self.widget) end, 0.1)
	end
end

function mod:ShowGoldTooltip(frame)
	-- Check if GoldTracker module exists
	local goldTracker = addon:GetModule('GoldTracker', true)
	if not goldTracker then
		-- Fallback to default tooltip
		GameTooltip:SetOwner(frame, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Money"], 1, 1, 1)
		GameTooltip:Show()
		return
	end

	GameTooltip:SetOwner(frame, "ANCHOR_TOP")
	GameTooltip:ClearLines()

	-- Add title
	GameTooltip:AddLine(L["Gold Across Characters"], 1, 1, 1)
	GameTooltip:AddLine(" ")

	-- Get all character gold data
	local realmData = goldTracker:GetRealmGoldData()

	-- Count characters
	local charCount = 0
	for _ in pairs(realmData) do
		charCount = charCount + 1
	end

	-- If no data, show a message
	if charCount == 0 then
		GameTooltip:AddLine("No character data yet", 0.8, 0.8, 0.8)
		GameTooltip:AddLine("Login with characters to track gold", 0.6, 0.6, 0.6)
		GameTooltip:Show()
		return
	end

	-- Sort characters by name
	local sortedChars = {}
	for charName, data in pairs(realmData) do
		table.insert(sortedChars, {name = charName, gold = data.gold or 0})
	end
	table.sort(sortedChars, function(a, b) return a.name < b.name end)

	-- Add each character's gold
	for _, charData in pairs(sortedChars) do
		local formattedGold = goldTracker:FormatMoney(charData.gold)
		GameTooltip:AddDoubleLine(charData.name, formattedGold, 1, 1, 1, 1, 1, 1)
	end

	-- Add separator and total
	if #sortedChars > 1 then
		GameTooltip:AddLine(" ")
		local totalGold = goldTracker:GetTotalRealmGold()
		local formattedTotal = goldTracker:FormatMoney(totalGold)
		GameTooltip:AddDoubleLine(L["Total"], formattedTotal, 1, 1, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

