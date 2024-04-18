--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS

local Service = Knit.CreateService {
	Name = "Service",
	Client = {
	}
}
function Service:KnitInit()

end

function Service:KnitStart()
	
end

return Service