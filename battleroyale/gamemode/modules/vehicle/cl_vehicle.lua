/*---------------------------------------------------------------------------
	Variables
---------------------------------------------------------------------------*/
local offset = ScreenScale(20)
local w, h = ScreenScale(55), 20

local smoothFuel = 0
local smoothFuelAlpha = 0

local smoothHealth = 0
local smoothHealthAlpha = 0


/*---------------------------------------------------------------------------
	Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("VehicleSpeed", {font = "Roboto Thin", size = 32, weight = 100})
surface.CreateFont("VehicleBar", {font = "Roboto", size = 18})
surface.CreateFont("VehicleBarTitle", {font = "Oswald Light", size = 24, weight = 100})


/*---------------------------------------------------------------------------
	The HUD
---------------------------------------------------------------------------*/
function GM:DrawVehicleHUD()
	if(!LocalPlayer():InVehicle()) then return end
	local veh = LocalPlayer():GetVehicle()
	if(!IsValid(veh)) then return end

	local x, y = offset, ScrH()-offset

	local o = UBR.Config.VehicleHealthEnabled && UBR.Config.VehicleFuelEnabled

	/*---------------------------------------------------------------------------
		Health
	---------------------------------------------------------------------------*/
	if(UBR.Config.VehicleHealthEnabled) then
		local max = veh:GetMaxHealth()
		smoothHealth, smoothHealthAlpha = self:DrawBar(x, y-h, w, h, veh:Health(), max, smoothHealth, smoothHealthAlpha)

		draw.SimpleText(math.Round(smoothHealth/max*100).."%", "VehicleBar", x+3, y-h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Health", "VehicleBarTitle", x+w+5, y-h/2, Color(255, 255, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		y = y - h*(UBR.Config.VehicleFuelEnabled&&1.3||1)
	end

	/*---------------------------------------------------------------------------
		Fuel
	---------------------------------------------------------------------------*/
	if(UBR.Config.VehicleFuelEnabled) then
		local max = veh:GetNWFloat("MaxFuel")
		smoothFuel, smoothFuelAlpha = self:DrawBar(x, y-h, w, h, veh:GetNWFloat("Fuel"), max, smoothFuel, smoothFuelAlpha)

		draw.SimpleText(math.Round(smoothFuel/max*100).."%", "VehicleBar", x+3, y-h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Fuel", "VehicleBarTitle", x+w+5, y-h/2, Color(255, 255, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		y = y - h
	end


	/*---------------------------------------------------------------------------
		Speed
	---------------------------------------------------------------------------*/
	local speed = veh:GetVelocity():Length2D()
	speed = speed/22.65*1.60934
	speed = UBR.ResolveString("speed", math.Round(speed))

	draw.SimpleText(speed, "VehicleSpeed", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end