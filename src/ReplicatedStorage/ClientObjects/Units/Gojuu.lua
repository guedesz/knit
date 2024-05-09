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

local Gojuu = {}
Gojuu.__index = UnitsClient
Gojuu.Objects = {}
setmetatable(Gojuu, UnitsClient)

function Gojuu.new(tycoon, unitsController, player, unitFolder)
	local self = setmetatable(UnitsClient.new(tycoon, unitsController, player, unitFolder), Gojuu)

	
	return self
end

function Gojuu:hit()
	
end

return Gojuu