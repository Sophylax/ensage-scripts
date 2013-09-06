--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0

			Hooking  v1.0b

		Changelog:
			v1.0b:
			 - Slight performance tweaks

			v1.0a:
			 - Lowered menu Width

			v1.0:
			 - Release   
]]


require("libs.SkillShot")
require("libs.TargetFind")
require("libs.HotkeyConfig")
require("libs.Utils")

ScriptConfig:SetName("Hooking")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("active","Use Hook",SGC_TYPE_ONKEYDOWN,false,false,string.byte("C"))
sleepTick = 0
target = nil
range = 0
gui = {
	target = drawManager:CreateText(33,35,0xFFFFFFFF,"Target"),
	distance = drawManager:CreateText(33,45,0xFFFFFFFF,"Distance"),
	search = drawManager:CreateText(33,35,0xFFFFFFFF,"Search"),
	error = drawManager:CreateText(33,35,0xFFFFFFFF,"Can not use Meat Hook"),
}

gui.target.visible = false
gui.distance.visible = false
gui.search.visible = false
gui.error.visible = false

guiState = 0

skillShot:Disable()

castTime = {}
castTime["Pudge"] = 300
castTime["Rubick"] = 100

function Tick( tick )

	if not PlayingGame() then
		return
	end

	local hook = me:FindSpell("pudge_meat_hook")
	if hook then
		skillShot:Enable()
		ScriptConfig:SetVisible(true)
		if me:CanCast() and hook:CanBeCasted() then
			target = targetFind:GetLastMouseOver(hook.castRange + 100)
			if target then
				SetGUIState(3)
				if gui.target.text ~= "Target: "..target.name then
					gui.target:SetText("Target: "..target.name)
				end
				if gui.distance.text ~= "Distance: "..GetDistance2D(target,me) then
					gui.distance:SetText("Distance: "..GetDistance2D(target,me))
				end

				if ScriptConfig.active then
					local xyz = skillShot:BlockableSkillShotXYZ(me,target,castTime[me.name],1600,125,true)
					if xyz and GetDistance2D(xyz,me) < hook.castRange + 125 then
						me:CastAbility(hook,(xyz - me.position) * 600 / GetDistance2D(xyz,me) + me.position)
					end
				end
			else
				SetGUIState(2)
				if gui.search.text ~= "Search Range: "..hook.castRange + 100 then
					gui.search:SetText("Search Range: "..hook.castRange + 100)
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