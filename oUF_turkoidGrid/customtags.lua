local parent = ...
local global = GetAddOnMetadata(parent, 'X-oUF')
local oUF = _G[global]
local config = turkoid.config
local PrintLine = config.helper.PrintLine
local utf8sub = config.helper.utf8sub

oUF.TagEvents["[centertext1]"] = "UNIT_NAME_UPDATE"
oUF.Tags["[centertext1]"]  = function(unit)
	if not unit then return "nil" end
	
	local raidID = config.helper.RaidFromPet(unit)
	local vehicleswap = config["raid"].vehicleswap
	if vehicleswap and raidID then
		return utf8sub(UnitName(raidID), 1, 7)
	else
		return utf8sub(UnitName(unit), 1, 7)
	end
end

oUF.TagEvents["[centertext2]"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_AURA"
oUF.Tags["[centertext2]"]  = function(unit)
	if not unit then return "nil" end
	
	local retval = oUF.Tags["[status]"](unit)
	if retval ~= "" then return retval end
	retval = UnitIsFeignDeath(unit)
	if retval then return "FD" end
	retval = UnitAura(unit, "Spirit of Redemption", nil, "HELPFUL")
	if retval then return "Spirit" end
	return oUF.Tags["[missinghp]"](unit)	
end