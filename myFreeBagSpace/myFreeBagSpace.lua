myBagSpace = CreateFrame("frame", nil, UIParent)
local anchorButton = MultiBarRightButton4
myBagSpace:RegisterEvent("PLAYER_ENTERING_WORLD")

local font = "Interface\\Addons\\myMedia\\ABF.ttf"
local size = 22

local function GetBagSpace()
	local freeSlots = 0
	local totalSlots = 0
	for bagID = 0, 4 do
		freeSlots = freeSlots + GetContainerNumFreeSlots(bagID)
		totalSlots = totalSlots + GetContainerNumSlots(bagID)
	end
	return freeSlots, totalSlots
end

function myBagSpace:Initialize()
	self:SetAllPoints(anchorButton)
	self:SetParent(anchorButton)
	self:EnableKeyboard()
	self:SetFrameLevel(self:GetFrameLevel() + 1)
	self.freeSpace = self:CreateFontString(nil, "OVERLAY")
	self.freeSpace:SetFont(font, size, "THINOUTLINE")
	self.freeSpace:SetAllPoints(self)
	self.freeSpace:SetJustifyH("CENTER")
	self.freeSpace:SetJustifyV("CENTER")
	self:Update()
end

-- update
function myBagSpace:Update()
	local freeSlots, totalSlots = GetBagSpace()
	
	if freeSlots <= (0.10 * totalSlots) then
		self.freeSpace:SetTextColor(1, 0, 0)
	else
		self.freeSpace:SetTextColor(0, 1, 0)
	end
	self.freeSpace:SetText(freeSlots)	
end

myBagSpace:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		self:Initialize()
		self:RegisterEvent("BAG_UPDATE")
	elseif event == "BAG_UPDATE" then
		self:Update()
	end
end)

myBagSpace:SetScript("OnUpdate", function(self, elapsed)
	if (IsControlKeyDown() or IsShiftKeyDown()) then
		if self:GetAlpha() == 1 then
			self:SetAlpha(0)
		end
	elseif self:GetAlpha() == 0 then
		self:SetAlpha(1)
	end
end)
	