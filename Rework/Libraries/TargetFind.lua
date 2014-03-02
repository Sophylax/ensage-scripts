require("libs.Utils")

--[[
		Save as TargetFind.lua into Ensage\Scripts\libs.

		Functions:
			targetFind:GetLastMouseOver(range): Returns the latest mouse-overed hero if it is in range, if not it will return closest hero to the mouse position.
			targetFind:GetClosestToMouse(range): Returns closest hero to the mouse position that is in range.
			targetFind:GetLowestEHP(range,type): Returns the hero by looking at their hp and resistances.
				Type: Damage type. Possible inputs : "magic", "phys" and nothing
					NoType: Compares purely by current HP
					"phys": Comparation includes armor calculation and ignores ethereal heroes.
					"magic": Comparation includes magic resistance calculation and ignores magic immune heroes.
				Tresh: EHP Threshold. If entered function will only return a hero if it's EHP is lower than given amount
				
		Examples:
			targetFind:GetLastMouseOver(1000)
			targetFind:GetClosestToMouse(500)
			targetFind:GetLowestEHP(600,"phys")
			targetFind:GetLowestEHP(850,"magic")
			targetFind:GetLowestEHP(99999,"magic",300)
			targetFind:GetLowestEHP(1300)
--]]

targetFind = {}
targetFind.handles = {}
targetFind.mTarget = nil

function targetFind:TargetTick(tick)
	local heroes = entityList:FindEntities({type = LuaEntity.TYPE_HERO})
	for i,v in ipairs(heroes) do
		if not targetFind.handles[v.handle] then
			targetFind.handles[v.handle] = true
		end
	end
	--local mOver = entityList:GetMouseOver()
	if mOver and mOver.visible and mOver.alive and mOver.team == TEAM_ENEMY and not mOver.illusion and targetFind.handles[mOver.handle] then
		targetFind.mTarget = mOver
	end
end

function targetFind:GetLastMouseOver(range)
	if targetFind.mTarget == nil or entityList:GetMyHero():GetDistance2D(targetFind.mTarget) > range or not targetFind.mTarget.alive or not targetFind.mTarget.visible then
		targetFind.mTarget = nil
	end
	if targetFind.mTarget then
		return targetFind.mTarget
	else
		local _enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO, team = TEAM_ENEMY, distance = {entityList:GetMyHero(),range}})
		local real = {}
		for i,v in ipairs(_enemies) do
			if not v.illusion and v.visible and v.alive then
				table.insert(real,v)
			end
		end
		if #real == 1 then
			return real[1]
		else
			return targetFind:GetClosestToMouse(range)
		end
	end
end

function targetFind:GetClosestToMouse(range)
	local lowenemy = nil
	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO, distance = {entityList:GetMyHero(),range}})
	for i,v in ipairs(enemies) do
		if v.GetDistance2D ~= nil and v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 then
			local distance = v:GetDistance2D(client.mousePosition)
			local distance2 = v:GetDistance2D(entityList:GetMyHero())
			if  v.alive and v.visible and not v.illusion and distance2 <= range then 
				if lowenemy == nil then
					lowenemy = v
				elseif distance < lowenemy:GetDistance2D(client.mousePosition) then
					lowenemy = v
				end
			end
		end
	end
	return lowenemy
end

function targetFind:GetLowestEHP(range,dmg_type,tresh)
	local lowenemy = nil
	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO, team = TEAM_ENEMY, distance = {entityList:GetMyHero(),range}})
	for i,v in ipairs(enemies) do
		local immunity
		if dmg_type == "magic" then
			if lowenemy then l_multipler = 1/(1-lowenemy.magicDmgResist) end
			v_multipler = 1/(1-v.magicDmgResist)
			immunity = v.magicImmune
		elseif dmg_type == "phys" then
			if lowenemy then l_multipler = 1/(1-lowenemy.dmgResist)  end
			v_multipler = 1/(1-v.dmgResist) 
			immunity = v.ghost
		else
			l_multipler = 1
			v_multipler = 1
			immunity = false
		end
		local distance = entityList:GetMyHero():GetDistance2D(v)
		if distance <= range and v.alive and not v.illusion and v.visible and not immunity and (not tresh or (v.health*v_multipler) < tresh) then 
			if lowenemy == nil then
				lowenemy = v
			elseif (lowenemy.health*l_multipler) > (v.health*v_multipler) then
				lowenemy = v
			end
		end
	end
	return lowenemy
end

scriptEngine:RegisterLibEvent(EVENT_TICK,targetFind.TargetTick)