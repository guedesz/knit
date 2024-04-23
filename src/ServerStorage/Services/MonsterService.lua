--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS

local MonsterService = Knit.CreateService {
	Name = "MonsterService",
	Client = {
		OnTakeDamage = Knit.CreateSignal(),
		OnMonsterKilled = Knit.CreateSignal(),
	}
}
function MonsterService:KnitInit()

end

function MonsterService:KnitStart()
	
end

return MonsterService