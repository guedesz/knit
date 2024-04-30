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

-- // KNIT SERVICES
local DataService, DamageService
-- // CONSTS

local UnitsService = Knit.CreateService {
	Name = "UnitsService",
	Client = {
		OnUnitReleaseSkill = Knit.CreateSignal(),
		OnUnitEquipped = Knit.CreateSignal(),
		OnUnitUnequipped = Knit.CreateSignal(),
		OnUnitRemoved = Knit.CreateSignal(),
		OnNewUnitCreated = Knit.CreateSignal(),
	}
}

function UnitsService:KnitInit()

end

function UnitsService:KnitStart()

	DataService = Knit.GetService("DataService")
	DamageService = Knit.GetService("DamageService")

	Players.PlayerAdded:Connect(function(player)
		task.wait(1)
		local id = self:createUnitObject(player, "Karurin")
		self:onUnitEquipRequest(player, id)
		self:createServerObjectUnit(player, id)

		local id = self:createUnitObject(player, "Maguto")
		self:onUnitEquipRequest(player, id)
		self:createServerObjectUnit(player, id)

		local id = self:createUnitObject(player, "Karurin")
		self:onUnitEquipRequest(player, id)
		self:createServerObjectUnit(player, id)
		-- local id = self:createUnitObject(player, "Goko")
		-- self:onUnitEquipRequest(player, id)
		-- self:createServerObjectUnit(player, id)

		-- local id = self:createUnitObject(player, "Maguto")
		-- self:onUnitEquipRequest(player, id)
		-- self:createServerObjectUnit(player, id)
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

				print(unit.Name .. " releasing hit")

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
	DataService:AppendTableToProfileInPath(player, "Units.List", { Name = unitName, isGolden = isGolden or false, isVoid = isVoid or false}, id)

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

function UnitsService:onUnitEquipRequest(player: Player, id: string)

	if id == nil then
		return false, "no id found"
	end

	if not self:getUnitObjectById(player, id) then
		print("no object found with id")
		return false, "no object found with id"
	end

	local dataFolder = DataService:GetReplicationFolder(player)

	local maxEquipped = dataFolder.Units:GetAttribute("MaxUnitsEquipped")

	local equippeds = self:getUnitsEquipped(player)

	if #equippeds >= maxEquipped then
		return false, "You can equip more than ".. maxEquipped .. " units!"
	end

	if table.find(equippeds, id) then
		print("unit is already equipped!")
		return false, "Unit is already equipped!"
	end

	--self.Client.OnPetEquipped:Fire(player, id, object:GetAttribute("Name"))

	DataService:AppendTableToProfileInPath(player, "Units.Equippeds", { id }, id)

end


return UnitsService