--[[
	myMoney v1.2.0
	Tracks your money spent and gained
	
	by Turkoid
	
	credits:  MoneyFu for the design and UpdateText() method
]]--

myMoneyFrame = CreateFrame("button", "myMoneyFrame", UIParent)
myMoney = CreateFrame("frame", "myMoney", myMoneyFrame)

local pairs, ipairs, time, sort = pairs, ipairs, time, sort

--[[ Configuration ]]--
--SETTING ANY VALUE TO NIL WILL USE THE DEFAULT VALUES

local fnt = "Interface\\Addons\\myMedia\\ABF.ttf"
local backgroundTexture = "Interface\\ChatFrame\\ChatFrameBackground" --"Interface\\Tooltips\\UI-Tooltip-Background"
local borderTexture = "Interface\\Addons\\myMedia\\border.blp"
local showBorder = true
local backgroundAlpha = 1 --alpha of moneyframe not tooltip
local fntsize = 14
local justification = "center" --left, center, or right
local minWidth = 150 --the frame will not get anything smaller than this value
local customAnchor = true --add a custom anchor in the funciton below
local borderInset = 0
local sortByGold = true --if false sorts by name
local sortDir = "desc" --desc or asc
local frameStrata = "LOW"
local textColor = {
	r = 1, 
	g = 1, 
	b = 1
}
local backdropColor = {
	r = 0, 
	g = 0,
	b = 0
}

--[[ Custom Anchoring ]]--
function myMoney:CustomAnchor()
	myMoneyFrame:SetPoint("TOPLEFT", myStats, "BOTTOMLEFT")
	myMoneyFrame:SetPoint("TOPRIGHT", myStats, "BOTTOMRIGHT")
end

 --[[ Events to Register ]]--
myMoney:RegisterEvent("PLAYER_MONEY")
myMoney:RegisterEvent("ADDON_LOADED")
myMoney:RegisterEvent("PLAYER_ENTERING_WORLD")

--[[ Initialization ]]--
local realmfaction = nil
local playername = UnitName("player")
local realmTotal = 0
local compareFunc = nil
local backdropTable = nil

--graphical coin variables
local goldicon = myMoney:CreateTexture("goldicon", "ARTWORK")
local silvericon = myMoney:CreateTexture("silvericon", "ARTWORK")
local coppericon = myMoney:CreateTexture("coppericon", "ARTWORK")
local goldtext = myMoney:CreateFontString("goldtext", "OVERLAY")
local silvertext = myMoney:CreateFontString("silvertext", "OVERLAY")
local coppertext = myMoney:CreateFontString("coppertext", "OVERLAY")

--databases
realmMoneyData = nil
playerMoneyData = nil

local session = nil
local color_style = nil
local data = nil
local config = nil
local realmChars = {}
local toggle = nil

--tooltip variables
local tooltip = nil
local tooltipText = nil
local frameWidth = 0
local yOffset = 0
local lineNum = 0
local padding = 10

--[[ Helper Functions ]]--
local function Hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local COLOR_COPPER = "|cffeda55f"
local COLOR_SILVER = "|cffc7c7cf"
local COLOR_GOLD = "|cffffd700"

local function FormatMoney(money)
	local neg = money < 0 and "-" or ""
	money = abs(money)
	local gold = floor(money / 10000)
	local silver = floor(mod(money / 100, 100))
	local copper = floor(mod(money, 100))
	
	local formattedText = copper..COLOR_COPPER.."c|r"
	
	if silver > 0 or gold > 0 then
		formattedText = silver..COLOR_SILVER.."s|r "..formattedText
	end
	if gold > 0 then
		formattedText = gold..COLOR_GOLD.."g|r "..formattedText
	end
	formattedText = neg..formattedText
	return formattedText	
end

local function BeginningOf(period)
	local t = date("*t")
	t.hour = 0
	t.min = 0
	t.sec = 0
	
	if period == "week" then
		t.day = t.day - t.wday + 1
	elseif period == "yesterday" then
		t.day = t.day - 1
	end
	
	return time(t)
end

local function PrintLine(txt) --way easier to type
	DEFAULT_CHAT_FRAME:AddMessage(tostring(txt))
end

function myMoney:ToggleFrameLock()
	myMoneyFrame:SetMovable(not myMoneyFrame:IsMovable()) 
	if myMoneyFrame:IsMovable() then
		myMoneyFrame:RegisterForDrag("LeftButton")
		myMoneyFrame:SetBackdropColor(1, 0, 0, 1)
	else
		myMoneyFrame:RegisterForDrag(nil)
		myMoneyFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
	end
end

local function GetPlayerIndexByName(name)
	if not name then return end
	
	local playerIndex = 0
	repeat
		playerIndex = playerIndex + 1
	until playerIndex > #realmMoneyData[realmfaction].chars or strlower(realmMoneyData[realmfaction].chars[playerIndex].name) == strlower(name)

	return playerIndex <= #realmMoneyData[realmfaction].chars and playerIndex
end

--[[ Initialization ]]--
function myMoney:Initialize()
	--default values
	
	fnt = fnt or "Fonts\\FRIZQT__.TTF"
	backgroundTexture = backgroundTexture or "Interface\\Tooltips\\UI-Tooltip-Background"
	borderTexture = borderTexture or "Interface\\Tooltips\\UI-Tooltip-Border"
	backgroundAlpha = backgroundAlpha or 1
	fntsize = fntsize or 14
	justification = justification or "center"
	minWidth = minWidth or 150
	borderInset = borderInset or 0
	frameStrata = frameStrata or "LOW"
	textColor = textColor or {r = 1, g = 1, b = 1}
	backdropColor = backdropColor or {r = 0, g = 0, b = 0}
	backdropColor.a = backgroundAlpha
	backdropTable = {
		bgFile = backgroundTexture, 
		edgeFile = showBorder and borderTexture or nil, 
		tile = false, 
		edgeSize = 16,
		insets = {
			left = borderInset,
			right = borderInset,
			top = borderInset,
			bottom = borderInset
		}
	}	
	
	--frame stuff
	myMoney:SetPoint(strupper(justification) , myMoneyFrame, strupper(justification), 1, 0)
	myMoneyFrame:SetBackdrop(backdropTable)
	myMoneyFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
	myMoneyFrame:SetClampedToScreen(true)
	myMoneyFrame:SetHeight(fntsize + padding)
	myMoneyFrame:SetWidth(minWidth)	
	myMoneyFrame:EnableMouse(true)
	myMoneyFrame:RegisterForClicks("RightButtonUp")
	myMoneyFrame:SetFrameStrata(strupper(frameStrata))
	local x, y = playerMoneyData and playerMoneyData.x or nil, playerMoneyData and playerMoneyData.y or nil
	myMoneyFrame:SetPoint("CENTER", UIParent, x and "BOTTOMLEFT" or "CENTER", x or 0, y or 0)

	--Graphical coins
	goldicon:SetWidth(fntsize - 2)
	goldicon:SetHeight(fntsize - 2)
	goldicon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	goldicon:SetTexCoord(0, 0.25, 0, 1)

	silvericon:SetWidth(fntsize - 2)
	silvericon:SetHeight(fntsize - 2)
	silvericon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	silvericon:SetTexCoord(0.25, 0.5, 0, 1)

	coppericon:SetWidth(fntsize - 2)
	coppericon:SetHeight(fntsize - 2)
	coppericon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	coppericon:SetTexCoord(0.5, 0.75, 0, 1)

	goldtext:SetJustifyH("RIGHT")
	goldtext:SetFont(fnt, fntsize)
	goldtext:SetPoint("RIGHT", goldicon, "LEFT", 0, 0)
	goldtext:SetTextColor(textColor.r, textColor.g, textColor.b)
	
	silvertext:SetJustifyH("RIGHT")
	silvertext:SetFont(fnt, fntsize)
	silvertext:SetPoint("RIGHT", silvericon, "LEFT", 0, 0)
	silvertext:SetTextColor(textColor.r, textColor.g, textColor.b)
	
	coppertext:SetJustifyH("RIGHT")
	coppertext:SetFont(fnt, fntsize)
	coppertext:SetPoint("RIGHT", coppericon, "LEFT", 0, 0)
	coppertext:SetTextColor(textColor.r, textColor.g, textColor.b)
	
	coppericon:SetPoint("RIGHT", myMoney, "RIGHT")
	silvericon:SetPoint("RIGHT", coppertext, "LEFT", 0, 0)
	goldicon:SetPoint("RIGHT", silvertext, "LEFT", 0, 0)
	
	--Databases	
	if not playerMoneyData then -- new user
		playerMoneyData = {
			today = {gained = 0, spent = 0, initialTime = BeginningOf("today")}, 
			yesterday = {gained = 0, spent = 0, initialTime = BeginningOf("yesterday")}, 
			week = {gained = 0, spent = 0, initialTime = BeginningOf("week")}, 
			alltime = {gained = 0, spent = 0, initialTime = time()}
		}
	end
	session = {gained = 0, spent = 0, initialTime = 0}
	
	color_style = {
		title  = {
			r = 1, 
			g = 0.823529, 
			b = 0
		},
		desc = {
			r = 1, 
			g = 1, 
			b = 0
		},
		profit = {
			r = 0, 
			g = 1, 
			b = 0
		},
		debt = {
			r = 1,
			g = 0,
			b = 0
		},
		default = {
			r = 1,
			g = 1,
			b = 1
		},
		help = {
			r = 0,
			g = 0.8,
			b = 1
		}
	}
			
	data = {
		description = nil,
		gained = nil,
		gainedPerHour = nil,
		spent = nil,
		spentPerHour = nil,
		netTitle = nil,
		net = nil,
		netPerHour = nil,
		netColor = nil
	}

	toggle = {
		{text = "Today", hide = playerMoneyData.today.hide, dbIndex = "today"},
		{text = "Yesterday", hide = playerMoneyData.yesterday.hide, dbIndex = "yesterday"},
		{text = "This Week", hide = playerMoneyData.week.hide, dbIndex = "week"},
		{text = "All Time", hide = playerMoneyData.alltime.hide, dbIndex = "alltime"},
		{text = "Per Hour", hide = playerMoneyData.hidePerHour, dbIndex = "perhour"},
	}
	
	--tooltip databases	
	config = {
		default = 	{text = "default", size = fntsize, color = color_style.default, justify = "center"},
		title = 	{{text = "My Money", size = floor(fntsize * 1.3), color = color_style.title}},
		blank = 	{{text = ""}},
		base = 
		{
			{
				{text = function() return data.description end, justify = "left"},
				{text = "Amount", justify = playerMoneyData.hidePerHour and "right"},
				{text = "Per Hour", justify = "right", hide = playerMoneyData.hidePerHour}
			},
			{
				{text = "Gained", color = color_style.desc, justify = "left"},
				{text = function() return data.gained end, justify = playerMoneyData.hidePerHour and "right"},
				{text = function() return data.gainedPerHour end, justify = "right", hide = playerMoneyData.hidePerHour}
			},
			{
				{text = "Spent", color = color_style.desc, justify = "left"},
				{text = function() return data.spent end, justify = playerMoneyData.hidePerHour and "right"},
				{text = function() return data.spentPerHour end, justify = "right", hide = playerMoneyData.hidePerHour}
			},
			{
				{text = function() return data.netTitle end, color = color_style.desc, justify = "left"},
				{text = function() return data.net end, color = function() return data.netColor end, justify = playerMoneyData.hidePerHour and "right"},
				{text = function() return data.netPerHour end, color = function() return data.netColor end, justify = "right", hide = playerMoneyData.hidePerHour}
			}
		},
		totals = 
		{
			{
				{text = function() return data.description end, justify = "left"},
				{text = function() return data.net end, color = color_style.default, justify = "right"}
			}
		},
		hint = 		{{text = "Hint: Hold down shift to view realm data", color = color_style.profit, justify = "left"}}
	}	
	
	if sortByGold then
		if sortDir == "desc" then
			compareFunc = function(a, b) return a.total > b.total end
		else
			compareFunc = function(a, b) return a.total < b.total end
		end
	else
		if sortDir == "desc" then
			compareFunc = function(a, b) return a.name > b.name end
		else
			compareFunc = function(a, b) return a.name < b.name end
		end
	end		
end

--[[ Update Functions ]]--
function myMoney:UpdatePlayerIndex()
	if not realmMoneyData[realmfaction].chars[playerMoneyData.index] or realmMoneyData[realmfaction].chars[playerMoneyData.index].name ~= playername then
		local newIndex = 0
		repeat
			newIndex = newIndex + 1
		until newIndex > #realmMoneyData[realmfaction].chars or realmMoneyData[realmfaction].chars[newIndex].name == playername
		playerMoneyData.index = newIndex
		if newIndex > #realmMoneyData[realmfaction].chars then
			realmMoneyData[realmfaction].chars[playerMoneyData.index] = {name = playername, total = GetMoney()}
		end
	end
end

function myMoney:SortChars()
	myMoney.UpdatePlayerIndex() --make sure there is an index
	sort(realmMoneyData[realmfaction].chars, compareFunc)
	myMoney.UpdatePlayerIndex() --update the current one
	for index, player in ipairs(realmMoneyData[realmfaction].chars) do
		realmChars[index] = player.name
	end
	sort(realmChars, function(a, b) return a < b end)
end

local day = 60 * 60 * 24
local function UpdateData(db, title)
	local t = time()
	local net = db.gained - db.spent
	
	if title == "Yesterday" then
		t = db.initialTime + day
	end
	data.description = title
	data.gained = FormatMoney(db.gained)
	data.gainedPerHour = FormatMoney(db.gained / ((t - db.initialTime) / 3600))
	data.spent = FormatMoney(db.spent)
	data.spentPerHour = FormatMoney(db.spent / ((t - db.initialTime) / 3600))
	data.netTitle = net < 0 and "Loss" or "Profit"	
	data.net = FormatMoney(net)
	data.netPerHour = FormatMoney(net / ((t - db.initialTime) / 3600))
	data.netColor = (net > 0 and color_style.profit) or (net < 0 and color_style.debt) or color_style.default
end

function myMoney:UpdateTimes()
	local playerTimeChange = floor((time() - playerMoneyData.today.initialTime) / day)
	local realmTimeChange = floor((time() - realmMoneyData[realmfaction].today.initialTime) / day)
	local change = abs(playerTimeChange)	
	if change >= 1 then --next day
		playerMoneyData.today.initialTime = playerMoneyData.today.initialTime + (day * playerTimeChange)
		playerMoneyData.yesterday.initialTime = playerMoneyData.today.initialTime - day
		playerMoneyData.yesterday.gained = change == 1 and playerMoneyData.today.gained or 0
		playerMoneyData.yesterday.spent = change == 1 and playerMoneyData.today.spent or 0
		playerMoneyData.today.gained = 0
		playerMoneyData.today.spent = 0
		
		change = abs(realmTimeChange)
		--update realm data if it hasnt already
		if change >= 1 then
			realmMoneyData[realmfaction].today.initialTime = realmMoneyData[realmfaction].today.initialTime + (day * realmTimeChange)
			realmMoneyData[realmfaction].yesterday.initialTime = realmMoneyData[realmfaction].today.initialTime - day
			realmMoneyData[realmfaction].yesterday.gained = change == 1 and realmMoneyData[realmfaction].today.gained or 0
			realmMoneyData[realmfaction].yesterday.spent = change == 1 and realmMoneyData[realmfaction].today.spent or 0
			realmMoneyData[realmfaction].today.gained = 0
			realmMoneyData[realmfaction].today.spent = 0
		end
	end

	playerTimeChange = floor((time() - playerMoneyData.week.initialTime) / (day * 7))
	realmTimeChange = floor((time() - realmMoneyData[realmfaction].week.initialTime) / (day * 7))
	change = abs(playerTimeChange)	

	if change >= 1 then
		playerMoneyData.week.initialTime = playerMoneyData.week.initialTime + (day * 7 * playerTimeChange)
		playerMoneyData.week.gained = 0
		playerMoneyData.week.spent = 0
		
		change = abs(realmTimeChange)
		if change >= 1 then
			realmMoneyData[realmfaction].week.initialTime = realmMoneyData[realmfaction].week.initialTime + (day * 7 * realmTimeChange)
			realmMoneyData[realmfaction].week.gained = 0
			realmMoneyData[realmfaction].week.spent = 0
		end
	end
end

function myMoney:UpdateText() --Modified from MoneyFu
	--Update text
	local current = GetMoney()	
	local gold = floor(current / 10000)
	local silver = floor(mod(current / 100, 100))
	local copper = floor(mod(current, 100))

	local width = 0
	if gold == 0 then
		goldicon:Hide()
		goldtext:Hide()
	else
		goldicon:Show()
		goldtext:Show()
		goldtext:SetWidth(0)
		goldtext:SetText(gold)
		width = width + goldicon:GetWidth() + goldtext:GetStringWidth()
	end
	if gold == 0 and silver == 0 then
		silvericon:Hide()
		silvertext:Hide()
	else
		silvericon:Show()
		silvertext:Show()
		silvertext:SetWidth(0)
		silvertext:SetText(silver)
		width = width + silvericon:GetWidth() + silvertext:GetStringWidth()
	end
	coppericon:Show()
	coppertext:Show()
	coppertext:SetWidth(0)
	coppertext:SetText(copper)
	width = width + coppericon:GetWidth() + coppertext:GetStringWidth()
	myMoney:SetWidth(width)
	myMoney:SetHeight(fntsize)
	myMoneyFrame:SetWidth(width <= minWidth and minWidth or (width + padding))
	
	local oldCurrent = realmMoneyData[realmfaction].chars[playerMoneyData.index].total
	local change = current - oldCurrent
	local changeType = (change < 0 and "spent") or (change > 0 and "gained") or nil
	
	--update times for per hour calculations
	myMoney.UpdateTimes()
	
	if change ~= 0 then
		--session data
		session[changeType] = session[changeType] + abs(change)
		
		--today data
		playerMoneyData.today[changeType] = playerMoneyData.today[changeType] + abs(change)
		realmMoneyData[realmfaction].today[changeType] = realmMoneyData[realmfaction].today[changeType] + abs(change)
		
		--week data
		playerMoneyData.week[changeType] = playerMoneyData.week[changeType] + abs(change)
		realmMoneyData[realmfaction].week[changeType] = realmMoneyData[realmfaction].week[changeType] + abs(change)
		
		--all time data
		playerMoneyData.alltime[changeType] = playerMoneyData.alltime[changeType] + abs(change)
		realmMoneyData[realmfaction].alltime[changeType] = realmMoneyData[realmfaction].alltime[changeType] + abs(change)
	end
	
	--realm data
	realmMoneyData[realmfaction].chars[playerMoneyData.index].total = current
	if change ~= 0 then
		myMoney.SortChars()
	end
	realmTotal = 0
	for _, player in ipairs(realmMoneyData[realmfaction].chars) do
		realmTotal = realmTotal + player.total
	end
end

--[[ Gametooltip ]]--
local cols = {}
local colSpacing = 30
local lineSpacing = 2
local shiftkey = false
local moneyDB = nil

local frameCols = setmetatable({}, {
	__index = function(t, i)
		local f = CreateFrame("frame", nil, tooltipText)
		local colIndex = mod(i, 10)
		local numCols = floor(i / 10)
		if not cols[numCols] then cols[numCols] = true end
		if colIndex == 1 then
			f:SetPoint("TOPLEFT", tooltipText, "TOPLEFT")
		elseif colIndex == numCols then
			f:SetPoint("TOPRIGHT", tooltipText, "TOPRIGHT")
		end
		rawset(t, i, f)
		return f
	end,
})

local frameStrings = setmetatable({}, {
	__index = function(t, i)
		local fs = tooltipText:CreateFontString(nil)
		rawset(t, i, fs)
		return fs
	end,
})

function myMoney:AnchorTooltip()
	local vTooltip = (myMoneyFrame:GetBottom() - tooltip:GetHeight()) < 0 and "BOTTOM" or "TOP"
	local hAnchor = ((myMoneyFrame:GetCenter() + (tooltip:GetWidth() / 2)) > GetScreenWidth() and "RIGHT") or ((myMoneyFrame:GetCenter() - (tooltip:GetWidth() / 2)) < 0 and "LEFT") or ""
	local vFrame = vTooltip == "TOP" and "BOTTOM" or "TOP"

	--position columns
	local column, spacing
	for numCols in pairs(cols) do
		spacing = (frameCols[numCols..numCols]:GetLeft() or 0) - (frameCols[numCols..1]:GetRight() or 0)
		spacing = spacing / (numCols - 1)
		spacing = spacing <= colSpacing and colSpacing or spacing
		for colIndex = 2, (numCols - 1) do
			column = frameCols[numCols..colIndex]
			column:ClearAllPoints()
			column:SetPoint("TOPLEFT", frameCols[numCols..(colIndex - 1)], "TOPRIGHT", spacing - (column:GetWidth() / 2), 0)	
		end
	end
	
	tooltip:ClearAllPoints()
	tooltip:SetPoint(vTooltip..hAnchor, myMoneyFrame, vFrame..hAnchor)
end

local function AddTooltipLine(index, data)
	local fntstring = frameStrings[index]
	
	fntstring:SetWidth(0)
	fntstring:SetHeight(0)		
	fntstring:SetFont(fnt, data.size or config.default.size)
	fntstring:SetJustifyH(strupper(data.justify or config.default.justify))
	
	local color = type(data.color) == 'function' and data.color() or data.color or config.default.color
	fntstring:SetTextColor(color.r, color.g, color.b)
	fntstring:SetText(type(data.text) == 'function' and data.text() or data.text or config.default.text)
	fntstring:Show()
	
	return fntstring
end

local function AddTooltipData(tooltipData)	
	if not tooltip then
		tooltip = CreateFrame("frame", "myMoneyTooltip", UIParent)
		tooltip:SetScript("OnUpdate", myMoney.onUpdate)
		tooltip:SetBackdrop(backdropTable)					
		tooltip:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, 1)
		tooltip:SetClampedToScreen(true)
		tooltip:SetFrameStrata("HIGH")
		tooltipText = CreateFrame("frame", "myMoneyTooltipText", tooltip )
		tooltipText:SetPoint("TOPLEFT", tooltip, "TOPLEFT", padding, -(padding))
		tooltipText:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", -padding, padding)
	end

	local newLine, lineWidth, newCol, colWidth, lineDataLength
	for line, lineData in ipairs(tooltipData) do
		newLine, lineWidth, lineDataLength = nil, 0, #lineData
		if lineDataLength > 0 then
			for col, colData in ipairs(lineData) do
				if colData.hide then
					lineDataLength = lineDataLength - 1
				end
			end
			for col, colData in ipairs(lineData) do
				if not colData.hide then
					newCol = frameCols[lineDataLength..col]
					newCol:SetHeight(yOffset + (colData.size or config.default.size))
					colWidth = newCol:GetWidth() or 0
					newLine = AddTooltipLine(lineNum..col, colData)
					if newLine:GetWidth() > colWidth then
						colWidth = newLine:GetWidth()					
					end
					newCol:SetWidth(colWidth)
					newLine:ClearAllPoints()
					newLine:SetPoint("TOP", newCol, "TOP", 0, -yOffset)
					newLine:SetPoint(strupper(colData.justify or config.default.justify), newCol, strupper(colData.justify or config.default.justify))				
					lineWidth = lineWidth + colWidth + colSpacing
				end				
			end
			lineWidth = lineWidth - colSpacing
		elseif lineData.text ~= "" then
			newLine = AddTooltipLine(lineNum, lineData)
			newLine:ClearAllPoints()
			newLine:SetPoint("TOP", tooltipText, "TOP", 0, -yOffset)
			newLine:SetPoint(strupper(lineData.justify or config.default.justify), tooltipText, strupper(lineData.justify or config.default.justify))
			lineWidth = newLine:GetWidth()			
		end
		lineNum = lineNum + 1
		yOffset = yOffset + (lineData.text == "" and config.default.size or newLine:GetHeight()) + lineSpacing
		if lineWidth > frameWidth then
			frameWidth = lineWidth
			lineWidth = nil
		end
	end
end

function myMoney:UpdateTooltip()
	yOffset = 0
	frameWidth = 0
	colWidth = 0
	lineNum = 1
	
	myMoney.UpdateTimes()	
	for _, f in pairs(frameCols) do
		f:SetWidth(0)
	end
	if not moneyDB then moneyDB = playerMoneyData end
	
	--title
	AddTooltipData(config.title)	
	config.default.size = 5
	AddTooltipData(config.blank)
	config.default.size = fntsize
	
	--session 
	UpdateData(session, "This Session")
	AddTooltipData(config.base)
	AddTooltipData(config.blank)	
	
	--today
	if not playerMoneyData.today.hide then
		UpdateData(moneyDB.today, "Today")
		AddTooltipData(config.base)	
		AddTooltipData(config.blank)
	end
	
	--yesterday
	if not playerMoneyData.yesterday.hide then
		UpdateData(moneyDB.yesterday, "Yesterday")
		AddTooltipData(config.base)	
		AddTooltipData(config.blank)
	end
	
	--this week
	if not playerMoneyData.week.hide then
		UpdateData(moneyDB.week, "This Week")
		AddTooltipData(config.base)	
		AddTooltipData(config.blank)
	end
	
	--all time
	if not playerMoneyData.alltime.hide then
		UpdateData(moneyDB.alltime, "All Time")
		AddTooltipData(config.base)	
		AddTooltipData(config.blank)
	end
	
	--char totals
	if #realmMoneyData[realmfaction].chars > 1 then
		data.description = "Characters"
		data.net = "Amount"
		AddTooltipData(config.totals)
		config.default.color = color_style.desc
		for _, player in ipairs(realmMoneyData[realmfaction].chars) do
			data.description = player.name
			data.net = FormatMoney(player.total)
			AddTooltipData(config.totals)
		end
		config.default.color = color_style.default
		AddTooltipData(config.blank)
	end
	
	--realm total	
	data.description = "Total"
	data.net = FormatMoney(realmTotal)
	AddTooltipData(config.totals)
	AddTooltipData(config.blank)
	
	--Hint
	AddTooltipData(config.hint)
	
	--frame resizing and positioning	
	tooltip:SetWidth(frameWidth + padding * 2)
	tooltip:SetHeight((yOffset - lineSpacing) + padding * 2)
	
	tooltip:Show()
end

local lastUpdate = 0
function myMoney:onUpdate(elapsed)
	lastUpdate = lastUpdate + elapsed

	if lastUpdate > 1 or shiftkey ~= IsShiftKeyDown() then 
		lastUpdate = 0
		shiftkey = IsShiftKeyDown()
		config.title[1].text = shiftkey and  "My Money: "..GetRealmName() or "My Money"		
		moneyDB = shiftkey and realmMoneyData[realmfaction] or playerMoneyData	
		myMoney.UpdateTooltip()	
	end
	myMoney.AnchorTooltip()
end
		
--[[ Handlers ]]--
local function SlashHandler(msg)
	local cmd, rest = msg:match("^(%S*)%s*(.-)$")
	if cmd == "remove" then
		rest = tonumber(rest) and GetPlayerIndexByName(realmChars[tonumber(rest)]) or GetPlayerIndexByName(rest)
		if rest then
			PrintLine(Hex(color_style.title).."Removed|r: "..realmMoneyData[realmfaction].chars[rest].name)
			table.remove(realmMoneyData[realmfaction].chars, rest)
			realmChars = {}
			myMoney.SortChars()
		else
			PrintLine(Hex(color_style.title).."Usage|r: ["..Hex(color_style.help).."index|r]: name")
			for index, name in ipairs(realmChars) do
				PrintLine(" - "..Hex(color_style.help).."["..index.."]|r: "..name)
			end
		end			
	elseif cmd == "lock" then
		myMoney.ToggleFrameLock()
	elseif cmd == "version" then
		PrintLine(Hex(color_style.title).."myMoney|r: v"..GetAddOnMetadata("myMoney", "Version"))
	elseif cmd == "toggle" then
		rest = tonumber(rest)
		if rest and toggle[rest] then
			toggle[rest].hide = not toggle[rest].hide
			for _, fs in pairs(frameStrings) do
				fs:Hide()
			end
			if toggle[rest].dbIndex == "perhour" then --handles this differently
				for index = 1, 4 do
					config.base[index][2].justify = toggle[rest].hide and "right"
					config.base[index][3].hide = toggle[rest].hide
				end
				playerMoneyData.hidePerHour = toggle[rest].hide			
			else				
				playerMoneyData[toggle[rest].dbIndex].hide = toggle[rest].hide
			end
			if tooltip:IsShown() then
				myMoney.UpdateTooltip()
			end
		end
		PrintLine(Hex(color_style.title).."Usage|r: ["..Hex(color_style.help).."index|r]")
		for index = 1, #toggle do
			PrintLine(" - "..Hex(color_style.help).."["..index.."]|r: "..Hex(color_style.title)..toggle[index].text.."|r("..(toggle[index].hide and (Hex(color_style.debt).."off") or (Hex(color_style.profit).."on")).."|r)")
		end
	else
		PrintLine(Hex(color_style.title).."myMoney|r: Commands")
		PrintLine(" - "..Hex(color_style.title).."remove|r "..Hex(color_style.help).."<index | name>|r: Remove a character (Doesn't reset data)")
		PrintLine(" - "..Hex(color_style.title).."toggle|r "..Hex(color_style.help).."<index>|r: Toggle a calculation")
		PrintLine(" - "..Hex(color_style.title).."lock|r: Toggles frame movement")
		PrintLine(" - "..Hex(color_style.title).."version|r: Prints current version")
	end		
end

myMoney:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "PLAYER_MONEY" then
		self.UpdateText()
	elseif event == "ADDON_LOADED" and arg1 == "myMoney" then
		self:UnregisterEvent(event)
		self.Initialize()
		
		SLASH_MYMONEY1 = "/myMoney"
		SLASH_MYMONEY2 = "/mm"
		SlashCmdList["MYMONEY"] = SlashHandler
		PrintLine(Hex(color_style.title).."myMoney v"..GetAddOnMetadata("myMoney", "Version").."|r loaded.  /myMoney, /mm for options.")
	elseif event == "PLAYER_ENTERING_WORLD" then		
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if customAnchor then
			self.CustomAnchor()
		end
		realmfaction = GetRealmName().." - "..UnitFactionGroup("player")
		if not realmMoneyData then realmMoneyData = {} end
		if not realmMoneyData[realmfaction] then
			realmMoneyData[realmfaction] = {
				today = {gained = 0, spent = 0, initialTime = playerMoneyData.today.initialTime}, 
				yesterday = {gained = 0, spent = 0, initialTime = playerMoneyData.yesterday.initialTime}, 
				week = {gained = 0, spent = 0, initialTime = playerMoneyData.week.initialTime}, 
				alltime = {gained = 0, spent = 0, initialTime = playerMoneyData.alltime.initialTime}
			}
			realmMoneyData[realmfaction].chars = {}
		end		
		if not playerMoneyData.index then
			playerMoneyData.index = #realmMoneyData[realmfaction].chars + 1
			realmMoneyData[realmfaction].chars[playerMoneyData.index] = {name = playername, total = GetMoney()}
		else
			self.UpdatePlayerIndex()
		end
		session.initialTime = time()
		self.SortChars()
		self.UpdateText()
	end
end)
myMoneyFrame:SetScript("OnEnter", myMoney.UpdateTooltip)	
myMoneyFrame:SetScript("OnLeave", function () tooltip:Hide() end)
myMoneyFrame:SetScript("OnClick", myMoney.ToggleFrameLock)
myMoneyFrame:SetScript("OnDragStart", myMoneyFrame.StartMoving)
myMoneyFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	playerMoneyData.x, playerMoneyData.y = self:GetCenter()
end)