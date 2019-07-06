include("shared.lua")

function ENT:Initialize()
	if(!IsValid(LocalPlayer())) then return end
	LocalPlayer():EmitSound("Plane")
end

function ENT:OnRemove()
	if(!IsValid(LocalPlayer())) then return end
	LocalPlayer():StopSound("Plane")
end

function ENT:Draw()
    self:DrawModel()
end