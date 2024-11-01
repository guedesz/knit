--//SERVICES
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS

-- // CONSTS

local AnimationController = Knit.CreateController({ Name = "AnimationController" })

function AnimationController:KnitInit() end

AnimationController.Animations = {

	Run = 18426726922,
	RunBow = 18459918340,
	IdleBow = 18460157531,
	AttackBow = 18519875322,
	Slash1 = 18426733637,
	Slash2 = 18460512335,
	Slash3 = 18460521741,

	IdleSword = 18460528807,

	IdleSamurai = 18537088738,
	RunSamurai = 18537102744,
	SwingSamurai1 = 18537096383,
	SwingSamurai2 = 18537107376,
	SwingSamurai3 = 18537110479,
	
}

function AnimationController:KnitStart() end

function AnimationController:play(character, animName, priority, returnTrack)
	if not character then
		character = Knit.LocalPlayer.Character or Knit.LocalPlayer.CharacterAppearenceLoaded:Wait()
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator: Animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. self.Animations[animName]

	local track: Animation = animator:LoadAnimation(animation)
	track.Priority = priority or Enum.AnimationPriority.Action
	track:Play()

	if returnTrack then
		return track
	end
end

return AnimationController
