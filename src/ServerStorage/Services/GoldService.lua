--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES
local DataService, MessageService
-- // CONSTS

local GoldService = Knit.CreateService {
	Name = "GoldService",
	Client = {
		OnGoldEarned = Knit.CreateSignal(),
	}
}

function GoldService:KnitInit()

end

function GoldService:KnitStart()
	
	MessageService = Knit.GetService("MessageService")

	DataService = Knit.GetService("DataService")
end

function GoldService:giveGold(player: Player, value: number)
	
	local amount = value

	DataService:IncrementDataValueInPath(player, "Data.Gold", amount)

	self.Client.OnGoldEarned:Fire(player, amount)
end



return GoldService