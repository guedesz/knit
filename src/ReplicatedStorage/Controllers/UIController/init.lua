--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local Color = Knit:GetModule("Color")
local Tween = Knit:GetModule("Tween")
local Constants = Knit:GetModule("Constants")
local PlayerGui = Knit.LocalPlayer:WaitForChild("PlayerGui")
--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local DataController, AudioController, MessageController
-- // CONSTS

local UIController = Knit.CreateController({ Name = "UIController" })

function UIController:KnitInit()
	Knit.Hud = Knit.PlayerGui:FindFirstChild("Hud") or PlayerGui:FindFirstChild("Hud", 5)
	Knit.Gui = Knit.PlayerGui:FindFirstChild("Gui") or PlayerGui:FindFirstChild("Gui", 5)
end

UIController.GuiControllers = {}

function UIController:KnitStart()
	DataController = Knit.GetController("DataController")
	AudioController = Knit.GetController("AudioController")
	MessageController = Knit.GetController("MessageController")

	-- load main GUIs under controller
	for _, module in script:GetChildren() do
		local controller = require(module)

		local object = controller.new(self, DataController, MessageController)

		-- force init means it must load without player having to open the frame
		local time = workspace:GetAttribute("Tick") or tick()

		if not object then
			print("error getting object for:", module.Name)
			return
		end

		local success = object:init()

		if not success then
			print("error trying to init:", module.Name)
			return false
		end

		self.GuiControllers[module.Name] = object
	end

	for name, object in self.GuiControllers do
		task.spawn(function()
			if object.IsInit then
				print(name .. " Started!")
				object:start()
			end
		end)
	end

end

function UIController:GetGuiController(name: string)
	return self.GuiControllers[name]
end

function UIController:GetDarkerColor(Color: Color3, Opacity: number): Color3
	return Color:GetDarkerColor(Color, Opacity)
end

function UIController:GetHolder(type: "Hud" | "Gui", holderName: string)
	if not Knit.Hud then
		Knit.Hud = Knit.PlayerGui:FindFirstChild("Hud") or PlayerGui:WaitForChild("Hud", 5)
	end

	if not Knit.Gui then
		Knit.Gui = Knit.PlayerGui:FindFirstChild("Gui") or PlayerGui:WaitForChild("Gui", 5)
	end

	if type == "Hud" then
		return Knit.Hud:WaitForChild(holderName)
	elseif type == "Gui" then
		return Knit.Gui:WaitForChild(holderName)
	end

	print("ERROR GETTING HOLDER", holderName)
	return false
end

function UIController:Activated(button, callback, returnConnection)
	local connection = button.Activated:Connect(function()
		callback()
	end)

	if returnConnection then
		return connection
	end
end

function UIController:MouseEnter(button, callback, returnConnection)
	local connection = button.MouseEnter:Connect(function()
		AudioController:Play("Hover")
		callback()
	end)

	if returnConnection then
		return connection
	end
end

function UIController:MouseLeave(button, callback, returnConnection)
	local connection = button.MouseLeave:Connect(function()
		callback()
	end)

	if returnConnection then
		return connection
	end
end

function UIController:MouseEnterScale(parent: TextButton | ImageButton, scale: UIScale, returnConnection)
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = parent.Parent
	end

	if not AudioController then
		AudioController = Knit.GetController("AudioController")
	end

	AudioController:Play("Hover")

	local a = self:MouseEnter(parent, function()
		Tween.Play(scale, { 0.25 }, { Scale = 1.1 })
	end, returnConnection)

	if returnConnection then
		return a
	end
end

function UIController:MouseLeaveScale(parent: TextButton | ImageButton, scale: UIScale, returnConnection)
	local a = self:MouseLeave(parent, function()
		Tween.Play(scale, { 0.25 }, { Scale = 1 })
	end, returnConnection)

	if returnConnection then
		return a
	end
end

function UIController:closeGui(gui)
	if gui and gui.Visible then
		Tween.Play(
			workspace.CurrentCamera,
			{ 0.2, Enum.EasingStyle.Linear },
			{ FieldOfView = Constants.FieldOfViewClosed }
		)

		-- local holder = gui.Holder
		-- Tween.Play(holder, { 0.05, Enum.EasingStyle.Linear }, { Position = UDim2.fromScale(0.5, 0.45) })

		-- task.wait(.05)

		gui.Visible = false

	end
end

function UIController:openWithoutClosingAll(gui)

	Tween.Play(workspace.CurrentCamera, { 0.2, Enum.EasingStyle.Linear }, { FieldOfView = Constants.FieldOfViewOpen })

	local holder = gui.Holder
	holder.Position = UDim2.fromScale(0.5, 0.45)

	if gui and not gui.Visible then
		gui.Visible = true
	end

	Tween.Play(holder, { 0.1, Enum.EasingStyle.Linear }, { Position = UDim2.fromScale(0.5, 0.5) })
end
function UIController:openGui(gui)

	self:CloseAllFrames()

	Tween.Play(workspace.CurrentCamera, { 0.2, Enum.EasingStyle.Linear }, { FieldOfView = Constants.FieldOfViewOpen })

	local holder = gui.Holder
	holder.Position = UDim2.fromScale(0.5, 0.45)

	if gui and not gui.Visible then
		gui.Visible = true
	end

	Tween.Play(holder, { 0.1, Enum.EasingStyle.Linear }, { Position = UDim2.fromScale(0.5, 0.5) })
end

function UIController:CloseAllFrames()
	for _, guiObject in self.GuiControllers do
		if guiObject.Type == "Gui" then
			guiObject:close()
		end
	end
end

function UIController:removeHud(bypassTable: {})
	for _, v in Knit.Hud:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end

		if #bypassTable > 0 and table.find(bypassTable, v.Name) or v:GetAttribute("Bypass") then
			continue
		end

		v.Visible = false
	end
end

function UIController:enableHud(bypassTable: {})
	for _, v in Knit.Hud:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end

		if #bypassTable > 0 and table.find(bypassTable, v.Name) or v:GetAttribute("Bypass") then
			continue
		end

		v.Visible = true
	end
end

return UIController
