--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Constants = Knit:GetModule("Constants")

-- // KNIT SERVICES

-- // CONSTS

local Monster = {}
Monster.__index = Monster
Monster.Objects = {}

function Monster.new(player, dataFolder, levelsData, monsterService, level, wave)
	local self = setmetatable({}, Monster)
	self._Maid = Maid.new()

	self._Player = player
	self._DataFolder = dataFolder
	self._LevelsData = levelsData
	self._MonsterService = monsterService

	self.Level = level
	self.Wave = wave

	if self.Wave == 11 then
		self.IsBoss = true
	else
		self.IsBoss = false
	end

	return self
end

function Monster:init()
	self:setupHealth()

	if self.Wave == self._LevelsData.MOSTERS_UNTIL_BOSS + 1 then
		self.Name = self._LevelsData.Bosses[math.random(1, #self._LevelsData.Bosses)].Name
	else
		self.Name = self._LevelsData.Levels[math.random(1, #self._LevelsData.Levels)].Name
	end

end

function Monster:takeDamage(damage: value)
	self.Health = math.round(math.clamp(self.Health - damage, 0, self.MaxHealth))

	self._MonsterService.Client.OnTakeDamage:FireAll(self._Player, damage, self.Health, self.MaxHealth)
end

function Monster:setupHealth()
	local health = self._LevelsData.MONSTER_HEALTH_BASE
		* (self._LevelsData.HEALTH_MULTIPLIER_PER_MONSTER ^ (self.Level + self.Wave - 2))

	if self.IsBoss then
		health *= Constants.BOSS_HEALTH_MULTIPLIER
	end

	self.Health = math.round(health)
	self.MaxHealth = self.Health

	return self.Health
end

function Monster:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	self._MonsterService.Client.OnMonsterKilled:FireAll(self._Player, self.Info)
end

return Monster
