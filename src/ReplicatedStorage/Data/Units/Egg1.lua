local UnitsRarity = require(script.Parent.Parent:WaitForChild("UnitsRarity"))

local Egg1 = {
    Type = "Win",
    Price = 10,
    Name = "Starter Egg",
    World = 1,
    ImageId = 16594405488,
}

Egg1.List = {

    ["Maguto"] = {
        Name = "Maguto",
        Damage = 50,
        Delay = 2,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Common
    },

    ["Karurin"] = {
        Name = "Karurin",
        Damage = 50,
        Delay = 5,
        TimeSinceLastHit = 0,
        Chance = 48, -- Adjusted chance
        ImageId = 16597971191,
        Rarity = UnitsRarity.Common
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

return Egg1