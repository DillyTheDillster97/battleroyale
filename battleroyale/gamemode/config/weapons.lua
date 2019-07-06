/*---------------------------------------------------------------------------
	Ammo Models
	
	This is where ammo models are defined. This is NOT the type of ammo
	that guns use. These basically say which guns should use which models
	for their ammo boxes. Supplying text here will allow you to match ammo
	types to models.

	If you only supply one parameter, for example "5.56", it will apply
	the 5.56 ammo box model to all guns whose ammo types have "5.56" in their
	names. Useful for CW.

	If you supply two parameters, for example "ar2" and "7.62", it will
	apply the 7.62 (second parameter) ammo box model to all guns whose 
	ammo types have "ar2" (first parameter) in their name.

	Available ammo models and the guns they usually go with:
		- 5.56 (Rifle)
		- 7.62 (Rifle)
		- 9mm (Pistol/SMG)
		- acp (Pistol/SMG)
		- gauge (Shotgun)

	Example: Applying the shotgun shell ammo model to all guns with 5.56 in
			 their ammo name:
			 UBR.AddAmmoModel("5.56", "gauge")

	Example: Applying the 9mm ammo model to all guns with "ar2" in their
			 ammo name:
			 UBR.AddAmmoModel("ar2", "9mm")

	Example: Applying the 5.56 ammo model to all guns with "5.56" in their
			 ammo name:
			 UBR.AddAmmoModel("5.56")
---------------------------------------------------------------------------*/
UBR.AddAmmoModel("5.56") //matches 5.56x45MM etc.
UBR.AddAmmoModel("7.62") //matches 7.62x51MM, etc.
UBR.AddAmmoModel("9x", "9mm") //matches 9x17MM, 9x19MM, etc.
UBR.AddAmmoModel("acp") //matches .45 ACP
UBR.AddAmmoModel("gauge") //matches 12 Gauge
UBR.AddAmmoModel("lapua", "7.62") //matches .338 Lapua
UBR.AddAmmoModel("357", "acp") //matches .357
UBR.AddAmmoModel("5.45", "5.56") //matches 5.45x39MM
UBR.AddAmmoModel("winchester", "7.62") //matches .30 Winchester
UBR.AddAmmoModel("40", "acp") //matches .40 S&W
UBR.AddAmmoModel("44", "acp") //matches .44 Magnium


/*---------------------------------------------------------------------------
	Name: Ammo Weight
	Description: How much inventory space should each bullet in someone's
				 inventory be worth?
---------------------------------------------------------------------------*/
UBR.Config.AmmoWeight = 1


/*---------------------------------------------------------------------------
	Weapons
	
	This is where weapons are defined.

	Breakdown: UBR.AddWeapon({
		class = "m9k_colt1911",
		ammoCount = {5, 10},
		ammoType = "45acp"
	})

	class: This is the class of the weapon. Find this by locating the
		   weapon in the Q menu, right clicking it, and copying it to
		   clipboard. Examples:
		   	- cw_scarh
			- m9k_colt1911

	ammoCount: This is the amount of ammo boxes that will spawn with a
			   weapon. Entering a value of {1, 5} will randomly select
			   a number between 1 and 5. To have a number which is not
			   random, just put it in instead of both. E.g:
			   	- ammoCount = 3
			   	- ammoCount = {3, 10}
---------------------------------------------------------------------------*/
UBR.AddWeapon({
	class = "cw_m3super90",
	ammoCount = {2, 3},
	ammoModel = "gauge",
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_scarh",
	ammoCount = {2, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_g36c",
	ammoCount = {1, 2},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_g4p_ump45",
	ammoCount = {1, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_mp5",
	ammoCount = {1, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_m1911",
	ammoCount = {1, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_m14",
	ammoCount = {1, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_g4p_glock17",
	ammoCount = {1, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_g4p_xm8",
	ammoCount = {1, 3},
	rarity = 1
})

UBR.AddWeapon({
	class = "cw_ak74",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_ar15",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_fiveseven",
	ammoCount = {3, 3},
	rarity = 0.9
})

UBR.AddWeapon({
	class = "cw_g3a3",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_deagle",
	ammoCount = {2, 3},
	rarity = 0.4
})

UBR.AddWeapon({
	class = "cw_l85a2",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_mac11",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_mr96",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_p99",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_makarov",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_shorty",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_vss",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_g4p_usp40",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_g4p_an94",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_g4p_m98b",
	ammoCount = {2, 3},
	rarity = 0.6
})

UBR.AddWeapon({
	class = "cw_g4p_mp412_rex",
	ammoCount = 2,
	rarity = 0.6
})


/*---------------------------------------------------------------------------
	Airdrop weapons. Same as above except these go in airdrops. No rarity.
---------------------------------------------------------------------------*/
UBR.AddAirdropWeapon({
	class = "cw_m249_official",
	ammoCount = 1
})

UBR.AddAirdropWeapon({
	class = "cw_g4p_awm",
	ammoCount = {1, 2}
})

UBR.AddAirdropWeapon({
	class = "cw_g4p_fn_fal",
	ammoCount = {2, 4}
})

UBR.AddAirdropWeapon({
	class = "cw_g4p_g2contender",
	ammoCount = {4, 6}
})