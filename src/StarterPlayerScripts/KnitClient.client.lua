local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local start = tick()

local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))

Knit.LocalPlayer = Players.LocalPlayer
Knit.PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
Knit.Camera = game.Workspace.Camera
Knit.Mouse = Players.LocalPlayer:GetMouse()
Knit.AddControllers(ReplicatedStorage.src:WaitForChild("Controllers"))

Knit.Start():andThen(function()
    print("Client loaded in: ".. string.format("%2f", tick() - start) .."s")
    Knit.LocalPlayer:SetAttribute("LOADED", true)
end):catch(warn)