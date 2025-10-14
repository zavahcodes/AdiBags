--[[
AdiBags - Item Count Tooltip
Displays item counts in tooltips
Copyright 2025
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local pairs = _G.pairs
local format = _G.format
local GameTooltip = _G.GameTooltip
local ItemRefTooltip = _G.ItemRefTooltip
--GLOBALS>

local mod = addon:NewModule('ItemCountTooltip', 'AceEvent-3.0', 'AceHook-3.0')
mod.uiName = L['Item Count Tooltips']
mod.uiDesc = L['Display item counts from all characters in item tooltips.']

-- Color codes
local TEAL = '|cff00ff9a%s|r'
local SILVER = '|cffc7c7cf%s|r'
local YELLOW = '|cffffd100%s|r'
local WHITE = '|cffffffff%s|r'

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

local function FormatCount(bags, bank, equipped, guildBank, profile)
	local parts = {}
	local total = 0

	if profile.showBags and bags > 0 then
		table.insert(parts, format(L['%d Bags'], bags))
		total = total + bags
	end

	if profile.showBank and bank > 0 then
		table.insert(parts, format(L['%d Bank'], bank))
		total = total + bank
	end

	if profile.showEquipped and equipped > 0 then
		table.insert(parts, L['Equipped'])
		total = total + equipped
	end

	if profile.showGuildBank and guildBank > 0 then
		table.insert(parts, format(L['%d Guild Bank'], guildBank))
		total = total + guildBank
	end

	if #parts == 0 then
		return nil, 0
	end

	local details = table.concat(parts, ', ')

	-- If there are multiple locations, show total
	if #parts > 1 then
		return format(TEAL, total) .. format(SILVER, format(' (%s)', details)), total
	else
		return format(TEAL, details), total
	end
end

--------------------------------------------------------------------------------
-- Tooltip Functions
--------------------------------------------------------------------------------

local function AddItemCountsToTooltip(tooltip, itemLink)
	if not itemLink then return end

	local itemCountMod = addon:GetModule('ItemCount', true)
	if not itemCountMod or not itemCountMod:IsEnabled() or not itemCountMod.db.profile.enabled then
		return
	end

	local profile = itemCountMod.db.profile
	local characters = itemCountMod:GetCharacterList()

	if not characters or #characters == 0 then
		return
	end

	local addedHeader = false
	local grandTotal = 0

	for _, charInfo in ipairs(characters) do
		-- Skip if it's current char and we shouldn't show it
		if charInfo.isCurrent and not profile.showCurrentChar then
			-- Skip
		-- Skip if it's an alt and we shouldn't show alts
		elseif not charInfo.isCurrent and not profile.showAlts then
			-- Skip
		else
			local bags, bank, equipped, guildBank = itemCountMod:GetItemCount(itemLink, charInfo.name)
			local countString, total = FormatCount(bags, bank, equipped, guildBank, profile)

			if countString and total > 0 then
				if not addedHeader then
					tooltip:AddLine(' ') -- Spacing
					tooltip:AddLine(format(YELLOW, L['Item Count:']))
					addedHeader = true
				end

				local charName = charInfo.isCurrent and format(WHITE, charInfo.name .. ' ' .. L['(Current)']) or format(TEAL, charInfo.name)
				tooltip:AddDoubleLine(charName, countString)
				grandTotal = grandTotal + total
			end
		end
	end

	-- Add grand total if showing multiple characters
	if addedHeader and profile.showAlts and grandTotal > 0 then
		local totalChars = 0
		for _, charInfo in ipairs(characters) do
			local bags, bank, equipped, guildBank = itemCountMod:GetItemCount(itemLink, charInfo.name)
			if (bags + bank + equipped + guildBank) > 0 then
				totalChars = totalChars + 1
			end
		end

		if totalChars > 1 then
			tooltip:AddDoubleLine(format(WHITE, L['Total:']), format(YELLOW, grandTotal))
		end
	end

	tooltip:Show()
end

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

function mod:OnInitialize()
	-- No database needed, uses ItemCount module settings
end

function mod:OnEnable()
	-- Hook GameTooltip (main tooltip)
	if not self:IsHooked(GameTooltip, 'OnTooltipSetItem') then
		GameTooltip:HookScript('OnTooltipSetItem', function(tooltip)
			local _, itemLink = tooltip:GetItem()
			if itemLink then
				AddItemCountsToTooltip(tooltip, itemLink)
			end
		end)
	end

	-- Hook ItemRefTooltip (chat link tooltip)
	if not self:IsHooked(ItemRefTooltip, 'OnTooltipSetItem') then
		ItemRefTooltip:HookScript('OnTooltipSetItem', function(tooltip)
			local _, itemLink = tooltip:GetItem()
			if itemLink then
				AddItemCountsToTooltip(tooltip, itemLink)
			end
		end)
	end

	addon:Debug('ItemCountTooltip module enabled')
end

function mod:OnDisable()
	-- Unhook tooltips
	if self:IsHooked(GameTooltip, 'OnTooltipSetItem') then
		self:Unhook(GameTooltip, 'OnTooltipSetItem')
	end

	if self:IsHooked(ItemRefTooltip, 'OnTooltipSetItem') then
		self:Unhook(ItemRefTooltip, 'OnTooltipSetItem')
	end
end
