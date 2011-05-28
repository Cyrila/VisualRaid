--[[
##############################################
##- 
##-
##-	CyrilaRaid by Cyrila
##-
##-
##############################################
]]

local defaults = {
	profile = {
		barheader = {
			parent = "UIParent"
			anchorFrom = "UIParent"
			anchorTo = "UIParent"
			xPos = 0
			yPos = 0
		}
		bar = {
			-- Functionality
			updates = 0.01,
			
			padding = 1,
			spacing = 1,
			texture = "",
			borderTexture = "",
			font = ""
			groupBySpell = true, -- If false, group by time remaining
			groupBySpellCompactMode = false, -- If true, hide some stuff
			
			iconSize = 20,
			iconHAlign = "left",
			iconVAlign = "top",
			
			barWidth = 100,
			barHeight = 20,
			barDirection = "right",
			barFillDeplete = "fill",
			
			spellTextFontSize = 10,
			spellTextXOff = 0,
			spellTextYOff = 10,
			
			timerTextFontSize = 10,
			timerTextXOff = 0,
			timerTextYOff = 10,
		}
	}
}

local addon = cRA
local module = addon:NewModule("Prototype", "LibSink-2.0")
addon.Alerts = module