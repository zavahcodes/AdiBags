--[[
AdiBags_UnusableItems - Visual overlay for unusable items
Copyright 2024 zavahcodes
Based on AdiBags-ItemOverlayPlus

This module adds a red overlay to items that you cannot use due to:
- Level requirements
- Class restrictions
- Race restrictions
- Profession requirements
- Any other restrictions shown in red text on tooltips
--]]

local addonName, addon = ...
local L = addon.L

--[[
ABOUT THIS MODULE:
This module scans item tooltips for red text (indicating unusability)
and applies a red overlay to those items for easy visual identification.
--]]

local mod = addon:NewModule("UnusableItems", 'AceEvent-3.0', 'AceTimer-3.0')
mod.uiName = L['Unusable Item Overlay']
mod.uiDesc = L["Adds a red overlay to items that are unusable for you."]

-- Tooltip for scanning
local tooltipName = "AdiBags_UnusableItemsScanner"
local tooltipFrame = _G[tooltipName]
if not tooltipFrame then
	tooltipFrame = CreateFrame("GameTooltip", tooltipName, nil, "GameTooltipTemplate")
	tooltipFrame:SetOwner(WorldFrame, "ANCHOR_NONE")
end

local openBagCount = 0
local updateAllScheduled = false

-- Debounce mechanism for frequent events
local function RequestFullUpdate()
	if not mod.db.profile.EnableOverlay then return end
	if openBagCount == 0 then return end

	if updateAllScheduled then
		return
	end

	updateAllScheduled = true

	-- Use AceTimer for delayed call
	if _G.C_Timer and _G.C_Timer.After then
		_G.C_Timer.After(0, function()
			if openBagCount > 0 and mod.db.profile.EnableOverlay then
				mod:SendMessage('AdiBags_UpdateAllButtons')
			end
			updateAllScheduled = false
		end)
	else
		mod:ScheduleTimer(function()
			if openBagCount > 0 and mod.db.profile.EnableOverlay then
				mod:SendMessage('AdiBags_UpdateAllButtons')
			end
			updateAllScheduled = false
		end, 0)
	end
end

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {
		profile = {
			EnableOverlay = true,
		},
	})

	-- Register events - capture self in closure
	local modSelf = self	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ITEM_LOCK_UPDATE")
	frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	frame:SetScript("OnEvent", function(_, event)
		if openBagCount == 0 or not modSelf.db.profile.EnableOverlay then return end
		RequestFullUpdate()
	end)

	local frame2 = CreateFrame("Frame")
	frame2:RegisterEvent("ITEM_UNLOCKED")
	frame2:RegisterEvent("ITEM_LOCKED")
	frame2:SetScript("OnEvent", function(_, event)
		if openBagCount == 0 or not modSelf.db.profile.EnableOverlay then return end
		RequestFullUpdate()
	end)

	local levelFrame = CreateFrame("Frame")
	levelFrame:RegisterEvent("PLAYER_LEVEL_UP")
	levelFrame:SetScript("OnEvent", function()
		if openBagCount > 0 and modSelf.db.profile.EnableOverlay then
			modSelf:SendMessage('AdiBags_UpdateAllButtons')
		end
	end)
end

function mod:OnEnable()
	self:RegisterMessage('AdiBags_BagSwapPanelClosed', 'ItemPositionChanged')
	self:RegisterMessage('AdiBags_NewItemReset', 'ItemPositionChanged')
	self:RegisterMessage('AdiBags_TidyBags', 'TidyBagsUpdateRed')
	self:RegisterMessage('AdiBags_BagOpened', 'OnBagOpened')
	self:RegisterMessage('AdiBags_BagClosed', 'OnBagClosed')
end

function mod:OnDisable()
	self:UnregisterMessage('AdiBags_UpdateButton')
	self:UnregisterMessage('AdiBags_BagSwapPanelClosed')
	self:UnregisterMessage('AdiBags_NewItemReset')
	self:UnregisterMessage('AdiBags_TidyBags')
	self:UnregisterMessage('AdiBags_BagOpened')
	self:UnregisterMessage('AdiBags_BagClosed')
end

function mod:OnBagOpened()
	openBagCount = openBagCount + 1

	if openBagCount == 1 then
		self:RegisterMessage('AdiBags_UpdateButton', 'UpdateButton')
	end

	if self.db.profile.EnableOverlay then
		-- Use AceTimer for delayed call
		if _G.C_Timer and _G.C_Timer.After then
			_G.C_Timer.After(0, function()
				if openBagCount > 0 and self.db.profile.EnableOverlay then
					self:SendMessage('AdiBags_UpdateAllButtons')
				end
			end)
		else
			self:ScheduleTimer(function()
				if openBagCount > 0 and self.db.profile.EnableOverlay then
					self:SendMessage('AdiBags_UpdateAllButtons')
				end
			end, 0)
		end
	end
end

function mod:OnBagClosed()
	openBagCount = openBagCount - 1

	if openBagCount == 0 then
		self:UnregisterMessage('AdiBags_UpdateButton')
		updateAllScheduled = false
	end

	if openBagCount < 0 then
		openBagCount = 0
	end
end

function mod:TidyBagsUpdateRed()
	if not self.db.profile.EnableOverlay or openBagCount == 0 then return end
	self:SendMessage('AdiBags_UpdateAllButtons')
end

function mod:ItemPositionChanged()
	if not self.db.profile.EnableOverlay or openBagCount == 0 then return end
	self:SendMessage('AdiBags_UpdateAllButtons')
end

-- Apply red overlay to button
local function ApplyOverlay(button, isActuallyUnusable)
	if not button or not button.IconTexture then
		return
	end

	if not mod or not mod.db or not mod.db.profile then
		button.IconTexture:SetVertexColor(1, 1, 1)
		return
	end

	local shouldBeRed = mod.db.profile.EnableOverlay and isActuallyUnusable
	local r, g, b = button.IconTexture:GetVertexColor()

	if shouldBeRed then
		if r ~= 1 or g ~= 0.1 or b ~= 0.1 then
			button.IconTexture:SetVertexColor(1, 0.1, 0.1)
		end
	else
		if r ~= 1 or g ~= 1 or b ~= 1 then
			button.IconTexture:SetVertexColor(1, 1, 1)
		end
	end
end-- Check if text color is red (indicating unusability)
local function isTextColorRed(textTable)
	if not textTable then return false end
	local text = textTable:GetText()
	if not text or text == "" or string.find(text, "^0 / %d+$") then return false end
	local r, g, b = textTable:GetTextColor()
	return r > 0.95 and g < 0.2 and b < 0.2
end

-- Scan tooltip for red text
function mod:ScanTooltipOfBagItemForRedText(bag, slot)
	tooltipFrame:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltipFrame:ClearLines()
	tooltipFrame:SetBagItem(bag, slot)

	for i = 1, tooltipFrame:NumLines() do
		local leftText = _G[tooltipName .. "TextLeft" .. i]
		local rightText = _G[tooltipName .. "TextRight" .. i]

		if isTextColorRed(leftText) or isTextColorRed(rightText) then
			return true
		end
	end

	return false
end-- Update button callback
function mod:UpdateButton(_, button)
	local itemID = GetContainerItemID(button.bag, button.slot)
	if not itemID then
		ApplyOverlay(button, false)
		return
	end

	if not self.db.profile.EnableOverlay then
		ApplyOverlay(button, false)
		return
	end

	local isUnusable = self:ScanTooltipOfBagItemForRedText(button.bag, button.slot)
	ApplyOverlay(button, isUnusable)
end

-- Configuration options
function mod:GetOptions()
	return {
		EnableOverlay = {
			name = L["Enable Overlay"],
			desc = L["Check this if you want overlay shown for unusable items"],
			type = "toggle",
			width = "double",
			order = 10,
			get = function() return self.db.profile.EnableOverlay end,
			set = function(_, value)
				self.db.profile.EnableOverlay = value
				if openBagCount > 0 then
					self:SendMessage('AdiBags_UpdateAllButtons')
				end
			end,
		},
	}, addon:GetOptionHandler(self)
end
