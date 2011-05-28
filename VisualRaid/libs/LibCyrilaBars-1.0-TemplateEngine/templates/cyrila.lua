-- Cyrila template

local function func()
	local self = CreateFrame("Frame","CyrilaBarsTemplate",UIParent)
	self:SetHeight(20)
	self:SetWidth(200)
	self:SetScale(1)
	
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
end

local function bartable()
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
end

