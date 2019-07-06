/*---------------------------------------------------------------------------
	Registering teams
---------------------------------------------------------------------------*/
UBR.RegisterContestant({
	model = {
		"models/player/breen.mdl",
		"models/player/barney.mdl",
		"models/player/alyx.mdl",
		"models/player/monk.mdl",
		"models/player/magnusson.mdl",
		"models/player/combine_soldier.mdl"
	},
	color = Color(0, 0, 255, 255)
})

UBR.RegisterSpectator({
	model = {
		"models/player/p2_chell.mdl",
		"models/player/gman_high.mdl"
	},
	color = Color(255, 255, 255, 255)
})


/*---------------------------------------------------------------------------
	Speeds
---------------------------------------------------------------------------*/
UBR.Config.Walkspeed = 160
UBR.Config.Runspeed = 260


/*---------------------------------------------------------------------------
	Realistic fall damage. Lower this for more, raise this for less.
---------------------------------------------------------------------------*/
UBR.Config.FallDamper = 15


/*---------------------------------------------------------------------------
	How many weapons can someone hold?
---------------------------------------------------------------------------*/
UBR.Config.MaxWeapons = 3


/*---------------------------------------------------------------------------
	At which point of the trip down is someone's parachute automatically
	triggered?
---------------------------------------------------------------------------*/
UBR.Config.DropPoint = 4