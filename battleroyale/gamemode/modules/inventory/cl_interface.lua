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

function panelMeta:InventoryItemHover(hover, speed, clr)
	hover = hover || self
	speed = speed || 8
	clr = clr || Color(255, 255, 255, 30)

	self.w = 0
	local oldPaint = self.PaintOver || function() end
	self.PaintOver = function(s, w, h)
		oldPaint(s, w, h)

		if(hover:IsHovered()) then
			s.w = Lerp(FrameTime() * speed, s.w, w)
		else
			s.w = Lerp(FrameTime() * speed, s.w, 0)
		end

		if(hover:IsHovered()) then
			surface.SetDrawColor(clr)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, h, h)
			draw.SimpleText(hover.HoverText, "InventoryItemPickup", h/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		surface.SetDrawColor(255, 255, 255, 50)
		surface.DrawRect(w/2-s.w/2, h-2, s.w, 2)
	end
end

function panelMeta:EnableDroppableHover(speed, ...)
	speed = speed || 10
	local droppables = {...}

	self.Alpha = 0

	local oldPaint = self.PaintOver || function() end
	self.PaintOver = function(s, w, h)
		oldPaint(s, w, h)

		local amt = 0
		for _, v in pairs(droppables) do
			amt = amt + #(dragndrop.GetDroppable(v) || {})
		end

		local dragging = amt > 0

		s.Alpha = Lerp(FrameTime()*speed, s.Alpha, dragging && 15 || 0)
		if(s.Alpha < 1) then return end

		surface.SetDrawColor(255, 255, 255, s.Alpha)
		surface.DrawRect(0, 0, w, h)
	end
end

/*---------------------------------------------------------------------------
	Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("InventoryName", {font = "Oswald", size = ScreenScale(15)})
surface.CreateFont("InventoryColumn", {font = "Oswald Light", size = ScreenScale(10), weight = 100})
surface.CreateFont("InventoryItemPrimary", {font = "Oswald Light", size = ScreenScale(9), weight = 100})
surface.CreateFont("InventoryItemSecondary", {font = "Consolas", size = ScreenScale(6)})

surface.CreateFont("InventoryWeaponName", {font = "Titillium Web", size = ScreenScale(11), weight = 300})
surface.CreateFont("InventoryWeaponMag", {font = "Consolas", size = ScreenScale(10)})
surface.CreateFont("InventoryWeaponReserve", {font = "Consolas", size = ScreenScale(7)})
surface.CreateFont("InventoryWeaponAmmoName", {font = "Titillium Web", size = ScreenScale(7), weight = 100})

surface.CreateFont("InventoryItemPickup", {font = "Oswald", size = ScreenScale(7), weight = 100})


/*---------------------------------------------------------------------------
	Functions to interact with the inventory
---------------------------------------------------------------------------*/
local function dropWeapon(pnl)
	if(!IsValid(pnl)) then return end

	net.Start("DropWeapon")
		net.WriteString(pnl.Weapon:GetClass())
	net.SendToServer()
end

local function dropAmmo(pnl)
	if(!IsValid(pnl)) then return end
	if(!pnl.AmmoType || !pnl.Amount) then return end


	net.Start("DropAmmo")
		net.WriteString(pnl.AmmoType)
		net.WriteInt(pnl.Amount, 15)
	net.SendToServer()
end

local function dropItem(pnl)
	if(!IsValid(pnl)) then return end

	net.Start("DropItem")
		net.WriteInt(pnl.Item, 10)
	net.SendToServer()
end

local function pickupVicinity(pnl)
	if(!IsValid(pnl) || !IsValid(pnl.Item)) then return end

	net.Start("PickupVicinity")
		net.WriteEntity(pnl.Item)
	net.SendToServer()
end


/*---------------------------------------------------------------------------
	Custom panel for an inventory item
---------------------------------------------------------------------------*/
local PANEL = {}

local o = ScreenScale(3)
function PANEL:Init()
	self.ModelCont = vgui.Create("DPanel", self)
	self.ModelCont:Dock(LEFT)
	self.ModelCont:InvalidateParent(true)
	self.ModelCont:SetWide(self.ModelCont:GetTall())
	self.ModelCont.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 5)
		surface.DrawRect(0, 0, w, h)
	end

	self.Model = vgui.Create("DModelPanel", self.ModelCont)
	self.Model:Dock(FILL)
	self.Model:DockMargin(2, 2, 2, 2)
	self.Model:SetAmbientLight(Color(255, 255, 255, 255))
	self.Model:SetFOV(45)
	self.Model.LayoutEntity = function() end

	self.Text = vgui.Create("DButton", self)
	self.Text:Dock(FILL)
	self.Text:SetText("")
	self.Text:DockMargin(o, 0, 0, 0)
	self.Text.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(0, 0, w, h)
	end

	self.DeleteTime = CurTime() + 0.3
end

function PANEL:SetItem(key, item)
	self.Model:SetModel(item.model)

	local mn, mx = self.Model.Entity:GetRenderBounds()
	local size = 0
	size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
	size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
	size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

	self.Model:SetCamPos(Vector(size, size, size))
	self.Model:SetLookAt((mn + mx) * 0.5)

	if(item.isAmmo) then
		self.Text:Droppable("DropAmmo")

		self.Text.AmmoType = item.name
		self.Text.Amount = LocalPlayer():GetAmmoCount(item.name)
		self.Text.Think = function(s)
			if(CurTime() < self.DeleteTime) then return end
			s.Amount = LocalPlayer():GetAmmoCount(item.name)
			if(s.Amount <= 0) then self:Remove() end
		end
	else
		self.Text.Item = key
		self.Text:Droppable("DropItem")
		self.Text.Think = function()
			if(!LocalPlayer():InventoryContains(key)) then self:Remove() end
		end
	end

	self.Text.Paint = function(s, w, h)
		draw.SimpleText(item.name,"InventoryItemPrimary", 0, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		if(item.isAmmo) then
			draw.SimpleText(LocalPlayer():GetAmmoCount(item.name),"InventoryItemSecondary", w-o, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end

	self.Text.DoRightClick = function(s)
		if(item.isAmmo) then
			dropAmmo(s)
		else
			net.Start("UseItem")
				net.WriteInt(key, 10)
			net.SendToServer()
		end
	end

	self.Text.HoverText = UBR.ResolveString((item.isAmmo && "drop" || "use").."_item")
	self:EnableClickyEffect(self.Text)
	self:InventoryItemHover(self.Text)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 5)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("InventoryItem", PANEL, "Panel")


/*---------------------------------------------------------------------------
	Custom panel for an item in the vicinity
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self.ModelCont = vgui.Create("DPanel", self)
	self.ModelCont:Dock(LEFT)
	self.ModelCont:InvalidateParent(true)
	self.ModelCont:SetWide(self.ModelCont:GetTall())
	self.ModelCont.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 5)
		surface.DrawRect(0, 0, w, h)
	end

	self.Model = vgui.Create("DModelPanel", self.ModelCont)
	self.Model:Dock(FILL)
	self.Model:DockMargin(2, 2, 2, 2)
	self.Model:SetAmbientLight(Color(255, 255, 255, 255))
	self.Model:SetFOV(45)
	self.Model.LayoutEntity = function() end

	self.Text = vgui.Create("DButton", self)
	self.Text:Dock(FILL)
	self.Text:SetText("")
	self.Text:DockMargin(o, 0, 0, 0)
	self.Text.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(0, 0, w, h)
	end
end

function PANEL:SetItem(item)
	self.Think = function(s) if(!IsValid(item)) then s:Remove() end end

	self.DisplayName = item:GetTooltip()
	if(item:GetClass() == "weapon_pickup") then
		local tbl = weapons.GetStored(self.DisplayName)
		if(tbl && tbl.PrintName) then self.DisplayName = tbl.PrintName end
	end

	self.Model:SetModel(item:GetModel())
	self.Text:Droppable("PickupVicinity"..(item:GetClass() == "weapon_pickup" && "Weapon" || "Item"))

	local mn, mx = self.Model.Entity:GetRenderBounds()
	local size = 0
	size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
	size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
	size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

	self.Model:SetCamPos(Vector(size, size, size))
	self.Model:SetLookAt((mn + mx) * 0.5)

	self.Text.Paint = function(s, w, h)
		if(!IsValid(item)) then self:Remove() return end
		draw.SimpleText(self.DisplayName, "InventoryItemPrimary", 0, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	self.Text.Item = item
	self.Text.DoRightClick = function(s)
		pickupVicinity(s)
	end

	self.Text.HoverText = UBR.ResolveString("pickup_item")
	self:EnableClickyEffect(self.Text)
	self:InventoryItemHover(self.Text)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 5)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("VicinityItem", PANEL, "Panel")


/*---------------------------------------------------------------------------
	Custom panel for the inventory
---------------------------------------------------------------------------*/
local frame

local PANEL = {}

local gradMat = Material("vgui/gradient_down")

local weight = 0
function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:MakePopup()

	self:SetKeyboardInputEnabled()

	self:SetAlpha(0)
	self:AlphaTo(255, 0.3)

	self.VicinityItems = {}


	/*---------------------------------------------------------------------------
		The player's name
	---------------------------------------------------------------------------*/
	self.Name = vgui.Create("DLabel", self)
	self.Name:SetText(LocalPlayer():Nick())
	self.Name:SetFont("InventoryName")
	self.Name:SetContentAlignment(5)
	self.Name:SizeToContents()
	self.Name:Dock(TOP)
	self.Name:DockMargin(0, ScreenScale(15), 0, 0)


	/*---------------------------------------------------------------------------
		Container for everything in the menu
	---------------------------------------------------------------------------*/
	local cm = ScreenScale(30)
	self.Container = vgui.Create("DPanel", self)
	self.Container:Dock(FILL)
	self.Container:DockMargin(cm, cm, cm, cm)
	self.Container:InvalidateParent(true)
	self.Container.Paint = nil


	/*---------------------------------------------------------------------------
		Playermodel in the center
	---------------------------------------------------------------------------*/
	self.Model = vgui.Create("DModelPanel", self.Container)
	self.Model:Dock(FILL)
	self.Model:SetWide(self.Container:GetWide()/3)
	self.Model:SetModel(LocalPlayer():GetModel())
	self.Model:SetAmbientLight(Color(255, 255, 255, 255))
	self.Model:SetCamPos(self.Model:GetLookAt() + Vector(50, 0, 0))
	self.Model.Entity:SetEyeTarget(self.Model:GetCamPos())
	self.Model.Angles = Angle(0, 0, 0)

	self.Model.PaintOver = function(s, w, h)
		local bw, bh = 10, h/5
		local x, y = bw, h/2-bh/2

		weight = Lerp(FrameTime()*10, weight, LocalPlayer():GetInventoryWeight() || 0)
		local progress = math.Round(weight/LocalPlayer():GetInventoryCapacity()*bh)

		surface.SetDrawColor(85, 85, 85, 150)
		surface.DrawRect(x, y, bw, bh)

		surface.SetDrawColor(255, 255, 255, 10)
		surface.DrawOutlinedRect(x, y, bw, bh)

		surface.SetMaterial(gradMat)
		surface.SetDrawColor(200, 200, 200, 150)
		surface.DrawTexturedRect(x, y+bh-progress, bw, progress)
	end

	function self.Model:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function self.Model:DragMouseRelease() self.Pressed = false end

    function self.Model:LayoutEntity(ent)
        if(self.bAnimated) then self:RunAnimation() end

        if(self.Pressed) then
            local mx, my = gui.MousePos()
            self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)

            self.PressX, self.PressY = gui.MousePos()
        end

        ent:SetAngles(self.Angles)
    end


    /*---------------------------------------------------------------------------
    	Base for everything on the left
    ---------------------------------------------------------------------------*/
	self.ListBase = vgui.Create("DPanel", self.Container)
	self.ListBase:Dock(LEFT)
	self.ListBase:SetWide(self.Container:GetWide()/3)
	self.ListBase:InvalidateParent(true)
	self.ListBase.Paint = nil


	/*---------------------------------------------------------------------------
		Vicinity
	---------------------------------------------------------------------------*/
	self.VicinityBase = vgui.Create("DPanel", self.ListBase)
	self.VicinityBase.Paint = nil

	self.VicinityTitle = vgui.Create("DLabel", self.VicinityBase)
	self.VicinityTitle:Dock(TOP)
	self.VicinityTitle:SetContentAlignment(4)
	self.VicinityTitle:SetFont("InventoryColumn")
	self.VicinityTitle:SetText(UBR.ResolveString("vicinity"))
	self.VicinityTitle:SetTextColor(Color(200, 200, 200, 200))
	self.VicinityTitle:SizeToContents()

	self.Vicinity = vgui.Create("DPanelList", self.VicinityBase)
	self.Vicinity:Dock(FILL)
	self.Vicinity:EnableVerticalScrollbar()
	self.Vicinity:SetSpacing(3)
	self.Vicinity:EnableDroppableHover(10, "DropAmmo", "DropWeapon", "DropItem")

	self.Vicinity:Receiver("DropWeapon", function(s, tbl, dropped)
		if(dropped) then dropWeapon(tbl[1]) end
	end)
	self.Vicinity:Receiver("DropAmmo", function(s, tbl, dropped)
		if(dropped) then dropAmmo(tbl[1]) end
	end)
	self.Vicinity:Receiver("DropItem", function(s, tbl, dropped)
		if(dropped) then dropItem(tbl[1]) end
	end)

	self:UpdateVicinity()

	local vbar = self.Vicinity.VBar
	local clr = Color(145, 146, 148)
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


	/*---------------------------------------------------------------------------
		Inventory
	---------------------------------------------------------------------------*/
	self.InventoryBase = vgui.Create("DPanel", self.ListBase)
	self.InventoryBase.Paint = nil

	self.InventoryTitle = vgui.Create("DLabel", self.InventoryBase)
	self.InventoryTitle:Dock(TOP)
	self.InventoryTitle:SetContentAlignment(4)
	self.InventoryTitle:SetFont("InventoryColumn")
	self.InventoryTitle:SetText(UBR.ResolveString("inventory"))
	self.InventoryTitle:SetTextColor(Color(200, 200, 200, 200))
	self.InventoryTitle:SizeToContents()

	self.Inventory = vgui.Create("DPanelList", self.InventoryBase)
	self.Inventory:Dock(FILL)
	self.Inventory:EnableVerticalScrollbar()
	self.Inventory:SetSpacing(3)
	self.Inventory:EnableDroppableHover(10, "PickupVicinityItem")

	self.Inventory:Receiver("PickupVicinityItem", function(s, tbl, dropped)
		if(dropped) then pickupVicinity(tbl[1]) end
	end)

	local vbar = self.Inventory.VBar
	local clr = Color(145, 146, 148)
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

	self:PopulateInventory()


	/*---------------------------------------------------------------------------
		Divider between vicinity and inventory
	---------------------------------------------------------------------------*/
	self.Divider = vgui.Create("DHorizontalDivider", self.ListBase)
	self.Divider:Dock(FILL)
	self.Divider:SetLeft(self.VicinityBase)
	self.Divider:SetRight(self.InventoryBase)
	self.Divider:SetDividerWidth(30)
	self.Divider:SetLeftMin(self.ListBase:GetWide()/2-15)
	self.Divider:SetRightMin(self.ListBase:GetWide()/2-15)
	self.Divider.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawRect(w/2-1, 0, 2, h)
	end


	/*---------------------------------------------------------------------------
		Weapons on the right
	---------------------------------------------------------------------------*/
	self.WeaponBase = vgui.Create("DPanel", self.Container)
	self.WeaponBase:Dock(RIGHT)
	self.WeaponBase:SetWide(self.Container:GetWide()/3)
	self.WeaponBase:InvalidateParent(true)
	self.WeaponBase.Paint = nil

	self.WeaponTitle = vgui.Create("DLabel", self.WeaponBase)
	self.WeaponTitle:Dock(TOP)
	self.WeaponTitle:SetContentAlignment(6)
	self.WeaponTitle:SetFont("InventoryColumn")
	self.WeaponTitle:SetText(UBR.ResolveString("weapons"))
	self.WeaponTitle:SetTextColor(Color(200, 200, 200, 200))
	self.WeaponTitle:SizeToContents()

	self.Weapons = vgui.Create("DPanelList", self.WeaponBase)
	self.Weapons:Dock(FILL)
	self.Weapons:EnableVerticalScrollbar()
	self.Weapons:SetSpacing(6)
	self.Weapons:EnableDroppableHover(10, "PickupVicinityWeapon")

	self.Weapons:Receiver("PickupVicinityWeapon", function(s, tbl, dropped)
		if(dropped) then pickupVicinity(tbl[1]) end
	end)

	local vbar = self.Weapons.VBar

	local clr = Color(145, 146, 148)

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

	self:PopulateWeapons()
end


/*---------------------------------------------------------------------------
	Updating weapons in the vicinity
---------------------------------------------------------------------------*/

function PANEL:UpdateVicinity()
	local entities = ents.FindInSphere(LocalPlayer():GetPos(), UBR.Config.PickupDistance)
	local lEnts = {}

	for _, v in pairs(entities) do
		if(!hook.Call("CanPickupItem", GAMEMODE.Hooks, LocalPlayer(), v)) then continue end

		lEnts[v] = true

		if(!self.VicinityItems[v]) then
			self.VicinityItems[v] = true

			local pnl = vgui.Create("VicinityItem")
			pnl:SetTall(self.ListBase:GetTall()/14)
			pnl.ModelCont:SetWide(pnl:GetTall())
			pnl:SetItem(v)
			pnl.ent = v

			self.Vicinity:AddItem(pnl)	
		end
	end

	for _, v in pairs(self.Vicinity:GetItems()) do
		if(!lEnts[v.ent]) then
			self.VicinityItems[v.ent] = nil
			v:Remove()
		end
	end
end


/*---------------------------------------------------------------------------
	Updating the ammo and inventory
---------------------------------------------------------------------------*/
function PANEL:PopulateInventory(ammoType)
	for k, v in pairs(self.Inventory:GetItems()) do v:Remove() end

	local t = table.Copy(LocalPlayer():GetInventory())
	for k, v in pairs(game.BuildAmmoTypes()) do
		local amt = LocalPlayer():GetAmmoCount(v.name)
		if(amt > 0 || v.name == ammoType) then
			local ins = {}
			ins.name = v.name
			ins.model = UBR.AmmoTypeToModel(v.name)
			ins.isAmmo = true

			table.insert(t, ins)
		end
	end

	for k, v in pairs(t) do
		local pnl = vgui.Create("InventoryItem")
		pnl:SetTall(self.ListBase:GetTall()/14)
		pnl.ModelCont:SetWide(pnl:GetTall())
		pnl:SetItem(k, v)

		self.Inventory:AddItem(pnl)
	end
end


/*---------------------------------------------------------------------------
	Updating the weapons
---------------------------------------------------------------------------*/
function PANEL:PopulateWeapons()
	for k, v in pairs(self.Weapons:GetItems()) do v:Remove() end

	for k, v in pairs(LocalPlayer():GetWeapons()) do
		local pnl = vgui.Create("DPanel")
		pnl:SetTall(self.WeaponBase:GetTall()/5)
		pnl.Paint = function(s, w, h)
			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawRect(0, h-2, w, 2)
		end
		pnl.Think = function() if(!IsValid(v)) then pnl:Remove() end end

		local model = vgui.Create("DModelPanel", pnl)
		model:Dock(FILL)
		model:SetModel(v:GetWeaponWorldModel())
		model:SetAmbientLight(Color(255, 255, 255, 255))
		model:Droppable("DropWeapon")
		model.LayoutEntity = function() end
		model.DoRightClick = function(s)
			dropWeapon(s)
		end

		local mn, mx = model.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

		model:SetFOV(35)
		model:SetCamPos(Vector(0, 90, 0))
		model:SetLookAt((mn + mx) * 0.5)
		model.Weapon = v
		model.PaintOver = function(s, w, h)
			if(!IsValid(v)) then return end
			if(!v:Clip1()) then return end
			if(v:Clip1() < 0) then return end

			local mag = v:Clip1()
			surface.SetFont("InventoryWeaponMag")
			local mw, mh = surface.GetTextSize(mag)

			local reserve = LocalPlayer():GetAmmoCount(v:GetPrimaryAmmoType())
			surface.SetFont("InventoryWeaponReserve")
			local rw, rh = surface.GetTextSize(reserve)

			draw.SimpleText(v:GetPrintName(), "InventoryWeaponName")

			draw.SimpleText(mag, "InventoryWeaponMag", w-rw, 0, Color(255, 255, 255, 150), TEXT_ALIGN_RIGHT)
			draw.SimpleText(reserve, "InventoryWeaponReserve", w, mh/2, Color(255, 255, 255, 40), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			draw.SimpleText(game.GetAmmoName(v:GetPrimaryAmmoType()), "InventoryWeaponAmmoName", w-rw-mw-ScreenScale(7), 0, Color(255, 255, 255, 40), TEXT_ALIGN_RIGHT)
		end

		self.Weapons:AddItem(pnl)
	end
end


/*---------------------------------------------------------------------------
	Hooking onto events to update inventory/weapons
---------------------------------------------------------------------------*/
hook.Add("HUDAmmoPickedUp", "UpdateInventory", function(ammoType, amount)
	if(IsValid(frame)) then frame:PopulateInventory(ammoType) end
end)

hook.Add("HUDWeaponPickedUp", "UpdateInventory", function(wep)
	if(IsValid(frame)) then frame:PopulateWeapons() end
end)


/*---------------------------------------------------------------------------
	Another function to update the inventory
---------------------------------------------------------------------------*/
function GM:RefreshInventory()
	if(IsValid(frame)) then frame:PopulateInventory() end
end


/*---------------------------------------------------------------------------
	Auto vicinity scan
---------------------------------------------------------------------------*/
local cd = CurTime()
function PANEL:Think()
	if(CurTime() > cd) then cd = CurTime() + UBR.Config.InventoryRefreshRate else return end
	self:UpdateVicinity()
end


/*---------------------------------------------------------------------------
	painting the panel
---------------------------------------------------------------------------*/
function PANEL:Paint(w, h)
	drawBlur(self)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("Inventory", PANEL, "Panel")


/*---------------------------------------------------------------------------
	Binding the inventory to open up properly
---------------------------------------------------------------------------*/
function GM:ScoreboardShow()
	self:ScoreboardHide()
	frame = vgui.Create("Inventory")
end

function GM:ScoreboardHide()
    if(IsValid(frame)) then frame:Remove() end
end