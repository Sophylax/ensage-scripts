--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0

			Hookshoting  v1.0

		Changelog:

			v1.0:
			 - Release   
]]


require("libs.SkillShot")
require("libs.TargetFind")
require("libs.HotkeyConfig")
require("libs.Utils")

ScriptConfig:SetName("Hookshoting")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("active","Use Hookshot",SGC_TYPE_ONKEYDOWN,false,false,string.byte("C"))
sleepTick = 0
target = nil
range = 0
gui = {
	target = drawManager:CreateText(163,35,0xFFFFFFFF,"Target"),
	distance = drawManager:CreateText(163,45,0xFFFFFFFF,"Distance"),
	search = drawManager:CreateText(163,35,0xFFFFFFFF,"Search"),
	error = drawManager:CreateText(163,35,0xFFFFFFFF,"Can not use Hookshot"),
}

gui.target.visible = false
gui.distance.visible = false
gui.search.visible = false
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

	local hookshot = me:FindSpell("rattletrap_hookshot")
	if hookshot then
		skillShot:Enable()
		ScriptConfig:SetVisible(true)
		if me:CanCast() and hookshot:CanBeCasted() then
			target = targetFind:GetLastMouseOver(hookshot.castRange)
			if target then
				SetGUIState(3)
				if gui.target.text ~= "Target: "..target.name then
					gui.target:SetText("Target: "..target.name)
				end
				if gui.distance.text ~= "Distance: "..GetDistance2D(target,me) then
					gui.distance:SetText("Distance: "..GetDistance2D(target,me))
				end

				if ScriptConfig.active then
					local xyz = skillShot:BlockableSkillShotXYZ(me,target,castTime[me.name],hookshot.castRange*2,125,true)
					if xyz and GetDistance2D(xyz,me) < hookshot.castRange then
						me:CastAbility(hookshot,(xyz - me.position) * 600 / GetDistance2D(xyz,me) + me.position)
						Sleep(250)
					end
				end
			else
				SetGUIState(2)
				if gui.search.text ~= "Search Range: "..hookshot.castRange then
					gui.search:SetText("Search Range: "..hookshot.castRange)
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