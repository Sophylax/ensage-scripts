require("libs.Utils")
require("libs.TargetFind")
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

			Storm Spirit Combo  v1.1a

		If target is nearby (vortex range):
			Vortex - Orchid - Veil - Shiva - Dagon - Attack - Remnant - Attack - Ball Lightning out - Sheepstick - Attack

		If not:
			Ball Lightning In - Orchid - Veil - Attack - Vortex - Shiva - Dagon - Attack - Remnant - Attack - Ball Lightning - Sheepstick - Attack

		Changelog:
			v1.1a:
			 - Minor speed increase

			v1.1
			 - Script will not repeat the combo if combo key isn't released.
			 - Fixed the bug when user tries to combo while mouse is on HUD which causes storm to fly to mid.
			 - Fixed the bug when vortex is used too close to target which causes storm to fly to mid.

			v1.0:
			 - Release

]]

ScriptConfig:SetName("Storm Combo")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("combo","Combo",SGC_TYPE_ONKEYDOWN,false,false,string.byte("Z"))

stage = 0
itemSleep = 75
castSleep = 300

function Tick(tick)
	if not PlayingGame() then
		ScriptConfig:SetVisible(false)
		return
	end

	if me.name ~= "StormSpirit" then
		ScriptConfig:SetVisible(false)
		script:Disable()
		return
	end

	ScriptConfig:SetVisible(true)

	local remnant = me:FindSpell("storm_spirit_static_remnant")
	local vortex = me:FindSpell("storm_spirit_electric_vortex")
	local rofl = me:FindSpell("storm_spirit_ball_lightning")

	local roflSpeed = 625 * (rofl.level + 1)

	if ScriptConfig.combo and SleepCheck() then
		local target = nil
		if stage <= 0 then
			target = targetFind:GetLastMouseOver(600)
		else
			target = targetFind:GetLastMouseOver(vortex.castRange)
		end
	
		if target then
			if stage == -3 then
				local orchid = me:FindItem("item_orchid")
				if orchid then
					if me:SafeCastAbility(orchid,target) then
						stage = stage + 1
						Sleep(itemSleep)
						return
					else
						stage = stage + 1
					end
				else
					stage = stage + 1
				end
			elseif stage == -2 then
				local veil = me:FindItem("item_veil_of_discord")
				if veil then
					if me:SafeCastAbility(veil,target.position) then
						stage = stage + 1
						Sleep(itemSleep)
						return
					else
						stage = stage + 1
					end
				else
					stage = stage + 1
				end
			elseif stage == -1 then
				me:Attack(target)
				stage = stage + 1
				Sleep(1700/(me.attackSpeed/100))
				return
			elseif stage == 0 then
				if me:SafeCastAbility(vortex,target) then
					stage = stage + 1
					local distanceDelay = 1000*(me:GetDistance2D(target)/me.moveSpeed)
					if distanceDelay > 0 then
						Sleep(castSleep + 158 + distanceDelay)
					else
						Sleep(castSleep + 158)
					end
					return
				end
			elseif stage == 1 then
				local orchid = me:FindItem("item_orchid")
				if orchid then
					if me:SafeCastAbility(orchid,target) then
						stage = stage + 1
						Sleep(itemSleep)
						return
					else
						stage = stage + 1
					end
				else
					stage = stage + 1
				end
			elseif stage == 2 then
				local veil = me:FindItem("item_veil_of_discord")
				if veil then
					if me:SafeCastAbility(veil,target.position) then
						stage = stage + 1
						Sleep(itemSleep)
						return
					else
						stage = stage + 1
					end
				else
					stage = stage + 1
				end
			elseif stage == 3 then
				local shiva = me:FindItem("item_shivas_guard")
				if shiva then
					if me:SafeCastAbility(shiva) then
						stage = stage + 1
						Sleep(itemSleep)
						return
					else
						stage = stage + 1
					end
				else
					stage = stage + 1
				end
			elseif stage == 4 then
				local dagon = me:FindItem("item_dagon_5")
				dagon = dagon or me:FindItem("item_dagon_4")
				dagon = dagon or me:FindItem("item_dagon_3")
				dagon = dagon or me:FindItem("item_dagon_2")
				dagon = dagon or me:FindItem("item_dagon")
				if dagon then
					if me:SafeCastAbility(dagon,target) then
						stage = stage + 1
						Sleep(itemSleep)
						return
					else
						stage = stage + 1
					end
				else
					stage = stage + 1
				end
			elseif stage == 5 then
				me:Attack(target)
				stage = stage + 1
				Sleep(1700/(me.attackSpeed/100))
				return
			elseif stage == 6 then
				if me:SafeCastAbility(remnant) then
					stage = stage + 1
					return
				end
			elseif stage == 7 then
				me:Attack(target)
				stage = stage + 1
				Sleep(1700/(me.attackSpeed/100))
				return
			elseif stage == 8 then
				local dest = target.position - me.position
				if me:GetDistance2D(target) > 0 then
					dest = dest / me:GetDistance2D(target)
				else
					dest = Vector(math.cos(me.rotR),math.sin(me.rotR),0)
				end
				dest = dest * (me.attackRange)
				dest = target.position + dest
				print(dest.x,dest.y)
				if me:SafeCastAbility(rofl,dest) then
					stage = stage + 1
					Sleep(300)
					return
				end
			elseif stage == 9 then
				local sheepstick = me:FindItem("item_sheepstick")
				if sheepstick then
					if not target:DoesHaveModifier("modifier_storm_spirit_electric_vortex_pull") then
						if me:SafeCastAbility(sheepstick,target) then
							stage = stage + 1
							Sleep(itemSleep)
							return
						else
							stage = stage + 1
						end
					end
				else
					stage = stage + 1
				end
			elseif stage == 10 then
				QueueNextAction()
				me:Attack(target)
				Sleep(1000)
				return
			end

		elseif stage == 0 and GetDistance2D(engineClient.mousePosition,Vector(0,0,0)) > 0 then
			if me:SafeCastAbility(rofl,engineClient.mousePosition) then
				stage = -3
			end
		end
	elseif SleepCheck() then
		stage = 0
	end
end

script:RegisterEvent(EVENT_TICK,Tick)