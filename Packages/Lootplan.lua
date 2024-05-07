-- Original Module can be found at - roblox.com/library/4710697524/LootPlan
-- API Documentation can be found at - https://devforum.roblox.com/t/lootplan-random-loot-generation-made-easy/463702
-- Two example scripts can be found within the explorer, inside this module
--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

local PetsData = Knit:GetMetaData("Units")

local LootPlan = {}

--> SingleLootPlan Class <--

local SingleLootPlan = {}
SingleLootPlan.__index = SingleLootPlan

function SingleLootPlan.new(seed)
	local SingleLootPlan = setmetatable({}, SingleLootPlan)
	SingleLootPlan.Randomizer = Random.new(seed or (tick() % 1) * 1e10)
	SingleLootPlan.Loot = {}
	SingleLootPlan.LootList = {}
	SingleLootPlan.LootCount = 0
	SingleLootPlan.TotalChance = 0
	return SingleLootPlan
end

function SingleLootPlan:_updateLootList()
	local LootList = {}

	for Name, Loot in self.Loot do
		table.insert(LootList, Loot)
	end

	table.sort(LootList, function(a, b)
		return a.chance < b.chance
	end)

	self.LootList = LootList
end

function SingleLootPlan:AddLoot(name, chance)
	local newLoot = {
		name = name,
		chance = chance,
	}
	
	self.Loot[name] = newLoot
	self.LootCount += 1
	self.TotalChance += chance
	self:_updateLootList()
	return newLoot
end

function SingleLootPlan:AddLootFromTable(Table)
	for name, chance in Table do
		self:AddLoot(name, chance)
	end
	return self
end

function SingleLootPlan:GetLootChance(name)
	local loot = self.Loot[name]
	if loot then
		return loot.chance
	else
		error("Loot with name '" .. tostring(name) .. "' does not exist")
	end
end

function SingleLootPlan:GetTrueLootChance(name)
	local loot = self.Loot[name]
	if loot then
		return (loot.chance / self.TotalChance) * 100
	else
		error("Loot with name '" .. tostring(name) .. "' does not exist")
	end
end

function SingleLootPlan:RemoveLoot(name)
	local loot = self.Loot[name]
	if loot then
		self.TotalChance -= loot.chance
		self.LootCount -= 1
		self.Loot[name] = nil
		self:_updateLootList()
	end
end

function SingleLootPlan:ChangeLootChance(name, chance)
	local loot = self.Loot[name]
	if loot then
		self.TotalChance += chance - loot.chance
		loot.chance = chance
		self:_updateLootList()
		return loot
	else
		error("Loot with name '" .. tostring(name) .. "' does not exist")
	end
end

function SingleLootPlan:GetRandomLoot(luck)

	local luck = luck or 1
	if luck > 1 then
		local result = self.Randomizer:NextNumber()
		local aggregate = 0
		for i, loot in self.LootList do

			local petInfo = PetsData:getUnitByName(loot.name)

            if not petInfo then
                print("error", loot.name)
                continue
            end

            local chance = loot.chance
            if petInfo.Lucky then
                chance = chance * luck  -- Increase chance for lucky pets (adjust multiplier as needed)
            end

            aggregate += chance
            if result < (chance + aggregate) / self.TotalChance then
                return loot.name
            end
			
		end
	else
		local luck = 1 / luck
		local result = self.Randomizer:NextNumber()
		local aggregate = 0
		for i = self.LootCount, 1, -1 do
			local loot = self.LootList[i]
			local chance = loot.chance * luck
			if result < (chance + aggregate) / self.TotalChance then
				return loot.name
			end
			aggregate += chance
		end
	end
end

--> MultiLootPlan Class <--

local MultiLootPlan = {}
MultiLootPlan.__index = MultiLootPlan

function MultiLootPlan.new(seed)
	local MultiLootPlan = setmetatable({}, MultiLootPlan)
	MultiLootPlan.Randomizer = Random.new(seed or (tick() % 1) * 1e10)
	MultiLootPlan.Loot = {}
	return MultiLootPlan
end

function MultiLootPlan:AddLoot(name, chance)
	local newLoot = {
		name = name,
		chance = chance,
	}
	self.Loot[name] = newLoot
	return newLoot
end

function MultiLootPlan:AddLootFromTable(Table)
	for name, chance in Table do
		self:AddLoot(name, chance)
	end
end

function MultiLootPlan:GetLootChance(name)
	local loot = self.Loot[name]
	if loot then
		return loot.chance
	else
		error("Loot with name '" .. tostring(name) .. "' does not exist")
	end
end

function MultiLootPlan:RemoveLoot(name)
	self.Loot[name] = nil
end

function MultiLootPlan:ChangeLootChance(name, newChance)
	local loot = self.Loot[name]
	if loot then
		loot.chance = newChance
	else
		error("Loot with name '" .. tostring(name) .. "' does not exist")
	end
end

function MultiLootPlan:GetRandomLoot(iterations, luck) -- iterations optional, defaults to 1 when not provided
	local LootTable = {}
	for i = 1, iterations or 1 do
		for name, loot in self.Loot do
			local result = self.Randomizer:NextNumber()
			local chance = (loot.chance / 100) * (luck or 1)
			if result < chance then
				LootTable[name] = LootTable[name] and LootTable[name] + 1 or 1
			end
		end
	end
	return LootTable
end

--> LootPlan Creator <--

function LootPlan.new(class, seed)
	if class == "multi" then
		return MultiLootPlan.new(seed)
	else -- Class defaults to single when no class provided
		return SingleLootPlan.new(seed)
	end
end

return LootPlan
