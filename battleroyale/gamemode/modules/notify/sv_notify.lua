/*---------------------------------------------------------------------------
	Network string for notifications
---------------------------------------------------------------------------*/
util.AddNetworkString("Notify")


/*---------------------------------------------------------------------------
	Functions for notifying
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

local function notify(text, notiftype, length)
	text = text || ""
	notiftype = notiftype || 0
	length = length || 3

	net.WriteString(text)
	net.WriteInt(notiftype, 8)
	net.WriteInt(length, 8)
end

function meta:Notify(text, notiftype, length)
	net.Start("Notify")
		notify(text, notiftype, length)
	net.Send(self)
end

function GM:Notify(text, type, length, tbl)
	net.Start("Notify")
		notify(text, notiftype, length)
	if(tbl) then net.Send(tbl) else net.Broadcast() end
end