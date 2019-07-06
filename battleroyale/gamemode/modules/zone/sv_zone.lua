/*---------------------------------------------------------------------------
	Gamemode functions for manipulating aspects of the zone
---------------------------------------------------------------------------*/
function GM:SetZonePos(pos)
	SetGlobalVector("ZonePos", pos)
end

function GM:SetZoneRadius(rad)
	SetGlobalFloat("ZoneRadius", rad)
end

function GM:EnableZone()
	SetGlobalBool("ZoneActive", true)
end

function GM:DisableZone()
	SetGlobalBool("ZoneActive", false)
end

function GM:AddZoneRadius(rad)
	SetGlobalFloat("ZoneRadius", self:GetZoneRadius() + rad)
end

function GM:SetZoneMoveTime(t)
	SetGlobalInt("ZoneMoveTime", t)
end


/*---------------------------------------------------------------------------
	Gets a random point within a radius
---------------------------------------------------------------------------*/
local function randomPoint(rad)
	local rand = VectorRand()*rad
	return Vector(rand.x, rand.y)
end


/*---------------------------------------------------------------------------
	Returns whether a vector is underwater
---------------------------------------------------------------------------*/
local function isUnderwater(pos)
	return bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
end


/*---------------------------------------------------------------------------
	Function which sets up the zone when the round begins
---------------------------------------------------------------------------*/
local damageCd = CurTime()
local moveCd = CurTime()
local enabled = false
local step = 1

local newPos, newRad = Vector(), 0
local oldPos, oldRad = Vector(), 0

function GM:SetupZone()
	self:EnableZone()

	local pos
	repeat
		local rand = VectorRand()*UBR.Config.MapRadius

		local data = {}
		data.start = UBR.Config.MapCenter + Vector(rand.x, rand.y)
		data.endpos = data.start - Vector(0, 0, UBR.Config.MapRadius*2)
		data.filter = function(ent) return ent != game.GetWorld() end

		local tr = util.TraceLine(data)

		pos = tr.HitPos
	until util.IsInWorld(pos) && !isUnderwater(pos)
		
	self:SetZonePos(pos)
	self:SetZoneRadius(UBR.Config.ZoneRadius)

	newPos, newRad = pos, UBR.Config.ZoneRadius

	step = 1
	enabled = false

	damageCd = CurTime() + UBR.Config.ZoneDamageDelay
	moveCd = CurTime() + UBR.Config.ZoneMoveDelay
	self:SetZoneMoveTime(moveCd)

	self:Notify(UBR.ResolveString("zone_alert", UBR.Config.ZoneMoveDelay, UBR.Config.ZoneDamageDelay), NOTIFY_HINT, 10)
end


/*---------------------------------------------------------------------------
	Handles the zone
---------------------------------------------------------------------------*/
local decx, dexy, decz = 0, 0, 0
function GM:ZoneTick()
	if(!self:ZoneActive()) then return end

	if(enabled) then
		if(CurTime() > moveCd) then
			local pos = self:GetZonePos()
			self:SetZonePos(Vector(pos.x - decx, pos.y - decy, pos.z - decz))
			self:AddZoneRadius(-UBR.Config.ZoneMovementSpeed)
		end

		if(self:GetZoneRadius() <= UBR.Config.ZoneRadius/2^(step-1)) then
			enabled = false
			moveCd = CurTime() + UBR.Config.ZoneStepTime
			self:SetZoneMoveTime(moveCd)
		end
	elseif(CurTime() > moveCd && step != UBR.Config.ZoneSteps) then
		step = step + 1
		enabled = true

		if(step == UBR.Config.ZoneSteps) then
			enabled = false
			self:SetZoneMoveTime(0)
		end

		local pos = self:GetZonePos()
		local rad = self:GetZoneRadius()

		oldRad, newRad = rad, rad/2
		oldPos = pos

		repeat
			local rand = pos + randomPoint(newRad)

			local tr = util.TraceLine({
				start = Vector(newPos.x, newPos.y, UBR.Config.MapHeight),
				endpos = Vector(newPos.x, newPos.y, -UBR.Config.MapHeight*2),
				filter = function(ent) return ent != game.GetWorld() end
			})

			newPos = Vector(rand.x, rand.y, tr.HitPos.z)
		until util.IsInWorld(newPos) && !isUnderwater(newPos)

		local diffX, diffY, diffZ = oldPos.x - newPos.x, oldPos.y - newPos.y, oldPos.z - newPos.z

		decx = (diffX / (oldRad/2)) * UBR.Config.ZoneMovementSpeed
		decy = (diffY / (oldRad/2)) * UBR.Config.ZoneMovementSpeed
		decz = (diffZ / (oldRad/2)) * UBR.Config.ZoneMovementSpeed
	end


	/*---------------------------------------------------------------------------
		Damage
	---------------------------------------------------------------------------*/
	if(CurTime() > damageCd) then damageCd = CurTime() + 1 else return end

	local pos, rad = self:GetZonePos(), self:GetZoneRadius()

	local tbl = {}
	for k, v in pairs(self:GetLivingContestants()) do
		if(v:GetPos():DistToSqr(pos) > rad*rad) then
			local dmg = hook.Call("GetZoneDamage", self.Hooks, ply, step*UBR.Config.ZoneDamageMultiplier)

			if(v:InVehicle()) then
				local veh = v:GetVehicle()
				veh:TakeDamage(dmg, v, v)
			else
				v:TakeDamage(dmg, v, v)
			end
		end
	end
end