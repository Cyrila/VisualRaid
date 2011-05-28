--[[
	Author: Kollektiv
	Usage:
		type = "select"
		dialogControl = "SA_FauxScrollFrame"
]]

local AceGUI = LibStub("AceGUI-3.0")
local buttonHeight = 16
local buttonNum = 11

local font = CreateFont("SA_FauxScrollFrameButtonFont")
font:SetFont(GameFontNormal:GetFont(),12)
font:SetJustifyH("LEFT")

local function fixlevels(parent,...)
	local i = 1
	local child = select(i, ...)
	while child do
		child:SetFrameLevel(parent:GetFrameLevel()+1)
		i = i + 1
		child = select(i, ...)
	end
end

do
	local widgetType = "SA_FauxScrollFrameButton"
	local widgetVersion = 1

	local function OnAcquire(self)

	end
	
	local function OnRelease(self)
		self.frame:ClearAllPoints()
		self.frame:Hide()
	end
	
	local function OnClick(self)
		self.obj.userdata.obj:Fire("OnValueChanged", self.obj.userdata.value)
	end

	local function SetDisabled(self,disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
		else
			self.frame:Enable()
		end
	end

	local function Constructor()
		local self = {}
		self.type = widgetType

		local count = AceGUI:GetNextWidgetNum(widgetType)
		local frame = CreateFrame("Button","SA_FauxScrollFrameButton"..count,UIParent)
		frame:SetWidth(130)
		frame:SetHeight(buttonHeight)
		frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
		frame:SetScript("OnClick",OnClick)
		frame:SetNormalFontObject(font)

		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.SetDisabled = SetDisabled
		
		self.frame = frame
		frame.obj = self

		AceGUI:RegisterAsWidget(self)
		return self
	end
	
	AceGUI:RegisterWidgetType(widgetType,Constructor,widgetVersion)
end


do
	local widgetType = "SA_FauxScrollFrame"
	local widgetVersion = 1
	
	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		for i=1,buttonNum do
			local button = AceGUI:Create("SA_FauxScrollFrameButton")
			button.userdata.obj = self
			self.buttons[i] = button
			button:SetPoint("TOPLEFT",self.frame,"TOPLEFT",11,-1*i*buttonHeight+5)
			button.frame:SetParent(self.frame)
		end
		fixlevels(self.frame,self.frame:GetChildren())
	end

	local function OnRelease(self)
		self:SetDisabled(false)
		for _,button in ipairs(self.buttons) do
			AceGUI:Release(button)
		end
		wipe(self.buttons)
		self.frame:Hide()
		self.frame:ClearAllPoints()
	end
	
	local function SetLabel(self,name)
		self.label:SetText(name)
	end
	
	local function SetValue(self,value)
		self.userdata.value = value
		self:UpdateScrollBar()
	end

	local function GetListNum(self)
		local n = 0
		for _ in pairs(self.list) do n = n + 1 end
		return n
	end

	local function UpdateScrollBar(self)
		local listNum = self:GetListNum()
		FauxScrollFrame_Update(self.frame,listNum,buttonNum,buttonHeight,nil,nil,nil,nil,nil,nil,true)
		for line=1,buttonNum do
			local lineOffset = line + FauxScrollFrame_GetOffset(self.frame)
			local button = self.buttons[line]
			button.userdata.value = self.sortlist[lineOffset]
			if lineOffset <= listNum then
				button.frame:SetText(self.list[self.sortlist[lineOffset]])
				if self.sortlist[lineOffset] ~= self.userdata.value then 
					button.frame:SetNormalTexture("") 
				else 
					button.frame:SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
					button.frame:GetNormalTexture():SetBlendMode("ADD") 
				end
				button.frame:Show()
			else
				button.frame:Hide()
			end
		end
	end

	local function SetList(self, list)
		self.list = list
		if not list then return end
		wipe(self.sortlist)
		for k,v in pairs(list) do
			self.sortlist[#self.sortlist+1] = k
		end
		table.sort(self.sortlist)
	end

	local function OnVerticalScroll(this,offset)
		this.scrollbar:SetValue(offset)
		this.offset = floor((offset / buttonHeight) + 0.5);
		this.obj:UpdateScrollBar()
	end
	
	local function SetDisabled(self,disabled)
		self.disabled = disabled
		if disabled then
			self.frame.up:Disable()
			self.frame.down:Disable()
			self.label:SetTextColor(0.5,0.5,0.5)
			self.frame:SetScript("OnVerticalScroll",nil)
			self.frame:SetScript("OnMouseWheel",nil)
			for _,button in ipairs(self.buttons) do button.frame:Hide() end
		else
			self.frame.up:Enable()
			self.frame.down:Enable()
			self.label:SetTextColor(1,.82,0)
			self.frame:SetScript("OnVerticalScroll",OnVerticalScroll)
			self.frame:SetScript("OnMouseWheel",ScrollFrameTemplate_OnMouseWheel)
			self:UpdateScrollBar()
		end
		
		for _,button in ipairs(self.buttons) do
			button:SetDisabled(disabled)
		end
	end

	local FrameBackdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	}
	
	local ScrollbarBackdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile=nil, tile=true,tileSize=16,
	}

	local function Constructor()
		local self = {}
		self.type = widgetType

		local count = AceGUI:GetNextWidgetNum(widgetType)
		local frame = CreateFrame("ScrollFrame","SA_FauxScrollFrame"..count,UIParent,"FauxScrollFrameTemplate")
		frame:SetHeight(200)
		frame:SetScript("OnVerticalScroll",OnVerticalScroll)
		frame:SetBackdrop(FrameBackdrop)
		frame:SetBackdropColor(0.15,0.15,0.15,0.5)
		frame:SetBackdropBorderColor(0.4,0.4,0.4)

		local scrollbar = _G[frame:GetName().."ScrollBar"]
		scrollbar:ClearAllPoints()
		scrollbar:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-5,-35)
		scrollbar:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-5,35)
		scrollbar:SetBackdrop(ScrollbarBackdrop)
		scrollbar:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
		frame.scrollbar = scrollbar
		frame.up = _G[frame:GetName().."ScrollBarScrollUpButton"]
		frame.down = _G[frame:GetName().."ScrollBarScrollDownButton"]

		local label = frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		label:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)
		label:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
		label:SetJustifyH("LEFT")
		label:SetHeight(18)
		self.label = label

		self.OnAcquire = OnAcquire
		self.OnRelease = OnRelease
		self.SetLabel = SetLabel
		self.SetList = SetList
		self.SetValue = SetValue
		self.GetListNum = GetListNum
		self.UpdateScrollBar = UpdateScrollBar
		self.SetDisabled = SetDisabled

		self.buttons = {}
		self.sortlist = {}
		
		self.frame = frame
		frame.obj = self

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(widgetType,Constructor,widgetVersion)
end
