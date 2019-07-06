ENT.Type = "anim"
ENT.PrintName = "Medkit"
ENT.Author = "Threebow"
ENT.Spawnable = false
ENT.Lootable = true
ENT.Weight = 30
ENT.UseTime = 10

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Tooltip")
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
end