local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Format = Knit:GetModule("Format")
local Tween = Knit:GetModule("Tween")
local Promise = Knit:GetModule("Promise")
local UnitsData = Knit:GetMetaData("Units")
local GoldMachineData = Knit:GetMetaData("GoldMachine")
local VoidMachineData = Knit:GetMetaData("VoidMachine")

-- // KNIT SERVICES

-- // CONSTS
local LAYOUUT_EQUIPPED = 999999

local Units = {}
Units.__index = Units
Units.Objects = {}

function Units.new(_uiController, _dataController, _messageController)
	local self = setmetatable({}, Units)
	self._Maid = Maid.new()
	self.ForceInit = true
	self._UIController = _uiController
	self._DataController = _dataController
	self.DataFolder = _dataController:GetReplicationFolder()
	self._MessageController = _messageController

	self.Type = "Gui"
	self.Name = "Units"

	--self.Gui = nil
	self.Hud = nil
	self.Gui = nil

	self.IsInit = false
	self.IsStart = false

	return self
end

function Units:init()
	self.Hud = self._UIController:GetHolder("Hud", "Units")
	self.Gui = self._UIController:GetHolder("Gui", "Units")

	if not self.Gui then
		warn("error while init in: ", self.Name)
		return false
	end

	self.Holder = self.Gui.Holder
	self.ScrollingFrame = self.Holder:WaitForChild("ScrollingFrame")
	self.Bottom = self.Holder:WaitForChild("Bottom")

	self.EquippedPets = {}
	self.EquippedFrames = {}
	self.Connections = {}

	self.IsInit = true

	return true
end

function Units:start()
	self.UnitsService = Knit.GetService("UnitsService")
	self.UnitsController = Knit.GetController("UnitsController")

	self.UnitsService.OnUnitRemoved:Connect(function(unitId)
		self:loadInventory()
	end)

	self.UnitsService.OnNewUnitCreated:Connect(function(id, unitName)
		self:loadUnit(id, unitName)
	end)

	self._UIController:MouseEnterScale(self.Hud.Activation, self.Hud.UIScale)
	self._UIController:MouseLeaveScale(self.Hud.Activation, self.Hud.UIScale)

	self._UIController:Activated(self.Hud.Activation, function()
		self:open()
	end)

	self._UIController:MouseEnterScale(self.Holder.Close, self.Holder.Close.UIScale)
	self._UIController:MouseLeaveScale(self.Holder.Close, self.Holder.Close.UIScale)

	self._UIController:Activated(self.Holder.Close, function()
		self:close()
	end)

	self:loadTopButtons()
	self:loadInventory()

	self.IsStart = true
end

function Units:loadTopButtons()
	self._UIController:MouseEnterScale(self.Holder.UnquipAll.Activation, self.Holder.UnquipAll.UIScale)
	self._UIController:MouseLeaveScale(self.Holder.UnquipAll.Activation, self.Holder.UnquipAll.UIScale)

	self._UIController:Activated(self.Holder.UnquipAll.Activation, function()
		self.UnitsService:OnUnquipAllRequest():andThen(function(result, message)
			if not result then
				return self._MessageController:DisplayErrorMessage(message)
			end

			for petId, v in self.EquippedPets do
				v.LayoutOrder += LAYOUUT_EQUIPPED
				v.isEquipped.Visible = false
				v = nil

				self.EquippedPets[petId] = nil
			end

			self:updateMaxEquipped()
			
			--self:loadInventory()
		end)
	end)

	local canClick = true
	-- equip best button
	self._UIController:MouseEnterScale(self.Holder.EquipBest.Activation, self.Holder.EquipBest.UIScale)
	self._UIController:MouseLeaveScale(self.Holder.EquipBest.Activation, self.Holder.EquipBest.UIScale)

	self._UIController:Activated(self.Holder.EquipBest.Activation, function()
		if not canClick then
			return
		end
		self.UnitsService:OnEquipBestRequest():andThen(function(result, message)
			if not result then
				return self._MessageController:DisplayErrorMessage(message)
			end

			self:updateMaxEquipped()
		end)

		task.wait(0.5)
		canClick = true
	end)
end

function Units:onEquipped(unitId)
	if not self.EquippedPets[unitId] then
		local frame = self.ScrollingFrame:FindFirstChild(unitId)

		if not frame then
			return
		end

		frame.LayoutOrder -= LAYOUUT_EQUIPPED
		frame.isEquipped.Visible = true

		self.EquippedPets[unitId] = frame
	end
end

function Units:onUnquipped(unitId)
	local frame = self.EquippedPets[unitId]

	if frame then
		frame = self.ScrollingFrame:FindFirstChild(unitId)
	end

	if not frame then
		return
	end

	frame.LayoutOrder += LAYOUUT_EQUIPPED
	frame.isEquipped.Visible = false
	frame = nil

	self.EquippedPets[unitId] = nil
end

function Units:clearInventory()
	for _, v in self.Connections do
		v:Disconnect()
		v = nil
	end

	for _, v in self.ScrollingFrame:GetChildren() do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end

	self.PetsIn = 0
end

function Units:updateMaxInventory()
	local maxInventory = self.DataFolder:WaitForChild("Units"):GetAttribute("MaxUnitsInventory")
	self.Bottom.MaxInventory.TextLabel.Text = self.PetsIn .. "/" .. maxInventory

	--local button = self.Holder.Bottom.Frame.MaxInventory.Purchase

	-- if self.DataFolder:WaitForChild("Gamepass"):GetAttribute("Plus25Pet") and self.DataFolder.Gamepass:GetAttribute("Plus100Pet") then
	-- 	button.Visible = false
	-- end

end

function Units:updateMaxEquipped(equippedPets: {})
	if equippedPets == nil then
		equippedPets = self.DataFolder:WaitForChild("Units").Equippeds:GetChildren()
	end

	local maxEquipped = self.DataFolder.Units:GetAttribute("MaxUnitsEquipped")
	self.Bottom.MaxEquipped.TextLabel.Text = #equippedPets .. "/" .. maxEquipped
end

function Units:loadInventory()
	self:clearInventory()

	local equippedUnits = self.UnitsController:getEquippedUnits(Knit.LocalPlayer)

	for _, unit: Folder in self.DataFolder:WaitForChild("Units").List:GetChildren() do
		local unitId = unit.Name
		self:loadUnit(unitId, unit:GetAttribute("Name"), unit)
	end

	self:updateMaxEquipped(equippedUnits)
	self:updateMaxInventory()
end

function Units:loadUnit(unitId, unitName, unitFolder)
	if self.ScrollingFrame:FindFirstChild(unitId) then
		return
	end

	if not unitFolder then
		unitFolder = self.DataFolder:WaitForChild("Units").List:FindFirstChild(unitId)
	end

	local equippedPets = self.UnitsController:getEquippedUnits(Knit.LocalPlayer)

	local petInfo = UnitsData:getUnitByName(unitName)
	local frame = Knit:GetAsset("UnitInventoryTemplate")

	local petBonus = petInfo.Damage

	local imageId = 0

	if unitFolder:GetAttribute("isGolden") then
		frame.isGolden.Visible = true
		petBonus *= GoldMachineData.MULTIPLIER_GOLD_PET
		imageId = petInfo.GoldImage
	elseif unitFolder:GetAttribute("isVoid") then
		frame.isVoid.Visible = true
		petBonus *= VoidMachineData.MULTIPLIER_GOLD_PET
		imageId = petInfo.VoidImage
	elseif unitFolder:GetAttribute("isHuge") then
		frame.isHuge.Visible = true
		--petBonus *= HugeMachineData.MULTIPLIER_GOLD_PET
		imageId = petInfo.HugeImage
	else
		imageId = petInfo.ImageId
	end

	frame.ImageLabel.Image = "rbxassetid://" .. (imageId or petInfo.ImageId)
	-- local upgradeAmount = self.DataFolder:WaitForChild("Upgrades"):GetAttribute("Pet")

	-- if upgradeAmount > 0 then
	-- 	petBonus += petBonus * (Constants.BONUS_PER_UPGRADE * upgradeAmount)
	-- end
	frame.LayoutOrder -= petInfo.Damage * 1000

	local isEquipped = false
	if table.find(equippedPets, unitId) then
		frame.LayoutOrder -= LAYOUUT_EQUIPPED
		frame.isEquipped.Visible = true
		isEquipped = true
		self.EquippedPets[unitId] = frame
	end

	local gradient = Knit:GetAsset(petInfo.Rarity.Name .. "Gradient")
	gradient.Parent = frame

	frame.Bonus.Text = "+" .. string.format("%.2f", petBonus)

	frame.Name = unitId

	table.insert(self.Connections, self._UIController:MouseEnterScale(frame.Activation, frame.UIScale, true))
	table.insert(self.Connections, self._UIController:MouseLeaveScale(frame.Activation, frame.UIScale, true))

	table.insert(
		self.Connections,
		self._UIController:MouseEnter(frame.Activation, function()
			Tween.Play(frame.ImageLabel, { 0.25 }, { Rotation = -15 })
		end, true)
	)

	table.insert(
		self.Connections,
		self._UIController:MouseLeave(frame.Activation, function()
			Tween.Play(frame.ImageLabel, { 0.25 }, { Rotation = 0 })
		end, true)
	)

	table.insert(
		self.Connections,
		self._UIController:Activated(frame.Activation, function()
			if self.IsDeleteMenuOpen then
				return self:onPetSelectedWithDelete(frame)
			end

			if frame.isEquipped.Visible then
				return self.UnitsService:OnUnitUnquipRequest(unitId):andThen(function(result, message)
					if not result then
						return self._MessageController:DisplayErrorMessage(message)
					end

					frame.LayoutOrder += LAYOUUT_EQUIPPED
					self._MessageController:DisplaySoundMessage("", Color3.fromRGB(255, 166, 0), 2, "Equip")
					self:updateMaxEquipped()
				end)
			end

			return self.UnitsService:OnUnitEquipRequest(unitId):andThen(function(result, message)
				if not result then
					return self._MessageController:DisplayErrorMessage(message)
				end

				frame.LayoutOrder -= LAYOUUT_EQUIPPED
				self:updateMaxEquipped()
				self._MessageController:DisplaySoundMessage("", Color3.fromRGB(255, 166, 0), 2, "Equip")
			end)
		end, true)
	)

	frame.Parent = self.ScrollingFrame

	self.PetsIn += 1
	self:updateMaxInventory()
end

function Units:open()
	self._UIController:openGui(self.Gui)
end

function Units:close()
	self._UIController:closeGui(self.Gui)
end

function Units:destroy() end

return Units
