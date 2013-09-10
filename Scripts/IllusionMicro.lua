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

			Illusion Micro v1.1

		This script utilizes middle-mouse button to control illusions.

		Changelog:
			v1.1:
			 - Newly Created Illusions now attack nearest hero in 800 range if there is any.

			v1.0:
			 - Release

]]

init = false

illuTable = {}

function Tick(tick)
	if not PlayingGame() then
		init = false
		return
	end

	Init()

	local phantoms = entityList:FindEntities({type = TYPE_HERO, controllable = true, team = me.team, illusion = true, alive = true})
	for i,v in ipairs(phantoms) do
		if not illuTable[v.handle] then
			PseudoEntityAdd(v)
			illuTable[v.handle] = true
		end
	end
end

function PseudoEntityAdd(entity)
	local enemies = entityList:FindEntities({type = TYPE_HERO, controllable = true, team = TEAM_ENEMY, illusion = false, alive = true, distance = {entity,800}})
	table.sort(enemies,function(a,b) return entity:GetDistance2D(a)<entity:GetDistance2D(b) end)
	if #enemies > 0 then
		entity:Attack(enemies[1])
	end
end

function Init()
	if not init then
		init = true
		local phantoms = entityList:FindEntities({type = TYPE_HERO, controllable = true, team = me.team, illusion = true, alive = true})
		for i,v in ipairs(phantoms) do
			illuTable[v.handle] = true
		end
	end
end


function Key(msg,code)
	if msg == MBUTTON_DOWN then
		local phantoms = entityList:FindEntities({type = TYPE_HERO, controllable = true, team = me.team, illusion = true, alive = true})
		if entityList:GetMouseOver() then
			local target = entityList:GetMouseOver()
			if target.team == me.team then
				for i,v in ipairs(phantoms) do
					if v.unitState ~= -1031241196 then
						v:Attack(target)
						QueueNextAction()
						v:Follow(target)
					end
				end
			else
				for i,v in ipairs(phantoms) do
					if v.unitState ~= -1031241196 then
						v:Attack(target)
					end
				end
			end
		elseif GetDistance2D(Vector(0,0,0),engineClient.mousePosition) > 0 then
			local target = engineClient.mousePosition 
			for i,v in ipairs(phantoms) do
				if v.unitState ~= -1031241196 then
					v:Move(target.x,target.y,1500)
				end
			end
		end
	end
end

script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_TICK,Tick)