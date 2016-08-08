local config = turkoid.config
local UnitAura, GetTime = UnitAura, GetTime
local floor, ceil = floor, ceil
local red, green, yellow = "|cffff0000", "|cff00ff00", "|cffffff00"

config.helper = {
	Hex = function(r, g, b)
		if type(r) == "table" then
			if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
	end,
	
	ShortValues = function(value)
		if(value >= 1e6) then
			return gsub(format('%.2fM', value / 1e6), '%.?0+([km])$', '%1')
		elseif(value >= 1e5) then
			return gsub(format('%.1fK', value / 1e3), '%.?0+([km])$', '%1')
		else
			return value
		end
	end,
	
	MedValues = function(value)
		if(value >= 1e6) then
			return gsub(format('%.2fM', value / 1e6), '%.?0+([km])$', '%1')
		elseif(value >= 1e3) then
			return gsub(format('%.1fK', value / 1e3), '%.?0+([km])$', '%1')
		else
			return value
		end
	end,
	
	formatDuration = function(t)	
		if t then
			local duration = abs(GetTime() - t)
			local h = floor(duration / 3600)
			local m = floor(mod(duration / 60, 60))
			local s = floor(mod(duration, 60))
			if duration >= 3600 then
				return format("%d:%.2d:%.2d", h, m, s)
			else
				return format("%d:%.2d", m, s)
			end
		end
		return ""
	end,
	
	formatCooldown = function(expTime)
		local t = GetTime()
		if expTime and expTime > t then
			local cooldown = ceil(expTime - t)
			if cooldown + 60 > 3600 then
				return format("%dh", ceil(cooldown / 3600))
			elseif cooldown >= 60 then
				return format("%dm", ceil(mod(cooldown / 60, 60)))
			elseif cooldown > 5 then
				return format("%s%d|r", yellow, cooldown)
			elseif cooldown > 0 then
				return format("%s%d|r", red, cooldown)
			end
		end
		return ""
	end,
	
	formatAuraTimer = function(expTime)
		local t = GetTime()
		if expTime and expTime > t then
			local duration = floor(expTime - t + .5)
			local h, m, s
			if duration >= 3600 then
				h = floor((duration + 30) / 3600)
				m = floor(mod((duration + 30) / 60, 60))
				
				return format("%d:%.2d", h, m)
			elseif duration >= 0 then
				m = floor(mod(duration / 60, 60))
				s = floor(mod(duration, 60))
				
				return format("%d:%.2d", m, s)
			end
		end
		return ""
	end,
	
	PrintLine = function(...)
		local txt, counter
		local retval = ""
		for i = 1, select("#", ...) do
			txt = select(i, ...)
			if type(txt) == "table" then
				retval = retval..green..format("[%d]|r TABLE: ", i)
				counter = 1
				for k, v in pairs(txt) do
					retval = retval..red..format("[%d]|r %s ", counter, tostring(v))
					counter = counter + 1
					if counter > 10 then break end
				end
			else
				retval = retval..green..format("[%d]|r %s", i, tostring(txt))
			end			
		end
		if retval == "" then retval = red.."NOTHING TO PRINT|r" end
		DEFAULT_CHAT_FRAME:AddMessage(retval)
	end,
	
	utf8sub = function(str, start, numChars)
		local currentIndex = start
		while numChars > 0 and currentIndex <= #str do
			local char = string.byte(str, currentIndex)
			if char > 240 then
				currentIndex = currentIndex + 4
			elseif char > 225 then
				currentIndex = currentIndex + 3
			elseif char > 192 then
				currentIndex = currentIndex + 2
			else 
				currentIndex = currentIndex + 1
			end
			numChars = numChars -1
		end
		return str:sub(start, currentIndex - 1)
	end,

	formattedUnit = function(unit)
		if not unit then 
			unit = "error"
		elseif unit:find("party") then
			if unit:find("pet") then
				unit = "partypet"
			elseif unit:find("target") then
				unit = "partytarget"
			else
				unit = "party"
			end
		elseif unit:find("raid") then
			if unit:find("pet") then
				unit = "raidpet"
			elseif unit:find("target") then
				unit = "raidtarget"
			else
				unit = "raid"
			end
		elseif unit:find("boss") then
			unit = "boss"
		end
		return unit
	end,
	
	HasAura = function(unit, name, rank, filter)
		return UnitAura(unit, name, rank, strupper(filter)) and true or false
	end,
	
	SpellTexture = function(name)
		local _, _, texture = GetSpellInfo(name)
		return texture
	end,
	
	HideStatus = function(status, unit)
		if not config.statuses[status].hide then return end
		
		local checkVal
		for _, check in ipairs(config.statuses[status].hide) do
			if config.statuses[check] then
				checkVal = config.statuses[check]:func(unit)
				if checkVal or checkVal == "" then return true end
			end
		end
	end,
	
	RaidFromPet = function(petID) 
		if not petID then return end
		local raidID = petID:match("raidpet(%d+)")
		return raidID and "raid"..raidID
	end,
	
	PetFromRaid = function(raidID)
		if not raidID then return end
		local petID = raidID:match("raid(%d+)")
		return petID and "raidpet"..petID
	end,
		
	IsValidRGB = function(...)
		for i = 1, 3 do
			local val = select(i, ...)
			if type(val) ~= "number" then return end
			if i < 0 or i > 255 then return end
		end
		return true
	end, 

	FindUnitAura = function(self, unit, name, maxRank, filter)		
		if self and self.filter == "dispel" and filter == "buff" then return end
		filter = filter == "buff" and "HELPFUL" or "HARMFUL"		
		if self then
			if self.filter == "player" then
		 		filter = filter.."|PLAYER"
		 	elseif self.filter == "dispel" then
		 		filter = filter.."|RAID"
			end
		end		
		local found = UnitAura(unit, name, nil, filter)
		local rank = 2		
		while not found and maxRank and rank <= maxRank do
			found = UnitAura(unit, name.." "..config.roman[rank], nil, filter)
			if found then name = name.." "..config.roman[rank] end
			rank = rank + 1
		end
		if found then
			return UnitAura(unit, name, nil, filter)
		end		
	end, 

	AddAura = function(auraType, auraName, maxRank, alias, filter, hideStatuses, events, showCount, showDuration, statusType, r1, g1, b1, r2, g2, b2)
		if not auraName then return end
		auraType = (auraType == "buff" or auraType == "debuff") and auraType or "debuff"
		filter = (filter == "dispel" or filter == "player") and filter
		alias = auraType..":"..(alias or strlower(auraName))
		
		local statusConfig = config.statuses[alias]
		if not statusConfig then
			statusConfig = {}
			statusConfig.events = {"UNIT_AURA"}
			
			if events then
				events = " "..events.." "
				for event in events:gmatch("%s(.+)%s") do
					if event ~= "UNIT_AURA" then table.insert(statusConfig.events, event) end
				end
			end
			statusConfig.func = function(self, unit) return config.helper.FindUnitAura(self, unit, auraName, maxRank, auraType) end
			if statusType == "gradient" then				
				if not config.helper.IsValidRGB(r1, g1, b1) then
					r1, g1, b1 = 1, 0, 0
				end
				if not config.helper.IsValidRGB(r2, g2, b2) then
					r2, g2, b2 = 0, 1, 0
				end
				statusConfig.gradient = {r1, g1, b1, r2, g2, b2}
			elseif statusType == "color" then
				if not config.helper.IsValidRGB(r1, g1, b1) then
					r1, g1, b1 = 0, 1, 0
				end
				statusConfig.color = {r1, g1, b1}
			else
				statusConfig.texture = true
			end
			if showCount then statusConfig.showCount = true end
			if showDuration then statusConfig.showDuration = true end
			if filter then	statusConfig.filter = filter end
			if hideStatuses then				
				for status in hideStatuses:gmatch("%s(.+)%s") do
					if not statusConfig.hide then statusConfig.hide = {} end
					table.insert(statusConfig.hide, status)
				end
			end
			
			config.statuses[alias] = statusConfig
			return alias
		end
	end, 

	AddBuff = function(...)
		return config.helper.AddAura("buff", ...)
	end,
	
	AddDebuff = function(...)
		return config.helper.AddAura("debuff", ...)
	end,	
}