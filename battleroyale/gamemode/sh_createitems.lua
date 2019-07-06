/*---------------------------------------------------------------------------
	Global tables
---------------------------------------------------------------------------*/
UBR.Weapons = {}
UBR.AirdropWeapons = {}
UBR.Teams = {}
UBR.Vehicles = {}
UBR.PlayerSpawnpoints = {}
UBR.WeaponSpawnpoints = {}
UBR.VehicleSpawnpoints = {}
UBR.Entities = {}
UBR.HelpTabs = {}


/*---------------------------------------------------------------------------
	Gets position for ammo boxes relative to a gun's position
---------------------------------------------------------------------------*/
function UBR.AmmoPos(v)
	local rand = VectorRand()*40
	return v + Vector(rand.x, rand.y)
end


/*---------------------------------------------------------------------------
	Interaction with ammo types
---------------------------------------------------------------------------*/
UBR.DefaultAmmoModel = "models/Items/BoxSRounds.mdl"

local path = "models/freeman/ammobox_"
local ammoModelPaths = {
	["9mm"] = path.."9mmpara.mdl",
	["acp"] = path.."45auto.mdl",
	["5.56"] = path.."556nato.mdl",
	["7.62"] = path.."762nato.mdl",
	["gauge"] = "models/Items/BoxBuckshot.mdl"
}

function UBR.RegisterAmmoModelPath(name, model)
	ammoModelPaths[name] = model
end

local ammoModels = {}

function UBR.AddAmmoModel(match, model)
	ammoModels[match:lower()] = ammoModelPaths[model || match:lower()] || UBR.DefaultAmmoModel
end

function UBR.GetAmmoModel(match)
	return ammoModels[match:lower()] || UBR.DefaultAmmoModel
end

function UBR.GetAmmoModels()
	return ammoModels
end

local modelCache = {}
function UBR.AmmoTypeToModel(match)
	match = isnumber(match) && game.GetAmmoName(match) || match

	if(modelCache[match]) then return modelCache[match] end

	for k, v in pairs(ammoModels) do
		if(match:lower():find(k)) then
			modelCache[match] = v
			return v
		end
	end

	return UBR.DefaultAmmoModel
end


/*---------------------------------------------------------------------------
	Registers an entity
---------------------------------------------------------------------------*/
function UBR.AddEntity(class)
	table.insert(UBR.Entities, class)
end


/*---------------------------------------------------------------------------
	Adds entity spawnpoints
---------------------------------------------------------------------------*/
function UBR.AddEntitySpawnpoints(tbl)
	UBR.EntitySpawnpoints = tbl
end


/*---------------------------------------------------------------------------
	Registers a weapon type
---------------------------------------------------------------------------*/
function UBR.AddWeapon(tbl)
	table.insert(UBR.Weapons, tbl)
end


/*---------------------------------------------------------------------------
	Registers an airdrop weapon type
---------------------------------------------------------------------------*/
function UBR.AddAirdropWeapon(tbl)
	table.insert(UBR.AirdropWeapons, tbl)
end


/*---------------------------------------------------------------------------
	Registers the two teams
---------------------------------------------------------------------------*/
function UBR.RegisterContestant(tbl)
	UBR.Teams["Contestant"] = tbl
end

function UBR.RegisterSpectator(tbl)
	UBR.Teams["Spectator"] = tbl
end


/*---------------------------------------------------------------------------
	Registers a vehicle
---------------------------------------------------------------------------*/
function UBR.AddVehicle(tbl)
	table.insert(UBR.Vehicles, tbl)
end


/*---------------------------------------------------------------------------
	Registers vehicle spawnpoints
---------------------------------------------------------------------------*/
function UBR.AddVehicleSpawnpoints(tbl)
	UBR.VehicleSpawnpoints = tbl
end


/*---------------------------------------------------------------------------
	Registers player spawnpoints
---------------------------------------------------------------------------*/
function UBR.AddPlayerSpawnpoints(tbl)
	UBR.PlayerSpawnpoints = tbl
end


/*---------------------------------------------------------------------------
	Registers weapon spawnpoints
---------------------------------------------------------------------------*/
function UBR.AddWeaponSpawnpoints(tbl)
	UBR.WeaponSpawnpoints = tbl
end


/*---------------------------------------------------------------------------
	Help menu tabs
---------------------------------------------------------------------------*/
function UBR.AddHelpTab(title, text)
	if(SERVER) then return end
	table.insert(UBR.HelpTabs, {title = title, text = text})
end