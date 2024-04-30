local TweenService = game:GetService("TweenService")
local Promise = require(script.Parent:WaitForChild("Promise"))

local cycleDuration = 0.1
local totalDuration = 0.2
local volatility = .2

return function(part)
    return Promise.new(function(resolve, reject)

        local savedPosition = part.Position
        local tweeninfo = TweenInfo.new(
            cycleDuration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out,
            0,
            false,
            0
        )
    
        for i = 0, totalDuration - cycleDuration, cycleDuration do
            local tween = TweenService:Create(
                part,
                tweeninfo,
                {Position = savedPosition + Vector3.new(math.random(),math.random(),math.random()).Unit * volatility}
            )
            tween:Play()
            tween.Completed:Wait()
        end

        local tween =  TweenService:Create(
            part,
            tweeninfo,
            {Position = savedPosition}
        )
        
        tween:Play()
        tween.Completed:Wait()

        tween:Destroy()

        resolve(true)

    end)
end