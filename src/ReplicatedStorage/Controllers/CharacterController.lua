--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

-- // MODULES

--// OBJECTS

-- // KNIT SERVICES & CONTROLLERS

-- // CONSTS


local CharacterController = Knit.CreateController{Name = "CharacterController"}

function CharacterController:KnitInit()

end

function CharacterController:KnitStart()
	
end

function CharacterController:GetCharacter(player)
    
    if player == nil then
        player = Knit.LocalPlayer
    end

    return player.Character or player.CharacterAdded:Wait()
end

return CharacterController
