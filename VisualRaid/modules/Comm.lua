-- ----------------------------
--  VisualRaid Comm module
-- ----------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon("visualRaidAssist")
local module = addon:NewModule("Comm", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
addon.comm = module

function module:OnInitialize()
	self:RegisterComm("oRA3", "OnExtCommReceived")
	self:RegisterComm("ISC_RC", "OnExtCommReceived")
	self:RegisterComm("vRA")
	
	self:RegisterMessage("vRA_Update", "UpdateCommHandler")
	self:RegisterMessage("vRA_Cooldown", "CooldownCommHandler")
	self:RegisterMessage("vRA_RequestUpdate", "SendUpdateDelayed")
end

function module:SendComm(...)
	-- Only send to raid
	if (GetNumPartyMembers() <= 0 and GetNumRaidMembers() <= 0) or UnitInBattleground("player") then return nil end
	self:SendCommMessage("vRA", self:Serialize(...), "RAID")
end

local function commDispatch(sender, isNative, continue, commType, ...)
	-- isNative boolean equals vRA native comms. In other words, comms that weren't sent by vRA wont be flagged with isNative.
	addon:debug(("Dispatching comm. Sender: %s, Native: %s, Comm type: %s, Message: %s"):format(sender, tostring(isNative), tostring(commType), (...) and tostring(...) or "nil"))
	if type(commType)=="string" and continue then
		module:SendMessage(("vRA_%s"):format(commType), sender, isNative, ...)
	end
end

function module:OnCommReceived(prefix, message, distribution, sender)
	-- vRA comm
	if (prefix ~= "vRA") then return nil end
	if (distribution ~= "RAID" and distribution ~= "PARTY") then return end
	
	commDispatch(sender, true, self:Deserialize(message))
end

local ISC_RC_cdtbl = {
	[1] = 20484, -- Rebirth
	[2] = 95750, -- Soulstone Resurrection
	[3] = 20608, -- Reincarnation
	[4] = 32182, -- Heroism
	[5] = 80353, -- Time Warp
	[6] = 740, -- Tranquility
	[7] = 64843, -- Divine Hymn
	[8] = 61999, -- Raise Ally
}

function module:OnExtCommReceived(prefix, message, distribution, sender)
	if (distribution ~= "RAID" and distribution ~= "PARTY") then return end
	
	if (prefix == "oRA3") then
		-- oRA3 uses AceSerializer to send Lua code as strings, therefore we have to deserialize before we can use it.
		--addon:debug(("Received oRA3 Cooldown comm. Data: %s"):format(message))
		commDispatch(sender, nil, self:Deserialize(message))
	end
	
	if (prefix == "ISC_RC") then
		-- ISCore sends var strings split by commas.
		-- Raid cooldowns are transmitted with their local table index, which means we have to guess at the spell id.
		-- format: string.format("%d,%d,%d", raidCooldowns[name]["Index"], timeleft, duration)
		addon:debug(("Received ISCore Raid Cooldown comm. Data: \"%s\""):format(message))
		local spellid, timeleft, duration = unpack(addon:Explode(",", message))
		spellid = ISC_RC_cdtbl[spellid]
		commDispatch(sender, nil, "Cooldown", spellid, timeleft)
	end
end


-- -----------------------
--  Cooldown Commtype
-- -----------------------

function module:CooldownCommHandler(event, sender, isNative, spellid, timeleft)
	if (event ~= "vRA_Cooldown") then return end
	
	addon:debug(("Handling Cooldown Comm. Event: %s, sender: %s, native: %s, spellid: %s, timeleft: %s."):format(event,sender,tostring(isNative),tostring(spellid),tostring(timeleft)))
	
	-- We don't wanna change anything if you transmitted the cooldown in the first place. -- ACTUALLLY, we do! Since we can't get cooldown info the same second as we cast.
	-- This adds some overhead, but nothing too bad.
	--if sender == UnitName("player") then return end
	if not addon:GetSpell(spellid) then return end
	
	local barid = "cd"..sender..spellid
	local bar = addon:RetrieveBar(barid)
	if bar then
		-- Bar is already created, let's update the cooldown
		if bar:GetAttribute("vRA_Comm") then return end
		bar:SetAttribute("vRA_Comm", isNative)
		bar:SetAttribute("Comm", true)
		bar:SetTimeleft(timeleft)
	else
		-- Create bar
		local spellname, _, spellicon, _, _, _, _, _, _ = GetSpellInfo(spellid)
		local classcolor = RAID_CLASS_COLORS[select(2,UnitClass(sender))]
		classcolor = {classcolor.r, classcolor.g, classcolor.b}
		
		local csort = addon:GetSort(sender, spellid)
		
		bar = addon:NewTimerBar("VisualRaid_CDs", barid, ("%s"):format(sender), timeleft, spellicon, classcolor, csort)
		bar:SetAttribute("vRA_Comm", isNative)
	end
end

function module:UpdateCommHandler(event, sender, isNative, version, spells)
	if (event ~= "vRA_Update") then return end
	
	addon:debug("Handling Update Comm.")
	
	addon:UpdateMemberVersion(sender, version)
	for _,v in ipairs(spells) do
		addon:InjSpellpool(v)
	end
end


function module:SendUpdateDelayed()
	addon:BroadcastHello()
end
