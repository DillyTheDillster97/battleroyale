//util.AddNetworkString("PlaneSound")

/*---------------------------------------------------------------------------
	Setting up teams by making everyone a contestant
---------------------------------------------------------------------------*/
function GM:SetupTeams()
	local plane = self:SetupPlane()

	//net.Start("PlaneSound")
	//	net.WriteEntity(plane)
	//net.Broadcast()

	for k, v in pairs(player.GetAll()) do
		v:SetKills(0)
		v:SetNWBool("InPlane", true)

		plane.Passengers[v] = true

		v:SetTeam(TEAM_CONTESTANT)
	end
end


/*---------------------------------------------------------------------------
	Setting a player, or a table of players, or everyone, to spectators
---------------------------------------------------------------------------*/
function GM:Spectatorify(ply)
	if(ply && !istable(ply)) then ply = {ply} end

	for k, v in pairs(ply || player.GetAll()) do
		v:SetTeam(TEAM_SPECTATOR)
		v:ExitVehicle()
		v:ClearInventory()
		v:Spawn()
	end
end