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
local ThemesData = Knit:GetMetaData("Themes")

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
	self._DataFolder = dataService:GetReplicationFolder(player)

	local themeName, info = ThemesData:getThemeByLevel(self._DataFolder:WaitForChild("Data"):GetAttribute("Level"))

	self.ThemeName = themeName
	self.Theme = Knit:GetAsset(themeName or "Castle")
	self.Theme.Parent = TYCOONS_FOLDER
	self._Maid.Theme = self.Theme

	self.Folder = Knit:GetAsset("TycoonTemplate")
	self.Folder.Name = player.UserId
	self.Folder:PivotTo(plot.monsterSpawn.CFrame)

	self.Folder.Parent = TYCOONS_FOLDER
	self._Maid:GiveTask(self.Folder)

	self.Level = self._LevelService:createNewLevel(self.Player)
	self.Level:init()

	self._Maid:GiveTask(self.Level.OnNewLevel:Connect(function()
		self:checkForThemeChanged()
	end))

	self._Maid:GiveTask(function()
		self.Level:destroy()
		self.Level = nil
	end)
	
	Tycoon.Objects[player] = self
	
	return self
end

function Tycoon:checkForThemeChanged()
	
	local themeName, info = ThemesData:getThemeByLevel(self._DataFolder:WaitForChild("Data"):GetAttribute("Level"))

	if themeName == self.ThemeName then
		return
	end

	self._Maid.Theme = nil

	self.ThemeName = themeName

	self.Theme = Knit:GetAsset(themeName or "Castle")
	self.Theme.Parent = TYCOONS_FOLDER
	self._Maid.Theme = self.Theme

	-- TODO display visual animation to upgrade the plot client side
	
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

	-- task.spawn(function()
	-- 	task.wait(3)
	-- 	while true do
	-- 		if self.Level then
	-- 			self.Level:takeDamage(300)
	-- 		else
	-- 			break
	-- 		end
		
	-- 		task.wait(1)
	-- 	end
	-- end)

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

	self.IsDestroying = true
	
	Tycoon.Objects[self.Player] = nil

	self.Plot = nil
	self._DataService = nil
	self._LevelService = nil

	self._TycoonService.Client.OnPlayerRemoving:FireAll(self.Player)
	self._TycoonService = nil
	self.Player = nil
end

return Tycoon