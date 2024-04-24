--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local LevelClient = Knit:GetModule("LevelClient")

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local LevelService, TycoonController
-- // CONSTS


local LevelController = Knit.CreateController{Name = "LevelController"}

function LevelController:KnitInit()

end

function LevelController:KnitStart()
	
    LevelService = Knit.GetService("LevelService")
    TycoonController = Knit.GetController("TycoonController")

    -- LevelService.OnBossTimerCreated:Connect(function(tickStarted)
    --     self:onBossTimerCreated(tickStarted)
    -- end)
end

return LevelController
