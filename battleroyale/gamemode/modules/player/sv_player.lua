/*---------------------------------------------------------------------------
	Handling player spawns, loadouts, and models
---------------------------------------------------------------------------*/
function GM:PlayerSpawn(ply)
	self.BaseClass.PlayerSpawn(self, ply)

	if(ply.SpawnAsSpectator && self:RoundInProgress()) then
		ply:SetTeam(TEAM_SPECTATOR)
		ply.SpawnAsSpectator = false
	end

	ply:DrawShadow(ply:IsContestant() || !self:RoundInProgress())
end

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:StripAmmo()

	local info = ply:GetConfigTable()

	ply:SetWalkSpeed(UBR.Config.Walkspeed)
	ply:SetRunSpeed(UBR.Config.Runspeed)
	ply:SetCrouchedWalkSpeed(0.5)
end

function GM:PlayerSetModel(ply)
	local model = ply:GetConfigTable().model
	
	if(istable(model)) then
		model = model[math.random(#model)]
	end

	ply:SetModel(model)
end


/*---------------------------------------------------------------------------
	Handling player deaths
---------------------------------------------------------------------------*/
local offset = Vector(0, 0, 15)
function GM:PlayerDeath(ply, inflictor, attacker)
	self.BaseClass.PlayerDeath(self, ply, inflictor, attacker)

	ply.NextSpawn = CurTime() + 3

	if(self:RoundInProgress()) then
		ply.SpawnAsSpectator = true
	end

	if(IsValid(attacker) && attacker:IsPlayer() && attacker != ply) then
		attacker:AddKills(1)
		self:KillNotification(ply, attacker)
	end

	if(self:RoundInProgress()) then
		for k, v in pairs(ply:GetWeapons()) do
			if(IsValid(v) && v:Clip1() > 0) then
				UBR.SpawnAmmo(v:GetPrimaryAmmoType(), v:Clip1(), UBR.AmmoPos(ply:GetPos()) + offset)
			end
		end

		for _, v in pairs(game.BuildAmmoTypes()) do
			local amt = ply:GetAmmoCount(v.name)
			if(amt < 1) then continue end

			UBR.SpawnAmmo(v.name, amt, UBR.AmmoPos(ply:GetPos()) + offset)
		end

		for _, v in pairs(ply:GetWeapons()) do
			UBR.SpawnWeapon(v:GetClass(), UBR.AmmoPos(ply:GetPos()) + offset)
		end

		for k, v in pairs(ply:GetInventory()) do
			local ent = ents.Create(v.class)
			ent:SetPos(UBR.AmmoPos(ply:GetPos()))
			ent:SetAngles(Angle(0, math.Rand(0, 360), 0))
			ent:Spawn()
		end

		ply:ClearInventory()
	end
end

function GM:PlayerDeathThink(ply)
	if(CurTime() >= ply.NextSpawn) then
		ply:Spawn()
		return true
	end

	return false
end


/*---------------------------------------------------------------------------
	Handling player fall damage
---------------------------------------------------------------------------*/
function GM:GetFallDamage(ply, speed)
	return ply:IsSpectator() && 0 || speed/UBR.Config.FallDamper
end


/*---------------------------------------------------------------------------
	Handling player initial spawns
---------------------------------------------------------------------------*/
function GM:PlayerInitialSpawn(ply)
	self:Spectatorify(ply)
	ply:SetupParachuteColor()
	ply:SetupStats()
	ply:SetCustomCollisionCheck(true)
end


/*---------------------------------------------------------------------------
	Restricting actions to certain teams
---------------------------------------------------------------------------*/
UBR.Debug = false

function GM:PlayerNoClip(ply)
	if(UBR.Debug) then return true end
	return ply:IsSpectator()
end

function GM:PlayerSwitchFlashlight(ply)
	return ply:IsContestant()
end

function GM:AllowPlayerPickup(ply)
	return ply:IsContestant()
end

function GM:PlayerCanPickupItem(ply)
	return ply:IsContestant()
end

function GM:CanPlayerEnterVehicle(ply)
	return ply:IsContestant()
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if(UBR.Debug) then return false end
	return !ply:GetNWBool("InPlane") && ply:IsContestant()
end

function GM:CanPlayerEnterVehicle(ply)
	return ply:IsContestant()
end

function GM:PlayerUse(ply, item)
	return ply:IsContestant()
end

function GM:AllowPlayerPickup(ply)
	return ply:IsContestant()
end

function GM:PlayerCanPickupItem(ply)
	return ply:IsContestant()
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	if(UBR.Debug) then return true end
	return listener:Team() == talker:Team(), listener:IsContestant() || talker:IsContestant()
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	if(UBR.Debug) then return true end
	if(!speaker:IsPlayer()) then return true end
	return !(speaker:IsSpectator() && listener:IsContestant())
end

function GM:PlayerCanPickupWeapon(ply, wep)
	if(UBR.Debug) then return true end
	return ply:IsContestant() && table.Count(ply:GetWeapons()) < UBR.Config.MaxWeapons
end

function GM:CanPlayerSuicide(ply)
	if(UBR.Debug) then return true end
	if(ply:GetNWBool("InPlane")) then return false end
	return ply:IsContestant()
end