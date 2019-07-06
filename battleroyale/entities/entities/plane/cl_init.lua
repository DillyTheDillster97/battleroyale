include("shared.lua")

function ENT:Initialize()
	if(!IsValid(LocalPlayer())) then return end
	LocalPlayer():EmitSound("Plane")
end

function ENT:OnRemove()
	if(!IsValid(LocalPlayer())) then return end
	LocalPlayer():StopSound("Plane")
	self:StopSound("Plane")
end

function ENT:Draw()
    self:DrawModel()
end

net.Receive("PlayerEjected", function()
	local plane = net.ReadEntity()
	if(IsValid(plane) && IsValid(LocalPlayer())) then
		LocalPlayer():StopSound("Plane")
		plane:EmitSound("Plane")
	end
end)