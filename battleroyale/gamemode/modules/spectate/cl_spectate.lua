/*---------------------------------------------------------------------------
	Variables for click cooldown and player being spectated
---------------------------------------------------------------------------*/
local spectating = 1
local cd = CurTime()


/*---------------------------------------------------------------------------
	Cycle through contestants with leftmouse/rightmouse
---------------------------------------------------------------------------*/
function GM:SpectatorKeyPress(ply, key)
	if(ply:IsContestant() || !self:RoundInProgress()) then return end

	if(CurTime() > cd) then cd = CurTime() + 0.1 else return end

	if(key == IN_ATTACK) then
		if(self:GetLivingContestants()[spectating + 1]) then
			spectating = spectating + 1
		else spectating = 1 end
	end

	if(key == IN_ATTACK2) then
		if(self:GetLivingContestants()[spectating - 1]) then
			spectating = spectating - 1
		else spectating = #self:GetLivingContestants() end
	end
end

/*---------------------------------------------------------------------------
	Called in GM:HUDPaint, paints spectator overlay
---------------------------------------------------------------------------*/
surface.CreateFont("SpectateName", {font = "Titillium Web", size = 39})
surface.CreateFont("SpectateValue", {font = "Roboto Thin", size = 18, weight = 100})
surface.CreateFont("SpectateHint", {font = "Roboto Thin", size = 16.5, weight = 100})
local spectatingText = "Spectating"

function GM:SpectatorHUD()
	if(LocalPlayer():IsContestant() || !self:RoundInProgress()) then return end

	local ply = self:GetLivingContestants()[spectating]
	if(!ply) then spectating = 1 return end

	local name = ply:Nick()
	surface.SetFont("SpectateName")
	local tw, th = surface.GetTextSize(name)

	local x, y = ScrW()/2, ScrH()/1.7

	draw.SimpleText(name, "SpectateName", x, y, Color(255, 255, 255, 120), TEXT_ALIGN_CENTER)

	w, h = tw*1.5, ScreenScale(8)
	x, y = x - w/2, y + th

	local t = {
		{
			name = UBR.ResolveString("health"),
			val = ply:Health().."%"
		},
		{
			name = UBR.ResolveString("armor"),
			val = ply:Armor().."%"
		},
		{
			name = UBR.ResolveString("kills"),
			val = ply:GetNWInt("KillCount", 0)
		}
	}

	local count = 1
	for k, v in ipairs(t) do
		draw.SimpleText(v.name..": "..v.val, "SpectateValue", x+w/2, y+h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(255, 255, 255, count%2==0 && 20 || 40)
		surface.DrawRect(x, y, w, h)
		y = y + h

		count = count + 1
	end

	draw.SimpleText(UBR.ResolveString("lmb"), "SpectateHint", x+w, y, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.SimpleText(UBR.ResolveString("rmb"), "SpectateHint", x, y, Color(255, 255, 255, 255))
end


/*---------------------------------------------------------------------------
	Spectator third-person view
---------------------------------------------------------------------------*/
hook.Add("CalcView", "SpectatorCalcView", function(lp, origin, angles)
	if(LocalPlayer():IsContestant() || !GAMEMODE:RoundInProgress()) then return end
	
	local ply = GAMEMODE:GetLivingContestants()[spectating]
	if(!ply) then spectating = 1 return end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() - angles:Forward() * 80,
		filter = ply:InVehicle() && ply:GetVehicle() || ply
	})

	return {origin = tr.HitPos}
end)


/*---------------------------------------------------------------------------
	Don't draw spectators if you're a contestant
---------------------------------------------------------------------------*/
function GM:PrePlayerDraw(ply)
	return LocalPlayer():IsContestant() && ply:IsSpectator()
end


/*---------------------------------------------------------------------------
	Making sure sounds work properly
---------------------------------------------------------------------------*/
function GM:EntityEmitSound(data)
	if(LocalPlayer():IsContestant() || !self:RoundInProgress()) then return end
	
	local ply = self:GetLivingContestants()[spectating]
	if(!ply) then return end

	if(data.Entity == ply) then
		data.Entity = LocalPlayer()
		data.Pos = LocalPlayer():GetPos()
		return true
	end
end