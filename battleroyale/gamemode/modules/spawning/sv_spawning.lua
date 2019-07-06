/*---------------------------------------------------------------------------
	Spawn weapon
---------------------------------------------------------------------------*/
function UBR.SpawnAmmo(ammoType, amount, pos)
	local ammo = ents.Create("ammo_pickup")
	ammo:SetPos(pos)
	ammo:SetAngles(Angle(0, math.random(0, 360), 0))
	ammo:SetModel(UBR.AmmoTypeToModel(ammoType))
	ammo:SetAmmo(ammoType, amount)
	ammo:Spawn()

	return ammo
end

function UBR.SpawnWeapon(class, pos, spawnAmmo, tbl)
	local wepTbl = weapons.GetStored(class)

	local wep = ents.Create("weapon_pickup")
	wep:SetWeapon(class, wepTbl)
	wep:SetPos(pos)
	wep:SetAngles(Angle(0, math.random(0, 360), 0))
	wep:Spawn()

	hook.Call("WeaponSpawned", GAMEMODE.Hooks, wep)

	if(spawnAmmo) then
		local ammoType, mag = wepTbl.Primary.Ammo, wepTbl.Primary.ClipSize
		local amt = tbl.ammoCount

		for i = istable(amt) && amt[1] || 1, istable(amt) && amt[2] || amt do
			local ammo = UBR.SpawnAmmo(ammoType, mag,UBR.AmmoPos(pos))
			hook.Call("AmmoSpawned", GAMEMODE.Hooks, ammo, wep)
		end
	end

	return wep, wepTbl
end

function GM:SpawnWeapon(pos, data)
	UBR.SpawnWeapon(data.class, pos + Vector(0, 0, 15), true, data)
end


/*---------------------------------------------------------------------------
	Spawn vehicle
---------------------------------------------------------------------------*/
function GM:SpawnVehicle(pos, tbl, cfgTbl)
	local veh = ents.Create(tbl.Class)
	veh:SetModel(tbl.Model)

	veh:SetColor(istable(cfgTbl.color) && (cfgTbl.color[math.random(#cfgTbl.color)] || ColorRand()) || cfgTbl.color || ColorRand())
	veh:SetPos(pos + Vector(0, 0, 100))
	veh:SetAngles(Angle(0, math.Rand(0, 360), 0))
	
	if(UBR.Config.VehicleFuelEnabled) then
		veh:SetNWFloat("Fuel", cfgTbl.fuel || UBR.Config.DefaultFuel)
		veh:SetNWFloat("MaxFuel", cfgTbl.fuel || UBR.Config.DefaultFuel)
	end

	if(UBR.Config.VehicleHealthEnabled) then
		veh:SetHealth(100)
		veh:SetMaxHealth(100)
	end
		
	if(tbl.KeyValues) then
		for k, v in pairs(tbl.KeyValues) do
			veh:SetKeyValue(k, v)
		end
	end

	veh.VehicleName = name
	veh.VehicleTable = tbl

	veh:Spawn()
	veh:Activate()

	hook.Call("VehicleSpawned", self.Hooks, veh)
end


/*---------------------------------------------------------------------------
	Spawn entity
---------------------------------------------------------------------------*/
function GM:SpawnEntity(pos, data)
	local ent = ents.Create(data.class)
	ent:SetPos(pos+Vector(0, 0, 15))
	ent:SetAngles(Angle(0, math.Rand(0, 360), 0))
	ent:Spawn()

	hook.Call("EntitySpawned", self.Hooks, veh)
end


/*---------------------------------------------------------------------------
	Handles spawning of stuff
---------------------------------------------------------------------------*/
local i
local t
local shouldTick = false
local nextTick = CurTime()
function GM:HandleSpawning()
	if(!shouldTick) then return end
	
	local tbl = t[i]
	if(!tbl) then shouldTick = false hook.Call("DoneSpawning", self.Hooks) return end
	
	if(CurTime() > nextTick) then nextTick = CurTime()+0.03 else return end
	self["Spawn"..tbl[1]](self, tbl[2], tbl[3], tbl[4])

	i = i + 1
end


/*---------------------------------------------------------------------------
	Gets the vehicle table properly
---------------------------------------------------------------------------*/
local function getVehicles()
	local vehicles = list.Get("Vehicles")

	for k, v in pairs(list.Get("SCarsList") or {}) do
		vehicles[v.PrintName] = {
			Name = v.PrintName,
			Class = v.ClassName,
			Model = v.CarModel
		}
	end

	local t = {}
	for k, v in pairs(vehicles) do
		t[v.PrintName || v.Name] = v
	end

	return t
end


/*---------------------------------------------------------------------------
	Spawning weapons
---------------------------------------------------------------------------*/
function GM:SpawnItems()
	i = 1
	t = {}

	for k, v in pairs(UBR.WeaponSpawnpoints) do
		local data = UBR.Weapons[math.random(#UBR.Weapons)]
		if(!data) then break end

		if(math.random() > (data.rarity || 0.8)) then continue end

		table.insert(t, {"Weapon", v, data})
	end

	for k, v in pairs(UBR.VehicleSpawnpoints) do
		local cfgTbl = UBR.Vehicles[math.random(#UBR.Vehicles)]
		if(!cfgTbl) then break end

		local tbl = getVehicles()[cfgTbl.name]
		if(math.random() > (cfgTbl.rarity || 0.5)) then continue end

		table.insert(t, {"Vehicle", v, tbl, cfgTbl})
	end

	for k, v in pairs(UBR.EntitySpawnpoints) do
		local data = UBR.Entities[math.random(#UBR.Entities)]
		if(!data) then break end

		if(math.random() > (data.rarity || 0.7)) then continue end

		table.insert(t, {"Entity", v, data})
	end

	shouldTick = true
end