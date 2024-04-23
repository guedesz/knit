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

function LevelClient.new(player, info)
	local self = setmetatable({}, LevelClient)
	self._Maid = Maid.new()
	self._Player = player
	self.Info = info

	LevelClient.Objects[player] = self
	
	return self
end

function LevelClient:init()

end

function LevelClient:getMonster()

	return Promise.new(function(resolve, reject)
	
		self:destroyMonster()

		local monster = MonsterClient.new(self._Player, self.Info)
		monster:init():andThen(function(result)
			self.Monster = monster
		end):catch(warn):await()

		resolve(true)
	end)

end

function LevelClient:destroyMonster()
	
	if not self.Monster then
		return
	end

	self.Monster:destroy()

end

function LevelClient:destroy()
	self:destroyMonster()
	
	self._Maid:DoCleaning()
	self._Maid = nil

	LevelClient.Objects[self._Player] = nil
end

return LevelClient