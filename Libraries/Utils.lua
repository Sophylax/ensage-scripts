--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0

	====================================
	|       Ensage Utility Library     |
	====================================
	
		This library consolidates functions that are often repeated in scripts as well as
		including extra class functions and additional functions.
	
	====================================
	|            How To Use            |
	====================================
		1. Place this script to the Ensage\Scripts\Libs folder
		2. Add 'require("libs.Utils")' to the top of your script, without single quotes.
		
	====================================
	|             Changelog            |
	====================================

		v1.1a:
		 - PlayingGame() now returns false if game is paused.
		 - Fixed SafeCastAbility and CastAbility
		 - Removed errors from class detection

		v1.1:
		 - Fixed Linken's Detection

		v1.0:
		 - Released
		
	====================================
	|               API                |
	====================================

 		----- Globals -----


			-----> Damage Types <-----
			
			DAMAGE_PHYS					-- Physical Damage
			DAMAGE_MAGC					-- Magic Damage
			DAMAGE_PURE					-- Pure Damage
			DAMAGE_COMP					-- Composite Damage
			DAMAGE_HPRM					-- HP Removal Damage
			DAMAGE_UNIV					-- Universal Damage


			-----> Power Treads States <-----

			PT_STR						-- Strength
			PT_INT						-- Intelligence
			PT_AGI						-- Agility


			-----> Linken Block Extras <-----

			LINKEN_MINOR_BLOCK			-- Linkens block a minor part of the spell
			LINKEN_MAJOR_BLOCK			-- Linkens block a major part of the spell



		----- Global Functions -----

			GetDistance2D(a[,b]): Returns the 2D (ignoring height) distance between 2 units, locations or one unit and one location.
				a: First Unit/Location.
				b: Second Unit/Location. If not entered it defaults as "me" value.

			IsKeysDown(keyTable,orCheck): Returns "true" if all the keys in the table is pressed. Returns "true" if any of them is pressed if orCheck is "true"

			IsIngame(): Returns whether player is in a game.

			PlayingGame(): Returns whether player is playing game.


			SleepCheck([id]): Returns "true" if given id is finished sleep period
				id: Identification for a sleep instance. If not entered checks the global sleep instance.

			Sleep(time[,id]): Sleeps given sleep instance for given amount of ms. If sleep instance is sleeping for more than given time already it will not overwrite it.
				time: Amount of time in miliseconds.
				id: Identification for a sleep instance. If not entered sleeps the global sleep instance.


			SetDebugState(): Sets debug state of the script.

			IsDebugActive(): Returns "true" if debug is active.

			DebugPrint(text): Prints a text in a format if debug is active.


			SelectUnit(unit): Selects a given unit and returns the previously selected table.
				unit: Unit that will be selected
			SelectBack(table): Selects back a given table of units.
				table: Table of units which will be selected back. Primary source for this table is "SelectUnit" function





		----- Class Functions -----


			-----> LuaEntity (CDOTA_BaseNPC) Functions <-----

				LuaEntity:Move(x[,y,z]): Selects the unit and gives a Move order then selects back the previous selection
					Possible Parameters:
						--(Vector)
						--(Number,Number,Number)

				LuaEntity:AttackMove(x[,y,z]): Selects the unit and gives a AttackMove order then selects back the previous selection
					Possible Parameters:
						--(Vector)
						--(Number,Number,Number)

				LuaEntity:Attack(unit): Selects the unit and gives a Attack order then selects back the previous selection

				LuaEntity:Follow(unit): Selects the unit and gives a Follow order then selects back the previous selection

				LuaEntity:Stop(): Selects the unit and gives a Stop order then selects back the previous selection

				LuaEntity:FindSpell(spellName): If unit owns an ability with the given name, returns the ability.

				LuaEntity:CastSpell(spellName[,x,y,z]): If units own an ability with the given name; selects unit, uses ability then selects back the previous selection
					Possible Parameters:
						--(String)
						--(String,Vector)
						--(String,LuaEntity)
						--(String,Number,Number,Number)

				LuaEntity:SafeCastSpell(spellName[,x,y,z]): Same as CastSpell, but both spell and unit should be able to cast/be casted and it checks for Linkens Interaction if target is a unit.
					Possible Parameters:
						--(String)
						--(String,Vector)
						--(String,LuaEntity)
						--(String,Number,Number,Number)

				LuaEntity:ToggleSpell(spellName): Same as CastSpell, but for toggle abilities

				LuaEntity:SafeToggleSpell(spellName): Same as SafeCastSpell, but for toggle abilities

				LuaEntity:FindItem(itemName): If unit owns an item with the given name, returns the item.

				LuaEntity:SetPowerTreadsState(state): If unit owns a Power Treads; selects unit, sets its state then selects back the previous selection

				LuaEntity:CastItem(itemName[,x,y,z]): If units own an item with the given name; selects unit, uses item then selects back the previous selection. If the item is Armlet of Mordiggian or Radiance then toggles it instad of using.
					Possible Parameters:
						--(String)
						--(String,Vector)
						--(String,LuaEntity)
						--(String,Number,Number,Number)
				
				LuaEntity:SafeCastItem(itemName[,x,y,z]): Same as CastItem, but both item and unit should be able to cast/be casted and it checks for Linkens Interaction if target is a unit.
					Possible Parameters:
						--(String)
						--(String,Vector)
						--(String,LuaEntity)
						--(String,Number,Number,Number)
				
				LuaEntity:CastAbility(ability[,x,y,z]): Selects unit, uses ability then selects back the previous selection
					Possible Parameters:
						--(CDOTABaseAbility)
						--(CDOTABaseAbility,Vector)
						--(CDOTABaseAbility,LuaEntity)
						--(CDOTABaseAbility,Number,Number,Number)
				
				LuaEntity:SafeCastAbility(itemName[,x,y,z]): Same as CastAbility, but both item and unit should be able to cast/be casted and it checks for Linkens Interaction if target is a unit.
					Possible Parameters:
						--(CDOTABaseAbility)
						--(CDOTABaseAbility,Vector)
						--(CDOTABaseAbility,LuaEntity)
						--(CDOTABaseAbility,Number,Number,Number)
				
				LuaEntity:GetAllSpells(): Returns a table consisting of all of the spells unit owns.
				
				LuaEntity:GetAllItems(): Returns a table consisting of all of the items unit owns.
				
				LuaEntity:IsChanneling(): Returns "true" if unit is channeling a spell/item.
				
				LuaEntity:GetChanneledSpell(): Returns the spell/item the unit channels if there is any.

				LuaEntity:FindRelativeAngle(a): Returns the relative angle of the given unit or location. 0 means unit is facing -+PI means its behind the unit.
					Possible Parameters:
						--(Vector)
						--(Vector2D)
						--(LuaEntity)

				LuaEntity:GetDistance2D(a): Returns the 2D (ignoring height) distance between the unit and given unit or location.
					Possible Parameters:
						--(Vector)
						--(Vector2D)
						--(LuaEntity)
				
				LuaEntity:IsMagicDmgImmune(): Returns true if unit will not affected by from magical damage.
				
				LuaEntity:IsPhysDmgImmune(): Returns true if unit will not affected by from physical damage.
				
				LuaEntity:DoesHaveModifier(modifier): Returns true if unit has the given modifier.
				
				LuaEntity:IsLinkensProtected(): Returns true if unit is being protected by Linken's Sphere
				
				LuaEntity:IsRanged(): Returns true if unit is ranged
				
				LuaEntity:DamageTaken(damage,type,source): Returns the theoretical damage recieved from given parameters.
				
				LuaEntity:ManaBurnDamageTaken(burnAmount,percent,type,source): Returns the theoretical damage recieved by a "ManaBurn" effect hero from given parameters.
				
				LuaEntity:CanDie(): Returns true if unit can die.
				
				LuaEntity:CanReincarnate(): Returns true if unit can reincarnate.
				
				LuaEntity:IsInvul(): Returns true if unit is Invulnerable.
				
				LuaEntity:FindFlag(row): Returns the state of the specified flag from unitState.
				
				LuaEntity:CanMove(): Returns true if the unit can move.
				
				LuaEntity:CanCast(): Returns true if the unit can cast spells.
				
				LuaEntity:CanAttack(): Returns true if the unit can attack.
				
				LuaEntity:CanUseItems(): Returns true if the unit can use items.



			-----> LuaEntity (CDOTABaseAbility) Functions<-----

				LuaEntity:CanBeCasted(): Returns true if the ability can be casted.

				LuaEntity:CanBeBlockedByLinkens(): Returns true if the ability can be blocked by Linken's Shere.

				LuaEntity:IsBeingChanneled(): Returns true if the ability is currently being channeled.

				LuaEntity:GetOwner(): Returns the owner of the ability if there is one.	

]]

--== DO NOT TOUCH BELOW ==--

DAMAGE_PHYS = 0 -- Physical
DAMAGE_MAGC = 1 -- Magic
DAMAGE_PURE = 2 -- Pure
DAMAGE_COMP = 3 -- Composite
DAMAGE_HPRM = 4 -- HP Removal
DAMAGE_UNIV = 5 -- Universal

LINKEN_MINOR_BLOCK = 0 -- Linkens block a minor part of the spell
LINKEN_MAJOR_BLOCK = 1 -- Linkens block a major part of the spell

PT_STR = 0 -- Strength
PT_INT = 1 -- Intelligence
PT_AGI = 2 -- Agility

--== GLOBALS ==--

utils = {}

utils.sleepDB = {}

utils.externalDmgReducs = {
	--Spectre: Dispersion
	{
		modifierName = "modifier_spectre_dispersion",
		type = 1,
		sourceTeam = 0,
		sourceSpellName = "spectre_dispersion",
		reduce = {.1,.14,.18,.22},
	},

	--Kunkka: Ghost Ship
	{
		modifierName = "modifier_kunkka_ghost_ship_damage_absorb",
		type = 1,
		reduce = .5,

	},

	--Templar Assasin: Refraction
	{
		modifierName = "modifier_templar_assassin_refraction_absorb",
		type = 1,
		reduce = 1,
	},

	--Abaddon: Borrowed Time
	{
		modifierName = "modifier_abaddon_borrowed_time",
		type = 1,
		reduce = 2,
	},

	--Treant Protector: Living Armor
	{
		modifierName = "modifier_treant_living_armor",
		type = 0,
		sourceTeam = 1,
		sourceSpellName = "treant_living_armor",
		reduce = {20,40,60,80},
	},

	--Abaddon: Aphotic Shield
	{
		modifierName = "modifier_abaddon_aphotic_shield",
		type = 0,
		sourceTeam = 1,
		sourceSpellName = "abaddon_aphotic_shield",
		reduce = {110,140,170,200},
	},
}

utils.externalDmgAmps = {
	--Shadow Demon: Soul Catcher
	{
		modifierName = "modifier_shadow_demon_soul_catcher",
		sourceTeam = -1,
		amp = {.2,.3,.4,.5},
		sourceSpellName = "shadow_demon_soul_catcher",
		type = DAMAGE_PURE,
	},

	--Chen: Penitence
	{
		modifierName = "modifier_chen_penitence",
		sourceTeam = -1,
		amp = {.08,.16,.24,.32},
		sourceSpellName = "chen_penitence",
		type = DAMAGE_PHYS,
	},

	--Slardar: Sprint
	{
		modifierName = "modifier_slardar_sprint",
		amp = .15,
		type = -1,
	},

	--Mask of Madness: Berserk
	{
		modifierName = "modifier_item_mask_of_madness_berserk",
		amp = .3,
		type = -1,
	},

	--Orchid Malevolence: Soul Burn
	{
		modifierName = "modifier_orchid_malevolence_debuff",
		amp = .3,
		type = DAMAGE_MAGC,
	},
}

utils.damageBlocks = {
	--Tidehunter: Kraken Shell
	{
		modifier = "modifier_tidehunter_kraken_shell",
		meleeBlock = {7,14,21,28},
		rangedBlock = {7,14,21,28},
		abilityName = "tidehunter_kraken_shell",
	},

	--Poor Man's Shield: Damage Block
	{
		modifier = "modifier_item_poor_mans_shield",
		meleeBlock = 20,
		rangedBlock = 10,
	},

	--Vanguard: Damage Block
	{
		modifier = "modifier_item_vanguard",
		meleeBlock = 40,
		rangedBlock = 20,
	},

	--Stout Shield: Damage Block
	{
		modifier = "modifier_item_stout_shield",
		meleeBlock = 20,
		rangedBlock = 10,
	},
}

--Table containing spellnames that are blocked by Linken's Sphere
utils.linkenBlocks = {
	--Alchemist: Unstable Concoction Throw
	alchemist_unstable_concoction_throw = true,
	--Ancient Appariton: Cold Feet
	ancient_apparition_cold_feet = true,
	--Anti-Mage: Mana Void
	antimage_mana_void = true,
	--Axe: Battle Hunger
	axe_battle_hunger = true,
	--Axe: Culling Blade
	axe_culling_blade = 0,
	--Bane: Enfeeble
	bane_enfeeble = true,
	--Bane: Brain Sap
	bane_brain_sap = true,
	--Bane: Nightmare
	bane_nightmare = true,
	--Bane: Fiend's Grip
	bane_fiends_grip = true,
	--Batrider: Flaming Lasso
	batrider_flaming_lasso = true,
	--Beastmaster: Primal Roar
	beastmaster_primal_roar = true,
	--Bloodseeker: Bloodrage
	bloodseeker_bloodrage = true,
	--Bloodseeker: Rupture
	bloodseeker_rupture = true,
	--Bounty Hunter: Shuriken Toss
	bounty_hunter_shuriken_toss = true,
	--Bounty Hunter: Track
	bounty_hunter_track = true,
	--Brewmaster: Drunken Haze
	brewmaster_drunken_haze = true,
	--Brewmaster: Earth: Hurl Boulder
	brewmaster_earth_hurl_boulder = true,
	--Brewmaster: Storm: Cyclone
	brewmaster_storm_cyclone = true,
	--Broodmother: Spawn Spiderlings
	broodmother_spawn_spiderlings = true,
	--Chaos Knight: Chaos Bolt
	chaos_knight_chaos_bolt = true,
	--Chaos Knight: Reality Rift
	chaos_knight_reality_rift = true,
	--Chen: Penitence
	chen_penitence = true,
	--Chen: Test of Faith
	chen_test_of_faith = true,
	--Crystal Maiden: Frostbite
	crystal_maiden_frostbite = true,
	--Dazzle: Poison Touch
	dazzle_poison_touch = true,
	--Distuptor: Thunder Strike
	disruptor_thunder_strike = true,
	--Distuptor: Glimpse
	disruptor_glimpse = true,
	--Doom: LVL? Death
	doom_bringer_lvl_death = true,
	--Doom: Doom
	doom_bringer_doom = true,
	--Dragon Knight: Dragon Tail
	dragon_knight_dragon_tail = true,
	--Earthshaker: Fissure
	earthshaker_fissure = true,
	--Enchantress: Enchant
	enchantress_enchant = true,
	--Enigma: Malefice
	enigma_malefice = true,
	--Gyrocopter: Homing Missile
	gyrocopter_homing_missile = true,
	--Huskar: Life Break
	huskar_life_break = true,
	--Invoker: Cold Snap
	invoker_cold_snap = true,
	--Juggernaut: Omnislash
	juggernaut_omni_slash = 0,
	--Keeper of the Light: Mana Leak
	keeper_of_the_light_mana_leak = true,
	--Keeper of the Light: Blinding Light
	keeper_of_the_light_blinding_light = 1;
	--Kunkka: X Marks the Spot
	kunkka_x_marks_the_spot = true,
	--Leshrac: Lightning Storm
	leshrac_lightning_storm = true,
	--Lich: Frost Nova
	lich_frost_nova = ture,
	--Lich: Chain Frost
	lich_chain_frost = 0,
	--Lifestealer: Open Wounds
	life_stealer_open_wounds = true,
	--Lina: Laguna Blade
	lina_laguna_blade = true,
	--Lion: Earth Spike
	lion_impale = true,
	--Lion: Hex
	lion_voodoo = true,
	--Lion: Mana Drain
	lion_mana_drain = true,
	--Lion: Finger of Death
	lion_finger_of_death = true,
	--Luna: Lucent Beam
	luna_lucent_beam = true,
	--Morphling: Adaptive Strike
	morphling_adaptive_strike = true,
	--Morphling: Replicate
	morphling_morph_replicate = true,
	--Naga Siren: Ensnare
	naga_siren_ensnare = true,
	--Nature's Prophet: Sprout
	furion_sprout = ture,
	--Nature's Prophet: Wrath of Nature
	furion_wrath_of_nature = true,
	--Necrolyte: Reaper's Scythe
	necrolyte_reapers_scythe = true,
	--Nightstalker: Void
	night_stalker_void = true,
	--Nightstalker: Crippling Fear
	night_stalker_crippling_fear = true,
	--Nyx Assassin: Impale
	nyx_assassin_impale = true,
	--Nyx Assassin: Mana Burn
	nyx_assassin_mana_burn = true,
	--Ogre Magi: Fireblast
	ogre_magi_fireblast = true,
	--Ogre Magi: Ignite
	ogre_magi_ignite = true,
	--Ogre Magi: Unrefined Fireblast
	ogre_magi_unrefined_fireblast = true,
	--Outworld Devourer: Astral Imprisonment
	obsidian_destroyer_astral_imprisonment = true,
	--Phantom Assassin: Stifling Dagger
	phantom_assassin_stifling_dagger = true,
	--Phantom Assassin: Phantom Strike
	phantom_assassin_phantom_strike = true,
	--Phantom Lancer: Spirit Lance
	phantom_lancer_spirit_lance = true,
	--Pugna: Decrepify
	pugna_decrepify = true,
	--Pugna: Nether Ward
	pugna_nether_ward = 0,
	--Pugna: Life Drain
	pugna_life_drain = true,
	--Queen of Pain: Shadow Strike
	queenofpain_shadow_strike = true,
	--Rubick: Telekinesis
	rubick_telekinesis = true,
	--Rubick: Fade Bolt
	rubick_fade_bolt = true,
	--Rubick: Spell Steal
	rubick_spell_steal = true,
	--Sand King: Burrowstrike
	sandking_burrowstrike = true,
	--Shadow Demon: Disruption
	shadow_demon_disruption = true,
	--Shadow Demon: Demonic Purge
	shadow_demon_demonic_purge = true,
	--Shadow Shaman: Hex
	shadow_shaman_voodoo = true,
	--Shadow Shaman: Shackles
	shadow_shaman_shackles = true,
	--Silencer: Last Word
	silencer_last_word = true,
	--Skeleton King: Hellfire Blast
	skeleton_king_hellfire_blast = true,
	--Skeleton King: Mortal Strike
	skeleton_king_mortal_strike = true,
	--Slardar: Amplify Damage
	slardar_amplify_damage = true,
	--Sniper: Assassinate
	sniper_assassinate = true,
	--Spirit Breaker: Charge of Darkness
	spirit_breaker_charge_of_darkness = true,
	--Spirit Breaker: Nether Strike
	spirit_breaker_nether_strike = true,
	--Storm Spirit: Electric Vortex
	storm_spirit_electric_vortex = true,
	--Sven: Storm Hammer
	sven_storm_bolt = true,
	--Tidehunter: Gush
	tidehunter_gush = true,
	--Tinker: Laser
	tinker_laser = true,
	--Treant Protector: Leech Seed
	treant_leech_seed = true,
	--Undying: Soul Rip
	undying_soul_rip = true,
	--Vengeful Spirit: Magic Missile
	vengefulspirit_magic_missile = true,
	--Vengeful Spirit: Nether Swap
	vengefulspirit_nether_swap = true,
	--Viper: Viper Strike
	viper_viper_strike = true,
	--Visage: Grave Chill
	visage_grave_chill = true,
	--Visage: Soul Assumption
	visage_soul_assumption = true,
	--Warlock: Fatal Bonds
	warlock_fatal_bonds = true,
	--Warlock: Shadow Word
	warlock_shadow_word = true,
	--Windrunner: Shackleshot
	windrunner_shackleshot = 1,
	--Windrunner: Focus Fire
	windrunner_focusfire = true,
	--Witch Doctor: Paralyzing Cask
	witch_doctor_paralyzing_cask = true,
	--Zeus: Arc Lightning
	zuus_lightning_bolt = true,
	--Zeus: Lightning Bolt
	zuus_arc_lightning = true,

	--Abyssal Blade
	item_abyssal_blade = true,
	--Dagon
	item_dagon = true,
	item_dagon_2 = true,
	item_dagon_3 = true,
	item_dagon_4 = true,
	item_dagon_5 = true,
	--Diffusal Blade
	item_diffusal_blade = true,
	item_diffusal_blade_2 = true,
	--Ethereal Blade
	item_ethereal_blade = true,
	--Eul's Scepter of Divinity
	item_cyclone = true,
	--Force Staff
	item_force_staff = true,
	--Heaven's Halberd
	item_heavens_halberd = true,
	--Necronomicon: Archer: Mana Burn
	necronomicon_archer_mana_burn = true,
	--Orchid Malevolence
	item_orchid = true,
	--Rod of Atos
	item_rod_of_atos = true,
	--Scythe of Vyse
	item_sheepstick = true,

	--Harpy Storm: Chain Lightning
	harpy_storm_chain_lightning = true,
	--Satyr Soulstealer: Mana Burn
	satyr_soulstealer_mana_burn = true,
	--Satyr Trickster: Purge
	satyr_trickster_purge = true,
}

utils.immunity = {}

--Modifiers that grant Physical Damage Immunity
utils.immunity.phys = {
	--Omniknight: Guardian Angel
	modifier_omninight_guardian_angel
	--Winter Wyvern: Cold Embrace
	-- PLACE HOLDER --
}


--Modifiers that grant Magical Damage Immunity
utils.immunity.magic = {
	--Medusa: Stone Gaze Petrify
	modifier_medusa_stone_gaze_stone = true,
}

--Modifiers that cause hero to be hidden
utils.hiddenModifiers = {
	--Brewmaster: Primal Split
	modifier_brewmaster_primal_split = true,
	modifier_brewmaster_primal_split_delay = true,
	--Juggernaut: Omnislash
	modifier_juggernaut_omnislash = true,
	--Puck: Phase Shift
	modifier_puck_phase_shift = true,
	--Lifestealer: Infest
	modifier_life_stealer_infest = true,
	--Phoenix: Supernova
	-- PLACE HOLDER --
	--Ember Spirit: Sleight of Fist
	-- PLACE HOLDER --
	--Outworld Devourer: Astral Imprisonment
	modifier_obsidian_destroyer_astral_imprisonment_prison = true,
	--Shadow Demon: Disruption
	modifier_shadow_demon_disruption = true,
}

--Modifiers that cause hero to be invul
utils.invulModifiers = {
	--Generic Invulnerable
	modifier_invulnerable = true,
	--Brewmaster: Storm: Cyclone
	modifier_brewmaster_storm_cyclone = true,
	--Eul: Cyclone
	modifier_cyclone = true,
	--Invoker: Tornado
	modifier_invoker_tornado,
	--Bane: Nightmare
	modifier_bane_nightmare_invulnerable = true,
	--Faceless Void: Time Walk
	modifier_faceless_void_time_walk = true,
	--Storm Spirit: Ball Lightning
	modifier_storm_spirit_ball_lightning = true,
	--Morphling: Waveform
	modifier_morphling_waveform = true,
	--Tusk: Snowball
	modifier_tusk_snowball_movement = true,
	modifier_tusk_snowball_movement_friendly = true,
	--Naga Siren: Mirror Image
	modifier_naga_siren_mirror_image = true,
	--Chaos Knight: Phantasm
	modifier_chaos_knight_phantasm = true,
	--Manta Style: Mirror Image
	modifier_manta_phase = true,
}

--== GLOBAL FUNCTIONS ==--

--Returns the 2D distance (ignoring height) between 2 units.
--	Returns distance between unit and user's hero if only one unit is given.
function GetDistance2D(a,b)
	assert(GetType(a) == "LuaEntity" or GetType(a) == "Vector" or GetType(a) == "Vector2D", debug.getinfo(1, "n").name..": Invalid First Parameter")
	assert(GetType(b) == "LuaEntity" or GetType(b) == "Vector" or GetType(b) == "Vector2D" or GetType(b) == "nil", debug.getinfo(1, "n").name..": Invalid Second Parameter")
	if not b then b = me end
	return math.sqrt(math.pow(a.x-b.x,2)+math.pow(a.y-b.y,2))
end

--Returns the base class of an obj
function GetType(obj)
	if obj then
		if type(obj.IsZero) == "function" then
			if type(obj.z) == "number" then
				return "Vector"
			else
				return "Vector2D"
			end
		elseif type(obj.SetPosition) == "function" then
			if type(obj.SetParameter) == "function" then
				return "LuaEffect"
			else
				return "DrawObject"
			end
		elseif type(obj.rotR) == "number" then
			return "LuaEntity"
		elseif type(obj.Unload) == "function" then
			return "script"
		elseif type(obj.IsLoaded) == "function" then
			return "scriptEngine"
		elseif type(obj.DrawText) == "function" then
			return "drawManager"
		elseif type(obj.FindEntities) == "function" then
			return "entityList"
		elseif type(obj.GetType) == "function" then
			return obj:GetType()
		end
	else
		return type(obj)
	end
end

--Returns true if all of the keys are down
-- Returns true if one of the key is down if the orCheck value is true
function IsKeysDown(key_table,orCheck)
	assert(GetType(key_table) == "table", debug.getinfo(1, "n").name..": Invalid Key Table")
	if not orCheck then orCheck = false end
    for i,v in ipairs(key_table) do
        if not IsKeyDown(v) or (IsKeyDown(v) and orCheck) then
                return IsKeyDown(v)
    	end
    end
    return not orCheck
end

	--Game State--

--Returns whether client is ingame.
function IsIngame()
	return engineClient.ingame and not engineClient.console
end

--Returns if user is playing the game.
function PlayingGame()
	return IsIngame() and me and not IsGamePaused()
end

    --Debug Engine--

--Sets debug state for IsDebugActive checks and DebugPrint.
function SetDebugState(state)
	assert(type(state) == "boolean", debug.getinfo(1, "n").name..": Invalid State")
	utils.debugState = state
end

--Returns the debug state.
function IsDebugActive()
	return utils.debugState
end

--Prints a debug message in a format:
--	[SCRIPTNAME] YourMessage
function DebugPrint(text)
	assert(type(tostring(text)) == "string", debug.getinfo(1, "n").name..": Invalid Text")
	if IsDebugActive() then
		print("["..script.name.."] "..tostring(text))
	end
end

   --Sleep Engine--

--Returns the sleeping status of the sleep engine with the given id (not entering id will return the state of the global sleep engine).
function SleepCheck(id)
	if id then
		return not utils.sleepDB[id] or GetTick() > utils.sleepDB[id]
	else
		return not utils.sleepTick or GetTick() > utils.sleepTick
	end
end

--Sleeps the sleeping engine with the given id for given ms (not entering id will sleep the global sleep engine).
--	If engine is already sleeping for more than the given time it will ignore it.
function Sleep(ms,id)
	if id then
		if not utils.sleepDB[id] or utils.sleepDB[id] < GetTick() + ms then
			utils.sleepDB[id] = GetTick() + ms
		end
	else
		if not utils.sleepTick or utils.sleepTick < GetTick() + ms then
			utils.sleepTick = GetTick() + ms
		end
	end
end

    --Selection Engine--

--Selects given unit if it is not the only unit selected, returns the previous selected unit as a table for the "SelectBack" function.
function SelectUnit(unit)
	if not unit then
		unit = me
	end
	assert(GetType(unit) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Unit")
	local _prevSelect = {}
	local selection = entityList:GetSelection()
	if selection and selection[1] and selection[1].handle ~= unit.handle or #selection ~= 1 then
		_prevSelect = selection
		Select(unit)
	end
	return _prevSelect
end

--Selects given table of units if there is any. Primary source for the table should be the "SelectUnit" function.
function SelectBack(units)
	assert(type(units) == "table", debug.getinfo(1, "n").name..": Invalid Unit Table")
	if #units > 0 then
		for i,v in ipairs(units) do
			if v.alive and v.visible then
				if i == 1 then
					Select(v)
				else
					SelectAdd(v)
				end
			end
		end
	end
end

--== LUAENTITY (CDOTA_BaseNPC) FUNCTIONS ==--

--Selects LuaEntity, Gives a Move command and Selects back the previous selection.
function LuaEntity:Move(x,y,z)
	if x and y and z then
		assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
		local prev = SelectUnit(self)
		Move(x,y,z)
		SelectBack(prev)
	elseif x then
		assert(GetType(x) == "Vector", debug.getinfo(1, "n").name..": Invalid Vector")
		local prev = SelectUnit(self)
		Move(x)
		SelectBack(prev)
	end
end

--Selects LuaEntity, Gives an AttackMove command it and Selects back the previous selection.
function LuaEntity:AttackMove(x,y,z)
	if x and y and z then
		assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
		local prev = SelectUnit(self)
		AttackMove(x,y,z)
		SelectBack(prev)
	elseif x then
		assert(GetType(x) == "Vector", debug.getinfo(1, "n").name..": Invalid Vector")
		local prev = SelectUnit(self)
		AttackMove(x)
		SelectBack(prev)
	end
end

--Selects LuaEntity, Gives an Attack command it and Selects back the previous selection.
function LuaEntity:Attack(unit)
	assert(GetType(unit) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Unit")
	local prev = SelectUnit(self)
	Attack(unit)
	SelectBack(prev)
end

--Selects LuaEntity, Gives an Follow command it and Selects back the previous selection.
function LuaEntity:Follow(unit)
	assert(GetType(unit) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Unit")
	local prev = SelectUnit(self)
	Follow(unit)
	SelectBack(prev)
end

--Selects LuaEntity, Gives an Stop command it and Selects back the previous selection.
function LuaEntity:Stop()
	local prev = SelectUnit(self)
	Stop()
	SelectBack(prev)
end


--Searchs the LuaEntity's spells for a spell with given name and returns it if there is any.
function LuaEntity:FindSpell(spellName)
	assert(type(spellName) == "string", debug and debug.getinfo(1, "n") and debug.getinfo(1, "n").name and debug.getinfo(1, "n").name..": Invalid Spell Name")
	local i = 1
	if self then
		local spell = self:GetAbility(i)
		while spell and spell.name and i < 16 do
			if spell.name == spellName then
				return spell
			end
			spell = self:GetAbility(i)
			i = i + 1
		end
	end
end

--Returns a table consisting of all the spells of the LuaEntity.
function LuaEntity:GetAllSpells()
	local i = 1
	local spTable = {}
	if self then
		local spell = self:GetAbility(i)
		while i < 16 do
			if spell then
				spTable[#spTable + 1] = spell
			end
			i = i + 1
			spell = self:GetAbility(i)
		end
	end
	return spTable
end

--Finds the spell with given name; If there is one selects LuaEntity, casts it and selects back the previous selection.
--	Returns true if cast order is given.
function LuaEntity:CastSpell(spellName,x,y,z)
	assert(type(spellName) == "string", debug.getinfo(1, "n").name..": Invalid Spell Name")
	local spell = self:FindSpell(spellName)
	if spell then
		local prev = SelectUnit(self)
		if not x and not y and not z then
			self:UseAbility(spell)
		elseif not y and not z then
			assert(GetType(x) == "Vector" or GetType(x) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid parameters")
			self:UseAbility(spell,x)
		else
			assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
			self:UseAbility(spell,x,y,z)
		end
		SelectBack(prev)
		return true
	end
end

--Finds the spell with given name; If there is one selects LuaEntity, toggles it and selects back the previous selection.
--	Returns true if toggle order is given.
function LuaEntity:ToggleSpell(spellName)
	assert(type(spellName) == "string", debug.getinfo(1, "n").name..": Invalid Spell Name")
	local spell = self:FindSpell(spellName)
	if spell then
		local prev = SelectUnit(self)
		self:ToggleAbility(spell)
		SelectBack(prev)
		return true
	end
end

--Finds the spell with given name; If there is one selects LuaEntity, casts it and selects back the previous selection.
--	Checks both hero's state and spells state to cast successfully
--	Returns true if cast order is "successfully" given.
function LuaEntity:SafeCastSpell(spellName,x,y,z)
	assert(type(spellName) == "string", debug.getinfo(1, "n").name..": Invalid Spell Name")
	local spell = self:FindSpell(spellName)
	print(x and x.IsLinkensProtected and x:IsLinkensProtected() and spell:CanBeBlockedByLinkens() == true)
	if spell and spell:CanBeCasted() and self:CanCast() and not (x and x.IsLinkensProtected and x:IsLinkensProtected() and spell:CanBeBlockedByLinkens() == true) then
		local prev = SelectUnit(self)
		if not x and not y and not z then
			self:UseAbility(spell)
		elseif not y and not z then
			assert(GetType(x) == "Vector" or GetType(x) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid parameters")
			self:UseAbility(spell,x)
		else
			assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
			self:UseAbility(spell,x,y,z)
		end
		SelectBack(prev)
		return true
	end
end

--Finds the spell with given name; If there is one selects LuaEntity, toggles it and selects back the previous selection.
--	Checks both hero's state and spells state to cast successfully
--	Returns true if toggle order is "successfully" given.
function LuaEntity:SafeToggleSpell(spellName)
	assert(type(spellName) == "string", debug.getinfo(1, "n").name..": Invalid Spell Name")
	local spell = self:FindSpell(spellName)
	if spell and spell:CanBeCasted() and self:CanCast() then
		local prev = SelectUnit(self)
		self:ToggleAbility(spell)
		SelectBack(prev)
		return true
	end
end

--Searchs the LuaEntity's inventory for an item with given name and returns it if there is any.
function LuaEntity:FindItem(itemName)
	assert(type(itemName) == "string", debug.getinfo(1, "n").name..": Invalid Item Name")
	local i = 1
	if self then
		while i < 7 do
			if self:HasItem(i) and self:GetItem(i).name == itemName then
				return self:GetItem(i)
			end
			i = i + 1
		end
	end
end

--Returns a table consisting of all the items of the LuaEntity.
function LuaEntity:GetAllItems()
	local i = 1
	local iTable = {}
	if self then
		while i < 7 do
			if self:HasItem(i) then
				iTable[#iTable + 1] =  self:GetItem(i)
			end
			i = i + 1
		end
	end
	return iTable
end

--Sets the LuaEntity's power treads (if there is) to given state
--	Look to the globals for possible states
function LuaEntity:SetPowerTreadsState(state)
	assert(state == PT_AGI or state == PT_STR or state == PT_INT, debug.getinfo(1, "n").name..": Invalid State")
	local pt = self:FindItem("item_power_treads")
	if pt then
		local prev = SelectUnit(self)
		for i = 1, (state - pt.bootsState) % 3 do
			self:UseItem(pt)
		end
		SelectBack(prev)
	end
end

--Finds the spell with given name; If there is one selects LuaEntity, casts it and selects back the previous selection.
--	If the item is Armlet of Mordiggian or Radiance then toggles it.
--	Returns true if cast order is given.
function LuaEntity:CastItem(itemName,x,y,z)
	assert(type(itemName) == "string", debug.getinfo(1, "n").name..": Invalid Item Name")
	local item = self:FindItem(itemName)
	if item then
		local prev = SelectUnit(self)
		if item.classId == CDOTA_Item_Armlet or item.classId == CDOTA_Item_Radiance then
			self:ToggleItem(item)
		elseif not x and not y and not z then
			self:UseItem(item)
		elseif not y and not z then
			assert(GetType(x) == "Vector" or GetType(x) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid parameters")
			self:UseItem(item,x)
		else
			assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
			self:UseItem(item,x,y,z)
		end
		SelectBack(prev)
		return true
	end
end

--Finds the spell with given name; If there is one selects LuaEntity, casts it and selects back the previous selection.
--	If the item is Armlet of Mordiggian or Radiance then toggles it.
--	Checks both hero's state and item state to cast successfully
--	Returns true if cast order is "successfully" given.
function LuaEntity:SafeCastItem(itemName,x,y,z)
	assert(type(itemName) == "string", debug.getinfo(1, "n").name..": Invalid Item Name")
	local item = self:FindItem(itemName)
	if item and item:CanBeCasted() and self:CanUseItems() and not (x and x.IsLinkensProtected and x:IsLinkensProtected() and spell:CanBeBlockedByLinkens() == true) then
		local prev = SelectUnit(self)
		if item.classId == CDOTA_Item_Armlet or item.classId == CDOTA_Item_Radiance then
			self:ToggleItem(item)
		elseif not x and not y and not z then
			self:UseItem(item)
		elseif not y and not z then
			assert(GetType(x) == "Vector" or GetType(x) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid parameters")
			self:UseItem(item,x)
		else
			assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
			self:UseItem(item,x,y,z)
		end
		SelectBack(prev)
		return true
	end
end

--Selects LuaEntity, casts ability and selects back the previous selection.
--	Returns true if cast order is given.
function LuaEntity:CastAbility(ability,x,y,z)
	assert(GetType(ability) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Ability")
	if ability then
		local prev = SelectUnit(self)
		if not x and not y and not z then
			self:UseAbility(ability)
		elseif not y and not z then
			assert(GetType(x) == "Vector" or GetType(x) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid parameters")
			self:UseAbility(ability,x)
		else
			assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
			self:UseAbility(ability,x,y,z)
		end
		SelectBack(prev)
		return true
	end
end


--Selects LuaEntity, casts ability and selects back the previous selection.
--	Returns true if cast order is given.
--	Checks both hero's state and item state to cast successfully
function LuaEntity:SafeCastAbility(ability,x,y,z)
	assert(GetType(ability) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Ability")
	if ability and ability:CanBeCasted() and self:CanCast() and not (x and x.IsLinkensProtected and x:IsLinkensProtected() and ability:CanBeBlockedByLinkens() == true) then
		local prev = SelectUnit(self)
		if not x and not y and not z then
			self:UseAbility(ability)
		elseif not y and not z then
			assert(GetType(x) == "Vector" or GetType(x) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid parameters")
			self:UseAbility(ability,x)
		else
			assert(type(x) == "number" and type(y) == "number" and type(z) == "number", debug.getinfo(1, "n").name..": Invalid Coordinates")
			self:UseAbility(ability,x,y,z)
		end
		SelectBack(prev)
		return true
	end
end

--Returns if LuaEntity is currently channeling an ability.
function LuaEntity:IsChanneling()
	local items = self:GetAllItems()
	local spells = self:GetAllSpells()
	for i,v in ipairs(items) do
		if v:IsBeingChanneled() then
			return true
		end
	end
	for i,v in ipairs(spells) do
		if v:IsBeingChanneled() then
			return true
		end
	end
	return false
end

--Returns the LuaEntity of the spell if LuaEntity is currently channeling an ability.
function LuaEntity:GetChanneledSpell()
	local items = self:GetAllItems()
	local spells = self:GetAllSpells()
	for i,v in ipairs(items) do
		if v:IsBeingChanneled() then
			return v
		end
	end
	for i,v in ipairs(spells) do
		if v:IsBeingChanneled() then
			return v
		end
	end
end

--Returns the distance between LuaEntity and the given unit/position.
function LuaEntity:GetDistance2D(a)
	assert(GetType(a) == "Vector" or GetType(a) == "LuaEntity" or GetType(a) == "Vector2D", debug.getinfo(1, "n").name..": Invalid Parameter")
	return math.sqrt(math.pow(a.x-self.x,2)+math.pow(a.y-self.y,2))
end

--Returns if LuaEntity is immune to Magic damage.
function LuaEntity:IsMagicDmgImmune()
	if self.magicImmune then
		return true
	else
		for i,v in ipairs(utils.immunity.magic) do
			if self:DoesHaveModifier(v) then
				return true
			end
		end
	end
	return false
end

--Returns if LuaEntity is immune to Physical damage.
function LuaEntity:IsPhysDmgImmune()
	if self.ghost then
		return true
	else
		for i,v in ipairs(utils.immunity.phys) do
			if self:DoesHaveModifier(v) then
				return true
			end
		end
	end
	return false
end

--Returns whether LuaEntity has the particular modifier.
function LuaEntity:DoesHaveModifier(name)
	assert(type(name) == "string", debug.getinfo(1, "n").name..": Invalid Modifier Name")
	if self.modifierCount then
		for i=1,self.modifierCount do
			if self:GetModifierName(i) == name then
				return true
			end
		end
	end
	return false
end

--Returns if LuaEntity is protected by Linken's Sphere
function LuaEntity:IsLinkensProtected()
	local linken = self:FindItem("item_sphere")
	return linken and linken.cd == 0
end

--Returns if LuaEntity is ranged
function LuaEntity:IsRanged()
	return self.attackRange > 128 and self.name ~= "Tiny"
end

--Returns if LuaEntity can die from the next instance of Damage
function LuaEntity:CanDie()
	if self:CanReincarnate() then
		return false
	end
	if self:DoesHaveModifier("modifier_dazzle_shallow_grave") then
		return false
	end
	return true
end

--Returns if LuaEntity can reincarnate after dying.
function LuaEntity:CanReincarnate()
	local aegis = self:FindItem("item_aegis")
	if aegis then
		return true
	end
	local reincarnation = self:FindSpell("skeleton_king_reincarnation")
	if reincarnation then
		return true
	end
	return false
end

--Returns damage LuaEntity takes from a manaburn attack
function LuaEntity:ManaBurnDamageTaken(burnAmount,percent,dmgType,source)
	assert(type(burnAmount) == "number", debug.getinfo(1, "n").name..": Invalid Burned Mana")
	assert(GetType(source) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Source")
	assert(dmgType == 0 or dmgType == 1 or dmgType == 2 or dmgType == 3 or dmgType == 4 or dmgType == 5, debug.getinfo(1, "n").name..": Invalid Damage Type")
	assert(type(percent) == "number", debug.getinfo(1, "n").name..": Invalid Damage Percent")
	local tempBurn =  burnAmount
	if self.mana < tempBurn then tempBurn = self.mana end
	return self:DamageTaken(tempBurn*percent,dmgType,source)
end

--Returns the damage LuaEntity takes
function LuaEntity:DamageTaken(dmg,dmgType,source)
	assert(type(dmg) == "number", ": Invalid Damage")
	assert(dmgType == 0 or dmgType == 1 or dmgType == 2 or dmgType == 3 or dmgType == 4 or dmgType == 5, ": Invalid Damage Type")
	assert(GetType(source) == "LuaEntity", debug.getinfo(1, "n").name..": Invalid Source")
	local tempDmg = dmg

	--Physical Damage Calculation
	if dmgType == DAMAGE_PHYS then
		if self:IsPhysDmgImmune() or self:IsInvul() then
			tempDmg = 0
		else
			for i,v in ipairs(utils.damageBlocks) do
				if self:DoesHaveModifier(v.modifierName) then
					local block
					if self:IsRanged() then
						block = v.rangedBlock
					else
						block = v.meleeBlock
					end
					if type(block) ~= "number" then
						tempDmg = tempDmg - block
					else
						temmpDmg = tempDmg - block[self:FindSpell(v.abilityName).level]
					end
					break
				end
			end
			tempDmg = tempDmg*(1 - self.dmgResist)
		end

	--Magical Damage Calculation
	elseif dmgType == DAMAGE_MAGC then
		if self:IsMagicDmgImmune() or self:IsInvul() then
			tempDmg = 0
		else
			tempDmg = tempDmg*(1 - self.magicDmgResist)
		end

	--Pure Damage Calculation
	elseif dmgType == DAMAGE_PURE then
		if self.magicImmune or self:IsInvul() then
			tempDmg = 0
		end

	--Composite Damage Calculation
	elseif dmgType == DAMAGE_COMP then
		if self:IsPhysDmgImmune() or self:IsInvul() then
			tempDmg = 0
		else
			for i,v in ipairs(utils.damageBlocks) do
				if self:DoesHaveModifier(v.modifierName) then
					local block
					if self:IsRanged() then
						block = v.rangedBlock
					else
						block = v.meleeBlock
					end
					if type(block) ~= "number" then
						tempDmg = tempDmg - block
					else
						temmpDmg = tempDmg - block[self:FindSpell(v.abilityName).level]
					end
					break
				end
			end
			tempDmg = tempDmg*(1 - self.dmgResist)*(1 - self.magicDmgResist)
		end

	--Universal Damage Calculation
	elseif dmgType == DAMAGE_UNIV then
		if (self:IsMagicDmgImmune() and not self.magicImmune) or self:IsInvul() then
			tempDmg = 0
		else
			tempDmg = tempDmg*(1 - self.magicDmgResist)
		end
	end

	--External Amplification and Reduction Calculation
	--	HP removal cannot be reduced or amplified
	if dmgType ~= DAMAGE_HPRM then

		--External Amplify
		for i,v in ipairs(utils.externalDmgAmps) do
			if self:DoesHaveModifier(v.modifierName) then
				local amp = v.amp
				if type(amp) == "table" then
					if v.sourceTeam == -1 then
						for k,l in pairs(entityList:FindEntities({type = TYPE_HERO, team = TEAM_ENEMY})) do
							if not k.illusion then
								local spell = k:FindSpell(v.sourceSpellName)
								if spell then
									amp = amp[spell.level]
									break
								end
							end
						end
					end
				end
				if v.type == -1 then
					tempDmg = tempDmg * (1 + amp)
				elseif v.type == DAMAGE_PURE then
					if not self.magicImmune and not self:IsInvul() then
						tempDmg = tempDmg * (1 + amp)
					end
				elseif v.type == DAMAGE_PHYS then
					local tempAmp = tempDmg * amp
					if not self:IsPhysDmgImmune() and not self:IsInvul() then
						for i,v in ipairs(utils.damageBlocks) do
							if self:DoesHaveModifier(v.modifierName) then
								local block
								if self:IsRanged() then
									block = v.rangedBlock
								else
									block = v.meleeBlock
								end
								if type(block) ~= "number" then
									tempAmp = tempAmp - block
								else
									tempAmp = tempAmp - block[self:FindSpell(v.abilityName).level]
								end
								break
							end
						end
						tempDmg = tempDmg + tempAmp* (1 - self.dmgResist)
					end
				elseif v.type == DAMAGE_MAGC then
					if not self:IsMagicDmgImmune() and not self:IsInvul() then
						tempDmg = tempDmg + temp * amp * (1 - self.magicDmgResist)
					end
				end
			end
		end

		--Exception External Amplify: Undying: Flesh Golem: Plauge
		if self:DoesHaveModifier("modifier_undying_flesh_golem_plague_aura") then
			for k,l in pairs(entityList:FindEntities({type = TYPE_HERO, team = TEAM_ENEMY})) do
				if not k.illusion then
					local spell = k:FindSpell(v.sourceSpellName)
					if spell then
						local baseAmp = .05 * spell.level
						if v:FindItem("item_ultimate_scepter") then
							baseAmp = baseAmp + .05
						end
						local distantce = self:GetDistance2D(v)
						if distance <= 200 then
							amp = baseAmp + 0.15
						elseif distance > 750 then
							amp = baseAmp
						else
							amp = baseAmp + (750 - distance)*0.03/110
						end
						tempDmg = tempDmg * (1 + amp)
						break
					end
				end
			end
		end

		--External Reduction
		for i,v in ipairs(utils.externalDmgAmps) do
			if self:DoesHaveModifier(v.modifierName) then
				local reduce = v.reduce
				if v.type == 1 then
					if type(reduce) == "table" then
						if v.sourceTeam == 1 then
							for k,l in pairs(entityList:FindEntities({type = TYPE_HERO, team = me.team})) do
								if not k.illusion then
									local spell = k:FindSpell(v.sourceSpellName)
									if spell then
										reduce = reduce[spell.level]
										break
									end
								end
							end
							if type(reduce) == "table" then
								reduce = 0
							end
						elseif v.sourceTeam == 0 then
							local spell = me:FindSpell(v.sourceSpellName)
							if spell then
								reduce = reduce[spell.level]
							else
								reduce = 0
							end
						end
					end
					tempDmg = tempDmg * (1 - reduce)
				elseif tempDmg > 0 then
					if type(reduce) == "table" then
						if v.sourceTeam == 1 then
							for k,l in pairs(entityList:FindEntities({type = TYPE_HERO, team = me.team})) do
								if not k.illusion then
									local spell = k:FindSpell(v.sourceSpellName)
									if spell then
										reduce = reduce[spell.level]
										break
									end
								end
							end
							if type(reduce) == "table" then
								reduce = 0
							end
						elseif v.sourceTeam == 0 then
							local spell = me:FindSpell(v.sourceSpellName)
							if spell then
								reduce = reduce[spell.level]
							else
								reduce = 0
							end
						end
					end
					tempDmg = tempDmg - reduce
				end
			end
		end

		--Exception External Reductiom: Bristleback: Bristleback
		if self:DoesHaveModifier("modifier_bristleback_bristleback") then
			local spell = self:FindSpell("bristleback_bristleback")
			if spell then
				local reduce = 0
				local angle = ((self:FindRelativeAngle(source.position)) % (2 * math.pi)) * 180 / math.pi
				if angle >= 110 and angle <= 250 then
					reduce = (1 + spell.level) * 0.08
					elseif angle >= 70 and angle <= 290 then
					reduce = (1 + spell.level) * 0.04
				end
				tempDmg = tempDmg * (1 - reduce)
			end
		end
	end
	return tempDmg
end

--Returns if LuaEntity is Invulnerable
function LuaEntity:IsInvul()
	if self.modifierCount then
		for i=1,self.modifierCount do
			if utils.invulModifiers[self:GetModifierName(i)] or utils.hiddenModifiers[self:GetModifierName(i)] then
				return true
			end
		end
	end
	return false
end

function LuaEntity:FindRelativeAngle(pos)
	assert(GetType(pos) == "Vector" or GetType(pos) == "LuaEntity" or GetType(pos) == "Vector2D", debug.getinfo(1, "n").name..": Invalid Parameter")
	return ((math.atan2(pos.y-self.y,pos.x-self.x) - self.rotR + math.pi) % (2 * math.pi)) - math.pi
end

--Returns the particular flag at the LuaEntity's unitState.
function LuaEntity:FindFlag(row)
	assert(type(row) == "number", "FindFlag: Invalid Row")
	return math.floor(self.unitState/math.pow(2,row-1)) % 2 == 1
end

--Returns if LuaEntity can move.
function LuaEntity:CanMove()
	return not self:FindFlag(1) and not self:FindFlag(8) and self.alive
end

--Returns if LuaEntity can cast spells.
function LuaEntity:CanCast()
	return not self:FindFlag(6) and not self:FindFlag(8) and self.alive
end

--Returns if LuaEntity can attack.
function LuaEntity:CanAttack()
	return not self:FindFlag(2) and not self:FindFlag(3) and not self:FindFlag(8) and self.alive
end

--Returns if LuaEntity can use items.
function LuaEntity:CanUseItems()
	return not self:FindFlag(7) and not self:FindFlag(8) and self.alive
end

--== LUAENTITY (CDOTABaseAbility) FUNCTIONS ==--

--Returns if LuaEntity can be casted.
function LuaEntity:CanBeCasted()
	return self.state == STATE_READY
end

--Returns if LuaEntity can be blocked by Linken's Sphere.
--	Possible outcomes are: true, false, LINKEN_MAJOR_BLOCK, and LINKEN_MINOR_BLOCK
function LuaEntity:CanBeBlockedByLinkens()
	return utils.linkenBlocks[self.name]
end

--Returns if LuaEntity is being channeled.
function LuaEntity:IsBeingChanneled()
	return self.channelTime ~= 0
end

function LuaEntity:GetOwner()
	local sameRot = {}
	for i,v in ipairs(entityList:FindEntities({})) do
		if self.rotR == v.rotR then
			table.insert(sameRot,v)
		end
	end
	if #sameRot == 1 then return sameRot[1] end
	for i,v in ipairs(sameRot) do
		local items = v:GetAllItems()
		local spells = v:GetAllSpells()
		for k,l in pairs(items) do
			if self.handle == l.handle then
				return v
			end
		end
		for k,l in pairs(spells) do
			if self.handle == l.handle then
				return v
			end
		end
	end
end

	--Code to apply all functions to the old LuaEntities.--

utils.entityFuncs = {
	"Move",
	"AttackMove",
	"Attack",
	"Follow",
	"Stop",
	"FindSpell",
	"CastSpell",
	"SafeCastSpell",
	"ToggleSpell",
	"SafeToggleSpell",
	"CastAbility",
	"SafeCastAbility",
	"FindItem",
	"SetPowerTreadsState",
	"CastItem",
	"SafeCastItem",
	"GetAllSpells",
	"GetAllItems",
	"IsChanneling",
	"GetChanneledSpell",
	"GetDistance2D",
	"IsMagicDmgImmune",
	"IsPhysDmgImmune",
	"DoesHaveModifier",
	"IsLinkensProtected",
	"IsRanged",
	"CanDie",
	"CanReincarnate",
	"DamageTaken",
	"ManaBurnDamageTaken",
	"IsInvul",
	"FindRelativeAngle",
	"FindFlag",
	"CanMove",
	"CanCast",
	"CanAttack",
	"CanUseItems",
	"CanBeCasted",
	"CanBeBlockedByLinkens",
	"IsBeingChanneled",
	"GetOwner",
}

for i,v in ipairs(entityList:FindEntities({})) do
	for k,l in pairs(utils.entityFuncs) do
		v[l] = LuaEntity[l]
	end
end