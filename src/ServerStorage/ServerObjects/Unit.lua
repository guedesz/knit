--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local UnitsData = Knit:GetMetaData("Units")
-- // KNIT SERVICES

-- // CONSTS

local Unit = {}
Unit.__index = Unit
Unit.Objects = {}


function Unit.new(player: Player, name: string, id: string, damageService)
	local self = setmetatable({}, Unit)
	self._Maid = Maid.new()
	self._Player = player
	self.Name = name
	self.Id = id

	self._DamageService = damageService

	self.Info = UnitsData:getUnitByName(name)
	self.CanHit = true

	if Unit.Objects[player] == nil then
		Unit.Objects[player] = {}
	end

	if Unit.Objects[name] == nil then
		Unit.Objects[name] = {}
	end

	Unit.Objects[name][id] = self
	Unit.Objects[player][id] = self

	return self
end

function Unit:takeDamage()

	if self.IsDestroying then
		return
	end

	self._DamageService:onDamageRequestByUnit(self)
end

function Unit:destroy()

	self.IsDestroying = true
	
	self._Maid:DoCleaning()
	self._Maid = nil

	Unit.Objects[self._Player][self.Id] = nil
	Unit.Objects[self.Name][self.Id] = nil

	self.Name = nil
	self.Id = nil
	self._Player = nil

end

return Unit