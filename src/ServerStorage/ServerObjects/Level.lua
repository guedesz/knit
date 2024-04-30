--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Constants = Knit:GetModule("Constants")
local Monster = Knit:GetModule("Monster")

-- // KNIT SERVICES

-- // CONSTS

local Level = {}
Level.__index = Level
Level.Objects = {}

function Level.new(player: Player, levelService, monsterService, dataService, goldService, gemsService, dataFolder, levelsData)
	local self = setmetatable({}, Level)
	self._Maid = Maid.new()
	self._Player = player
	self._DataFolder = dataFolder
	self._LevelsData = levelsData

	self._DataService = dataService
	self._MonsterService = monsterService
	self._LevelService = levelService
	self._GoldService = goldService
	self._GemsService = gemsService

	self.CurrentlyLevel = self._DataFolder:WaitForChild("Data"):GetAttribute("Level")
	self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")

	return self
end

function Level:init()

	self:setupMonster()
	
	--self:setupInfoForMonster(isBoss)
end

function Level:setupMonster()

	if self.Monster then
		self.Monster:destroy()
	end

	self.Monster = Monster.new(self._Player, self._DataFolder, self._LevelsData, self._MonsterService, self._LevelService, self.CurrentlyLevel, self.CurrentlyWave)
	self.Monster:init()

	if self.Monster.OnBossFailedToKill then

		self._Maid:GiveTask(self.Monster.OnBossFailedToKill:Connect(function()
			self:onBossFailedToKill()
		end))
	end

	self._Maid:GiveTask(self.Monster.OnDamageTaken:Connect(function(damage, health, maxHealth)

		if health > 0 then
			return
		end
		
		local boss = false
		if self.Monster.Info.IsBoss then
			boss = true
			self:onBossSuccessKill()
		end

		self:onMonsterKilled(boss)
	end))

end

function Level:onBossFailedToKill()
	
	if not self.Monster then
		return warn("error getting monster when killed")
	end

	self._DataService:ChangeValueOnProfile(self._Player, "Data.Wave", 1)
	self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")

	self.Monster:destroy()
	self.Monster = nil

	self:setupMonster()

	self._LevelService.Client.OnBossFailedToKill:Fire(self._Player)
	
end

function Level:onBossSuccessKill()
	
	if not self.Monster then
		return warn("error getting monster when killed")
	end

	self._DataService:IncrementDataValueInPath(self._Player, "Data.Level", 1)
	self._DataService:IncrementDataValueInPath(self._Player, "Data.Wave", 0)

	self._LevelService.Client.OnBossSuccessKill:Fire(self._Player)

end

function Level:onMonsterKilled()

	if not self.Monster then
		return warn("error getting monster when killed")
	end

	if self.Monster.Info.Wave == self._LevelsData.MOSTERS_UNTIL_BOSS + 1 then
		self._DataService:IncrementDataValueInPath(self._Player, "Data.Level", 1)
		self._DataService:ChangeValueOnProfile(self._Player, "Data.Wave", 0)
		self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")
	end

	if self.CurrentlyWave < self._LevelsData.MOSTERS_UNTIL_BOSS then
		self._DataService:IncrementDataValueInPath(self._Player, "Data.Wave", 1)
	else
		self._DataService:ChangeValueOnProfile(self._Player, "Data.Wave", self._LevelsData.MOSTERS_UNTIL_BOSS + 1 )
	end

	self.CurrentlyLevel = self._DataFolder:WaitForChild("Data"):GetAttribute("Level")
	self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")

	local reward = self.Monster:getReward()

	if self.Monster.Info.Data.Type == "Gold" then
		self._GoldService:giveGold(self._Player, reward)
	elseif self.Monster.Info.Data.Type == "Gems" then
		self._GemsService:giveGems(self._Player, reward)
	end

	self.Monster:destroy()
	self.Monster = nil

	self:setupMonster()
end

function Level:destroy()

	if self.Monster then
		self.Monster:destroy()
	end
	
	self._Maid:DoCleaning()
	self._Maid = nil
end

return Level