local _, ns = ...
local oUF = ns.oUF or oUF
local config = turkoid.config
local Hex = config.helper.Hex
local ShortValues = config.helper.ShortValues
local MedValues = config.helper.MedValues
local formatDuration = config.helper.formatDuration
local HasAura = config.helper.HasAura
local PrintLine = config.helper.PrintLine
local utf8sub = config.helper.utf8sub

oUF.Tags["[curxp]"]  = function(unit)
	if not unit then return "nil" end
	return ShortValues(UnitXP(unit))
end

oUF.Tags["[maxxp]"]  = function(unit)
	if not unit then return "nil" end
	return ShortValues(UnitXPMax(unit))
end

oUF.TagEvents["[diffcolor]"] = oUF.TagEvents["[level]"]
oUF.Tags["[diffcolor]"]  = function(unit)
	if not unit then return "nil" end
	local level = UnitLevel(unit)
	return Hex(GetQuestDifficultyColor(level > 0 and level or 999))
end

oUF.Tags["[curhp]"]  = function(unit)
	if not unit then return "nil" end
	return ShortValues(UnitHealth(unit))
end

oUF.Tags["[maxhp]"]  = function(unit)
	if not unit then return "nil" end
	return ShortValues(UnitHealthMax(unit))
end

oUF.Tags["[missinghp]"] = function(unit)
	if not unit then return "nil" end
	local threshold = 0.01
	local max = UnitHealthMax(unit)
	local missing = max - UnitHealth(unit)
	return (missing - (threshold * max)) > 0 and (Hex(1, 0, 0).."-"..MedValues(missing).."|r") or ""
end

oUF.Tags["[curpp]"]  = function(unit)
	if not unit then return "nil" end
	return ShortValues(UnitPower(unit))
end

oUF.Tags["[maxpp]"]  = function(unit)
	if not unit then return "nil" end
	return ShortValues(UnitPowerMax(unit))
end

oUF.TagEvents["[druidcurpp]"] = "UNIT_MANA"
oUF.Tags["[druidcurpp]"]  = function()
	return ShortValues(UnitPower("player", 0))
end

oUF.TagEvents["[druidmaxpp]"] = "UNIT_MAXMANA"
oUF.Tags["[druidmaxpp]"]  = function()
	return ShortValues(UnitPowerMax("player", 0))
end

oUF.TagEvents["[druidform]"] = "UNIT_AURA"
oUF.Tags["[druidform]"]  = function(unit)
	if not unit then return "nil" end
	if select(2, UnitClass(unit)) ~= "DRUID" then return "" end
	
	local retval
	for form, formattedForm in pairs(config.druidforms) do
		if HasAura(unit, form, form == "Tree of Life" and "shapeshift" or nil, "helpful") then
			retval = formattedForm
			break
		end
	end
	
	return retval and "("..retval..")" or ""
end

oUF.TagEvents["[status]"] = "UNIT_HEALTH"
oUF.Tags["[status]"]  = function(unit)
	if not unit then return "nil" end
	local retval = ""
	
	if UnitIsDead(unit) then
		retval = "Dead"
	elseif UnitIsGhost(unit) then
		retval = "Ghost"
	elseif not UnitIsConnected(unit) then
		retval = "Offline"
	end
	return retval
end

oUF.TagEvents["[flags]"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags["[flags]"]  = function(unit)
	if not unit then return "nil" end
	local retval = ""	
	if UnitIsAFK(unit) then
		local afkStart = config.durations.afk[UnitName(unit)] or GetTime()
		config.durations.afk[UnitName(unit)] = afkStart
		retval = "<AFK ("..formatDuration(afkStart)..")>"
	elseif UnitIsDND(unit) then
		retval = "<DND>"
	end
	if not UnitIsAFK(unit) and config.durations.afk[UnitName(unit)] then
		config.durations.afk[UnitName(unit)] = nil
	end
	return retval
end

oUF.Tags["[classification]"]  = function(unit)
	if not unit then return "nil" end
	return config.classification[UnitClassification(unit)] or config.classification["normal"]
end

oUF.Tags["[classbase]"]  = function(unit)
	if not unit then return "nil" end
	local retval = ""
	if UnitIsPlayer(unit) or (UnitIsEnemy("player", unit) and not (UnitPlayerOrPetInParty(unit) and UnitPlayerOrPetInRaid(unit))) then
		retval = UnitClassBase(unit) or ""		
	end
	return retval 
end

oUF.Tags["[classcolor]"]  = function(unit)
	if not unit then return "nil" end
	local class = UnitClassBase(unit) and strupper(gsub(UnitClassBase(unit), "%s", "")) or "NO_CLASS"
	return Hex(oUF.colors.class[class] or config.font.color)
end

oUF.Tags["[SmartRace]"]  = function(unit)
	if not unit then return "nil" end
	local retval = ""
	if UnitIsPlayer(unit) then
		retval = UnitRace(unit)
	else
		retval = UnitCreatureFamily(unit) or UnitCreatureType(unit) or _G.UNKNOWN
	end
	return retval
end

oUF.TagEvents["[SmartHP]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["[SmartHP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[status]"](unit)	
	if retval == "" then
		retval = oUF.Tags["[curhp]"](unit).."/"..oUF.Tags["[maxhp]"](unit)
	end
	return retval
end

oUF.TagEvents["[SmartFullHP]"] = oUF.TagEvents["[SmartHP]"]
oUF.Tags["[SmartFullHP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[status]"](unit)
	if retval == "" then
		retval = oUF.Tags["[curhp]"](unit).."/"..oUF.Tags["[maxhp]"](unit).." | "..oUF.Tags["[perhp]"](unit).."%"
	end
	return retval
end

oUF.TagEvents["[SmartFullMissingHP]"] = oUF.TagEvents["[SmartHP]"]
oUF.Tags["[SmartFullMissingHP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[status]"](unit)
	if retval == "" then
		retval = oUF.Tags["[curhp]"](unit).."/"..oUF.Tags["[maxhp]"](unit).." | "
		local missing = oUF.Tags["[missinghp]"](unit)
		if UnitCanAssist("player", unit) and missing ~= "" then
			retval = retval..missing			
		else
			retval = retval..oUF.Tags["[perhp]"](unit).."%"
		end
	end
	return retval
end

oUF.TagEvents["[SmartPercHP]"] = oUF.TagEvents["[SmartHP]"]
oUF.Tags["[SmartPercHP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[status]"](unit)
	
	if retval == "" then
		retval = oUF.Tags["[perhp]"](unit).."%"
	end
	return retval
end

oUF.TagEvents["[SmartPP]"] = "UNIT_HEALTH UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER"
oUF.Tags["[SmartPP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[curpp]"](unit).."/"..oUF.Tags["[maxpp]"](unit)
	return (oUF.Tags["[status]"](unit) == "" and UnitPowerMax(unit) > 0) and retval or ""
end

oUF.TagEvents["[SmartFullPP]"] = oUF.TagEvents["[SmartPP]"]
oUF.Tags["[SmartFullPP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[curpp]"](unit).."/"..oUF.Tags["[maxpp]"](unit).." | "..oUF.Tags["[perpp]"](unit).."%"
	return (oUF.Tags["[status]"](unit) == "" and UnitPowerMax(unit) > 0) and retval or ""
end

oUF.TagEvents["[SmartPercPP]"] = oUF.TagEvents["[SmartPP]"]
oUF.Tags["[SmartPercPP]"]  = function(unit)
	if not unit then return "nil" end
	local retval = oUF.Tags["[perpp]"](unit).."%"
	return (oUF.Tags["[status]"](unit) == "" and UnitPowerMax(unit) > 0) and retval or ""
end