--//SERVICES
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//LOAD
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Promise = Knit:GetModule("Promise")
local BadgeList = Knit:GetModule("BadgeList")
local TableUtil = Knit:GetModule("TableUtil")

-- // KNIT SERVICES

-- // CONSTS

local _BadgeService = Knit.CreateService({
	Name = "BadgeService",
	Client = {},
})

function _BadgeService:KnitInit() end

function _BadgeService:KnitStart()

end

function _BadgeService:giveWinBadge(player, dataFolder)
    local badges = BadgeList.Wins
    local wins = dataFolder:WaitForChild("Data"):GetAttribute("Wins")
    
    for winCount, badgeID in pairs(badges) do
        if wins >= winCount then
			local success, hasBadge = pcall(function()
				return BadgeService:UserHasBadgeAsync(player.UserId, badgeID)
			end)
		
			-- If there's an error, issue a warning and exit the function
			if not success then
				continue
			end
		
			if not hasBadge then
				
				local awardSuccess, result = pcall(function()
					BadgeService:AwardBadge(player.UserId, badgeID)
				end)
			end
        end
    end
end
function _BadgeService:giveBadge(player, badgeName)
	
	local badgeId = BadgeList[badgeName]

	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
	end)

	-- If there's an error, issue a warning and exit the function
	if not success then
		warn("Error while checking if player has badge!")
		return
	end

	if not hasBadge then
		
		local awardSuccess, result = pcall(function()
			return BadgeService:AwardBadge(player.UserId, badgeId)
		end)
		
	end
end

return _BadgeService