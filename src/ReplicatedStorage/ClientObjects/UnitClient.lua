--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")

-- // KNIT SERVICES

-- // CONSTS

local UnitClient = {}
UnitClient.__index = UnitClient
UnitClient.Objects = {}


function UnitClient.new(tycoon, unitsController, player, unitFolder)
	local self = setmetatable({}, UnitClient)
	self._Maid = Maid.new()
	self._UnitsController = unitsController
	self._Player = player
	self._Folder = unitFolder
	self._Tycoon = tycoon
	
	self.Id = self._Folder.Name
	self.UnitName = self._Folder:GetAttribute("Name")

	self.IsInit = false
	return self
end

function UnitClient:init()

	self:loadModel()

	self.IsInit = true

	print(self)
end

function UnitClient:loadModel()

	self.Model = Knit:GetAsset(self._Folder:GetAttribute("Name"))
	self._Maid:GiveTask(self.Model)

	self.PartPosition = self._Tycoon:findFreeUnitPosition()

	if not self.PartPosition then
		return warn("no part position found")
	end

	self._Tycoon:claimPosition(self.PartPosition, self.Id)

	self.Model:PivotTo(self.PartPosition.CFrame + Vector3.new(0, self.Model:GetExtentsSize().Y / 2, 0))
	self.Model.Parent = workspace.Units


end

function UnitClient:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	self._Tycoon:cleanPosition(self.PartPosition)
end

return UnitClient