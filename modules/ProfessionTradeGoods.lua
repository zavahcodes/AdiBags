--[[
AdiBags - Trade Goods by Profession Filter
Separates trade goods by profession type for WoW 3.3.5
--]]

local addonName, addon = ...
local L = addon.L

-- Create the filter
local filter = addon:RegisterFilter("ProfessionTradeGoods", 85, "AceEvent-3.0")
filter.uiName = L["Trade Goods by Profession"] or "Trade Goods by Profession"
filter.uiDesc = L["Separates trade goods into sections by profession (Blacksmithing, Tailoring, Leatherworking, etc.)"] or "Separates trade goods into sections by profession (Blacksmithing, Tailoring, Leatherworking, etc.)"

-- Profession categories
local PROFESSIONS = {
    BLACKSMITHING = L["Blacksmithing"] or "Blacksmithing",
    TAILORING = L["Tailoring"] or "Tailoring",
    LEATHERWORKING = L["Leatherworking"] or "Leatherworking",
    ALCHEMY = L["Alchemy"] or "Alchemy",
    ENGINEERING = L["Engineering"] or "Engineering",
    ENCHANTING = L["Enchanting"] or "Enchanting",
    JEWELCRAFTING = L["Jewelcrafting"] or "Jewelcrafting",
    INSCRIPTION = L["Inscription"] or "Inscription",
    COOKING = L["Cooking"] or "Cooking",
    FIRST_AID = L["First Aid"] or "First Aid",
}

local TRADE_GOODS = addon.BI['Trade Goods']

-- Cache for item profession data
local itemProfessionCache = {}

-- Tooltip scanning setup
local scanTooltip = CreateFrame("GameTooltip", "AdiBagsProfessionScanTooltip", UIParent, "GameTooltipTemplate")
scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- Profession keywords in different languages (WoW 3.3.5)
local PROFESSION_PATTERNS = {
    -- English
    ["Blacksmithing"] = "BLACKSMITHING",
    ["Tailoring"] = "TAILORING",
    ["Leatherworking"] = "LEATHERWORKING",
    ["Alchemy"] = "ALCHEMY",
    ["Engineering"] = "ENGINEERING",
    ["Enchanting"] = "ENCHANTING",
    ["Jewelcrafting"] = "JEWELCRAFTING",
    ["Inscription"] = "INSCRIPTION",
    ["Cooking"] = "COOKING",
    ["First Aid"] = "FIRST_AID",
    -- Spanish
    ["Herrería"] = "BLACKSMITHING",
    ["Herreria"] = "BLACKSMITHING",
    ["Sastrería"] = "TAILORING",
    ["Sastreria"] = "TAILORING",
    ["Peletería"] = "LEATHERWORKING",
    ["Peleteria"] = "LEATHERWORKING",
    ["Alquimia"] = "ALCHEMY",
    ["Ingeniería"] = "ENGINEERING",
    ["Ingenieria"] = "ENGINEERING",
    ["Encantamiento"] = "ENCHANTING",
    ["Joyería"] = "JEWELCRAFTING",
    ["Joyeria"] = "JEWELCRAFTING",
    ["Inscripción"] = "INSCRIPTION",
    ["Inscripcion"] = "INSCRIPTION",
    ["Cocina"] = "COOKING",
    ["Primeros auxilios"] = "FIRST_AID",
    -- German
    ["Schmiedekunst"] = "BLACKSMITHING",
    ["Schneiderei"] = "TAILORING",
    ["Lederverarbeitung"] = "LEATHERWORKING",
    ["Ingenieurskunst"] = "ENGINEERING",
    ["Verzauberkunst"] = "ENCHANTING",
    ["Juwelenschleifen"] = "JEWELCRAFTING",
    ["Inschriftenkunde"] = "INSCRIPTION",
    ["Kochkunst"] = "COOKING",
    ["Erste Hilfe"] = "FIRST_AID",
    -- French
    ["Forge"] = "BLACKSMITHING",
    ["Couture"] = "TAILORING",
    ["Travail du cuir"] = "LEATHERWORKING",
    ["Alchimie"] = "ALCHEMY",
    ["Ingénierie"] = "ENGINEERING",
    ["Ingenierie"] = "ENGINEERING",
    ["Enchantement"] = "ENCHANTING",
    ["Joaillerie"] = "JEWELCRAFTING",
    ["Calligraphie"] = "INSCRIPTION",
    ["Cuisine"] = "COOKING",
    ["Secourisme"] = "FIRST_AID",
}

function filter:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            enabled = true,
            groupOthers = true,
            scanTooltips = true,
        }
    })
end

function filter:OnEnable()
    -- Clear cache when enabled
    wipe(itemProfessionCache)
end

function filter:OnDisable()
    -- Clear cache when disabled
    wipe(itemProfessionCache)
end

-- Scan item tooltip to find profession
function filter:ScanItemProfession(itemLink)
    if not self.db.profile.scanTooltips then
        return nil
    end
    
    -- Check cache first
    local itemId = addon.GetDistinctItemID(itemLink)
    if itemProfessionCache[itemId] then
        return itemProfessionCache[itemId]
    end
    
    -- Scan tooltip
    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink(itemLink)
    
    -- Check all tooltip lines
    for i = 1, scanTooltip:NumLines() do
        local line = _G["AdiBagsProfessionScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                -- Check against all profession patterns
                for pattern, profession in pairs(PROFESSION_PATTERNS) do
                    if text:find(pattern) then
                        itemProfessionCache[itemId] = profession
                        return profession
                    end
                end
            end
        end
    end
    
    -- No profession found, cache as false
    itemProfessionCache[itemId] = false
    return nil
end

-- Main filter function
function filter:Filter(slotData)
    -- Only process Trade Goods
    if slotData.class ~= TRADE_GOODS then
        return nil
    end
    
    -- Get item link
    local itemLink = slotData.link
    if not itemLink then
        return nil
    end
    
    -- Check for profession in tooltip
    local profession = self:ScanItemProfession(itemLink)
    
    if profession then
        local professionName = PROFESSIONS[profession]
        return professionName, TRADE_GOODS
    elseif self.db.profile.groupOthers then
        -- Group other trade goods together
        return L["Other Trade Goods"] or "Other Trade Goods", TRADE_GOODS
    end
    
    return nil
end

-- Configuration options
function filter:GetFilterOptions()
    return {
        enabled = {
            name = L["Enable"] or "Enable",
            desc = L["Enable profession-based trade goods filtering"] or "Enable profession-based trade goods filtering",
            type = 'toggle',
            order = 10,
        },
        scanTooltips = {
            name = L["Scan Tooltips"] or "Scan Tooltips",
            desc = L["Scan item tooltips to detect profession. Disable if you experience performance issues."] or "Scan item tooltips to detect profession. Disable if you experience performance issues.",
            type = 'toggle',
            order = 20,
        },
        groupOthers = {
            name = L["Group Other Trade Goods"] or "Group Other Trade Goods",
            desc = L["Put trade goods without a detected profession in an 'Other Trade Goods' section"] or "Put trade goods without a detected profession in an 'Other Trade Goods' section",
            type = 'toggle',
            order = 30,
        },
    }, addon:GetOptionHandler(self, true)
end
