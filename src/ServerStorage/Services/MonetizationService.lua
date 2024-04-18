--//SERVICES
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local Signal = Knit:GetModule("Signal")
local MonetizationIds = Knit:GetModule("MonetizationIds")
local Constants = Knit:GetModule("Constants")

-- // KNIT SERVICES
local DataService, MessageService
-- // CONSTS
local productFunctions = {}

local MonetizationService = Knit.CreateService({
	Name = "MonetizationService",
	Client = {
		OnGamepassPurchase = Knit.CreateSignal(),
	},
})

MonetizationService.CheckSignal = Signal.new()

function MonetizationService:KnitInit() end

function MonetizationService:KnitStart()
	DataService = Knit.GetService("DataService")
	MessageService = Knit.GetService("MessageService")

	self:_InitDevProducts()

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassID, purchaseSuccess)
		self:_onPromptGamePassPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	end)

	Players.PlayerAdded:Connect(function(player)
		self:_CheckForPurchaseOutsideGame(player)
	end)
end

for _, player in Players:GetPlayers() do
	MonetizationService:_CheckForPurchaseOutsideGame(player)
end

function MonetizationService:PromptProductPurchase(player, productName)
	local id = MonetizationIds.DevProducts[productName]

	if not id then
		return warn("no product name found")
	end

	MarketplaceService:PromptProductPurchase(player, id)
end

function MonetizationService:PromptGamepassPurchase(player: Player, gamepassName: string)
	local id = MonetizationIds.Gamepass[gamepassName]

	if not id then
		return warn("no gamepass name found")
	end

	MarketplaceService:PromptGamePassPurchase(player, id)
end

function MonetizationService:GetProductInfo(id, isGamepass)
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

-- PRIVATE
function MonetizationService:_onPromptGamePassPurchaseFinished(player: Player, purchasedPassID, purchaseSuccess)
	if not purchaseSuccess then
		return
	end

	local nameInProfile
	for name, id in MonetizationIds.Gamepass do
		if id == purchasedPassID then
			nameInProfile = name
			break
		end
	end

	local folder = DataService:GetReplicationFolder(player)

	if folder then
		if folder.Gamepass:GetAttribute(tostring(nameInProfile)) ~= nil then
			DataService:ChangeValueOnProfile(player, "Gamepass." .. tostring(nameInProfile), true)
			self:handleGamepassCallbacks(player, nameInProfile)
			self.Client.OnGamepassPurchase:Fire(player, nameInProfile)
			MessageService.Client.MessagePlayer:Fire(
				player,
				"Yey! You purchase has been processed succesfully. ✅",
				Color3.fromRGB(0, 170, 0),
				5,
				"DevPurchase"
			)

			local productInfo = self:GetProductInfo(purchasedPassID, true)

			if productInfo then
				MessageService.Client.MessagePlayerChat:FireAll("[SYSTEM] " .. player.Name .. " just purchased ".. productInfo.Name .. " Gamepass!", Color3.fromRGB(0, 200, 255))
			end

		end
	end
end
function MonetizationService:_InitDevProducts()

	-- for quantity, id in MonetizationIds.DevProducts.Spins do
	-- 	productFunctions[id] = function(receipt, player)
	-- 		DataService:IncrementDataValueInPath(player, "Wheel.SpinsLeft", quantity)
	-- 		return true
	-- 	end
	-- end

	local function processReceipt(receiptInfo)
		local userId = receiptInfo.PlayerId
		local productId = receiptInfo.ProductId

		local player = Players:GetPlayerByUserId(userId)

		if player then
			local handler = productFunctions[productId]
			local success, result = pcall(handler, receiptInfo, player)
			if success then
				-- The player has received their benefits!
				-- return PurchaseGranted to confirm the transaction.
				MessageService.Client.MessagePlayer:Fire(
					player,
					"Yey! You purchase has been processed succesfully. ✅",
					Color3.fromRGB(170, 94, 0),
					5,
					"DevPurchase"
				)

				local productInfo = self:GetProductInfo(productId, false)

				if productInfo then
					MessageService.Client.MessagePlayerChat:FireAll("[SYSTEM] " .. player.Name .. " just purchased ".. productInfo.Name .. "!", Color3.fromRGB(0, 200, 255))
				end

				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				warn("Failed to process receipt:", receiptInfo, result)
			end
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	MarketplaceService.ProcessReceipt = processReceipt
end

function MonetizationService:handleGamepassCallbacks(player, gamepassName)
	local dataFolder = DataService:GetReplicationFolder(player)

end

function MonetizationService:_CheckForPurchaseOutsideGame(player: Player)
	assert(player, "Player is needed to check for purchases. Got: ", type(player))

	local dataFolder = DataService:GetReplicationFolder(player)

	for name, id in MonetizationIds.Gamepass do
		local hasPass
		local success, err = pcall(function()
			hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
		end)

		if not success then
			warn(err)
			continue
		end

		if hasPass then
			local gamepass = dataFolder.Gamepass:GetAttribute(name)
			if gamepass ~= nil and gamepass == false then
				DataService:ChangeValueOnProfile(player, "Gamepass." .. tostring(name), true)
				self:handleGamepassCallbacks(player, name)
				self.Client.OnGamepassPurchase:Fire(player, name)
			end
		end
	end
end

return MonetizationService
