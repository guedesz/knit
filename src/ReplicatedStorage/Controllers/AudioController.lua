local Debris = game:GetService("Debris")
local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("packages").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local DataController

local AudioController = Knit.CreateController{
	Name = "AudioController"
}

AudioController.Assets = {

	GoldPurchase = 7145481742,
    Error2 = 3742413227,

	MonsterKill = 17274325063,
	BossKill = 3199239299,
	BossFail = 17284893833,

	Shuriken = 5789211405,
	GoldEarned = 5226834046,
}

AudioController.LastTimePlayed = {}

function AudioController:KnitInit()

end

function AudioController:KnitStart()

	DataController = Knit.GetController("DataController")
end


function AudioController:PlayAndDestroy(audioName, maxTime)
	if self.Assets[audioName] then 
		local sound = Instance.new("Sound")
		sound.SoundGroup = SoundService.DefaultSoundGroup

		sound.SoundId = "rbxassetid://"..self.Assets[audioName]
		sound.Parent = SoundService

		if self.LastTimePlayed[audioName] and time() - self.LastTimePlayed[audioName] < 0.1 then
			return
		end

		self.LastTimePlayed[audioName] = time()

		sound:Play()
		task.spawn(function()
			while sound.IsPlaying do
				wait()
				if sound.TimePosition >= maxTime then
					sound:Destroy()
				end
			end
		end)
	end
end

function AudioController:PlaySoundInPart(part, name, props)
	
	if not part then
		return
	end
	
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Part.Position = part.Position

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://"..self.Assets[name]

	if props then 
		for i, v in props do 
			sound[i] = v 
		end
	end 

	sound.Parent = Part

	sound:Play()
	
	sound.Ended:Once(function()
		task.delay(1, function()
			sound:Destroy()
			Part:Destroy()
		end)
	end)
	
end


function AudioController:Play(audioName, properties)
	
	if self.Assets[audioName] then 

		local sound = Instance.new("Sound")

		if not SoundService:FindFirstChild("DefaultSoundGroup") then
			local a = Instance.new("SoundGroup")
			a.Name = "DefaultSoundGroup"
			a.Parent = SoundService
		end
		
		sound.SoundGroup = SoundService.DefaultSoundGroup

		if properties then 
			for i, v in properties do 
				sound[i] = v 
			end
		
			if not properties.Volume then
				sound.Volume = 1.5
			end
		end 

		sound.SoundId = "rbxassetid://"..self.Assets[audioName]
		sound.Parent = SoundService


		-- if self.LastTimePlayed[audioName] and time() - self.LastTimePlayed[audioName] < 0.1 then 
		-- 	return
		-- end

		self.LastTimePlayed[audioName] = time()

		sound:Play()

		sound.Ended:Once(function()
			task.delay(1, function()
				sound:Destroy()
			end)
		end)
	end
end

-- CLIENT END POINT


return AudioController