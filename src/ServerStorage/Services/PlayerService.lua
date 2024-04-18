--//SERVICES
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local Format = Knit:GetModule("Format")

-- // KNIT SERVICES
local DataService, BadgeService
-- // CONSTS
local Connections = {}

local PlayerService: Types.PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {
	},
})

function PlayerService:KnitInit() end

function PlayerService:KnitStart()
	DataService = Knit.GetService("DataService")
	BadgeService = Knit.GetService("BadgeService")

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			self:_onPlayerAdded(player)
		end)

		Connections[player]["CharAdded"] = player.CharacterAdded:Connect(function(character)
			self:_onCharacterAdded(player, character)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_onPlayerRemoving(player)
	end)

	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				if not player:GetAttribute("TimePlayed") then
					player:SetAttribute("TimePlayed", 0)
				end

				player:SetAttribute("TimePlayed", player:GetAttribute("TimePlayed") + 1)

				DataService:IncrementDataValueInPath(player, "Data.TimePlayed", 1)
			end

			task.wait(1)
		end
	end)
end

for _, player in Players:GetPlayers() do
	PlayerService:_onPlayerAdded(player)
end

function PlayerService:ChangeCollisions(character)
	for _, part: BasePart in character:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.CollisionGroup = "Player"
		end
	end
end

function PlayerService:_onPlayerRemoving(player)


	if Connections[player] then

		for _, v in Connections[player] do
			v:Disconnect()
			v = nil
		end
	end

	Connections[player] = nil

	local dataFolder = DataService:GetReplicationFolder(player)

	if not dataFolder then
		print("error")
		return
	end
end

function PlayerService:_onCharacterAdded(player: Player, character)

	local dataFolder = DataService:GetReplicationFolder(player)

	if Connections[player]["Appearance"] then
		Connections[player]["Appearance"]:Disconnect()
		Connections[player]["Appearance"] = nil
	end

	Connections[player]["Appearance"] = player.CharacterAppearanceLoaded:Connect(function()
		self:ChangeCollisions(character)

		Connections[player]["Appearance"]:Disconnect()
		Connections[player]["Appearance"] = nil
	end)

	self:ChangeCollisions(character)

	player:SetAttribute("SERVER_LOADED", true)
end

function PlayerService:_onPlayerAdded(player)

	if Connections[player] == nil then
		Connections[player] = {}
	end

	if player.Character then
		self:_onCharacterAdded(player, player.Character)
	end

end

function PlayerService:getCharacterWithTimeout(player)
	local tryPromise = Promise.new(function(resolve, reject)
		local character = player.Character

		if not character then
			repeat
				task.wait()
			until player.Character ~= nil
		end

		resolve(character)
	end):catch(warn)

	local crashPromise = Promise.new(function(resolve, reject)
		task.wait(5)
		reject("Failed to get player's character")
	end):catch(warn)

	-- start timeout if fail in 10 seconds then throw exception
	return Promise.race({
		tryPromise,
		crashPromise,
	})
		:andThen(function(character)
			return character
		end)
		:catch(function(err)
			warn(err)
		end)
end
return PlayerService
