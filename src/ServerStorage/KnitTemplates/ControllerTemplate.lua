--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS

-- // CONSTS


local Template = Knit.CreateController{Name = "Template"}

function Template:KnitInit()

end

function Template:KnitStart()
	
end

return Template
