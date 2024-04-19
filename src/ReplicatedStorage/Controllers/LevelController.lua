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

    LevelService.OnNewLevelCreated:Connect(function(player, info)
        self:onNewLevelCreated(player, info)
    end)
end

function LevelController:onNewLevelCreated(player, currentLevel)

    local tycoon = TycoonController:getTycoonByPlayer(player)

    if not tycoon then
        return warn("error getting tycoon on new level created")
    end

    local newLevel = LevelClient.new(player, currentLevel)
    tycoon.Level = newLevel
    newLevel:init()
        
end

return LevelController
