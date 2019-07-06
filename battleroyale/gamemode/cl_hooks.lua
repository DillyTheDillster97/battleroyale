/*---------------------------------------------------------------------------
	Name: CanThirdPerson
	Description: Called when the game polls the local player's ability
	to use third person mode. Called every frame (to avoid drawing third
	person if the player is already in third person, for instance)
---------------------------------------------------------------------------*/
function GM.Hooks:CanThirdPerson()
	if(!UBR.Config.EnableThirdPerson) then return false end
	if(LocalPlayer():InVehicle()) then return false end
	if(LocalPlayer():GetNWBool("InPlane")) then return false end
	if(!LocalPlayer():IsContestant() && GAMEMODE:RoundInProgress()) then return false end
	if(!LocalPlayer():Alive()) then return false end

	return true
end