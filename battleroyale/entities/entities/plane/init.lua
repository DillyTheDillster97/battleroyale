AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("PlayerEjected")

function ENT:Initialize()
	self:SetModel("models/freeman/ubr_c130herc.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self.Passengers = {}
	self.EjectTime = CurTime() + 1

	local phys = self:GetPhysicsObject()
	if(IsValid(phys)) then phys:Wake() phys:EnableGravity(false) end
end

function ENT:PhysicsCollide(data)
	if(data.HitEntity == game.GetWorld()) then
		self.CanRemove = true
	end
end

function ENT:Eject(ply)
	net.Start("PlayerEjected")
		net.WriteEntity(self)
	net.Send(ply)

	ply:Spawn()

	ply:SetNWBool("InPlane", false)
	ply:SetPos(self:GetPos())

	ply:RemoveFlags(FL_ONGROUND)

	ply:SetNWVector("StartPos", self:GetPos())
	ply:SetNWBool("DisallowParachute", false)
	ply:SetNWBool("AutoPara", true)
	ply:SetNWBool("Parachuting", false)

	hook.Call("PlayerEjectedFromPlane", GAMEMODE.Hooks, ply, self)
end

function ENT:OnRemove()
	for k, v in pairs(self.Passengers) do
		self:Eject(k)
	end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if(IsValid(phys)) then phys:SetVelocity(self:GetForward()*UBR.Config.PlaneSpeed) end

	if(CurTime() > self.EjectTime && self:GetPos():DistToSqr(UBR.Config.MapCenter) > self.RemoveDist) then self:Remove() end
	if(self.CanRemove) then self:Remove() end

	for k, v in pairs(self.Passengers || {}) do
		if(!k:GetNWBool("InPlane")) then
			self.Passengers[k] = nil
		end
	end
end