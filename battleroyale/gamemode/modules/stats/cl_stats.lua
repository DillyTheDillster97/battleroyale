local meta = FindMetaTable("Player")
local stats = {}

function UBR.GetStats() return stats end
function UBR.GetStat(stat) return stats[stat] end

net.Receive("UpdateStats", function()
	stats = net.ReadTable()
end)