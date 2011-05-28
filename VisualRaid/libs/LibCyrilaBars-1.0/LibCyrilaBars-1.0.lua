--[[
##############################################
##-
##-  LibCyrilaBars
##-  By Cyrila <Aspire> @ Bloodfeather-EU
##-
##-
##-
##-   * Copyright (C) 2010  Dan Jacobsen
##-   *
##-   * This program is free software: you can redistribute it and/or modify
##-   * it under the terms of the GNU General Public License as published by
##-   * the Free Software Foundation, either version 3 of the License, or
##-   * (at your option) any later version.
##-   *
##-   * This program is distributed in the hope that it will be useful,
##-   * but WITHOUT ANY WARRANTY; without even the implied warranty of
##-   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##-   * GNU General Public License for more details.
##-   *
##-   * You should have received a copy of the GNU General Public License
##-   * along with this program.  If not, see <http://www.gnu.org/licenses/>.
##-
##############################################
]]


local MAJOR, MINOR = "LibCyrilaBars-1.0", 1
assert(LibStub, MAJOR.." requires LibStub")

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local cbh = LibStub:GetLibrary("CallbackHandler-1.0")
assert(cbh, MAJOR.." requires CallbackHandler-1.0")

lib.callbacks = lib.callbacks or cbh:New(lib)

-- -------------------------
--	Locals
-- -------------------------

local GetTime,PlaySoundFile = _G.GetTime,_G.PlaySoundFile
local error,assert,type = error,assert,type
local ipairs,pairs,next,unpack = ipairs,pairs,next,unpack
local sin,sqrt,floor,ceil = sin,sqrt,floor,ceil
local format = format

local AceTimer = LibStub("AceTimer-3.0")


-- -------------------------
-- Init
-- -------------------------

local prototype = {}
local prototypeHeader = {}
local active = {}
local inactive = {}
local headers = {}

-- --------------------
--  Include modules
-- --------------------

lib.plugin = {}

lib.embeds = lib.embeds or {}

do
	local mixins = {"SpawnHeader", "NewBar", "SearchBar", "SearchHeader", "mod"}
	function lib:Embed(target)
		for k, v in pairs(mixins) do
			target[v] = self[v]
		end
		lib.embeds[target] = true
		return target
	end
end

local maxbars = 50


local function throw(eid, ...)
end

local function catch(eid, ...)
end

-- -------------------------
--	Updaters and helpers
-- -------------------------

local function GetBarByID(id)
	for bar in pairs(active) do
		if id == bar.data.id then
			return bar
		end
	end
	return nil
end

local function GetHeaderByName(name)
	for header in pairs(headers) do
		if name == header.name then
			return header
		end
	end
	return nil
end

local function MMSS(time)
	local min = floor(time/60)
	local sec = ceil(time % 60)
	return ("%d:%02d"):format(min,sec)
end


local function OnUpdate(self,elapsed)
	local bar = next(active)
	if not bar then self:Hide() return end
	local time = GetTime()
	while bar do
		if not bar.data.endTime then
		
			bar.timer:SetText("#INF "..MMSS(bar.data.timeleft))
			
		else
		
			bar.data.timeleft = bar.data.endTime-time or 0
			
			if(bar.data.timeleft<=0) then
				bar:Release()
				return
			end
			
			local value = (bar.data.timeleft / bar.data.totalTime)
			bar.statusbar:SetValue(value)
			bar.spark:SetPoint("CENTER", bar.statusbar, "LEFT", value*bar.statusbar:GetWidth(), 0);
			bar.timer:SetText(MMSS(bar.data.timeleft))
			
			if(bar.data.animatetable) then
				--header,x,y,starttime,animtime
				local h,x,y,t0,at = unpack(bar.data.animatetable)
				local pcpl = (GetTime() - t0) / at
				if pcpl>=1 then
					pcpl = 1
					bar.data.animatetable = nil
				end
				x = bar.data.x + (x - bar.data.x) * pcpl
				y = bar.data.y + (y - bar.data.y) * pcpl
				bar:SetPoint("CENTER", h, "CENTER", x, y)
				bar.data.x, bar.data.y = x,y
			end
			
			if(bar.data.flash) then
				-- maths to the rescue
				-- alternative to blizzard's restrictive animation system
				local a = 0.5 * sin(sqrt(bar.data.timeleft)*1500) + 0.5
				bar.statusbarbg:SetAlpha(a);
			end
			
			-- FIXER
			if not bar.data.flash then
				bar.statusbarbg:SetAlpha(1)
			end
			--if not bar.data.animatetable then
			--	-- Check if position is correct
			--end
			
		end
		
		bar = next(active,bar)
	end
end

local BarUpdate = CreateFrame("Frame", nil, UIParent)
BarUpdate:SetScript("OnUpdate",OnUpdate)
BarUpdate:Hide()


local order = {}
local bartbl = {}

local function ReSort(header)
	local bar = next(active)
	while bar do
		if bar.data.headerName == header.name then
			-- Lets get to it!
			if bar.data.sort then
				--tinsert(order,bar.data.sort)
				bar.order = bar.data.sort
				tinsert(bartbl,bar)
			else
				--tinsert(order,bar.data.headerPos)
				bar.order = bar.data.headerPos
				tinsert(bartbl,bar)
			end
		end
		bar = next(active,bar)
	end
	
	if #bartbl>1 then
		table.sort(bartbl, function(n1, n2)
			if not n1 then n1 = {order = 0} end
			if not n2 then n2 = {order = 0} end
			return n1.order < n2.order
		end)
	end
	local i = 1
	for _,bar in ipairs(bartbl) do
		bar.data.headerPos = i
		if bar.data.sort then 
			bar.data.sort = tonumber(("%d%02d"):format(tonumber(strsub(bar.data.sort,1,-3)),i)) 
			--print("Sorting: "..tostring(bar.data.sort))
		end
		bar:SnapIntoPlace()
		i = i + 1
	end
	wipe(order)
	wipe(bartbl)
end

local function OnRelease(bar,pos,header)
	if type(header)=="string" then
		-- Header table was not sent, instead we got the name of the header.
		-- Let's find our frame
		header = GetHeaderByName(header)
	end
	header.numbars = header.numbars - 1
	ReSort(header)
	--[[
	header.bars[pos] = nil
	local i = pos + 1
	while(header.bars[i]) do
		if not header.bars[i-1] then
			local bar = GetBarByID(header.bars[i])
			header.bars[i] = nil
			header.bars[i-1] = bar.data.id
			bar.data.headerPos = i - 1
			bar:SnapIntoPlace()
		end
		i = i + 1
	end]]
end

function prototype:Release()
	self:ClearAllPoints()
	self:UnregisterAllEvents()
	self:CancelAllTimers()
	active[self] = nil
	inactive[self] = true
	
	self:Hide()
	OnRelease(self, self.data.headerPos, self.data.headerName)
	wipe(self.data)
end


-- -------------------------------------
--	Bar prototype
-- -------------------------------------

function prototype:Start()
end

function prototype:EffectFlash()
	self.data.flash = true
end

function prototype:IsRunning()
	if self.data.id then return true end
	return nil
end

function prototype:IsPaused()
	return self.data.IsPaused
end

function prototype:Pause()
	-- Pauses ALL currently running animation functions.
	local time = GetTime()
	if not self.data.IsPaused then
		self.data.pauseTbl = {
			endTime = self.data.endTime,
			pauseStart = time,
		}
		self.data.endTime = nil
	else
		local endTime = self.data.pauseTbl.endTime
		local pauseStart = self.data.pauseTbl.pauseStart
		self.data.endTime = endTime + (time-pauseStart)
		wipe(self.data.pauseTbl)
	end
	self.data.IsPaused = not self.data.IsPaused
end

function prototype:SetTimeleft(timeleft)
	if type(timeleft)~="number" then timeleft = 1 end
	--print(("Updating Bar with ID: %s, Header: %s. Timeleft: %d, Label: %s"):format(self.data.id,self.data.headerName,timeleft,self.label:GetText()))
	self.data.timeleft = timeleft
	self.data.flash = nil
	
	self.data.startTime = GetTime()
	self.data.endTime = GetTime()+timeleft
	self.data.totalTime = timeleft
	self:ScheduleTimer("EffectFlash", timeleft-2)
	self:SetScript("OnUpdate",OnUpdate)
end

function prototype:SetID(id)
	assert(not self.data.id and not self.data.headerPos, "<LibCyrilaBars-1.0>  Usage: SetID(id): Headers were already sent. You can not change ID on an active bar.")
	self.data.id = id
end

function prototype:SetManyAttributes(t)
	for k,v in pairs(t) do
		self:SetAttribute(k,v)
	end
end

function prototype:SetAttribute(k,v)
	self.data[k] = v
end

function prototype:GetAttribute(k)
	return self.data[k]
end

function prototype:SetIcon(path)
	self.icon.t:SetTexture(path)
end

function prototype:SetLabel(str)
	self.label:SetText(str);
end

function prototype:SetColor(c)
	if not c then return end
	if not c[1] or not c[2] or not c[3] then return end
	self.statusbar:SetStatusBarColor(unpack(c))
end

function prototype:TranslateTo(h,x,y,s)
	if not s then s = 1 end
	self.data.animatetable = {h,x,y,GetTime(),s}
end

function prototype:SnapIntoPlace()
	local header = GetHeaderByName(self.data.headerName)
	local xOfs,yOfs
	xOfs = 0
	yOfs = (self.data.headerPos ~= 1) and (header.data.Height + header.data.Spacing)*(self.data.headerPos-1) or 0
	self:TranslateTo(header,xOfs,-yOfs,1)
	--[[
	self:SetPoint("CENTER", header, "CENTER", xOfs, -yOfs)
	self.data.x, self.data.y = xOfs, yOfs
	]]
end

function prototype:AnchorTo(header)
	if type(header)=="string" then
		-- Header table was not sent, instead we got the name of the header.
		-- Let's find our frame
		header = GetHeaderByName(header)
	end
	header.numbars = header.numbars + 1
	local xOfs,yOfs
	xOfs = 0
	--yOfs = (header.numbars ~= 1) and (header.data.Height + header.data.Spacing)*(header.numbars-1) or 0
	yOfs = 0
	self:SetPoint("CENTER", header, "CENTER", xOfs, -yOfs)
	self.data.x, self.data.y = xOfs, -yOfs
	header.bars[header.numbars] = self.data.id
	self.data.headerPos = header.numbars
	self.data.headerName = header.name
	
	ReSort(header)
end


-- ---------------------
-- Bar creation
-- ---------------------

local function ApplySettings(bar, t)
	bar:SetHeight(t.Height)
	bar:SetWidth(t.Width)
	bar:SetScale(t.Scale)
	
	bar.statusbar:SetValue(1)
	bar.statusbar:SetWidth(t.BarWidth)
	bar.statusbar:SetHeight(t.BarHeight)
	bar.statusbar:SetStatusBarTexture(t.BarTexture)
	
	bar.statusbarbg:SetAlpha(t.BGAlpha)
	bar.statusbarbg:SetVertexColor(.1,.1,.1)
	bar.statusbarbg:SetTexture(t.BarTexture)
	
	bar.spark:SetHeight(t.BarHeight+5)
	bar.spark:SetWidth(15)
	
	bar.icon:SetSize(t.Height, t.Height);
	
	bar.label:SetFont(t.LabelFont, t.LabelFontSize, t.LabelFontFlags)
	bar.timer:SetFont(t.TimerFont, t.TimerFontSize, t.TimerFontFlags)
	
	--[[
	self.bg:Hide()
	self.bg2:Hide()
	self.iconbg:Hide()
	self.iconbg2:Hide()
	]]
end


local numbars = 1
local function NewBarPrototype()
	assert(numbars<maxbars,"<LibCyrilaBars-1.0>  Fatal Error! could not create additional bars. Reason: Number of active bars exceeds maximum number of allotted bars.")
	
	local self = CreateFrame("Frame","CyrilaBars"..numbars,UIParent)
	self:SetHeight(20)
	self:SetWidth(200)
	self:SetScale(1)
	
	self:Show()
	
	self.data = {}
	
	local statusbar = CreateFrame("StatusBar",nil,self)
	statusbar:SetPoint("BOTTOM",self,"BOTTOM");
	statusbar:SetFrameStrata("MEDIUM");
	statusbar:SetStatusBarTexture("Interface\\AddOns\\VisualRaid\\media\\statusbar.tga")
	statusbar:SetMinMaxValues(0,1) 
	statusbar:SetValue(0.5)
	statusbar:SetStatusBarColor(0.41, 0.80, 0.94, 1);
	statusbar:SetWidth(200)
	statusbar:SetHeight(5)
	statusbar:Show()
	
	local statusbarbg = statusbar:CreateTexture(nil, "BACKGROUND")
	statusbarbg:SetAllPoints(statusbar)
	statusbarbg:SetTexture("Interface\\AddOns\\VisualRaid\\media\\statusbar.tga")
	statusbarbg:SetVertexColor(.1,.1,.1)
	
	self.statusbar = statusbar
	self.statusbarbg = statusbarbg
	
	local bg = CreateFrame("Frame", nil, statusbar)
	bg:SetPoint("TOPLEFT", statusbar, "TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", statusbar, "BOTTOMRIGHT", 1, -1)
	bg:SetFrameStrata("LOW")
	bg:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8",
	insets = {left = 0,right = 0,top = 0,bottom = 0}});
	bg:SetBackdropColor(0, 0, 0, 1)
	bg:Show()
	self.bg = bg
	
	
	local bg2 = CreateFrame("Frame", nil, statusbar)
	bg2:SetPoint("TOPLEFT", statusbar, "TOPLEFT", -5, 5)
	bg2:SetPoint("BOTTOMRIGHT", statusbar, "BOTTOMRIGHT", 5, -5)
	bg2:SetFrameStrata("BACKGROUND")
	bg2:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\AddOns\\VisualRaid\\media\\glowTex", edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	bg2:SetBackdropColor(0.55, 0.55, 0.55, 0.8)
	bg2:SetBackdropBorderColor(0, 0, 0)
	bg2:Show()
	self.bg2 = bg2
	
	--local border = CreateFrame("Frame",nil,self)
	--border:SetAllPoints(true)
	--border:SetFrameLevel(statusbar:GetFrameLevel()+1)
	
	
	local spark = statusbar:CreateTexture(nil,"OVERLAY");
	spark:SetTexture("Interface\\AddOns\\VisualRaid\\media\\Spark");
	spark:SetBlendMode("ADD");
	spark:SetHeight(10)
	spark:SetWidth(15)
	spark:SetVertexColor(1, 1, 1, 0.3)
	spark:SetPoint("CENTER",statusbar,"CENTER");
	self.spark = spark
	
	local label = statusbar:CreateFontString(nil, "OVERLAY")
	label:SetPoint("LEFT", self, 4, 0)
	label:SetFont("Interface\\AddOns\\VisualRaid\\media\\font.ttf", 9, "OUTLINE, MONOCHROME")
	label:SetShadowOffset(0, 0)
	label:SetTextColor(1, 1, 1)
	label:SetText("#SPELL");
	self.label = label
	
	local timer = statusbar:CreateFontString(nil, "OVERLAY")
	timer:SetPoint("RIGHT", self, -4, 0)
	timer:SetFont("Interface\\AddOns\\VisualRaid\\media\\font.ttf", 9, "OUTLINE, MONOCHROME")
	timer:SetShadowOffset(0, 0)
	timer:SetTextColor(1, 1, 1)
	timer:SetText("00:00");
	self.timer = timer
	
	
	-- CREATE ICON
	local icon = CreateFrame("Button", nil, self);
	icon:SetFrameStrata("MEDIUM");
	icon:SetPoint("BOTTOM",self,"BOTTOMLEFT", -14, 0);
	icon:SetSize(15, 15);
	icon:Show();
	
	icon.t = icon:CreateTexture(nil,"OVERLAY")
	icon.t:SetTexCoord(.1, .9, .1, .9)
	icon.t:SetAllPoints(icon)
	self.icon = icon
	
	local iconbg = CreateFrame("Frame", nil, icon)
	iconbg:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
	iconbg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
	iconbg:SetFrameStrata("LOW")
	iconbg:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8",
	insets = {left = 0,right = 0,top = 0,bottom = 0}});
	iconbg:SetBackdropColor(0.1, 0.1, 0.1, 1)
	iconbg:Show()
	self.iconbg = iconbg
	
	local iconbg2 = CreateFrame("Frame", nil, icon)
	iconbg2:SetPoint("TOPLEFT", icon, "TOPLEFT", -5, 5)
	iconbg2:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 5, -5)
	iconbg2:SetFrameStrata("BACKGROUND")
	iconbg2:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\AddOns\\VisualRaid\\media\\glowTex", edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	iconbg2:SetBackdropColor(0.55, 0.55, 0.55, 0.8)
	iconbg2:SetBackdropBorderColor(0, 0, 0)
	iconbg2:Show()
	self.iconbg2 = iconbg2
	
	
	AceTimer:Embed(self)
	for k,v in pairs(prototype) do self[k] = v end
	
	self.uid = numbars -- Unique identifier
	
	numbars = numbars + 1

	return self
end

local function GetBarPrototype()
	local bar = next(inactive)
	if bar then
		inactive[bar] = nil
	else
		bar = NewBarPrototype()
	end
	active[bar] = true
	BarUpdate:Show()
	bar:Show()
	
	return bar
end

local function BartableFillMissing(bt)
	if not bt then bt = {} end
	
	local t = {}
	-- Size
	t.Scale = 1
	t.Width = 200
	t.Height = 15
	t.Spacing = 7
	-- Background
	t.BGTextureEnabled = 1
	t.BGAlpha = 1
	t.BGColor = {0, 0, 0}
	-- Bar
	t.BarWidth = 200
	t.BarHeight = 15
	t.BarGrowth = "DOWN"
	t.BarDirection = "LEFTTORIGHT"
	t.BarFillDeplete = "DEPLETE"
	t.BarTexture = ""
	-- Colors
	t.BarAlpha = 1
	t.BarColor = {100/255, 100/255, 100/255}
	-- Icon
	t.IconEnabled = 1
	t.IconScale = 1
	t.IconXOffset = 0
	t.IconYOffset = 0
	-- Spark
	t.SparkEnabled = 1
	t.SparkColor = {1, 1, 1, 1}
	-- Label
	t.LabelEnabled = 1
	t.LabelFont = ""
	t.LabelFontSize = 10
	t.LabelFontFlags = "OUTLINE, MONOCRHOME"
	t.LabelFontColor = {1, 1, 1, 1}
	--t.Label
	-- Timer
	t.TimerEnabled = 1
	t.TimerFont = ""
	t.TimerFontSize = 10
	t.TimerFontFlags = "OUTLINE, MONOCHROME"
	t.TimerFontColor = {1, 1, 1, 1}
	
	for k,v in pairs(bt) do
		assert(t[k], ("<LibCyrilaBars-1.0>  Usage: SpawnHeader(name, parent, xOfs, yOfs, settings table): 'settings table' - '%s' is not a valid setting. Refer to template function BartableFillMissing for a list of available settings."):format(k))
		assert(type(t[k])==type(v), ("<LibCyrilaBars-1.0>  Usage: SpawnHeader(name, parent, xOfs, yOfs, settings table): 'settings table' - '%s' expected for '%s' got '%s'."):format(type(t[k]),k,v))
		t[k] = v
	end
	
	return t
end


-- --------------------------
--	Header Prototype
-- --------------------------

function prototypeHeader:SetPoint()
	error("<LibCyrilaBars-1.0>  Call to locked function SetPoint(). Error: Please do not use SetPoint() to translate headers. Use Move(point, xOffset, yOffset) instead.")
end

function prototypeHeader:Move(p,x,y)
	self:SetPointInternal("CENTER", p, "CENTER", x, y)
end

function prototypeHeader:SetManyAttributes(t)
	for k,v in pairs(t) do
		self:SetAttribute(k,v)
	end
end

function prototypeHeader:SetAttribute(k,v)
	if(self.data[k]) then
		assert(type(self.data[k])==type(v), ("<LibCyrilaBars-1.0>  Usage: SetAttribute(key, value): 'value' - '%s' expected for '%s' got '%s'."):format(self.data[k],k,v))
	end
	self.data[k] = v
end

function prototypeHeader:SetSortMethod(stype)
	self.data.sort = "manual"
end


-- -------------------------------
--	Embeddable functions
-- -------------------------------

local numheaders = 1
function lib:SpawnHeader(name, xOfs, yOfs, point, rpoint, bartable, sortmethod, label)
	name = name or "CyrilaBarHeader"..numheaders
	assert(type(name)=="string", ("<LibCyrilaBars-1.0>  Usage: SpawnHeader([name, parent, xOfs, yOfs, settings table]: 'name' - string expected got '%s'"):format(name))
	parent = parent or UIParent
	xOfs = xOfs or 0
	yOfs = yOfs or 0
	point = point or "CENTER"
	rpoint = rpoint or "CENTER"
	bartable = BartableFillMissing(bartable)
	
	local header = CreateFrame("Frame",name,UIParent)
	header:ClearAllPoints()
	header:SetPoint(point, UIParent, rpoint, xOfs, yOfs)
	header.data = bartable
	header.data.x = xOfs
	header.data.y = yOfs
	header.data.point = point
	header.data.rpoint = rpoint
	header.numbars = 0
	header.name = name
	header.label = label or name
	header.bars = {}
	
	header:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8",
	insets = {left = 0,right = 0,top = 0,bottom = 0}});
	header:SetBackdropColor(.1, .1, .1, 1)
	header:EnableMouse(true)
	header:SetScript("OnLeave", function(self)
		-- save pos
		local point, _, rpoint, xOfs, yOfs = self:GetPoint()
		self.data.x = xOfs
		self.data.y = yOfs
		self.data.point = point
		self.data.rpoint = rpoint
	end)
	
	header.tr = header:CreateTitleRegion()
	header.tr:SetAllPoints(header)
	
	header:SetHeight(20)
	header:SetWidth(200)
	
	header.SetPointInternal = header.SetPoint
	for k,v in pairs(prototypeHeader) do header[k] = v end
	
	numheaders=numheaders+1
	
	--
	-- header table is returned, but not required to create bars.
	-- If you use a predefined name, simply call NewBar with header as a string instead of a table without catching return value
	--
	
	header:SetSortMethod(sortmethod)
	header:Hide()
	
	headers[header] = true
	return header
end

local barUID = 1
function lib:NewBar(header, id, label, timeleft, icon, colors, customsort)
	if type(header)=="string" then
		-- Header table was not sent, instead we got the name of the header.
		-- Let's find our frame
		header = GetHeaderByName(header)
	end
	assert(header, "")
	if not header then return nil end
	if not header.name then return nil end
	if not id then id = barUID end
	
	
	local bartable = header.data
	local bar = GetBarPrototype()
	ApplySettings(bar, bartable)
	bar:SetID(id)
	bar.data.sid = barUID
	if customsort then 
		bar.data.sort = tonumber(("%d99"):format(tonumber(customsort)))
	end
	--bar:SetID(id)
	bar:AnchorTo(header)
	bar:SetLabel(label)
	bar:SetTimeleft(timeleft)
	bar:SetIcon(icon)
	bar:SetColor(colors)
	
	barUID = barUID+1
	return bar
end

function lib:SearchBar(pattern)
	local bar
	if type(pattern)=="string" then
		bar = GetBarByID(pattern)
		if bar then return bar end
		-- Keep searching
	end
	return bar
end

function lib:SearchHeader(pattern)
	local header
	-- do something
	return header
end

