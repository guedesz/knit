--//SERVICES
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local UnitsData = Knit:GetMetaData("Units")
local Tween = Knit:GetModule("Tween")
local Color = Knit:GetModule("Color")
local ConfettiCreator = Knit:GetModule("ConfettiCreator")
local MonetizationIds = Knit:GetModule("MonetizationIds")
local GetDevice = Knit:GetModule("GetDevice")
local Format = Knit:GetModule("Format")
local ThemesData = Knit:GetMetaData("Themes")

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local UIController, EggService, MessageController, AudioController, MonetizationCotroller, DataController, UnitsController
 
-- // CONSTS
local DISTANCE_TO_OPEN = 7
local SINGLE_ACTION_NAME = "EggSingleHatching"
local AUTO_ACTION_NAME = "EggAuto"
local TRIPLE_ACTION_NAME = "EggTripleHatching"

local EGGS = CollectionService:GetTagged("Egg")

local EggController = Knit.CreateController({ Name = "EggController" })

EggController.Connections = {}
EggController.LuckConnections = {}
EggController.EggsLoaded = {}
EggController.PetsDeletedPerEgg = {}
EggController.AutoHatchingEgg = nil
EggController.AutoHatchingEggConnection = nil
EggController.BillboardOpen = nil
EggController.EggOpened = nil

EggController.Eggs = {}
EggController.EggsByWorldConnection = {}
EggController.EggsPreLoaded = {}

function EggController:KnitInit() end

function EggController:KnitStart()
	UIController = Knit.GetController("UIController")
	EggService = Knit.GetService("EggService")
	MessageController = Knit.GetController("MessageController")
	AudioController = Knit.GetController("AudioController")
	MonetizationCotroller = Knit.GetController("MonetizationController")
	DataController = Knit.GetController("DataController")
    UnitsController = Knit.GetController("UnitsController")

	self.DataFolder = DataController:GetReplicationFolder()

	for _, egg in EGGS do
		local world = egg:GetAttribute("Theme")

		if self.Eggs[world] == nil then
			self.Eggs[world] = {}
		end

		table.insert(self.Eggs[world], egg)
		-- task.spawn(function()
		-- 	self:loadEgg(egg)
		-- end)
	end

    EggService.OnServerOpenedSixEgg:Connect(function(eggName, pets)
		self:onSixEggOpenAnimation(eggName, pets)
	end)

	EggService.OnServerOpenedEgg:Connect(function(eggName, petName)
		self:onEggOpenAnimation(eggName, petName)
	end)

	EggService.OnServerOpenedTripleEgg:Connect(function(eggName, pets: {})
		self:onTripleEggOpenAnimation(eggName, pets)
	end)

	Knit.LocalPlayer:GetAttributeChangedSignal("AutoHatching"):Connect(function()
		if not Knit.LocalPlayer:GetAttribute("AutoHatching") then
			if self.AutoHatchingEggConnection then
				self:disableAutoHatching()
			end
		else
			self:enableAutoHatching()
		end
	end)

	self:loadHatchers()


    -- TODO unlock new hatchers when player level up

end

function EggController:loadHatchers()

    local level = self.DataFolder:WaitForChild("Data"):GetAttribute("Level")

    local themeName, info = ThemesData:getThemeByLevel(level)

	-- local world = Knit.LocalPlayer:GetAttribute("CurrentlyWorld")

	-- if not world then
	-- 	return
	-- end

	-- for _, v in self.EggsByWorldConnection do
	-- 	v:Disconnect()
	-- 	v = nil
	-- end

	local eggs = self.Eggs[themeName]

	for _, egg in eggs do
        print(egg)

		self:loadEgg(egg)
	end
end

function EggController:loadEgg(egg: Model)

	local eggInfo = UnitsData:getEggInfoByName(egg.Name)

	if not self.EggsPreLoaded[egg] then
		
		if not eggInfo then
			return
		end

		if not egg.PrimaryPart then
			repeat
				task.wait()
			until egg.PrimaryPart
		end

		if eggInfo.Price then
			local price = Knit:GetAsset("EggPrice")
			price.Parent = egg.PrimaryPart
			price.TextLabel.Text = Format:Abbrievate(eggInfo.Price)
		end

		self.Connections[egg.Name] = {}
		self.LuckConnections[egg.Name] = {}

		local billboard = Knit:GetAsset("EggHatcherBillboard")
		billboard.MainFrame.EggName.Text = eggInfo.Name

		self.EggsPreLoaded[egg] = billboard

		if eggInfo.Type == "Robux" then
			local info = MonetizationCotroller:GetProductInfo(MonetizationIds.DevProducts.Eggs[egg.Name])

			local text = "ROBUX"

			if info then
				text = info.PriceInRobux
			end

			local price = Knit:GetAsset("EggRobuxPrice")
			price.Parent = egg.PrimaryPart
			price.TextLabel.Text = info.PriceInRobux

			billboard.MainFrame.PetsFrame.EggPrice.Text = text
			local image = billboard.MainFrame.PetsFrame.EggPrice:FindFirstChild("ImageLabel")
			image.Image = "rbxassetid://16269172357"
		else
			billboard.MainFrame.PetsFrame.EggPrice.Text = Format:Abbrievate(eggInfo.Price)
		end

		billboard.Adornee = egg
		billboard.Name = egg.Name
		billboard.Parent = Knit.PlayerGui
	end

	local IS_OPEN = false

	table.insert(
		self.EggsByWorldConnection,
		RunService.Heartbeat:Connect(function(deltaTime)
			if not Knit.LocalPlayer.Character or not egg.PrimaryPart or not Knit.LocalPlayer.Character.PrimaryPart then
				return
			end

			if
				(Knit.LocalPlayer.Character.PrimaryPart.Position - egg.PrimaryPart.Position).Magnitude
				> DISTANCE_TO_OPEN
			then
				if IS_OPEN then
					IS_OPEN = false
					self:closeBillboard(self.EggsPreLoaded[egg], egg.Name)
				end

				return
			end

			if IS_OPEN then
				return
			end

			IS_OPEN = true
			self:openBillboard(self.EggsPreLoaded[egg], egg.Name, eggInfo)
		end)
	)
end

function EggController:closeBillboard(billboard, eggName, eggInfo)
	for Name, v in self.Connections[eggName] do
		if Name == "single" then
			continue
		end

		v:Disconnect()
		v = nil
	end

	self.Connections[eggName] = {}

	Tween.Play(billboard, { 0.2, Enum.EasingStyle.Linear }, { Size = UDim2.fromScale(0, 0) }, true)
	billboard.Enabled = false

	ContextActionService:UnbindAction(SINGLE_ACTION_NAME)
	ContextActionService:UnbindAction(AUTO_ACTION_NAME)
	ContextActionService:UnbindAction(TRIPLE_ACTION_NAME)

	-- force disable auto
	self:onAutoHatchingRequest(billboard.MainFrame.ButtonsFrame.AutoBuyFrame.Activation, true)
end

function EggController:updateLuckChance(chance)
	local luck = 1

	-- Verifica se o gamepass Luck está ativado
	local luck = 1

	-- Verifica se o gamepass Luck está ativado
	if self.DataFolder:WaitForChild("Gamepass"):GetAttribute("Luck") then
		luck += 1
	end

	-- Verifica se o gamepass SuperLuck está ativado
	if self.DataFolder.Gamepass:GetAttribute("SuperLuck") then
		luck += 1
	end

	-- Verifica se o gamepass MegaLuck está ativado
	if self.DataFolder.Gamepass:GetAttribute("MegaLuck") then
		luck += 2
	end

	-- Verifica se há uma poção de sorte ativa
	if self.DataFolder.Potions.Timer:GetAttribute("LuckyPotion") > 0 then
		luck += 1
	end

	return chance * luck
end

function EggController:openBillboard(billboard, eggName, eggInfo)
	self.BillboardOpen = billboard
	self.EggOpened = eggName

	Tween.Play(billboard, { 0.2, Enum.EasingStyle.Linear }, { Size = UDim2.fromScale(13, 13) }, true)

	local buttonFrames = billboard.MainFrame.ButtonsFrame

	if not self.EggsLoaded[eggName] then
		task.spawn(function()
			if GetDevice.IsPhone() or GetDevice.IsTablet() then
				buttonFrames.Hatch3Frame.Activation.Text = "Open 3"
				buttonFrames.BuyFrame.Activation.Text = "Open 1"
				buttonFrames.AutoBuyFrame.Activation.Text = "Auto Open"
			elseif GetDevice.IsXbox() then
				buttonFrames.Hatch3Frame.Activation.Text = "Open 3 (Y)"
				buttonFrames.BuyFrame.Activation.Text = "Open 1 (X)"
				buttonFrames.AutoBuyFrame.Activation.Text = "Auto Open (B)"
			elseif GetDevice.IsPlayStation() then
				buttonFrames.Hatch3Frame.Activation.Text = "Open 3 (Triangle)"
				buttonFrames.BuyFrame.Activation.Text = "Open 1 (Square)"
				buttonFrames.AutoBuyFrame.Activation.Text = "Auto Open (Circle)"
			end
		end)

		for _, v in self.Connections[eggName] do
			v:Disconnect()
			v = nil
		end

		for _, v in billboard.MainFrame.PetsFrame.Frame:GetChildren() do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end

		self.PetsDeletedPerEgg[eggName] = {}

		for petName, pet in eggInfo.List do
			local frame = Knit:GetAsset("HatcherPetFrameTemplate").Pet

			local gradient = Knit:GetAsset(pet.Rarity.Name .. "Gradient")
			gradient.Parent = frame

            UnitsController:SetViewportFrameRender(frame.ViewportFrame, petName)

			
			local chance = frame.ViewportFrame:FindFirstChild("chance")

			local realChance = pet.Chance

			if pet.Lucky then
				if pet.DisplayRarity then
					realChance = pet.DisplayRarity
				end

				realChance = string.format("%.2f", self:updateLuckChance(realChance))
			end

			chance.Text = realChance .. "%"

			frame.LayoutOrder = -pet.Chance

			local bonus = frame.ViewportFrame:FindFirstChild("bonus")

			local amount = pet.Damage

			bonus.Text = "x" .. string.format("%.2f", amount)

			local stroke = frame.ViewportFrame:FindFirstChild("UIStroke")
			stroke.Color = Color:GetDarkerColor(pet.Rarity.Color)

			frame.Name = petName
			frame.Parent = billboard.MainFrame.PetsFrame.Frame

			self.Connections[eggName]["single"] = UIController:Activated(frame.ViewportFrame.Activation, function()
				if frame.ViewportFrame.toDelete:GetAttribute("visible") then
					Tween.Play(frame.ViewportFrame.toDelete.UIScale, { 0.2 }, { Scale = 0 })
					frame.ViewportFrame.toDelete:SetAttribute("visible", false)
					self.PetsDeletedPerEgg[eggName][frame.Name] = nil
				else
					if eggInfo.Type == "Robux" then
						return
					end

					frame.ViewportFrame.toDelete:SetAttribute("visible", true)
					Tween.Play(frame.ViewportFrame.toDelete.UIScale, { 0.2 }, { Scale = 1 })
					self.PetsDeletedPerEgg[eggName][frame.Name] = true
				end
			end, true)
		end

		if self.DataFolder:WaitForChild("Gamepass"):GetAttribute("InstantEggOpen") then
			billboard.MainFrame.InstantEgg.Visible = false
		else
			self.Connections[eggName]["Instant"] = UIController:Activated(
				billboard.MainFrame.InstantEgg.Activation,
				function()
					MarketplaceService:PromptGamePassPurchase(Knit.LocalPlayer, MonetizationIds.Gamepass.InstantEggOpen)
				end,
				true
			)
		end

		if self.DataFolder:WaitForChild("Gamepass"):GetAttribute("MagicEggs") then
			billboard.MainFrame.MagicEggs.Visible = false
		else
			self.Connections[eggName]["Magic"] = UIController:Activated(
				billboard.MainFrame.MagicEggs.Activation,
				function()
					MarketplaceService:PromptGamePassPurchase(Knit.LocalPlayer, MonetizationIds.Gamepass.MagicEggs)
				end,
				true
			)
		end

		self:updateLuck(billboard.MainFrame, eggName)

		self.EggsLoaded[eggName] = true
	end

	self.Connections[eggName]["singleHatch"] = UIController:Activated(buttonFrames.BuyFrame.Activation, function()
		self:onSingleOpenRequest(eggName)
	end, true)

	self.Connections[eggName]["singleEnter"] =
		UIController:MouseEnterScale(buttonFrames.BuyFrame.Activation, buttonFrames.BuyFrame.UIScale, true)
	self.Connections[eggName]["singleLeave"] =
		UIController:MouseLeaveScale(buttonFrames.BuyFrame.Activation, buttonFrames.BuyFrame.UIScale, true)

	self.Connections[eggName]["auto"] = UIController:Activated(buttonFrames.AutoBuyFrame.Activation, function()
		self:onAutoHatchingRequest(buttonFrames.AutoBuyFrame.Activation)
	end, true)

	self.Connections[eggName]["autoEnter"] =
		UIController:MouseEnterScale(buttonFrames.AutoBuyFrame.Activation, buttonFrames.AutoBuyFrame.UIScale, true)
	self.Connections[eggName]["autoLeave"] =
		UIController:MouseLeaveScale(buttonFrames.AutoBuyFrame.Activation, buttonFrames.AutoBuyFrame.UIScale, true)

	local function openTriple(_, input)
		if input == Enum.UserInputState.Begin then
			self:onTripleHatchingRequest(eggName)
		end
	end

	self.Connections[eggName]["hatch3Enter"] =
		UIController:MouseEnterScale(buttonFrames.Hatch3Frame.Activation, buttonFrames.Hatch3Frame.UIScale, true)
	self.Connections[eggName]["hatch3Leave"] =
		UIController:MouseLeaveScale(buttonFrames.Hatch3Frame.Activation, buttonFrames.Hatch3Frame.UIScale, true)

	ContextActionService:BindAction(TRIPLE_ACTION_NAME, openTriple, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonY)

	self.Connections[eggName]["hatch3Frame"] = UIController:Activated(buttonFrames.Hatch3Frame.Activation, function()
		self:onTripleHatchingRequest(eggName)
	end, true)

	local function openSingle(_, input)
		if input == Enum.UserInputState.Begin then
			self:onSingleOpenRequest(eggName)
		end
	end

	local function openAuto(_, input)
		if input == Enum.UserInputState.Begin then
			self:onAutoHatchingRequest(buttonFrames.AutoBuyFrame.Activation)
		end
	end

	ContextActionService:BindAction(SINGLE_ACTION_NAME, openSingle, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
	ContextActionService:BindAction(AUTO_ACTION_NAME, openAuto, false, Enum.KeyCode.F, Enum.KeyCode.ButtonB)

	billboard.Enabled = true
end

function EggController:updateAllLucks()
	for eggName, connections: {} in self.LuckConnections do
		if #connections <= 0 then
			continue
		end

		local frame = Knit.PlayerGui:FindFirstChild(eggName)

		if not frame then
			continue
		end
		self.EggsLoaded[eggName] = nil

		if self.BillboardOpen == frame then
			local eggInfo = UnitsData:getEggInfoByName(eggName)

			if not eggInfo then
				return
			end

			self:openBillboard(frame, eggName, eggInfo)
		end

		self:updateLuck(frame.MainFrame, eggName)
	end
end

function EggController:updateLuck(MainFrame: Frame, eggName)
	self.LuckConnections[eggName] = {}

	local luckFrames = MainFrame:WaitForChild("LuckFrames")

	for _, v in luckFrames:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end

		table.insert(self.LuckConnections[eggName], UIController:MouseEnterScale(v.Activation, v.UIScale, true))
		table.insert(self.LuckConnections[eggName], UIController:MouseLeaveScale(v.Activation, v.UIScale, true))
	end

	if self.DataFolder:WaitForChild("Gamepass"):GetAttribute("Luck") then
		if self.DataFolder.Gamepass:GetAttribute("SuperLuck") then
			luckFrames.Luck3.block.Visible = false

			if not self.DataFolder.Gamepass:GetAttribute("MegaLuck") then
				table.insert(
					self.LuckConnections[eggName],
					UIController:Activated(luckFrames.Luck3.Activation, function()
						MonetizationCotroller:PromptGamepassPurchase("MegaLuck")
					end, true)
				)
			end
		else
			luckFrames.Luck2.block.Visible = false

			table.insert(
				self.LuckConnections[eggName],
				UIController:Activated(luckFrames.Luck2.Activation, function()
					MonetizationCotroller:PromptGamepassPurchase("SuperLuck")
				end, true)
			)
		end
	else
		table.insert(
			self.LuckConnections[eggName],
			UIController:Activated(luckFrames.LuckGamepass.Activation, function()
				MonetizationCotroller:PromptGamepassPurchase("Luck")
			end, true)
		)
	end
end

function EggController:onSingleOpenRequest(eggName)
	if Knit.LocalPlayer:GetAttribute("EventAutoHatch") then
		return
	end

	if Knit.LocalPlayer:GetAttribute("OpeningEgg") then
		return
	end

	EggService:OnEggOpenRequest(eggName, self.PetsDeletedPerEgg[eggName]):andThen(function(result, message, isDeleted, magicType)
		if not result then
			return MessageController:DisplayErrorMessage(message)
		end

		-- message == petName
		self:onEggOpenAnimation(eggName, message, isDeleted, nil, nil, magicType)
	end)
end

function EggController:onTripleHatchingRequest(eggName)
	if Knit.LocalPlayer:GetAttribute("EventAutoHatch") then
		return
	end

	if Knit.LocalPlayer:GetAttribute("OpeningEgg") then
		return
	end

	EggService:OnTripleEggOpenRequest(eggName, self.PetsDeletedPerEgg[eggName]):andThen(function(success, result)
		if not success then
			return MessageController:DisplayErrorMessage(result)
		end

		local pets = result

		self:onTripleEggOpenAnimation(eggName, pets)
	end)
end

function EggController:onAutoHatchingRequest(button, forceDisable)
	if forceDisable then
		Knit.LocalPlayer:SetAttribute("AutoHatching", false)
		self:disableAutoHatching()

		button.BackgroundColor3 = Color3.fromRGB(230, 0, 4)
		return
	end

	if not self.DataFolder:WaitForChild("Gamepass"):GetAttribute("AutoEggOpen") then
		return MarketplaceService:PromptGamePassPurchase(Knit.LocalPlayer, MonetizationIds.Gamepass.AutoEggOpen)
	end

	if not self.EggOpened then
		return
	end

	if Knit.LocalPlayer:GetAttribute("EventAutoHatch") then
		return
	end

	local eggInfo = UnitsData:getEggInfoByName(self.EggOpened)

	if self.DataFolder:WaitForChild("Data"):GetAttribute("Wins") < eggInfo.Price then
		return false, "You don't have enough wins to purchase " .. eggInfo.Name
	end

	if Knit.LocalPlayer:GetAttribute("AutoHatching") then
		Knit.LocalPlayer:SetAttribute("AutoHatching", false)
		button.BackgroundColor3 = Color3.fromRGB(230, 0, 4)
	else
		if
			#self.DataFolder:WaitForChild("Units").List:GetChildren()
			== self.DataFolder.Units:GetAttribute("MaxUnitsInventory")
		then
			return
		end

		Knit.LocalPlayer:SetAttribute("AutoHatching", true)
		button.BackgroundColor3 = Color3.fromRGB(0, 230, 12)
	end
end

function EggController:disableAutoHatching()
	if self.AutoHatchingEggConnection then
		self.AutoHatchingEggConnection:Disconnect()
		self.AutoHatchingEggConnection = nil
	end

	self.BillboardOpen.MainFrame.ButtonsFrame.AutoBuyFrame.Activation.BackgroundColor3 = Color3.fromRGB(230, 0, 4)
end

function EggController:enableAutoHatching()
	if
		#self.DataFolder:WaitForChild("Units").List:GetChildren() == self.DataFolder.Units:GetAttribute("MaxUnitsInventory")
	then
		return
	end

	self.AutoHatchingEggConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if Knit.LocalPlayer:GetAttribute("OpeningEgg") then
			return
		end

		if self.DataFolder.Gamepass:GetAttribute("TripleHatch") then
			if #self.DataFolder.Units.List:GetChildren() + 3 <= self.DataFolder.Units:GetAttribute("MaxUnitsInventory") then
				return self:onTripleHatchingRequest(self.EggOpened)
			end

			if #self.DataFolder.Units.List:GetChildren() + 1 <= self.DataFolder.Units:GetAttribute("MaxUnitsInventory") then
				return self:onSingleOpenRequest(self.EggOpened)
			end
			Knit.LocalPlayer:SetAttribute("AutoHatching", false)
			self:disableAutoHatching()
			MessageController:DisplayErrorMessage("Your backpack is full!")
			return
		end

		if #self.DataFolder.Units.List:GetChildren() + 1 > self.DataFolder.Units:GetAttribute("MaxUnitsInventory") then
			MessageController:DisplayErrorMessage("Your backpack is full!")
			Knit.LocalPlayer:SetAttribute("AutoHatching", false)
			self:disableAutoHatching()
			return
		end

		self:onSingleOpenRequest(self.EggOpened)
	end)
end

function EggController:onEggOpenAnimation(eggName, petName, isDeleted, holderNumber, isSix, magycType)
	local holder = UIController:GetHolder("Gui", "Hatching")

	if not self.DataFolder:WaitForChild("Gamepass"):GetAttribute("InstantEggOpen") then
		local eggInfo = UnitsData:getEggInfoByName(eggName)
		local eggImageId = "rbxassetid://" .. eggInfo.ImageId

		local holderName

		if isSix then
			holderName = "EggSixImageTemplate"
		else
			holderName = "EggImageTemplate"
		end

		if holderNumber then
			holderName = holderName .. holderNumber
		else
			holderName = "EggImageTemplate1"
		end

		local clone = holder[holderName]:Clone()
		clone.Parent = holder
		clone.Visible = true
		clone.Image = eggImageId
		clone.Rotation = 0

		holder.Visible = true

		AudioController:Play("EggCracking2")
		Tween.Play(clone, { 0.2 }, { Rotation = 20 }, true)
		task.wait(0.3)
		AudioController:Play("EggCracking2")
		Tween.Play(clone, { 0.2 }, { Rotation = -20 }, true)
		task.wait(0.3)
		AudioController:Play("EggCracking2")
		Tween.Play(clone, { 0.2 }, { Rotation = 20 }, true)
		task.wait(0.3)

		for i = 1, 5 do
			local rotation = 20

			if i % 2 == 0 then
				rotation = -20
			end

			AudioController:Play("EggCracking2")

			Tween.Play(clone, { 0.05 }, { Rotation = rotation }, true)
		end

		Tween.Play(clone.UIScale, { 0.2 }, { Scale = 1.2 })
		Tween.Play(clone, { 0.2 }, { ImageTransparency = 1 })

		AudioController:Play("EggCracking")
		AudioController:Play("EggFinish")

		Debris:AddItem(clone, 0.2)
	end

	local petInfo = UnitsData:getUnitByName(petName)

	local holderName = "PetImageTemplate"

	if isSix then
		holderName = "PetSixImageTemplate"
	end

	if holderNumber then
		holderName = holderName .. holderNumber
	else
		holderName = "PetImageTemplate1"
	end

	local petClone = holder[holderName]:Clone()

    UnitsController:SetViewportFrameRender(petClone.ViewportFrame , petName)

	if not holderNumber or holderNumber == 1 then
		ConfettiCreator(UDim2.fromScale(0.9, 0.1))
		ConfettiCreator(UDim2.fromScale(0.8, 0.1))
		ConfettiCreator(UDim2.fromScale(0.7, 0.1))
		ConfettiCreator(UDim2.fromScale(0.3, 0.1))
		ConfettiCreator(UDim2.fromScale(0.2, 0.1))
		ConfettiCreator(UDim2.fromScale(0.1, 0.1))
	end

	local rarity = petClone:FindFirstChild("Rarity")


	local gradientName = rarity.Text

	if magycType == "Void" then
		gradientName = "Void"
		rarity.Text = "VOID"
	elseif magycType == "Gold" then
		gradientName = "Gold"
		rarity.Text = "GOLD"
	else
		rarity.Text = petInfo.Rarity.Name
		gradientName = rarity.Text
	end

	local gradient = Knit:GetAsset(gradientName .. "Gradient")
	gradient.Parent = rarity

	local gradient = Knit:GetAsset(gradientName .. "Gradient")
	gradient.Parent = petClone.RotateImage

	local petName = petClone:FindFirstChild("petName")

	-- means player choose to delete its
	if isDeleted then
		petName.Text = "AUTO DELETE"
		petName.TextColor3 = Color3.fromRGB(255, 0, 0)
	else
		petName.Text = petInfo.Name

		if magycType then
			petName.Text = magycType .. " ".. petInfo.Name
		else
			petName.Text = petInfo.Name
		end
	end

	petClone.Visible = true
	petClone.Parent = holder

	Tween.Play(petClone.UIScale, { 0.2 }, { Scale = 1 })
	Tween.Play(petClone.RotateImage, { 2, Enum.EasingStyle.Linear }, { Rotation = 360 })

	task.wait(2)

	Tween.Play(petClone.RotateImage, { 0.3 }, { ImageTransparency = 1 })
	Tween.Play(petClone.ViewportFrame, { 0.3 }, { ImageTransparency = 1 })
	Tween.Play(petClone.Rarity, { 0.3 }, { TextTransparency = 1 })
	petClone.Rarity.UIStroke.Enabled = false
	petClone.petName.UIStroke.Enabled = false

	Tween.Play(petClone.petName, { 0.3 }, { TextTransparency = 1 })
	Tween.Play(petClone.petName.UIStroke, { 0.3 }, { Thickness = 0 })

	Tween.Play(petClone.UIScale, { 0.2 }, { Scale = 0 })

	Debris:AddItem(petClone, 2.5)
end

function EggController:onSixEggOpenAnimation(eggName, pets)
	
	-- true stands for six hatch on those animations
	for index, pet in pets do
		task.spawn(function()
			self:onEggOpenAnimation(eggName, pet.petName, pet.isDeleted, index, true)
		end)
	end
end

function EggController:onTripleEggOpenAnimation(eggName, pets)
	for index, pet in pets do
		task.spawn(function()
			self:onEggOpenAnimation(eggName, pet.petName, pet.isDeleted, index, false, pet.isMagic)
		end)
	end
end

return EggController