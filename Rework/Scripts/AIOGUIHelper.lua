--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0  

                All-in-One GUI Helper v1.1

        Rune and Roshan monitor at the top bar

        Rune monitoring at the minimap

        Side-Screen enemy monitoring

        Minimap locations of enemy couriers

        Advanced Monitor
        -Level, Stats, Damage, Armor and other information about enemies
        -Levels and states of the spells of the enemies
        -Items of enemies and their states, charges. Even items in their Stash!

        Missing hero monitor at the side of the minimap
        -When an enemy is missing ETA timer appears
        -ETA timer ignores terrain and assumes heroes ms as 500 (because you can't know when a guy will have haste)

        Last known location of the missing heroes shown at the minimap and actual position
        -Minimap: Mini icon of the hero
        -Actual Position: Hero name and HP percent

        6 Different 4:3 resolution support
        -800x600
        -1024x768
        -1152x864
        -1280x960
        -1280x1024
        -1600x1200

        5 Different 16:9 resolution support
        -1280x720
        -1360x768
        -1366x768
        -1600x900
        -1920x1080

        5 Different 16:10 resolution support
        -1280x768
        -1280x800
        -1440x900
        -1680x1050
        -1920x1200

        Special Thanks:
        -Zynox: For Ensage, RuneMarker Script and RoshanTimer Script
        -Ryan: For completely adapting the script to 4:3 resolutions
        -4xing: For his idea of Side-Screen enemy monitoring

        Changelog:
            v1.2:
             - Reworked for ensage rework
             - Added last hit monitor

            v1.1:
             - Added Advanced Monitor
             - Added enemy couriers to the minimap

            v1.0c:
             - Switched from GetTotalGameTime() to client.gameTime for stability

            v1.0b:
             - Added custom missing messages for Invisibility/Smoke
             - Added an arrow shape to indicate last-known direction to the last known position
             - Swithced from EVENT_TICK to EVENT_FRAME for some sync improving (experimental, may cause performace drop)

            v1.0a:
             - Added HotkeyConfig Support for disabling features

            v1.0:
             - Release
]]

require("libs.Utils")
require("libs.HotkeyConfig")
require("libs.VectorOp")

ScriptConfig = ConfigGUI:New(script.name)
script:RegisterEvent(EVENT_KEY, ScriptConfig.Key, ScriptConfig)
script:RegisterEvent(EVENT_TICK, ScriptConfig.Refresh, ScriptConfig)
ScriptConfig:SetName("AIOGUI")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("roshBox","Roshan Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("runeBox","Rune Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("missingMonitor","Missing Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("sideView","SideScreen Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("cours","Enemy Couriers",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("creeps","Last Hit Monitor",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("selfVis","Self Visibility",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("allyVis","Allied Visibility",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("shCharge","Show Charge",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("shInfest","Show Infest",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("shIllu","Show Illusion",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("allyTow","Ally Tower Range",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("enemyTow","Enemy Tower Range",SGC_TYPE_TOGGLE,false,false,nil)
ScriptConfig:AddParam("advMon","Advanced Monitor",SGC_TYPE_TOGGLE,false,false,109)

defaultFont = drawMgr:CreateFont("defaultFont","Arial",14,500)
lhFont = drawMgr:CreateFont("defaultFont","Arial",14,1800)

--==A lot of constants==--
init = false
location = {}
--Roshan Monitor
deathTick = nil
tickDelta = 0
roshText = ""
--Rune Monitor
filename = ""
runeMsg = nil
--Missing Monitor
MapLeft = -8000
MapTop = 7350
MapRight = 7500
MapBottom = -7200
MapWidth = math.abs(MapLeft - MapRight)
MapHeight = math.abs(MapBottom - MapTop)
lastseenList = {}
--AdvancedMonitor
itemSize = Vector2D(32,16)
gapSize = Vector2D(2,2)
extraGap = Vector2D(10,20)
advFont = drawMgr:CreateFont("advFont","Arial",12,500)
itemChargeFont = drawMgr:CreateFont("itemChargeFont","Arial",10,500)
itemPercent = 88/124
wi = 150
ga = 4
adVisible = false
--Settings Table for 16 resolution
ResTable = 
{
 -- Settings for 4:3
 {800,600,{rosh = {x = 640, y = 3},rune = {x = 730, y = 3},minimap={px = 4, py = 5, h = 146, w = 151},ssMonitor={x = 172, y = 488, h = 19, w =84, size = 12},sideview={w = 82, h = 60, t = 77, b = 200}}},
 {1024,768,{rosh = {x = 820, y = -1},rune = {x = 820 , y = 13},minimap={px = 5, py = 7, h = 186, w = 193},ssMonitor={x = 222, y = 625, h = 25, w = 104, size = 12},sideview={w = 82, h = 60, t = 90, b = 240}}}, 
 {1152,864,{rosh = {x = 930, y = 0},rune = {x = 930 , y = 16},minimap={px = 6, py = 7, h = 211, w = 217},ssMonitor={x = 249, y = 703, h = 27, w = 115, size = 13},sideview={w = 82, h = 60, t = 90, b = 266}}},
 {1280,960,{rosh = {x = 1030, y = 1},rune = {x = 1030 , y = 19},minimap={px = 6, py = 9, h = 233, w = 241},ssMonitor={x = 277, y = 782, h = 30, w = 130, size = 14},sideview={w = 82, h = 60, t = 99, b = 290}}},
 {1280,1024,{rosh = {x = 1030, y = 3},rune = {x = 1030 , y = 21},minimap={px = 6, py = 9, h = 233, w = 241},ssMonitor={x = 277, y = 845, h = 30, w = 130, size = 14},sideview={w = 82, h = 60, t = 99, b = 290}}},
 {1360,1024,{rosh = {x = 1100, y = 3},rune = {x = 1100 , y = 21},minimap={px = 6, py = 11, h = 246, w = 260},ssMonitor={x = 296, y = 835, h = 30, w = 132, size = 14},sideview={w = 82, h = 60, t = 99, b = 290}}},
 {1600,1200,{rosh = {x = 1395, y = 6},rune = {x = 1395 , y = 24},minimap={px = 8, py = 14, h = 288, w = 304},ssMonitor={x = 346, y = 978, h = 37, w = 156, size = 15},sideview={w = 82, h = 60, t = 99, b = 360}}},
 -- Settings for 16:9
 {1280,720,{rosh = {x = 150, y = 4},rune = {x = 241 , y = 4},minimap={px = 8, py = 8, h = 174, w = 181},ssMonitor={x = 200, y = 605, h = 21, w = 90, size = 12},sideview={w = 82, h = 60, t = 29, b = 193}}},
 {1360,768,{rosh = {x = 167, y = 6},rune = {x = 258 , y = 6},minimap={px = 8, py = 8, h = 186, w = 193},ssMonitor={x = 213, y = 645, h = 23, w = 95, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1366,768,{rosh = {x = 167, y = 6},rune = {x = 258 , y = 6},minimap={px = 8, py = 8, h = 186, w = 193},ssMonitor={x = 213, y = 645, h = 23, w = 95, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1600,900,{rosh = {x = 202, y = 9},rune = {x = 293 , y = 9},minimap={px = 9, py = 9, h = 217, w = 227},ssMonitor={x = 250, y = 756, h = 27, w = 100, size = 14},sideview={w = 82, h = 60, t = 37, b = 242}}},
 {1920,1080,{rosh = {x = 212, y = 3},rune = {x = 212 , y = 21},minimap={px = 11, py = 11, h = 261, w = 272},ssMonitor={x = 300, y = 907, h = 32, w = 100, size = 14},sideview={w = 82, h = 60, t = 44, b = 290}}},
 -- Settings for 16:10
 {1280,768,{rosh = {x = 146, y = 6},rune = {x = 236 , y = 6},minimap={px = 8, py = 8, h = 186, w = 193},ssMonitor={x = 283, y = 620, h = 25, w = 103, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1280,800,{rosh = {x = 1020, y = 6},rune = {x = 1110 , y = 6},minimap={px = 8, py = 10, h = 192, w = 203},ssMonitor={x = 283, y = 652, h = 25, w = 103, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1440,900,{rosh = {x = 172, y = 9},rune = {x = 262 , y = 9},minimap={px = 9, py = 9, h = 217, w = 227},ssMonitor={x = 318, y = 734, h = 28, w = 115, size = 14},sideview={w = 82, h = 60, t = 37, b = 242}}},
 {1680,1050,{rosh = {x = 212, y = 3},rune = {x = 212 , y = 21},minimap={px = 10, py = 11, h = 252, w = 267},ssMonitor={x = 277, y = 857, h = 32, w = 95, size = 14},sideview={w = 82, h = 60, t = 44, b = 290}}},
 {1920,1200,{rosh = {x = 242, y = 6},rune = {x = 242 , y = 24},minimap={px = 12, py = 14, h = 288, w = 304},ssMonitor={x = 320, y = 977, h = 32, w = 100, size = 14},sideview={w = 82, h = 60, t = 44, b = 290}}},
}

effectTables = {
    infest = {
        check = function (ent) return ScriptConfig.shInfest and ent.FindModifier ~= nil and ent.visible and ent.alive and ent:FindModifier("modifier_life_stealer_infest_effect") ~= nil and #entityList:FindEntities(function (v) return v.classId ~= 518 and v.visible and ent:GetDistance2D(v) == 0  end) == 1 end,
        effects = {
        {"life_stealer_infested_unit_icon", Vector(0,0,250)},
        }
    },
    charge = {
        check = function (ent) return ScriptConfig.shCharge and ent.FindModifier ~= nil and ent.alive and ent:FindModifier("modifier_spirit_breaker_charge_of_darkness_vision") ~= nil and ent.team == entityList:GetMyHero().team end,
        effects = {
        {"spirit_breaker_charge_target_mark", Vector(0,0,250)},
        }
    },
    selfVisible = {
        check = function (ent) return ScriptConfig.selfVis and ent.handle == entityList:GetMyHero().handle and ent.visibleToEnemy and ent.alive and not ent:IsUnitState(LuaEntityNPC.STATE_OUT_OF_GAME) end,
        effects = {
        {"rune_generic_rings",param = Vector(255,0,0)},
        {"rune_generic_rings",param = Vector(255,0,0)},
        {"rune_generic_rings",param = Vector(255,0,0)},
        {"rune_generic_rings",param = Vector(255,0,0)},
        }
    },
    alliedVisible = {
        check = function (ent) return ScriptConfig.allyVis and ent.team == entityList:GetMyHero().team and ent.handle ~= entityList:GetMyHero().handle and ent.alive and ent.hero and ent.visibleToEnemy and not ent:IsUnitState(LuaEntityNPC.STATE_OUT_OF_GAME) end,
        effects = {
        {"rune_generic_rings",param = Vector(0,0,255)},
        {"rune_generic_rings",param = Vector(0,0,255)},
        {"rune_generic_rings",param = Vector(0,0,255)},
        {"rune_generic_rings",param = Vector(0,0,255)},
        }
    },
    enemyIllu = {
        check = function (ent) return ScriptConfig.shIllu and ent.team ~= entityList:GetMyHero().team and ent.hero and ent.illusion and ent.alive and ent.visible and not ent:IsUnitState(LuaEntityNPC.STATE_OUT_OF_GAME) end,
        effects = {
        {"smoke_of_deceit_buff"},
        {"rune_generic_rings",param = Vector(0,0,255)},
        {"rune_generic_rings",param = Vector(0,0,255)},
        {"rune_generic_rings",param = Vector(0,0,255)},
        {"rune_generic_rings",param = Vector(0,0,255)},
        }
    },
    enemyTowers = {
        check = function (ent) return ScriptConfig.allyTow and ent.team ~= entityList:GetMyHero().team and ent.classId == CDOTA_BaseNPC_Tower and ent.alive and not ent:IsUnitState(LuaEntityNPC.STATE_OUT_OF_GAME) end,
        effects = {
        {"range_display",param = Vector(850,0,0)},
        }
    },
    alliedTowers = {
        check = function (ent) return ScriptConfig.enemyTow and ent.team == entityList:GetMyHero().team and ent.classId == CDOTA_BaseNPC_Tower and ent.alive and not ent:IsUnitState(LuaEntityNPC.STATE_OUT_OF_GAME) end,
        effects = {
        {"range_display",param = Vector(850,0,0)},
        }
    },
}

effects = {}

function effTick()
    local ents = entityList:FindEntities({})
    for i,v in ipairs(ents) do
        if v.handle and (v.npc or v.hero or v.meepo or v.creep or v.classId == CDOTA_BaseNPC_Tower) then
            if not effects[v.handle] then
                effects[v.handle] = {}
            end
            for _,t in pairs(effectTables) do
                if not effects[v.handle][_] then
                    if t.check(v) then
                        effects[v.handle][_] = {}
                        for __,eff in ipairs(t.effects) do
                            if eff[3] then
                                effects[v.handle][_][__] = Effect(v, eff[1],eff[2],eff[3])
                            elseif eff[2] then
                                effects[v.handle][_][__] = Effect(v.position + eff[2] , eff[1])
                            else
                                effects[v.handle][_][__] = Effect(v , eff[1])
                            end
                            if eff.param then
                                effects[v.handle][_][__]:SetVector( 1, eff.param )
                            end
                        end
                    end
                elseif not t.check(v) then
                    effects[v.handle][_] = nil
                    collectgarbage("collect")
                end
            end
        end
    end
end

function Tick(tick)
    if not PlayingGame() then
        DeInit()
        CleanUp()
        return
    end

    DrawInit()

    SetVisibilityOfATable(roshBox,ScriptConfig.roshBox)

    SetVisibilityOfATable(runeBox,ScriptConfig.runeBox)
    if minimapRune then
        minimapRune.visible = ScriptConfig.runeBox
    end

    SetVisibilityOfATable(missingMonitor,ScriptConfig.missingMonitor)

    SetVisibilityOfATable(sideView,ScriptConfig.sideView)

    SetVisibilityOfATable(cours,ScriptConfig.cours)

    SetVisibilityOfATable(creeps,ScriptConfig.creeps)

    RoshanTick()

    MissingTick()

    RuneTick()

    SideTick()

    CourierTick()

    effTick()

    AdvancedMonitorTick( tick )

    LastHitMonitorTick()

    CleanUp()
end

function CourierTick()
    local dirty = false
    local enemyCours = entityList:FindEntities({classId = CDOTA_Unit_Courier, alive = true})
    for i,v in ipairs(enemyCours) do
        if v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 then
            if v.visible and v.alive then
                local courMinimap = MapToMinimap(v)
                if type(courMinimap) == "table" then
                    courMinimap = Vector2D(courMinimap.x,courMinimap.y)
                end
                local flying = v:GetProperty("CDOTA_Unit_Courier","m_bFlyingCourier")
                if flying then
                    if not cours[v.handle] or not cours[v.handle].flying then
                        cours[v.handle] = {}
                        cours[v.handle].icon = drawMgr:CreateRect(courMinimap.x-10,courMinimap.y-6,21,12,0x000000FF,drawMgr:GetTextureId("AIOGUI/courier_flying"))
                        cours[v.handle].icon.visible = ScriptConfig.cours
                        cours[v.handle].vec = courMinimap
                        cours[v.handle].flying = flying
                        dirty = true
                    elseif GetDistance2D(courMinimap,cours[v.handle].vec) > 0 then
                        cours[v.handle].icon.x,cours[v.handle].icon.y = courMinimap.x-10,courMinimap.y-6
                    end
                else
                    if not cours[v.handle] or not cours[v.handle].flying then
                        cours[v.handle] = {}
                        cours[v.handle].icon = drawMgr:CreateRect(courMinimap.x-6,courMinimap.y-6,12,12,0x000000FF,drawMgr:GetTextureId("AIOGUI/courier"))
                        cours[v.handle].icon.visible = ScriptConfig.cours
                        cours[v.handle].vec = courMinimap
                        cours[v.handle].flying = flying
                        dirty = true
                    elseif GetDistance2D(courMinimap,cours[v.handle].vec) > 0 then
                        cours[v.handle].icon.x,cours[v.handle].icon.y = courMinimap.x-6,courMinimap.y-6
                    end
                end
            else
                cours[v.handle] = nil
            end
        end
    end
    if dirty then
        collectgarbage("collect")
    end
end

heroCount = 0

function ColorTransfusionHealth(hpPerc)

    local brightness = 200 --Out of 255

    local _r = math.floor(brightness * (1 - 2*math.abs(0.5 - hpPerc)))
    local _g = math.floor(brightness * (1 - 2*math.abs(0.5 - hpPerc)))

    if hpPerc <= .5 then
        _r = brightness
    end

    if hpPerc >= .5 then
        _g = brightness
    end

    return _r*0x1000000 + _g*0x10000 + 0xFF

end

function DoesHeroHasStashItems(ent)
    for i=7,12 do
        if ent:GetItem(i) then
            return true
        end
    end
    return false
end

function AdvancedMonitorTick( tick )

    enemies = entityList:FindEntities({ illusion = false}) 
    for k,v in pairs(enemies) do
        if not v.illusion and (v.hero or v.meepo) and v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 then
            if not advancedMonitor[v.handle] then
                advancedMonitor[v.handle] = {}
            end
        

            if not advancedMonitor[v.handle].data then
                advancedMonitor[v.handle].data = {}
            end

            if v.visible or not advancedMonitor[v.handle].data.health then
                advancedMonitor[v.handle].data.health = v.health
                advancedMonitor[v.handle].data.maxHealth = v.maxHealth
                advancedMonitor[v.handle].data.healthRegen = v.healthRegen
                advancedMonitor[v.handle].data.mana = v.mana
                advancedMonitor[v.handle].data.maxMana = v.maxMana
                advancedMonitor[v.handle].data.manaRegen = v.manaRegen
                advancedMonitor[v.handle].data.lvl = v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel")
                advancedMonitor[v.handle].data.dmgBonus = v.dmgBonus
                advancedMonitor[v.handle].data.dmgMin = v.dmgMin
                advancedMonitor[v.handle].data.dmgMax = v.dmgMax
                advancedMonitor[v.handle].data.moveSpeed = v.movespeed or 300
                advancedMonitor[v.handle].data.bonusArmor = v.bonusArmor
                advancedMonitor[v.handle].data.totalArmor = v.totalArmor
                advancedMonitor[v.handle].data.magicDmgResist = v.magicDmgResist
                advancedMonitor[v.handle].data.attackSpeed = v.attackSpeed
                advancedMonitor[v.handle].data.strength = v.strength
                advancedMonitor[v.handle].data.strengthTotal = v.strengthTotal
                advancedMonitor[v.handle].data.agility = v.agility
                advancedMonitor[v.handle].data.agilityTotal = v.agilityTotal
                advancedMonitor[v.handle].data.intellect = v.intellect
                advancedMonitor[v.handle].data.intellectTotal = v.intellectTotal
            end
        end
    end

    if adVisible then
        local STARTXY = Vector2D(5,screenSize.y-425-location.sideview.b)
        local dirty = false
        enemies = entityList:FindEntities({ illusion = false}) 

        local i = 1

        for k,v in ipairs(enemies) do
            if not v.illusion and (v.hero or v.meepo) and v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 then
                if not advancedMonitor[v.handle] then
                    advancedMonitor[v.handle] = {}
                end

                local topLeft = STARTXY + Vector2D(0,itemSize.y + gapSize.y + extraGap.y) * (i - 1) * 2

                if not advancedMonitor[v.handle].bg then
                    advancedMonitor[v.handle].bg = drawMgr:CreateRect(topLeft.x-1,topLeft.y-5,348,76,0x000000D0)
                    advancedMonitor[v.handle].bg3 = drawMgr:CreateRect(topLeft.x-1,topLeft.y-5,348,77,0x000000FF,true)
                    advancedMonitor[v.handle].bg2 = drawMgr:CreateRect(topLeft.x + itemSize.x*itemPercent + extraGap.x,topLeft.y+itemSize.y + gapSize.y,itemSize.x*itemPercent*6 + gapSize.x*5,itemSize.y,0x000000D0)
                end

                if not advancedMonitor[v.handle].portrait then

                    --Portrait
                    advancedMonitor[v.handle].portrait = drawMgr:CreateRect(topLeft.x + 3,topLeft.y,itemSize.x,itemSize.y*2 + gapSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/heroes_vertical/"..v.name))
                    advancedMonitor[v.handle].portrait.visible = true

                    --HP
                    local hpPerc = advancedMonitor[v.handle].data.health/advancedMonitor[v.handle].data.maxHealth
                    local hpColor = ColorTransfusionHealth(hpPerc)
                    local hpX = topLeft.x + 83 - advFont:GetTextSize(tostring(advancedMonitor[v.handle].data.health).."/"..tostring(advancedMonitor[v.handle].data.maxHealth)).x
                    advancedMonitor[v.handle].hp = drawMgr:CreateText(hpX,topLeft.y-5,hpColor,tostring(advancedMonitor[v.handle].data.health).."/"..tostring(advancedMonitor[v.handle].data.maxHealth),advFont)
                    advancedMonitor[v.handle].hpBG = drawMgr:CreateRect(topLeft.x + 85,topLeft.y-3,100,8,0x80808080)
                    advancedMonitor[v.handle].hpBar = drawMgr:CreateRect(topLeft.x + 85,topLeft.y-3,100*hpPerc,8,hpColor)
                    advancedMonitor[v.handle].hpOut = drawMgr:CreateRect(topLeft.x + 85,topLeft.y-3,100,8,hpColor,true)
                    advancedMonitor[v.handle].hpReg = drawMgr:CreateText(topLeft.x + 85,topLeft.y-5,0xFFFFFF80,advancedMonitor[v.handle].data.health == advancedMonitor[v.handle].data.maxHealth and "" or advancedMonitor[v.handle].data.healthRegen > 0 and "+"..tostring(math.floor(advancedMonitor[v.handle].data.healthRegen)) or tostring(math.floor(advancedMonitor[v.handle].data.healthRegen)),advFont)

                    --Mana
                    local mpX = topLeft.x + 83 - advFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.mana)).."/"..tostring(math.floor(advancedMonitor[v.handle].data.maxMana))).x
                    advancedMonitor[v.handle].mana = drawMgr:CreateText(mpX,topLeft.y+5,0x2570D6FF,tostring(math.floor(advancedMonitor[v.handle].data.mana)).."/"..tostring(math.floor(advancedMonitor[v.handle].data.maxMana)),advFont)
                    advancedMonitor[v.handle].manaBG = drawMgr:CreateRect(topLeft.x + 85,topLeft.y+7,100,8,0x80808080)
                    advancedMonitor[v.handle].manaBar = drawMgr:CreateRect(topLeft.x + 85,topLeft.y+7,100*advancedMonitor[v.handle].data.mana/advancedMonitor[v.handle].data.maxMana,8,0x2570D6FF)
                    advancedMonitor[v.handle].manaOut = drawMgr:CreateRect(topLeft.x + 85,topLeft.y+7,100,8,0x2570D6FF,true)
                    advancedMonitor[v.handle].manaReg = drawMgr:CreateText(topLeft.x + 85 ,topLeft.y+5,0xFFFFFF80,advancedMonitor[v.handle].data.mana == advancedMonitor[v.handle].data.maxMana and "" or advancedMonitor[v.handle].data.manaRegen > 0 and "+"..tostring(math.floor(advancedMonitor[v.handle].data.manaRegen)) or tostring(math.floor(advancedMonitor[v.handle].data.manaRegen)),advFont)

                    --Level
                    advancedMonitor[v.handle].lvl = drawMgr:CreateText(topLeft.x + 5,topLeft.y + itemSize.y*2 + gapSize.y + 1,0xFFFFFFFF,"L:   "..advancedMonitor[v.handle].data.lvl,advFont)

                    --Attack
                    local attackColor = advancedMonitor[v.handle].data.dmgBonus > 0 and 0x00FF00FF or advancedMonitor[v.handle].data.dmgBonus < 0 and 0xFF0000FF or 0xFFFFFFFF
                    advancedMonitor[v.handle].attackIcon = drawMgr:CreateRect(topLeft.x,2 + topLeft.y + itemSize.y*2 + gapSize.y + 10,36,11,0x000000FF,drawMgr:GetTextureId("AIOGUI/DamageSword"))
                    advancedMonitor[v.handle].attack = drawMgr:CreateText(topLeft.x + 12,2 +topLeft.y + itemSize.y*2 + gapSize.y+10,attackColor,tostring(math.floor(((advancedMonitor[v.handle].data.dmgMin+advancedMonitor[v.handle].data.dmgMax)/2)+advancedMonitor[v.handle].data.dmgBonus)),advFont)

                    --MoveSpeed
                    advancedMonitor[v.handle].moveIcon = drawMgr:CreateRect(topLeft.x + 38,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x000000FF,drawMgr:GetTextureId("AIOGUI/MSBoots"))
                    advancedMonitor[v.handle].moveFade = drawMgr:CreateRect(topLeft.x + 38,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    advancedMonitor[v.handle].move = drawMgr:CreateText(topLeft.x + 38 ,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,tostring(math.floor(advancedMonitor[v.handle].data.moveSpeed)),defaultFont)

                    --Armor
                    advancedMonitor[v.handle].armorIcon = drawMgr:CreateRect(topLeft.x + 59,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,0x000000FF,drawMgr:GetTextureId("AIOGUI/ArmorShield"))
                    advancedMonitor[v.handle].armorFade = drawMgr:CreateRect(topLeft.x + 59,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,0x00000080)
                    local armorColor = advancedMonitor[v.handle].data.bonusArmor  > 0 and 0x00FF00FF or advancedMonitor[v.handle].data.bonusArmor  < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local e_gap = tostring(v.totalArmor):len() == 1 and 4 or 0
                    advancedMonitor[v.handle].armor = drawMgr:CreateText(topLeft.x + 60 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,armorColor,tostring(advancedMonitor[v.handle].data.totalArmor),defaultFont)

                    --Magic Resist
                    advancedMonitor[v.handle].magResIcon = drawMgr:CreateRect(topLeft.x + 79,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,0x000000FF,drawMgr:GetTextureId("AIOGUI/MagicShield"))
                    advancedMonitor[v.handle].magResFade = drawMgr:CreateRect(topLeft.x + 79,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,0x00000080)
                    local baseRes = nil
                    if v.name == "Meepo" then
                        baseRes = .35
                    elseif v.name == "Visage" then
                        baseRes = .10
                    else
                        baseRes = .25
                    end
                    local magResistColor = math.floor(advancedMonitor[v.handle].data.magicDmgResist*10000) > baseRes*10000 and 0x00FF00FF or math.floor(advancedMonitor[v.handle].data.magicDmgResist*10000) < baseRes*10000 and 0xFF0000FF or 0xFFFFFFFF
                    advancedMonitor[v.handle].magRes = drawMgr:CreateText(topLeft.x + 78 ,topLeft.y + itemSize.y*2 + gapSize.y+12,magResistColor,v.magicDmgResist >= 0 and "."..tostring(math.floor(v.magicDmgResist*100)) or "-."..tostring(math.abs(math.floor(v.magicDmgResist*100))),defaultFont)

                    --Increased Attack Speed
                    advancedMonitor[v.handle].iasIcon = drawMgr:CreateRect(topLeft.x + 98,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/abaddon_frostmourne"))
                    advancedMonitor[v.handle].iasFade = drawMgr:CreateRect(topLeft.x + 98,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    advancedMonitor[v.handle].ias = drawMgr:CreateText(topLeft.x + 98 ,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,tostring(math.floor(advancedMonitor[v.handle].data.attackSpeed)),defaultFont)

                    --Strength
                    advancedMonitor[v.handle].strIcon = drawMgr:CreateRect(topLeft.x + 118,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x000000FF,drawMgr:GetTextureId("AIOGUI/StrIcon"))
                    advancedMonitor[v.handle].strFade = drawMgr:CreateRect(topLeft.x + 118,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    local strColor = (advancedMonitor[v.handle].data.strengthTotal - advancedMonitor[v.handle].data.strength)  > 0 and 0x00FF00FF or (advancedMonitor[v.handle].data.strengthTotal - advancedMonitor[v.handle].data.strength) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local strX = topLeft.x + 127 - defaultFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.strengthTotal))).x / 2
                    advancedMonitor[v.handle].str = drawMgr:CreateText(strX,topLeft.y + itemSize.y*2 + gapSize.y+12,strColor,tostring(math.floor(advancedMonitor[v.handle].data.strengthTotal)),defaultFont)

                    --Agility
                    advancedMonitor[v.handle].agiIcon = drawMgr:CreateRect(topLeft.x + 138,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x000000FF,drawMgr:GetTextureId("AIOGUI/AgiIcon"))
                    advancedMonitor[v.handle].agiFade = drawMgr:CreateRect(topLeft.x + 138,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    local agiColor = (advancedMonitor[v.handle].data.agilityTotal - advancedMonitor[v.handle].data.agility)  > 0 and 0x00FF00FF or (advancedMonitor[v.handle].data.agilityTotal - advancedMonitor[v.handle].data.agility) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local agiX = topLeft.x + 147 - defaultFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.agilityTotal))).x / 2
                    advancedMonitor[v.handle].agi = drawMgr:CreateText(agiX,topLeft.y + itemSize.y*2 + gapSize.y+12,agiColor,tostring(math.floor(advancedMonitor[v.handle].data.agilityTotal)),defaultFont)

                    --Intelligence
                    advancedMonitor[v.handle].intIcon = drawMgr:CreateRect(topLeft.x + 158,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x000000FF,drawMgr:GetTextureId("AIOGUI/IntIcon"))
                    advancedMonitor[v.handle].intFade = drawMgr:CreateRect(topLeft.x + 158,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    local intColor = (advancedMonitor[v.handle].data.intellectTotal - advancedMonitor[v.handle].data.intellect)  > 0 and 0x00FF00FF or (advancedMonitor[v.handle].data.intellectTotal - advancedMonitor[v.handle].data.intellect) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local intX = topLeft.x + 167 - defaultFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.intellectTotal))).x / 2
                    advancedMonitor[v.handle].int = drawMgr:CreateText(intX,topLeft.y + itemSize.y*2 + gapSize.y+12,intColor,tostring(math.floor(advancedMonitor[v.handle].data.intellectTotal)),defaultFont)

                    --Visiblity
                    if missingMonitor.side.heroes[v.handle] and missingMonitor.side.heroes[v.handle].missTime then
                        if missingMonitor.side.heroes[v.handle].missTime.color == 0xFFFFFFFF then
                            advancedMonitor[v.handle].lastSeen = drawMgr:CreateText(topLeft.x + 196 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,"Last Seen:"..missingMonitor.side.heroes[v.handle].missTime.text:gsub("Missing:",""),defaultFont)                   
                        else
                            advancedMonitor[v.handle].lastSeen = drawMgr:CreateText(topLeft.x + 196 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,"Last Seen: Now",defaultFont)
                        end
                        advancedMonitor[v.handle].eta = drawMgr:CreateText(topLeft.x + 196 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+24,missingMonitor.side.heroes[v.handle].etaTime.color,"ETA: ",defaultFont)
                    end
                else
                    if advancedMonitor[v.handle].lvl.text ~= "L:   "..v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel") then
                        advancedMonitor[v.handle].lvl.text = ("L:   "..v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel"))
                    end
                    local hpPerc = advancedMonitor[v.handle].data.health/advancedMonitor[v.handle].data.maxHealth
                    local hpColor = ColorTransfusionHealth(hpPerc)
                    if advancedMonitor[v.handle].hp.color ~= hpColor then
                        advancedMonitor[v.handle].hp.color = hpColor
                        advancedMonitor[v.handle].hpBar.color = hpColor
                        advancedMonitor[v.handle].hpOut.color = hpColor
                    end
                    if advancedMonitor[v.handle].hp.text ~= tostring(advancedMonitor[v.handle].data.health).."/"..tostring(advancedMonitor[v.handle].data.maxHealth) then
                        advancedMonitor[v.handle].hp.text = (tostring(advancedMonitor[v.handle].data.health).."/"..tostring(advancedMonitor[v.handle].data.maxHealth))
                        advancedMonitor[v.handle].hpBar.w = math.floor(100*advancedMonitor[v.handle].data.health/advancedMonitor[v.handle].data.maxHealth)
                    end
                    if advancedMonitor[v.handle].hpReg.text ~= advancedMonitor[v.handle].data.health == advancedMonitor[v.handle].data.maxHealth and "" or advancedMonitor[v.handle].data.healthRegen > 0 and "+"..tostring(math.floor(advancedMonitor[v.handle].data.healthRegen)) or tostring(math.floor(advancedMonitor[v.handle].data.healthRegen)) then
                        advancedMonitor[v.handle].hpReg.text = (advancedMonitor[v.handle].data.health == advancedMonitor[v.handle].data.maxHealth and "" or advancedMonitor[v.handle].data.healthRegen > 0 and "+"..tostring(math.floor(advancedMonitor[v.handle].data.healthRegen)) or tostring(math.floor(advancedMonitor[v.handle].data.healthRegen)))
                    end
                    if advancedMonitor[v.handle].mana.text ~= tostring(math.floor(advancedMonitor[v.handle].data.mana)).."/"..tostring(math.floor(advancedMonitor[v.handle].data.maxMana)) then
                        advancedMonitor[v.handle].mana.text = (tostring(math.floor(advancedMonitor[v.handle].data.mana)).."/"..tostring(math.floor(advancedMonitor[v.handle].data.maxMana)))
                        advancedMonitor[v.handle].manaBar.w = math.floor(100*advancedMonitor[v.handle].data.mana/advancedMonitor[v.handle].data.maxMana)
                    end
                    if advancedMonitor[v.handle].manaReg.text ~= advancedMonitor[v.handle].data.mana == advancedMonitor[v.handle].data.maxMana and "" or advancedMonitor[v.handle].data.manaRegen > 0 and "+"..tostring(math.floor(advancedMonitor[v.handle].data.manaRegen)) or tostring(math.floor(advancedMonitor[v.handle].data.manaRegen)) then
                        advancedMonitor[v.handle].manaReg.text = (advancedMonitor[v.handle].data.mana == advancedMonitor[v.handle].data.maxMana and "" or advancedMonitor[v.handle].data.manaRegen > 0 and "+"..tostring(math.floor(advancedMonitor[v.handle].data.manaRegen)) or tostring(math.floor(advancedMonitor[v.handle].data.manaRegen)))
                    end

                    local attackColor = advancedMonitor[v.handle].data.dmgBonus > 0 and 0x00FF00FF or advancedMonitor[v.handle].data.dmgBonus < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].attack.color ~= attackColor then
                        advancedMonitor[v.handle].attack.color = attackColor
                    end
                    if advancedMonitor[v.handle].attack.text ~= tostring(math.floor(((advancedMonitor[v.handle].data.dmgMin+advancedMonitor[v.handle].data.dmgMax)/2)+advancedMonitor[v.handle].data.dmgBonus)) then
                        advancedMonitor[v.handle].attack.text = (tostring(math.floor(((advancedMonitor[v.handle].data.dmgMin+advancedMonitor[v.handle].data.dmgMax)/2)+advancedMonitor[v.handle].data.dmgBonus)))
                    end
                    if advancedMonitor[v.handle].move.text ~= tostring(math.floor(advancedMonitor[v.handle].data.moveSpeed)) then
                        advancedMonitor[v.handle].move.text = (tostring(math.floor(advancedMonitor[v.handle].data.moveSpeed)))
                    end
                    local armorColor = advancedMonitor[v.handle].data.bonusArmor  > 0 and 0x00FF00FF or advancedMonitor[v.handle].data.bonusArmor  < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].armor.color ~= armorColor then
                        advancedMonitor[v.handle].armor.color = armorColor
                    end
                    if advancedMonitor[v.handle].armor.text ~= tostring(advancedMonitor[v.handle].data.totalArmor) then
                        advancedMonitor[v.handle].armor.x  = advancedMonitor[v.handle].armor.x - 4*(tostring(advancedMonitor[v.handle].data.totalArmor):len() - advancedMonitor[v.handle].armor.text:len())
                        advancedMonitor[v.handle].armor.text = (tostring(advancedMonitor[v.handle].data.totalArmor))
                    end
                    local baseRes = nil
                    if v.name == "Meepo" then
                        baseRes = .35
                    elseif v.name == "Visage" then
                        baseRes = .10
                    else
                        baseRes = .25
                    end
                    local magResistColor = math.floor(advancedMonitor[v.handle].data.magicDmgResist*10000) > baseRes*10000 and 0x00FF00FF or math.floor(advancedMonitor[v.handle].data.magicDmgResist*10000) < baseRes*10000 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].magRes.color ~= magResistColor then
                        advancedMonitor[v.handle].magRes.color = magResistColor
                    end
                    if advancedMonitor[v.handle].magRes.text ~= (advancedMonitor[v.handle].data.magicDmgResist >= 0 and "."..tostring(math.floor(advancedMonitor[v.handle].data.magicDmgResist*100)) or "-."..tostring(math.abs(math.floor(advancedMonitor[v.handle].data.magicDmgResist*100)))) then
                        advancedMonitor[v.handle].magRes.text = (advancedMonitor[v.handle].data.magicDmgResist >= 0 and "."..tostring(math.floor(advancedMonitor[v.handle].data.magicDmgResist*100)) or "-."..tostring(math.abs(math.floor(advancedMonitor[v.handle].data.magicDmgResist*100))))
                    end
                    if advancedMonitor[v.handle].ias.text ~= tostring(math.floor(advancedMonitor[v.handle].data.attackSpeed)) then
                        advancedMonitor[v.handle].ias.text = (tostring(math.floor(advancedMonitor[v.handle].data.attackSpeed)))
                    end
                    local strColor = (advancedMonitor[v.handle].data.strengthTotal - advancedMonitor[v.handle].data.strength)  > 0 and 0x00FF00FF or (advancedMonitor[v.handle].data.strengthTotal - advancedMonitor[v.handle].data.strength) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local strX = topLeft.x + 127 - defaultFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.strengthTotal))).x / 2
                    if advancedMonitor[v.handle].str.color ~= strColor then
                        advancedMonitor[v.handle].str.color = strColor
                    end
                    if advancedMonitor[v.handle].str.x ~= strX then
                        advancedMonitor[v.handle].str.x = strX
                    end
                    if advancedMonitor[v.handle].str.text ~= tostring(math.floor(advancedMonitor[v.handle].data.strengthTotal)) then
                        advancedMonitor[v.handle].str.text = (tostring(math.floor(advancedMonitor[v.handle].data.strengthTotal)))
                    end
                    local agiColor = (advancedMonitor[v.handle].data.agilityTotal - advancedMonitor[v.handle].data.agility)  > 0 and 0x00FF00FF or (advancedMonitor[v.handle].data.agilityTotal - advancedMonitor[v.handle].data.agility) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local agiX = topLeft.x + 147 - defaultFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.agilityTotal))).x / 2
                    if advancedMonitor[v.handle].agi.color ~= agiColor then
                        advancedMonitor[v.handle].agi.color = agiColor
                    end
                    if advancedMonitor[v.handle].agi.x ~= agiX then
                        advancedMonitor[v.handle].agi.x = agiX
                    end
                    if advancedMonitor[v.handle].agi.text ~= tostring(math.floor(advancedMonitor[v.handle].data.agilityTotal)) then
                        advancedMonitor[v.handle].agi.text = (tostring(math.floor(advancedMonitor[v.handle].data.agilityTotal)))
                    end
                    local intColor = (advancedMonitor[v.handle].data.intellectTotal - advancedMonitor[v.handle].data.intellect)  > 0 and 0x00FF00FF or (advancedMonitor[v.handle].data.intellectTotal - advancedMonitor[v.handle].data.intellect) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local intX = topLeft.x + 167 - defaultFont:GetTextSize(tostring(math.floor(advancedMonitor[v.handle].data.intellectTotal))).x / 2
                    if advancedMonitor[v.handle].int.color ~= intColor then
                        advancedMonitor[v.handle].int.color = intColor
                    end
                    if advancedMonitor[v.handle].int.x ~= intX then
                        advancedMonitor[v.handle].int.x = intX
                    end
                    if advancedMonitor[v.handle].int.text ~= tostring(math.floor(advancedMonitor[v.handle].data.intellectTotal)) then
                        advancedMonitor[v.handle].int.text = (tostring(math.floor(advancedMonitor[v.handle].data.intellectTotal)))
                    end

                    if missingMonitor.side.heroes[v.handle] and missingMonitor.side.heroes[v.handle].missTime then
                        if advancedMonitor[v.handle].eta.color ~= missingMonitor.side.heroes[v.handle].etaTime.color then
                            advancedMonitor[v.handle].eta.color = missingMonitor.side.heroes[v.handle].etaTime.color
                        end
                        if missingMonitor.side.heroes[v.handle].etaTime.text ~= "   Careful" then
                            if advancedMonitor[v.handle].eta.text ~= missingMonitor.side.heroes[v.handle].etaTime.text then
                                advancedMonitor[v.handle].eta.text = (missingMonitor.side.heroes[v.handle].etaTime.text)
                            end
                        else
                            if advancedMonitor[v.handle].eta.text ~= "ETA: Now" then
                                advancedMonitor[v.handle].eta.text = ("ETA: Now")
                            end
                        end
                        if missingMonitor.side.heroes[v.handle].missTime.color == 0xFFFFFFFF then
                            if advancedMonitor[v.handle].lastSeen.text ~= "Last Seen:"..missingMonitor.side.heroes[v.handle].missTime.text:gsub("Missing:","") then
                                advancedMonitor[v.handle].lastSeen.text = ("Last Seen:"..missingMonitor.side.heroes[v.handle].missTime.text:gsub("Missing:",""))                   
                            end
                        else
                            if advancedMonitor[v.handle].lastSeen.text ~= "Last Seen: Now" then
                                advancedMonitor[v.handle].lastSeen.text = ("Last Seen: Now")
                            end
                        end
                    end
                end

                local spells = {}

                local spellPos = topLeft + Vector2D(200,0)

                for i=1,15 do
                    local ability = v:GetAbility(i)
                    if ability ~= nil then
                        if not ability.hidden and ability.name ~= "attribute_bonus" then
                            spells[#spells+1] = ability
                        end
                    end
                end

                local len = nil
                if #spells < 4 then
                    len = math.floor((wi - ga*4 + ga)/4)
                else
                    len = math.floor((wi - ga*#spells + ga)/#spells)
                end
                spellPos = Vector2D(spellPos.x,spellPos.y + 17 - len/2)
                local font = drawMgr:CreateFont("tFont","Arial",len == 21 and 10 or len == 26 and 12 or 14,500)
                local c_ga = font.tall == 10 and (len/2 - 6) or (len/2 - 9)

                if not advancedMonitor[v.handle].spells then
                    advancedMonitor[v.handle].spells = {}
                end

                for index,spell in ipairs(spells) do
                    local _font = drawMgr:CreateFont("cdFont","Arial",math.floor(tostring(math.ceil(spell.cd)):len() ~= 1 and font.tall*4/tostring(math.ceil(spell.cd)):len() or font.tall*2),500)
                    local gap = math.floor(wi*(index-1)/#spells)
                    if not advancedMonitor[v.handle].spells[index] or #spells ~= advancedMonitor[v.handle].spells.spellCount then
                        advancedMonitor[v.handle].spells[index] = {}
                        advancedMonitor[v.handle].spells.spellCount = #spells
                    end
                    if spell.name ~= advancedMonitor[v.handle].spells[index].name or spell.toggled ~= advancedMonitor[v.handle].spells[index].toggled then
                        if spell.name == "troll_warlord_berserkers_rage" and spell.toggled then
                            advancedMonitor[v.handle].spells[index].icon = drawMgr:CreateRect(spellPos.x + gap,spellPos.y,len,len,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/"..spell.name.."_active"))
                        else
                            advancedMonitor[v.handle].spells[index].icon = drawMgr:CreateRect(spellPos.x + gap,spellPos.y,len,len,0x000000FF,drawMgr:GetTextureId("NyanUI/spellicons/"..spell.name))
                        end
                        advancedMonitor[v.handle].spells[index].name = spell.name
                        advancedMonitor[v.handle].spells[index].toggle = spell.toggled
                        advancedMonitor[v.handle].spells[index].level = drawMgr:CreateText(spellPos.x + gap + c_ga,spellPos.y+len,0xFFFFFFFF,"L. "..spell.level,font)
                        advancedMonitor[v.handle].spells[index].border = drawMgr:CreateRect(spellPos.x + gap-1,spellPos.y-1,len+1,len+1,0x00000001,true)
                        advancedMonitor[v.handle].spells[index].effect = drawMgr:CreateRect(spellPos.x + gap,spellPos.y,len,len,0x00000001)
                        advancedMonitor[v.handle].spells[index].cd = drawMgr:CreateText(spellPos.x + wi*(index-1)/#spells+c_ga/2,spellPos.y+c_ga/2,0xFFFFFFFF,"",_font)
                        dirty = true
                    end
                    if spell.state == LuaEntityAbility.STATE_COOLDOWN then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x000000FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x000000FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x000000D0 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x000000D0
                        end
                        local size = _font:GetTextSize(tostring(math.ceil(spell.cd)))
                        local _pos = spellPos - (size / 2) + Vector2D(len,len)/2 + Vector2D(gap,0)
                        if advancedMonitor[v.handle].spells[index].cd.text ~= ""..math.ceil(spell.cd) then
                            advancedMonitor[v.handle].spells[index].cd.text = (""..math.ceil(spell.cd))
                            advancedMonitor[v.handle].spells[index].cd.x = _pos.x
                            advancedMonitor[v.handle].spells[index].cd.y = _pos.y
                        end
                    elseif spell.state == LuaEntityAbility.STATE_NOMANA then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x0000A0FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x0000A0FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x3030A0D0 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x3030A0D0
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd.text = ("")
                        end
                    elseif (spell.state == LuaEntityAbility.STATE_NOTLEARNED or spell.state == 84) and not spell.name:find("empty") then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x404040FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x404040FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x404040D0 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x404040D0
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd.text = ("")
                        end
                    elseif spell.state == LuaEntityAbility.STATE_READY then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x808080FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x808080FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x00000001 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x00000001
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd.text = ("")
                        end
                    elseif spell.state == 17 then --Passive Spells
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x000000FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x000000FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x00000001 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x00000001
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd.text = ("")
                        end
                    end
                end

                for i=#spells + 1,6 do
                    advancedMonitor[v.handle].spells[i] = nil
                    dirty = true
                end

                spells = nil

                --ItemShowing

                if not advancedMonitor[v.handle].items then
                    advancedMonitor[v.handle].items = {}
                end

                local stashState = DoesHeroHasStashItems(v)

                if not advancedMonitor[v.handle].stashText then
                    advancedMonitor[v.handle].stashBg = drawMgr:CreateRect(topLeft.x + 350 ,topLeft.y-4,60,75,0x000000D0)
                    advancedMonitor[v.handle].stashText = drawMgr:CreateText(topLeft.x + 360 ,topLeft.y-4,0xFFFFFFFF,"STASH",defaultFont)
                end

                if stashState then
                    if advancedMonitor[v.handle].stashBg.color ~= 0x000000D0 then
                        advancedMonitor[v.handle].stashBg.color = 0x000000D0
                    end
                    if advancedMonitor[v.handle].stashText.color ~= 0xFFFFFFFF then
                        advancedMonitor[v.handle].stashText.color = 0xFFFFFFFF
                    end
                else
                    if advancedMonitor[v.handle].stashBg.color ~= 0x00000001 then
                        advancedMonitor[v.handle].stashBg.color = 0x00000001
                    end
                    if advancedMonitor[v.handle].stashText.color ~= 0x00000001 then
                        advancedMonitor[v.handle].stashText.color = 0x00000001
                    end
                end


                for itemSlot = 1, 12 do
                    if not advancedMonitor[v.handle].items[itemSlot] then
                        advancedMonitor[v.handle].items[itemSlot] = {}
                    end

                    local itemXY = topLeft + Vector2D(extraGap.x,0)
                    local dx = itemSlot < 7 and itemSlot or itemSlot%2 + 14
                    local dy = itemSlot < 7 and 1 or math.floor((itemSlot - 7)/2) + 0.6
                    local itemXY = itemXY + Vector2D(itemSize.x*itemPercent + gapSize.x,0) * dx + Vector2D(0,itemSize.y + gapSize.y) * dy
                    local item = v:GetItem(itemSlot)

                    local hide = not stashState and itemSlot > 6

                    if item and item.name and not hide then
                        if item.name == "item_bottle" then
                            if item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 0 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_doubledamage" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_doubledamage"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_doubledamage"))
                                    dirty = true
                                end
                            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 2 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_illusion" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_illusion"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_illusion"))
                                    dirty = true
                                end
                            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 3 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_invisibility" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_invisibility"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_invisibility"))
                                    dirty = true
                                end
                            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 4 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_regeneration" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_regeneration"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_regeneration"))
                                    dirty = true
                                end
                            elseif item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") == 1 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_haste" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_haste"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_haste"))
                                    dirty = true
                                end
                            elseif item.charges == 3 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle"))
                                    dirty = true
                                end
                            elseif item.charges == 2 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_medium" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_medium"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_medium"))
                                    dirty = true
                                end
                            elseif item.charges == 1 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_small" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_small"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_small"))
                                    dirty = true
                                end
                            elseif item.charges == 0 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "bottle_empty" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "bottle_empty"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_empty"))
                                    dirty = true
                                end
                            end
                        elseif item.name == "item_power_treads" then
                            if item.bootsState == PT_AGI then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads_agi" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "power_treads_agi"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/power_treads_agi"))
                                    dirty = true
                                end
                            elseif item.bootsState == PT_INT then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads_int" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "power_treads_int"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/power_treads_int"))
                                    dirty = true
                                end
                            elseif item.bootsState == PT_STR then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads_str" then  
                                    advancedMonitor[v.handle].items[itemSlot].name = "power_treads_str"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/power_treads_str"))
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads" then  
                                advancedMonitor[v.handle].items[itemSlot].name = "power_treads"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/power_treads"))
                                dirty = true
                            end
                        elseif item.name == "item_armlet" then
                            if item.toggled then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "armlet_active" then 
                                    advancedMonitor[v.handle].items[itemSlot].name = "armlet_active"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/armlet_active"))
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "armlet" then    
                                advancedMonitor[v.handle].items[itemSlot].name = "armlet"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/armlet"))
                                dirty = true
                            end
                        elseif item.name == "item_radiance" then
                            if item.toggled then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "radiance_inactive" then 
                                    advancedMonitor[v.handle].items[itemSlot].name = "radiance_inactive"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/radiance_inactive"))
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "radiance" then  
                                advancedMonitor[v.handle].items[itemSlot].name = "radiance"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/radiance"))
                                dirty = true
                            end
                        elseif item.name == "item_tranquil_boots" then
                            if item.charges == 3 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "tranquil_boots_active" then 
                                    advancedMonitor[v.handle].items[itemSlot].name = "tranquil_boots_active"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/tranquil_boots_active"))
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "tranquil_boots" then    
                                advancedMonitor[v.handle].items[itemSlot].name = "tranquil_boots"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/tranquil_boots"))
                                dirty = true
                            end
                        elseif advancedMonitor[v.handle].items[itemSlot].name ~= item.name then
                            advancedMonitor[v.handle].items[itemSlot].name = item.name
                            advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/"..item.name:gsub("item_","")))
                            dirty = true
                        end
                        if item.initialCharges > 0 or not item.permanent or item.requiresCharges or item.bottle then
                            local tempCharges = (item.bottle and item:GetProperty("CDOTA_Item_EmptyBottle","m_iStoredRuneType") > 0) and 3 or item.charges
                            if dirty or advancedMonitor[v.handle].items[itemSlot].charges ~= tempCharges then
                                advancedMonitor[v.handle].items[itemSlot].charges = tempCharges
                                advancedMonitor[v.handle].items[itemSlot].chargeBG = drawMgr:CreateRect(itemXY.x + itemSize.x*itemPercent - itemChargeFont.tall,itemXY.y + itemSize.y - itemChargeFont.tall,itemChargeFont.tall,itemChargeFont.tall,0x000000D0)
                                advancedMonitor[v.handle].items[itemSlot].chargeText = drawMgr:CreateText(itemXY.x + itemSize.x*itemPercent - itemChargeFont.tall*7/10,itemXY.y + itemSize.y - itemChargeFont.tall,0xFFFFFFFF,tostring(tempCharges),itemChargeFont)
                            end
                        elseif advancedMonitor[v.handle].items[itemSlot].chargeBG then
                            advancedMonitor[v.handle].items[itemSlot].charges = nil
                            advancedMonitor[v.handle].items[itemSlot].chargeBG = nil
                            advancedMonitor[v.handle].items[itemSlot].chargeText = nil
                            dirty = true
                        end
                        if not advancedMonitor[v.handle].items[itemSlot].effect then
                            if item.state == LuaEntityAbility.STATE_NOMANA then
                                advancedMonitor[v.handle].items[itemSlot].effect = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x*itemPercent,itemSize.y,0x3030A0D0)
                            elseif item.state == LuaEntityAbility.STATE_ITEMCOOLDOWN then
                                advancedMonitor[v.handle].items[itemSlot].effect = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x*itemPercent,itemSize.y,0x000000D0)
                            else
                                advancedMonitor[v.handle].items[itemSlot].effect = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x*itemPercent,itemSize.y,0x00000001)
                            end
                        else
                            if item.state == LuaEntityAbility.STATE_NOMANA then
                                if advancedMonitor[v.handle].items[itemSlot].effect.color ~= 0x3030A0D0 then
                                    advancedMonitor[v.handle].items[itemSlot].effect.color = 0x3030A0D0
                                end
                            elseif item.state == LuaEntityAbility.STATE_ITEMCOOLDOWN then
                                if advancedMonitor[v.handle].items[itemSlot].effect.color ~= 0x000000D0 then
                                    advancedMonitor[v.handle].items[itemSlot].effect.color = 0x000000D0
                                end
                            else
                                if advancedMonitor[v.handle].items[itemSlot].effect.color ~= 0x00000001 then
                                    advancedMonitor[v.handle].items[itemSlot].effect.color = 0x00000001
                                end
                            end
                        end
                        if not advancedMonitor[v.handle].items[itemSlot].cd then
                            local _cd = math.ceil(item.cd)
                            local xGap = _cd > 99 and 3 or _cd > 9 and 5 or 9
                            _cd = _cd > 0 and tostring(_cd) or ""
                            local _x = itemXY.x + itemSize.x*itemPercent/2 - defaultFont:GetTextSize(_cd).x/2
                            advancedMonitor[v.handle].items[itemSlot].cd = _cd
                            advancedMonitor[v.handle].items[itemSlot].cdGap = xGap
                            advancedMonitor[v.handle].items[itemSlot].cdText = drawMgr:CreateText(_x,itemXY.y + 1,0xFFFFFFD0,_cd,defaultFont)
                        elseif math.ceil(item.cd) ~= advancedMonitor[v.handle].items[itemSlot].cd then
                            local _cd = math.ceil(item.cd)
                            local xGap = _cd > 99 and 3 or _cd > 9 and 5 or 9
                            _cd = _cd > 0 and tostring(_cd) or ""
                            local _x = itemXY.x + itemSize.x*itemPercent/2 - defaultFont:GetTextSize(_cd).x/2
                            advancedMonitor[v.handle].items[itemSlot].cdText.text = (tostring(_cd))
                            advancedMonitor[v.handle].items[itemSlot].cdText.x = _x
                            advancedMonitor[v.handle].items[itemSlot].cd = _cd
                            advancedMonitor[v.handle].items[itemSlot].cdGap = xGap
                        end
                    elseif not hide and advancedMonitor[v.handle].items[itemSlot].name ~= "empty" then
                        advancedMonitor[v.handle].items[itemSlot].charges = nil
                        advancedMonitor[v.handle].items[itemSlot].chargeBG = nil
                        advancedMonitor[v.handle].items[itemSlot].chargeText = nil
                        advancedMonitor[v.handle].items[itemSlot].name = "empty"
                        advancedMonitor[v.handle].items[itemSlot].icon = drawMgr:CreateRect(itemXY.x,itemXY.y,itemSize.x,itemSize.y,0x000000FF,drawMgr:GetTextureId("NyanUI/items/emptyitembg"))
                        dirty = true
                    end

                    item = nil

                    if hide then
                        advancedMonitor[v.handle].items[itemSlot] = nil
                        dirty = true
                    end
                end

                i = i + 1
            end
        end

        if advancedMonitor.count and i ~= advancedMonitor.count then
            advancedMonitor = {}
            dirty = true
        elseif not advancedMonitor.count then
            advancedMonitor.count = i
        end

        if dirty then
            collectgarbage("collect")
        end

    end

    SetVisibilityOfATable(advancedMonitor,ScriptConfig.advMon)
    adVisible = ScriptConfig.advMon
end

function MissingTick()
    --Missing heroes monitoring
    local dirty = false
    local heroes = entityList:FindEntities({type=LuaEntity.TYPE_HERO})
    for i,v in ipairs(heroes) do
        if not v.illusion and v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 then
            if missingMonitor.side.heroes[v.handle] == nil then
                heroCount = heroCount + 1
                missingMonitor.side.heroes[v.handle] = {}
                missingMonitor.side.heroes[v.handle].bmp = drawMgr:CreateRect(location.ssMonitor.x,location.ssMonitor.y+location.ssMonitor.h*(heroCount-1),32,32,0x000000FF,drawMgr:GetTextureId("NyanUI/miniheroes/"..v.name))
                missingMonitor.side.heroes[v.handle].missTime = drawMgr:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+location.ssMonitor.h*(heroCount-1),0x00000000,"Missing: ",mmFont)
                missingMonitor.side.heroes[v.handle].etaTime = drawMgr:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+mmFont.tall+location.ssMonitor.h*(heroCount-1),0x00000000,"ETA: ",mmFont)
                missingMonitor.side.heroes[v.handle].visibleText = drawMgr:CreateText(location.ssMonitor.x + 40,location.ssMonitor.y+mmFont.tall/2+2+location.ssMonitor.h*(heroCount-1),0xFFFFFFFF,"  Visible",mmFont)
                missingMonitor.side.heroes[v.handle].deadText = drawMgr:CreateText(location.ssMonitor.x + 40,location.ssMonitor.y+mmFont.tall/2+2+location.ssMonitor.h*(heroCount-1),0xFFFFFFFF,"   Dead",mmFont)
                missingMonitor.side.heroes[v.handle].miniBMP = nil
                missingMonitor.side.heroes[v.handle].mapText = {}
                missingMonitor.side.heroes[v.handle].mapText.top = nil
                missingMonitor.side.heroes[v.handle].mapText.bot = nil
            end
            if v.visible then
                if v:FindModifier("modifier_treant_natures_guise") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_rune_invis") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_weaver_shukuchi") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_phantom_lancer_doppelwalk_invis") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_item_invisibility_edge_windwalk") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_clinkz_wind_walk") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_bounty_hunter_wind_walk") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_nyx_assassin_vendetta") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_broodmother_spin_web_invisible_applier") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_lycan_summon_wolves_invisibility") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_sandking_sand_storm_invis") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_riki_permanent_invisibility") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_invisible") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_persistent_invisibility") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_mirana_moonlight_shadow") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_templar_assassin_meld") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_slark_shadow_dance") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_invoker_ghost_walk_self") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_item_shadow_amulet_fade") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:FindModifier("modifier_smoke_of_deceit") then
                    missingMonitor.side.heroes[v.handle].customText = "Smoked"
                else
                    missingMonitor.side.heroes[v.handle].customText = nil
                end
            end
            if lastseenList[v.handle] == nil and v.visible == false and v.respawnTime <= 0 then
                lastseenList[v.handle] = client.gameTime
                missingMonitor.side.heroes[v.handle].missTime.color = 0xFFFFFFFF
                missingMonitor.side.heroes[v.handle].etaTime.color = 0xFFFFFFFF
                missingMonitor.side.heroes[v.handle].visibleText.color = 0x00000000
                missingMonitor.side.heroes[v.handle].deadText.color = 0x00000000
            elseif v.visible == true or v.respawnTime > 0 then
                lastseenList[v.handle] = nil
                missingMonitor.side.heroes[v.handle].missTime.color = 0x00000000
                missingMonitor.side.heroes[v.handle].etaTime.color = 0x00000000
                if  v.respawnTime > 0 then
                    missingMonitor.side.heroes[v.handle].visibleText.color = 0x00000000
                    missingMonitor.side.heroes[v.handle].deadText.color = 0xFFFFFFFF
                else
                    missingMonitor.side.heroes[v.handle].visibleText.color = 0xFFFFFFFF
                    missingMonitor.side.heroes[v.handle].deadText.color = 0x00000000
                end
                if missingMonitor.side.heroes[v.handle].miniBMP then
                    missingMonitor.side.heroes[v.handle].miniBMP = nil
                    dirty = true
                end
                if missingMonitor.side.heroes[v.handle].mapText.top then
                   missingMonitor.side.heroes[v.handle].mapText.top = nil
                   missingMonitor.side.heroes[v.handle].mapText.bot = nil
                    missingMonitor.side.heroes[v.handle].mapText.eff = nil
                    dirty = true
                end
            end
            local vPos = v.health > 0 and v.position or entityList:FindEntities({classId = CDOTA_Unit_Fountain, team = v.team})[1].position
            if not v.visible and v.respawnTime <= 0 and not v.illusion then
                --Minimap Draw
                local coord = MapToMinimap(vPos)
                if not missingMonitor.side.heroes[v.handle].miniBMP then
                    missingMonitor.side.heroes[v.handle].miniBMP = drawMgr:CreateRect(coord.x-8,coord.y-8,16,16,0x000000FF,drawMgr:GetTextureId("NyanUI/miniheroes/"..v.name))
                end

                --Mainmap Draw
                local inscreen, pos = client:ScreenPosition(vPos)
                if pos and IsInScreen(pos) and v.alive then
                    if SleepCheck(v.handle.."ef") and ScriptConfig.missingMonitor then
                        local side = Vector(3*math.cos(v.rotR + math.pi/2),3*math.sin(v.rotR + math.pi/2),0)
                        local front = Vector(4*math.cos(v.rotR),4*math.sin(v.rotR),0)
                        missingMonitor.side.heroes[v.handle].mapText.eff = {
                            Effect(vPos+(side*6),"draw_commentator"),
                            Effect(vPos+(side*5)+(front),"draw_commentator"),
                            Effect(vPos+(side*4)+(front*2),"draw_commentator"),
                            Effect(vPos+(side*3)+(front*3),"draw_commentator"),
                            Effect(vPos+(side*2)+(front*4),"draw_commentator"),
                            Effect(vPos+(side)+(front*5),"draw_commentator"),
                            Effect(vPos+(front*6),"draw_commentator"),
                            Effect(vPos-(side*1)+(front*5),"draw_commentator"),
                            Effect(vPos-(side*2)+(front*4),"draw_commentator"),
                            Effect(vPos-(side*3)+(front*3),"draw_commentator"),
                            Effect(vPos-(side*4)+(front*2),"draw_commentator"),
                            Effect(vPos-(side*5)+(front),"draw_commentator"),
                            Effect(vPos-(side*6),"draw_commentator"),
                        }
                        for k,l in ipairs(missingMonitor.side.heroes[v.handle].mapText.eff) do
                            l:SetVector(1,Vector(255,255,255))
                        end
                        Sleep(500,v.handle.."ef")
                    dirty = true
                    end
                    if not ScriptConfig.missingMonitor then
                        missingMonitor.side.heroes[v.handle].mapText.eff = nil
                    dirty = true
                    end

                    if not missingMonitor.side.heroes[v.handle].mapText.top then
                        missingMonitor.side.heroes[v.handle].mapText.top = drawMgr:CreateText(math.floor(pos.x),math.floor(pos.y)-30,0xFFFFFFFF,v.name,defaultFont)
                        missingMonitor.side.heroes[v.handle].mapText.bot = drawMgr:CreateText(math.floor(pos.x),math.floor(pos.y)-15,0xFFFFFFFF,math.floor(100*v.health/v.maxHealth).."% HP",defaultFont)
                    elseif missingMonitor.side.heroes[v.handle].mapText.top.x ~= math.floor(pos.x) or missingMonitor.side.heroes[v.handle].mapText.top.y ~= math.floor(pos.y)-30 then
                        missingMonitor.side.heroes[v.handle].mapText.top.x = math.floor(pos.x)
                        missingMonitor.side.heroes[v.handle].mapText.top.y = math.floor(pos.y)-30
                        missingMonitor.side.heroes[v.handle].mapText.bot.x = math.floor(pos.x)
                        missingMonitor.side.heroes[v.handle].mapText.bot.y = math.floor(pos.y)-15
                    end
                elseif missingMonitor.side.heroes[v.handle].mapText.top then
                    missingMonitor.side.heroes[v.handle].mapText.top = nil
                    missingMonitor.side.heroes[v.handle].mapText.bot = nil
                    dirty = true
                end

                --Miss timer
                local delta = client.gameTime - lastseenList[v.handle]
                local minutes = math.floor(delta/60)
                local seconds = delta%60
                local ssText
                if missingMonitor.side.heroes[v.handle].customText then
                    if minutes > 0 then
                            ssText = string.format(missingMonitor.side.heroes[v.handle].customText..": "..minutes..":%02d",seconds)
                    else
                            ssText = string.format(missingMonitor.side.heroes[v.handle].customText..": %02d",seconds)
                    end
                else
                    if minutes > 0 then
                            ssText = string.format("Missing: "..minutes..":%02d",seconds)
                    else
                            ssText = string.format("Missing: %02d",seconds)
                    end
                end
                missingMonitor.side.heroes[v.handle].missTime.text = (ssText)

                --ETA timer
                local distance = GetDistance2D(vPos,entityList:GetMyHero())
                local proximity = distance/500 - delta
                local proxText
                if proximity > 0 then
                        local proxMin = math.floor(proximity/60)
                        local proxSec = proximity%60
                        if minutes > 0 then
                                proxText = string.format("ETA: "..proxMin..":%02d",proxSec)
                        else
                                proxText = string.format("ETA: %02d",proxSec)
                        end
                else
                        proxText = "   Careful"
                end
                missingMonitor.side.heroes[v.handle].etaTime.text = (proxText)
            end
        end
    end
    if dirty then
        collectgarbage("collect")
    end
end

function SideTick()
    local _x
    local _y
    local center = {x = screenSize.x/2 , y = screenSize.y/2}
    local dirty = false
    enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,alive=true})
    for i,v in ipairs(enemies) do
        local inscreen, pos = client:ScreenPosition(v.position)
        if pos and not v.illusion and v.visible and v.team ~= entityList:GetMyHero().team and v.team ~= 0 and v.team ~= 1 and v.team ~= 5 and pos:GetDistance2D(Vector2D(-640,-640)) > 0 then
            if pos.x < 0 or pos.x > screenSize.x  or pos.y < location.sideview.t or pos.y > screenSize.y - location.sideview.b then
                local slope = (pos.y - center.y) / (pos.x - center.x)
                if (pos.x - center.x < 0 and slope < (screenSize.y/2-location.sideview.t)/(screenSize.x/2) and slope > -(screenSize.y/2-location.sideview.b)/(screenSize.x/2)) or (pos.x - center.x >= 0 and slope > -(screenSize.y/2-location.sideview.t)/(screenSize.x/2) and slope < (screenSize.y/2-location.sideview.b)/(screenSize.x/2)) then
                    if pos.x < 0 then
                        _x = location.sideview.w
                        _y = math.floor(center.y + slope * (_x - center.x))
                    else
                        _x = screenSize.x - location.sideview.w
                        _y = math.floor(center.y + slope * (_x - center.x))
                    end
                else
                    if pos.y < location.sideview.t then
                        _y = location.sideview.t
                        _x = math.floor(center.x + (_y-center.y)/slope)
                    else
                        _y = screenSize.y - location.sideview.b
                        _x = math.floor(center.x + (_y-center.y)/slope)
                    end
                end
                if _x and _y then
                    if sideView[v.handle] then
                        sideView[v.handle] = MantainSideBox(v,_x,_y,sideView[v.handle])
                    else
                        sideView[v.handle] = CreateSideBox(v,_x,_y)
                        SetVisibilityOfATable(sideView[v.handle],ScriptConfig.sideView)
                    end
                elseif sideView[v.handle] then
                    if sideView[v.handle].border then
                        sideView[v.handle].border = nil
                        dirty = true
                    end
                    if sideView[v.handle].name then
                        sideView[v.handle].name = nil
                        dirty = true
                    end
                    if sideView[v.handle].hp then
                        sideView[v.handle].hp = nil
                        dirty = true
                    end
                    if sideView[v.handle].mana then
                        sideView[v.handle].mana = nil
                        dirty = true
                    end
                    if sideView[v.handle].distance then
                        sideView[v.handle].distance = nil
                        dirty = true
                    end
                end
            else
                if sideView[v.handle] then
                    if sideView[v.handle].border then
                        sideView[v.handle].border = nil
                        dirty = true
                    end
                    if sideView[v.handle].name then
                        sideView[v.handle].name = nil
                        dirty = true
                    end
                    if sideView[v.handle].hp then
                        sideView[v.handle].hp = nil
                        dirty = true
                    end
                    if sideView[v.handle].mana then
                        sideView[v.handle].mana = nil
                        dirty = true
                    end
                    if sideView[v.handle].distance then
                        sideView[v.handle].distance = nil
                        dirty = true
                    end
                    sideView[v.handle] = nil
                end
            end
        elseif sideView[v.handle] then
            if sideView[v.handle].border then
                sideView[v.handle].border = nil
                dirty = true
            end
            if sideView[v.handle].name then
                sideView[v.handle].name = nil
                dirty = true
            end
            if sideView[v.handle].hp then
                sideView[v.handle].hp = nil
                dirty = true
            end
            if sideView[v.handle].mana then
                sideView[v.handle].mana = nil
                dirty = true
            end
            if sideView[v.handle].distance then
                sideView[v.handle].distance = nil
                dirty = true
            end
        end
    end

    if dirty then
        collectgarbage("collect")
    end

end

function RoshanTick()
    --Roshan monitoring
    if deathTick and RoshAlive() then
            deathTick = nil
    end

    if deathTick then
        local bigRes = 660 - tickDelta
        local smlRes = 480 - tickDelta
        local minutes = math.floor(tickDelta/60)
        local seconds = tickDelta%60
        if smlRes > 0 then
            roshBox.text.text = (string.format("Roshan: %02d:%02d",10-minutes,59-seconds))
        else
            roshBox.text.text = (string.format("%02d:%02d - %02d:%02d",math.floor(smlRes/60),smlRes%60,math.floor(bigRes/60),bigRes%60))
        end
    elseif roshBox.text.text ~= "Roshan: Alive" then
        roshBox.text.text = ("Roshan: Alive")
    end
end

function RuneTick()
    --Rune monitoring
    local runes = entityList:FindEntities({classId=CDOTA_Item_Rune})
    if #runes == 0 then
            if minimapRune then
                minimapRune = nil
                collectgarbage("collect")
            end
            if runeBox.text.text ~= ("No Rune") then
                runeBox.bmp = drawMgr:CreateRect(location.rune.x,location.rune.y+1,28,14,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_empty"))
                runeBox.bmp.visible = ScriptConfig.runeBox
                runeBox.text.text = ("No Rune")
            end
            return 
    end
    if  runeBox.text.text ~= "No Rune" then
            return
    end
    local rune = runes[1]
    local runeType = rune.runeType
    filename = ""
    if runeType == 0 then
            runeMsg = "DD"
            filename = "doubledamage"
    elseif runeType == 2 then
            runeMsg = "Illu"
            filename = "illusion"
    elseif runeType == 3 then
            runeMsg = "Invis"
            filename = "invis"
    elseif runeType == 4 then
            runeMsg = "Reg"
            filename = "regen"
    elseif runeType == 1 then
            runeMsg = "Haste"
            filename = "haste"
    else
            runeMsg = "???"
    end
    if not minimapRune then
        if runeBox.text.text ~= runeMsg then
            local runeMinimap = MapToMinimap(rune)
            local size = 20
            minimapRune = drawMgr:CreateRect(runeMinimap.x-size/2,runeMinimap.y-size/2,size,size,0x000000FF,drawMgr:GetTextureId("/NyanUI/minirunes/"..filename))
            minimapRune.visible = ScriptConfig.runeBox
            if rune.position.x == -2272 then
                    runeMsg = runeMsg .. " TOP"
            else
                    runeMsg = runeMsg .. " BOT"
            end
            runeBox.text.text = (runeMsg)
            runeBox.bmp = drawMgr:CreateRect(location.rune.x,location.rune.y+1,16,16,0x000000FF,drawMgr:GetTextureId("/NyanUI/runes/"..filename))
            runeBox.bmp.visible = ScriptConfig.runeBox
        end
    end
end

function LastHitMonitorTick()
    if ScriptConfig.creeps then
        local units = entityList:FindEntities({})
        for i,v in ipairs(units) do
            if v.alive and v.visible and v.DamageTaken and (not v.creep or v.spawned) and (v.classId == CDOTA_BaseNPC_Creep or v.classId == CDOTA_BaseNPC_Creep_Lane or v.classId == CDOTA_BaseNPC_Creep_Neutral or v.classId == CDOTA_BaseNPC_Creep_Siege or v.classId == CDOTA_BaseNPC_Barracks or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Building) then
                local hpPos = v.position + Vector(0,0,150)
                local inscreen, pos = client:ScreenPosition(hpPos)
                if pos and IsInScreen(pos) then
                    --pos = pos - Vector2D(0,9)
                    local textSize = lhFont:GetTextSize("[ "..tostring(v.health).." ]")
                    local relPos = pos - Vector2D(textSize.x/2,textSize.y/2)
                    local damageMin, damageMax = GetDamageToCreep(v)
                    local denyRatio = (v.classId == CDOTA_BaseNPC_Barracks or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Building) and .1 or .5
                    if (v.health < damageMin * 2 and v.team ~= entityList:GetMyHero().team)  or (v.health < v.maxHealth * denyRatio and v.team == entityList:GetMyHero().team) then
                        color = v.health < damageMin and 0xFF0000FF or v.health < damageMax and 0xD2691EFF or v.health < damageMin*2 and 0xFFFF00FF or 0xFFFFFFFF
                        if not creeps[v.handle] then
                            creeps[v.handle] = drawMgr:CreateText(relPos.x,relPos.y,color,"[ "..tostring(v.health).." ]",lhFont)
                        else
                            creeps[v.handle].x = relPos.x
                            creeps[v.handle].y = relPos.y
                            creeps[v.handle].color = color
                            creeps[v.handle].text = "[ "..tostring(v.health).." ]"
                        end
                    end
                end
            end
        end
    end
end

function GetDamageToCreep(v)
    local damageMin = entityList:GetMyHero().dmgMin + entityList:GetMyHero().dmgBonus
    local damageMax = entityList:GetMyHero().dmgMax + entityList:GetMyHero().dmgBonus
    local qb = entityList:GetMyHero():FindItem("item_quelling_blade")
    if v.team ~= entityList:GetMyHero().team and not (v.classId == CDOTA_BaseNPC_Creep_Siege or v.classId == CDOTA_BaseNPC_Barracks or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Building) then
        if qb then
            if entityList:GetMyHero().attackType == LuaEntityNPC.ATTACK_MELEE then
                damageMin = damageMin + damageMin * qb:GetSpecialData("damage_bonus")/100
                damageMax = damageMax + damageMax * qb:GetSpecialData("damage_bonus")/100
            elseif entityList:GetMyHero().attackType == LuaEntityNPC.ATTACK_RANGED then
                damageMin = damageMin + damageMin * qb:GetSpecialData("damage_bonus_ranged")/100
                damageMax = damageMax + damageMax * qb:GetSpecialData("damage_bonus_ranged")/100
            end
        end
    end
    if v.classId == CDOTA_BaseNPC_Creep_Siege or v.classId == CDOTA_BaseNPC_Barracks or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Building then
        damageMin = damageMin / 2
        damageMax = damageMax / 2
    end
    return v:DamageTaken(damageMin,DAMAGE_PHYS,entityList:GetMyHero()), v:DamageTaken(damageMax,DAMAGE_PHYS,entityList:GetMyHero())
end

--Function returns if two tables are same
function CompareTables(t1,t2)
    if #t1 ~= #t2 then return false end
    for i,v in ipairs(t1) do
        if t2[i] ~= v then
            return false
        end
    end
    return true
end

--Function returns x,y coordinates of a point's minimap equilavent
function MapToMinimap(x, y)
        if y == nil then
            if x.x then
                _x = x.x - MapLeft
                _y = x.y - MapBottom
            elseif x.pos then
                _x = x.position.x - MapLeft
                _y = x.position.y - MapBottom
            else
                return {x = -640, y = -640}
            end
        else
                _x = x - MapLeft
                _y = y - MapBottom
        end
        
        local scaledX = math.min(math.max(_x * MinimapMapScaleX, 0), location.minimap.w)
        local scaledY = math.min(math.max(_y * MinimapMapScaleY, 0), location.minimap.h)
        
        local screenX = location.minimap.px + scaledX
        local screenY = screenSize.y - scaledY - location.minimap.py
        
        return Vector2D(math.floor(screenX),math.floor(screenY))
end

--Function returns whether roshan is alive or not
function RoshAlive()
        local entities = entityList:FindEntities({classId=CDOTA_Unit_Roshan})
        tickDelta = client.gameTime-deathTick
        if #entities > 0 and tickDelta > 60 then
                local rosh = entities[1]
                if rosh and rosh.alive then
                        return true
                end
        end
        return false
end

function SetVisibilityOfATable(ta,b)
    for k,v in pairs(ta) do
        if type(v) == "table" then
            SetVisibilityOfATable(v,b)
        elseif type(v) == "userdata" and v.visible ~= nil then
            v.visible = b
        end
    end
end


function DeInit()
    if init then
        ScriptConfig:SetVisible(false)

        deathTick = nil

        roshBox = {}

        runeBox = {}

        cours = {}

        creeps = {}

        advancedMonitor = {}

        init = false

        minimapRune = nil

        runeMsg = nil

        heroCount = 0

        missingMonitor = {}

        sideView = {}

        collectgarbage("collect")

        init = false
    end
end

function DrawInit()
    if not init then
        ScriptConfig:SetVisible(true)

        advancedMonitor = {}

        cours = {}

        creeps = {}

        roshBox = {}
        roshBox.inside = drawMgr:CreateRect(location.rosh.x,location.rosh.y,95,18,0x000000FF)
        roshBox.inBorder = drawMgr:CreateRect(location.rosh.x-1,location.rosh.y-1,97,20,0x000000A0,true)
        roshBox.outBorder = drawMgr:CreateRect(location.rosh.x-2,location.rosh.y-2,99,22,0x00000050,true)
        roshBox.bmp = drawMgr:CreateRect(location.rosh.x,location.rosh.y,16,16,0x000000FF,drawMgr:GetTextureId("NyanUI/miniheroes/roshan"))
        roshBox.text = drawMgr:CreateText(location.rosh.x+20,location.rosh.y+3,0xFFFFFFFF,"Roshan: Alive",defaultFont)

        runeBox = {}
        runeBox.inside = drawMgr:CreateRect(location.rune.x,location.rune.y,95,18,0x000000FF)
        runeBox.inBorder = drawMgr:CreateRect(location.rune.x-1,location.rune.y-1,97,20,0x000000A0,true)
        runeBox.outBorder = drawMgr:CreateRect(location.rune.x-2,location.rune.y-2,99,22,0x00000050,true)
        runeBox.bmp = drawMgr:CreateRect(location.rune.x,location.rune.y+1,28,14,0x000000FF,drawMgr:GetTextureId("NyanUI/items/bottle_empty"))
        runeBox.text = drawMgr:CreateText(location.rune.x+20,location.rune.y+3,0xFFFFFFFF,"No Rune",defaultFont)

        minimapRune = nil

        missingMonitor = {}
        missingMonitor.miniMap = {}
        missingMonitor.side = {}

        missingMonitor.side.inside = drawMgr:CreateRect(location.ssMonitor.x,location.ssMonitor.y,location.ssMonitor.w,5*location.ssMonitor.h,0x000000FF)
        missingMonitor.side.inBorder = drawMgr:CreateRect(location.ssMonitor.x-1,location.ssMonitor.y-1,location.ssMonitor.w+2,5*location.ssMonitor.h+2,0x000000A0,true)
        missingMonitor.side.outBorder = drawMgr:CreateRect(location.ssMonitor.x-2,location.ssMonitor.y-2,location.ssMonitor.w+4,5*location.ssMonitor.h+4,0x00000050,true)
        missingMonitor.side.heroes = {}

        sideView = {}

        init = true
    end
end

function CleanUp()
    local dirty = false
    if missingMonitor and missingMonitor.miniMap then
        for k,v in pairs(missingMonitor.miniMap) do
            if type(k) == "number" then
                if not entityList:GetEntity(k) then
                    missingMonitor.miniMap[k] = nil
                    dirty = true
                end
            end
        end
    end
    if missingMonitor and missingMonitor.side and missingMonitor.side.heroes then
        for k,v in pairs(missingMonitor.side.heroes) do
            if type(k) == "number" then
                if not entityList:GetEntity(k) then
                    missingMonitor.side.heroes[k] = nil
                    dirty = true
                end
            end
        end
    end
    if sideview then
        for k,v in pairs(sideView) do
            if type(k) == "number" then
                if not entityList:GetEntity(k) then
                    sideView[k] = nil
                    dirty = true
                end
            end
        end
    end
    if advancedMonitor then
        for k,v in pairs(advancedMonitor) do
            if type(k) == "number" then
                if not entityList:GetEntity(k) then
                    advancedMonitor[k] = nil
                    dirty = true
                end
            end
        end
    end
    if cours then
        for k,v in pairs(cours) do
            if type(k) == "number" then
                if not entityList:GetEntity(k) then
                    cours[k] = nil
                    dirty = true
                end
            end
        end
    end
    if creeps then
        for k,v in pairs(creeps) do
            if type(k) == "number" then
                if not entityList:GetEntity(k) then
                    creeps[k] = nil
                    dirty = true
                else
                    local creep = entityList:GetEntity(k)
                    local is, pos = client:ScreenPosition(creep.position)
                    local damage = creep:DamageTaken(GetDamageToCreep(creep),DAMAGE_PHYS,entityList:GetMyHero())
                    local denyRatio = (creep.classId == CDOTA_BaseNPC_Barracks or creep.classId == CDOTA_BaseNPC_Tower or creep.classId == CDOTA_BaseNPC_Building) and .1 or .5
                    if not creep.alive or not creep.visible or not IsInScreen(pos) or not damage then
                        creeps[k] = nil
                        dirty = true
                    elseif not ((creep.health < damage * 2 and creep.team ~= entityList:GetMyHero().team)  or creep.health < creep.maxHealth * denyRatio) then
                        creeps[k] = nil
                        dirty = true                  
                    end
                end
            end
        end
    end
    if dirty then
        collectgarbage("collect")
    end
end

function IsInScreen(vec)
    local w,h = screenSize.x,screenSize.y
    return vec.x < w and vec.y < h and vec.x > 0 and vec.y > 0
end


function CreateSideBox(hero,x,y)
    _table = {}
    _x = x-location.sideview.w/2
    _y = y-location.sideview.h/2
    _table.border = drawMgr:CreateRect(_x,_y,location.sideview.w,location.sideview.h,0xFFFFFF80,true)
    _table.name = drawMgr:CreateText(_x+3,_y,0xFFFFFF80,hero.name,defaultFont)
    _table.hp = drawMgr:CreateText(_x+3,_y+15,0xFFFFFF80,math.floor(hero.health).." / "..math.floor(hero.maxHealth),defaultFont)
    _table.mana = drawMgr:CreateText(_x+3,_y+30,0xFFFFFF80,math.floor(hero.mana).." / "..math.floor(hero.maxMana),defaultFont)
    if entityList:GetMyHero() then
        _table.distance = drawMgr:CreateText(_x+3,_y+45,0xFFFFFF80,"Distance: "..math.floor(GetDistance2D(entityList:GetMyHero(),hero)),defaultFont)
    end
    return _table
end


function MantainSideBox(hero,x,y,_table)
    if _table and _table.border then
        _x = x-location.sideview.w/2
        _y = y-location.sideview.h/2
        _table.border.x = _x
        _table.border.y = _y
        _table.name.x = _x + 3
        _table.name.y = _y
        --_table.name.text = (hero.name)
        _table.hp.x = _x+3
        _table.hp.y = _y+15
        _table.hp.text = (math.floor(hero.health).." / "..math.floor(hero.maxHealth))
        _table.mana.x = _x+3
        _table.mana.y = _y+30
        _table.mana.text = (math.floor(hero.mana).." / "..math.floor(hero.maxMana))
        if entityList:GetMyHero() and not _table.distance then
            _table.distance = drawMgr:CreateText(_x+3,_y+45,0xFFFFFF80,"Distance: "..math.floor(GetDistance2D(entityList:GetMyHero(),hero)),defaultFont)
        elseif entityList:GetMyHero() and _table.distance then
            _table.distance.x = _x+3
            _table.distance.y = _y+45
            _table.distance.text = ("Distance: "..math.floor(GetDistance2D(entityList:GetMyHero(),hero)))
        elseif _table.distance then
            _table.distance = nil
            collectgarbage("collect")
        end
        return _table
    end
end


function FireEvent( event )
    if event:name() == "dota_roshan_kill" then
        deathTick = client.gameTime
    end
end

do
    screenSize = client.screenSize
    if screenSize.x == 0 and screenSize.y == 0 then
            print("AiO GUI Helper cannot detect your screen resolutions.\nPlease switch to the Borderless Window mode.")
            script:Unload()
    end
    for i,v in ipairs(ResTable) do
            if v[1] == screenSize.x and v[2] == screenSize.y then
                    location = v[3]
                    break
            elseif i == #ResTable then
                    print(screenSize.x.."x"..screenSize.y.." resolution is unsupported by AiO GUI Helper.")
                    script:Unload()
            end
    end

    mmFont = drawMgr:CreateFont("mmFont","Arial",location.ssMonitor.size,500)
end


MinimapMapScaleX = location.minimap.w / MapWidth
MinimapMapScaleY = location.minimap.h / MapHeight

script:RegisterEvent(EVENT_FRAME,Tick)
script:RegisterEvent(EVENT_DOTA,FireEvent)