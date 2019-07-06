AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/gascan001a.mdl")
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
				return ply:InVehicle(), UBR.ResolveString("must_be_in_vehicle")
			end, 
			function(ply)
				local veh = ply:GetVehicle()
				veh:SetNWFloat("Fuel", veh:GetNWFloat("MaxFuel"))
				if(!veh.Destroyed && !veh:IsEngineStarted()) then veh:Fire("TurnOn", true) end
			end
		)
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg)
end