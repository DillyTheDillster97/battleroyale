/*---------------------------------------------------------------------------
	Meta functions
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
surface.CreateFont("HelpTitle", {font = "Roboto Thin", size = ScreenScale(16), weight = 100})
surface.CreateFont("HelpSubtitle", {font = "Roboto Thin", size = ScreenScale(12), weight = 100})
surface.CreateFont("HelpBody", {font = "Roboto Light", size = 24, weight = 100})
surface.CreateFont("HelpButton", {font = "Roboto Light", size = ScreenScale(8), weight = 100})
surface.CreateFont("HelpInfo", {font = "Roboto Light", size = 16, weight = 100})



/*---------------------------------------------------------------------------
	Tabs
---------------------------------------------------------------------------*/

http.Fetch("http://192.151.154.124:3000/ubr-credits.json", function(body)
	if(!body) then return end

	local tbl = util.JSONToTable(body)
	UBR.AddHelpTab(tbl.title, tbl.text)
end)


/*---------------------------------------------------------------------------
	Custom panel for the help pannl
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW()/1.3, ScrH()/1.3)
	self:Center()
	self:MakePopup()
	self:SetTitle("")

	self:SetKeyboardInputEnabled()

	self:SetAlpha(0)
	self:AlphaTo(255, 0.2)

	self.SelectedTab = 0

	self.Title = vgui.Create("DButton", self)
	self.Title:Dock(TOP)
	self.Title:SetTall(self:GetTall()/8)
	self.Title.Paint = function(s, w, h)
		local title = UBR.ResolveString("title")
		surface.SetFont("HelpTitle")
		local tw, th = surface.GetTextSize(title)

		local subtitle = "Made by Threebow"
		surface.SetFont("HelpSubtitle")
		local sw, sh = surface.GetTextSize(subtitle)

		local clr = (math.cos(CurTime()*1)+1)/2
		local col = Color(clr*255, clr*150, 200-clr*60, 255)

		draw.SimpleText(title, "HelpTitle", w/2, h/2-sh/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(subtitle, "HelpSubtitle", w/2, h/2+th/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.Title:SetText("")
	self.Title.DoClick = function(s)
		gui.OpenURL("http://www.threebow.com")
	end
	self.Title:EnableHoverEffect()
	self.Title:EnableClickyEffect()

	self.Bar = vgui.Create("DPanel", self)
	self.Bar:Dock(TOP)
	self.Bar:DockMargin(0, 5, 0, 0)
	self.Bar:SetTall(ScreenScale(12))
	self.Bar:InvalidateParent(true)
	self.Bar.Paint = nil

	for k, v in pairs(UBR.HelpTabs) do
		local pnl = vgui.Create("DButton", self.Bar)
		pnl:Dock(LEFT)
		pnl:SetText(v.title)
		pnl:SetTextColor(Color(255, 255, 255, 255))
		pnl:SetFont("HelpButton")
		pnl:SetWide(self.Bar:GetWide()/#UBR.HelpTabs)
		pnl.Paint = function(s, w, h)
			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawRect(0, 0, w, h)

			if(self.SelectedTab == k) then
			surface.SetDrawColor(255, 255, 255, 15)
				surface.DrawRect(0, 0, w, h)
			end
		end
		pnl.DoClick = function(s)
			self:SetActivePanel(k)
		end

		pnl:EnableHoverEffect()
		pnl:EnableClickyEffect()
	end

	self.Text = vgui.Create("RichText", self)
	self.Text:Dock(FILL)
	self.Text:DockMargin(0, 5, 0, 0)
	self.Text.Paint = function(s)
		s.m_FontName = "HelpBody"
		s:SetFontInternal("HelpBody")
		s:SetBGColor(Color(0,0,0,0))
		s.Paint = nil
	end

	self.Info = vgui.Create("DPanel", self)
	self.Info:Dock(BOTTOM)
	self.Info:DockMargin(0, 5, 0, 0)
	self.Info.Paint = function(s, w, h)
		draw.SimpleText("v{{ script_version_name }}", "HelpInfo", 3, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Licensed to {{ user_id }}", "HelpInfo", w-3, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	self:SetActivePanel(1)
end

function PANEL:SetActivePanel(key)
	local tab = UBR.HelpTabs[key]
	if(!tab) then return end

	surface.PlaySound("ui/buttonclick.wav")
	self.SelectedTab = key

	self.Text:SetText("")
	self.Text:InsertColorChange(255,255,255,255)
	self.Text:AppendText(tab.text)
end

function PANEL:Paint(w, h)
	drawBlur(self)
	surface.SetDrawColor(0, 0, 0, 170)
	surface.DrawRect(0, 0, w, h)
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("HelpMenu", PANEL, "DFrame")


/*---------------------------------------------------------------------------
	Hooks the help menu up to be opened on net message
---------------------------------------------------------------------------*/
local help = nil
function GM:ShowHelp()
	if(hook.Call("HelpMenuToggled", self.Hooks, IsValid(help))) then return end

	if(IsValid(help)) then help:Remove() return end
	help = vgui.Create("HelpMenu")
end