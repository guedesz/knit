--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local Format = Knit:GetModule("Format")

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local MessageController, GoldService
-- // CONSTS


local GoldController = Knit.CreateController{Name = "GoldController"}

function GoldController:KnitInit()

end

function GoldController:KnitStart()
	
    MessageController = Knit.GetController("MessageController")
    GoldService = Knit.GetService("GoldService")

    GoldService.OnGoldEarned:Connect(function(amount)
        self:onGoldEarned(amount)
    end)
end

function GoldController:onGoldEarned(amount)
    MessageController:DisplaySoundMessage("+" .. Format:Abbrievate(amount) .. " Golds", Color3.fromRGB(255, 189, 103), nil, "GoldEarned")
end

return GoldController
