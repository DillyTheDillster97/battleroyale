UBR.AirdropCooldown = CurTime()

function GM:AirdropTick()
	if(!self:RoundInProgress()) then return end
	if(CurTime() > UBR.AirdropCooldown) then
		local pos
		
		repeat
			pos = self:GetZonePos()+VectorRand()*self:GetZoneRadius()*0.8
			pos = Vector(pos.x, pos.y, math.Min(self:GetZonePos().z + self:GetZoneRadius() * 2, UBR.Config.MapHeight))
		until util.IsInWorld(pos)

		local ang = Angle(0, math.random(0, 360))
		local origin = pos - ang:Forward() * UBR.Config.MapRadius*2

		local tr = util.TraceLine({
			start = pos,
			endpos = origin
		})

		local plane = ents.Create("airdrop_plane")
		plane:SetDropPos(pos)
		plane.Dist = tr.HitPos:DistToSqr(pos)
		plane:SetPos(tr.HitPos)
		plane:SetAngles(ang)
		plane:Spawn()

		UBR.AirdropCooldown = CurTime() + UBR.Config.AirdropRate

		hook.Call("AirdropSpawned", self.Hooks, drop)
	end
end