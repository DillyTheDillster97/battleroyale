hook.Add("CalcView", "Plane", function(lp, origin, angles, fov)
	if(!LocalPlayer():GetNWBool("InPlane")) then return end

	local plane = GetGlobalEntity("Plane")
	if(!IsValid(plane)) then return end

	if(!GAMEMODE:RoundInProgress()) then return end
	if(!LocalPlayer():IsContestant()) then return end

	local tr = util.TraceLine({
		start = plane:GetPos(),
		endpos = plane:GetPos() - angles:Forward()*400,
		filter = plane
	})

	return {
		origin = tr.HitPos,
		drawviewer = true
	}
end)

hook.Add("PlayerBindPress", "PlaneJump", function(ply, bind, pressed)
	if(!ply:GetNWBool("InPlane")) then return end

	local plane = GetGlobalEntity("Plane")
	if(!IsValid(plane)) then return end

	if(bind == "+jump" && pressed) then
		net.Start("PlaneJump")
		net.SendToServer()

		return true
	end
end)