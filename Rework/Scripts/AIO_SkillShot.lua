--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0

			All-in-One SkillShot v1.0a

		Meat Hook, Sacred Arrow, Nyx Impale, Hookshot, Powershot

		Includes Auto Powershot cancel and Kill monitor for Rocket Flare

		Changelog:

			v1.0a:
			 - Fixed UI getting stuck in the new game before hero selection

			v1.0:
			 - Release   
]]

require("libs.TargetFind")
require("libs.HotkeyConfig")
require("libs.Utils")
require("libs.SkillShot")
require("libs.VectorOp")

for k,ent in pairs(entityList:FindEntities({type = LuaEntity.TYPE_HERO})) do
	print(ent.position:tostring())
end

_X = 33
_Y = 35
_GAP = 10
_COLOR = 0xFFFFFFFF

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("SkillShot AIO")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)
ScriptConfig:AddParam("ping","Ping Corrector",SGC_TYPE_TOGGLE,false,true,nil)

gui = {}

skillShotList = {
	{
	spellName = "windrunner_powershot",
	paramName = "powershot",
	engName = "Powershot",
	blockType = nil,
	rangeData = "arrow_range",
	speedData = "arrow_speed",
	aoeData = "arrow_width",
	extraCastTime = .8,
	defaultKey = "C",
	},
	{
	spellName = "pudge_meat_hook",
	paramName = "hook",
	engName = "Meat Hook",
	blockType = true,
	rangeData = "hook_distance",
	speedData = "hook_speed",
	aoeData = "hook_width",
	extraCastTime = 0,
	defaultKey = "C",
	},
	{
	spellName = "rattletrap_rocket_flare",
	paramName = "flare",
	engName = "Rocket Flare",
	blockType = nil,
	rangeData = nil,
	speedData = "speed",
	aoeData = "radius",
	extraCastTime = 0,
	defaultKey = "X",
	},
	{
	spellName = "rattletrap_hookshot",
	paramName = "hookshot",
	engName = "Hookshot",
	blockType = true,
	rangeData = "tooltip_range",
	speedData = "speed",
	aoeData = "latch_radius",
	extraCastTime = 0,
	defaultKey = "C",
	},
	{
	spellName = "mirana_arrow",
	paramName = "arrow",
	engName = "Sacred Arrow",
	blockType = false,
	rangeData = "arrow_range",
	speedData = "arrow_speed",
	aoeData = "arrow_width",
	extraCastTime = 0,
	defaultKey = "C",
	},
	{
	spellName = "nyx_assassin_impale",
	paramName = "nyxImpale",
	engName = "Nyx Impale",
	blockType = nil,
	rangeData = "length",
	speedData = "speed",
	aoeData = "width",
	extraCastTime = 0,
	defaultKey = "C",
	}
}

function Tick( tick )

	if not PlayingGame() then
		ScriptConfig:SetVisible(false)
		gui = {}
		return
	end

	--Auto Powershot Cancel
	local powershot = entityList:GetMyHero():FindSpell("windrunner_powershot")
	if powershot then
		local delay = 0
		if ScriptConfig.ping then
			delay = client.latency / 1000
		end
		if powershot.channelTime > 0 and client.gameTime > powershot.channelTime + .81 - delay then
			entityList:GetMyHero():Move(entityList:GetMyHero().position)
			return
		end
	end

	local flare = entityList:GetMyHero():FindSpell("rattletrap_rocket_flare")
	if flare then
		if gui.flareKill == nil then
			gui.flareKill = drawMgr:CreateText(_X + 160,_Y,_COLOR,"",hcFont)
		end
		local target = targetFind:GetLowestEHP(22000,"magic",(1+flare.level)*40)
		if target then
			gui.flareKill.text = "Flare Kill:"..target.name
		else
			gui.flareKill.text = ""
		end
	else
		if gui.flareKill then
			gui.flareKill = nil
		end
	end
	local spellCount = 0

	for i,v in ipairs(skillShotList) do
		if gui[v.paramName] == nil then
			gui[v.paramName] = drawMgr:CreateText(_X,_Y+spellCount*_GAP,_COLOR,"",hcFont)
		elseif gui[v.paramName].y ~= _Y + spellCount*_GAP then
			gui[v.paramName].position = Vector2D(_X,_Y+spellCount*_GAP)
		end
		local spell = entityList:GetMyHero():FindSpell(v.spellName)
		if spell then
			if ScriptConfig[v.paramName] == nil then
				ScriptConfig:AddParam(v.paramName,"Use "..v.engName,SGC_TYPE_ONKEYDOWN,false,false,string.byte(v.defaultKey))
			end
			spellCount = spellCount + 1
			if entityList:GetMyHero():CanCast() and spell:CanBeCasted() then
				if SleepCheck(v.paramName) then
					local range = v.rangeData ~= nil and spell:GetSpecialData(v.rangeData) or 22000 -- More than the distance between topleft corner and bottomright corner of the map
					local speed = spell:GetSpecialData(v.speedData)
					local aoe = spell:GetSpecialData(v.aoeData)
					local target = targetFind:GetLastMouseOver(range + aoe)
					local castPoint = spell:FindCastPoint()
					if target then
						gui[v.paramName].text = v.engName..": "..target.name.." ("..math.ceil(target:GetDistance2D(entityList:GetMyHero()))..")"
						if ScriptConfig[v.paramName] then
							local xyz = nil
							local delay = 0
							if ScriptConfig.ping then
								delay = client.latency
							end
							if v.blockType == nil then
								xyz = SkillShot.SkillShotXYZ(entityList:GetMyHero(),target,castPoint + v.extraCastTime*1000 + delay,speed)
							else
								xyz = SkillShot.BlockableSkillShotXYZ(entityList:GetMyHero(),target,castPoint + v.extraCastTime*1000 + delay,speed,aoe,v.blockType)
							end
							if xyz and entityList:GetMyHero():GetDistance2D(xyz) < range + aoe then
								if entityList:GetMyHero():GetDistance2D(xyz) > spell.castRange and spell.castRange ~= 0 then
									xyz = (xyz - entityList:GetMyHero().position) * (spell.castRange - 100) / entityList:GetMyHero():GetDistance2D(xyz) + entityList:GetMyHero().position
								end
								entityList:GetMyHero():CastAbility(spell,xyz)
								Sleep(250,v.paramName)
							end
						end
					else
						gui[v.paramName].text = v.engName..": Searching: "..(range + aoe)
					end
				end
			else
				gui[v.paramName].text = v.engName..": Cannot Be Casted"
			end
		else
			if ScriptConfig[v.paramName] ~= nil then
				ScriptConfig:RemoveParam(v.paramName)
			end
			gui[v.paramName].text = ""
		end
	end
		
	ScriptConfig:SetVisible(spellCount > 0)
end

script:RegisterEvent(EVENT_TICK,Tick)