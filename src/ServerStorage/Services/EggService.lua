--//SERVICES
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local UnitsData = Knit:GetMetaData("Units")
local LootPlan = Knit:GetModule("Lootplan")
local MonetizationIds = Knit:GetModule("MonetizationIds")
--local AnalyticsModule = Knit:GetModule("AnalyticsModule")

-- // KNIT SERVICES
local DataService, UnitsService, MonetizationService, MessageService
-- // CONSTS

local EggService = Knit.CreateService({
	Name = "EggService",
	Client = {
		OnServerOpenedEgg = Knit.CreateSignal(),
		OnServerOpenedTripleEgg = Knit.CreateSignal(),
		OnServerOpenedSixEgg = Knit.CreateSignal(),
	},
})

function EggService:KnitInit() end

EggService.EggsLootPlan = {}

function EggService:KnitStart()
	DataService = Knit.GetService("DataService")
	UnitsService = Knit.GetService("UnitsService")

	MonetizationService = Knit.GetService("MonetizationService")
	MessageService = Knit.GetService("MessageService")

	for eggName, egg in UnitsData.Eggs do
		self.EggsLootPlan[eggName] = LootPlan.new()
		for petName, info in egg.List do
			self.EggsLootPlan[eggName]:AddLoot(petName, info.Chance)
			--self.Picker:Add(id, info.Chance)
		end
	end

	-- task.delay(5, function()
	-- 	local pets = {}

	-- 	for i= 1, 1000 do
	-- 		local petName = self:generatePetFromEgg(Players:GetPlayers()[1], "Egg11")


	-- 		if pets[petName] == nil then
	-- 			pets[petName] = 0
	-- 		end

	-- 		pets[petName] += 1
	-- 	end

	-- 	print(pets)
	-- end)
end

function EggService:onEggOpenRequest(player: Player, eggName: string, petsToDelete: {}, isTriple, boolean)

	if player:GetAttribute("AutoBattle") then
		return false, ""
	end
	
	if player:GetAttribute("OpeningEgg") then
		return false, ""
	end

	if eggName == nil or eggName == "" then
		return false, ""
	end

	if player:GetAttribute("InBattle") then
		return false, "You can't open an egg while fightning"
	end

	if typeof(petsToDelete) ~= "table" then
		print("Invalid input for pets to delete table")
		return false, "Invalid input for pets to delete table"
	end

	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		return false, "error"
	end

	if #dataFolder.Units.List:GetChildren() + 1 > dataFolder.Units:GetAttribute("MaxUnitsInventory") then
		return false, "Your backpack is full, delete some units to open eggs!"
	end

	local eggInfo = UnitsData:getEggInfoByName(eggName)

	if not eggInfo then
		return false, "invalid egg name."
	end

	if eggInfo.Type == "Robux" then
		return MarketplaceService:PromptProductPurchase(player, MonetizationIds.DevProducts.Eggs[eggName])
	end

	local dataFolder = DataService:GetReplicationFolder(player)

	-- if not dataFolder.Worlds.List:GetAttribute("World" .. eggInfo.World) then
	-- 	print("You don't have this world unlocked.")
	-- 	return false, "You don't have this world unlocked."
	-- end

	if not isTriple then
		if dataFolder.Data:GetAttribute("Gold") < eggInfo.Price then
			return false, "You don't have enough gold to purchase " .. eggInfo.Name
		end

		DataService:IncrementDataValueInPath(player, "Data.Gold", -eggInfo.Price)
	end

	local isDeleted = false
	local petName = self:generatePetFromEgg(player, eggName)
	local magicType

	if petsToDelete[petName] then
		isDeleted = true
	else

		local id
		local canMagic = self:_checkForMagicEgg(player)

		if canMagic then
	
			if canMagic == "Void" then
				id = UnitsService:createUnitObject(player, petName, false, true)
			elseif canMagic == "Gold" then
				id = UnitsService:createUnitObject(player, petName, true, false)
			end

			magicType = canMagic
		else
			id = UnitsService:createUnitObject(player, petName)
		end

		local equipped = UnitsService:getUnitsEquipped(player)

		if #equipped < dataFolder.Units:GetAttribute("MaxUnitsInventory") then
			UnitsService:onUnitEquipRequest(player, id)
		end

		local petInfo = UnitsData:getUnitByName(petName)

		if petInfo then
			if petInfo.Rarity.Name == "Mythic" then
				MessageService.Client.MessagePlayerChat:FireAll("[SYSTEM] " .. player.Name .. " just hatched a MYTHICAL ".. petInfo.Name, Color3.fromRGB(255, 0, 0))
			end
		end
		
	end
	
	player:SetAttribute("OpeningEgg", true)

	local delay = 4 

	if dataFolder:WaitForChild("Gamepass"):GetAttribute("InstantEggOpen") then
		delay = 2
	end

	task.delay(delay, function()
		if player then
			player:SetAttribute("OpeningEgg", false)
		end

	end)

	-- task.spawn(function()
	-- 	AnalyticsModule.DesignEvent(player, "Eggs:World" .. eggInfo.World .. ":".. eggName, 1)
	-- end)

	--self:addEggOnEggEvent(player, 1)
	return true, petName, isDeleted, magicType
end


local chanceToMagic = 10
local chanceToVoid = 10
            
function EggService:_checkForMagicEgg(player)
    
    local dataFolder = DataService:GetReplicationFolder(player)

    if not dataFolder then
        return
    end

    if dataFolder.Gamepass:GetAttribute("MagicEggs") then
        

        if chanceToMagic >= math.random(1, 100) then

			print("Magic")
		

            if math.random(1, 100) <= chanceToVoid then
                return "Void"
            else
                return "Gold"
            end
        end
    end

	return false
end



function EggService:addEggOnEggEvent(player: Player, amount)

	local folder = player:FindFirstChild("EggEvent")

	if not folder then
		return false
	end

	folder.EggsOpened.Value += amount or 1
end

function EggService:generatePetFromEgg(player, eggName)
	
	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		return
	end

    local luck = 1

    -- Verifica se o gamepass Luck está ativado
    if dataFolder.Gamepass:GetAttribute("Luck") then
        luck += 1
    end

    -- Verifica se o gamepass SuperLuck está ativado
    if dataFolder.Gamepass:GetAttribute("SuperLuck") then
        luck += 1
    end

    -- Verifica se o gamepass MegaLuck está ativado
    if dataFolder.Gamepass:GetAttribute("MegaLuck") then
        luck += 2
    end

    -- Verifica se há uma poção de sorte ativa
    if dataFolder.Potions.Timer:GetAttribute("LuckyPotion") > 0 then
        luck += 1
    end

    -- Retorna a chance multiplicada pelo valor acumulado de sorte

	if luck == 1 then
		luck = nil
	end

	local petName = self.EggsLootPlan[eggName]:GetRandomLoot(luck)

	return petName
end

function EggService:onTripleEggOpenRequest(player: Player, eggName: string, petsToDelete)

	if player:GetAttribute("OpeningEgg") then
		return false, ""
	end
	
	if typeof(petsToDelete) ~= "table" then
		print("Invalid input for pets to delete table")
		return false, "Invalid input for pets to delete table"
	end

	local eggInfo = UnitsData:getEggInfoByName(eggName)

	if not eggInfo then
		return false, "invalid egg name."
	end

	if eggInfo.Type == "Robux" then
		return MarketplaceService:PromptProductPurchase(player, MonetizationIds.DevProducts.TripleEggs[eggName])
	end
	
	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		return false, "error"
	end

	if #dataFolder.Units.List:GetChildren() + 3 > dataFolder.Units:GetAttribute("MaxUnitsInventory") then
		return false, "Your backpack is full, delete some pets to open eggs!"
	end
	
	if not dataFolder.Gamepass:GetAttribute("TripleHatch") then
		MonetizationService:PromptGamepassPurchase(player, "TripleHatch")
		return false, ""
	end

	-- if not dataFolder.Worlds.List:GetAttribute("World" .. eggInfo.World) then
	-- 	return false, "You don't have this world unlocked."
	-- end

	if dataFolder.Data:GetAttribute("Gold") < eggInfo.Price * 3 then
		return false, "You don't have enough gold to purchase " .. eggInfo.Name
	end

	DataService:IncrementDataValueInPath(player, "Data.Gold", -(eggInfo.Price * 3))

	local pets = {}

	for i = 1, 3 do
	
		local isDeleted = false
		local petName = self:generatePetFromEgg(player, eggName)
		local magicType
		if petsToDelete[petName] then
			isDeleted = true
		else

			local id
			local canMagic = self:_checkForMagicEgg(player)
	
			if canMagic then
		
				if canMagic == "Void" then
					id = UnitsService:createUnitObject(player, petName, false, true)
				elseif canMagic == "Gold" then
					id = UnitsService:createUnitObject(player, petName, true, false)
				end
	
				magicType = canMagic
			else
				id = UnitsService:createUnitObject(player, petName)
			end
	
			local equipped = UnitsService:getUnitsEquipped(player)

			if #equipped < dataFolder:WaitForChild("Units"):GetAttribute("MaxUnitsEquipped") then
				UnitsService:onUnitEquipRequest(player, id)
			end

		end
		
		pets[i] = {petName = petName, isDeleted = isDeleted, isMagic = magicType}

		local petInfo = UnitsData:getUnitByName(petName)

		if petInfo then
			if petInfo.Rarity.Name == "Mythic" then
				MessageService.Client.MessagePlayerChat:FireAll("[SYSTEM] " .. player.Name .. " just hatched a MYTHICAL ".. petInfo.Name, Color3.fromRGB(255, 0, 0))
			end
		end

	end

	player:SetAttribute("OpeningEgg", true)
	
	local delay = 4 

	if dataFolder:WaitForChild("Gamepass"):GetAttribute("InstantEggOpen") then
		delay = 2
	end

	task.delay(delay, function()
		if player then
			player:SetAttribute("OpeningEgg", false)
		end
	end)

	--self:addEggOnEggEvent(player, 3)
	return true, pets
end

function EggService.Client:OnEggOpenRequest(player: Player, eggName: string, petsToDelete: {} )
	return self.Server:onEggOpenRequest(player, eggName, petsToDelete)
end

function EggService.Client:OnTripleEggOpenRequest(player: Player, eggName: string, petsToDelete: {})
	return self.Server:onTripleEggOpenRequest(player, eggName, petsToDelete)
end

return EggService