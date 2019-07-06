/*---------------------------------------------------------------------------
	Enumerations for round states
---------------------------------------------------------------------------*/
STATE_INPROGRESS = 0
STATE_COOLDOWN = 1
STATE_LOBBY = 2
STATE_PREPARING = 3


/*---------------------------------------------------------------------------
	Gamemode functions for getting/setting round info
---------------------------------------------------------------------------*/
function GM:SetRoundState(state)
	SetGlobalInt("RoundState", state)
end

function GM:GetRoundState()
	return GetGlobalInt("RoundState")
end

function GM:RoundInProgress()
	return self:GetRoundState() == STATE_INPROGRESS
end

function GM:RoundInCooldown()
	return self:GetRoundState() == STATE_COOLDOWN
end

function GM:RoundInLobby()
	return self:GetRoundState() == STATE_LOBBY
end

function GM:RoundInPreparation()
	return self:GetRoundState() == STATE_PREPARING
end


/*---------------------------------------------------------------------------
	Client functions for round events
---------------------------------------------------------------------------*/
if(CLIENT) then
	function GM:RoundBegun()
		chat.AddText("Round Begin")
	end

	function GM:RoundEnded()
		chat.AddText("Round End")
	end

	function GM:RoundLobby()
		chat.AddText("Round Lobby")
	end

	function GM:RoundPreparing()
		chat.AddText("Round Preparing")
	end

	net.Receive("RoundBegun", GM.RoundBegun)
	net.Receive("RoundEnded", GM.RoundEnded)
	net.Receive("RoundLobby", GM.RoundLobby)
	net.Receive("RoundPreparing", GM.RoundPreparing)

	concommand.Add("getposv", function()
		local pos = LocalPlayer():GetPos()
		chat.AddText("Vector(", tostring(math.Round(pos.x)), ", ", tostring(math.Round(pos.y)), ", ", tostring(math.Round(pos.z)), "),")
	end)

	concommand.Add("getpost", function()
		local pos = LocalPlayer():GetEyeTrace().HitPos
		chat.AddText("Vector(", tostring(math.Round(pos.x)), ", ", tostring(math.Round(pos.y)), ", ", tostring(math.Round(pos.z)), "),")
	end)
end