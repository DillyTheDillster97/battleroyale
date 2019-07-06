util.AddNetworkString("ParachuteColor")
util.AddNetworkString("OpenParachuteColorMenu")

/*---------------------------------------------------------------------------
	Initialize parachute data
---------------------------------------------------------------------------*/
if(!sql.TableExists("ubr_paracolors")) then
	sql.Query("CREATE TABLE ubr_paracolors (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, steamid TEXT NOT NULL, r INTEGER NOT NULL, g INTEGER NOT NULL, b INTEGER NOT NULL)")
end

local meta = FindMetaTable("Player")

function meta:GetParachuteColor()
	local row = sql.QueryRow("SELECT * FROM ubr_paracolors WHERE steamid = '"..self:SteamID64().."'")

	if(!row) then return end
	return Color(row.r, row.g, row.b)
end

function meta:SetParachuteColor(clr)
	sql.Query("UPDATE ubr_paracolors SET r = "..clr.r..", g = "..clr.g..", b = "..clr.b.." WHERE steamid = '"..self:SteamID64().."'")
	self:NetworkParachuteColor()
	self:Notify("Parachute color changed.")
end

function meta:NetworkParachuteColor()
	net.Start("ParachuteColor")
		net.WriteTable(self:GetParachuteColor())
	net.Send(self)
end

function meta:SetupParachuteColor()
	if(self:IsBot()) then return end

	local clr = self:GetParachuteColor()

	if(!IsColor(clr)) then
		sql.Query("INSERT INTO ubr_paracolors (steamid, r, g, b) VALUES ('"..self:SteamID64().."', 255, 255, 255)")
	end

	self:NetworkParachuteColor()
end

net.Receive("ParachuteColor", function(len, ply)
	local t = net.ReadTable()
	if(!isnumber(t.r) || !isnumber(t.g) || !isnumber(t.b)) then return end

	t.r = math.Clamp(t.r, 0, 255)
	t.g = math.Clamp(t.g, 0, 255)
	t.b = math.Clamp(t.b, 0, 255)

	local oldCol = ply:GetParachuteColor() || Color(255, 255, 255)
	local newCol = Color(t.r, t.g, t.b)

	local canChange = hook.Call("CanChangeParachuteColor", GAMEMODE.Hooks, ply, oldCol, newCol)
	if(!canChange) then return end

	ply:SetParachuteColor(newCol)
end)

hook.Add("PlayerSay", "OpenParachuteColorMenu", function(ply, text)
	if(text:lower() == "!parachute") then
		net.Start("OpenParachuteColorMenu")
		net.Send(ply)
		
		return ""
	end
end)