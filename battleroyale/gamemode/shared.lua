/*---------------------------------------------------------------------------
	Gamemode variables
---------------------------------------------------------------------------*/
GM.Name = "Ultimate Battle Royale"
GM.Author = "Threebow"

function GM:Initialize()
	self.BaseClass.Initialize(self)
end


/*---------------------------------------------------------------------------
	Globals for our gamemode
---------------------------------------------------------------------------*/
UBR = {}
UBR.Config = {}
UBR.Hooks = {}


/*---------------------------------------------------------------------------
	Functions for creating items
---------------------------------------------------------------------------*/
AddCSLuaFile("sh_createitems.lua")
include("sh_createitems.lua")


/*---------------------------------------------------------------------------
	Loading configuration files
---------------------------------------------------------------------------*/
local cfgPath = GM.FolderName.."/gamemode/config/"
local cfgFiles = file.Find(cfgPath.."*.lua", "LUA")

for _, cfg in pairs(cfgFiles) do
	local path = cfgPath..cfg

	if(SERVER) then
		AddCSLuaFile(path)
	end

	include(path)
end


/*---------------------------------------------------------------------------
	Loading modules
---------------------------------------------------------------------------*/
local modulePath = GM.FolderName.."/gamemode/modules/"
local moduleDirs = select(2, file.Find(modulePath.."*", "LUA"))

for _, dir in pairs(moduleDirs) do
	local path = modulePath..dir.."/"
	local files = file.Find(path.."*.lua", "LUA")

	for _, f in pairs(files) do
		local path = path..f

		if(SERVER) then
			if(f:StartWith("sh_")) then
				AddCSLuaFile(path)
				include(path)		
			end

			if(f:StartWith("cl_")) then
				AddCSLuaFile(path)
			end

			if(f:StartWith("sv_")) then
				include(path)
			end
		else
			include(path)
		end
	end
end