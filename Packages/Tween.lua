--[[
	Very basic tween module
]]

local Tween = {}

-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))

-- Default Tween Settings --
local DefualtTweens = {
	Duration = 1,
	EasingStyle = Enum.EasingStyle.Back,
	EasingDirection = Enum.EasingDirection.Out,
	Repeat = 0,
	Reverse = false,
	Delay = 0,
}

local Maid = Knit:GetModule('Maid')

------------------- PRIVATE FUNCTIONS -------------------

local function GetTweenInfo(Tweeninfo): TweenInfo
	local Duration = Tweeninfo[1] or DefualtTweens.Duration
	local EasingStyle = Tweeninfo[2] or DefualtTweens.EasingStyle
	local EasingDirection = Tweeninfo[3] or DefualtTweens.EasingDirection
	local Repeat = Tweeninfo[4] or 0
	local Reverse = Tweeninfo[5] or false
	local Delay = Tweeninfo[6] or 0

	return TweenInfo.new(Duration, EasingStyle, EasingDirection, Repeat, Reverse, Delay)
end

------------------- PUBLIC METHODS -------------------

function Tween.TweenModel(Model, TweenInfo, Props)
	local Tweeninfo = GetTweenInfo(TweenInfo)
	local TweenMaid = Maid.new()

	local CFrameValue = TweenMaid:GiveTask(Instance.new("CFrameValue"))
	CFrameValue.Value = Model:GetPivot()
	TweenMaid:GiveTask(CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		Model:PivotTo(CFrameValue.Value)
	end))

	local CurrentTween = TweenService:Create(CFrameValue, Tweeninfo, {
		Value = Props.CFrame,
	})

	TweenMaid:GiveTask(CurrentTween)
	CurrentTween:Play()

	CurrentTween.Completed:Wait()

	TweenMaid:Destroy()
end

function Tween.TweenUI(instance, TweenInfo, Props, Yield)
	local Tweeninfo = GetTweenInfo(TweenInfo)
	local TweenMaid = Maid.new()

	local CurrentTween = TweenService:Create(instance, Tweeninfo, Props)
	TweenMaid:GiveTask(CurrentTween)

	CurrentTween:Play()

	if Yield then
		CurrentTween.Completed:Wait()
	end

	TweenMaid:Destroy()
end

function Tween.Play(instance: Instance, TweenInfo: table, Props: table, Yield: boolean)
	assert(instance, "No instance given!")
	assert(Props, "No Property Table Given!")

	if instance:IsA("Model") then
		Tween.TweenModel(instance, TweenInfo, Props)
	else
		Tween.TweenUI(instance, TweenInfo, Props, Yield)
	end
end

return Tween
