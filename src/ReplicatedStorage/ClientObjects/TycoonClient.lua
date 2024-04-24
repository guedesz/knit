--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local LevelClient = Knit:GetModule("LevelClient")

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

	self._TycoonFolder = tycoonFolder
	self._PlotFolder = plotFolder

	self.IsDestroying = false

	self.MonsterSpawn = self._PlotFolder:WaitForChild("monsterSpawn")

	self._DataFolder = self._DataController:GetReplicationFolder(player)

	self:getNewLevel()

	TycoonClient.Objects[player] = self

	return self
end

function TycoonClient:init()
	self:spawnMonster()
	self:loadNPCs()

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
function TycoonClient:loadNPCs() end

function TycoonClient:destroy()

	self.IsDestroying = true

	self._Maid:DoCleaning()
	self._Maid = nil

	TycoonClient.Objects[self._Player] = nil
end

return TycoonClient
