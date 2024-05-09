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

local Sookuna = {}
Sookuna.__index = UnitsClient
Sookuna.Objects = {}
setmetatable(Sookuna, UnitsClient)

function Sookuna.new(tycoon, unitsController, player, unitFolder)
	local self = setmetatable(UnitsClient.new(tycoon, unitsController, player, unitFolder), Sookuna)

	
	return self
end

function Sookuna:hit()
	
end

return Sookuna