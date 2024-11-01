--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS

local Template = Knit.CreateService {
	Name = "Template",
	Client = {
	}
}
function Template:KnitInit()

end

function Template:KnitStart()
	
end

return Template