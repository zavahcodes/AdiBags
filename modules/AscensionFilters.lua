--[[
AdiBags_AscensionFilters - Ascension-specific item filters for AdiBags
Copyright 2024 zavahcodes
All rights reserved.

This module provides filters for Ascension WoW specific items including:
- Mythic+ items
- Tier Tokens
- Mystic Enchants (categorized by class)
- Tools
- Vanity items
--]]

local addonName, addon = ...
local L = addon.L

--[[
ABOUT THIS MODULE:
This module adds Ascension WoW-specific item categorization to AdiBags.
It automatically detects items unique to Ascension and groups them appropriately.
--]]

local filter = addon:RegisterFilter("AscensionFilters", 95, 'AceEvent-3.0')
filter.uiName = L['Ascension Filters']
filter.uiDesc = L['Automatically categorize items specific to Ascension WoW, including Mythic+ items, Tier Tokens, Mystic Enchants, and more.']

function filter:OnInitialize()
	self.db = addon.db:RegisterNamespace('AscensionFilters', {
		profile = {
			enabled = true,
		}
	})
end

function filter:OnEnable()
	addon:UpdateFilters()
end

function filter:OnDisable()
	addon:UpdateFilters()
end

function filter:Filter(slotData)
	if not self.db.profile.enabled then
		return
	end

	local item = GetItemInfoInstant(slotData.itemId)
	if not item then
		return
	end

	-- Mythic+ items (check both weapons/armor and other items)
	if item.description and (string.find(item.description, "@Mythic %d") or string.find(item.description, "@Mythic Level")) then
		return "Mythic+", 'Equipment'
	end

	-- Tier Tokens
	if item.description and item.inventoryType == 0 and (string.find(item.description, "This Token") or string.find(item.description, "This token")) then
		return "Tier Token", 'Equipment'
	end

	-- Mystic Enchants - categorize by class
	if item.description and string.find(item.description, "@re") then
		-- Extract class from description (format: @re:XXXXX:X@ @ClassName@)
		local className = string.match(item.description, "@re:[^@]+@ @([^@]+)@")

		if className then
			return className
		else
			return "Mystic Enchants"
		end
	end

	-- Tools - specific item IDs
	local toolIds = {
		5956, 6219, 20824, 20815, 10498, 22463, 22462, 22461,
		16207, 11145, 11130, 6339, 6218, 23821, 6954, 9149, 2901, 7005
	}

	for _, toolId in ipairs(toolIds) do
		if slotData.itemId == toolId then
			return "Tools", 'Trade Goods'
		end
	end

	-- Vanity items (quality 6)
	if slotData.quality == 6 then
		if VANITY_ITEMS and VANITY_ITEMS[slotData.itemId] and VANITY_ITEMS[slotData.itemId].itemid > 0 then
			return "Ascension"
		else
			return "Vanity"
		end
	end
end

function filter:GetFilterOptions()
	return {
		enabled = {
			name = L['Enable Ascension Filters'],
			desc = L['Enable automatic categorization of Ascension-specific items.'],
			type = 'toggle',
			order = 10,
			get = function() return self.db.profile.enabled end,
			set = function(_, value)
				self.db.profile.enabled = value
				addon:UpdateFilters()
			end,
		},
	}, addon:GetOptionHandler(self, true)
end
