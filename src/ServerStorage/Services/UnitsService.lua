--//SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local UnitsData = Knit:GetMetaData("Units")
local Unit = Knit:GetModule("Unit")
local GoldMachineData = Knit:GetMetaData("GoldMachine")
local VoidMachineData = Knit:GetMetaData("VoidMachine")

-- // KNIT SERVICES
local DataService, DamageService
-- // CONSTS

local UnitsService = Knit.CreateService({
	Name = "UnitsService",
	Client = {
		OnUnitReleaseSkill = Knit.CreateSignal(),
		OnUnitEquipped = Knit.CreateSignal(),
		OnUnitUnequipped = Knit.CreateSignal(),
		OnUnitRemoved = Knit.CreateSignal(),
		OnNewUnitCreated = Knit.CreateSignal(),
	},
})

function UnitsService:KnitInit() end

function UnitsService:KnitStart()
	DataService = Knit.GetService("DataService")
	DamageService = Knit.GetService("DamageService")

	Players.PlayerAdded:Connect(function(player)
		task.wait(1)
		local id = self:createUnitObject(player, "Karurin")
		local id = self:createUnitObject(player, "Maguto")
		local id = self:createUnitObject(player, "Karurin")
		local id = self:createUnitObject(player, "Gokoo")
		local id = self:createUnitObject(player, "Gokoo")

	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:onPlayerRemoving(player)
	end)

	-- handle units releasing hits
	RunService.Heartbeat:Connect(function(deltaTime)
		for i, unit in UnitsData.UnitsInfo do
			unit.TimeSinceLastHit += deltaTime

			if unit.TimeSinceLastHit >= unit.Delay then
				unit.TimeSinceLastHit = 0

				--print(unit.Name .. " releasing hit")

				self.Client.OnUnitReleaseSkill:FireAll(unit.Name)

				if Unit.Objects[unit.Name] then
					for _, unit in Unit.Objects[unit.Name] do
						unit:takeDamage()
					end
				end
			end
		end
	end)
end

function UnitsService:onPlayerRemoving(player: Player)
	if Unit.Objects[player] then
		for _, unit in Unit.Objects[player] do
			unit:destroy()
		end
	end
end

function UnitsService:createUnitObject(player: Player, unitName: string, isGolden, isVoid, isHuge)
	local unitInfo = UnitsData:getUnitByName(unitName)

	if not unitInfo then
		return print("error getting pet info for name: ", unitName)
	end

	local id = "P-" .. player.UserId .. HttpService:GenerateGUID(false)
	DataService:AppendTableToProfileInPath(
		player,
		"Units.List",
		{ Name = unitName, isGolden = isGolden or false, isVoid = isVoid or false },
		id
	)

	--self:CheckUnlockedPet(player, petName)

	self.Client.OnNewUnitCreated:Fire(player, id, unitName)

	return id
end

function UnitsService:getUnitObjectById(player: Player, id: string)
	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		return warn("error getting data folder while get unit object by id")
	end

	local object = dataFolder:WaitForChild("Units"):WaitForChild("List"):FindFirstChild(id)

	if not object then
		return warn("error getting unit object")
	end

	return object
end

function UnitsService:getUnitsEquipped(player: Player)
	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		return warn("data folder error getting units equipped")
	end

	local ids = {}

	for id, folder in dataFolder:WaitForChild("Units"):WaitForChild("Equippeds"):GetChildren() do
		table.insert(ids, folder.Name)
	end

	return ids
end

function UnitsService:createServerObjectUnit(player: player, id: string)
	local object = self:getUnitObjectById(player, id)

	if not object then
		return warn("error getting object, invalid id")
	end

	if Unit.Objects[player] and Unit.Objects[player][id] then
		return warn("server object already exist with given id")
	end

	Unit.new(player, object:GetAttribute("Name"), id, DamageService)
end

function UnitsService:removeServerObjectUnit(player: Player, id: string)
	local object = self:getUnitObjectById(player, id)

	if not object then
		return warn("error getting object, invalid id")
	end

	if Unit.Objects[player] and Unit.Objects[player][id] then
		Unit.Objects[player][id]:destroy()
	end
end

function UnitsService:onUnitEquipRequest(player: Player, id: string)
	if id == nil then
		return false, "no id found"
	end

	local object = self:getUnitObjectById(player, id)
	if not object then
		print("no object found with id")
		return false, "no object found with id"
	end

	local dataFolder = DataService:GetReplicationFolder(player)

	local maxEquipped = dataFolder.Units:GetAttribute("MaxUnitsEquipped")

	local equippeds = self:getUnitsEquipped(player)

	if #equippeds >= maxEquipped then
		return false, "You can equip more than " .. maxEquipped .. " units!"
	end

	if table.find(equippeds, id) then
		print("unit is already equipped!")
		return false, "Unit is already equipped!"
	end

	self:createServerObjectUnit(player, id)

	DataService:AppendTableToProfileInPath(player, "Units.Equippeds", { id }, id)
	self.Client.OnUnitEquipped:FireAll(player, id)

	return true
end

function UnitsService:onUnitUnquipRequest(player, id)
	local object = self:getUnitObjectById(player, id)

	if not object then
		return false, "something went wrong. [pet unequip request]"
	end

	if not table.find(self:getUnitsEquipped(player), id) then
		print("Pet is not equipped!")
		return false, "Pet is not equipped!"
	end

	self:removeServerObjectUnit(player, id)

	--StrengthService.Client.OnBonusChanged:Fire(player)
	DataService:DeleteDataValueInPath(player, "Units.Equippeds." .. object.Name)

	self.Client.OnUnitUnequipped:FireAll(player, id)

	return true
end

function UnitsService:onUnquipAllRequest(player: Player)
	local equipped = self:getUnitsEquipped(player)

	if not equipped then
		return false, ""
	end

	for _, petId in equipped do
		self:onUnitUnquipRequest(player, petId)
	end

	return true
end

function UnitsService:onEquipBestRequest(player: Player)
	if not self:onUnquipAllRequest(player) then
		return false, ""
	end

	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		return false, "[something went wrong. [data folder equip best request]"
	end

	local allPets = dataFolder:WaitForChild("Units").List:GetChildren()
	local maxSlots = dataFolder.Units:GetAttribute("MaxUnitsEquipped")

	local petsToEquip = {}
	local sortedPets = {}

	for _, pet in allPets do
		local petName = pet:GetAttribute("Name")
		local data = UnitsData:getUnitByName(petName)

		if not data then
			warn("Error getting data for unit, ", petName)
			continue
		end

		local bonus = data.Damage
		if pet:GetAttribute("isGolden") then
			bonus *= GoldMachineData.MULTIPLIER_GOLD_PET
		end

		if pet:GetAttribute("isVoid") then
			bonus *= VoidMachineData.MULTIPLIER_GOLD_PET
		end

		sortedPets[#sortedPets + 1] = { Object = pet, Power = bonus }
	end

	table.sort(sortedPets, function(a, b)
		return a.Power > b.Power
	end)

	for i = 1, maxSlots do
		if sortedPets[i] == nil then
			continue
		end

		self:onUnitEquipRequest(player, tostring(sortedPets[i].Object.Name))
	end

	sortedPets = nil

	return true
end

function UnitsService.Client:OnUnquipAllRequest(player: Player)
	return self.Server:onUnquipAllRequest(player)
end

function UnitsService.Client:OnUnitEquipRequest(player: Player, id: string)
	return self.Server:onUnitEquipRequest(player, id)
end

function UnitsService.Client:OnUnitUnquipRequest(player: Player, id: string)
	return self.Server:onUnitUnquipRequest(player, id)
end

function UnitsService.Client:OnEquipBestRequest(player: Player)
	return self.Server:onEquipBestRequest(player)
end

return UnitsService
