/*---------------------------------------------------------------------------
	Functionality
---------------------------------------------------------------------------*/
local parachuteColor = Color(255, 255, 255)

function UBR.SetParachuteColor(clr)
	clr = clr || Color(255, 255, 255)

	net.Start("ParachuteColor")
		net.WriteTable(clr)
	net.SendToServer()
end

function UBR.GetParachuteColor()
	return parachuteColor
end

function UBR.UpdateParachuteColor(clr)
	parachuteColor = clr
end

net.Receive("ParachuteColor", function()
	local t = net.ReadTable()
	UBR.UpdateParachuteColor(Color(t.r, t.g, t.b))
end)


/*---------------------------------------------------------------------------
	Panel meta functions
---------------------------------------------------------------------------*/
local blur = Material("pp/blurscreen")
local function drawBlur(pnl, amount)
	local x, y = pnl:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 8))
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

local function drawCircle(x, y, r)
	local circle = {}

	for i = 1, 360 do
		circle[i] = {}
		circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end

	surface.DrawPoly(circle)
end

local panelMeta = FindMetaTable("Panel")

function panelMeta:EnableClickyEffect(click, speed, alpha)
	click = click || self
	speed = speed || 4
	alpha = alpha || 80

	self.rad = 0
	self.clickAlpha = alpha
	local oldPaint = self.PaintOver || function() end
	self.PaintOver = function(s, w, h)
		oldPaint(s, w, h)

		if(s.clickX && s.clickY && s.rad && s.clickAlpha != 0) then
			surface.SetDrawColor(255, 255, 255, s.clickAlpha)
			draw.NoTexture()
			drawCircle(s.clickX, s.clickY, s.rad)
			s.rad = Lerp(FrameTime() * speed, s.rad, w)
			s.clickAlpha = Lerp(FrameTime() * speed, s.clickAlpha, 0)
		end
	end

	local oldClick = click.DoClick

	click.DoClick = function(s)
		oldClick(s)

		self.clickX, self.clickY = self:CursorPos()
		self.rad = 0
		self.clickAlpha = alpha
	end
end

function panelMeta:EnableHoverEffect(hover, speed, alpha, clr)
	hover = hover || self
	speed = speed || 4
	alpha = alpha || 30
	clr = clr || Color(255, 255, 255, 255)

	self.alpha = 0
	local oldPaint = self.PaintOver || function() end
	self.PaintOver = function(s, w, h)
		oldPaint(s, w, h)

		if(hover:IsHovered()) then
			s.alpha = Lerp(FrameTime() * speed, s.alpha, alpha)
		else
			s.alpha = Lerp(FrameTime() * speed, s.alpha, 0)
		end

		if(s.alpha > 0) then
			surface.SetDrawColor(ColorAlpha(clr, s.alpha))
			surface.DrawRect(0, 0, w, h)
		end
	end
end


/*---------------------------------------------------------------------------
	Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("ParachuteSubmit", {font = "Roboto Light", size = 24, weight = 100})


/*---------------------------------------------------------------------------
	Custom panel for the parachute color selection
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	local w = ScrW()/1.6
	local h = w / 2.5

	self:SetSize(w, h)
	self:Center()
	self:MakePopup()

	self:SetKeyboardInputEnabled()

	self:SetTitle(UBR.ResolveString("parachute_color"))


	/*---------------------------------------------------------------------------
		Active parachute
	---------------------------------------------------------------------------*/
	self.Active = vgui.Create("DModelPanel", self)
	self.Active:Dock(LEFT)
	self.Active:SetWide(self:GetWide()/3)
	self.Active:SetColor(UBR.GetParachuteColor())
	self.Active:SetModel("models/freeman/parachute_open.mdl")
	self.Active:SetAmbientLight(Color(255, 255, 255, 255))
	self.Active.LayoutEntity = function() end

	local mn, mx = self.Active.Entity:GetRenderBounds()
	local size = 0
	size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
	size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
	size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

	self.Active:SetFOV(45)
	self.Active:SetCamPos(Vector(size, size, size))
	self.Active:SetLookAt((mn + mx) * 0.5)


	/*---------------------------------------------------------------------------
		Landed parachute
	---------------------------------------------------------------------------*/
	self.Landed = vgui.Create("DModelPanel", self)
	self.Landed:Dock(RIGHT)
	self.Landed:SetWide(self:GetWide()/3)
	self.Landed:SetColor(UBR.GetParachuteColor())
	self.Landed:SetModel("models/freeman/parachute_ground.mdl")
	self.Landed:SetAmbientLight(Color(255, 255, 255, 255))
	self.Landed.LayoutEntity = function() end

	local mn, mx = self.Landed.Entity:GetRenderBounds()
	local size = 0
	size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
	size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
	size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

	self.Landed:SetFOV(45)
	self.Landed:SetCamPos(Vector(size, size, size))
	self.Landed:SetLookAt((mn + mx) * 0.5)


	/*---------------------------------------------------------------------------
	Color mixer
	---------------------------------------------------------------------------*/
	self.Mixer = vgui.Create("DColorMixer", self)
	self.Mixer:Dock(FILL)
	self.Mixer:SetAlphaBar(false)
	self.Mixer:SetColor(UBR.GetParachuteColor())
	self.Mixer.ValueChanged = function(s, val)
		self.Active:SetColor(val)
		self.Landed:SetColor(val)
	end

	self.Submit = vgui.Create("DButton", self)
	self.Submit:Dock(BOTTOM)
	self.Submit:DockMargin(0,15,0,0)
	self.Submit:SetTall(32)
	self.Submit:SetTextColor(Color(0, 0, 0, 255))
	self.Submit:SetFont("ParachuteSubmit")
	self.Submit:SetText(UBR.ResolveString("submit"))
	self.Submit.Paint = function(s, w, h)
		surface.SetDrawColor(ColorAlpha(self.Mixer:GetColor(), 80))
		surface.DrawRect(0, 0, w, h)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	self.Submit.DoClick = function()
		UBR.SetParachuteColor(self.Mixer:GetColor())
	end

	self.Submit:EnableHoverEffect()
	self.Submit:EnableClickyEffect()
end

function PANEL:Paint(w, h)
	drawBlur(self)
	surface.SetDrawColor(255, 255, 255, 30)
	surface.DrawRect(0, 0, w, h)
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("ParachuteColorSelection", PANEL, "DFrame")


/*---------------------------------------------------------------------------
	Functionality to open the menu
---------------------------------------------------------------------------*/
local function createFrame()
	vgui.Create("ParachuteColorSelection")
	surface.PlaySound("ui/buttonclick.wav")
end

concommand.Add("parachutecolor", createFrame)
net.Receive("OpenParachuteColorMenu", createFrame)