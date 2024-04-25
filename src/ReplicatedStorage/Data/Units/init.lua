local Units = {}
Units.Eggs = {}

local UnitsRarity = require(script.Parent:WaitForChild("UnitsRarity"))

Units.LimitedUnits = {

    -- ["Marmalade"] = {
    --     Name = "Marmalade",
    --     Bonus = 219.1,
    --     Chance = 0.3, -- Adjusted chance
    --     ImageId = 16971695384,
    --     Lucky = true,
    --     DisplayRarity = 0.01,
    --     Rarity = PetsRarity.Legendary
    -- }
}

for _, unit in script:GetChildren() do
	Units.Eggs[unit.Name] = require(unit)
end

Units.UnitsInfo = {}

for _, egg in Units.Eggs do

	for unit, info in egg.List do
		Units.UnitsInfo[unit] = info
	end
end

for pet, info in Units.LimitedUnits do
	Units.UnitsInfo[pet] = info
end

function Units:getUnitByName(name)
	return self.UnitsInfo[name]
	-- for _, egg in self.Eggs do

	-- 	for pet, info in egg.List do

	-- 		if pet == name then
	-- 			return info
	-- 		end

	-- 	end
	-- end

	-- for n, info in self.LimitedPets do
		
	-- 	if n == name then
	-- 		return info
	-- 	end
	-- end
end

function Units:getEggInfoByName(eggName: string)
	
	for name, egg in self.Eggs do
		if eggName == name then
			return egg
		end
	end

	return nil
end

return Units