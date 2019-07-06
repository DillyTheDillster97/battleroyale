AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/popcan01a.mdl")
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
				return true
			end, 
			function(ply)
				ply:SetHealth(math.Clamp(ply:Health() + 10, 0, ply:GetMaxHealth()))
			end
		)
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)
end