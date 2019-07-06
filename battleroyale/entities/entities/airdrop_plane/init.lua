AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/freeman/ubr_c130herc.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self.Dropped = false

	local phys = self:GetPhysicsObject()
	if(IsValid(phys)) then phys:Wake() phys:EnableGravity(false) end
end

function ENT:PhysicsCollide(data)
	if(data.HitEntity == game.GetWorld() && self.Dropped) then
		self.CanRemove = true
	end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if(IsValid(phys)) then phys:SetVelocity(self:GetForward()*1500) end
	
	if(self.CanRemove) then self:Remove() end

	local dist = self:GetPos():DistToSqr(self:GetDropPos())
	if(!self.Dropped && dist > self.Dist) then
		self.Dropped = true

		local airdrop = ents.Create("airdrop")
		airdrop:SetPos(self:GetDropPos())
		airdrop:SetAngles(self:GetAngles())
		airdrop:Spawn()
	end

	self.Dist = dist
end