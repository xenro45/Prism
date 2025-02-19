local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local DEFAULT_COLOR = BrickColor.White()
local DEFAULT_TRANSPARENCY = 0

local container = Instance.new("Folder")
container.Name = "Prisms"
container.Parent = workspace

local Prism = {}
Prism.__index = Prism

type Prism = typeof(setmetatable(
	{} :: {
		Origin: Vector3,
		Direction: Vector3,
		Cylinder: CylinderHandleAdornment,
		Cone: ConeHandleAdornment,
		SetStyle: (self: Prism, styles: PrismStyle) -> nil,
		Update: (orgin: Vector3, direction: Vector3) -> nil,
		Destroy: () -> nil,
	},
	Prism
))

type PrismStyle = {
	Color: BrickColor,
	Transparency: number,
}

function Prism.new(origin: Vector3, direction: Vector3): Prism
	local self = setmetatable({}, Prism)
	self.Origin = origin
	self.Direction = direction
	self.Cylinder = Instance.new("CylinderHandleAdornment")
	self.Cylinder.AlwaysOnTop = true
	self.Cylinder.ZIndex = 5
	self.Cylinder.Parent = container
	self.Cone = Instance.new("ConeHandleAdornment")
	self.Cone.AlwaysOnTop = true
	self.Cone.ZIndex = 5
	self.Cone.Parent = container
	self._janitor = Janitor.new()
	self._janitor:Add(self.Cylinder, "Destroy")
	self._janitor:Add(self.Cone, "Destroy")

	local adornee = Instance.new("Part")
	adornee.Size = Vector3.one
	adornee.Parent = container
	adornee.Anchored = true
	adornee.CanCollide = false
	adornee.Position = Vector3.zero
	adornee.Transparency = 1
	adornee.CanTouch = false
	adornee.CanQuery = false

	self.Cylinder.Adornee = adornee
	self.Cone.Adornee = adornee
	self.Cone.Radius = 0.5
	self.Cylinder.Radius = 0.25
	self.Cylinder.Height = 5

	self:SetStyle({
		Transparency = DEFAULT_TRANSPARENCY,
		Color = DEFAULT_COLOR,
	})
	self:Update(origin, direction)
	self._janitor:Add(adornee, "Destroy")

	return self
end

function Prism:SetStyle(styles: PrismStyle)
	for index, property in styles do
		if self.Cylinder[index] then
			self.Cylinder[index] = property
			self.Cone[index] = property
		end
	end
end

function Prism:Update(origin: Vector3, direction: Vector3)
	local distance = (origin - direction).Magnitude
	local midPoint = (origin + direction) / 2
	local lookAt = CFrame.lookAt(midPoint, direction)
	self.Cylinder.Height = distance
	self.Cylinder.CFrame = lookAt
	self.Cone.CFrame = lookAt * CFrame.new(0, distance / 2, 0)
end

function Prism:Destroy()
	self._janitor:Cleanup()
	self.Cylinder = nil
	self.Direction = nil
	self.Cone = nil
	self._janitor = nil
	self.Origin = nil
	setmetatable(self, nil)
end

return Prism
