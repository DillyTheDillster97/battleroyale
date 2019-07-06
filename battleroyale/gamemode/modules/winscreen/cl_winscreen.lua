/*---------------------------------------------------------------------------
	Draws a blur on a panel
---------------------------------------------------------------------------*/
local blur = Material("pp/blurscreen")
local function drawBlur(pnl, amount)
	local x, y = pnl:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("", (i / 3) * (amount or 8))
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end


/*---------------------------------------------------------------------------
	Creates fonts for our winscreen
---------------------------------------------------------------------------*/
surface.CreateFont("WSHeading", {font = "Titillium Web", size = ScreenScale(26)})
surface.CreateFont("WSFont", {font = "Roboto Thin", size = ScreenScale(15), weight = 100})


/*---------------------------------------------------------------------------
	The custom panel containing the winscreen
---------------------------------------------------------------------------*/
local PANEL = {}

AccessorFunc(PANEL, "winner", "Winner")

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:Hide()
end

function PANEL:Hide()
	self:SetVisible(false)
end

function PANEL:Show()
	self:SetVisible(true)

	self.Smooth = 0
	self.anim = Derma_Anim("WinscreenOpen", self, function(pnl)
		self.Smooth = Lerp(5 * FrameTime(), self.Smooth, ScrH())
		pnl:SetTall(math.ceil(self.Smooth))
		pnl:Center()
	end)
	self.anim:Start(2)
end

function PANEL:Think()
	if(self.anim:Active()) then self.anim:Run() end
end

function PANEL:Paint(w, h)
	drawBlur(self, 6)
	
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, w, h)

	surface.SetFont("WSFont")
	local tw, th = surface.GetTextSize(self:GetWinner())

	local x = ScreenScale(15)
	local y = x

	draw.SimpleText(self:GetWinner(), "WSHeading", x, y, Color(255, 255, 255, 255))
	draw.SimpleText(UBR.ResolveString("win"), "WSFont", x, y + th*1.5, Color(243, 200, 1))
end

vgui.Register("Winscreen", PANEL, "Panel")


/*---------------------------------------------------------------------------
	Hooking the winscreen up to our pooled net messages
---------------------------------------------------------------------------*/
net.Receive("ShowWinscreen", function()
	local ws = vgui.Create("Winscreen")
	ws:SetWinner(net.ReadString() || LocalPlayer():Name())
	ws:Show()

	timer.Simple(UBR.Config.RoundCooldown/2, function()
		if(IsValid(ws)) then ws:Remove() end
	end)
end)