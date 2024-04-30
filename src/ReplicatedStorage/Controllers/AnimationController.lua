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


local AnimationController = Knit.CreateController{Name = "AnimationController"}

function AnimationController:KnitInit()

end

AnimationController.Animations = {
    Idle = 17340268234
}

function AnimationController:KnitStart()
	
    for _, character in CollectionService:GetTagged("NPC") do
        self:Play("IdleNpc", nil, character)
    end

    for _, character in CollectionService:GetTagged("NPC2") do
        self:Play("IdleNPC2", nil, character)
    end
end

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
    animation.AnimationId = "rbxassetid://".. self.Animations[animName]

    local track: Animation = animator:LoadAnimation(animation)
    track.Priority = priority or Enum.AnimationPriority.Action
    track:Play()

    if returnTrack then
        return track
    end

end

return AnimationController