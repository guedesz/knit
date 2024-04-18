--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")

-- // KNIT SERVICES

-- // CONSTS

local Object = {}
Object.__index = Object
Object.Objects = {}


function Object.new()
	local self = setmetatable({}, Object)
	self._Maid = Maid.new()
	
	return self	
end

function Object:init()
	
end

function Object:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil
end

return Object