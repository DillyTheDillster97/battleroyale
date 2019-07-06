ENT.Type = "anim"
ENT.PrintName = "Airdrop Plane"
ENT.Author = "Threebow"

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "DropPos")
end