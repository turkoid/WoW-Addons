myClock = CreateFrame("Button", "myClock", UIParent)

local backdropTable =
{
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", --"Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Addons\\myMedia\\border.blp",
	tile = false,
	edgeSize = 16,
	insets = 
	{
		left = 0, 
		right = 0, 
		top = 0, 
		bottom = 0 
	}
}

local offsetX, offsetY = 0, 5
local font = "Interface\\Addons\\myMedia\\ABF.ttf"
local size = 14
local color = {r = 0, g = 0.8, b = 1}
local hexColor = "|c00ffffff"

myClock:RegisterEvent("ADDON_LOADED")
myClock:RegisterEvent("PLAYER_ENTERING_WORLD")
myClock:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")

local PI, cos = PI, math.cos
local INVITE_PULSE_SEC	= 1.0 / (2.0 * 1.0)

local FindPendingInvites = function()
	local pendingCalendarInvites = CalendarGetNumPendingInvites()
	if pendingCalendarInvites > myClock.pendingCalendarInvites then
		if not CalendarFrame or (CalendarFrame and not CalendarFrame:IsShown()) then
			myClock.flash:Show()
			myClock.pendingCalendarInvites = pendingCalendarInvites;
		end
	elseif pendingCalendarInvites == 0 then
		myClock.flash:Hide()
		myClock.pendingCalendarInvites = 0
	end
end

local UpdateTime = function()
	local t = time()
	if myClock.showDate then
		myClock.text:SetText(hexColor..date("%A, %b %d, %Y", t).."|r")
	else
		myClock.text:SetText(hexColor..tonumber(date("%I", t))..date(":%M:%S", t).."|r"..date(" %p", t))
	end
end

function myClock:Initialize()	
	self:SetHeight(size + 10)
	self:SetWidth(150)
	self:SetPoint("BOTTOM", Minimap, "TOP", offsetX, offsetY)
	self:SetBackdrop(backdropTable)
	self:SetBackdropColor(0,0,0,1)
	self:SetFrameStrata("LOW")
	self:RegisterForClicks("AnyUp")
	
	self.text = self:CreateFontString(nil, "OVERLAY")
	self.text:SetFont(font, size, nil)
	self.text:SetJustifyH("CENTER")
	self.text:SetTextColor(color.r, color.g, color.b)
	self.text:SetPoint("CENTER", myClock, "CENTER", 0, 1)

	self.flash = self:CreateTexture()
	self.flash:ClearAllPoints()
	self.flash:SetAllPoints(myClock)
	self.flash:SetTexture(1, 1, 0, 0.25)
	self.flash:SetBlendMode("ADD")
	self.flash:SetDrawLayer("ARTWORK")
	self.flash:Hide()
	
	self.pendingCalendarInvites = 0
	self.flashTimer = 0	
end

local lastUpdate = 0
myClock:SetScript("OnUpdate", function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if lastUpdate >= 1 then
		lastUpdate = 0
		UpdateTime()		
		FindPendingInvites()
	end
	
	if elapsed and myClock.flash:IsShown() then
		local flashIndex = 2 * PI * self.flashTimer * INVITE_PULSE_SEC
		local flashValue = max(0, 0.5 + 0.5 * cos(flashIndex))
		
		if flashIndex >= (2 * PI) then
			self.flashTimer = 0
		else
			self.flashTimer = self.flashTimer + elapsed
		end
		self.flash:SetAlpha(flashValue)
	end
end)
myClock:SetScript("OnEnter", function(self)
	self.showDate = true
	self.text:SetFont(font, size - 1, nil)
	UpdateTime()
end)
myClock:SetScript("OnLeave", function(self)
	self.showDate = false
	self.text:SetFont(font, size, nil)
	UpdateTime()
end)
myClock:SetScript("OnClick", function(self)
	GameTimeFrame_OnClick(GameTimeFrame)
	self.flash:Hide()
	self.pendingCalendarInvites = 0
end)
myClock:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "myClock" then
		self:UnregisterEvent(event)
		self:Initialize()
	elseif event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" then
		FindPendingInvites()
	end
end)