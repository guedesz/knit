--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local Level = Knit:GetModule("Level")
local LevelsData = Knit:GetMetaData("Levels")

-- // KNIT SERVICES
local DataService, TycoonService, MonsterService

-- // CONSTS

local LevelService = Knit.CreateService {
	Name = "LevelService",
	Client = {
		OnNewLevelCreated = Knit.CreateSignal(),
		OnBossTimerCreated = Knit.CreateSignal(),
		OnBossFailedToKill = Knit.CreateSignal(),
		OnBossSuccessKill = Knit.CreateSignal(),
	}
}

function LevelService:KnitInit()

end

function LevelService:KnitStart()

	DataService = Knit.GetService("DataService")
	TycoonService = Knit.GetService("TycoonService")
	MonsterService = Knit.GetService("MonsterService")

end

function LevelService:createNewLevel(player: Player)

	local dataFolder = DataService:GetReplicationFolder(player)
	assert(dataFolder, " error getting data folder while creating new level")

	local newLevel = Level.new(player, self, MonsterService, DataService, dataFolder, LevelsData)

	return newLevel
end

function LevelService:getLevelInfoByPlayer(player: Player)
	local tycoon = TycoonService:getTycoonByPlayer(player)
	assert(tycoon, "error getting tycoon when level info by player")

	return tycoon.Level.Monster.Info
end

function LevelService.Client:GetLevelInfoByPlayer(player: Player, target: Player)
	return self.Server:getLevelInfoByPlayer(target)
end

return LevelService