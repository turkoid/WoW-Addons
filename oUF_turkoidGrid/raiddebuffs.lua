--[[ 
	
	RAID DEBUFF LIST
	FORMAT:
		["zone"] = {
			"debuff1",
			"debuff2",
		},
	
	The order of debuffs in the list is its priority
	I just parsed the raid debuff list from grid so everything from there is in here
	To not track a debuff just comment it out.
	
]]--
--GridStatusRaidDebuff:Debuff\(zone, (\d+).+--(.+)

local config = turkoid.config
config.raiddebuffs = {
	["Ulduar"] = {				
		--[[ Razorscale ]]--
		--"Fuse Armor", --64771
					
		--[[ Ignis the Furnace Master ]]--
		--"Scorch", --62548
		--"Flame Jet", --62680
		"Slag Pot", --62717
					
		--[[ XT-002 ]]--
		"Gravity Bomb", --63024
		"Light Bomb", --63018
					
		--[[ The Assembly of Iron ]]--
		"Overwhelming Power", --61888
		--"Rune of Death", --62269
		"Fusion Punch", --61903
		--"Static Disruption", --61912
					
		--[[ Kologarn ]]--
		"Stone Grip", --64290
		--"Crunch Armor", --63355
		--"Brittle Skin", --62055
					
		--[[ Hodir ]]--		
		"Flash Freeze", --61969
		"Freeze", --62469
		--"Biting Cold", --62188
					
		--[[ Thorim ]]--
		--"Stormhammer", --62042
		"Unbalancing Strike", --62130
		"Rune Detonation", --62526
		--"Deafening Thunder", --62470
		--"Impale", --62331
					
		--[[ Freya ]]--
		"Iron Roots", --62861
		"Nature's Fury", --62589		
					
		--[[ Mimiron ]]--
		--"Napalm Shell", --63666
		"Plasma Blast", --62997
		--"Magnetic Field", --64668
		
		--[[ General Vezax ]]--
		"Mark of the Faceless", --63276
		--"Saronite Vapors", --63322
		
		--[[ Yogg-Saron ]]--
		--"Sara's Bless", --63134
		--"Sara's Fevor", --63138
		--"Malady of the Mind", --63830
		"Brain Link", --63802
		"Dominate Mind", --63042
		--"Apathy", --64156
		--"Black Plague", --64153
		--"Curse of Doom", --64157
		--"Draining Poison", --64152
		"Squeeze", --64125
		--"Sanity", --63050
		
		--[[ Algalon ]]--
		--"Phase Punch", --64412
	},
	["Trial of the Crusader"] ={
		--[[ Gormok the Impaler ]]--
		--"Impale", --66331
		--"Fire Bomb", --67475
		
		
		--[[ Acidmaw + Dreadscale ]]--
		"Paralytic Toxin", --67618
		"Burning Bile", --66869
		
		--[[ Icehowl ]]--
		--"Ferocious Butt", --67654
		"Arctic Breath", --66689
		--"Massive Crash", --66683
		
		"Snobolled!", --66406
		
		--[[ Lord Jaraxxus ]]--		
		--"Fel Fireball", --66532
		"Incinerate Flesh", --66237
		--"Burning Inferno", --66242
		"Legion Flame", --66197
		--"Spinning Pain Spike", --66283
		--"Touch of Jaraxxus", --66209
		--"Curse of the Nether", --66211
		--"Mistress' Kiss", --67906
		
		--[[ Faction Champions ]]--
		--"Unstable Affliction", --65812
		--"Blind", --65960
		--"Polymorph", --65801
		--"Psychic Scream", --65543
		--"Hex", --66054
		--"Fear", --65809
		
		--[[ The Twin Val'kyr ]]--
		--"Dark Essence", --67176
		--"Light Essence", --67222
		"Dark Touch", --67283
		"Light Touch", --67298
		--"Twin Spike", --67309
		
		--[[ Anub'arak ]]--
		--"Pursued by Anub'arak", --67574
		"Penetrating Cold", --66013
		--"Expose Weakness", --67847
		--"Freezing Slash", --66012
		--"Acid-Drenched Mandibles", --67863
	},
	["The Obsidian Sanctum"] = {
		--[[ Sartharion ]]--
		--"Fade Armor", --60708
		"Flame Tsunami", --57491
	},
	["The Eye of Eternity"] = {
		--[[ Malygos ]]--	
		"Surge of Power", --57407
		"Arcane Breath", --56272
	},
	["Vault of Archavon"] = {
		--[[ Emalon ]]--
		--"Flaming Cinder", --67332
	},
	["Naxxramas"] = {
		--[[ Trash ]]--
		--"Strangulate", --55314
		
		--[[ Anub'Rekhan ]]--
		"Locust Swarm", --28786
		
		--[[ Grand Widow Faerlina ]]--
		--"Poison Bolt Volley", --28796
		--"Rain of Fire", --28794
		
		--[[ Maexxna ]]--
		--"Web Wrap", --28622
		--"Necrotic Poison", --54121
		
		--[[ Noth the Plaguebringer ]]--
		--"Curse of the Plaguebringer", --29213
		--"Wrath of the Plaguebringer", --29214
		--"Cripple", --29212
		
		--[[ Heigan the Unclean ]]--
		--"Decrepit Fever", --29998
		--"Spell Disruption", --29310
		
		--[[ Grobbulus ]]--
		"Mutating Injection", --28169
		
		--[[ Gluth ]]--
		--"Mortal Wound", --54378
		--"Infected Wound", --29306
		
		--[[ Thaddius ]]--
		--"Negative Charge", --28084
		--"Positive Charge", --28059
		
		--[[ Instructor Razuvious ]]--
		--"Jagged Knife", --55550
					
		--[[ Sapphiron ]]--
		"Icebolt", --28522
		--"Life Drain", --28542
		
		--[[ Kel'Thuzad ]]--
		"Chains of Kel'Thuzad", --28410
		"Detonate Mana", --27819
		"Frost Blast", --27808
	},
	["Icecrown Citadel"] = {
		--[[ Trash ]]--
		"Dark Reckoning", --69483
		
		--[[ Lord Marrowgar ]]--   
		--"Coldflame", --70823
		"Impaled", --69065
		--"Bone Storm", --70835
		
		--[[ Lady Deathwhisper ]]--
		--"Death and Decay", --72109
		"Dominate Mind", --71289
		--"Touch of Insignificance", --71204
		--"Frost Fever", --67934
		"Curse of Torpor", --71237
		--"Necrotic Strike", --72491
		
		--[[ Gunship Battle ]]--
		--"Wounding Strike", --69651
		
		--[[ Deathbringer Saurfang ]]--
		"Mark of the Fallen Champion", --72293
		"Boiling Blood", --72442
		--"Rune of Blood", --72449
		--"Scent of Blood", --72769
		
		--[[ Rotface ]]--   
		"Mutated Infection", --71224
		--"Ooze Flood", --71215
		--"Sticky Ooze", --69774

		 --[[ Festergut ]]--
		"Gas Spore", --69279
		"Vile Gas", --71218
		"Gastric Bloat", --72219

	 	--[[ Professor Putricide ]]--
		--"Slime Puddle", --70341
		--"Malleable Goo", --72549		
		"Unbound Plague",
		"Plague Sickness",
		"Gaseous Bloat", --70215
		"Volatile Ooze Adhesive", --70447
		--"Choking Gas Bomb", --71278		
		--"Mutated Plague", --72454
		"Mutated Transformation ", --70405
		
		--[[ Blood Queen Lana'thel ]]--
		"Uncontrollable Frenzy",
		"Frenzied Bloodthirst",
		"Essence of the Blood Queen",		
		"Pact of the Darkfallen",
		"Swarming Shadows",

		--[[ Valithria Dreamwalker ]]--
		"Emerald Vigor", --70873
		--"Column of Frost", --71746		
		"Corrosion", --71738
		--"Acid Burst", --71733
		"Gut Spray", --71283
		"Mana Void", --71741
		
		--[[ Sindragosa ]]--		
		--"Chlled to the Bone", --70106
		--"Instability", --69766
		"Frost Beacon", --70126
		"Ice Tomb", --70157		
		"Unchained Magic", --69762
		"Mystic Buffet", --70127
		
		--[[ The Lich King ]]--
		"Harvest Soul", --68980
		
		"Necrotic plague", --70337
		
		--"Shockwave ", --72149
		"Infest", --70541
		"Defile	", --72762
		--"Soul Shriek", --69242
		--"Raging Spirit", --69200
		"Soul Reaper ", --69409
	
	},
	['The Ruby Sanctum'] = {
		'Mark of Combustion',
		'Mark of Consumption',
	},
}