/*---------------------------------------------------------------------------
	Colors
---------------------------------------------------------------------------*/
local txtColor = Color(255, 255, 255, 255)
local killColor = Color(206, 62, 56, 255)
local remainingColor = Color(245, 244, 163, 255)


/*---------------------------------------------------------------------------
	Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("KillNotifText", {font = "Titillium Web", size = 40, weight = 100})
surface.CreateFont("KillNotifCount", {font = "Titillium Web", size = 50})


/*---------------------------------------------------------------------------
	Variables
---------------------------------------------------------------------------*/
local ply = ""
local wep = nil
local show = false


/*---------------------------------------------------------------------------
	Function to draw the kill popup
---------------------------------------------------------------------------*/
local dist = 6

local alpha = 0
local multi = 4
function GM:DrawKillNotif()
	if(!ply) then return end
	alpha = Lerp(FrameTime()*multi, alpha, show && 255 || 0)
	if(alpha <= 0 && wep) then wep = nil return end

	if(!hook.Run("HUDShouldDraw", "KillNotification")) then return end

	local x, y = ScrW()/2, ScrH()/1.5

	local killText = "You killed "..ply
	if(wep) then
		killText = "You killed "..ply.." with a "..wep
	end
	surface.SetFont("KillNotifText")
	local tw, th = surface.GetTextSize(killText)

 	local alive = self:GetContestantCount()

	local aliveText = alive > 0 && (" - "..alive.." left") || ""
	local aw, ah = surface.GetTextSize(aliveText)

	draw.SimpleText(killText, "KillNotifText", x-aw/2, y+dist, ColorAlpha(txtColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(aliveText, "KillNotifText", x+tw/2, y+dist, ColorAlpha(remainingColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

	local kc = LocalPlayer():GetKills()

	draw.SimpleText(kc.." "..UBR.ResolveString(kc == 1 && "kill" || "kills"), "KillNotifCount", x, y-dist, ColorAlpha(killColor, alpha), TEXT_ALIGN_CENTER)
end


/*---------------------------------------------------------------------------
	Hooking it up via net message
---------------------------------------------------------------------------*/
net.Receive("KillNotif", function()
	ply = net.ReadString()

	local aWep = LocalPlayer():GetActiveWeapon()
	if(IsValid(aWep)) then wep = aWep:GetPrintName() end

	show = true
	multi = 8
	timer.Simple(UBR.Config.KillNotifTime, function()
		show = false
		multi = 4
	end)
end)