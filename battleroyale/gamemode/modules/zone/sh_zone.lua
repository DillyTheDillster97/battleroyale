/*---------------------------------------------------------------------------
	Gamemode functions for interacting with the zone
---------------------------------------------------------------------------*/
local lerp = 0.016

function GM:GetZonePos()
	return GetGlobalVector("ZonePos")
end

function GM:GetZoneRadius()
	return GetGlobalFloat("ZoneRadius")
end

function GM:ZoneActive()
	return GetGlobalBool("ZoneActive")
end

function GM:GetZoneMoveTime()
	return GetGlobalInt("ZoneMoveTime", CurTime())
end


/*---------------------------------------------------------------------------
	Draws the zone
---------------------------------------------------------------------------*/
if(CLIENT) then
	local rad = 0
	local smoothPos = Vector()

	function GM:DrawZone()
		if(!self:ZoneActive()) then return end
		local speed = FrameTime()*2

		rad = Lerp(speed, rad, self:GetZoneRadius())

		local pos = self:GetZonePos()
		smoothPos = Vector(
			Lerp(speed, smoothPos.x, pos.x),
			Lerp(speed, smoothPos.y, pos.y),
			Lerp(speed, smoothPos.z, pos.z)
		)

		local alpha = math.Remap(LocalPlayer():GetPos():Distance(smoothPos), rad*0.5, rad, 20, 60)
		alpha = math.Clamp(alpha, 20, 60)

		if(alpha <= 0) then return end

		render.CullMode(MATERIAL_CULLMODE_CW)
		render.SetColorMaterial()
		render.DrawSphere(smoothPos, rad, 50, 50, ColorAlpha(UBR.Config.ZoneColor, alpha))

		render.CullMode(MATERIAL_CULLMODE_CCW)
		render.SetColorMaterial()
		render.DrawSphere(smoothPos, rad, 50, 50, ColorAlpha(UBR.Config.ZoneColor, alpha))
	end
end