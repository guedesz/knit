--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local Shuriken = Knit:GetModule("Shuriken")

-- // KNIT SERVICES
local DataService, TycoonService
-- // CONSTS
local Connections = {}

local ShurikenService = Knit.CreateService {
	Name = "ShurikenService",
	Client = {
	}
}
function ShurikenService:KnitInit()

end

function ShurikenService:KnitStart()
	
	DataService = Knit.GetService("DataService")
	TycoonService = Knit.GetService("TycoonService")

	
	Players.PlayerAdded:Connect(function(player)
		self:_onPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_onPlayerRemoving(player)
	end)

end

function ShurikenService:_onPlayerAdded(player: Player)
	Connections[player] = {}

	if player.Character ~= nil then
		self:_onCharacterAdded(player, player.Character)
	end

	Connections[player]["char"] = player.CharacterAdded:Connect(function(character)
		--character.AncestryChanged:Wait()

		self:_onCharacterAdded(player, character)
	end)
end

for _, player in Players:GetPlayers() do
	ShurikenService:_onPlayerAdded(player)
end

function ShurikenService:_onPlayerRemoving(player: Player)
	if Connections[player] then
		for _, v in Connections[player] do
			v:Disconnect()
			v = nil
		end
	end

	Connections[player] = nil

	if Shuriken.Objects[player] then
		Shuriken.Objects[player]:destroy()
		Shuriken.Objects[player] = nil
	end

end

function ShurikenService:_onCharacterAdded(player: Player, character: Model)
	local dataFolder = DataService:GetReplicationFolder(player)

	assert(dataFolder, "failed getting data folder while character added dumbell service")

	self:loadShuriken(player, dataFolder)
end

function ShurikenService:loadShuriken(player, dataFolder)
	-- already exists, just respawned
	if Shuriken.Objects[player] then
		return Shuriken.Objects[player]:spawn(player.Character)
	end

	local shurikenName = dataFolder:WaitForChild("Shurikens"):GetAttribute("Equipped")

	-- first time creating
	local shuriken = Shuriken.new(player, shurikenName, self, TycoonService)
	shuriken:spawn(player.Character)
end

function ShurikenService:onClickRequest(player: Player)

	local isBonus = math.random() < .01

	if Shuriken.Objects[player] then
		return Shuriken.Objects[player]:click(isBonus)
	end
end


function ShurikenService.Client:OnClickRequest(player: Player)
	return self.Server:onClickRequest(player)
end


return ShurikenService