local addon = vRA
assert(addon, "VisualRaidOptions requires VisualRaid.")

local module = addon:NewModule("Options")
addon.Options = module

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

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


local dbp

local unlocked

local options

function module:RegisterOptions()
	options = {
		name = "VisualRaid",
		handler = addon,
		type = "group",
		args = {
			inline_enabled = {
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Enable or disable addon.",
				descStyle = "inline",
				set = function(i,v)
					if addon:IsEnabled() then
						addon:Disable()
						dbp.disabled = true
					else
						addon:Enable()
						dbp.disabled = false
					end
				end,
				get = function() return addon:IsEnabled() end,
			},
			inline_lock = {
				order = 2,
				type = "toggle",
				name = "Locked",
				desc = "Lock or unlock bars.",
				descStyle = "inline",
				set = function(info,value) addon:UnlockHeaders(); unlocked = not unlocked end,
				get = function(info) return not unlocked end,
			},
			inline_test = {
				order = 3,
				type = "execute",
				name = "Test Bars",
				desc = "Populate test bars.",
				width = "half",
				func = function() addon:Test() end,
			},
			inline_pause = {
				order = 4,
				type = "execute",
				name = "Pause Bars",
				desc = "Pause test bars.",
				width = "half",
				func = function() addon:TestPause() end,
			},
			inline_spellheader = {
				name = ("Version: %d"):format(addon.version),
				type = "header",
				order = 10,
			},
			
		},
	}
	
	options.args.general = {
		name = "General",
		type = "group",
		order = 1,
		args = {
			
		},
	}
	
	options.args.spells = {
		name = "Raid Cooldowns",
		type = "group",
		order = 2,
		args = {
			
		},
	}
	
	--[[
	options.args.barconfig = {
		name = "Bar Configuration",
		type = "group",
		order = 3,
		args = LibStub("LibCyrilaBars-1.0").plugin.options:GenerateOptionsTable("VisualRaid", "AceConfig-3.0"),
	},
	]]
end



function module:ToggleConfig() ACD[ACD.OpenFrames.VisualRaid and "Close" or "Open"](ACD,"VisualRaid") end

function module:OnInitialize()
	dbp = vRA.db.profile
	self:RegisterOptions()
	
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(vRA.db)
	options.args.profile.order = 500
	
	AC:RegisterOptionsTable("VisualRaid", options)
	ACD:SetDefaultSize("VisualRaid", 700, 480)
end