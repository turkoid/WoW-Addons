--UnitAura return values = [1]name, [2]rank, [3]icon, [4]count, [5]debuffType, [6]duration, [7]expirationTime, [8]unitCaster, [9]isStealable
local parent = ...
local global = GetAddOnMetadata(parent, 'X-oUF')
local oUF = _G[global]
local config = turkoid.config
local HasAura = config.helper.HasAura
local SpellTexture = config.helper.SpellTexture
local PrintLine = config.helper.PrintLine
local AddAura, AddBuff, AddDebuff = config.helper.AddAura, config.helper.AddBuff, config.helper.AddDebuff
local UnitHasVehicleUI, UnitIsDead, UnitIsGhost, UnitIsConnected, UnitAura, UnitIsUnit, UnitHealth, UnitHealthMax, UnitPowerType, UnitPower, UnitPowerMax = 
	UnitHasVehicleUI, UnitIsDead, UnitIsGhost, UnitIsConnected, UnitAura, UnitIsUnit, UnitHealth, UnitHealthMax, UnitPowerType, UnitPower, UnitPowerMax
	
--[[ FORMAT: texture->gradient->color
	["status"] = {
		["events"] = {
			"event",
		},
		["func"] = function(self, unit, event, ...)
			--self is the status the function is linked to			
			--unit is the unit to check
			--event is the event that trigger it

			return values
		end,
		["texture"] = true,  			--display the aura texture or a custom texture returned
		["gradient"] = {			--color indicator by duration
			{r1, g1, b1}			--min
			{r2, g2, b2}
		},					--max
		["color"] = {r, g, b},			--color indicator
		["filter"] = nil,			--how to filter auras: 'player': if you cast it or 'dispel': if you can dispel it
		["hide"] = {				--hide indicator based on statuses defined in config.statuses
			"status1",
			...,
			"statusN"
		},
		["showCount"] = true,
		["showDuration"] = true,
		["delay"] = seconds, 			--if status is shown, how long before it fades		
	},
	
	**There is a special function specifically for buffs/debuffs statuses
	
	FUNCTION:  AddAura(auraType, auraName, maxRank, alias, [filter, hideStatuses, extraEvents, showCount, showDuration, statusType, r1, g1, b1, r2, g2, b2])
	|---------------|-----------------------------------------------|---------------------------------------|-----------------------|
	|arg            | description                                   | format / values                       | default               |
	|---------------|-----------------------------------------------|---------------------------------------|-----------------------|
	|auraType       | type of aura                                  | "buff", "debuff"                      | "debuff"              | 
	|auraName       | name of aura to find                          |                                       | N/A                   |
	|maxRank        | the max rank of the buff                      | 1-10 for now                          | nil                   | 
	|alias          | name to use for the status                    |                                       | strlower(auraName)    |     
	|filter         | how to filter auras                           | "player", "dispel"                    | nil                   | 
	|hideStatuses   | hide based on statuses                        | "status1 ... statusN"                 | nil                   |
	|extraEvents    | extra events to trigger status                | "event1 ... eventN"                   | nil                   | 
	|showCount      | whether to show stack count                   | true, false                           | false                 | 
	|showDuration   | whether to show aura duration                 | true, false                           | false                 | 
	|statusType     | how to display status                         | "texture", "gradient", "color"        | "texture"             | 
	|rgb1, rgb2     | RGB values for color or gradients             | 1-255                                 | 1, 0, 0, 0, 1, 0      |
	|---------------|-----------------------------------------------|---------------------------------------|-----------------------|
    
	**AddBuff, AddDebuff are wrappers for AddAura("buff", ...), AddAura("debuff", ...) respectively
	
	**NOTES:
		-- If the status already exists it will not override it
		-- Use maxRank only if the rank is a part of the aura's name (ie. 'Wound Poison VII')
		-- If no RGB values are supplied for the statusType 'color' then it uses RGB2 default values
		-- UNIT_AURA will always be registered, only use 'extraEvents' for additional events to register
		-- The function returns the status name it will be indexed under using the format: auraType:alias
		
]]--

--DO NOT ADD AURAS HERE, ADD THEM AT THE END OF THE FILE.
config.statuses = {
	["vehicle"] = {
		["events"] = {
			"UNIT_ENTERED_VEHICLE", 
			"UNIT_EXITED_VEHICLE",
		},
		["func"] = function(self, unit)
			return UnitHasVehicleUI(unit) or UnitHasVehicleUI(config.helper.RaidFromPet(unit))
		end,
		["color"] =  {0, 0, 0},
	},
	["combat"] = {
		["events"] = {
			"PLAYER_REGEN_ENABLED", 
			"PLAYER_REGEN_DISABLED",
		},
		["func"] = function(self, unit)
			return config.InCombat
		end,
		["color"] =  {0, 0, 0},
	},
	["dead"] = {
		["events"] = {
			"UNIT_HEALTH",
		},
		["func"] = function(self, unit)
			return UnitIsDead(unit) or (UnitClass(unit) == "Priest" and HasAura(unit, "Spirit of Redemption", nil, "helpful"))
		end,
		["color"] =  {0, 0, 0},
	},
	["ghost"] = {
		["events"] = {
			"UNIT_HEALTH",
		},
		["func"] = function(self, unit)
			return UnitIsGhost(unit)
		end,
		["color"] =  {0, 0, 0},
	},
	["offline"] = {
		["events"] = {
			"UNIT_HEALTH",
		},
		["func"] = function(self, unit)
			return not UnitIsConnected(unit)
		end,
		["color"] =  {0, 0, 0},
	},
	["missinghp"] = {
		["events"] = {
			"UNIT_HEALTH",
			"UNIT_MAXHEALTH",
		},
		["func"] = function(self, unit)
			return oUF.Tags["[missinghp]"](unit) ~= ""
		end,
		["color"] =  {0, 0, 0},
	},
	["raiddebuff"] = {
		["events"] = {
			"UNIT_AURA",
		},
		["func"] = function(self, unit)
			if not config.raiddebuffs then return end
			local zone = GetRealZoneText()
			if zone and config.raiddebuffs[zone] then
				for _, debuff in ipairs(config.raiddebuffs[zone]) do
					if HasAura(unit, debuff, nil, "HARMFUL") then
						return UnitAura(unit, debuff, nil, "HARMFUL")
					end
				end
			end
		end,
		["texture"] = true,
		["showDuration"] = true,
		["showCount"] = true,
	},
	["missingbuff"] = {
		["events"] = {
			"UNIT_AURA",
		},
		["func"] = function(self, unit)
			if not config.missingbuffs then return end
			
			for _, buffgroup in ipairs(config.missingbuffs) do
				for index, buff in ipairs(buffgroup) do
					if SpellTexture(buff) then
						if HasAura(unit, buff, nil, "HELPFUL") then break end
						if index == #buffgroup then return true, nil, SpellTexture(buffgroup[1]) or SpellTexture(buff) end
					end
				end
			end
		end,
		["texture"] = true,
		["hide"] = {			
			"combat",
			"dead",
			"ghost",
			"offline",
		},
	},
	["healingreduced"] = {
		["events"] = {
			"UNIT_AURA",
		},
		["func"] = function(self, unit)
			for _, debuff in ipairs(config.healingdebuffs.reduced) do
				if HasAura(unit, debuff, nil, "HARMFUL") then
					return UnitAura(unit, debuff, nil, "HARMFUL")
				end
			end
			return false
		end,
		["color"] =  {1, 0, 1},
	},
	["healingprevented"] = {
		["events"] = {
			"UNIT_AURA",
		},
		["func"] = function(self, unit)
			for _, debuff in ipairs(config.healingdebuffs.prevented) do
				if HasAura(unit, debuff, nil, "HARMFUL") then
					return UnitAura(unit, debuff, nil, "HARMFUL")
				end
			end
			return false
		end,		
		["color"] =  {1, 0, 0},
	},
	["target"] = {
		["events"] = {
			"PLAYER_TARGET_CHANGED",
		},
		["func"] = function(self, unit)
			return UnitIsUnit("target", unit)
		end,
		["color"] = {0.8, 0.8, 0.8},
	},
	["lowhp"] = {
		["events"] = {
			"UNIT_HEALTH",
		},
		["func"] = function(self, unit)
			return UnitHealth(unit)/UnitHealthMax(unit) <= 0.2
		end,
		["color"] = {1, 0, 0},
		["hide"] = {			
			"dead",
			"ghost",
			"offline",		
		},
	},
	["lowmana"] = {
		["events"] = {
			"UNIT_MANA",
		},
		["func"] = function(self, unit)
			return UnitPowerType(unit) == 0 and UnitPower(unit)/UnitPowerMax(unit) <= 0.1
		end,
		["color"] = {0.5, 0.5, 1},
		["hide"] = {			
			"dead",
			"ghost",
			"offline",		
		},
	},
	["readycheck"] = {
		["events"] = {
			"READY_CHECK",
			"READY_CHECK_CONFIRM",
			"READY_CHECK_FINISHED",
			"PARTY_LEADER_CHANGED",
			"RAID_ROSTER_UPDATE",
		},
		["func"] = function(self, unit, event, icon)
			if event == "READY_CHECK_FINISHED" then icon.delay = self.delay return end
			unit = config.helper.RaidFromPet(unit) or unit
			local status = GetReadyCheckStatus(unit)
			if not status then return end
			return true, nil, config.readycheck[status]
		end,
		["texture"] = true,
		["hide"] = {			
			"combat",
			"offline",		
		},
		["delay"] = 5, 
	},
	["plague_sickness"] = {
		["events"] = {
			"UNIT_AURA",
		},
		["func"] = function(self, unit)
			if HasAura(unit, "Plague Sickness", nil, "HARMFUL") and HasAura(unit, "Unbound Plague", nil, "HARMFUL") then 
				return UnitAura(unit,"Plague Sickness", nil, "HARMFUL")
			end
		end,
		["texture"] = true,
	},
}

--auraType(auraName, maxRank, alias, filter, hideStatuses, events, showCount, showDuration, statusType, r1, g1, b1, r2, g2, b2)

local pName = UnitName('player')
if pName == 'Yattay' or pName == 'Bryz' then
	AddBuff("Divine Intervention", nil, "di")
	AddBuff("Spirit of Redemption", nil, "angel") 
	AddDebuff('Deep Freeze', nil, 'deepfreeze')
	AddDebuff('Fear', nil, 'fear')
	AddDebuff('Hammer of Justice', nil, 'hammer')
	AddDebuff('Psychic Horror', nil, 'horror')
	AddDebuff('Death Coil', nil, 'deathcoil')
	AddDebuff('Judgement of Justice', nil, 'justice')
	AddDebuff('Frost Nova', nil, 'nova')
	AddDebuff('Entangling Roots', nil, 'roots')
	AddDebuff('Chains of Ice', nil, 'chains')
	AddDebuff('Immolate', nil, 'immolate')
	AddDebuff('Flame Shock', nil, 'flameshock')
	AddDebuff('Unstable Affliction', nil, 'unstableaffliction')
	AddDebuff('Weakened Soul', nil, 'weakenedsoul', nil, nil, nil, false, true)
	AddBuff("Renew", nil, "renew", "player", nil, nil, false, false, "gradient")
	AddBuff("Power Word: Shield", nil, "shield")
	AddBuff('Prayer of Mending', nil, 'pom', 'player', nil, nil, false, false, 'color')
	AddDebuff('Polymorph', nil, 'poly')
	AddDebuff('Repentance', nil, 'repentance')
	AddDebuff('Psychic Scream', nil, 'priestfear')
	AddDebuff('Howl of Terror', nil, 'howlofterror')
	AddDebuff('Freezing Trap Effect', nil, 'huntertrap')
	AddDebuff('Hungering Cold', nil, 'dktrap')
	AddBuff("Innervate")
elseif pName == 'Yatta' then
	AddBuff("Divine Intervention", nil, "di")
	AddBuff("Spirit of Redemption", nil, "angel") 
	AddBuff("Lifebloom", nil, "lifebloom", "player", nil, nil, false, false, "gradient")
	AddBuff("Rejuvenation", nil, "rejuv", "player", nil, nil, false, false, "gradient")
	AddBuff("Regrowth", nil, "regrowth", "player", nil, nil, false, false, "gradient")
	AddBuff("Wild Growth", nil, "wildgrowth", nil, nil, nil, false, false, "gradient", 1, 0, 0, 0, 1, 1)
	AddDebuff("Hex", nil, "hex", "dispel")
	AddDebuff("Curse of Tongues", nil, "cot", "dispel")
	AddDebuff("Wound Poison", 7, "wound", "dispel")
	AddDebuff("Viper Sting", nil, "viper", "dispel")
	AddDebuff("Crippling Poison", nil, "crippling", "dispel")
	AddBuff("Innervate")
	AddDebuff("Choking Gas", nil, "choking", nil, nil, nil, nil, false, false, 'color', 1, .5, .25)
else

end


