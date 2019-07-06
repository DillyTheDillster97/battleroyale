AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Airdrop"
ENT.Author = "Threebow"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Looting")
	self:NetworkVar("String", 0, "Tooltip")
end

if(CLIENT) then
	surface.CreateFont("AirdropDisplay", {font = "Open Sans", size = 140})
	surface.CreateFont("LootingHUD", {font = "Roboto Thin", size = 24, weight = 100})

	local looting = false
	local lootTime
	net.Receive("StartLootingAirdrop", function() looting = true lootTime = CurTime()+UBR.Config.AirdropLootTime end)
	net.Receive("StopLootingAirdrop", function() looting = false end)

	hook.Add("HUDPaint", "DrawAirdropLootProgress", function()
		if(!looting) then return end
		
		local w, h = 300, 32
		local x, y = ScrW()/2-w/2, ScrH()/1.5-h/2

		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawRect(x, y, w, h)

		local width = (lootTime-CurTime())/UBR.Config.AirdropLootTime*w
		width = math.Clamp(width, 0, w)
		surface.DrawRect(x, y, math.Round(width), h)

		draw.SimpleText(UBR.ResolveString("looting")..("."):rep(UBR.Dots), "LootingHUD", x+w/2, y+h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)

	function ENT:Draw()
		self:DrawModel()

		local pos, ang = self:LocalToWorld(Vector(21, 0, 0)), self:GetAngles()

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)

		cam.Start3D2D(pos, ang, 0.06)
			draw.SimpleText(self:GetLooting() && UBR.ResolveString("looting")..("."):rep(UBR.Dots) || UBR.ResolveString("airdrop"), "AirdropDisplay", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
else
	util.AddNetworkString("StartLootingAirdrop")
	util.AddNetworkString("StopLootingAirdrop")

	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local obj = self:GetPhysicsObject()
		if(IsValid(obj)) then obj:SetMass(300) obj:Wake() end

		self:SetTooltip(self.PrintName)

		self.Parachute = ents.Create("prop_physics")
		self.Parachute:SetModel("models/freeman/parachute_open.mdl")
		self.Parachute:SetColor(ColorRand())
		self.Parachute:SetPos(self:GetPos() + Vector(0, 0, 50))
		self.Parachute:SetAngles(self:GetAngles())
		self.Parachute:SetParent(self)
		self.Parachute:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self.Parachute:Spawn()
	end

	function ENT:CanLoot(ply)
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity

		if(ent != self) then return false end
		if(!self.Landed) then return false end

		return hook.Call("CanLootAirdrop", GAMEMODE.Hooks, ply, self)
	end

	function ENT:Use(activator, ply)
		if(!IsValid(ply) || !ply:IsPlayer()) then return end
		if(self:GetLooting()) then ply:Notify(UBR.ResolveString("already_being_looted")) return end
		if(!self:CanLoot(ply)) then return end

		self.Looter = ply
		self:SetLooting(true)
		self.LootFinish = CurTime() + UBR.Config.AirdropLootTime

		net.Start("StartLootingAirdrop")
		net.Send(ply)

		self:LootSound()
		self.SoundCD = CurTime() + 0.1
	end

	function ENT:FinishLooting(ply)
		net.Start("StopLootingAirdrop")
		net.Send(ply)

		self:EmitSound("items/ammocrate_open.wav")

		local tbl = UBR.AirdropWeapons[math.random(#UBR.AirdropWeapons)]
		if(!tbl) then return end

		UBR.SpawnWeapon(tbl.class, self:GetPos() + Vector(0, 0, 10), true, tbl)

		hook.Call("AirdropLooted", self.Hooks, ply)
	end

	function ENT:LootSound(level)
		self:EmitSound("npc/combine_soldier/gear"..math.random(1, 6)..".wav", level || 120)
	end

	function ENT:PhysicsCollide(data)
		if(self.Landed) then return end

		if(data.HitEntity == game.GetWorld()) then
			self.Landed = true
			if(IsValid(self.Parachute)) then
				self.Parachute.CanRemove = true
			end
			self:EmitSound("physics/concrete/concrete_block_impact_hard1.wav", 120)
		end
	end

	function ENT:Think()
		local phys = self:GetPhysicsObject()
		if(!self.Landed && IsValid(phys)) then
			phys:SetVelocity(Vector(0, 0, -UBR.Config.AirdropSpeed))
		end

		if(IsValid(self.Parachute) && self.Parachute.CanRemove) then self.Parachute:Remove() end

		if(!self:GetLooting()) then return end

		if(CurTime() > self.SoundCD) then
			self:LootSound()
			self.SoundCD = CurTime() + 0.2
		end

		if(!IsValid(self.Looter) || !self.Looter:IsPlayer() || !self:CanLoot(self.Looter)) then
			self:SetLooting(false)
			net.Start("StopLootingAirdrop")
			net.Send(self.Looter)
			return
		end

		if(CurTime() > self.LootFinish) then
			self:FinishLooting(self.Looter)
			self:SetLooting(false)
			self.Looter = nil
			self:Remove()
		end
	end
end