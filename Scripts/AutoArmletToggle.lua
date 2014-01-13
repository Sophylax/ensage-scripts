require("libs.Utils")
require("libs.HotkeyConfig")

--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0 

			Auto Armlet Toggle  v1.1

		This script uses armlet to gain hp when your hero is below a specified health.

		Changelog:
			v1.1:
			 - Tweaked script for the new armlet mechanics again
			 - Removed the configurable armlet delay

			v1.0c:
			 - Tweaked script for the new armlet mechanics
			 - Added key for manual armlet toggling

			v1.0b:
			 - Script now checks armlet cooldown even if it is activated by the user

			v1.0a:
			 - Script now disables itself if the user is under Ice Blast effect
			 - Lowered menu Width

			v1.0:
			 - Release

]]
ScriptConfig = ConfigGUI:New(script.name)
ScriptConfig:SetName("Auto-Armlet")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("active","Auto-Armlet",SGC_TYPE_TOGGLE,true,true,string.byte("L"))
ScriptConfig:AddParam("minhp","Min HP",SGC_TYPE_NUMCYCLE,true,400,nil,100,450,50)
ScriptConfig:AddParam("manual","Manual-Armlet",SGC_TYPE_ONKEYDOWN,false,false,string.byte("B"))

ARMLET_DELAY = 1000

extraToggle = 0

function Tick( tick )
	if not PlayingGame() then
		ScriptConfig:SetVisible(false)
		return
	end

	local armlet = me:FindItem("item_armlet")

	if not armlet then
		ScriptConfig:SetVisible(false)
		return
	end

	ScriptConfig:SetVisible(true)

	local armState = me:DoesHaveModifier("modifier_item_armlet_unholy_strength")

	if not me:DoesHaveModifier("modifier_ice_blast") and (ScriptConfig.active or ScriptConfig.manual) and armlet.cd == 0 and SleepCheck() then
		if me.health <= ScriptConfig.minhp + 0 or (ScriptConfig.manual and armState) then
			if armState then
				extraToggle = 2
			else
				extraToggle = 1
			end
			Sleep(ARMLET_DELAY)
		end
	end

	if extraToggle > 0 then
		if armlet.state == STATE_READY and armlet.cd == 0 then
			if me:SafeCastItem("item_armlet") then
				extraToggle = extraToggle - 1
			end
		end
	end
end

script:RegisterEvent(EVENT_TICK,Tick)