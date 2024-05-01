--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local DataController, AnimationController, UnitsService, UIController, TycoonController
-- // CONSTS

local UnitsController = Knit.CreateController({ Name = "UnitsController" })

UnitsController.Units = {}

function UnitsController:KnitInit() end

for _, module in ReplicatedStorage:WaitForChild("src"):WaitForChild("ClientObjects"):WaitForChild("Units"):GetChildren() do
	UnitsController.Units[module.Name] = require(module)
end

function UnitsController:KnitStart()
	DataController = Knit.GetController("DataController")
	AnimationController = Knit.GetController("AnimationController")
	UnitsService = Knit.GetService("UnitsService")
	UIController = Knit.GetController("UIController")
	TycoonController = Knit.GetController("TycoonController")

	UnitsService.OnUnitEquipped:Connect(function(player, id, unitName)
		self:onUnitEquipped(player, id, unitName)
	end)

	UnitsService.OnUnitUnequipped:Connect(function(player, id)
		self:onUnitUnquipped(player, id)
	end)

	UnitsService.OnUnitRemoved:Connect(function(player)
		self:onUnitRemoved(player)
	end)
end

function UnitsController:onUnitRemoved(player)
	local unitsGui = UIController:GetGuiController("Units")

	if not unitsGui then
		return warn("error getting units gui")
	end

	unitsGui:loadInventory()
end

function UnitsController:onUnitEquipped(player, id, unitName)
	if player == Knit.LocalPlayer then
		local unitsGui = UIController:GetGuiController("Units")

		if not unitsGui then
			return warn("error getting units gui")
		end

		unitsGui:onEquipped(id)
	end

	local tycoonObject = TycoonController:getTycoonByPlayer(player)

	if not tycoonObject then
		return
	end

	if tycoonObject.Units[id] then
		return
	end

	tycoonObject:loadUnit(id)
end

function UnitsController:onUnitUnquipped(player, id)
	if player == Knit.LocalPlayer then
		local unitsGui = UIController:GetGuiController("Units")

		if not unitsGui then
			return warn("error getting units gui")
		end

		unitsGui:onUnquipped(id)
	end

	local tycoonObject = TycoonController:getTycoonByPlayer(player)

	if not tycoonObject then
		return
	end

	if tycoonObject.Units[id] then
		tycoonObject:removeUnit(id)
	end
end

function UnitsController:loadIdleAnimation(model)
	AnimationController:play(model, "Idle")
end

function UnitsController:getEquippedUnits(player: Player)
	if not DataController then
		DataController = Knit.GetController("DataController")
	end

	local dataFolder = DataController:GetReplicationFolder(player)

	if not dataFolder then
		return warn("error getting data folder for get equipped units", player)
	end

	local ids = {}

	for id, folder in dataFolder:WaitForChild("Units"):WaitForChild("Equippeds"):GetChildren() do
		table.insert(ids, folder.Name)
	end

	return ids
end

function UnitsController:getUnitObjectById(player, id)
	local dataFolder = DataController:GetReplicationFolder(player)

	if not dataFolder then
		return warn("error getting data folder while get unit object by id")
	end

	local object = dataFolder:WaitForChild("Units"):WaitForChild("List"):FindFirstChild(id)

	if not object then
		return warn("error getting unit object")
	end

	return object
end
return UnitsController
