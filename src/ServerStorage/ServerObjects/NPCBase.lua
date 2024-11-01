--//SERVICES
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Signal = Knit:GetModule("Signal")
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS
local MAX_FOCUSED = 3

local NPCBase = {}
NPCBase.__index = NPCBase
NPCBase.Objects = {}

function NPCBase.new(info, parent, match, type)
	local self = setmetatable({}, NPCBase)
	self._Maid = Maid.new()

	self.Attackers = {}
	self.FocusingTargetObject = nil

	self.Match = match
	self.Type = type

	self.Info = info
	
	self.Speed = info.Speed
	self.Name = info.Name

	self.DistanceToHit = info.DistanceToHit or 6
	self.DelayBetweenHits = info.DelayBetweenHits or 3

	self.DelayToDamage = info.DelayToDamage
	self.Damage = info.Damage

	self.Health = info.Health or 100
	self.MaxHealth = self.Health

	self.Parent = parent

	self.Id = HttpService:GenerateGUID(false)

	NPCBase.Objects[self.Id] = self

	self.Model = Knit:GetAsset(self.Name)

	self.CurrentlyState = self:changeState("Idle")

	return self
end

function NPCBase:spawn()
	self.Model.Name = self.Id

	self.IsAttacking = false

	self.Model:PivotTo(self.Spawn.CFrame)

	for _, v: Part in self.Model:GetDescendants() do
		if v:IsA("Part") or v:IsA("MeshPart") then
			v.CollisionGroup = "NPCS"
		end
	end

	self.Model.Parent = self.Parent
	self._Maid:GiveTask(self.Model)

	self.OnAttackingSignal = Signal.new()
end

function NPCBase:init()
	self:spawn()
end

-- Helper function to handle movement and orientation
function NPCBase:moveTowards(position, targetPosition, deltaTime)
	local direction = (targetPosition - position).Unit
	local newPosition = position + direction * self.Speed * deltaTime
	local lookAtCFrame = CFrame.lookAt(newPosition, targetPosition)
	self.Model:PivotTo(lookAtCFrame)
end

-- Helper function to update orientation towards the current target
function NPCBase:orientTowards(position, targetPosition)
	local lookAtCFrame = CFrame.lookAt(position, targetPosition)
	self.Model:PivotTo(lookAtCFrame)
end

-- Method to handle target transition
function NPCBase:switchTarget(newTarget)
	self.closestEnemy = newTarget
	if newTarget then
		self.IsMovingToEnemy = true
		local prevPosition = self.Model:GetPivot().Position
		local enemyPosition = newTarget.PrimaryPart.Position
		self:orientTowards(prevPosition, enemyPosition)
	else
		self.IsMovingToEnemy = false
	end
end

function NPCBase:onClosestEnemyDead()
	self:switchTarget(nil)
end

function NPCBase:move(deltaTime)

	if self.Destroying then
		return
	end

	self.closestEnemy = self:getClosestEnemy()

	if self.closestEnemy and not self.closestEnemy.PrimaryPart then
		self.closestEnemy = nil
	end

	if #self.EnemyFolder:GetChildren() == 0 then
		self:switchTarget(nil)
		self:MoveToEnemyTower(deltaTime)
		return
	end

	-- Validate closestEnemy
	if not self.closestEnemy or not self.closestEnemy.PrimaryPart then
		self:changeState("Run")

		self:switchTarget(nil)

		self:MoveToEnemyTower(deltaTime)
		return
	end

	if self:canAttackBasedOnDistance() then
		local prevPosition = self.Model:GetPivot().Position
		local enemyPosition = self.closestEnemy.PrimaryPart.Position
		self:orientTowards(prevPosition, enemyPosition)

		if self:canAttack() then
			self:attack()
		end

		return
	end

	self:changeState("Run")

	-- Move towards the closest enemy
	local prevPosition = self.Model:GetPivot().Position
	local enemyPosition = self.closestEnemy.PrimaryPart.Position
	self:moveTowards(prevPosition, enemyPosition, deltaTime)
end

function NPCBase:MoveToEnemyTower(deltaTime)
	local prevPosition = self.Model:GetPivot().Position
	local targetPosition = self.End.Position
	self:moveTowards(prevPosition, targetPosition, deltaTime)

	local actualDistance = (targetPosition - prevPosition).Magnitude

	if actualDistance < 3 then
		self.Match:onNpcReachingEnd(self)
	end
	
end

function NPCBase:changeState(state: string)

	self.CurrentlyState = state
	self.Model:SetAttribute("CurrentlyState", state)

end

function NPCBase:canAttack()
	
	if self.CurrentlyState == "Cooldown" then
		return
	end

	if self.CurrentlyState == "Attack" then
		return
	end

	return true
end

function NPCBase:attack()

	if not self.closestEnemy then
		return
	end

	self:changeState("Attack")
	self.OnAttackingSignal:Fire(self.closestEnemy.Name)

		-- Delay between hits
	self.AttackPromise = Promise.new(function(resolve, reject, onCancel)
		
		task.wait()

		self:changeState("Cooldown")

		task.wait(self.DelayBetweenHits)

		resolve(true)

	end):finally(function(result)
		
		self.AttackPromise = nil
		self:changeState("Idle")

	end):catch(warn)

end

function NPCBase:processDamage(receiverType, receiver)
	-- Fire attack event based on receiver type
	if receiverType == "Hero" then
		self.MonsterService.Client.OnAttack:Fire(self.Player, self.Id, receiver.Id)
	else
		self.HeroService.Client.OnAttack:Fire(self.Player, self.Id, receiver.Id)
	end

	-- If the receiver is still alive after taking damage, exit function
	if receiver.Health > 0 then
		return
	end

	self:onClosestEnemyDead()
	-- Destroy the receiver
	receiver:destroy()

	-- Fire the appropriate destruction event
	if receiverType == "Monster" then
		self.MonsterService.Client.DestroyMonsterClient:Fire(self.Player, receiver.Id)
	else
		self.HeroService.Client.DestroyHeroClient:Fire(self.Player, receiver.Id)
	end

	self.Match:cancelAttack(self)
	self.Match:cancelAttack(receiver)
end

function NPCBase:takeDamage(damage)
	if self.Health > 0 then
		self.Health = math.clamp(self.Health - damage, 0, self.MaxHealth)
		self.Model:SetAttribute("Health", self.Health)
	end
end

function NPCBase:cancelAttackPromise()

	if self.AttackPromise then
		self.AttackPromise:cancel()
		self.AttackPromise = nil
	end

	self:changeState("Idle")

end

function NPCBase:canAttackBasedOnDistance()

	local actualDistance = (self.closestEnemy.PrimaryPart.Position - self.Model.PrimaryPart.Position).Magnitude

	if actualDistance < self.DistanceToHit then
		return true
	end

	return false
end

function NPCBase:getClosestEnemy()
	local enemies = self.EnemyFolder:GetChildren() -- Get all enemies from EnemyFolder

	local closestChar = nil
	local distance = nil

	for i, character in enemies do
		if not character.Parent then
			return
		end

		local currentDistance = (character.PrimaryPart.Position - self.Model.PrimaryPart.Position).Magnitude

		if closestChar == nil then
			closestChar = character
			distance = currentDistance
			continue
		end

		-- check if this enemy is far from currently targeted in the loop
		if currentDistance > distance then
			continue
		end

		closestChar = character
		distance = currentDistance
	end

	return closestChar
end

function NPCBase:destroy()
	self.Destroying = true

	if not self._Maid then
		return
	end

	if self.CooldownPromise then
		self.CooldownPromise:cancel()
		self.CooldownPromise  = nil
	end
	
	self._Maid:DoCleaning()
	self._Maid = nil

	NPCBase.Objects[self.Id] = nil
end

return NPCBase
