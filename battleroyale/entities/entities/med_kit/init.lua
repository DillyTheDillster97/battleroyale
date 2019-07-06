AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/items/healthkit.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTooltip(self.PrintName)

    local obj = self:GetPhysicsObject()
    if(IsValid(obj)) then obj:Wake() end
end

function ENT:Use(activator, ply)
	if(IsValid(ply) && ply:IsPlayer()) then
		ply:AddToInventory(
			self,
			function(ply)
				return ply:Health() < ply:GetMaxHealth(), UBR.ResolveString("below_100_health")
			end, 
			function(ply)
				ply:SetHealth(ply:GetMaxHealth())
			end
		)
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)
end