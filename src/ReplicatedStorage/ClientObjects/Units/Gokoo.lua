--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local UnitsClient = Knit:GetModule("UnitClient")

-- // KNIT SERVICES

-- // CONSTS

local Gokoo = {}
Gokoo.__index = UnitsClient
Gokoo.Objects = {}
setmetatable(Gokoo, UnitsClient)

function Gokoo.new(tycoon, unitsController, player, unitFolder)
	local self = setmetatable(UnitsClient.new(tycoon, unitsController, player, unitFolder), Gokoo)

	
	return self
end

function Gokoo:hit()
	
end

return Gokoo