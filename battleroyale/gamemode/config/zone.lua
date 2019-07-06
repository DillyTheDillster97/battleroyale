/*---------------------------------------------------------------------------
	Name: Zone Radius
	Description: Radius of the zone in source engine units.
---------------------------------------------------------------------------*/
UBR.Config.ZoneRadius = 20000


/*---------------------------------------------------------------------------
	Name: Zone Move Delay
	Description: The zone will start to move after this many seconds.
---------------------------------------------------------------------------*/
UBR.Config.ZoneMoveDelay = 60


/*---------------------------------------------------------------------------
	Name: Zone Damage Delay
	Description: The zone will start to deal damage after this many seconds.
---------------------------------------------------------------------------*/
UBR.Config.ZoneDamageDelay = 60


/*---------------------------------------------------------------------------
	Name: Zone Steps
	Description: The amount of times that the zone will stop moving.
	Setting this too high will make the game crash, which is understandable
	as you should not be having zones that are 3 inches in diameter at any
	point
---------------------------------------------------------------------------*/
UBR.Config.ZoneSteps = 7


/*---------------------------------------------------------------------------
	Name: Zone Step Time
	Description: The amount of seconds each step lasts for.
---------------------------------------------------------------------------*/
UBR.Config.ZoneStepTime = 60


/*---------------------------------------------------------------------------
	Name: Zone Movement Speed
	Description: How many source units the zone moves per tick.
---------------------------------------------------------------------------*/
UBR.Config.ZoneMovementSpeed = 1


/*---------------------------------------------------------------------------
	Name: Zone Damage Multiplier
	Description: Easy way to change how much damage the zone does overall.
	Set this to 2 and the zone will deal 2x damage, 0.4 and it will deal
	0.4x damage, etc.
---------------------------------------------------------------------------*/
UBR.Config.ZoneDamageMultiplier = 1


/*---------------------------------------------------------------------------
	Name: Zone Color
	Description: Color of the zone, in RGB.
---------------------------------------------------------------------------*/
UBR.Config.ZoneColor = Color(240, 240, 240)