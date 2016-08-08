myStats = CreateFrame("Button", "myStats", UIParent)

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

local offsetX, offsetY = 0, -5
local font = "Interface\\Addons\\myMedia\\ABF.ttf"
local size = 12
local color = {r = 0, g = 0.8, b = 1}
local hexColor = "|c00ffffff"
local maxShow = 76

local fps, lag, mem
local pairs, UpdateAddOnMemoryUsage, GetNumAddOns, GetAddOnMemoryUsage, GetAddOnInfo = pairs, UpdateAddOnMemoryUsage, GetNumAddOns, GetAddOnMemoryUsage, GetAddOnInfo
local GetFramerate, GetNetStats = GetFramerate, GetNetStats

myStats:RegisterEvent("ADDON_LOADED")

local memformat = function(number)
	if number > 1000 then
		return string.format("%.2f mb", (number / 1000))
	else
		return string.format("%.1f kb", floor(number))
	end
end

local addoncompare = function(a, b)
	return a.memory > b.memory
end

local TotalMemory = function()
	local total = 0
	for i = 1, GetNumAddOns() do
		total = total + GetAddOnMemoryUsage(i)
	end
	return memformat(total)
end

function myStats:Initialize()
	self:SetHeight(size + 10)
	self:SetWidth(150)
	self:SetPoint("TOP", Minimap, "BOTTOM", offsetX, offsetY)
	self:SetBackdrop(backdropTable)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetFrameStrata("LOW")
	self:RegisterForClicks("AnyUp")
	
	self.text = self:CreateFontString(nil, "OVERLAY")
	self.text:SetFont(font, size, nil)
	self.text:SetPoint("CENTER", self, "CENTER", 0, 1)
	self.text:SetJustifyH("CENTER")
	self.text:SetTextColor(color.r, color.g, color.b)
	
	self.addons = {}
	self.addonGroups = {
		["Standalone Libs"] = {
			matchList = {
				["Ace2"] = 1,
				["Ace3"] = 1,
				["FuBarPlugin-2.0"] = 1,
				["DewdropLib"] = 1,
				["LibSharedMedia-3.0"] = 1,
				["SharedMedia"] = 1,
				["SinkLib"] = 1,
				["TabletLib"] = 1,
				["AceGUI-3.0-SharedMediaWidgets"] = 1
			}
		},
		["Skada Modules"] = {
			matchString = "Skada",
		},
		--["Grid Modules"] = {
		--	matchString = "Grid",
		--},
		--["BigWigs Modules"] = {
		--	matchString = "BigWigs",
		--},
		["DBM Modules"] = {
			matchstring = "DBM",
		},
		["DXE Modules"] = {
			matchstring = "DXE",
		},
		["AzCastBar Modules"] = {
			matchString = "acb",
		}
	}		
	self.addonColors = {
		["Skada"] = {r = 1, g = 0, b = 0},
		["Grid"] = {r = 1, g = 1, b = 0},
		["DBM"] = {r = 1, g = 0, b = 1},
		["DXE"] = {r = 1, g = 0, b = 1},
		["oUF"] = {r = color.r, g = color.g, b = color.b},
		["my"] = {r = 0, g = 1, b = 0},
		['nib'] = {r = 1, b = 0, c = 0},
	}
end
	
local lineColor = {r = 1, g = 1, b = 1}		
function myStats:UpdateTooltip()
	local addonCount, tempTotal, tIndex, totalEntries, customColor
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
	
	UpdateAddOnMemoryUsage()
	totalEntries = 1
	for i = 1, GetNumAddOns() do
		if GetAddOnMemoryUsage(i) > 0 then
			tIndex = totalEntries
			memory = GetAddOnMemoryUsage(i)
			name = GetAddOnInfo(i)
            
			for groupName, groupConfig in pairs(self.addonGroups) do
				if (groupConfig.matchString and groupConfig.matchString ~= name and name:match(groupConfig.matchString)) or (groupConfig.matchList and groupConfig.matchList[name]) then
					name = groupName
					if not groupConfig.index then
						groupConfig.index = totalEntries
					else
						memory = memory + self.addons[groupConfig.index].memory
						tIndex = groupConfig.index
						totalEntries = totalEntries - 1
					end
				end						
			end
			if not self.addons[tIndex] then
				self.addons[tIndex] = {name = name, memory = memory}
			else
				self.addons[tIndex].name = name
				self.addons[tIndex].memory = memory
			end
			totalEntries = totalEntries + 1
		end
	end
	for i = totalEntries, #self.addons do
		self.addons[i] = nil
	end
	for _, groupConfig in pairs(self.addonGroups) do
		groupConfig.index = nil
	end
	
	table.sort(self.addons, addoncompare)
	addonCount = 0
	overflow = 0

	for _, entry in pairs(self.addons) do
		addonCount = addonCount + 1
		if addonCount > maxShow then
			overflow = overflow + entry.memory
		else
			lineColor.r = 1
			lineColor.g = 1
			lineColor.b = 1
			customColor = false
			for matchStr, addonColor in pairs(self.addonColors) do				
				if entry.name:match(matchStr) and not customColor then
					lineColor.r = addonColor.r
					lineColor.g = addonColor.g
					lineColor.b = addonColor.b
					customColor = true
				end
			end
			
			GameTooltip:AddDoubleLine(entry.name, memformat(entry.memory), lineColor.r, lineColor.g, lineColor.b, lineColor.r, lineColor.g, lineColor.b)
		end
	end
	if overflow > 0 then
		GameTooltip:AddDoubleLine("Overflow", memformat(overflow), 1, 1, 1, 1, 1, 1)
	end

	GameTooltip:AddLine("----------------------------------------------------------------", 1, 1, 1)
	GameTooltip:AddDoubleLine("Total", TotalMemory(), color.r, color.g, color.b, color.r, color.g, color.b)
	GameTooltip:Show()
	self.tooltipShown = true
end

local lastUpdate = 0
myStats:SetScript("OnUpdate", function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if lastUpdate >= 1 then
		lastUpdate = 0
		
		fps = GetFramerate()
		fps = hexColor..floor(fps).."|rfps "
		
		_, _, lag = GetNetStats()
		lag = hexColor..lag.."|rms "

		UpdateAddOnMemoryUsage()
		mem = TotalMemory()
		mem = hexColor..strsub(mem, 1, strlen(mem) - 3).."|r"..strsub(mem, strlen(mem) - 1).." "

		if self.tooltipShown or self.keepShown then self:UpdateTooltip() end
		self.text:SetText(fps..lag..mem)
	end
end)
myStats:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
		self.keepShown = not self.keepShown 
	else
		collectgarbage() 
	end
end)
myStats:SetScript("OnEnter", myStats.UpdateTooltip)
myStats:SetScript("OnLeave", function(self) 
	self.tooltipShown = false
	GameTooltip:Hide() 
end)
myStats:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "myStats" then
		self:UnregisterEvent(event)
		self:Initialize()
	end
end)