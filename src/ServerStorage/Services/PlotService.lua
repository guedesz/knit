--//SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS
local PLOTS_TABLE: { Folder } = workspace:WaitForChild("Map"):WaitForChild("Plots"):GetChildren()
local CHECK_FOR_OWNER_ATTRIBUTE_NAME = "HasOwner"

local PlotService = Knit.CreateService {
	Name = "PlotService",
	Client = {
	}
}

function PlotService:KnitInit()

	Players.PlayerRemoving:Connect(function(player)
		self:_onPlayerRemoving(player)
	end)
end

function PlotService:KnitStart()

end
function PlotService:_onPlayerRemoving(player: Player)

	local plot = self:getPlotFromPlayer(player)

	if not plot then
		return
	end

	plot:SetAttribute(CHECK_FOR_OWNER_ATTRIBUTE_NAME, nil)
end

function PlotService:_findFreePlot()

	for _, plot: Folder in PLOTS_TABLE do

		if not plot:GetAttribute(CHECK_FOR_OWNER_ATTRIBUTE_NAME) then
			return plot
		end
	end

	return false
end

function PlotService:getPlotFromPlayer(player: Player)

	for _, plot: Folder in PLOTS_TABLE do
		if plot:GetAttribute(CHECK_FOR_OWNER_ATTRIBUTE_NAME, player.UserId) then
			return plot
		end
	end

end

function PlotService:claimPlotForPlayer(player: Player)
	
	local plot = self:_findFreePlot()

	if not plot then
		return warn("error getting plot")
	end

	plot:SetAttribute(CHECK_FOR_OWNER_ATTRIBUTE_NAME, player.UserId)

	return plot
end

return PlotService