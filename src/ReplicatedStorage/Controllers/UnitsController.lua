--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local DataController, AnimationController
-- // CONSTS


local UnitsController = Knit.CreateController{Name = "UnitsController"}

UnitsController.Units = {}

function UnitsController:KnitInit()

	for _, module in ReplicatedStorage:WaitForChild("src"):WaitForChild("ClientObjects"):WaitForChild("Units"):GetChildren() do
		self.Units[module.Name] = require(module)
	end

end

function UnitsController:KnitStart()
	
    DataController = Knit.GetController("DataController")
	AnimationController = Knit.GetController("AnimationController")

end

function UnitsController:loadIdleAnimation(model)
	AnimationController:play(model, "Idle")
end

function UnitsController:getEquippedUnits(player: Player)
    
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
