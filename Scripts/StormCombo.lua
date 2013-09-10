require("libs.Utils")
require("libs.TargetFind")

--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0 

			Storm Spirit Combo  v1.0

		If target is nearby (vortex range):
			Vortex - Orchid - Veil - Shiva - Dagon - Attack - Remnant - Attack - Ball Lightning out - Sheepstick - Attack

		If not:
			Ball Lightning In - Orchid - Veil - Attack - Vortex - Shiva - Dagon - Attack - Remnant - Attack - Ball Lightning - Sheepstick - Attack

		Changelog:

			v1.0:
			 - Release

]]

stage = 0
itemSleep = 75
castSleep = 300

function Tick(tick)
	if not PlayingGame() then
		return
	end

	if me.name ~= "StormSpirit" then
		script:Disable()
		return
	end

	local remnant = me:FindSpell("storm_spirit_static_remnant")
	local vortex = me:FindSpell("storm_spirit_electric_vortex")
	local rofl = me:FindSpell("storm_spirit_ball_lightning")

	local roflSpeed = 625 * (rofl.level + 1)

	if IsKeyDown(string.byte("Z")) and SleepCheck() then
		target = targetFind:GetLastMouseOver(vortex.castRange)
	
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
					Sleep(castSleep + 158)
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
				dest = dest / me:GetDistance2D(target)
				dest = dest * (me.attackRange)
				dest = target.position + dest
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
				stage = 0
				Sleep(1000)
				return
			end

		elseif stage == 0 then
			if me:SafeCastAbility(rofl,engineClient.mousePosition) then
				stage = -3
			end
		end
	elseif SleepCheck() then
		stage = 0
	end
end

script:RegisterEvent(EVENT_TICK,Tick)