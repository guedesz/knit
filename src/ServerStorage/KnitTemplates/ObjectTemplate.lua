--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")

-- // KNIT SERVICES

-- // CONSTS

local Template = {}
Template.__index = Template
Template.Objects = {}


function Template.new()
	local self = setmetatable({}, Template)
	self._Maid = Maid.new()

	return self	
end

function Template:init()

end

function Template:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil
end

return Template