--[[

	THIS IS THE FLITER LIST FOR MISSING BUFFS
	
	Format: {buff1, buff2, ...} --brackets indicate a buff group
	
	The order in the list is its priorty.
	The first buff in the buffgroup is the texture used.
]]--

local config = turkoid.config
local _, playerClass = UnitClass("player")

if playerClass == "PRIEST" then
	config.missingbuffs = {
		{"Power Word: Fortitude", "Prayer of Fortitude"},
		{"Divine Spirit", "Prayer of Spirit"},		
		{"Shadow Protection", "Prayer of Shadow Protection"},
	}
elseif playerClass == "SHAMAN" then
elseif playerClass == "PALADIN" then
	config.missingbuffs = {
		{"Blessing of Kings", "Greater Blessing of Kings"},
		{"Blessing of Might", "Greater Blessing of Might"},
		{"Blessing of Sanctuary", "Greater Blessing of Sanctuary"},
		{"Blessing of Wisdom", "Greater Blessing of Wisdom"},
	}
elseif playerClass == "MAGE" then
	config.missingbuffs = {
		{"Arcane Intellect", "Arcane Brilliance", "Dalaran Intellect", "Dalaran Brilliance"},
	}
elseif playerClass == "DRUID" then
	config.missingbuffs = {
		{"Mark of the Wild", "Gift of the Wild"},
	}
elseif playerClass == "WARRIOR" then
	config.missingbuffs = {
		{"Commanding Shout"},
		{"Battle Shout"},		
	}
elseif playerClass == "WARLOCK" then	
elseif playerClass == "HUNTER" then	
elseif playerClass == "ROGUE" then	
elseif playerClass == "DEATHKNIGHT" then
	config.missingbuffs = {
		{"Horn of Winter"},
	}
end