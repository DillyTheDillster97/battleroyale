GM.Hooks = GM.Hooks || {}


/*---------------------------------------------------------------------------
	Name: CanPickupItem
	Description: Used to determine if a player can pick up an item in the
	vicinity, or view it in their inventory.
---------------------------------------------------------------------------*/
local dist = UBR.Config.PickupDistance * UBR.Config.PickupDistance
function GM.Hooks:CanPickupItem(ply, item)
	if(!item.Lootable) then return false end
	if(ply:IsSpectator()) then return false end
	if(!GAMEMODE:RoundInProgress()) then return false end
	if(ply:GetPos():DistToSqr(item:GetPos()) > dist) then return false end
	if(!ply:Alive()) then return false end
	if(ply:GetNWBool("InPlane")) then return false end

	return true
end


/*---------------------------------------------------------------------------
	Name: GetPlayerInventoryCapacity
	Description: Allows you to modify a player's inventory capacity.
	The capacity argument is the original inventory's capacity, if the
	default capacity is 100 and you return capacity * 2, players will
	have 200 capacity.
---------------------------------------------------------------------------*/
function GM.Hooks:GetPlayerInventoryCapacity(ply, capacity)
	return capacity
end