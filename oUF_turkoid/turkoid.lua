-- localizing functions
local select, ipairs, pairs = select, ipairs, pairs
local UnitAura, UnitName, UnitPower, UnitPowerMax, UnitPowerType, UnitExists, UnitCanAttack, UnitHasVehicleUI, UnitClass = 
	UnitAura, UnitName, UnitPower, UnitPowerMax, UnitPowerType, UnitExists, UnitCanAttack, UnitHasVehicleUI, UnitClass
local GetTime = GetTime
	
--localizing
local _, ns = ...
local oUF = ns.oUF or oUF
local config = turkoid.config
local colors = oUF.colors
local PrintLine = config.helper.PrintLine
local formattedUnit = config.helper.formattedUnit
local formatDuration = config.helper.formatDuration
local HideStatus = config.helper.HideStatus

config.backdropTable = {
	bgFile = config.background.texture, 
	edgeFile = config.border and config.border.texture,
	edgeSize = config.border and config.border.size or 0,
	tile = config.background.tile, 
	tileSize = config.background.tilesize,
	insets = {
		left = config.background.insets.left, 
		right = config.background.insets.right, 
		top = config.background.insets.top, 
		bottom = config.background.insets.bottom,
	},
}
config.iconBG = {
	edgeFile = "Interface\\Addons\\MyMedia\\whiteborder",
	edgeSize = 1,
	tile = true, 
	tileSize = 8,
	insets = {
		left = 0, 
		right = 0, 
		top = 0, 
		bottom = 0,
	},
}

-- This is the core of RightClick menus on diffrent frames
-- Raid unit menu code based off GridUnitMenu
local init = function(self)
	local unit = self.unit or "player"
	if UnitIsUnit(unit, "player") then
		return UnitPopup_ShowMenu(self, "SELF", unit, UnitName(unit), UnitInRaid(unit))
	end
	UnitPopup_ShowMenu(self, "RAID_PLAYER", unit, UnitName(unit), UnitInRaid(unit))
end

local attschanged = function(self)
	local unit = self:GetAttribute("unit") or "player";
	if self.raidmenu.unit ~= unit then
		self.raidmenu.unit = unit;
		UIDropDownMenu_Initialize(self.raidmenu, init, "MENU");
	end
end

local function menu(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	
	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	else
		if not self.raidmenu then
			self.raidmenu = CreateFrame("frame","oUF_Menu_"..self:GetName(),UIParent,"UIDropDownMenuTemplate");
			self:HookScript("OnAttributeChanged", attschanged);
			self:SetAttribute("type2", "menu");
		end
		ToggleDropDownMenu(1, nil, self.raidmenu, "cursor")
	end
end

--[[ UPDATE FUNCTIONS ]]--
local function updateDruidMana(self, event, unit)
	if not self.DruidMana or self.unit ~= "player" then return end
	
	local min, max = UnitPower("player", 0), UnitPowerMax("player", 0)
	self.DruidMana:SetStatusBarColor(unpack(colors.power.MANA))
	self.DruidMana:SetMinMaxValues(0, max)
	self.DruidMana:SetValue(min)
	self.DruidMana:SetAlpha(UnitPowerType("player") == 0 and 0 or 1)
end

local function updatePower(self, event, unit, bar, min, max) --copy of oUFs power with a few additions
	if unit and self.unit ~= unit then return end
	local r, g, b, t
	
	if (bar.colorNoPower and max == 0) then
		t = self.colors.nopower
		bar:SetValue(0)
	elseif (bar.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		t = self.colors.tapped
	elseif (bar.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
		bar:SetValue(0)
	elseif (bar.colorGhost and UnitIsGhost(unit)) then
		t = self.colors.ghost
		bar:SetValue(0)
	elseif (bar.colorDead and UnitIsDead(unit)) then
		t = self.colors.dead
		bar:SetValue(0)
	elseif (bar.colorHappiness and unit == "pet" and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif (bar.colorPower) then
		local ptype
		_, ptype, r, g, b = UnitPowerType(unit)
		if self.colors.power[ptype] then				
			t = self.colors.power[ptype]
		end
	elseif (bar.colorClass and UnitIsPlayer(unit)) or
		(bar.colorClassNPC and not UnitIsPlayer(unit)) or
		(bar.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif (bar.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif (bar.colorSmooth) then
		r, g, b = self.ColorGradient(min / max, unpack(bar.smoothGradient or self.colors.smooth))
	end
	
	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	r = r or 1
	g = g or 1
	b = b or 1
	
	if(b) then
		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
	
	if config[self.configUnit].powerbar.manaonly then
		local powertype, unitstatus = UnitPowerType(self.unit), oUF.Tags["[status]"](self.unit)		
		if powertype == 0 and unitstatus == "" then
			bar:SetAlpha(1)
			self.Health:SetHeight(config[self.configUnit].healthbar.height)
		else
			bar:SetAlpha(0)
			self.Health:SetHeight(config[self.configUnit].height - (2 * self.offset))
		end
	end
	if config.helper.HasAura(self.unit, "Spirit of Redemption", nil, "helpful") then bar:SetValue(0) end
	if bar.value then bar.value:UpdateTag() end
	if self.UnitInfo then
		self.UnitInfo:SetWidth(self:GetWidth() - bar.value:GetStringWidth() - config.textoffset * 3)
	end
	if self.DruidMana and self.unit == "player" then updateDruidMana(self, event, unit) end
end

local function updateHealth(self, event, unit, bar, min, max) --copy of oUFs health with a few additions
	if unit and self.unit ~= unit then return end
	local r, g, b, t
	
	if (bar.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitPlayerControlled(unit)) then
		t = self.colors.tapped
	elseif (bar.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
		bar:SetValue(0)
	elseif (bar.colorGhost and UnitIsGhost(unit)) then
		t = self.colors.ghost
		bar:SetValue(0)
	elseif (bar.colorDead and UnitIsDead(unit)) then
		t = self.colors.dead
		bar:SetValue(0)
	elseif (bar.colorHappiness and unit == "pet" and GetPetHappiness()) then
		t = self.colors.happiness[GetPetHappiness()]
	elseif (bar.colorClass and UnitIsPlayer(unit)) or
		(bar.colorClassNPC and not UnitIsPlayer(unit)) or
		(bar.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif (bar.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif (bar.colorSmooth and max ~= 0) then
		r, g, b = self.ColorGradient(min / max, unpack(bar.smoothGradient or self.colors.smooth))
	elseif (bar.colorHealth) then
		t = self.colors.health
	end
	
	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
	
	if config.helper.HasAura(self.unit, "Spirit of Redemption", nil, "helpful") then bar:SetValue(0) end
	if bar.value then bar.value:UpdateTag() end
	if self.Name then
		self.Name:SetWidth(self:GetWidth() - bar.value:GetStringWidth() - config.textoffset * 3)
	end
end

--cuz blizz is stupid and doesnt always create the petunit when u have ENTERED! a vehicle
local blizzhate = CreateFrame("frame")

local ghostUnits = {}
local updateVehicleSwitch
local function checkUnitExists(self, elapsed)
	if #ghostUnits == 0 then blizzhate:SetScript("OnUpdate", nil) return end
	local idx, raidUnit = 1
	while ghostUnits[idx] do
		raidUnit = ghostUnits[idx]
		if not UnitExists(raidUnit) then
			table.remove(ghostUnits, idx)
		elseif UnitExists(config.helper.PetFromRaid(raidUnit)) then
			table.remove(ghostUnits, idx)
			updateVehicleSwitch(oUF.units[raidUnit], nil, raidUnit)
		else
			idx = idx + 1
		end
	end
end

local function updateDebuffHighlight(self, event, unit)	
	if not self.Highlight then return end
	if unit and self.unit ~= unit then return end
	if UnitCanAttack("player", self.unit) then 
		self.Highlight.texture:SetVertexColor(0, 0, 0, 0)
		return
	end
	local found, debufftype, color
	
	color = DebuffTypeColor[self.Highlight.overrideDebuffType]
		
	local index = 1
	while not color do
		found, _, _, _, debuffType = UnitAura(self.unit, index, "HARMFUL|RAID")
		if not found then break end
		if debuffType and config.canDispel[debuffType] then	
			color = DebuffTypeColor[debuffType]			
		end
		index = index + 1
	end
	if color then
		self.Highlight.texture:SetVertexColor(color.r, color.g, color.b, self.Highlight.alpha or 1)
	else
		self.Highlight.texture:SetVertexColor(0, 0, 0, 0)
	end
end

local function ResetRaidFrame(self)
	local icon
	for loc in pairs(config.reset) do
		if loc == "border" then 
			self:SetBackdropBorderColor(0, 0, 0, 0)
		elseif not config[self.configUnit].indicators[loc] then
			icon = self.IconFrame[loc]
			icon:Hide()
			if icon.cd then icon.cd:Hide() end
			if icon.count then icon.count:Hide() end
		end
	end		
	if self.Highlight then self.Highlight.overrideDebuffType = nil end
	updateDebuffHighlight(self)
end

updateVehicleSwitch = function(self, event, unit)
	local petUnit = config.helper.PetFromRaid(unit)
	if self.unit ~= unit and self.unit ~= petUnit then return end
	
	if (UnitHasVehicleUI(unit) or event == "UNIT_ENTERED_VEHICLE") and self.unit ~= petUnit then
		if UnitExists(petUnit) then
			self.unit = petUnit
			self.configUnit = "raidvehicle"
			ResetRaidFrame(self)
			self:PLAYER_ENTERING_WORLD()
		else
			--i hate u blizz
			table.insert(ghostUnits, unit)
			if not blizzhate:GetScript("OnUpdate") then blizzhate:SetScript("OnUpdate", checkUnitExists) end
		end
	elseif event == "UNIT_EXITING_VEHICLE" and self.unit ~= unit then
		self.unit = unit
		self.configUnit = "raid"
		ResetRaidFrame(self)
		self:PLAYER_ENTERING_WORLD()
	end
end

local function updateIndicator(icon, event)
	local unit = icon.parent.unit	
	local unitConfig = config[icon.parent.configUnit]
	local showStatus, rank, iconTexture, count, debuffType, duration, expirationTime, unitCaster, isStealable	
	if icon.delay and icon.delay <= 0 then icon.delay = nil end
	if not unitConfig.indicators[icon.loc] then return end
	for _, status in ipairs(unitConfig.indicators[icon.loc].statuses) do
		if not HideStatus(status, unit) then
			showStatus, rank, iconTexture, count, debuffType, duration, expirationTime, unitCaster, isStealable = config.statuses[status]:func(unit, event, icon)
			if showStatus or icon.delay then
				statusConfig = config.statuses[status]
				break
			end
		end		
	end
	--UnitAura return values = [1]name, [2]rank, [3]iconTexture, [4]count, [5]debuffType, [6]duration, [7]expires, [8]unitCaster, [9]isStealable
	
	icon.update = icon.delay or false
	if icon.cd then icon.cd:Hide() end
	if icon.count then icon.count:Hide() end	
	if showStatus then		
		if statusConfig.texture then
			icon.texture:SetTexture(iconTexture)
			icon.texture:SetTexCoord(.07, .93, .07, .93)	
		elseif statusConfig.gradient then
			local threshold = 1 --so that it stays the min color for at least a GCD
			local r, g, b
			
			if (expirationTime and expirationTime > 0) and (duration and duration > 0) then
				local timeLeft = expirationTime - GetTime() - threshold
				if timeLeft > 0 then
					r, g, b = oUF.ColorGradient(timeLeft / duration, unpack(statusConfig.gradient))	
					icon.update = true
				else
					r, g, b = unpack(statusConfig.gradient)
				end
			else
				r, g, b = select(4, unpack(statusConfig.gradient))
			end
			icon.texture:SetTexture(r, g, b)
		elseif statusConfig.color then
			icon.texture:SetTexture(unpack(statusConfig.color))			
		else
			PrintLine("ERROR - No way to indicate for ["..status.."]")
		end
		if statusConfig.showCount and count and count > 0 then
			icon.count:SetText(count)
			icon.count:Show()
		end
		if statusConfig.showDuration then
			local timeLeft = config.helper.formatCooldown(expirationTime)
			if timeLeft ~= "" then
				icon.cd:SetText(timeLeft)
				icon.cd:Show()
				icon.update = true
			end
		end
		icon:Show()
	elseif not icon.delay then
		icon:Hide()
		icon.update = false
	end
	
	if icon.loc == "center" and icon.parent.Highlight then
		debuffType = config.canDispel[debuffType] and debuffType
		if icon.parent.Highlight.overrideDebuffType ~= debuffType then
			icon.parent.Highlight.overrideDebuffType = debuffType
			updateDebuffHighlight(icon.parent)
		end
	end
	
	if icon.update then
		for _, v in ipairs(config.updateIcons) do
			if v == icon then return end
		end
		table.insert(config.updateIcons, icon)
	else
		for k, v in ipairs(config.updateIcons) do
			if v == icon then 
				table.remove(config.updateIcons, k)
				return 
			end
		end
	end
end

local function updateBorder(self, event)
	local showStatus, statusConfig
	for _, status in ipairs(config[self.configUnit].border.statuses) do
		if not HideStatus(status, self.unit) then
			showStatus = config.statuses[status]:func(self.unit)
			if showStatus then
				statusConfig = config.statuses[status]
				break
			end
		end
	end
	if showStatus then
		self:SetBackdropBorderColor(unpack(statusConfig.color))
	else
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end		
end

local function updateStatuses(self, event, unit)
	if not self.Border and not self.Indicators then return end
	if event then
		if event:find("READY") then unit = nil end
		if event:find("REGEN") then config.InCombat = event:find("DISABLED") end
	end
	if unit and self.unit ~= unit then return end
	local unitConfig = config[self.configUnit]
	
	if unitConfig.events[event] then
		for loc in pairs(unitConfig.events[event]) do
			if loc == "border" then
				updateBorder(self)
			else	
				updateIndicator(self.IconFrame[loc], event)
			end
		end
	else
		for loc in pairs(unitConfig.indicators) do
			updateIndicator(self.IconFrame[loc], event)
		end
		updateBorder(self)
	end
end

local function updateGroupIcons(self)
	local offset = self.offset
	
	if self.Leader and self.Leader:IsShown() then
		self.Leader:ClearAllPoints()
		self.Leader:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", offset, self.offset)
		offset = offset + self.Leader:GetWidth() + 1
	end
	if self.Assistant and self.Assistant:IsShown() then
		self.Assistant:ClearAllPoints()
		self.Assistant:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", offset, self.offset)
		offset = offset + self.Assistant:GetWidth() + 1
	end
	if self.LFDRole and self.LFDRole:IsShown() then
		self.LFDRole:ClearAllPoints()
		self.LFDRole:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", offset, self.offset)
		offset = offset + self.LFDRole:GetWidth() + 1
	end
	if self.MasterLooter and self.MasterLooter:IsShown() then
		self.MasterLooter:ClearAllPoints()
		self.MasterLooter:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", offset, self.offset)
		offset = offset + self.MasterLooter:GetWidth() + 1
	end
end
	
config.lastUpdate = 0
config.updateIcons = {}
local function UpdateObjects(self, elapsed)
	local index = 1
	config.lastUpdate = config.lastUpdate + elapsed
	if config.lastUpdate >= 0.1 then
		local icon
		while config.updateIcons[index] do		
			icon = config.updateIcons[index]
			if icon.delay then
				icon.delay = icon:IsVisible() and (icon.delay - config.lastUpdate) or nil
			end
			updateIndicator(icon)
			index = index + 1
		end
		config.lastUpdate = 0
	end
end
turkoid:SetScript("OnUpdate", UpdateObjects)

local function getFontString(parent)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	local size = config.font.size
	if size > parent:GetHeight() then
		size = parent:GetHeight()
	end
	fs:SetFont(config.font.name, size)
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1, -1)
	fs:SetJustifyV("CENTER")
	fs:SetTextColor(config.font.color.r, config.font.color.g, config.font.color.b)
	fs:SetHeight(size)
	return fs
end

local function OnEnter(self)
	UnitFrame_OnEnter(self)
end

local function OnLeave(self)
	UnitFrame_OnLeave()
end

local function ApplyTags(self, fs, tags)
	if tags:match("[flags]") then	
		if not config.durations then 
			config.durations = {}
			config.durations.afk = {}
		end
		fs.frequentUpdates = .5
	end
	self:Tag(fs, tags)
end	

local RegisterStatuses
RegisterStatuses = function(self, unit, loc, hideStatuses)
	local unitConfig = config[unit]
	local statuses = hideStatuses or (unitConfig[loc] and unitConfig[loc].statuses) or unitConfig.indicators[loc].statuses
	
	local statusConfig
	for i, status in ipairs(statuses) do
		statusConfig = config.statuses[status]
		if statusConfig then
			if not unitConfig.events then unitConfig.events = {} end
			if not config.reset then config.reset = {} end
			for _, event in ipairs(statusConfig.events) do
				if not unitConfig.events[event] then unitConfig.events[event] = {} end
				unitConfig.events[event][loc] = true
				config.reset[loc] = true
				self:RegisterEvent(event, updateStatuses)
			end
			if statusConfig.hide then
				RegisterStatuses(self, unit, loc, statusConfig.hide)
			end
		else
			table.remove(statuses, i)
			PrintLine('ERROR - Status not found!: '..status..' (Loc='..loc..'; Unit='..unit..')') 
		end
	end
end

local function setStyle(self, unit)
	self.configUnit = formattedUnit(unit or strlower(self:GetName()))
	
	local unitConfig = config[self.configUnit]	
	if not unitConfig then 
		PrintLine("ERROR - No Config for this frame: "..self:GetName())
		return self
	end	
	self.offset = config.border.size + (unitConfig.border and 1 or 0)	
	
	-- FRAME ATTRIBUTES
	self.menu = menu -- Enable the menus
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self:SetAttribute("*type2", "menu")
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetAttribute("initial-height", unitConfig.height)
	self:SetAttribute("initial-width", unitConfig.width)
	self:SetAttribute("alt-type1", "focus")
	-- VEHICLE SWAP
	if unitConfig.vehicleswap and self.configUnit == "raid" and config["raidvehicle"] then
		self.disallowVehicleSwap = true;
		table.insert(self.__elements, updateVehicleSwitch)
		self:RegisterEvent("UNIT_ENTERED_VEHICLE", updateVehicleSwitch)
		self:RegisterEvent("UNIT_EXITING_VEHICLE", updateVehicleSwitch)
	end
	
	-- BACKGROUND
	if config.background then
		config.backdropTable.edgeFile = unitConfig.border and config.border.texture or nil
		config.backdropTable.edgeSize = unitConfig.border and unitConfig.border.size or config.border.size or 0
		self:SetBackdrop(config.backdropTable)
		self:SetBackdropColor(0, 0, 0, config.background.alpha or 1)
		
		-- BORDER
		if unitConfig.border then 
			self:SetBackdropBorderColor(0, 0, 0, 1) 
			RegisterStatuses(self, self.configUnit, "border")
			if self.configUnit == "raid" and unitConfig.vehicleswap and config.raidvehicle then		
				RegisterStatuses(self, "raidvehicle", "border")
			end

			table.insert(self.__elements, updateStatuses)
			self.Border = true
		end
	end
	
	-- HEALTH BAR
	if unitConfig.healthbar then
		local hp = CreateFrame("StatusBar", nil, self)
		hp:SetHeight(unitConfig.healthbar.height)
		hp:SetStatusBarTexture(config.statusbar)
		hp:SetPoint("TOPLEFT", self, "TOPLEFT", self.offset, -self.offset)
		hp:SetPoint("TOPRIGHT", self, "TOPRIGHT", -self.offset, -self.offset)
		hp:SetOrientation(unitConfig.healthbar.orientation or "HORIZONTAL")
		
		hp.bg = hp:CreateTexture(nil, "BORDER")
		hp.bg:SetAllPoints(hp)
		hp.bg:SetTexture(config.statusbar)
		hp.bg.multiplier = .3
		
		hp.colorClass = true
		hp.colorReaction = true
		hp.colorTapping = true
		--hp.colorDead = true
		--hp.colorGhost = true
		hp.frequentUpdates = true

		self.Health = hp
		self.OverrideUpdateHealth = updateHealth
	end

	-- POWERBAR
	if unitConfig.powerbar then
		local pp = CreateFrame("StatusBar", nil, self)
		pp:SetHeight(unitConfig.powerbar.height)
		pp:SetStatusBarTexture(config.statusbar)		
		pp:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, 0)
		pp:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
	
		pp.bg = pp:CreateTexture(nil, "BORDER")
		pp.bg:SetAllPoints(pp)
		pp.bg:SetTexture(config.statusbar)
		pp.bg.multiplier = .3
		pp.frequentUpdates = true
				
		pp.colorPower = true
		pp.colorNoPower = true
		pp.colorDead = true
		pp.colorGhost = true
		
		self.Power = pp
		self.OverrideUpdatePower = updatePower
		
		--POWER SPARK
		if unitConfig.powerspark and unit == "player" then
			local spark = pp:CreateTexture(nil, "OVERLAY")
			spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			spark:SetVertexColor(1, 1, 1, 0.5)
			spark:SetBlendMode("ADD")
			spark:SetHeight(pp:GetHeight()*2)
			spark:SetWidth(pp:GetHeight())
			self.Spark = spark
		end
	end
	
	-- DRUIDMANA BAR
	local _, unitClass = UnitClass("player")
	if unitConfig.druidbar and unit == "player" and unitClass == "DRUID" then
		local druidpp = CreateFrame("StatusBar", nil, self)
		druidpp:SetHeight(unitConfig.druidbar.height)
		druidpp:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		druidpp:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.offset, self.offset)
		druidpp:SetStatusBarTexture(config.statusbar)
		druidpp:SetStatusBarColor(unpack(colors.power.MANA))
		
		druidpp.bg = druidpp:CreateTexture(nil, "BORDER")
		druidpp.bg:SetAllPoints(druidpp)
		druidpp.bg:SetTexture(config.statusbar)
		druidpp.bg:SetVertexColor(colors.power.MANA[1] * .3, colors.power.MANA[2] * .3, colors.power.MANA[3] * .3)
		
		druidpp.value = getFontString(druidpp)
		druidpp.value:SetFont(config.font.name, unitConfig.druidbar.fontsize or config.font.size)
		druidpp.value:SetJustifyH("RIGHT")
		druidpp.value:SetPoint("RIGHT", druidpp, "RIGHT", -config.textoffset, 1)
		
		ApplyTags(self, druidpp.value, unitConfig.texts.druidpower)
		self:RegisterEvent("UNIT_MANA", updateDruidMana)
		self.DruidMana = druidpp
	end
	
	--EXPERIENCE BAR
	local level = UnitLevel("player")
	if unitConfig.experience and unit=="player" and level ~= MAX_PLAYER_LEVEL then
		local xpbar = CreateFrame("StatusBar", nil, self)
		xpbar:SetHeight(unitConfig.experience.height)
		xpbar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		xpbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.offset, self.offset)
		xpbar:SetStatusBarTexture(config.statusbar)
		xpbar:SetStatusBarColor(unpack(colors.experience))
		
		local restbar = CreateFrame("StatusBar", nil, self)
		restbar:SetHeight(unitConfig.experience.height)
		restbar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		restbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.offset, self.offset)
		restbar:SetStatusBarTexture(config.statusbar)
		restbar:SetStatusBarColor(unpack(colors.rested))
		
		xpbar.value = getFontString(xpbar)
		xpbar.value:SetFont(config.font.name, unitConfig.experience.fontsize or config.font.size)
		xpbar.value:SetJustifyH("RIGHT")
		xpbar.value:SetPoint("RIGHT", xpbar, "RIGHT", -config.textoffset, 1)
		
		ApplyTags(self, xpbar.value, unitConfig.texts.experience)
		self.Experience = xpbar
		self.Experience.Rested = restbar
		self.Experience.Tooltip = true
	end
	
	-- COMBOPOINTS
	if unitConfig.combopoints then
		self.CPoints = {}
		for i = 1, 5 do
			local cpoint = self:CreateTexture(nil, "ARTWORK")
			cpoint:SetTexture(config.combopoints)
			cpoint:SetTexCoord(0, 0.5, 0, 1)
			cpoint:SetHeight(10)
			cpoint:SetWidth(10)
			cpoint:SetVertexColor(colors.combopoints[1], colors.combopoints[2], colors.combopoints[3], 1)
			if i == 1 then
				cpoint:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.offset, (1 + self.offset))
			else
				cpoint:SetPoint("RIGHT", self.CPoints[i-1], "LEFT", -1, 0)
			end
			self.CPoints[i] = cpoint
		end
		self.CPoints.unit = PlayerFrame.unit
	end
	
	-- DEBUFF HIGHLIGHTING
	if unitConfig.debuffhighlight and config.canDispel then
		local highlight = CreateFrame("frame", nil, self.Health)
		local highlightTexture = highlight:CreateTexture(nil, "OVRELAY")
		highlightTexture:SetAllPoints(self)
		highlightTexture:SetTexture(config.debuffhighlight.texture)
		highlightTexture:SetBlendMode("ADD")
		highlightTexture:SetVertexColor(0, 0, 0, 0)
		highlight.alpha = config.debuffhighlight.alpha
		highlight.texture = highlightTexture
		self.Highlight = highlight
		
		table.insert(self.__elements, updateDebuffHighlight)
		self:RegisterEvent("UNIT_AURA", updateDebuffHighlight)
	end
	
	-- NAME TEXT
	if unitConfig.texts.name then
		self.Name = getFontString(self.Health)
		self.Name:SetJustifyH("LEFT")
		self.Name:SetPoint("LEFT", self.Health, "LEFT", config.textoffset, 0)

		ApplyTags(self, self.Name, unitConfig.texts.name)
	end
	
	-- UNITINFO TEXT
	if unitConfig.texts.unitinfo then
		self.UnitInfo = getFontString(self.Power)
		self.UnitInfo:SetJustifyH("LEFT")
		self.UnitInfo:SetPoint("LEFT", self.Power, "LEFT", config.textoffset, 0)
		
		ApplyTags(self, self.UnitInfo, unitConfig.texts.unitinfo)
	end
	
	-- HP TEXT
	if unitConfig.texts.health then
		self.Health.value = getFontString(self.Health)
		self.Health.value:SetJustifyH("RIGHT")
		self.Health.value:SetPoint("RIGHT", self.Health, "RIGHT", -config.textoffset, 0)
		
		ApplyTags(self, self.Health.value, unitConfig.texts.health)
	end
	
	-- MP TEXT	
	if unitConfig.texts.power then
		self.Power.value = getFontString(self.Power)
		self.Power.value:SetJustifyH("RIGHT")
		self.Power.value:SetPoint("RIGHT", self.Power, "RIGHT", -config.textoffset, 0)
		
		ApplyTags(self, self.Power.value, unitConfig.texts.power)
	end
	
	--CENTERTEXTS
	if unitConfig.texts.centertexts then
		local spacer = config.textoffset * 2
		self.CenterTexts = CreateFrame("frame", nil, self)
		self.CenterTexts.num = #unitConfig.texts.centertexts
		self.CenterTexts:SetHeight((config.font.size + spacer) * self.CenterTexts.num - spacer)
		self.CenterTexts:SetWidth(unitConfig.width)
		
		local centertext
		for index, tag in ipairs(unitConfig.texts.centertexts) do
			centertext = getFontString(self.CenterTexts)
			centertext:SetJustifyH("CENTER")
			if index == 1 then
				centertext:SetPoint("TOP", self.CenterTexts, "TOP")
			else
				centertext:SetPoint("TOP", self.CenterTexts[index - 1], "BOTTOM", 0, -spacer)
			end			
			
			ApplyTags(self, centertext, tag)
			self.CenterTexts[index] = centertext						
		end
		
		self.CenterTexts:SetPoint("CENTER", self, "CENTER", 0, 0)
	end
	
	-- Creates a frame so i can manually set the level of the icons
	self.IconFrame = CreateFrame("frame", nil, self)
	self.IconFrame:SetFrameLevel(self.Health:GetFrameLevel() + 1)
	
	-- RAID ICON
	if unitConfig.raidicon then
		local raidicon = self.IconFrame:CreateTexture(nil, "OVERLAY")
		raidicon:SetHeight(16)
		raidicon:SetWidth(16)
		raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		raidicon:SetPoint("CENTER", self, "TOP", 0, -self.offset)
		self.RaidIcon = raidicon
	end
	
	-- LEADER ICON
	if unitConfig.leadericon then
		local leader = self.IconFrame:CreateTexture(nil, "OVERLAY")
		leader:SetHeight(10)
		leader:SetWidth(10)
		leader:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		self.Leader = leader
	end
	
	-- ASSISTANT ICON	
	if unitConfig.assistanticon then
		local assistant = self.IconFrame:CreateTexture(nil, "OVERLAY")
		assistant:SetHeight(10)
		assistant:SetWidth(10)
		assistant:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		self.Assistant = assistant
	end
	
	-- LFD ROLE ICON	
	if unitConfig.roleicon then
		local role = self.IconFrame:CreateTexture(nil, "OVERLAY")
		role:SetHeight(10)
		role:SetWidth(10)
		role:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		self.LFDRole = role
	end
	
	-- MASTERLOOT ICON
	if unitConfig.masterlooticon then
		local mlicon = self.IconFrame:CreateTexture(nil, "OVERLAY")
		mlicon:SetHeight(10)
		mlicon:SetWidth(10)
		mlicon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.offset, self.offset)
		self.MasterLooter = mlicon
	end
	
	if self.Leader or self.Assistant or self.LFDRole or self.MasterLooter then
		self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", updateGroupIcons)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", updateGroupIcons)
		self:RegisterEvent("PARTY_LEADER_CHANGED", updateGroupIcons)
		self:RegisterEvent("PLAYER_ROLES_ASSIGNED", updateGroupIcons)
	end
		
	-- COMBAT ICON
	if unitConfig.combaticon then
		local combat = self.IconFrame:CreateTexture(nil, "OVERLAY")
		combat:SetHeight(12)
		combat:SetWidth(12)
		combat:SetPoint("CENTER", self, "TOPLEFT", self.offset, -self.offset)
		combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		combat:SetTexCoord(0.57, 0.90, 0.08, 0.41)
		self.Combat = combat
		self.Combat:Hide()
		
		self:RegisterEvent("PLAYER_REGEN_ENABLED", function() self.Combat:Hide() end)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", function() self.Combat:Show() end)
	end	
	
	-- INDICATOR ICONS
	if unitConfig.indicators then
		local icon, cd, offsetX, offsetY, statusConfig
		for loc, iconConfig in pairs(unitConfig.indicators) do
			offsetX = (loc:match("left") and self.offset - 1) or (loc:match("right") and -self.offset + 1) or 0
			offsetY = (loc:match("top") and -self.offset + 1) or (loc:match("bottom") and self.offset - 1) or 0
			icon = CreateFrame("frame", nil, self.IconFrame)
			icon:SetBackdrop(config.iconBG)
			icon:SetBackdropBorderColor(0, 0, 0, loc == "center" and 0 or 1)
			icon:SetHeight(iconConfig.size + 1)
			icon:SetWidth(iconConfig.size + 1)
			icon:SetPoint(loc, self, loc, offsetX, offsetY)
			icon.parent = self
			icon.loc = loc
			icon.texture = icon:CreateTexture(nil, "BACKGROUND")
			icon.texture:SetAllPoints(icon)
			
			RegisterStatuses(self, self.configUnit, loc)
			if self.configUnit == "raid" and unitConfig.vehicleswap and config.raidvehicle and config.raidvehicle.indicators[loc] then
				RegisterStatuses(self, "raidvehicle", loc)
			end
			for _, status in ipairs(iconConfig.statuses) do
				statusConfig = config.statuses[status]
				if statusConfig.showCount and not icon.count then
					count = icon:CreateFontString(nil, "OVERLAY")
					count:SetFont(config.font.name, 11, "THINOUTLINE")
					count:SetShadowColor(0, 0, 0)
					count:SetJustifyV("BOTTOM")
					count:SetJustifyH("RIGHT")
					if loc == "center" then
						count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
					else
						count:SetPoint("CENTER", icon, "CENTER")
					end
					
					icon.count = count
					icon.count:Hide()
				end		
				if statusConfig.showDuration and not icon.cd then
					cd = icon:CreateFontString(nil, "OVERLAY")
					cd:SetFont(config.font.name, iconConfig.size - 6 <= 12 and 12 or iconConfig.size - 6, "THINOUTLINE")
					cd:SetShadowColor(0, 0, 0)
					cd:SetJustifyV("CENTER")
					cd:SetPoint("CENTER", icon, "CENTER")
					
					icon.cd = cd
					icon.cd:Hide()
				end
			end			
			
			self.IconFrame[loc] = icon
			self.IconFrame[loc]:Hide()
		end
	
		if not self.Border then
			table.insert(self.__elements, updateStatuses)
		end
		self.Indicators = true
	end
	
	-- BUFFS
	if unitConfig.buffs and self.configUnit ~= "player" then
		local buffs = CreateFrame("frame", nil, self)
		buffs.size = unitConfig.buffs.size
		buffs.spacingx = unitConfig.buffs.paddingx or 0
		buffs.spacingy = unitConfig.buffs.paddingy or 0
		buffs:SetWidth((buffs.size + buffs.spacingx) * unitConfig.buffs.cols)
		buffs:SetHeight((buffs.size + buffs.spacingy) * unitConfig.buffs.rows)
		buffs.initialAnchor = unitConfig.buffs.initialanchor
		buffs["growth-x"] = unitConfig.buffs.growthx
		buffs["growth-y"] = unitConfig.buffs.growthy
		buffs.disableCooldown = true
		buffs.filter = "HELPFUL"
		buffs.num = unitConfig.buffs.rows * unitConfig.buffs.cols
		buffs:SetPoint(unitConfig.buffs.anchorpoint, self, unitConfig.buffs.selfanchor, unitConfig.buffs.xoffset or 0, unitConfig.buffs.yoffset or 0)
		
		self.Buffs = buffs
		
	end
	
	-- DEBUFFS
	if unitConfig.debuffs and self.configUnit ~= "player" then
		local debuffs = CreateFrame("frame", nil, self)
		debuffs.size = unitConfig.debuffs.size
		debuffs.spacingx = unitConfig.debuffs.paddingx or 0
		debuffs.spacingy = unitConfig.debuffs.paddingy or 0
		debuffs:SetHeight((debuffs.size + debuffs.spacingy) * unitConfig.debuffs.rows)
		debuffs:SetWidth((debuffs.size + debuffs.spacingx) * unitConfig.debuffs.cols)
		debuffs.initialAnchor = unitConfig.debuffs.initialanchor
		debuffs["growth-x"] = unitConfig.debuffs.growthx
		debuffs["growth-y"] = unitConfig.debuffs.growthy
		debuffs.disableCooldown = true
		debuffs.filter = "HARMFUL"		
		debuffs.num = unitConfig.debuffs.rows * unitConfig.debuffs.cols
		debuffs:SetPoint(unitConfig.debuffs.anchorpoint, self, unitConfig.debuffs.selfanchor, unitConfig.debuffs.xoffset or 0, unitConfig.debuffs.yoffset or 0)	
		
		self.Debuffs = debuffs
	end	
	
	-- RANGECHECK
	if unitConfig.rangecheck then
		self.Range = true 
		self.inRangeAlpha = config.insideRangeAlpha
		self.outsideRangeAlpha = config.outsideRangeAlpha
	end	
	
	-- MISC
	if self.configUnit == "raid" then -- or --self.configUnit == "player" or self.configUnit == "party" then
		self:SetAttribute("toggleForVehicle", true)
	end
	
	return self
end

oUF:RegisterStyle("turkoid", setStyle)
oUF:SetActiveStyle("turkoid")

local frames = {}
--Only accepted values for 'spawnOrder is [player, target, targettarget, pet, focus, focustarget]
local spawnOrder = {"player", "target", "targettarget", "pet", "focus", "focustarget"}
local pConfig
for _, frameUnit in ipairs(spawnOrder) do
	pConfig = config[frameUnit].position
	frames[frameUnit] = oUF:Spawn(frameUnit, "oUF_"..frameUnit)
	frames[frameUnit]:SetPoint(pConfig.selfAnchor, frames[pConfig.target] or UIParent, pConfig.targetAnchor, pConfig.xOffset, pConfig.yOffset)
end

pConfig = config["party"].position
frames.party = oUF:Spawn("header", "oUF_party")
local partySpacing = pConfig.spacing
if pConfig.direction == "DOWN" then
	partySpacing = -partySpacing
else
	partySpacing = partySpacing + config.party.height
end
frames.party:SetPoint(pConfig.selfAnchor, frames[pConfig.target] or UIParent, pConfig.targetAnchor, pConfig.xOffset, pConfig.yOffset)
frames.party:SetAttribute("showParty", true)
frames.party:SetAttribute("yOffset", partySpacing)
frames.party:SetAttribute("template", "oUF_turkoidPartyTemplate")
frames.party:Hide()

local partytoggle = CreateFrame("frame")
partytoggle:RegisterEvent("PLAYER_LOGIN")
partytoggle:RegisterEvent("RAID_ROSTER_UPDATE")
partytoggle:RegisterEvent("PARTY_LEADER_CHANGED")
partytoggle:RegisterEvent("PARTY_MEMBER_CHANGED")
partytoggle:SetScript("OnEvent", function(self)
	if (InCombatLockdown()) and false then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if GetNumRaidMembers() > 0 then
			frames.party:Hide()
		else	
			--PrintLine("showing")
			frames.party:Show()
		end
	end
end)

frames.boss = {}
pConfig = config["boss"].position
for i = 1, MAX_BOSS_FRAMES do
	frames.boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)

	if i == 1 then
		frames.boss[i]:SetPoint(pConfig.selfAnchor, frames[pConfig.target] or UIParent, pConfig.targetAnchor, pConfig.xOffset, pConfig.yOffset)
	else
		frames.boss[i]:SetPoint("TOP", frames.boss[i-1], "BOTTOM", 0, -5)
	end
	frames.boss[i]:Show()
end