--//SERVICES
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Promise = Knit:GetModule("Promise")
local LevelsData = Knit:GetMetaData("Levels")
local Tween = Knit:GetModule("Tween")
local Signal = Knit:GetModule("Signal")
local DamageEffect = Knit:GetModule("DamageEffect")
local ShakePart = Knit:GetModule("ShakePart")
local Format = Knit:GetModule("Format")

-- // KNIT SERVICES

-- // CONSTS
local MAX_DISPLAY_DISTANCE = 125

local MonsterClient = {}
MonsterClient.__index = MonsterClient
MonsterClient.Objects = {}

function MonsterClient.new(player, info, audioController, levelHud)
	local self = setmetatable({}, MonsterClient)
	self._Maid = Maid.new()
	self.Info = info
	self._Player = player
	self.OnDamage = Signal.new()

	self.IsDestroying = false

	self._AudioController = audioController

	self.Shaking = false

	MonsterClient.Objects[player] = self

	return self
end

function MonsterClient:onTakeDamage(damage, actual, maxHealth)
	self.Info.Health = actual

	self.Billboard.Red.TextLabel.Text = Format:Abbrievate(self.Info.Health) .. "/" .. Format:Abbrievate(self.Info.MaxHealth)
	Tween.Play(self.Billboard.Red.Green, { 0.25 }, { Size = UDim2.fromScale(math.clamp(actual / maxHealth, 0, 1), 1) })

	if Knit.LocalPlayer == self._Player then
		self.OnDamage:Fire(actual, maxHealth)
	end

	local highLight = Instance.new("Highlight")
	highLight.Parent = self.Model
	highLight.OutlineColor = Color3.fromRGB(255, 0, 0)

	Debris:AddItem(highLight, 0.1)

	local color = Color3.new(1, 0.0117647, 0.0117647)
	DamageEffect.createDamageEffect(self.Model, math.round(damage), color)

	self._AudioController:PlaySoundInPart(
		self.Model.PrimaryPart,
			"Hit",
			{ Volume = 1, RollOffMaxDistance = 100, RollOffMinDistance = 1 }
		)
end

function MonsterClient:init()
	return Promise.new(function(resolve, reject)
		local monster

		if self.Info.IsBoss then
			monster = Knit:GetBoss(self.Info.Data.Name)
		else
			monster = Knit:GetMonster(self.Info.Data.Name)
		end

		self.Model = monster

		if not monster then
			return reject("error getting monster")
		end

		self:setupHealthBar()

		self._Maid:GiveTask(self.Model)

		local connection = RunService.Heartbeat:Connect(function(dtTime)
			local playerCharacter = Knit.LocalPlayer.Character

			if playerCharacter and monster.Parent then
				if
					(playerCharacter.PrimaryPart.Position - monster.PrimaryPart.Position).Magnitude
					>= MAX_DISPLAY_DISTANCE
				then
					return
				end

				local playerPosition = playerCharacter.HumanoidRootPart.Position
				local monsterPosition = monster.PrimaryPart.Position
				local direction = (playerPosition - monsterPosition).unit

				-- Update monster's rotation to face the player
				local lookAt = CFrame.new(monsterPosition, monsterPosition + direction)
				monster:SetPrimaryPartCFrame(lookAt)
			end
		end)

		self._Maid:GiveTask(connection)

		resolve(monster)
	end)
end

function MonsterClient:setupHealthBar()
	self.Billboard = Knit:GetAsset("HealthBar")
	self.Billboard.Parent = self.Model

	self.Billboard.Red.TextLabel.Text = Format:Abbrievate(self.Info.Health) .. "/" .. Format:Abbrievate(self.Info.MaxHealth)
	Tween.Play(
		self.Billboard.Red.Green,
		{ 0.25 },
		{ Size = UDim2.fromScale(math.clamp(self.Info.Health / self.Info.MaxHealth, 0, 1), 1) }
	)
end

function MonsterClient:destroy(isRemoving)
	if self.IsDestroying then
		return
	end

	MonsterClient.Objects[self._Player] = nil

	if isRemoving then
		print("rEMOVING")
		self._Maid:DoCleaning()
		self._Maid = nil
		return
	end

	self.IsDestroying = true

	self._AudioController:PlaySoundInPart(
		self.Model.PrimaryPart,
		"MonsterKill",
		{ Volume = 1, RollOffMaxDistance = 100, RollOffMinDistance = 1 }
	)

	self.Billboard:Destroy()
	self.Model.PrimaryPart.PetNameUI:Destroy()

	local delay = 1

	Tween.Play(self.Model.PrimaryPart, {delay}, {Transparency = 1})
	Tween.Play(self.Model.PrimaryPart, {delay}, {Position = self.Model.PrimaryPart.Position + Vector3.new(0, 5, 0)})

	Promise.delay(delay):andThen(function()
		self._Maid:DoCleaning()
		self._Maid = nil
	end)
end

return MonsterClient
