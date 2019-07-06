ENT.Type = "anim"
ENT.PrintName = "Ammo Pickup"
ENT.Author = "Threebow"
ENT.Spawnable = false
ENT.Lootable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Tooltip")
end

function ENT:SetAmmo(ammoType, amount)
	self.AmmoType = ammoType
	self.Amount = amount

	self:SetTooltip(UBR.ResolveString("ammo_tooltip", ammoType, amount))
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end	
end