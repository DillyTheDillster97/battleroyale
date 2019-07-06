ENT.Type = "anim"
ENT.PrintName = "Gas Can"
ENT.Author = "Threebow"
ENT.Spawnable = false
ENT.Lootable = true
ENT.Weight = 25
ENT.UseTime = 5

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Tooltip")
end

if(CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
end