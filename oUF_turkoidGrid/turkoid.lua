local parent = ...
local global = GetAddOnMetadata(parent, 'X-oUF')
local oUF = _G[global]
local config = turkoid.config
local PrintLine = config.helper.PrintLine
local raid = CreateFrame("frame", nil, UIParent)

if config.raid then
	raid:SetBackdrop(config.backdropTable)
	raid:SetBackdropColor(0, 0, 0, 0.3)
	raid:SetWidth((config.raid.spacing + config.raid.width + 1) * NUM_RAID_GROUPS + (config.raid.spacing * 2) + 1)
	raid:SetHeight((config.raid.spacing + config.raid.height) * 5 + (config.raid.spacing * 2) + 1)
	raid:SetPoint("TOPLEFT", UIParent, "TOP", 317, -910)
	
	for i = 1, NUM_RAID_GROUPS do
		local raidgroup = oUF:Spawn("header", "oUF_Raid"..i)
		raidgroup:SetAttribute("groupFilter", tostring(i))
		raidgroup:SetAttribute("showRaid", true)
		--raidgroup:SetAttribute("showSolo", true)
		--raidgroup:SetAttribute("showPlayer", true)
		raidgroup:SetAttribute("yOffSet", -config.raid.spacing)
		raidgroup:Show()
		raidgroup:SetParent(raid)
		--raidgroup:SetAttribute("template", "oUF_turkoidRaidTemplate")
		table.insert(raid, raidgroup)
		if i == 1 then
			raidgroup:SetPoint("TOPLEFT", raid, "TOPLEFT", config.raid.spacing * 2, -(config.raid.spacing * 2))
		else
			raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", config.raid.spacing + 1, 0)
		end
	end
end
raid:Show()
raid:RegisterEvent("PLAYER_LOGIN")
raid:RegisterEvent("RAID_ROSTER_UPDATE")
raid:RegisterEvent("PARTY_LEADER_CHANGED")
raid:RegisterEvent("PARTY_MEMBER_CHANGED")
raid:RegisterEvent("PLAYER_ENTERING_WORLD")
raid:SetScript("OnEvent", function(self, event)
	if GetNumRaidMembers() > 0 then
		raid:SetAlpha(1)
	else
		raid:SetAlpha(0)
	end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if GetNumRaidMembers() > 0 then
			raid:Show()
		else	
			raid:Hide()
		end
	end
end)