--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local LevelClient = Knit:GetModule("LevelClient")
local UnitClient = Knit:GetModule("UnitClient")

-- // KNIT SERVICES

-- // CONSTS

local TycoonClient = {}
TycoonClient.__index = TycoonClient
TycoonClient.Objects = {}

function TycoonClient.new(
	player,
	tycoonService,
	tycoonController,
	levelService,
	dataController,
	audioController,
	uiController,
	unitsController,
	tycoonFolder,
	plotFolder
)
	local self = setmetatable({}, TycoonClient)
	self._Maid = Maid.new()

	self._Player = player

	self._TycoonService = tycoonService
	self._TycoonController = tycoonController
	self._DataController = dataController
	self._LevelService = levelService
	self._AudioController = audioController
	self._UIController = uiController
	self._UnitsController = unitsController
	self._TycoonFolder = tycoonFolder
	self._PlotFolder = plotFolder

	self.IsDestroying = false

	self.MonsterSpawn = self._PlotFolder:WaitForChild("monsterSpawn")
	self.UnitsPositions = self._TycoonFolder:WaitForChild("UnitsPositions")

	self._DataFolder = self._DataController:GetReplicationFolder(player)

	self:getNewLevel()

	TycoonClient.Objects[player] = self

	self.Units = {}

	return self
end

function TycoonClient:init()
	self:spawnMonster()
	self:loadUnits()

	print("Tycoon init on client", self)
end

function TycoonClient:getNewLevel()

	if self.Level then
		self.Level:destroy()
	end

	self._LevelService
		:GetLevelInfoByPlayer(self._Player)
		:andThen(function(info)

			if not info then
				return print(info)
			end

			self.LevelInfo = info

			self.Level = LevelClient.new(self._Player, info, self._AudioController, self._UIController, self._LevelService)

			self._Maid:GiveTask(function()
				
				if self.Level then
					self.Level:destroy()
					self.Level = nil
				end

			end)
		end):await()
		

		
end

function TycoonClient:spawnMonster()

	if not self.Level then
		return
	end
	
	self.Level:getMonster():andThen(function(result)
		if not self.Level.Monster then
			return
		end

		self.Level.Monster.Model:PivotTo(
			self.MonsterSpawn.CFrame + Vector3.new(0, self.Level.Monster.Model:GetExtentsSize().Y / 2, 0)
		)
		self.Level.Monster.Model.Parent = self._TycoonFolder.Monster
	end)

end

function TycoonClient:findFreeUnitPosition()
	
	for i = 1, #self.UnitsPositions:GetChildren() do

		local part = self.UnitsPositions:FindFirstChild(tostring(i))

		if not part:GetAttribute("Owner") then
			return part
		end
	end

	warn("no position found free")
	return nil
end

function TycoonClient:claimPosition(part, id)
	
	if not part then
		return
	end

	if part:GetAttribute("Owner") then
		return
	end

	part:SetAttribute("Owner", id)
end

function TycoonClient:cleanPosition(part)
	
	if not part then
		return
	end

	part:SetAttribute("Owner", nil)
end

function TycoonClient:loadUnits()

	local equippedUnits = self._UnitsController:getEquippedUnits(self._Player)

	for _, id in equippedUnits do
		self:loadUnit(id)
	end

end

function TycoonClient:loadUnit(id)
	
	local unitObject = self._UnitsController:getUnitObjectById(self._Player, id)

	local unit = UnitClient.new(self, self._UnitsController, self._Player, unitObject)
	unit:init()

	self.Units[id] = unit

end

function TycoonClient:removeUnit(id)

	local unit = self.Units[id]

	if unit then
		unit:destroy()
		self.Units[id] = nil
	end
end

function TycoonClient:destroy()

	self.IsDestroying = true

	self._Maid:DoCleaning()
	self._Maid = nil

	for _, v in self.Units do
		v:destroy()
	end
	
	TycoonClient.Objects[self._Player] = nil
end

return TycoonClient
