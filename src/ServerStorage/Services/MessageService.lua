--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES
local DataService
-- // CONSTS

local MessageService = Knit.CreateService({
	Name = "MessageService",
	Client = {
		MessagePlayerChat = Knit.CreateSignal(),
		MessagePlayer = Knit.CreateSignal(),
	},
})

function MessageService:KnitInit() end

function MessageService:KnitStart()
end

return MessageService
