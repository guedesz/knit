--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")

-- // KNIT SERVICES

-- // CONSTS

local Level = {}
Level.__index = Level
Level.Objects = {}

function Level.new(player: Player, levelService, monsterService, dataFolder, levelsData)
	local self = setmetatable({}, Level)
	self._Maid = Maid.new()
	self._Player = player
	self._DataFolder = dataFolder
	self._LevelsData = levelsData

	self._MonsterService = monsterService
	self._LevelService = levelService

	self.CurrentlyLevel = self._DataFolder:WaitForChild("Data"):GetAttribute("Level")
	self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")

	return self
end

function Level:init()

	local health = self:getHealthForWave()

	self.Info = {
		Name = self._LevelsData.Levels[math.random(1, #self._LevelsData.Levels)].Name,
		Health = health,
		MaxHealth = health,
		Level = self.CurrentlyLevel,
		Wave = self.CurrentlyWave,
	}

end

function Level:getHealthForWave()

	local health = self._LevelsData.MONSTER_HEALTH_BASE * (self._LevelsData.HEALTH_MULTIPLIER_PER_MONSTER ^ (self.CurrentlyLevel + self.CurrentlyWave - 2))

    return health
end

function Level:takeDamage(damage: number)

	self.Info.Health = math.clamp(self.Info.Health - damage, 0, self.Info.MaxHealth)

	self._MonsterService.Client.OnTakeDamage:FireAll(self._Player, damage, self.Info.Health, self.Info.MaxHealth)

	if self.Info.Health == 0 then
		self:onMonsterKilled()
	end
	
end

function Level:onMonsterKilled()
	
end

function Level:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

end

return Level