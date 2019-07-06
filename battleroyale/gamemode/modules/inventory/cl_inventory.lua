/*---------------------------------------------------------------------------
	Meta functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:UpdateInventory(t)
	self.Inventory = t
	hook.Run("RefreshInventory")
	return self.Inventory
end


/*---------------------------------------------------------------------------
	Net messages for updating inventory
---------------------------------------------------------------------------*/
net.Receive("InventoryUpdate", function()
	if(!IsValid(LocalPlayer())) then return end
	
	LocalPlayer():UpdateInventory(net.ReadTable())
	hook.Run("RefreshInventory")
end)

net.Receive("ForceRefreshInventory", function()
	hook.Run("RefreshInventory")
end)


/*---------------------------------------------------------------------------
	Item use HUD
---------------------------------------------------------------------------*/
local using = false
local time
local stopUse

net.Receive("StartItemUse", function()
	using = true
	time = net.ReadInt(16)
	stopUse = CurTime() + time
end)

net.Receive("EndItemUse", function()
	using = false
end)

local gradMat = Material("vgui/gradient_up")

surface.CreateFont("UsingItem", {font = "Titillium Web", size = 24, weight = 100})

local topClr = Color(211, 84, 0)
local bottomClr = Color(192, 57, 43)

UBR.Dots = 0
timer.Create("DotIncrement", 0.3, 0, function()
	if(UBR.Dots >= 3) then UBR.Dots = 1 else UBR.Dots = UBR.Dots + 1 end
end)

hook.Add("HUDPaint", "ItemUseHUD", function()
	if(using) then
		local w, h = 200, 15
		local x, y = ScrW()/2-w/2, ScrH()/1.7

		local bw = stopUse - CurTime()
		bw = bw/time*w
		bw = math.Clamp(bw, 0, w)

		local nice = math.Round(stopUse - CurTime(), 1)

		draw.SimpleText(UBR.ResolveString("using", ("."):rep(UBR.Dots)), "UsingItem", x+w/2, y-2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(UBR.ResolveString("use_time", math.Round(stopUse - CurTime(), 1)), "UsingItem", x+w/2, y+h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawTexturedRect(x, y, w, h)

		surface.SetDrawColor(topClr)
		surface.DrawTexturedRect(x, y, bw, h)

		surface.SetDrawColor(bottomClr)
		surface.SetMaterial(gradMat)
		surface.DrawTexturedRect(x, y, bw, h)

		surface.SetDrawColor(255, 255, 255, 100)
		surface.DrawOutlinedRect(x, y, w, h)
	end
end)