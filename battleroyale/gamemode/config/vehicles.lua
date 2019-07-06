/*---------------------------------------------------------------------------
	Should the fuel system be enabled?
---------------------------------------------------------------------------*/
UBR.Config.VehicleFuelEnabled = true


/*---------------------------------------------------------------------------
	Should vehicle damage be enabled?
---------------------------------------------------------------------------*/
UBR.Config.VehicleHealthEnabled = true


/*---------------------------------------------------------------------------
	Exactly how much damage does a vehicle suffer? This is an overall
	multiplier, so 0.3 would make vehicles suffer 3/10 of the damage
	they would normally suffer.
---------------------------------------------------------------------------*/
UBR.Config.VehicleDamageMultiplier = 1


/*---------------------------------------------------------------------------
	Default amount of fuel when it's not set per-car
---------------------------------------------------------------------------*/
UBR.Config.DefaultFuel = 350


/*---------------------------------------------------------------------------
	Should we damage players when they exit a vehicle moving too fast?
---------------------------------------------------------------------------*/
UBR.Config.DamageOnVehicleExit = true


/*---------------------------------------------------------------------------
	Vehicles

	name: The name of the vehicle
	fuel: How large will the car's fuel tank be? Leave out for default fuel.
	color: You can put in a color that the car will always spawn with.
		   Alternatively, put a table and it will pick from random. Leave
		   it empty and it will generate a completely random color.
	rarity: What chance does this car have to spawn in a spot?
			Decimal value from 0-1 (1: always spawns, 0.3: spawns 3/10
			of the time, etc.)
---------------------------------------------------------------------------*/
local someColors = {
	/*Color(26, 188, 156),
	Color(46, 204, 113),
	Color(52, 152, 219),
	Color(155, 89, 182),
	Color(52, 73, 94),
	Color(22, 160, 133),
	Color(39, 174, 96),
	Color(41, 128, 185),
	Color(142, 68, 173),
	Color(44, 62, 80),
	Color(241, 196, 15),
	Color(230, 126, 34),
	Color(231, 76, 60),
	Color(236, 240, 241),
	Color(149, 165, 166),
	Color(243, 156, 18),
	Color(192, 57, 43),
	Color(211, 84, 0),
	Color(189, 195, 199),
	Color(127, 140, 141)*/
}

UBR.AddVehicle({
	name = "BMW 1M",
	rarity = 1,
	color = someColors
})

UBR.AddVehicle({
	name = "BMW 340i",
	rarity = 1,
	color = someColors
})

UBR.AddVehicle({
	name = "BMW M5 E60",
	rarity = 1,
	color = someColors
})

UBR.AddVehicle({
	name = "Toyota MR2 GT",
	rarity = 1,
	color = someColors
})

UBR.AddVehicle({
	name = "Toyota Supra",
	rarity = 1,
	color = someColors
})