--//SERVICES
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local MonsterClient = Knit:GetModule("MonsterClient")
local BezierCurves = Knit:GetModule("BezierCurves")
local Constants = Knit:GetModule("Constants")

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local ShurikenService, AnimationController, MessageController, AudioController
-- // CONSTS
local CAN_SHOOT = true

local ShurikenController = Knit.CreateController{Name = "ShurikenController"}

function ShurikenController:KnitInit()

end

function ShurikenController:KnitStart()

    AnimationController = Knit.GetController("AnimationController")
    ShurikenService = Knit.GetService("ShurikenService")
    MessageController = Knit.GetController("MessageController")
    AudioController = Knit.GetController("AudioController")

    self:initShurikenInputs()
end

function ShurikenController:onClick()
	
	-- if CAN_ANIMATE_DUMBELL then
	-- 	local anim = AnimationController:play("DumbellClick", Enum.AnimationPriority.Action4, nil, true)

	-- 	CAN_ANIMATE_DUMBELL = false
	-- 	task.spawn(function()
	-- 		repeat
	-- 			task.wait()
	-- 		until not anim.IsPlaying
	-- 		CAN_ANIMATE_DUMBELL = true
	-- 	end)
		
	-- end

    if not CAN_SHOOT then
        return
    end

    local monster = MonsterClient.Objects[Knit.LocalPlayer]

    if not monster then
        return
    end

    if not monster.Model then
        return
    end
    
    if not Knit.LocalPlayer.Character then
        return
    end

    if not Knit.LocalPlayer.Character.PrimaryPart then
        return
    end

    if (Knit.LocalPlayer.Character.PrimaryPart.Position - monster.Model.PrimaryPart.Position).Magnitude > Constants.MAX_SHURIKEN_DISTANCE then
        return print("too far")
    end

    CAN_SHOOT = false

    task.delay(Constants.SHURIKEN_DELAY + 0.1, function()
        CAN_SHOOT = true
    end)

    local angles = {
        CFrame.new(math.random(20, 30), 0, 0),
        CFrame.new(math.random(-20, -10), 0, 0),
    }

    local startCFrame =  Knit.LocalPlayer.Character.RightHand.CFrame
    local endCFrame = monster.Model.PrimaryPart.CFrame
    local midpoint = (startCFrame:Lerp(endCFrame, 0.5) * angles[math.random(1, #angles)]).Position
    local connection
    local elapsed = 0

    local ice = Knit:GetAsset("Starter")
    ice:PivotTo(startCFrame)

    ice.PrimaryPart.Trail.Enabled = true

    ice.Parent = workspace.Shurikens

   AudioController:PlaySoundInPart(
    ice.PrimaryPart,
		"Shuriken",
		{ Volume = 1, RollOffMaxDistance = 100, RollOffMinDistance = 1 }
	)

    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt * 1.1
    
        if elapsed >= 1 then
            connection:Disconnect()
            connection = nil
            ice:Destroy()
            self:onHit()
            return
        end
    
        local Time = elapsed / .2
        local curve = BezierCurves.QuadBezier(elapsed, startCFrame.Position, midpoint, endCFrame.Position)
       
        ice.PrimaryPart.Position = curve
        ice.PrimaryPart.Orientation += Vector3.new(0, 10, 0)

        if elapsed >= 1 then
            connection:Disconnect()
            connection = nil
            ice:Destroy()
            self:onHit()
        end

    end)

end

function ShurikenController:onHit()
    ShurikenService:OnClickRequest():andThen(function(result, clickAmount, isBonus)
	
		if not result then
			return
		end

		-- self:displayClickEffect(clickAmount)

		-- if isBonus then
		-- 	MessageController:DisplaySoundMessage("🎁 Strength Bonus!", Color3.fromRGB(255, 183, 0), 3, "Bonus")

		-- 	for i = 1, 10 do
		-- 		task.spawn(function()
		-- 			BonusEffect.createBonusEffect(Knit.LocalPlayer.Character, 1, Color3.fromRGB(255,0,0))
		-- 		end)
		-- 	end

		-- end
	end)
end


function ShurikenController:initShurikenInputs()

    local function click(_, input)
    
        if input == Enum.UserInputState.Begin then
			self:onClick()
        end

		return Enum.ContextActionResult.Pass
    end

    ContextActionService:BindAction("Shuriken", click, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1)

	local function TouchTap(touchPositions, _gameProcessedEvent)
		click("Click", Enum.UserInputState.Begin)
	end
	
	if UserInputService.TouchEnabled then
		UserInputService.TouchTap:Connect(TouchTap)
	end

end
return ShurikenController
