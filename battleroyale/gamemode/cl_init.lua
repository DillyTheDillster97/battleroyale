include("shared.lua")
include("sh_hooks.lua")
include("cl_hooks.lua")


/*---------------------------------------------------------------------------
	Handles all keypress hooks
---------------------------------------------------------------------------*/
function GM:KeyPress(...)
	self:SpectatorKeyPress(...)
end


/*---------------------------------------------------------------------------
	Handles showhelp, showteam, and the showspares clientside
---------------------------------------------------------------------------*/
local gmBinds = {
	["gm_showhelp"] = "ShowHelp",
	["gm_showteam"] = "ShowTeam",
	["gm_showspare1"] = "ShowSpare1",
	["gm_showspare2"] = "ShowSpare2"
}

function GM:PlayerBindPress(ply, bind, pressed)
	local name = gmBinds[bind]
	if(name) then
		local fn = self[name]
		if(fn) then fn(self) end
	end
end


/*---------------------------------------------------------------------------
	Overwriting it so that the team selection menu doesn't pop up when
	F2 is pressed
---------------------------------------------------------------------------*/
function GM:ShowTeam() end