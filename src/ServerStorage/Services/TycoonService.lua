--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local Tycoon = Knit:GetModule("Tycoon")

-- // KNIT SERVICES
local PlotService, DataService, LevelService

-- // CONSTS
local Connections = {}

local TycoonService = Knit.CreateService({
	Name = "TycoonService",
	Client = {
		OnTycoonSetup = Knit.CreateSignal(),
		OnPlayerAdded = Knit.CreateSignal(),
		OnPlayerRemoving = Knit.CreateSignal(),
	},

})

function TycoonService:KnitInit() end

function TycoonService:KnitStart()

	PlotService = Knit.GetService("PlotService")
	DataService = Knit.GetService("DataService")
	LevelService = Knit.GetService("LevelService")

	Players.PlayerAdded:Connect(function(player: Player)
		self:_onPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:_onPlayerRemoving(player)
	end)
end

function TycoonService:getTycoonByPlayer(player: Player)
	return Tycoon.Objects[player]
end

function TycoonService:_onPlayerRemoving(player: Player)

	if Connections[player] then
		for _, v in Connections[player] do
			v:Disconnect()
			v = nil
		end
	end

	Connections[player] = nil

	if Tycoon.Objects[player] then
		Tycoon.Objects[player]:destroy()
		Tycoon.Objects[player] = nil
	end

end

function TycoonService:_onCharacterAdded(player: Player, character)

	task.wait()

	local tycoon = Tycoon.Objects[player]

	if not tycoon then
		return error("tycoon not found on character added")
	end

	tycoon:teleportToTycoonSpawn()

end

function TycoonService:_onPlayerAdded(player: Player)
	local plot = PlotService:claimPlotForPlayer(player)

	if not plot then
		return warn("error getting player plot")
	end

	if not Tycoon.Objects[player] then
		local tycoon = Tycoon.new(player, plot, self, DataService, LevelService)
		tycoon:init()
	end

	if player.Character then
		self:_onCharacterAdded(player, player.Character)
	end

	Connections[player] = {}

	Connections[player]["Char"] = player.CharacterAdded:Connect(function(character)
		self:_onCharacterAdded(player, character)
	end)

end

return TycoonService
