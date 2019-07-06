AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local obj = self:GetPhysicsObject()
    if(IsValid(obj)) then obj:Wake() end
end

function ENT:Use(activator, caller)
	if(IsValid(caller) && caller:IsPlayer()) then
		local allowed = gamemode.Call("PlayerCanPickupWeapon", caller)

		if(allowed) then
			if(caller:HasWeapon(self.Class)) then 
				caller:Notify(UBR.ResolveString("already_has_weapon"))
				return
			end

			local wep = caller:Give(self.Class, true)
			wep:SetClip1(0)
			self:Remove()
		else
			caller:Notify(UBR.ResolveString("too_many_weapons"))
		end
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)
end