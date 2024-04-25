--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS
local TycoonClient = Knit:GetModule("TycoonClient")

-- // KNIT SERVICES & CONTROLLERS
local TycoonService, DataController, LevelService, AudioController, UIController, UnitsController
-- // CONSTS

local TycoonController = Knit.CreateController({ Name = "TycoonController" })

function TycoonController:KnitInit() end

function TycoonController:KnitStart()
	TycoonService = Knit.GetService("TycoonService")
	DataController = Knit.GetController("DataController")
	LevelService = Knit.GetService("LevelService")
	AudioController = Knit.GetController("AudioController")
	UIController = Knit.GetController("UIController")
	UnitsController = Knit.GetController("UnitsController")
	
	TycoonService.OnTycoonSetup:Connect(function(player, tycoonFolder: Folder, plot: Folder)
		self:onTycoonSetup(player, tycoonFolder, plot)
	end)

	TycoonService.OnPlayerRemoving:Connect(function(player)
		self:onPlayerRemoving(player)
	end)

	TycoonService.OnPlayerAdded:Connect(function(player, tycoonFolder: Folder, plot: Folder)
		self:onTycoonSetup(player, tycoonFolder, plot)
	end)
end

function TycoonController:onPlayerRemoving(player)
	local obj = TycoonClient.Objects[player]

	if not obj then
		return
	end

	obj:destroy()
end

function TycoonController:getTycoonByPlayer(player: Player)

	local objt = TycoonClient.Objects[player]

	if not objt then
		return false
	end

	if objt.IsDestroying then
		return false
	end

	return objt
end

function TycoonController:onTycoonSetup(player, tycoon, plot)
	local tycoon = TycoonClient.new(
		player,
		TycoonService,
		TycoonController,
		LevelService,
		DataController,
		AudioController,
		UIController,
		UnitsController,
		tycoon,
		plot
	)
	tycoon:init()
end

return TycoonController
