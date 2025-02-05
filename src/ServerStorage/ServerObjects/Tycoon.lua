--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Signal = Knit:GetModule("Signal")
local Monster = Knit:GetModule("Monster")
local PlayerTower = Knit:GetModule("PlayerTower")

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

	self._DataFolder = dataService:GetReplicationFolder(player)
 
	self.Folder = Knit:GetAsset("TycoonTemplate")
	self.Folder.Name = player.UserId
	self.Folder:PivotTo(plot.spawn.CFrame)

	self.Folder.Parent = TYCOONS_FOLDER
	self._Maid:GiveTask(self.Folder)

	Tycoon.Objects[player] = self
	
	return self
end

function Tycoon:initTower()

	self.Tower = PlayerTower.new(self.Player, self._DataFolder:WaitForChild("Tower"):GetAttribute("Health"), "Cabin", self.Folder.Builds.PlayerTower.CFrame, self.Folder.Builds)
	self.Tower:spawn()

end

function Tycoon:init()

	-- create tycoon just for client
	self._TycoonService.Client.OnTycoonSetup:FireAll(self.Player, self.Folder, self.Plot)

	-- load other tycoons
	for plr, tycoon in Tycoon.Objects do

		if plr == self.Player then
			continue
		end
		
		if tycoon.IsDestroying then
			continue
		end

		self._TycoonService.Client.OnPlayerAdded:Fire(self.Player, plr, tycoon.Folder, tycoon.Plot)
	end

	self:initTower()

	print("Tycoon init on server")

end

function Tycoon:newMatch(match)

	if self.Match then
		return
	end

	self.Match = match

	self.Match:start()
end

function Tycoon:teleportToTycoonSpawn()
	self.Player.Character:PivotTo(
		self.Folder.spawn.CFrame + Vector3.new(0, self.Player.Character:GetExtentsSize().Y / 2, 0)
	)
end

function Tycoon:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	self.IsDestroying = true
	
	Tycoon.Objects[self.Player] = nil

	self.Plot = nil
	self._DataService = nil

	self._TycoonService.Client.OnPlayerRemoving:FireAll(self.Player)
	self._TycoonService = nil
	self.Player = nil

	if self.Match then
		self.Match:destroy()
		self.Match = nil
	end
	
end

return Tycoon