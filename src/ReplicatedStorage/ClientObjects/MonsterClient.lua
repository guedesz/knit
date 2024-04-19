--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Promise = Knit:GetModule("Promise")
local LevelsData = Knit:GetMetaData("Levels")

-- // KNIT SERVICES

-- // CONSTS

local MonsterClient = {}
MonsterClient.__index = MonsterClient
MonsterClient.Objects = {}

function MonsterClient.new(player, info)
	local self = setmetatable({}, MonsterClient)
	self._Maid = Maid.new()
	self.Info = info


	return self
end

function MonsterClient:init()

	return Promise.new(function(resolve, reject)
		
		local monster
	
		if self.Info.Wave <= LevelsData.MOSTERS_UNTIL_BOSS then
			monster = Knit:GetMonster(self.Info.Name)
		end
	
		self.Model = monster
		
		if not self.Monster then
			return reject("error getting monster")
		end

		resolve(monster)

		self._Maid:GiveTask(self.Monster)
	end)
end


function MonsterClient:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil
end

return MonsterClient