
require("libs.Utils")
require("libs.VectorOp")

--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0    

			SkillShot Library v1.2

		Save as SkillShot.lua into Ensage\Scripts\libs.

		Functions:
			SkillShot.InFront(target,distance): Returns the Vector of the position in front of the target for specified distance
			SkillShot.PredictedXYZ(target,delay): Returns the Vector of the target's predicted location after specified milisecond
			SkillShot.SkillShotXYZ(source,target,delay,speed): Returns the Vector of the target's predicted location for a  Souce is the caster,speed is the speed of the projectile and delay is the casting time
			SkillShot.BlockableSkillShotXYZ(source,target,delay,speed,aoe,team): Same as SkillShotXYZ, but this time it returns nil if skillshot can be blocked by a unit. AoE is aoe of the spell. Team is true if allies can block, false otherwise.


		Changelog:
			v1.2:
			 - Tweaked for new ensage patch
			 - Removed Enable and Disable functions

			v1.1a:
			 - Removed unnecessary tracking of non-npcs

			v1.1:
			 - Added Option to track only heroes

			v1.0:
			 - Release

--]]

SkillShot = {}

SkillShot.liteMode = false
SkillShot.onlyHeroes = false  	

SkillShot.trackTable = {}
SkillShot.lastTrackTick = 0
SkillShot.currentTick = 0

function SkillShot.__TrackTick(tick)
	SkillShot.currentTick = tick
	if not SkillShot.liteMode or tick > SkillShot.lastTrackTick + 50 then
		SkillShot.__Track()
		SkillShot.lastTrackTick = tick 	
	end
end

i = 1
function SkillShot.__Track()
	local all = entityList:FindEntities({type = LuaEntity.TYPE_HERO})
	if not SkillShot.onlyHeroes then
		local _addition = entityList:FindEntities({type = LuaEntity.TYPE_NPC})
		for i,v in ipairs(_addition) do
			table.insert(all,v)
		end
	end
	for i,v in ipairs(all) do
		if SkillShot.trackTable[v.handle] == nil and v.alive and v.visible then
			SkillShot.trackTable[v.handle] = {}
		elseif SkillShot.trackTable[v.handle] ~= nil and (not v.alive or not v.visible) then
			SkillShot.trackTable[v.handle] = nil
		elseif SkillShot.trackTable[v.handle] and (not SkillShot.trackTable[v.handle].last or SkillShot.currentTick > SkillShot.trackTable[v.handle].last.tick) then
			if SkillShot.trackTable[v.handle].last ~= nil then
				SkillShot.trackTable[v.handle].speed = (v.position - SkillShot.trackTable[v.handle].last.position)/(SkillShot.currentTick - SkillShot.trackTable[v.handle].last.tick)
			end
			SkillShot.trackTable[v.handle].last = {position = v.position:Clone(), tick = SkillShot.currentTick}
		end
	end
end

function SkillShot.InFront(t,distance)
	local alpha = t.rotR
	if alpha then
		local v = t.position + VectorOp.UnitVectorFromXYAngle(alpha) * distance
		return Vector(v.x,v.y,0)
	end
end

function SkillShot.PredictedXYZ(t,delay)
	if t.CanMove and not t:CanMove() then
		return Vector(t.x,t.y,0)
	elseif SkillShot.trackTable[t.handle] and SkillShot.trackTable[t.handle].speed then
		local v = t.position + SkillShot.trackTable[t.handle].speed * delay
		return Vector(v.x,v.y,0)
	end
end

function SkillShot.SkillShotXYZ(source,t,delay,speed)
	local cycle = 0
	if not source.x then source = source.position end
	if not t:CanMove() then
		return Vector(t.x,t.y,0)
	elseif source and t and delay and speed then
		local delay1 = delay + (GetDistance2D(source,t)*1000/speed)
		local stage1 = SkillShot.PredictedXYZ(t,delay1)
		cycle = cycle + 1		if stage1 then
			local distance = math.sqrt(math.pow(source.x-stage1.x,2)+math.pow(source.y-stage1.y,2))
			local delay2 = delay + (distance*1000/speed)
			local stage2 = SkillShot.PredictedXYZ(t,delay2)
			cycle = cycle + 1
			local i = 1
			print(math.floor(distance), math.floor(math.sqrt(math.pow(source.x-stage1.x,2)+math.pow(source.y-stage1.y,2))))
			while (i < 2 and SkillShot.liteMode) or (not SkillShot.liteMode and math.floor(distance) ~= math.floor(math.sqrt(math.pow(source.x-stage1.x,2)+math.pow(source.y-stage1.y,2)))) do
				stage1 = stage2
				distance = math.sqrt(math.pow(source.x-stage1.x,2)+math.pow(source.y-stage1.y,2))
				delay2 = delay + (distance*1000/speed)
				stage2 = SkillShot.PredictedXYZ(t,delay2)
				i = i + 1
				cycle = cycle + 1
				print(math.floor(distance), math.floor(math.sqrt(math.pow(source.x-stage1.x,2)+math.pow(source.y-stage1.y,2))))
			end
			return Vector(stage2.x,stage2.y,t.position.z)
		end
	end
end


function SkillShot.BlockableSkillShotXYZ(source,t,delay,speed,aoe,team)
	if team == nil then
		team = false
	end
	local pred = SkillShot.SkillShotXYZ(source,t,delay,speed)
	if pred and not SkillShot.__GetBlock(source.position,pred,t,aoe,team) then
		return pred
	end
end


function SkillShot.__GetBlock(v1,v2,target,aoe,team)
	if team == nil then
		team = false
	end
	local block = {}
	local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,team=TEAM_ENEMY,visible=true})
	local siege = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Siege,alive=true,team=TEAM_ENEMY,visible=true})
	local forge = entityList:FindEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,alive=true,team=TEAM_ENEMY,visible=true})
	local hero = entityList:FindEntities({type=TYPE_HERO,alive=true,team=TEAM_ENEMY,visible=true})
	local neutrals = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Neutral,alive=true,visible=true})
	local golem = entityList:FindEntities({classId=CDOTA_BaseNPC_Warlock_Golem,alive=true,team=TEAM_ENEMY,visible=true})
	if team then
		creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,visible=true})
		siege = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Siege,alive=true,visible=true})
		forge = entityList:FindEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,alive=true,visible=true})
		hero = entityList:FindEntities({type=TYPE_HERO,alive=true,visible=true})
		golem = entityList:FindEntities({classId=CDOTA_BaseNPC_Warlock_Golem,alive=true,visible=true})
	end
	for k,v in pairs(creeps) do block[#block + 1] = v end
	for k,v in pairs(siege) do block[#block + 1] = v end
	for k,v in pairs(forge) do block[#block + 1] = v end
	for k,v in pairs(hero) do block[#block + 1] = v end
	for k,v in pairs(golem) do block[#block + 1] = v end	
	for k,v in pairs(neutrals) do block[#block + 1] = v end	
	local block = SkillShot.__CheckBlock(block,v1,v2,aoe,target)
	return block
end

function SkillShot.__CheckBlock(units,v1,v2,aoe,target)
	distance = GetDistance2D(v1,v2)
	local i = 1
	local block = false
	local filterunits = {}
	for k,v in pairs(units) do
		if v ~= nil and v.handle ~= target.handle and v.GetDistance2D then
			if v1 ~= nil and v:GetDistance2D(v1) < distance and v:GetDistance2D(target) < distance then
				filterunits[#filterunits + 1] = v
			end
		end
	end
	for i,v in ipairs(filterunits) do
		local closest = SkillShot.GetClosestPoint(v1,(v2 - v1):GetXYAngle(),v.position,distance-aoe)
		if closest then
			if GetDistance2D(v,closest) < aoe then
				block = true
			end
		end
	end
	return block
end

function SkillShot.GetClosestPoint(A, _a, P,e)
    local l1 = {x = math.tan(_a), c = A.y - A.x * math.tan(_a)}
    local l2 = {x = math.tan(_a+math.pi/2), c =  P.y - P.x * math.tan(_a+math.pi/2)}

    local final = Vector((l2.c-l1.c)/(l1.x-l2.x),l1.x*(l2.c-l1.c)/(l1.x-l2.x) + l1.c,A.z)

    local length = GetDistance2D(final, A)
    if math.floor((final.x - A.x)/length) == math.floor(math.cos(_a)) and math.floor((final.y - A.y)/length) == math.floor(math.sin(_a)) then
        if length <= e then
            return final
        else
            return Vector(A.x + e*math.cos(_a),A.y + e*math.sin(_a),A.z)
        end
    end
end

scriptEngine:RegisterLibEvent(EVENT_TICK,SkillShot.__TrackTick)