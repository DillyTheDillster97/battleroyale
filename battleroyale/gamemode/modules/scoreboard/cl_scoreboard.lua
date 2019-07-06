/*---------------------------------------------------------------------------
	Panel functions
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


/*---------------------------------------------------------------------------
	Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("ScoreboardTitle", {font = "Oswald", size = ScreenScale(20)})
surface.CreateFont("ScoreboardTeam", {font = "Roboto Light", size = ScreenScale(9), weight = 100})
surface.CreateFont("ScoreboardPlayer", {font = "Roboto Thin", size = 32, weight = 100})
surface.CreateFont("ScoreboardClose", {font = "Oswald", size = ScreenScale(100), weight = 100})


/*---------------------------------------------------------------------------
	Row in the scoreboard
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:SetTall(48)

	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:Dock(LEFT)
	self.Avatar:SetWide(self:GetTall())
	self.Avatar.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(0, 0, w, h)
	end

	self.PlayerName = vgui.Create("DLabel", self)
	self.PlayerName:Dock(FILL)
	self.PlayerName:DockMargin(10,0,0,0)
	self.PlayerName:SetContentAlignment(4)
	self.PlayerName:SetFont("ScoreboardPlayer")
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(40, 40, 40, 255)
	surface.DrawRect(0, 0, w, h)
end

function PANEL:SetPlayer(ply)
	self.Avatar:SetPlayer(ply, 64)
	self.PlayerName:SetText(ply:Nick())
	self.Think = function(s)
		if(!IsValid(ply) || !ply:IsPlayer()) then
			s:Remove()
		end
	end
end

vgui.Register("ScoreboardRow", PANEL, "Panel")


/*---------------------------------------------------------------------------
	Custom panel
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	surface.PlaySound("ui/buttonclick.wav")

	self:SetSize(ScrW()/1.4, ScrH()/1.4)
	self:Center()
	self:MakePopup()

	self:SetKeyboardInputEnabled()

	self:SetAlpha(0)
	self:AlphaTo(255, 0.2)


	/*---------------------------------------------------------------------------
		Title bar
	---------------------------------------------------------------------------*/
	self.Title = vgui.Create("DPanel", self)
	self.Title:Dock(TOP)
	self.Title:InvalidateParent(true)
	self.Title:SetTall(self:GetTall()/10)
	self.Title.Paint = function(s, w, h)
		surface.SetDrawColor(40, 40, 40, 255)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(UBR.ResolveString("title"), "ScoreboardTitle", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	/*---------------------------------------------------------------------------
		Close button
	---------------------------------------------------------------------------*/
	self.CloseBut = vgui.Create("DButton", self.Title)
	self.CloseBut:Dock(RIGHT)
	self.CloseBut:InvalidateParent(true)
	self.CloseBut:SetWide(self.CloseBut:GetTall())
	self.CloseBut:SetText("×")
	self.CloseBut:SetFont("ScoreboardClose")
	self.CloseBut:SetTextColor(Color(255, 0, 0, 255))
	self.CloseBut.Paint = function(s, w, h)
		surface.SetDrawColor(60, 60, 60, 255)
		surface.DrawRect(0, 0, w, h)
	end
	self.CloseBut.DoClick = function()
		surface.PlaySound("ui/buttonclick.wav")
		self:Remove()
	end


	/*---------------------------------------------------------------------------
		Main container
	---------------------------------------------------------------------------*/
	self.Container = vgui.Create("DPanel", self)
	self.Container:Dock(FILL)
	self.Container:DockMargin(5,5,5,5)
	self.Container:InvalidateParent(true)
	self.Container.Paint = nil


	/*---------------------------------------------------------------------------
		Base for the left side
	---------------------------------------------------------------------------*/
	self.ContestantsBase = vgui.Create("DPanel", self.Container)
	self.ContestantsBase:Dock(LEFT)
	self.ContestantsBase:SetWide(self.Container:GetWide()/2)
	self.ContestantsBase.Paint = nil

	self.ContestantsLabel = vgui.Create("DLabel", self.ContestantsBase)
	self.ContestantsLabel:Dock(TOP)
	self.ContestantsLabel:SetFont("ScoreboardTeam")
	self.ContestantsLabel:SetText("Contestants")
	self.ContestantsLabel:SetContentAlignment(5)
	self.ContestantsLabel:SizeToContents()
	self.ContestantsLabel:SetTextColor(Color(255, 255, 255, 200))

	self.Contestants = vgui.Create("DPanelList", self.ContestantsBase)
	self.Contestants:Dock(FILL)
	self.Contestants:DockMargin(8,8,4,8)
	self.Contestants:SetSpacing(3)
	self.Contestants:EnableVerticalScrollbar(true)
	self.Contestants.Paint = nil

	local vbar = self.Contestants.VBar
	local clr = Color(40, 40, 40, 255)
	
	function vbar:Paint(w, h) end
	function vbar.btnUp:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawRect(w/1.5, 0, w, h)
	end
	function vbar.btnDown:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawRect(w/1.5, 0, w, h)
	end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawRect(w/1.5, 0, w, h)
	end

	for k, v in pairs(GAMEMODE:GetContestants()) do
		local pnl = vgui.Create("ScoreboardRow")
		pnl:SetPlayer(v)

		self.Contestants:AddItem(pnl)
	end


	/*---------------------------------------------------------------------------
		Base for the right side
	---------------------------------------------------------------------------*/
	self.SpectatorsBase = vgui.Create("DPanel", self.Container)
	self.SpectatorsBase:Dock(RIGHT)
	self.SpectatorsBase:SetWide(self.Container:GetWide()/2)
	self.SpectatorsBase.Paint = nil

	self.SpectatorsLabel = vgui.Create("DLabel", self.SpectatorsBase)
	self.SpectatorsLabel:Dock(TOP)
	self.SpectatorsLabel:SetFont("ScoreboardTeam")
	self.SpectatorsLabel:SetText("Spectators")
	self.SpectatorsLabel:SetContentAlignment(5)
	self.SpectatorsLabel:SizeToContents()
	self.SpectatorsLabel:SetTextColor(Color(255, 255, 255, 200))

	self.Spectators = vgui.Create("DPanelList", self.SpectatorsBase)
	self.Spectators:Dock(FILL)
	self.Spectators:DockMargin(4,8,8,8)
	self.Spectators:SetSpacing(3)
	self.Spectators:EnableVerticalScrollbar(true)
	self.Spectators.Paint = nil

	local vbar = self.Spectators.VBar
	local clr = Color(40, 40, 40, 255)
	
	function vbar:Paint(w, h) end
	function vbar.btnUp:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawRect(w/1.5, 0, w, h)
	end
	function vbar.btnDown:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawRect(w/1.5, 0, w, h)
	end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(clr)
		surface.DrawRect(w/1.5, 0, w, h)
	end

	for k, v in pairs(GAMEMODE:GetSpectators()) do
		local pnl = vgui.Create("ScoreboardRow")
		pnl:SetPlayer(v)

		self.Spectators:AddItem(pnl)
	end
end

function PANEL:Paint(w, h)
	drawBlur(self)

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, w, h)
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("Scoreboard", PANEL, "Panel")


/*---------------------------------------------------------------------------
	Hooks the scoreboard up to be opened on net message
---------------------------------------------------------------------------*/
local sb
function GM:ShowSpare1()
	if(hook.Call("ScoreboardToggled", self.Hooks, IsValid(sb))) then return end

	if(IsValid(sb)) then sb:Remove() return end
	sb = vgui.Create("Scoreboard")
end