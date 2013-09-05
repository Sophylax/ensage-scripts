require("libs.Utils")

--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0 

			Auto Lina Ulti  v1.0a

		This script will try to kill anyone who is anyone that can die from a laguna blade. 

		Changelog:
			v1.0a:
			 - Improved Scepter Detection

			v1.0:
			 - Release

]]

damage = {450,675,950}
damage[0] = 0
damageAgha = {600,925,1250}
damageAgha[0] = 0
rangeAgha = 900
range = 600

-- [ CODENZ ] --
function Tick( tick )

	if not PlayingGame() or not SleepCheck() then
		return
	end
	
	local lagunaBlade = me:FindSpell("lina_laguna_blade")

	local enemies = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY,alive=true,visible=true})
	for i,v in ipairs(enemies) do
		if not v.illusion and v:CanDie() then
			if lagunaBlade.castRange == rangeAgha then
				if me:GetDistance2D(v) < aghaRange and v.health < v:DamageTaken(damageAgha[lagunaBlade.level],DAMAGE_MAGC,me) then
					me:SafeCastSpell("lina_laguna_blade",v)
					Sleep(1000)
					return
				end
			else
				if me:GetDistance2D(v) < range and v.health < v:DamageTaken(damage[lagunaBlade.level],DAMAGE_MAGC,me) then
					me:SafeCastSpell("lina_laguna_blade",v)
					Sleep(1000)
					return
				end
			end
		end
	end
end
script:RegisterEvent(EVENT_TICK,Tick)