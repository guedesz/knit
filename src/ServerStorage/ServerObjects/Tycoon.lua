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

function Tycoon.new(player: Player, plot, tycoonService, dataService, levelService)
	local self = setmetatable({}, Tycoon)
	self._Maid = Maid.new()
	self.Player = player
	self.Plot = plot

	self._TycoonService = tycoonService
	self._DataService = dataService
	self._LevelService = levelService

	self.Folder = Knit:GetAsset("TycoonTemplate")
	self.Folder.Name = player.UserId
	self.Folder.Parent = TYCOONS_FOLDER
	self._Maid:GiveTask(self.Folder)

	self.Level = self._LevelService:createNewLevel(self.Player)
	self.Level:init()

	self._Maid:GiveTask(function()
		self.Level:destroy()
	end)
	
	Tycoon.Objects[player] = self
	
	return self
end

function Tycoon:init()

	-- create tycoon just for client
	self._TycoonService.Client.OnTycoonSetup:FireAll(self.Player, self.Folder, self.Plot)

	print("Tycoon init on server")
end

function Tycoon:teleportToTycoonSpawn()
	self.Player.Character:PivotTo(
		self.Plot.spawn.CFrame + Vector3.new(0, self.Player.Character:GetExtentsSize().Y / 2, 0)
	)
end

function Tycoon:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	Tycoon.Objects[self.Player] = nil
	self._TycoonService.Client.OnPlayerRemoving:FireAll(self.Player)

end

return Tycoon