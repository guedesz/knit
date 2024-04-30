--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES
local Format = Knit:GetModule("Format")

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS
local MessageController, GemsService
-- // CONSTS


local GemsController = Knit.CreateController{Name = "GemsController"}

function GemsController:KnitInit()

end

function GemsController:KnitStart()
	
    MessageController = Knit.GetController("MessageController")
    GemsService = Knit.GetService("GemsService")

    GemsService.OnGemsEarned:Connect(function(amount)
        self:onGemsEarned(amount)
    end)
end

function GemsController:onGemsEarned(amount)
    MessageController:DisplaySoundMessage("+" .. Format:Abbrievate(amount) .. " Gems", Color3.fromRGB(255, 98, 229), nil, "GoldEarned")
end

return GemsController
