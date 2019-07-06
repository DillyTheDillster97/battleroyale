AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Parachute - Active"
ENT.Author = "Threebow"

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
else
	function ENT:Initialize()
		self:SetModel("models/freeman/parachute_open.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		local owner = self:GetOwner()

		local col = owner:GetParachuteColor()
		if(col) then self:SetColor(col) end

		local bone = owner:LookupBone("ValveBiped.Bip01_Spine")
		self:SetPos(owner:GetPos() + Vector(0, 0, 90))
		self:SetAngles(owner:GetAngles() - Angle(10, 180, 0))
		self:SetParent(owner, bone)
	end

	function ENT:Think()
		if(!self:GetOwner():GetNWBool("Parachuting")) then self:Remove() end
	end
end