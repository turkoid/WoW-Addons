--[[

	THIS IS THE AURA ILTER LIST FOR EACH CLASS
	
	HELPFUL = buffs
	HARMFUL = debuffs
	
	Format:	["auraname[maxrank]"] = priority
	
	**Only use [maxrank] if the rank is the aura name (ie. Wound Poison VII)
	**but you would write it as ["Wound Poison[7]"]
	
	If priorities are equal it sorts alphabetically
	
]]--
local config = turkoid.config
local _, playerClass = UnitClass("player")
local _, playerRace = UnitRace("player")	

config.auraFilters = {}
if playerClass == "PRIEST" then
	config.canDispel = {
		["Magic"] 				= true,
		["Disease"] 				= true,
	}
	config.auraFilters["HELPFUL"] = {
		["Blessed Recovery"]			= 1,
		["Fade"]				= 1,
		["Focused Casting"]			= 1,
		["Inner Fire"]				= 1,
		["Inner Focus"]				= 1,
		["Levitate"]				= 1,
		["Shadowform"]				= 1,
		["Dispersion"]				= 1,
		["Abolish Disease"]			= 1,
		["Divine Spirit"]			= 1,
		["Fear Ward"]				= 1,
		["Inspiration"]				= 1,
		["Power Infusion"]			= 1,
		["Power Word: Fortitude"]		= 1,
		["Power Word: Shield"]			= 1,
		["Prayer of Fortitude"]			= 1,
		["Pain Suppression"]			= 1,
		["Prayer of Mending"]			= 1,
		["Prayer of Shadow Protection"]		= 1,
		["Prayer of Spirit"]			= 1,
		["Renew"]				= 1,
		["Shadow Protection"]			= 1,
		["Replenishment"]			= 1,
		["Hymn of Hope"]			= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Mind Vision"]				= 1,
		["Devouring Plague"]			= 1,
		["Holy Fire"]				= 1,
		["Mind Control"]			= 1,
		["Mind Flay"]				= 1,
		["Mind Soothe"]				= 1,
		["Mind Vision"]				= 1,
		["Psychic Scream"]			= 1,
		["Shackle Undead"]			= 1,
		["Shadow Vulnerability"]		= 1,
		["Shadow Word: Pain"]			= 1,
		["Silence"]				= 1,
		["Vampiric Embrace"]			= 1,
		["Vampiric Touch"]			= 1,
		["Weakened Soul"]			= 1,
	}
elseif playerClass == "SHAMAN" then
	config.canDispel = {
		["Disease"] 				= true,
		["Poison"] 				= true,
		["Curse"] 				= true,
	}
	config.auraFilters["HELPFUL"] = {
		["Astral Shift"]			= 1,
		["Clearcasting"]			= 1,
		["Elemental Devastation"]		= 1,
		["Elemental Mastery"]			= 1,
		["Far Sight"]				= 1,
		["Focused Casting"]			= 1,
		["Ghost Wolf"]				= 1,
		["Lightning Shield"]			= 1,
		["Maelstrom Weapon"]			= 1,
		["Nature's Swiftness"]			= 1,
		["Sentry Totem"]			= 1,
		["Focused"]				= 1,
		["Shamanistic Rage"]			= 1,
		["Tidal Force"]				= 1,
		["Tidal Waves"]				= 1,
		["Water Shield"]			= 1,
		["Ancestral Fortitude"]			= 1,
		["Bloodlust"]				= 1,
		["Earth Shield"]			= 1,
		["Earthliving"]				= 1,
		["Elemental Oath"]			= 1,
		["Fire Resistance"]			= 1,
		["Flametongue Totem"]			= 1,
		["Frost Resistance"]			= 1,
		["Grounding Totem Effect"]		= 1,
		["Healing Stream"]			= 1,
		["Healing Way"]				= 1,
		["Heroism"]				= 1,
		["Mana Spring"]				= 1,
		["Mana Tide"]				= 1,
		["Nature Resistance"]			= 1,
		["Riptide"]				= 1,
		["Stoneskin"]				= 1,
		["Strength of Earth"]			= 1,
		["Totem of Wrath"]			= 1,
		["Water Breathing"]			= 1,
		["Water Walking"]			= 1,
		["Windfury Totem"]			= 1,
		["Wrath of Air Totem"]			= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Earthbind"]				= 1,
		["Flame Shock"]				= 1,
		["Frost Shock"]				= 1,
		["Frostbrand Attack"]			= 1,
		["Stoneclaw Stun"]			= 1,
		["Stormstrike"]				= 1,
	}
elseif playerClass == "PALADIN" then
	config.canDispel = {
		["Magic"] 				= true,
		["Disease"] 				= true,
		["Poison"] 				= true,
	}
	config.auraFilters["HELPFUL"] = {
		["Avenging Wrath"]			= 1,
		["Divine Favor"]			= 1,
		["Divine Illumination"]			= 1,
		["Divine Protection"]			= 1,
		["Divine Shield"]			= 1,
		["Holy Shield"]				= 1,
		["Righteous Fury"]			= 1,
		["Seal of Blood"]			= 1,
		["Seal of Command"]			= 1,
		["Seal of Justice"]			= 1,
		["Seal of Light"]			= 1,
		["Seal of Righteousness"]		= 1,
		["Seal of Vengeance"]			= 1,
		["Seal of Wisdom"]			= 1,
		["Sense Undead"]			= 1,
		["Summon Charger"]			= 1,
		["Summon Warhorse"]			= 1,
		["Vengeance"]				= 1,
		["Beacon of Light"]			= 1,
		["Blessing of Freedom"]			= 1,
		["Blessing of Kings"]			= 1,
		["Blessing of Might"]			= 1,
		["Blessing of Protection"]		= 1,
		["Blessing of Sacrifice"]		= 1,
		["Blessing of Sanctuary"]		= 1,
		["Blessing of Wisdom"]			= 1,
		["Concentration Aura"]			= 1,
		["Crusader Aura"]			= 1,
		["Devotion Aura"]			= 1,
		["Divine Intervention"]			= 1,
		["Fire Resistance Aura"]		= 1,
		["Frost Resistance Aura"]		= 1,
		["Greater Blessing of Kings"]		= 1,
		["Greater Blessing of Might"]		= 1,
		["Greater Blessing of Sanctuary"]	= 1,
		["Greater Blessing of Wisdom"]		= 1,
		["Retribution Aura"]			= 1,
		["Sacred Shield"]			= 1,
		["Shadow Resistance Aura"]		= 1,
		["Replenishment"]			= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Avenger's Shield"]			= 1,
		["Consecration"]			= 1,
		["Hammer of Justice"]			= 1,
		["Holy Vengeance"]			= 1,
		["Judgement of Justice"]		= 1,
		["Judgement of Light"]			= 1,
		["Judgement of Wisdom"]			= 1,
		["Repentance"]				= 1,
		["Stun"]				= 1,
		["Turn Evil"]				= 1,
		["Forbearance"]				= 1,
	}
elseif playerClass == "MAGE" then
	config.canDispel = {
		["Curse"] 				= true,
	}
	config.auraFilters["HELPFUL"] = {
		["Arcane Power"]			= 1,
		["Blazing Speed"]			= 1,
		["Blink"]				= 1,
		["Clearcasting"]			= 1,
		["Combustion"]				= 1,
		["Evocation"]				= 1,
		["Fire Ward"]				= 1,
		["Frost Armor"]				= 1,		
		["Frost Ward"]				= 1,
		["Ice Armor"]				= 1,
		["Ice Barrier"]				= 1,
		["Ice Block"]				= 1,
		["Invisibility"]			= 1,
		["Mage Armor"]				= 1,
		["Mana Shield"]				= 1,
		["Molten Armor"]			= 1,
		["Presence of Mind"]			= 1,
		["Slow Fall"]				= 1,
		["Amplify Magic"]			= 1,
		["Arcane Brilliance"]			= 1,
		["Arcane Intellect"]			= 1,
		["Dalaran Brilliance"]			= 1,
		["Dalaran Intellect"]			= 1,
		["Dampen Magic"]			= 1,
		["Focus Magic"]				= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Arcane Blast"]			= 1,
		["Hypothermia"]				= 1,
		["Blast Wave"]				= 1,
		["Blizzard"]				= 1,
		["Chilled"]				= 1,
		["Cone of Cold"]			= 1,
		["Detect Magic"]			= 1,
		["Dragon's Breath"]			= 1,
		["Fire Vulnerability"]			= 1,
		["Fireball"]				= 1,
		["Flamestrike"]				= 1,
		["Frost Armor"]				= 1,
		["Frost Nova"]				= 1,
		["Frostbite"]				= 1,
		["Frostbolt"]				= 1,
		["Ice Armor"]				= 1,
		["Ignite"]				= 1,
		["Impact"]				= 1,
		["Living Bomb"]				= 1,
		["Polymorph"]				= 1,
		["Pyroblast"]				= 1,
		["Slow"]				= 1,
		["Winter's Chill"]			= 1,
	}
elseif playerClass == "DRUID" then
	config.canDispel = {
		["Poison"] 				= true,
		["Curse"] 				= true,
	}
	config.auraFilters["HELPFUL"] = {
		["Master Shapeshifter"]			= 1,
		["Aquatic Form"]			= 1,
		["Barkskin"]				= 1,
		["Bear Form"]				= 1,
		["Cat Form"]				= 1,
		["Clearcasting"]			= 1,
		["Dash"]				= 1,
		["Dire Bear Form"]			= 1,
		["Enrage"]				= 1,
		["Flight Form"]				= 1,
		["Frenzied Regeneration"]		= 1,
		["Moonkin Form"]			= 1,
		["Nature's Grasp"]			= 1,
		["Nature's Swiftness"]			= 1,
		["Omen of Clarity"]			= 1,
		["Prowl"]				= 1,
		["Swift Flight Form"]			= 1,
		["Tiger's Fury"]			= 1,
		["Track Humanoids"]			= 1,
		["Travel Form"]				= 1,
		["Abolish Poison"]			= 1,
		["Gift of the Wild"]			= 1,
		["Innervate"]				= 1,
		["Leader of the Pack"]			= 1,
		["Lifebloom"]				= 1,
		["Mark of the Wild"]			= 1,
		["Moonkin Aura"]			= 1,
		["Regrowth"]				= 1,
		["Rejuvenation"]			= 1,
		["Thorns"]				= 1,
		["Tranquility"]				= 1,
		["Tree of Life"]			= 1,
		["Living Seed"]				= 1,
		["Wild Growth"]				= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Bash"]				= 1,
		["Challenging Roar"]			= 1,
		["Cyclone"]				= 1,
		["Demoralizing Roar"]			= 1,
		["Entangling Roots"]			= 1,
		["Faerie Fire"]				= 1,
		["Faerie Fire (Feral)"]			= 1,
		["Feral Charge"]			= 1,
		["Hibernate"]				= 1,
		["Hurricane"]				= 1,
		["Insect Swarm"]			= 1,
		["Lacerate"]				= 1,
		["Maim"]				= 1,
		["Mangle (Bear)"]			= 1,
		["Mangle (Cat)"]			= 1,
		["Moonfire"]				= 1,
		["Pounce"]				= 1,
		["Rake"]				= 1,
		["Rip"]					= 1,
		["Soothe Animal"]			= 1,
		
		--just for my sake
		["Demoralizing Shout"]			= 1,
		["Sunder Armor"]			= 1,
		["Thunder Clap"]			= 1,		
		["Trauma"]					= 1,
		["Vindication"]				= 1,
	}
elseif playerClass == "WARRIOR" then
	config.auraFilters["HELPFUL"] = {
		["Berserker Rage"]			= 1,
		["Blood Craze"]				= 1,
		["Bloodrage"]				= 1,
		["Bloodthirst"]				= 1,
		["Enrage"]				= 1,
		["Flurry"]				= 1,
		["Last Stand"]				= 1,
		["Rampage"]				= 1,
		["Recklessness"]			= 1,
		["Retaliation"]				= 1,
		["Second Wind"]				= 1,
		["Shield Block"]			= 1,
		["Shield Wall"]				= 1,
		["Spell Reflection"]			= 1,
		["Sweeping Strikes"]			= 1,
		["Blade Turning"]			= 1,
		["Revenge"]				= 1,
		["Battle Rush"]				= 1,
		["Reinforced Shield"]			= 1,
		["Overpower"]				= 1,
		["Battle Shout"]			= 1,
		["Commanding Shout"]			= 1,
		["Intervene"]				= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Death Wish"]				= 1,
		["Blood Frenzy"]			= 1,
		["Challenging Shout"]			= 1,
		["Charge Stun"]				= 1,
		["Concussion Blow"]			= 1,
		["Dazed"]				= 1,
		["Deep Wound"]				= 1,
		["Demoralizing Shout"]			= 1,
		["Disarm"]				= 1,
		["Hamstring"]				= 1,
		["Improved Hamstring"]			= 1,
		["Intercept Stun"]			= 1,
		["Intimidating Shout"]			= 1,
		["Mace Stun Effect"]			= 1,
		["Mocking Blow"]			= 1,
		["Mortal Strike"]			= 1,
		["Piercing Howl"]			= 1,
		["Rend"]				= 1,
		["Revenge Stun"]			= 1,
		["Silenced - Gag Order"]		= 1,
		["Sunder Armor"]			= 1,
		["Taunt"]				= 1,
		["Thunder Clap"]			= 1,
	}
elseif playerClass == "WARLOCK" then
	config.auraFilters["HELPFUL"] = {
		["Amplify Curse"]			= 1,
		["Backlash"]				= 1,
		["Demon Armor"]				= 1,
		["Demon Skin"]				= 1,
		["Demonic Knowledge"]			= 1,
		["Demonic Sacrifice"]			= 1,
		["Fel Armor"]				= 1,
		["Fel Domination"]			= 1,
		["Master Demonologist"]			= 1,
		["Nether Protection"]			= 1,
		["Sacrifice"]				= 1,
		["Sense Demons"]			= 1,
		["Shadow Trance"]			= 1,
		["Shadow Ward"]				= 1,
		["Soul Link"]				= 1,
		["Dreadsteed"]				= 1,
		["Felsteed"]				= 1,
		["Blood Pact"]				= 1,
		["Detect Invisibility"]			= 1,
		["Fire Shield"]				= 1,
		["Fel Intelligence"]			= 1,
		["Soulstone Resurrection"]		= 1,
		["Unending Breath"]			= 1,
		["Demonic Frenzy"]			= 1,
		["Well Fed"]				= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Aftermath"]				= 1,
		["Banish"]				= 1,
		["Corruption"]				= 1,
		["Cripple"]				= 1,
		["Curse of Agony"]			= 1,
		["Curse of Doom"]			= 1,
		["Curse of Exhaustion"]			= 1,
		["Curse of Recklessness"]		= 1,
		["Curse of Tongues"]			= 1,
		["Curse of Weakness"]			= 1,
		["Curse of the Elements"]		= 1,
		["Death Coil"]				= 1,
		["Drain Life"]				= 1,
		["Drain Mana"]				= 1,
		["Drain Soul"]				= 1,
		["Fear"]				= 1,
		["Hellfire"]				= 1,
		["Howl of Terror"]			= 1,
		["Immolate"]				= 1,
		["Inferno"]				= 1,
		["Pyroclasm"]				= 1,
		["Rain of Fire"]			= 1,
		["Seduction"]				= 1,
		["Seed of Corruption"]			= 1,
		["Shadow Embrace"]			= 1,
		["Shadow Vulnerability"]		= 1,
		["Shadowburn"]				= 1,
		["Shadowfury"]				= 1,
		["Silence"]				= 1,
		["Siphon Life"]				= 1,
		["Soothing Kiss"]			= 1,
		["Spell Lock"]				= 1,
		["Suffering"]				= 1,
		["Shadow Bite"]				= 1,
		["Unstable Affliction"]			= 1,
	}
elseif playerClass == "HUNTER" then
	config.auraFilters["HELPFUL"] = {
		["Aspect of the Beast"]			= 1,
		["Aspect of the Cheetah"]		= 1,
		["Aspect of the Hawk"]			= 1,
		["Aspect of the Monkey"]		= 1,
		["Aspect of the Viper"]			= 1,
		["Deterrence"]				= 1,
		["Eagle Eye"]				= 1,
		["Eyes of the Beast"]			= 1,
		["Feign Death"]				= 1,
		["Master Tactician"]			= 1,
		["Quick Shots"]				= 1,
		["Rapid Fire"]				= 1,
		["Rapid Killing"]			= 1,
		["The Beast Within"]			= 1,
		["Aspect of the Pack"]			= 1,
		["Aspect of the Wild"]			= 1,
		["Ferocious Inspiration"]		= 1,
		["Misdirection"]			= 1,
		["Spirit Bond"]				= 1,
		["Trueshot Aura"]			= 1,
		["Replenishment"]			= 1,
		["Bestial Wrath"]			= 1,
		["Boar Charge"]				= 1,
		["Dash"]				= 1,
		["Dive"]				= 1,
		["Feed Pet Effect"]			= 1,
		["Frenzy"]				= 1,
		["Furious Howl"]			= 1,
		["Mend Pet"]				= 1,
		["Prowl"]				= 1,
		["Shell Shield"]			= 1,
		["Warp"]				= 1,
		["Well Fed"]				= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Aimed Shot"]				= 1,
		["Beast Lore"]				= 1,
		["Boar Charge"]				= 1,
		["Concussive Barrage"]			= 1,
		["Concussive Shot"]			= 1,
		["Counterattack"]			= 1,
		["Crippling Poison"]			= 1,
		["Deadly Poison"]			= 1,
		["Entrapment"]				= 1,
		["Explosive Trap Effect"]		= 1,
		["Expose Weakness"]			= 1,
		["Fire Breath"]				= 1,
		["Flare"]				= 1,
		["Freezing Trap Effect"]		= 1,
		["Frost Trap Aura"]			= 1,
		["Growl"]				= 1,
		["Hunter's Mark"]			= 1,
		["Improved Concussive Shot"]		= 1,
		["Improved Wing Clip"]			= 1,
		["Intimidation"]			= 1,
		["Mind-numbing Poison"]			= 1,
		["Poison Spit"]				= 1,
		["Scare Beast"]				= 1,
		["Scatter Shot"]			= 1,
		["Scorpid Poison"]			= 1,
		["Scorpid Sting"]			= 1,
		["Screech"]				= 1,
		["Serpent Sting"]			= 1,
		["Silencing Shot"]			= 1,
		["Tame Beast"]				= 1,
		["Viper Sting"]				= 1,
		["Wing Clip"]				= 1,
		["Wyvern Sting"]			= 1,
	}
elseif playerClass == "ROGUE" then
	config.auraFilters["HELPFUL"] = {
		["Adrenaline Rush"]			= 1,
		["Blade Flurry"]			= 1,
		["Cloak of Shadows"]			= 1,
		["Cold Blood"]				= 1,
		["Evasion"]				= 1,
		["Ghostly Strike"]			= 1,
		["Remorseless"]				= 1,
		["Shadowstep"]				= 1,
		["Slice and Dice"]			= 1,
		["Sprint"]				= 1,
		["Stealth"]				= 1,
		["Vanish"]				= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Blind"]				= 1,
		["Cheap Shot"]				= 1,
		["Crippling Poison"]			= 1,
		["Deadly Poison[8]"]			= 1,
		["Deadly Throw"]			= 1,
		["Expose Armor"]			= 1,
		["Garrote"]				= 1,
		["Garrote - Silence"]			= 1,
		["Gouge"]				= 1,
		["Hemorrhage"]				= 1,
		["Silenced - Improved Kick"]		= 1,
		["Kidney Shot"]				= 1,
		["Mace Stun Effect"]			= 1,
		["Mind-numbing Poison"]			= 1,
		["Riposte"]				= 1,
		["Rupture"]				= 1,
		["Sap"]					= 1,
		["Wound Poison[7]"]			= 1,
		["Interrupt"]				= 1,
	}
elseif playerClass == "DEATHKNIGHT" then
	config.auraFilters["HELPFUL"] = {
		["Icebound Fortitude"]			= 1,
		["Unholy Blight"]			= 1,
		["Vampiric Blood"]			= 1,
		["Unbreakable Armor"]			= 1,
		["Sudden Doom"]				= 1,
		["Scent of Blood"]			= 1,
		["Freezing Fog"]			= 1,
		["Lichborne"]				= 1,
		["Killing Machine"]			= 1,
		["Deathchill"]				= 1,
		["Dancing Rune Weapon"]			= 1,
		["Summon Gargoyle"]			= 1,
		["Bone Shield"]				= 1,
		["Blade Barrier"]			= 1,
		["Horn of Winter"]			= 1,
		["Path of Frost"]			= 1,
		["Hysteria"]				= 1,
		["Abominable Might"]			= 1,
	}
	config.auraFilters["HARMFUL"] = {
		["Blood Plague"]			= 1,
		["Frost Fever"]				= 1,
		["Ebon Plague"]				= 1,
		["Crypt Fever"]				= 1,
		["Chains of Ice"]			= 1,
		["Strangulate"]				= 1,
		["Mark of Blood"]			= 1,
		["Hungering Cold"]			= 1,
	}
end
config.auraFilters["HARMFUL"]["Regurgitated Ooze"] = 99
if playerRace == "BloodElf" then
	config.auraFilters["HELPFUL"]["Mana Tap"]		= 1
	config.auraFilters["HARMFUL"]["Arcane Torrent"]	= 1
elseif playerRace == "Troll" then
	config.auraFilters["HELPFUL"]["Berserking"]		= 1
elseif playerRace == "Orc" then
	config.auraFilters["HELPFUL"]["Blood Fury"]		= 1
	config.auraFilters["HARMFUL"]["Blood Fury"]		= 1
elseif playerRace == "Scourge" then
	config.auraFilters["HELPFUL"]["Cannibalize"]		= 1
	config.auraFilters["HELPFUL"]["Will of the Forsaken"]	= 1
elseif playerRace == "Tauren" then
	config.auraFilters["HARMFUL"]["War Stomp"]		= 1
elseif playerRace == "Dwarf" then
	config.auraFilters["HELPFUL"]["Find Treasure"]		= 1
	config.auraFilters["HELPFUL"]["Stoneform"]		= 1
elseif playerRace == "Draenei" then
	config.auraFilters["HELPFUL"]["Gift of the Naaru"]	= 1
elseif playerRace == "Human" then
	config.auraFilters["HELPFUL"]["Perception"]		= 1
elseif playerRace == "NightElf" then
	config.auraFilters["HELPFUL"]["Shadowmeld"]		= 1
end

if playerRace == "BloodElf" or playerRace == "Troll" or playerRace == "Orc" or playerRace == "Scourge" or playerRace == "Tauren" then
	config.auraFilters["HELPFUL"]["Warsong Flag"]		= 99
	config.auraFilters["HARMFUL"]["Silverwing Flag"]	= 99
else
	config.auraFilters["HELPFUL"]["Silverwing Flag"]	= 99
	config.auraFilters["HARMFUL"]["Warsong Flag"]		= 99
end

config.auraFilters["HELPFUL"]["Netherstorm Flag"]		= 99
config.auraFilters["HARMFUL"]["Netherstorm Flag"]		= 99

local name, first, last, romanrank
for aura, priority in pairs(config.auraFilters["HELPFUL"]) do
	name, maxrank = aura:match("(.+)%[(%d+)%]")
	if maxrank then
		config.auraFilters["HELPFUL"][name] = priority
		for rank = 2, maxrank do
			romanrank = config.roman[rank]
			if romanrank then config.auraFilters["HELPFUL"][name.." "..romanrank] = priority end
		end
	end
end
for aura, priority in pairs(config.auraFilters["HARMFUL"]) do
	name, maxrank = aura:match("(.+)%[(%d+)%]")
	if maxrank then
		config.auraFilters["HARMFUL"][name] = priority
		for rank = 2, maxrank do
			romanrank = config.roman[rank]
			if romanrank then config.auraFilters["HARMFUL"][name.." "..romanrank] = priority end
		end
	end
end