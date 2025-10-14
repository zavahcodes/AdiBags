--[[
AdiBags - Item Count Tracker
Tracks items across characters for tooltip display
Copyright 2025
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local type = _G.type
local format = _G.format
local UnitName = _G.UnitName
local GetRealmName = _G.GetRealmName
local GetMoney = _G.GetMoney
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local time = _G.time
--GLOBALS>

local mod = addon:NewModule('ItemCount', 'AceEvent-3.0', 'AceTimer-3.0')
mod.uiName = L['Item Count']
mod.uiDesc = L['Track items across characters and display counts in tooltips.']

local currentPlayer = UnitName('player')
local currentRealm = GetRealmName()

-- Helper function to get item ID from link
local function GetItemIDFromLink(link)
	if not link then return nil end
	local itemID = link:match("item:(%d+)")
	return tonumber(itemID)
end

-- Helper function to create a short item identifier
local function GetItemKey(link)
	if not link then return nil end
	-- Use just the item ID as key for simplicity
	return GetItemIDFromLink(link)
end

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

function mod:OnInitialize()
	-- Initialize database structure
	local defaults = {
		global = {
			characters = {
				['*'] = { -- [realmName.characterName]
					lastUpdate = 0,
					money = 0,
					items = {}, -- [itemID] = {bags = count, bank = count, equipped = count, guildBank = count}
				}
			}
		},
		profile = {
			enabled = true,
			showBags = true,
			showBank = true,
			showEquipped = true,
			showGuildBank = true,
			showCurrentChar = true,
			showAlts = true,
			colorByCharacter = true,
		}
	}

	self.db = addon.db:RegisterNamespace('ItemCount', defaults)
end

function mod:GetOptions()
	return {
		enabled = {
			name = L['Enable Item Count Tracking'],
			desc = L['Track and display item counts across characters in tooltips.'],
			type = 'toggle',
			width = 'full',
			order = 10,
		},
		showCurrentChar = {
			name = L['Show Current Character'],
			desc = L['Display item counts for the current character.'],
			type = 'toggle',
			disabled = function() return not self.db.profile.enabled end,
			order = 20,
		},
		showAlts = {
			name = L['Show Other Characters'],
			desc = L['Display item counts for other characters on this realm.'],
			type = 'toggle',
			disabled = function() return not self.db.profile.enabled end,
			order = 30,
		},
		locationHeader = {
			name = L['Show Locations'],
			type = 'header',
			order = 40,
		},
		showBags = {
			name = L['Bags'],
			desc = L['Show items in bags.'],
			type = 'toggle',
			disabled = function() return not self.db.profile.enabled end,
			order = 50,
		},
		showBank = {
			name = L['Bank'],
			desc = L['Show items in bank.'],
			type = 'toggle',
			disabled = function() return not self.db.profile.enabled end,
			order = 60,
		},
		showEquipped = {
			name = L['Equipped'],
			desc = L['Show equipped items.'],
			type = 'toggle',
			disabled = function() return not self.db.profile.enabled end,
			order = 70,
		},
		showGuildBank = {
			name = L['Guild Bank'],
			desc = L['Show items in guild bank (if available).'],
			type = 'toggle',
			disabled = function() return not self.db.profile.enabled end,
			order = 80,
		},
	}, addon:GetOptionHandler(self, false, false)
end

function mod:OnEnable()
	if not self.db.profile.enabled then return end

	-- Register events for tracking
	self:RegisterEvent('PLAYER_MONEY', 'UpdateMoney')
	self:RegisterEvent('BAG_UPDATE', 'OnBagUpdate')
	self:RegisterEvent('BANKFRAME_OPENED', 'OnBankOpened')
	self:RegisterEvent('PLAYERBANKSLOTS_CHANGED', 'OnBankChanged')
	self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'OnInventoryChanged')

	-- Guild Bank events (if module is enabled)
	if addon.modules.GuildBankSupport then
		self:RegisterMessage('AdiBags_BagUpdated', 'OnAdiBagsBagUpdated')
	end

	-- Initial scan
	self:ScheduleTimer('ScanCurrentCharacter', 2)

	addon:Debug('ItemCount module enabled')
end

function mod:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

function mod:UpdateMoney()
	local key = currentRealm .. "." .. currentPlayer
	self.db.global.characters[key].money = GetMoney()
end

function mod:OnBagUpdate(event, bag)
	-- Scan the specific bag
	if bag >= 0 and bag <= 4 then
		self:ScheduleTimer('ScanBags', 0.5)
	end
end

function mod:OnBankOpened()
	addon:Debug('ItemCount: Bank opened, scheduling scan')
	self:ScheduleTimer('ScanBank', 1)
end

function mod:OnBankChanged()
	self:ScheduleTimer('ScanBank', 0.5)
end

function mod:OnInventoryChanged(event, unit)
	if unit == 'player' then
		self:ScheduleTimer('ScanEquipment', 0.5)
	end
end

function mod:OnAdiBagsBagUpdated(event, bagID)
	-- Check if it's a guild bank bag (101-108)
	if addon:IsGuildBankBag(bagID) then
		self:ScheduleTimer('ScanGuildBank', 1)
	end
end

--------------------------------------------------------------------------------
-- Scanning Functions
--------------------------------------------------------------------------------

function mod:ScanCurrentCharacter()
	addon:Debug('ItemCount: Starting full character scan')
	self:ScanBags()
	self:ScanEquipment()
	self:UpdateMoney()

	local key = currentRealm .. "." .. currentPlayer
	self.db.global.characters[key].lastUpdate = time()

	addon:Debug('ItemCount: Character scan complete')
end

function mod:ScanBags()
	local key = currentRealm .. "." .. currentPlayer
	local charData = self.db.global.characters[key]

	-- Clear current bag data
	for itemID, data in pairs(charData.items) do
		data.bags = 0
	end

	-- Scan bags 0-4 (backpack + 4 bags)
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local _, count = GetContainerItemInfo(bag, slot)
			local link = GetContainerItemLink(bag, slot)
			if link then
				local itemID = GetItemIDFromLink(link)
				if itemID then
					charData.items[itemID] = charData.items[itemID] or {}
					charData.items[itemID].bags = (charData.items[itemID].bags or 0) + (count or 1)
				end
			end
		end
	end

	addon:Debug('ItemCount: Bags scanned')
end

function mod:ScanBank()
	local key = currentRealm .. "." .. currentPlayer
	local charData = self.db.global.characters[key]

	-- Clear current bank data
	for itemID, data in pairs(charData.items) do
		data.bank = 0
	end

	-- Scan main bank container (bag -1, slots 1-28)
	-- In WoW 3.3.5, bank uses BANK_CONTAINER (-1) with GetContainerItemInfo/Link
	local BANK_CONTAINER = -1
	local numBankSlots = GetContainerNumSlots(BANK_CONTAINER)
	if numBankSlots > 0 then
		for slot = 1, numBankSlots do
			local _, count = GetContainerItemInfo(BANK_CONTAINER, slot)
			local link = GetContainerItemLink(BANK_CONTAINER, slot)
			if link then
				local itemID = GetItemIDFromLink(link)
				if itemID then
					charData.items[itemID] = charData.items[itemID] or {}
					charData.items[itemID].bank = (charData.items[itemID].bank or 0) + (count or 1)
				end
			end
		end
	end

	-- Scan bank bags (5-11)
	for bag = 5, 11 do
		local numSlots = GetContainerNumSlots(bag)
		if numSlots and numSlots > 0 then
			for slot = 1, numSlots do
				local _, count = GetContainerItemInfo(bag, slot)
				local link = GetContainerItemLink(bag, slot)
				if link then
					local itemID = GetItemIDFromLink(link)
					if itemID then
						charData.items[itemID] = charData.items[itemID] or {}
						charData.items[itemID].bank = (charData.items[itemID].bank or 0) + (count or 1)
					end
				end
			end
		end
	end

	addon:Debug('ItemCount: Bank scanned')
end

function mod:ScanEquipment()
	local key = currentRealm .. "." .. currentPlayer
	local charData = self.db.global.characters[key]

	-- Clear current equipped data
	for itemID, data in pairs(charData.items) do
		data.equipped = 0
	end

	-- Scan equipment slots (1-19)
	for slot = 1, 19 do
		local link = GetInventoryItemLink('player', slot)
		if link then
			local itemID = GetItemIDFromLink(link)
			if itemID then
				local count = GetInventoryItemCount('player', slot)
				charData.items[itemID] = charData.items[itemID] or {}
				charData.items[itemID].equipped = (charData.items[itemID].equipped or 0) + (count or 1)
			end
		end
	end

	addon:Debug('ItemCount: Equipment scanned')
end

function mod:ScanGuildBank()
	if not addon.modules.GuildBankSupport then return end

	local key = currentRealm .. "." .. currentPlayer
	local charData = self.db.global.characters[key]

	-- Clear current guild bank data
	for itemID, data in pairs(charData.items) do
		data.guildBank = 0
	end

	-- Scan all guild bank tabs (101-108)
	for bagID = 101, 108 do
		if addon:IsGuildBankBag(bagID) then
			local numSlots = addon:GetGuildBankNumSlots(bagID)
			if numSlots and numSlots > 0 then
				for slot = 1, numSlots do
					local link = addon:GetGuildBankItemLink(bagID, slot)
					if link then
						local itemID = GetItemIDFromLink(link)
						if itemID then
							local _, count = addon:GetGuildBankItemInfo(bagID, slot)
							charData.items[itemID] = charData.items[itemID] or {}
							charData.items[itemID].guildBank = (charData.items[itemID].guildBank or 0) + (count or 1)
						end
					end
				end
			end
		end
	end

	addon:Debug('ItemCount: Guild Bank scanned')
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function mod:GetCharacterList()
	local chars = {}
	for fullName, data in pairs(self.db.global.characters) do
		local realm, name = fullName:match("^(.+)%.(.+)$")
		if realm == currentRealm and data.lastUpdate > 0 then
			table.insert(chars, {
				name = name,
				fullName = fullName,
				lastUpdate = data.lastUpdate,
				isCurrent = (name == currentPlayer)
			})
		end
	end

	-- Sort: current character first, then alphabetically
	table.sort(chars, function(a, b)
		if a.isCurrent then return true end
		if b.isCurrent then return false end
		return a.name < b.name
	end)

	return chars
end

function mod:GetItemCount(itemLink, characterName)
	if not itemLink then return 0, 0, 0, 0 end

	local itemID = GetItemIDFromLink(itemLink)
	if not itemID then return 0, 0, 0, 0 end

	local charKey = currentRealm .. "." .. (characterName or currentPlayer)
	local charData = self.db.global.characters[charKey]

	if not charData or not charData.items[itemID] then
		return 0, 0, 0, 0
	end

	local data = charData.items[itemID]
	return data.bags or 0, data.bank or 0, data.equipped or 0, data.guildBank or 0
end

function mod:GetTotalItemCount(itemLink)
	if not itemLink then return 0 end

	local itemID = GetItemIDFromLink(itemLink)
	if not itemID then return 0 end

	local total = 0
	for fullName, charData in pairs(self.db.global.characters) do
		local realm = fullName:match("^(.+)%..+$")
		if realm == currentRealm and charData.items[itemID] then
			local data = charData.items[itemID]
			total = total + (data.bags or 0) + (data.bank or 0) + (data.equipped or 0) + (data.guildBank or 0)
		end
	end

	return total
end

-- Cleanup old characters (optional, can be called manually)
function mod:CleanupOldData(daysOld)
	daysOld = daysOld or 30
	local cutoff = time() - (daysOld * 24 * 60 * 60)

	for fullName, data in pairs(self.db.global.characters) do
		if data.lastUpdate < cutoff then
			self.db.global.characters[fullName] = nil
			addon:Debug('ItemCount: Removed old data for', fullName)
		end
	end
end
