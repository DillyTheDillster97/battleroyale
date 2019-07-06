util.AddNetworkString("KillNotif")

function GM:KillNotification(ply, attacker)
	local wep = attacker:GetActiveWeapon()

	net.Start("KillNotif")
		net.WriteString(ply:Nick())
	net.Send(attacker)
end