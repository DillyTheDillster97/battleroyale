/*---------------------------------------------------------------------------
	Pools the network string we use for showing the winscreen
---------------------------------------------------------------------------*/
util.AddNetworkString("ShowWinscreen")


/*---------------------------------------------------------------------------
	Opens the winscreen for all players when somebody wins
---------------------------------------------------------------------------*/
function GM:Win(winner)
	net.Start("ShowWinscreen")
		net.WriteString(winner:Nick())
	net.Broadcast()
end