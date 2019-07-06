/*---------------------------------------------------------------------------
	Hooking up notifications on net message
---------------------------------------------------------------------------*/
net.Receive("Notify", function()
	surface.PlaySound("ui/buttonclick.wav")
	notification.AddLegacy(net.ReadString(), net.ReadInt(8), net.ReadInt(8))
end)