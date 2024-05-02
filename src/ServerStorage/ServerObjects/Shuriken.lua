--//SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Constants = Knit:GetModule("Constants")
local Monster = Knit:GetModule("Monster")

-- // KNIT SERVICES

-- // CONSTS

local Shuriken = {}
Shuriken.__index = Shuriken
Shuriken.Objects = {}

function Shuriken.new(player, shurikenName, ShurikenService, tycoonService)
	local self = setmetatable({}, Shuriken)
	self._Maid = Maid.new()
	self.Player = player
	self.Model = nil
	self.Name = shurikenName
	self.ShurikenService = ShurikenService
	self.TycoonService = tycoonService

	self.Tycoon = tycoonService:getTycoonByPlayer(player)

	if not self.Tycoon then
		warn("error getting tycoon")
	end

	self.IsEquipped = false
	self.InCooldown = false

	Shuriken.Objects[player] = self

	return self
end

function Shuriken:unquipShuriken()
	if self.Model then
		self.Model:Destroy()
	end

	self.IsEquipped = false
end

function Shuriken:updateShuriken(name)
	self.Name = name
	self.IsEquipped = false
	self._Maid:DoCleaning()

	self:spawn(self.Player.Character)
end

function Shuriken:spawn(character)
	if not character then
		character = self.Player.Character
	end

	if not character then
		assert(character, "Character is nil to load new weapon!")
	end

	self.Destroy = false

	self.Model = Knit:GetAsset(self.Name)

	if not self.Model then
		self.Model = Knit:GetAsset("Starter")
	end

	assert(self.Model, " Model not found with given name: " .. self.Name)
	self._Maid:GiveTask(self.Model)

	local hand = self.Player.Character:FindFirstChild("RightHand") or self.Player.Character:WaitForChild("RightHand", 5)
	assert(hand, "No hand found")

	self.Model.Name = self.Player.UserId

	local weld = hand:FindFirstChild("ObjectWeld")
	if not weld then
		weld = Instance.new("WeldConstraint")
		weld.Name = "ObjectWeld"
		weld.Parent = self.Model
		weld.Part0 = hand
	end

	weld.Part1 = self.Model.PrimaryPart
	self.Model:PivotTo(hand.CFrame)

	self.IsEquipped = true


	self.Model.Parent = workspace.Shurikens
end

function Shuriken:click(isBonus)

	if not self.IsEquipped then
		return false
	end

	if self.Destroy then
		print("a")
		return
	end

	if self.InCooldown then
		return false
	end

	self.InCooldown = true

	task.delay(Constants.SHURIKEN_DELAY, function()
		self.InCooldown = false
	end)

	if not self.Player.Character or not self.Player.Character.PrimaryPart then
		return
	end

    local monster = Monster.Objects[self.Player]

	if not monster then
		return false
	end

	if monster.IsDestroying then
		return
	end

	if not self.Tycoon then
		self.Tycoon = self.TycoonService:getTycoonByPlayer(self.Player)
	end
	
	if (self.Player.Character.PrimaryPart.Position - self.Tycoon.Plot.monsterSpawn.Position).Magnitude > Constants.MAX_SHURIKEN_DISTANCE then
        return
    end

	monster:takeDamage(Constants.SHURIKEN_BASE_DAMAGE)

	return true
end

function Shuriken:destroy()
	self.Destroy = true
	self._Maid:DoCleaning()
	Shuriken.Objects[self.Player] = nil
	self._Maid = nil

	self.Player = nil
	self.Model = nil
	self.Name = nil
	self.ShurikenService = nil

	self.IsEquipped = false
	self.InCooldown = false

end

return Shuriken