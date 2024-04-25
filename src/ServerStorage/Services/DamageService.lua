--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES
local DataService, TycoonService
-- // CONSTS

local DamageService = Knit.CreateService {
	Name = "DamageService",
	Client = {
	}
}
function DamageService:KnitInit()

end

function DamageService:KnitStart()

	DataService = Knit.GetService("DataService")
	TycoonService = Knit.GetService("TycoonService")

end

function DamageService:onDamageRequestByUnit(unit)

	if not unit then
		return
	end

	local tycoon = TycoonService:getTycoonByPlayer(unit._Player)

	if not tycoon then
		return
	end

	if not tycoon.Level or not tycoon.Level.Monster then
		return warn("error while getting level or monster")
	end
	
	tycoon.Level.Monster:takeDamage(unit.Info.Damage)

end

-- function DamageService:onSwordDamageRequest(player: Player)

-- end

-- function DamageService:OnSwordDamageRequest(player: Player)
-- 	return self.Server:onSwordDamageRequest(player)
-- end

return DamageService