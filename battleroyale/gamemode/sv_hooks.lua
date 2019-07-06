/*---------------------------------------------------------------------------
	Name: CanLootAirdrop
	Description: Called when a player starts looting an airdrop, and
	repeatedly after until they are done looting, to make sure they are
	allowed to continue looting.
---------------------------------------------------------------------------*/
function GM.Hooks:CanLootAirdrop(ply, airdrop)
	if(ply:GetPos():DistToSqr(airdrop:GetPos()) > 10000) then return false end
	if(!ply:Alive()) then return false end
	if(!GAMEMODE:RoundInProgress()) then return false end
	if(!ply:IsContestant()) then return false end
	if(ply:KeyDown(IN_ATTACK) || ply:KeyDown(IN_ATTACK2) || ply:KeyDown(IN_RELOAD) || ply:KeyDown(IN_JUMP)) then return false end

	return true
end


/*---------------------------------------------------------------------------
	Name: CanStartRound
	Description: Called when the round system attempts to start a round.
	Determines whether a round can actually be started.
---------------------------------------------------------------------------*/
function GM.Hooks:CanStartRound()
	return player.GetCount() >= UBR.Config.MinPlayers
end


/*---------------------------------------------------------------------------
	Name: CanChangeParachuteColor
	Description: Called when a player attempts to change the color of their
	parachute. Use this to only allow certain ranks, etc.
---------------------------------------------------------------------------*/
function GM.Hooks:CanChangeParachuteColor(ply, oldCol, newCol)
	return oldCol != newCol
end


/*---------------------------------------------------------------------------
	Name: AirdropSpawned
	Description: Called whenever an airdrop is spawned.
---------------------------------------------------------------------------*/
function GM.Hooks:AirdropSpawned(drop)
	GAMEMODE:Notify(UBR.ResolveString("airdrop_spawned"))
end


/*---------------------------------------------------------------------------
	Name: CanUseItem
	Description: Called to determine whether or not a player is allowed to
	use an item.
---------------------------------------------------------------------------*/
function GM.Hooks:CanUseItem(ply)
	local vel = (ply:InVehicle() && ply:GetVehicle() || ply):GetVelocity():Length2DSqr()
	if(vel > 5000) then return false end
	if(ply:KeyDown(IN_ATTACK) || ply:KeyDown(IN_ATTACK2)) then return false end
	if(!ply:InventoryContains(ply.UsingKey)) then return false end
	if(ply:GetNWBool("InPlane")) then return false end
	if(!ply:Alive()) then return false end

	return true
end


/*---------------------------------------------------------------------------
	Name: GetZoneDamage
	Description: Called when the game determines how much damage it should
	deal to a player outside of the zone.
---------------------------------------------------------------------------*/
function GM.Hooks:GetZoneDamage(ply, dmg) return dmg end


/*---------------------------------------------------------------------------
	Name: GetVehicleDamage
	Description: Called when a vehicle is damaged by a player. Use this to
	modify the amount of damage dealt.
---------------------------------------------------------------------------*/
function GM.Hooks:GetVehicleDamage(veh, dmg) return dmg end


/*---------------------------------------------------------------------------
	Name: Join/leave Messages
	Description: Return false in any of these hooks to prevent the game
	sending the corresponding message on player join/spawn/leave.
---------------------------------------------------------------------------*/
function GM.Hooks:ShouldShowConnectMessage(name) return true end
function GM.Hooks:ShouldShowSpawnMessage(ply) return true end
function GM.Hooks:ShouldShowDisconnectMessage(name, reason) return true end