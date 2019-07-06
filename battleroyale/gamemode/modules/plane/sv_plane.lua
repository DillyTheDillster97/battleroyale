util.AddNetworkString("PlaneJump")

function GM:SetupPlane()
	local center = UBR.Config.MapCenter
	local pos = Vector(center.x, center.y, UBR.Config.MapHeight)
	local ang = Angle(0, math.random(0, 360))

	local origin = pos - ang:Forward() * UBR.Config.MapRadius

	local plane = ents.Create("plane")
	plane.RemoveDist = UBR.Config.MapRadius * UBR.Config.MapRadius * 1.95
	plane:SetPos(origin)
	plane:SetAngles(ang)
	plane:Spawn()

	SetGlobalEntity("Plane", plane)

	return plane
end

net.Receive("PlaneJump", function(len, ply)
	if(!ply:GetNWBool("InPlane")) then return end
	
	local plane = GetGlobalEntity("Plane")
	if(!IsValid(GetGlobalEntity("Plane"))) then return end

	plane:Eject(ply)
end)