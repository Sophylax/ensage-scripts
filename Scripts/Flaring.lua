--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0    
]]


require("libs.SkillShot")
require("libs.TargetFind")
require("libs.HotkeyConfig")
require("libs.Utils")

ScriptConfig:SetName("Flaring")
ScriptConfig:AddParam("active","Use Flare",SGC_TYPE_ONKEYDOWN,false,false,string.byte(" "))
ScriptConfig:SetVisible(false)
target = nil
range = 0
gui = {
	target = drawManager:CreateText(33,35,0xFFFFFFFF,"Target"),
	distance = drawManager:CreateText(33,54,0xFFFFFFFF,"Distance"),
	error = drawManager:CreateText(33,35,0xFFFFFFFF,"Can not use Rocket Flare"),
}

gui.target.visible = false
gui.distance.visible = false
gui.error.visible = false

guiState = 0

skillShot:Disable()

castTime = {}
castTime["Rattletrap"] = 300
castTime["Rubick"] = 100

function Tick( tick )

	if not PlayingGame() then
		return
	end

	local flare = me:FindSpell("rattletrap_rocket_flare")
	if flare then
		skillShot:Enable()
		ScriptConfig:SetVisible(true)
		if me:CanCast() and flare:CanBeCasted() then
			target = targetFind:GetLowestEHP(99999,"magic",(1+flare.level)*40)
			if target then
				SetGUIState(2)
				if gui.target.text ~= "Target: "..target.name then
					gui.target:SetText("Target: "..target.name)
				end
				if gui.distance.text ~= "Distance: "..GetDistance2D(target,me) then
					gui.distance:SetText("Distance: "..GetDistance2D(target,me))
				end

				if ScriptConfig.active then
					local xyz = skillShot:BlockableSkillShotXYZ(me,target,castTime[me.name],1600,125,true)
					if xyz then
						me:CastAbility(flare,xyz)
						Sleep(250)
					end
				end
			else
				SetGUIState(0)
			end
		else
			SetGUIState(1)
		end
	else
		skillShot:Disable()
		SetGUIState(0)
		ScriptConfig:SetVisible(false)
	end
end

function SetGUIState(state)
	if state ~= guiState then
		if state == 0 then
			gui.target.visible = false
			gui.distance.visible = false
			gui.error.visible = false
		elseif state == 1 then
			gui.target.visible = false
			gui.distance.visible = false
			gui.error.visible = true
		elseif state == 2 then
			gui.target.visible = true
			gui.distance.visible = true
			gui.error.visible = false
		end
		guiState = state0xFFFFFFFF
	end
end

script:RegisterEvent(EVENT_TICK,Tick)