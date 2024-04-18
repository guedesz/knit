local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService('ServerStorage')
local Knit = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Knit"))

Knit.AddServicesDeep(ServerStorage.src:WaitForChild('Services'))

Knit.Start():andThen(function()
    print("Knit server has started")
end):catch(warn)