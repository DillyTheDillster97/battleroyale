/*---------------------------------------------------------------------------
	Meta functions for config and teams
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:GetConfigTable()
	return UBR.Teams[team.GetName(self:Team())]
end

function meta:IsSpectator()
	return self:Team() == TEAM_SPECTATOR
end

function meta:IsContestant()
	return self:Team() == TEAM_CONTESTANT
end

function meta:GetKills()
	return self:GetNWInt("KillCount")
end

if(SERVER) then
	function meta:SetKills(amt)
		self:SetNWInt("KillCount", amt)
	end

	function meta:AddKills(amt)
		self:SetKills(self:GetKills() + amt)
	end
end