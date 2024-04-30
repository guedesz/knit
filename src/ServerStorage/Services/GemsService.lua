--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES
local DataService
-- // CONSTS

local GemsService = Knit.CreateService {
	Name = "GemsService",
	Client = {
		OnGemsEarned = Knit.CreateSignal()
	}
}
function GemsService:KnitInit()

end

function GemsService:KnitStart()
	
	DataService = Knit.GetService("DataService")
end

function GemsService:giveGems(player: Player, value: number)
	
	local amount = value

	DataService:IncrementDataValueInPath(player, "Data.Gems", amount)

	self.Client.OnGemsEarned:Fire(player, amount)
	
end



return GemsService