--[[
##############################################
##- 
##-
##-	VisualRaid by Cyrila
##-       Alpha 2
##-
##############################################
]]

local addon = LibStub("AceAddon-3.0"):NewAddon("visualRaidAssist", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0")
_G.vRA = addon
addon.version = tonumber(("$Revision: 13 $"):match("%d+"))
addon.callbacks = LibStub("CallbackHandler-1.0"):New(addon)
addon.media = LibStub("LibSharedMedia-3.0")


-- -----------------
--  Locals
-- -----------------
local pairs, ipairs, tinsert = pairs, ipairs, tinsert
local format, strupper, strlower, strsub, strfind = string.format, string.upper, string.lower, string.sub, string.find
local UnitIsPlayer = _G.UnitIsPlayer
local GetSpellInfo = _G.GetSpellInfo
local UnitAura = _G.UnitAura
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass

-- --------------------------
--	Include cyrila bars
-- --------------------------
local CyBar = LibStub("LibCyrilaBars-1.0")
local CyBarHeaders = {}
local CyBarData = {}

local font = "Interface\\AddOns\\VisualRaid\\media\\font.ttf"
local fontsize = 9
local fontflags = "OUTLINE, MONOCHROME"

local texture = "Interface\\AddOns\\VisualRaid\\media\\statusbar.tga"


-- --------------------------------
--  DEFAULTS
-- --------------------------------

local db
local defaults = {
	profile = {
		sound = true,
		showActive = true,
		showCD = true,
		effects = true,
		tanks = {
		},
		barsettings = {
			["Global"] = {
				isglobal = true,
				x = 0,
				y = 0,
			},
			["VisualRaid_Active"] = {
				name = "VisualRaid_Active",
				x = 0,
				y = 50,
			},
			["VisualRaid_CDs"] = {
				name = "VisualRaid_CDs",
				x = 0,
				y = -50,
			},
		},
	},
}

local SpellDB = {
	--[[[33076] = {
		cd = 10,   -- Prayer of Mending
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[34861] = {
		cd = 10,   -- Circle of Healing
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
		event = "SPELL_HEAL",
	},
	[586] = {
		cd = 30,   -- Fade
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},]]
	
	
	[47788] = { -- Guardian Spirit
		cd = 150,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[33206] = { -- Pain Suppression
		cd = 144,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	--[[[10060] = { -- Power Infusion
		cd = 96,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},]]
	[73325] = { -- Leap of Faith
		cd = 90,
		event = "SPELL_CAST_SUCCESS",
		dur = 1.5,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[62618] = { -- Power Word: Barrier
		dur = 10,
		event = "SPELL_CAST_SUCCESS",
		cd = 120,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	
	[871] = { -- Shield Wall
		cd = 120,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
		istank = true,
	},
	
	[48792] = { -- Icebound Fortitude
		cd = 180,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
		istank = true,
	},
	
	[16190] = { -- Mana Tide
		dur = 12,
		event = "SPELL_SUMMON",
		cd = 180,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[98008] = { -- Spirit Link Totem
		dur = 6,
		event = "SPELL_SUMMON",
		cd = 180,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	
	[20484] = { -- Rebirth
		dur = 1.5,
		event = "SPELL_RESURRECT",
		cd = 600,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[29166] = { -- Innervate
		cd = 180,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	
	[633] = { -- Lay on Hands
		dur = 1.5,
		event = "SPELL_HEAL",
		cd = 600,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[6940] = { -- Hand of Sacrifice
		cd = 120,
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	
	
	
	
	
	
	
	--[[
	[49576] = {
		cd = 35,   -- Death Grip
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[47528] = {
		cd = 10,   -- Mind Freeze
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[47476] = {
		cd = 120,  -- Strangulate
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[48707] = {
		cd = 45,   -- Anti-Magic Shell
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[61999] = {
		cd = 600,  -- Raise Ally
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[42650] = {
		cd = 600,  -- Army of the Dead
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[55233] = {
		cd = 60,   -- Vampiric Blood
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[49028] = {
		cd = 60,   -- Dancing Rune Weapon
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[49039] = {
		cd = 120,  -- Lichborne
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[45529] = {
		cd = 60,   -- Blood Tap
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[48982] = {
		cd = 30,   -- Rune Tap
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[51271] = {
		cd = 60,   -- Pillar of Frost
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[49203] = {
		cd = 60,   -- Hungering Cold
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[49016] = {
		cd = 180,  -- Unholy Frenzy
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[49206] = {
		cd = 180,  -- Summon Gargoyle
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[46584] = {
		cd = 180,  -- Raise Dead
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[51052] = {
		cd = 120,  -- Anti-Magic Zone
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[57330] = {
		cd = 20,   -- Horn of Winter
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[47568] = {
		cd = 300,  -- Empower Rune Weapon
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},
	[48743] = {
		cd = 120,  -- Death Pact
		activeBar = "VisualRaid_Active",
		cdBar = "VisualRaid_CDs",
	},]]
}

addon.SpellDB = SpellDB

local spellpool = {}

local isInRaid
local playersInRaid = {}
local versionsInRaid = {}
local latestVersion = addon.version
local playerIndex = {}

local sortclass = {
	DRUID = 10,
	HUNTER = 11,
	MAGE = 12,
	PALADIN = 13,
	PRIEST = 14,
	ROGUE = 15,
	SHAMAN = 16,
	WARLOCK = 17,
	WARRIOR = 18,
	DEATHKNIGHT = 19,
	UNKNOWN = 99,
}

--1025 40

--1214 04

-- ------------------------
--	WRAPPERS
-- ------------------------

local debug = true

function addon:print(s)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[vRA]|r "..s)
end

function addon:debug(s)
	if(debug) then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[vRA Debug]|r "..s)
	end
end

function addon:error(s, l)
	error(s, l)
end


-- -------------------------
--	INIT
-- -------------------------


function addon:OnInitialize()
	-- Init
	self.db = LibStub("AceDB-3.0"):New("VisualRaidDB", defaults, "Default")
	db = self.db.profile
	
	--if not db.disabled then
	--	self:SetEnabledState(true)
	--else
	--	self:SetEnabledState(false)
	--end
	
	self.media:Register("statusbar", "VisualRaid", [[Interface\AddOns\VisualRaid\media\statusbar.tga]])
	
	self:RegisterChatCommand("vr", "SlashHandler");
	self:RegisterChatCommand("vraid", "SlashHandler");
	
	-- Version queue
	StaticPopupDialogs["VRA_UPDATE_AVAILABLE"] = {
	  text = "VisualRaid\n\nUpdate available! Your version is out of date.",
	  button1 = "Okay",
	  OnAccept = function()
		  return false
	  end,
	  timeout = 10,
	  whileDead = 1,
	  hideOnEscape = 1
	}
end

function addon:OnEnable()
	-- ENABLED
	self:SpawnHeaders()
	
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "RAID_ROSTER_UPDATE");
	self:RegisterEvent("RAID_ROSTER_UPDATE", "RAID_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE");
end

function addon:OnDisable()
	self:print("VisualRaid Disabled. /vRA standby to turn back on");
end

function addon:fucktanks()
	db.tanks = {}
end

function addon:SlashHandler(input)
	input = self:Explode(" ", string.lower(input))
	if(input[1] == "lock") then
		self:UnlockHeaders()
	elseif(input[1] == "addtank") then
		if not input[2] then
			DEFAULT_CHAT_FRAME:AddMessage("VisualRaid: You did not specify a name.")
		return end
		local name = string.upper(string.sub(input[2], 1, 1))..string.lower(string.sub(input[2], 2))
		for _,tanks in ipairs(db.tanks) do
			if tanks == name then
				DEFAULT_CHAT_FRAME:AddMessage(("VisualRaid: %s is already in the tank group."):format(name))
			return end
		end
		tinsert(db.tanks, name)
		DEFAULT_CHAT_FRAME:AddMessage(("VisualRaid: Added %s to the tank group."):format(name))
	elseif(input[1] == "remtank") then
		if not input[2] then
			DEFAULT_CHAT_FRAME:AddMessage("VisualRaid: You did not specify a name.")
		return end
		local name = string.upper(string.sub(input[2], 1, 1))..string.lower(string.sub(input[2], 2))
		for k,tanks in ipairs(db.tanks) do
			if tanks == name then
				tremove(db.tanks, k)
				DEFAULT_CHAT_FRAME:AddMessage(("VisualRaid: %s was removed from the tank group."):format(name))
			return end
		end
		DEFAULT_CHAT_FRAME:AddMessage(("VisualRaid: Could not find %s in the tank group."):format(name))
	elseif(input[1] == "listtanks") then
		local str
		if #db.tanks<=0 then
			DEFAULT_CHAT_FRAME:AddMessage("VisualRaid: The tank group is currently empty")
		return end
		for _,v in ipairs(db.tanks) do
			str = (str) and ("%s, %s"):format(str,v) or v
		end
		DEFAULT_CHAT_FRAME:AddMessage(("VisualRaid: Players currently in tank group: %s"):format(str))
	elseif(input[1] == "active") then
		db.showActive = not db.showActive
		local s = (db.showActive) and "[enabled]" or "[disabled]"
		DEFAULT_CHAT_FRAME:AddMessage(("VisualRaid: Active spell bars have been %s"):format(s))
	elseif(input[1] == "test") then
		self:NewTimerBar("VisualRaid_Active", "testbar", "Test #1", 10)
		self:NewTimerBar("VisualRaid_Active", "testbar2", "Test #2", 12)
		self:NewTimerBar("VisualRaid_Active", "testbar3", "Test #3", 10)
		self:NewTimerBar("VisualRaid_Active", "testbar4", "Test #4", 20)
		self:NewTimerBar("VisualRaid_Active", "testbar5", "Test #5", 20)
		
		self:NewTimerBar("VisualRaid_CDs", "xtestbar", "Test #1", 10)
		self:NewTimerBar("VisualRaid_CDs", "xtestbar2", "Test #2", 12)
		self:NewTimerBar("VisualRaid_CDs", "xtestbar3", "Test #3", 10)
		self:NewTimerBar("VisualRaid_CDs", "xtestbar4", "Test #4", 20)
		self:NewTimerBar("VisualRaid_CDs", "xtestbar5", "Test #5", 20)
	elseif(input[1] == "help") then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00VisualRaid help:")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Lock|r - Toggles lock/unlock movable bars.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Addtank [name]|r - Adds [name] to the tank group.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Remtank [name]|r - Removes [name] from the tank group.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Listtanks|r - Lists all tanks in the tank group.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Active|r - Toggles display of active spells.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Test|r - Shows test bars.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC9900   Help|r - Shows help.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCC1100   This addon has no config. You can add and edit spell events in the Lua file.|r")
	else
		self.Options:ToggleConfig()
	end
end

-- ---------------------------
--	Cumbat log
-- ---------------------------

function addon:GetSort(playerName, spellid)
	local plI
	if not spellid then
		for k,v in ipairs(playerIndex) do
			if v == playerName then
				plI = k
				break
			end
		end
		if not plI then
			tinsert(playerIndex, playerName)
			plI = #playerIndex
		end
		plI = ("%02d"):format(i)
	else
		-- If spell id is supplied, use it.
		plI = ("%06d"):format(spellid)
	end
	
	local clI = sortclass[select(2,UnitClass(playerName))or"UNKNOWN"]
	
	return tonumber(("%d%d"):format(clI,plI))
end

local is42 = tonumber((select(4, GetBuildInfo()))) > 40100 -- XXX
function addon:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	if is42 then
		timestamp, event, _, sourceGUID, sourceName, srcFlags, srcRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellid, spellname, _, arg1, arg2 = ...
	else
		timestamp, event, _, sourceGUID, sourceName, srcFlags, destGUID, destName, destFlags, spellid, spellname, _, arg1, arg2 = ...
	end
	-- Nil
	if not spellid then return end
	if not UnitIsPlayer(sourceName) then return end
	
	local spell = SpellDB[spellid]
	
	if not spell then return end
	
	if spell.istank and #db.tanks>=1 then
		local tankhit
		for _,tank in ipairs(db.tanks) do
			if sourceName == tank then
				tankhit = true
			end
		end
		if not tankhit then return end
	end
	if not spell.event then
		if(event == "SPELL_AURA_APPLIED") then
			spell.dur = select(6,UnitAura(destName, spellname))
		elseif(event == "SPELL_AURA_REMOVED") then
			self:RemoveBar("active"..sourceName..spellid)
			return
		else
			return
		end
	else
		if spell.event ~= event then return end
	end
	
	----------------------
	-- Comm
	--if self.comm and sourceGUID == UnitGUID("player") then
	--	spell.cd = select(2,GetSpellCooldown(spellid))
	--	addon:debug(("Broadcasting Comm Message. Cooldown duration: %s"):format(tostring(spell.cd)))
	--	self.comm:SendComm("Cooldown", spellid, spell.cd) -- Spell id, duration
	--end
	
	local icon = select(3,GetSpellInfo(spellid))
	local classcolor = RAID_CLASS_COLORS[select(2,UnitClass(sourceName))]
	classcolor = {classcolor.r, classcolor.g, classcolor.b}
	
	local csort = self:GetSort(sourceName, spellid)
	
	if spell.activeBar and db.showActive then
		local id = "active"..sourceName..spellid
		--self:ScheduleTimer("ClearBarCache", spell.dur, id)
		self:NewTimerBar(spell.activeBar, id, ("%s"):format(destName or sourceName), spell.dur, icon, classcolor, csort)
	end
	if spell.cdBar and db.showCD then
		local id = "cd"..sourceName..spellid
		--self:ScheduleTimer("ClearBarCache", spell.cd, id)
		self:NewTimerBar(spell.cdBar, id, ("%s"):format(sourceName), spell.cd, icon, classcolor, csort)
	end
end

function addon:GetSpell(spellid)
	return SpellDB[spellid]
end

function addon:TryCooldown(spellid)
	--addon:debug("Player casted spell: "..spellid.." with cooldown info: "..select(1,GetSpellCooldown(spellid)).." "..select(2,GetSpellCooldown(spellid)).." "..select(3,GetSpellCooldown(spellid)))
	local duration = select(2,GetSpellCooldown(spellid))
	if duration == 0 then duration = nil end
	if duration then
		self.comm:SendComm("Cooldown", spellid, duration-0.2) -- Spell id, duration
	end
	return duration
end

function addon:UNIT_SPELLCAST_SUCCEEDED(_, unit, spellname, _, _, spellid)
	if unit ~= "player" then return end
	if not spellpool[spellid] then return end
	--if not self:TryCooldown(spellid) then self:ScheduleTimer("TryCooldown", 0.1, spellid) end
	self:ScheduleTimer("TryCooldown", 0.1, spellid)
end

-- ------------------------------
--	BAR stuff
-- ------------------------------

local unlocked
function addon:UnlockHeaders()
	for header in pairs(CyBarHeaders) do
		if not unlocked then
			header:Show()
		else
			db.barsettings[header.name].x = header.data.x
			db.barsettings[header.name].y = header.data.y
			db.barsettings[header.name].point = header.data.point
			db.barsettings[header.name].rpoint = header.data.rpoint
			header:Hide()
		end
	end
	unlocked = not unlocked
end

function addon:SpawnHeaders()
	local t = {}
	t.LabelFont = font
	t.LabelFontSize = fontsize
	t.LabelFontFlags = fontflags
	
	t.TimerFont = font
	t.TimerFontSize = fontsize
	t.TimerFontFlags = fontflags

	t.BarTexture = texture

	for k,v in pairs(db.barsettings) do
		if not v.isglobal then
			local header = CyBar:SpawnHeader(k, v.x, v.y, v.point, v.rpoint, t)
			CyBarHeaders[header] = true
		end
	end
end

function addon:RetrieveBar(id)
	local bar = CyBar:SearchBar(id)
	if bar then
		if not bar:IsRunning() then bar = nil end
	end
	return bar
end

function addon:NewTimerBar(header, id, label, timeleft, icon, colors, customsort)
	--addon:debug(("New Bar! header: %s id: %s label: %s timeleft: %d"):format(header,id,label,timeleft or 0))
	local bar = self:RetrieveBar(id)
	if bar then
		if bar:GetAttribute("Comm") then return nil end
		bar:Release()
	end
	CyBarData[id] = CyBar:NewBar(header, id, label, timeleft, icon, colors, customsort)
	return CyBarData[id]
end

function addon:RemoveBar(id)
	print("Removing bar: "..id)
	local bar = self:RetrieveBar(id)
	if bar then print("bar found!") end
	if bar then bar:Release() end
end

function addon:ClearBarCache(id)
	--CyBarData[id] = nil
end

function addon:Test()
	self:NewTimerBar("VisualRaid_Active", "testbar0", "Test #0", 0)
	self:NewTimerBar("VisualRaid_Active", "testbar1", "Test #1", 10)
	self:NewTimerBar("VisualRaid_Active", "testbar2", "Test #2", 12)
	self:NewTimerBar("VisualRaid_Active", "testbar3", "Test #3", 10)
	self:NewTimerBar("VisualRaid_Active", "testbar4", "Test #4", 20)
	self:NewTimerBar("VisualRaid_Active", "testbar5", "Test #5", 20)
	self:NewTimerBar("VisualRaid_Active", "testbar6", "Test #6", 30)
	
	self:NewTimerBar("VisualRaid_CDs", "xtestbar0", "Test #0", 0)
	self:NewTimerBar("VisualRaid_CDs", "xtestbar1", "Test #1", 10)
	self:NewTimerBar("VisualRaid_CDs", "xtestbar2", "Test #2", 12)
	self:NewTimerBar("VisualRaid_CDs", "xtestbar3", "Test #3", 10)
	self:NewTimerBar("VisualRaid_CDs", "xtestbar4", "Test #4", 20)
	self:NewTimerBar("VisualRaid_CDs", "xtestbar6", "Test #6", 30)
end

function addon:TestPause()
	for i = 1, 7 do
		local bar = addon:RetrieveBar("testbar"..i-1)
		if bar then bar:Pause() end
	end
	for i = 1, 7 do
		local bar = addon:RetrieveBar("xtestbar"..i-1)
		if bar then bar:Pause() end
	end
end

-- -----------------------
--  Comm methods
-- -----------------------

do
	local waiting
	
	function addon:BroadcastHelloFinish()
		waiting = nil
		local spells = {}
		for k, _ in pairs(SpellDB) do
			tinsert(spells, k)
		end
		self.comm:SendComm("Update", self.version, spells)
	end
	
	function addon:BroadcastHello()
		if waiting then return end
		waiting = true
		self:ScheduleTimer("BroadcastHelloFinish", 5)
	end
end

do
	local waiting
	
	function addon:RequestUpdateFinish()
		self.comm:SendComm("RequestUpdate")
	end
	
	function addon:RequestUpdate()
		if waiting then return end
		waiting = true
		self:ScheduleTimer("RequestUpdateFinish", 1)
	end
end

function addon:InjSpellpool(id)
	if spellpool[id] then return end
	spellpool[id] = true
end

function addon:UpdateMemberVersion(name, version)
	latestVersion = (latestVersion < version) and version or latestVersion
	if (latestVersion > addon.version) then
		StaticPopup_Show("VRA_UPDATE_AVAILABLE")
	end
	if not versionsInRaid[name] then
		versionsInRaid[name] = version
		return
	end
	if versionsInRaid[name] ~= version then
		versionsInRaid[name] = version
		return
	end
end

function addon:RAID_ROSTER_UPDATE(event)
	if(GetNumRaidMembers() >= 1 or GetNumPartyMembers() >= 1) then
		isInRaid = true
		self:UpdateRaidMembers()
		if event == "PLAYER_ENTERING_WORLD" then
			self:RequestUpdate();
		end
	else
		wipe(playerIndex)
	end
	return true
end

function addon:UpdateRaidMembers()
	local newMembers = {}
	for i = 1, MAX_RAID_MEMBERS do
		local name
		local online
		name, _, _, _, _, _, _, online, _, _, _ = GetRaidRosterInfo(i);
		if not playersInRaid[name] and online then
			playersInRaid[name] = true
			tinsert(newMembers, name)
		end
	end
	if #newMembers >= 1 then
		-- New members!
		self:BroadcastHello()
	end
end

function addon:Explode(d, str)
	local t, ll
	t={}
	ll=0
	if(#str == 1) then return str end
		while true do
			l=strfind(str, d, ll+1, true)
			if l~=nil then
				tinsert(t, strsub(str, ll, l-1))
				ll=l+1
			else
				tinsert(t, strsub(str,ll))
				break
			end
		end
	return t
end

function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end
