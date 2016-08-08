myPanels = CreateFrame("frame", nil, UIParent)

local backdropTable = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", --"Interface\\Addons\\myMedia\\Smoothv2.tga",
	edgeFile = "Interface\\Addons\\myMedia\\border.blp",
	tile = true,
	edgeSize = 16,
	insets = {
		left = 0, 
		right = 0, 
		top = 0, 
		bottom = 0 
	}
}	
local bgAlpha = .8	
local minimapButtons = {
	{
		name = "DA_Minimap",
		overlay = "OVERLAY",
		size = 24,
		offset = -4,
	}, 
	{
		name = "LibDBIcon10_Skada",
		overlay = "OVERLAY",
		size = 19,
		offset = 1,
	}, 
	{
		name = "LibDBIcon10_Omen",
		overlay = "OVERLAY",
		size = 19,
		offset = 2,
	}, 
	-- {
		-- name = "DBMMinimapButton",
		-- overlay = "OVERLAY",
		-- size = 26,
		-- offset = 0,
	-- },
	{
		name = "LibDBIcon10_DXE",
		overlay = "OVERLAY",
		size = 19,
		offset = 0,
	}, 
	{
		name = "ItemRackMinimapFrame",
		overlay = "ARTWORK",
		size = 20,
		offset = 3,
	},
}
local _G = getfenv(0)

myPanels:RegisterEvent("PLAYER_ENTERING_WORLD")
myPanels:RegisterEvent("ADDON_LOADED")

function myPanels:Initialize()	
	self.bar = CreateFrame("frame", nil, self)
	self.bar:SetBackdrop(backdropTable)
	self.bar:SetBackdropColor(0, 0, 0, bgAlpha)
	self.bar:SetFrameStrata("BACKGROUND")
	self.bar:SetFrameLevel(0)
	
	self.minimap = CreateFrame("frame", nil, self)
	self.minimap:SetBackdrop(backdropTable)
	self.minimap:SetBackdropColor(0, 0, 0, bgAlpha)
	self.minimap:SetFrameStrata("BACKGROUND")
	self.minimap:SetFrameLevel(0)
	
	self.minimapButtons = CreateFrame("frame", nil, self)
	self.minimapButtons:SetBackdrop(backdropTable)
	self.minimapButtons:SetBackdropColor(0, 0, 0, bgAlpha)
	self.minimapButtons:SetFrameStrata("BACKGROUND")
	self.minimapButtons:SetFrameLevel(0)
	for index = 1, #minimapButtons do
		self.minimapButtons["button"..index] = CreateFrame("frame", nil, self.minimapButtons)
		self.minimapButtons["button"..index]:ClearAllPoints()
		if index == 1 then
			self.minimapButtons["button"..index]:SetPoint("TOP", self.minimapButtons, "TOP", 0, minimapButtons[index].offset)
		else
			self.minimapButtons["button"..index]:SetPoint("TOP", self.minimapButtons["button"..(index - 1)], "BOTTOM", 0, minimapButtons[index].offset)
		end
	end
	
	self.chatbox = CreateFrame("frame", nil, self)
	self.chatbox:SetBackdrop(backdropTable)
	self.chatbox:SetBackdropColor(0, 0, 0, bgAlpha)
	self.chatbox:SetFrameStrata("BACKGROUND")
	self.chatbox:SetFrameLevel(0)

	self:SetScript("OnUpdate", self.ScanButtons)			
end

local index = 1
function myPanels:ScanButtons(elapsed)
	if index <= #minimapButtons and _G[minimapButtons[index].name] then
		index = index + 1
	else
		self:SetScript("OnUpdate", nil)
		self:WrangleButtons()
	end
end

function myPanels:WrangleButtons()
	local size = 18
	
	local button, region, drawLayer
	for index = 1, #minimapButtons do
		button = _G[minimapButtons[index].name]
		for regionIndex = 1, button:GetNumRegions() do
			region = select(regionIndex, button:GetRegions())
			drawLayer = region:GetDrawLayer()
			region:ClearAllPoints()
			region:SetAllPoints(button)
			if drawLayer == minimapButtons[index].overlay then
				region:Hide()
			elseif drawLayer == "BACKGROUND" then
				button:SetHighlightTexture(region:GetTexture())
			end			
		end
		
		self.minimapButtons["button"..index]:SetWidth(self.minimapButtons:GetWidth())
		self.minimapButtons["button"..index]:SetHeight(self.minimapButtons:GetHeight() / 5)
		
		button:SetParent(self.minimapButtons)
		button:RegisterForDrag(nil)
		button:ClearAllPoints()		
		button:SetPoint("CENTER", self.minimapButtons["button"..index], "CENTER")
		button:SetWidth(minimapButtons[index].size)
		button:SetHeight(minimapButtons[index].size)
	end
	DagAssist.Menu:SetFrameStrata("TOOLTIP")
end
	 
function myPanels:ShowFrames()	
	local pName, fixBars, barFrameOffset, outerOffset, chatBoxSpacing, chatFrameOffset = UnitName('player')
	if pName == 'Yattay' then
		fixBars = {
			{"MultiBarBottomLeftButton", 1, "MultiBarBottomRightButton", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "MultiBarRightButton", 1, 2, 3, 4},
			{"MultiBarBottomLeftButton", 2, "BonusActionButton", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "MultiBarRightButton", 5, 6, 7, 8},
			{"MultiBarBottomLeftButton", 3, "ActionButton", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "MultiBarRightButton", 9, 10, 11, 12}
		}
		outerOffset = 2
		barFrameOffset = -910
		chatBoxSpacing = 2
		chatFrameOffset = 8
	else		
		fixBars = {
			{"MultiBarRightButton", 9, "BonusActionButton", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "MultiBarRightButton", 1, 2, 3, 4},
			{"MultiBarRightButton", 10, "ActionButton", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "MultiBarRightButton", 5, 6, 7, 8}
		}
		outerOffset = 3
		barFrameOffset = -910
		chatBoxSpacing = 2
		chatFrameOffset = 8
	end
	
	local barname, button, point, relativeButton, relativePoint
	local offsetX, offsetY
	
	for _, buttons in ipairs(fixBars) do
		for i = 1, #buttons do
			if tonumber(buttons[i]) then
				button = _G[barName..buttons[i]]
				if relativeButton then
					button:SetPoint(point, relativeButton, relativePoint, offsetX, offsetY)
				end
				relativeButton = button
				point, relativePoint = "TOPLEFT", "TOPRIGHT"
				offsetX, offsetY = 3, 0
			else
				barName = buttons[i]
			end
		end
		relativeButton = _G[buttons[1]..buttons[2]]
		point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
		offsetX = 0
		offsetY = -2
	end
	
	local buttonWidth = ActionButton1:GetWidth()
	local buttonHeight = ActionButton1:GetHeight()
	
	local spacing = 3
	self.buttons = CreateFrame("frame", nil, ActionButton1:GetParent())
	self.buttons:SetWidth((buttonWidth + spacing) * 17 - spacing)
	self.buttons:SetHeight((buttonHeight + outerOffset) * #fixBars - outerOffset)		
	self.buttons:SetPoint("CENTER", self.bar, "CENTER", 0, 0)	
	
	local firstButton = _G[fixBars[1][1]..fixBars[1][2]]
	firstButton:SetPoint("TOPLEFT", self.buttons, "TOPLEFT")
	
	spacing = 5
	self.minimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -spacing, spacing)
	self.minimap:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", spacing, -spacing)

	spacing = 0
	self.minimapButtons:SetWidth(33)
	self.minimapButtons:SetPoint("TOPLEFT", self.minimap, "TOPRIGHT", spacing, spacing)
	self.minimapButtons:SetPoint("BOTTOMLEFT", self.minimap, "BOTTOMRIGHT", spacing, spacing)

	spacing = 2
	self.bar:SetPoint("TOP", UIParent, "TOP", 0, barFrameOffset)
	self.bar:SetWidth(622)
	self.bar:SetHeight(self.buttons:GetHeight() + 2 * outerOffset)
	
	self.chatbox:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, chatBoxSpacing)
	self.chatbox:SetPoint("TOP", self.bar, "BOTTOM", 0, -chatBoxSpacing)
	self.chatbox:SetWidth(622)
	
	ChatFrame1:SetClampedToScreen(false)
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetWidth(610)
	ChatFrame1:SetPoint('BOTTOM', self.chatbox, 'BOTTOM', 0, chatFrameOffset)
	--ChatFrame1:SetPoint('TOP', self.chatbox, 'TOP')
	--ChatFrame1EditBox:SetPoint('TOP', self.chatbox, 'TOP', 0, -chatFrameOffset - 1)
	
	VehicleSeatIndicator:ClearAllPoints()
	VehicleSeatIndicator:SetPoint("LEFT", self.minimapButtons, "RIGHT")
	
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint('TOP', self.minimapButtons, 'BOTTOM', 0 -5)
	LFDSearchStatus:ClearAllPoints()
	LFDSearchStatus:SetPoint("TOPLEFT", MiniMapLFGFrame, "TOPRIGHT")
	--LFDSearchStatus:ClearAllPoints()
	--LFDSearchStatus:SetPoint("TOPLEFT", MiniMapLFGFrame, "TOPRIGHT")
	if _G["LibFuBarPlugin-3.0_Addon Preferences_FrameMinimapButton"] then
		_G["LibFuBarPlugin-3.0_Addon Preferences_FrameMinimapButton"]:Hide()
	end
end

myPanels:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "myPanels" then
		self:UnregisterEvent(event)
		self:Initialize()
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		self:ShowFrames()
	end
end)



