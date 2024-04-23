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

function Level.new(player: Player, levelService, monsterService, dataService, dataFolder, levelsData)
	local self = setmetatable({}, Level)
	self._Maid = Maid.new()
	self._Player = player
	self._DataFolder = dataFolder
	self._LevelsData = levelsData

	self._DataService = dataService
	self._MonsterService = monsterService
	self._LevelService = levelService

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

	self.Monster = Monster.new(self._Player, self._DataFolder, self._LevelsData, self._MonsterService, self.CurrentlyLevel, self.CurrentlyWave)
	self.Monster:init()

end

function Level:takeDamage(damage: number)

	if not self.Monster then
		return
	end

	self.Monster:takeDamage(damage)

	if self.Monster.Health == 0 then
		self:onMonsterKilled()
	end

end

function Level:onMonsterKilled()

	if not self.Monster then
		return warn("error getting monster when killed")
	end

	if self.Monster.Wave == self._LevelsData.MOSTERS_UNTIL_BOSS + 1 then
		self._DataService:IncrementDataValueInPath(self._Player, "Data.Level", 1)
		self._DataService:ChangeValueOnProfile(self._Player, "Data.Wave", 0)
		self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")
	end

	if self.CurrentlyWave < self._LevelsData.MOSTERS_UNTIL_BOSS then
		self._DataService:IncrementDataValueInPath(self._Player, "Data.Wave", 1)
	else
		print("[BOSS TIME]")
		self._DataService:ChangeValueOnProfile(self._Player, "Data.Wave", self._LevelsData.MOSTERS_UNTIL_BOSS + 1 )
	end

	self.CurrentlyLevel = self._DataFolder:WaitForChild("Data"):GetAttribute("Level")
	self.CurrentlyWave = self._DataFolder.Data:GetAttribute("Wave")

	self.Monster:destroy()
	self.Monster = nil

	self:setupMonster()
end

function Level:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil
end

return Level