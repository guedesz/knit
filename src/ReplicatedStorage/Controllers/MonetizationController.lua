--//SERVICES
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

local MonetizationIds = Knit:GetModule("MonetizationIds")
--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local MonetizationService, DataController, UIController
-- // CONSTS


local MonetizationController = Knit.CreateController{Name = "MonetizationController"}

function MonetizationController:KnitInit()

end

function MonetizationController:KnitStart()
	
	MonetizationService = Knit.GetService("MonetizationService")
	UIController = Knit.GetController("UIController")
	DataController = Knit.GetController("DataController")

	MonetizationService.OnGamepassPurchase:Connect(function(gamepassName)
		self:_HandleGamepassPurchaseCallbacks(gamepassName)
	end)

end

function MonetizationController:PromptGamepassPurchase(gamePassName)
	
	if MonetizationIds.Gamepass[gamePassName] then
		MarketplaceService:PromptGamePassPurchase(Knit.LocalPlayer, MonetizationIds.Gamepass[gamePassName])
	end

end

function MonetizationController:GetProductInfo(id, isGamepass)

	local info 
	
	local success, err = pcall(function()
		if isGamepass then
			info = MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
		else
			info = MarketplaceService:GetProductInfo(id, 1)
		end

	end)
	
	if not info then
		return false
	end
	
	return info
end

function MonetizationController:_HandleGamepassPurchaseCallbacks(gamepassName)

	--ShopController:OnGamepassPurchased(gamepassName)
	local dataFolder = DataController:GetReplicationFolder()

end

return MonetizationController