/*---------------------------------------------------------------------------
	Function which parachutes a player
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")

function meta:Parachute()
	if(!IsValid(self)) then return end
	if(!self:Alive()) then return end
	if(self:GetMoveType() == MOVETYPE_NOCLIP) then return end
	if(self:InVehicle()) then return end
	if(self:GetNWBool("DisallowParachute")) then return end
	if(self:GetNWBool("Parachuting")) then return end
	if(!GAMEMODE:RoundInProgress()) then return end
	if(!self:IsContestant()) then return end

	self:SetNWBool("Parachuting", true)
	self:ViewPunch(Angle(35, 0, 0))
	self:EmitSound("ParachuteDeploy")

	local chute = ents.Create("parachute_active")
	chute:SetOwner(self)
	chute:Spawn()
end


/*---------------------------------------------------------------------------
	Handling parachute keypresses
---------------------------------------------------------------------------*/
function GM:ParachuteKeyPress(ply, key)
	if(key != IN_JUMP) then return end
	if(ply:GetVelocity().z > -600) then return end
	if(ply:OnGround()) then return end
	ply:Parachute()
end


/*---------------------------------------------------------------------------
	Handles player/parachute movement
---------------------------------------------------------------------------*/
function GM:ParachuteThink()
	for _, v in pairs(player.GetAll()) do
		if(v:GetNWBool("Parachuting")) then
			v.ForwardVel = Lerp(0.013, v.ForwardVel || 0, v:KeyDown(IN_FORWARD) && 1 || 0)
			v.BackwardVel = Lerp(0.03, v.BackwardVel || 0, v:KeyDown(IN_BACK) && 1 || 0)
			v.LeftVel = Lerp(0.03, v.LeftVel || 0, v:KeyDown(IN_MOVELEFT) && 1 || 0)
			v.RightVel = Lerp(0.03, v.RightVel || 0, v:KeyDown(IN_MOVERIGHT) && 1 || 0)

			local ang = v:GetAngles()

			local f = v.ForwardVel * ang:Forward() * 150
			local b = v.BackwardVel * -ang:Forward() * 150
			local l = v.RightVel * ang:Right() * 150
			local r = v.LeftVel * -ang:Right() * 150

			v:SetLocalVelocity(f+b+l+r+v:GetForward()*375 - v:GetUp() * 320)

			if(v:OnGround() || !v:Alive()) then
				v:SetNWBool("Parachuting", false)
				v:SetNWBool("DisallowParachute", true)
				v:ViewPunch(Angle(-20, 0, 0))
				v:EmitSound("ParachuteLand")

				if(!self:RoundInProgress()) then return end
				
				local chute = ents.Create("parachute_landed")
				chute:SetOwner(v)
				chute:SetPos(v:EyePos())
				chute:SetAngles(v:GetAngles())
				chute:Spawn()
			end
		else
			if(!self:RoundInProgress()) then return end
			if(v:GetNWBool("DisallowParachute")) then continue end
			if(!v:IsContestant()) then continue end

			local tr = util.TraceLine({
				start = v:GetPos(),
				endpos = v:GetPos() - Vector(0, 0, UBR.Config.MapHeight*2),
				filter = v
			})

			local start = v:GetNWVector("StartPos")
			local startDistance = start.z - v:GetPos().z
			local groundDistance = v:GetPos().z - tr.HitPos.z

			if(startDistance == 0 || groundDistance == 0) then continue end

			if(v:GetNWBool("AutoPara") && startDistance >= groundDistance*(UBR.Config.DropPoint - 1)) then
				v:Parachute()
				v:SetNWBool("AutoPara", false)
			end
		end
	end
end