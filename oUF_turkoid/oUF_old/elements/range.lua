--[[
	Elements handled: .Range

	Settings:
	 - inRangeAlpha - A number for frame alpha when unit is within player range.
	 Required.
	 - outsideRangeAlpha - A number for frame alpha when unit is outside player
	 range. Required.
--]]
local oUF
local parent
if(...) then
	parent = ...
else
	parent = debugstack():match[[\AddOns\(.-)\]]
end

local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
if(...) then
	local _, ns = ...
	oUF = ns.oUF
else
	oUF = _G[global]
end

local objects = oUF.objects
local OnRangeFrame

local UnitClass = UnitClass
local _, class = UnitClass("player")
local friendID, hostileID

if class == "PRIEST" then
	friendID = 29170
	hostileID = 5176
elseif class == "DRUID" then
	friendID = 5185
	hostileID = 5176
elseif class == "PALADIN" then
	friendID = 635
	hostileID = 5176
elseif class == "SHAMAN" then
	friendID = 331
	hostileID = 5176
elseif class == "WARLOCK" then
	friendID = 172
	hostileID = 5176
elseif class == "MAGE" then
	friendID = 133
	hostileID = 5176
elseif class == "HUNTER" then
	friendID = 75
	hostileID = 5176
else
	friendID = 5185
	hostileID = 5176
end

local IsSpellInRange, UnitInRange, UnitIsVisible, GetSpellInfo, CheckInteractDistance = IsSpellInRange, UnitInRange, UnitIsVisible, GetSpellInfo, CheckInteractDistance

-- updating of range.
local lastUpdate = 0
local OnRangeUpdate = function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	
	if(lastUpdate >= .1) then
		local inrange 
		for _, object in ipairs(objects) do
			if object:IsShown() and object.Range then
				inrange = CheckInteractDistance(object.unit, 3)
				inrange = inrange or CheckInteractDistance(object.unit, 4)
				inrange = inrange or UnitInRange(object.unit)
				inrange = inrange or (not UnitIsDead(object.unit) and IsSpellInRange(GetSpellInfo(hostileID), object.unit))
				inrange = inrange or (not UnitIsDead(object.unit) and IsSpellInRange(GetSpellInfo(friendID), object.unit))
				inrange = inrange or (not UnitIsDead(object.unit) and UnitIsVisible(object.unit))
				
				if inrange == 1 then
					if object:GetAlpha() ~= object.inRangeAlpha then
						object:SetAlpha(object.inRangeAlpha)
					end
				else
					if object:GetAlpha() ~= object.outsideRangeAlpha then
						object:SetAlpha(object.outsideRangeAlpha)
					end
				end
			end
		end

		lastUpdate = 0
	end
end

local Enable = function(self)
	if(self.Range and not OnRangeFrame) then
		OnRangeFrame = CreateFrame "Frame" 
		OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
	end
end

oUF:AddElement('Range', nil, Enable)
