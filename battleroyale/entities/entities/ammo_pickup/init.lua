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
		if(caller:GetInventoryWeight() + self.Amount * UBR.Config.AmmoWeight > caller:GetInventoryCapacity()) then return end
		caller:GiveAmmo(self.Amount, self.AmmoType)
		self:Remove()
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)
end