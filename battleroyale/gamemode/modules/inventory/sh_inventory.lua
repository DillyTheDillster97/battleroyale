/*---------------------------------------------------------------------------
	Functions which are the same on both server and client
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:GetInventory()
	self.Inventory = self.Inventory || {}
	return self.Inventory
end

function meta:GetInventoryWeight()
	local weight = 0

	for k, v in pairs(self:GetInventory()) do
		if(v.weight) then weight = weight + v.weight end
	end
	
	for k, v in pairs(game.BuildAmmoTypes()) do
		weight = weight + self:GetAmmoCount(v.name) * UBR.Config.AmmoWeight
	end

	return weight
end

function meta:InventoryContains(key)
	return istable(self:GetInventory()[key])
end

function meta:GetInventoryCapacity()
	return hook.Call("GetPlayerInventoryCapacity", GAMEMODE.Hooks, self, UBR.Config.MaxInventoryCapacity)
end