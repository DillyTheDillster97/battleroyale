util.AddNetworkString("JoinMessage")
util.AddNetworkString("SpawnMessage")
util.AddNetworkString("DisconnectMessage")

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")

hook.Add("player_connect", "JoinMessage", function(data)
	if(!hook.Call("ShouldShowConnectMessage", GAMEMODE.Hooks, data.name)) then return end

	net.Start("JoinMessage")
		net.WriteString(data.name)
	net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "IPOnSpawn", function(ply)
	if(!hook.Call("ShouldShowSpawnMessage", GAMEMODE.Hooks, ply)) then return end

	net.Start("SpawnMessage")
		net.WriteString(ply:Nick())
	net.Broadcast()
end)

hook.Add("player_disconnect", "DisconnectMessage", function(data)
	if(!hook.Call("ShouldShowDisconnectMessage", GAMEMODE.Hooks, data.name, data.reason)) then return end

	net.Start("DisconnectMessage")
		net.WriteString(data.name)
		net.WriteString(data.reason)
	net.Broadcast()
end)