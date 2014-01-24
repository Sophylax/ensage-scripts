require("libs.Utils")
require("libs.TargetFind")
require("libs.HotkeyConfig")
require("libs.SkillShot")

--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0 

			Earth Spirit Tools  v1.0

		3 Combos in one key, skipping to other combo if spells for one isn't ready:
			Remnant - Boulder Smash - Geomagnetic Grip - Rolling Boulder
			Remnant - Geomagnetic Grip - Rolling Boulder
			Remnant - Boudler Smash - Geomagnetic Grip

		Instant remnant and spell cast to desired mouse location
			Remnant Smash
			Rolling Remnant
			Remnant Grip

		Smash Navigator: Hovering mouse on a nearby unit will show where the target will go with the Boulder Smash

		Auto Magnetize: A remnant will refresh an enemy's Magnetize debuff if it is about to end

		Changelog:

			v1.0:
			 - Release

]]

ScriptConfig = ConfigGUI:New(script.name)
ScriptConfig:SetName("Earth Combo")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("push","Remnant Smash",SGC_TYPE_ONKEYDOWN,false,false,string.byte("Z"))
ScriptConfig:AddParam("roll","Rolling Remnant",SGC_TYPE_ONKEYDOWN,false,false,string.byte("X"))
ScriptConfig:AddParam("pull","Remnant Grip",SGC_TYPE_ONKEYDOWN,false,false,string.byte("C"))
ScriptConfig:AddParam("combo","Combo",SGC_TYPE_ONKEYDOWN,false,false,0x20)
ScriptConfig:AddParam("nav","Smash Navigator",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ping","Ping Corrector",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("ult","Auto Magnetize",SGC_TYPE_TOGGLE,false,true,nil)

remnants = {}
effs = {}
init = false
stage = {combo = 0, push = 0, pull = 0, roll = 0}
itemSleep = 75
castSleep = 75
bat = 100
remnant = nil
push = nil
pull = nil
roll = nil
magnetize = nil

function Tick(tick)
	if not PlayingGame() then
		DeInit()
		return
	end

	if me.name ~= "EarthSpirit" then
		DeInit()
		script:Disable()
		return
	end

	Init()

	TrackRemnants()

	SmashNav()

	Combo()

	RemnantSmash()

	RollingRemnant()

	RemnantGrip()

	ExtendMagnetize()
end

function Init( ... )
	if not init then
		for i=1,40 do
			effs[i] = Effect(Vector(0,0,-1250),"espirit_boouldersmash_groundsmoketrail")
		end
		init = true
		ScriptConfig:SetVisible(true)

		remnant = me:FindSpell("earth_spirit_stone_caller")
		push = me:FindSpell("earth_spirit_boulder_smash")
		pull = me:FindSpell("earth_spirit_geomagnetic_grip")
		roll = me:FindSpell("earth_spirit_rolling_boulder")
		magnetize = me:FindSpell("earth_spirit_magnetize")

	end
end

function DeInit( ... )
	if init then
		ScriptConfig:SetVisible(false)
		effs = {}
		init = false
		remnant = nil
		push = nil
		pull = nil
		roll = nil
		magnetize = nil
	end
end

function SmashNav()
	dirty = false
	
	local mouseOver = entityList:GetMouseOver()
	local allRemnants = entityList:FindEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, team = me.team, distance = {me, 900}})
	if #allRemnants > 0 then
		table.sort(allRemnants, function(a,b) return GetDistance2D(a, engineClient.mousePosition) < GetDistance2D(b, engineClient.mousePosition) end)
		if GetDistance2D(allRemnants[1],engineClient.mousePosition) < 50 then
			mouseOver = allRemnants[1]
		end
	end

	if ScriptConfig.nav and me:CanCast() and push:CanBeCasted() and mouseOver then
		local limit = mouseOver.classId == CDOTA_Unit_Earth_Spirit_Stone and 40 or 8 + 2*push.level
		for i=1,limit do
			local xyz = ((mouseOver.position - me.position) / me:GetDistance2D(mouseOver) * 50 * i) + mouseOver.position
			effs[i]:SetPosition(Vector(xyz.x, xyz.y, mouseOver.z))
		end
		dirty = true
	elseif dirty then
		dirty = false
		for i=1,40 do
			effs[i]:SetPosition(Vector(0,0,-1250))
		end
	end
end

function Combo()
	if ScriptConfig.combo and SleepCheck("c") then
		local target = targetFind:GetLastMouseOver(1000)
		if target then
			if stage.combo == 0 then
				stage.combo = 1
				if me.activity == 422 and ScriptConfig.ping then
					me:Stop()
					Sleep(engineClient.latency + 25,"c")
				end
			elseif stage.combo == 1 and remnant:CanBeCasted() then
				if push:CanBeCasted() and pull:CanBeCasted() and me:CanCast() then
					local xyz = SkillShot.SkillShotXYZ(me,target,375,1200)
					if xyz then
						me:SafeCastAbility(remnant,(xyz - me.position) * 150 / GetDistance2D(xyz,me) + me.position)
						QueueNextAction()
						me:SafeCastAbility(push,(xyz - me.position) * 150 / GetDistance2D(xyz,me) + me.position)
						stage.combo = 2
						Sleep(castSleep*2 + 250,"c")
					end
				elseif pull:CanBeCasted() and me:CanCast() and roll:CanBeCasted() then
					me:SafeCastAbility(remnant,target.position)
					QueueNextAction()
					me:SafeCastAbility(pull,target.position)
					QueueNextAction()
					me:SafeCastAbility(roll,target.position)
					stage.combo = 3
					Sleep(castSleep*3 + 250,"c")
				end
			elseif stage.combo == 2 then
				if GetLatestRemnant() and target:GetDistance2D(GetLatestRemnant().position) < 180 then
					if me:SafeCastAbility(pull,GetLatestRemnant()) then
						if roll:CanBeCasted() then
							QueueNextAction()
							me:SafeCastAbility(roll,target.position)
						end
						stage.combo = 3
						Sleep(castSleep*3 + 250,"c")
					end
				end
			elseif stage.combo == 3 then
				me:Attack(target)
				stage.combo = 4
				Sleep(castSleep + 158,"c")
			end
		end
	elseif SleepCheck("c") then
		stage.combo = 0
	end
end

function RemnantSmash( ... )
	if (ScriptConfig.push or (stage.push > 0 and stage.push < 2)) and SleepCheck("push") then
		local target = engineClient.mousePosition
		if me:GetDistance2D(target) < 2000 and GetDistance2D(target,Vector(0,0,0)) > 1 then
			if remnant:CanBeCasted() and push:CanBeCasted() and me:CanCast() then
				if stage.push == 0 then
					stage.push = 1
					if me.activity == 422 and  ScriptConfig.ping then
						me:Stop()
						Sleep(engineClient.latency + 25,"push")
					end
				elseif stage.push == 1 then
					me:SafeCastAbility(remnant,(target - me.position) * 150 / GetDistance2D(target,me) + me.position)
					QueueNextAction()
					me:SafeCastAbility(push,(target - me.position) * 150 / GetDistance2D(target,me) + me.position)
					stage.push = 2
					Sleep(1000,"push")
				end
			end
		end
	elseif SleepCheck("push") then
		stage.push = 0
	end
end

function RollingRemnant( ... )
	if (ScriptConfig.roll or (stage.roll > 0 and stage.roll < 1)) and SleepCheck("roll") then
		local target = engineClient.mousePosition
		if me:GetDistance2D(target) < 3000 and GetDistance2D(target,Vector(0,0,0)) > 1 then
			if remnant:CanBeCasted() and roll:CanBeCasted() and me:CanCast() then
				if stage.roll == 0 then
					me:SafeCastAbility(remnant,(target - me.position) * 150 / GetDistance2D(target,me) + me.position)
					QueueNextAction()
					me:SafeCastAbility(roll,target)
					stage.roll = 1
					Sleep(1000,"roll")
				end
			end
		end
	elseif SleepCheck("roll") then
		stage.roll = 0
	end
end

function RemnantGrip()
	if (ScriptConfig.pull or (stage.pull > 0 and stage.pull < 1)) and SleepCheck("pull") then
		local target = engineClient.mousePosition
		if me:GetDistance2D(target) < 1100 and GetDistance2D(target,Vector(0,0,0)) > 1 then
			if remnant:CanBeCasted() and pull:CanBeCasted() and me:CanCast() then
				if stage.pull == 0 then
					me:SafeCastAbility(remnant,target)
					QueueNextAction()
					me:SafeCastAbility(pull,target)
					stage.pull = 1
					Sleep(1000,"pull")
				end
			end
		end
	elseif SleepCheck("pull") then
		stage.pull = 0
	end
end

function ExtendMagnetize()
	if ScriptConfig.ult and SleepCheck("ult") and me:CanCast() and remnant:CanBeCasted() then
		local enemies = entityList:FindEntities({type = TYPE_HERO, team = TEAM_ENEMY})
		for i,v in ipairs(enemies) do
			if v.visible and v.alive and not v.illusion and v:GetDistance2D(me) < remnant.castRange - 150 then
				local mod = v:FindModifier("modifier_earth_spirit_magnetize")
				if mod and mod.remainingTime < 0.4 then
					me:SafeCastAbility(remnant,v.position)
					Sleep(450, "ult")
				end
			end
		end
	end
end

function GetLatestRemnant()
	local allRemnants = entityList:FindEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, team = me.team})
	if #allRemnants > 0 then
		table.sort(allRemnants, function(a,b) return remnants[a.handle]>remnants[b.handle] end)
		return allRemnants[1]
	end
end

function TrackRemnants()
	local allRemnants = entityList:FindEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, team = me.team})
	for i,v in ipairs(allRemnants) do
		if not remnants[v.handle] then
			remnants[v.handle] = GetTotalGameTime()
		end
	end
end

script:RegisterEvent(EVENT_TICK,Tick)