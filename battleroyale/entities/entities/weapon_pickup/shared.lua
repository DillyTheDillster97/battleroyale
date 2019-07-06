ENT.Type = "anim"
ENT.PrintName = "Weapon Pickup"
ENT.Author = "Threebow"
ENT.Spawnable = false
ENT.Lootable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Tooltip")
end

function ENT:SetWeapon(class, tbl)
	self.Class = class
	self.PrintName = tbl.PrintName
	self.WepTBL = tbl

	if(SERVER) then
		self:SetModel(tbl.WorldModel)
		self:SetTooltip(tbl.PrintName || class)
	end
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end	
end