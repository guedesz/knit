--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS

-- // CONSTS


local Controller = Knit.CreateController{Name = "Controller"}

function Controller:KnitInit()

end

function Controller:KnitStart()
	
end

return Controller
