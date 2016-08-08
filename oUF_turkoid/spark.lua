--[[
	THIS IS MY OWN MODIFIED VERSION OF POWERSPARK
	
	modified from oUF Powerspark created by Snago
	http://www.wowinterface.com/downloads/info8883-oUF_PowerSpark.html#info
	
	ONLY SHOWS THE FSR FOR MANA BARS	
]]--
local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then return end

local UnitPowerType, GetSpellInfo = UnitPowerType, GetSpellInfo
local fsrtimer
local function OnUpdate(self, elapsed)
	if not self.Spark then 
		self:SetScript("OnUpdate", nil) 
		return 
	end
	local f = fsrtimer + elapsed
	if f > 5 then 
		self.Spark:Hide()
		self:SetScript("OnUpdate", nil)
	elseif UnitPowerType(self.unit) == 0 then
		self.Spark:Show()
		self.Spark:SetPoint("CENTER", self.Spark:GetParent(), "LEFT", f * 0.2 * self.Spark:GetParent():GetWidth(), 0)
	else
		self.Spark:Hide()
	end
	fsrtimer = f
end

local function Update(self, event, unit, spellname)
	if self.unit ~= unit  then return end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, _, cost, _, powerType = GetSpellInfo(spellname)
		if powerType == 0 and cost > 0 then
			fsrtimer = 0
			self:SetScript("OnUpdate", OnUpdate)
		end
	elseif event == "PLAYER_DEAD" then
		self:SetScript("OnUpdate", nil)
		self.Spark:Hide()
	end
end

local function Enable(self)
	if not self.Spark then return end
	
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
	self:RegisterEvent("PLAYER_DEAD", function() self.Spark:Hide() end)
	--self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
	return true
end

local function Disable(self)
	if self.Spark then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
		self:UnregisterEvent("PLAYER_DEAD", function() self.Spark:Hide() end)
		--self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
	end
end

oUF:AddElement("Spark", Update, Enable, Disable)