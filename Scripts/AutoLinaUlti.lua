require("libs.Utils")


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
			if me:FindItem("item_ultimate_scepter") then
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


function GetDistance3D(p,t)
	return math.sqrt(math.pow(p.x-t.x,2)+math.pow(p.y-t.y,2)+math.pow(p.z-t.z,2))
end

function Draw()
	local pos = Vector()
	ult = me:GetAbility(4)
	if  ult and ult.level ~= 0 then
		enemies = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY,alive=true})
		for i,v in ipairs(enemies) do
			if HasAgha() == true then
				damageult = damageAgha[ult.level]*(1-v.magicDmgResist)
			else
				damageult = damageNorm[ult.level]*(1-v.magicDmgResist)
			end
			if v:ScreenPosition(pos) then
				if v.health < damageult then
					drawManager:DrawText(pos.x-8,pos.y-50,0xFFFFFFFF,"KILL!")	
				else
					drawManager:DrawText(pos.x-8,pos.y-50,0xFFFFFFFF,math.floor(damageult).."")	
				end
			end
		end
	end
end
--script:RegisterEvent(EVENT_FRAME,Draw)
script:RegisterEvent(EVENT_TICK,Tick)