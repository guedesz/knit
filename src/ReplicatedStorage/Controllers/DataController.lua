--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))

--//OBJECTS

-- // KNIT SERVICES

-- // CONSTS


local DataController = Knit.CreateController{
	Name = "DataController",
}

function DataController:KnitInit()

end


function DataController:KnitStart()
	
end

function DataController:GetReplicationFolder(player)

	if not player then
		player = Knit.LocalPlayer 
	end

	return player:FindFirstChild("_replicationFolder") or player:WaitForChild("_replicationFolder", 10)
	
end

return DataController
