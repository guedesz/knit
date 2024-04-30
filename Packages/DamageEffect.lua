--- ### Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)

--- ### Fusion
local Fusion = Knit:GetModule("Fusion")

local DamageEffects = {}

local function createBillboard(text, color): BillboardGui
	local billboard = Fusion.New "BillboardGui" {
		Enabled = true,
		Size = UDim2.fromScale(2,2),
		[Fusion.Children] = {
			Fusion.New "TextLabel" {
				Size = UDim2.fromScale(1,1),
				TextScaled = true,
				Text = text,
				TextColor3 = color or Color3.new(1,1,1),
				BackgroundTransparency = 1,
				Font = Enum.Font.FredokaOne,
				[Fusion.Children] = {
					Fusion.New "UIStroke" {}
				}
			}
		}
	}
	billboard.Enabled = true
	return billboard
end

local offset = Vector3.new(0, 4, 0)
local range = 0.25
function DamageEffects.createDamageEffect(target: Model | BasePart, damage: number, color: Color3?)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Transparency = 1
	part.Anchored = false

	local randomOffset = Vector3.new(math.random(-range, range), math.random(-range, range), math.random(-range, range))
	part:PivotTo(target:GetPivot() + offset + randomOffset)
	part.Parent = workspace

	local billboard = createBillboard(tostring(math.ceil(damage)), color)
	billboard.Parent = part
	billboard.Adornee = part

	--- apply random upwards force
	local randUpwardsForce = Vector3.new(math.random(-10, 10), math.random(30, 35), math.random(-10, 10));
	part:ApplyImpulse(randUpwardsForce * part.AssemblyMass)

	task.delay(0.45, function()
		part:Destroy()
	end)
end

return DamageEffects