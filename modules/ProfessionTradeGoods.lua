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
    COOKING = L["Cooking"] or "Cooking",
    FIRST_AID = L["First Aid"] or "First Aid",
}

local TRADE_GOODS = addon.BI['Trade Goods']

-- Item name database by profession for WoW 3.3.5
local PROFESSION_ITEMS = {
    -- BLACKSMITHING (Herrería)
    BLACKSMITHING = {
        -- Bars (Barras)
        "Copper Bar", "Bronze Bar", "Silver Bar", "Iron Bar", "Gold Bar", "Mithril Bar", "Truesilver Bar",
        "Dark Iron Bar", "Thorium Bar", "Arcanite Bar", "Fel Iron Bar", "Adamantite Bar", "Eternium Bar",
        "Khorium Bar", "Hardened Adamantite Bar", "Cobalt Bar", "Saronite Bar", "Titansteel Bar", "Titanium Bar",
        -- Ore (Minerales)
        "Copper Ore", "Tin Ore", "Silver Ore", "Iron Ore", "Gold Ore", "Mithril Ore", "Truesilver Ore",
        "Dark Iron Ore", "Thorium Ore", "Fel Iron Ore", "Adamantite Ore", "Eternium Ore", "Khorium Ore",
        "Cobalt Ore", "Saronite Ore", "Titanium Ore",
        -- Stone (Piedra)
        "Rough Stone", "Coarse Stone", "Heavy Stone", "Solid Stone", "Dense Stone", "Jade", "Citrine",
        "Ruby", "Sapphire", "Diamond", "Azerothian Diamond", "Star Ruby", "Large Opal", "Blue Sapphire",
        "Black Diamond", "Arcane Crystal", "Blood of the Mountain",
        -- Flux, etc
        "Strong Flux", "Elemental Flux", "Coal", "Sulfuron Ingot", "Fiery Core", "Lava Core",
    },

    -- TAILORING (Sastrería)
    TAILORING = {
        -- Cloth (Tela)
        "Linen Cloth", "Wool Cloth", "Silk Cloth", "Mageweave Cloth", "Runecloth", "Felcloth",
        "Netherweave Cloth", "Imbued Netherweave", "Bolt of Imbued Netherweave", "Shadowcloth",
        "Spellcloth", "Primal Mooncloth", "Frostweave Cloth", "Ebonweave", "Spellweave", "Moonshroud",
        -- Thread (Hilo)
        "Coarse Thread", "Fine Thread", "Heavy Silken Thread", "Silken Thread", "Rune Thread", "Eternium Thread",
        -- Dye (Tinte)
        "Gray Dye", "Purple Dye", "Red Dye", "Yellow Dye", "Bleach", "Pink Dye", "Black Dye",
        -- Spider Silk, etc
        "Spider's Silk", "Thick Spider's Silk", "Bolt of Linen Cloth", "Bolt of Woolen Cloth",
        "Bolt of Silk Cloth", "Bolt of Mageweave", "Bolt of Runecloth", "Mooncloth", "Shadoweave Cloth",
        "Primal Nether", "Spellfire Cloth",
    },

    -- LEATHERWORKING (Peletería)
    LEATHERWORKING = {
        -- Leather (Cuero)
        "Light Leather", "Medium Leather", "Heavy Leather", "Thick Leather", "Rugged Leather",
        "Knothide Leather", "Heavy Knothide Leather", "Fel Scales", "Crystal Infused Leather",
        "Cobra Scales", "Wind Scales", "Borean Leather", "Heavy Borean Leather", "Icy Dragonscale",
        "Nerubian Chitin", "Jormungar Scale", "Arctic Fur",
        -- Scales (Escamas)
        "Green Dragonscale", "Blue Dragonscale", "Black Dragonscale", "Red Dragonscale",
        "Scorpid Scale", "Worn Dragonscale", "Pristine Hide of the Beast", "Scale of Onyxia",
        -- Hide (Piel)
        "Light Hide", "Medium Hide", "Heavy Hide", "Thick Hide", "Rugged Hide", "Devilsaur Leather",
        "Chimera Leather", "Core Leather", "Primal Tiger Leather", "Primal Bat Leather",
        "Black Whelp Scale", "Red Whelp Scale", "Deviate Scale", "Perfect Deviate Scale",
        -- Thread, Salt
        "Coarse Thread", "Fine Thread", "Heavy Silken Thread", "Silken Thread", "Deeprock Salt",
        "Refined Deeprock Salt", "Cured Leather", "Cured Medium Hide", "Cured Heavy Hide",
        "Cured Thick Hide", "Cured Rugged Hide",
    },

    -- ALCHEMY (Alquimia)
    ALCHEMY = {
        -- Herbs (Hierbas)
        "Silverleaf", "Peacebloom", "Earthroot", "Mageroyal", "Briarthorn", "Swiftthistle", "Bruiseweed",
        "Stranglekelp", "Wild Steelbloom", "Grave Moss", "Kingsblood", "Liferoot", "Fadeleaf", "Goldthorn",
        "Khadgar's Whisker", "Wintersbite", "Firebloom", "Purple Lotus", "Arthas' Tears", "Sungrass",
        "Blindweed", "Ghost Mushroom", "Gromsblood", "Golden Sansam", "Dreamfoil", "Mountain Silversage",
        "Plaguebloom", "Icecap", "Black Lotus", "Felweed", "Dreaming Glory", "Terocone", "Ancient Lichen",
        "Bloodthistle", "Mana Thistle", "Netherbloom", "Nightmare Vine", "Ragveil", "Flame Cap",
        "Adder's Tongue", "Tiger Lily", "Talandra's Rose", "Goldclover", "Icethorn", "Lichbloom",
        "Frozen Herb", "Frost Lotus",
        -- Vials (Viales)
        "Crystal Vial", "Leaded Vial", "Empty Vial", "Imbued Vial",
        -- Elemental
        "Elemental Earth", "Elemental Water", "Elemental Fire", "Elemental Air", "Essence of Earth",
        "Essence of Water", "Essence of Fire", "Essence of Air", "Heart of Fire", "Globe of Water",
        "Core of Earth", "Breath of Wind", "Living Essence", "Essence of Undeath", "Ichor of Undeath",
        "Elemental Fire", "Elemental Water", "Elemental Earth", "Elemental Air", "Mote of Earth",
        "Mote of Water", "Mote of Fire", "Mote of Air", "Mote of Life", "Mote of Shadow", "Mote of Mana",
        "Primal Earth", "Primal Water", "Primal Fire", "Primal Air", "Primal Life", "Primal Shadow",
        "Primal Mana", "Crystallized Earth", "Crystallized Water", "Crystallized Fire", "Crystallized Air",
        "Crystallized Life", "Crystallized Shadow", "Eternal Earth", "Eternal Water", "Eternal Fire",
        "Eternal Air", "Eternal Life", "Eternal Shadow", "Frozen Orb",
    },

    -- ENGINEERING (Ingeniería)
    ENGINEERING = {
        -- Explosives (Explosivos)
        "Rough Blasting Powder", "Coarse Blasting Powder", "Heavy Blasting Powder", "Solid Blasting Powder",
        "Dense Blasting Powder", "Rough Dynamite", "Coarse Dynamite", "Heavy Dynamite", "Solid Dynamite",
        "Dense Dynamite", "Big Iron Bomb", "Mithril Frag Bomb", "Hi-Explosive Bomb", "Thorium Grenade",
        "Explosive Sheep", "Goblin Land Mine", "EZ-Thro Dynamite", "Fel Iron Bomb", "Adamantite Grenade",
        "Frost Grenade", "Explosive Decoy", "Super Sapper Charge", "Cobalt Frag Bomb", "Saronite Bomb",
        -- Parts (Piezas)
        "Handful of Copper Bolts", "Copper Tube", "Rough Copper Bomb", "Bronze Tube", "Gyrochronatom",
        "Iron Strut", "Gold Power Core", "Mithril Tube", "Unstable Trigger", "Thorium Widget",
        "Arcane Bomb", "Fel Iron Casing", "Hardened Adamantite Tube", "Khorium Power Core",
        "Adamantite Frame", "Handful of Cobalt Bolts", "Volatile Blasting Trigger", "Froststeel Tube",
        -- Elemental
        "Elemental Earth", "Elemental Water", "Elemental Fire", "Elemental Air", "Essence of Earth",
        "Essence of Water", "Essence of Fire", "Essence of Air", "Elemental Blasting Powder",
    },

    -- ENCHANTING (Encantamiento)
    ENCHANTING = {
        -- Dust (Polvo)
        "Strange Dust", "Soul Dust", "Vision Dust", "Dream Dust", "Illusion Dust", "Arcane Dust",
        "Infinite Dust", "Greater Cosmic Essence", "Dream Shard",
        -- Essence (Esencia)
        "Lesser Magic Essence", "Greater Magic Essence", "Lesser Astral Essence", "Greater Astral Essence",
        "Lesser Mystic Essence", "Greater Mystic Essence", "Lesser Nether Essence", "Greater Nether Essence",
        "Lesser Eternal Essence", "Greater Eternal Essence", "Lesser Planar Essence", "Greater Planar Essence",
        "Lesser Cosmic Essence", "Greater Cosmic Essence",
        -- Shard (Fragmento)
        "Small Glimmering Shard", "Large Glimmering Shard", "Small Glowing Shard", "Large Glowing Shard",
        "Small Radiant Shard", "Large Radiant Shard", "Small Brilliant Shard", "Large Brilliant Shard",
        "Nexus Crystal", "Small Prismatic Shard", "Large Prismatic Shard", "Void Crystal", "Abyss Crystal",
        -- Crystal (Cristal)
        "Nexus Crystal", "Void Crystal", "Abyss Crystal",
        -- Rods, etc
        "Runed Copper Rod", "Runed Silver Rod", "Runed Golden Rod", "Runed Truesilver Rod",
        "Runed Arcanite Rod", "Runed Fel Iron Rod", "Runed Adamantite Rod", "Runed Eternium Rod",
        "Runed Cobalt Rod", "Runed Titanium Rod",
    },

    -- COOKING (Cocina)
    COOKING = {
        -- Meat (Carne)
        "Chunk of Boar Meat", "Stringy Wolf Meat", "Bear Meat", "Boar Ribs", "Tender Wolf Meat",
        "Stormwind Seasoning Herbs", "Goretusk Liver", "Murloc Eye", "Spider Ichor", "Crag Boar Rib",
        "Meat Cleaver", "Raw Bear Meat", "Crispy Bat Wing", "Goretusk Snout", "Bristle Whisker Catfish",
        "Mystery Meat", "Red Wolf Meat", "Bear Flank", "Raptor Egg", "Giant Egg", "Clam Meat",
        "Small Egg", "Worg Haunch", "Crawler Meat", "Coyote Meat", "Slitherskin Mackerel",
        "Longjaw Mud Snapper", "Loch Frenzy", "Rainbow Fin Albacore", "Rockscale Cod", "Spotted Yellowtail",
        "Darkclaw Lobster", "Succulent Pork Ribs", "Haunch of Meat", "Cured Ham Steak", "Wild Hog Shank",
        -- Fish (Pescado)
        "Raw Brilliant Smallfish", "Raw Slitherskin Mackerel", "Raw Longjaw Mud Snapper", "Raw Loch Frenzy",
        "Raw Rainbow Fin Albacore", "Raw Rockscale Cod", "Raw Mithril Head Trout", "Raw Redgill",
        "Raw Nightfin Snapper", "Raw Greater Sagefish", "Raw Whitescale Salmon", "Raw Sunscale Salmon",
        "Stonescale Eel", "Oily Blackmouth", "Firefin Snapper", "Raw Spotted Yellowtail", "Furious Crawdad",
        "Crescent-Tail Skullfish", "Icefin Bluefish", "Barbed Gill Trout", "Nettlefish", "Fangtooth Herring",
        "Musselback Sculpin", "Dragonfin Angelfish", "Imperial Manta Ray", "Moonglow Cuttlefish",
        "Fangtooth Herring", "Glacial Salmon", "Deep Sea Monsterbelly", "Dragonfin Angelfish",
        -- Spices (Especias)
        "Mild Spices", "Hot Spices", "Soothing Spices", "Refreshing Spring Water", "Ice Cold Milk",
        "Sweet Nectar", "Moonberry Juice", "Holiday Spices", "Alterac Swiss", "Dalaran Sharp",
        "Deeprun Rat Kabob", "Savory Deviate Delight", "Gingerbread Cookie", "Egg Nog",
    },

    -- FIRST AID (Primeros Auxilios)
    FIRST_AID = {
        -- Cloth for bandages
        "Linen Cloth", "Wool Cloth", "Silk Cloth", "Mageweave Cloth", "Runecloth", "Netherweave Cloth",
        "Frostweave Cloth",
        -- Anti-venom materials
        "Large Venom Sac", "Small Venom Sac", "Anti-Venom", "Strong Anti-Venom", "Powerful Anti-Venom",
    },
}

-- Build reverse lookup table: itemName -> profession
local itemToProfession = {}
for profession, items in pairs(PROFESSION_ITEMS) do
    for _, itemName in ipairs(items) do
        -- If an item can be used by multiple professions, prioritize the first one
        if not itemToProfession[itemName] then
            itemToProfession[itemName] = profession
        end
    end
end

function filter:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            enabled = true,
            groupOthers = true,
        }
    })
end

-- Get item name from link or slotData
function filter:GetItemName(itemLink)
    if not itemLink then return nil end
    local itemName = itemLink:match("%[(.+)%]")
    return itemName
end

-- Main filter function
function filter:Filter(slotData)
    -- Only process Trade Goods
    if slotData.class ~= TRADE_GOODS then
        return nil
    end

    -- Get item name
    local itemName = self:GetItemName(slotData.link)
    if not itemName then
        return nil
    end

    -- Check if item belongs to a profession (by name)
    local profession = itemToProfession[itemName]

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
        groupOthers = {
            name = L["Group Other Trade Goods"] or "Group Other Trade Goods",
            desc = L["Put trade goods without a detected profession in an 'Other Trade Goods' section"] or "Put trade goods without a detected profession in an 'Other Trade Goods' section",
            type = 'toggle',
            order = 10,
        },
    }, addon:GetOptionHandler(self, true)
end
