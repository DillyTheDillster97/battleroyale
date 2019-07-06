/*---------------------------------------------------------------------------
	Precaching Models
---------------------------------------------------------------------------*/
util.PrecacheModel("models/freeman/parachute_open.mdl")
util.PrecacheModel("models/freeman/parachute_ground.mdl")


/*---------------------------------------------------------------------------
	Precaching Sounds
---------------------------------------------------------------------------*/
util.PrecacheSound("threebow/plane_loop.wav")

local t = {}
for i=1, 6 do
	local s = "npc/combine_soldier/gear"..i..".wav"
	table.insert(t, s)
	util.PrecacheSound(s)
end


/*---------------------------------------------------------------------------
	Setting up sounds
---------------------------------------------------------------------------*/
sound.Add({
	name = "ParachuteLand",
	channel = CHAN_BODY,
	volume = 1,
	level = 50,
	pitch = {90, 110},
	sound = t
})

sound.Add({
	name = "ParachuteDeploy",
	channel = CHAN_BODY,
	volume = 1,
	level = 75,
	pitch = {105, 110},
	sound = t
})

sound.Add({
	name = "Plane",
	channel = CHAN_STATIC,
	volume = 1,
	level = 140,
	sound = "threebow/plane_loop.wav"
})