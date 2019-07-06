/*---------------------------------------------------------------------------
	Join/leave/spawn messages
---------------------------------------------------------------------------*/
net.Receive("JoinMessage", function()
	local name = net.ReadString()
	chat.AddText(Color(52, 152, 219), "[Arion] ", Color(255, 255, 255, 255), name, Color(52, 152, 219), " has connected!")
end)

net.Receive("DisconnectMessage", function()
	local name = net.ReadString()
	local reason = net.ReadString()
	chat.AddText(Color(52, 152, 219), "[Arion] ", Color(255, 255, 255, 255), name, Color(52, 152, 219), " has disconnected! ", Color(255, 255, 255, 255), reason)
end)

net.Receive("SpawnMessage", function()
	local name = net.ReadString()
	chat.AddText(Color(52, 152, 219), "[Arion] ", Color(255, 255, 255, 255), name, Color(52, 152, 219), " has spawned!")
end)


/*---------------------------------------------------------------------------
	Fancy chat messages
---------------------------------------------------------------------------*/