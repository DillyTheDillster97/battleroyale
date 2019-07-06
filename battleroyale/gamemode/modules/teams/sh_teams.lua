/*---------------------------------------------------------------------------
	Setting up teams as well as global TEAM_<name> enums
---------------------------------------------------------------------------*/
local teamIndex = 0
for k, v in pairs(UBR.Teams) do
	team.SetUp(teamIndex, k, v.color)
	_G["TEAM_"..k:upper()] = teamIndex

	teamIndex = teamIndex + 1
end


/*---------------------------------------------------------------------------
	Gamemode functions for getting a table of spectators and contestants
---------------------------------------------------------------------------*/
function GM:GetSpectators()
	return team.GetPlayers(TEAM_SPECTATOR)
end

function GM:GetContestants()
	return team.GetPlayers(TEAM_CONTESTANT)
end

function GM:GetContestantCount()
	local amt = 0

	for k, v in pairs(self:GetContestants()) do
		if(v:Alive()) then amt = amt + 1 end
	end

	return amt
end

function GM:GetLivingContestants()
	local t = {}

	for k, v in pairs(self:GetContestants()) do
		if(v:Alive()) then table.insert(t, v) end
	end

	return t
end