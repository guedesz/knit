--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")

-- // KNIT SERVICES

-- // CONSTS
local TYCOONS_FOLDER: Folder = workspace:WaitForChild("Map"):WaitForChild("Tycoons")

local Tycoon = {}
Tycoon.__index = Tycoon
Tycoon.Objects = {}

function Tycoon.new(player: Player, plot, tycoonService, dataService)
	local self = setmetatable({}, Tycoon)
	self._Maid = Maid.new()
	self.Player = player
	self.Plot = plot
	self._TycoonService = tycoonService
	self._DataService = dataService

	Tycoon.Objects[player] = self

	self.Folder = Knit:GetAsset("TycoonTemplate")
	self.Folder.Name = player.UserId
	self.Folder.Parent = TYCOONS_FOLDER
	self._Maid:GiveTask(self.Folder)

	return self
end

function Tycoon:init()

	-- create tycoon just for client
	self._TycoonService.Client.OnTycoonSetup:FireAll(self.Player, self.Folder, self.Plot)

end

function Tycoon:teleportToTycoonSpawn()
	
end

function Tycoon:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	Tycoon.Objects[self.Player] = nil
	self._TycoonService.Client.OnPlayerRemoving:FireAll(self.Player)

end

return Tycoon