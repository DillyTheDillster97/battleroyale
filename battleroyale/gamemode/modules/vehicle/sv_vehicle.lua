/*---------------------------------------------------------------------------
	Handle fuel
---------------------------------------------------------------------------*/
function GM:VehicleMove(ply, veh, mv)
	self.BaseClass.VehicleMove(self, ply, veh, mv)
	if(!UBR.Config.VehicleFuelEnabled) then return end
	
	if(!veh.nextmove || CurTime() > veh.nextmove) then
		local vel = veh:GetVelocity():Length2DSqr()
		if(vel < 1) then return end

		local fuel = veh:GetNWFloat("Fuel")
		local newFuel = fuel-vel/300000

		if(newFuel <= 0) then
			veh:Fire("TurnOff", true)
			veh:SetNWFloat("Fuel", 0)
		else
			veh:SetNWFloat("Fuel", newFuel)
		end

		veh.nextmove = CurTime() + 0.4
	end
end


/*---------------------------------------------------------------------------
	Disallow entering vehicles when they are destroyed
---------------------------------------------------------------------------*/
function GM:CanPlayerEnterVehicle(ply, veh)
	return !(UBR.Config.VehicleHealthEnabled && veh.Destroyed)
end


/*---------------------------------------------------------------------------
	Making sure the vehicle is off when it is entered without fuel
---------------------------------------------------------------------------*/
function GM:PlayerEnteredVehicle(ply, veh)
	if(!UBR.Config.VehicleFuelEnabled) then return end
	
	if(veh:GetNWFloat("Fuel") <= 0) then
		veh:Fire("TurnOff", true)
	end
end


/*---------------------------------------------------------------------------
	Damages the player when they leave their vehicle, if it's going fast
---------------------------------------------------------------------------*/
function GM:PlayerLeaveVehicle(ply, veh)
	if(!UBR.Config.DamageOnVehicleExit) then return end

	local vel = veh:GetVelocity():Length2DSqr()
	local dmg = math.Remap(vel,100000,1000000,0,70)

	if(dmg < 10) then return end
	timer.Simple(0, function()
		if(!IsValid(ply) || !ply:IsPlayer()) then return end
		ply:TakeDamage(dmg, veh, veh)
	end)
end


/*---------------------------------------------------------------------------
	Vehicle damage
---------------------------------------------------------------------------*/
function GM:EntityTakeDamage(veh, dmginfo)
	if(!UBR.Config.VehicleHealthEnabled) then return end

	if(!veh:IsVehicle()) then return end
	local hp = veh:Health()

	local dmg = dmginfo:GetDamage()
	if(dmginfo:IsBulletDamage()) then
		dmg = dmg*750
	elseif(dmginfo:IsExplosionDamage()) then
		dmg = dmg*8
	end

	dmg = hook.Call("GetVehicleDamage", self.Hooks, veh, dmg*UBR.Config.VehicleDamageMultiplier)
	
	if(veh.Destroyed) then return end

	if(!veh.Damaged && hp <= 50) then
		local engineId = veh:LookupAttachment("vehicle_engine")
		ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, veh, engineId)
		veh.Damaged = true
	end

	if(hp - dmg <= 0) then
		local time = math.random(5, 10)

		veh:Fire("TurnOff", true)
		veh:SetNWFloat("Fuel", 0)
		veh:Ignite(time)
		veh.Destroyed = true

		timer.Simple(time, function()
			if(!IsValid(veh) || !veh:IsVehicle()) then return end
			
			local engineId = veh:LookupAttachment("vehicle_engine")
			local enginePos = veh:GetAttachment(engineId)

			local boom = ents.Create("env_explosion")
			boom:SetPos(enginePos.Pos)
			boom:SetAngles(enginePos.Ang)
			boom:Spawn()
			boom:SetOwner(veh)
			boom:SetKeyValue("iMagnitude", "220")
			boom:Fire("Explode", 0, 0)
			boom:EmitSound("weapon_AWP.Single")
		end)
	end

	veh:SetHealth(hp - dmg)
end