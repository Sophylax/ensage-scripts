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

			Illusion Delta Split v1.0

		Changelog:
			v1.0:
			 - Release

]]


function Tick(msg,code)
	if not PlayingGame() then
		return
	end

	local phantoms = entityList:FindEntities({classId = me.classId, controllable = true, team = me.team, illusion = true, distance = {me,600}, alive = true})

	if #phantoms == 0 then
		return
	end

	if IsKeyDown(string.byte("V")) and SleepCheck() then
		local alpha = vectorOp:GetXYAngle(engineClient.mousePosition - me.position)
		local dAlpha = 2*math.pi/(#phantoms + 1)
		me:Move(engineClient.mousePosition)
		for i,v in ipairs(phantoms) do
			v:Move(v.position + vectorOp:UnitVectorFromXYAngle(alpha + dAlpha*i)*50)
			for d=100,550,225 do
				QueueNextAction()
				v:Move(v.position + vectorOp:UnitVectorFromXYAngle(alpha + dAlpha*i)*d)
			end
		end
		Sleep(5000)
	end
end

script:RegisterEvent(EVENT_TICK,Tick)