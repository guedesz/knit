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

local Karurin = {}
Karurin.__index = UnitsClient
Karurin.Objects = {}
setmetatable(Karurin, UnitsClient)

function Karurin.new(tycoon, unitsController, player, unitFolder)
	local self = setmetatable(UnitsClient.new(tycoon, unitsController, player, unitFolder), Karurin)

	
	return self
end

function Karurin:hit()
	
end

return Karurin