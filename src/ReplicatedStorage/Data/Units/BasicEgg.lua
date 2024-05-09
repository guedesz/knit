local UnitsRarity = require(script.Parent.Parent:WaitForChild("UnitsRarity"))

local BasicEgg = {
    Type = "Win",
    Price = 10,
    Name = "Starter Egg",
    ImageId = 16594405488,
}

BasicEgg.List = {

    ["Maguto"] = {
        Name = "Maguto",
        Damage = 50,
        Delay = 3,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Common
    },

    ["Karurin"] = {
        Name = "Karurin",
        Damage = 10,
        Delay = 1,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Common
    },

    ["Gokoo"] = {
        Name = "Gokoo",
        Damage = 100,
        Delay = 1,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Common
    },

    ["Sookuna"] = {
        Name = "Sookuna",
        Damage = 65,
        Delay = 1,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Epic
    },

    ["Gojuu"] = {
        Name = "Gojuu",
        Damage = 25,
        Delay = 1,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Legendary
    },

    -- ["Chicken"] = {
    --     Name = "Chicken",
    --     Bonus = .65,
    --     Chance = 31, -- Adjusted chance
    --     ImageId = 16599121877,
    --     Rarity = UnitsRarity.Uncommon
    -- },

    -- ["Bat"] = {
    --     Name = "Bat",
    --     Bonus = 2.3,
    --     Chance = 20.7, -- Adjusted chance
    --     ImageId = 16597969829,
    --     Rarity = UnitsRarity.Rare
    -- },

    -- ["Tree"] = {
    --     Name = "Tree",
    --     Bonus = 9.3,
    --     Chance = .3, -- Adjusted chance
    --     ImageId = 16597972292,
    --     Lucky = true,
    --     DisplayRarity = 0.01,
    --     Rarity = UnitsRarity.Legendary
    -- }
}

return BasicEgg