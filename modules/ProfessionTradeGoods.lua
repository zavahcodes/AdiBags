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

-- Item ID database by profession for WoW 3.3.5
local PROFESSION_ITEMS = {
    -- BLACKSMITHING (Herrería)
    BLACKSMITHING = {
        -- Bars (Barras)
        2840, 2841, 2842, 3575, 3576, 3577, 3859, 3860, 6037, 11371, 12359, 12360, 12361, 12655, 17771, 23445, 23446, 23447, 23448, 36913, 36916, 37663,
        -- Ore (Minerales)
        2770, 2771, 2772, 3858, 10620, 23424, 23425, 36909, 36910, 36912,
        -- Stone (Piedra)
        2835, 2836, 2838, 7912, 12363, 12364, 12365, 12799, 12800, 18240,
        -- Flux, etc
        3466, 3478, 3486, 6260, 17060, 17202, 23436, 23437,
    },
    
    -- TAILORING (Sastrería)
    TAILORING = {
        -- Cloth (Tela)
        2589, 2592, 4305, 4306, 14047, 14048, 21840, 21841, 33470, 41510, 41511,
        -- Thread (Hilo)
        2320, 2321, 4291, 8343, 14341, 38426,
        -- Dye (Tinte)
        2324, 2325, 2604, 4340, 4341, 4342, 6260, 6261, 8343, 10290,
        -- Spider Silk, etc
        4291, 4305, 8343, 14227, 14256, 21840, 21842, 21844, 21845, 38426,
    },
    
    -- LEATHERWORKING (Peletería)
    LEATHERWORKING = {
        -- Leather (Cuero)
        2318, 2319, 4231, 4234, 4235, 4236, 4304, 8170, 8171, 15407, 15408, 15409, 15410, 15412, 15414, 15415, 15416, 15417, 17012, 25649, 25699, 25700, 29539, 29547, 29548, 33567, 33568, 38425, 44128,
        -- Scales (Escamas)
        5498, 5500, 7286, 7392, 8154, 8165, 8167, 8168, 15408, 15410, 15412, 15414, 15415, 15416, 15417, 15419, 17012, 25699, 25700, 29539, 29547, 29548,
        -- Hide (Piel)
        783, 2318, 2319, 4232, 4233, 4234, 4235, 4236, 4304, 5082, 5116, 5784, 7428, 7429, 8169, 8170, 8171, 17012, 25649, 29547, 29548, 33567, 33568, 38425, 44128,
        -- Thread, Salt
        2320, 2321, 3182, 3824, 4289, 4291, 6260, 14341,
    },
    
    -- ALCHEMY (Alquimia)
    ALCHEMY = {
        -- Herbs (Hierbas)
        765, 785, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 8831, 8836, 8838, 8839, 8845, 8846, 13463, 13464, 13465, 13466, 13467, 13468, 22785, 22786, 22787, 22788, 22789, 22790, 22791, 22792, 22793, 36901, 36903, 36904, 36905, 36906, 36907, 37921, 39970,
        -- Lotus
        8153, 13468,
        -- Vials (Viales)
        3371, 3372, 8925, 18256,
        -- Elemental
        7067, 7068, 7069, 7070, 7071, 7072, 7075, 7076, 7077, 7078, 7079, 7080, 7081, 7082, 12803, 12808, 21884, 21886, 22452, 22451, 35622, 35623, 35624, 35625, 35627, 36860, 37700, 37701, 37702, 37703, 37704, 37705,
    },
    
    -- ENGINEERING (Ingeniería)
    ENGINEERING = {
        -- Explosives (Explosivos)
        4358, 4359, 4360, 4361, 4362, 4363, 4364, 4365, 4366, 4367, 4368, 4369, 4370, 4371, 4377, 4378, 4380, 4382, 4384, 4387, 4389, 4390, 4394, 4404, 10505, 10560, 10561, 10562, 15992, 15994, 16000, 16006, 18631, 21557, 23781, 23782, 23783, 23784, 23785, 23786, 23787, 39682,
        -- Parts (Piezas)
        814, 1206, 1210, 1705, 2589, 2592, 3470, 3471, 3575, 4306, 4337, 4338, 4339, 4340, 4341, 4342, 4375, 4377, 4382, 4384, 4387, 4389, 4404, 7191, 7387, 10558, 10559, 10560, 10561, 12359, 12361, 15992, 15994, 16000, 16006, 18631, 21557, 23077, 23079, 23781, 23782, 23783, 23784, 23785, 23786, 32423,
        -- Elemental
        7067, 7068, 7069, 7070, 7071, 7072, 7075, 7076, 7077, 7078, 7079, 7080, 7081, 7082, 12803, 12808,
    },
    
    -- ENCHANTING (Encantamiento)
    ENCHANTING = {
        -- Dust (Polvo)
        10940, 10998, 11083, 11137, 11176, 16204, 34054, 34055, 34056,
        -- Essence (Esencia)
        10938, 10939, 10978, 10998, 11082, 11084, 11134, 11135, 11174, 11175, 16202, 16203, 34052, 34053, 34055, 34056, 34057,
        -- Shard (Fragmento)
        10978, 11084, 11138, 11139, 14343, 14344, 16204, 22449, 22450, 34052, 34053, 34054, 34055, 34056, 34057,
        -- Crystal (Cristal)
        11174, 11175, 20725, 22448, 22449, 22450,
        -- Rods, etc
        6218, 11128, 11144, 11145, 16202, 16203, 16204, 16206, 16207, 17725, 18240, 22461, 22462, 22463, 38682, 38929,
    },
    
    -- JEWELCRAFTING (Joyería)
    JEWELCRAFTING = {
        -- Raw Gems (Gemas en bruto)
        23077, 23079, 23107, 23112, 23117, 23436, 23437, 23438, 23439, 23440, 23441, 36917, 36918, 36919, 36920, 36921, 36922, 36923, 36924, 36925, 36926, 36927, 36928, 36929, 36930, 36931, 36932, 36933, 37700, 37701, 37702, 37703, 37704, 37705, 41163,
        -- Ore for prospecting
        2770, 2771, 2772, 3858, 10620, 23424, 23425, 36909, 36910, 36912,
        -- Gems cut
        -- Note: Cut gems are not trade goods, they're gems
    },
    
    -- INSCRIPTION (Inscripción)
    INSCRIPTION = {
        -- Herbs (for milling)
        765, 785, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 8831, 8836, 8838, 8839, 8845, 8846, 13463, 13464, 13465, 13466, 13467, 13468, 22785, 22786, 22787, 22788, 22789, 22790, 22791, 22792, 22793, 36901, 36903, 36904, 36905, 36906, 36907, 37921, 39970,
        -- Inks (Tintas)
        37101, 39151, 39334, 39338, 39339, 39340, 39341, 39342, 39343, 39469, 39774, 43116, 43117, 43118, 43119, 43120, 43121, 43122, 43123, 43124, 43125, 43126, 43127,
        -- Pigments (Pigmentos)
        39151, 39334, 39338, 39339, 39340, 39341, 39342, 39343, 39469, 39774, 43103, 43104, 43105, 43106, 43107, 43108, 43109,
        -- Parchment (Pergamino)
        38682, 39354,
    },
    
    -- COOKING (Cocina)
    COOKING = {
        -- Meat (Carne)
        769, 1015, 1080, 2251, 2672, 2673, 2674, 2675, 2677, 2886, 3173, 3404, 5465, 5466, 5467, 5468, 5469, 5470, 5471, 5503, 5504, 6289, 6291, 6303, 6308, 6317, 6889, 9681, 12037, 12184, 12202, 12203, 12204, 12205, 12206, 12207, 12208, 21071, 27422, 27425, 27429, 27435, 27437, 27438, 27439, 27516, 27668, 33048, 35562, 35563, 43009, 43010, 43011, 43012, 43013,
        -- Fish (Pescado)
        4603, 4655, 5503, 5504, 6289, 6291, 6303, 6308, 6317, 6889, 8365, 12184, 13754, 13755, 13756, 13757, 13758, 13759, 13760, 13888, 13889, 13890, 13893, 21071, 21153, 27422, 27425, 27429, 27435, 27437, 27438, 27439, 27516, 33048, 35562, 35563, 41800, 41801, 41802, 41803, 41805, 41806, 41807, 41808, 41809, 41810, 41812, 41813, 41814,
        -- Spices (Especias)
        2321, 2324, 2325, 2604, 2605, 2678, 2692, 2723, 2724, 2725, 2771, 3182, 3404, 3466, 3713, 3827, 4289, 4399, 4400, 4402, 4404, 5469, 6889, 8150, 8153, 8831, 17194, 17196, 17197, 21153, 30817,
    },
    
    -- FIRST AID (Primeros Auxilios)
    FIRST_AID = {
        -- Cloth for bandages
        2589, 2592, 4305, 4306, 14047, 14048, 21840, 21841, 33470, 41510, 41511,
        -- Anti-venom materials
        3383, 3384, 5996, 6371,
    },
}

-- Build reverse lookup table: itemID -> profession
local itemToProfession = {}
for profession, items in pairs(PROFESSION_ITEMS) do
    for _, itemID in ipairs(items) do
        -- If an item can be used by multiple professions, prioritize the first one
        if not itemToProfession[itemID] then
            itemToProfession[itemID] = profession
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

-- Get item ID from link or slotData
function filter:GetItemID(itemLink)
    if not itemLink then return nil end
    local itemID = tonumber(itemLink:match("item:(%d+)"))
    return itemID
end

-- Main filter function
function filter:Filter(slotData)
    -- Only process Trade Goods
    if slotData.class ~= TRADE_GOODS then
        return nil
    end

    -- Get item ID
    local itemID = self:GetItemID(slotData.link)
    if not itemID then
        return nil
    end

    -- Check if item belongs to a profession
    local profession = itemToProfession[itemID]
    
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
