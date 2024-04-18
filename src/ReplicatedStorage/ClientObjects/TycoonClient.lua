--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")

-- // KNIT SERVICES

-- // CONSTS

local TycoonClient = {}
TycoonClient.__index = TycoonClient
TycoonClient.Objects = {}

function TycoonClient.new(player, tycoonService, tycoonController, dataController, tycoonFolder, plotFolder)
	local self = setmetatable({}, TycoonClient)
	self._Maid = Maid.new()

	self._Player = player

	self._TycoonService = tycoonService
	self._TycoonController = tycoonController
	self._DataController = dataController

	self._TycoonFolder = tycoonFolder
	self._PlotFolder = plotFolder
	
	TycoonClient.Objects[player] = self
	return self
end

function TycoonClient:init()
	
end

function TycoonClient:destroy()
	self._Maid:DoCleaning()
	self._Maid = nil

	TycoonClient.Objects[self._Player] = nil
end


return TycoonClient