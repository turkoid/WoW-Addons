local myNamePlates = CreateFrame("Frame", nil, UIParent)
local _, playerClass = UnitClass("player")

--[[ Config Variables ]]--
local barTexture = "Interface\\AddOns\\myMedia\\smoothv2.tga"
local backgroundAlpha = .5
local barWidth, barHeight = 125, 11
local font = "Interface\\Addons\\myMedia\\ABF.ttf"
local textColor = {r = 1, g = 1, b = 1, a = 1}
local nameFontSize, nameOffsetX, nameOffsetY = 10, 1, 0
local levelFontSize, levelOffsetX, levelOffsetY = 10, -1, 0
local comboPointsOffsetX, comboPointsOffsetY = -3, 0

--[[ Initialization ]]--
local numWorldChildren = 0
local select = select
local GetComboPoints, UnitExists, UnitName, UnitGUID = GetComboPoints, UnitExists, UnitName, UnitGUID

--ComboPoints
if playerClass == "ROGUE" or playerClass == "DRUID" then
	myNamePlates.comboPoints = myNamePlates:CreateFontString()
	myNamePlates.comboPoints:Hide()
	myNamePlates.comboPoints:ClearAllPoints()
	myNamePlates.comboPoints:SetFont(font, 30, "THICKOUTLINE")
	myNamePlates.comboPoints:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
	myNamePlates.comboPoints:SetShadowOffset(0, 0)
	
	myNamePlates.cpGUID = nil
	myNamePlates.cpName = ""
	
	myNamePlates:RegisterEvent("UNIT_COMBO_POINTS")
	myNamePlates:RegisterEvent("PLAYER_TARGET_CHANGED")
	myNamePlates:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

--[[ Helper Functions ]]--
local PrintLine = function(txt) --way easier to type
	DEFAULT_CHAT_FRAME:AddMessage(tostring(txt))
end

local IsValidFrame = function(frame)
	if not frame or frame:GetName() then
		return
	end

	overlayRegion = select(2, frame:GetRegions())

	return overlayRegion and overlayRegion:GetObjectType() == "Texture" and overlayRegion:GetTexture() == "Interface\\Tooltips\\Nameplate-Border"
end

local AnchorComboPoints = function(frame)
	if frame then
		myNamePlates.comboPoints:ClearAllPoints()		
		myNamePlates.comboPoints:SetPoint("RIGHT", frame.healthBar, "LEFT", comboPointsOffsetX, comboPointsOffsetY)
		myNamePlates.comboPoints:SetParent(frame)
		myNamePlates.comboPoints:Show()
	else
		myNamePlates.comboPoints:Hide()
		myNamePlates:ClearAllPoints()
		myNamePlates.comboPoints:SetParent(myNamePlates)
	end
end

local FixCastbar = function(self)
	self.castbarOverlay:Hide()
	self.spellIcon:Hide()
	self:SetHeight(barHeight / 2)
	self:ClearAllPoints()
	self:SetPoint("TOP", self:GetParent().healthBar, "BOTTOM", 0, -1)
end

local ColorCastBar = function(self, shielded)
	if shielded then
		self:SetStatusBarColor(0.8, 0.05, 0)
	end
end

local OnSizeChanged = function(self)
	self.needFix = true
end

local OnValueChanged = function(self, curValue)
	if self.needFix then
		FixCastbar(self)
		self.needFix = nil
	end
end

local OnShow = function(self)
	FixCastbar(self)
	ColorCastBar(self, self.shieldedRegion:IsShown())
end

--[[ Script Handling ]]--
local UpdateFrame = function(self)
	if not self:IsVisible() then return end
	
	self.healthBar:SetHeight(barHeight)
	self.healthBar:SetWidth(barWidth)

	self.castBar:SetHeight(barHeight / 2)
	self.castBar:SetWidth(barWidth)
	
	self.highlight:ClearAllPoints()
	self.highlight:SetAllPoints(self.healthBar)
	
	if self.boss:IsShown() then
		self.level:SetText("??")
		self.level:SetTextColor(1, 0, 0)		
	else
		self.level:SetText(self.level:GetText()..(self.elite:IsShown() and "+" or ""))
	end
	self.level:Show()
	
	self.name:SetText(self.oldname:GetText())
	self.name:SetWidth(self.healthBar:GetWidth() - self.level:GetStringWidth() - 5)	
	self.name:SetHeight(self.healthBar:GetHeight())
	
	if myNamePlates.comboPoints and self.name:GetText() == myNamePlates.cpName and myNamePlates.comboPoints:GetParent() == myNamePlates then
		AnchorComboPoints(self)
	end
end

local OnHide = function(self)
	self.highlight:Hide()
	if myNamePlates.comboPoints and myNamePlates.comboPoints:GetParent() == self then
		AnchorComboPoints(nil)
	end
end

local OnEnter = function(self)
	if myNamePlates.comboPoints and UnitExists("mouseover") then
		if GetComboPoints("player", "mouseover") > 0 and myNamePlates.comboPoints:GetParent() ~= self then
			AnchorComboPoints(self)
		elseif GetComboPoints("player", "mouseover") == 0 and myNamePlates.comboPoints:GetParent() == self then
			AnchorComboPoints(nil)
		end
	end
end

local cbOnEvent = function(self, event, unit)
	if unit == "target" then
		if self:IsShown() then
			ColorCastBar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
		end
	end
end

local OnEvent = function(self, ...)
	local event = select(3, ...) or select(1, ...)
	local cp = GetComboPoints("player", "target")
	if (event == "UNIT_DIED" and myNamePlates.cpGUID == select(7, ...)) or (UnitExists("target") and (UnitIsDead("target") or cp == 0)) or (event == "UNIT_COMBO_POINTS" and not UnitExists("target")) then
		myNamePlates.cpGUID = nil
		myNamePlates.cpName = ""
		myNamePlates.comboPoints:SetText("")
	elseif (event == "PLAYER_TARGET_CHANGED" or event == "UNIT_COMBO_POINTS") and UnitExists("target") and cp > 0 then
		myNamePlates.cpGUID = UnitGUID("target")
		myNamePlates.cpName = UnitName("target")
		myNamePlates.comboPoints:SetText(cp)
	end
end

--[[ The Style ]]--
local CreateFrame = function(frame)
	if frame.done then return end

	frame.healthBar, frame.castBar = frame:GetChildren()
	healthBar, castBar = frame.healthBar, frame.castBar
	local glowRegion, overlayRegion, castbarOverlayRegion, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()
	
	frame.healthBar:ClearAllPoints()
	frame.healthBar:SetPoint("CENTER", frame.healthBar:GetParent())
	frame.healthBar:SetStatusBarTexture(barTexture)
	frame.healthBar.hpBackground = frame.healthBar:CreateTexture(nil, "BORDER")
	frame.healthBar.hpBackground:SetAllPoints(frame.healthBar)
	frame.healthBar.hpBackground:SetTexture(barTexture)
	frame.healthBar.hpBackground:SetVertexColor(0, 0, 0, backgroundAlpha)

	frame.castBar:ClearAllPoints()
	frame.castBar:SetPoint("TOP", frame.healthBar, "BOTTOM", 0, -1)
	frame.castBar:SetStatusBarTexture(barTexture)
	frame.castBar.cbBackground = frame.castBar:CreateTexture(nil, "BORDER")
	frame.castBar.cbBackground:SetAllPoints(frame.castBar)
	frame.castBar.cbBackground:SetTexture(barTexture)
	frame.castBar.cbBackground:SetVertexColor(0, 0, 0, backgroundAlpha)
	
	frame.castBar.castbarOverlay = castbarOverlayRegion
	frame.castBar.spellIcon = spellIconRegion
	frame.castBar.shieldedRegion = shieldedRegion	

	frame.castBar:HookScript("OnShow", OnShow)
	frame.castBar:HookScript("OnSizeChanged", OnSizeChanged)
	frame.castBar:HookScript("OnValueChanged", OnValueChanged)
	frame.castBar:HookScript("OnEvent", cbOnEvent)
	frame.castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	frame.castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

	frame.highlight = highlightRegion
	highlightRegion:SetTexture(barTexture)
	highlightRegion:SetBlendMode("ADD")
	highlightRegion:SetVertexColor(1, 1, 0, 0.25)	
	
	frame.level = levelTextRegion
	levelTextRegion:ClearAllPoints()
	levelTextRegion:SetPoint("RIGHT", frame.healthBar, "RIGHT", levelOffsetX, levelOffsetY)
	levelTextRegion:SetFont(font, levelFontSize, "THINOUTLINE")
	levelTextRegion:SetShadowOffset(0, 0)	

	frame.oldname = nameTextRegion
	nameTextRegion:Hide()
	frame.name = frame:CreateFontString()
	frame.name:ClearAllPoints()
	frame.name:SetPoint("LEFT", frame.healthBar, "LEFT", nameOffsetX, nameOffsetY)
	frame.name:SetFont(font, nameFontSize, "THINOUTLINE")
	frame.name:SetJustifyH("LEFT")
	frame.name:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
	frame.name:SetShadowOffset(0, 0)
	
	raidIconRegion:ClearAllPoints()
	raidIconRegion:SetPoint("CENTER", frame.healthBar, "CENTER")

	frame.elite = stateIconRegion
	frame.boss = bossIconRegion
		
	--Hides unwanted featres
	glowRegion:SetTexture(nil)
	overlayRegion:SetTexture(nil)
	castbarOverlayRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	spellIconRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)	
	stateIconRegion:SetTexture(nil)
	--frame.castBar:Hide()
	
	frame.done = true

	UpdateFrame(frame)
	frame:SetScript("OnShow", UpdateFrame)
	frame:SetScript("OnHide", OnHide)
end

--[[ Handlers ]]--
myNamePlates:SetScript("OnUpdate", function(self, elapsed)
	local selectedNamePlates = 0
	for i = 1, select("#", WorldFrame:GetChildren()) do
		frame = select(i, WorldFrame:GetChildren())
		
		if IsValidFrame(frame) then
			CreateFrame(frame)
		end
		if frame.done and frame.highlight:IsVisible() then
			OnEnter(frame)
		end
		if UnitExists("target") and frame.done and frame:IsVisible() and frame:GetAlpha() == 1 then			
			selectedNamePlates = selectedNamePlates + 1
			targetNamePlate = frame			
		end
	end
	if selectedNamePlates == 1 and myNamePlates.comboPoints and GetComboPoints("player", "target") > 0 and myNamePlates.comboPoints:GetParent() ~= targetNamePlate then
		AnchorComboPoints(targetNamePlate)
	end
end)
myNamePlates:SetScript("OnEvent", OnEvent)