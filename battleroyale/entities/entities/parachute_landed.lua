AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Parachute - Landed"
ENT.Author = "Threebow"

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
else
	function ENT:Initialize()
		self:SetModel("models/freeman/parachute_ground.mdl")
		self:SetMoveType(MOVETYPE_FLYGRAVITY)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		local owner = self:GetOwner()
		
		local col = owner:GetParachuteColor()
		if(col) then self:SetColor(col) end

		self.RemoveAt = CurTime() + 6
	end

	function ENT:Think()
		if(self.RemoveAt && CurTime() > self.RemoveAt) then
			self:Remove()
		end
	end
end