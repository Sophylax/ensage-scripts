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

			Auto Armlet Toggle  v1.0b

		This script uses armlet to gain hp when your hero is below a specified health.

		Changelog:
			v1.0b:
			 - Script now checks armlet cooldown even if it is activated by the user

			v1.0a:
			 - Script now disables itself if the user is under Ice Blast effect
			 - Lowered menu Width

			v1.0:
			 - Release

]]

ScriptConfig:SetName("Auto-Armlet")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("active","Auto-Armlet",SGC_TYPE_TOGGLE,true,true,string.byte("L"))
ScriptConfig:AddParam("minhp","Min HP",SGC_TYPE_NUMCYCLE,true,400,nil,100,450,50)

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

	if not me:DoesHaveModifier("modifier_ice_blast") and ScriptConfig.active and armlet.cd == 0 and SleepCheck() then
		if me.health <= ScriptConfig.minhp + 0 then
			if armState then
				me:SafeCastItem("item_armlet")
			end
			me:SafeCastItem("item_armlet")
			Sleep(1000)
		end
	end
end

script:RegisterEvent(EVENT_TICK,Tick)