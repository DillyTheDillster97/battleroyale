/*---------------------------------------------------------------------------
	Third person
---------------------------------------------------------------------------*/
local tpEnabled = false
local tpMulti = 0

hook.Add("CalcView", "ThirdPerson", function(lp, origin, angles, fov)
	if(!hook.Call("CanThirdPerson", GAMEMODE.Hooks)) then return end

	tpMulti = Lerp(FrameTime()*10, tpMulti, tpEnabled && (LocalPlayer():KeyDown(IN_ATTACK2) && 0.4 || 1) || 0)

	if(!tpEnabled && tpMulti < 0.05) then return end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() - angles:Forward()*tpMulti*80 + angles:Right()*tpMulti*20,
		filter = ply
	})

	local view = {}
	view.origin = tr.HitPos
	view.drawviewer = true

	return view
end)

hook.Add("HUDPaint", "ThirdPersonCrosshair", function()
	if(!hook.Call("CanThirdPerson", GAMEMODE.Hooks)) then return end

	local pos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()

	local alpha = tpMulti*255
	if(alpha < 1) then return end
	draw.SimpleText("×", "Trebuchet24", pos.x, pos.y, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

function UBR.ThirdPerson(state)
	if(!hook.Call("CanThirdPerson", GAMEMODE.Hooks)) then return end
	tpEnabled = isbool(state) && state || !tpEnabled
end

concommand.Add("ubr_thirdperson", UBR.ThirdPerson)