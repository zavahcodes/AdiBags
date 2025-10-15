--[[
AdiBags_AscensionTransmog - Visual transmog indicators for AdiBags
Copyright 2024 zavahcodes
All rights reserved.

This module adds visual indicators to uncollected transmog items:
- Spinning star overlay
- Letter "T" indicator
- Configurable display modes
--]]

local addonName, addon = ...
local L = addon.L

--[[
ABOUT THIS MODULE:
This module adds visual indicators to items that haven't been collected for transmog yet.
It supports multiple display modes: spinning overlay, letter "T", or both.
Works seamlessly with Ascension WoW's appearance collection system.
--]]

local filter = addon:RegisterFilter("AscensionTransmog", 96, 'AceEvent-3.0')
filter.uiName = L['Ascension Transmog Indicators']
filter.uiDesc = L['Add visual indicators to uncollected transmog items with configurable display modes.']

local transmogOverlays = {}
local transmogLetters = {}

function filter:OnInitialize()
	self.db = addon.db:RegisterNamespace('AscensionTransmog', {
		profile = {
			enabled = true,
			transmogOwnCategory = true, -- Option to group transmog in its own category
			transmogOverlayColor = { r = 1, g = 1, b = 1, a = 0.9 }, -- Default white color
			transmogIndicatorMode = "both" -- Options: "overlay", "letter", "both"
		}
	})
end

function filter:OnEnable()
	addon:UpdateFilters()
	-- Register to update buttons like NewItemTracking does
	self:RegisterMessage('AdiBags_UpdateButton', 'UpdateButton')
end

function filter:OnDisable()
	addon:UpdateFilters()
	self:UnregisterAllMessages()
	-- Hide all indicators
	for button in pairs(transmogOverlays) do
		self:ShowTransmogIndicators(button, false)
	end
	for button in pairs(transmogLetters) do
		self:ShowTransmogIndicators(button, false)
	end
end

function filter:Filter(slotData)
	if not self.db.profile.enabled then
		return
	end

	-- Only process weapons and armor
	if not (slotData.class == "Weapon" or slotData.class == "Armor") then
		return
	end

	-- Skip Mythic+ items
	local item = GetItemInfoInstant(slotData.itemId)
	if item and item.description and (string.find(item.description, "@Mythic %d") or string.find(item.description, "@Mythic Level")) then
		return
	end

	-- Check for transmog
	if C_Appearance and slotData.subclass ~= "Thrown" and slotData.itemId ~= 5956 then
		local appearanceID = C_Appearance.GetItemAppearanceID(slotData.itemId)
		if appearanceID then
			local isCollected = C_AppearanceCollection.IsAppearanceCollected(appearanceID)
			if not isCollected then
				-- If transmogOwnCategory is enabled, use Transmog category
				if self.db.profile.transmogOwnCategory then
					return "Transmog", 'Transmog'
				end
				-- Otherwise don't return anything, let other filters categorize
			end
		end
	end
end

-- Create letter "T" indicator
local function CreateTransmogLetter(button)
	local text = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	text:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -3)
	text:SetText("T")
	text:SetTextColor(1, 1, 1, 1) -- White

	-- Add outline and bold for better visibility
	text:SetFont(text:GetFont(), 12, "OUTLINE, THICKOUTLINE")

	transmogLetters[button] = text
	return text
end

-- Create spinning overlay
local function CreateTransmogOverlay(button)
	local overlay = CreateFrame("FRAME", nil, button)
	overlay:SetFrameLevel(button:GetFrameLevel() + 15)
	overlay:SetPoint("CENTER")
	overlay:SetWidth(addon.ITEM_SIZE or 37)
	overlay:SetHeight(addon.ITEM_SIZE or 37)

	local tex = overlay:CreateTexture("OVERLAY")
	tex:SetTexture([[Interface\Cooldown\star4]])
	tex:SetBlendMode("ADD")
	tex:SetAllPoints(overlay)

	-- Use configured color from database
	local color = filter.db.profile.transmogOverlayColor
	tex:SetVertexColor(color.r, color.g, color.b, color.a)
	overlay.Texture = tex

	local group = overlay:CreateAnimationGroup()
	group:SetLooping("REPEAT")

	local anim = group:CreateAnimation("Rotation")
	anim:SetOrder(1)
	anim:SetDuration(8)
	anim:SetDegrees(360)
	anim:SetOrigin("CENTER", 0, 0)

	group:Play()

	transmogOverlays[button] = overlay
	return overlay
end

-- Show/hide transmog indicators based on mode
function filter:ShowTransmogIndicators(button, show)
	local mode = self.db.profile.transmogIndicatorMode
	local overlay = transmogOverlays[button]
	local letter = transmogLetters[button]

	if show then
		-- Show overlay if mode is "overlay" or "both"
		if mode == "overlay" or mode == "both" then
			if not overlay then
				overlay = CreateTransmogOverlay(button)
			end
			overlay:Show()
		elseif overlay then
			overlay:Hide()
		end

		-- Show letter if mode is "letter" or "both"
		if mode == "letter" or mode == "both" then
			if not letter then
				letter = CreateTransmogLetter(button)
			end
			letter:Show()
		elseif letter then
			letter:Hide()
		end
	else
		-- Hide both when not showing
		if overlay then
			overlay:Hide()
		end
		if letter then
			letter:Hide()
		end
	end
end

-- Update button callback
function filter:UpdateButton(event, button)
	if not self.db.profile.enabled then
		self:ShowTransmogIndicators(button, false)
		return
	end

	if not button.itemId then
		self:ShowTransmogIndicators(button, false)
		return
	end

	-- Create slotData as AdiBags does internally
	local slotData = {
		bag = button.bag,
		slot = button.slot,
		itemId = button.itemId,
		class = select(6, GetItemInfo(button.itemId)) or "",
		subclass = select(7, GetItemInfo(button.itemId)) or ""
	}

	local isTransmog = self:IsTransmogItem(slotData)
	self:ShowTransmogIndicators(button, isTransmog)
end

-- Helper function to check if an item is transmog
function filter:IsTransmogItem(slotData)
	if not slotData or not slotData.itemId then
		return false
	end

	-- Check if it's weapon or armor
	if not (slotData.class == "Weapon" or slotData.class == "Armor") then
		return false
	end

	-- Skip Mythic+ items
	local item = GetItemInfoInstant(slotData.itemId)
	if item and item.description and (string.find(item.description, "@Mythic %d") or string.find(item.description, "@Mythic Level")) then
		return false
	end

	-- Check transmog collection status
	if C_Appearance and slotData.subclass ~= "Thrown" and slotData.itemId ~= 5956 then
		local appearanceID = C_Appearance.GetItemAppearanceID(slotData.itemId)
		if appearanceID then
			local isCollected = C_AppearanceCollection.IsAppearanceCollected(appearanceID)
			if not isCollected then
				return true
			end
		end
	end

	return false
end

-- Update all overlay colors
function filter:UpdateAllTransmogOverlayColors()
	local color = self.db.profile.transmogOverlayColor
	for button, overlay in pairs(transmogOverlays) do
		if overlay and overlay.Texture then
			overlay.Texture:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	end
end

-- Update all indicators when mode changes
function filter:UpdateAllTransmogIndicators()
	-- Re-evaluate and update all buttons with transmog indicators
	for button in pairs(transmogOverlays) do
		if button.itemId then
			local slotData = {
				bag = button.bag,
				slot = button.slot,
				itemId = button.itemId,
				class = select(6, GetItemInfo(button.itemId)) or "",
				subclass = select(7, GetItemInfo(button.itemId)) or ""
			}
			local isTransmog = self:IsTransmogItem(slotData)
			self:ShowTransmogIndicators(button, isTransmog)
		end
	end
	for button in pairs(transmogLetters) do
		if button.itemId then
			local slotData = {
				bag = button.bag,
				slot = button.slot,
				itemId = button.itemId,
				class = select(6, GetItemInfo(button.itemId)) or "",
				subclass = select(7, GetItemInfo(button.itemId)) or ""
			}
			local isTransmog = self:IsTransmogItem(slotData)
			self:ShowTransmogIndicators(button, isTransmog)
		end
	end
end

-- Configuration options
function filter:GetFilterOptions()
	return {
		enabled = {
			name = L['Enable Transmog Indicators'],
			desc = L['Show visual indicators on uncollected transmog items.'],
			type = 'toggle',
			order = 10,
			get = function() return self.db.profile.enabled end,
			set = function(_, value)
				self.db.profile.enabled = value
				if value then
					addon:UpdateFilters()
				else
					-- Hide all indicators when disabling
					for button in pairs(transmogOverlays) do
						self:ShowTransmogIndicators(button, false)
					end
					for button in pairs(transmogLetters) do
						self:ShowTransmogIndicators(button, false)
					end
				end
			end,
		},
		transmogOwnCategory = {
			name = L['Group Transmog in Own Category'],
			desc = L["If enabled, transmog items will appear in their own 'Transmog' category. If disabled, they will appear in their normal categories but keep the visual indicator."],
			type = 'toggle',
			order = 20,
			get = function() return self.db.profile.transmogOwnCategory end,
			set = function(_, value)
				self.db.profile.transmogOwnCategory = value
				addon:UpdateFilters()
				addon:SendMessage('AdiBags_FiltersChanged', true)
			end,
		},
		transmogIndicatorMode = {
			name = L['Transmog Indicator Display'],
			desc = L['Choose how to display transmog indicators on uncollected transmog items.'],
			type = 'select',
			order = 30,
			values = {
				overlay = L["Spinning Overlay Only"],
				letter = L["Letter 'T' Only"],
				both = L["Both Overlay and Letter"]
			},
			get = function() return self.db.profile.transmogIndicatorMode end,
			set = function(_, value)
				self.db.profile.transmogIndicatorMode = value
				self:UpdateAllTransmogIndicators()
			end,
		},
		transmogOverlayColor = {
			name = L['Transmog Overlay Color'],
			desc = L['Choose the color for the transmog overlay that appears on uncollected transmog items.'],
			type = 'color',
			hasAlpha = true,
			order = 40,
			get = function()
				local color = self.db.profile.transmogOverlayColor
				return color.r, color.g, color.b, color.a
			end,
			set = function(_, r, g, b, a)
				self.db.profile.transmogOverlayColor = { r = r, g = g, b = b, a = a }
				self:UpdateAllTransmogOverlayColors()
			end,
			disabled = function()
				local mode = self.db.profile.transmogIndicatorMode
				return mode == "letter" -- Disable if only letter is shown
			end,
		},
	}, addon:GetOptionHandler(self, true)
end
