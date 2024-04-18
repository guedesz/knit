--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local Color = Knit:GetModule("Color")
local Promise = Knit:GetModule("Promise")
local Constants = Knit:GetModule("Constants")
local ToRichText = Knit:GetModule("ToRichText")

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local AudioController, UIController, MessageService, DataController
-- // CONSTS
local MessagesHolder
local MessageController = Knit.CreateController({ Name = "MessageController" })

function MessageController:KnitInit() end

function MessageController:KnitStart()
	AudioController = Knit.GetController("AudioController")
	UIController = Knit.GetController("UIController")
	MessageService = Knit.GetService("MessageService")
	DataController = Knit.GetController("DataController")

	MessageService.MessagePlayerChat:Connect(function(message, color)
		self:FireMessageInChat(message, color)
	end)

	MessageService.MessagePlayer:Connect(function(message, color, delay, sound)
		self:DisplaySoundMessage(message, color, delay, sound)
	end)

end

function MessageController:DisplayErrorMessage(message)
	self:DisplaySoundMessage(message, Color3.new(1, 0, 0), 2, "Error2")
end

function MessageController:DisplaySuccessMessage(message)
	self:DisplaySoundMessage(message, Color3.new(0, 1, 0), 2, "GoldPurchase")
end

function MessageController:DisplaySoundMessage(message, color, duration, sound)
	if not message then
		return
	end

	if sound then
		AudioController:Play(sound)
	end

	self:DisplayMessage(message, color, duration)
end

local tweens = {}

function MessageController:DisplayMessage(message, color, duration)
	if not MessagesHolder then
		MessagesHolder = UIController:GetHolder("Gui", "Messages")
	end

	if message then

		local hasTextAlready: TextLabel = MessagesHolder:FindFirstChild(message)

		if hasTextAlready then
			
			local amount = hasTextAlready:GetAttribute("Amount")

			if amount == nil then
				hasTextAlready:SetAttribute("Amount", 2)
			else
				hasTextAlready:SetAttribute("Amount", amount + 1)
			end

			hasTextAlready.Text = message .. " (x" .. hasTextAlready:GetAttribute("Amount") .. ")"
			return
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Text = message
		textLabel.Name = message
		textLabel.TextColor3 = color or Color3.fromRGB(247, 0, 255)
		textLabel.Font = Enum.Font.FredokaOne
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true

		-- Adiciona o UIStroke
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color:GetDarkerColor(color or Color3.fromRGB(247, 0, 255), 0.67)
		uiStroke.Thickness = 2
		uiStroke.Parent = textLabel

		textLabel.Size = UDim2.new(1, 0, 0.1, 0)
		textLabel.Parent = MessagesHolder

		if duration then
			task.delay(duration, function()
				-- Animação para tornar o texto e o UIStroke transparentes
				TweenService:Create(textLabel, TweenInfo.new(1), { TextTransparency = 1 }):Play()
				TweenService:Create(uiStroke, TweenInfo.new(1), { Transparency = 1 }):Play()
				task.wait(1.1)
				textLabel:Destroy()
			end)
			return
		end

		task.delay(1.5, function()
			-- Animação para tornar o texto e o UIStroke transparentes
			TweenService:Create(textLabel, TweenInfo.new(1), { TextTransparency = 1 }):Play()
			TweenService:Create(uiStroke, TweenInfo.new(1), { Transparency = 1 }):Play()
			task.wait(1.1)
			textLabel:Destroy()
		end)
	end
end

return MessageController
