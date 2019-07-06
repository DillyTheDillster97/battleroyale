/*---------------------------------------------------------------------------
	Pooling network strings for round states
---------------------------------------------------------------------------*/
util.AddNetworkString("RoundBegun")
util.AddNetworkString("RoundEnded")
util.AddNetworkString("RoundLobby")
util.AddNetworkString("RoundPreparing")

/*---------------------------------------------------------------------------
	Gamemode functions for starting/ending/lobbying/preparing rounds
---------------------------------------------------------------------------*/
local cd = CurTime()
local cdDuration = UBR.Config.RoundCooldown

function GM:StartRound()
	self:SetRoundState(STATE_INPROGRESS)
	self:SetupTeams()

	self:SetupZone()

	UBR.AirdropCooldown = CurTime() + UBR.Config.AirdropRate

	net.Start("RoundBegun")
	net.Broadcast()
end

function GM:EndRound()
	self:DisableZone()

	self:SetRoundState(STATE_COOLDOWN)
	self:Spectatorify()

	net.Start("RoundEnded")
	net.Broadcast()
end

function GM:Lobby()
	if(self:RoundInProgress()) then
		self:EndRound()
	end

	self:SetRoundState(STATE_LOBBY)

	net.Start("RoundLobby")
	net.Broadcast()
end

function GM:PrepareRound()
	if(self:RoundInProgress()) then return end

	cd = CurTime() + UBR.Config.PreparationTime
	SetGlobalInt("PreparationTime", cd)
	self:SetRoundState(STATE_PREPARING)

	timer.Create("RoundPrepare", 2, 1, function()
		game.CleanUpMap()
		self:SpawnItems()
	end)

	net.Start("RoundPreparing")
	net.Broadcast()
end


/*---------------------------------------------------------------------------
	Throw the gamemode into the lobby state to start off
---------------------------------------------------------------------------*/
timer.Simple(0, function()
	if(UBR.Debug) then return end
	GAMEMODE:Lobby()
end)


/*---------------------------------------------------------------------------
	Handle all round processing here
---------------------------------------------------------------------------*/
function GM:RoundTick()
	/*---------------------------------------------------------------------------
		Start or lobby the round after preparation
	---------------------------------------------------------------------------*/
	if(self:RoundInPreparation() && CurTime() > cd) then
		local allowed = hook.Call("CanStartRound", self.Hooks)
		if(allowed) then self:StartRound() else self:Lobby() end
	end


	/*---------------------------------------------------------------------------
		Prepare the round if the condition is met
	---------------------------------------------------------------------------*/
	if(self:RoundInLobby() && CurTime() > cd) then
		local allowed = hook.Call("CanStartRound", self.Hooks)
		if(allowed) then self:PrepareRound() else cd = CurTime() + 8 end
	end


	/*---------------------------------------------------------------------------
		End the round if there's one player alive, and trigger the win condition
	---------------------------------------------------------------------------*/
	if(self:RoundInProgress()) then
		self:ZoneTick()
	 	if(CurTime() > cd) then
			cd = CurTime() + 0.5

			local count = #self:GetContestants()

			if(count == 1) then
				local winner = self:GetContestants()[1]
				hook.Run("Win", winner)
				self:EndRound()
				cd = CurTime() + cdDuration
			elseif(count == 0) then
				cd = CurTime() + cdDuration
				self:EndRound()
			end
		end
	end


	/*---------------------------------------------------------------------------
		Transition the round into the lobby state when the cooldown is over
	---------------------------------------------------------------------------*/
	if(self:RoundInCooldown() && CurTime() > cd) then
		self:Lobby()
	end
end