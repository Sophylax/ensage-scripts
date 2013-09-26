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
            v1.1:
             - Added Advanced Monitor
             - Added enemy couriers to the minimap

            v1.0c:
             - Switched from GetTotalGameTime() to GetGameTime() for stability

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
ScriptConfig:SetName("AIOGUI")
ScriptConfig:SetExtention(-.3)
ScriptConfig:SetVisible(false)

ScriptConfig:AddParam("roshBox","Roshan Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("runeBox","Rune Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("missingMonitor","Missing Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("sideView","SideScreen Monitor",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("cours","Enemy Couriers",SGC_TYPE_TOGGLE,false,true,nil)
ScriptConfig:AddParam("advMon","Advanced Monitor",SGC_TYPE_TOGGLE,false,false,109)


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
fontSize = 10
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

function Tick(tick)
    if not PlayingGame() then
        DeInit()
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

    RoshanTick()

    MissingTick()

    RuneTick()

    SideTick()

    CourierTick()

    AdvancedMonitorTick( tick )
end

function CourierTick()
    local dirty = false
    local enemyCours = entityList:FindEntities({classId = CDOTA_Unit_Courier, alive = true, team = TEAM_ENEMY})
    for i,v in ipairs(enemyCours) do
        if v.visible then
            local courMinimap = MapToMinimap(v)
            local flying = v:GetProperty("CDOTA_Unit_Courier","m_bFlyingCourier")
            if flying then
                if not cours[v.handle] or not cours[v.handle].flying then
                    cours[v.handle] = {}
                    cours[v.handle].icon = drawManager:CreateRectM(courMinimap.x-10,courMinimap.y-6,21,12,"AIOGUI/courier_flying")
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
                    cours[v.handle].icon = drawManager:CreateRectM(courMinimap.x-6,courMinimap.y-6,12,12,"AIOGUI/courier")
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

    if adVisible then

        local STARTXY = Vector2D(5,drawManager.screenHeight-425-location.sideview.b)

        local graphicsTable = advancedMonitor
        local dirty = false
        enemies = entityList:FindEntities({type = TYPE_HERO , team = TEAM_ENEMY , illusion = false}) 

        local i = 1

        for k,v in ipairs(enemies) do
            if not v.illusion then
                if not graphicsTable[v.handle] then
                    graphicsTable[v.handle] = {}
                end

                local topLeft = STARTXY + Vector2D(0,itemSize.y + gapSize.y + extraGap.y) * (i - 1) * 2

                if not advancedMonitor[v.handle].bg then
                    graphicsTable[v.handle].bg = drawManager:CreateRect(topLeft.x-1,topLeft.y-5,348,76,0x000000D0)
                    graphicsTable[v.handle].bg3 = drawManager:CreateRect(topLeft.x-1,topLeft.y-5,348,77,0x000000FF,true)
                    advancedMonitor[v.handle].bg2 = drawManager:CreateRect(topLeft.x + itemSize.x*itemPercent + extraGap.x,topLeft.y+itemSize.y + gapSize.y,itemSize.x*itemPercent*6 + gapSize.x*5,itemSize.y,0x000000D0)
                end

                if not advancedMonitor[v.handle].portrait then

                    --Portrait
                    advancedMonitor[v.handle].portrait = drawManager:CreateRectM(topLeft.x + 3,topLeft.y,itemSize.x,itemSize.y*2 + gapSize.y,"NyanUI/heroes_vertical/"..v.name)

                    --HP
                    local hpPerc = v.health/v.maxHealth
                    local hpColor = ColorTransfusionHealth(hpPerc)
                    advancedMonitor[v.handle].hp = drawManager:CreateText(topLeft.x + 30 ,topLeft.y-5,hpColor,tostring(v.health).."/"..tostring(v.maxHealth))
                    advancedMonitor[v.handle].hpBG = drawManager:CreateRect(topLeft.x + 85,topLeft.y-3,100,8,0x80808080)
                    advancedMonitor[v.handle].hpBar = drawManager:CreateRect(topLeft.x + 85,topLeft.y-3,100*hpPerc,8,hpColor)
                    advancedMonitor[v.handle].hpOut = drawManager:CreateRect(topLeft.x + 85,topLeft.y-3,100,8,hpColor,true)
                    advancedMonitor[v.handle].hpReg = drawManager:CreateText(topLeft.x + 85 ,topLeft.y-5,12,0xFFFFFF80,v.health == v.maxHealth and "" or v.healthRegen > 0 and "+"..tostring(math.floor(v.healthRegen)) or tostring(math.floor(v.healthRegen)))

                    --Mana
                    advancedMonitor[v.handle].mana = drawManager:CreateText(topLeft.x + 30 ,topLeft.y+5,0x2570D6FF,tostring(math.floor(v.mana)).."/"..tostring(math.floor(v.maxMana)))
                    advancedMonitor[v.handle].manaBG = drawManager:CreateRect(topLeft.x + 85,topLeft.y+7,100,8,0x80808080)
                    advancedMonitor[v.handle].manaBar = drawManager:CreateRect(topLeft.x + 85,topLeft.y+7,100*v.mana/v.maxMana,8,0x2570D6FF)
                    advancedMonitor[v.handle].manaOut = drawManager:CreateRect(topLeft.x + 85,topLeft.y+7,100,8,0x2570D6FF,true)
                    advancedMonitor[v.handle].manaReg = drawManager:CreateText(topLeft.x + 85 ,topLeft.y+5,12,0xFFFFFF80,v.mana == v.maxMana and "" or v.manaRegen > 0 and "+"..tostring(math.floor(v.manaRegen)) or tostring(math.floor(v.manaRegen)))

                    --Level
                    advancedMonitor[v.handle].lvl = drawManager:CreateText(topLeft.x + 5,topLeft.y + itemSize.y*2 + gapSize.y + 1,11,0xFFFFFFFF,"L:   "..v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel"))

                    --Attack
                    local attackColor = v.damageBonus > 0 and 0x00FF00FF or v.damageBonus < 0 and 0xFF0000FF or 0xFFFFFFFF
                    advancedMonitor[v.handle].attackIcon = drawManager:CreateRectM(topLeft.x,2 + topLeft.y + itemSize.y*2 + gapSize.y + 10,36,11,"AIOGUI/DamageSword")
                    advancedMonitor[v.handle].attack = drawManager:CreateText(topLeft.x + 12,2 +topLeft.y + itemSize.y*2 + gapSize.y+10,12,attackColor,tostring(math.floor(((v.damageMin+v.damageMax)/2)+v.damageBonus)))

                    --MoveSpeed
                    advancedMonitor[v.handle].moveIcon = drawManager:CreateRectM(topLeft.x + 38,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,"AIOGUI/MSBoots")
                    advancedMonitor[v.handle].moveFade = drawManager:CreateRect(topLeft.x + 38,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    advancedMonitor[v.handle].move = drawManager:CreateText(topLeft.x + 38 ,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,tostring(math.floor(v.moveSpeed)))

                    --Armor
                    advancedMonitor[v.handle].armorIcon = drawManager:CreateRectM(topLeft.x + 59,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,"AIOGUI/ArmorShield")
                    advancedMonitor[v.handle].armorFade = drawManager:CreateRect(topLeft.x + 59,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,0x00000080)
                    local armorColor = v.bonusArmor  > 0 and 0x00FF00FF or v.bonusArmor  < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local e_gap = tostring(v.totalArmor):len() == 1 and 4 or 0
                    advancedMonitor[v.handle].armor = drawManager:CreateText(topLeft.x + 60 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,armorColor,tostring(v.totalArmor))

                    --Magic Resist
                    advancedMonitor[v.handle].magResIcon = drawManager:CreateRectM(topLeft.x + 79,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,"AIOGUI/MagicShield")
                    advancedMonitor[v.handle].magResFade = drawManager:CreateRect(topLeft.x + 79,topLeft.y + itemSize.y*2 + gapSize.y + 2,15,20,0x00000080)
                    local magResistColor = v.magicDmgResist > .25 and v.name ~= "Meepo" and 0x00FF00FF or math.floor(v.magicDmgResist*10000) > 3499 and v.name == "Meepo" and 0x00FF00FF or v.magicDmgResist < .25 and v.name ~= "Meepo" and 0xFF0000FF or math.floor(v.magicDmgResist*10000) < 3499 and v.name == "Meepo" and 0xFF0000FF or 0xFFFFFFFF
                    advancedMonitor[v.handle].magRes = drawManager:CreateText(topLeft.x + 78 ,topLeft.y + itemSize.y*2 + gapSize.y+12,magResistColor,"."..tostring(math.floor(v.magicDmgResist*100)))

                    --Increased Attack Speed
                    advancedMonitor[v.handle].iasIcon = drawManager:CreateRectM(topLeft.x + 98,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,"NyanUI/spellicons/abaddon_frostmourne")
                    advancedMonitor[v.handle].iasFade = drawManager:CreateRect(topLeft.x + 98,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    advancedMonitor[v.handle].ias = drawManager:CreateText(topLeft.x + 98 ,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,tostring(math.floor(v.attackSpeed)))

                    --Strength
                    advancedMonitor[v.handle].strIcon = drawManager:CreateRectM(topLeft.x + 118,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,"AIOGUI/StrIcon")
                    advancedMonitor[v.handle].strFade = drawManager:CreateRect(topLeft.x + 118,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    local strColor = (v.strengthTotal - v.strength)  > 0 and 0x00FF00FF or (v.strengthTotal - v.strength) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local e_gap = tostring(v.strengthTotal):len() == 2 and 4 or 0
                    advancedMonitor[v.handle].str = drawManager:CreateText(topLeft.x + 118 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,strColor,tostring(v.strengthTotal))

                    --Agility
                    advancedMonitor[v.handle].agiIcon = drawManager:CreateRectM(topLeft.x + 138,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,"AIOGUI/AgiIcon")
                    advancedMonitor[v.handle].agiFade = drawManager:CreateRect(topLeft.x + 138,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    local agiColor = (v.agilityTotal - v.agility)  > 0 and 0x00FF00FF or (v.agilityTotal - v.agility) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local e_gap = tostring(v.agilityTotal):len() == 2 and 4 or 0
                    advancedMonitor[v.handle].agi = drawManager:CreateText(topLeft.x + 138 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,agiColor,tostring(v.agilityTotal))

                    --Intelligence
                    advancedMonitor[v.handle].intIcon = drawManager:CreateRectM(topLeft.x + 158,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,"AIOGUI/IntIcon")
                    advancedMonitor[v.handle].intFade = drawManager:CreateRect(topLeft.x + 158,topLeft.y + itemSize.y*2 + gapSize.y + 2,18,18,0x00000080)
                    local intColor = (v.intellectTotal - v.intellect)  > 0 and 0x00FF00FF or (v.intellectTotal - v.intellect) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    local e_gap = tostring(v.intellectTotal):len() == 2 and 4 or 0
                    advancedMonitor[v.handle].int = drawManager:CreateText(topLeft.x + 158 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,intColor,tostring(v.intellectTotal))

                    --Visiblity
                    if missingMonitor.side.heroes[v.handle].missTime.color == 0xFFFFFFFF then
                        advancedMonitor[v.handle].lastSeen = drawManager:CreateText(topLeft.x + 196 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,"Last Seen:"..missingMonitor.side.heroes[v.handle].missTime.text:gsub("Missing:",""))                   
                    else
                        advancedMonitor[v.handle].lastSeen = drawManager:CreateText(topLeft.x + 196 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+12,0xFFFFFFFF,"Last Seen: Now")
                    end
                    advancedMonitor[v.handle].eta = drawManager:CreateText(topLeft.x + 196 +e_gap,topLeft.y + itemSize.y*2 + gapSize.y+24,missingMonitor.side.heroes[v.handle].etaTime.color,"ETA: ")
                else
                    if advancedMonitor[v.handle].lvl.text ~= "L:   "..v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel") then
                        advancedMonitor[v.handle].lvl:SetText("L:   "..v:GetProperty("CDOTA_BaseNPC","m_iCurrentLevel"))
                    end
                    local hpPerc = v.health/v.maxHealth
                    local hpColor = ColorTransfusionHealth(hpPerc)
                    if advancedMonitor[v.handle].hp.color ~= hpColor then
                        advancedMonitor[v.handle].hp.color = hpColor
                        advancedMonitor[v.handle].hpBar.color = hpColor
                        advancedMonitor[v.handle].hpOut.color = hpColor
                    end
                    if advancedMonitor[v.handle].hp.text ~= tostring(v.health).."/"..tostring(v.maxHealth) then
                        advancedMonitor[v.handle].hp:SetText(tostring(v.health).."/"..tostring(v.maxHealth))
                        advancedMonitor[v.handle].hpBar:SetPosition(advancedMonitor[v.handle].hpBar.x,advancedMonitor[v.handle].hpBar.y,math.floor(100*v.health/v.maxHealth),advancedMonitor[v.handle].hpBar.h)
                    end
                    if advancedMonitor[v.handle].hpReg.text ~= v.health == v.maxHealth and "" or v.healthRegen > 0 and "+"..tostring(math.floor(v.healthRegen)) or tostring(math.floor(v.healthRegen)) then
                        advancedMonitor[v.handle].hpReg:SetText(v.health == v.maxHealth and "" or v.healthRegen > 0 and "+"..tostring(math.floor(v.healthRegen)) or tostring(math.floor(v.healthRegen)))
                    end
                    if advancedMonitor[v.handle].mana.text ~= tostring(math.floor(v.mana)).."/"..tostring(math.floor(v.maxMana)) then
                        advancedMonitor[v.handle].mana:SetText(tostring(math.floor(v.mana)).."/"..tostring(math.floor(v.maxMana)))
                        advancedMonitor[v.handle].manaBar:SetPosition(advancedMonitor[v.handle].manaBar.x,advancedMonitor[v.handle].manaBar.y,math.floor(100*v.mana/v.maxMana),advancedMonitor[v.handle].manaBar.h)
                    end
                    if advancedMonitor[v.handle].manaReg.text ~= v.mana == v.maxMana and "" or v.manaRegen > 0 and "+"..tostring(math.floor(v.manaRegen)) or tostring(math.floor(v.manaRegen)) then
                        advancedMonitor[v.handle].manaReg:SetText(v.mana == v.maxMana and "" or v.manaRegen > 0 and "+"..tostring(math.floor(v.manaRegen)) or tostring(math.floor(v.manaRegen)))
                    end

                    local attackColor = v.damageBonus > 0 and 0x00FF00FF or v.damageBonus < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].attack.color ~= attackColor then
                        advancedMonitor[v.handle].attack.color = attackColor
                    end
                    if advancedMonitor[v.handle].attack.text ~= tostring(math.floor(((v.damageMin+v.damageMax)/2)+v.damageBonus)) then
                        advancedMonitor[v.handle].attack:SetText(tostring(math.floor(((v.damageMin+v.damageMax)/2)+v.damageBonus)))
                    end
                    if advancedMonitor[v.handle].move.text ~= tostring(math.floor(v.moveSpeed)) then
                        advancedMonitor[v.handle].move:SetText(tostring(math.floor(v.moveSpeed)))
                    end
                    local armorColor = v.bonusArmor  > 0 and 0x00FF00FF or v.bonusArmor  < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].armor.color ~= armorColor then
                        advancedMonitor[v.handle].armor.color = armorColor
                    end
                    if advancedMonitor[v.handle].armor.text ~= tostring(v.totalArmor) then
                        advancedMonitor[v.handle].armor:SetPosition(advancedMonitor[v.handle].armor.x - 4*(tostring(v.totalArmor):len() - advancedMonitor[v.handle].armor.text:len()),advancedMonitor[v.handle].armor.y)
                        advancedMonitor[v.handle].armor:SetText(tostring(v.totalArmor))
                    end
                    local magResistColor = v.magicDmgResist > .25 and v.name ~= "Meepo" and 0x00FF00FF or math.floor(v.magicDmgResist*10000) > 3499 and v.name == "Meepo" and 0x00FF00FF or v.magicDmgResist < .25 and v.name ~= "Meepo" and 0xFF0000FF or math.floor(v.magicDmgResist*10000) < 3499 and v.name == "Meepo" and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].magRes.color ~= magResistColor then
                        advancedMonitor[v.handle].magRes.color = magResistColor
                    end
                    if advancedMonitor[v.handle].magRes.text ~= "."..tostring(math.floor(v.magicDmgResist*100)) then
                        advancedMonitor[v.handle].magRes:SetText("."..tostring(math.floor(v.magicDmgResist*100)))
                    end
                    if advancedMonitor[v.handle].ias.text ~= tostring(math.floor(v.attackSpeed)) then
                        advancedMonitor[v.handle].ias:SetText(tostring(math.floor(v.attackSpeed)))
                    end
                    local strColor = (v.strengthTotal - v.strength)  > 0 and 0x00FF00FF or (v.strengthTotal - v.strength) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].str.color ~= strColor then
                        advancedMonitor[v.handle].str.color = strColor
                    end
                    if advancedMonitor[v.handle].str.text ~= tostring(math.floor(v.strengthTotal)) then
                        advancedMonitor[v.handle].str:SetText(tostring(math.floor(v.strengthTotal)))
                    end
                    local agiColor = (v.agilityTotal - v.agility)  > 0 and 0x00FF00FF or (v.agilityTotal - v.agility) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].agi.color ~= agiColor then
                        advancedMonitor[v.handle].agi.color = agiColor
                    end
                    if advancedMonitor[v.handle].agi.text ~= tostring(math.floor(v.agilityTotal)) then
                        advancedMonitor[v.handle].agi:SetText(tostring(math.floor(v.agilityTotal)))
                    end
                    local intColor = (v.intellectTotal - v.intellect)  > 0 and 0x00FF00FF or (v.intellectTotal - v.intellect) < 0 and 0xFF0000FF or 0xFFFFFFFF
                    if advancedMonitor[v.handle].int.color ~= intColor then
                        advancedMonitor[v.handle].int.color = intColor
                    end
                    if advancedMonitor[v.handle].int.text ~= tostring(math.floor(v.intellectTotal)) then
                        advancedMonitor[v.handle].int:SetText(tostring(math.floor(v.intellectTotal)))
                    end

                    if advancedMonitor[v.handle].eta.color ~= missingMonitor.side.heroes[v.handle].etaTime.color then
                        advancedMonitor[v.handle].eta.color = missingMonitor.side.heroes[v.handle].etaTime.color
                    end
                    if missingMonitor.side.heroes[v.handle].etaTime.text ~= "   Careful" then
                        if advancedMonitor[v.handle].eta.text ~= missingMonitor.side.heroes[v.handle].etaTime.text then
                            advancedMonitor[v.handle].eta:SetText(missingMonitor.side.heroes[v.handle].etaTime.text)
                        end
                    else
                        if advancedMonitor[v.handle].eta.text ~= "ETA: Now" then
                            advancedMonitor[v.handle].eta:SetText("ETA: Now")
                        end
                    end
                    if missingMonitor.side.heroes[v.handle].missTime.color == 0xFFFFFFFF then
                        if advancedMonitor[v.handle].lastSeen.text ~= "Last Seen:"..missingMonitor.side.heroes[v.handle].missTime.text:gsub("Missing:","") then
                            advancedMonitor[v.handle].lastSeen:SetText("Last Seen:"..missingMonitor.side.heroes[v.handle].missTime.text:gsub("Missing:",""))                   
                        end
                    else
                        if advancedMonitor[v.handle].lastSeen.text ~= "Last Seen: Now" then
                            advancedMonitor[v.handle].lastSeen:SetText("Last Seen: Now")
                        end
                    end
                end

                local spells = {}

                local spellPos = topLeft + Vector2D(200,0)

                for i=1,15 do
                    local ability = v:GetAbility(i)
                    if ability ~= nil then
                        if not ability:IsHidden() and ability.name ~= "attribute_bonus" then
                            spells[#spells+1] = ability
                        end
                    end
                end

                local len = math.floor((wi - ga*#spells + ga)/#spells)
                local font = len == 21 and 10 or len == 26 and 12 or 14
                local c_ga = font == 10 and (len/2 - 6) or (len/2 - 9)

                if not advancedMonitor[v.handle].spells then
                    advancedMonitor[v.handle].spells = {}
                end

                for index,spell in ipairs(spells) do
                    local _font = math.floor(tostring(math.ceil(spell.cd)):len() ~= 1 and font*4/tostring(math.ceil(spell.cd)):len() or font*2)
                    local gap = math.floor(wi*(index-1)/#spells)
                    if not advancedMonitor[v.handle].spells[index] or #spells ~= advancedMonitor[v.handle].spells.spellCount then
                        advancedMonitor[v.handle].spells[index] = {}
                        advancedMonitor[v.handle].spells.spellCount = #spells
                    end
                    if spell.name ~= advancedMonitor[v.handle].spells[index].name or spell.toggled ~= advancedMonitor[v.handle].spells[index].toggled then
                        if spell.name == "troll_warlord_berserkers_rage" and spell.toggled then
                            advancedMonitor[v.handle].spells[index].icon = drawManager:CreateRectM(spellPos.x + gap,spellPos.y,len,len,"NyanUI/spellicons/"..spell.name.."_active")
                        else
                            advancedMonitor[v.handle].spells[index].icon = drawManager:CreateRectM(spellPos.x + gap,spellPos.y,len,len,"NyanUI/spellicons/"..spell.name)
                        end
                        advancedMonitor[v.handle].spells[index].name = spell.name
                        advancedMonitor[v.handle].spells[index].toggle = spell.toggled
                        advancedMonitor[v.handle].spells[index].level = drawManager:CreateText(spellPos.x + gap + c_ga,spellPos.y+len,font,0xFFFFFFFF,"L. "..spell.level)
                        advancedMonitor[v.handle].spells[index].border = drawManager:CreateRect(spellPos.x + gap-1,spellPos.y-1,len+1,len+1,0x00000001,true)
                        advancedMonitor[v.handle].spells[index].effect = drawManager:CreateRect(spellPos.x + gap,spellPos.y,len,len,0x00000001)
                        advancedMonitor[v.handle].spells[index].cd = drawManager:CreateText(spellPos.x + wi*(index-1)/#spells+c_ga/2,spellPos.y+c_ga/2,_font,0xFFFFFFFF,"")
                        dirty = true
                    end
                    if spell.state == STATE_COOLDOWN then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x000000FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x000000FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x000000D0 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x000000D0
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= ""..math.ceil(spell.cd) then
                            advancedMonitor[v.handle].spells[index].cd:SetText(""..math.ceil(spell.cd))
                        end
                    elseif spell.state == STATE_NOMANA then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x0000A0FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x0000A0FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x3030A0D0 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x3030A0D0
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd:SetText("")
                        end
                    elseif (spell.state == STATE_NOTLEARNED or spell.state == 84) and not spell.name:find("empty") then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x404040FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x404040FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x404040D0 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x404040D0
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd:SetText("")
                        end
                    elseif spell.state == STATE_READY then
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x808080FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x808080FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x00000001 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x00000001
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd:SetText("")
                        end
                    elseif spell.state == 17 then --Passive Spells
                        if advancedMonitor[v.handle].spells[index].border.color ~= 0x000000FF then
                            advancedMonitor[v.handle].spells[index].border.color = 0x000000FF
                        end
                        if advancedMonitor[v.handle].spells[index].effect.color ~= 0x00000001 then
                            advancedMonitor[v.handle].spells[index].effect.color = 0x00000001
                        end
                        if advancedMonitor[v.handle].spells[index].cd.text ~= "" then
                            advancedMonitor[v.handle].spells[index].cd:SetText("")
                        end

                    end
                end

                --ItemShowing

                if not advancedMonitor[v.handle].items then
                    advancedMonitor[v.handle].items = {}
                end

                local stashState = DoesHeroHasStashItems(v)

                if not advancedMonitor[v.handle].stashText then
                    advancedMonitor[v.handle].stashBg = drawManager:CreateRect(topLeft.x + 350 ,topLeft.y-4,60,75,0x000000D0)
                    advancedMonitor[v.handle].stashText = drawManager:CreateText(topLeft.x + 360 ,topLeft.y-4,0xFFFFFFFF,"STASH")
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
                        if item.name == "item_power_treads" then
                            if item.bootsState == PT_AGI then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads_agi" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "power_treads_agi"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/power_treads_agi")
                                    dirty = true
                                end
                            elseif item.bootsState == PT_INT then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads_int" then
                                    advancedMonitor[v.handle].items[itemSlot].name = "power_treads_int"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/power_treads_int")
                                    dirty = true
                                end
                            elseif item.bootsState == PT_STR then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads_str" then  
                                    advancedMonitor[v.handle].items[itemSlot].name = "power_treads_str"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/power_treads_str")
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "power_treads" then  
                                advancedMonitor[v.handle].items[itemSlot].name = "power_treads"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/power_treads")
                                dirty = true
                            end
                        elseif item.name == "item_armlet" then
                            if item.toggled then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "armlet_active" then 
                                    advancedMonitor[v.handle].items[itemSlot].name = "armlet_active"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/armlet_active")
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "armlet" then    
                                advancedMonitor[v.handle].items[itemSlot].name = "armlet"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/armlet")
                                dirty = true
                            end
                        elseif item.name == "item_radiance" then
                            if item.toggled then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "radiance_inactive" then 
                                    advancedMonitor[v.handle].items[itemSlot].name = "radiance_inactive"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/radiance_inactive")
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "radiance" then  
                                advancedMonitor[v.handle].items[itemSlot].name = "radiance"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/radiance")
                                dirty = true
                            end
                        elseif item.name == "item_tranquil_boots" then
                            if item.charges == 3 then
                                if advancedMonitor[v.handle].items[itemSlot].name ~= "tranquil_boots_active" then 
                                    advancedMonitor[v.handle].items[itemSlot].name = "tranquil_boots_active"
                                    advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/tranquil_boots_active")
                                    dirty = true
                                end
                            elseif advancedMonitor[v.handle].items[itemSlot].name ~= "tranquil_boots" then    
                                advancedMonitor[v.handle].items[itemSlot].name = "tranquil_boots"
                                advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/tranquil_boots")
                                dirty = true
                            end
                        elseif advancedMonitor[v.handle].items[itemSlot].name ~= item.name then
                            advancedMonitor[v.handle].items[itemSlot].name = item.name
                            advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/"..item.name:gsub("item_",""))
                            dirty = true
                        end
                        if item.charges > 0 and item.name ~= "item_tranquil_boots" then
                            if advancedMonitor[v.handle].items[itemSlot].charges ~= item.charges then
                                if not advancedMonitor[v.handle].items[itemSlot].charges then
                                    advancedMonitor[v.handle].items[itemSlot].charges = item.charges
                                    advancedMonitor[v.handle].items[itemSlot].chargeBG = drawManager:CreateRect(itemXY.x + itemSize.x*itemPercent - fontSize,itemXY.y + itemSize.y - fontSize,fontSize,fontSize,0x000000D0)
                                    advancedMonitor[v.handle].items[itemSlot].chargeText = drawManager:CreateText(itemXY.x + itemSize.x*itemPercent - fontSize*7/10,itemXY.y + itemSize.y - fontSize,fontSize,0xFFFFFFFF,tostring(item.charges))
                                    dirty = true
                                else
                                    advancedMonitor[v.handle].items[itemSlot].charges = item.charges
                                    advancedMonitor[v.handle].items[itemSlot].chargeText:SetText(tostring(item.charges))
                                end
                            end
                        elseif advancedMonitor[v.handle].items[itemSlot].chargeBG then
                            advancedMonitor[v.handle].items[itemSlot].charges = nil
                            advancedMonitor[v.handle].items[itemSlot].chargeBG = nil
                            advancedMonitor[v.handle].items[itemSlot].chargeText = nil
                            dirty = true
                        end
                        if not advancedMonitor[v.handle].items[itemSlot].effect then
                            if item.state == STATE_NOMANA then
                                advancedMonitor[v.handle].items[itemSlot].effect = drawManager:CreateRect(itemXY.x,itemXY.y,itemSize.x*itemPercent,itemSize.y,0x3030A0D0)
                            elseif item.state == STATE_ITEMCOOLDOWN then
                                advancedMonitor[v.handle].items[itemSlot].effect = drawManager:CreateRect(itemXY.x,itemXY.y,itemSize.x*itemPercent,itemSize.y,0x000000D0)
                            else
                                advancedMonitor[v.handle].items[itemSlot].effect = drawManager:CreateRect(itemXY.x,itemXY.y,itemSize.x*itemPercent,itemSize.y,0x00000001)
                            end
                        else
                            if item.state == STATE_NOMANA then
                                if advancedMonitor[v.handle].items[itemSlot].effect.color ~= 0x3030A0D0 then
                                    advancedMonitor[v.handle].items[itemSlot].effect.color = 0x3030A0D0
                                end
                            elseif item.state == STATE_ITEMCOOLDOWN then
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
                            _cd = _cd > 0 and _cd or ""
                            advancedMonitor[v.handle].items[itemSlot].cd = _cd
                            advancedMonitor[v.handle].items[itemSlot].cdGap = xGap
                            advancedMonitor[v.handle].items[itemSlot].cdText = drawManager:CreateText(itemXY.x + xGap,itemXY.y + 1,14,0xFFFFFFD0,tostring(math.ceil(item.cd)))
                        elseif math.ceil(item.cd) ~= advancedMonitor[v.handle].items[itemSlot].cd then
                            local _cd = math.ceil(item.cd)
                            local xGap = _cd > 99 and 3 or _cd > 9 and 5 or 9
                            _cd = _cd > 0 and _cd or ""
                            advancedMonitor[v.handle].items[itemSlot].cdText:SetText(tostring(_cd))
                            advancedMonitor[v.handle].items[itemSlot].cdText.x = advancedMonitor[v.handle].items[itemSlot].cdText.x + xGap - advancedMonitor[v.handle].items[itemSlot].cdGap
                            advancedMonitor[v.handle].items[itemSlot].cd = _cd
                            advancedMonitor[v.handle].items[itemSlot].cdGap = xGap
                        end
                    elseif not hide and advancedMonitor[v.handle].items[itemSlot].name ~= "empty" then
                        advancedMonitor[v.handle].items[itemSlot].charges = nil
                        advancedMonitor[v.handle].items[itemSlot].chargeBG = nil
                        advancedMonitor[v.handle].items[itemSlot].chargeText = nil
                        advancedMonitor[v.handle].items[itemSlot].name = "empty"
                        advancedMonitor[v.handle].items[itemSlot].icon = drawManager:CreateRectM(itemXY.x,itemXY.y,itemSize.x,itemSize.y,"NyanUI/items/emptyitembg")
                        dirty = true
                    end

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
    local heroes = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY})
    for i,v in ipairs(heroes) do
        if not v.illusion then
            if missingMonitor.side.heroes[v.handle] == nil then
                heroCount = heroCount + 1
                missingMonitor.side.heroes[v.handle] = {}
                missingMonitor.side.heroes[v.handle].bmp = drawManager:CreateRectM(location.ssMonitor.x,location.ssMonitor.y+location.ssMonitor.h*(heroCount-1),32,32,"NyanUI/miniheroes/"..v.name)
                missingMonitor.side.heroes[v.handle].missTime = drawManager:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+location.ssMonitor.h*(heroCount-1),location.ssMonitor.size,0x00000000,"Missing: ")
                missingMonitor.side.heroes[v.handle].etaTime = drawManager:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+location.ssMonitor.size+location.ssMonitor.h*(heroCount-1),location.ssMonitor.size,0x00000000,"ETA: ")
                missingMonitor.side.heroes[v.handle].visibleText = drawManager:CreateText(location.ssMonitor.x + 40,location.ssMonitor.y+location.ssMonitor.size/2+2+location.ssMonitor.h*(heroCount-1),location.ssMonitor.size,0xFFFFFFFF,"  Visible")
                missingMonitor.side.heroes[v.handle].miniBMP = nil
                missingMonitor.side.heroes[v.handle].mapText = {}
                missingMonitor.side.heroes[v.handle].mapText.top = nil
                missingMonitor.side.heroes[v.handle].mapText.bot = nil
            end
            if v.visible then
                if v:DoesHaveModifier("modifier_treant_natures_guise") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_rune_invis") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_weaver_shukuchi") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_phantom_lancer_doppelwalk_invis") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_item_invisibility_edge_windwalk") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_clinkz_wind_walk") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_bounty_hunter_wind_walk") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_nyx_assassin_vendetta") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_broodmother_spin_web_invisible_applier") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_lycan_summon_wolves_invisibility") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_sandking_sand_storm_invis") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_riki_permanent_invisibility") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_invisible") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_persistent_invisibility") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_mirana_moonlight_shadow") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_templar_assassin_meld") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_slark_shadow_dance") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_invoker_ghost_walk_self") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_item_shadow_amulet_fade") then
                    missingMonitor.side.heroes[v.handle].customText = "Invis"
                elseif v:DoesHaveModifier("modifier_smoke_of_deceit") then
                    missingMonitor.side.heroes[v.handle].customText = "Smoked"
                else
                    missingMonitor.side.heroes[v.handle].customText = nil
                end
            end
            if lastseenList[v.handle] == nil and v.visible == false then
                lastseenList[v.handle] = GetGameTime()
                missingMonitor.side.heroes[v.handle].missTime.color = 0xFFFFFFFF
                missingMonitor.side.heroes[v.handle].etaTime.color = 0xFFFFFFFF
                missingMonitor.side.heroes[v.handle].visibleText.color = 0x00000000
            elseif v.visible == true then
                lastseenList[v.handle] = nil
                missingMonitor.side.heroes[v.handle].missTime.color = 0x00000000
                missingMonitor.side.heroes[v.handle].etaTime.color = 0x00000000
                missingMonitor.side.heroes[v.handle].visibleText.color = 0xFFFFFFFF
                if missingMonitor.side.heroes[v.handle].miniBMP then
                    missingMonitor.side.heroes[v.handle].miniBMP:Destroy()
                    missingMonitor.side.heroes[v.handle].miniBMP = nil
                end
                if missingMonitor.side.heroes[v.handle].mapText.top then
                    missingMonitor.side.heroes[v.handle].mapText.top:Destroy()
                   missingMonitor.side.heroes[v.handle].mapText.top = nil
                    missingMonitor.side.heroes[v.handle].mapText.bot:Destroy()
                   missingMonitor.side.heroes[v.handle].mapText.bot = nil
                    missingMonitor.side.heroes[v.handle].mapText.eff = nil
                    collectgarbage("collect")
                end
            end
            if (not v.visible or not me ) and not v.illusion then
                --Minimap Draw
                local coord = MapToMinimap(v.x,v.y)
                if not missingMonitor.side.heroes[v.handle].miniBMP then
                    missingMonitor.side.heroes[v.handle].miniBMP = drawManager:CreateRectM(coord.x-8,coord.y-8,16,16,"NyanUI/miniheroes/"..v.name)
                end

                --Mainmap Draw
                local pos = Vector()
                if v:ScreenPosition(pos) and IsInScreen(pos) and v.alive then
                    if SleepCheck(v.handle.."ef") and ScriptConfig.missingMonitor then
                        local side = Vector(3*math.cos(v.rotR + math.pi/2),3*math.sin(v.rotR + math.pi/2),0)
                        local front = Vector(4*math.cos(v.rotR),4*math.sin(v.rotR),0)
                        missingMonitor.side.heroes[v.handle].mapText.eff = {
                            Effect(v.position+(side*6),"draw_commentator"),
                            Effect(v.position+(side*5)+(front),"draw_commentator"),
                            Effect(v.position+(side*4)+(front*2),"draw_commentator"),
                            Effect(v.position+(side*3)+(front*3),"draw_commentator"),
                            Effect(v.position+(side*2)+(front*4),"draw_commentator"),
                            Effect(v.position+(side)+(front*5),"draw_commentator"),
                            Effect(v.position+(front*6),"draw_commentator"),
                            Effect(v.position-(side*1)+(front*5),"draw_commentator"),
                            Effect(v.position-(side*2)+(front*4),"draw_commentator"),
                            Effect(v.position-(side*3)+(front*3),"draw_commentator"),
                            Effect(v.position-(side*4)+(front*2),"draw_commentator"),
                            Effect(v.position-(side*5)+(front),"draw_commentator"),
                            Effect(v.position-(side*6),"draw_commentator"),
                        }
                        for k,l in ipairs(missingMonitor.side.heroes[v.handle].mapText.eff) do
                            l:SetParameter(Vector(255,255,255))
                        end
                        Sleep(500,v.handle.."ef")
                        collectgarbage("collect")
                    end
                    if not ScriptConfig.missingMonitor then
                        missingMonitor.side.heroes[v.handle].mapText.eff = nil
                        collectgarbage("collect")
                    end

                    if not missingMonitor.side.heroes[v.handle].mapText.top then
                        missingMonitor.side.heroes[v.handle].mapText.top = drawManager:CreateText(math.floor(pos.x),math.floor(pos.y)-30,0xFFFFFFFF,v.name)
                        missingMonitor.side.heroes[v.handle].mapText.bot = drawManager:CreateText(math.floor(pos.x),math.floor(pos.y)-15,0xFFFFFFFF,math.floor(100*v.health/v.maxHealth).."% HP")
                    elseif missingMonitor.side.heroes[v.handle].mapText.top.x ~= math.floor(pos.x) or missingMonitor.side.heroes[v.handle].mapText.top.y ~= math.floor(pos.y)-30 then
                        missingMonitor.side.heroes[v.handle].mapText.top:SetPosition(math.floor(pos.x),math.floor(pos.y)-30)
                        missingMonitor.side.heroes[v.handle].mapText.bot:SetPosition(math.floor(pos.x),math.floor(pos.y)-15)
                    end
                elseif missingMonitor.side.heroes[v.handle].mapText.top then
                    missingMonitor.side.heroes[v.handle].mapText.top:Destroy()
                    missingMonitor.side.heroes[v.handle].mapText.bot:Destroy()
                    missingMonitor.side.heroes[v.handle].mapText.top = nil
                    missingMonitor.side.heroes[v.handle].mapText.bot = nil
                end

                --Miss timer
                local delta = GetGameTime() - lastseenList[v.handle]
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
                missingMonitor.side.heroes[v.handle].missTime:SetText(ssText)

                --ETA timer
                local distance = GetDistance2D(v,me)
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
                missingMonitor.side.heroes[v.handle].etaTime:SetText(proxText)
            end
        end
    end
end

function SideTick()
    local pos = Vector()
    local _x
    local _y
    local center = {x = drawManager.screenWidth/2 , y = drawManager.screenHeight/2}
    enemies = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY,alive=true})
    for i,v in ipairs(enemies) do
        if v:ScreenPosition(pos) and v.replicatingModel == -1 and not v.illusion and v.visible then
            if pos.x < 0 or pos.x > drawManager.screenWidth or pos.y < location.sideview.t or pos.y > drawManager.screenHeight - location.sideview.b then
                local slope = (pos.y - center.y) / (pos.x - center.x)
                if (pos.x - center.x < 0 and slope < (drawManager.screenHeight/2-location.sideview.t)/(drawManager.screenWidth/2) and slope > -(drawManager.screenHeight/2-location.sideview.b)/(drawManager.screenWidth/2)) or (pos.x - center.x >= 0 and slope > -(drawManager.screenHeight/2-location.sideview.t)/(drawManager.screenWidth/2) and slope < (drawManager.screenHeight/2-location.sideview.b)/(drawManager.screenWidth/2)) then
                    if pos.x < 0 then
                        _x = location.sideview.w
                        _y = math.floor(center.y + slope * (_x - center.x))
                    else
                        _x = drawManager.screenWidth - location.sideview.w
                        _y = math.floor(center.y + slope * (_x - center.x))
                    end
                else
                    if pos.y < location.sideview.t then
                        _y = location.sideview.t
                        _x = math.floor(center.x + (_y-center.y)/slope)
                    else
                        _y = drawManager.screenHeight - location.sideview.b
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
                        sideView[v.handle].border:Destroy()
                        sideView[v.handle].border = nil
                    end
                    if sideView[v.handle].name then
                        sideView[v.handle].name:Destroy()
                        sideView[v.handle].name = nil
                    end
                    if sideView[v.handle].hp then
                        sideView[v.handle].hp:Destroy()
                        sideView[v.handle].hp = nil
                    end
                    if sideView[v.handle].mana then
                        sideView[v.handle].mana:Destroy()
                        sideView[v.handle].mana = nil
                    end
                    if sideView[v.handle].distance then
                        sideView[v.handle].distance:Destroy()
                        sideView[v.handle].distance = nil
                    end
                end
            else
                if sideView[v.handle] then
                    if sideView[v.handle].border then
                        sideView[v.handle].border:Destroy()
                        sideView[v.handle].border = nil
                    end
                    if sideView[v.handle].name then
                        sideView[v.handle].name:Destroy()
                        sideView[v.handle].name = nil
                    end
                    if sideView[v.handle].hp then
                        sideView[v.handle].hp:Destroy()
                        sideView[v.handle].hp = nil
                    end
                    if sideView[v.handle].mana then
                        sideView[v.handle].mana:Destroy()
                        sideView[v.handle].mana = nil
                    end
                    if sideView[v.handle].distance then
                        sideView[v.handle].distance:Destroy()
                        sideView[v.handle].distance = nil
                    end
                    sideView[v.handle] = nil
                end
            end
        elseif sideView[v.handle] then
            if sideView[v.handle].border then
                sideView[v.handle].border:Destroy()
                sideView[v.handle].border = nil
            end
            if sideView[v.handle].name then
                sideView[v.handle].name:Destroy()
                sideView[v.handle].name = nil
            end
            if sideView[v.handle].hp then
                sideView[v.handle].hp:Destroy()
                sideView[v.handle].hp = nil
            end
            if sideView[v.handle].mana then
                sideView[v.handle].mana:Destroy()
                sideView[v.handle].mana = nil
            end
            if sideView[v.handle].distance then
                sideView[v.handle].distance:Destroy()
                sideView[v.handle].distance = nil
            end
        end
    end
end

function RoshanTick()
    --Roshan monitoring
    if deathTick and RoshAlive() then
            deathTick = nil
    end

    if deathTick then
        local minutes = math.floor(tickDelta/60)
        local seconds = tickDelta%60
        roshBox.text:SetText(string.format("Roshan: %02d:%02d",9-minutes,59-seconds))
    elseif roshBox.text.text ~= "Roshan: Alive" then
        roshBox.text:SetText("Roshan: Alive")
    end
end

function RuneTick()
    --Rune monitoring
    local runes = entityList:FindEntities({classId=CDOTA_Item_Rune})
    if #runes == 0 then
            if minimapRune then
                minimapRune:Destroy()
                minimapRune = nil
            end
            runeBox.bmp:Destroy()
            runeBox.bmp = drawManager:CreateRectM(location.rune.x,location.rune.y+1,28,14,"NyanUI/items/bottle_empty")
            runeBox.bmp.visible = ScriptConfig.runeBox
            runeBox.text:SetText("No Rune")
            return 
    end
    if  runeBox.text.text ~= "No Rune" then
            return
    end
    local rune = runes[1]
    local runeType = rune.runeType
    filename = ""
    if runeType == RUNETYPE_DOUBLEDAMAGE then
            runeMsg = "DD"
            filename = "doubledamage"
    elseif runeType == RUNETYPE_HASTE then
            runeMsg = "Haste"
            filename = "haste"
    elseif runeType == RUNETYPE_ILLUSION then
            runeMsg = "Illu"
            filename = "illusion"
    elseif runeType == RUNETYPE_INVISIBILITY then
            runeMsg = "Invis"
            filename = "invis"
    elseif runeType == RUNETYPE_REGENERATION then
            runeMsg = "Reg"
            filename = "regen"
    else
            runeMsg = "???"
    end
    if not mnimapRune then
        local runeMinimap = MapToMinimap(rune)
        local size = 20
        minimapRune = drawManager:CreateRectM(runeMinimap.x-size/2,runeMinimap.y-size/2,size,size,"/NyanUI/minirunes/"..filename)
        minimapRune.visible = ScriptConfig.runeBox
        if rune.x == -2272 then
                runeMsg = runeMsg .. " TOP"
        else
                runeMsg = runeMsg .. " BOT"
        end
        runeBox.text:SetText(runeMsg)
        runeBox.bmp:Destroy()
        runeBox.bmp = drawManager:CreateRectM(location.rune.x,location.rune.y,16,16,"/NyanUI/runes/"..filename)
        runeBox.bmp.visible = ScriptConfig.runeBox
    end
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
                _x = x.x - MapLeft
                _y = x.y - MapBottom
        else
                _x = x - MapLeft
                _y = y - MapBottom
        end
        
        local scaledX = math.min(math.max(_x * MinimapMapScaleX, 0), location.minimap.w)
        local scaledY = math.min(math.max(_y * MinimapMapScaleY, 0), location.minimap.h)
        
        local screenX = location.minimap.px + scaledX
        local screenY = drawManager.screenHeight - scaledY - location.minimap.py
        
        return { x = math.floor(screenX), y = math.floor(screenY) }
end

--Function returns whether roshan is alive or not
function RoshAlive()
        local entities = entityList:FindEntities({classId=CDOTA_Unit_Roshan})
        tickDelta = GetGameTime()-deathTick
        if #entities > 0 and tickDelta > 15 then
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

        roshBox = {}
        roshBox.inside = drawManager:CreateRect(location.rosh.x,location.rosh.y,95,18,0x000000FF)
        roshBox.inBorder = drawManager:CreateRect(location.rosh.x-1,location.rosh.y-1,97,20,0x000000A0,true)
        roshBox.outBorder = drawManager:CreateRect(location.rosh.x-2,location.rosh.y-2,99,22,0x00000050,true)
        roshBox.bmp = drawManager:CreateRectM(location.rosh.x,location.rosh.y,16,16,"NyanUI/miniheroes/roshan")
        roshBox.text = drawManager:CreateText(location.rosh.x+20,location.rosh.y+3,0xFFFFFFFF,"Roshan: Alive")

        runeBox = {}
        runeBox.inside = drawManager:CreateRect(location.rune.x,location.rune.y,95,18,0x000000FF)
        runeBox.inBorder = drawManager:CreateRect(location.rune.x-1,location.rune.y-1,97,20,0x000000A0,true)
        runeBox.outBorder = drawManager:CreateRect(location.rune.x-2,location.rune.y-2,99,22,0x00000050,true)
        runeBox.bmp = drawManager:CreateRectM(location.rune.x,location.rune.y+1,28,14,"NyanUI/items/bottle_empty")
        runeBox.text = drawManager:CreateText(location.rune.x+20,location.rune.y+3,0xFFFFFFFF,"No Rune")

        minimapRune = nil

        missingMonitor = {}
        missingMonitor.miniMap = {}
        missingMonitor.side = {}

        missingMonitor.side.inside = drawManager:CreateRect(location.ssMonitor.x,location.ssMonitor.y,location.ssMonitor.w,5*location.ssMonitor.h,0x000000FF)
        missingMonitor.side.inBorder = drawManager:CreateRect(location.ssMonitor.x-1,location.ssMonitor.y-1,location.ssMonitor.w+2,5*location.ssMonitor.h+2,0x000000A0,true)
        missingMonitor.side.outBorder = drawManager:CreateRect(location.ssMonitor.x-2,location.ssMonitor.y-2,location.ssMonitor.w+4,5*location.ssMonitor.h+4,0x00000050,true)
        missingMonitor.side.heroes = {}

        sideView = {}

        init = true
    end
end

function IsInScreen(vec)
    local w,h = drawManager.screenWidth,drawManager.screenHeight
    return vec.x < w and vec.y < h and vec.x > 0 and vec.y > 0
end


function CreateSideBox(hero,x,y)
    _table = {}
    _x = x-location.sideview.w/2
    _y = y-location.sideview.h/2
    _table.border = drawManager:CreateRect(_x,_y,location.sideview.w,location.sideview.h,0xFFFFFF80,true)
    _table.name = drawManager:CreateText(_x+3,_y,0xFFFFFF80,hero.name)
    _table.hp = drawManager:CreateText(_x+3,_y+15,0xFFFFFF80,math.floor(hero.health).." / "..math.floor(hero.maxHealth))
    _table.mana = drawManager:CreateText(_x+3,_y+30,0xFFFFFF80,math.floor(hero.mana).." / "..math.floor(hero.maxMana))
    if me then
        _table.distance = drawManager:CreateText(_x+3,_y+45,0xFFFFFF80,"Distance: "..math.floor(GetDistance2D(me,hero)))
    end
    return _table
end


function MantainSideBox(hero,x,y,_table)
    if _table and _table.border then
        _x = x-location.sideview.w/2
        _y = y-location.sideview.h/2
        _table.border:SetPosition(_x,_y,location.sideview.w,location.sideview.h)
        _table.name:SetPosition(_x+3,_y)
        --_table.name:SetText(hero.name)
        _table.hp:SetPosition(_x+3,_y+15)
        _table.hp:SetText(math.floor(hero.health).." / "..math.floor(hero.maxHealth))
        _table.mana:SetPosition(_x+3,_y+30)
        _table.mana:SetText(math.floor(hero.mana).." / "..math.floor(hero.maxMana))
        if me and not _table.distance then
            _table.distance = drawManager:CreateText(_x+3,_y+45,0xFFFFFF80,"Distance: "..math.floor(GetDistance2D(me,hero)))
        elseif me and _table.distance then
            _table.distance:SetPosition(_x+3,_y+45)
            _table.distance:SetText("Distance: "..math.floor(GetDistance2D(me,hero)))
        elseif _table.distance then
            _table.distance:Destroy()
            _table.distance = nil
        end
        return _table
    end
end


function FireEvent( name )
    if name == "dota_roshan_kill" then
            deathTick = GetGameTime()
    end
end

function GetDistance2D(a,b)
    return math.sqrt(math.pow(a.x-b.x,2)+math.pow(a.y-b.y,2))
end

do
    local w,h = drawManager.screenWidth,drawManager.screenHeight
    if w == 0 and h == 0 then
            print("AiO GUI Helper cannot detect your screen resolutions.\nPlease switch to the Borderless Window mode.")
            script:Unload()
    end
    for i,v in ipairs(ResTable) do
            if v[1] == w and v[2] == h then
                    location = v[3]
                    break
            elseif i == #ResTable then
                    print(w.."x"..h.." resolution is unsupported by AiO GUI Helper.")
                    script:Unload()
            end
    end
end


MinimapMapScaleX = location.minimap.w / MapWidth
MinimapMapScaleY = location.minimap.h / MapHeight

script:RegisterEvent(EVENT_FRAME,Tick)
script:RegisterEvent(EVENT_DOTA,FireEvent)