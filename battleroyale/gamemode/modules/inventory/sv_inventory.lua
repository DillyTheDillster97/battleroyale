/*---------------------------------------------------------------------------
	Pooling network strings
---------------------------------------------------------------------------*/
util.AddNetworkString("InventoryUpdate")
util.AddNetworkString("DropItem")
util.AddNetworkString("UseItem")
util.AddNetworkString("DropWeapon")
util.AddNetworkString("DropAmmo")
util.AddNetworkString("PickupVicinity")
util.AddNetworkString("ForceRefreshInventory")
util.AddNetworkString("StartItemUse")
util.AddNetworkString("EndItemUse")


/*---------------------------------------------------------------------------
	Meta functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:NetworkInventory()
	local inv = table.Copy(self:GetInventory())

	for k, v in pairs(inv) do
		v.onUse = nil
		v.canUse = nil
	end

	net.Start("InventoryUpdate")
		net.WriteTable(inv)
	net.Send(self)
end

function meta:ClearInventory()
	self.Inventory = {}
	self:NetworkInventory()
	return self.Inventory
end

function meta:DeleteFromInventory(key, dontPlaySound)
	local inv = self:GetInventory()
	inv[key] = nil

	if(!dontPlaySound) then
		self:EmitSound(UBR.Config.InventorySounds.Drop)
	end

	self:NetworkInventory()
	return inv
end

function meta:AddToInventory(ent, allowed, use, dontPlaySound)
	if(ent.Weight && self:GetInventoryWeight() + ent.Weight > self:GetInventoryCapacity()) then
		self:Notify(UBR.ResolveString("inventory_full"))
		return
	end

	local inv = self:GetInventory()

	table.insert(inv, {
		class = ent:GetClass(),
		model = ent:GetModel(),
		name = ent.PrintName,
		weight = ent.Weight,
		useTime = ent.UseTime,
		canUse = allowed,
		onUse = use
	})

	if(!dontPlaySound) then
		self:EmitSound(UBR.Config.InventorySounds.Pickup)
	end

	self:NetworkInventory()
	ent:Remove()
	return inv
end

function meta:ForceRefreshInventory()
	net.Start("ForceRefreshInventory")
	net.Send(self)
end

function meta:StartUsing(item, key)
	self.UsingItem = true
	self.UsingKey = key
	net.Start("StartItemUse")
		net.WriteInt(item.useTime, 16)
	net.Send(self)
end

function meta:EndUsing()
	self.UsingItem = false
	net.Start("EndItemUse")
	net.Send(self)
end


/*---------------------------------------------------------------------------
	Handles dropping of items
---------------------------------------------------------------------------*/
net.Receive("DropItem", function(len, ply)
	local key = net.ReadInt(10)
	if(!ply:InventoryContains(key)) then return end
	if(ply:InVehicle()) then return end
	local item = ply:GetInventory()[key]

	ply:DeleteFromInventory(key)

	local ent = ents.Create(item.class)
	ent:SetPos(ply:EyePos() + ply:GetAimVector() * 10)
	ent:SetAngles(ply:GetAngles())
	ent:Spawn()
end)


/*---------------------------------------------------------------------------
	Handles use of items
---------------------------------------------------------------------------*/
function GM:ItemUseThink()
	for k, v in pairs(player.GetAll()) do
		if(v.UsingItem) then
			if(!hook.Call("CanUseItem", self.Hooks, v)) then v:EndUsing() end
		end
 	end
end

net.Receive("UseItem", function(len, ply)
	local key = net.ReadInt(10)
	if(!ply:InventoryContains(key)) then return end
	local item = ply:GetInventory()[key]

	if(item.useTime) then
		local canUse, msg = item.canUse(ply)
		if(!canUse) then ply:Notify(msg) return end

		ply:StartUsing(item, key)

		timer.Create(ply:SteamID64().."use", item.useTime, 1, function()
			if(!IsValid(ply) || !ply:IsPlayer()) then return end
			if(!ply.UsingItem) then return end

			ply:EndUsing()

			local canUse, msg = item.canUse(ply)
			if(canUse) then
				item.onUse(ply)
				ply:DeleteFromInventory(key)
			else ply:Notify(msg) end
		end)
	else
		local canUse, msg = item.canUse(ply)
		if(canUse) then
			item.onUse(ply)
			ply:DeleteFromInventory(key)
		else ply:Notify(msg) end
	end
end)


/*---------------------------------------------------------------------------
	Handles dropping of weapons
---------------------------------------------------------------------------*/
net.Receive("DropWeapon", function(len, ply)
	local cl = net.ReadString()
	if(!cl) then return end
	if(!ply:HasWeapon(cl)) then return end
	local wep = ply:GetWeapon(cl)
	if(!wep) then return end

	local ent, tbl = UBR.SpawnWeapon(cl, ply:EyePos()+ply:GetAimVector()*15)

	ent:EmitSound(UBR.Config.InventorySounds.Drop)
	ent:PhysWake()

	local phys = ent:GetPhysicsObject()
	if(IsValid(phys)) then
		phys:SetVelocity(ply:GetVelocity())
	end

	ply:GiveAmmo(wep:Clip1(), tbl.Primary.Ammo)
	ply:StripWeapon(cl)
	ply:ConCommand("lastinv")
end)


/*---------------------------------------------------------------------------
	Handle dropping ammo
---------------------------------------------------------------------------*/
net.Receive("DropAmmo", function(len, ply)
	local ammoType = net.ReadString()
	local amount = net.ReadInt(15)
	if(!ammoType || !amount) then return end

	local ammo = math.min(amount, ply:GetAmmoCount(ammoType))
	if(ammo <= 0) then return end

	local ent = UBR.SpawnAmmo(ammoType, amount, ply:EyePos()+ply:GetAimVector()*15)
	ent:EmitSound(UBR.Config.InventorySounds.Drop)
	ent:PhysWake()

	local phys = ent:GetPhysicsObject()
	if(IsValid(phys)) then
		phys:SetVelocity(ply:GetVelocity())
	end

	ply:RemoveAmmo(ammo, ammoType)
end)


/*---------------------------------------------------------------------------
	Picking up items in the vicinity
---------------------------------------------------------------------------*/
net.Receive("PickupVicinity", function(len, ply)
	local ent = net.ReadEntity()
	if(!IsValid(ent)) then return end

	if(!hook.Call("CanPickupItem", GAMEMODE.Hooks, ply, ent)) then return end

	ent:Use(ply, ply, USE_ON, 1)
	ent:EmitSound(UBR.Config.InventorySounds.Pickup)
end)