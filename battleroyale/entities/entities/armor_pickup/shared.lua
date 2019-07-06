ENT.Type = "anim"
ENT.PrintName = "Armor Pickup"
ENT.Author = "Threebow"
ENT.Spawnable = false
ENT.Lootable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Tooltip")
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end	
end