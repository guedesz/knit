--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local LevelsData = Knit:GetMetaData("Levels")
local Promise = Knit:GetModule("Promise")
local MonsterClient = Knit:GetModule("MonsterClient")

-- // KNIT SERVICES

-- // CONSTS

local LevelClient = {}
LevelClient.__index = LevelClient
LevelClient.Objects = {}

function LevelClient.new(player, info, audioController, uiController, levelService)
	local self = setmetatable({}, LevelClient)
	self._Maid = Maid.new()
	self._Player = player
	self.Info = info
	self._AudioController = audioController
	self._UIController = uiController
	self._LevelService = levelService

	self.IsDestroying = false

	if player == Knit.LocalPlayer then
		self.LevelHud = uiController:GetGuiController("Level")
		self.LevelHud:updateInfo(self.Info.Data.DisplayName or self.Info.Data.Name, self.Info.Level, self.Info.Wave)
	end

	LevelClient.Objects[player] = self
	
	return self
end

function LevelClient:init()

end

function LevelClient:getMonster()

	return Promise.new(function(resolve, reject)
	
		self:destroyMonster()

		local monster = MonsterClient.new(self._Player, self.Info, self._AudioController)
		monster:init():andThen(function(result)

			if not result then
				return warn(result)
			end

			self.Monster = monster

			if self.LevelHud then

				self._Maid:GiveTask(monster.OnDamage:Connect(function(actual, maxHealth)
					self.LevelHud:updateHealthbar(actual, maxHealth)
				end))

				self.LevelHud:updateHealthbar(monster.Info.Health, monster.Info.Health)
			end

		end):catch(function(err)
			warn(err)
		end):await()

		resolve(true)
	end)

end

function LevelClient:destroyMonster()
	
	if not self.Monster then
		return
	end

	self.Monster:destroy()
	self.Monster = nil
end

function LevelClient:destroy(isRemoving)

	if self.IsDestroying then
		return
	end
	
	self.IsDestroying = true
	self:destroyMonster(isRemoving)
	
	self._Maid:DoCleaning()
	self._Maid = nil

	LevelClient.Objects[self._Player] = nil
end

return LevelClient