/*---------------------------------------------------------------------------
	Hides default HUD Elements
---------------------------------------------------------------------------*/
local hide = {
	["CHudAmmo"] = true,
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSuitPower"] = true,
	["CHudCrosshair"] = true
}

function GM:HUDShouldDraw(e)
	return !hide[e]
end


/*---------------------------------------------------------------------------
	Returns text that describes your position relative to the zone
---------------------------------------------------------------------------*/
function GM:GetHUDZoneText()
	local pos = self:GetZonePos()
	local rad = self:GetZoneRadius()

	local dist = LocalPlayer():GetPos():Distance(pos)

	if(dist <= rad) then return UBR.ResolveString("in_safezone") end
	return UBR.ResolveString("out_of_safezone", math.Clamp(math.Round((dist-rad)/53), 0, 99999999))
end


/*---------------------------------------------------------------------------
	Returns text that describes the round state
---------------------------------------------------------------------------*/
function GM:GetHUDRoundText()
	local st = self:GetRoundState()

	if(st == STATE_COOLDOWN) then
		return UBR.ResolveString("cooldown")
	elseif(st == STATE_LOBBY) then
		local plys, min = #player.GetAll(), UBR.Config.MinPlayers
		if(plys >= min) then
			return UBR.ResolveString("starts_soon")
		else
			return UBR.ResolveString("waiting_for_plys", plys, min)
		end
	elseif(st == STATE_PREPARING) then
		local t = GetGlobalInt("PreparationTime", CurTime())
		t = t - CurTime()
		t = math.Round(t)
		t = math.Clamp(t, 0, UBR.Config.PreparationTime)
		return UBR.ResolveString("preparing", t)
	else return end
end


/*---------------------------------------------------------------------------
	Draws player statistics
---------------------------------------------------------------------------*/
surface.CreateFont("StatName", {font = "Roboto Thin", size = 32, weight = 100})
surface.CreateFont("StatValue", {font = "Consolas", size = 32})
function GM:DrawStats()
	if(!hook.Run("HUDShouldDraw", "Stats")) then return end

	if(self:RoundInProgress()) then return end
	if(LocalPlayer():IsContestant()) then return end
	
	local stats = UBR.GetStats()
	local x, y = ScrW()/2, ScrH()/1.5

	for k, v in pairs(stats) do
		if(k == "steamid" || k == "id") then continue end

		local name = UBR.ResolveString(k).."  "
		surface.SetFont("StatName")
		local nw, nh = surface.GetTextSize(name)

		local value = string.Comma(v)
		surface.SetFont("StatValue")
		local vw, vh = surface.GetTextSize(value)

		nw=nw+2
		nh=nh+2
		vw=vw+2
		vh=vh+2

		local tw = nw+vw

		draw.SimpleText(name, "StatName", x-vw/2, y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(value, "StatValue", x+nw/2, y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		y = y - nh
	end
end


/*---------------------------------------------------------------------------
	Returns text that describes zone damage/move times
---------------------------------------------------------------------------*/
function GM:GetHUDZoneTimer()
	local move = self:GetZoneMoveTime()
	if(!move || move == 0) then
		return UBR.ResolveString("final_circle")
	end
	
	move = move - CurTime()
	if(move < 0) then
		move = UBR.ResolveString("zone_shrinking")
	else
		move = UBR.ResolveString("shrinking_in", string.ToMinutesSeconds(move))
	end

	return move
end


/*---------------------------------------------------------------------------
	Function for drawing a good bar
---------------------------------------------------------------------------*/
surface.CreateFont("BarText", {font = "Oswald", size = 24, weight = 200})

local gradMat = Material("vgui/gradient-r")
local redVal = 230
function GM:DrawBar(x, y, w, h, val, maxVal, smoothVal, smoothAlpha)
	val = math.Clamp(val, 0, maxVal)

	local fill = smoothVal/maxVal*w

	smoothVal = Lerp(FrameTime()*8, smoothVal, val)
	smoothAlpha = Lerp(FrameTime()*8, smoothAlpha, math.Remap(val, maxVal/4, maxVal/4*3, 255, 20))
	smoothAlpha = math.Clamp(smoothAlpha, 20, 255)

	local red = math.Remap(smoothAlpha, 255, 20, 0, redVal)

	surface.SetDrawColor(math.max(red, redVal/2), red, red, smoothAlpha)
	surface.DrawRect(x, y, fill, h)

	if(red < redVal) then
		surface.SetDrawColor(redVal, red, red, smoothAlpha*(math.cos(CurTime()*5)+1)/2 - 20)
		surface.SetMaterial(gradMat)
		surface.DrawTexturedRect(x, y, fill, h)
	end

	surface.SetDrawColor(255, 255, 255, smoothAlpha/2)
	surface.DrawOutlinedRect(x, y, w, h)

	return smoothVal, smoothAlpha
end


/*---------------------------------------------------------------------------
	Draws the health bar, armor text, and zone text main HUD in general
---------------------------------------------------------------------------*/
local smoothHealth, smoothAlpha, smoothArmor = 0, 0, 0
function GM:DrawMainHUD()
	if(!hook.Run("HUDShouldDraw", "MainHUD")) then return end

	if(LocalPlayer():IsSpectator()) then return end
	local w, h = ScrW() / 4, ScrH() / 35
	local x, y = ScrW()/2 - w/2, ScrH() - h*2

	//(math.cos(CurTime()*0.9)+1)/2*100
	smoothHealth, smoothAlpha = self:DrawBar(x, y, w, h, LocalPlayer():Health(), LocalPlayer():GetMaxHealth(), smoothHealth, smoothAlpha)

	draw.SimpleText(self:GetHUDZoneTimer(), "BarText", ScrW()/2-w/2,y-2,Color(255, 255, 255, 200),TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
	draw.SimpleText(self:GetHUDZoneText(), "BarText", ScrW()/2+w/2,y-2,Color(255, 255, 255, 200),TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)

	smoothArmor = Lerp(FrameTime()*8, smoothArmor, LocalPlayer():Armor())
	local aw = math.Round(smoothArmor/100*w)

	surface.SetDrawColor(31, 71, 136, 200)
	surface.DrawRect(x+w/2-aw/2, y+h+2, aw, 3)
end


/*---------------------------------------------------------------------------
	Draws the player count and kill count at the top right
---------------------------------------------------------------------------*/
surface.CreateFont("GameStats", {font = "Oswald Light", size = 36, weight = 100})

function GM:DrawPlayerCount()
	if(!hook.Run("HUDShouldDraw", "PlayerCount")) then return end

	if(!self:RoundInProgress()) then return end

	local t = UBR.ResolveString("alive_count")
	local count = " "..self:GetContestantCount().." "

	surface.SetFont("GameStats")
	local tw, th = surface.GetTextSize(t)
	local cw, ch = surface.GetTextSize(count)

	tw, th, cw, ch = tw*1.1, th*1.1, cw*1.1, ch*1.1

	local x, y = ScrW()-tw-20, 20

	draw.RoundedBox(0, x, y, tw, th, Color(255, 255, 255, 150))
	draw.SimpleText(t, "GameStats", x+tw/2, y+th/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	x = x - cw
	draw.RoundedBox(0, x, y, cw, ch, Color(40, 40, 40, 150))
	draw.SimpleText(count, "GameStats", x+cw/2, y+ch/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function GM:DrawKillCount()
	if(!hook.Run("HUDShouldDraw", "KillCount")) then return end

	if(LocalPlayer():GetKills() <= 0) then return end
	if(LocalPlayer():IsSpectator()) then return end

	local t = UBR.ResolveString("kill_count")
	local count = " "..LocalPlayer():GetKills().." "

	surface.SetFont("GameStats")
	local tw, th = surface.GetTextSize(t)
	local cw, ch = surface.GetTextSize(count)

	tw, th, cw, ch = tw*1.1, th*1.1, cw*1.1, ch*1.1

	local aliveW = surface.GetTextSize(UBR.ResolveString("alive_count"))
	aliveW = aliveW + surface.GetTextSize(" "..self:GetContestantCount().." ")

	local x, y = ScrW()-tw-aliveW*1.1-30, 20

	draw.RoundedBox(0, x, y, tw, th, Color(255, 255, 255, 150))
	draw.SimpleText(t, "GameStats", x+tw/2, y+th/2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	x = x - cw
	draw.RoundedBox(0, x, y, cw, ch, Color(40, 40, 40, 150))
	draw.SimpleText(count, "GameStats", x+cw/2, y+ch/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


/*---------------------------------------------------------------------------
	Draws the round state
---------------------------------------------------------------------------*/
surface.CreateFont("RoundStateTitle", {font = "Oswald Light", size = ScreenScale(22), weight = 100})
surface.CreateFont("RoundState", {font = "Roboto Thin", size = ScreenScale(12), weight = 100})

function GM:DrawRoundState()
	if(!hook.Run("HUDShouldDraw", "RoundState")) then return end

	local txt = self:GetHUDRoundText()
	if(!txt) then return end

	local w, h = ScrW(), ScrH()/4
	local x, y = 0, ScrH()-h

	local clr = (math.cos(CurTime())+1)/2

	local title = UBR.ResolveString("title")
	surface.SetFont("RoundStateTitle")
	local tw, th = surface.GetTextSize(title)

	local x, y = ScrW()/2, ScrH()-ScrH()/5

	local col = Color(255 - clr * 255, clr * 200, 200 - clr * 170, 255)

	surface.SetDrawColor(ColorAlpha(col, 150))
	surface.DrawRect(x-tw/2, y, tw, 2)

	draw.SimpleText(title, "RoundStateTitle", x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(txt, "RoundState", x, y+6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end


/*---------------------------------------------------------------------------
	Draws the parachuting progress
---------------------------------------------------------------------------*/
local parachuteSmooth = 0
local parachuteAlphaSmooth = 0

surface.CreateFont("Parachute", {font = "Roboto Thin", size = ScreenScale(10), weight = 100})

function GM:DrawParachuteHUD()
	if(!hook.Run("HUDShouldDraw", "ParachuteHUD")) then return end

	if(!self:RoundInProgress()) then return end
	if(LocalPlayer():GetNWBool("DisallowParachute")) then return end
	if(!LocalPlayer():IsContestant()) then return end

	local tr = util.TraceLine({
		start = LocalPlayer():GetPos(),
		endpos = LocalPlayer():GetPos()-Vector(0, 0, UBR.Config.MapHeight),
		filter = LocalPlayer()
	})

	local distance = tr.HitPos:Distance(LocalPlayer():GetPos())
	distance = distance/53
	distance = math.Round(distance)

	if(distance <= 0) then return end

	local speed = LocalPlayer():GetVelocity():Length()
	speed = speed/22.65*1.60934
	speed = UBR.ResolveString("speed", math.Round(speed))

	local spawn = LocalPlayer():GetNWVector("StartPos")
	local start = spawn:Distance(LocalPlayer():GetPos())
	start = start / 53
	start = math.Round(start)

	local w, h = ScreenScale(6), ScreenScale(52)
	local x, y = w*2.5, ScrH()-h*1.3

	local progress = math.Remap(LocalPlayer():GetPos().z, spawn.z, tr.HitPos.z, h, 0)
	parachuteSmooth = Lerp(FrameTime()*10, parachuteSmooth, progress)

	local alpha = math.Remap(progress, 0, h, 150, 25)
	parachuteAlphaSmooth = Lerp(3 * FrameTime(), parachuteAlphaSmooth, alpha)

	surface.SetDrawColor(255, 255, 255, parachuteAlphaSmooth)
	surface.DrawRect(x, y+h-parachuteSmooth, w, parachuteSmooth)

	surface.SetDrawColor(255, 255, 255, parachuteAlphaSmooth)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetFont("Parachute")
	local dw, dh = surface.GetTextSize(distance.."m")
	local sw, sh = surface.GetTextSize(speed)

	draw.SimpleText(UBR.ResolveString("distance", distance), "Parachute", x+w*1.5, y+h/2-sh/2, Color(255, 255, 255, parachuteAlphaSmooth*2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(speed, "Parachute", x+w*1.5, y+h/2+dh/2, Color(255, 255, 255, parachuteAlphaSmooth*2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	if(!LocalPlayer():GetNWBool("Parachuting")) then
		local cin = (math.sin(CurTime() * 3) + 1) / 2
		local clr = Color(255, 255 - (cin * 90), 0)

		draw.SimpleText(UBR.ResolveString("activate_parachute"), "Parachute", ScrW()/2, ScrH()-ScrH()/3, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


/*---------------------------------------------------------------------------
	Draws stuff above peoples' heads
---------------------------------------------------------------------------*/
surface.CreateFont("NameDisplay", {font = "Roboto Light", size = 120, weight = 100})

function GM:DrawPlayerInfo(ply)
	if(!hook.Run("HUDShouldDraw", "PlayerInfo")) then return end

	if(!IsValid(ply)) then return end
	if(ply == LocalPlayer()) then return end
	if(!ply:Alive()) then return end
	if(LocalPlayer():InVehicle()) then return end
	if(LocalPlayer():IsContestant() && ply:IsSpectator()) then return end

	local distance = LocalPlayer():GetPos():Distance(ply:GetPos())
	local toCheck = 400

	if(distance > toCheck) then return end

	local ang = LocalPlayer():EyeAngles()

	local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
	local pos = ply:GetBonePosition(bone)
	pos = pos + Vector(0, 0, 20)

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local alpha = math.Clamp(math.Remap(distance, toCheck/4, toCheck, 255, 0), 0, 255)

	cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.05)
		draw.DrawText(ply:Nick(), "NameDisplay", 0, 0, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	cam.End3D2D()
end


/*---------------------------------------------------------------------------
	Hook which we call the player info and zone drawing drawing from 
---------------------------------------------------------------------------*/
function GM:PostDrawTranslucentRenderables()
	if(self:ZoneActive()) then self:DrawZone() end

	for k, v in pairs(player.GetAll()) do
		self:DrawPlayerInfo(v)
	end
end


/*---------------------------------------------------------------------------
	Draws lookat tooltips
---------------------------------------------------------------------------*/
surface.CreateFont("TooltipKey", {font = "Consolas", size = 32})
surface.CreateFont("TooltipText", {font = "Open Sans", size = 24})

local tooltipOpen = false
local tooltipDist = 85*85
local tooltipAlpha = 0

function GM:DrawTooltip()
	if(!hook.Run("HUDShouldDraw", "Tooltip")) then return end

	tooltipAlpha = Lerp(FrameTime() * 7, tooltipAlpha, tooltipOpen && 200 || 0)

	local ent = LocalPlayer():GetEyeTrace().Entity
	if(!ent.Lootable || !ent.GetTooltip || ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > tooltipDist) then
		if(tooltipOpen) then tooltipOpen = false end
		return
	end

	local tt = ent:GetTooltip()
	local tbl = weapons.GetStored(tt)
	if(tbl && tbl.PrintName) then tt = tbl.PrintName end

	tooltipOpen = true

	local w, h = 40, 40
	local x, y = ScrW()/2 + w*1.5, ScrH()/2-h/2

	surface.SetDrawColor(0, 0, 0, tooltipAlpha)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(255, 255, 255, tooltipAlpha)
	surface.DrawOutlinedRect(x, y, w, h)

	draw.SimpleText(UBR.ResolveString("tooltip_key"), "TooltipKey", x+w/2, y+h/2, Color(255, 255, 255, tooltipAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	surface.SetFont("TooltipText")
	local tw, th = surface.GetTextSize(tt)
	tw, th = tw + 12, th + 6

	local x, y = x+w, y+h/2-th/2

	surface.SetDrawColor(0, 0, 0, tooltipAlpha)
	surface.DrawRect(x, y, tw, th)

	draw.SimpleText(tt, "TooltipText", x+tw/2, y+th/2, Color(255, 255, 255, tooltipAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


/*---------------------------------------------------------------------------
	Draws information on how to jump out of the plane
---------------------------------------------------------------------------*/
function GM:DrawPlaneHint()
	if(!hook.Run("HUDShouldDraw", "PlaneHint")) then return end

	if(LocalPlayer():GetNWBool("InPlane")) then 
		local cin = (math.sin(CurTime() * 3) + 1) / 2
		local clr = Color(255, 255 - (cin * 90), 0)

		draw.SimpleText(UBR.ResolveString("jump_from_plane"), "Parachute", ScrW()/2, ScrH()-ScrH()/3, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


/*---------------------------------------------------------------------------
	Disables the center text when you look at a player
---------------------------------------------------------------------------*/
function GM:HUDDrawTargetID() end


/*---------------------------------------------------------------------------
	Ammo Display
---------------------------------------------------------------------------*/
surface.CreateFont("AmmoMag", {font = "Consolas", size = ScreenScale(10)})
surface.CreateFont("AmmoReserve", {font = "Consolas", size = ScreenScale(7)})

function GM:DrawAmmo()
	if(!hook.Run("HUDShouldDraw", "MainHUD")) then return end

	local wep = LocalPlayer():GetActiveWeapon()
	if(!IsValid(wep)) then return end
	if(!wep:Clip1()) then return end
	if(wep:Clip1() < 0) then return end

	local mag = wep:Clip1()
	surface.SetFont("AmmoMag")
	local mw, mh = surface.GetTextSize(mag)

	local reserve = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
	surface.SetFont("AmmoReserve")
	local rw, rh = surface.GetTextSize(reserve)

	local x, y = ScrW()/2, ScrH() - ScrH()/8

	draw.SimpleText(mag, "AmmoMag", x-rw/2, y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(reserve, "AmmoReserve", x+mw/2, y, Color(255, 255, 255, 40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


/*---------------------------------------------------------------------------
	Draws the HUD
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	self.BaseClass.HUDPaint(self)

	if(LocalPlayer():IsSpectator() && self:RoundInProgress()) then
		self:SpectatorHUD()
	end

	self:DrawRoundState()
	self:DrawStats()
	
	self:DrawKillNotif()

	if(!self:RoundInProgress()) then return end

	self:DrawParachuteHUD()
	self:DrawVehicleHUD()

	self:DrawPlaneHint()

	self:DrawAmmo()
	self:DrawMainHUD()
	self:DrawPlayerCount()
	self:DrawKillCount()

	self:DrawTooltip()
end