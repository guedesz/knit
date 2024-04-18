--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS

local AnimationService = Knit.CreateService {
	Name = "AnimationService",
	Client = {
		Play = Knit.CreateSignal()
	}
}
function AnimationService:KnitInit()

end

function AnimationService:KnitStart()
	
end

return AnimationService