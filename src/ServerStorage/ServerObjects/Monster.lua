--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Constants = Knit:GetModule("Constants")
local Signal = Knit:GetModule("Signal")

-- // KNIT SERVICES

-- // CONSTS

local Monster = {}
Monster.__index = Monster
Monster.Objects = {}

function Monster.new(player, dataFolder, levelsData, monsterService, levelService, level, wave)
	local self = setmetatable({}, Monster)
	self._Maid = Maid.new()

	self._Player = player
	self._DataFolder = dataFolder
	self._LevelsData = levelsData
	self._MonsterService = monsterService
	self._LevelService = levelService

	self.OnDamageTaken = Signal.new()

	self._Maid:GiveTask(self.OnDamageTaken)

	self.Info = {
		Level = level,
		Wave = wave,
		IsBoss = false,
	}

	return self
end

function Monster:init()
	local index = "Levels"

	if self.Info.Wave == self._LevelsData.MOSTERS_UNTIL_BOSS + 1 then
		index = "Bosses"
		self.Info.IsBoss = true

		self.OnBossFailedToKill = Signal.new()
		self._Maid:GiveTask(self.OnBossFailedToKill)

		self:startTimer()
	end

	self:setupHealth()

	local info = self._LevelsData[index][math.random(1, #self._LevelsData[index])]

	self.Info.Data = info
end

function Monster:startTimer()
	self.Tick = workspace:GetAttribute("Tick")
	self.Timer = 0

	local dtAmount = 0

	self._LevelService.Client.OnBossTimerCreated:Fire(self._Player, self.Tick)

	self._Maid:GiveTask(RunService.Heartbeat:Connect(function(deltaAmount)
		if dtAmount < 1 then
			dtAmount += deltaAmount
			return
		end

		dtAmount = 0
		self.Timer += 1

		if self.Timer >= self._LevelsData.TIMER_FOR_BOSS and self.Info.Health > 0 then
			self.OnBossFailedToKill:Fire()
		end
	end))
end

function Monster:takeDamage(damage: value)
	self.Info.Health = math.round(math.clamp(self.Info.Health - damage, 0, self.Info.MaxHealth))

	self._MonsterService.Client.OnTakeDamage:FireAll(self._Player, damage, self.Info.Health, self.Info.MaxHealth)

	self.OnDamageTaken:Fire(damage, self.Info.Health, self.Info.MaxHealth)
end

function Monster:getReward()

	local reward = self._LevelsData.MONSTER_REWARD_BASE
		* (self._LevelsData.HEALTH_MULTIPLIER_PER_MONSTER ^ (self.Info.Level + self.Info.Wave - 2))

	if self.Info.IsBoss then
		reward *= Constants.BOSS_HEALTH_MULTIPLIER
	end

	return math.round(reward)

end

function Monster:setupHealth()
	local health = self._LevelsData.MONSTER_HEALTH_BASE
		* (self._LevelsData.HEALTH_MULTIPLIER_PER_MONSTER ^ (self.Info.Level + self.Info.Wave - 2))

	if self.Info.IsBoss then
		health *= Constants.BOSS_HEALTH_MULTIPLIER
	end

	self.Info.Health = math.round(health)
	self.Info.MaxHealth = self.Info.Health

	return self.Info.Health
end

function Monster:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	self._MonsterService.Client.OnMonsterKilled:FireAll(self._Player, self.Info)
end

return Monster
