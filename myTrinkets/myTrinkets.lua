myTrinkets = CreateFrame("frame", nil, UIParent)

local select, _G = select, _G
local GetItemCooldown, GetItemInfo, GetContainerItemLink = GetItemCooldown, GetItemInfo, GetContainerItemLink
local LBF = LibStub('LibButtonFacade', true)

local anchorButton, trinket1, trinket2
if UnitName('player') == 'Yattay' then
	anchorButton = MultiBarBottomLeftButton3
	trinket1 = MultiBarBottomLeftButton2
	trinket2 = MultiBarBottomLeftButton3
else
	anchorButton = MultiBarRightButton10
	trinket1 = MultiBarRightButton9
	trinket2 = MultiBarRightButton10
end
local selfAnchor, buttonAnchor = "BOTTOMRIGHT", "BOTTOMLEFT"
local size = 32
local offsetx, offsety = -10, 0
local growthx, growthy = "LEFT", "UP"
local padding = 5
local maxRows = 5
local maxCols = 5

myTrinkets:RegisterEvent("PLAYER_ENTERING_WORLD")

local function TrinketButton_OnEnter(self)
	if not self:IsVisible() then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetBagItem(self.bagID, self.slotID)
end
 
local function TrinketButton_OnClick(self, button)
	local slot = button == "LeftButton" and 13 or 14
	if InCombatLockdown() then
		local trinket = slot == 13 and trinket1 or trinket2
		if trinket1.slot == slot and trinket2.combatqueue == self then
			trinket2.combatqueue = nil
			trinket2.small:SetTexture(nil)
		elseif trinket2.slot == slot and trinket1.combatqueue == self then
			trinket1.combatqueue = nil
			trinket1.small:SetTexture(nil)
		end
		if trinket.combatqueue == self then
			trinket.combatqueue = nil
			trinket.small:SetTexture(nil)
		else
			trinket.combatqueue = self
			trinket.small:SetTexture(self.icon:GetTexture())
		end
		self.parent:RegisterEvent("PLAYER_REGEN_ENABLED")		
	else
		EquipItemByName(self.itemLink, slot)
		if not IsShiftKeyDown() then self.parent:Hide() end
	end
end

function myTrinkets:CreateTrinketButton(index)
	local row, col
	local btn = CreateFrame("Button", "myTrinket"..index, self, "ActionButtonTemplate")

	if maxRows then
		row = mod(index - 1, maxRows)
		col = ceil(index / maxRows) - 1
		if index >= maxRows then
			self:SetHeight(maxRows * (size + padding) - padding)
		else
			self:SetHeight((row + 1) * (size + padding) - padding)
		end
		self:SetWidth((col + 1) * (size + padding) - padding)
	elseif maxCols then
		row = ceil(index / maxCols)
		col = mod(index - 1, maxCols) - 1
		if index >= maxCols then
			self:SetWidth(maxCols * (size + padding) - padding)
		else
			self:SetWidth((col + 1) * (size + padding) - padding)
		end
		self:SetHeight((row + 1) * (size + padding) - padding)
	end

	btn:SetWidth(size)
	btn:SetHeight(size)
	btn:SetPoint(selfAnchor, self, selfAnchor, col * (size + padding) * growthx, row * (size + padding) * growthy)
	
	if LBF then
		LBF:Group("myTrinkets", "Trinkets"):AddButton(_G["myTrinket"..index])
		LBF:Group("myTrinkets", "Trinkets"):Skin("Caith", 0, false)
	end
	
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	btn:SetScript("OnEnter", TrinketButton_OnEnter)
	btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	btn:SetScript("OnClick", TrinketButton_OnClick)
	btn.parent = self
	btn.icon = _G["myTrinket"..index.."Icon"]
	btn.cd = _G["myTrinket"..index.."Cooldown"]
	
	self[index] = btn
	return btn
end

function myTrinkets:ScanTrinkets()
	local bagID, slotID, itemLink, trinketButton, index
	
	index = 1
	for bagID = 0, 4 do
		for slotID = 1, GetContainerNumSlots(bagID) do	
			itemLink = GetContainerItemLink(bagID, slotID)
			
			if itemLink and select(9, GetItemInfo(itemLink)) == "INVTYPE_TRINKET" then
				trinketButton = self[index] or self:CreateTrinketButton(index)
				trinketButton.bagID = bagID
				trinketButton.slotID = slotID
				trinketButton.itemLink = itemLink				
				trinketButton.icon:SetTexture(select(10, GetItemInfo(itemLink)))
				trinketButton.cd:SetCooldown(GetItemCooldown(itemLink))
				trinketButton:Show()
				index = index + 1				
			end
		end
	end
	
	while self[index] do
		self[index]:Hide()
		index = index + 1
	end
end

function myTrinkets:ShowMenu()
	self:ScanTrinkets()
	
	if self[1] and self[1]:IsShown() then
		self:Show()
	end
end
local function OnEnter(...)
	if IsShiftKeyDown() then
		myTrinkets:ShowMenu()
	end
end

local lastCheck = 0
function myTrinkets:OnUpdate(elapsed)
	lastCheck = lastCheck + elapsed
	if lastCheck >= .1 then
		local focus = GetMouseFocus()
		if not IsShiftKeyDown() and focus ~= self and focus:GetParent() ~= self then
			self:Hide()
		end
	end
end

function myTrinkets:Initialize()
	growthx = growthx == "LEFT" and -1 or 1
	growthy = growthy == "DOWN" and -1 or 1
	self:SetFrameStrata("DIALOG")
	self:SetPoint(selfAnchor, anchorButton, buttonAnchor, offsetx, offsety)		
	self:EnableMouse(true)
	self:Hide()
	
	trinket1.small = trinket1:CreateTexture(nil, "OVERLAY")
	trinket1.small:SetPoint("TOPLEFT", trinket1, "TOPLEFT")
	trinket1.small:SetWidth(trinket1:GetWidth() / 2)
	trinket1.small:SetHeight(trinket1:GetHeight() / 2)
	trinket1.slot = 13
	trinket1:HookScript("OnEnter", OnEnter)	
	
	trinket2.small = trinket2:CreateTexture(nil, "OVERLAY")
	trinket2.small:SetPoint("TOPLEFT", trinket2, "TOPLEFT")
	trinket2.small:SetWidth(trinket2:GetWidth() / 2)
	trinket2.small:SetHeight(trinket2:GetHeight() / 2)
	trinket2.slot = 14
	trinket2:HookScript("OnEnter", OnEnter)	
end

myTrinkets:SetScript("OnUpdate", myTrinkets.OnUpdate)
myTrinkets:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		self:RegisterEvent("BAG_UPDATE")
		self:Initialize()
	elseif event == "BAG_UPDATE" and self:IsShown() then
		self:ScanTrinkets()
		local focus = GetMouseFocus()
		if focus.parent == self then
			TrinketButton_OnEnter(focus)
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent(event)
		if trinket1.combatqueue then
			trinket1.small:SetTexture(nil)
			EquipItemByName(trinket1.combatqueue.itemLink, trinket1.slot)
			trinket1.combatqueue = nil
		end
		if trinket2.combatqueue then
			trinket2.small:SetTexture(nil)
			EquipItemByName(trinket2.combatqueue.itemLink, trinket2.slot)
			trinket2.combatqueue = nil
		end				
	end
end)
