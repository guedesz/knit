--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS
local MonsterClient = Knit:GetModule("MonsterClient")
local TycoonClient = Knit:GetModule("TycoonClient")

-- // KNIT SERVICES & CONTROLLERS
local MonsterService
-- // CONSTS


local MonsterController = Knit.CreateController{Name = "MonsterController"}

function MonsterController:KnitInit()

end

function MonsterController:KnitStart()

    MonsterService = Knit.GetService("MonsterService")

    -- fired from Level server object
    MonsterService.OnTakeDamage:Connect(function(player, damage,actualHealth, maxHealth)
        self:onTakeDamage(player, damage, actualHealth, maxHealth)
    end)

    -- fired from level server object
    MonsterService.OnMonsterKilled:Connect(function(player, info)
        self:onMonsterKilled(player, info)
    end)
end

function MonsterController:onMonsterKilled(player, info)
    
    local tycoon = TycoonClient.Objects[player]

    if not tycoon then
        return warn("no tycoon was found with given player", player)
    end

    tycoon:getNewLevel()

    tycoon:spawnMonster()
    
end

function MonsterController:onTakeDamage(player, damage, actualHealth, maxHealth)

    local monster = MonsterClient.Objects[player]

    if not monster then
        return
    end

    monster:onTakeDamage(damage, actualHealth, maxHealth)
end

return MonsterController
