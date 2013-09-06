--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0

			Powershoting  v1.0

		Includes Auto-Powershot cancel

		Changelog:

			v1.0:
			 - Release   
]]


require("libs.SkillShot")
require("libs.TargetFind")
require("libs.HotkeyConfig")
require("libs.Utils")

ScriptConfig:SetName("Powershoting")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("active","Use Powershot",SGC_TYPE_ONKEYDOWN,false,false,string.byte("C"))
sleepTick = 0
target = nil
range = 0
gui = {
	target = drawManager:CreateText(33,35,0xFFFFFFFF,"Target"),
	distance = drawManager:CreateText(33,45,0xFFFFFFFF,"Distance"),
	search = drawManager:CreateText(33,35,0xFFFFFFFF,"Search"),
	error = drawManager:CreateText(33,35,0xFFFFFFFF,"Can not use Powershot"),
}

gui.target.visible = false
gui.distance.visible = false
gui.search.visible = false
gui.error.visible = false

guiState = 0

skillShot:Disable()

castTime = {}
castTime["Windrunner"] = 300
castTime["Rubick"] = 100

function Tick( tick )

	if not PlayingGame() then
		return
	end

	local powershot = me:FindSpell("windrunner_powershot")

	if powershot then
		skillShot:Enable()
		ScriptConfig:SetVisible(true)
		if powershot.channelTime > 0 and GetTotalGameTime() > powershot.channelTime + .49 then
			me:Move(me.position)
			return
		end
		if me:CanCast() and powershot:CanBeCasted() then
			target = targetFind:GetLastMouseOver(powershot.castRange)
			if target then
				SetGUIState(3)
				if gui.target.text ~= "Target: "..target.name then
					gui.target:SetText("Target: "..target.name)
				end
				if gui.distance.text ~= "Distance: "..GetDistance2D(target,me) then
					gui.distance:SetText("Distance: "..GetDistance2D(target,me))
				end

				if ScriptConfig.active then
					local xyz = skillShot:SkillShotXYZ(me,target,castTime[me.name]+500,3000)
					if xyz and GetDistance2D(xyz,me) < powershot.castRange then
						me:CastAbility(powershot,(xyz - me.position) * 600 / GetDistance2D(xyz,me) + me.position)
						Sleep(250)
					end
				end
			else
				SetGUIState(2)
				if gui.search.text ~= "Search Range: "..powershot.castRange then
					gui.search:SetText("Search Range: "..powershot.castRange)
				end
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
			gui.search.visible = false
			gui.error.visible = false
		elseif state == 1 then
			gui.target.visible = false
			gui.distance.visible = false
			gui.search.visible = false
			gui.error.visible = true
		elseif state == 2 then
			gui.target.visible = false
			gui.distance.visible = false
			gui.search.visible = true
			gui.error.visible = false
		elseif state == 3 then
			gui.target.visible = true
			gui.distance.visible = true
			gui.search.visible = false
			gui.error.visible = false
		end
		guiState = state
	end
end

script:RegisterEvent(EVENT_TICK,Tick)