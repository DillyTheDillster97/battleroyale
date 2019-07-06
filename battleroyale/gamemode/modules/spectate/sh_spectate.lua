/*---------------------------------------------------------------------------
	Block spectator movement
---------------------------------------------------------------------------*/
function GM:StartCommand(ply, ucmd)
	if((ply:IsSpectator() || ply:GetNWBool("InPlane")) && self:RoundInProgress()) then
		ucmd:ClearMovement()
		ucmd:RemoveKey(IN_JUMP)
		ucmd:RemoveKey(IN_DUCK)
		ucmd:RemoveKey(IN_USE)
	end
end


/*---------------------------------------------------------------------------
	Block spectator collision
---------------------------------------------------------------------------*/
function GM:ShouldCollide(ply1, ply2)
	if(!IsValid(ply1) || !IsValid(ply2)) then return true end
	if(!ply1:IsPlayer() || !ply2:IsPlayer()) then return true end

	if(!self:RoundInProgress()) then return false end
	if(!ply1:IsOnGround() && !ply2:IsOnGround()) then return false end
	if(ply1:IsSpectator() || ply2:IsSpectator()) then return false end
	if(ply1:GetNWBool("InPlane") || ply2:GetNWBool("InPlane")) then return false end

	return true
end