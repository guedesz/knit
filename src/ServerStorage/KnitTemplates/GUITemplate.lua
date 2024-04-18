local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//KNIT
local Knit = require(ReplicatedStorage:WaitForChild("packages").Knit)
local Types = require(ReplicatedStorage.packages:WaitForChild("Types"))

--//MODULES
local Maid = Knit:GetModule("Maid")
local Format = Knit:GetModule("Format")
local Tween = Knit:GetModule("Tween")
local Promise = Knit:GetModule("Promise")

-- // KNIT SERVICES

-- // CONSTS

local GUITemplate = {}
GUITemplate.__index = GUITemplate
GUITemplate.Objects = {}

function GUITemplate.new(_uiController, _dataController)
	local self = setmetatable({}, GUITemplate)
	self._Maid = Maid.new()
	self.ForceInit = true
	self._UIController = _uiController
	self._DataController = _dataController
	self._DataFolder = _dataController:GetReplicationFolder()

	self.Type = "Gui"
	self.Name = "GUITemplate"

	--self.Gui = nil
	self.Hud = nil
	self.Gui = nil

	self.IsInit = false
	self.IsStart = false

	return self
end

function GUITemplate:init()

	self.Gui = self._UIController:GetHolder("Gui", "GUITemplate")

	if not self.Gui then
		warn("error while init in: ", self.Name)
		return false
	end
	
	self.Holder = self.Gui.Holder

	self.IsInit = true
	
	return true
end

function GUITemplate:start()

	self.IsStart = true
	
end
function GUITemplate:open()
	self._UIController:openGui(self.Gui)
end

function GUITemplate:close()
	self._UIController:closeGui(self.Gui)
end

function GUITemplate:destroy() end

return GUITemplate
