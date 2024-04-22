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

function TycoonClient.new(player, tycoonService, tycoonController, levelService, dataController, tycoonFolder, plotFolder)
	local self = setmetatable({}, TycoonClient)
	self._Maid = Maid.new()

	self._Player = player

	self._TycoonService = tycoonService
	self._TycoonController = tycoonController
	self._DataController = dataController
	self._LevelService = levelService
	self._TycoonFolder = tycoonFolder
	self._PlotFolder = plotFolder

	self.MonsterSpawn = self._PlotFolder:WaitForChild("monsterSpawn")

	self._DataFolder = self._DataController:GetReplicationFolder(player)

	levelService:GetLevelInfoByPlayer(player):andThen(function(info)
		
		if not info then
			return
		end

		self.LevelInfo = info

		self.Level = LevelClient.new(player, info)

		self._Maid:GiveTask(function()
			self.Level:destroy()
		end)
	end):await()

	TycoonClient.Objects[player] = self
	
	return self
end

function TycoonClient:init()

	self:spawnMonster()
	self:loadNPCs()

	print("Tycoon init on client", self)
end

function TycoonClient:spawnMonster()

	self.Level:getMonster():andThen(function(result)

		if not self.Level.Monster then
			return
		end
	
		self.Level.Monster.Model:PivotTo(self.MonsterSpawn.CFrame)
		self.Level.Monster.Model.Parent = self._TycoonFolder.Monster
	
	end)
end
function TycoonClient:loadNPCs()
	
end

function TycoonClient:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil


	TycoonClient.Objects[self._Player] = nil
end


return TycoonClient