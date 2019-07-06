/*---------------------------------------------------------------------------
	Network string for networking player stats
---------------------------------------------------------------------------*/
util.AddNetworkString("UpdateStats")


/*---------------------------------------------------------------------------
	Initializing the stats table
---------------------------------------------------------------------------*/
if(!sql.TableExists("ubr_stats")) then
	sql.Query("CREATE TABLE ubr_stats (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, steamid TEXT NOT NULL, wins INTEGER NOT NULL, kills INTEGER NOT NULL, deaths INTEGER NOT NULL, airdrops_looted INTEGER NOT NULL, damage_dealt INTEGER NOT NULL)")
end


/*---------------------------------------------------------------------------
	Meta functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:NetworkStats()
	if(self:IsBot()) then return end

	net.Start("UpdateStats")
		net.WriteTable(self:GetStats())
	net.Send(self)
end

function meta:SetupStats()
	if(self:IsBot()) then return end

	local stats = self:GetStats()

	if(!istable(stats)) then
		sql.Query("INSERT INTO ubr_stats (steamid, wins, kills, deaths, airdrops_looted, damage_dealt) VALUES ('"..self:SteamID64().."', 0, 0, 0, 0, 0)")
	end

	self:NetworkStats()
end

function meta:GetStats()
	return sql.QueryRow("SELECT * FROM ubr_stats WHERE steamid = '"..self:SteamID64().."'")
end

function meta:GetStat(stat)
	return self:GetStats()[stat]
end

function meta:AddStat(stat, amt)
	if(self:IsBot()) then return end

	local count = self:GetStat(stat)
	self:SetStat(stat, count && count + amt || amt)
end

function meta:SetStat(stat, amt)
	if(self:IsBot()) then return end

	amt = math.Round(amt)

	sql.Query("UPDATE ubr_stats SET "..stat.." = "..amt.." WHERE steamid = '"..self:SteamID64().."'")
	self:NetworkStats()
	return self:GetStats()
end


/*---------------------------------------------------------------------------
	Hooks to increase stats
---------------------------------------------------------------------------*/
hook.Add("AirdropLooted", "Stats", function(ply)
	if(ply:IsBot()) then return end
	ply:AddStat("airdrops_looted", 1)
end)

hook.Add("Win", "Stats", function(ply)
	if(ply:IsBot()) then return end
	ply:AddStat("wins", 1)
end)

hook.Add("PlayerDeath", "Stats", function(ply, inflictor, attacker)
	if(!IsValid(ply) || !IsValid(attacker)) then return end
	if(!ply:IsPlayer() || !attacker:IsPlayer()) then return end
	if(ply:IsBot() || attacker:IsBot()) then return end

	if(ply != attacker) then
		attacker:AddStat("kills", 1)
		ply:AddStat("deaths", 1)
	end
end)

hook.Add("PlayerHurt", "Stats", function(ply, attacker, remaining, dmg)
	if(!IsValid(ply) || !IsValid(attacker)) then return end
	if(!ply:IsPlayer() || !attacker:IsPlayer()) then return end
	if(ply:IsBot() || attacker:IsBot()) then return end

	if(ply != attacker) then
		attacker:AddStat("damage_dealt", dmg)
	end
end)