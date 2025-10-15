--[[
AdiBags_ItemBinding - Filter items by binding type (BoE, BoP, BoA)
Copyright 2024 zavahcodes
Based on AdiBags_Bound by Lucas Vienna (Avyiel), Lars Norberg, Spanky, and Kevin (Outroot)

This module filters items by their binding type into separate categories.
--]]

local addonName, addon = ...
local L = addon.L

--[[
ABOUT THIS MODULE:
This module categorizes items based on their binding type:
- BoE (Bind on Equip)
- BoP (Bind on Pickup/Soulbound)
- BoA (Bind on Account) - Currently disabled for WotLK
--]]

local filter = addon:RegisterFilter("ItemBinding", 70, "ABEvent-1.0")
filter.uiName = L['Item Binding']
filter.uiDesc = L['Put BoA, BoE, and BoP items in their own sections.']

-- WoW Constants
local S_ITEM_BOP = ITEM_SOULBOUND
local S_ITEM_BOE = ITEM_BIND_ON_EQUIP
local S_BOA = "BoA"
local S_BOE = "BoE"
local S_BOP = "BoP"
local N_BANK_CONTAINER = BANK_CONTAINER

-- Tooltip for scanning
local _SCANNER = "AdiBags_BindingScanner"
local Scanner = _G[_SCANNER] or CreateFrame("GameTooltip", _SCANNER, UIParent, "GameTooltipTemplate")

function filter:OnInitialize()
	self.db = addon.db:RegisterNamespace('ItemBinding', {
		profile = {
			enableBoE = true,
			grayAndWhiteBoE = false,
			enableBoA = false,
			enableBoP = false,
			onlyEquipableBoP = true,
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
	local bag, slot, quality, itemId = slotData.bag, slotData.slot, slotData.quality, slotData.itemId
	local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemId)

	-- Only parse items that are Common (1) and above, and are of type BoP, BoE, and BoU
	if (quality ~= nil and (quality > 1 or self.db.profile.grayAndWhiteBoE)) or (bindType ~= nil and bindType > 0 and bindType < 3) then
		local category = self:GetItemCategory(bag, slot)
		return self:GetCategoryLabel(category, itemId)
	end
end

function filter:GetItemCategory(bag, slot)
	local category = nil

	local function GetBindType(msg)
		if msg then
			if string.find(msg, S_ITEM_BOP) then
				return S_BOP
			elseif string.find(msg, S_ITEM_BOE) then
				return S_BOE
			end
		end
	end

	Scanner.owner = self
	Scanner.bag = bag
	Scanner.slot = slot
	Scanner:ClearLines()
	Scanner:SetOwner(UIParent, "ANCHOR_NONE")

	if bag == N_BANK_CONTAINER then
		Scanner:SetInventoryItem("player", BankButtonIDToInvSlotID(slot, nil))
	else
		Scanner:SetBagItem(bag, slot)
	end

	for i = 2, 4 do
		local line = _G[_SCANNER .. "TextLeft" .. i]
		if not line then
			break
		end
		local bind = GetBindType(line:GetText())
		if bind then
			category = bind
			break
		end
	end

	Scanner:Hide()
	return category
end

function filter:GetCategoryLabel(category, itemId)
	if not category then return nil end

	if (category == S_BOE) and self.db.profile.enableBoE then
		return L[S_BOE]
	elseif (category == S_BOA) and self.db.profile.enableBoA then
		return L[S_BOA]
	elseif (category == S_BOP) and self.db.profile.enableBoP then
		if self.db.profile.onlyEquipableBoP then
			if self:IsItemEquipable(itemId) then
				return L[S_BOP]
			end
		else
			return L[S_BOP]
		end
	end
end

function filter:IsItemEquipable(itemId)
	local itemInfo = { GetItemInfo(itemId) }
	if not itemInfo[1] then
		return false
	end

	local equipLoc = itemInfo[9] or ""
	if equipLoc == "INVTYPE_NON_EQUIP" or equipLoc == "INVTYPE_BAG" then
		return false
	elseif equipLoc:match("^INVTYPE_") then
		return true
	else
		return false
	end
end

function filter:GetFilterOptions()
	return {
		enableBoE = {
			name = L["Enable BoE"],
			desc = L["Check this if you want a section for BoE items."],
			type = "toggle",
			width = "double",
			order = 10,
			get = function() return self.db.profile.enableBoE end,
			set = function(_, value)
				self.db.profile.enableBoE = value
				self:SendMessage("AdiBags_FiltersChanged")
			end,
		},
		grayAndWhiteBoE = {
			name = L["Filter Poor/Common BoE"],
			desc = L["Also filter Poor (gray) and Common (white) quality BoE items."],
			type = "toggle",
			width = "double",
			order = 15,
			get = function() return self.db.profile.grayAndWhiteBoE end,
			set = function(_, value)
				self.db.profile.grayAndWhiteBoE = value
				self:SendMessage("AdiBags_FiltersChanged")
			end,
		},
		bound = {
			name = L["Soulbound"],
			desc = L["Soulbound item filtering options"],
			type = "group",
			inline = true,
			order = 20,
			args = {
				enableBoP = {
					name = L["Enable Soulbound"],
					desc = L["Check this if you want a section for BoP items."],
					type = "toggle",
					order = 10,
					get = function() return self.db.profile.enableBoP end,
					set = function(_, value)
						self.db.profile.enableBoP = value
						self:SendMessage("AdiBags_FiltersChanged")
					end,
				},
				onlyEquipableBoP = {
					name = L["Only Equipable"],
					desc = L["Only filter equipable soulbound items."],
					type = "toggle",
					order = 20,
					disabled = function() return not self.db.profile.enableBoP end,
					get = function() return self.db.profile.onlyEquipableBoP end,
					set = function(_, value)
						self.db.profile.onlyEquipableBoP = value
						self:SendMessage("AdiBags_FiltersChanged")
					end,
				},
			},
		},
	}, addon:GetOptionHandler(self, true)
end
