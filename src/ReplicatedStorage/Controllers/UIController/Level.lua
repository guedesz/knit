local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Format = Knit:GetModule("Format")
local Tween = Knit:GetModule("Tween")
local Promise = Knit:GetModule("Promise")
local LevelsData = Knit:GetMetaData("Levels")

-- // KNIT SERVICES
local LevelService, AudioController
-- // CONSTS

local Level = {}
Level.__index = Level
Level.Objects = {}

function Level.new(_uiController, _dataController, _messageController)
	local self = setmetatable({}, Level)
	self._Maid = Maid.new()
	self.ForceInit = true
	self._UIController = _uiController
	self._DataController = _dataController
	self._MessageController = _messageController

	
	self._DataFolder = _dataController:GetReplicationFolder()
 
	self.Type = "Hud"
	self.Name = "Level"

	--self.Gui = nil

	self.Gui = nil

	self.IsInit = false
	self.IsStart = false

	return self
end

function Level:init()

	self.Gui = self._UIController:GetHolder("Hud", "Level")

	if not self.Gui then
		warn("error while init in: ", self.Name)
		return false
	end

	self.IsInit = true
	
	return true
end

function Level:start()

	LevelService = Knit.GetService("LevelService")
	AudioController = Knit.GetController("AudioController")

	LevelService.OnBossTimerCreated:Connect(function(tickStart)
		self:enableTimer(tickStart)
	end)

	LevelService.OnBossFailedToKill:Connect(function()
		self:onBossFailedToKill()
	end)

	LevelService.OnBossSuccessKill:Connect(function()
		self:onBossSuccessKill()
	end)


	self.IsStart = true
end

function Level:onBossSuccessKill()
	
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	self.Gui.timer.Visible = false

	self._MessageController:DisplaySoundMessage("You defeated a boss and unlocked a new level!", Color3.fromRGB(207, 103, 255), 3, "BossKill")
end

function Level:onBossFailedToKill()
	
	self._MessageController:DisplaySoundMessage("You need more power to defeat the boss!", Color3.fromRGB(255,0,0), 3, "BossFail")

	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	self.Gui.timer.Visible = false
end

function Level:enableTimer(tickStart)
	
	if not self.Gui.timer.Visible then
		self.Gui.timer.Visible = true
	end

	local duration = LevelsData.TIMER_FOR_BOSS

	self.connection = RunService.Heartbeat:Connect(function(dt)
		
		local timeTook = workspace:GetAttribute("Tick") - tickStart -- calculate the time elapsed since the start time

		if timeTook >= duration then -- stop the timer when time is up
			
			if not self.connection then
				return
			end
			
			self.connection:Disconnect()
			self.connection = nil
			
			self.Gui.timer.Text = "0s"
			task.wait(.1)
			self.Gui.timer.Visible = false
			
			return
		end

		local timeRemaining = duration - timeTook -- calculate the time remaining until the duration is reached

		local minutes = math.floor(timeRemaining / 60)
		timeRemaining = timeRemaining - (minutes * 60)

		local seconds = math.floor(timeRemaining)
		timeRemaining = timeRemaining - seconds

		local milliseconds = math.floor(timeRemaining * 1000)

		self.Gui.timer.Text = string.format("%02d.%.01d", seconds, milliseconds) .. "s"
	end)

end

function Level:updateInfo(monsterName: string, level, wave)
	
	self.Gui.monsterName.Text = monsterName
	self.Gui.level.Text = "Level: ".. level

	if wave == LevelsData.MOSTERS_UNTIL_BOSS + 1 then
		self.Gui.wave.Text = "Wave: BOSS"
	else
		self.Gui.wave.Text = "Wave: " .. wave .. "/".. LevelsData.MOSTERS_UNTIL_BOSS
	end

end

function Level:updateHealthbar(actual, maxHealth)
	
	self.Gui.Red.TextLabel.Text = actual .. "/" .. maxHealth
	Tween.Play(self.Gui.Red.Green, { 0.25 }, { Size = UDim2.fromScale(math.clamp(actual / maxHealth, 0, 1), 1) })
end

function Level:open()
	
end

function Level:close()
	
end

function Level:destroy() end

return Level
